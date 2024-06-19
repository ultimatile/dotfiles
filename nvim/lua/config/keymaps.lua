-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function remap_keys(lhs, rhs)
  vim.api.nvim_set_keymap("n", lhs, rhs, { noremap = true, silent = true })
end

-- escaping by double return
remap_keys("<CR><CR>", "<C-w><C-w>")

-- moving
remap_keys("j", "h") -- go left
remap_keys("k", "gk") -- go up
remap_keys("l", "gj") -- go down
remap_keys(";", "l") -- go right
remap_keys("h", ";")

--
remap_keys("x", '"_x') -- character erasure without yank
remap_keys("d", '"_d') -- opping yank when end-of-line erasure
remap_keys("D", '"_D') -- topping yank when lines erasure

-- escaping by jj
vim.keymap.set({ "i", "v", "s" }, "", "<Esc>", { noremap = true, silent = true })
--  vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = true, silent = true })
