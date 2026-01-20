return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      texlab = {
        -- Lower priority for .latexmkrc to avoid misdetecting home directory as root
        -- See: https://github.com/neovim/nvim-lspconfig/issues/2975
        root_markers = { ".git", ".texlabroot", "texlabroot", "Tectonic.toml", ".latexmkrc", "latexmkrc" },
        settings = {
          texlab = {
            build = {
              executable = "latexmk",
              args = { "-pv" },
              onSave = true,
            },
            chktex = {
              onOpenAndSave = true,
              onEdit = true,
            },
          },
        },
      },
    },
  },
}
