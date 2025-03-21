const rl = @import("raylib");

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "basic window");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        // Update
        
        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.light_gray);
    }
}
