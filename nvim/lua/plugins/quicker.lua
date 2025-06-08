return {
  "stevearc/quicker.nvim",
  event = "FileType qf",
  ---@module "quicker"
  ---@type quicker.SetupOptions
  opts = {},
  keys = {
    {
      "<leader>9",
      function()
        require("quicker").toggle()
      end,
      desc = "Toggle quickfix",
    },
  },
}
