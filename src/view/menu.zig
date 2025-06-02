const std = @import("std");
const rl = @import("raylib");
const print = std.debug.print;
const window = @import("../render/window.zig");
const GameView = window.GameView;
const btns = @import("../ui/buttons_panel.zig");
const textures = @import("../render/textures.zig");
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const Sprite = textures.Sprite;

pub fn update() void {
    if (rl.isKeyPressed(rl.KeyboardKey.one)) {
        window.currentView = GameView.Play;
    }
}

pub fn render() !void {
    rl.beginDrawing();
    defer rl.endDrawing();

    drawBackground();

    drawButtons();
}

fn drawBackground() void {
    rl.clearBackground(.white);
}

fn drawButtons() void {
    btns.btns_panel.play.draw();
}
