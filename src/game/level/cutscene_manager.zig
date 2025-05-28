const rl = @import("raylib");
const std = @import("std");

const Elf = @import("../../entity/elf.zig").Elf;
const ElfManager = @import("../animations/elf_anims.zig").ElfManager;
const Wizard = @import("../animations/wizard_anims.zig").WizardManager;
const EffectManager = @import("../animations/vfx_anims.zig").EffectManager;

pub var cut_scene_manager = CutSceneManager{};
pub var wait_active: bool = false;
pub var wait_start_time: f64 = 0.0;
pub var time_to_wait: f64 = 2.0;
var current_elapsed_time: f64 = 0.0;

pub var door_opened: bool = false;
pub var quiet_closed_door: bool = false;

pub const Scene = enum {
    LEVEL_STARTING,
    LEVEL_ENDING,
    NONE,
};

pub fn wait() bool {
    if (time_to_wait == 0.0) {
        return false;
    }
    const current_time = rl.getTime();
    if (wait_active == false) {
        wait_start_time = current_time;
        wait_active = true;
    }

    if (wait_active) {
        const elapsed_time: f64 = current_time - wait_start_time;
        current_elapsed_time = elapsed_time;
        if (elapsed_time >= time_to_wait) {
            time_to_wait = 0;
            wait_active = false;
        }
    }
    return wait_active;
}

pub const CutSceneManager = struct {
    current_scene: Scene = .LEVEL_STARTING,
    last_done: Scene = .NONE,

    pub fn setQuiet(quiet: bool) void {
        quiet_closed_door = quiet;
    }

    pub fn lastDone() Scene {
        return cut_scene_manager.last_done;
    }

    pub fn reset() void {
        cut_scene_manager.current_scene = .LEVEL_STARTING;
        cut_scene_manager.last_done = .NONE;
        door_opened = false;
        quiet_closed_door = false;
        time_to_wait = 2.0;
    }

    pub fn setCurrent(scene: Scene) void {
        cut_scene_manager.current_scene = scene;
    }

    pub fn setLast(scene: Scene) void {
        cut_scene_manager.last_done = scene;
    }

    pub fn run() void {
        switch (cut_scene_manager.current_scene) {
            .LEVEL_STARTING => level_starting(),
            .LEVEL_ENDING => level_ending(),
            else => {},
        }
    }

    fn level_ending() void {
        EffectManager.setCurrent(.FALLING_PLATFORM);
        ElfManager.setAnim(.IDLE);
        if (wait()) {
            //std.debug.print("LEVEL ENDING \n", .{});
            return;
        }

        cut_scene_manager.last_done = .LEVEL_ENDING;
        cut_scene_manager.current_scene = .NONE;
    }

    fn level_starting() void {
        Elf.setDrawing(false);

        const half_time: bool = current_elapsed_time > time_to_wait / 2;
        door_opened = half_time;
        if (half_time) {
            EffectManager.setCurrent(.WOOSH);
        }

        if (wait()) return;

        EffectManager.setCurrent(.ENTITY_SPAWN);
        Elf.setDrawing(true);

        if (ElfManager.getPrevAnim() == .IDLE) {
            time_to_wait = 3.0;
            cut_scene_manager.last_done = .LEVEL_STARTING;
            cut_scene_manager.current_scene = .NONE;
        }
        //Doors Anims

        //Elf Idle

        //Elf Running
    }
};

const Scenarios = struct {};
