const rl = @import("raylib");

pub var elf: Elf = Elf{ .x = 400, .y = 300 };

const Elf = struct {
    x: f32,
    y: f32,
    pub fn controller(self: *Elf) void {
        if (rl.isKeyPressed(rl.KeyboardKey.down) or rl.isKeyDown(rl.KeyboardKey.down)) {
            self.y += 1;
            rl.waitTime(0.005);
        }
        if (rl.isKeyDown(rl.KeyboardKey.up)) {
            self.y -= 1;
            rl.waitTime(0.005);
        }
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            self.x += 1;
            rl.waitTime(0.005);
        }
        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            self.x -= 1;
            rl.waitTime(0.005);
        }
    }
};
