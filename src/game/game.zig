const scene = @import("../render/scene.zig");
const player = @import("../game/player.zig");
const terrain = @import("../game/grid.zig");
const inventory = @import("../game/inventory.zig");
const utils = @import("../game/utils.zig");
const objects = @import("../game/level/events.zig");
const rl = @import("raylib");
const print = @import("std").debug.print;

pub fn run() !void {
    rl.beginDrawing();
    defer rl.endDrawing();

    //Interactions
    player.elf.controller();
    terrain.grid.interactions();
    inventory.inv.interactions();

    //Update Cursor's position
    utils.hud.refresh();
    try objects.level.refresh();

    try render();
}

pub fn render() !void {
    player.elf.drawElf();
    try scene.drawScene();
}
