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
};

pub const WizardManager = struct {
    current: WizardAnimation = .IDLE,
    prev: WizardAnimation = .IDLE,

    pub fn set(animation: WizardAnimation) void {
        wizard_anim.current = animation;
    }

    pub fn update(self: *WizardManager, wizard: *Wizard) void {
        //_ = self;
        //_ = demon;

        if (self.current != .IDLE) {
            print("{any}\n", .{self.current});
        }

        switch (self.current) {
            .IDLE => idle(wizard),
            .JUMPING => jumping(wizard),
            .FALLING => falling(wizard),
            // else => {},
        }

        moving_platform(wizard);
    }

    fn idle(wizard: *Wizard) void {
        anim.demon_idle2.isRunning = true;
        anim.demon_idle2.update(Elf.getCurrentTime(), 1);
        anim.demon_idle2.draw(.init(wizard.x, wizard.y), wizard.scale, 0.0, 255, 0, 0);
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
