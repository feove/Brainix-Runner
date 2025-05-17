const rl = @import("raylib");
const demon_anims = @import("../game/animations/demon_anims.zig");
const textures = @import("../render/textures.zig");

pub var demon: Demon = undefined;

const DEFAULT_POSITION: rl.Vector2 = .init(100, 0);
const TEXTURE_SIZE: rl.Vector2 = .init(100, 100);

pub fn init() void {
    demon = Demon{
        .x = DEFAULT_POSITION.x,
        .y = DEFAULT_POSITION.y,
        .width = TEXTURE_SIZE.x,
        .height = TEXTURE_SIZE.y,

        .animator = demon_anims.demon_anim,
    };
}

pub const Demon = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    animator: demon_anims.DemonManager,

    pub fn draw() void {
        demon_anims.demon_anim.update(&demon);
    }
};
