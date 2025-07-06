# Package Development

## Project Structure
```
MyPackage.jl/
├── Project.toml
├── src/
│   └── MyPackage.jl
├── test/
│   ├── runtests.jl
│   └── Project.toml
├── docs/
│   ├── make.jl
│   ├── Project.toml
│   └── src/
├── .github/
│   └── workflows/
│       ├── CI.yml
│       └── TagBot.yml
└── README.md
```

## Dependencies and Compatibility
```toml
# Project.toml
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
DataFrames = "1.3"
julia = "1.6"
```

## Testing Best Practices
```julia
# test/runtests.jl
using MyPackage
using Test

@testset "MyPackage.jl" begin
    @testset "Basic functionality" begin
        @test my_function(2, 3) == 5
        @test_throws ArgumentError my_function(-1, 3)
    end
    
    @testset "Edge cases" begin
        @test isnan(my_function(NaN, 1))
        @test_broken known_bug() == expected  # Known bug
    end
end
```

## Documentation with Documenter.jl
```julia
# docs/make.jl
using Documenter, MyPackage

makedocs(
    sitename = "MyPackage.jl",
    modules = [MyPackage],
    pages = [
        "Home" => "index.md",
        "Manual" => "manual.md",
        "API" => "api.md"
    ]
)

deploydocs(
    repo = "github.com/username/MyPackage.jl.git"
)
```

## GitHub Actions CI
```yaml
# .github/workflows/CI.yml
name: CI
on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        julia-version: ['1.6', '1', 'nightly']
        os: [ubuntu-latest, windows-latest, macOS-latest]
    steps:
      - uses: actions/checkout@v2
      - uses: julia-actions/setup-julia@v1
        with:
          version: ${{ matrix.julia-version }}
      - uses: julia-actions/cache@v1
      - uses: julia-actions/julia-buildpkg@v1
      - uses: julia-actions/julia-runtest@v1
      - uses: julia-actions/julia-processcoverage@v1
      - uses: codecov/codecov-action@v1
```

## Package Registration
1. Use PkgTemplates.jl for template creation
2. Register to General Registry with `@JuliaRegistrator register`
3. Auto-merge after 3-day review period