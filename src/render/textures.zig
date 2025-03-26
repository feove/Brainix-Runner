const rl = @import("raylib");

pub var elf: rl.Texture2D = undefined;

pub fn texturesInit() !void {
    elf = try rl.loadTexture("assets/textures/elf/pers.png");
}
