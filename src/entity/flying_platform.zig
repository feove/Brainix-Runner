const std = @import("std");
const rl = @import("raylib");
const Grid = @import("../terrain/grid.zig").Grid;

pub var flying_platform: FlyingPlatform = undefined;

var INITIAL_POSITION: rl.Vector2 = undefined;
pub const DEFAULT_SPEED = 320.0;

pub fn init() void {
    INITIAL_POSITION = .{ .x = Grid.getExitDoor().x, .y = -50 };
    flying_platform = FlyingPlatform{
        .x = INITIAL_POSITION.x,
        .y = INITIAL_POSITION.y,
        .width = 100,
        .height = 20,
        .destination = .{
            .x = INITIAL_POSITION.x,
            .y = INITIAL_POSITION.y,
        },
        .speed = DEFAULT_SPEED,
    };
}

pub const FlyingPlatform = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    destination: rl.Vector2,
    speed: f32,

    pub fn SelfReturn() FlyingPlatform {
        return flying_platform;
    }

    pub fn setSpeed(speed: f32) void {
        flying_platform.speed = speed;
    }

    pub fn controller(self: *FlyingPlatform) void {
        updatePosition(self);
    }

    fn updatePosition(self: *FlyingPlatform) void {
        const dt = rl.getFrameTime();

        if (self.x < self.destination.x) {
            self.x += self.speed * dt;
        } else if (self.x > self.destination.x) {
            self.x -= self.speed * dt;
        }

        if (self.y < self.destination.y) {
            self.y += self.speed * dt;
        } else if (self.y > self.destination.y) {
            self.y -= self.speed * dt;
        }
    }

    pub fn getPosition() rl.Vector2 {
        return .{ .x = flying_platform.x, .y = flying_platform.y };
    }

    pub fn getInitialPosition() rl.Vector2 {
        return INITIAL_POSITION;
    }

    pub fn setDestination(pos: rl.Vector2) void {
        flying_platform.destination = pos;
    }
};
