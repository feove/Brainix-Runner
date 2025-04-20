const Grid = @import("../game/grid.zig").Grid;
const CellType = @import("../game/grid.zig").CellType;
const rl = @import("raylib");
const textures = @import("textures.zig");
const player = @import("../game/player.zig");
const Inventory = @import("../game/inventory.zig").Inventory;
const Item = @import("../game/inventory.zig").Item;

//Tmp Drawing
pub fn drawScene() void {
    rl.clearBackground(.white);

    drawGrid();
    drawInventory();
    player.elf.drawElf();
}

fn drawGrid() void {
    const grid: Grid = Grid.selfReturn();

    for (0..grid.nb_rows) |r| {
        for (0..grid.nb_cols) |c| {
            const cell = grid.cells[r][c];

            const p_f32 = cell.padding;
            const p_i32 = @as(i32, @intFromFloat(cell.padding));

            const x: i32 = @as(i32, @intFromFloat(cell.x + p_f32));
            const y: i32 = @as(i32, @intFromFloat(cell.y + p_f32));
            const width: i32 = @as(i32, @intFromFloat(cell.width - 2 * p_f32));
            const height: i32 = @as(i32, @intFromFloat(cell.height - 2 * p_f32));

            //empty cell
            rl.drawRectangleLines(x - p_i32, y - p_i32, width + 2 * p_i32, height + 2 * p_i32, .black);

            switch (cell.type) {
                CellType.AIR => rl.drawRectangleLines(x - p_i32, y - p_i32, width + 2 * p_i32, height + 2 * p_i32, .black),
                CellType.GROUND => rl.drawRectangle(x, y, width, height, .blue),
                else => unreachable,
            }

            if (cell.isSelected) {
                rl.drawRectangleLines(x, y, width, height, .gray);
            }
        }
    }
}

fn drawInventory() void {
    const inv = Inventory.selfReturn();

    const x_inv: i32 = @as(i32, @intFromFloat(inv.pos.x));
    const y_inv: i32 = @as(i32, @intFromFloat(inv.pos.y));
    const width_inv: i32 = @as(i32, @intFromFloat(inv.width));
    const height_inv: i32 = @as(i32, @intFromFloat(inv.height));

    rl.drawRectangleLines(x_inv, y_inv, width_inv, height_inv, .black);

    const p = @as(i32, @intFromFloat(inv.slots[0].padding / 2));

    for (0..inv.size) |i| {
        const slot = inv.slots[i];
        const x: i32 = @as(i32, @intFromFloat(inv.slots[i].pos.x));
        const y: i32 = @as(i32, @intFromFloat(inv.slots[i].pos.y));
        const width: i32 = @as(i32, @intFromFloat(inv.slots[i].width));
        const height: i32 = @as(i32, @intFromFloat(inv.slots[i].height));

        switch (inv.slots[i].type) {
            Item.BLOCK => rl.drawRectangle(x, y, width, height, .blue),
            Item.PAD => rl.drawRectangle(x, y, width, height, .orange),
            Item.EMPTY => rl.drawRectangle(x, y, width, height, .white),
        }
        if (i != inv.size - 1) {
            rl.drawLine(x + width + 2 * p, y_inv, x + width + 2 * p, y_inv + height_inv, .black);
        }

        if (slot.isSelected) {
            rl.drawRectangleLines(x - p, y - p, width + 2 * p, height + 2 * p, .gray);
        }
    }
}
