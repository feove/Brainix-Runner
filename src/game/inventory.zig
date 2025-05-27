const rl = @import("raylib");

const terrain = @import("../terrain/grid.zig");
const Grid = terrain.Grid;
const CellType = terrain.CellType;

const std = @import("std");
const CursorManager = @import("utils.zig").CursorManager;
const Object = @import("terrain_object.zig").Object;
const Areas = @import("../game/level/events.zig").Areas;
const EffectManager = @import("../game/animations/effects_spawning.zig").EffectManager;
const Selector = @import("../interface/selector.zig").Selector;
const Interface = @import("../interface/hud.zig").Interface;
pub var inv: Inventory = undefined;

pub const SLOT_NB: usize = 4;

var SLOT_WIDTH: f32 = undefined;
var SLOT_HEIGHT: f32 = undefined;

const SLOT_PADDING: f32 = 15;
const INV_MARGIN: f32 = 10;

pub var save_inv: []InvCell = undefined;

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

    pub fn selfReturn() Inventory {
        return inv;
    }

    pub fn init(allocator: std.mem.Allocator) !void {
        const grid: Grid = Grid.selfReturn();

        const slots = try allocator.alloc(InvCell, SLOT_NB);
        save_inv = try allocator.alloc(InvCell, SLOT_NB);

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
                // if (inv.slots[i].object.type != .EMPTY and inv.slots[i].object.key != Areas.getCurrentInterKey()) {
                //     std.debug.print("Areas Current Key {d}\n", .{Areas.getCurrentInterKey()});

                // }
                // std.debug.print("Areas Current Key : {d} == {d} : Key\n", .{ Areas.getCurrentInterKey(), objects[i].key });

                if (objects[i].key != Areas.getCurrentInterKey()) {
                    continue;
                }
                inv.slots[i].object.type = objects[i].type;
                inv.slots[i].object.count = 0;
                if (inv.slots[i].object.type != .EMPTY) {
                    inv.slots[i].object.count = objects[i].count;
                }
            }
        }
    }

    pub fn add(itemType: CellType) void {
        for (0..SLOT_NB) |i| {
            if (inv.slots[i].object.type == itemType) {
                inv.slots[i].object.count += 1;
                return;
            }

            if (inv.slots[i].object.type == .EMPTY) {
                inv.slots[i].object.count = 1;
                inv.slots[i].object.type = itemType;
                return;
            }
        }
    }

    pub fn clear() void {
        for (0..SLOT_NB) |i| {
            save_inv[i] = inv.slots[i];
            inv.slots[i].object.type = CellType.EMPTY;
            inv.slots[i].object.count = 0;
            // std.debug.print("save_inv[{d}] = {any} \n", .{ i, save_inv[i].object.type });
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

        const cursorInInventory = CursorManager.cursorInInventory();
        if (cursorInInventory) {
            for (0..SLOT_NB) |i| {
                if (CursorManager.cursorInSlot(inv.slots[i])) {
                    inv.slots[i].isSelected = true;

                    if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
                        if (tookItem(i)) continue;

                        if (place(i, inv.cell.type)) {
                            increaseSlotCount(i);
                            inv.cell.type = CellType.EMPTY;
                        }
                    }
                }
            }
        }

        std.debug.print("Last Taken {d}\n", .{Selector.SelfReturn().last_taken});

        if (Selector.keyIsPressed()) {
            const i = Selector.getIndexKey();
            if (tookItem(i)) return;

            swap(i);
        }
    }

    fn swap(i: usize) void {
        const last_taken: usize = Selector.SelfReturn().last_taken;
        const dest_type = inv.slots[last_taken].object.type;
        const src_type = inv.cell.type;

        if (dest_type != .EMPTY and dest_type != inv.cell.type) {
            return;
        }

        //Give Item Back
        if (dest_type == .EMPTY) {
            inv.slots[last_taken].object.type = src_type;
            inv.slots[last_taken].object.count = 1;
        } else {
            inv.slots[last_taken].object.count += 1;
        }

        inv.cell.type = inv.slots[i].object.type;
        decreaseSlotCount(i);
    }

    fn tookItem(i: usize) bool {
        if (inv.cell.type == CellType.EMPTY and inv.slots[i].object.type != .EMPTY) {

            //Take Item fom Inventory
            inv.cell.type = inv.slots[i].object.type;
            remove(i, inv.slots[i].object.type);
            Interface.SelfReturn().selector.last_taken = i;
            return true;
        }
        return false;
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
