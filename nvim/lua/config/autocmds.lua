-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
-- local augroup = vim.api.nvim_create_augroup
local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

-- IME Control System
-- Efficiently manage IME state to switch to English input outside of insert mode

-- Check if buffer should be ignored for IME control
local function should_ignore_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Early return for invalid buffers
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return true
  end

  local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  -- Built-in special buffers
  if buftype ~= "" and buftype ~= "acwrite" then
    return true
  end

  -- Plugin special buffers (common ones)
  local special_filetypes = {
    "neo-tree",
    "lazy",
    "mason",
    "trouble",
    "lspinfo",
    "checkhealth",
    "help",
    "qf",
    "quickfix",
    "toggleterm",
    "TelescopePrompt",
    "which-key",
    "notify",
    "noice",
    "alpha",
    "dashboard",
  }

  for _, ft in ipairs(special_filetypes) do
    if filetype == ft then
      return true
    end
  end

  -- Special buffer name patterns (brackets-enclosed names or empty buffers)
  return bufname:match("^%[") ~= nil or bufname == ""
end

-- State management for IME control
local ime_state = {
  last_switch_time = 0,
  last_mode = "",
  debounce_ms = 100,
}

-- Switch IME to English with state management
local function switch_ime_to_english()
  local current_time = (vim.uv or vim.loop).now()

  -- Debounce: ignore if called too frequently
  if current_time - ime_state.last_switch_time < ime_state.debounce_ms then
    return
  end

  -- Check if we should ignore current buffer
  if should_ignore_buffer() then
    return
  end

  -- Perform IME switch asynchronously
  vim.schedule(function()
    vim.system({ "macism", "com.apple.keylayout.ABC" }, { detach = true })
  end)

  ime_state.last_switch_time = current_time
end

-- Enhanced IME switching with comprehensive event coverage
autocmd({ "InsertLeave", "WinEnter", "FocusGained", "VimEnter", "VimResume", "CmdlineLeave", "TabEnter" }, {
  callback = switch_ime_to_english,
  group = augroup("IMESwitcher"),
})

-- stop comment continuation
-- https://github.com/LazyVim/LazyVim/discussions/598
autocmd({ "FileType" }, {
  pattern = { "*" },
  callback = function()
    vim.opt.formatoptions:remove({ "c", "o", "r" })
  end,
  group = augroup("DiscontinueComment"),
  desc = "no comment continuation",
})

-- for typst
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.typ",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_set_option_value("filetype", "typst", { buf = buf })
  end,
  group = augroup("Tinymist"),
})

-- workaround for avoiding conflicts with <CR>-prefix keymaps in command-line window
autocmd("CmdwinEnter", {
  callback = function()
    vim.api.nvim_buf_set_keymap(0, "n", "<CR>", "<CR>", { noremap = true, nowait = true })
    vim.api.nvim_buf_set_keymap(0, "n", "Q", ":q<CR>", { noremap = true, nowait = true })
  end,
  group = augroup("CmdWinSetting"),
})

-- Colorscheme table that maps events to themes
-- TODO: should refer to the predefined colorscheme for normal mode
local themes = {
  InsertEnter = "tokyonight-night",
  InsertLeave = "tokyonight-storm",
  RecordingEnter = "terafox",
  RecordingLeave = "tokyonight-storm",
}

-- Function to determine and set the colorscheme
local handle_event_and_update = function(event)
  local scheme = themes[event]
  if scheme then
    -- schedule is necessary to emit ColorScheme event
    vim.schedule(function()
      vim.cmd.colorscheme(scheme)
    end)
  end
end

-- Autocommands for handling mode transitions
autocmd({ "InsertEnter", "InsertLeave", "RecordingEnter", "RecordingLeave" }, {
  callback = function(event)
    handle_event_and_update(event.event)
  end,
  group = augroup("ColorSchemeSwitcher"),
})

-- https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques#disable--enable-cmp-sources-only-on-certain-buffers
-- https://github.com/LazyVim/LazyVim/discussions/5338
local has_cmp, cmp = pcall(require, "cmp")
if has_cmp then
  autocmd("FileType", {
    pattern = "julia",
    callback = function()
      local sources = vim.deepcopy(cmp.get_config().sources or {})
      table.insert(sources, { name = "latex_symbols", option = { strategy = 0 } })
      cmp.setup.buffer({ sources = sources }) ---@diagnostic disable-line: redundant-parameter
    end,
    group = augroup("NvimCmp"),
  })
end

autocmd("InsertEnter", {
  pattern = "*",
  callback = function()
    -- store the column number when entering insert mode
    vim.b.insert_mode_start_col = vim.fn.col(".")
  end,
  group = augroup("InsertModeStartCol"),
})
