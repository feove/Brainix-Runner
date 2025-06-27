const scene = @import("../render/scene.zig");
const player = @import("../entity/elf.zig");
const wizard = @import("../entity/wizard.zig");
const flying = @import("../entity/flying_platform.zig");
const terrain = @import("../terrain/grid.zig");
const inventory = @import("../game/inventory.zig");
const btns = @import("../ui/buttons_panel.zig");
const events = @import("../game/level/events.zig");
const level = @import("../game/level/events.zig");
const Level = level.Level;
const Entity = @import("../entity/entity_manager.zig").Entity;
const CutScene = @import("../game/level/cutscene_manager.zig").CutSceneManager;
const rl = @import("raylib");
const print = @import("std").debug.print;
const Switcher = @import("../view/transition/transition_controller.zig").Switcher;
const window = @import("../render/window.zig");
const GameView = window.GameView;

pub fn update() !void {
    Switcher.start(.CIRCLE_OUT);

    if (btns.btns_panel.settings.isClicked() or rl.isKeyPressed(rl.KeyboardKey.escape)) {
        window.previousView = .Play;

        window.currentView = GameView.Settings;
        //  print(" start : {d}\n", .{events.auto_death_start_time});
    }

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
