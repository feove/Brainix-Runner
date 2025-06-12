const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;
const textures = @import("../render/textures.zig");
const window = @import("../render/window.zig");
const lvls = @import("../game/level/levels_manager.zig");
const FontManager = @import("../render/fonts.zig").FontManager;
const CursorManager = @import("../game/cursor.zig").CursorManager;
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const Sprite = textures.Sprite;

pub var btns_panel: ButtonsPanel = undefined;

pub const HoverConfig = struct {
    hover_color: rl.Color = .gray,
    default_color: rl.Color = .white,

    hover_scale: f32 = 1.1,
    default_scale: f32 = 1.0,
};

pub const ButtonsPanel = struct {
    play: Button,
    exit: Button,
    settings: Button,
    back: Button,
    next: Button,
    prev: Button,
    levels: []Button,
    locked_level: Button,

    pub fn init(allocator: std.mem.Allocator) !void {
        var levels = try allocator.alloc(Button, lvls.level_manager.level_nb);

        const padding = lvls.level_manager.page.padding;
        const spacing = lvls.level_manager.page.spacing;
        const offset_y = lvls.level_manager.page.offset_y;
        const offset_x = lvls.level_manager.page.offset_x;
        const column = lvls.level_manager.page.column;
        const row = lvls.level_manager.page.row;

        for (0..lvls.level_manager.level_nb) |i| {
            const i_mod: f32 = @as(f32, @floatFromInt(i % column));
            const i_div: f32 = @as(f32, @floatFromInt((i / column) % row));
            const x = offset_x + i_mod * padding * 0.65;
            const y = offset_y + i_div * padding * 0.45 + spacing * i_div;

            levels[i] = Button{
                .texture = textures.level_button,

                .hoverConf = HoverConfig{
                    .default_scale = 6.0,
                    .hover_scale = 6.2,
                },
                .spriteConf = SpriteDefaultConfig{
                    .position = .{ .x = x, .y = y },
                    .scale = 6,
                    .sprite = Sprite{
                        .name = "Level Button",
                        .src = .{ .x = 0, .y = 0, .width = 12, .height = 12 },
                    },
                    .height = 12 * 6,
                },
                .fontText = "",
                .size = 32,
                .fontOffset = .{ .x = 15, .y = 20 },
                .canClick = false,
            };
        }

        btns_panel = ButtonsPanel{
            .play = Button{
                .texture = textures.play_button,
                .hoverConf = HoverConfig{
                    .default_scale = 5.0,
                    .hover_scale = 5.3,
                },
                .spriteConf = SpriteDefaultConfig{
                    .position = .{ .x = window.WINDOW_WIDTH * 0.05, .y = window.WINDOW_HEIGHT * 0.88 }, //0.32
                    .scale = 5.1,
                    .sprite = Sprite{
                        .name = "Play",
                        .src = .{ .x = 0, .y = 0, .width = 48, .height = 12 },
                    },
                },
                .fontText = "Play",
                .size = 32,
                .fontOffset = .{ .x = 90, .y = 10 },
            },
            .exit = Button{
                .texture = textures.exit_button,
                .hoverConf = HoverConfig{
                    .default_scale = 5.1,
                    .hover_scale = 5.3,
                },
                .spriteConf = SpriteDefaultConfig{
                    .position = .{ .x = window.WINDOW_WIDTH * 0.35, .y = window.WINDOW_HEIGHT * 0.88 }, // 0.47
                    .scale = 5.0,
                    .sprite = Sprite{
                        .name = "Exit",
                        .src = .{ .x = 0, .y = 0, .width = 48, .height = 12 },
                    },
                },
                .fontText = "Exit",
                .size = 32,
                .fontOffset = .{ .x = 90, .y = 10 },
            },
            .settings = Button{
                .texture = textures.settings_button,
                .hoverConf = HoverConfig{
                    .default_scale = 5.0,
                    .hover_scale = 5.2,
                },
                .spriteConf = SpriteDefaultConfig{
                    .position = .{ .x = window.WINDOW_WIDTH * 0.9, .y = window.WINDOW_HEIGHT * 0.88 },
                    .scale = 5.0,
                    .sprite = Sprite{
                        .name = "Settings",
                        .src = .{ .x = 0, .y = 0, .width = 12, .height = 12 },
                    },
                },
                .fontText = "",
                .size = 0,
                .fontOffset = .{ .x = 0, .y = 0 },
            },
            .back = Button{
                .texture = textures.back_button,
                .hoverConf = HoverConfig{
                    .default_scale = 5.1,
                    .hover_scale = 5.3,
                },
                .spriteConf = SpriteDefaultConfig{
                    .position = .{ .x = window.WINDOW_WIDTH * 0.05, .y = window.WINDOW_HEIGHT * 0.87 },
                    .scale = 5.2,
                    .sprite = Sprite{
                        .name = "Back",
                        .src = .{ .x = 19, .y = 0, .width = 42, .height = 11 },
                    },
                },
                .fontText = "Back",
                .size = 32,
                .fontOffset = .{ .x = 60, .y = 10 },
            },
            .next = Button{
                .texture = textures.next_button,
                .hoverConf = HoverConfig{
                    .default_scale = 5.0,
                    .hover_scale = 5.3,
                },
                .spriteConf = SpriteDefaultConfig{
                    .position = .{ .x = window.WINDOW_WIDTH * 0.90, .y = window.WINDOW_HEIGHT * 0.87 },
                    .scale = 5.5,
                    .sprite = Sprite{
                        .name = "Next",
                        .src = .{ .x = 0, .y = 0, .width = 12, .height = 12 },
                    },
                },
                .fontText = "Next",
                .size = 32,
                .fontOffset = .{ .x = 60, .y = 10 },
            },
            .prev = Button{
                .texture = textures.next_button,
                .hoverConf = HoverConfig{
                    .default_scale = 5.0,
                    .hover_scale = 5.5,
                },
                .spriteConf = SpriteDefaultConfig{
                    .position = .{ .x = window.WINDOW_WIDTH * 0.79, .y = window.WINDOW_HEIGHT * 0.862 },
                    .scale = 5.5,
                    .sprite = Sprite{
                        .name = "Prev",
                        .src = .{ .x = 0, .y = 0, .width = 12, .height = 12 },
                    },
                    .rotation = 180.0,
                    .origin = .{ .x = 12 * 5.5, .y = 12 * 5.5 },
                },
                .fontText = "Play",
                .size = 0,
                .fontOffset = .{ .x = 0, .y = 0 },
            },
            .locked_level = Button{
                .texture = textures.locked_level_button,
                .hoverConf = HoverConfig{
                    .default_scale = 6.0,
                    .hover_scale = 6.2,
                },
                .spriteConf = SpriteDefaultConfig{
                    .position = .{ .x = window.WINDOW_WIDTH * 0.3, .y = window.WINDOW_HEIGHT * 0.3 },
                    .scale = 6,
                    .sprite = Sprite{
                        .name = "Locked Level",
                        .src = .{ .x = 0, .y = 0, .width = 12, .height = 12 },
                    },
                },
                .fontText = "",
                .size = 0,
                .fontOffset = .{ .x = 0, .y = 0 },
            },
            .levels = levels,
        };

        print("TEXT : {s} \n", .{btns_panel.levels[0].fontText});
    }

    pub fn deinit(self: *ButtonsPanel, allocator: std.mem.Allocator) void {
        for (self.levels) |*btn| {
            allocator.free(btn.fontText);
        }
        allocator.free(self.levels);
    }
};

pub const Button = struct {
    texture: rl.Texture2D,
    hoverConf: HoverConfig,
    spriteConf: SpriteDefaultConfig,
    fontText: [:0]const u8,
    size: u32,
    fontOffset: rl.Vector2,
    canClick: bool = true,

    pub fn setPosition(self: *Button, x: f32, y: f32) void {
        self.spriteConf.position.x = x;
        self.spriteConf.position.y = y;
    }

    pub fn setConfig(self: *Button, config: SpriteDefaultConfig) void {
        self.spriteConf = config;
    }

    pub fn setCanClick(self: *Button, canClick: bool) void {
        self.canClick = canClick;
    }

    fn applyHover(self: *Button) void {
        const hover = isHover(self);
        const conf = self.hoverConf;
        if (hover) {
            self.spriteConf.color = conf.hover_color;
            self.spriteConf.scale = conf.hover_scale;
        }
    }

    pub fn isClicked(self: *Button) bool {
        const hover = self.isHover();
        const mouseLeftButton: bool = rl.isMouseButtonPressed(rl.MouseButton.left);

        return hover and mouseLeftButton;
    }

    fn resetHover(self: *Button) void {
        self.spriteConf.color = self.hoverConf.default_color;
        self.spriteConf.scale = self.hoverConf.default_scale;
    }

    pub fn isHover(self: *Button) bool {
        if (rl.isCursorOnScreen() == false) {
            return false;
        }

        const mouse_pos: rl.Rectangle = .init(CursorManager.getMouseX(), CursorManager.getMouseY(), 20, 20);
        const button: rl.Rectangle = .init(
            self.spriteConf.position.x,
            self.spriteConf.position.y,
            self.spriteConf.sprite.src.width * self.spriteConf.scale,
            self.spriteConf.sprite.src.height * self.spriteConf.scale,
        );

        const mouseInButton: bool = rl.Rectangle.checkCollision(mouse_pos, button);
        return mouseInButton;
    }

    pub fn draw(self: *Button) void {
        applyHover(self);

        // print("x : {d} y : {d}\n", .{ self.spriteConf.position.x, self.spriteConf.position.y });
        Sprite.drawCustom(self.texture, self.spriteConf);
        FontManager.drawText(self.fontText, self.spriteConf.position.x + self.fontOffset.x, self.spriteConf.position.y + self.fontOffset.y, self.size, 0.0, .black);

        resetHover(self);
    }
};
