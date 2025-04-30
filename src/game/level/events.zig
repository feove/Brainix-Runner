const std = @import("std");
const rl = @import("raylib");
const Elf = @import("../player.zig").Elf;
const player = @import("../player.zig");
const Grid = @import("../grid.zig").Grid;
const Cell = @import("../grid.zig").Cell;
const CellType = @import("../grid.zig").CellType;
const Object = @import("../terrain_object.zig").Object;
const Inventory = @import("../inventory.zig").Inventory;
const EventConfig = @import("level_reader.zig").EventConfig;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = gpa.allocator();
const print = std.debug.print;

pub var level: Level = undefined;
pub var slow_motion_active: bool = false;
pub var stop_slow_motion: bool = false;
pub var slow_motion_start_time: f64 = 0;
var slots_filled = false;

pub var playerEventstatus: PlayerEventStatus = PlayerEventStatus.IDLE_AREA;
pub var levelStatement = LevelStatement.STARTING;

const LEVEL_NB: usize = 2;
var CURRENT_LEVEL: usize = 0;

const level_paths: []const []const u8 = &.{
    "levels/lvl_1.json",
    "levels/lvl_2.json",
};

var EVENT_NB: usize = undefined;
const CURRENT_EVENT: usize = 0;

pub const PlayerEventStatus = enum {
    IDLE_AREA,
    SLOW_MOTION_AREA,
    RESTRICTED_AREA,
    COMPLETED_AREA,
};

const LevelStatement = enum {
    STARTING,
    ONGOING,
    PRE_COMPLETED,
    COMPLETED,
};

pub const Areas = struct {
    trigger_area: rl.Vector4,
    restricted_area: rl.Vector4 = .init(0, 0, 0, 0),
    completed_area: rl.Vector4,

    fn player_in_trigger_area(self: *Areas, elf: *Elf) bool {
        const inAxeX: bool = elf.x > self.trigger_area.x and elf.x < self.trigger_area.x + self.trigger_area.w;
        const inAxeY: bool = elf.y > self.trigger_area.y and elf.y < self.trigger_area.y + self.trigger_area.z;

        return inAxeX and inAxeY;
    }

    fn player_in_restricted_area(self: *Areas, elf: *Elf) bool {
        const inAxeX: bool = elf.x > self.restricted_area.x and elf.x < self.restricted_area.x + self.restricted_area.w;
        const inAxeY: bool = elf.y > self.restricted_area.y and elf.y < self.restricted_area.y + self.restricted_area.z;

        return inAxeX and inAxeY;
    }

    fn player_in_end_are(self: *Areas, elf: *Elf) bool {
        const inAxeX: bool = elf.x > self.completed_area.x and elf.x < self.completed_area.x + self.completed_area.w;

        const inAxeY: bool = elf.y > self.completed_area.y and elf.y < self.completed_area.y + self.completed_area.z;

        return inAxeX and inAxeY;
    }

    fn player_in_area(self: *Areas, elf: *Elf, area: rl.Vector4) bool {
        _ = self;
        const elf_left = elf.x;
        const elf_right = elf.x + elf.width;
        const elf_top = elf.y;
        const elf_bottom = elf.y + elf.height;

        const area_left = area.x;
        const area_right = area.x + area.w;
        const area_top = area.y;
        const area_bottom = area.y + area.z;

        const horizontal_overlap = elf_left < area_right and elf_right > area_left;
        const vertical_overlap = elf_top < area_bottom and elf_bottom > area_top;

        return horizontal_overlap and vertical_overlap;
    }
};

pub const Event = struct {
    object_nb: usize,
    grid_objects: []Object,
    inv_objects: []Object,
    areas: Areas,
    slow_motion_time: f32,
    time_divisor: f32,
    already_triggered: bool = false,

    fn objectsSetUp(event: *Event, objects: []Object) void {
        var grid: Grid = Grid.selfReturn();
        for (0..event.object_nb) |i| {
            Object.set(&objects[i], &grid);
        }
    }

    fn objectsCleaning(event: *Event, objects: []Object) void {
        var grid: Grid = Grid.selfReturn();
        for (0..event.object_nb) |i| {
            Object.remove(&objects[i], &grid);
        }
    }

    pub fn slow_motion_effect(elf: *Elf) void {
        const current_time = rl.getTime();
        _ = elf;
        if (!slow_motion_active) {
            if (playerEventstatus == PlayerEventStatus.SLOW_MOTION_AREA and !level.events[level.i_event].already_triggered) {
                player.time_divisor = level.events[level.i_event].time_divisor;
                slow_motion_active = true;
                slow_motion_start_time = current_time;
                level.events[level.i_event].already_triggered = true;
                return;
            }
        }

        if (slow_motion_active) {
            const elapsed = current_time - slow_motion_start_time;
            //or (Inventory.invEmpty() and Inventory.cacheEmpty()) but better without
            if (elapsed >= level.events[level.i_event].slow_motion_time or stop_slow_motion) {
                slow_motion_active = false;
                player.time_divisor = 1;
                stop_slow_motion = false;

                playerEventstatus = .IDLE_AREA;
            }
        }
    }

    pub fn stopSlowMotion() void {
        stop_slow_motion = true;
    }
};

pub const Level = struct {
    events: []Event,
    event_nb: usize,
    i_event: usize,

    pub fn init(allocator: std.mem.Allocator) !void {

        //must allocate event_nb array of each lvl

        //Events Init
        level.i_event = CURRENT_EVENT;

        const eventConfig: *EventConfig = try EventConfig.levelReader(allocator, level_paths[CURRENT_LEVEL]);

        level.events = eventConfig.*.events.*;
        EVENT_NB = eventConfig.*.event_nb;
        level.event_nb = EVENT_NB;
        reset();
    }

    pub fn reset() void {
        level.i_event = 0;

        for (0..level.event_nb) |i| {
            level.events[i].already_triggered = false;
        }

        Grid.reset();

        levelStatement = .STARTING;

        Elf.elfRespawning();
    }

    pub fn usize_assign_to_f32(i: usize, j: usize, width: usize, height: usize) rl.Vector4 {
        const grid: Grid = Grid.selfReturn();

        //Need to check out of band of j + height and i + width

        const tl_cell: Cell = grid.cells[j][i];
        const bl_cell: Cell = grid.cells[j + height][i];
        const tr_cell: Cell = grid.cells[j][i + width];

        const x: f32 = tl_cell.x;
        const y: f32 = tl_cell.y;
        const w: f32 = tr_cell.x - bl_cell.x;
        const h: f32 = bl_cell.y - tl_cell.y;

        return .init(x, y, h, w); //flex
    }

    pub fn refresh(self: *Level) !void {
        var elf: Elf = Elf.selfReturn();
        _ = self;

        //TMP Conditions
        if (levelStatement == .PRE_COMPLETED or levelStatement == .COMPLETED) {
            try levelState();
            return;
        }

        areaSetting(&elf);

        playerStatement(&elf);

        eventDrawing(level.i_event);
    }

    fn areaSetting(elf: *Elf) void {
        var area: Areas = level.events[level.i_event].areas;

        if (area.player_in_area(elf, area.trigger_area) and !level.events[level.i_event].already_triggered) {
            playerEventstatus = .SLOW_MOTION_AREA;
        }

        if (area.player_in_area(elf, area.restricted_area)) {
            playerEventstatus = .RESTRICTED_AREA;
        }

        if (area.player_in_area(elf, area.completed_area)) {
            playerEventstatus = .COMPLETED_AREA;
        }
    }

    fn playerStatement(elf: *Elf) void {
        switch (playerEventstatus) {
            PlayerEventStatus.IDLE_AREA => idle(),
            PlayerEventStatus.SLOW_MOTION_AREA => slow_motion(elf),
            PlayerEventStatus.RESTRICTED_AREA => print("IN RESTRICTED AREA\n", .{}),
            PlayerEventStatus.COMPLETED_AREA => complete(),
        }
    }

    fn idle() void {
        Inventory.clear();
        slots_filled = false;
    }

    fn slow_motion(elf: *Elf) void {
        var event: Event = level.events[level.i_event];

        if (slots_filled == false) {
            print("EVENT {d} TRIGGERED\n", .{level.i_event});
            Inventory.slotSetting(event.inv_objects);
            slots_filled = true;
        }

        event.objectsSetUp(event.grid_objects);

        Event.slow_motion_effect(elf);
    }

    fn complete() void {
        var event: Event = level.events[level.i_event];

        print("EVENT {d} COMPLETED\n", .{level.i_event});

        event.objectsCleaning(event.grid_objects);

        Inventory.clear();
        Grid.reset();

        playerEventstatus = PlayerEventStatus.IDLE_AREA;

        level.i_event += 1;

        if (level.i_event == level.event_nb) {
            levelStatement = .PRE_COMPLETED;
        }
    }

    fn levelState() !void {
        switch (levelStatement) {
            .STARTING => {},
            .ONGOING => {},
            .PRE_COMPLETED => {
                in_ending_level();
            },
            .COMPLETED => {
                print("LEVEL COMPLETED \n", .{});
                CURRENT_LEVEL += 1;

                if (CURRENT_LEVEL == LEVEL_NB) {
                    CURRENT_LEVEL = 0;
                    print("GAME ENDED \n", .{});
                    return;
                }

                try init(alloc);
            },
        }
    }

    fn in_ending_level() void {
        if (Level.openTheDoor()) {
            levelStatement = .COMPLETED;
        }
    }

    fn openTheDoor() bool {
        //Anims
        return Elf.playerInDoor();
    }

    fn eventDrawing(event_num: usize) void {
        if (levelStatement == .COMPLETED or levelStatement == .PRE_COMPLETED or level.events[level.i_event].already_triggered) {
            return;
        }
        const event: Event = level.events[event_num];

        const c_x: f32 = event.areas.completed_area.x;
        const c_y: f32 = event.areas.completed_area.y;
        const c_w: f32 = event.areas.completed_area.w;
        const c_h: f32 = event.areas.completed_area.z;

        const t_x: f32 = event.areas.trigger_area.x;
        const t_y: f32 = event.areas.trigger_area.y;
        const t_w: f32 = event.areas.completed_area.w;
        const t_h: f32 = event.areas.completed_area.z;

        const grid: Grid = Grid.selfReturn();

        rl.drawRectangleRec(.init(c_x, c_y, c_w, c_h), rl.Color.alpha(.green, 250));

        rl.drawRectangleRec(.init(t_x, t_y, t_w, t_h), rl.Color.alpha(.yellow, 250));

        const cell: Cell = grid.cells[event.grid_objects[0].y][event.grid_objects[0].x];
        rl.drawRectangleRec(.init(cell.x, cell.y, cell.width, cell.height), .beige);
    }
};
