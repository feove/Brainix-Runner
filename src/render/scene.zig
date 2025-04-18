const Grid = @import("../game/grid.zig").Grid;
const CellType = @import("../game/grid.zig").CellType;
const rl = @import("raylib");
const textures = @import("textures.zig");
const player = @import("../game/player.zig");

//Tmp Drawing
pub fn drawScene() void {
    rl.clearBackground(.white);

    const grid: Grid = Grid.selfReturn();

    for (0..grid.nb_rows) |r| {
        for (0..grid.nb_cols) |c| {
            const cell = grid.cells[r][c];

            const p = cell.padding;
            const x: i32 = @as(i32, @intFromFloat(cell.x)) + p;
            const y: i32 = @as(i32, @intFromFloat(cell.y)) + p;
            const width: i32 = @as(i32, @intFromFloat(cell.width)) - 2 * p;
            const height: i32 = @as(i32, @intFromFloat(cell.height)) - 2 * p;

            rl.drawRectangleLines(x - p, y - p, width + 2 * p, height + 2 * p, .black);
            switch (cell.type) {
                CellType.AIR => rl.drawRectangleLines(x - p, y - p, width + 2 * p, height + 2 * p, .black),
                CellType.GROUND => rl.drawRectangle(x, y, width, height, .blue),
                else => unreachable,
            }

            if (cell.isSelected) {
                rl.drawRectangleLines(x, y, width, height, .gray);
            }
        }
    }

    player.elf.drawElf();
}
