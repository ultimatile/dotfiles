-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- leave Japanese input method for specific events
vim.api.nvim_create_autocmd({ "InsertLeave", "FocusGained", "VimEnter", "BufEnter" }, {
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

-- for typst
vim.api.nvim_create_autocmd({
  "BufNewFile",
  "BufRead",
}, {
  pattern = "*.typ",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_set_option_value("filetype", "typst", { buf = buf })
  end,
})

-- workarond for avoiding conflicts with <CR>-prefix keymaps in command-line window
vim.api.nvim_create_autocmd("CmdwinEnter", {
  callback = function()
    vim.api.nvim_buf_set_keymap(0, "n", "<CR>", "<CR>", { noremap = true, nowait = true })
    vim.api.nvim_buf_set_keymap(0, "n", "Q", ":q<CR>", { noremap = true, nowait = true })
  end,
})

-- set colorscheme based on the current mode
local themes = {
  insert = "tokyonight-night",
  -- TODO: should refer to the predefined colorscheme
  normal = "tokyonight-storm",
}
local set_colorscheme_and_refresh = function(scheme)
  vim.cmd.colorscheme(scheme)
  require("lualine").setup({})
end
vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
  callback = function(event)
    local scheme = event.event == "InsertEnter" and themes.insert or themes.normal
    set_colorscheme_and_refresh(scheme)
  end,
})
