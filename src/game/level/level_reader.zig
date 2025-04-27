const std = @import("std");
const Elf = @import("../player.zig").Elf;
const player = @import("../player.zig");
const Grid = @import("../grid.zig").Grid;
const Cell = @import("../grid.zig").Cell;
const CellType = @import("../grid.zig").CellType;
const Object = @import("../terrain_object.zig").Object;
const Areas = @import("events.zig").Areas;
const Inventory = @import("../inventory.zig").Inventory;
const Event = @import("events.zig").Event;
const Level = @import("events.zig").Level;

pub const EventConfig = struct {
    events: []Event,

    pub fn levelReader(allocator: std.mem.Allocator, id: usize, level_pathway: []const u8) !EventConfig {
        var eventConfig: EventConfig = undefined;
        var events = try allocator.alloc(Event, 1);

        var file = try std.fs.cwd().openFile(level_pathway, .{});
        defer file.close();

        const json_data = try file.readToEndAlloc(allocator, 1024 * 10);
        defer allocator.free(json_data);

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, json_data, .{}) catch |err| {
            std.debug.print("JSON Parse Error: {}\n", .{err});
            return err;
        };
        defer parsed.deinit();

        const root_object = parsed.value.object;
        var iter = root_object.iterator();

        while (iter.next()) |entry| {
            const event_number = entry.key_ptr;

            if (event_number.*[event_number.len - 1] == '0' + @as(u8, @intCast(id))) {
                const el = entry.value_ptr.object;
                const object_nb: usize = @as(usize, @intCast(el.get("object_nb").?.integer));
                const slow_motion_time: f32 = @as(f32, @floatCast(el.get("slow_motion_time").?.float));
                const time_divisor: f32 = @as(f32, @floatCast(el.get("time_divisor").?.float));
                const already_triggered: bool = el.get("already_triggered").?.bool;

                const inv_json = el.get("inv_objects").?.array;

                var inv_objects = try allocator.alloc(Object, Inventory.selfReturn().size);
                for (0..Inventory.selfReturn().size) |i| {
                    inv_objects[i] = Object{};
                }
                for (inv_json.items) |item| {
                    const celltype: CellType = stringToCellType(item.string);
                    Object.add(&inv_objects, celltype);
                }

                events[id].object_nb = object_nb;
                events[id].slow_motion_time = slow_motion_time;
                events[id].time_divisor = time_divisor;
                events[id].inv_objects = inv_objects;
                events[id].already_triggered = already_triggered;

                // std.debug.print("\nobject_nb : {d}\n", .{object_nb});
                // std.debug.print("\nslow_motion_time : {}\n", .{slow_motion_time});
            }
        }

        //Add First Event (ONE SPIKE)

        var grid_objects = try allocator.alloc(Object, 1);
        grid_objects[0] = Object{ .x = 5, .y = 7, .type = CellType.SPIKE };
        events[0].grid_objects = grid_objects;

        // var inv_objects = try allocator.alloc(Object, Inventory.selfReturn().size);
        // for (0..Inventory.selfReturn().size) |i| {
        //     inv_objects[i] = Object{};
        // }
        // Object.add(&inv_objects, CellType.PAD);

        events[0].areas = Areas{
            .trigger_area = Level.usize_assign_to_f32(3, 7, 1, 1),
            .completed_area = Level.usize_assign_to_f32(8, 7, 1, 1),
        };

        eventConfig.events = events;
        return eventConfig;
    }
};

//Sad but functionnal
pub fn stringToCellType(str: []const u8) CellType {
    if (std.mem.eql(u8, str, "AIR")) {
        return CellType.AIR;
    } else if (std.mem.eql(u8, str, "GROUND")) {
        return CellType.GROUND;
    } else if (std.mem.eql(u8, str, "SPIKE")) {
        return CellType.SPIKE;
    } else if (std.mem.eql(u8, str, "PAD")) {
        return CellType.PAD;
    } else if (std.mem.eql(u8, str, "EMPTY")) {
        return CellType.EMPTY;
    } else {
        return CellType.EMPTY;
    }
}
