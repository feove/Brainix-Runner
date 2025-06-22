const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;
const textures = @import("../../render/textures.zig");
const Sprite = textures.Sprite;
const SpriteDefaultConfig = textures.SpriteDefaultConfig;
const levelsView = @import("./../levels.zig");
const menuView = @import("./../menu.zig");
const gameView = @import("../../game/game.zig");
const window = @import("../../render/window.zig");
const GameView = window.GameView;

pub var transition_controller: TransitionController = undefined;
pub var switcher: Switcher = undefined;
pub var start_transiton: f32 = 0.0;

const root = "assets/transitions/";

pub const TransitionType = enum {
    NONE,
    CIRCLE_IN,
    CIRCLE_OUT,
};

pub const Switcher = struct {
    has_started: bool = false,
    can_switch: bool = false,
    view: GameView = .None,

    pub fn default_render() !void {
        return switch (switcher.view) {
            .Menu => menuView.drawElements(),
            .Levels => levelsView.drawElements(),
            .Play => try gameView.drawElements(),
            else => return,
        };
    }

    pub fn authorize_switch(view: GameView) void {
        switcher.can_switch = true;
        switcher.view = view;
    }

    pub fn can_default_render() bool {
        return switcher.can_switch == false and TransitionController.isFinished();
    }

    pub fn start(tr: TransitionType) void {
        if (switcher.has_started) return;

        TransitionController.setCurrent(tr);
        switcher.has_started = true;
        //set Background render func
        return;
    }

    pub fn update() void {
        if (switcher.can_switch) {
            if (TransitionController.isFinished()) {
                window.currentView = switcher.view;
                reset();
            }
        }
    }

    pub fn reset() void {
        switcher.has_started = false;
        switcher.can_switch = false;
    }
};

pub const TransitionController = struct {
    cercleIn: Transition,
    cercleOut: Transition,
    current: TransitionType,
    previous: TransitionType,

    pub fn selfReturn() TransitionController {
        return transition_controller;
    }

    pub fn isFinished() bool {
        //print("{}\n", .{transition_controller.current});
        return transition_controller.current == .NONE;
    }

    pub fn isTransitionDone(transition: TransitionType) bool {
        return transition_controller.previous == transition;
    }

    pub fn setCurrent(transition: TransitionType) void {
        transition_controller.current = transition;
    }

    pub fn setPrevious(transition: TransitionType) void {
        transition_controller.previous = transition;
    }

    pub fn update() !void {

        // drawBackground Scene
        Switcher.update();

        switch (transition_controller.current) {
            .CIRCLE_IN => {
                render(&transition_controller.cercleIn);
            },
            .CIRCLE_OUT => {
                try Switcher.default_render();
                render(&transition_controller.cercleOut);
            },
            else => {},
        }
    }

    pub fn render(transition: *Transition) void {

        // print("Drawing {}\n", .{transition.transition_type});

        if (transition.update(rl.getFrameTime())) {
            setPrevious(transition.transition_type);
            setCurrent(.NONE);

            return;
        }

        transition.draw();
    }

    pub fn init(allocator: std.mem.Allocator) !void {
        transition_controller = TransitionController{
            .cercleOut = Transition{
                .frame_start = 0,
                .frame_end = 13,
                .frame_current = 0,
                .transition_type = .CIRCLE_OUT,
                .frames = try allocator.alloc(rl.Texture2D, 14),
                .frame_duration = 0.03,
            },
            .cercleIn = Transition{
                .frame_start = 0,
                .frame_end = 13,
                .frame_current = 0,
                .transition_type = .CIRCLE_IN,
                .frames = try allocator.alloc(rl.Texture2D, 14),
                .frame_duration = 0.03,
            },
            .current = .NONE,
            .previous = .NONE,
        };
        try transition_controller.cercleOut.fillFrames(allocator, "cercle_out/cercle_out_", ".png", 0, 13); //18
        try transition_controller.cercleIn.fillFrames(allocator, "cercle_in/cercle_in_", ".png", 0, 13); //18 cercle_in/cercle_in_

    }

    pub fn deinit(allocator: std.mem.Allocator) void {
        transition_controller.cercleOut.deinit(allocator);
        transition_controller.cercleIn.deinit(allocator);
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

        if (self.frame_current >= self.frame_end) {
            self.frame_current = 0;
            self.time_acc = 0;
            return true;
        }

        return false;
    }

    pub fn draw(self: *Transition) void {
        const frame = self.frames[self.frame_current];

        // rl.clearBackground(.white);
        Sprite.drawCustom(frame, SpriteDefaultConfig{
            .sprite = Sprite{
                .name = "Transition",
                .src = .init(0, 0, 1000, 800),
            },
            .position = .init(0, 0),
        });
    }

    fn fillFrames(self: *Transition, allocator: std.mem.Allocator, name: []const u8, format: []const u8, start: u32, end: u32) !void {
        for (start..end) |i| {
            const unit = if (i < 9) "0" else "";
            const number = try std.fmt.allocPrint(allocator, "{s}{d}", .{ unit, i + 1 });
            const path = try std.fmt.allocPrintZ(allocator, "{s}{s}{s}{s}", .{ root, name, number, format });
            print("{s}\n", .{path});
            self.frames[i] = try rl.loadTexture(path);
        }
    }

    pub fn deinit(self: *Transition, allocator: std.mem.Allocator) void {
        for (self.frames) |*frame| {
            rl.unloadTexture(frame.*);
        }
        allocator.free(self.frames);
    }
};
