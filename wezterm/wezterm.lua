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
	{ key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },
	{ key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "SHIFT|CMD", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{
		key = "t",
		mods = "CMD",
		action = act.SpawnCommandInNewTab({ cwd = wezterm.home_dir, domain = "CurrentPaneDomain" }),
	},
	{ key = "t", mods = "SHIFT|CMD", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "SHIFT|CMD", action = wezterm.action.SpawnWindow },
	{ key = "n", mods = "CMD", action = wezterm.action.SpawnCommandInNewWindow({ cwd = wezterm.home_dir }) },
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) },
}

return config
