const scene = @import("../render/scene.zig");
const Grid = @import("grid.zig").Grid;
const rl = @import("raylib");
const textures = @import("../render/textures.zig");
const PhysicObject = @import("terrain_object.zig").PhysicObject;
const CellType = @import("grid.zig").CellType;
const CellAround = @import("grid.zig").CellAround;
const print = @import("std").debug.print;

pub var elf: Elf = undefined;

pub fn initElf() void {
    const tex = textures.elf;
    const scale_factor: f32 = 0.1;

    elf = Elf{
        .x = 400,
        .y = 300,
        .width = @as(f32, @floatFromInt(tex.width)) * scale_factor,
        .height = @as(f32, @floatFromInt(tex.height)) * scale_factor,
        .speed = 200.0,
        .physics = PhysicObject{ .mass = 20 },
        .isOnGround = false,
        .hitBox = HitBox{},
    };
}

const gravity: f32 = 1500.0;
const jump_force: f32 = -500.0;

pub const Elf = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    speed: f32,
    physics: PhysicObject,
    isOnGround: bool,
    hitBox: HitBox,

    pub fn selfReturn() Elf {
        return elf;
    }

    pub fn controller(self: *Elf) void {
        const dt: f32 = rl.getFrameTime();
        var grid: Grid = Grid.selfReturn();

        self.isOnGround = self.hitBox.bottomCellType == CellType.GROUND;

        if (!self.isOnGround) {
            self.physics.velocity += gravity * dt;
        } else {
            self.physics.velocity = 0;
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

        self.hitBox.hitBoxUpdate(&grid, &elf);
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

        if (new_y + self.height > grid.y + grid.height - ground_tolerance) {
            self.isOnGround = true;
            self.physics.velocity = 0;
            return false;
        }

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

const HitBox = struct {
    topCellType: CellType = CellType.EMPTY,
    bottomCellType: CellType = CellType.EMPTY,
    leftCellType: CellType = CellType.EMPTY,
    rightCellType: CellType = CellType.EMPTY,

    pub fn hitBoxDrawing(x: f32, y: f32, width: f32, height: f32) void {
        const rectangle: rl.Rectangle = rl.Rectangle.init(x, y, width, height);

        rl.drawRectangleLinesEx(rectangle, 4.0, .red);
    }

    fn i_and_j_assign(grid: *Grid, x: f32, y: f32, i: *usize, j: *usize) void {
        i.* = @intFromFloat((x - grid.x) / grid.cells[0][0].width);
        j.* = @intFromFloat((y - grid.y) / grid.cells[0][0].height);
    }

    pub fn hitBoxUpdate(self: *HitBox, grid: *Grid, player: *Elf) void {
        var i: usize = undefined;
        var j: usize = undefined;

        i_and_j_assign(grid, player.x + player.width, player.y + player.height, &i, &j);
        self.bottomCellType = grid.cells[j][i].type;
    }
};
