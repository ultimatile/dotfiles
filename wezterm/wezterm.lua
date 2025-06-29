local wezterm = require("wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

local config = wezterm.config_builder()

-- Network IO monitoring functions
local is_darwin = wezterm.target_triple:find("apple%-darwin") ~= nil

local function get_network_io(iface)
	if is_darwin then
		-- netstat コマンドで累積バイト数を取得 (macOS)
		local ok, out = wezterm.run_child_process({ "netstat", "-ibn" })
		if ok then
			for line in out:gmatch("[^\n]+") do
				-- インターフェース名で始まり、Linkという文字列を含む行を探す
				if line:find("^" .. iface .. "%s") and line:find("Link") then
					local fields = {}
					for w in line:gmatch("%S+") do
						table.insert(fields, w)
					end
					-- netstat -ibn の出力形式: Name Mtu Network Address Ipkts Ierrs Ibytes Opkts Oerrs Obytes Coll
					-- インデックス: [1]Name [2]Mtu [3]Network [4]Address [5]Ipkts [6]Ierrs [7]Ibytes [8]Opkts [9]Oerrs [10]Obytes
					if #fields >= 10 then
						return tonumber(fields[7]), tonumber(fields[10]) -- Ibytes, Obytes
					end
				end
			end
		end
	else
		-- Linux: /proc/net/dev パース
		local ok, out = wezterm.run_child_process({ "cat", "/proc/net/dev" })
		if ok then
			for line in out:gmatch("[^\n]+") do
				if line:find(iface .. ":") then
					local fields = {}
					for w in line:gmatch("%S+") do
						table.insert(fields, w)
					end
					return tonumber(fields[2]), tonumber(fields[10])
				end
			end
		end
	end
	return nil, nil
end

-- Global state for network IO calculations
if not wezterm.GLOBAL then
	wezterm.GLOBAL = {}
end

config.automatically_reload_config = true
config.status_update_interval = 1000 -- 1秒間隔でネットワーク監視を更新

-- ネットワーク監視設定
local NETWORK_SAMPLE_INTERVAL = 5 -- 秒単位でのサンプリング間隔（推奨: 3-5秒）

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

-- tabline configuration
config.tab_bar_at_bottom = true

tabline.setup({
	options = {
		icons_enabled = true,
		theme = "Tokyo Night Storm",
		tabs_enabled = true,
		section_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
		component_separators = {
			left = wezterm.nerdfonts.pl_left_soft_divider,
			right = wezterm.nerdfonts.pl_right_soft_divider,
		},
		tab_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
	},
	sections = {
		-- Left side: workspace or mode
		tabline_a = {},
		tabline_b = {},
		tabline_c = {},

		-- Tab configuration - show job name (process) and current directory
		tab_active = {
			"index",
			{ "process", padding = { left = 0, right = 1 } },
			"/",
			{ "cwd", padding = { left = 0, right = 1 } },
		},
		tab_inactive = {
			"index",
			{ "process", padding = { left = 0, right = 1 } },
		},

		-- Right side: git state, CPU, RAM, Network, clock
		tabline_x = {
			function(window)
				local pane = window:active_pane()
				local cwd = pane:get_current_working_dir()
				if cwd then
					local success, result = pcall(function()
						local cmd = 'cd "' .. cwd.file_path .. '" && git rev-parse --abbrev-ref HEAD 2>/dev/null'
						local handle = io.popen(cmd)
						local branch = handle:read("*a"):gsub("\n", "")
						handle:close()
						if branch ~= "" then
							return "  " .. branch
						end
						return ""
					end)
					return success and result or ""
				end
				return ""
			end,
		},
		tabline_y = {
			{
				"cpu",
				fmt = function(str)
					-- Convert to sparkline (simplified version)
					local cpu_val = tonumber(str:match("%d+"))
					if cpu_val then
						local spark_chars = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
						local spark_idx = math.min(8, math.max(1, math.ceil(cpu_val / 12.5)))
						return spark_chars[spark_idx] .. str
					end
					return str
				end,
			},
			{
				"ram",
				fmt = function(str)
					-- Convert to sparkline (simplified version)
					local ram_val = tonumber(str:match("%d+%.?%d*"))
					if ram_val then
						local spark_chars = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
						local spark_idx = math.min(8, math.max(1, math.ceil(ram_val / 2)))
						return spark_chars[spark_idx] .. str
					end
					return str
				end,
			},
			function(window)
				local iface = "en1" -- アクティブなインターフェース
				local rx, tx = get_network_io(iface)

				local function format_rate(rate)
					if rate >= 1024 * 1024 then -- MB/s
						return string.format("%5.1fM", rate / (1024 * 1024))
					elseif rate >= 1024 then -- KB/s
						return string.format("%5.0fK", rate / 1024)
					else -- B/s
						return string.format("%5.0fB", rate)
					end
				end

				local function format_display(icon, spark, rx_str, tx_str)
					return string.format("%s%s%s↓%s↑", icon, spark, rx_str, tx_str)
				end

				if not rx or not tx then
					return format_display(wezterm.nerdfonts.md_ethernet, "▁", "  ERRB", "  ERRB")
				end

				if not wezterm.GLOBAL.net_prev then
					wezterm.GLOBAL.net_prev = { rx = rx, tx = tx, time = os.time() }
					local init_display = format_display(wezterm.nerdfonts.md_ethernet, "▁", "    0B", "    0B")
					wezterm.GLOBAL.net_last_display = init_display
					return init_display
				end

				local prev = wezterm.GLOBAL.net_prev
				local current_time = os.time()
				local time_delta = current_time - prev.time

				if time_delta >= NETWORK_SAMPLE_INTERVAL then
					local rx_bytes = math.max(0, rx - prev.rx)
					local tx_bytes = math.max(0, tx - prev.tx)
					local rx_rate = rx_bytes / time_delta -- bytes/s
					local tx_rate = tx_bytes / time_delta -- bytes/s

					-- Sparkline calculation based on combined rate
					local total_rate = rx_rate + tx_rate
					local spark_chars = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
					local spark_idx = 1
					if total_rate > 100 then -- 100 B/s以上で反応
						local log_rate = math.log10(total_rate)
						spark_idx = math.min(8, math.max(1, math.floor(log_rate - 1)))
					end

					wezterm.GLOBAL.net_prev = { rx = rx, tx = tx, time = current_time }
					local display = format_display(
						wezterm.nerdfonts.md_ethernet,
						spark_chars[spark_idx],
						format_rate(rx_rate),
						format_rate(tx_rate)
					)
					wezterm.GLOBAL.net_last_display = display
					return display
				else
					return wezterm.GLOBAL.net_last_display
						or format_display(wezterm.nerdfonts.md_ethernet, "▁", "    0B", "    0B")
				end
			end,
		},
		tabline_z = {
			{
				"datetime",
				style = "%m/%d %H:%M",
			},
		},
	},
})

tabline.apply_to_config(config)

return config
