#!/usr/bin/env python3
# PreToolUse hook: deny filesystem scans rooted at / or $HOME.
#
# Walking the whole root or the entire home directory is slow and almost always
# a symptom of "I don't know where the target is" rather than a deliberate full
# scan. We block it at the path-operand level (not by prefix string matching, so
# option ordering / extra whitespace / cd-prefixes cannot trivially bypass it)
# and return a reason that tells the agent what to do INSTEAD of retrying with a
# slightly narrower scan. The reason is the real payload here: it routes the
# agent toward asking the user, inferring the directory, or using the Spotlight
# index — never a scan-and-narrow loop.
#
# Covers find / rg / grep / fd. For find we parse true path operands (operands
# precede the expression); for the grep-likes we flag any broad-root argument,
# since "/" or "$HOME" essentially never appears as a legitimate search target.

import json
import os
import shlex
import sys

# Commands whose directory targets we police.
SCANNERS = {"find", "rg", "grep", "egrep", "fgrep", "fd", "fdfind"}

# Shell tokens that terminate one simple command's argument list.
OPERATORS = {";", "&&", "||", "|", "|&", "&", "(", ")", "{", "}"}

# find global options that appear BEFORE path operands.
FIND_GLOBAL_EXACT = {"-H", "-L", "-P"}

HOME = os.path.expanduser("~")


def is_broad_root(tok: str) -> bool:
    """True if the token denotes the filesystem root or the whole home dir.

    Subdirectories of home ($HOME/projects, ~/src) are intentionally allowed —
    only the unscoped roots are too broad to permit.
    """
    t = tok.strip().strip("'\"")
    norm = t.rstrip("/")
    if norm in ("", "~", "$HOME", "${HOME}"):  # "" comes from "/" after rstrip
        return True
    if t == HOME or norm == HOME.rstrip("/"):
        return True
    return False


def find_path_operands(args: list[str]) -> list[str]:
    """Extract find's path operands: tokens after global options, before the
    expression (which begins at the first -predicate / ( / ! / )).
    """
    j = 0
    while j < len(args) and (args[j] in FIND_GLOBAL_EXACT or args[j].startswith(("-D", "-O"))):
        j += 1
    operands = []
    while j < len(args):
        t = args[j]
        if t.startswith("-") or t in ("(", "!", ")"):
            break
        operands.append(t)
        j += 1
    return operands


def broad_roots(command: str) -> list[str]:
    """Return the distinct broad-root targets found across scanner invocations."""
    try:
        tokens = shlex.split(command)
    except ValueError:
        # Unbalanced quotes etc. — fall back to a coarse whitespace scan so a
        # malformed command can't slip a broad scan through unchecked.
        tokens = command.split()

    hits: list[str] = []
    i, n = 0, len(tokens)
    while i < n:
        base = os.path.basename(tokens[i])
        if base in SCANNERS:
            j = i + 1
            while j < n and tokens[j] not in OPERATORS:
                j += 1
            args = tokens[i + 1:j]
            candidates = find_path_operands(args) if base == "find" else args
            for c in candidates:
                if is_broad_root(c) and c not in hits:
                    hits.append(c)
            i = j
        else:
            i += 1
    return hits


REASON = (
    "Blocked: scanning / or $HOME with find/rg/grep/fd is too broad and is "
    "usually a sign that the target's location is unknown. Do NOT retry with a "
    "slightly narrower scan (no scan-and-narrow loop). Instead:\n"
    "1. If you can infer the directory from the project layout, config, or "
    "`git ls-files`, search only there with fd/rg.\n"
    "2. If you genuinely don't know where it is, ASK THE USER for the path "
    "instead of scanning. In a subagent (which cannot prompt), stop and report "
    "that the path is unknown rather than scanning.\n"
    "3. If you truly must search the whole disk, use the Spotlight index: "
    "`mdfind -name <file>` — do not walk the tree.\n"
    "Detected broad root(s): {roots}"
)


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return  # Nothing to inspect; let the call proceed.

    command = data.get("tool_input", {}).get("command", "")
    if not command:
        return

    hits = broad_roots(command)
    if not hits:
        return

    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": REASON.format(roots=", ".join(hits)),
        }
    }))


if __name__ == "__main__":
    main()
