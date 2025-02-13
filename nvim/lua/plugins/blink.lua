return {
  "saghen/blink.cmp",
  dependencies = { "kdheepak/cmp-latex-symbols", "saghen/blink.compat" },
  opts = {
    keymap = {
      ["<S-Tab>"] = {
        LazyVim.cmp.map({ "snippet_backward", "ai_accept_WORD" }),
        "fallback",
      },
      ["<C-/>"] = {
        LazyVim.cmp.map({ "snippet_backward", "ai_accept_word" }),
        "fallback",
      },
    },
    sources = {
      compat = { "latex_symbols" },
      per_filetype = {
        julia = { "lsp", "path", "snippets", "buffer", "latex_symbols" },
      },
      -- enclose by function to avoid automatic loading compat to default
      default = function()
        return { "lsp", "path", "snippets", "buffer" }
      end,
    },
  },
}
