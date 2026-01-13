return {
  {
    "neovim/nvim-lspconfig",
    ft = { "julia" },
    opts = function(_, opts)
      -- Define JETLS server configuration
      opts.servers = opts.servers or {}
      opts.servers.jetls = {
        cmd = { "jetls" },
        filetypes = { "julia" },
        root_dir = function(fname)
          local util = require("lspconfig.util")
          local root = util.root_pattern("Project.toml", "JuliaProject.toml", ".git")(fname)
          return root or vim.fn.fnamemodify(fname, ":p:h")
        end,
        single_file_support = true,
        settings = {},
      }

      -- Setup function to register JETLS with lspconfig before LazyVim sets it up
      opts.setup = opts.setup or {}
      opts.setup.jetls = function(_, server_opts)
        -- Register JETLS config with lspconfig if not already defined
        local configs = require("lspconfig.configs")
        if not configs.jetls then
          configs.jetls = {
            default_config = {
              cmd = server_opts.cmd,
              filetypes = server_opts.filetypes,
              root_dir = server_opts.root_dir,
              single_file_support = server_opts.single_file_support,
              settings = server_opts.settings,
            },
          }
        end
        -- Return false to let LazyVim handle the setup with vim.lsp.config() and vim.lsp.enable()
        return false
      end

      return opts
    end,
  },
}
