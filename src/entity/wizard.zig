const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;
const player = @import("elf.zig");
const Elf = player.Elf;
const AutoMovements = @import("../game/terrain_object.zig").AutoMovements;
const wizard_anims = @import("../game/animations/wizard_anims.zig");
const effect_anims = @import("../game/animations/effects_spawning.zig");
const textures = @import("../render/textures.zig");

pub var wizard: Wizard = undefined;

const DEFAULT_POSITION: rl.Vector2 = .init(250, -80);
const TEXTURE_SIZE: rl.Vector2 = .init(231, 190);
const SCALE: f32 = 2.0;

pub const WizardPosition = enum {
    LEFT,
    MIDDLE,
    RIGHT,
};

pub fn init() void {
    wizard = Wizard{
        .x = DEFAULT_POSITION.x,
        .y = DEFAULT_POSITION.y,
        .width = TEXTURE_SIZE.x,
        .height = TEXTURE_SIZE.y,
        .scale = SCALE,
        .hitbox = HitBox{ .rec = rl.Rectangle.init(
            DEFAULT_POSITION.x + 100,
            DEFAULT_POSITION.y + 100,
            TEXTURE_SIZE.x,
            TEXTURE_SIZE.y + 60,
        ) },
        .animator = wizard_anims.wizard_anim,
    };
}

pub const Wizard = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    scale: f32,
    hitbox: HitBox,
    current_pos: WizardPosition = .MIDDLE,
    animator: wizard_anims.WizardManager,

    pub fn reset() void {
        wizard.x = DEFAULT_POSITION.x;
        wizard.y = DEFAULT_POSITION.y;
        wizard.hitbox.rec.x = DEFAULT_POSITION.x + 100;
        wizard.hitbox.rec.y = DEFAULT_POSITION.y + 100;
        wizard.current_pos = .MIDDLE;
    }

    pub fn controller(self: *Wizard) void {
        self.hitbox.refresh();
        // print("{}\n", .{self.hitbox.isInCollision});

        if (self.hitbox.isInCollision) {
            Wizard.updatePos(self);
            Wizard.move();
        }
    }

    fn updatePos(self: *Wizard) void {
        const autoMovement: AutoMovements = Elf.selfReturn().physics.auto_moving;
        switch (self.current_pos) {
            .LEFT => self.setCurrentPos(.MIDDLE),
            .MIDDLE => {
                const direction: WizardPosition = if (autoMovement == .LEFT) .RIGHT else .LEFT;
                self.setCurrentPos(direction);
            },
            .RIGHT => self.setCurrentPos(.MIDDLE),
        }
    }

    fn setCurrentPos(self: *Wizard, direction: WizardPosition) void {
        self.current_pos = direction;
    }

    fn move() void {
        switch (wizard.current_pos) {
            .LEFT => wizard.setPos(50, DEFAULT_POSITION.y),
            .MIDDLE => wizard.setPos(DEFAULT_POSITION.x, DEFAULT_POSITION.y),
            .RIGHT => wizard.setPos(450, DEFAULT_POSITION.y),
        }
    }

    fn goTo(start: *f32, end: f32, inc: f32) void {
        start.* = if (start.* < end) start.* + inc else if (start.* > end) start.* - 10 else start.*;
    }

    fn setPos(self: *Wizard, x: f32, y: f32) void {
        //goTo(&self.x, self.hitbox.rec.x, 10);
        self.x = x;
        self.y = y;
        self.hitbox.rec.x = x + 100;
        self.hitbox.rec.y = y + 100;
    }

    pub fn draw() void {
        wizard_anims.wizard_anim.update(&wizard);
        effect_anims.EffectManager.update();

        const x = @as(i32, @intFromFloat(wizard.hitbox.rec.x));
        const y = @as(i32, @intFromFloat(wizard.hitbox.rec.y));

        const width = @as(i32, @intFromFloat(wizard.hitbox.rec.width));
        const height = @as(i32, @intFromFloat(wizard.hitbox.rec.height));

        rl.drawRectangleLines(x, y, width, height, .red);
    }
};

pub const HitBox = struct {
    rec: rl.Rectangle,
    isInCollision: bool = false,

    fn refresh(self: *HitBox) void {
        const elf: Elf = Elf.selfReturn();
        const elf_hitbox: rl.Rectangle = .init(elf.x, elf.y, elf.width, elf.height);

        self.isInCollision = rl.Rectangle.checkCollision(elf_hitbox, self.rec);
    }
};
