-- Bind Cmd+Ctrl+Esc to the runSwpunc function
hs.hotkey.bind({ "cmd", "ctrl" }, "escape", function()
	local output, ret = hs.execute("swpunc", true)
	if ret then
		hs.alert.show(output)
	end
end)
-- Bind Cmd+Ctrl+c to the copy-flattern-split function
hs.hotkey.bind({"cmd", "ctrl"}, "c", function()
	hs.eventtap.keyStroke({"cmd"}, "c")
	hs.timer.doAfter(0.3, function()
		hs.execute("pbpaste | tr '\\n' ' ' | sed -e 's/\\([.?!]\\) /\\1\\n/g' -e 's/- //g' | pbcopy", true)
	end)
end)