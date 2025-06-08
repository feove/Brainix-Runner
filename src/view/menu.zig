const std = @import("std");
const rl = @import("raylib");
const print = std.debug.print;
const window = @import("../render/window.zig");
const GameView = window.GameView;
const btns = @import("../ui/buttons_panel.zig");
const textures = @import("../render/textures.zig");
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const Sprite = textures.Sprite;

var cloud_position: rl.Vector2 = .{ .x = -window.WINDOW_WIDTH, .y = 0 };

pub fn update() !void {
    if (btns.btns_panel.play.isClicked()) {
        window.currentView = GameView.Play;
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
    //  rl.drawTexture(textures.forest_background, 0, 0, .white);
    //

    const sprite_forest_config = SpriteDefaultConfig{
        .position = .{ .x = -40, .y = 0 },
        .sprite = Sprite{
            .name = "Forest Layer",
            .src = .{ .x = 0, .y = 0, .width = 384, .height = 216 },
        },
        .scale = 3.1,
    };
    Sprite.drawCustom(textures.forest_bg_9, sprite_forest_config);

    drawClouds(sprite_forest_config);

    Sprite.drawCustom(textures.forest_bg_7, sprite_forest_config);
    Sprite.drawCustom(textures.forest_bg_6, sprite_forest_config);
    Sprite.drawCustom(textures.forest_bg_5, sprite_forest_config);
    Sprite.drawCustom(textures.forest_bg_4, sprite_forest_config);
    Sprite.drawCustom(textures.forest_bg_3, sprite_forest_config);
    Sprite.drawCustom(textures.forest_bg_2, sprite_forest_config);
    Sprite.drawCustom(textures.forest_bg_1, sprite_forest_config);
}

fn drawClouds(config: SpriteDefaultConfig) void {
    var cloud_config = config;
    cloud_config.position = cloud_position;
    const dt = @as(f32, @floatCast(rl.getTime()));
    const speed = 50.0;
    const cloud_speed: f32 = speed * dt;
    cloud_config.position.x += @mod(cloud_speed, window.WINDOW_WIDTH * 2);
    Sprite.drawCustom(textures.forest_bg_8, cloud_config);
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
            .x = window.WINDOW_WIDTH * 0.50,
            .y = -window.WINDOW_HEIGHT * 0.20,
        },

        .scale = 0.52,
    });
}
