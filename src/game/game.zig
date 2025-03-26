const scene = @import("../render/scene.zig");
const player = @import("../game/player.zig");

pub fn run() void {
    player.elf.controller();
    render();
}

pub fn render() void {
    scene.drawElf();
    scene.drawScene();
}
