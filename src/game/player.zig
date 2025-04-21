const scene = @import("../render/scene.zig");
const Grid = @import("grid.zig").Grid;
const rl = @import("raylib");
const textures = @import("../render/textures.zig");
const PhysicObject = @import("terrain_object.zig").PhysicObject;
const AutoMovements = @import("terrain_object.zig").AutoMovements;
const CellType = @import("grid.zig").CellType;
const CellAround = @import("grid.zig").CellAround;
const print = @import("std").debug.print;

pub var elf: Elf = undefined;
var initGrid: Grid = undefined;

pub fn initElf() void {
    const tex = textures.elf;
    const scale_factor: f32 = 0.1;
    initGrid = Grid.selfReturn();

    elf = Elf{
        .x = initGrid.x,
        .y = initGrid.cells[initGrid.nb_cols - 4][initGrid.nb_rows - 1].y,
        .width = @as(f32, @floatFromInt(tex.width)) * scale_factor,
        .height = @as(f32, @floatFromInt(tex.height)) * scale_factor,
        .speed = 200.0,
        .physics = PhysicObject{ .mass = 20 },
        .isOnGround = false,
        .hitBox = HitBox{},
        .repulsive_force = 500.0,
    };
}

const gravity: f32 = 1500.0;
const jump_force: f32 = -800.0;

pub const Elf = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    speed: f32,
    physics: PhysicObject,
    isOnGround: bool,
    hitBox: HitBox,
    repulsive_force: f32,

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

        var sides = [_]CellType{elf.hitBox.kneesCellType};

        if ((rl.isKeyPressed(rl.KeyboardKey.space) or HitBox.isInCollision(sides[0..], CellType.PAD))) {
            if (self.isOnGround) {
                self.physics.applyJump(jump_force);
                self.isOnGround = false;
            }
        }

        var x_movement: f32 = 0;
        if (rl.isKeyDown(rl.KeyboardKey.right) or self.physics.auto_moving == AutoMovements.RIGHT) {
            x_movement += self.speed * dt;
        }
        if (rl.isKeyDown(rl.KeyboardKey.left) or self.physics.auto_moving == AutoMovements.LEFT) {
            x_movement -= self.speed * dt;
        }

        self.elfMovement(x_movement, self.physics.velocity * dt);

        self.hitBox.hitBoxUpdate(&grid, &elf);

        HitBox.hitBoxDrawing(self.x, self.y, self.width, self.height);
    }

    fn canMoveHorizontal(self: *Elf, x_offset: f32) bool {
        const grid: Grid = Grid.selfReturn();

        const new_x = self.x + x_offset;
        return new_x >= grid.x and new_x + self.width <= grid.x + grid.width;
    }

    fn canMoveVertical(self: *Elf, y_offset: f32) bool {
        const grid: Grid = Grid.selfReturn();

        const new_y = self.y + y_offset;

        const ground_tolerance: f32 = 20;

        if (new_y + self.height >= grid.y + grid.height + ground_tolerance) {
            return false;
        }
        self.isOnGround = true;

        return true;
    }

    fn elfMovement(self: *Elf, x: f32, y: f32) void {
        const dt: f32 = rl.getFrameTime();
        const grid = Grid.selfReturn();

        if (self.y + self.height >= grid.y + grid.height - 5) {
            self.x = initGrid.x;
            self.y = initGrid.cells[initGrid.nb_cols - 4][initGrid.nb_rows - 1].y;
            self.physics.auto_moving = AutoMovements.RIGHT;
            return;
        }

        if (canMoveHorizontal(self, x)) {
            if ((self.hitBox.rightCellType == CellType.GROUND and x > 0) or self.x + self.width >= grid.x + grid.width - 10) {
                self.x -= self.repulsive_force * dt; //Useless
                self.physics.auto_moving = AutoMovements.LEFT;
            } else if ((self.hitBox.leftCellType == CellType.GROUND and x < 0) or self.x - 10 <= grid.x) {
                self.x += self.repulsive_force * dt; //Useless
                self.physics.auto_moving = AutoMovements.RIGHT;
            } else {
                self.x += x;
            }
        }

        if (canMoveVertical(self, y)) {
            if (self.y <= grid.y) {
                self.y += 5;
                self.physics.velocity += self.repulsive_force;
                return;
            }

            if ((self.hitBox.topCellType == CellType.GROUND and y < 0)) {
                self.physics.velocity += self.repulsive_force;
            } else if (self.hitBox.bottomCellType == CellType.GROUND and y > 0) {
                self.y -= self.repulsive_force * 0.4 * dt;
            } else {
                self.y += y;
            }
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
    kneesCellType: CellType = CellType.EMPTY,

    pub fn hitBoxDrawing(x: f32, y: f32, width: f32, height: f32) void {
        const rectangle: rl.Rectangle = rl.Rectangle.init(x, y, width, height);
        rl.drawRectangleLinesEx(rectangle, 5, .red);
    }

    fn i_and_j_assign(grid: *Grid, x: f32, y: f32, i: *usize, j: *usize) void {
        i.* = @intFromFloat((x - grid.x) / grid.cells[0][0].width);
        j.* = @intFromFloat((y - grid.y) / grid.cells[0][0].height);
    }

    fn isInCollision(sides: []const CellType, celltype: CellType) bool {
        for (sides) |side| {
            if (side == celltype) return true;
        }
        return false;
    }

    pub fn hitBoxUpdate(self: *HitBox, grid: *Grid, player: *Elf) void {
        var i: usize = undefined;
        var j: usize = undefined;

        print("{any}\n", .{self.kneesCellType});

        self.bottomCellType = cellDetection(
            grid,
            player.x,
            player.y + player.height,
            player.x + player.width,
            3,
            0,
            1,
            player.width,
            &i,
            &j,
        );

        self.topCellType = cellDetection(
            grid,
            player.x,
            player.y,
            player.x + player.width,
            3,
            0,
            1,
            player.width,
            &i,
            &j,
        );

        self.rightCellType = cellDetection(
            grid,
            player.x + player.width,
            player.y,
            player.y + player.height,
            0,
            3,
            player.height,
            1,
            &i,
            &j,
        );

        self.leftCellType = cellDetection(
            grid,
            player.x,
            player.y,
            player.y + player.height,
            0,
            3,
            player.height,
            1,
            &i,
            &j,
        );

        self.kneesCellType = cellDetection(
            grid,
            player.x + 15,
            player.y + player.height - 10,
            player.x + player.width - 15,
            3,
            0,
            1,
            player.width,
            &i,
            &j,
        );
    }

    fn cellDetection(grid: *Grid, x: f32, y: f32, length: f32, incx: f32, incy: f32, xrst: f32, yrst: f32, i: *usize, j: *usize) CellType {
        var currentCell = CellType.AIR;
        var xp = x;
        var yp = y;

        while (xp * xrst < length or yp * yrst < length) {
            i_and_j_assign(grid, xp, yp, i, j);

            currentCell = grid.cells[j.*][i.*].type;

            if (currentCell != CellType.AIR) {
                return currentCell;
            }

            xp += incx;
            yp += incy;
        }

        return CellType.AIR;
    }
};
