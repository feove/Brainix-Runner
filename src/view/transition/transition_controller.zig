const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;

pub var transition_controller: TransitionController = undefined;
const textures = @import("../../render/textures.zig");
const Sprite = textures.Sprite;
const SpriteDefaultConfig = textures.SpriteDefaultConfig;

pub var start_transiton: f32 = 0.0;

const root = "assets/transitions";

pub const TransitionType = enum {
    NONE,
    CIRCLE_IN,
};

pub const TransitionController = struct {
    cercleIn: Transition,
    current: TransitionType,

    pub fn is_showing_transition() bool {
        //print("{}\n", .{transition_controller.current});
        return transition_controller.current != .NONE;
    }

    pub fn setCurrent(transition: TransitionType) void {
        transition_controller.current = transition;
    }

    pub fn update() !void {
        switch (transition_controller.current) {
            .NONE => {
                //  start_transiton = rl.getFrameTime();
                // print("Transition started at {d}\n", .{start_transiton});
            },
            .CIRCLE_IN => {
                render(&transition_controller.cercleIn);
            },
        }
    }

    pub fn render(transition: *Transition) void {
        if (transition.update(rl.getFrameTime())) {
            setCurrent(.NONE);
        }
        transition.draw();
    }

    pub fn init(allocator: std.mem.Allocator) !void {
        transition_controller = TransitionController{
            .cercleIn = Transition{
                .frame_start = 0,
                .frame_end = 17,
                .frame_current = 0,
                .transition_type = .NONE,
                .frames = try allocator.alloc(rl.Texture2D, 18),
                .frame_duration = 2.0,
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
    frame_duration: f32, // seconds
    time_acc: f32 = 0.0,

    pub fn update(self: *Transition, delta_time: f32) bool {
        self.time_acc += delta_time;
        if (self.time_acc >= self.frame_duration) {
            self.time_acc -= self.frame_duration;
            self.frame_current += 1;
        }

        if (self.frame_current > self.frame_end) {
            self.frame_current = self.frame_end;
            self.frame_current = self.frame_start;
            return true;
        }

        return false;
    }

    pub fn draw(self: *Transition) void {
        const frame = self.frames[self.frame_current];
        Sprite.drawCustom(frame, SpriteDefaultConfig{
            .sprite = Sprite{
                .name = "Circle01-128x128.png",
                .src = .init(0, 0, 128, 128),
            },
            .position = .init(0, 0),
            .scale = 4.0,
        });
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
            const unit = if (i < 9) "0" else "";
            const number = try std.fmt.allocPrint(allocator, "{s}{d}", .{ unit, i + 1 });
            const path = try std.fmt.allocPrintZ(allocator, "{s}/{s}{s}{s}", .{ root, name_pt1, number, name_pt2 });
            print("{s}\n", .{path});
            self.frames[i] = try rl.loadTexture(path);
        }
    }
};
