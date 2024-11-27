-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function remap_keys(lhs, rhs)
  vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true })
end

remap_keys("<CR><CR>", "<C-w><C-w>")
-- Workaround when <CR> is not available
remap_keys("<S-CR><S-CR>", "<C-w><C-w>")

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

-- original dd
remap_keys("<leader>d", "d")
remap_keys("<leader>D", "dd")

-- escaping by jj
vim.keymap.set({ "i", "v", "s" }, "jj", "<Esc>", { noremap = true, silent = true })

-- show all the hidden diagnostics
vim.keymap.set("n", "<leader>m", vim.diagnostic.open_float, { noremap = true, silent = true })

-- move to the end of the line
vim.keymap.set("i", "<C-E>", "<C-o>$", { noremap = true, silent = true })

-- line swapping
-- Normal mode mappings
-- move the line up
vim.keymap.set("n", "<C-S-Up>", '":move -1-" .. v:count1 .. "<CR>==l"', { noremap = true, expr = true, silent = true })
-- move the line down
vim.keymap.set("n", "<C-S-Down>", '":move +1<CR>==" .. v:count1 .. "l"', { noremap = true, expr = true, silent = true })
-- Visual mode mappings
-- move the line up
vim.keymap.set("x", "<C-S-Up>", ":move '<-2<CR>gv=gv", { noremap = true, silent = true })
-- move the line down
vim.keymap.set("x", "<C-S-Down>", ":move '>+1<CR>gv=gv", { noremap = true, silent = true })

-- Q-prefix keymaps that behave like Z-prefix commands in normal mode
local function nmapQ()
  -- Wait for a character input
  local char = vim.fn.getchar()

  -- Convert the input to a readable character if needed
  if type(char) == "number" then
    char = vim.fn.nr2char(char)
  end

  -- Mapping of keys to commands for Q-prefix keymaps
  local keymap_actions_Q = {
    Q = "conf qa", -- QQ
    S = "wa", -- QS
    W = "xa", -- QW
    Z = "qa!", -- QZ
  }

  -- Execute the corresponding command if the keymap exists
  local cmdQ = keymap_actions_Q[char]
  if cmdQ then
    vim.cmd(cmdQ)
  else
    print("No keymap for Q" .. char)
  end
end

-- Map Q in normal mode to nmapQ function
vim.keymap.set("n", "Q", "", { noremap = true, silent = true, callback = nmapQ })
