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
	{ key = "d", mods = "CMD", action = act.SplitHorizontal({}) },
	{ key = "d", mods = "SHIFT|CMD", action = act.SplitVertical({}) },
	{ key = "t", mods = "CMD", action = act.SpawnCommandInNewTab({ cwd = wezterm.home_dir }) },
	{ key = "t", mods = "SHIFT|CMD", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) },
	{ key = "n", mods = "CMD", action = act.SpawnCommandInNewWindow({ cwd = wezterm.home_dir }) },
	{ key = "n", mods = "SHIFT|CMD", action = act.SpawnWindow },
}

-- enable option key
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

config.hide_tab_bar_if_only_one_tab = false
config.window_decorations = "NONE"

wezterm.on("update-status", function(window, pane)
	local date = wezterm.strftime(" %m/%-d %H:%M ")

	window:set_right_status(wezterm.format({
		{ Text = wezterm.nerdfonts.fa_clock_o .. " " .. date },
	}))
	window:set_left_status(wezterm.format({
		{ Text = wezterm.nerdfonts.fa_clock_o .. " " .. date },
	}))
end)

config.tab_bar_at_bottom = true
config.show_tabs_in_tab_bar = false
wezterm.on("update-right-status", function(window, pane)
	window:set_left_status("left")
	window:set_right_status("right")
end)

config.use_fancy_tab_bar = false
config.show_tabs_in_tab_bar = false
config.show_new_tab_button_in_tab_bar = false

-- TODO: separate status bar and tab bar
-- bottom status bar cannot be native, and it would be implemented by window_decorations

-- TODO: how to add status icons (iTerm2's icons are image files, but nerdfonts would be enough)

-- TODO: consider how to get cpu usage, memory usage, network io usage (fastfetch?)
-- TODO: consider how to implement sparkline to visualize cpu usage, memory usage, network io usage

-- TODO: get current git branch name

-- TODO: get current directory name
return config
