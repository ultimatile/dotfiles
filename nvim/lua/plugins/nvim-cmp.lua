return {
  "hrsh7th/nvim-cmp",
  ---@param opts cmp.ConfigSchema
  opts = function(_, opts)
    local cmp = require("cmp")
    local copilot = require("copilot.suggestion")
    opts.mapping = vim.tbl_extend("force", opts.mapping, {
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if copilot.is_visible() then
          LazyVim.create_undo()
          copilot.accept_word()
        else
          fallback()
        end
      end, { "i", "s" }),
    })
  end,
}
