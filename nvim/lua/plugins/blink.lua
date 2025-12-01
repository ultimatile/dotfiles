return {
  "saghen/blink.cmp",
  dependencies = { "kdheepak/cmp-latex-symbols", "saghen/blink.compat" },
  opts = {
    fuzzy = {
      implementation = "rust", -- Full Unicode support for CJK languages
      max_typos = 0, -- Strict matching to reduce over-matching in Japanese
      use_proximity = false, -- Disable proximity scoring for CJK languages
    },
    completion = {
      keyword = {
        range = "prefix", -- Only match text before cursor for CJK languages
      },
    },
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
      providers = {
        path = {
          min_keyword_length = 2, -- Require at least 3 characters before triggering path completion
          opts = {
            trailing_slash = true,
            label_trailing_slash = true,
            get_cwd = function(_)
              return vim.fn.getcwd()
            end,
            show_hidden_files_by_default = false,
          },
        },
      },
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
