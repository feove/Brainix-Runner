const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;
const stdout = std.io.getStdOut().writer();
const game = @import("../game/game.zig");
const menu = @import("../view/menu.zig");
const levels = @import("../view/levels.zig");
const CursorManager = @import("../game/cursor.zig").CursorManager;
const TransitionController = @import("../view/transition/transition_controller.zig").TransitionController;

pub const WINDOW_WIDTH = 1000;
pub const WINDOW_HEIGHT = 800;

pub var isOpen: bool = true;

pub const GameView = enum {
    Menu,
    Play,
    Settings,
    Levels,
    Credits,
    Help,
    Quit,
    None,
};

pub var currentView = GameView.Menu;

pub fn windowInit(screenWidth: i32, screenHeight: i32) void {
    rl.initWindow(screenWidth, screenHeight, "Brainix Runner");
}

pub fn GameViewManager() !void {
    rl.beginDrawing();
    defer rl.endDrawing();

    CursorManager.refresh();
    try TransitionController.update();

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
        .Settings => {},
        .Credits => {},
        .Help => {},
        .Quit => {},
        else => return,
    }
}

pub fn clear() void {
    stdout.writeAll("\x1b[2J\x1b[H") catch {};
}
