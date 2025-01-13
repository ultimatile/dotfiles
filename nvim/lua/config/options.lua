-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- stop relative line numbers
vim.opt.relativenumber = false

-- Disable conceal
vim.opt.conceallevel = 0

-- enable line wrapping
vim.o.wrap = true

-- enable yank to clipboard
-- vim.opt.clipboard = "unnamedplus"

-- vim.o.timeout = false

-- disable mini.pairs
-- need to disable this because LazyVim loads mini.pairs automatically
-- https://github.com/LazyVim/LazyVim/discussions/2248
vim.g.minipairs_disable = true

-- use copilot with tab accept
vim.g.ai_cmp = false

-- set spelllang
vim.opt.spelllang = { "en", "cjk" }

-- set what is "word"
vim.opt.iskeyword:remove({ "_" })

vim.g.mapleader = "q"

require("config.usercmds")
