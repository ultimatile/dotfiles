return {
  "monaqa/dial.nvim",
  opts = function(_, opts)
    local augend = require("dial.augend")
    vim.list_extend(opts.groups.default, {
      augend.constant.new({
        elements = { "translated", "untranslated" },
        word = true,
        cyclic = true,
      }),
      augend.constant.new({
        elements = { "yes", "no" },
        word = true,
        cyclic = true,
      }),
      augend.constant.new({
        elements = { "上", "下" },
        word = false,
        cyclic = true,
      }),
      augend.constant.new({
        elements = { "開", "閉" },
        word = false,
        cyclic = true,
      }),
    })
    return opts
  end,
}
