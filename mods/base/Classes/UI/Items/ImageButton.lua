BLT.Items.ImageButton = BLT.Items.ImageButton or class(BLT.Items.Item)
local ImageButton = BLT.Items.ImageButton
ImageButton.type_name = "ImageButton"
function ImageButton:InitBasicItem()
    self.h = self.h or self.w
    self.panel = self.parent_panel:panel({
        name = self.name,
        w = self.w,
        h = self.h,
    })
    self:InitBGs()
    self.img = self.panel:bitmap({
        name = "img",
        texture = self.texture,
        texture_rect = self.texture_rect,
        color = self.img_color or self.foreground,
        w = self.icon_w or self.w - 4,
        h = self.icon_h or self.h - 4,
        rotation = self.img_rot,
        halign = "center",
        valign = "center",
        layer = 5
    })
    self.img:set_world_center(self.panel:world_center())
    self:MakeBorder()
end

function ImageButton:DoHighlight(highlight)
    ImageButton.super.DoHighlight(self, highlight)
    if self.highlight_image and self.img then
        play_color(self.img, self:GetForeground(highlight))
    end
end

function ImageButton:SetImage(texture, texture_rect)
    self.img:set_image(texture, texture_rect)
end
