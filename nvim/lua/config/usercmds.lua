-- This file is manually required in options.lua
-- because this is not LazyVim's config, and not automatically loarded by LazyVim
-- Add user defined commands here

-- create commands to open help in a vertical split
local function vertical_help_command(opts)
  vim.cmd("vert help " .. opts.args)
  vim.cmd("vertical resize 82") -- Resize to fit the fixed help's width
end

-- vertical help with resized width
vim.api.nvim_create_user_command("Vhelp", vertical_help_command, { nargs = 1 })
vim.api.nvim_create_user_command("Vh", vertical_help_command, { nargs = 1 })

-- Create a stupid alias for neo-tree
vim.api.nvim_create_user_command("NeoTree", function()
  vim.cmd("Neotree")
end, {})
