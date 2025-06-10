const std = @import("std");
const rl = @import("raylib");
const print = std.debug.print;
const window = @import("../render/window.zig");
const GameView = window.GameView;
const levelmanager = @import("../game/level/levels_manager.zig");
const LevelManager = levelmanager.LevelManager;
const LevelMeta = levelmanager.LevelMeta;

const PageSpecific = levelmanager.PageSpecific;
const textures = @import("../render/textures.zig");
const btns = @import("../ui/buttons_panel.zig");
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const Sprite = textures.Sprite;

pub fn update() !void {
    LevelManager.update();

    if (btns.btns_panel.back.isClicked()) {
        window.currentView = GameView.Menu;
    }

    if (btns.btns_panel.next.isClicked() and btns.btns_panel.next.canClick) {
        PageSpecific.increasePage();
    }

    if (btns.btns_panel.prev.isClicked() and btns.btns_panel.prev.canClick) {
        PageSpecific.decreasePage();
    }

    //LevelManager.debug();
    //if () Level_XX Pressed and Level_XX unlocked and shown, try level.init(alloc)
}

pub fn render() !void {
    rl.beginDrawing();
    defer rl.endDrawing();

    drawBackground();

    drawButtons();

    drawLevels();
}

fn drawLevels() void {
    const level_manager = LevelManager.SelfReturn();
    const offset_x = level_manager.page.offset_x;
    const offset_y = level_manager.page.offset_y;
    const padding = level_manager.page.padding;
    const spacing = level_manager.page.spacing;

    //Need Locked logic

    for (0..level_manager.page.row) |i| {
        for (0..level_manager.page.column) |j| {
            const index = level_manager.page.first_level_index + i + j * level_manager.page.row;

            if (index > level_manager.level_nb) {
                return;
            }
            const i_f32 = @as(f32, @floatFromInt(i));
            const j_f32 = @as(f32, @floatFromInt(j));

            const x = offset_x + j_f32 * padding * 0.65;
            const y = offset_y + i_f32 * padding * 0.45 + spacing * i_f32;

            if (level_manager.levels[index].is_locked == false) {
                level_manager.levels[index].draw_unlocked_level(x, y);
                continue;
            }
            level_manager.levels[index].draw_locked_level(x, y);
        }
    }
}

fn drawBackground() void {
    textures.Sprite.draw(textures.forest_background, textures.sprites.forest_background, .{
        .x = -window.WINDOW_WIDTH * 0.1,
        .y = -window.WINDOW_HEIGHT * 0.05,
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
