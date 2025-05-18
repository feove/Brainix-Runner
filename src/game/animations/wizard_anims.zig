const std = @import("std");
const print = std.debug.print;
const rl = @import("raylib");

const anim = @import("animations_manager.zig");
const Elf = @import("../../entity/elf.zig").Elf;
const Wizard = @import("../../entity/wizard.zig").Wizard;

pub var wizard_anim = WizardManager{};

pub const WizardAnimation = enum {
    IDLE,
    FALLING,
    JUMPING,
    ATTACKING_1,
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
        WizardManager.setCurrent(.IDLE);
        WizardManager.setPrev(.IDLE);
    }

    pub fn update(self: *WizardManager, wizard: *Wizard) void {
        //_ = self;
        //_ = demon;

        switch (self.current) {
            .IDLE => idle(wizard),
            .JUMPING => jumping(wizard),
            .FALLING => falling(wizard),
            .ATTACKING_1 => attacking_1(wizard),
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

    fn attacking_1(wizard: *Wizard) void {
        wizard_anim.current = .ATTACKING_1;
        wizard_anim.prev = .IDLE;

        anim.wizard_attacking_1.isRunning = true;
        anim.wizard_attacking_1.update(Elf.getCurrentTime() * Elf.getTimeDivisor(), 1);
        anim.wizard_attacking_1.draw(.init(wizard.x, wizard.y), wizard.scale, 0.0, 255, 0, 0);

        if (anim.wizard_attacking_1.isRunning == false) {
            wizard_anim.prev = .ATTACKING_1;
            wizard_anim.current = .IDLE;
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
        anim.moving_platform.draw(.init(wizard.x + wizard.width * 0.63, wizard.y + wizard.height * 1.48), wizard.scale * 2, 0.0, 255, 0, 0);
    }
};
