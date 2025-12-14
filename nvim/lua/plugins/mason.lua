-- Custom Mason configuration to add JETLS.jl registry
return {
  "mason-org/mason.nvim",
  opts = function(_, opts)
    -- Add custom registry path to Lua package path
    local registry_path = vim.fn.expand("~/ghq/github.com/ultimatile/mason-jetls-registry")
    if vim.fn.isdirectory(registry_path) == 1 then
      package.path = package.path .. ";" .. registry_path .. "/lua/?.lua"
      package.path = package.path .. ";" .. registry_path .. "/lua/?/init.lua"
    end

    -- Initialize registries table with default if it doesn't exist
    opts.registries = opts.registries or {
      "github:mason-org/mason-registry",
    }

    -- Add custom registry at the beginning (higher priority)
    table.insert(opts.registries, 1, "lua:mason-jetls-registry")

    return opts
  end,
}
