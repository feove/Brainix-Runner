const rl = @import("raylib");
const std = @import("std");

const Elf = @import("../../entity/elf.zig").Elf;
const ElfManager = @import("../animations/elf_anims.zig").ElfManager;
const Wizard = @import("../animations/wizard_anims.zig").WizardManager;

pub var cut_scene_manager = CutSceneManager{};
pub var wait_active: bool = false;
pub var wait_start_time: f64 = 0.0;
pub var time_to_wait: f64 = 1.0;
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

    pub fn run() void {
        switch (cut_scene_manager.current_scene) {
            .LEVEL_STARTING => level_starting(),
            .LEVEL_ENDING => {},
            else => {},
        }
    }

    fn level_starting() void {
        Elf.setDrawing(false);

        door_opened = current_elapsed_time > time_to_wait / 2;

        if (wait()) return;

        Elf.setDrawing(true);

        if (ElfManager.getPrevAnim() == .IDLE) {
            cut_scene_manager.last_done = .LEVEL_STARTING;
            cut_scene_manager.current_scene = .NONE;
        }
        //Doors Anims

        //Elf Idle

        //Elf Running
    }
};

const Scenarios = struct {};
