const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;
const textures = @import("../render/textures.zig");
const window = @import("../render/window.zig");
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

    pub fn init() void {
        btns_panel = ButtonsPanel{
            .play = Button{
                .texture = textures.play_button,
                .hoverConf = HoverConfig{
                    .default_scale = 5.0,
                    .hover_scale = 5.3,
                },
                .spriteConf = SpriteDefaultConfig{
                    .position = .{ .x = window.WINDOW_WIDTH * 0.25 - 48 * 3, .y = window.WINDOW_HEIGHT * 0.50 },
                    .scale = 5.0,
                    .sprite = Sprite{
                        .name = "Play",
                        .src = .{ .x = 0, .y = 0, .width = 48, .height = 12 },
                    },
                },
                .fontText = "Play",
                .size = 32,
                .fontOffset = .{ .x = 90, .y = 12 },
            },
            .exit = Button{
                .texture = textures.exit_button,
                .hoverConf = HoverConfig{
                    .default_scale = 5.0,
                    .hover_scale = 5.3,
                },
                .spriteConf = SpriteDefaultConfig{
                    .position = .{ .x = window.WINDOW_WIDTH * 0.25 - 48 * 3, .y = window.WINDOW_HEIGHT * 0.65 },
                    .scale = 5.0,
                    .sprite = Sprite{
                        .name = "Exit",
                        .src = .{ .x = 0, .y = 0, .width = 48, .height = 12 },
                    },
                },
                .fontText = "Exit",
                .size = 32,
                .fontOffset = .{ .x = 90, .y = 12 },
            },
            .settings = Button{
                .texture = textures.settings_button,
                .hoverConf = HoverConfig{
                    .default_scale = 5.0,
                    .hover_scale = 5.2,
                },
                .spriteConf = SpriteDefaultConfig{
                    .position = .{ .x = window.WINDOW_WIDTH * 0.9, .y = window.WINDOW_HEIGHT * 0.90 },
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
        };
    }
};

pub const Button = struct {
    texture: rl.Texture2D,
    hoverConf: HoverConfig,
    spriteConf: SpriteDefaultConfig,
    fontText: [:0]const u8,
    size: u32,
    fontOffset: rl.Vector2,

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
