pub const PhysicObject = struct {
    mass: f32,
    velocity: f32 = 0,
    acceleration: f32 = 0,

    const gravity: f32 = 9.8;

    pub fn applyPhysics(self: *PhysicObject, dt: f32) void {
        self.acceleration = self.mass * gravity;
        self.velocity += self.acceleration * dt;
    }
};
