const std = @import("std");
const rl = @import("raylib");
const print = std.debug.print;
const window = @import("../render/window.zig");
const GameView = window.GameView;
const btns = @import("../ui/buttons_panel.zig");
const textures = @import("../render/textures.zig");
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const Sprite = textures.Sprite;
const Elf = @import("../entity/elf.zig").Elf;
const ElfManager = @import("../game/animations/elf_anims.zig").ElfManager;
const Wizard = @import("../entity/wizard.zig").Wizard;
const WizardManager = @import("../game/animations/wizard_anims.zig").WizardManager;
const TransitionController = @import("./transition/transition_controller.zig").TransitionController;
const Switcher = @import("./transition/transition_controller.zig").Switcher;
const Button = @import("../ui/buttons_panel.zig").Button;
const sounds = @import("../sounds/sounds.zig");
var cloud_position: rl.Vector2 = .{ .x = -window.WINDOW_WIDTH, .y = 0 };

pub fn update() !void {

    //debug
    if (rl.isKeyPressed(rl.KeyboardKey.c)) {
        window.currentView = .Completed;
    }

    //affect once time
    Switcher.start(.CIRCLE_OUT);

    if (btns.btns_panel.play.isClicked()) {
        //print("Clicked\n", .{});
        Button.reset();
        Switcher.authorize_switch(.Levels);
        TransitionController.setCurrent(.CIRCLE_IN);
    }

    if (btns.btns_panel.settings.isClicked()) {
        window.previousView = window.currentView;
        window.currentView = GameView.Settings;
        Button.reset();
    }

    if (btns.btns_panel.exit.isClicked()) {
        window.isOpen = false;
    }

    //if (!rl.isMusicStreamPlaying(sounds.soundsets.theme_music)) {
    //  sounds.soundControl.playMusic(sounds.soundsets.theme_music);
    //}
}

pub fn render() !void {
    if (Switcher.can_default_render()) {
        drawElements();
    }
}

pub fn drawElements() void {
    drawBackground();

    drawButtons();

    drawLogo();
}

fn drawButtons() void {
    btns.btns_panel.play.draw();
    btns.btns_panel.exit.draw();
    btns.btns_panel.settings.draw();
}

fn drawBackground() void {
    rl.clearBackground(.black);

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

    drawTreesParallax(sprite_forest_config);

    Sprite.drawCustom(textures.forest_bg_5, sprite_forest_config);
    Sprite.drawCustom(textures.forest_bg_4, sprite_forest_config);

    drawNPC();

    Sprite.drawCustom(textures.forest_bg_3, sprite_forest_config);

    drawFoliageParallax(sprite_forest_config);

    Sprite.drawCustom(textures.forest_bg_1, sprite_forest_config);

    drawTopBlackBackground();
}

fn drawTreesParallax(trees_config: SpriteDefaultConfig) void {
    var config = trees_config;
    config.position.x += rl.getMousePosition().x * 0.002;
    Sprite.drawCustom(textures.forest_bg_7, config);
    config.position.x += rl.getMousePosition().x * 0.003;
    Sprite.drawCustom(textures.forest_bg_6, config);
}

fn drawFoliageParallax(foliage_config: SpriteDefaultConfig) void {
    var config = foliage_config;
    config.position.x += rl.getMousePosition().x * 0.005;
    Sprite.drawCustom(textures.forest_bg_2, config);
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

fn drawTopBlackBackground() void {
    Sprite.drawCustom(textures.top_far_bgrnd, SpriteDefaultConfig{
        .sprite = Sprite{
            .name = "Black Background",
            .src = .{ .x = 0, .y = 700, .width = 640, .height = 100 },
        },
        .position = .{
            .x = window.WINDOW_WIDTH * 0.92,
            .y = window.WINDOW_HEIGHT * 1.02,
        },
        .scale = 2.5,
        .rotation = 180,
        .origin = .{ .x = 320, .y = 50 },
    });
}

fn drawNPC() void {
    Wizard.setPos(320, 310);
    WizardManager.setCurrent(.IDLE);
    Wizard.setScale(2.6);
    Wizard.draw();
    Wizard.reset();

    Elf.setPos(.init(200, 405));
    ElfManager.setAnim(.IDLE);
    Elf.drawElf();
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
