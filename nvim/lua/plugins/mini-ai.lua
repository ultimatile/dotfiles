return {
  "echasnovski/mini.ai",
  opts = {
    custom_textobjects = {
      ["_"] = function()
        return {
          -- 内側 (inner)
          i = vim.regex("%w\\+_%w\\+"),
          -- 外側 (around)
          a = vim.regex("%w\\+_%w\\+"),
        }
      end,
    },
  },
}
