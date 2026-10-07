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

    pub fn SelfReturn() Selector {
        return Interface.SelfReturn().selector;
    }

    pub fn getLastTaken() usize {
        return Interface.SelfReturn().selector.last_taken;
    }

    pub fn setLastTaken(last_taken: usize) void {
        Interface.SelfReturn().selector.last_taken = last_taken;
    }

    pub fn increasCurrent(self: *Selector) void {
        const inc: usize = if (self.cur_slot < self.max_range) 1 else 0;
        self.cur_slot += inc;
    }

    pub fn decreasCurrent(self: *Selector) void {
        const inc: usize = if (self.cur_slot > 0) 1 else 0;
        self.cur_slot -= inc;
    }

    pub fn indexToSprite(index: usize) Sprite {
        const selector = Interface.getSelector();
        return selector.controls_sprites[index];
    }

    pub fn keyIsPressed() bool {
        const selector = Interface.getSelector();
        return getIndexKey() != selector.max_range;
    }

    pub fn getIndexKey() usize {
        const selector = Interface.getSelector();
        for (0..selector.max_range) |i| {
            if (rl.isKeyPressed(selector.controls_keys[i])) {
                return i;
            }
        }
        return selector.max_range;
    }
};
