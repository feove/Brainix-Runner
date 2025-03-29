const scene = @import("../render/scene.zig");
const Grid = @import("grid.zig").Grid;
const rl = @import("raylib");
const textures = @import("../render/textures.zig");
const PhysicObject = @import("terrain_object.zig").PhysicObject;
const print = @import("std").debug.print;

pub var elf: Elf = undefined;

pub fn initElf() void {
    elf = Elf{
        .x = 400,
        .y = 300,
        .width = Grid.selfReturn().cells[0][0].width,
        .height = Grid.selfReturn().cells[0][0].height * 2,
        .speed = 200.0, // Movement speed
        .physics = PhysicObject{ .mass = 10, .velocity = 0 },
        .isOnGround = false,
    };
}

// Physics Constants
const gravity: f32 = 1000.0; // Increased for a more natural feel
const jump_force: f32 = -400.0; // More negative = stronger jump

pub const Elf = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    speed: f32,
    physics: PhysicObject,
    isOnGround: bool,

    pub fn controller(self: *Elf) void {
        const dt: f32 = rl.getFrameTime();

        if (!self.isOnGround) {
            self.physics.velocity += gravity * dt;
        }

        if (rl.isKeyPressed(rl.KeyboardKey.space) and self.isOnGround) {
            self.physics.velocity = jump_force;
            self.isOnGround = false;
        }

        var x_movement: f32 = 0;
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            x_movement += self.speed * dt;
        }
        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            x_movement -= self.speed * dt;
        }

        self.elfMovement(x_movement, self.physics.velocity * dt);
    }

    fn canMoveHorizontal(self: *Elf, x_offset: f32) bool {
        const grid: Grid = Grid.selfReturn();

        const new_x = self.x + x_offset;
        return new_x >= grid.x and new_x + self.width <= grid.x + grid.width;
    }
    fn canMoveVertical(self: *Elf, y_offset: f32) bool {
        const grid: Grid = Grid.selfReturn();

        const new_y = self.y + y_offset;

        const ground_tolerance: f32 = 0.1;

        if (new_y + self.height >= grid.y + grid.height - ground_tolerance) {
            self.isOnGround = true;
            self.physics.velocity = 0;
            return false;
        }

        self.isOnGround = false;
        return true;
    }
    fn elfMovement(self: *Elf, x: f32, y: f32) void {
        if (canMoveHorizontal(self, x)) {
            self.x += x;
        }

        if (canMoveVertical(self, y)) {
            self.y += y;
        }
    }

    fn elfInGrid(self: *Elf, x_offset: f32, y_offset: f32) bool {
        const grid: Grid = Grid.selfReturn();

        const inLeftRightBoundaries = self.x + x_offset >= grid.x and
            self.x + self.width + x_offset <= grid.x + grid.width;

        const inVerticalBoundaries = self.y + self.height + y_offset <= grid.y + grid.height;

        return inLeftRightBoundaries and inVerticalBoundaries;
    }

    pub fn drawElf(self: *Elf) void {
        rl.drawTextureEx(textures.elf, rl.Vector2.init(self.x, self.y), 0, 0.1, .white);
    }
};
