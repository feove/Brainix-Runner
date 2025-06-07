const rl = @import("raylib");
const std = @import("std");
const stdout = std.io.getStdOut().writer();
const game = @import("../game/game.zig");
const menu = @import("../view/menu.zig");
const levels = @import("../view/levels.zig");
const CursorManager = @import("../game/cursor.zig").CursorManager;

pub const WINDOW_WIDTH = 1000;
pub const WINDOW_HEIGHT = 800;

pub var isOpen: bool = true;

pub const GameView = enum {
    Menu,
    Play,
    Pause,
    Settings,
    Levels,
    Credits,
    Help,
    Quit,
};

pub var currentView = GameView.Menu;

pub fn windowInit(screenWidth: i32, screenHeight: i32) void {
    rl.initWindow(screenWidth, screenHeight, "Brainix Runner");
}

pub fn GameViewManager() !void {
    CursorManager.refresh();

    switch (currentView) {
        .Menu => {
            try menu.update();
            try menu.render();
        },
        .Play => {
            try game.update();
            try game.render();
        },
        .Levels => {
            try levels.update();
            try levels.render();
        },
        .Pause => {},
        .Settings => {},
        .Credits => {},
        .Help => {},
        .Quit => {},
    }
}

pub fn clear() void {
    stdout.writeAll("\x1b[2J\x1b[H") catch {};
}
