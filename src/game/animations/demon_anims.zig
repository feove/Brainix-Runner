const rl = @import("raylib");
const anim = @import("animations_manager.zig");
const Elf = @import("../../entity/elf.zig").Elf;
const Demon = @import("../../entity/demon.zig").Demon;

pub var demon_anim = DemonManager{};

pub const DemonAnimation = enum {
    IDLE,
    IDLE2,
};

pub const DemonManager = struct {
    current: DemonAnimation = .IDLE2,
    prev: DemonAnimation = .IDLE2,

    pub fn update(self: *DemonManager, demon: *Demon) void {
        //_ = self;
        //_ = demon;

        switch (self.current) {
            .IDLE2 => idle_2(demon),
            else => {},
        }

        moving_platform();
    }

    fn idle_2(demon: *Demon) void {
        anim.demon_idle2.isRunning = true;
        anim.demon_idle2.update(Elf.getCurrentTime(), 1);
        anim.demon_idle2.draw(.init(demon.x, demon.y), 2.0, 0.0, 255, 0, 0);
    }

    fn moving_platform() void {}
};
