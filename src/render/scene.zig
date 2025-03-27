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

            const x: i32 = @intFromFloat(cell.x);
            const y: i32 = @intFromFloat(cell.y);
            const width: i32 = @intFromFloat(cell.width);
            const height: i32 = @intFromFloat(cell.height);

            switch (cell.type) {
                CellType.AIR => rl.drawRectangleLines(x, y, width, height, .black),
                CellType.GROUND => rl.drawRectangle(x, y, width, height, .blue),
                else => unreachable,
            }
        }
    }
}

pub fn drawElf() void {
    rl.drawTextureEx(textures.elf, rl.Vector2.init(player.elf.x, player.elf.y), 0, 0.1, .white);
}
