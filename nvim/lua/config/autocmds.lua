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

-- for typst doc (split docstring lines with periods)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(args)
    local bufnr = args.buf

    _G.format_rs_comments_func = function(start_line_arg, end_line_arg)
      -- Use passed arguments or fall back to visual marks
      local start_line = start_line_arg or vim.fn.line("'<")
      local end_line = end_line_arg or vim.fn.line("'>")

      -- Convert to 0-indexed for API
      local start_idx = start_line - 1
      local end_idx = end_line  -- end_line is inclusive, nvim_buf_get_lines end is exclusive, so we use end_line as-is

      if start_idx < 0 or start_idx >= end_idx then
        return
      end

      local lines = vim.api.nvim_buf_get_lines(bufnr, start_idx, end_idx, false)

      if #lines == 0 then
        return
      end

      -- Extract content from /// comments and join them, preserving indentation
      local contents = {}
      local common_indent = nil
      for i = 1, #lines do
        local line = lines[i]
        local indent, content = line:match("^(%s*)///%s*(.*)")
        if content then
          -- Determine common indentation level
          if common_indent == nil then
            common_indent = indent
          elseif #indent < #common_indent then
            common_indent = indent
          end
          if content ~= "" then
            table.insert(contents, content)
          end
        end
      end

      if #contents == 0 then
        return
      end

      local full_text = table.concat(contents, " ")

      -- Split by periods while handling various cases
      local result = {}
      local sentences = {}

      -- Split text by periods, keeping the period with the sentence
      local current_sentence = ""
      local i = 1
      while i <= #full_text do
        local char = full_text:sub(i, i)
        current_sentence = current_sentence .. char

        if char == "." then
          -- Check if this is actually end of sentence
          -- Look ahead to see if next char is space, newline, or end of string
          local next_char = full_text:sub(i + 1, i + 1)
          if next_char == "" or next_char:match("%s") then
            -- This is likely end of sentence
            local trimmed = current_sentence:gsub("^%s*", ""):gsub("%s*$", "")
            if trimmed ~= "" then
              table.insert(sentences, trimmed)
            end
            current_sentence = ""
            -- Skip whitespace after period
            while i < #full_text and full_text:sub(i + 1, i + 1):match("%s") do
              i = i + 1
            end
          end
        end
        i = i + 1
      end

      -- Add any remaining text
      local trimmed = current_sentence:gsub("^%s*", ""):gsub("%s*$", "")
      if trimmed ~= "" then
        table.insert(sentences, trimmed)
      end

      -- Convert sentences to /// comments with preserved indentation
      common_indent = common_indent or ""
      for _, sentence in ipairs(sentences) do
        table.insert(result, common_indent .. "/// " .. sentence)
      end

      vim.api.nvim_buf_set_lines(bufnr, start_idx, end_idx, false, result)
    end

    vim.keymap.set("x", "<leader>j", ":<C-u>lua format_rs_comments_func()<CR>", {
      noremap = true,
      silent = true,
      buffer = bufnr,
      desc = "Format Rust doc comments",
    })
  end,
  group = augroup("TypstDoc"),
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
