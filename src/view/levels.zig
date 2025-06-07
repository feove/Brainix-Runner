const std = @import("std");
const rl = @import("raylib");
const print = std.debug.print;
const window = @import("../render/window.zig");
const textures = @import("../render/textures.zig");
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const Sprite = textures.Sprite;
pub fn update() !void {}

pub fn render() !void {
    rl.beginDrawing();
    defer rl.endDrawing();

    drawBackground();
}

fn drawBackground() void {
    textures.Sprite.drawCustom(textures.level_selector_bg, SpriteDefaultConfig{
        .position = .{ .x = 200, .y = 100 },
        .sprite = Sprite{
            .name = "Level Selector Background",
            .src = .{ .x = 0, .y = 0, .width = 96, .height = 52 },
        },

        .scale = 5.0,
    });
}
