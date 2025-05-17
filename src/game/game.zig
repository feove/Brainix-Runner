const scene = @import("../render/scene.zig");
const player = @import("../entity/elf.zig");
const terrain = @import("../terrain/grid.zig");
const inventory = @import("../game/inventory.zig");
const utils = @import("../game/utils.zig");
const objects = @import("../game/level/events.zig");
const Entity = @import("../entity/entity_manager.zig").Entity;
const rl = @import("raylib");
const print = @import("std").debug.print;

pub fn run() !void {
    rl.beginDrawing();
    defer rl.endDrawing();

    //Interactions
    terrain.grid.interactions();
    inventory.inv.interactions();
    player.elf.controller();

    //Update Cursor's position
    utils.hud.refresh();
    try objects.level.refresh();

    try render();
}

pub fn render() !void {
    // print("{any} {any}\n", .{ objects.Level.getLevelStatement(), player.elf.state });
    try scene.drawScene();

    Entity.draw();

    return;
}
