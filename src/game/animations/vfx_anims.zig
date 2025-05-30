const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;

const anim = @import("animations_manager.zig");
const Elf = @import("../../entity/elf.zig").Elf;
const Wizard = @import("../../entity/wizard.zig").Wizard;
const object = @import("../terrain_object.zig");
const Object = object.Object;
const Grid = @import("../../terrain/grid.zig").Grid;
const FlyingPlatform = @import("../../entity/flying_platform.zig").FlyingPlatform;
const inventory = @import("../inventory.zig");
const InvCell = inventory.InvCell;
const Inventory = inventory.Inventory;
const events = @import("../level/events.zig");
const Event = events.Event;
const Level = events.Level;
const Areas = events.Areas;

pub var effect_anim: EffectManager = EffectManager{};

pub const EffectAnimation = enum {
    NONE,
    SPAWNING,
    DESPAWNING,
    SMALL_LIGHTING_EFFECT,
    SCRATCH,
    ENTITY_SPAWN,
    WOOSH,
    SLOT_CLEANNING,
    FALLING_PLATFORM,
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
        //  print("Current Effect Anim {}\n", .{effect_anim.current});
        // if (getCurrentAnim() == .SLOT_CLEANNING and )

        switch (effect_anim.current) {
            .SPAWNING => item_spawning(),
            .DESPAWNING => item_despawning(),
            .SLOT_CLEANNING => slot_cleanning(),

            .SMALL_LIGHTING_EFFECT => small_lighting(),
            .SCRATCH => scratch(),
            .ENTITY_SPAWN => entity_spawn(),
            .WOOSH => woosh(),
            .FALLING_PLATFORM => falling_platform(),
            else => {},
        }
    }

    pub fn onceTime(animation: EffectAnimation) bool {
        const alreadyPlayed: bool = getPreviousAnim() == animation;

        if (!alreadyPlayed) {
            if (getCurrentAnim() != animation) {
                setCurrent(animation);
            }
        }
        return !alreadyPlayed;
    }

    pub fn falling_platform() void {
        //const elf: Elf = Elf.selfReturn();
        const endPos: rl.Vector2 = FlyingPlatform.getPosition();
        anim.falling_platform.isRunning = true;
        anim.falling_platform.update(Elf.getInitialTime(), 1);
        anim.falling_platform.draw(.init(endPos.x, endPos.y), 3.00, 0.0, 1.0, 0, 0);

        if (anim.falling_platform.isRunning == false) {
            effect_anim.prev = .FALLING_PLATFORM;
            effect_anim.current = .NONE;
        }
    }

    fn woosh() void {
        anim.woosh.isRunning = true;

        anim.woosh.update(Elf.getCurrentTime() / 2, 1);
        anim.woosh.draw(.init(object.DoorPos.x - 25, object.DoorPos.y), 1.5, 0, 0.3, 0, 0); //sale : 3.5

        if (anim.woosh.isRunning == false) {
            effect_anim.prev = .WOOSH;
            effect_anim.current = .NONE;
        }
    }

    fn entity_spawn() void {
        const elf: Elf = Elf.selfReturn();
        anim.entity_spawn.isRunning = true;

        anim.entity_spawn.update(Elf.getCurrentTime() / 2, 1);
        anim.entity_spawn.draw(.init(elf.x - elf.width * 0.23, elf.y + elf.height * 0.45), 1.5, 0, 255, 0, 0); //sale : 3.5

        if (anim.entity_spawn.isRunning == false) {
            effect_anim.prev = .ENTITY_SPAWN;
            effect_anim.current = .NONE;
        }
    }

    pub fn small_lighting() void {
        const elf: Elf = Elf.selfReturn();
        anim.small_lighting_0.isRunning = true;

        anim.small_lighting_0.update(Elf.getCurrentTime() / 2, 1);
        anim.small_lighting_0.draw(.init(elf.x - elf.width / 2, elf.y - elf.height * 0.50), 2.0, 0, 255, 0, 0); //sale : 3.5

        if (anim.small_lighting_0.isRunning == false) {
            effect_anim.prev = .SMALL_LIGHTING_EFFECT;
            effect_anim.current = .NONE;
        }
    }

    pub fn scratch() void {
        const elf: Elf = Elf.selfReturn();
        anim.scratch.isRunning = true;

        anim.scratch.update(Elf.getCurrentTime() / 2, 1);
        anim.scratch.draw(.init(elf.x, elf.y + elf.height * 0.2), 2.0, 0, 255, 0, 0); //sale : 3.5

        if (anim.scratch.isRunning == false) {
            effect_anim.prev = .SCRATCH;
            effect_anim.current = .NONE;
        }
    }

    pub fn slot_cleanning() void {
        const inv: Inventory = Inventory.selfReturn();

        anim.slot_cleanning.isRunning = true;
        for (0..inv.slots.len) |i| {
            if (inventory.save_inv[i].object.type != .EMPTY) {
                anim.slot_cleanning.update(Elf.getCurrentTime() / 2, 1);
                anim.slot_cleanning.draw(.init(inv.slots[i].pos.x, inv.slots[i].pos.y + 4), 4.0, 0, 255, 0, 0); //sale : 3.5
            }
        }

        if (anim.slot_cleanning.isRunning == false) {
            //print("Is Running {}\n", .{anim.slot_cleanning.isRunning});
            effect_anim.prev = .SLOT_CLEANNING;
            effect_anim.current = .NONE;
        }
    }

    pub fn item_despawning() void {
        const event: Event = Level.getPreviousEvent().*;
        const objects = event.grid_objects;
        const size = event.object_nb;
        anim.square_despawning_item.isRunning = true;
        anim.spike_despawning_item.isRunning = true;

        for (0..size) |i| {
            const pos: rl.Vector2 = Grid.getFrontEndPostion(objects[i].x, objects[i].y);

            if (objects[i].type == .GROUND) {
                anim.square_despawning_item.update(Elf.getInitialTime(), 1);
                anim.square_despawning_item.draw(.init(pos.x, pos.y), 3.50, 0, 255, 0, 0); //sale : 3.5
                continue;
            }
            anim.spike_despawning_item.update(Elf.getInitialTime(), 1);
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
            if (objects[i].key != Areas.getCurrentInterKey()) {
                continue;
            }

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
