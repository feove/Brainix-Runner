const scene = @import("../render/scene.zig");
const player = @import("../entity/elf.zig");
const wizard = @import("../entity/wizard.zig");
const flying = @import("../entity/flying_platform.zig");
const terrain = @import("../terrain/grid.zig");
const inventory = @import("../game/inventory.zig");
const btns = @import("../ui/buttons_panel.zig");
const Level = @import("../game/level/events.zig").Level;
const Entity = @import("../entity/entity_manager.zig").Entity;
const CutScene = @import("../game/level/cutscene_manager.zig").CutSceneManager;
const rl = @import("raylib");
const print = @import("std").debug.print;

pub fn update() !void {

    //Interactions
    terrain.grid.interactions();
    inventory.inv.interactions();
    player.elf.controller();
    wizard.wizard.controller();
    flying.flying_platform.controller();

    try Level.stateLevelManager();
}

pub fn render() !void {
    rl.beginDrawing();
    defer rl.endDrawing();

    // print("{any} {any}\n", .{ objects.Level.getLevelStatement(), player.elf.state });
    CutScene.run();

    try scene.drawScene();

    Entity.draw();

    btns.btns_panel.settings.draw();

    return;
}
