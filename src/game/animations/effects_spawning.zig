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

pub const EffectAnimation = enum { NONE, SPAWNING, DESPAWNING };

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
            .DESPAWNING => item_despawning(),
            .NONE => none(),
        }
    }

    pub fn onceTime(animation: EffectAnimation) bool {
        const alreadyPlayed: bool = getPreviousAnim() == animation;

        //   print("{} {}\n", .{ getCurrentAnim(), getPreviousAnim() });
        if (!alreadyPlayed) {
            if (getCurrentAnim() != animation) {
                setCurrent(animation);
            }
        }
        return !alreadyPlayed;
    }

    fn none() void {}

    pub fn item_despawning() void {
        const event: Event = Level.getPreviousEvent().*;
        const objects = event.grid_objects;
        const size = event.object_nb;
        anim.square_despawning_item.isRunning = true;
        anim.spike_despawning_item.isRunning = true;

        for (0..size) |i| {
            const pos: rl.Vector2 = Grid.getFrontEndPostion(objects[i].x, objects[i].y);

            if (objects[i].type == .GROUND) {
                anim.square_despawning_item.update(Elf.getCurrentTime() / 2, 1);
                anim.square_despawning_item.draw(.init(pos.x, pos.y), 3.50, 0, 255, 0, 0); //sale : 3.5
                continue;
            }
            anim.spike_despawning_item.update(Elf.getCurrentTime() / 2, 1);
            anim.spike_despawning_item.draw(.init(pos.x, pos.y), 3.50, 0, 255, 0, 0); //sale : 3.5

        }

        if (anim.square_despawning_item.isRunning == false or anim.spike_despawning_item.isRunning == false) {
            effect_anim.prev = .DESPAWNING;
            effect_anim.current = .NONE;
        }
    }

    pub fn item_spawning() void {
        const event: Event = Level.getCurrentEvent().*;
        const objects = event.grid_objects;
        const size = event.object_nb;

        anim.spawning_item.isRunning = true;

        for (0..size) |i| {
            const pos: rl.Vector2 = Grid.getFrontEndPostion(objects[i].x, objects[i].y);

            anim.spawning_item.update(Elf.getCurrentTime(), 1);
            anim.spawning_item.draw(.init(pos.x, pos.y), 3.50, 0, 255, 0, 0); //sale : 3.5
        }

        if (anim.spawning_item.isRunning == false) {
            effect_anim.prev = .SPAWNING;
            effect_anim.current = .NONE;
        }
    }
};
