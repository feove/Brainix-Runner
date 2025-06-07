const std = @import("std");
const rl = @import("raylib");
const print = std.debug.print;
const window = @import("../render/window.zig");
const GameView = window.GameView;
const btns = @import("../ui/buttons_panel.zig");
const textures = @import("../render/textures.zig");
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const Sprite = textures.Sprite;

pub fn update() !void {
    if (btns.btns_panel.play.isClicked()) {
        window.currentView = GameView.Levels;
    }

    if (btns.btns_panel.exit.isClicked()) {
        window.isOpen = false;
    }

    if (btns.btns_panel.settings.isClicked()) {
        window.currentView = GameView.Settings;
    }
}

pub fn render() !void {
    rl.beginDrawing();
    defer rl.endDrawing();

    drawBackground();

    drawButtons();

    drawLogo();
}

fn drawBackground() void {
    // rl.clearBackground(.white);
    rl.drawTexture(textures.forest_background, 0, 0, .white);
    //rl.drawTexturePro(textures.forest_background, self.src, dest, origin, rotation, tint);
}

fn drawButtons() void {
    btns.btns_panel.play.draw();
    btns.btns_panel.exit.draw();
    btns.btns_panel.settings.draw();
}

fn drawLogo() void {
    textures.Sprite.drawCustom(textures.logo, SpriteDefaultConfig{
        .sprite = Sprite{
            .name = "Logo",
            .src = .{ .x = 0, .y = 0, .width = 1080, .height = 1080 },
        },
        .position = .{
            .x = window.WINDOW_WIDTH * 0.40,
            .y = -window.WINDOW_HEIGHT * 0.1,
        },

        .scale = 0.53,
    });
}
