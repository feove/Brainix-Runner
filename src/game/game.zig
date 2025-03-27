const scene = @import("../render/scene.zig");
const player = @import("../game/player.zig");
const rl = @import("raylib");

pub fn run() void {
    render();
}

pub fn render() void {
    rl.beginDrawing();
    defer rl.endDrawing();

    scene.drawScene();
    player.elf.controller();
    scene.drawElf();
}
