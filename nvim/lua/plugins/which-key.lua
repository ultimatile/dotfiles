return {
  "folke/which-key.nvim",
  opts = {
    -- Explicit trigger list (replaces the default `<auto>`).
    -- `<auto>` refuses to register single-key uppercase prefixes other than Z
    -- (see is_safe in which-key's buf.lua), so Q would never become a which-key
    -- prefix under it and would fall through to Neovim's built-in Q (macro
    -- replay). Registering Q manually here bypasses that guard, making it a
    -- `nowait` prefix that waits for the next key without Vim's timeoutlen.
    triggers = {
      { "<leader>", mode = { "n", "v" } },
      { "g", mode = { "n", "v" } },
      { "Q", mode = "n" },
    },
  },
}
