const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;
const window = @import("../render/window.zig");
const GameView = window.GameView;
const textures = @import("../render/textures.zig");
const Sprite = textures.Sprite;
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const btns = @import("../ui/buttons_panel.zig");
const level = @import("../game/level/events.zig");
const Level = level.Level;
const Button = btns.Button;
const menu = @import("menu.zig");
const game = @import("../game/level/events.zig");

pub var settings = Settings{};
var hasStarted: bool = false;

const Settings = struct {
    breakTime: f64 = 0,
    startTime: f64 = 0,

    fn update() void {
        settings.breakTime = rl.getTime() - settings.startTime;
    }

    fn setNewStartTime() void {
        game.auto_death_start_time += settings.breakTime;
        //       print("Break time set {d}\n", .{settings.breakTime});
    }

    fn reset() void {
        settings.breakTime = 0;
    }
};

pub fn start() void {
    if (hasStarted) return;

    settings.startTime = rl.getTime();
    hasStarted = true;
}

pub fn update() !void {
    if (btns.btns_panel.res.isClicked()) {
        Settings.setNewStartTime();
        Settings.reset();
        Button.reset();
        window.currentView = window.previousView;
    }

    if (btns.btns_panel.menu.isClicked()) {
        if (window.previousView == .Play) {
            level.reset_level_values();
            Level.guiQuit();
        }
        hasStarted = false;
        Button.reset();
        window.currentView = .Menu;
    }

    if (btns.btns_panel.option.isClicked()) {
        Button.reset();
        window.currentView = .Options;
    }

    Settings.update();
}

pub fn render() !void {
    drawBG();

    drawHUD();

    drawButtons();
}

pub fn drawBG() void {
    var alpha: f32 = 0.005;
    if (window.previousView != .Play) {
        menu.drawElements();
        alpha = 0.65;
    }
    const color: rl.Color = rl.colorAlpha(.black, alpha);
    rl.drawRectangle(0, 0, window.WINDOW_WIDTH, window.WINDOW_HEIGHT, color);
}

fn drawHUD() void {
    textures.Sprite.drawCustom(textures.settings_bg, SpriteDefaultConfig{
        .position = .{ .x = window.WINDOW_WIDTH * 0.287, .y = window.WINDOW_HEIGHT * 0.19 },
        .sprite = Sprite{
            .name = "Settings Background",
            .src = .{ .x = 0, .y = 0, .width = 46, .height = 46 },
        },
        .color = .white,
        .scale = 9,
    });
}

fn drawButtons() void {
    btns.btns_panel.res.draw();
    btns.btns_panel.option.draw();
    btns.btns_panel.menu.draw();
}
