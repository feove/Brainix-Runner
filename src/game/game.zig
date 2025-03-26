const scene = @import("../render/scene.zig");

pub fn run() void {
    render();
}

pub fn render() void {
    scene.drawScene();
    scene.drawElf();
}
