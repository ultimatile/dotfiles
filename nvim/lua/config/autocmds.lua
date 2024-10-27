-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- leave Japanese input method for specific events
vim.api.nvim_create_autocmd({ "InsertLeave", "FocusGained" }, {
  callback = function()
    vim.fn.system("im-select com.apple.inputmethod.Kotoeri.RomajiTyping.Roman")
  end,
})
