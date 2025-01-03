-- Function to execute the "swpunc" command

-- Bind Cmd+Shift+Esc to the runSwpunc function
hs.hotkey.bind({ "cmd", "ctrl" }, "escape", function()
	local output, ret = hs.execute("swpunc", true)
	if ret then
		hs.alert.show(output)
	end
end)
