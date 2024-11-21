require("config.lazy")

-- create commands to open help in a vertical split
-- Define a function to handle the command logic
local function vertical_help_command(opts)
  vim.cmd("vert help " .. opts.args)
  vim.cmd("vertical resize 82") -- Resize to fit the fixed help's width
end

-- Create both commands using the same function
vim.api.nvim_create_user_command("Vhelp", vertical_help_command, { nargs = 1 })
vim.api.nvim_create_user_command("Vh", vertical_help_command, { nargs = 1 })

-- Create a stupid alias for neo-tree
vim.api.nvim_create_user_command("NeoTree", function()
  vim.cmd("Neotree")
end, {})
