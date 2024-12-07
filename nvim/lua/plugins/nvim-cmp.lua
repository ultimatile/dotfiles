return {
  "hrsh7th/nvim-cmp",
  ---@param opts cmp.ConfigSchema
  opts = function(_, opts)
    local cmp = require("cmp")
    local copilot = require("copilot.suggestion")
    local accept_WORD = function()
      copilot.accept(function(suggestion)
        local range, text = suggestion.range, suggestion.text

        local cursor = vim.api.nvim_win_get_cursor(0)
        local _, character = cursor[1], cursor[2]
        local _, char_idx = string.find(text, "[^%s]+", character + 1)
        if char_idx then
          suggestion.text = string.sub(text, 1, char_idx)

          range["end"].line = range["start"].line
          range["end"].character = char_idx
        end
        return suggestion
      end)
    end
    opts.mapping = vim.tbl_extend("force", opts.mapping, {
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if copilot.is_visible() then
          LazyVim.create_undo()
          accept_WORD()
          -- copilot.accept_word()
        else
          fallback()
        end
      end, { "i", "s" }),
    })
  end,
}
