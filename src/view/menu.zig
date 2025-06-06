const std = @import("std");
const rl = @import("raylib");
const print = std.debug.print;
const window = @import("../render/window.zig");
const GameView = window.GameView;
const btns = @import("../ui/buttons_panel.zig");
const textures = @import("../render/textures.zig");
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const Sprite = textures.Sprite;

pub fn update() void {
    if (btns.btns_panel.play.isClicked()) {
        window.currentView = GameView.Play;
    }

    if (btns.btns_panel.exit.isClicked()) {
        window.isOpen = false;
    }
}

pub fn render() !void {
    rl.beginDrawing();
    defer rl.endDrawing();

    drawBackground();

    drawButtons();
}

fn drawBackground() void {
    // rl.clearBackground(.white);
    rl.drawTexture(textures.forest_background, 0, 0, .white);
    //rl.drawTexturePro(textures.forest_background, self.src, dest, origin, rotation, tint);
}

fn drawButtons() void {
    btns.btns_panel.play.draw();
    btns.btns_panel.exit.draw();
}
