const std = @import("std");
const print = std.debug.print;
const rl = @import("raylib");

const inventory = @import("../game/inventory.zig");
const Inventory = inventory.Inventory;
const textures = @import("../render/textures.zig");
const Sprite = textures.Sprite;

pub var interface: Interface = undefined;

pub var DefaultControlConfig: []Sprite = undefined;

pub const Selector = struct {
    cur_slot: usize = 0,
    prev_slot: usize = 0,
    max_range: usize,
    min_range: usize = 0,
    controls: []Sprite,

    pub fn increasCurrent(self: *Selector) void {
        const inc: usize = if (self.cur_slot < self.max_range) 1 else 0;
        self.cur_slot += inc;
    }

    pub fn decreasCurrent(self: *Selector) void {
        const inc: usize = if (self.cur_slot > 0) 1 else 0;
        self.cur_slot -= inc;
    }

    pub fn indexAssignToKey(index: usize) Sprite {
        return interface.selector.controls[index];
    }

    pub fn currentSprite() Sprite {
        return interface.selector.controls[interface.selector.cur_slot];
    }
};

pub const Interface = struct {
    selector: Selector,
    pub fn init(allocator: std.mem.Allocator) !void {
        DefaultControlConfig = try allocator.alloc(Sprite, inventory.SLOT_NB);

        DefaultControlConfig[0] = textures.keyboard_sprites.d;
        DefaultControlConfig[1] = textures.keyboard_sprites.d;
        DefaultControlConfig[2] = textures.keyboard_sprites.d;
        DefaultControlConfig[3] = textures.keyboard_sprites.d;

        interface = Interface{
            .selector = Selector{
                .max_range = inventory.SLOT_NB,
                .controls = DefaultControlConfig,
            },
        };
    }

    pub fn SelfReturn() Interface {
        return interface;
    }
};
