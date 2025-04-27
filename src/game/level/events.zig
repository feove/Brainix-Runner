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
const print = std.debug.print;

pub var level: Level = undefined;
pub var slow_motion_active: bool = false;
pub var slow_motion_start_time: f64 = 0;
var inv_objects_used = false;

pub var playerEventstatus: PlayerEventStatus = PlayerEventStatus.IDLE_AREA;
pub var levelStatement = LevelStatement.STARTING;

const OBJECT_NB: usize = 1;
const EVENT_NB: usize = 1;
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

            if (elapsed >= level.events[level.i_event].slow_motion_time or (Inventory.invEmpty() and Inventory.cacheEmpty())) {
                slow_motion_active = false;
                player.time_divisor = 1;

                playerEventstatus = PlayerEventStatus.IDLE_AREA;
            }
        }
    }
};

pub const Level = struct {
    events: []Event,
    event_nb: usize,
    i_event: usize,

    pub fn init(allocator: std.mem.Allocator) !void {

        //Events Init
        level.event_nb = EVENT_NB;
        level.i_event = CURRENT_EVENT;

        for (0..EVENT_NB) |id_event| {
            const eventConfig: EventConfig = try EventConfig.levelReader(allocator, id_event, "levels/lvl_1.json");

            level.events = eventConfig.events;
        }

        print("\n OBJ NUM : {d}\n", .{level.events[0].object_nb});
        print("\n SLOW MOTION TIME  : {d}\n", .{level.events[0].slow_motion_time});
        print("\n TIME DIVISOR  : {d}\n", .{level.events[0].time_divisor});

        // var events = try allocator.alloc(Event, EVENT_NB);
        // //Add First Event (ONE SPIKE)
        // events[0].object_nb = 1;
        // var grid_objects = try allocator.alloc(Object, 1);
        // var inv_objects = try allocator.alloc(Object, Inventory.selfReturn().size);
        // grid_objects[0] = Object{ .x = 5, .y = 7, .type = CellType.SPIKE };
        // for (0..Inventory.selfReturn().size) |i| {
        //     inv_objects[i] = Object{};
        // }
        // Object.add(&inv_objects, CellType.PAD);
        // events[0].grid_objects = grid_objects;
        // events[0].inv_objects = inv_objects;
        // events[0].slow_motion_time = 2;
        // events[0].time_divisor = 3;
        // events[0].areas = Areas{
        //     .trigger_area = usize_assign_to_f32(grid_objects[0].x - 2, grid_objects[0].y, 1, 1),
        //     .completed_area = usize_assign_to_f32(grid_objects[0].x + 3, grid_objects[0].y, 1, 1),
        // };

        // //Add Second Event (SPIKES AND BLOCKS)
        // events[1].object_nb = 7;
        // grid_objects = try allocator.alloc(Object, events[1].object_nb);
        // inv_objects = try allocator.alloc(Object, Inventory.selfReturn().size);
        // grid_objects[0] = Object{ .x = 6, .y = 7, .type = CellType.PAD };
        // grid_objects[1] = Object{ .x = 5, .y = 7, .type = CellType.GROUND };
        // grid_objects[2] = Object{ .x = 3, .y = 6, .type = CellType.SPIKE };
        // grid_objects[3] = Object{ .x = 4, .y = 7, .type = CellType.GROUND };
        // grid_objects[4] = Object{ .x = 4, .y = 6, .type = CellType.SPIKE };
        // grid_objects[5] = Object{ .x = 3, .y = 7, .type = CellType.GROUND };
        // grid_objects[6] = Object{ .x = 5, .y = 6, .type = CellType.SPIKE };
        // for (0..Inventory.selfReturn().size) |i| {
        //     inv_objects[i] = Object{};
        // }
        // Object.add(&inv_objects, CellType.GROUND);

        // events[1].slow_motion_time = 2;
        // events[1].time_divisor = 3;
        // events[1].areas = Areas{
        //     .trigger_area = usize_assign_to_f32(grid_objects[0].x, grid_objects[0].y, 1, 1),
        //     .completed_area = usize_assign_to_f32(grid_objects[0].x - 5, grid_objects[0].y, 1, 1),
        // };
        // events[1].grid_objects = grid_objects;
        // events[1].inv_objects = inv_objects;

        // //level assign
        // level.events = events;
        // level.event_nb = EVENT_NB;
        // level.i_event = CURRENT_EVENT;
    }

    pub fn reset() void {
        level.i_event = 0;

        for (0..level.event_nb) |i| {
            level.events[i].already_triggered = false;
        }
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

    pub fn refresh(self: *Level) void {
        var elf: Elf = Elf.selfReturn();
        _ = self;
        if (levelStatement == LevelStatement.COMPLETED) {
            return;
        }
        areaSetting(&elf);

        playerStatement(&elf);

        eventDrawing(level.i_event);
    }

    fn areaSetting(elf: *Elf) void {
        var area: Areas = level.events[level.i_event].areas;

        if (area.player_in_area(elf, area.trigger_area) and !level.events[level.i_event].already_triggered) {
            playerEventstatus = PlayerEventStatus.SLOW_MOTION_AREA;
        }

        if (area.player_in_area(elf, area.restricted_area)) {
            playerEventstatus = PlayerEventStatus.RESTRICTED_AREA;
        }

        if (area.player_in_area(elf, area.completed_area)) {
            playerEventstatus = PlayerEventStatus.COMPLETED_AREA;
        }
    }

    fn playerStatement(elf: *Elf) void {
        switch (playerEventstatus) {
            PlayerEventStatus.IDLE_AREA => idle(),
            PlayerEventStatus.SLOW_MOTION_AREA => slow_motion(elf),
            PlayerEventStatus.RESTRICTED_AREA => print("RESTRICTED AREA\n", .{}),
            PlayerEventStatus.COMPLETED_AREA => complete(),
        }
    }

    fn idle() void {
        Inventory.clear();
        inv_objects_used = false;
    }

    fn slow_motion(elf: *Elf) void {
        var event: Event = level.events[level.i_event];

        if (inv_objects_used == false) {
            print("TRIGGER EVENT {d} \n", .{level.i_event});
            Inventory.slotSetting(event.inv_objects);
            inv_objects_used = true;
        }

        event.objectsSetUp(event.grid_objects);

        Event.slow_motion_effect(elf);
    }

    fn complete() void {
        var event: Event = level.events[level.i_event];

        print("COMPLETED EVENT {d}\n", .{level.i_event});

        event.objectsCleaning(event.grid_objects);

        Inventory.clear();
        Grid.reset();

        playerEventstatus = PlayerEventStatus.IDLE_AREA;

        level.i_event += 1;

        if (level.i_event == level.event_nb) {
            print("LEVEL COMPLETED \n", .{});
            levelStatement = LevelStatement.COMPLETED;
            return;
        }
    }

    fn eventDrawing(event_num: usize) void {
        if (levelStatement == LevelStatement.COMPLETED or level.events[level.i_event].already_triggered) {
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
