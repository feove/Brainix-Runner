const scene = @import("../render/scene.zig");
const Grid = @import("grid.zig").Grid;
const rl = @import("raylib");
const textures = @import("../render/textures.zig");
const PhysicObject = @import("terrain_object.zig").PhysicObject;
const AutoMovements = @import("terrain_object.zig").AutoMovements;
const CellType = @import("grid.zig").CellType;
const CellAround = @import("grid.zig").CellAround;
const Level = @import("level/events.zig").Level;
const LevelStatement = @import("level/events.zig").LevelStatement;
const event = @import("level/events.zig");
const print = @import("std").debug.print;
const Object = @import("terrain_object.zig").Object;

pub var elf: Elf = undefined;
pub var initGrid: Grid = undefined;
pub var time_divisor: f32 = 1.0;

const ELF_DEFAULT_SPEED: f32 = 170.0;
const SLOW_MOTION_SPEED: f32 = 50.0;

var RESPAWN_POINT: rl.Vector2 = .init(80, 443);

pub const PlayerState = enum {
    ALIVE,
    RESPAWNING,
    DEAD,
};

pub fn initElf() void {
    const tex = textures.elf;
    const scale_factor: f32 = 0.1;
    initGrid = Grid.selfReturn();

    elf = Elf{
        .x = RESPAWN_POINT.x,
        .y = RESPAWN_POINT.y,
        .width = @as(f32, @floatFromInt(tex.width)) * scale_factor,
        .height = @as(f32, @floatFromInt(tex.height)) * scale_factor,
        .speed = ELF_DEFAULT_SPEED,
        .physics = PhysicObject{ .mass = 20 },
        .isOnGround = false,
        .hitBox = HitBox{},
        .repulsive_force = 500.0,
    };
}

const gravity: f32 = 1500.0;
const jump_force: f32 = -800.0;
const boost_force: f32 = 0.1;

pub const Elf = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    speed: f32,
    physics: PhysicObject,
    canTrigger: bool = true,
    isOnGround: bool,
    hitBox: HitBox,
    repulsive_force: f32,
    jump_force: f32 = jump_force,
    boost_force: f32 = boost_force,
    state: PlayerState = PlayerState.RESPAWNING,

    pub fn respawn() void {
        elf.x = RESPAWN_POINT.x;
        elf.y = RESPAWN_POINT.y;
        elf.physics.auto_moving = AutoMovements.RIGHT;
    }

    pub fn selfReturn() Elf {
        return elf;
    }

    pub fn setDefaultSpeed(self: *Elf) void {
        self.speed = ELF_DEFAULT_SPEED;
    }

    pub fn setSlowMotiontSpeed(self: *Elf) void {
        self.speed = SLOW_MOTION_SPEED;
    }

    pub fn setSpeedBoost(self: *Elf) void {
        self.speed = 1500;
    }

    pub fn setState(state: PlayerState) void {
        elf.state = state;
    }

    pub fn enableTriggers() void {
        elf.canTrigger = true;
    }

    pub fn controller(self: *Elf) void {
        const dt: f32 = rl.getFrameTime() / time_divisor;
        var grid: Grid = Grid.selfReturn();

        // if (elf.x != 80 or elf.y != 443) {
        //     return;
        // }

        // print("x : {d} ||y : {d}\n\n", .{ initGrid.cells[6][0].x + 15, initGrid.cells[6][0].y });

        //print("{d}\n", .{self.time_divisor});
        // print("{}\n", .{Level.getLevelStatement()});

        if (rl.isKeyPressed(rl.KeyboardKey.r) or Level.getLevelStatement() == .STARTING) {
            respawn();
        }

        self.isOnGround = self.hitBox.bottomLeggs == CellType.GROUND;

        if (!self.isOnGround and Level.getLevelStatement() != .STARTING) {
            self.physics.velocity_y += gravity * dt;
        } else {
            self.physics.velocity_y = 0;
            self.physics.velocity_x = 0;
        }

        Object.padAction(&elf);

        Object.upPadAction(&elf);

        Object.spikeAction(&elf);

        Object.boostAction(&elf);

        //HitBox.antiSoftLock(&elf);

        var x_movement: f32 = 0;
        if (rl.isKeyDown(rl.KeyboardKey.right) or self.physics.auto_moving == AutoMovements.RIGHT) {
            x_movement += self.speed * dt + self.physics.velocity_x;
        }
        if (rl.isKeyDown(rl.KeyboardKey.left) or self.physics.auto_moving == AutoMovements.LEFT) {
            x_movement -= self.speed * dt - self.physics.velocity_x;
        }

        self.elfMovement(x_movement, self.physics.velocity_y * dt);

        updatePlayerStatement();

        self.hitBox.hitBoxUpdate(&grid, &elf);

        self.canTrigger = self.hitBox.middleLeggs != CellType.AIR;

        //HitBox.hitBoxDrawing(self.x, self.y, self.width, self.height);
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

        //If Void Falling or Ground Issue
        if (self.y + self.height >= grid.y + grid.height - 5 or self.y + self.height >= Grid.getGroundPos().y + 15) {
            print("Elf under Ground at x : {d} y : {d}\n", .{ self.x, self.y });
            Elf.respawn();
            return;
        }

        //print("DEBUG 1 : x : {d} ||y : {d}\n\n", .{ elf.x, elf.y });
        if (canMoveHorizontal(self, x)) {
            if (((self.hitBox.rightBody == CellType.GROUND or self.hitBox.rightLeggs == CellType.GROUND) and x > 0) or self.x + self.width >= grid.x + grid.width - 10) {
                self.x -= self.repulsive_force * dt;

                self.physics.auto_moving = AutoMovements.LEFT;
            } else if (((self.hitBox.leftBody == CellType.GROUND or self.hitBox.leftLeggs == CellType.GROUND) and x < 0) or self.x - 10 <= grid.x) {
                self.x += self.repulsive_force * dt;
                self.physics.auto_moving = AutoMovements.RIGHT;
            } else {
                self.x += x;
            }
        }

        //print("DEBUG 2 : x : {d} ||y : {d}\n\n", .{ elf.x, elf.y });
        if (canMoveVertical(self, y)) {
            if (self.y < grid.y) {
                self.y += 5;
                self.physics.velocity_y += self.repulsive_force;
                return;
            }

            if ((self.hitBox.topBody == CellType.GROUND and y < 0)) {
                self.physics.velocity_y += self.repulsive_force;
            } else if (self.hitBox.bottomLeggs == CellType.GROUND and y > 0) {
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

    fn updatePlayerStatement() void {
        if (elf.state == PlayerState.DEAD) {
            Grid.reset();
            Level.reset();

            elf.state = PlayerState.ALIVE;

            event.level.events[event.level.i_event].already_triggered = false;
        }
    }

    pub fn playerInDoor() bool {
        //print("{any}\n", .{elf.hitBox.middleBody});

        if (elf.hitBox.middleBody == .DOOR or elf.hitBox.middleLeggs == .DOOR) {
            return true;
        }
        return false;
    }

    pub fn drawElf(self: *Elf) void {
        rl.drawTextureEx(textures.elf, rl.Vector2.init(self.x, self.y), 0, 0.1, .white);
        //const p: f32 = Grid.selfReturn().cells[0][0].padding;
        //rl.drawRectangleRec(.init(elf.x + 2 * p, elf.y + p + elf.height / 4, elf.width - 4 * p, p), .orange);

        //rl.drawRectangleRec(.init(elf.x + 3 * p, elf.y + elf.height / 2, elf.width - 6 * p, p), .orange);

        //rl.drawRectangleRec(.init(elf.x + 2 * p, elf.y + elf.height - elf.height / 3 + p, elf.width - 4 * p, p), .yellow);
    }
};

pub const HitBox = struct {
    topBody: CellType = CellType.EMPTY,
    rightBody: CellType = CellType.EMPTY,
    leftBody: CellType = CellType.EMPTY,
    middleBody: CellType = CellType.EMPTY,

    kneesLeggs: CellType = CellType.EMPTY,
    middleLeggs: CellType = CellType.EMPTY,
    leftLeggs: CellType = CellType.EMPTY,
    rightLeggs: CellType = CellType.EMPTY,
    bottomLeggs: CellType = CellType.EMPTY,

    pub fn hitBoxDrawing(x: f32, y: f32, width: f32, height: f32) void {
        const rectangle: rl.Rectangle = rl.Rectangle.init(x, y, width, height);
        rl.drawRectangleLinesEx(rectangle, 5, .red);
    }

    pub fn i_and_j_assign(grid: *Grid, x: f32, y: f32, i: *usize, j: *usize) void {
        i.* = @intFromFloat((x - grid.x) / grid.cells[0][0].width);
        j.* = @intFromFloat((y - grid.y) / grid.cells[0][0].height);
    }

    pub fn isInCollision(sides: []const CellType, celltype: CellType) bool {
        for (sides) |side| {
            if (side == celltype) return true;
        }
        return false;
    }

    pub fn hitBoxUpdate(self: *HitBox, grid: *Grid, player: *Elf) void {
        var i: usize = undefined;
        var j: usize = undefined;
        const p: f32 = grid.cells[0][0].padding;

        const x: f32 = player.x;
        const y: f32 = player.y;
        const width: f32 = player.width;
        const height = player.height;

        self.topBody = horizontal_detection(grid, x, y, width, p, &i, &j);

        self.rightBody = body_vertical_detection(grid, x + width, y, height, p, &i, &j);

        self.rightLeggs = leggs_vertical_detection(grid, x + width, y + height - p, height, p, &i, &j);

        self.middleBody = horizontal_detection(grid, x + 2 * p, y + p + height / 4, width - 4 * p, p, &i, &j);

        self.kneesLeggs = horizontal_detection(grid, x + 2 * p, y + 2 * p, width - 4 * p, p, &i, &j);

        self.middleLeggs = horizontal_detection(grid, x + 3 * p, y + height / 2, width - 6 * p, p, &i, &j);

        self.leftBody = body_vertical_detection(grid, x - p, y, height, p, &i, &j);

        self.leftLeggs = leggs_vertical_detection(grid, x - p, y + height - p, height, p, &i, &j);

        self.bottomLeggs = horizontal_detection(grid, x, y + height, width, p, &i, &j);
    }

    fn antiSoftLock(self: *Elf) void {
        const htb: HitBox = self.hitBox;

        //print("\n{}\n", .{htb.kneesLeggs});

        if (htb.kneesLeggs == .GROUND or htb.middleBody == .GROUND) {
            Elf.respawn();
        }
    }

    fn leggs_vertical_detection(grid: *Grid, x: f32, y: f32, len: f32, inc: f32, i: *usize, j: *usize) CellType {
        var index: f32 = 0;

        i_and_j_assign(grid, x, y + index, i, j);
        var j_prev = j.*;

        while (index < len) {
            j_prev = j.*;
            i_and_j_assign(grid, x, y - index, i, j);

            if (j.* < j_prev) {
                break;
            }

            const currentCell = grid.cells[j.*][i.*].object.type;

            if (currentCell != CellType.AIR) {
                return currentCell;
            }
            //rl.drawRectangleRec(.init(x, y - index, 5, 3), .red);
            index += inc;
        }
        return CellType.AIR;
    }

    fn body_vertical_detection(grid: *Grid, x: f32, y: f32, len: f32, inc: f32, i: *usize, j: *usize) CellType {
        var index: f32 = 0;

        i_and_j_assign(grid, x, y + index, i, j);
        var j_prev = j.*;

        while (index < len) {
            j_prev = j.*;
            i_and_j_assign(grid, x, y + index, i, j);

            if (j.* > j_prev) {
                break;
            }

            const currentCell = grid.cells[j.*][i.*].object.type;

            if (currentCell != CellType.AIR) {
                return currentCell;
            }
            //rl.drawRectangleRec(.init(x, y + index, 5, 3), .red);
            index += inc;
        }
        return CellType.AIR;
    }

    fn horizontal_detection(grid: *Grid, x: f32, y: f32, len: f32, inc: f32, i: *usize, j: *usize) CellType {
        i_and_j_assign(grid, x, y, i, j);
        const left = grid.cells[j.*][i.*].object.type;

        i_and_j_assign(grid, x + len, y, i, j);
        const right = grid.cells[j.*][i.*].object.type;

        if (left == CellType.GROUND or right == CellType.GROUND) {
            return CellType.GROUND;
        }

        var p: f32 = 0;
        while (p < len) {
            i_and_j_assign(grid, x + p, y, i, j);
            const currentCell = grid.cells[j.*][i.*].object.type;
            if (currentCell != CellType.AIR) {
                return currentCell;
            }
            //rl.drawRectangleRec(.init(x + p, y, 5, 3), .red);
            p += inc;
        }
        return CellType.AIR;
    }
};
