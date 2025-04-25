const std = @import("std");
const rl = @import("raylib");
const Elf = @import("../player.zig").Elf;
const Grid = @import("../grid.zig").Grid;
const Cell = @import("../grid.zig").Cell;
const CellType = @import("../grid.zig").CellType;
const Object = @import("../terrain_object.zig").Object;
const Inventory = @import("../inventory.zig").Inventory;
const print = std.debug.print;

pub var level: Level = undefined;
pub var slow_motion_active: bool = false;
pub var slow_motion_start_time: f64 = 0;
pub var inv_objects_used = false;

pub var playerEventstatus: PlayerEventStatus = PlayerEventStatus.IDLE_AREA;

const LEVEL_NB: usize = 1;
const OBJECT_NB: usize = 1;
const EVENT_NB: usize = 1;
const CURRENT_EVENT: usize = 0;

pub const PlayerEventStatus = enum {
    IDLE_AREA,
    SLOW_MOTION_AREA,
    RESTRICTED_AREA,
    COMPLETED_AREA,
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
    grid_objects: []Object,
    inv_objects: []Object,
    size_inv_objects: usize,
    areas: Areas,
    object_nb: usize,
    slow_motion_time: f32 = 3,

    //Setting Event's Objects over the grid
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

    //Slow Motion effect
    pub fn slow_motion_effect(elf: *Elf) void {
        var area: Areas = level.events[level.i_event].areas;
        const current_time = rl.getTime();
        if (!slow_motion_active) {
            if (area.player_in_area(elf, area.trigger_area)) {
                playerEventstatus = PlayerEventStatus.SLOW_MOTION_AREA;
                elf.speed = 50;
                slow_motion_active = true;
                slow_motion_start_time = current_time;
            }
        }

        if (slow_motion_active) {
            const elapsed = current_time - slow_motion_start_time;
            if (elapsed >= 0.5) {
                elf.setDefaultSpeed();
                slow_motion_active = false;
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
        var events = try allocator.alloc(Event, LEVEL_NB);

        //Add First Event (ONE SPIKE)
        const grid_objects = try allocator.alloc(Object, OBJECT_NB);
        grid_objects[0] = Object{
            .x = 5,
            .y = 7,
            .type = CellType.SPIKE,
        };

        const inv_objects = try allocator.alloc(Object, Inventory.selfReturn().size);
        inv_objects[0] = Object{
            .x = 0,
            .y = 0,
            .type = CellType.PAD,
        };
        events[0].size_inv_objects = 1;

        events[0].grid_objects = grid_objects;

        events[0].inv_objects = inv_objects;

        events[0].areas = Areas{
            .trigger_area = usize_assign_to_f32(grid_objects[0].x - 2, grid_objects[0].y, 1, 1),
            .completed_area = usize_assign_to_f32(grid_objects[0].x + 2, grid_objects[0].y, 1, 1),
        };

        events[0].object_nb = 1;

        //Add Second Event (SPIKES AND BLOCKS)

        //level assign
        level.events = events;
        level.event_nb = EVENT_NB;
        level.i_event = CURRENT_EVENT;
    }

    pub fn refresh(self: *Level) void {
        var elf: Elf = Elf.selfReturn();
        var area: Areas = level.events[level.i_event].areas;
        _ = self;

        if (playerEventstatus != PlayerEventStatus.SLOW_MOTION_AREA) {
            playerEventstatus = PlayerEventStatus.IDLE_AREA;
        }

        if (area.player_in_area(&elf, area.trigger_area)) {
            playerEventstatus = PlayerEventStatus.SLOW_MOTION_AREA;
        }

        if (area.player_in_area(&elf, area.restricted_area)) {
            playerEventstatus = PlayerEventStatus.RESTRICTED_AREA;
        }

        if (area.player_in_area(&elf, area.completed_area)) {
            playerEventstatus = PlayerEventStatus.COMPLETED_AREA;
        }

        playerStatement(&elf);

        eventDrawing(0);
    }

    fn usize_assign_to_f32(i: usize, j: usize, width: usize, height: usize) rl.Vector4 {
        const grid: Grid = Grid.selfReturn();

        //Need to check out of band of j + height and i + width

        const tl_cell: Cell = grid.cells[j][i];
        const bl_cell: Cell = grid.cells[j + height][i];
        const tr_cell: Cell = grid.cells[j][i + width];

        const x: f32 = tl_cell.x;
        const y: f32 = tl_cell.y;
        const w: f32 = tr_cell.x - bl_cell.x;
        const h: f32 = bl_cell.y - tl_cell.y;

        return .init(x, y, h, w); //I should replace with return .init(x,y,h, w); to test;
    }

    fn playerStatement(elf: *Elf) void {
        var event: Event = level.events[level.i_event];

        switch (playerEventstatus) {
            PlayerEventStatus.IDLE_AREA => {
                print("IDLE\n", .{});
                elf.setDefaultSpeed();
                Inventory.clear();
                inv_objects_used = false;
            },
            PlayerEventStatus.SLOW_MOTION_AREA => { //After triggered
                //print("SLOW MOTION AREA\n", .{});

                if (inv_objects_used == false) {
                    Inventory.slotSetting(event.inv_objects, event.size_inv_objects);
                    inv_objects_used = true;
                }

                event.objectsSetUp(event.grid_objects);
            },
            PlayerEventStatus.RESTRICTED_AREA => print("RESTRICTED AREA\n", .{}),
            PlayerEventStatus.COMPLETED_AREA => {
                event.objectsCleaning(event.grid_objects);

                Inventory.clear();
                Grid.reset();

                if (level.i_event < level.event_nb - 1) {
                    level.i_event += 1;
                }

                print("COMPLETED AREA\n", .{});
            },
        }
    }

    fn eventDrawing(event_num: usize) void {
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
