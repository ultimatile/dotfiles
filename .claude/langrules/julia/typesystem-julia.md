# Type System

## Basic Principles

- Define custom types when they improve code clarity
- Use parametric types for generic code
- Prefer concrete types over abstract types in performance-critical code

## Abstract Type Hierarchies

```julia
# Good hierarchy design
abstract type Animal end
abstract type Mammal <: Animal end
abstract type Bird <: Animal end

struct Dog <: Mammal where {S<:AbstractString, I<:Integer}
    name::S
    age::I
end

struct Eagle <: Bird where {F<:AbstractFloat}
    wingspan::F
end

```

## Union Types

Use for small sets of types. Too many types hurt performance.

```julia
# Good: 2-3 types
Response = Union{String, Nothing, Symbol}

# Bad: too many types
BadUnion = Union{Int, Float64, String, Symbol, Nothing, Missing}

# Optimized Union branching
process(x::Union{Int, Float64}) = x is Int ? x * 2 : x * 2.0
```

## Parametric Types Best Practices

```julia
# Minimal type parameters
struct Point{Tx<:Real, Ty<:Real}
    x::Tx
    y::Ty
end

# Type constraints for safety
struct Matrix{T<:Number, N<:Integer}
    data::Array{T, N}

    function Matrix{T, N}(data) where {T<:Number, N<:Integer}
        N == 2 || throw(ArgumentError("Only 2D matrices supported"))
        new{T, N}(data)
    end
end
```

## Type Stability

```julia
# Type-stable function
function stable_sum(v::Vector{Float64})
    s = 0.0  # Initialize with same type
    for x in v
        s += x
    end
    return s
end

# Type-unstable function (avoid)
function unstable_sum(v)
    s = 0  # Int
    for x in v
        s += x  # Type might change
    end
    return s
end

# Check with @code_warntype
@code_warntype stable_sum([1.0, 2.0, 3.0])
```

