return {
  "hrsh7th/nvim-cmp",
  dependencies = { "kdheepak/cmp-latex-symbols" },
  opts = function(_, opts)
    opts.mapping = vim.tbl_extend("force", opts.mapping, {
      ["<S-Tab>"] = function(fallback)
        return LazyVim.cmp.map({ "snippet_backward", "ai_accept_WORD" }, fallback)()
      end,
      ["<C-/>"] = function(fallback)
        return LazyVim.cmp.map({ "snippet_backward", "ai_accept_word" }, fallback)()
      end,
    })
  end,
}
