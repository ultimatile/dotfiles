local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.automatically_reload_config = true

-- font
config.font = wezterm.font("UDEV Gothic NF", { weight = "Bold" })
config.font_size = 16.0

-- color scheme
config.color_scheme = "Tokyo Night Storm"

-- keymaps
config.disable_default_key_bindings = true
local act = wezterm.action
config.keys = {
	{ key = "C", mods = "CMD", action = act.CopyTo("Clipboard") },
	{ key = "P", mods = "CMD", action = act.PasteFrom("Clipboard") },
	{ key = "D", mods = "SHIFT|CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "D", mods = "CMD", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) },
}

return config
