const rl = @import("raylib");
const std = @import("std");
const stdout = std.io.getStdOut().writer();
const game = @import("../game/game.zig");
const menu = @import("../view/menu.zig");
const CursorManager = @import("../game/cursor.zig").CursorManager;

pub const WINDOW_WIDTH = 1000;
pub const WINDOW_HEIGHT = 800;

pub const GameView = enum {
    Menu,
    Play,
    Pause,
    Settings,
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
        GameView.Menu => {
            menu.update();
            try menu.render();
        },
        GameView.Play => {
            try game.manage();
            try game.render();
        },
        GameView.Pause => {},
        GameView.Settings => {},
        GameView.Credits => {},
        GameView.Help => {},
        GameView.Quit => {},
    }
}

pub fn clear() void {
    stdout.writeAll("\x1b[2J\x1b[H") catch {};
}
