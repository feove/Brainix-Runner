const std = @import("std");
const rl = @import("raylib");
const CellType = @import("grid.zig").CellType;
const Elf = @import("player.zig").Elf;
const HitBox = @import("player.zig").HitBox;
const Grid = @import("grid.zig").Grid;
const PlayerState = @import("player.zig").PlayerState;
const event = @import("level/events.zig");
const print = std.debug.print;

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

    pub fn cellAroundchecking(i: usize, j: usize, cell: CellType) bool {
        const config_requirement: AroundConfig = cellConfigRequirment(cell).*;
        const current_config: AroundConfig = currentConfig(i, j).*;
        print("\n\ncurrent_config {any}\n\n\n", .{current_config});
        _ = config_requirement;

        return true;
    }

    fn cellConfigRequirment(cell: CellType) *AroundConfig {
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

    fn set_row(config: *AroundConfig, i: usize, cell: CellType) void {
        for (0..3) |j| {
            config.model[i][j] = cell;
        }
    }

    fn set_col(config: *AroundConfig, j: usize, cell: CellType) void {
        for (0..3) |i| {
            config.model[i][j] = cell;
        }
    }

    fn setVoidConfig(config: *AroundConfig, i: usize, j: usize) void {
        if (@as(i32, @intCast(j)) - 1 < 0) {
            set_row(config, 0, .VOID);
        }
        if (j + 1 >= Grid.selfReturn().nb_cols) {
            set_col(config, 2, .VOID);
        }
        if (@as(i32, @intCast(i)) - 1 < 0) {
            set_col(config, 0, .VOID);
        }
        if (i + 1 >= Grid.selfReturn().nb_rows) {
            set_row(config, 2, .VOID);
        }
    }
    fn currentConfig(i: usize, j: usize) *AroundConfig {
        var config: AroundConfig = AroundConfig{};
        setVoidConfig(&config, i, j);

        //tl corner
        // const r: usize = @as(usize, @intCast(@as(i32, @intCast(i)) - 1));
        // const c: usize = @as(usize, @intCast(@as(i32, @intCast(j)) - 1));

        const r = if (i > 0) i - 1 else 0;
        const c = if (j > 0) j - 1 else 0;

        for (0..3) |di| {
            for (0..3) |dj| {
                if (config.model[di][dj] == .VOID) {
                    continue;
                }
                config.model[dj][di] = Grid.selfReturn().cells[c + dj][r + di].object.type;
            }
        }

        return &config;
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
