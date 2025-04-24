const std = @import("std");
const rl = @import("raylib");
const Elf = @import("../player.zig").Elf;
const Grid = @import("../grid.zig").Grid;

pub var level = undefined;

pub const PlayerEventStatus = enum {
    NONE,
    SLOW_MOTION,
    TRIGGERING_EVENT,
    IN_RESTRICTED_AREA,
    EVENT_COMPLETED,
};

pub const Area = struct {
    trigger_area: rl.Vector4,
    restricted_area: rl.Vector4,
    completed_area: rl.Vector4,
};

pub const Event = struct {
    areas: Area,
};

pub const Level = struct {
    events: []Event,
    event_nb: usize,

    fn init() void {}
};
