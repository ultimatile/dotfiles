-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- Keymap utility functions

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

local function defaultopts(opts)
  opts = opts or {}
  opts.noremap = opts.noremap == nil and true or opts.noremap
  opts.silent = opts.silent == nil and true or opts.silent
  return opts
end

local function nmapkey(lhs, rhs, opts)
  vim.keymap.set("n", lhs, rhs, defaultopts(opts))
end

local function xmapkey(lhs, rhs, opts)
  vim.keymap.set("x", lhs, rhs, defaultopts(opts))
end

local function omapkey(lhs, rhs, opts)
  vim.keymap.set("o", lhs, rhs, defaultopts(opts))
end

local function imapkey_noautocmd(lhs, rhs, opts)
  vim.keymap.set("i", lhs, function()
    local ei = vim.opt.eventignore
    vim.opt.eventignore = "all"
    if type(rhs) == "function" then
      rhs()
    else
      feedkeys("n", rhs)
    end
    vim.schedule(function()
      vim.opt.eventignore = ei
    end)
  end, defaultopts(opts))
end

-- Add any additional keymaps here

-- https://zenn.dev/vim_jp/articles/43d021f461f3a4#i%3Cspace%3E%E3%81%A7word%E9%81%B8%E6%8A%9E
omapkey("<Space>", "W")
xmapkey("<Space>", "W")

xmapkey("p", '"_dP', { desc = "Paste without yanking" })

-- duplicate the current line(s)
nmapkey("<C-P>", ":copy.<CR>", { desc = "Duplicate current line(s) below" })
nmapkey("<C-S-P>", ":copy-1<CR>", { desc = "Duplicate current line(s) above" })
xmapkey("<C-P>", ":copy '<-1<CR>gv", { desc = "Duplicate selected lines below" })
xmapkey("<C-S-P>", ":copy '>+0<CR>gv", { desc = "Duplicate selected lines above" })

xmapkey("gp", "y`>p", { desc = "Duplicate selected characters" })

-- map <Tab> to switch between windows
nmapkey("<Tab>", "<C-w><C-w>", { desc = "Next Window" })
-- map <S-Tab> to switch between buffers (needs bufferline)
nmapkey("<S-Tab>", function()
  vim.cmd("BufferLineCycleNext")
end, { desc = "Next Buffer" })
nmapkey("<S-Right>", function()
  vim.cmd("BufferLineCycleNext")
end, { desc = "Next Buffer" })
nmapkey("<S-Left>", function()
  vim.cmd("BufferLineCyclePrev")
end, { desc = "Previous Buffer" })
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

nmapkey("<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete buffer" })

nmapkey("<leader>cp", function()
  local col = vim.fn.col(".")
  local line = vim.fn.getline(".")
  local before = line:sub(1, col - 1)
  local after = line:sub(col)
  vim.fn.setline(".", before) ---@diagnostic disable-line: param-type-mismatch
  vim.fn.append(".", after) ---@diagnostic disable-line: param-type-mismatch
end, { desc = "Split current line at cursor" })

-- show all the hidden diagnostics
nmapkey("<leader>m", vim.diagnostic.open_float, { desc = "show all the hidden diagnostics" })
nmapkey("<leader>snH", function()
  require("noice").cmd("history")
  vim.cmd("wincmd T")
end, { desc = "Noice History (tab)" })

local function put_linewise_below()
  local reg_content = vim.fn.getreg('"')
  local lines = vim.split(reg_content, "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines, #lines)
  end
  vim.api.nvim_put(lines, "l", true, true)
end

local function put_linewise_above()
  local reg_content = vim.fn.getreg('"')
  local lines = vim.split(reg_content, "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines, #lines)
  end
  vim.api.nvim_put(lines, "l", false, true)
end

-- <leader>p will conflict with yanky.nvim's keymap if enabled
nmapkey("<Leader>p", put_linewise_below, { desc = "Linewise paste below" })
nmapkey("<Leader>P", put_linewise_above, { desc = "Linewise paste above" })

-- keep the cursor position when moving lines
nmapkey("~", "g~l")

imapkey_noautocmd("<C-B>", "<Esc>I")
imapkey_noautocmd("<C-E>", "<Esc>g_a")
imapkey_noautocmd("<C-O>", "<Esc>o")
-- move to the next line and keep the cursor position
imapkey_noautocmd("<C-J>", function()
  local col = vim.b.insert_mode_start_col or vim.fn.col(".")
  feedkeys("n", "<ESC>", { do_lt = false, escape_ks = true })
  vim.schedule(function()
    vim.cmd("normal! j" .. col .. "|")
    vim.cmd.startinsert()
  end)
end)

-- line swapping
-- Normal mode mappings
-- move the line up
nmapkey("<M-Up>", '":move -1-" .. v:count1 .. "<CR>==l"', { expr = true, desc = "Move line up" })
-- move the line down
nmapkey("<M-Down>", '":move +1<CR>==" .. v:count1 .. "l"', { expr = true, desc = "Move line down" })
-- Visual mode mappings
-- move the line up
xmapkey("<M-Up>", ":move '<-2<CR>gv=gv", { desc = "Move selected lines up" })
-- move the line down
xmapkey("<M-Down>", ":move '>+1<CR>gv=gv", { desc = "Move selected lines down" })

-- Map Q in normal mode without timeout
nmapkey("Q", function()
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
  (keymap_actions_Q[char] or function()
    print("No keymap for Q" .. char)
  end)()
end, { desc = "Q-prefix" })
