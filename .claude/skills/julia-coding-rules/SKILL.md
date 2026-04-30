---
name: julia-coding-rules
description: User's opinionated Julia preferences. Four real frictions: (1) ASCII-only identifiers — never use Unicode (π, ≤, χ, …) because editor / terminal glyphs collapse confusables (e.g. x vs χ) and the resulting bugs are silent; (2) Tooling — scaffold with `jtc create MyPackage.jl`, manage deps with `mise run add`, and use `TestItemRunner.jl` with tags for test selection (mise tasks filter by tag); never `Pkg.generate` / `Pkg.add` / `Pkg.test` by hand; (3) Union{T, Nothing} for optional / fallible values rather than throwing or sentinel returns; (4) parameter-pack factory pattern — @kwdef struct with parametric types fed by a factory constructor that takes a loose Dict{String, Any} from CLI / config parsing. Plus opinions on multiple dispatch, type stability, performance idioms (@view, @inbounds, @simd, StaticArrays), and Project.toml compat. TRIGGER when writing or editing any Julia (.jl) file, Project.toml, test/, or mise.toml. SKIP for non-Julia work.
---

# Julia Coding Rules

Standard Julia practice (`snake_case` / `PascalCase`, multiple dispatch, `@testset`, exporting public API) is assumed and not restated. Only listed: opinions that diverge from defaults, patterns that have actually caused friction, and bug-prone choices.

Comment policy follows the global rule: write comments only when the WHY is non-obvious. No mandatory docstrings.

## Real frictions

### 1. ASCII-only identifiers and operators

Julia allows Unicode identifiers (`π`, `χ`, `∇`, `≤`, …) but **do not use them**. Editors, terminals, and code review tools render confusable glyphs identically — `x` vs `χ`, `v` vs `ν`, `p` vs `ρ` — and the resulting bugs are silent: code parses, runs, but binds the wrong variable.

- Identifiers: ASCII letters, digits, `_` only. Spell out `chi`, `nu`, `rho`, `nabla`, `lambda`.
- Constants: use the ASCII alias when Julia provides one (`pi`, not `π`; `Inf`, `NaN`).
- Operators: `<=`, `>=`, `!=`, `in` — never `≤`, `≥`, `≠`, `∈`.
- Strings and comments: ASCII too — keep the failure mode out of the source.

The cost of being unable to type `π` is trivial; the cost of `x` silently shadowing `χ` in a long-running simulation is not.

### 2. Tooling: `jtc` for scaffolding, `mise run …` for everything else

- New package: `jtc create MyPackage.jl` — never `Pkg.generate` / `PkgTemplates.generate` by hand.
- Add a dependency from inside an existing project: `mise run add <PackageName>` — never `julia -e 'using Pkg; Pkg.add(...)'` or `]add` from a fresh REPL outside the project env.
- Removing / updating deps: use the corresponding `mise run` task; if one isn't defined, add it rather than reaching for `Pkg` directly.

The point is that environment activation and the resulting `Project.toml` / `Manifest.toml` edits stay consistent across machines and CI. Bypassing the wrappers tends to land deps in the wrong env or skip the project's compat conventions.

#### Tests: `TestItemRunner.jl` with tags

Test selection is the framework's job, not `runtests.jl`'s. Use `TestItemRunner.jl` and tag tests at definition:

```julia
# test/test_core.jl
using TestItems

@testitem "addition" begin
    using MyPackage
    @test add(1, 2) == 3
end

# test/test_aqua.jl
@testitem "Aqua quality" tags=[:quality] begin
    using MyPackage, Aqua
    Aqua.test_all(MyPackage)
end
```

`test/runtests.jl` becomes one line:

```julia
using TestItemRunner; @run_package_tests
```

mise tasks select by tag:
- `mise run test` → `filter = ti -> !(:quality in ti.tags)` (fast feedback, skips Aqua)
- `mise run test:aqua` → `filter = ti -> :quality in ti.tags`
- `mise run test:all` → no filter (CI default)

Bonus: each `@testitem` runs in an isolated module (no test-to-test state leaks), enables parallel execution, and is recognized by the VS Code Julia extension.

For legacy packages still on `@testset` that you don't want to migrate, fall back to gating sections on `ENV["GROUP"]` in `runtests.jl` (`get(ENV, "GROUP", "All")`, branch on `"Core"` / `"Aqua"` / `"All"`). Treat this as an interim workaround, not a target state.

### 3. `Union{T, Nothing}` for optional / fallible values

Default representation for "may be absent":

```julia
function find_user(id::Integer)::Union{User, Nothing}
    haskey(users, id) ? users[id] : nothing
end
```

- Prefer this over throwing for predictable absence.
- Reserve exceptions for I/O and unexpected failure.
- Optional struct fields: type as `Union{T, Nothing}` with `nothing` default.
- Test with `isnothing(x)` (not `x === nothing`).

### 4. Parameter pack: typed `@kwdef struct` + factory from `Dict{String, Any}`

For configuration objects fed by loose input (parsed CLI args, JSON, …) keep a strict separation: `Dict{String, Any}` at the boundary, parametric `@kwdef struct` internally, factory constructor bridging them.

```julia
@kwdef struct ModPara{R<:Real, I<:Integer, S<:AbstractString}
    N::I = 10
    J::R = 1.0
    spin::S = "S=1/2"
    conserve_qns::Bool = true
end

# Factory from loose input
function ModPara(pargs::Dict{String, Any})
    return ModPara(
        pargs["num_spin"], pargs["J"], pargs["spin"], pargs["conserve_qns"],
    )
end
```

When fields need validation, use an inner constructor:

```julia
@kwdef struct OptTPara{R<:Real, I<:Integer}
    Tmin::R = 1.0
    Tmax::R = 10.0
    iter_max::I = 100
    function OptTPara(Tmin::R, Tmax::R, iter_max::I) where {R<:Real, I<:Integer}
        @validate_positive Tmin Tmax iter_max
        return new{R, I}(Tmin, Tmax, iter_max)
    end
end
```

For top-level containers filled in stages (e.g. `MainPara` = mod + rte + util + …), use `@kwdef mutable struct` with `Union{T, Nothing} = nothing` fields and assign as each sub-pack is built:

```julia
@kwdef mutable struct MainPara
    mod::Union{ModPara, Nothing} = nothing
    rte::Union{RTEPara, Nothing} = nothing
    outputlevel::Int = 0
end
```

## Type system

- Default to abstract types in signatures: `Number`, `Integer`, `AbstractString`, `AbstractVector{<:Real}`. `f(::Integer)` not `f(::Int)`.
- Reserve concrete types for hot inner loops where dispatch / type stability matters.
- Avoid `Any` in signatures.
- Parametric struct syntax: `struct Dog{S<:AbstractString, I<:Integer} <: Mammal`. The `where` clause goes on the struct name, NOT after `<: Mammal`.

## Type stability

- Initialize accumulators with the result type: `s = 0.0` for a `Float64` sum, not `s = 0`.
- Check with `@code_warntype` when uncertain.
- Avoid non-`const` globals — they prevent type inference.

## Dispatch — pattern selection

| Situation | Use |
|---|---|
| Behavior varies by argument type | Multiple dispatch |
| Small fixed key → handler map | `const HANDLERS = Dict(...)` |
| 2–3 mutually exclusive branches | `if` / `elseif` |
| Ad-hoc behavior variants without exploding concrete types | Holy traits |

Holy trait skeleton:

```julia
struct FastTrait end
struct SafeTrait end
trait(::Type{<:Integer})         = FastTrait()
trait(::Type{<:AbstractString})  = SafeTrait()
_process(x, ::FastTrait) = @inbounds sum(x)
_process(x, ::SafeTrait) = sum(parse.(Int, collect(x)))
process(x) = _process(x, trait(typeof(x)))
```

## Performance idioms

- Pre-allocate buffers; mutate with `!` functions (`sort!`, `push!`, `mul!`).
- Slice via `@view M[1:100, :]` to skip the copy.
- Hot numeric loops: `@inbounds for i in eachindex(x)`, add `@simd` for reductions.
- Small fixed-size arrays (≤100 elements) → `StaticArrays.jl` (`SVector`, `SMatrix`).
- Use concrete element types in hot containers (`Vector{Float64}`, not `Vector{<:Real}`).
- Don't splat in tight loops.
- `@fastmath` only when IEEE compliance is acceptable to lose.

## Logging

- `@info`, `@warn`, `@error`. Never `println("warning: …")`.

## Package development

- Scaffolding, dep management, and test selection: see Non-negotiable #2.
- `Project.toml` `[compat]`: pin meaningful lower bounds. Default `julia = "1.10"` (current LTS).
- `@test_throws ArgumentError …` for negative cases.

## Style notes (low priority — formatter territory)

These don't matter much when an agent writes code, but apply on touch:

- `isnothing(x)` over `x === nothing`; `!isnothing(x)` over `x !== nothing`.
- Kwarg shorthand: `f(; width)` over `f(; width=width)`.
- Triple-quoted `"""..."""` for multi-line literals, not chained `println`.

## Anti-patterns

- `struct Dog <: Mammal where {S<:…}` — invalid syntax. Use `struct Dog{S<:…} <: Mammal`.
- `x is Int` — Python syntax. Julia uses `x isa Int`.
- Throwing exceptions for predictable absence → use `Union{T, Nothing}`.
- Over-narrow signatures: `f(x::Int)` when `f(::Integer)` works (hot loops are the exception).
- Globals without `const` — kills type inference.
- Unicode identifiers / operators (`π`, `χ`, `∇`, `≤`) — see Non-negotiable #1.
- `Pkg.generate` / `]add` outside the project's `mise` task — see Non-negotiable #2.
- Loose `Dict` plumbed deep into the codebase — keep it at the boundary, convert to typed pack early.
