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
	{ key = "c", mods = "CMD", action = act.CopyTo("Clipboard") },
	{ key = "p", mods = "CMD", action = act.PasteFrom("Clipboard") },
	{ key = "d", mods = "CMD", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "SHIFT|CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) },
}

return config
