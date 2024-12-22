-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
-- local augroup = vim.api.nvim_create_augroup
local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end
local autocmds = vim.api.nvim_create_autocmd

-- leave Japanese input method for specific events
autocmds({ "InsertLeave", "FocusGained", "VimEnter", "BufEnter" }, {
  callback = function()
    vim.system({ "macism", "com.apple.keylayout.ABC" })
    -- vim.system({ "im-select", "com.apple.inputmethod.Kotoeri.RomajiTyping.Roman" }):wait()
  end,
  group = augroup("IMESwitcher"),
})

-- stop comment continuation
-- https://github.com/LazyVim/LazyVim/discussions/598
autocmds({ "FileType" }, {
  pattern = { "*" },
  callback = function()
    vim.opt.formatoptions:remove({ "c", "o", "r" })
  end,
  group = augroup("DiscontinueComment"),
  desc = "no comment continuation",
})

-- for typst
autocmds({ "BufNewFile", "BufRead" }, {
  pattern = "*.typ",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_set_option_value("filetype", "typst", { buf = buf })
  end,
  group = augroup("Tinymist"),
})

-- workarond for avoiding conflicts with <CR>-prefix keymaps in command-line window
autocmds("CmdwinEnter", {
  callback = function()
    vim.api.nvim_buf_set_keymap(0, "n", "<CR>", "<CR>", { noremap = true, nowait = true })
    vim.api.nvim_buf_set_keymap(0, "n", "Q", ":q<CR>", { noremap = true, nowait = true })
  end,
  group = augroup("CmdWinSetting"),
})

-- Colorscheme table that maps events to themes
-- TODO: should refer to the predefined colorscheme for normal mode
local themes = {
  InsertEnter = "tokyonight-night",
  InsertLeave = "tokyonight-storm",
  RecordingEnter = "terafox",
  RecordingLeave = "tokyonight-storm",
}

-- Function to determine and set the colorscheme
local handle_event_and_update = function(event)
  local scheme = themes[event]
  if scheme then
    vim.cmd.colorscheme(scheme)
    require("lualine").setup({})
  end
end

-- Autocommands for handling mode transitions
vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave", "RecordingEnter", "RecordingLeave" }, {
  callback = function(event)
    handle_event_and_update(event.event)
  end,
  group = augroup("ColorSchemeSwitcher"),
})
