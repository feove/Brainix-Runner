const rl = @import("raylib");

pub const Window = struct {};

pub fn windowInit(screenWidth: i32, screenHeight: i32) void {
    rl.initWindow(screenWidth, screenHeight, "Brainix Runner");
}
