return {
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-v>",
          -- If you want to use <CR> to accept, you have to configure nvim-cmp's supertab setting
          -- https://www.lazyvim.org/configuration/recipes#supertab
          --accept = "<Tab>",
        },
      },
      panel = { enabled = false },
    },
  },
  {
    "zbirenbaum/copilot-cmp",
    enabled = false,
  },
}
