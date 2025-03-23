const rl = @import("raylib");
const std = @import("std");
const Grid = @import("game/grid.zig").Grid;
const window = @import("render/window.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
pub fn main() anyerror!void {

    //---Inits------------

    window.windowInit(800, 800);

    const grid: Grid = try Grid.init(allocator);

    while (!rl.windowShouldClose()) {
        if (rl.isWindowResized()) {
            window.windowInit(rl.getScreenWidth(), rl.getScreenHeight());
        }

        window.drawScene(grid);
    }

    rl.closeWindow();
}
