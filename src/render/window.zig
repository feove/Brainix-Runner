const rl = @import("raylib");
const std = @import("std");
const stdout = std.io.getStdOut().writer();
pub const Window = struct {};

pub fn windowInit(screenWidth: i32, screenHeight: i32) void {
    rl.initWindow(screenWidth, screenHeight, "Brainix Runner");
}

pub fn clear() void {
    stdout.writeAll("\x1b[2J\x1b[H") catch {};
}
