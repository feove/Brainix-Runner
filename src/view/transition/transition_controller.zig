const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;

pub var transition_controller: TransitionController = undefined;

const root = "assets/transitions";

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

    pub fn init(allocator: std.mem.Allocator) !void {
        transition_controller = TransitionController{
            .cercleIn = Transition{
                .frame_start = 0,
                .frame_end = 17,
                .frame_current = 0,
                .transition_type = .NONE,
                .frames = try allocator.alloc(rl.Texture2D, 18),
            },
            .current = .NONE,
        };
        try transition_controller.cercleIn.fillFrames(allocator, "Circle01-", "-128x128.png", 0, 18);
    }
};

pub const Transition = struct {
    frame_start: u32,
    frame_end: u32,
    frame_current: u32,
    transition_type: TransitionType,
    frames: []rl.Texture2D,

    pub fn update(self: *Transition) void {
        self.frame_current += 1;
        if (self.frame_current > self.frame_end) {
            self.frame_current = self.frame_end;
        }
    }

    fn fillFrames(
        self: *Transition,
        allocator: std.mem.Allocator,
        name_pt1: []const u8,
        name_pt2: []const u8,
        start: u32,
        end: u32,
    ) !void {
        for (start..end) |i| {
            const unit = if (i < 10) "0" else "";
            const number = try std.fmt.allocPrint(allocator, "{s}{d}", .{ unit, i });
            const path = try std.fs.path.join(allocator, &[_][]const u8{ root, name_pt1, number, name_pt2 });

            self.frames[i] = try rl.loadTexture(path);
        }
    }
};
