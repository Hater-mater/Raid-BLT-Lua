MenuDialog = MenuDialog or class()
MenuDialog.type_name = "MenuDialog"
function MenuDialog:init(params, menu)
    if self.type_name == MenuDialog.type_name then
        params = params and clone(params) or {}
    end
    self._default_width = self._default_width or 620
    self._no_blur = params.no_blur
    self._tbl = {}
    menu = menu or BLT.Dialogs:Menu()
    self._menu = menu:Menu(table.merge({
        name = "dialog" .. tostring(self),
        position = "Center",
        w = MenuDialog._default_width,
        visible = false,
        auto_height = true,
        auto_foreground = true,
        always_highlighting = true,
        reach_ignore_focus = true,
        scrollbar = false,
        items_size = 32,
        offset = 8,
        accent_color = tweak_data.gui.colors.raid_red,
        background_color = Color(0.6, 0.25, 0.25, 0.25),
    }, params))
    BLT.Dialogs:AddDialog(self)
end

function MenuDialog:Show(params)
    BLT.Dialogs:OpenDialog(self, get_type_name(params) == "table" and params or nil)
end

function MenuDialog:SetCurrentId(id)
    self.current_id = id
end

function MenuDialog:show(...)
    return self:Show(...)
end

function MenuDialog:_Show(params)
    if not self:basic_show(params) then
        return false
    end
    self:CreateCustomStuff(params)
    self:show_dialog()
    return true
end

function MenuDialog:CreateCustomStuff(params)
    if params.title then
        self._menu:Divider(table.merge({
            name = "Title",
            text = params.title,
            border_left = true,
            items_size = self._menu.items_size + 4,
        }, params.title_merge or {}))
    end
    if params.message then
        self._menu:Divider({
            name = "Message",
            text = params.message,
            items_size = self._menu.items_size + 2,
        })
    end
    if params.create_items then
        params.create_items(self._menu)
    end
    if params.yes ~= false then
        self._menu:Button({
            name = "Yes",
            text = params.yes or (params.no and "Yes") or "Close",
            reachable = true,
            highlight = true,
            callback = callback(self, self, "hide", true)
        })
    end
    if params.no then
        self._menu:Button({
            name = "No",
            text = params.no,
            reachable = true,
            callback = callback(self, self, "hide")
        })
    end
end

function MenuDialog:show_dialog()
    self._menu:SetVisible(true, true)
    if self._menus then
        for _, menu in pairs(self._menus) do
            menu:SetVisible(true, true)
        end
    end
end

function MenuDialog:basic_show(params, force)
    self._blur = params.blur or false
    BLT.Dialogs:ShowDialog(self)
    self._tbl = {}
    self._params = params
    params = type_name(params) == "table" and params or {}
    self._callback = params.callback
    self._no_callback = params.no_callback
    if not self._no_clearing_menu then
        self._menu:ClearItems()
    end
    self._menu:SetLayer(BLT.Dialogs:GetMyIndex(self) * 50)
    if not self._no_reshaping_menu then
        self._menu:SetSize(params.w or self._default_width, params.h)
        self._menu:SetPosition(params.position or "Center")
    end
    if self._menus then
        for _, menu in pairs(self._menus) do
            menu:SetLayer(BLT.Dialogs:GetMyIndex(self) * 50)
            if not self._no_clearing_menu then
                menu:ClearItems()
            end
        end
    end
    return true
end

function MenuDialog:run_callback(clbk)
    if clbk then
        clbk(self._menu)
    end
end

function MenuDialog:Hide(yes, menu, item)
    return self:hide(yes, menu, item)
end

function MenuDialog:should_close()
    return self._menu:ShouldClose()
end

function MenuDialog:hide(yes, menu, item)
    BLT.Dialogs:CloseDialog(self)
    local clbk = yes == true and self._callback or yes ~= false and self._no_callback
    if not self._no_clearing_menu then
        self._menu:ClearItems()
    end
    self._menu:SetVisible(false, true)
    if self._menus then
        for _, menu in pairs(self._menus) do
            menu:SetVisible(false, true)
            if not self._no_clearing_menu then
                menu:ClearItems()
            end
        end
    end
    self._callback = nil
    self._no_callback = nil
    self._params = nil
    if type(clbk) == "function" then
        self:run_callback(clbk)
    end
    self._tbl = {}
    return true
end

function QuickDialog(opt, items)
    opt = opt or {}
    local dialog = opt.dialog or BLT.Dialogs:Simple()
    opt.dialog = nil
    opt.title = opt.title or "Info"
    dialog:Show(table.merge({
        no = "Close",
        yes = false,
        create_items = function(menu)
            for i, item in pairs(items) do
                if item[3] == true then
                    dialog._no_callback = item[2]
                end
                menu:Button({
                    highlight = true,
                    reachable = true,
                    name = type_name(item) == "table" and item[1] or item,
                    callback = function()
                        if type(item[2]) == "function" then
                            item[2]()
                        end
                        dialog:hide(false)
                    end,
                    type_name(item) == "table" and item[2]
                })
            end
        end
    }, opt))
end
