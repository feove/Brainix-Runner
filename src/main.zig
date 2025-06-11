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
const FontManager = @import("render/fonts.zig").FontManager;
const LevelsManager = @import("game/level/levels_manager.zig").LevelManager;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() anyerror!void {

    //---Inits------------

    window.windowInit(window.WINDOW_WIDTH, window.WINDOW_HEIGHT);

    try textures.init();
    try anim.init();
    try Grid.init(allocator);
    try Inventory.init(allocator);
    try LevelsManager.init(allocator);
    try Level.init(allocator);
    try Entity.init();
    try Interface.init(allocator);
    try FontManager.init(allocator);
    try ButtonsPanel.init(allocator);

    //window.clear();

    while (window.isOpen) {
        try window.GameViewManager();
    }

    FontManager.deinit();
    // try ButtonsPanel.deinit(allocator);

    rl.closeWindow();
}
