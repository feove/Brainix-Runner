const std = @import("std");
const rl = @import("raylib");

const textures = @import("../../render/textures.zig");
const window = @import("../../render/window.zig");
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const FontManager = @import("../../render/fonts.zig").FontManager;
const Sprite = textures.Sprite;
const btns = @import("../../ui/buttons_panel.zig");
pub var level_manager: LevelManager = undefined;

const LEVEL_NB = 26;
const LEVEL_PATH = "levels/level_XX.json";

pub const PageSpecific = struct {
    current_page: usize,
    max_pages: usize,
    max_level_by_page: usize,
    first_level_index: usize,
    last_level_index: usize,
    column: usize,
    row: usize,
    offset_x: f32,
    offset_y: f32,
    padding: f32,
    spacing: f32,

    pub fn selfReturn() PageSpecific {
        return level_manager.page;
    }

    pub fn update(self: *PageSpecific) void {
        self.first_level_index = self.current_page * self.max_level_by_page;
        self.last_level_index = self.first_level_index + self.max_level_by_page - 1;
    }

    pub fn increasePage() void {
        level_manager.page.current_page += 1;
    }

    pub fn decreasePage() void {
        level_manager.page.current_page -= 1;
    }
};

pub const LevelMeta = struct {
    id: usize,
    is_locked: bool,
    stars_collected: u8,
    path: []const u8,

    pub fn draw_unlocked_level(id: usize) void {
        const pos = btns.btns_panel.levels[id].spriteConf.position;

        var static_buf: [16:0]u8 = undefined;
        const id_text: [:0]const u8 = std.fmt.bufPrintZ(&static_buf, "{}", .{id + 1}) catch "??";
        btns.btns_panel.levels[id].draw();
        FontManager.drawText(id_text, if (id < 9) pos.x + 25 else pos.x + 15, pos.y + 20, 32, 0.0, .black);
    }

    pub fn draw_locked_level(id: usize) void {
        const pos = btns.btns_panel.levels[id].spriteConf.position;

        btns.btns_panel.locked_level.setPosition(pos.x, pos.y);
        btns.btns_panel.locked_level.draw();
    }
};

pub const LevelManager = struct {
    level_nb: usize,
    levels: []LevelMeta,
    current_level: usize = 0,
    page: PageSpecific,

    pub fn debug() void {
        std.debug.print("LevelManager: current_level = {}, page = {}\n", .{ level_manager.current_level, level_manager.page.current_page });
        std.debug.print("Page = {}\n\n", .{level_manager.page});
    }

    pub fn update() void {
        level_manager.page.update();
    }

    pub fn SelfReturn() LevelManager {
        return level_manager;
    }

    pub fn CurrentLevel() LevelMeta {
        return level_manager.levels[level_manager.current_level];
    }

    pub fn setCurrentLevel(id: usize) void {
        level_manager.current_level = id;
    }

    pub fn init(allocator: std.mem.Allocator) !void {
        const levels: []LevelMeta = try allocator.alloc(LevelMeta, LEVEL_NB);
        for (0..LEVEL_NB) |id| {
            const path = try makePath(allocator, id);
            levels[id] = LevelMeta{
                .id = id,
                .is_locked = id > 18,
                .stars_collected = 0,
                .path = path,
            };
        }
        level_manager = LevelManager{
            .levels = levels,
            .level_nb = LEVEL_NB,
            .current_level = 0,
            .page = PageSpecific{
                .current_page = 0,
                .max_level_by_page = 10,
                .max_pages = 3,
                .first_level_index = 0,
                .last_level_index = 9,
                .column = 5,
                .row = 2,
                .offset_x = window.WINDOW_WIDTH * 0.22,
                .offset_y = window.WINDOW_HEIGHT * 0.25,
                .padding = 6 * 32,
                .spacing = 56,
            },
        };
    }

    fn makePath(allocator: std.mem.Allocator, id: usize) ![]const u8 {
        return std.fmt.allocPrint(allocator, "levels/lvl_{}.json", .{id + 1});
    }
};
