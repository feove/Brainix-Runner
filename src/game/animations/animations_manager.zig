const rl = @import("raylib");
const print = @import("std").debug.print;
const textures = @import("../../render/textures.zig");
const Sprite = textures.Sprite;

//Items
pub var jumper_sprite: AnimatedSprite = undefined;
pub var moving_platform: AnimatedSprite = undefined;
pub var boost_sprite: AnimatedSprite = undefined;
pub var falling_platform: AnimatedSprite = undefined;

pub var battlemage_running: AnimatedSprite = undefined;
pub var battlemage_jumping_full: AnimatedSprite = undefined;
pub var battlemage_jumping_going_down: AnimatedSprite = undefined;
pub var battlemage_dying: AnimatedSprite = undefined;
pub var battlemage_idle: AnimatedSprite = undefined;

//Effects
pub var spawning_item: AnimatedSprite = undefined;
pub var square_despawning_item: AnimatedSprite = undefined;
pub var spike_despawning_item: AnimatedSprite = undefined;
pub var small_lighting_0: AnimatedSprite = undefined;
pub var scratch: AnimatedSprite = undefined;
pub var entity_spawn: AnimatedSprite = undefined;
pub var woosh: AnimatedSprite = undefined;
pub var slot_cleanning: AnimatedSprite = undefined;

//Wizard
pub var demon_idle2: AnimatedSprite = undefined;
pub var wizard_jumping: AnimatedSprite = undefined;
pub var wizard_falling: AnimatedSprite = undefined;
pub var wizard_attacking_1: AnimatedSprite = undefined;
pub var wizard_attacking_2: AnimatedSprite = undefined;

//Star
pub var star: AnimatedSprite = undefined;

pub fn init() !void {
    falling_platform = AnimatedSprite{
        .texture = textures.falling_platfom,
        .sprite = Sprite{
            .name = "Falling Platform",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 256, .height = 16 },
        },
        .start_x = 0,
        .start_y = 0,
        .frame_width = 32,
        .frame_height = 16,
        .horizontal_shift = true,
        .num_frames = 8,
        .frame_duration = 0.1,
    };

    jumper_sprite = AnimatedSprite{
        .texture = textures.pad,
        .sprite = Sprite{
            .name = "Pad",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 24, .height = 16 },
        },
        .start_x = 24,
        .start_y = 0,
        .frame_width = 24,
        .frame_height = 16,
        .horizontal_shift = true,
        .num_frames = 7, //8
        .frame_duration = 0.1,
    };

    slot_cleanning = AnimatedSprite{
        .texture = textures.yellow_effects,
        .sprite = Sprite{
            .name = "Slot Cleanning",
            .src = rl.Rectangle{ .x = 304, .y = 190, .width = 16, .height = 16 },
        },
        .start_x = 304,
        .start_y = 194,
        .frame_width = 16,
        .frame_height = 14,
        .horizontal_shift = true,
        .num_frames = 4,
        .frame_duration = 0.1,
    };

    boost_sprite = AnimatedSprite{
        .texture = textures.yellow_effects,
        .sprite = Sprite{
            .name = "Boost",
            .src = rl.Rectangle{ .x = 304, .y = 32, .width = 16, .height = 16 },
        },
        .start_x = 304,
        .start_y = 32,
        .frame_width = 16,
        .frame_height = 16,
        .horizontal_shift = true,
        .num_frames = 4,
        .frame_duration = 0.1,
    };

    entity_spawn = AnimatedSprite{
        .texture = textures.effects_sheet_517,
        .sprite = Sprite{
            .name = "Spawn effect",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 768, .height = 576 },
        },
        .start_x = 64,
        .start_y = 64 * 5,
        .frame_width = 64,
        .frame_height = 64,
        .horizontal_shift = true,
        .num_frames = 12,
        .frame_duration = 0.05,
    };

    woosh = AnimatedSprite{
        .texture = textures.effects_sheet_519,
        .sprite = Sprite{
            .name = "Woosh effect",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 768, .height = 576 },
        },
        .start_x = 0,
        .start_y = 64 * 5,
        .frame_width = 64,
        .frame_height = 64,
        .horizontal_shift = true,
        .num_frames = 12,
        .frame_duration = 0.05,
    };

    spawning_item = AnimatedSprite{
        .texture = textures.yellow_effects,
        .sprite = Sprite{
            .name = "Spawning Item Effect",
            .src = rl.Rectangle{ .x = 480, .y = 96, .width = 96, .height = 16 },
        },
        .start_x = 480,
        .start_y = 96,
        .frame_width = 16,
        .frame_height = 16,
        .horizontal_shift = true,
        .num_frames = 6,
        .frame_duration = 0.1,
    };

    small_lighting_0 = AnimatedSprite{
        .texture = textures.effects_sheet_506,
        .sprite = Sprite{
            .name = "Small Lighting effect",
            .src = rl.Rectangle{ .x = 0, .y = 128, .width = 704, .height = 576 },
        },
        .start_x = 0,
        .start_y = 64 * 7,
        .frame_width = 64,
        .frame_height = 64,
        .horizontal_shift = true,
        .num_frames = 11,
        .frame_duration = 0.1,
    };

    scratch = AnimatedSprite{
        .texture = textures.effects_sheet_526,
        .sprite = Sprite{
            .name = "Scratch effect",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 832, .height = 576 },
        },
        .start_x = 0,
        .start_y = 64 * 1,
        .frame_width = 64,
        .frame_height = 64,
        .horizontal_shift = true,
        .num_frames = 7,
        .frame_duration = 0.05,
    };

    spike_despawning_item = AnimatedSprite{
        .texture = textures.yellow_effects,
        .sprite = Sprite{
            .name = "Spike despawning Item Effect",
            .src = rl.Rectangle{ .x = 384, .y = 113, .width = 80, .height = 16 },
        },
        .start_x = 384,
        .start_y = 113,
        .frame_width = 16,
        .frame_height = 16,
        .horizontal_shift = true,
        .num_frames = 6,
        .frame_duration = 0.1,
    };

    square_despawning_item = AnimatedSprite{
        .texture = textures.yellow_effects,
        .sprite = Sprite{
            .name = "Square Despawning Item Effect",
            .src = rl.Rectangle{ .x = 384, .y = 144, .width = 80, .height = 16 },
        },
        .start_x = 384,
        .start_y = 144,
        .frame_width = 16,
        .frame_height = 16,
        .horizontal_shift = true,
        .num_frames = 6,
        .frame_duration = 0.1,
    };

    battlemage_idle = AnimatedSprite{
        .texture = textures.battlemage_idle,
        .sprite = Sprite{
            .name = "Battle Mage is in Idle State",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 56, .height = 384 },
        },
        .start_x = 0,
        .start_y = 0,
        .frame_width = 56,
        .frame_height = 48,
        .horizontal_shift = false,
        .num_frames = 8,
        .frame_duration = 0.1,
    };

    battlemage_running = AnimatedSprite{
        .texture = textures.battlemage_running,
        .sprite = Sprite{
            .name = "Battle Mage is Running",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 56, .height = 480 },
        },
        .start_x = 0,
        .start_y = 0,
        .frame_width = 56,
        .frame_height = 48,
        .horizontal_shift = false,
        .num_frames = 10,
        .frame_duration = 0.1,
    };

    battlemage_jumping_full = AnimatedSprite{
        .texture = textures.battlemage_jump_neutral,
        .sprite = Sprite{
            .name = "Battle Mage is Jumping Going up",
            .src = rl.Rectangle{ .x = 0, .y = 48, .width = 56, .height = 624 },
        },
        .start_x = 0,
        .start_y = 48,
        .frame_width = 56,
        .frame_height = 48,
        .horizontal_shift = false,
        .num_frames = 10,
        .frame_duration = 0.1,
    };

    battlemage_jumping_going_down = AnimatedSprite{
        .texture = textures.battlemage_jump_neutral_going_down,
        .sprite = Sprite{
            .name = "Battle Mage is going down",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 56, .height = 144 },
        },
        .start_x = 0,
        .start_y = 0,
        .frame_width = 56,
        .frame_height = 48,
        .horizontal_shift = false,
        .num_frames = 3,
        .frame_duration = 0.1,
    };

    battlemage_dying = AnimatedSprite{
        .texture = textures.battlemage_dying,
        .sprite = Sprite{
            .name = "Battle Mage is dying",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 56, .height = 576 },
        },
        .start_x = 0,
        .start_y = 0,
        .frame_width = 56,
        .frame_height = 48,
        .horizontal_shift = false,
        .num_frames = 12,
        .frame_duration = 0.1,
    };

    demon_idle2 = AnimatedSprite{
        .texture = textures.demon_idle2,
        .sprite = Sprite{
            .name = "Demon in Idle2",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 1386, .height = 190 },
        },
        .start_x = 0,
        .start_y = 0,
        .frame_width = 231,
        .frame_height = 190,
        .horizontal_shift = true,
        .num_frames = 6,
        .frame_duration = 0.2,
    };

    wizard_jumping = AnimatedSprite{
        .texture = textures.wizard_jumping,
        .sprite = Sprite{
            .name = "Wizard is Jumping",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 462, .height = 190 },
        },
        .start_x = 0,
        .start_y = 0,
        .frame_width = 231,
        .frame_height = 190,
        .horizontal_shift = true,
        .num_frames = 2,
        .frame_duration = 0.1,
    };

    wizard_falling = AnimatedSprite{
        .texture = textures.wizard_falling,
        .sprite = Sprite{
            .name = "Wizard is Falling",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 462, .height = 190 },
        },
        .start_x = 0,
        .start_y = 0,
        .frame_width = 231,
        .frame_height = 190,
        .horizontal_shift = true,
        .num_frames = 2,
        .frame_duration = 0.1,
    };

    wizard_attacking_1 = AnimatedSprite{
        .texture = textures.wizard_attacking_1,
        .sprite = Sprite{
            .name = "Wizard is Attacking (1)",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 1848, .height = 190 },
        },
        .start_x = 0,
        .start_y = 0,
        .frame_width = 231,
        .frame_height = 190,
        .horizontal_shift = true,
        .num_frames = 8,
        .frame_duration = 0.1,
    };

    wizard_attacking_2 = AnimatedSprite{
        .texture = textures.wizard_attacking_2,
        .sprite = Sprite{
            .name = "Wizard is Attacking (2)",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 1848, .height = 190 },
        },
        .start_x = 0,
        .start_y = 0,
        .frame_width = 231,
        .frame_height = 190,
        .horizontal_shift = true,
        .num_frames = 8,
        .frame_duration = 0.1,
    };

    moving_platform = AnimatedSprite{
        .texture = textures.moving_platform,
        .sprite = Sprite{
            .name = "Moving Platform",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 320, .height = 8 },
        },
        .start_x = 0,
        .start_y = 0,
        .frame_width = 32,
        .frame_height = 8,
        .horizontal_shift = true,
        .num_frames = 10,
        .frame_duration = 0.1,
    };

    star = AnimatedSprite{
        .texture = textures.star_sheet,
        .sprite = Sprite{
            .name = "Star",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 32, .height = 32 },
        },
        .start_x = 0,
        .start_y = 0,
        .frame_width = 32,
        .frame_height = 32,
        .horizontal_shift = true,
        .num_frames = 13,
        .frame_duration = 0.2,
    };
}

pub fn deinit() void {
    rl.unloadTexture(jumper_sprite.texture);
    rl.unloadTexture(moving_platform.texture);
    rl.unloadTexture(boost_sprite.texture);
    rl.unloadTexture(falling_platform.texture);

    rl.unloadTexture(battlemage_running.texture);
    rl.unloadTexture(battlemage_jumping_full.texture);
    rl.unloadTexture(battlemage_jumping_going_down.texture);
    rl.unloadTexture(battlemage_dying.texture);
    rl.unloadTexture(battlemage_idle.texture);

    rl.unloadTexture(spawning_item.texture);
    rl.unloadTexture(square_despawning_item.texture);
    rl.unloadTexture(spike_despawning_item.texture);
    rl.unloadTexture(small_lighting_0.texture);
    rl.unloadTexture(scratch.texture);
    rl.unloadTexture(entity_spawn.texture);
    rl.unloadTexture(woosh.texture);
    rl.unloadTexture(slot_cleanning.texture);

    rl.unloadTexture(demon_idle2.texture);
    rl.unloadTexture(wizard_jumping.texture);
    rl.unloadTexture(wizard_falling.texture);
    rl.unloadTexture(wizard_attacking_1.texture);
    rl.unloadTexture(wizard_attacking_2.texture);

    rl.unloadTexture(star.texture);
}

pub const AnimatedSprite = struct {
    texture: rl.Texture2D,
    sprite: Sprite,
    start_x: f32,
    start_y: f32,
    frame_width: f32,
    frame_height: f32,
    horizontal_shift: bool,
    num_frames: usize,
    current_frame: usize = 0,
    frame_duration: f32, // seconds
    time_acc: f32 = 0.0,
    x: usize = 0,
    y: usize = 0,
    isRunning: bool = false,
    mirror: bool = false,
    loop: usize = 0,

    pub fn setPos(self: *AnimatedSprite, x: usize, y: usize) void {
        self.x = x;
        self.y = y;
    }

    pub fn resetPos(self: *AnimatedSprite) void {
        self.x = 0;
        self.y = 0;
    }

    pub fn update(self: *AnimatedSprite, delta_time: f32, loop_limit: usize) void {
        if (self.loop >= loop_limit) {
            self.isRunning = false;
            self.loop = 0;
            self.current_frame = 0;
            self.resetPos();
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

    pub fn applyMirror(self: *AnimatedSprite, mirror: bool) void {
        self.mirror = mirror;
    }

    pub fn draw(self: AnimatedSprite, position: rl.Vector2, scale: f32, rotation: f32, alpha: f32, x: usize, y: usize) void {
        var x_apply: f32 = 0;
        var y_apply: f32 = 0;

        if (self.isRunning and x == self.x and y == self.y) {
            if (self.horizontal_shift) {
                x_apply = @as(f32, @floatFromInt(self.current_frame)) * self.frame_width;
            } else {
                y_apply = @as(f32, @floatFromInt(self.current_frame)) * self.frame_height;
            }
        }

        const src = rl.Rectangle{
            .x = self.start_x + x_apply,
            .y = self.start_y + y_apply,
            .width = if (self.mirror) -1 * self.frame_width else self.frame_width,
            .height = self.frame_height,
        };

        const dest = rl.Rectangle{
            .x = position.x,
            .y = position.y,
            .width = self.frame_width * scale,
            .height = self.frame_height * scale,
        };

        const origin = rl.Vector2{
            .x = 0,
            .y = 0,
        };

        //Reminder
        //.x = self.start_x + x_apply + self.frame_width / 2,
        //.y = self.start_y + y_apply + self.frame_height / 2,

        const color: rl.Color = .white;

        const tint: rl.Color = rl.Color.alpha(color, alpha);

        rl.drawTexturePro(self.texture, src, dest, origin, rotation, tint);
    }
};
