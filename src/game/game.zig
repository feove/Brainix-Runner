const scene = @import("../render/scene.zig");
const player = @import("../game/player.zig");
const terrain = @import("../game/grid.zig");
const inventory = @import("../game/inventory.zig");
const utils = @import("../game/utils.zig");
const rl = @import("raylib");

pub fn run() void {
    render();
}

pub fn render() void {
    rl.beginDrawing();
    defer rl.endDrawing();

    scene.drawScene();

    //Interactions
    terrain.grid.interactions();
    inventory.inv.interactions();

    player.elf.controller();
    player.elf.drawElf();

    //Update Cursor's position
    utils.hud.refresh();
}
