return {
  {
    "neovim/nvim-lspconfig",
    ft = "julia",
    config = function()
      local lspconfig = require("lspconfig")
      local configs = require("lspconfig.configs")
      local util = require("lspconfig.util")

      -- Define JETLS if not already defined
      if not configs.jetls then
        configs.jetls = {
          default_config = {
            cmd = { "jetls" },
            filetypes = { "julia" },
            root_dir = function(fname)
              local root = util.root_pattern("Project.toml", "JuliaProject.toml", ".git")(fname)
              return root or vim.fn.fnamemodify(fname, ":p:h")
            end,
            single_file_support = true,
            settings = {},
          },
        }
      end

      -- Setup JETLS
      lspconfig.jetls.setup({})

      -- Configure diagnostics for virtual text (like LazyVim)
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
      })
    end,
  },
}
