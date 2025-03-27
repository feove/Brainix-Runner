const scene = @import("../render/scene.zig");
const rl = @import("raylib");

pub var elf: Elf = Elf{
    .x = 400,
    .y = 300,
    .speed = 2.0,
};

const default_distance: f32 = 1.0;
var default_time: f64 = 0.005;

const Elf = struct {
    x: f32,
    y: f32,
    speed: f32,

    pub fn controller(self: *Elf) void {
        if (rl.isKeyPressed(rl.KeyboardKey.down) or rl.isKeyDown(rl.KeyboardKey.down)) {
            playerMovement(self, 0, default_distance, self.speed);
        }
        if (rl.isKeyDown(rl.KeyboardKey.up)) {
            playerMovement(self, 0, -default_distance, self.speed);
        }
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            playerMovement(self, default_distance, 0, self.speed);
        }
        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            playerMovement(self, -default_distance, 0, self.speed);
        }
    }

    fn playerMovement(self: *Elf, x: f32, y: f32, speed: f32) void {
        self.x += x * speed;
        self.y += y * speed;
        const time = default_time / speed;
        rl.waitTime(time);
    }
};
