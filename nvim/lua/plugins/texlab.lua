return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      texlab = {
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
