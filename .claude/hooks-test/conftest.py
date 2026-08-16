"""Test support for the PreToolUse hooks in ../hooks.

Hook filenames are dash-separated and therefore not importable, so behaviour is
exercised the way the harness invokes them: a JSON payload on stdin, a decision
(or nothing) on stdout. `shell_tokens` is importable and unit-tested directly.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from collections.abc import Callable
from pathlib import Path
from typing import Protocol

import pytest

HOOKS_DIR = Path(__file__).resolve().parent.parent / "hooks"

# Let test modules `import shell_tokens` the same way the hooks do. Runs at
# collection time, before the test modules themselves are imported.
sys.path.insert(0, str(HOOKS_DIR))


def child_env(extra: dict[str, str] | None = None) -> dict[str, str]:
    """The environment a hook is launched with, minus the test runner's own bin dir.

    The hooks resolve their interpreter through their shebang, so what PATH means
    to a child process decides what is under test. A runner like `uvx pytest`
    prepends its own tool-environment bin, and the hooks would then run under that
    environment rather than the one a normal shell hands the harness. Dropping the
    runner's bin dir keeps the choice of test runner from silently changing the
    subject.
    """
    env = {**os.environ, **(extra or {})}
    runner_bin = Path(sys.prefix) / "bin"
    kept = [
        p for p in env.get("PATH", "").split(os.pathsep) if p and Path(p) != runner_bin
    ]
    env["PATH"] = os.pathsep.join(kept)
    return env


class HookRunner(Protocol):
    """(hook, command[, extra_env][, cwd][, payload_cwd]) -> deny reason, or None."""

    def __call__(
        self,
        hook: str,
        command: str,
        extra_env: dict[str, str] | None = None,
        cwd: Path | None = None,
        *,
        payload_cwd: Path | str | None = None,
    ) -> str | None: ...


def _run_hook(
    hook: str,
    command: str,
    extra_env: dict[str, str] | None = None,
    cwd: Path | None = None,
    *,
    payload_cwd: Path | str | None = None,
) -> str | None:
    """Run a hook against a Bash command; return its deny reason, or None if allowed.

    Executes the script itself rather than passing it to `sys.executable`, which
    is how settings.json invokes it: the shebang picks the interpreter, so the
    hooks are tested under the same Python the harness gives them no matter which
    interpreter happens to be running pytest. It also puts the sibling-module
    import and the executable bit inside what gets tested.

    `cwd` sets the subprocess's directory; `payload_cwd` sets the `cwd` field of
    the JSON payload. The harness supplies both and they normally agree, but a
    hook that resolves paths from the payload has to keep working when they do
    not, so they are controlled separately here. `payload_cwd` is keyword-only:
    an existing caller passes `cwd` positionally, and both are path-typed, so a
    positional insertion would silently rebind it with nothing to catch the swap.
    """
    script = HOOKS_DIR / hook
    payload: dict[str, object] = {"tool_input": {"command": command}}
    if payload_cwd is not None:
        payload["cwd"] = str(payload_cwd)
    proc = subprocess.run(
        [str(script)],
        input=json.dumps(payload),
        capture_output=True,
        text=True,
        check=False,
        env=child_env(extra_env),
        cwd=cwd,
    )
    assert proc.returncode == 0, f"{hook} exited {proc.returncode}: {proc.stderr}"
    out = proc.stdout.strip()
    if not out:
        return None
    payload = json.loads(out)
    hook_output = payload["hookSpecificOutput"]
    assert hook_output["hookEventName"] == "PreToolUse"
    assert hook_output["permissionDecision"] == "deny"
    reason = hook_output["permissionDecisionReason"]
    assert isinstance(reason, str) and reason
    return reason


@pytest.fixture(scope="session")
def deny_reason() -> HookRunner:
    """(hook, command) -> the hook's deny reason, or None if it allowed the command."""
    return _run_hook


@pytest.fixture(scope="session")
def is_blocked() -> Callable[[str, str], bool]:
    """(hook, command) -> True if the hook denies the command."""

    def check(hook: str, command: str) -> bool:
        return _run_hook(hook, command) is not None

    return check
