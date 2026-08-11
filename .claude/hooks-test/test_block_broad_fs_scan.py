"""Behaviour table for the hook that blocks filesystem scans rooted at / or $HOME."""

from __future__ import annotations

from collections.abc import Callable
from pathlib import Path

import pytest
from conftest import HookRunner

HOOK = "block-broad-fs-scan.py"

HOME = str(Path.home())

ALLOWED = [
    # A broad path belonging to a LATER command is not the scanner's target.
    # This is the same command-boundary regression as the ripgrep -r hook.
    "rg -n pat src; ls /",
    "fd -t f foo src; du -sh /",
    "fd -t f foo src\nls /",
    "find src -name x; ls /",
    "rg -n pat src && ls /",
    # Scoped scans.
    "rg -n pat src",
    "fd -t f x src",
    "find src -name x",
    # Subdirectories of home are deliberately allowed; only the bare root is not.
    "fd foo ~/projects",
    f"rg -n pat {HOME}/dotfiles",
    # find's expression values are not path operands: `-newer /` is not a scan of /.
    "find . -newer / -name x",
]

DENIED = [
    "find / -name foo",
    "find -H / -name foo",  # global option precedes the operand
    "rg -n pat /",
    "grep -rn pat /",
    "fd foo /",
    "fd foo ~",
    "fd foo $HOME",
    f"fd foo {HOME}",
    "fd foo /  ",  # trailing whitespace does not narrow anything
    # The scanner need not be the first command on the line.
    "ls /tmp; fd foo /",
    "echo x && find / -name foo",
    # Grouping does not hide the target.
    "{ fd foo /; }",
    "(find / -name foo)",
]


@pytest.mark.parametrize("command", ALLOWED)
def test_allowed(is_blocked: Callable[[str, str], bool], command: str) -> None:
    assert not is_blocked(HOOK, command)


@pytest.mark.parametrize("command", DENIED)
def test_denied(is_blocked: Callable[[str, str], bool], command: str) -> None:
    assert is_blocked(HOOK, command)


def test_reason_names_the_detected_root(deny_reason: HookRunner) -> None:
    """The agent has to be able to see WHICH argument was judged too broad."""
    reason = deny_reason(HOOK, "fd foo /")
    assert reason is not None
    assert "Detected broad root(s): /" in reason
    assert "mdfind" in reason  # routes to the index instead of a narrower walk


def test_broad_root_as_a_search_pattern_is_also_denied(
    is_blocked: Callable[[str, str], bool],
) -> None:
    """Deliberate coarseness, kept visible: for the grep-likes any broad-root-looking
    argument is flagged, so a literal "/" pattern is denied even though it is not a
    path. Distinguishing pattern from path would mean modelling every rg/grep flag
    that takes a value; the cost of that is judged higher than the cost of quoting
    the pattern differently (`rg -n '[/]' src`).
    """
    assert is_blocked(HOOK, "rg -n '/' src")
