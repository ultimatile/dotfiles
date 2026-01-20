return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    table.insert(opts.dashboard.preset.keys, 9, { icon = "󱌣 ", key = "m", desc = "Mason", action = ":Mason" })
    opts.lazygit = { win = { keys = { term_normal = false } } }
    return opts
  end,
}
