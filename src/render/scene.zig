const Grid = @import("../game/grid.zig").Grid;
const CellType = @import("../game/grid.zig").CellType;
const rl = @import("raylib");
const textures = @import("textures.zig");
const player = @import("../game/player.zig");
const Inventory = @import("../game/inventory.zig").Inventory;

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
            const height_qrt: i32 = @as(i32, @intFromFloat(cell.height / 4 - 2 * p_f32));

            //empty cell
            rl.drawRectangleLines(x - p_i32, y - p_i32, width + 2 * p_i32, height + 2 * p_i32, .black);

            switch (cell.type) {
                CellType.AIR => rl.drawRectangleLines(x - p_i32, y - p_i32, width + 2 * p_i32, height + 2 * p_i32, .black),
                CellType.GROUND => rl.drawRectangle(x, y, width, height, .blue),
                CellType.OBSTACLE => rl.drawRectangle(x, y, width, height, .orange),
                CellType.PAD => {
                    rl.drawRectangle(x, y + height - height_qrt, width, height_qrt, .yellow);
                    rl.drawRectangleLines(x, y + height - height_qrt, width, height_qrt, .black);
                },
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

    //const p = @as(i32, @intFromFloat(inv.slots[0].padding));

    for (0..inv.size) |i| {
        const slot = inv.slots[i];

        switch (inv.slots[i].type) {
            CellType.GROUND => drawCell(slot.pos.x, slot.pos.y, slot.width, slot.height, 0, true, .blue),
            CellType.OBSTACLE => drawCell(slot.pos.x, slot.pos.y, slot.width, slot.height, 0, true, .orange),
            CellType.AIR => drawCell(slot.pos.x, slot.pos.y, slot.width, slot.height, 0, true, .white),
            CellType.EMPTY => drawCell(slot.pos.x, slot.pos.y, slot.width, slot.height, 0, true, .gray),
            CellType.PAD => {
                drawCell(slot.pos.x, slot.pos.y + slot.height - slot.height / 4, slot.width, slot.height / 4, 0, true, .yellow);
            },
        }
        if (i != inv.size - 1) {
            drawLines(slot.pos.x + slot.width + slot.padding, inv.pos.y, slot.pos.x + slot.width + slot.padding, inv.pos.y + inv.height);
        }

        if (slot.isSelected) {
            drawCell(slot.pos.x, slot.pos.y, slot.width, slot.height, -slot.padding / 2, false, .gray);
        }
    }
}

//Casting de cons
fn drawCell(x_f32: f32, y_f32: f32, width_f32: f32, height_f32: f32, padding: f32, fill: bool, color: rl.Color) void {
    const p: i32 = @as(i32, @intFromFloat(padding));
    const x: i32 = @as(i32, @intFromFloat(x_f32));
    const y: i32 = @as(i32, @intFromFloat(y_f32));
    const width: i32 = @as(i32, @intFromFloat(width_f32));
    const height: i32 = @as(i32, @intFromFloat(height_f32));
    if (fill) {
        rl.drawRectangle(x + p, y + p, width - 2 * p, height - 2 * p, color);
    }
    rl.drawRectangleLines(x + p, y + p, width - 2 * p, height - 2 * p, .black);
}

fn drawLines(xs_f32: f32, ys_f32: f32, xe_f32: f32, ye_f32: f32) void {
    const xs: i32 = @as(i32, @intFromFloat(xs_f32));
    const ys: i32 = @as(i32, @intFromFloat(ys_f32));
    const xe: i32 = @as(i32, @intFromFloat(xe_f32));
    const ye: i32 = @as(i32, @intFromFloat(ye_f32));

    rl.drawLine(xs, ys, xe, ye, .black);
}
