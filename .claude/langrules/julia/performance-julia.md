# Performance Guidelines

## General Principles
- Avoid global variables
- Use type annotations for function arguments and return values
- Prefer in-place operations (functions ending with `!`) when appropriate
- Use `@inbounds` judiciously for performance-critical loops after bounds checking
- Profile before optimizing with `@profile` and `BenchmarkTools.@benchmark`

## Profiling and Optimization Workflow
```julia
using Profile, BenchmarkTools, ProfileView

# 1. Benchmark
@benchmark my_function($data)

# 2. Profiling
@profile for i in 1:1000
    my_function(data)
end
ProfileView.view()  # or Profile.print()

# 3. Allocation tracking
@time my_function(data)
# Start Julia with --track-allocation=user to identify allocation sites
```

## @fastmath Guidelines
Use when speed matters more than numerical accuracy. Sacrifices IEEE754 compliance.

```julia
# When to use
@fastmath function norm2(x::Vector{Float64})
    sqrt(sum(xi^2 for xi in x))
end

# When to avoid: financial calculations, scientific computing where accuracy is critical
```

## Performance-Oriented Libraries
- `StaticArrays.jl`: Small fixed-size arrays (<100 elements)
- `LoopVectorization.jl`: Automatic vectorization
- `StructArrays.jl`: Array of Structs → Struct of Arrays conversion

```julia
using StaticArrays

# 10x+ faster for 3D coordinate calculations
function distance(p1::SVector{3,Float64}, p2::SVector{3,Float64})
    norm(p1 - p2)
end
```

## Specific Rules

1. **Avoid abstract-type containers in hot paths**
   ```julia
   # Good
   a::Vector{Float64} = zeros(1_000_000)
   
   # Bad in tight loops
   a::Vector{<:Real} = zeros(1_000_000)
   ```

2. **Eliminate global variables**
   ```julia
   const SCALE = 2.0
   
   function scale!(x::Vector{Float64})
       @. x *= SCALE
   end
   ```

3. **Pre-allocate storage**
   ```julia
   buf = Vector{Int}(undef, N)
   for i in 1:M
       compute!(buf, data[i])
       # use buf
   end
   ```

4. **Use in-place `!` functions**
   ```julia
   sort!(arr)        # instead of arr2 = sort(arr)
   push!(dest, x)    # instead of vcat(dest, [x])
   ```

5. **Leverage views for slicing**
   ```julia
   for row in eachrow(@view M[1:100, :])
       # process row
   end
   ```

6. **Bounds-check once with `@inbounds`**
   ```julia
   function sum_fast(x::Vector{Float64})
       s = 0.0
       @inbounds for i in eachindex(x)
           s += x[i]
       end
       return s
   end
   ```

7. **Use `@simd` for numeric loops**
   ```julia
   function dot(u, v)
       s = 0.0
       @inbounds @simd for i in eachindex(u, v)
           s += u[i] * v[i]
       end
       s
   end
   ```

8. **Avoid splatting in tight loops**
   ```julia
   f(a, b, c)           # good
   g(tuple_of_args...)  # bad in loops
   ```