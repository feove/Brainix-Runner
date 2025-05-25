const rl = @import("raylib");
const std = @import("std");

pub var cut_scene_manager = CutSceneManager{};

pub const Scene = enum {
    LEVEL_STARTING,
    LEVEL_ENDING,
    NONE,
};

pub const CutSceneManager = struct {
    last_done: Scene = .NONE,
    current_scene: Scene = .LEVEL_STARTING,

    pub fn lastDone() Scene {
        return cut_scene_manager.last_done;
    }

    pub fn run() void {
        switch (cut_scene_manager.current_scene) {
            .LEVEL_STARTING => level_starting(),
            .LEVEL_ENDING => {},
            else => {},
        }
    }

    fn level_starting() void {
        cut_scene_manager.last_done = .LEVEL_STARTING;
        cut_scene_manager.current_scene = .NONE;
        //Doors Anims

        //Elf Idle

        //Elf Running
    }
};
