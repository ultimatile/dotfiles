return {
  "zbirenbaum/copilot.lua",
  dependencies = {
    "tpope/vim-repeat",
  },
  opts = function(_, opts)
    opts = opts or {}
    opts.print_log_level = vim.log.levels.ERROR

    local copilot = require("copilot.suggestion")
    local copilot_accept_WORD = function()
      copilot.accept(function(suggestion)
        local range, text = suggestion.range, suggestion.text

        local cursor = vim.api.nvim_win_get_cursor(0)
        local _, character = cursor[1], cursor[2]
        local _, char_idx = string.find(text, "[^%s]+", character + 1)
        if char_idx then
          -- `partial_text` keeps the preview and skips the re-request
          -- (zbirenbaum/copilot.lua#469); `text` would make it a full accept.
          suggestion.partial_text = string.sub(text, 1, char_idx)

          range["end"].line = range["start"].line
          range["end"].character = char_idx
        end
        return suggestion
      end)
    end
    LazyVim.cmp.actions.ai_accept_WORD = function()
      if copilot.is_visible() then
        LazyVim.create_undo()
        copilot_accept_WORD()
        vim.b.copilot_accepted = true
        return true
      end
    end
    LazyVim.cmp.actions.ai_accept_word = function()
      if copilot.is_visible() then
        LazyVim.create_undo()
        copilot.accept_word()
        vim.b.copilot_accepted = true
        return true
      end
    end

    -- Accepted text arrives via `apply_text_edits`, reaching neither the redo buffer
    -- nor the `.` register, so `.` replays the typed keys alone and inserts what was
    -- never written. Silence `.` until the next change.
    local guard = vim.api.nvim_create_augroup("copilot_accept_repeat_guard", { clear = true })
    -- `<C-C>` skips `InsertLeave` (|i_CTRL-C|) and `<C-O>` fires it without leaving,
    -- so key off the transition into plain normal mode.
    vim.api.nvim_create_autocmd("ModeChanged", {
      group = guard,
      pattern = "i*:*",
      callback = function()
        if vim.v.event.new_mode ~= "n" or not vim.b.copilot_accepted then
          return
        end
        vim.b.copilot_accepted = nil
        -- copilot.lua's edit may still be queued here, and `repeat#set` records
        -- `b:changedtick`; scheduling lands this after it.
        vim.schedule(function()
          -- `<Ignore>` never consumes a count, so `3.` would leave the 3 pending.
          vim.fn["repeat#set"](vim.api.nvim_replace_termcodes("<Ignore>", true, true, true), -1)
          -- Drop the one-shot CursorMoved `repeat#set` arms: the tick is final here,
          -- and a later edit must not inherit the guard.
          vim.cmd("silent! autocmd! repeat_custom_motion")
        end)
      end,
    })
    -- Contain a flag stranded by a missed mode change; `<C-O>` re-enters insert
    -- mid-session (`niI` -> `i`) and must not clear it.
    vim.api.nvim_create_autocmd("ModeChanged", {
      group = guard,
      pattern = "*:i*",
      callback = function()
        if vim.v.event.old_mode == "n" then
          vim.b.copilot_accepted = nil
        end
      end,
    })

    return opts
  end,
}
