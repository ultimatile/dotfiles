return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.typos_lsp = opts.servers.typos_lsp or {}

      -- Add typst to the filetypes list
      opts.servers.typos_lsp.filetypes = vim.list_extend(
        opts.servers.typos_lsp.filetypes or {
          "text", "markdown", "gitcommit"
        },
        { "typst" }
      )

      return opts
    end,
  },
}
