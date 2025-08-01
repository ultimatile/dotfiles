return {
  "echasnovski/mini.ai",
  opts = {
    custom_textobjects = {
      -- snake_case用のテキストオブジェクト
      s = function()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2] + 1

        -- 現在位置から左右に拡張してsnake_case境界を見つける
        local start_col = col
        local end_col = col

        -- 左に拡張（単語文字またはアンダースコアまで）
        while start_col > 1 and line:sub(start_col - 1, start_col - 1):match("[%w_]") do
          start_col = start_col - 1
        end

        -- 右に拡張
        while end_col <= #line and line:sub(end_col, end_col):match("[%w_]") do
          end_col = end_col + 1
        end

        -- snake_caseかチェック（アンダースコア含有）
        local text = line:sub(start_col, end_col - 1)
        if text:match("_") then
          return { from = { line = 1, col = start_col }, to = { line = 1, col = end_col - 1 } }
        end
      end,
    },
  },
}
