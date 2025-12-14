-- Custom Mason configuration to add JETLS.jl registry
return {
  "mason-org/mason.nvim",
  opts = function(_, opts)
    -- Initialize registries table with default if it doesn't exist
    opts.registries = opts.registries or {
      "github:mason-org/mason-registry",
    }

    -- Add custom registry from GitHub at the beginning (higher priority)
    table.insert(opts.registries, 1, "github:ultimatile/mason-jetls-registry")

    return opts
  end,
}
