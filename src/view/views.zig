const std = @import("std");
const rl = @import("raylib");
const print = std.debug.print;
const window = @import("../render/window.zig");
const GameView = window.GameView;

pub fn update() void {
    if (rl.isKeyPressed(rl.KeyboardKey.one)) {
        window.currentView = GameView.Play;
    }
}

pub fn render() !void {
    rl.beginDrawing();
    defer rl.endDrawing();

    rl.clearBackground(.white);
}
