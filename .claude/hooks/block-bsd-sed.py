#!/usr/bin/env -S uv run --no-project --script
# /// script
# requires-python = ">=3.11"
# ///
# PreToolUse hook: block local `sed`, which is BSD sed on this Mac.
#
# Agents write sed from mixed habits: sometimes GNU (`sed -i 's/a/b/' f`, `\s`,
# `\+`, the `I` flag), sometimes macOS-aware BSD (`sed -i '' ...`). Whichever
# dialect the local `sed` is, one of the two habits breaks — and some breakages
# are silent: BSD sed does not error on `\s` or `\+`, it just stops matching, and
# `sed -i -e ...` leaves `f-e` backup files behind. Aliasing sed to gsed was tried
# and removed for the mirror-image reason: it broke the BSD-aware calls.
#
# So instead of picking a dialect for the name `sed`, we deny the ambiguous name
# locally and route to tools whose dialect is fixed: `sd` or `gsed`.
#
# Remote execution is exempt. A command that runs through `ssh` or
# `crewster exec` (an ssh wrapper for HPC login nodes) runs sed on a Linux host,
# where it is GNU sed and sd/gsed are usually unavailable. The exemption covers
# the whole command line, not just the ssh arguments, as a fallback for input
# the heredoc stripping below fails to parse.
#
# Only command positions count, so `rg sed`, `which sed` or `man sed` pass, and
# heredoc bodies are dropped before tokenizing: they are data (a commit message
# line starting with "sed ..."), but the tokenizer would read each line as a
# command.
# Known gap: sed hidden in a quoted string (`bash -c 'sed ...'`) or in a heredoc
# fed to a local shell (`bash <<'EOF' ... EOF`) is not seen.

from __future__ import annotations

import json
import re
import sys
from pathlib import Path, PurePosixPath

# See block-rg-replace-confusion.py: without this, PYTHONSAFEPATH=1 makes the
# sibling import fail and the harness silently runs the command unguarded.
sys.path.insert(0, str(Path(__file__).resolve().parent))

from shell_tokens import is_separator, tokenize  # noqa: E402

# Prefix commands that run their argument as a command: the token after them
# (and after their flags / VAR=val / duration args) is again a command position.
WRAPPERS = {"sudo", "env", "time", "nohup", "command", "exec", "nice", "timeout", "stdbuf"}
ASSIGNMENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")
DURATION = re.compile(r"^\d+(\.\d+)?[smhd]?$")

# Flags after which find / fd take a command to run per match.
EXEC_FLAGS = {
    "find": {"-exec", "-execdir", "-ok", "-okdir"},
    "fd": {"-x", "--exec", "-X", "--exec-batch"},
}


# `<<WORD`, `<<-WORD`, `<<'WORD'`, `<<"WORD"`, but not the here-string `<<<`.
HEREDOC = re.compile(r"(?<!<)<<(?!<)-?\s*(['\"]?)([A-Za-z_][A-Za-z0-9_]*)\1")


def strip_heredocs(command: str) -> str:
    """Remove heredoc bodies (and their terminator lines) from a command line."""
    out: list[str] = []
    pending: list[str] = []
    for line in command.split("\n"):
        if pending:
            if line.strip() == pending[0]:
                pending.pop(0)
            continue
        out.append(line)
        pending.extend(m.group(2) for m in HEREDOC.finditer(line))
    return "\n".join(out)


def segments(command: str) -> list[list[str]]:
    """Split a command line into simple commands at separator tokens."""
    out: list[list[str]] = [[]]
    for tok in tokenize(strip_heredocs(command)):
        if is_separator(tok):
            out.append([])
        else:
            out[-1].append(tok)
    return [seg for seg in out if seg]


def strip_prefix(seg: list[str]) -> list[str]:
    """Drop leading VAR=val assignments and wrapper commands with their args."""
    i, n = 0, len(seg)
    while i < n:
        tok = seg[i]
        if ASSIGNMENT.match(tok):
            i += 1
        elif PurePosixPath(tok).name in WRAPPERS:
            i += 1
            while i < n and (
                seg[i].startswith("-") or ASSIGNMENT.match(seg[i]) or DURATION.match(seg[i])
            ):
                i += 1
        else:
            break
    return seg[i:]


def name(tok: str) -> str:
    return PurePosixPath(tok).name


def is_remote(seg: list[str]) -> bool:
    """True for `ssh ...` and `crewster exec ...`."""
    if not seg:
        return False
    head = name(seg[0])
    if head == "ssh":
        return True
    if head == "crewster":
        positional = [t for t in seg[1:] if not t.startswith("-")]
        return bool(positional) and positional[0] == "exec"
    return False


def runs_sed(seg: list[str]) -> bool:
    """True if this simple command executes sed, directly or via xargs/find/fd."""
    if not seg:
        return False
    head = name(seg[0])
    if head == "sed":
        return True
    if head == "xargs":
        return any(name(t) == "sed" for t in seg[1:])
    flags = EXEC_FLAGS.get(head, set())
    for k, tok in enumerate(seg):
        if tok in flags:
            rest = strip_prefix(seg[k + 1 :])
            if rest and name(rest[0]) == "sed":
                return True
    return False


def offending(command: str) -> bool:
    segs = [strip_prefix(s) for s in segments(command)]
    if any(is_remote(s) for s in segs):
        return False
    return any(runs_sed(s) for s in segs)


REASON = (
    "Blocked: local `sed` is BSD sed on this Mac (/usr/bin/sed). GNU-style calls "
    "misbehave here, some silently: `sed -i 's/a/b/' f` takes the script as a "
    "backup suffix, `sed -i -e ...` leaves `f-e` files, and `\\s`, `\\+`, `\\|` "
    "or the `I` flag simply stop matching without an error.\n"
    "Use a tool whose dialect does not depend on the platform:\n"
    "- Plain substitution: `sd 'pat' 'rep' file` (Rust regex, captures as `$1`; "
    "`sd -F 'lit' 'rep' file` for fixed strings). sd edits in place when given files.\n"
    "- Need sed-specific features (addresses, `-n ...p`, multiple commands): "
    "`gsed` (GNU sed, same syntax as on Linux hosts).\n"
    "Remote commands via `ssh` or `crewster exec` are not blocked; plain `sed` "
    "there is GNU sed."
)


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return

    command = data.get("tool_input", {}).get("command", "")
    if not command or not offending(command):
        return

    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": REASON,
                }
            }
        )
    )


if __name__ == "__main__":
    main()
