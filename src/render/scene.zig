const print = @import("std").debug.print;
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

            drawcell(cell.x, cell.y, cell.width, cell.height, 0, false, .black);

            switch (cell.object.type) {
                CellType.AIR => drawcell(cell.x, cell.y, cell.width, cell.height, 0, false, .black),
                CellType.GROUND => drawcell(cell.x, cell.y, cell.width, cell.height, 0, true, .blue),
                CellType.SPIKE => drawSpike(cell.x, cell.y, cell.width, cell.height, cell.padding, .red),
                CellType.PAD => drawcell(cell.x, cell.y + cell.height - cell.height / 4, cell.width, cell.height / 3, cell.padding, true, .yellow),
                else => drawcell(cell.x, cell.y, cell.width, cell.height, 0, true, .gray),
            }

            if (cell.isSelected) {
                drawcell(cell.x, cell.y, cell.width, cell.height, cell.padding, false, .black);
            }
        }
    }
}

fn drawInventory() void {
    const inv = Inventory.selfReturn();

    //Draw Inventory Borders
    drawcell(inv.pos.x, inv.pos.y, inv.width, inv.height, 0, false, .black);

    for (0..inv.size) |i| {
        const slot = inv.slots[i];

        switch (slot.object.type) {
            CellType.GROUND => drawcell(slot.pos.x, slot.pos.y, slot.width, slot.height, 0, true, .blue),
            CellType.SPIKE => drawSpike(slot.pos.x, slot.pos.y - slot.padding, slot.width, slot.height + slot.padding, slot.padding, .red),
            CellType.AIR => drawcell(slot.pos.x, slot.pos.y, slot.width, slot.height, 0, true, .white),
            CellType.EMPTY => drawcell(slot.pos.x, slot.pos.y, slot.width, slot.height, 0, true, .gray),
            CellType.PAD => drawcell(slot.pos.x, slot.pos.y + slot.height - slot.height / 4, slot.width, slot.height / 4, 0, true, .yellow),
            else => {},
        }
        if (i != inv.size - 1) {
            drawLines(slot.pos.x + slot.width + slot.padding, inv.pos.y, slot.pos.x + slot.width + slot.padding, inv.pos.y + inv.height);
        }

        if (slot.isSelected) {
            drawcell(slot.pos.x, slot.pos.y, slot.width, slot.height, -slot.padding / 2, false, .gray);
        }
    }
}

//Casting de cons
fn drawcell(x_f32: f32, y_f32: f32, width_f32: f32, height_f32: f32, padding: f32, fill: bool, color: rl.Color) void {
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

fn drawSpike(x: f32, y: f32, width: f32, height: f32, padding: f32, color: rl.Color) void {
    rl.drawTriangle(.init(x + width / 2, y + 2 * padding), .init(x + 2 * padding, y + height), .init(x + width - 2 * padding, y + height), color);
    rl.drawTriangleLines(.init(x + width / 2, y + 2 * padding), .init(x + 2 * padding, y + height), .init(x + width - 2 * padding, y + height), .black);
}
