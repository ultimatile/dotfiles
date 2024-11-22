-- TODO: harmonize neo-tree with im-select autocmd.
-- taken from https://github.com/LazyVim/LazyVim/discussions/2139
-- naive event_handelers sections do not work
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
  },
}
