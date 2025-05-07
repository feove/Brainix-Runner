const print = @import("std").debug.print;
const std = @import("std");
const Grid = @import("../game/grid.zig").Grid;
const CellType = @import("../game/grid.zig").CellType;
const rl = @import("raylib");
const textures = @import("textures.zig");
const Sprite = @import("textures.zig").Sprite;
const player = @import("../game/player.zig");
const Inventory = @import("../game/inventory.zig").Inventory;

//Tmp Drawing
pub fn drawScene() !void {
    rl.clearBackground(.white);

    drawGrid();
    try drawInventory();
    player.elf.drawElf();
}

fn drawGrid() void {
    textures.Sprite.draw(textures.forest_background, textures.sprites.forest_background, .init(0, 0), 0.85);

    const grid: Grid = Grid.selfReturn();

    for (0..grid.nb_rows) |r| {
        for (0..grid.nb_cols) |c| {
            const cell = grid.cells[r][c];

            drawcell(cell.x, cell.y, cell.width, cell.height, 0, false, .black);

            if (r < grid.nb_rows - 2) {
                switch (cell.object.type) {
                    .AIR => drawcell(cell.x, cell.y, cell.width, cell.height, 0, false, .black),
                    .GROUND => Sprite.draw(textures.spriteSheet, textures.sprites.granite_pure_l4, rl.Vector2{ .x = cell.x, .y = cell.y }, 4.15),
                    .SPIKE => drawSpike(cell.x, cell.y, cell.width, cell.height, cell.padding, .red),
                    .PAD => drawcell(cell.x, cell.y + cell.height - cell.height / 4, cell.width, cell.height / 3, cell.padding, true, .yellow),
                    .UP_PAD => drawcell(cell.x, cell.y + cell.height - cell.height / 4, cell.width, cell.height / 3, cell.padding, true, .orange),
                    .DOOR => drawcell(cell.x, cell.y, cell.width, cell.height, 0, true, .brown),
                    .BOOST => drawcell(cell.x, cell.y, cell.width, cell.height, 0, true, .beige),
                    else => drawcell(cell.x, cell.y, cell.width, cell.height, 0, true, .gray),
                }
            }

            if (cell.isSelected) {
                drawcell(cell.x, cell.y, cell.width, cell.height, cell.padding, false, .black);
            }
        }
    }
    drawGround();
}

fn drawGround() void {
    const grid: Grid = Grid.selfReturn();

    for (grid.nb_rows - 2..grid.nb_rows) |r| {
        for (0..grid.nb_cols) |c| {
            const cell = grid.cells[r][c];

            if (c == 0 or c == grid.nb_cols - 1) {
                if (r == grid.nb_rows - 2) {
                    Sprite.draw(textures.spriteSheet, textures.sprites.carved_granite, rl.Vector2{ .x = cell.x, .y = cell.y }, 4.15);
                    Sprite.draw(textures.spriteSheet, textures.sprites.granite_pillar, rl.Vector2{ .x = cell.x, .y = cell.y + cell.height }, 4.15);
                }
                continue;
            }

            if (r == grid.nb_rows - 2) {
                Sprite.draw(textures.spriteSheet, textures.sprites.granite_beam, rl.Vector2{ .x = cell.x, .y = cell.y }, 4.15);

                //Scripted
                if (c == 2 or c == 5 or c == 9) {
                    Sprite.draw(textures.spriteSheet, textures.sprites.granite_pure_l4, rl.Vector2{ .x = cell.x, .y = cell.y }, 4.15);
                    Sprite.draw(textures.spriteSheet, textures.sprites.granite_pure_l3, rl.Vector2{ .x = cell.x, .y = cell.y + cell.height }, 4.15);
                }

                continue;
            }

            if (c != 2 and c != 5 and c != 9) {
                Sprite.draw(textures.spriteSheet, textures.sprites.granite_l3, rl.Vector2{ .x = cell.x, .y = cell.y + 1 }, 4.15);
            }
        }
    }
}

pub fn getRandomNumber(min: u32, max: u32) u32 {
    // var prng = std.rand.DefaultPrng.init(@as(u64, @bitCast(std.time.milliTimestamp())));
    var prng = std.Random.DefaultPrng.init(@as(u64, @bitCast(std.time.milliTimestamp())));
    return prng.random().intRangeAtMost(u32, min, max);
}

fn drawInventory() !void {
    const inv = Inventory.selfReturn();

    //Draw Inventory Borders
    drawcell(inv.pos.x, inv.pos.y, inv.width, inv.height, 0, false, .black);

    for (0..inv.size) |i| {
        const slot = inv.slots[i];

        switch (slot.object.type) {
            .GROUND => Sprite.draw(textures.spriteSheet, textures.sprites.granite_pure_l4, rl.Vector2{ .x = slot.pos.x + slot.padding, .y = slot.pos.y }, 4.1),
            .SPIKE => drawSpike(slot.pos.x, slot.pos.y - slot.padding, slot.width, slot.height + slot.padding, slot.padding, .red),
            .AIR => drawcell(slot.pos.x, slot.pos.y, slot.width, slot.height, 0, true, .white),
            .EMPTY => drawcell(slot.pos.x, slot.pos.y, slot.width, slot.height, 0, true, .gray),
            .PAD => drawcell(slot.pos.x, slot.pos.y + slot.height - slot.height / 4, slot.width, slot.height / 4, 0, true, .yellow),
            .UP_PAD => drawcell(slot.pos.x, slot.pos.y + slot.height - slot.height / 4, slot.width, slot.height / 4, 0, true, .orange),
            .BOOST => drawcell(slot.pos.x, slot.pos.y, slot.width, slot.height, 0, true, .beige),
            else => {},
        }
        if (i != inv.size - 1) {
            drawLines(slot.pos.x + slot.width + slot.padding, inv.pos.y, slot.pos.x + slot.width + slot.padding, inv.pos.y + inv.height);
        }

        if (slot.isSelected) {
            drawcell(slot.pos.x, slot.pos.y, slot.width, slot.height, -slot.padding / 2, false, .gray);
        }
    }

    try drawItemNumber();
}

fn drawItemNumber() !void {
    const inv = Inventory.selfReturn();

    for (0..inv.size) |i| {
        const x: i32 = @as(i32, @intFromFloat(inv.slots[i].pos.x + inv.slots[i].width - 2 * inv.slots[i].padding));
        const y: i32 = @as(i32, @intFromFloat(inv.slots[i].pos.y));
        if (inv.slots[i].object.type != .EMPTY) {
            const slot = inv.slots[i].object;

            if (i > 0 and slot.type == .BOOST and inv.slots[i - 1].object.type == .BOOST) {
                continue;
            }
            var buf: [16:0]u8 = undefined; // Note the ':0' for null-terminated buffer
            const numAsString = try std.fmt.bufPrintZ(&buf, "{}", .{slot.count});
            rl.drawText(numAsString, x, y, 30, .black);
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
