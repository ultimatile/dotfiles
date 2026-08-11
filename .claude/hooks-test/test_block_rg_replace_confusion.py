"""Behaviour table for the hook that blocks ripgrep's short -r (--replace).

Three groups, and the middle one is the reason the other two cannot be read in
isolation: a fix that stops the false positives by loosening the check would
still pass "allowed" but fail "denied".
"""

from __future__ import annotations

from collections.abc import Callable

import pytest
from conftest import HookRunner

HOOK = "block-rg-replace-confusion.py"

# Commands that must reach the shell. The `rm -rf` rows are the regression this
# table was written for: the -rf belongs to rm, not to the rg before it.
ALLOWED = [
    # A following command's flags are not rg's, whatever separates them.
    "rg -n pat src; rm -rf /tmp/fmtchk2",
    "rg -n pat src\nrm -rf /tmp/fmtchk2",
    "rg -n pat src && rm -rf /tmp/fmtchk2",
    "rg -n pat src&&rm -rf /tmp/fmtchk2",
    "rg -n pat src|xargs rm -rf",
    "rg -n pat src 2>/dev/null; rm -rf /tmp/fmtchk2",
    "rg -n pat src >out.txt; rm -rf /tmp/x",
    "(rg -n pat src); rm -rf /tmp/x",
    "{ rg -n pat src; rm -rf /tmp/x; }",
    "rm -rf /tmp/fmtchk2",
    "rm -rf /tmp/fmtchk2 && rg -n pat src",
    # Other commands' -r flags, where -r is not ripgrep's --replace.
    "rg -n pat src; cp -r a b",
    "rg -n pat src; grep -rn pat .",
    "rg -n pat src; ls -rt",
    # Correct ripgrep usage.
    "rg -n 'svd' src",
    "rg 'svd' src",
    # The long form is an explicit, deliberate replace.
    "rg --replace=X pat src",
    "rg --replace X pat src",
    # Attached values that merely contain an 'r'.
    "rg -trust pat",  # -t rust
    "rg -tr pat",  # type R
    "rg -tmarkdown pat",
    "rg -gsrc pat",  # -g src
    "rg -C3 pat",
    # Metacharacters and the flag spelling itself, inside a quoted pattern.
    "rg -n 'a;b' src",
    "rg -n 'a|b' src",
    'rg -n "rm -rf" src',
    'rg -n "\\-rn" src',
]

# Commands that must be denied: a short -r cluster reached as a flag position.
DENIED = [
    "rg -r pat .",
    "rg -rn 'svd' src",
    "rg -nr 'svd' src",
    "rg -rin pat .",
    # The rg need not be the first command on the line.
    "echo hi; rg -rn pat src",
    "rm -rf /tmp/x && rg -rn pat src",
    "fd -H | rg -rn pat",
    # A later invocation is still checked after an earlier one ends.
    "rg -n a src; rg -rn b src",
    # Basename match: an absolute path is the same trap.
    "/opt/homebrew/bin/rg -rn pat src",
]


@pytest.mark.parametrize("command", ALLOWED)
def test_allowed(is_blocked: Callable[[str, str], bool], command: str) -> None:
    assert not is_blocked(HOOK, command)


@pytest.mark.parametrize("command", DENIED)
def test_denied(is_blocked: Callable[[str, str], bool], command: str) -> None:
    assert is_blocked(HOOK, command)


def test_reason_routes_to_the_fix(deny_reason: HookRunner) -> None:
    """The deny reason has to teach the correct command, not just refuse."""
    reason = deny_reason(HOOK, "rg -rn pat src")
    assert reason is not None
    assert "--replace" in reason
    assert "rg -n 'pat' path" in reason
