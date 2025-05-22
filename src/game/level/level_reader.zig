const std = @import("std");
const rl = @import("raylib");

const player = @import("../../entity/elf.zig");
const Elf = player.Elf;

const terrain = @import("../../terrain/grid.zig");
const Grid = terrain.Grid;
const Cell = terrain.Cell;
const CellType = terrain.CellType;

const Object = @import("../terrain_object.zig").Object;
const Areas = @import("events.zig").Areas;
const Inventory = @import("../inventory.zig").Inventory;
const Event = @import("events.zig").Event;
const Level = @import("events.zig").Level;

pub const EventConfig = struct {
    events: *[]Event,
    event_nb: usize,

    pub fn levelReader(allocator: std.mem.Allocator, level_pathway: []const u8) !*EventConfig {
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

        var id: usize = 0;

        const size: usize = @as(usize, @intCast(iter.values[0].integer));

        var eventConfig: EventConfig = undefined;
        var events = try allocator.alloc(Event, size);

        while (iter.next()) |entry| {
            if (entry.key_ptr.*[6] == 'n') {
                continue;
            }

            const el = entry.value_ptr.object;
            const object_nb: usize = @as(usize, @intCast(el.get("object_nb").?.integer));
            const slow_motion_time: f32 = @as(f32, @floatCast(el.get("slow_motion_time").?.float));
            const time_divisor: f32 = @as(f32, @floatCast(el.get("time_divisor").?.float));
            const already_triggered: bool = el.get("already_triggered").?.bool;

            var grid_objects = try allocator.alloc(Object, object_nb);

            const inv_json = el.get("inv_objects").?.array;
            const grid_objects_json = el.get("grid_objects").?.array;

            var inv_objects = try allocator.alloc(Object, Inventory.selfReturn().size);
            for (0..Inventory.selfReturn().size) |i| {
                inv_objects[i] = Object{};
            }
            for (inv_json.items) |item| {
                const str: []const u8 = item.object.get("type").?.string;
                const celltype: CellType = stringToCellType(str);
                const count: i64 = item.object.get("count").?.integer;
                const key: usize = @as(usize, @intCast(item.object.get("key").?.integer));
                Object.add(&inv_objects, celltype, count, false, key);
            }

            for (0..object_nb) |j| {
                grid_objects[j] = Object{};
            }
            var e: usize = 0;
            for (grid_objects_json.items) |obs| {
                const obj: Object = Object{
                    .x = @as(usize, @intCast(obs.object.get("x").?.integer)),
                    .y = @as(usize, @intCast(obs.object.get("y").?.integer)),
                    .key = @as(usize, @intCast(obs.object.get("key").?.integer)),
                };
                grid_objects[e] = obj;
                Object.add(&grid_objects, stringToCellType(obs.object.get("type").?.string), 1, true, obj.key);
                e += 1;
            }

            const areas = el.get("areas").?;
            const triggered = areas.object.get("triggered").?;

            const i_t: usize = @as(usize, @intCast(triggered.object.get("x").?.integer));
            const j_t: usize = @as(usize, @intCast(triggered.object.get("y").?.integer));
            const width_t: usize = @as(usize, @intCast(triggered.object.get("width").?.integer));
            const height_t: usize = @as(usize, @intCast(triggered.object.get("height").?.integer));

            const trigger_area: rl.Vector4 = Level.usize_assign_to_f32(i_t, j_t, width_t, height_t);

            const completed = areas.object.get("completed").?;
            const i_c = @as(usize, @intCast(completed.object.get("x").?.integer));
            const j_c = @as(usize, @intCast(completed.object.get("y").?.integer));
            const width_c = @as(usize, @intCast(completed.object.get("width").?.integer));
            const height_c = @as(usize, @intCast(completed.object.get("height").?.integer));

            const completed_area: rl.Vector4 = Level.usize_assign_to_f32(i_c, j_c, width_c, height_c);

            const intermediate_nb = @as(usize, @intCast(areas.object.get("intermediate_areas_nb").?.integer));
            const intermediate = areas.object.get("intermediate_areas").?.array;
            var intermediate_areas = try allocator.alloc(rl.Vector4, intermediate_nb);

            // for (0..1) |i_inter| {
            //     intermediate_areas[i_inter] = rl.Vector4.init(0, 0, 0, 0);
            // }

            var i_area: usize = 0;
            for (intermediate.items) |area| {
                const i_i = @as(usize, @intCast(area.object.get("x").?.integer));
                const j_i = @as(usize, @intCast(area.object.get("y").?.integer));
                const width_i = @as(usize, @intCast(area.object.get("width").?.integer));
                const height_i = @as(usize, @intCast(area.object.get("height").?.integer));
                // std.debug.print("i_i : {d} j_i : {d} width_i : {d} height_i : {d}\n", .{ i_i, j_i, width_i, height_i });

                intermediate_areas[i_area] = Level.usize_assign_to_f32(i_i, j_i, width_i, height_i);

                //std.debug.print("intermediate_areas[i_area].x {d} \n", .{intermediate_areas[i_area].x});
                i_area += 1;
            }

            events[id].object_nb = object_nb;
            events[id].slow_motion_time = slow_motion_time;
            events[id].time_divisor = time_divisor;
            events[id].inv_objects = inv_objects;
            events[id].already_triggered = already_triggered;
            events[id].grid_objects = grid_objects;
            events[id].areas = Areas{
                .trigger_area = trigger_area,
                .completed_area = completed_area,
                .intermediate_areas = intermediate_areas,
                .intermediate_areas_nb = intermediate_nb,
            };

            id += 1;
        }
        eventConfig.events = &events;
        eventConfig.event_nb = size;
        return &eventConfig;
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
    } else if (std.mem.eql(u8, str, "UP_PAD")) {
        return CellType.UP_PAD;
    } else if (std.mem.eql(u8, str, "BOOST")) {
        return CellType.BOOST;
    } else {
        return CellType.EMPTY;
    }
}
