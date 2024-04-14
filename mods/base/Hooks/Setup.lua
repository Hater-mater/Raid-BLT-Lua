_next_update_funcs = _next_update_funcs or {}
function call_on_next_update(func, optional_key)
	if not optional_key then
		table.insert(_next_update_funcs, func)
	else
		local key = optional_key == true and func or optional_key
		_next_update_funcs[key] = func
	end
end

function call_next_update_functions()
	local current = _next_update_funcs
	_next_update_funcs = {}

	for _, func in pairs(current) do
		func()
	end
end

Hooks:Register("SetupInitManagers")
Hooks:PostHook(Setup, "init_managers", "BLT.SetupInitManagers", function(self)
	BLT.Dialogs:Init()
	Hooks:Call("SetupInitManagers")
end)

Hooks:PostHook(Setup, "update", "BLT.SetupUpdate", function(self)
	call_next_update_functions()
end)
