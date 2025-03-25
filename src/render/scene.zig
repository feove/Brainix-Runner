const Grid = @import("../game/grid.zig").Grid;
const rl = @import("raylib");

//Tmp Drawing
pub fn drawScene() void {
    rl.beginDrawing();
    defer rl.endDrawing();

    rl.clearBackground(.white);

    const grid: Grid = Grid.selfReturn();

    for (0..grid.nb_rows) |r| {
        for (0..grid.nb_cols) |c| {
            const x: i32 = @intFromFloat(grid.cells[r][c].x);
            const y: i32 = @intFromFloat(grid.cells[r][c].y);
            const width: i32 = @intFromFloat(grid.cell_width);
            const height: i32 = @intFromFloat(grid.cell_height);

            rl.drawRectangleLines(x, y, width, height, rl.Color.black);
        }
    }
}
