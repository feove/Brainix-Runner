const rl = @import("raylib");
const wizard_anims = @import("../game/animations/wizard_anims.zig");
const effect_anims = @import("../game/animations/effects_spawning.zig");
const textures = @import("../render/textures.zig");

pub var wizard: Wizard = undefined;

const DEFAULT_POSITION: rl.Vector2 = .init(250, -50);
const TEXTURE_SIZE: rl.Vector2 = .init(231, 190);
const SCALE: f32 = 2.0;

pub fn init() void {
    wizard = Wizard{
        .x = DEFAULT_POSITION.x,
        .y = DEFAULT_POSITION.y,
        .width = TEXTURE_SIZE.x,
        .height = TEXTURE_SIZE.y,
        .scale = SCALE,
        .animator = wizard_anims.wizard_anim,
    };
}

pub const Wizard = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    scale: f32,
    animator: wizard_anims.WizardManager,

    pub fn draw() void {
        wizard_anims.wizard_anim.update(&wizard);
        effect_anims.EffectManager.update();
    }
};
