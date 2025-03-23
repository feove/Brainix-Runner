const rl = @import("raylib");
const Grid = @import("../game/grid.zig").Grid;

pub fn windowInit() void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "Brainix Runner");
}

//Tmp Test
pub fn drawScene() void {
    rl.beginDrawing();
    defer rl.endDrawing();

    rl.clearBackground(.white);
}
