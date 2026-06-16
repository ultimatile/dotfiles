#!/usr/bin/env python3
# PreToolUse hook: block ripgrep's short -r used with grep-recursive intent.
#
# The grep habit "-r = recursive, -n = line numbers" silently corrupts ripgrep
# output. In ripgrep `-r` is the short form of --replace, which takes a REQUIRED
# argument, and `r` is not a short flag for anything else. So `rg -rn 'svd' path`
# parses as --replace='n': every match (svd, Svd, trunc_svd...) is rewritten to
# "n" in the output, with no error. And ripgrep already recurses into directories
# by default, so a recursive `-r` is never needed in the first place.
#
# We therefore deny any rg invocation that uses a SHORT -r cluster (-r, -rn, -nr,
# -rin, ...) and route the agent to the correct command. The long form
# --replace=TEXT is left untouched: writing it out is an explicit, deliberate
# replace, not the reflex bug. grep -r is also untouched — there -r really is
# recursive; the trap is ripgrep-specific.

import json
import os
import shlex
import sys

# Shell tokens that terminate one simple command's argument list.
OPERATORS = {";", "&&", "||", "|", "|&", "&", "(", ")", "{", "}"}


# ripgrep short flags that consume an argument: when one of these appears in a
# bundled cluster, the REST of the cluster is its value, not further flags. `r`
# (--replace) is itself one of them. We must walk the cluster left-to-right and
# only treat `r` as replace if it is reached as a flag position — i.e. before any
# other value-taking flag swallows it. Otherwise `-trust` (-t value "rust"),
# `-tr` (type R), `-truby`, `-tperl`, `-tcsharp`, `-tmarkdown`, `-gsrc`, etc. —
# all legitimate searches whose attached value merely contains 'r' — would be
# misread as replace and wrongly blocked.
VALUE_TAKING = set("ABCEefgMmtTr")


def is_short_r_cluster(tok: str) -> bool:
    """True iff a short-option cluster invokes -r (--replace) as a flag.

    Excludes the long form (--replace), so an explicit deliberate replace is
    allowed through. Walks the cluster so an `r` that is part of another flag's
    attached value (e.g. `-trust`) is not mistaken for the replace flag.
    """
    if len(tok) < 2 or tok[0] != "-" or tok[1] == "-":
        return False
    for ch in tok[1:]:
        if not ch.isalpha():
            # A non-alpha char (digit, '=') means the rest is an attached value
            # (e.g. -C3, -r=foo): stop before misreading later letters as flags.
            return False
        if ch == "r":
            return True  # reached replace as a flag position → the bug
        if ch in VALUE_TAKING:
            return False  # a value-taking flag swallows the remainder as its arg
    return False


def offending_rg(command: str) -> bool:
    """True if any rg invocation in the command uses a short -r cluster."""
    try:
        tokens = shlex.split(command)
    except ValueError:
        # Unbalanced quotes etc. — fall back to a coarse split so a malformed
        # command cannot slip the pattern through unchecked.
        tokens = command.split()

    i, n = 0, len(tokens)
    while i < n:
        if os.path.basename(tokens[i]) == "rg":
            j = i + 1
            while j < n and tokens[j] not in OPERATORS:
                if is_short_r_cluster(tokens[j]):
                    return True
                j += 1
            i = j
        else:
            i += 1
    return False


REASON = (
    "Blocked: `rg` was called with a short `-r`. In ripgrep `-r` is --replace "
    "(it takes a required argument), NOT 'recursive' as in grep, and there is no "
    "short flag `r` for anything else. So `rg -rn 'pat' path` is parsed as "
    "--replace='n' and silently rewrites every match to \"n\" in the output.\n"
    "ripgrep already recurses into directories by default, so you do not need "
    "`-r` at all.\n"
    "- Want matches with line numbers: `rg -n 'pat' path` (drop the `-r`).\n"
    "- Want grep-style recursive search: that is the default; just `rg 'pat' path`.\n"
    "- Genuinely want substitution: write the long form explicitly, e.g. "
    "`rg --replace=TEXT 'pat' path`."
)


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return  # Nothing to inspect; let the call proceed.

    command = data.get("tool_input", {}).get("command", "")
    if not command:
        return

    if not offending_rg(command):
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
