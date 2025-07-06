# Julia Coding Rules

## Naming Conventions

- Use `snake_case` for variables and functions
- Use `PascalCase` for types and modules
- Use `SCREAMING_SNAKE_CASE` for constants
- Use descriptive names that clearly indicate purpose
- Avoid abbreviations unless they are well-established in the domain

## Code Structure

- Keep functions small and focused on a single responsibility
- Use multiple dispatch effectively - define methods for different argument types
- Group related functionality into modules
- Export only the public API from modules

## Type System

See @typesystem-julia.md for detailed guidelines on using Julia's type system effectively.

## Argument-Type Rules

1. **Use abstract types for generic APIs**

   ```julia
   function greet(name::AbstractString)
       println("Hello, $name!")
   end
   ```

2. **Parameterize collections with `<:`**

   ```julia
   function mean_value(xs::AbstractVector{<:Number})
       sum(xs) / length(xs)
   end
   ```

3. **Reserve concrete types for hot paths**

   ```julia
   # Inner-loop performance:
   function process_fast(xs::Vector{Float64})
       @inbounds for x in xs
           # processing logic
       end
   end
   ```

4. **Avoid `Any` in signatures**

   - Prefer `Number`, `AbstractString`, `AbstractDict`, etc.
   - If truly generic, use `T` with bounds:

   ```julia
   function wrap(x::T) where T
       (x,)
   end
   ```

5. **Document argument types in docstrings**

   ```julia
   """
       join_words(words::AbstractVector{<:AbstractString}) -> String

   Join an array of strings with spaces.
   """
   function join_words(words::AbstractVector{<:AbstractString})
       join(words, " ")
   end
   ```

## Error-Handling Rules

See @errorhandling-julia.md for best practices on error handling in Julia.

## Pattern Selection by Complexity

### 1. Table Map

**Use when**: You have a small, fixed set of keys → handlers  
**Why**: O(1) lookup, minimal boilerplate

```julia
const HANDLERS = Dict(
    :add => (x,y) -> x + y,
    :sub => (x,y) -> x - y,
    :mul => (x,y) -> x * y,
)

function calc(op::Symbol, x, y)
    handler = get(HANDLERS, op, nothing)
    handler !== nothing ? handler(x, y) : error("Unknown op")
end
```

### 2. If-Else Chain

**Use when**: Only 2–3 mutually exclusive conditions, simple logic  
**Why**: Clear, no dispatch overhead

```julia
function classify(x)
    if x < 0
        :negative
    elseif x == 0
        :zero
    else
        :positive
    end
end
```

### 3. Multiple Dispatch

**Use when**: Behavior varies by argument types/domains  
**Why**: Leverages Julia's core feature, extensible

```julia
abstract type Shape end
struct Circle <: Shape; r::Float64; end
struct Square <: Shape; a::Float64; end

area(c::Circle) = π * c.r^2
area(s::Square) = s.a^2
```

### 4. Holy Traits

**Use when**: You need ad-hoc "type" variations without proliferating concrete types  
**Why**: Encapsulates behavior without type explosion

```julia
# 1. Define trait types
struct FastTrait end
struct SafeTrait end

# 2. Trait selector
trait(::Type{T}) where {T<:Integer} = FastTrait()
trait(::Type{T}) where {T<:AbstractString} = SafeTrait()

# 3. Internal dispatch
_process(x, ::FastTrait) = @inbounds sum(x)
_process(x, ::SafeTrait) = sum(parse.(Int, collect(x)))

# 4. User API
function process(x)
    _process(x, trait(typeof(x)))
end
```

## Performance Guidelines

See @performance-julia.md for detailed performance guidelines.

## Memory Management

- Be aware of memory allocations in performance-critical code
- Use views (`@view`) to avoid copying arrays when possible
- Pre-allocate arrays when size is known
- Use `sizehint!` for collections that will grow

## Documentation

- Document all exported functions with docstrings
- Include examples in docstrings when helpful
- Document function parameters and return values in docstrings

## Testing

- Write comprehensive tests for all public functions
- Use descriptive test names that explain what is being tested
- Group related tests using `@testset`
- Test edge cases and error conditions

## Code Style

- Prefer `isnothing` over `=== nothing` and `!isnothing` over `!== nothing`
- Prefer shadowing in kwargs: not `f(;A=A)` but `f(;A)`
- For multi-line literals, use triple double quotes ("""...""") instead of multiple `println` calls.

## Metaprogramming

- Use macros sparingly and only when they provide clear benefits:
  - Code generation for repetitive patterns
  - Simplifying boilerplate code
- Prefer functions over macros when possible
- Use `@generated` functions for type-based code generation

## Package Development

See @packagedev-julia.md for guidelines on developing Julia packages.
