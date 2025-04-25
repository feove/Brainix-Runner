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
    velocity: f32 = 0,
    acceleration: f32 = 0,
    auto_moving: AutoMovements = AutoMovements.RIGHT,
    jump: bool = false,

    const gravity: f32 = 9.8;

    pub fn applyPhysics(self: *PhysicObject, dt: f32) void {
        self.acceleration = self.mass * gravity;
        self.velocity += self.acceleration * dt;
    }

    pub fn applyJump(self: *PhysicObject, jump_force: f32) void {
        self.velocity = jump_force;
        self.jump = false;
    }
};

pub const Object = struct {
    x: usize = 0,
    y: usize = 0,
    type: CellType = CellType.EMPTY,

    pub fn set(self: *Object, grid: *Grid) void {
        grid.cells[self.y][self.x].type = self.type;
    }

    pub fn remove(self: *Object, grid: *Grid) void {
        grid.cells[self.y][self.x].type = CellType.AIR;
    }

    //Need PAD only over ground condition
    pub fn padAction(elf: *Elf, respawn_point: rl.Vector2) void {
        const PadDetectionSides = [_]CellType{
            elf.hitBox.middleLeggs,
        };

        if ((rl.isKeyPressed(rl.KeyboardKey.space)) or HitBox.isInCollision(PadDetectionSides[0..], CellType.PAD)) {
            if (elf.isOnGround) {
                elf.speed = 1500;
                elf.physics.applyJump(elf.jump_force);
                elf.isOnGround = false;
            } else {
                elf.setDefaultSpeed();
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
            elf.state = PlayerState.DEAD; //For Later
            event.playerEventstatus = event.PlayerEventStatus.IDLE_AREA;
        }
    }
};
