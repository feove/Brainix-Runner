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
const Switcher = @import("../view/transition/transition_controller.zig").Switcher;

pub fn update() !void {
    Switcher.start(.CIRCLE_OUT);

    //Interactions
    terrain.grid.interactions();
    inventory.inv.interactions();
    player.elf.controller();
    wizard.wizard.controller();
    flying.flying_platform.controller();

    try Level.stateLevelManager();
}

pub fn render() !void {
    if (Switcher.can_default_render()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        // print("{any} {any}\n", .{ objects.Level.getLevelStatement(), player.elf.state });
        try drawElements();

        return;
    }
}

pub fn drawElements() !void {
    CutScene.run();

    try scene.drawScene();

    Entity.draw();

    btns.btns_panel.settings.draw();
}
