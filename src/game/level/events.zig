const std = @import("std");
const rl = @import("raylib");
const Elf = @import("../player.zig").Elf;
const Grid = @import("../grid.zig").Grid;
const Cell = @import("../grid.zig").Cell;
const CellType = @import("../grid.zig").CellType;
const Object = @import("../terrain_object.zig").Object;
const print = std.debug.print;

pub var level: Level = undefined;

pub var playerEventstatus: PlayerEventStatus = PlayerEventStatus.IDLE_AREA;

const LEVEL_NB: usize = 1;
const OBJECT_NB: usize = 1;
const EVENT_NB: usize = 1;
const CURRENT_EVENT: usize = 0;

pub const PlayerEventStatus = enum {
    IDLE_AREA,
    SLOW_MOTION_AREA,
    RESTRICTED_AREA,
    END_AREA,
};

pub const Areas = struct {
    trigger_area: rl.Vector4,
    restricted_area: rl.Vector4 = .init(0, 0, 0, 0),
    completed_area: rl.Vector4,

    fn player_in_trigger_area(self: *Areas, elf: *Elf) bool {
        const inAxeX: bool = elf.x > self.trigger_area.x and elf.x < self.trigger_area.x + self.trigger_area.z;
        const inAxeY: bool = elf.y > self.trigger_area.y and elf.y < self.trigger_area.y + self.trigger_area.w;

        return inAxeX and inAxeY;
    }

    fn player_in_restricted_area(self: *Areas, elf: *Elf) bool {
        const inAxeX: bool = elf.x > self.restricted_area.x and elf.x < self.restricted_area.x + self.restricted_area.z;
        const inAxeY: bool = elf.y > self.restricted_area.y and elf.y < self.restricted_area.y + self.restricted_area.w;

        return inAxeX and inAxeY;
    }

    fn player_in_end_are(self: *Areas, elf: *Elf) bool {
        const inAxeX: bool = elf.x > self.completed_area.x and elf.x < self.completed_area.x + self.completed_area.z;
        const inAxeY: bool = elf.y > self.completed_area.y and elf.y < self.completed_area.y + self.completed_area.w;

        return inAxeX and inAxeY;
    }
};

pub const Event = struct {
    objects: []Object,
    areas: Areas,
    object_nb: usize,
};

pub const Level = struct {
    events: []Event,
    event_nb: usize,
    i_event: usize,

    pub fn init(allocator: std.mem.Allocator) !void {
        var events = try allocator.alloc(Event, LEVEL_NB);

        //Add First Event (SPIKE)
        const objects = try allocator.alloc(Object, OBJECT_NB);
        objects[0] = Object{
            .x = 6,
            .y = 7,
            .type = CellType.SPIKE,
        };

        events[0].objects = objects;

        events[0].areas = Areas{
            .trigger_area = usize_assign_to_f32(objects[0].x - 3, objects[0].y - 2, 2, 2),
            .completed_area = usize_assign_to_f32(objects[0].x + 1, objects[0].y - 2, 2, 2),
        };

        events[0].object_nb = 1;

        //level assignement
        level.events = events;
        level.event_nb = EVENT_NB;
        level.i_event = CURRENT_EVENT;
    }

    pub fn refresh(self: *Level) void {
        var elf: Elf = Elf.selfReturn();

        if (level.events[level.i_event].areas.player_in_trigger_area(&elf)) {
            playerEventstatus = PlayerEventStatus.SLOW_MOTION_AREA;
        }

        if (level.events[level.i_event].areas.player_in_restricted_area(&elf)) {
            playerEventstatus = PlayerEventStatus.RESTRICTED_AREA;
        }

        if (level.events[level.i_event].areas.player_in_end_are(&elf)) {
            playerEventstatus = PlayerEventStatus.END_AREA;
        }

        _ = self;
    }

    fn usize_assign_to_f32(i: usize, j: usize, width: usize, height: usize) rl.Vector4 {
        const grid: Grid = Grid.selfReturn();

        //Need to check out of band of j + height and i + width

        const tl_cell: Cell = grid.cells[j][i];
        const bl_cell: Cell = grid.cells[j + height][i];
        const tr_cell: Cell = grid.cells[j][i + width];

        const x: f32 = tl_cell.x;
        const y: f32 = tl_cell.y;
        const w: f32 = bl_cell.y - tl_cell.y;
        const h: f32 = tr_cell.x - bl_cell.x;

        return rl.Vector4.init(x, y, w, h); //I should replace with return .init(x,y,w,h); to test;
    }

    fn playerStatement(elf: *Elf) void {
        switch (playerEventstatus) {
            PlayerEventStatus.IDLE_AREA => print("IDLE\n", .{}),
            PlayerEventStatus.SLOW_MOTION_AREA => {
                elf.speed = 100;
            },
            PlayerEventStatus.RESTRICTED_AREA => print("RESTRICTED AREA\n", .{}),
            PlayerEventStatus.END_AREA => print("END AREA\n", .{}),
        }
    }
};
