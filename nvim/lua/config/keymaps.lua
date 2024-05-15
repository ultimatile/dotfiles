-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function remap_keys(lhs, rhs)
    vim.api.nvim_set_keymap('n', lhs, rhs, { noremap = true, silent = true })
end

remap_keys('<CR><CR>', '<C-w><C-w>')
remap_keys('j', 'h') -- go left
remap_keys('k', 'gk') -- go up
remap_keys('l', 'gj') -- go down
remap_keys(';', 'l') -- go right
remap_keys('h', ';')

vim.keymap.set({'i', 'v', 's'}, 'jj', '<Esc>', { noremap = true, silent = true })

--  vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = true, silent = true })
