const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;
const player = @import("elf.zig");
const Grid = @import("../terrain/grid.zig").Grid;
const event = @import("../game/level/events.zig");
const PlayerEventStatus = event.PlayerEventStatus;

const Elf = player.Elf;
const AutoMovements = @import("../game/terrain_object.zig").AutoMovements;
const wizard_anims = @import("../game/animations/wizard_anims.zig");
const effect_anims = @import("../game/animations/effects_spawning.zig");
const textures = @import("../render/textures.zig");

pub var wizard: Wizard = undefined;

const DEFAULT_POSITION: rl.Vector2 = .init(250, -50);
const TEXTURE_SIZE: rl.Vector2 = .init(231, 190);
const SCALE: f32 = 2.0;
const WIZARD_SPEED: f32 = 500.0;

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
        .speed = WIZARD_SPEED,
        .hitbox = HitBox{ .rec = rl.Rectangle.init(
            DEFAULT_POSITION.x + 100,
            DEFAULT_POSITION.y + 100,
            TEXTURE_SIZE.x,
            TEXTURE_SIZE.y + 100,
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
    speed: f32,
    distance: f32 = 0.0,
    hitbox: HitBox,
    current_pos: WizardPosition = .MIDDLE,
    prev_pos: WizardPosition = .LEFT,
    animator: wizard_anims.WizardManager,
    canDraw: bool = true,

    pub fn SelfReturn() Wizard {
        return wizard;
    }

    pub fn setDrawing(canDraw: bool) void {
        wizard.canDraw = canDraw;
    }

    pub fn reset() void {
        // wizard.x = DEFAULT_POSITION.x;
        // wizard.y = DEFAULT_POSITION.y;
        wizard.hitbox.rec.x = DEFAULT_POSITION.x + 100;
        wizard.hitbox.rec.y = DEFAULT_POSITION.y + 100;
        wizard.current_pos = .MIDDLE;
    }

    pub fn controller(self: *Wizard) void {
        self.hitbox.refresh();

        if (self.hitbox.isInCollision or playerInTheMiddle()) {
            self.updatePos();
            self.move();
            self.updateDistance();
        }

        const dt: f32 = rl.getFrameTime();
        var x_movement: f32 = self.speed * dt;
        self.goTo(&x_movement);
    }

    // const rec1: rl.Rectangle = .init(elf.x, elf.y, elf.width, elf.height);
    // const rec2: rl.Rectangle = .init(Grid.getGroundPos().x, grid.cells[6][0].y, grid.cells[0][0].width, grid.cells[0][0].height);

    // const OnTheEdge: bool = rl.Rectangle.checkCollision(rec1, rec2);

    fn playerOnTheEdge() bool {
        const grid: Grid = Grid.selfReturn();
        const elf: Elf = Elf.selfReturn();

        const rec1: rl.Rectangle = .init(elf.x, elf.y, elf.width, elf.height);
        const rec2: rl.Rectangle = .init(Grid.getGroundPos().x, grid.cells[6][0].y, grid.cells[0][0].width, grid.cells[0][0].height);
        const rec3: rl.Rectangle = .init(grid.cells[6][grid.nb_cols - 1].x, grid.cells[6][0].y, grid.cells[0][0].width, grid.cells[0][0].height);

        const OnTheEdge: bool = rl.Rectangle.checkCollision(rec1, rec2) or rl.Rectangle.checkCollision(rec1, rec3);

        const res: bool = wizard.prev_pos != wizard.current_pos and elf.isOnGround and OnTheEdge;
        if (res) {
            wizard.prev_pos = wizard.current_pos;
        }

        return res;
    }

    fn playerInTheMiddle() bool {
        const grid: Grid = Grid.selfReturn();
        const elf: Elf = Elf.selfReturn();

        const inMiddle: bool = @abs(elf.x - (grid.x + grid.width / 2)) < 200;

        return inMiddle and event.playerEventstatus == .COMPLETED_AREA and elf.isOnGround;
    }

    fn updateDistance(self: *Wizard) void {
        self.distance = @abs(self.x - self.hitbox.rec.x + 100);
        self.distance = if (@abs(1 - self.distance) < 1) 0 else self.distance; //Oouf
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

    fn move(self: *Wizard) void {
        switch (self.current_pos) {
            .LEFT => self.setDestination(50, DEFAULT_POSITION.y),
            .MIDDLE => self.setDestination(DEFAULT_POSITION.x, DEFAULT_POSITION.y),
            .RIGHT => self.setDestination(450, DEFAULT_POSITION.y),
        }
    }

    fn goTo(self: *Wizard, inc: *f32) void {
        var current_distance: f32 = self.x - self.hitbox.rec.x + 100;
        current_distance = if (@abs(1 - current_distance) < 1) 0 else current_distance;
        //print("dist : {d} and inc : {d}\n", .{ distance, inc });
        //print("BEFORE elf.x {d}\n", .{self.x});

        // print("distance {d} and current {d}\n", .{ self.distance, current_distance });
        update_inc(inc, @abs(current_distance));

        if (current_distance < 0) {
            self.x += inc.*;
        } else if (current_distance > 0) {
            self.x -= inc.*;
        }
    }

    fn update_inc(inc: *f32, dst: f32) void {
        if (dst < wizard.distance * 0.05 or dst > wizard.distance * 0.85) {
            inc.* /= 2;
            //print("50%\n", .{});
            return;
        }

        inc.* *= 2.5;

        // inc.* = if (wizard.x + dst < wizard.distance / 2) inc.* / 2 else inc.* * 2;
    }

    fn setDestination(self: *Wizard, x: f32, y: f32) void {
        //goTo(&self.x, self.hitbox.rec.x, 10);
        //self.x = x;
        //self.y = y;
        self.hitbox.rec.x = x + 100;
        self.hitbox.rec.y = y + 100;
    }

    pub fn draw() void {
        wizard_anims.wizard_anim.update(&wizard);
        effect_anims.EffectManager.update();
        //HitBox.draw();
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

    fn draw() void {
        const x = @as(i32, @intFromFloat(wizard.hitbox.rec.x));
        const y = @as(i32, @intFromFloat(wizard.hitbox.rec.y));

        const width = @as(i32, @intFromFloat(wizard.hitbox.rec.width));
        const height = @as(i32, @intFromFloat(wizard.hitbox.rec.height));

        rl.drawRectangleLines(x, y, width, height, .red);
    }
};
