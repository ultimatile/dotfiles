if true then
  return {}
end
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
      window = {
        mappings = {
          -- ["L"] = "open_nofocus",
          -- ["<CR>"] = "quit_on_open",
          -- ["l"] = "quit_on_open",
        },
      },
      commands = {
        open_nofocus = function(state)
          require("neo-tree.sources.filesystem.commands").open(state)
          vim.schedule(function()
            vim.cmd([[Neotree focus]])
          end)
        end,
        quit_on_open = function(state)
          local node = state.tree:get_node()
          if require("neo-tree.utils").is_expandable(node) then
            state.commands["toggle_node"](state)
          else
            state.commands["open"](state)
            state.commands["close_window"](state)
            vim.cmd("normal! M")
          end
        end,
      },
    },
  },
}
