const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;
const textures = @import("../render/textures.zig");
const CursorManager = @import("../game/cursor.zig").CursorManager;
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const Sprite = textures.Sprite;

pub var btns_panel: ButtonsPanel = undefined;

pub const HoverConfig = struct {
    hover_color: rl.Color = .gray,

    hover_scale_factor: f32 = 1.1,
};

pub const ButtonsPanel = struct {
    play: Button,

    pub fn init() void {
        btns_panel = ButtonsPanel{
            .play = Button.init(
                textures.moving_platform,
                HoverConfig{},
                SpriteDefaultConfig{
                    .position = .{ .x = 100, .y = 100 },
                    .scale = 4.0,
                    .sprite = Sprite{
                        .name = "Play",
                        .src = .{ .x = 0, .y = 0, .width = 100, .height = 200 },
                    },
                },
            ),

            //For others
        };
    }
};

pub const Button = struct {
    texture: rl.Texture2D,
    hoverConf: HoverConfig,
    spriteConf: SpriteDefaultConfig,

    pub fn init(
        texture: rl.Texture2D,
        hoverConf: HoverConfig,
        spriteConf: SpriteDefaultConfig,
    ) Button {
        return Button{
            .texture = texture,
            .hoverConf = hoverConf,
            .spriteConf = spriteConf,
        };
    }

    pub fn isHover(self: *Button) bool {
        const mouse_pos: rl.Rectangle = .init(CursorManager.getMouseX(), CursorManager.getMouseY(), 5, 5);
        const button: rl.Rectangle = .init(
            self.spriteConf.position.x,
            self.spriteConf.position.y,
            self.spriteConf.sprite.src.width,
            self.spriteConf.sprite.src.height,
        );
        rl.drawRectangleRec(mouse_pos, .yellow);
        const mouseInButton: bool = rl.Rectangle.checkCollision(mouse_pos, button);
        return mouseInButton;
    }

    pub fn draw(self: *Button) void {
        if (self.isHover()) {
            print("Hover\n", .{});
            self.spriteConf.scale = self.hoverConf.hover_scale_factor;
            self.spriteConf.color = self.hoverConf.hover_color;
        } else {
            print("NO Hover\n", .{});
        }

        Sprite.drawCustom(self.texture, self.spriteConf);
    }
};
