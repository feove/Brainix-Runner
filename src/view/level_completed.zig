const std = @import("std");
const rl = @import("raylib");
const print = std.debug.print;
const window = @import("../render/window.zig");
const textures = @import("../render/textures.zig");
const Sprite = textures.Sprite;
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const btns = @import("../ui/buttons_panel.zig");
const Level = @import("../game/level/events.zig").Level;

pub fn update() !void {
    if (btns.btns_panel.complete.isClicked()) {
        Level.end_level();
        window.currentView = .Levels;
    }
}

pub fn render() !void {
    drawBG();

    drawButtons();
}

fn drawBG() void {
    Sprite.drawCustom(textures.simple_gui_sheets, SpriteDefaultConfig{
        .position = .{ .x = window.WINDOW_WIDTH * 0.25, .y = window.WINDOW_HEIGHT * 0.2 },
        .sprite = Sprite{
            .name = "Completed Level Background",
            .src = .{ .x = 0, .y = 95, .width = 48, .height = 35 },
        },
        .color = .white,
        .scale = 11.00,
    });
}

fn drawButtons() void {
    btns.btns_panel.complete.draw();
}
