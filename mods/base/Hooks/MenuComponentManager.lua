
CloneClass(MenuComponentManager)

Hooks:RegisterHook("MenuComponentManagerInitialize")
function MenuComponentManager:init()
	self.orig.init(self)
	managers.menu_component = managers.menu_component or self
	Hooks:Call("MenuComponentManagerInitialize", self)
end

Hooks:RegisterHook("MenuComponentManagerUpdate")
function MenuComponentManager:update(t, dt)
	self.orig.update(self, t, dt)
	Hooks:Call("MenuComponentManagerUpdate", self, t, dt)
end

Hooks:RegisterHook("MenuComponentManagerPreSetActiveComponents")
function MenuComponentManager:set_active_components(components, node)
	Hooks:Call("MenuComponentManagerPreSetActiveComponents", self, components, node)
	self.orig.set_active_components(self, components, node)
	for name, comp in pairs(self._active_components) do
		if BLT.Menus[name] then --Create only when necessary
			if not comp.orig_create then
				comp.orig_create = comp.create
				comp.create = function(this, ...)
					local r = comp.orig_create(this, ...)
					for _, inject in pairs(BLT.Menus[name]) do
						if inject.is_list then
							RaidMenuHelper:InjectIntoAList(r, inject.point, inject.buttons, inject.list_name)
						else
							for _, btn in pairs(inject.buttons) do
								BLTMenu.Button(r, {
									name = btn.name,
									text = btn.text,
									localize = btn.localize,
									callback = btn.callback
								})
								if r._layout then
									r:_layout()
								end
							end
						end
					end
					return r
				end
			end
		end
	end
end

Hooks:RegisterHook("MenuComponentManagerOnMousePressed")
function MenuComponentManager:mouse_pressed(o, button, x, y)
	local r = self.orig.mouse_pressed(self, o, button, x, y)
	local val = Hooks:ReturnCall("MenuComponentManagerOnMousePressed", self, o, button, x, y)
	if val then
		r = val
	end
	return r
end

Hooks:RegisterHook("MenuComponentManagerOnMouseMoved")
function MenuComponentManager:mouse_moved(o, x, y)
	local hover, pointer = self.orig.mouse_moved(self, o, x, y)
	local ohover, opointer = Hooks:ReturnCall("MenuComponentManagerOnMouseMoved", self, o, x, y)
	if ohover ~= nil then
		hover = ohover
		pointer = opointer
	end
	return hover, pointer
end

Hooks:RegisterHook("MenuComponentManagerOnMouseClicked")
function MenuComponentManager:mouse_clicked(o, button, x, y)
	local hover, pointer = self.orig.mouse_clicked(self, o, button, x, y)
	local ohover, opointer = Hooks:ReturnCall("MenuComponentManagerOnMouseClicked", self, o, button, x, y)
	if ohover ~= nil then
		hover = ohover
		pointer = opointer
	end
	return hover, pointer
end

Hooks:RegisterHook("MenuComponentManagerUpdate")
function MenuComponentManager:update(t, dt)
	local ret = self.orig.update(self, t, dt)
	Hooks:Call("MenuComponentManagerUpdate", self, t, dt)
	return ret
end