local dictionary_score_offset = -3
local frequency_ranks

local function get_frequency_ranks()
  if frequency_ranks then
    return frequency_ranks
  end

  frequency_ranks = {}
  local frequency_file = vim.fn.stdpath("config") .. "/third-party/frequencywords/en_50k.txt"
  if vim.fn.filereadable(frequency_file) == 0 then
    return frequency_ranks
  end

  -- Load the rank table lazily so dictionary frequency scoring does not affect startup time.
  for rank, line in ipairs(vim.fn.readfile(frequency_file)) do
    local word = line:match("^(%S+)%s+%d+$")
    if word then
      frequency_ranks[word:lower()] = rank
    end
  end

  return frequency_ranks
end

local function get_frequency_bonus(rank)
  -- Use coarse bands so common usage breaks close fuzzy-score ties without dominating match quality.
  if not rank then
    return 0
  elseif rank <= 1000 then
    return 6
  elseif rank <= 5000 then
    return 4
  elseif rank <= 25000 then
    return 2
  elseif rank <= 50000 then
    return 1
  end
  return 0
end

return {
  "saghen/blink.cmp",
  dependencies = { "kdheepak/cmp-latex-symbols", "saghen/blink.compat", "Kaiser-Yang/blink-cmp-dictionary" },
  opts = {
    fuzzy = {
      implementation = "rust", -- Full Unicode support for CJK languages
      max_typos = function(keyword)
        if keyword:match("[\128-\255]") then
          return 0
        end
        return math.floor(#keyword / 4)
      end,
      use_proximity = false, -- Disable proximity scoring for CJK languages
      sorts = { "exact", "score", "sort_text", "label" },
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
        dictionary = {
          module = "blink-cmp-dictionary",
          name = "Dict",
          min_keyword_length = 3,
          transform_items = function(_, items)
            local ranks = get_frequency_ranks()
            for _, item in ipairs(items) do
              local rank = ranks[item.label:lower()]
              item.score_offset = dictionary_score_offset + get_frequency_bonus(rank)
            end
            return items
          end,
          opts = {
            dictionary_files = { "/usr/share/dict/words" },
          },
        },
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
        return { "lsp", "path", "snippets", "buffer", "dictionary" }
      end,
    },
  },
}
