const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;
const CellType = @import("../game/grid.zig").CellType;
const Elf = @import("../game/player.zig").Elf;

pub var elf: rl.Texture2D = undefined;
pub var spriteSheet: rl.Texture2D = undefined;
pub var forest_background: rl.Texture2D = undefined;
pub var inventory_hud: rl.Texture2D = undefined;
pub var simple_inventory_hud: rl.Texture2D = undefined;

pub var oak_bg_lyr_1: rl.Texture2D = undefined;
pub var oak_bg_lyr_2: rl.Texture2D = undefined;
pub var oak_bg_lyr_3: rl.Texture2D = undefined;
pub var oak_woods_tileset: rl.Texture2D = undefined;
pub var top_far_bgrnd: rl.Texture2D = undefined;
pub var env_ground: rl.Texture2D = undefined;

pub var pad: rl.Texture2D = undefined;

pub var all_weapons: rl.Texture2D = undefined;

pub var jumper_sprite: AnimatedSprite = undefined;

pub const BLOCK_SIZE: f32 = 16;
pub var sprites: Sprites = undefined;

pub fn init() !void {
    elf = try rl.loadTexture("assets/textures/elf/pers.png");
    forest_background = try rl.loadTexture("assets/textures/pack/legacy_adventure/Assets/forest_background.png");

    oak_bg_lyr_1 = try rl.loadTexture("assets/textures/pack/oak_woods/background/background_layer_1.png");
    oak_bg_lyr_2 = try rl.loadTexture("assets/textures/pack/oak_woods/background/background_layer_2.png");
    oak_bg_lyr_3 = try rl.loadTexture("assets/textures/pack/oak_woods/background/background_layer_3.png");
    oak_woods_tileset = try rl.loadTexture("assets/textures/pack/oak_woods/oak_woods_tileset.png");

    top_far_bgrnd = try rl.loadTexture("assets/textures/pack/DarkForest/top_far_bgrnd.png");
    env_ground = try rl.loadTexture("assets/textures/pack/DarkForest/env_ground.png");
    inventory_hud = try rl.loadTexture("assets/textures/pack/oak_woods/inventory.png");
    simple_inventory_hud = try rl.loadTexture("assets/textures/pack/oak_woods/simple_inventory.png");

    all_weapons = try rl.loadTexture("assets/textures/pack/trap_and_weapon/all.png");

    pad = try rl.loadTexture("assets/textures/pack/trap_and_weapon/Jumper.png");

    spriteSheet = try rl.loadTexture("assets/textures/pack/legacy_adventure/Assets/Assets.png");
    sprites = Sprites.init();

    //Animated Sprites
    jumper_sprite = AnimatedSprite{
        .texture = pad,
        .sprite = Sprite{
            .name = "Pad",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 24, .height = 16 },
        },
        .start_x = 0,
        .start_y = 0,
        .frame_width = 24,
        .frame_height = 16,
        .num_frames = 8,
        .frame_duration = 0.1,
    };
}

pub const Sprite = struct {
    name: []const u8,
    src: rl.Rectangle,

    pub fn draw(sheet: rl.Texture2D, self: Sprite, position: rl.Vector2, scale: f32, tint: rl.Color) void {
        const dest = rl.Rectangle{
            .x = position.x,
            .y = position.y,
            .width = self.src.width * scale,
            .height = self.src.height * scale,
        };
        const origin = rl.Vector2{ .x = 0, .y = 0 };
        const rotation: f32 = 0.0;

        rl.drawTexturePro(sheet, self.src, dest, origin, rotation, tint);
    }

    pub fn drawWithRotation(sheet: rl.Texture2D, self: Sprite, position: rl.Vector2, scale: f32, rotation: f32, alpha: u8) void {
        const dest = rl.Rectangle{
            .x = position.x,
            .y = position.y,
            .width = self.src.width * scale,
            .height = self.src.height * scale,
        };
        const origin = rl.Vector2{ .x = 0, .y = 0 };

        const tint = rl.Color{
            .r = 255,
            .g = 255,
            .b = 255,
            .a = alpha,
        };

        rl.drawTexturePro(sheet, self.src, dest, origin, rotation, tint);
    }

    pub fn typeToSprite(celltype: CellType) Sprite {
        return switch (celltype) {
            .GROUND => sprites.granite_pure_l4,
            .PAD => jumper_sprite.texture,
            else => sprites.granite_pure_l4,
        };
    }
};

pub const Sprites = struct {
    granite_pure_l4: Sprite,
    granite_pure_l3: Sprite,
    granite_l1: Sprite,
    granite_l2: Sprite,
    granite_l3: Sprite,
    granite_l4: Sprite,
    granite_pillar: Sprite,
    granite_beam: Sprite,
    granite_border: Sprite,
    carved_granite: Sprite,
    bushGreen: Sprite,
    bushGreenBorders: Sprite,
    bushDark: Sprite,
    water: Sprite,
    portal: Sprite,

    oak_bg_lyr_1: Sprite,
    oak_bg_lyr_2: Sprite,
    oak_bg_lyr_3: Sprite,
    oak_woods_tileset: Sprite,

    forest_background: Sprite,
    inventory_hud: Sprite,
    simple_inventory_hud: Sprite,

    simple_spike: Sprite,
    wood_block_spikes: Sprite,

    dark_forest_grd: Sprite,
    scared_forest_grd: Sprite,
    env_ground_leaves: Sprite,

    pub fn init() Sprites {
        return Sprites{
            .granite_l4 = .{ .name = "Granite_L4", .src = rl.Rectangle{ .x = 0, .y = 0, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },
            .granite_l3 = .{ .name = "Granite_L3", .src = rl.Rectangle{ .x = 0, .y = BLOCK_SIZE, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },
            .granite_l2 = .{ .name = "Granite_L2", .src = rl.Rectangle{ .x = 0, .y = 2 * BLOCK_SIZE, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },
            .granite_l1 = .{ .name = "Granite_L1", .src = rl.Rectangle{ .x = 0, .y = 3 * BLOCK_SIZE, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },
            .carved_granite = .{ .name = "Carverd_Granite", .src = rl.Rectangle{ .x = 0, .y = 4 * BLOCK_SIZE, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },
            .granite_pillar = .{ .name = "Granite_Pillar", .src = rl.Rectangle{ .x = 0, .y = 5 * BLOCK_SIZE, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },
            .granite_beam = .{ .name = "Granite_Beam", .src = rl.Rectangle{ .x = BLOCK_SIZE, .y = 4 * BLOCK_SIZE, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },
            .granite_pure_l4 = .{ .name = "Granite_Pure_L4", .src = rl.Rectangle{ .x = BLOCK_SIZE, .y = 0, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },
            .granite_pure_l3 = .{ .name = "Granite_Pure_L3", .src = rl.Rectangle{ .x = 2 * BLOCK_SIZE, .y = 2 * BLOCK_SIZE, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },
            .granite_border = .{ .name = "Granite Border", .src = rl.Rectangle{ .x = BLOCK_SIZE, .y = 6 * BLOCK_SIZE, .width = BLOCK_SIZE, .height = BLOCK_SIZE } },

            .bushGreen = .{ .name = "GreenBush", .src = rl.Rectangle{ .x = 96, .y = 0, .width = 96, .height = 96 } },
            .bushGreenBorders = .{ .name = "Bush Green Borders", .src = rl.Rectangle{ .x = 145, .y = 0, .width = 78, .height = 78 } },

            .bushDark = .{ .name = "DarkBush", .src = rl.Rectangle{ .x = 192, .y = 0, .width = 96, .height = 96 } },
            .water = .{ .name = "Water", .src = rl.Rectangle{ .x = 96, .y = 96, .width = 96, .height = 96 } },
            .portal = .{ .name = "Portal", .src = rl.Rectangle{ .x = 0, .y = 96, .width = 96, .height = 96 } },

            .forest_background = .{ .name = "Forest Background", .src = rl.Rectangle{ .x = 0, .y = 0, .width = 1747, .height = 984 } },
            .inventory_hud = .{ .name = "Inventory HUD", .src = rl.Rectangle{ .x = 0, .y = 0, .width = 278, .height = 103 } },
            .simple_inventory_hud = .{ .name = "Simple Inventory HUD", .src = rl.Rectangle{ .x = 0, .y = 0, .width = 77, .height = 26 } },

            .oak_bg_lyr_1 = .{ .name = "Oak Background Layer 1", .src = rl.Rectangle{ .x = 0, .y = 0, .width = 320, .height = 180 } },
            .oak_bg_lyr_2 = .{ .name = "Oak Background Layer 2", .src = rl.Rectangle{ .x = 0, .y = 0, .width = 320, .height = 180 } },
            .oak_bg_lyr_3 = .{ .name = "Oak Background Layer 3", .src = rl.Rectangle{ .x = 0, .y = 0, .width = 320, .height = 180 } },
            .oak_woods_tileset = .{ .name = "Oak Wookd Tileset", .src = rl.Rectangle{ .x = 0, .y = 0, .width = 100, .height = 100 } },

            .scared_forest_grd = .{ .name = "Scared Forest Ground", .src = rl.Rectangle{ .x = 0, .y = 0, .width = 600, .height = 100 } },
            .dark_forest_grd = .{ .name = "Dark Forest Ground", .src = rl.Rectangle{ .x = 0, .y = 700, .width = 600, .height = 100 } },
            .env_ground_leaves = .{ .name = "Environment Ground With Orange Leaves", .src = rl.Rectangle{ .x = 120, .y = 250, .width = 150, .height = 30 } },
            .simple_spike = .{ .name = "Simple Spike", .src = rl.Rectangle{ .x = 415, .y = 320, .width = 16, .height = 14 } },
            .wood_block_spikes = .{ .name = "Wood Block Spikes", .src = rl.Rectangle{ .x = 160, .y = 70, .width = 30, .height = 30 } },
        };
    }
};

pub const AnimatedSprite = struct {
    texture: rl.Texture2D,
    sprite: Sprite,
    start_x: f32,
    start_y: f32,
    frame_width: f32,
    frame_height: f32,
    num_frames: usize,
    current_frame: usize = 0,
    frame_duration: f32, // seconds
    time_acc: f32 = 0.0,
    x: usize = 0, //Current Pad Animated Position
    y: usize = 0,
    isRunning: bool = false,
    loop: usize = 0,

    pub fn setPos(self: *AnimatedSprite, x: usize, y: usize) void {
        self.x = x;
        self.y = y;
    }

    pub fn update(self: *AnimatedSprite, delta_time: f32, loop_limit: usize) void {
        if (self.loop == loop_limit) {
            self.isRunning = false;
            self.loop = 0;

            return;
        }

        self.time_acc += delta_time;
        if (self.time_acc >= self.frame_duration) {
            self.time_acc -= self.frame_duration;
            self.current_frame = (self.current_frame + 1) % self.num_frames;
        }

        if (self.isRunning and self.current_frame == self.num_frames - 1) {
            self.loop += 1;
        }
    }

    pub fn draw(self: AnimatedSprite, position: rl.Vector2, scale: f32, alpha: u8, x: usize, y: usize) void {
        const next_sprite: f32 = if (self.isRunning and x == self.x and y == self.y) @as(f32, @floatFromInt(self.current_frame)) * self.frame_width else 0;

        // if (next_sprite != 0) {
        //     print("Animated !\n", .{});
        // }

        const src = rl.Rectangle{
            .x = self.start_x + next_sprite,
            .y = self.start_y,
            .width = self.frame_width,
            .height = self.frame_height,
        };

        const dest = rl.Rectangle{
            .x = position.x,
            .y = position.y,
            .width = self.frame_width * scale,
            .height = self.frame_height * scale,
        };

        const origin = rl.Vector2{ .x = 0, .y = 0 };

        const tint = rl.Color{
            .r = 255,
            .g = 255,
            .b = 255,
            .a = alpha,
        };

        rl.drawTexturePro(self.texture, src, dest, origin, 0.0, tint);
    }
};
