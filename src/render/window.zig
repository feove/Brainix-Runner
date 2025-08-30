const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;
const stdout = std.io.getStdOut().writer();
const game = @import("../game/game.zig");
const menu = @import("../view/menu.zig");
const levels = @import("../view/levels.zig");
const settings = @import("../view/settings.zig");
const options = @import("../view/options.zig");
const completed = @import("../view/completed.zig");
const sounds = @import("../sounds/sounds.zig");
const CursorManager = @import("../game/cursor.zig").CursorManager;
const TransitionController = @import("../view/transition/transition_controller.zig").TransitionController;

//tmp
const btn = @import("../ui/buttons_panel.zig");

pub const WINDOW_WIDTH = 1000;
pub const WINDOW_HEIGHT = 800;

pub var isOpen: bool = true;

pub const GameView = enum {
    Menu,
    Play,
    Settings,
    Levels,
    Completed,
    Credits,
    Help,
    Quit,
    Options,
    None,
};

pub var currentView = GameView.Menu;
pub var previousView = GameView.None;

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
        .Settings => {
            try settings.update();
            try settings.render();
        },
        .Options => {
            try options.update();
            try options.render();
        },
        .Completed => {
            try completed.update();
            try completed.render();
        },
        .Credits => {},
        .Help => {},
        .Quit => {},
        else => return,
    }

    sounds.run();
}

pub fn clear() void {
    stdout.writeAll("\x1b[2J\x1b[H") catch {};
}
