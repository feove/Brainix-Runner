const std = @import("std");
const print = std.debug.print;
const rl = @import("raylib");

const anim = @import("animations_manager.zig");
const Elf = @import("../../entity/elf.zig").Elf;
const Wizard = @import("../../entity/wizard.zig").Wizard;
const Object = @import("../terrain_object.zig").Object;
const Grid = @import("../../terrain/grid.zig").Grid;
const events = @import("../level/events.zig");
const Event = events.Event;
const Level = events.Level;

pub var wizard_anim = WizardManager{};

pub const WizardAnimation = enum {
    IDLE,
    FALLING,
    JUMPING,
    ATTACKING_1,
    ATTACKING_2,
};

pub const WizardManager = struct {
    current: WizardAnimation = .IDLE,
    prev: WizardAnimation = .IDLE,

    pub fn setCurrent(animation: WizardAnimation) void {
        wizard_anim.current = animation;
    }

    pub fn setPrev(animation: WizardAnimation) void {
        wizard_anim.prev = animation;
    }

    pub fn getCurrentAnim() WizardAnimation {
        return wizard_anim.current;
    }

    pub fn getPreviousAnim() WizardAnimation {
        return wizard_anim.prev;
    }

    pub fn reset() void {
        setCurrent(.IDLE);
        setPrev(.IDLE);
    }

    pub fn update(self: *WizardManager, wizard: *Wizard) void {
        //_ = self;
        //_ = demon;
        //  item_spawning(100, 100);

        switch (self.current) {
            .IDLE => idle(wizard),
            .JUMPING => jumping(wizard),
            .FALLING => falling(wizard),
            .ATTACKING_1 => attacking_1(wizard),
            .ATTACKING_2 => attacking_2(wizard),
            // else => {},
        }

        moving_platform(wizard);
    }

    fn idle(wizard: *Wizard) void {
        wizard_anim.current = .IDLE;
        anim.demon_idle2.isRunning = true;
        anim.demon_idle2.update(Elf.getCurrentTime() * Elf.getTimeDivisor(), 1);
        anim.demon_idle2.draw(.init(wizard.x, wizard.y), wizard.scale, 0.0, 255, 0, 0);
        // wizard_anim.prev = .IDLE;
    }

    pub fn onceTime(animation: WizardAnimation) bool {
        const alreadyPlayed: bool = getPreviousAnim() == animation;

        if (!alreadyPlayed) {
            if (getCurrentAnim() != animation) {
                // EffectManager.setCurrent(.SPAWNING);
                setCurrent(animation);
            }
        }
        return !alreadyPlayed;
    }

    fn attacking_1(wizard: *Wizard) void {
        setPrev(.IDLE);
        setCurrent(.ATTACKING_1);

        anim.wizard_attacking_1.isRunning = true;
        anim.wizard_attacking_1.update(Elf.getCurrentTime() * Elf.getTimeDivisor(), 1);
        anim.wizard_attacking_1.draw(.init(wizard.x, wizard.y), wizard.scale, 0.0, 255, 0, 0);

        if (anim.wizard_attacking_1.isRunning == false) {
            setPrev(.ATTACKING_1);
            setCurrent(.IDLE);
        }
    }

    fn attacking_2(wizard: *Wizard) void {
        setPrev(.IDLE);
        setCurrent(.ATTACKING_2);

        anim.wizard_attacking_2.isRunning = true;
        anim.wizard_attacking_2.update(Elf.getCurrentTime() * Elf.getTimeDivisor(), 1);
        anim.wizard_attacking_2.draw(.init(wizard.x, wizard.y), wizard.scale, 0.0, 255, 0, 0);

        if (anim.wizard_attacking_2.isRunning == false) {
            setPrev(.ATTACKING_2);
            setCurrent(.IDLE);
        }
    }

    fn jumping(wizard: *Wizard) void {
        anim.wizard_jumping.isRunning = true;
        anim.wizard_jumping.update(Elf.getCurrentTime() * Elf.getTimeDivisor(), 1);
        anim.wizard_jumping.draw(.init(wizard.x, wizard.y), wizard.scale, 0.0, 255, 0, 0);

        if (anim.wizard_jumping.isRunning == false) {
            wizard_anim.current = .FALLING;
        }
    }

    fn falling(wizard: *Wizard) void {
        anim.wizard_falling.isRunning = true;
        anim.wizard_falling.update(Elf.getCurrentTime() * Elf.getTimeDivisor(), 1);
        anim.wizard_falling.draw(.init(wizard.x, wizard.y), wizard.scale, 0.0, 255, 0, 0);
        if (anim.wizard_falling.isRunning == false) {
            wizard_anim.current = .IDLE;
        }
    }

    fn moving_platform(wizard: *Wizard) void {
        anim.moving_platform.isRunning = true;
        anim.moving_platform.update(Elf.getCurrentTime(), 1);
        anim.moving_platform.draw(.init(wizard.x + wizard.width * 0.62, wizard.y + wizard.height * 1.48), wizard.scale * 2.2, 0.0, 255, 0, 0);
    }
};
