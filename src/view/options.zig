const std = @import("std");
const rl = @import("raylib");
const print = std.debug.print;
const window = @import("../render/window.zig");
const GameView = window.GameView;

const Level = @import("../game/level/events.zig").Level;

const textures = @import("../render/textures.zig");
const btns = @import("../ui/buttons_panel.zig");
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const Sprite = textures.Sprite;
const FontManager = @import("../render/fonts.zig").FontManager;
const menu = @import("menu.zig");
const settings = @import("settings.zig");

pub var muted: bool = false;

pub fn update() !void {
    if (btns.btns_panel.back_option.isClicked()) {
        window.currentView = .Settings;
    }

    if (btns.btns_panel.mute.isClicked()) {
        muted = true;
    } else if (btns.btns_panel.unmute.isClicked()) {
        muted = false;
    }
}

pub fn render() !void {
    settings.drawBG();

    drawHUD();

    drawFonts();

    drawButtons();
}

pub fn drawHUD() void {
    textures.Sprite.drawCustom(textures.level_selector_bg, SpriteDefaultConfig{
        .position = .{ .x = window.WINDOW_WIDTH * 0.2, .y = window.WINDOW_HEIGHT * 0.17 },
        .sprite = Sprite{
            .name = "Option Background",
            .src = .{ .x = 0, .y = 0, .width = 96, .height = 52 },
        },
        .color = .white,
        .scale = 7,
    });
}

fn drawFonts() void {
    FontManager.drawText("Sounds", window.WINDOW_WIDTH * 0.28, window.WINDOW_HEIGHT * 0.25, 32, 0.0, .black);
}

fn drawButtons() void {
    btns.btns_panel.mute.setCanClick(!muted);
    btns.btns_panel.unmute.setCanClick(muted);

    if (muted) {
        btns.btns_panel.unmute.draw();
    } else {
        btns.btns_panel.mute.draw();
    }

    btns.btns_panel.back_option.draw();
}
