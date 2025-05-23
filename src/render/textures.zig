const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;

const terrain = @import("../terrain/grid.zig");
const Grid = terrain.Grid;
const CellType = terrain.CellType;

const Elf = @import("../entity/elf.zig").Elf;
const anim = @import("../game/animations/animations_manager.zig");
const HUD = @import("../game/utils.zig").HUD;
const Inventory = @import("../game/inventory.zig").Inventory;

pub var elf: rl.Texture2D = undefined;
pub var battlemage_text: rl.Texture2D = undefined;

//battlemage Anims
pub var battlemage_running: rl.Texture2D = undefined;
pub var battlemage_jump_neutral: rl.Texture2D = undefined;
pub var battlemage_jump_neutral_going_down: rl.Texture2D = undefined;
pub var battlemage_dying: rl.Texture2D = undefined;

//Wizard Anims
pub var demon_idle2: rl.Texture2D = undefined;
pub var wizard_jumping: rl.Texture2D = undefined;
pub var wizard_falling: rl.Texture2D = undefined;
pub var wizard_attacking_1: rl.Texture2D = undefined;
pub var wizard_attacking_2: rl.Texture2D = undefined;

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

pub var dungeons_tile: rl.Texture2D = undefined;

pub var pad: rl.Texture2D = undefined;
pub var moving_platform: rl.Texture2D = undefined;
pub var all_weapons: rl.Texture2D = undefined;

pub var green_effects: rl.Texture2D = undefined;
pub var yellow_effects: rl.Texture2D = undefined;
pub var effects_sheet_506: rl.Texture2D = undefined;
pub var effects_sheet_516: rl.Texture2D = undefined;
pub var effects_sheet_526: rl.Texture2D = undefined;

pub const BLOCK_SIZE: f32 = 16;
pub var sprites: Sprites = undefined;

pub fn init() !void {
    elf = try rl.loadTexture("assets/textures/elf/pers.png");

    //Battle mage
    battlemage_running = try rl.loadTexture("assets/textures/elf/battlemage/completed_sprite/Running/battlemage_running.png");
    battlemage_jump_neutral = try rl.loadTexture("assets/textures/elf/battlemage/completed_sprite/jump_neutal/battlemage_jump_neutral.png");
    battlemage_jump_neutral_going_down = try rl.loadTexture("assets/textures/elf/battlemage/completed_sprite/jump_neutal/going_down/jump_neutral_going_down.png");
    battlemage_dying = try rl.loadTexture("assets/textures/elf/battlemage/completed_sprite/death/battlemage_death.png");

    //Demon
    demon_idle2 = try rl.loadTexture("assets/textures/wizard/Idle.png");
    wizard_jumping = try rl.loadTexture("assets/textures/wizard/Jump.png");
    wizard_falling = try rl.loadTexture("assets/textures/wizard/Fall.png");
    wizard_attacking_1 = try rl.loadTexture("assets/textures/wizard/Attack1.png");
    wizard_attacking_2 = try rl.loadTexture("assets/textures/wizard/Attack2.png");

    //Dungeons
    dungeons_tile = try rl.loadTexture("assets/textures/pack/oak_woods/dungeons_tile.png");

    //try rl.loadTexture("assets/textures/demon/Idle.png")
    //try rl.loadTexture("assets/textures/demon/idle2.png");

    forest_background = try rl.loadTexture("assets/textures/pack/legacy_adventure/Assets/forest_background.png");

    oak_bg_lyr_1 = try rl.loadTexture("assets/textures/pack/oak_woods/background/background_layer_1.png");
    oak_bg_lyr_2 = try rl.loadTexture("assets/textures/pack/oak_woods/background/background_layer_2.png");
    oak_bg_lyr_3 = try rl.loadTexture("assets/textures/pack/oak_woods/background/background_layer_3.png");
    oak_woods_tileset = try rl.loadTexture("assets/textures/pack/oak_woods/oak_woods_tileset.png");

    top_far_bgrnd = try rl.loadTexture("assets/textures/pack/DarkForest/top_far_bgrnd.png");
    env_ground = try rl.loadTexture("assets/textures/pack/DarkForest/env_ground.png");
    inventory_hud = try rl.loadTexture("assets/textures/pack/oak_woods/inventory.png");
    simple_inventory_hud = try rl.loadTexture("assets/textures/pack/oak_woods/simple_inventory.png");

    green_effects = try rl.loadTexture("assets/textures/pack/effects/green_effect.png");
    yellow_effects = try rl.loadTexture("assets/textures/pack/effects/yellow_effect.png");
    all_weapons = try rl.loadTexture("assets/textures/pack/trap_and_weapon/all.png");
    effects_sheet_506 = try rl.loadTexture("assets/textures/pack/effects/Free/506.png");
    effects_sheet_516 = try rl.loadTexture("assets/textures/pack/effects/Free/516.png");
    effects_sheet_526 = try rl.loadTexture("assets/textures/pack/effects/Free/526.png");

    pad = try rl.loadTexture("assets/textures/pack/trap_and_weapon/Jumper.png");
    moving_platform = try rl.loadTexture("assets/textures/pack/trap_and_weapon/moving_platform.png");

    spriteSheet = try rl.loadTexture("assets/textures/pack/legacy_adventure/Assets/Assets.png");
    sprites = Sprites.init();
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

    pub fn drawWithRotation(sheet: rl.Texture2D, self: Sprite, position: rl.Vector2, scale: f32, rotation: f32, alpha: f32, canPlace: bool) void {
        const dest = rl.Rectangle{
            .x = position.x,
            .y = position.y,
            .width = self.src.width * scale,
            .height = self.src.height * scale,
        };
        const origin = rl.Vector2{ .x = 0, .y = 0 };

        const color: rl.Color = if (!canPlace) .white else .red;

        const tint: rl.Color = rl.Color.alpha(color, alpha / 255);

        rl.drawTexturePro(sheet, self.src, dest, origin, rotation, tint);
    }

    pub fn typeToSprite(celltype: CellType) Sprite {
        return switch (celltype) {
            .GROUND => sprites.granite_pure_l4,
            .PAD => anim.jumper_sprite.texture,
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
    arrow_icn: Sprite,

    dark_forest_grd: Sprite,
    scared_forest_grd: Sprite,
    env_ground_leaves: Sprite,

    dungeon_stair_right: Sprite,
    dungeon_wall_right_1: Sprite,
    dungeon_wall_right_2: Sprite,
    dungeon_wall_left_1: Sprite,
    dungeon_wall_left_2: Sprite,
    dungeon_long_wall_1: Sprite,
    dungeon_door: Sprite,

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
            .arrow_icn = .{ .name = "Arrow Icon", .src = rl.Rectangle{ .x = 300, .y = 160, .width = 20, .height = 15 } },

            .dungeon_stair_right = .{ .name = "Dungeon Stair Right", .src = rl.Rectangle{ .x = 94, .y = 16, .width = 16, .height = 16 } },

            .dungeon_wall_right_1 = .{ .name = "Dungeon Wall Right 1", .src = rl.Rectangle{ .x = 94, .y = 32, .width = 16, .height = 16 } },
            .dungeon_wall_right_2 = .{ .name = "Dungeon Wall Right 2", .src = rl.Rectangle{ .x = 94, .y = 48, .width = 16, .height = 16 } },
            .dungeon_wall_left_1 = .{ .name = "Dungeon Wall Left 1", .src = rl.Rectangle{ .x = 78, .y = 32, .width = 16, .height = 16 } },
            .dungeon_wall_left_2 = .{ .name = "Dungeon Wall Left 2", .src = rl.Rectangle{ .x = 78, .y = 48, .width = 16, .height = 16 } },

            .dungeon_long_wall_1 = .{ .name = "Dungeon Long Wall 1", .src = rl.Rectangle{ .x = 126, .y = 16, .width = 32, .height = 16 } },
            .dungeon_door = .{ .name = "Dungeon Door", .src = rl.Rectangle{ .x = 206, .y = 160, .width = 20, .height = 32 } },
        };
    }
};
