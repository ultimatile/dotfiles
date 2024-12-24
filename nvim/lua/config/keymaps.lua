-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function feedkeys(mode, keys, opts)
  opts = opts or {}

  local from_part = opts.from_part == nil and true or opts.from_part
  local do_lt = opts.do_lt == nil and true or opts.do_lt
  local special = opts.special == nil and true or opts.special
  local escape_ks = opts.escape_ks == nil and false or opts.escape_ks

  local termcodes = vim.api.nvim_replace_termcodes(keys, from_part, do_lt, special)
  -- mode is not an usual vim mode
  vim.api.nvim_feedkeys(termcodes, mode, escape_ks)
end

local function nmapkey(lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap == nil and true or opts.noremap
  opts.silent = opts.silent == nil and true or opts.silent
  vim.keymap.set("n", lhs, rhs, opts)
end

local function imapkey_noautocmd(lhs, rhs)
  vim.keymap.set("i", lhs, function()
    local ei = vim.opt.eventignore
    vim.opt.eventignore = "all"
    feedkeys("n", rhs)
    vim.defer_fn(function()
      vim.opt.eventignore = ei
    end, 0)
  end, { noremap = true, silent = true })
end

nmapkey("<Tab>", "<C-w><C-w>")
-- nmapkey("<CR><CR>", "<C-w><C-w>")
-- Workaround when <CR> is not available
-- nmapkey("<S-CR><S-CR>", "<C-w><C-w>")

-- suppress the default behaviors
nmapkey("q", "<Nop>")
nmapkey("<C-Z>", "<Nop>")

-- moving
nmapkey("j", "h") -- go left
nmapkey("k", "gk") -- go up
nmapkey("l", "gj") -- go down
nmapkey(";", "l") -- go right
nmapkey("h", ";")

-- stopping yank when erasing
nmapkey("x", '"_x') -- character erasure without yank
nmapkey("d", '"_d') -- stopping yank when end-of-line erasure
nmapkey("c", '"_c') -- stopping yank when changing
nmapkey("D", '"_D') -- stopping yank when lines erasure

-- original dd
nmapkey("<leader>D", "d")
nmapkey("<leader>DD", "dd")

-- escaping by jj
vim.keymap.set({ "i", "v", "s" }, "jj", "<Esc>", { noremap = true, silent = true })

-- show all the hidden diagnostics
nmapkey("<leader>m", vim.diagnostic.open_float, { desc = "show all the hidden diagnostics" })

imapkey_noautocmd("<C-B>", "<Esc>I")
imapkey_noautocmd("<C-E>", "<Esc>g_a")
imapkey_noautocmd("<C-O>", "<Esc>o")

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

local function nmapQ()
  -- Wait for a character input
  local char = vim.fn.getchar()

  -- Convert the input to a readable character if needed
  if type(char) == "number" then
    char = vim.fn.nr2char(char)
  end

  -- Mapping of keys to actions for Q-prefix keymaps
  local keymap_actions_Q = {
    C = function()
      feedkeys("n", "q:")
    end, -- Open command-line window (QC)
    Q = function()
      vim.cmd("confirm qa")
    end, -- Confirm quit all (QQ)
    R = function()
      feedkeys("n", "q")
    end, -- Start/Stop macro recording (QR)
    S = function()
      vim.cmd("wa")
    end, -- Write all buffers (QS)
    W = function()
      vim.cmd("xa")
    end, -- Write and quit all buffers (QW)
    Z = function()
      vim.cmd("qa!")
    end, -- Force quit all buffers (QZ)
  }

  -- Execute the corresponding function if the keymap exists
  local action = keymap_actions_Q[char]
  if action then
    action()
  else
    print("No keymap for Q" .. char)
  end
end

-- Map Q in normal mode to nmapQ function
nmapkey("Q", nmapQ, { desc = "Q-prefix" })
