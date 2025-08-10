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
    end,
  },
}
