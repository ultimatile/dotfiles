return {
  "saghen/blink.cmp",
  dependencies = { "kdheepak/cmp-latex-symbols", "saghen/blink.compat" },
  opts = {
    keymap = {
      ["<S-Tab>"] = {
        LazyVim.cmp.map({ "snippet_backward", "ai_accept_WORD" }),
        "fallback",
      },
    },
    sources = {
      compat = { "latex_symbols" },
    },
  },
}
