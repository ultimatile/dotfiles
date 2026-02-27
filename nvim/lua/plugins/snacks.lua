return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    table.insert(opts.dashboard.preset.keys, 9, { icon = "󱌣 ", key = "m", desc = "Mason", action = ":Mason" })
    opts.lazygit = { win = { keys = { term_normal = false } } }
    opts.picker = opts.picker or {}
    opts.picker.sources = opts.picker.sources or {}
    opts.picker.sources.explorer = opts.picker.sources.explorer or {}
    opts.picker.sources.explorer.actions = opts.picker.sources.explorer.actions or {}
    opts.picker.sources.explorer.actions.explorer_yank_basename = function(picker)
      local names = {} ---@type string[]
      if vim.fn.mode():find("^[vV]") then
        picker.list:select()
      end
      for _, item in ipairs(picker:selected({ fallback = true })) do
        local path = Snacks.picker.util.path(item)
        if path and path ~= "" then
          names[#names + 1] = vim.fs.basename(path)
        end
      end
      picker.list:set_selected() -- clear selection
      local value = table.concat(names, "\n")
      vim.fn.setreg(vim.v.register or "+", value, "l")
      Snacks.notify.info("Yanked " .. #names .. " file names")
    end
    opts.picker.sources.explorer.win = opts.picker.sources.explorer.win or {}
    opts.picker.sources.explorer.win.list = opts.picker.sources.explorer.win.list or {}
    opts.picker.sources.explorer.win.list.keys = opts.picker.sources.explorer.win.list.keys or {}
    opts.picker.sources.explorer.win.list.keys["Y"] = { "explorer_yank_basename", mode = { "n", "x" } }
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
