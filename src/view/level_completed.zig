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
    if (btns.btns_panel.back_option.isClicked()) {
        Level.end_level();
        window.currentView = .Levels;
    }
}

pub fn render() !void {
    drawBG();

    drawButtons();
}

fn drawBG() void {
    Sprite.drawCustom(textures.level_selector_bg, SpriteDefaultConfig{
        .position = .{ .x = window.WINDOW_WIDTH * 0.3, .y = window.WINDOW_HEIGHT * 0.3 },
        .sprite = Sprite{
            .name = "Completed Level Background",
            .src = .{ .x = 0, .y = 0, .width = 96, .height = 52 },
        },
        .color = .white,
        .scale = 7.00,
    });
}

fn drawButtons() void {
    btns.btns_panel.back_option.draw();
}
