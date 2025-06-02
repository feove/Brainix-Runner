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
const Interface = @import("interface/hud.zig").Interface;
const ButtonsPanel = @import("ui/buttons_panel.zig").ButtonsPanel;
const CursorManager = @import("game/cursor.zig").CursorManager;
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
    try Interface.init(allocator);
    ButtonsPanel.init();

    window.clear();

    while (!rl.windowShouldClose()) {

        //Test FullScreen feature
        if (rl.isKeyPressed(rl.KeyboardKey.f11)) {
            rl.toggleFullscreen();
        }

        CursorManager.refresh();

        try window.GameViewManager();
    }

    rl.closeWindow();
}
