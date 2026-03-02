return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      local Rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")

      npairs.setup({})
      npairs.add_rule(Rule('"""', '"""', "toml"):with_pair(cond.not_before_char('"', 3)))

      -- Custom condition: should we pair backticks?
      -- Returns false when inside an unclosed code block (to disable pairing)
      -- Only fires when typing backtick to avoid performance issues
      local function should_pair_backticks(opts)
        -- Only check in markdown files
        if not vim.tbl_contains({ "markdown", "markdown_inline" }, vim.bo.filetype) then
          return true
        end

        -- Get parser (lightweight check, doesn't parse the whole file)
        local ok, parser = pcall(vim.treesitter.get_parser, 0, "markdown")
        if not ok then
          return true -- No parser, allow pairing
        end

        -- Get current node at cursor
        local cursor = vim.api.nvim_win_get_cursor(0)
        local row, col = cursor[1] - 1, cursor[2] - 1

        -- Parse the current tree
        local tree = parser:parse()[1]
        if not tree then
          return true -- No tree, allow pairing
        end

        local node = tree:root():named_descendant_for_range(row, col, row, col)
        if not node then
          return true -- No node, allow pairing
        end

        -- Check if inside a fenced_code_block
        ---@type TSNode?
        local current = node
        while current do
          if current:type() == "fenced_code_block" then
            -- Check if the fenced_code_block has a closing delimiter
            local has_closing = false
            for child in current:iter_children() do
              if child:type() == "fenced_code_block_delimiter" then
                local child_row = child:range()
                -- If delimiter is after cursor position, it's the closing one
                if child_row > row then
                  has_closing = true
                  break
                end
              end
            end
            -- If has closing delimiter: complete block, allow pairing (return true)
            -- If no closing delimiter: unclosed block, disable pairing (return false)
            return has_closing
          end
          current = current:parent()
        end

        -- Not in fenced_code_block, allow pairing (normal case for creating new code blocks)
        return true
      end

      -- Remove default backtick rules
      npairs.remove_rule("`")
      npairs.remove_rule("```")

      -- Add triple backtick rule for markdown code blocks (higher priority)
      npairs.add_rule(Rule("```", "```", { "markdown", "markdown_inline" }):with_pair(should_pair_backticks))

      -- Add custom single backtick rule with our condition
      npairs.add_rule(
        Rule("`", "`")
          -- Keep default quote behavior: when already inside an unclosed backtick,
          -- insert only one backtick instead of auto-pairing another one.
          :with_pair(cond.not_add_quote_inside_quote(), 1)
          :with_pair(should_pair_backticks)
          :with_move(function(opts)
            return opts.char == "`" and opts.next_char == "`"
          end)
      )
    end,
  },
}
