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

-- stopping yank when erasing
remap_keys("x", '"_x') -- character erasure without yank
remap_keys("d", '"_d') -- stopping yank when end-of-line erasure
remap_keys("c", '"_c') -- stopping yank when changing
remap_keys("D", '"_D') -- stopping yank when lines erasure

remap_keys("<leader>d", "dd")

-- escaping by jj
vim.keymap.set({ "i", "v", "s" }, "jj", "<Esc>", { noremap = true, silent = true })
--  vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = true, silent = true })

-- show all the hidden diagnostics
vim.keymap.set("n", "<leader>m", vim.diagnostic.open_float, { noremap = true, silent = true })

-- Normal mode mappings
-- move the line up
vim.api.nvim_set_keymap(
  "n",
  "<C-S-Up>",
  '":move -1-" .. v:count1 .. "<CR>==l"',
  { noremap = true, expr = true, silent = true }
)
-- move the line down
vim.api.nvim_set_keymap(
  "n",
  "<C-S-Down>",
  '":move +1<CR>==" .. v:count1 .. "l"',
  { noremap = true, expr = true, silent = true }
)

-- Visual mode mappings
-- move the line up
vim.api.nvim_set_keymap("x", "<C-S-Up>", ":move '<-2<CR>gv=gv", { noremap = true, silent = true })
-- move the line down
vim.api.nvim_set_keymap("x", "<C-S-Down>", ":move '>+1<CR>gv=gv", { noremap = true, silent = true })
