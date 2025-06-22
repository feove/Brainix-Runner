const rl = @import("raylib");
const std = @import("std");
const window = @import("../render/window.zig");
const GameView = window.GameView;
const textures = @import("../render/textures.zig");
const Sprite = textures.Sprite;
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const btns = @import("../ui/buttons_panel.zig");

pub fn update() !void {

    //btns
}

pub fn render() !void {
    drawBG();

    drawButtons();
}

fn drawBG() void {
    const color = rl.colorAlpha(.black, 0.008);

    rl.drawRectangle(0, 0, window.WINDOW_WIDTH, window.WINDOW_HEIGHT, color);

    textures.Sprite.drawCustom(textures.level_selector_bg, SpriteDefaultConfig{
        .position = .{ .x = window.WINDOW_WIDTH * 0.16, .y = window.WINDOW_HEIGHT * 0.24 },
        .sprite = Sprite{
            .name = "Settings Background",
            .src = .{ .x = 0, .y = 0, .width = 96, .height = 52 },
        },
        .color = .white,
        .scale = 7,
    });
}

fn drawButtons() void {
    btns.btns_panel.res.draw();
    btns.btns_panel.option.draw();
    //   btns.btns_panel.menu.draw();
}
