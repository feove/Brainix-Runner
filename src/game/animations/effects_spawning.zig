const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;

const anim = @import("animations_manager.zig");
const Elf = @import("../../entity/elf.zig").Elf;
const Wizard = @import("../../entity/wizard.zig").Wizard;
const Object = @import("../terrain_object.zig").Object;
const Grid = @import("../../terrain/grid.zig").Grid;
const events = @import("../level/events.zig");
const Event = events.Event;
const Level = events.Level;

pub var effect_anim: EffectManager = EffectManager{};

pub const EffectAnimation = enum {
    NONE,
    SPAWNING,
};

pub const EffectManager = struct {
    current: EffectAnimation = .NONE,
    prev: EffectAnimation = .NONE,

    pub fn reset() void {
        EffectManager.setCurrent(.NONE);
        EffectManager.setPrev(.NONE);
    }

    pub fn setCurrent(animation: EffectAnimation) void {
        effect_anim.current = animation;
    }

    pub fn setPrev(animation: EffectAnimation) void {
        effect_anim.prev = animation;
    }

    pub fn getPreviousAnim() EffectAnimation {
        return effect_anim.prev;
    }

    pub fn getCurrentAnim() EffectAnimation {
        return effect_anim.current;
    }

    pub fn update() void {
        switch (effect_anim.current) {
            .SPAWNING => item_spawning(),
            .NONE => none(),
        }
    }

    pub fn onceTime(animation: EffectAnimation) bool {
        const alreadyPlayed: bool = getPreviousAnim() == animation;

        //   print("{} {}\n", .{ getCurrentAnim(), getPreviousAnim() });
        if (!alreadyPlayed) {
            if (getCurrentAnim() != animation) {
                // EffectManager.setCurrent(.SPAWNING);
                setCurrent(animation);
            }
        }
        return !alreadyPlayed;
    }

    fn none() void {
        effect_anim.current = .NONE;
        effect_anim.prev = .NONE;
    }

    pub fn item_spawning() void {
        const event: Event = Level.getCurrentEvent().*;
        const objects = event.grid_objects;
        const size = event.object_nb;

        setCurrent(.SPAWNING);
        //setPrev(.NONE);

        for (0..size) |i| {
            const pos: rl.Vector2 = Grid.getFrontEndPostion(objects[i].x, objects[i].y);

            anim.spawning_item.isRunning = true;
            //anim.spawning_item.isRunning = true;
            anim.spawning_item.update(Elf.getCurrentTime(), 1);
            anim.spawning_item.draw(.init(pos.x, pos.y), 3.50, 0, 255, 0, 0); //sale : 3.5
            //  print("Item Spawning\n at x {d} ||y {d}\n", .{ pos.x, pos.y });
        }

        if (anim.spawning_item.isRunning == false) {
            effect_anim.prev = .SPAWNING;
            effect_anim.current = .NONE;
        }
    }
};
