ColorDialog = ColorDialog or class(MenuDialog)
ColorDialog.type_name = "ColorDialog"
ColorDialog._default_width = 620
function ColorDialog:init(params, menu)
    if self.type_name == ColorDialog.type_name then
        params = params and clone(params) or {}
    end
    self._is_input = true
    ColorDialog.super.init(self, table.merge(params, {
        w = ColorDialog._default_width,
        offset = 8,
        auto_height = true,
        auto_align = true
    }), menu)
end

function ColorDialog:_Show(params)
    if not self:basic_show(params) then
        return
    end
    params.color = params.color or Color.white
    self._color = params.color
    local preview = self._menu:Divider({
        name = "ColorPreview",
        text = "",
        items_size = 42,
        offset = 0,
        background_color = params.color,
    })
    self._menu:TextBox({
        name = "Hex",
        text = "Hex:",
        value = "",
        lines = 1,
        auto_foreground = false,
        foreground_highlight = false,
        position = "CenterLeft",
        background_color = false,
        highlight_color = false,
        callback = callback(self, self, "update_hex"),
        w = 160,
        override_panel = preview
    })
    if params.create_items then
        params.create_items(self._menu)
    end
    for _, ctrl in pairs({ "Red", "Green", "Blue" }) do
        self._menu:Slider({
            name = ctrl,
            text = ctrl,
            min = 0,
            max = 255,
            callback = callback(self, self, "update_color"),
            value = params.color[ctrl:lower()] * 255
        })
    end
    self._menu:Slider({
        name = "Alpha",
        text = "Alpha",
        visible = not params.no_alpha,
        min = 0,
        max = 100,
        callback = callback(self, self, "update_color"),
        value = params.color.alpha * 100
    })
    self._menu:Button({
        name = "Apply",
        text = "Apply",
        callback = callback(self, self, "hide", true),
        label = "temp"
    })
    self._menu:Button({
        name = "Close",
        text = "Cancel",
        callback = callback(self, self, "hide"),
        label = "temp"
    })
    self:update_color(self._menu)
    self:show_dialog()
end

--http://stackoverflow.com/questions/3942878/how-to-decide-font-color-in-white-or-black-depending-on-background-color
function ColorDialog:update_hex_color()
    local item = self._menu:GetItem("Hex")
    local color = self._color:contrast()
    item.foreground = color
    item._textbox.line_color = color
    item:DoHighlight(item.highlighted)
end

function ColorDialog:set_color(color, not_hex)
    self._color = color
    self._menu:GetItem("Alpha"):SetValue(self._color.alpha * 100)
    self._menu:GetItem("Red"):SetValue(self._color.red * 255)
    self._menu:GetItem("Green"):SetValue(self._color.green * 255)
    self._menu:GetItem("Blue"):SetValue(self._color.blue * 255)
    self._menu:GetItem("ColorPreview").bg:set_color(self._color)
    self:update_color(not_hex)
end

function ColorDialog:update_hex(menu, item)
    self:set_color(Color:from_hex(item:Value()), true)
end

function ColorDialog:update_color(not_hex)
    self._color = Color(self._menu:GetItem("Alpha"):Value() / 100, self._menu:GetItem("Red"):Value() / 255,
        self._menu:GetItem("Green"):Value() / 255, self._menu:GetItem("Blue"):Value() / 255)
    self._menu:GetItem("ColorPreview").bg:set_color(self._color)
    if not_hex ~= true then
        local Hex = self._menu:GetItem("Hex")
        Hex:SetValue(self._color:to_hex())
    end
    self:update_hex_color()
end

function ColorDialog:run_callback(clbk)
    if clbk then
        clbk(self._color, self._menu)
    end
end
