return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    table.insert(opts.dashboard.preset.keys, 9, { icon = "󱌣 ", key = "m", desc = "Mason", action = ":Mason" })
    opts.lazygit = { win = { keys = { term_normal = false } } }
    opts.picker = opts.picker or {}
    opts.picker.sources = opts.picker.sources or {}
    opts.picker.sources.explorer = opts.picker.sources.explorer or {}
    opts.picker.sources.explorer.exclude = {
      "*.aux",
      "*.out",
      "*.toc",
      "*.fls",
      "*.fdb_latexmk",
      "*.synctex.gz",
      "*.bbl",
      "*.blg",
      "*.nav",
      "*.snm",
      "*.vrb",
      "*.xdv",
    }
    return opts
  end,
}
