const rl = @import("raylib");
const std = @import("std");
const Grid = @import("game/grid.zig").Grid;
const window = @import("render/window.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
pub fn main() anyerror!void {

    //---Inits------------

    window.windowInit();

    const grid: Grid = try Grid.init(allocator);

    while (!rl.windowShouldClose()) {
        window.drawScene(grid);
    }

    rl.closeWindow();
}
