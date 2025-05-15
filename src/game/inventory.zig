const rl = @import("raylib");
const Grid = @import("grid.zig").Grid;
const CellType = @import("grid.zig").CellType;
const std = @import("std");
const HUD = @import("utils.zig").HUD;
const Object = @import("terrain_object.zig").Object;

pub var inv: Inventory = undefined;

const SLOT_NB: usize = 4;

var SLOT_WIDTH: f32 = undefined;
var SLOT_HEIGHT: f32 = undefined;

const SLOT_PADDING: f32 = 15;
const INV_MARGIN: f32 = 10;

fn slotSizeInit(inventory_width: f32, cell_width: f32, cell_height: f32) void {
    SLOT_WIDTH = inventory_width / @as(f32, @floatFromInt(SLOT_NB));
    SLOT_HEIGHT = ((cell_height - 15) * SLOT_WIDTH) / cell_width;
}

pub const InvCell = struct {
    pos: rl.Vector2,
    width: f32,
    height: f32,
    object: Object,
    padding: f32 = SLOT_PADDING,
    isSelected: bool = false,
};

pub const Inventory = struct {
    pos: rl.Vector2,
    width: f32,
    height: f32,
    size: usize,
    cell: Object = Object{ .type = .EMPTY },
    slots: []InvCell,
    anySlotSelected: bool = true,

    pub fn selfReturn() Inventory {
        return inv;
    }

    pub fn init(allocator: std.mem.Allocator) !void {
        const grid: Grid = Grid.selfReturn();

        const slots = try allocator.alloc(InvCell, SLOT_NB);

        const inventory_width: f32 = grid.width / 3;

        slotSizeInit(inventory_width, grid.cells[0][0].width, grid.cells[0][0].height);

        const inventory_height: f32 = SLOT_HEIGHT;
        const x = grid.x + grid.width / 3 - SLOT_PADDING;
        const y = grid.y + grid.height + INV_MARGIN;

        var slot_x = x + SLOT_PADDING / 3;

        for (0..SLOT_NB) |i| {
            // const i_cast: f32 = @as(f32, @floatFromInt(i));

            slots[i] = InvCell{
                .pos = .init(slot_x, y + SLOT_PADDING / 5),
                .width = SLOT_WIDTH - SLOT_PADDING,
                .height = SLOT_HEIGHT,
                .object = Object{ .type = CellType.EMPTY },
            };

            slot_x += SLOT_WIDTH + SLOT_PADDING / 2;
        }

        //Harcode
        //slots[1].type = CellType.GROUND;
        //slots[2].type = CellType.SPIKE;

        inv.pos.x = x;
        inv.pos.y = y;
        inv.width = inventory_width;
        inv.height = inventory_height;
        inv.size = SLOT_NB;
        inv.slots = slots;
        Inventory.clearinv_cell();
    }

    pub fn slotSetting(objects: []Object) void {
        if (invEmpty()) {
            for (0..SLOT_NB) |i| {
                inv.slots[i].object.type = objects[i].type;
                inv.slots[i].object.count = 0;
                if (inv.slots[i].object.type != .EMPTY) {
                    inv.slots[i].object.count = objects[i].count;
                }
            }
        }
    }

    pub fn clear() void {
        for (0..SLOT_NB) |i| {
            inv.slots[i].object.type = CellType.EMPTY;
        }
    }

    pub fn invEmpty() bool {
        for (0..SLOT_NB) |i| {
            if (inv.slots[i].object.type != CellType.EMPTY) {
                return false;
            }
        }
        return true;
    }

    fn increaseSlotCount(i_slot: usize) void {
        if (inv.slots[i_slot].object.type != .EMPTY) {
            inv.slots[i_slot].object.count += 1;
        }
    }

    fn decreaseSlotCount(i_slot: usize) void {
        if (inv.slots[i_slot].object.type != .EMPTY and inv.slots[i_slot].object.count > 0) {
            inv.slots[i_slot].object.count -= 1;
        }
    }

    pub fn cacheEmpty() bool {
        return inv.cell.type == CellType.EMPTY;
    }

    fn remove(current: usize, cell: CellType) void {
        const object_size: usize = Object.objectSize(cell);

        decreaseSlotCount(current);

        if (inv.slots[current].object.count == 0) {
            inv.slots[current].object.type = .EMPTY;

            if (object_size == 1) {
                return;
            }

            if (current < inv.size - 1 and inv.slots[current + 1].object.type == cell) {
                decreaseSlotCount(current + 1);
                inv.slots[current + 1].object.type = .EMPTY;

                return;
            }

            if (current > 0 and inv.slots[current - 1].object.type == cell) {
                decreaseSlotCount(current - 1);
                inv.slots[current - 1].object.type = .EMPTY;
                return;
            }
        }
    }

    fn place(current: usize, cell: CellType) bool {
        const object_size: usize = Object.objectSize(cell);
        const slot = inv.slots[current].object.type;

        if (cell == .EMPTY or cell == .BOOST) {
            return false;
        }

        if (slot == cell) {
            return true;
        }

        if (slot == .EMPTY) {
            if (object_size == 1) {
                inv.slots[current].object.type = cell;
                return true;
            }
            if (current + 1 < inv.size and inv.slots[current + 1].object.type == .EMPTY) {
                inv.slots[current].object.type = cell;
                inv.slots[current + 1].object.type = cell;

                increaseSlotCount(current + 1);

                return true;
            }

            if (current > 0 and inv.slots[current - 1].object.type == .EMPTY) {
                inv.slots[current].object.type = cell;
                inv.slots[current - 1].object.type = cell;

                increaseSlotCount(current - 1);
                return true;
            }
        }
        return false;
    }

    fn cellRemaings(invCell: []InvCell) usize {
        var counter: usize = 0;
        for (invCell) |cell| {
            if (cell.object.type == .EMPTY) {
                counter += 1;
            }
        }
        return counter;
    }

    pub fn unselectSlots() void {
        for (0..SLOT_NB) |i| {
            inv.slots[i].isSelected = false;
        }
    }

    fn slotManagement() void {
        //const grid: Grid = Grid.selfReturn();
        unselectSlots();

        inv.anySlotSelected = HUD.cursorInInventory();
        if (HUD.cursorInInventory()) {
            for (0..SLOT_NB) |i| {
                if (HUD.cursorInSlot(inv.slots[i])) {
                    inv.slots[i].isSelected = true;

                    if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
                        // std.debug.print("\n========================================= \n", .{});
                        // for (inv.slots) |it| {
                        //     std.debug.print("\n Object : {any} \n", .{it.object});
                        // }

                        if (inv.cell.type == CellType.EMPTY and inv.slots[i].object.type != .EMPTY) {

                            //Take Item fom Inventory
                            inv.cell.type = inv.slots[i].object.type;
                            remove(i, inv.slots[i].object.type);
                            continue;
                        }

                        if (place(i, inv.cell.type)) {
                            increaseSlotCount(i);
                            inv.cell.type = CellType.EMPTY;
                        }
                    }
                }
            }
        }
    }

    pub fn clearinv_cell() void {
        inv.cell.type = CellType.EMPTY;
    }

    pub fn setinv_cell(cell: CellType) void {
        inv.cell.type = cell;
    }

    pub fn interactions(self: *Inventory) void {
        slotManagement();
        _ = self;
    }
};
