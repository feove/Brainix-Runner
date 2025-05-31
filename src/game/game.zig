const scene = @import("../render/scene.zig");
const player = @import("../entity/elf.zig");
const wizard = @import("../entity/wizard.zig");
const flying = @import("../entity/flying_platform.zig");
const terrain = @import("../terrain/grid.zig");
const inventory = @import("../game/inventory.zig");
const utils = @import("../game/utils.zig");
const Level = @import("../game/level/events.zig").Level;
const Entity = @import("../entity/entity_manager.zig").Entity;
const CutScene = @import("../game/level/cutscene_manager.zig").CutSceneManager;
const rl = @import("raylib");
const print = @import("std").debug.print;

pub fn run() !void {
    rl.beginDrawing();
    defer rl.endDrawing();

    //Interactions
    terrain.grid.interactions();
    inventory.inv.interactions();
    player.elf.controller();
    wizard.wizard.controller();
    flying.flying_platform.controller();

    //Update Cursor's position
    utils.hud.refresh();

    try Level.stateLevelManager();

    CutScene.run();
    try render();
}

pub fn render() !void {
    // print("{any} {any}\n", .{ objects.Level.getLevelStatement(), player.elf.state });
    try scene.drawScene();

    Entity.draw();

    return;
}
