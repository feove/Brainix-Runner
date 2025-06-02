const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;

pub var btns_panel: ButtonsPanel = undefined;

pub const ButtonsPanel = struct {
    start: Button,

    pub fn init() void {
        btns_panel = ButtonsPanel{
            .start = Button.init("Start", 100, 100),
        };
    }
};

pub const Button = struct {
    texture: rl.Texture2D,
    src: rl.Rectangle,
    pos: rl.Vector2,

    pub fn draw(self: Button) void {
        rl.DrawTextureRec(self.texture, self.src, self.pos, rl.WHITE);
    }
};
