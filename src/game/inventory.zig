const rl = @import("raylib");
const Grid = @import("grid.zig").Grid;
const std = @import("std");
pub var inv: Inventory = undefined;

const SIZE: usize = 4;

const Item = enum {
    PAD,
    BLOCK,
};

const InvCell = struct {
    pos: rl.Vector2,
    width: f32,
    height: f32,
    type: Item,
};

pub const Inventory = struct {
    pos: rl.Vector2,
    width: f32,
    height: f32,
    size: usize,

    slots: []InvCell,

    pub fn init(allocator: std.mem.Allocator) !void {
        const grid: Grid = Grid.selfReturn();

        const slots = try allocator.alloc(InvCell, SIZE);

        for (0..SIZE) |i| {
            const i_cast: f32 = @as(f32, @floatFromInt(i));

            slots[i] = InvCell{
                .pos = .init(grid.x + i_cast * (grid.cells[0][0].width + 5), grid.y + grid.height + 10),
                .width = grid.cells[0][0].width,
                .height = grid.cells[0][0].height,
                .type = Item.BLOCK,
            };
        }

        inv.pos.x = grid.x;
        inv.pos.y = grid.y + grid.height + 10;
        inv.width = grid.width;
        inv.height = grid.cells[0][0].height;
        inv.size = SIZE;
        inv.slots = slots;
    }

    pub fn selfReturn() Inventory {
        return inv;
    }
};
