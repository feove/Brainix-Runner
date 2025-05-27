const std = @import("std");
const print = std.debug.print;
const rl = @import("raylib");

const inventory = @import("../game/inventory.zig");
const Inventory = inventory.Inventory;
const Selector = @import("selector.zig").Selector;
const textures = @import("../render/textures.zig");

const Sprite = textures.Sprite;

pub var interface: Interface = undefined;

pub var controlHintSprites: []Sprite = undefined;
pub var controlKeys: []rl.KeyboardKey = undefined;

pub const Interface = struct {
    selector: Selector,
    pub fn init(allocator: std.mem.Allocator) !void {
        controlHintSprites = try allocator.alloc(Sprite, inventory.SLOT_NB);
        controlKeys = try allocator.alloc(rl.KeyboardKey, inventory.SLOT_NB);

        controlHintSprites[0] = textures.keyboard_sprites.d;
        controlHintSprites[1] = textures.keyboard_sprites.f;
        controlHintSprites[2] = textures.keyboard_sprites.e;
        controlHintSprites[3] = textures.keyboard_sprites.r;

        controlKeys[0] = rl.KeyboardKey.d;
        controlKeys[1] = rl.KeyboardKey.f;
        controlKeys[2] = rl.KeyboardKey.e;
        controlKeys[3] = rl.KeyboardKey.r;

        interface = Interface{
            .selector = Selector{
                .max_range = inventory.SLOT_NB,
                .controls_sprites = controlHintSprites,
                .controls_keys = controlKeys,
            },
        };
    }

    pub fn SelfReturn() Interface {
        return interface;
    }

    pub fn getSelector() Selector {
        return interface.selector;
    }
};
