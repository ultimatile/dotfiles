"""Unit tests for the shared command-boundary parser."""

from __future__ import annotations

from collections.abc import Iterable

import pytest
from shell_tokens import invocations, is_separator, tokenize


@pytest.mark.parametrize(
    ("command", "expected"),
    [
        # The case shlex.split() gets wrong: ';' glued to the preceding token.
        ("rg -n pat src; rm -rf /tmp/x", ["rg", "-n", "pat", "src", ";", "rm", "-rf", "/tmp/x"]),
        # ...and a newline, which shlex.split() drops as plain whitespace.
        ("rg -n pat src\nrm -rf /tmp/x", ["rg", "-n", "pat", "src", "\n", "rm", "-rf", "/tmp/x"]),
        # Separators need no surrounding whitespace.
        ("rg pat src|xargs rm", ["rg", "pat", "src", "|", "xargs", "rm"]),
        ("a&&b", ["a", "&&", "b"]),
        # Redirections split into fd and operator.
        ("rg pat src 2>/dev/null", ["rg", "pat", "src", "2", ">", "/dev/null"]),
        # Quoting wins: a metacharacter inside an argument stays in the argument.
        ("rg -n 'a;b' src", ["rg", "-n", "a;b", "src"]),
        ('rg -n "a|b" src', ["rg", "-n", "a|b", "src"]),
        ("rg -n 'rm -rf' src", ["rg", "-n", "rm -rf", "src"]),
    ],
)
def test_tokenize_separates_commands(command: str, expected: list[str]) -> None:
    assert tokenize(command) == expected


def test_tokenize_falls_back_on_unbalanced_quotes() -> None:
    """A malformed command still yields tokens, so callers inspect it instead of skipping."""
    assert tokenize('rg -n "unclosed src') == ["rg", "-n", '"unclosed', "src"]


@pytest.mark.parametrize("tok", [";", "&&", "||", "|", "\n", "(", ")", ">", ">>", ";;"])
def test_is_separator_true(tok: str) -> None:
    assert is_separator(tok)


@pytest.mark.parametrize("tok", ["", "rg", "-rf", "src;", "2", "/tmp/x", "a;b"])
def test_is_separator_false(tok: str) -> None:
    assert not is_separator(tok)


@pytest.mark.parametrize(
    ("command", "expected"),
    [
        # An argument list stops at the separator — the whole point of the module.
        ("rg -n pat src; rm -rf /tmp/x", [("rg", ["-n", "pat", "src"])]),
        ("rg -n pat src\nrm -rf /tmp/x", [("rg", ["-n", "pat", "src"])]),
        ("rm -rf /tmp/x && rg -n pat src", [("rg", ["-n", "pat", "src"])]),
        # Every matching invocation is reported, not just the first.
        ("rg a x; rg b y", [("rg", ["a", "x"]), ("rg", ["b", "y"])]),
        # A brace group's body has to be `;`-terminated, which is what bounds the
        # invocation — `{` and `}` are not treated as separators themselves.
        ("{ rg -n pat src; rm -rf /tmp/x; }", [("rg", ["-n", "pat", "src"])]),
        ("(rg -n pat src)", [("rg", ["-n", "pat", "src"])]),
        # Redirections end the argument list too.
        ("rg -n pat src > /dev/null 2>&1; rm -rf /tmp/x", [("rg", ["-n", "pat", "src"])]),
        # Basename match, so an absolute path or a pipeline stage still counts.
        ("/opt/homebrew/bin/rg -n pat", [("rg", ["-n", "pat"])]),
        ("fd -H | rg -n pat", [("rg", ["-n", "pat"])]),
        # No match at all.
        ("rm -rf /tmp/x", []),
    ],
)
def test_invocations(command: str, expected: list[tuple[str, list[str]]]) -> None:
    assert list(invocations(command, {"rg"})) == expected


def test_invocations_matches_multiple_names() -> None:
    got = list(invocations("fd -t f x src; rg -n y src", {"fd", "rg"}))
    assert got == [("fd", ["-t", "f", "x", "src"]), ("rg", ["-n", "y", "src"])]


def test_invocations_accepts_any_iterable_of_names() -> None:
    """SCANNERS-style frozensets, lists and generators all work as `names`."""
    variants: list[Iterable[str]] = [["rg"], frozenset({"rg"}), (n for n in ["rg"])]
    for names in variants:
        assert list(invocations("rg -n pat src", names)) == [("rg", ["-n", "pat", "src"])]
