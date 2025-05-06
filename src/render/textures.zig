const rl = @import("raylib");

pub var elf: rl.Texture2D = undefined;
pub var spriteSheet: rl.Texture2D = undefined;

pub var sprites: Sprites = undefined;

pub fn init() !void {
    elf = try rl.loadTexture("assets/textures/elf/pers.png");
    spriteSheet = try rl.loadTexture("assets/textures/pack/legacy_adventure/Assets/Assets.png");

    sprites = Sprites.init();
}

pub const Sprite = struct {
    name: []const u8,
    src: rl.Rectangle,

    pub fn draw(sheet: rl.Texture2D, self: Sprite, position: rl.Vector2, scale: f32) void {
        const dest = rl.Rectangle{
            .x = position.x,
            .y = position.y,
            .width = self.src.width * scale,
            .height = self.src.height * scale,
        };
        const origin = rl.Vector2{ .x = 0, .y = 0 };
        const rotation: f32 = 0.0;

        rl.drawTexturePro(sheet, self.src, dest, origin, rotation, .white);
    }
};

pub const Sprites = struct {
    block: Sprite,
    bushGreen: Sprite,
    bushDark: Sprite,
    water: Sprite,
    portal: Sprite,

    pub fn init() Sprites {
        return Sprites{
            .block = .{ .name = "Block", .src = rl.Rectangle{ .x = 0, .y = 0, .width = 16, .height = 16 } },
            .bushGreen = .{ .name = "GreenBush", .src = rl.Rectangle{ .x = 96, .y = 0, .width = 96, .height = 96 } },
            .bushDark = .{ .name = "DarkBush", .src = rl.Rectangle{ .x = 192, .y = 0, .width = 96, .height = 96 } },
            .water = .{ .name = "Water", .src = rl.Rectangle{ .x = 96, .y = 96, .width = 96, .height = 96 } },
            .portal = .{ .name = "Portal", .src = rl.Rectangle{ .x = 0, .y = 96, .width = 96, .height = 96 } },
        };
    }
};
