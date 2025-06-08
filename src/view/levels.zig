const std = @import("std");
const rl = @import("raylib");
const print = std.debug.print;
const window = @import("../render/window.zig");
const GameView = window.GameView;
const textures = @import("../render/textures.zig");
const btns = @import("../ui/buttons_panel.zig");
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const Sprite = textures.Sprite;

pub fn update() !void {
    if (btns.btns_panel.back.isClicked()) {
        window.currentView = GameView.Menu;
    }
}

pub fn render() !void {
    rl.beginDrawing();
    defer rl.endDrawing();

    drawBackground();

    drawButtons();
}

fn drawBackground() void {
    textures.Sprite.draw(textures.forest_background, textures.sprites.forest_background, .{
        .x = -window.WINDOW_WIDTH * 0.1,
        .y = -window.WINDOW_HEIGHT * 0.05,
    }, 0.85, .white);

    textures.Sprite.drawCustom(textures.level_selector_bg, SpriteDefaultConfig{
        .position = .{ .x = window.WINDOW_WIDTH * 0.11, .y = window.WINDOW_HEIGHT * 0.17 },
        .sprite = Sprite{
            .name = "Level Selector Background",
            .src = .{ .x = 0, .y = 0, .width = 96, .height = 52 },
        },
        .color = .white,
        .scale = 8.15,
    });
}

fn drawButtons() void {
    btns.btns_panel.back.draw();
}
