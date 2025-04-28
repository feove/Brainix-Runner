const std = @import("std");
const rl = @import("raylib");
const CellType = @import("grid.zig").CellType;
const Elf = @import("player.zig").Elf;
const HitBox = @import("player.zig").HitBox;
const Grid = @import("grid.zig").Grid;
const PlayerState = @import("player.zig").PlayerState;
const event = @import("level/events.zig");

pub const AutoMovements = enum {
    RIGHT,
    LEFT,
};

pub const PhysicObject = struct {
    mass: f32,
    velocity_y: f32 = 0,
    velocity_x: f32 = 0,
    acceleration: f32 = 0,
    auto_moving: AutoMovements = AutoMovements.RIGHT,
    jump: bool = false,

    const gravity: f32 = 9.8;

    pub fn applyPhysics(self: *PhysicObject, dt: f32) void {
        self.acceleration = self.mass * gravity;
        self.velocity_y += self.acceleration * dt;
    }

    pub fn applyJump(self: *PhysicObject, jump_force: f32) void {
        self.velocity_y = jump_force;

        const horizontal_boost: f32 = 0.05;

        self.velocity_x = switch (self.auto_moving) {
            AutoMovements.RIGHT => horizontal_boost,
            AutoMovements.LEFT => -horizontal_boost,
        };

        self.jump = false;
    }
};

pub const AroundConfig = struct {
    model: [3][3]CellType = .{
        .{ .ANY, .ANY, .ANY },
        .{ .ANY, .ANY, .ANY },
        .{ .ANY, .ANY, .ANY },
    },

    fn cellAssign(cell: CellType) *AroundConfig {
        var aroundConfig: AroundConfig = AroundConfig{};
        var model: [3][3]CellType = aroundConfig.model;

        switch (cell) {
            .PAD => {
                model[2][1] = .GROUND;
            },
            else => {},
        }
        aroundConfig.model = model;

        return &aroundConfig;
    }

    //fn currentCellConfig(i: usize, j: usize) AroundConfig {}

    pub fn cellAroundchecking(cell: CellType) bool {
        const aroundConfig: AroundConfig = cellAssign(cell).*;
        _ = aroundConfig;

        return true;
    }
};

pub const Object = struct {
    x: usize = 0,
    y: usize = 0,
    type: CellType = CellType.EMPTY,
    canPlayerTake: bool = false,
    //aroundConfig: AroundConfig,

    pub fn set(self: *Object, grid: *Grid) void {
        grid.cells[self.y][self.x].object.type = self.type;
    }

    pub fn remove(self: *Object, grid: *Grid) void {
        grid.cells[self.y][self.x].object.type = CellType.AIR;
    }

    pub fn add(self: *[]Object, cell: CellType) void {
        for (0..self.len) |i| {
            if (self.*[i].type == CellType.EMPTY) {
                self.*[i].type = cell;
                self.*[i].canPlayerTake = true;
                return;
            }
        }
    }

    //Need PAD only over ground condition
    pub fn padAction(elf: *Elf, respawn_point: rl.Vector2) void {
        const PadDetectionSides = [_]CellType{
            elf.hitBox.middleLeggs,
        };

        //(rl.isKeyPressed(rl.KeyboardKey.space)) or
        if (HitBox.isInCollision(PadDetectionSides[0..], CellType.PAD)) {
            if (elf.isOnGround) {
                elf.physics.applyJump(elf.jump_force);
                elf.isOnGround = false;
            }
        }
        _ = respawn_point;
    }

    pub fn spikeAction(elf: *Elf, respawn_point: rl.Vector2) void {
        const SpikeDetectionSides = [_]CellType{
            elf.hitBox.middleLeggs,
            elf.hitBox.middleBody,
        };

        if (HitBox.isInCollision(SpikeDetectionSides[0..], CellType.SPIKE)) {
            elf.x = respawn_point.x;
            elf.y = respawn_point.y;
            elf.physics.auto_moving = AutoMovements.RIGHT;
            elf.state = PlayerState.DEAD;
            event.playerEventstatus = event.PlayerEventStatus.IDLE_AREA;
        }
    }
};
