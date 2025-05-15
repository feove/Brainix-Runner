const anim = @import("../../render/animated_sprite.zig");
const Elf = @import("../player.zig").Elf;
const rl = @import("raylib");
const print = @import("std").debug.print;

pub var elf_anim = AnimManager{};

pub const Animation = enum {
    IDLE,
    RUNNING,
    JUMPING,
    FALLING,
    DYING,
};

pub const AnimManager = struct {
    current: Animation = .RUNNING,

    pub fn update(self: *AnimManager, elf: *Elf) void {
        switch (self.current) {
            .RUNNING => {
                anim.battle_mage_running.isRunning = true;
                anim.battle_mage_running.applyMirror(elf.physics.auto_moving == .LEFT);
                anim.battle_mage_running.update(Elf.getCurrentTime(), 10);
                anim.battle_mage_running.draw(.{ .x = elf.x - elf.width * 0.85, .y = elf.y - elf.height * 0.3 }, 3.00, 0.0, 255, 0, 0);
            },
            else => {},
        }
    }
};
