const rl = @import("raylib");

const scene = @import("scene.zig");
pub const Window = struct {};

pub fn windowInit(screenWidth: i32, screenHeight: i32) void {
    rl.initWindow(screenWidth, screenHeight, "Brainix Runner");
}

pub fn render() void {
    scene.drawScene();
}
