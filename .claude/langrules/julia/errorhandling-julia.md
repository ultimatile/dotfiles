# Error-Handling Rules

## 1. Union{T, Nothing} Pattern
Most common pattern for fallible operations.

```julia
function find_user(id::Int)::Union{User, Nothing}
    haskey(users, id) ? users[id] : nothing
end

# Usage
user = find_user(123)
if user !== nothing
    process(user)
else
    println("User not found")
end
```

## 2. Tuple Return Pattern
Return success/failure flag with value.

```julia
function safe_divide(a::Number, b::Number)::Tuple{Float64, Bool}
    b == 0 ? (0.0, false) : (a / b, true)
end

# Usage
result, success = safe_divide(10, 0)
success || error("Division failed")
```

## 3. Named Tuple Pattern
More explicit return values.

```julia
function parse_config(str::String)
    try
        data = JSON.parse(str)
        return (success=true, data=data, error=nothing)
    catch e
        return (success=false, data=nothing, error=e)
    end
end

# Usage
result = parse_config(json_str)
if result.success
    process(result.data)
else
    @warn "Parse failed" result.error
end
```

## 4. Exception Usage Guidelines
- Use exceptions for I/O operations and external resource access
- Avoid in performance-critical code
- Use `Union{T, Nothing}` for predictable errors

```julia
# Good exception usage
function read_config(path::String)
    try
        return JSON.parsefile(path)
    catch e
        isa(e, SystemError) && throw(ConfigError("Cannot read file: $path"))
        isa(e, JSONError) && throw(ConfigError("Invalid JSON in: $path"))
        rethrow()  # Rethrow unexpected exceptions
    end
end
```