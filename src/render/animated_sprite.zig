const rl = @import("raylib");
const Sprite = @import("textures.zig").Sprite;
const textures = @import("textures.zig");

pub var jumper_sprite: AnimatedSprite = undefined;
pub var boost_sprite: AnimatedSprite = undefined;
pub var battle_mage: AnimatedSprite = undefined;

pub fn init() !void {
    jumper_sprite = AnimatedSprite{
        .texture = textures.pad,
        .sprite = Sprite{
            .name = "Pad",
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = 24, .height = 16 },
        },
        .start_x = 0,
        .start_y = 0,
        .frame_width = 24,
        .frame_height = 16,
        .horizontal_shift = true,
        .num_frames = 8,
        .frame_duration = 0.06,
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
    battle_mage = AnimatedSprite{
        .texture = textures.battlemage,
        .sprite = Sprite{
            .name = "Battle Mage",
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
    loop: usize = 0,

    pub fn setPos(self: *AnimatedSprite, x: usize, y: usize) void {
        self.x = x;
        self.y = y;
    }

    pub fn update(self: *AnimatedSprite, delta_time: f32, loop_limit: usize) void {
        if (self.loop >= loop_limit) {
            self.isRunning = false;
            self.loop = 0;
            self.current_frame = 0;
            return;
        }

        self.time_acc += delta_time;
        if (self.time_acc >= self.frame_duration) {
            self.time_acc -= self.frame_duration;
            self.current_frame = (self.current_frame + 1) % self.num_frames;
        }

        if (self.isRunning and self.current_frame == self.num_frames - 1) {
            self.loop += 1;
            self.current_frame = 0;
        }
    }

    pub fn draw(self: AnimatedSprite, position: rl.Vector2, scale: f32, rotation: f32, alpha: u8, x: usize, y: usize) void {
        var x_apply: f32 = @as(f32, @floatFromInt(self.current_frame)) * self.frame_width;
        var y_apply: f32 = @as(f32, @floatFromInt(self.current_frame)) * self.frame_height;

        if (self.isRunning and x == self.x and y == self.y) {
            if (!self.horizontal_shift) {
                x_apply = 0;
            } else {
                y_apply = 0;
            }
        }
        const src = rl.Rectangle{
            .x = self.start_x + x_apply,
            .y = self.start_y + y_apply,
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

        rl.drawTexturePro(self.texture, src, dest, origin, rotation, tint);
    }
};
