return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      ["<S-Tab>"] = {
        LazyVim.cmp.map({ "snippet_backward", "ai_accept_WORD" }),
        "fallback",
      },
    },
  },
}
