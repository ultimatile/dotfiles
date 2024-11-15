-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- leave Japanese input method for specific events
vim.api.nvim_create_autocmd({ "InsertLeave", "FocusGained", "VimEnter" }, {
  callback = function()
    vim.fn.system("im-select com.apple.inputmethod.Kotoeri.RomajiTyping.Roman")
  end,
})

-- stop comment continuation
-- https://github.com/LazyVim/LazyVim/discussions/598
local augroup = vim.api.nvim_create_augroup
local autocmds = vim.api.nvim_create_autocmd
augroup("discontinue_comments", { clear = true })
autocmds({ "FileType" }, {
  pattern = { "*" },
  callback = function()
    vim.opt.formatoptions:remove({ "c", "o", "r" })
  end,
  group = "discontinue_comments",
  desc = "no comment continuation",
})
