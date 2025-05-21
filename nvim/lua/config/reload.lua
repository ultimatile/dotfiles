-- This module provides functions to reload Neovim configuration

local M = {}

-- Function to reload all configuration files
function M.reload_config()
  -- Reload init.lua
  dofile(vim.env.MYVIMRC)
  
  -- Reload all config modules
  for _, module in ipairs({
    "config.options",
    "config.lazy",
    "config.keymaps",
    "config.autocmds",
    "config.usercmds"
  }) do
    package.loaded[module] = nil
    require(module)
  end
  
  -- Reload all plugin modules
  for module_name, _ in pairs(package.loaded) do
    if module_name:match("^plugins%.") then
      package.loaded[module_name] = nil
      require(module_name)
    end
  end
  
  -- Notify the user
  vim.notify("Configuration reloaded!", vim.log.levels.INFO)
end

return M
