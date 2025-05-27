const rl = @import("raylib");
const Interface = @import("hud.zig").Interface;

const textures = @import("../render/textures.zig");
const Sprite = textures.Sprite;

pub const Selector = struct {
    cur_slot: usize = 0,
    prev_slot: usize = 0,
    max_range: usize,
    min_range: usize = 0,
    controls_sprites: []Sprite,
    controls_keys: []rl.KeyboardKey,

    pub fn increasCurrent(self: *Selector) void {
        const inc: usize = if (self.cur_slot < self.max_range) 1 else 0;
        self.cur_slot += inc;
    }

    pub fn decreasCurrent(self: *Selector) void {
        const inc: usize = if (self.cur_slot > 0) 1 else 0;
        self.cur_slot -= inc;
    }

    pub fn currentSprite() Sprite {
        const interface = Interface.SelfReturn();
        return interface.selector.controls_sprites[interface.selector.cur_slot];
    }
};
