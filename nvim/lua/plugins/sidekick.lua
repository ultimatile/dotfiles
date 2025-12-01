-- Override the <tab> key mapping for sidekick.nvim
-- to fallback to window switching instead of literal <tab>
return {
  {
    "folke/sidekick.nvim",
    keys = {
      {
        "<tab>",
        -- expr=true requires returning a string, not executing commands
        LazyVim.cmp.map({ "ai_nes" }, "<C-w>w"),
        mode = { "n" },
        expr = true,
        desc = "NES or Next Window",
      },
    },
  },
}
