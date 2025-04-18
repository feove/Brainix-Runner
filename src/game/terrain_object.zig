pub const AutoMovements = enum {
    RIGHT,
    LEFT,
};

pub const PhysicObject = struct {
    mass: f32,
    velocity: f32 = 0,
    acceleration: f32 = 0,
    auto_moving: AutoMovements = AutoMovements.RIGHT,
    jump: bool = false,

    const gravity: f32 = 9.8;

    pub fn applyPhysics(self: *PhysicObject, dt: f32) void {
        self.acceleration = self.mass * gravity;
        self.velocity += self.acceleration * dt;
    }

    pub fn applyJump(self: *PhysicObject, jump_force: f32) void {
        self.velocity = jump_force;
        self.jump = false;
    }
};
