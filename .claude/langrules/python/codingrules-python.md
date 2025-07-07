# Python Coding Rules

## Code Style and Formatting

### General Guidelines

- Follow PEP 8 style conventions
- Use trailing commas in multi-line structures
- **Use f-strings for string formatting (Python 3.6+)**

### Import Organization

- Standard library imports first
- Third-party imports second
- Local application imports last
- Separate each group with blank lines
- Use absolute imports when possible
- Sort imports alphabetically within each group
- **Use `__future__` imports when necessary at the very top**

```python
from __future__ import annotations

import os
import sys
from pathlib import Path

import requests
from fastapi import FastAPI

from myapp.models import User
from myapp.utils import helper_function
```

## Naming Conventions

### Variables and Functions

- Use snake_case for variables and functions
- Use descriptive names that clearly indicate purpose
- Avoid single-letter variables except for short loops or mathematical operations
- Use verbs for functions, nouns for variables
- **Use `_` for unused variables in unpacking**

### Classes

- Use PascalCase for class names
- Use descriptive names that represent the entity or concept
- Prefer composition over inheritance
- **Use mixins for shared behavior across unrelated classes**

### Constants

- Use UPPER_CASE with underscores for constants
- Define module-level constants at the top of the file
- **Use `enum.Enum` for related constants**

```python
from enum import Enum, auto

class Status(Enum):
    PENDING = auto()
    PROCESSING = auto()
    COMPLETED = auto()
```

### Private Members

- Use single underscore prefix for internal use (`_internal_method`)
- Use double underscore prefix for name mangling when necessary (`__private_attr`)
- **Prefer single underscore; double underscore should be rare**

## Type Hints

### Required Usage

- Use type hints for all function parameters and return values
- Use type hints for class attributes and instance variables
- Import types from `typing` module when needed
- **Use Python 3.10+ union syntax (`X | Y`) instead of `Union[X, Y]`**
- **Use `list[T]`, `dict[K, V]` instead of `List[T]`, `Dict[K, V]` (Python 3.9+)**

```python
from typing import Optional, TypeAlias, Protocol

# Type alias for complex types
UserId: TypeAlias = int | str

def process_data(items: list[str], config: dict[str, any]) -> str | None:
    """Process data items according to configuration."""
    if not items:
        return None
    return items[0]
```

### Advanced Type Features

- **Use `TypeAlias` for complex type definitions**
- **Use `Protocol` for structural subtyping**
- **Use `TypeVar` with bounds for generic functions**
- **Use `ParamSpec` and `Concatenate` for decorator typing**

```python
from typing import Protocol, TypeVar

class Comparable(Protocol):
    def __lt__(self, other: any) -> bool: ...

T = TypeVar('T', bound=Comparable)

def find_minimum(items: list[T]) -> T:
    return min(items)
```

## Modern Python Features

### Pattern Matching (Python 3.10+)

- **Use match statements for complex conditional logic**
- **Prefer match over long if-elif chains**
- **Use guard clauses with `if` in case statements**

```python
def process_command(command: dict[str, any]) -> str:
    match command:
        case {'action': 'create', 'type': obj_type, 'data': data}:
            return f'Creating {obj_type}'
        case {'action': 'delete', 'id': obj_id} if obj_id > 0:
            return f'Deleting {obj_id}'
        case _:
            return 'Unknown command'
```

### Data Classes

- **Use `@dataclass` for simple data containers**
- **Use `frozen=True` for immutable data**
- **Use `slots=True` for memory efficiency (Python 3.10+)**

```python
from dataclasses import dataclass, field

@dataclass(frozen=True, slots=True)
class Point:
    x: float
    y: float
    labels: list[str] = field(default_factory=list)
```

## Asynchronous Programming

### Async/Await Guidelines

- **Use `async def` for I/O-bound operations**
- **Use `asyncio.create_task()` for concurrent execution**
- **Prefer `asyncio.gather()` for waiting on multiple coroutines**
- **Use `async with` for async context managers**

```python
import asyncio
from typing import list

async def fetch_data(url: str) -> dict[str, any]:
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.json()

async def fetch_multiple(urls: list[str]) -> list[dict[str, any]]:
    tasks = [asyncio.create_task(fetch_data(url)) for url in urls]
    return await asyncio.gather(*tasks)
```

### Best Practices

- **Never use blocking I/O in async functions**
- **Use `asyncio.to_thread()` for CPU-bound operations**
- **Handle cancellation with try/except `asyncio.CancelledError`**

## Documentation

### Docstrings

- Use triple double quotes for all docstrings
- Follow Google or NumPy docstring format consistently
- Include purpose, parameters, return values, and exceptions
- Add examples for complex functions
- **Include type information in docstrings only when type hints are insufficient**
- **Document async behavior for coroutines**

```python
async def calculate_distance(
    point1: tuple[float, float],
    point2: tuple[float, float]
) -> float:
    """Calculate Euclidean distance between two points.

    This is an async function for demonstration purposes.
    In practice, CPU-bound operations should not be async.

    Args:
        point1: First point as (x, y) coordinates
        point2: Second point as (x, y) coordinates

    Returns:
        Distance between the two points

    Raises:
        ValueError: If points are not valid tuples

    Example:
        >>> await calculate_distance((0, 0), (3, 4))
        5.0
    """
```

### Comments

- Write clear, concise English comments explaining high-level purpose and rationale
- Document assumptions, side effects, and non-obvious logic
- Avoid comments that simply restate the code
- Use comments to explain "why" not "what"
- **Use TODO comments with username and date for future improvements**

## Error Handling

### Exception Management

- Use specific exception types, not bare `except:`
- Handle exceptions at the appropriate level
- Use `finally` blocks for cleanup operations
- Log errors with appropriate context
- **Use `contextlib.suppress()` for ignored exceptions**
- **Create exception hierarchies for complex applications**

```python
from contextlib import suppress

# Custom exception hierarchy
class AppError(Exception):
    """Base exception for application errors."""

class ValidationError(AppError):
    """Raised when validation fails."""

class ConfigurationError(AppError):
    """Raised when configuration is invalid."""

# Usage
with suppress(FileNotFoundError):
    Path('optional_file.txt').unlink()
```

### Error Context

- **Use `raise from` to preserve exception chains**
- **Add context with exception notes (Python 3.11+)**

```python
try:
    config = load_config()
except FileNotFoundError as e:
    raise ConfigurationError('Config file missing') from e
```

## Code Organization

### Module Structure

- Keep modules focused and cohesive
- Use `__init__.py` files to control public API
- Organize related functionality into packages
- Keep functions and classes reasonably sized
- **Use `__all__` to explicitly define public API**

### Function Guidelines

- Functions should do one thing well
- Aim for functions under 20 lines when possible
- Use early returns to reduce nesting
- Extract complex logic into separate functions
- **Prefer pure functions without side effects**
- **Use dependency injection over global state**

### Class Design

- Follow single responsibility principle
- Use composition over inheritance
- Implement `__str__` and `__repr__` methods when appropriate
- Use properties for computed attributes
- **Implement `__eq__` and `__hash__` for value objects**
- **Use `__slots__` for memory-critical classes**

## Logging

### Configuration

```python
import logging
import sys

def setup_logging(level: str = 'INFO') -> None:
    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(sys.stdout),
            logging.FileHandler('app.log')
        ]
    )

# Module-level logger
logger = logging.getLogger(__name__)
```

### Best Practices

- **Use module-level loggers**
- **Log at appropriate levels (DEBUG, INFO, WARNING, ERROR, CRITICAL)**
- **Include context in log messages**
- **Never log sensitive information**
- **Use structured logging for production**

## Environment Configuration

### Settings Management

```python
from pydantic import BaseSettings, Field

class Settings(BaseSettings):
    app_name: str = Field(default='MyApp')
    debug: bool = Field(default=False)
    database_url: str
    api_key: str = Field(..., alias='API_KEY')

    class Config:
        env_file = '.env'
        env_file_encoding = 'utf-8'

settings = Settings()
```

### Best Practices

- **Use pydantic for settings validation**
- **Never commit `.env` files**
- **Provide `.env.example` with dummy values**
- **Use different configs for different environments**

## Testing

### Test Structure

- Use pytest framework
- Organize tests to mirror source code structure
- Use descriptive test names that explain the scenario
- Follow arrange-act-assert pattern
- **Use parametrize for multiple test cases**
- **Group related tests in classes**

```python
import pytest

class TestCalculateDistance:
    @pytest.mark.parametrize('point1,point2,expected', [
        ((0, 0), (3, 4), 5.0),
        ((1, 1), (1, 1), 0.0),
        ((-1, -1), (2, 3), 5.0),
    ])
    def test_returns_correct_value(self, point1, point2, expected):
        result = calculate_distance(point1, point2)
        assert result == pytest.approx(expected)

    def test_raises_on_invalid_input(self):
        with pytest.raises(ValueError):
            calculate_distance('invalid', (0, 0))
```

### Fixtures and Mocks

```python
@pytest.fixture
async def db_session():
    async with create_session() as session:
        yield session
        await session.rollback()

@pytest.fixture
def mock_api_client(mocker):
    return mocker.patch('myapp.client.APIClient')
```

### Coverage and Quality

- Maintain high test coverage (aim for 90%+)
- Test edge cases and error conditions
- Use fixtures for common test data
- Mock external dependencies
- **Use hypothesis for property-based testing**
- **Test async code with pytest-asyncio**

## Tool Configuration

### Pyright (Type Checking)

```toml
[tool.pyright]
include = ["src"]
exclude = ["**/node_modules", "**/__pycache__"]
strict = true
reportMissingImports = true
reportMissingTypeStubs = false
pythonVersion = "3.11"
typeCheckingMode = "strict"
```

### Ruff (Linting and Formatting)

```toml
[tool.ruff]
line-length = 88
target-version = "py311"
extend-exclude = ["migrations", "build"]

[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "B",   # flake8-bugbear
    "C4",  # flake8-comprehensions
    "UP",  # pyupgrade
    "ARG", # flake8-unused-arguments
    "SIM", # flake8-simplify
    "PTH", # flake8-use-pathlib
]
ignore = ["E501"]  # Line length handled by formatter

[tool.ruff.format]
quote-style = "single"
indent-style = "space"
```

### UV (Package Management)

```toml
[project]
name = "myapp"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.100.0",
    "pydantic>=2.0.0",
    "httpx>=0.24.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "pytest-asyncio>=0.21.0",
    "pytest-cov>=4.0.0",
    "ruff>=0.1.0",
    "pyright>=1.1.0",
]
```

## Performance Considerations

### General Guidelines

- Profile before optimizing
- Use appropriate data structures for the task
- Avoid premature optimization
- Consider memory usage for large datasets
- **Use `functools.cache` instead of `lru_cache` when possible**
- **Profile with `py-spy` or `scalene` for production issues**

### Common Patterns

- Use list comprehensions for simple transformations
- Use generators for large datasets
- Cache expensive computations when appropriate
- **Use `itertools` for efficient iteration**
- **Prefer `collections.deque` for queues**
- **Use `bisect` for sorted data operations**

## Security

### Input Validation

- Validate all external inputs
- Sanitize data before processing
- Use parameterized queries for database operations
- Avoid `eval()` and `exec()` functions
- **Use `secrets` module for token generation**
- **Implement rate limiting for APIs**

### Dependencies

- **Regularly update dependencies**
- **Use `pip-audit` or `safety` for vulnerability scanning**
- **Pin exact versions in production**
- **Review dependency licenses**

## Continuous Integration

### GitHub Actions Example

```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.11", "3.12"]

    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}

      - name: Install dependencies
        run: |
          pip install uv
          uv sync --dev

      - name: Run tests
        run: |
          uv run pytest --cov=src tests/
          uv run ruff check .
          uv run ruff format --check .
          uv run pyright
```

### Pre-commit Configuration

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.0
    hooks:
      - id: ruff
      - id: ruff-format

  - repo: https://github.com/microsoft/pyright
    rev: v1.1.0
    hooks:
      - id: pyright
```

## Code Review Guidelines

### Review Checklist

- Code follows style guidelines
- Type hints are present and correct
- Tests are included and comprehensive
- Documentation is clear and complete
- Error handling is appropriate
- Security considerations are addressed
- Performance impact is considered
- **No hard-coded values or magic numbers**
- **Proper logging is implemented**
- **Backward compatibility is maintained**
- **Database migrations are included if needed**

