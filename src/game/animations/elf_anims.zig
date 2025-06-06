const anim = @import("animations_manager.zig");
const Elf = @import("../../entity/elf.zig").Elf;
const rl = @import("raylib");
const print = @import("std").debug.print;

pub var elf_anim = ElfManager{};

pub const ElfAnimation = enum {
    IDLE,
    RUNNING,
    JUMPING,
    FALLING,
    DYING,
    NONE,
};

pub const ElfManager = struct {
    current: ElfAnimation = .IDLE,
    prev: ElfAnimation = .NONE,

    pub fn getCurrentAnim() ElfAnimation {
        return elf_anim.current;
    }

    pub fn getPrevAnim() ElfAnimation {
        return elf_anim.prev;
    }

    pub fn reset() void {
        elf_anim.current = .IDLE;
        elf_anim.prev = .NONE;
    }

    pub fn update(self: *ElfManager, elf: *Elf) void {
        applyMirrorEffect(elf);
        stopPrev();

        //Flex
        switch (self.current) {
            .IDLE => idle(elf),
            .RUNNING => running(elf),
            .JUMPING => jumping(elf),
            .FALLING => falling(elf),
            .DYING => dying(elf),
            else => {},
        }
    }

    fn idle(elf: *Elf) void {
        anim.battlemage_idle.isRunning = true;
        anim.battlemage_idle.update(Elf.getCurrentTime(), 1);
        anim.battlemage_idle.draw(.{ .x = elf.x - elf.width * 0.85, .y = elf.y - elf.height * 0.3 }, 3.00, 0.0, 255, 0, 0);

        if (anim.battlemage_idle.isRunning == false) {
            elf_anim.prev = .IDLE;
        }
    }

    fn dying(elf: *Elf) void {
        anim.battlemage_dying.isRunning = true;
        anim.battlemage_dying.update(Elf.getCurrentTime(), 1);
        anim.battlemage_dying.draw(.{ .x = elf.x - elf.width * 0.85, .y = elf.y - elf.height * 0.3 }, 3.00, 0.0, 255, 0, 0);

        if (anim.battlemage_dying.isRunning == false) {
            setAnim(.RUNNING);
            elf.state = .RESPAWNING;
        }
    }

    fn running(elf: *Elf) void {
        anim.battlemage_running.isRunning = true;
        anim.battlemage_running.update(Elf.getCurrentTime(), 1);
        anim.battlemage_running.draw(.{ .x = elf.x - elf.width * 0.85, .y = elf.y - elf.height * 0.3 }, 3.00, 0.0, 255, 0, 0);
        elf_anim.prev = .RUNNING;
    }

    fn jumping(elf: *Elf) void {
        anim.battlemage_jumping_full.update(Elf.getCurrentTime(), 1);
        anim.battlemage_jumping_full.draw(.{ .x = elf.x - elf.width * 0.85, .y = elf.y - elf.height * 0.3 }, 3.00, 0.0, 255, 0, 0);

        if (anim.battlemage_jumping_full.isRunning == false) {
            setAnim(.FALLING);
        }
    }

    fn falling(elf: *Elf) void {
        anim.battlemage_jumping_going_down.isRunning = true;
        anim.battlemage_jumping_going_down.update(Elf.getCurrentTime(), 1);
        anim.battlemage_jumping_going_down.draw(.{ .x = elf.x - elf.width * 0.85, .y = elf.y - elf.height * 0.3 }, 3.00, 0.0, 255, 0, 0);

        if (elf.physics.velocity_y == 0) {
            setAnim(.RUNNING);
        }
    }

    fn stopPrev() void {
        if (elf_anim.current != elf_anim.prev) {
            switch (elf_anim.prev) {
                .RUNNING => anim.battlemage_running.isRunning = false,
                .JUMPING => anim.battlemage_jumping_full.isRunning = false,
                .FALLING => anim.battlemage_jumping_going_down.isRunning = false,
                .DYING => anim.battlemage_dying.isRunning = false,
                else => {},
            }
        }
    }

    pub fn setAnim(animation: ElfAnimation) void {
        elf_anim.prev = elf_anim.current;
        elf_anim.current = animation;
    }

    fn applyMirrorEffect(elf: *Elf) void {
        anim.battlemage_running.applyMirror(elf.physics.auto_moving == .LEFT);
        anim.battlemage_jumping_full.applyMirror(elf.physics.auto_moving == .LEFT);
        anim.battlemage_dying.applyMirror(elf.physics.auto_moving == .LEFT);
        anim.battlemage_jumping_going_down.applyMirror(elf.physics.auto_moving == .RIGHT);
    }

    pub fn AnimationTrigger(elf: *Elf) void {
        if (elf.physics.velocity_y < 0) {
            if (elf_anim.current == .RUNNING) {
                anim.battlemage_jumping_full.isRunning = true;
                setAnim(.JUMPING);
                return;
            }
        }
    }
};
