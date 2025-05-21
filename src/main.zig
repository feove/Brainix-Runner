const rl = @import("raylib");
const std = @import("std");
const game = @import("game/game.zig");
const player = @import("entity/elf.zig");
const window = @import("render/window.zig");
const Grid = @import("terrain/grid.zig").Grid;
const Inventory = @import("game/inventory.zig").Inventory;
const textures = @import("render/textures.zig");
const anim = @import("game/animations/animations_manager.zig");
const Level = @import("game/level/events.zig").Level;
const Entity = @import("entity/entity_manager.zig").Entity;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() anyerror!void {

    //---Inits------------

    window.windowInit(1000, 800);

    try textures.init();
    try anim.init();
    try Grid.init(allocator);
    try Inventory.init(allocator);
    try Level.init(allocator);
    try Entity.init();

    //   window.clear();

    while (!rl.windowShouldClose()) {

        //Test FullScreen feature
        if (rl.isKeyPressed(rl.KeyboardKey.f11)) {
            rl.toggleFullscreen();
        }

        try game.run();
    }

    rl.closeWindow();
}
