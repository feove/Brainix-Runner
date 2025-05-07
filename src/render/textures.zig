const rl = @import("raylib");

pub var elf: rl.Texture2D = undefined;
pub var spriteSheet: rl.Texture2D = undefined;

const BLOCK_SIZE: f32 = 16;
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
    granite_l1: Sprite,
    granite_l2: Sprite,
    granite_l3: Sprite,
    granite_l4: Sprite,
    granite_pillar: Sprite,
    granite_beam: Sprite,

    carved_granite: Sprite,

    bushGreen: Sprite,
    bushDark: Sprite,
    water: Sprite,
    portal: Sprite,

    pub fn init() Sprites {
        return Sprites{
            .granite_l4 = .{ .name = "Granite_L4", .src = rl.Rectangle{ .x = 0, .y = 0, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },
            .granite_l3 = .{ .name = "Granite_L3", .src = rl.Rectangle{ .x = 0, .y = BLOCK_SIZE, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },
            .granite_l2 = .{ .name = "Granite_L2", .src = rl.Rectangle{ .x = 0, .y = 2 * BLOCK_SIZE, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },
            .granite_l1 = .{ .name = "Granite_L1", .src = rl.Rectangle{ .x = 0, .y = 3 * BLOCK_SIZE, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },
            .carved_granite = .{ .name = "Carverd_Granite", .src = rl.Rectangle{ .x = 0, .y = 4 * BLOCK_SIZE, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },
            .granite_pillar = .{ .name = "Granite_Pillar", .src = rl.Rectangle{ .x = 0, .y = 5 * BLOCK_SIZE, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },
            .granite_beam = .{ .name = "Granite_Beam", .src = rl.Rectangle{ .x = BLOCK_SIZE, .y = 4 * BLOCK_SIZE, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },

            .bushGreen = .{ .name = "GreenBush", .src = rl.Rectangle{ .x = 96, .y = 0, .width = 96, .height = 96 } },
            .bushDark = .{ .name = "DarkBush", .src = rl.Rectangle{ .x = 192, .y = 0, .width = 96, .height = 96 } },
            .water = .{ .name = "Water", .src = rl.Rectangle{ .x = 96, .y = 96, .width = 96, .height = 96 } },
            .portal = .{ .name = "Portal", .src = rl.Rectangle{ .x = 0, .y = 96, .width = 96, .height = 96 } },
        };
    }
};
