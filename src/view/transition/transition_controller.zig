const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;

pub var transition_controller: TransitionController = undefined;

pub const TransitionType = enum {
    NONE,
};

pub const TransitionController = struct {
    cercleIn: Transition,
    current: TransitionType,

    pub fn update() void {
        switch (transition_controller.current) {
            .NONE => {},
        }
    }

    pub fn init() void {
        transition_controller = TransitionController{
            .cercleIn = Transition{
                .frame_start = 0,
                .frame_end = 60,
                .frame_current = 0,
                .transition_type = TransitionType.NONE,
            },
        };
    }
};

pub const Transition = struct {
    frame_start: u32,
    frame_end: u32,
    frame_current: u32,
    transition_type: TransitionType,

    pub fn update(self: *Transition) void {
        self.frame_current += 1;
        if (self.frame_current > self.frame_end) {
            self.frame_current = self.frame_end;
        }
    }
};
