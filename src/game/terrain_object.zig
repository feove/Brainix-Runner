const std = @import("std");
const rl = @import("raylib");

const player = @import("../entity/elf.zig");
const Elf = player.Elf;
const HitBox = player.HitBox;
const PlayerState = player.PlayerState;

const terrain = @import("../terrain/grid.zig");
const Grid = terrain.Grid;
const CellType = terrain.CellType;

const event = @import("level/events.zig");
const Inventory = @import("inventory.zig").Inventory;
const window = @import("../render/window.zig");
const textures = @import("../render/textures.zig");
const anim = @import("animations/animations_manager.zig");
const elf_anims = @import("../game/animations/elf_anims.zig");
const EffectManager = @import("../game/animations/effects_spawning.zig").EffectManager;

const print = std.debug.print;

const ItemSpec = struct {
    up_pad_force: f32 = -1000,
};

const itemSpec = ItemSpec{};

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
    newSens: bool = false,
    jump: bool = false,

    const gravity: f32 = 9.8;

    pub fn set(self: *PhysicObject, new: AutoMovements) void {
        self.auto_moving = new;
        self.newSens = true;
    }

    pub fn applyPhysics(self: *PhysicObject, dt: f32) void {
        self.acceleration = self.mass * gravity;
        self.velocity_y += self.acceleration * dt;
    }

    pub fn applyJump(self: *PhysicObject, jump_force: f32) void {
        self.velocity_y = jump_force;

        const horizontal_boost: f32 = 0.08;

        self.velocity_x = switch (self.auto_moving) {
            .RIGHT => horizontal_boost,
            .LEFT => -horizontal_boost,
        };

        self.jump = false;
    }

    pub fn upPadEffect(self: *PhysicObject, up_pad_force: f32) void {
        self.velocity_y = up_pad_force;
        self.velocity_x = 0;
    }

    pub fn boostEffect(self: *PhysicObject, boost_force: f32) void {
        self.velocity_x = boost_force;
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
        //print("\n\ncurrent_config {any}\n\n\n", .{current_config});

        for (0..3) |r| {
            for (0..3) |c| {
                if (config_requirement.model[c][r] == .ANY) {
                    continue;
                }

                if (config_requirement.model[c][r] != current_config.model[c][r]) {
                    return true;
                }
            }
        }
        return false;
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
        for (0..3) |e| {
            config.model[i][e] = cell;
        }
    }

    fn set_col(config: *AroundConfig, j: usize, cell: CellType) void {
        for (0..3) |e| {
            config.model[e][j] = cell;
        }
    }

    fn setVoidConfig(config: *AroundConfig, i: usize, j: usize) void {
        if (@as(i32, @intCast(j)) - 1 < 0) {
            //print("OUT OF BAND j - 1 < 0\n", .{});
            set_row(config, 0, .VOID);
        }
        if (j + 1 >= Grid.selfReturn().nb_rows) {
            //print("OUT OF BAND j + 1 >= nb_cols\n", .{});
            set_row(config, 2, .VOID);
        }
        if (@as(i32, @intCast(i)) - 1 < 0) {
            //print("OUT OF BAND i - 1 < 0\n", .{});
            set_col(config, 0, .VOID);
        }
        if (i + 1 >= Grid.selfReturn().nb_cols) {
            // print("OUT OF BAND i + 1 > nb_rows\n", .{});
            set_col(config, 2, .VOID);
        }
    }
    fn currentConfig(i: usize, j: usize) *AroundConfig {
        var config: AroundConfig = AroundConfig{};
        setVoidConfig(&config, i, j);

        //Thx Debuger
        // for (0..config.model.len) |e| {
        //     for (0..config.model.len) |f| {
        //         print("{}  ", .{config.model[e][f]});
        //     }
        //     print("\n", .{});
        // }

        //tl corner
        const r = if (i == 0) i else if (i == Grid.selfReturn().nb_rows) i - 3 else i - 1;
        const c = if (j == 0) j else if (j == Grid.selfReturn().nb_cols) j - 3 else j - 1;

        for (0..3) |di| {
            for (0..3) |dj| {
                if (config.model[dj][di] == .VOID) {
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
    width: usize = 1,
    type: CellType = .EMPTY,
    tail: bool = false, //Only For Boost
    canPlayerTake: bool = false,
    key: usize = 0,

    count: i64 = 1,

    pub fn set(self: *Object, grid: *Grid) void {
        const object_size: usize = objectSize(self.type);
        grid.cells[self.y][self.x].object.type = self.type;

        if (object_size == 2) {
            grid.cells[self.y][self.x + 1].object.type = self.type;
        }
    }

    pub fn remove(self: *Object, grid: *Grid) void {
        grid.cells[self.y][self.x].object.type = CellType.AIR;
    }

    pub fn add(self: *[]Object, cell: CellType, count: i64, is_grid_objects: bool, key: usize) void {
        var object_size: usize = objectSize(cell);
        if (is_grid_objects) {
            object_size = 1; //Grid exception
        }

        if (cellRemaings(self) >= object_size) {
            for (0..self.len) |i| {
                if (self.*[i].type == CellType.EMPTY) {
                    for (0..object_size) |j| {
                        self.*[j + i].type = cell;
                        self.*[j + i].width = object_size;
                        self.*[j + i].canPlayerTake = true;
                        self.*[j + i].count = count;
                        self.*[j + i].key = key;
                    }

                    return;
                }
            }
        }
    }

    pub fn objectSize(cell: CellType) usize {
        switch (cell) {
            .BOOST => return 2,
            else => return 1,
        }
    }

    pub fn cellRemaings(self: *[]Object) usize { //[]Object Only
        var counter: usize = 0;

        for (0..self.len) |j| {
            if (self.*[j].type == .EMPTY) {
                counter += 1;
            }
        }
        return counter;
    }

    fn findObject(elf: *Elf, i: *usize, j: *usize, celltype: CellType) void {
        var grid: Grid = Grid.selfReturn();
        HitBox.i_and_j_assign(&grid, elf.x + elf.width / 2, elf.y + elf.height - elf.height / 4, i, j);

        if (grid.cells[j.*][i.*].object.type != celltype) {
            i.* += 1; //Can be Out of band
        }

        if (grid.cells[j.*][i.*].object.type != celltype) {
            i.* -= 2; //Can be Out of band
        }
    }

    pub fn padAction(elf: *Elf) void {
        const PadDetectionSides = [_]CellType{
            elf.hitBox.middleLeggs,
        };

        if (HitBox.isInCollision(PadDetectionSides[0..], CellType.PAD)) {
            if (elf.isOnGround and elf.canTrigger) {
                elf.physics.applyJump(elf.jump_force);

                var i: usize = undefined;
                var j: usize = undefined;

                findObject(elf, &i, &j, .PAD);

                //print("i : {d} j : {d}\n", .{ i, j });
                anim.jumper_sprite.setPos(i, j);
            }
        }
    }

    pub fn upPadAction(elf: *Elf) void {
        const PadDetectionSides = [_]CellType{
            elf.hitBox.middleLeggs,
        };

        //(rl.isKeyPressed(rl.KeyboardKey.space)) or
        if (HitBox.isInCollision(PadDetectionSides[0..], CellType.UP_PAD)) {
            if (elf.isOnGround and elf.canTrigger) {
                elf.physics.upPadEffect(itemSpec.up_pad_force);

                var i: usize = undefined;
                var j: usize = undefined;

                findObject(elf, &i, &j, .UP_PAD);

                anim.jumper_sprite.setPos(i, j);
                anim.jumper_sprite.isRunning = true;
            }
        }
    }

    pub fn boostAction(elf: *Elf) void {
        const PadDetectionSides = [_]CellType{
            elf.hitBox.middleLeggs,
            elf.hitBox.middleBody,
        };

        if (HitBox.isInCollision(PadDetectionSides[0..], .BOOST)) {
            elf.physics.boostEffect(elf.boost_force);
            // event.Event.stopSlowMotion();
        }
    }

    pub fn spikeAction(elf: *Elf) void {
        const SpikeDetectionSides = [_]CellType{
            elf.hitBox.middleLeggs,
            elf.hitBox.middleBody,
        };

        if (HitBox.isInCollision(SpikeDetectionSides[0..], CellType.SPIKE)) {
            if (elf.state == .ALIVE) {
                Elf.set_death_purpose(.SPIKE);
                elf.state = .DEAD;
            }
        }
    }
};
