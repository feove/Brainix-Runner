const rl = @import("raylib");
const std = @import("std");
const window = @import("../render/window.zig");
const GameView = window.GameView;
const textures = @import("../render/textures.zig");
const Sprite = textures.Sprite;
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const btns = @import("../ui/buttons_panel.zig");

pub fn update() !void {
    if (btns.btns_panel.res.isClicked()) {
        window.currentView = window.previousView;
    }

    if (btns.btns_panel.menu.isClicked()) {
        window.currentView = .Menu;
    }

    if (btns.btns_panel.option.isClicked()) {
        window.currentView = .Options;
    }
    //btns
}

pub fn render() !void {
    drawBG();

    drawButtons();
}

fn drawBG() void {
    const alpha: f32 = if (window.previousView == .Menu) 0.015 else 0.005;

    const color = rl.colorAlpha(.black, alpha);

    rl.drawRectangle(0, 0, window.WINDOW_WIDTH, window.WINDOW_HEIGHT, color);

    textures.Sprite.drawCustom(textures.settings_bg, SpriteDefaultConfig{
        .position = .{ .x = window.WINDOW_WIDTH * 0.287, .y = window.WINDOW_HEIGHT * 0.19 },
        .sprite = Sprite{
            .name = "Settings Background",
            .src = .{ .x = 0, .y = 0, .width = 46, .height = 46 },
        },
        .color = .white,
        .scale = 9,
    });
}

fn drawButtons() void {
    btns.btns_panel.res.draw();
    btns.btns_panel.option.draw();
    btns.btns_panel.menu.draw();
}
