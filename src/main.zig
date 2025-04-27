const rl = @import("raylib");
const std = @import("std");
const game = @import("game/game.zig");
const player = @import("game/player.zig");
const window = @import("render/window.zig");
const Grid = @import("game/grid.zig").Grid;
const Inventory = @import("game/inventory.zig").Inventory;
const textures = @import("render/textures.zig");
const Level = @import("game/level/events.zig").Level;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() anyerror!void {

    //---Inits------------

    window.windowInit(1000, 800);

    try textures.texturesInit();
    try Grid.init(allocator);
    try Inventory.init(allocator);
    player.initElf();
    try Level.init(allocator);

    // window.clear();

    while (!rl.windowShouldClose()) {

        //Test FullScreen feature
        if (rl.isKeyPressed(rl.KeyboardKey.f11)) {
            rl.toggleFullscreen();
        }

        game.run();
    }

    rl.closeWindow();
}
