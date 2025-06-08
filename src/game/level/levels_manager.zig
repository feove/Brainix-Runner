const std = @import("std");
const rl = @import("raylib");

pub var level_manager: LevelManager = undefined;

const LEVEL_NUMBER = 2;

const LevelMeta = struct {
    id: usize,
    is_locked: bool,
    stars_collected: u8,
    path: []const []const u8,
};

pub const LevelManager = struct {
    level_number: usize,
    levels: []LevelMeta,
    current_level: usize = 0,

    pub fn init() void {
        level_manager = LevelManager{
            .level_number = LEVEL_NUMBER,
            .current_level = 0,
        };
    }
};
