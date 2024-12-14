return {
  "zbirenbaum/copilot.lua",
  opts = function()
    local copilot = require("copilot.suggestion")
    local copilot_accept_WORD = function()
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
    LazyVim.cmp.actions.ai_accept_WORD = function()
      if copilot.is_visible() then
        LazyVim.create_undo()
        copilot_accept_WORD()
        return true
      end
    end
  end,
}
