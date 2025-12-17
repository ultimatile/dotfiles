return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Extend LazyVim's tinymist configuration
      opts.servers = opts.servers or {}
      opts.servers.tinymist = opts.servers.tinymist or {}
      opts.servers.tinymist.settings = vim.tbl_deep_extend("force", opts.servers.tinymist.settings or {}, {
        exportPdf = "onType",
      })
      return opts
    end,
  },
}
