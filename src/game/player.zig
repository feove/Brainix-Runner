const scene = @import("../render/scene.zig");
const Grid = @import("grid.zig").Grid;
const rl = @import("raylib");
const textures = @import("../render/textures.zig");
const print = @import("std").debug.print;

pub var elf: Elf = undefined;

pub fn initElf() void {
    elf = Elf{
        .x = 400,
        .y = 300,
        .width = Grid.selfReturn().cells[0][0].width,
        .height = Grid.selfReturn().cells[0][0].height * 2,
        .speed = 2.0,
    };
}

const default_distance: f32 = 1.0;
var default_time: f64 = 0.005;

pub const Elf = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    speed: f32,

    pub fn controller(self: *Elf) void {
        if (rl.isKeyPressed(rl.KeyboardKey.down) or rl.isKeyDown(rl.KeyboardKey.down)) {
            elfMovement(self, 0, default_distance, self.speed);
        }
        if (rl.isKeyDown(rl.KeyboardKey.up)) {
            elfMovement(self, 0, -default_distance, self.speed);
        }
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            elfMovement(self, default_distance, 0, self.speed);
        }
        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            elfMovement(self, -default_distance, 0, self.speed);
        }
    }

    fn elfMovement(self: *Elf, x: f32, y: f32, speed: f32) void {
        const x_increment = x * speed;
        const y_increment = y * speed;

        if (elfInGrid(self, x_increment, y_increment)) {
            self.x += x_increment;
            self.y += y_increment;
            const time = default_time / speed;
            rl.waitTime(time);
        }
    }

    fn elfInGrid(self: *Elf, x_increment: f32, y_increment: f32) bool {
        const grid: Grid = Grid.selfReturn();

        const inLeftTopSides = self.x > grid.x - x_increment and self.y > grid.y - y_increment;
        const inRightBottomSides = self.x + self.width < grid.x + grid.width - x_increment and self.y + self.height < grid.y + grid.height - y_increment;

        return inLeftTopSides and inRightBottomSides;
    }
};
