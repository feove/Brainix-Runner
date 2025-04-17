const scene = @import("../render/scene.zig");
const player = @import("../game/player.zig");
const board = @import("../game/grid.zig");
const utils = @import("../game/utils.zig");
const rl = @import("raylib");

pub fn run() void {
    render();
}

pub fn render() void {
    rl.beginDrawing();
    defer rl.endDrawing();

    scene.drawScene();
    board.grid.interactions();
    player.elf.controller();
    player.elf.drawElf();
    utils.hud.refresh();
}
