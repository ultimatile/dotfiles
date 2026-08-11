return {
  "folke/which-key.nvim",
  opts = {
    -- Keep which-key's default automatic triggers and add Q explicitly.
    -- `<auto>` refuses to register single-key uppercase prefixes other than Z,
    -- so Q must be listed separately to override Neovim's built-in Q (macro
    -- replay) with a `nowait` which-key trigger.
    triggers = {
      { "<auto>", mode = "nxso" },
      { "Q", mode = "n" },
    },
  },
}
