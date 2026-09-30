-- lang.markdown extra のフォーマッタとmarkdownlint診断を、Slidevのスライドにだけ当てない。
--
-- Slidevでは `---` がスライド区切りで、その次の行からがそのスライドのfrontmatterである。
-- CommonMarkは `layout: center` + `---` をsetext見出しと読むので、prettierもmarkdownlint
-- (MD022) も区切りの直後に空行を入れ、frontmatterが本文に変わる。
-- 判定はプロジェクトではなく中身で行う。同じリポジトリのREADME等には従来どおり当てたい。

-- 先頭以外の `---` の直後にfrontmatterのキーが続く形があるか
local function is_slidev(buf)
  local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  return text:find("\n%-%-%-\n[%a_]+:[^\n]*\n") ~= nil
end

return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      local default = opts.formatters_by_ft.markdown
      opts.formatters_by_ft.markdown = function(buf)
        return is_slidev(buf) and {} or default
      end
    end,
  },
  -- 診断を止めるのはノイズ対策だけでなく、extra の markdownlint-cli2 フォーマッタが
  -- 「markdownlint診断が1件でもあれば走る」条件を持つため。
  -- extra は none-ls と nvim-lint の両方に登録するので、両方で止める。
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          -- LazyVim の lint 拡張は condition を現在のバッファで呼ぶ
          condition = function()
            if not is_slidev(0) then
              return true
            end
            -- 前回までの実行が残した診断は、走らなくなっても消えないので消す
            vim.diagnostic.reset(require("lint").get_namespace("markdownlint-cli2"), 0)
            return false
          end,
        },
      },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      for i, src in ipairs(opts.sources) do
        if src.name == "markdownlint-cli2" then
          opts.sources[i] = src.with({
            runtime_condition = function(params)
              return not is_slidev(params.bufnr)
            end,
          })
        end
      end
    end,
  },
}
