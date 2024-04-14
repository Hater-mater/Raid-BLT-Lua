Hooks:PostHook(MenuSetup, "update", "BLT.MenuUpdate", function(self, t, dt)
	Hooks:Call("MenuUpdate", t, dt)
end)
Hooks:PreHook(MenuSetup, "quit", "BLT.SetupQuit", function(...)
	Hooks:Call("SetupOnQuit", ...)
end)

Hooks:RegisterHook("SetupOnQuit")
Hooks:Add("MenuUpdate", "BLT.MenuUpdate", callback(BLT, BLT, "Update"))
