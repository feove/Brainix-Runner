const rl = @import("raylib");
const Grid = @import("grid.zig").Grid;

pub var inv: Inventory = undefined;

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

    //cells: [][]InvCell,

    pub fn init() void {
        const grid: Grid = Grid.selfReturn();

        inv.pos.x = grid.x;
        inv.pos.y = grid.y + grid.height + 10;
        inv.width = grid.width;
        inv.height = grid.cells[0][0].height;
    }

    pub fn selfReturn() Inventory {
        return inv;
    }
};
