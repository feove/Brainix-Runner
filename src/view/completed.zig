const std = @import("std");
const rl = @import("raylib");
const print = std.debug.print;
const window = @import("../render/window.zig");
const textures = @import("../render/textures.zig");
const Sprite = textures.Sprite;
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const anim = @import("../game/animations/animations_manager.zig");
const btns = @import("../ui/buttons_panel.zig");
const Level = @import("../game/level/events.zig").Level;

pub fn update() !void {
    if (btns.btns_panel.complete.isClicked()) {
        Level.end_level();
        window.currentView = .Levels;
    }
}

pub fn render() !void {
    drawBG();

    drawStars();

    drawButtons();
}

fn drawBG() void {
    //alpha
    const color: rl.Color = rl.colorAlpha(.gray, 0.03);
    rl.drawRectangle(0, 0, window.WINDOW_WIDTH, window.WINDOW_HEIGHT, color);

    Sprite.drawCustom(textures.simple_gui_sheets, SpriteDefaultConfig{
        .position = .{ .x = window.WINDOW_WIDTH * 0.23, .y = window.WINDOW_HEIGHT * 0.21 },
        .sprite = Sprite{
            .name = "Completed Level Background",
            .src = .{ .x = 0, .y = 95, .width = 48, .height = 35 },
        },
        .color = .white,
        .scale = 11.00,
    });
}

fn drawStars() void {
    anim.star.isRunning = true;
    anim.star.update(rl.getFrameTime(), 1);
    anim.star.draw(.{ .x = 100, .y = 100 }, 3.00, 0.0, 255, 0, 0);
}

fn drawButtons() void {
    btns.btns_panel.complete.draw();
}
