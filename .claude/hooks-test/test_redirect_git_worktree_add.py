"""Behaviour table for the hook that redirects `git worktree add` to gwq.

The tmp exemption depends on the caller, so this module builds its own payload
instead of using the conftest runner: `agent_id` is present in the hook input
only when the harness fires the hook inside a subagent.
"""

from __future__ import annotations

import json
import subprocess

import pytest
from conftest import HOOKS_DIR, child_env

HOOK = "redirect-git-worktree-add.py"

SCRATCHPAD = "/private/tmp/claude-501/-Users-me-repo/0123/scratchpad"


def _denied(command: str, *, subagent: bool) -> bool:
    payload: dict[str, object] = {"tool_input": {"command": command}}
    if subagent:
        payload["agent_id"] = "agent-0123"
        payload["agent_type"] = "general-purpose"
    proc = subprocess.run(
        [str(HOOKS_DIR / HOOK)],
        input=json.dumps(payload),
        capture_output=True,
        text=True,
        check=False,
        env=child_env(),
    )
    assert proc.returncode == 0, f"{HOOK} exited {proc.returncode}: {proc.stderr}"
    out = proc.stdout.strip()
    if not out:
        return False
    decision = json.loads(out)["hookSpecificOutput"]
    assert decision["permissionDecision"] == "deny"
    return True


# Allowed for every caller.
ALLOWED_ALWAYS = [
    "git worktree list",
    "git worktree remove ../wt",
    "git worktree prune",
    "git worktree add .claude/worktree/wt-1 -b feat",
    "git -C ~/repo worktree add ~/repo/.claude/worktree/wt-1",
    # Mentioned inside a string literal, not executed.
    "git commit -m 'git worktree add is redirected'",
    "echo \"run git worktree add later\"",
    # `git` and `worktree add` belong to different command segments.
    "git status; ls worktree add",
]

# Denied for every caller: a durable location.
DENIED_ALWAYS = [
    "git worktree add ../wt -b feat",
    "git worktree add /Users/me/wt feat",
    "git -C ~/repo worktree add ../wt",
    "cd repo && git worktree add ../wt",
]

# Allowed only inside a subagent: a tmp location.
SCRATCH = [
    f"git worktree add {SCRATCHPAD}/wt --detach HEAD",
    f"git worktree add '{SCRATCHPAD}/wt' -b tmp-branch",
    "git worktree add /tmp/wt",
    'git worktree add "$TMPDIR/wt"',
]


@pytest.mark.parametrize("command", ALLOWED_ALWAYS)
@pytest.mark.parametrize("subagent", [False, True])
def test_allowed_always(command: str, subagent: bool) -> None:
    assert not _denied(command, subagent=subagent)


@pytest.mark.parametrize("command", DENIED_ALWAYS)
@pytest.mark.parametrize("subagent", [False, True])
def test_denied_always(command: str, subagent: bool) -> None:
    assert _denied(command, subagent=subagent)


@pytest.mark.parametrize("command", SCRATCH)
def test_scratch_allowed_in_subagent(command: str) -> None:
    assert not _denied(command, subagent=True)


@pytest.mark.parametrize("command", SCRATCH)
def test_scratch_denied_on_main_thread(command: str) -> None:
    assert _denied(command, subagent=False)
