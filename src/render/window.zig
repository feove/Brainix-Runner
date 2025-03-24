const rl = @import("raylib");
const Grid = @import("../game/grid.zig").Grid;

pub const Window = struct {};

pub fn windowInit(screenWidth: i32, screenHeight: i32) void {
    rl.initWindow(screenWidth, screenHeight, "Brainix Runner");
}

//Tmp Test
pub fn drawScene(grid: Grid) void {
    rl.beginDrawing();
    defer rl.endDrawing();

    rl.clearBackground(.white);

    for (0..grid.nb_rows) |r| {
        for (0..grid.nb_cols) |c| {

            //rl.drawRectangleRec(rl.Rectangle.init(grid.cells[r][c].x, grid.cells[r][c].y, grid.cells[r][c].width, grid.cells[r][c].height), rl.Color.black);

            const x: i32 = @intFromFloat(grid.cells[r][c].x);
            const y: i32 = @intFromFloat(grid.cells[r][c].y);
            const width: i32 = @intFromFloat(grid.cell_width);
            const height: i32 = @intFromFloat(grid.cell_height);

            rl.drawRectangleLines(x, y, width, height, rl.Color.black);
        }
    }
}
