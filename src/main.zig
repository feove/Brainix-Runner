const rl = @import("raylib");
const std = @import("std");
const game = @import("game/game.zig");
const window = @import("render/window.zig");
const Grid = @import("game/grid.zig").Grid;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() anyerror!void {

    //---Inits------------

    window.windowInit(1000, 800);

    try Grid.init(allocator);

    while (!rl.windowShouldClose()) {

        //Test FullScreen feature
        if (rl.isKeyPressed(rl.KeyboardKey.f11)) {
            rl.toggleFullscreen();
        }

        game.run();
    }

    rl.closeWindow();
}
