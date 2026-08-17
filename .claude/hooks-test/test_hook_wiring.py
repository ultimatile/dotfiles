"""Properties every hook must hold regardless of what it checks.

A hook that crashes exits non-zero, which the harness reports as a non-blocking
error — the command then runs. So a crash is not a loud failure but a silently
disabled guard, and it is worth testing the paths that could cause one.
"""

from __future__ import annotations

import shutil
import sys
from pathlib import Path

import pytest
from conftest import HOOKS_DIR, HookRunner, child_env

# Hooks that import the shared `shell_tokens` module, paired with a command each
# one is known to deny. A deny proves the import resolved — a hook whose sibling
# import failed would abort before reaching any decision. It does not always
# prove the hook's own check ran; see block-git-discard below.
SHARED_MODULE_HOOKS = [
    ("block-rg-replace-confusion.py", "rg -rn pat src"),
    ("block-broad-fs-scan.py", "fd foo /"),
    # block-git-discard denies here because the payload carries no working
    # directory, which is its fail-closed path rather than a measurement. That
    # still discharges what this table is for — a hook whose sibling import
    # failed would abort before reaching any decision — but it is not evidence
    # that the measurement works; test_block_git_discard.py owns that.
    ("block-git-discard.py", "git checkout -- f"),
]


@pytest.mark.parametrize(("hook", "denied_command"), SHARED_MODULE_HOOKS)
def test_sibling_import_survives_safe_path(
    deny_reason: HookRunner, hook: str, denied_command: str
) -> None:
    """PYTHONSAFEPATH=1 drops the script's own directory from sys.path, which is
    where `shell_tokens` lives. The hooks add that directory back explicitly.
    """
    assert deny_reason(hook, denied_command, {"PYTHONSAFEPATH": "1"}) is not None


@pytest.mark.parametrize(("hook", "denied_command"), SHARED_MODULE_HOOKS)
def test_runs_from_an_unrelated_cwd(
    deny_reason: HookRunner, hook: str, denied_command: str, tmp_path: Path
) -> None:
    """The harness picks the working directory, so nothing may depend on it —
    including how the shared module is located.
    """
    assert deny_reason(hook, denied_command, None, tmp_path) is not None


@pytest.mark.parametrize("hook", [h for h, _ in SHARED_MODULE_HOOKS])
def test_empty_command_is_allowed(deny_reason: HookRunner, hook: str) -> None:
    """No command to inspect must mean "let it through", never a crash."""
    assert deny_reason(hook, "") is None


def test_runner_interpreter_does_not_leak_into_the_hooks() -> None:
    """`uvx pytest` and friends put their own `python3` first on PATH; if that
    reached the hooks, the suite would silently test a different Python from the
    one the harness resolves. Whichever runner is in use, the `python3` a hook
    sees must not come from the runner's environment.
    """
    resolved = shutil.which("python3", path=child_env()["PATH"])
    assert resolved is not None, "no python3 left on PATH for the hooks' shebang"
    assert Path(sys.prefix) not in Path(resolved).parents, (
        f"hooks would run under the test runner's interpreter: {resolved}"
    )


def test_hooks_are_executable() -> None:
    """settings.json invokes them by path, so the shebang has to be usable."""
    for hook, _ in SHARED_MODULE_HOOKS:
        path = HOOKS_DIR / hook
        assert path.exists(), path
        assert path.stat().st_mode & 0o111, f"{hook} is not executable"
