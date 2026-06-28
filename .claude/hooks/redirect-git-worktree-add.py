#!/usr/bin/env python3
# PreToolUse hook: redirect `git worktree add` to `gwq add`.
#
# The value gwq provides over raw `git worktree` is PLACEMENT DETERMINISM:
# the worktree location is a pure function of the branch name under gwq's
# configured basedir (outside any repo tree). Raw `git worktree add <path>`
# lets the location be improvised (./.claude, ../, scratch dirs); those land
# in fragile, often-gitignored or hand-deleted places and get lost. Forcing
# creation through gwq keeps every worktree branch-name-addressable and in a
# stable, recoverable tree (`gwq get <branch>` / `gwq list --json`).
#
# Only `add` (creation) is redirected — that is where placement is decided.
# `git worktree list/remove/prune` are left untouched.

import json
import re
import sys

# Match `git ... worktree add` within a single simple command. `[^|&;\n]*`
# stays inside one command segment so a `git` before a `|`/`;`/`&&` boundary
# is not joined to a later `worktree add`. Tolerates global options between
# git and the subcommand (e.g. `git -C /path worktree add`).
PATTERN = re.compile(r"\bgit\b[^|&;\n]*\bworktree\s+add\b")

REASON = (
    "Use `gwq` instead of `git worktree add`:\n"
    "- create:  gwq add -b <branch>      (existing branch: gwq add <branch>)\n"
    "- path:    gwq get <branch>\n"
    "- run in:  gwq exec <branch> -- <cmd>\n"
    "- list:    gwq list --json / gwq status --json\n"
    "- remove:  gwq remove <branch>\n"
    "Non-interactive flags only. If raw `git worktree` is required, ask the user."
)


def strip_quoted(text: str) -> str:
    """Remove quoted substrings so a command mentioned inside a string literal
    (echo text, commit message) does not false-positive. Heuristic, not a
    parser: accepts the rare false negative of a command hidden inside quotes
    in exchange for not firing on prose."""
    return re.sub(r"\"[^\"]*\"|'[^']*'", "", text)


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return  # Nothing to inspect; let the call proceed.

    command = data.get("tool_input", {}).get("command", "")
    if not command:
        return

    if not PATTERN.search(strip_quoted(command)):
        return

    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": REASON,
        }
    }))


if __name__ == "__main__":
    main()
