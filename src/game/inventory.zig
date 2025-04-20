const rl = @import("raylib");
const Grid = @import("grid.zig").Grid;
const std = @import("std");
const HUD = @import("utils.zig").HUD;

pub var inv: Inventory = undefined;

const SLOT_NB: usize = 4;

var SLOT_WIDTH: f32 = undefined;
var SLOT_HEIGHT: f32 = undefined;

const SLOT_PADDING: f32 = 10;
const INV_MARGIN: f32 = 10;

fn slotSizeInit(inventory_width: f32, cell_width: f32, cell_height: f32) void {
    SLOT_WIDTH = inventory_width / @as(f32, @floatFromInt(SLOT_NB));
    SLOT_HEIGHT = (cell_height * SLOT_WIDTH) / cell_width;
}

pub const Item = enum {
    PAD,
    BLOCK,
    EMPTY,
};

pub const InvCell = struct {
    pos: rl.Vector2,
    width: f32,
    height: f32,
    type: Item,
    padding: f32 = SLOT_PADDING,
    isSelected: bool = false,
};

pub const Inventory = struct {
    pos: rl.Vector2,
    width: f32,
    height: f32,
    size: usize,

    slots: []InvCell,

    pub fn selfReturn() Inventory {
        return inv;
    }

    pub fn init(allocator: std.mem.Allocator) !void {
        const grid: Grid = Grid.selfReturn();

        const slots = try allocator.alloc(InvCell, SLOT_NB);

        const inventory_width: f32 = grid.width / 2;

        slotSizeInit(inventory_width, grid.cells[0][0].width, grid.cells[0][0].height);

        const inventory_height: f32 = SLOT_HEIGHT;
        const x = grid.x + grid.width / 4;
        const y = grid.y + grid.height + INV_MARGIN;

        for (0..SLOT_NB) |i| {
            const i_cast: f32 = @as(f32, @floatFromInt(i));

            slots[i] = InvCell{
                .pos = .init(x + i_cast * SLOT_WIDTH + SLOT_PADDING, y + SLOT_PADDING),
                .width = SLOT_WIDTH - 2 * SLOT_PADDING,
                .height = SLOT_HEIGHT - 2 * SLOT_PADDING,
                .type = Item.PAD,
            };
        }

        inv.pos.x = x;
        inv.pos.y = y;
        inv.width = inventory_width;
        inv.height = inventory_height;
        inv.size = SLOT_NB;
        inv.slots = slots;
    }

    fn slotManagement() void {
        //const hud: HUD = HUD.selfReturn();

        if (HUD.cursorInInventory()) {
            for (0..SLOT_NB) |i| {
                inv.slots[i].isSelected = false;
                if (HUD.cursorInSlot(inv.slots[i])) {
                    inv.slots[i].isSelected = true;
                }
            }
            //std.debug.print("INSIDE\n", .{});

        }

        //std.debug.print("OUTSIDE\n", .{});
    }

    pub fn interactions(self: *Inventory) void {
        slotManagement();
        _ = self;
    }
};
