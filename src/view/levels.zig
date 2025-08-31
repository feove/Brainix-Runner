const std = @import("std");
const rl = @import("raylib");
const print = std.debug.print;
const window = @import("../render/window.zig");
const GameView = window.GameView;
const levelmanager = @import("../game/level/levels_manager.zig");
const LevelManager = levelmanager.LevelManager;
const LevelMeta = levelmanager.LevelMeta;
const Level = @import("../game/level/events.zig").Level;
const PageSpecific = levelmanager.PageSpecific;
const textures = @import("../render/textures.zig");
const btns = @import("../ui/buttons_panel.zig");
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const Sprite = textures.Sprite;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const TransitionController = @import("./transition/transition_controller.zig").TransitionController;
const Switcher = @import("./transition/transition_controller.zig").Switcher;
const sounds = @import("../sounds/sounds.zig");
const SoundDisplay = sounds.SoundDisplay;

pub fn update() !void {
    Switcher.start(.CIRCLE_OUT);

    if (btns.btns_panel.back.isClicked()) {
        // print("Clicked\n", .{});
        Switcher.authorize_switch(.Menu);
        TransitionController.setCurrent(.CIRCLE_IN);
    }

    if (btns.btns_panel.next.isClicked() and btns.btns_panel.next.canClick) {
        PageSpecific.increasePage();
        reset_click_permission();
    }

    if (btns.btns_panel.prev.isClicked() and btns.btns_panel.prev.canClick) {
        PageSpecific.decreasePage();
        reset_click_permission();
    }

    LevelManager.update();
    try level_is_clicked();

    //LevelManager.debug();
}

pub fn render() !void {
    if (Switcher.can_default_render()) {
        drawElements();
    }
}

pub fn drawElements() void {
    drawBackground();

    drawButtons();

    drawLevels();
}

fn drawLevels() void {
    const level_manager = LevelManager.SelfReturn();
    const first_id = level_manager.page.first_level_index;
    const last_id = first_id + level_manager.page.max_level_by_page;
    //Need Locked logic
    for (first_id..last_id) |id| {
        if (id == level_manager.level_nb) {
            return;
        }
        const lvl = btns.btns_panel.levels[id].spriteConf;

        for (0..3) |i| {
            const isEmptyStar = level_manager.levels[id].stars_collected > i;
            const star_sprite = if (isEmptyStar) textures.sprites.star else textures.sprites.empty_star;
            textures.Sprite.drawCustom(textures.things_sheet, SpriteDefaultConfig{
                .position = .{
                    .x = lvl.position.x - 15 + @as(f32, @floatFromInt(i * 30)),
                    .y = lvl.position.y + lvl.height,
                },
                .sprite = star_sprite,
                .scale = 5.0,
                .color = .white,
            });
        }

        btns.btns_panel.levels[id].canClick = true;
        if (level_manager.levels[id].is_locked) {
            LevelMeta.draw_locked_level(id);
            continue;
        }
        LevelMeta.draw_unlocked_level(id);
    }
}

fn reset_click_permission() void {
    const level_manager = LevelManager.SelfReturn();
    const first_id = level_manager.page.first_level_index;
    const last_id = first_id + level_manager.page.max_level_by_page;
    for (first_id..last_id) |id| {
        if (id == level_manager.level_nb) {
            return;
        }

        btns.btns_panel.levels[id].canClick = false;
    }
}

fn level_is_clicked() !void {
    const level_manager = LevelManager.SelfReturn();
    const first_id = level_manager.page.first_level_index;
    const last_id = first_id + level_manager.page.max_level_by_page;
    //Need Locked logic
    for (first_id..last_id) |id| {
        if (id == level_manager.level_nb) {
            return;
        }

        if (btns.btns_panel.levels[id].isClicked() and level_manager.levels[id].is_locked == false) {
            print("Level clicked : {d} PATH LEVEL : {s}\n", .{ id + 1, level_manager.levels[id].path });
            LevelManager.setCurrentLevel(id);
            try Level.init(allocator);
            Switcher.authorize_switch(.Play);
            TransitionController.setCurrent(.CIRCLE_IN);
            window.currentView = GameView.Play;

            sounds.canPlayMusic = false;
            SoundDisplay.stopMusic(sounds.soundsets.theme_music);

            sounds.current_music = sounds.soundsets.gameplay;
            SoundDisplay.playMusic(sounds.soundsets.gameplay);
        }
    }
}

fn drawBackground() void {
    textures.Sprite.draw(textures.forest_background, textures.sprites.forest_background, .{
        .x = -window.WINDOW_WIDTH * 0.1,
        .y = -window.WINDOW_HEIGHT * 0.04,
    }, 0.85, .white);

    textures.Sprite.drawCustom(textures.level_selector_bg, SpriteDefaultConfig{
        .position = .{ .x = window.WINDOW_WIDTH * 0.11, .y = window.WINDOW_HEIGHT * 0.17 },
        .sprite = Sprite{
            .name = "Level Selector Background",
            .src = .{ .x = 0, .y = 0, .width = 96, .height = 52 },
        },
        .color = .white,
        .scale = 8.15,
    });
}

fn drawButtons() void {
    btns.btns_panel.back.draw();
    drawPrevAndNextButtons();
}

fn drawPrevAndNextButtons() void {
    // btns.btns_panel.prev.draw();
    const page = PageSpecific.selfReturn();

    const showNext = page.current_page < page.max_pages - 1;
    const showPrev = page.current_page > 0;

    btns.btns_panel.prev.setCanClick(showPrev);
    btns.btns_panel.next.setCanClick(showNext);

    if (showNext) {
        btns.btns_panel.next.draw();
    }

    if (showPrev) {
        btns.btns_panel.prev.draw();
    }
}
