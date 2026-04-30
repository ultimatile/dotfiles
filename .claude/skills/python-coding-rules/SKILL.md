---
name: python-coding-rules
description: User's opinionated Python preferences. The two non-negotiables are (1) ALWAYS use uv for package management — never pip/poetry/conda/venv directly — and (2) ALWAYS add type annotations to every function signature. Plus secondary preferences (ruff, pyright strict, pydantic v2, 3.10+ syntax) and known pitfalls. TRIGGER when writing or editing any Python (.py) file, pyproject.toml, requirements.txt, or any package-management or environment setup. SKIP for non-Python work.
---

# Python Coding Rules

## Non-negotiables

These two are where real friction happens. Treat as MUST, not SHOULD.

### 1. Use `uv` for everything

- Project setup: `uv init`
- Add dep: `uv add <pkg>` (NOT `pip install`)
- Sync env: `uv sync` (NOT `pip install -r requirements.txt`)
- Run: `uv run <cmd>` (NOT `python ...` from an activated venv)
- Lock file: commit `uv.lock`
- Python version: pin in `pyproject.toml` `requires-python`, install via `uv python install`

Never propose `pip`, `poetry`, `conda`, `pipenv`, or hand-managed `venv` workflows. If a project is already on one of those, suggest migrating to `uv` rather than continuing in it. The only exception is touching an existing `requirements.txt` for a project that explicitly is not migrating — and even then, mention `uv pip install -r` over plain `pip`.

### 2. Type-annotate every function

- Every parameter: typed.
- Every return: typed (including `-> None`).
- Every public class attribute: typed.
- No `Any` as a shortcut for "I don't feel like figuring out the type" — if the type is genuinely dynamic, write `Any` *and* leave a one-line comment explaining why; if the shape is known, write a `TypedDict` / `dataclass` / `Protocol`.
- When editing existing untyped code, add annotations to the functions you touch. Don't leave the file in a half-typed state.

`pyright` runs in `strict` mode; missing annotations are errors, not warnings.

## Syntax & typing preferences

- `from __future__ import annotations` at the top of every module.
- Union: `X | Y`, `T | None`. Never `Union[...]` / `Optional[...]`.
- Builtin generics: `list[T]`, `dict[K, V]`, `tuple[T, ...]`. Never `List`/`Dict`/`Tuple` from `typing`.
- `Any` is the typing object — `dict[str, Any]`, NOT `dict[str, any]` (`any` is the builtin function).
- Type aliases: `type X = ...` (3.12+) or `TypeAlias` (3.10+).
- `Protocol` for structural typing; subclassing only when sharing implementation.

## Data shapes & dispatch

- `@dataclass(frozen=True, slots=True)` for value objects. Default to immutable.
- `match` for dispatch on shape/tag; `if/elif` only for ≤2–3 branches.
- `enum.Enum` / `StrEnum` for related constants — never module-level string sentinels.

## Errors

- Wrap with cause: `raise MyError(...) from e`.
- "Expected to fail, don't care": `contextlib.suppress(...)`.
- Catch the specific exception type, never bare `except` or broad `except Exception:` to silence.

## Async pitfalls

- `asyncio.to_thread(fn, ...)` to call blocking / CPU work from async code.
- `asyncio.gather(*tasks)` for fan-out; `create_task` when you need the handle.
- Don't swallow `CancelledError` — re-raise after cleanup.

## Tooling stack

| Concern | Choice |
|---|---|
| Package mgmt | `uv` (see non-negotiable #1) |
| Lint + format | `ruff` (replaces black / isort / flake8 / pyupgrade) |
| Type check | `pyright` in `strict` mode |
| Test | `pytest` + `pytest-asyncio`; `hypothesis` for invariants |
| Settings | `pydantic-settings` (Pydantic v2 — `BaseSettings` is no longer in core) |
| Profiling | `py-spy` or `scalene` |

Minimal config opinions:

```toml
[tool.pyright]
typeCheckingMode = "strict"
pythonVersion = "3.12"

[tool.ruff.lint]
select = ["E", "W", "F", "I", "B", "C4", "UP", "ARG", "SIM", "PTH"]
```

## Anti-patterns

- `pip install ...` / `poetry add ...` → use `uv add`.
- Function signature with no annotations → annotate it.
- `from typing import List, Dict, Tuple, Optional, Union` → builtins + `|`.
- `dict[str, any]` → `Any`.
- `pydantic.BaseSettings` import → moved to `pydantic-settings` in v2.
- `lru_cache` with no `maxsize` → use `functools.cache`.
- Mutable default args (`def f(x=[]):`) → use `None` and assign inside.
- `print(...)` for diagnostics in library code → `logging.getLogger(__name__)`.
