"""Shared shell-command parsing for PreToolUse hooks.

A hook that polices how a command is invoked has to answer "which arguments
belong to THIS command?" — the Bash tool hands over a whole command line, which
may chain several commands. Getting that boundary wrong makes a hook read the
next command's flags as its target's, which is how `rm -rf` came to be reported
as ripgrep's short `-r`.

`shlex.split()` cannot draw that boundary: it splits on whitespace only, so
`rg PAT src; rm -rf dir` yields `'src;'` as one token with no `;` token at all,
and a newline separator disappears as plain whitespace. Either way a walk that
stops at a separator token never finds one and runs off the end of the command.

`tokenize()` here emits separators as standalone tokens, and `invocations()`
wraps the walk so both hooks share one boundary implementation.
"""

from __future__ import annotations

import io
import shlex
from collections.abc import Iterable, Iterator
from pathlib import PurePosixPath

# Characters that separate one simple command from the next. shlex emits a run of
# these as its own token (`;`, `&&`, `>>`, ...), so a token made only of them ends
# the current command's argument list. '\n' is included and removed from the
# lexer's whitespace set, so a newline-separated command list splits too.
# Brace groups (`{ cmd; }`) are covered by the `;` their body requires, so `{`
# and `}` are deliberately left out: making them punctuation would also split
# `{}` in `find -exec ... {} \;` and brace expansions like `{a,b}`.
PUNCT = "();<>|&\n"


def tokenize(command: str) -> list[str]:
    """Split a shell command line, keeping separators as standalone tokens.

    Quoting is honored, so a metacharacter inside an argument (`rg -n 'a;b'`)
    stays part of its token. In posix mode an argument that is nothing BUT a
    metacharacter (`rg -n ';'`) is indistinguishable from a real separator and
    ends that invocation's argument list early; the effect is a narrower scope,
    never a wider one.

    On unbalanced quotes this falls back to a whitespace split so a malformed
    command still gets inspected rather than skipped. Separators stay glued to
    their neighbours in that path, so an invocation's argument list can run long
    — fail-closed for the hooks' deny checks, at the cost of over-reach on a
    command that was already syntactically broken.
    """
    lex = shlex.shlex(io.StringIO(command), posix=True, punctuation_chars=PUNCT)
    lex.whitespace_split = True
    lex.whitespace = " \t\r"
    try:
        return list(lex)
    except ValueError:
        return command.split()


def is_separator(tok: str) -> bool:
    """True if a token is a command separator rather than an argument."""
    return bool(tok) and all(ch in PUNCT for ch in tok)


def invocations(command: str, names: Iterable[str]) -> Iterator[tuple[str, list[str]]]:
    """Yield (basename, args) for each command in the line whose name matches.

    `names` is matched against the basename, so an absolute path (`/opt/homebrew/
    bin/rg`) counts. `args` stops at the first separator token, which is what
    keeps a following command's flags out of this one's argument list.
    """
    wanted = set(names)
    tokens = tokenize(command)
    i, n = 0, len(tokens)
    while i < n:
        base = PurePosixPath(tokens[i]).name
        if base in wanted:
            j = i + 1
            while j < n and not is_separator(tokens[j]):
                j += 1
            yield base, tokens[i + 1 : j]
            i = j
        else:
            i += 1
