const std = @import("std");
const rl = @import("raylib");

const player = @import("../../entity/elf.zig");
const Elf = player.Elf;

const LevelMeta = @import("levels_manager.zig").LevelMeta;
const LevelManager = @import("levels_manager.zig").LevelManager;

const wizard_anim = @import("../animations/wizard_anims.zig").wizard_anim;
const WizardAnimation = @import("../animations/wizard_anims.zig").WizardAnimation;
const WizardManager = @import("../animations/wizard_anims.zig").WizardManager;
const wizard = @import("../../entity/wizard.zig");
const Wizard = wizard.Wizard;
const ElfManager = @import("../animations/elf_anims.zig").ElfManager;
const EffectManager = @import("../animations/vfx_anims.zig").EffectManager;
const CutScene = @import("cutscene_manager.zig").CutSceneManager;
const anim = @import("../animations/animations_manager.zig");

const terrain = @import("../../terrain/grid.zig");
const Grid = terrain.Grid;
const Cell = terrain.Cell;
const CellType = terrain.CellType;

const Object = @import("../terrain_object.zig").Object;
const Inventory = @import("../inventory.zig").Inventory;
const EventConfig = @import("level_reader.zig").EventConfig;
const CursorManager = @import("../cursor.zig").CursorManager;
const transition = @import("../../view/transition/transition_controller.zig");
const Switcher = transition.Switcher;
const Controller = transition.TransitionController;
const window = @import("../../render/window.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = gpa.allocator();
const print = std.debug.print;

pub var level: Level = undefined;
var slots_filled = false;

pub var slow_motion_active: bool = false;
pub var stop_slow_motion: bool = false;
pub var slow_motion_start_time: f64 = 0;

pub var quick_slow_motion_active: bool = false;
pub var quick_slow_motion_start_time: f64 = 0;

pub var auto_death_timer_active: bool = false;
pub var auto_death_start_time: f64 = 0;
pub var auto_death_time_max: f64 = 10.0; //10

pub var playerEventstatus: PlayerEventStatus = PlayerEventStatus.IDLE_AREA;
pub var levelStatement: LevelStatement = .STARTING;

const LEVEL_NB: usize = 26;
pub var CURRENT_LEVEL: usize = 0;

var EVENT_NB: usize = undefined;
const CURRENT_EVENT: usize = 0;

pub const PlayerEventStatus = enum {
    IDLE_AREA,
    SLOW_MOTION_AREA,
    RESTRICTED_AREA,
    COMPLETED_AREA,
};

pub const LevelStatement = enum {
    STARTING,
    ONGOING,
    PRE_COMPLETED,
    COMPLETED,
};

pub fn reset_level_values() void {
    quick_slow_motion_active = false;
    quick_slow_motion_start_time = 0;
    quick_slow_motion_active = false;
    quick_slow_motion_start_time = 0;
    player.time_divisor = 1;
    Elf.respawn();
}

pub const Areas = struct {
    trigger_area: rl.Vector4,
    restricted_area: rl.Vector4 = .init(0, 0, 0, 0),
    completed_area: rl.Vector4,
    intermediate_areas: []rl.Vector4,
    intermediate_areas_nb: usize,
    current_inter_area: usize = 0,

    pub fn getCurrentInterKey() usize {
        const index = if (level.i_event == level.event_nb) level.i_event - 1 else level.i_event;

        return level.events[index].areas.current_inter_area;
    }

    fn getCurrentInterArea() rl.Vector4 {
        return undefined;
    }

    fn noMoreInterArea() bool {
        const area = level.events[level.i_event].areas;
        const ReachedTheLast: bool = getCurrentInterKey() == area.intermediate_areas_nb;

        return ReachedTheLast;
    }

    pub fn increaseInter() void {
        level.events[level.i_event].areas.current_inter_area += 1;
    }

    fn player_in_trigger_area(self: *Areas, elf: *Elf) bool {
        const inAxeX: bool = elf.x > self.trigger_area.x and elf.x < self.trigger_area.x + self.trigger_area.w;
        const inAxeY: bool = elf.y > self.trigger_area.y and elf.y < self.trigger_area.y + self.trigger_area.z;

        return inAxeX and inAxeY;
    }

    fn player_in_restricted_area(self: *Areas, elf: *Elf) bool {
        const inAxeX: bool = elf.x > self.restricted_area.x and elf.x < self.restricted_area.x + self.restricted_area.w;
        const inAxeY: bool = elf.y > self.restricted_area.y and elf.y < self.restricted_area.y + self.restricted_area.z;

        return inAxeX and inAxeY;
    }

    fn player_in_end_area(self: *Areas, elf: *Elf) bool {
        const inAxeX: bool = elf.x > self.completed_area.x and elf.x < self.completed_area.x + self.completed_area.w;

        const inAxeY: bool = elf.y > self.completed_area.y and elf.y < self.completed_area.y + self.completed_area.z;

        return inAxeX and inAxeY;
    }

    fn player_in_intermediate(self: *Areas, elf: *Elf) bool {
        // print("{}\n", .{self.current_inter_area});

        const area = self.intermediate_areas[self.current_inter_area];
        const inAxeX: bool = elf.x > area.x and elf.x < area.x + area.w;

        const inAxeY: bool = elf.y > area.y and elf.y < area.y + area.z;

        return inAxeX and inAxeY;
    }

    fn player_in_area(self: *Areas, elf: *Elf, area: rl.Vector4) bool {
        _ = self;
        const elf_left = elf.x;
        const elf_right = elf.x + elf.width;
        const elf_top = elf.y;
        const elf_bottom = elf.y + elf.height;

        const area_left = area.x;
        const area_right = area.x + area.w;
        const area_top = area.y;
        const area_bottom = area.y + area.z;

        const horizontal_overlap = elf_left < area_right and elf_right > area_left;
        const vertical_overlap = elf_top < area_bottom and elf_bottom > area_top;

        return horizontal_overlap and vertical_overlap;
    }
};

pub const Event = struct {
    object_nb: usize,
    grid_objects: []Object,
    inv_objects: []Object,
    areas: Areas,
    slow_motion_time: f32,
    quick_slow_motion_time: ?[]f64,
    time_divisor: f32,
    already_triggered: bool = false,

    fn objectsSetUp(event: *Event, objects: []Object) void { //Important
        var grid: Grid = Grid.selfReturn();
        for (0..event.object_nb) |i| {
            if (objects[i].key != Areas.getCurrentInterKey()) {
                continue;
            }

            Object.set(&objects[i], &grid);
        }
    }

    fn objectsCleaning(event: *Event, objects: []Object) void {
        var grid: Grid = Grid.selfReturn();

        for (0..event.object_nb) |i| {
            Object.remove(&objects[i], &grid);
        }
        //exception
        anim.jumper_sprite.resetPos();
    }

    pub fn quick_slow_motion() void {
        const current_time = rl.getTime();

        if (!quick_slow_motion_active) {
            player.time_divisor = 4;
            quick_slow_motion_active = true;
            quick_slow_motion_start_time = current_time;

            return;
        }

        const elapsed = current_time - quick_slow_motion_start_time;

        const limit: f64 = Level.getCurrentEvent().quick_slow_motion_time.?[Areas.getCurrentInterKey() - 1];

        //or (Inventory.invEmpty() and Inventory.cacheEmpty()) but better without
        //or Elf.selfReturn().physics.newSens
        if (elapsed >= limit) {
            quick_slow_motion_active = false;
            player.time_divisor = 1;

            //EffectManager.setCurrent(.SLOT_CLEANNING);
        }
    }

    pub fn slow_motion_effect(elf: *Elf) void {
        const current_time = rl.getTime();
        _ = elf;
        if (!slow_motion_active) {
            if (playerEventstatus == .SLOW_MOTION_AREA and !level.events[level.i_event].already_triggered) {
                player.time_divisor = level.events[level.i_event].time_divisor;
                slow_motion_active = true;
                slow_motion_start_time = current_time;
                level.events[level.i_event].already_triggered = true;
                Controller.setCurrent(.EPIC);
                return;
            }
        }

        if (slow_motion_active) {
            const elapsed = current_time - slow_motion_start_time;
            //or (Inventory.invEmpty() and Inventory.cacheEmpty()) but better without
            if (elapsed >= level.events[level.i_event].slow_motion_time or stop_slow_motion) {
                slow_motion_active = false;
                stop_slow_motion = false;

                player.time_divisor = 1;
                if (level.events[level.i_event].areas.intermediate_areas_nb == 0) {
                    EffectManager.setCurrent(.SLOT_CLEANNING);
                }
                playerEventstatus = .IDLE_AREA;
            }
        }
    }

    pub fn stopSlowMotion() void {
        stop_slow_motion = true;
    }
};

pub const Level = struct {
    events: []Event,
    event_nb: usize,
    i_event: usize,

    pub fn init(allocator: std.mem.Allocator) !void {

        //Events Init
        level.i_event = CURRENT_EVENT;
        const level_meta = LevelManager.CurrentLevel();
        const level_path = level_meta.path;
        const eventConfig: *EventConfig = try EventConfig.levelReader(allocator, level_path);

        level.events = eventConfig.*.events.*;
        // print("INIT : {d} \n", .{level.events[3].areas.intermediate_areas[0].x});
        EVENT_NB = eventConfig.*.event_nb;
        level.event_nb = EVENT_NB;
        reset();
    }

    pub fn reset() void {
        level.i_event = 0;

        for (0..level.event_nb) |i| {
            level.events[i].already_triggered = false;
            level.events[i].areas.current_inter_area = 0;
        }

        Grid.reset();

        Inventory.clear();

        levelStatement = .STARTING;
    }

    pub fn usize_assign_to_f32(i: usize, j: usize, width: usize, height: usize) rl.Vector4 {
        const grid: Grid = Grid.selfReturn();

        //Need to check out of band of j + height and i + width

        const tl_cell: Cell = grid.cells[j][i];
        const bl_cell: Cell = grid.cells[j + height][i];
        const tr_cell: Cell = grid.cells[j][i + width];

        const x: f32 = tl_cell.x;
        const y: f32 = tl_cell.y;
        const w: f32 = tr_cell.x - bl_cell.x;
        const h: f32 = bl_cell.y - tl_cell.y;

        return .init(x, y, h, w); //flex
    }

    pub fn guiQuit() void {
        var event: Event = level.events[level.i_event];
        event.objectsCleaning(event.grid_objects);

        ElfManager.reset();
        CutScene.reset();
        auto_death_timer_active = false;
        playerEventstatus = .IDLE_AREA;
    }

    pub fn stateLevelManager() !void {
        switch (levelStatement) {
            .STARTING => {
                Wizard.setPos(wizard.DEFAULT_POSITION.x, wizard.DEFAULT_POSITION.y);
                if (CutScene.lastDone() == .LEVEL_STARTING) {
                    Elf.setState(player.PlayerState.ALIVE);
                    levelStatement = .ONGOING;
                }
            },
            .ONGOING => {
                try refresh();
            },
            .PRE_COMPLETED => {
                in_ending_level();
            },
            .COMPLETED => {
                if (CutScene.lastDone() == .LEVEL_ENDING) {
                    print("LEVEL COMPLETED \n", .{});
                    LevelMeta.manageStars();
                    LevelMeta.unlockNextLevel();
                    window.currentView = .Completed;
                }
            },
        }
    }

    pub fn end_level() void {
        Wizard.reset();
        ElfManager.reset();
        CutScene.reset();
    }

    fn in_ending_level() void {
        EffectManager.setCurrent(.FALLING_PLATFORM);
        if (Elf.playerInDoor()) {
            CutScene.setCurrent(.LEVEL_ENDING);
            levelStatement = .COMPLETED;
        }
    }

    pub fn refresh() !void {
        var elf: Elf = Elf.selfReturn();

        areaSetting(&elf);

        try playerStatement(&elf);

        autoDeathTimer();
    }

    fn autoDeathTimer() void {
        const current_time = rl.getTime();
        if (auto_death_timer_active == false) {
            auto_death_start_time = current_time;
            return;
        }

        const elapsed = current_time - auto_death_start_time;
        //print("{d} \n", .{elapsed});

        if (elapsed > auto_death_time_max) {
            auto_death_timer_active = false;
            Elf.set_death_purpose(.TIME_OUT);
            WizardManager.setCurrent(.ATTACKING_2);
            Elf.set_state(.DEAD);
        }
    }

    fn areaSetting(elf: *Elf) void {
        var area: Areas = level.events[level.i_event].areas;

        if (area.player_in_area(elf, area.trigger_area) and !level.events[level.i_event].already_triggered) {
            playerEventstatus = .SLOW_MOTION_AREA;
        }

        if (area.player_in_area(elf, area.restricted_area)) {
            playerEventstatus = .RESTRICTED_AREA;
        }

        //print("no More Areas {} Key : {d}\n", .{ Areas.noMoreInterArea(), Areas.getCurrentInterKey() });

        if (elf.physics.newSens) {
            // print("no More Areas {} Key : {d}\n", .{ Areas.noMoreInterArea(), Areas.getCurrentInterKey() });
        }
        //print("{} {d}\n", .{ quick_slow_motion_active, quick_slow_motion_start_time });
        if (quick_slow_motion_active) {
            Event.quick_slow_motion();
        }

        if (!Areas.noMoreInterArea()) {
            const inter_area = area.intermediate_areas[area.current_inter_area];
            //(elf.physics.newSens)

            if (area.player_in_area(elf, inter_area)) {
                // print("Player In INTERMEDIATE\n", .{});
                // print("{d}, {d}\n", .{ area.current_inter_area, area.intermediate_areas_nb });

                intermediate();
            }
            return;
        }

        if (area.player_in_area(elf, area.completed_area)) {
            playerEventstatus = .COMPLETED_AREA;
        }
    }

    fn playerStatement(elf: *Elf) !void {
        switch (playerEventstatus) {
            .IDLE_AREA => idle(),
            .SLOW_MOTION_AREA => try slow_motion(elf),
            .RESTRICTED_AREA => print("IN RESTRICTED AREA\n", .{}),
            .COMPLETED_AREA => complete(),
        }
    }

    fn intermediate() void {
        var event: Event = level.events[level.i_event];

        if (WizardManager.onceTime(.ATTACKING_1) or WizardManager.getCurrentAnim() == .ATTACKING_1) {
            return;
        }

        //WizardManager.setCurrent(.ATTACKING_1);
        //WizardManager.setCurrent(.ATTACKING_1);

        //EffectManager.reset();
        Event.quick_slow_motion();

        //EffectManager.setCurrent(.SPAWNING);

        //_ = WizardManager.onceTime(.ATTACKING_1) or EffectManager.onceTime(.SPAWNING);
        Inventory.slotSetting(event.inv_objects);

        Areas.increaseInter();
        event.objectsSetUp(event.grid_objects);

        //WizardManager.reset();
    }

    fn idle() void {
        if (slots_filled) {
            Wizard.reset();
            WizardManager.reset();
            Inventory.clear();
            // EffectManager.reset();
            slots_filled = false;
        }
    }

    pub fn getCurrentEvent() *Event {
        return &level.events[level.i_event];
    }

    pub fn getPreviousEvent() *Event {
        const i_event: usize = if (level.i_event > 0) level.i_event - 1 else 0;

        return &level.events[i_event];
    }

    pub fn wizardHasPlaced() bool {
        const event = Level.getCurrentEvent();
        const currentKey = Areas.getCurrentInterKey();
        for (event.inv_objects) |obj| {
            if (obj.key == currentKey + 1) {
                return true;
            }
        }
        return false;
    }

    fn slow_motion(elf: *Elf) !void {
        var event: Event = level.events[level.i_event];

        const animationState: bool = WizardManager.onceTime(.ATTACKING_1) or EffectManager.onceTime(.SPAWNING);
        if (level.i_event == 0) CutScene.setQuiet(true);

        if (animationState) {
            return;
        }

        Event.slow_motion_effect(elf);

        if (slots_filled == false) {
            // print("EVENT {d} TRIGGERED\n", .{level.i_event});

            Inventory.slotSetting(event.inv_objects);
            event.objectsSetUp(event.grid_objects);
            auto_death_timer_active = true;

            slots_filled = true;
        }
    }

    fn complete() void {
        var event: Event = level.events[level.i_event];

        print("EVENT {d} COMPLETED\n", .{level.i_event});

        Inventory.clear();

        event.objectsCleaning(event.grid_objects);
        Grid.reset();
        EffectManager.setCurrent(.DESPAWNING);
        //_ = EffectManager.onceTime(.SPAWNING);
        auto_death_timer_active = false;

        playerEventstatus = .IDLE_AREA;

        level.i_event += 1;

        if (level.i_event == level.event_nb) {
            levelStatement = .PRE_COMPLETED;
            return;
        }
    }

    pub fn getLevelStatement() LevelStatement {
        return levelStatement;
    }

    fn drawIntermediateArea(event_num: usize) void {
        const event: Event = level.events[event_num];
        if (event.areas.intermediate_areas_nb == 0 or event.areas.intermediate_areas_nb == event.areas.current_inter_area) {
            return;
        }

        const c_x: f32 = event.areas.intermediate_areas[event.areas.current_inter_area].x;
        const c_y: f32 = event.areas.intermediate_areas[event.areas.current_inter_area].y;
        const c_w: f32 = event.areas.intermediate_areas[event.areas.current_inter_area].w;
        const c_h: f32 = event.areas.intermediate_areas[event.areas.current_inter_area].z;
        // print("OK {d} {d} {d} {d}\n", .{ c_x, c_y, c_w, c_h });

        const rec: rl.Rectangle = .init(c_x, c_y, c_w, c_h);
        const rec2: rl.Rectangle = .init(CursorManager.selfReturn().mouseX, CursorManager.selfReturn().mouseY, 10, 10);

        if (rl.Rectangle.checkCollision(rec, rec2)) {
            //  print("OK {d} {d} {d} {d}\n", .{ c_x, c_y, c_w, c_h });
        }

        rl.drawRectangleRec(.init(c_x, c_y, c_w, c_h), rl.Color.alpha(.yellow, 255));
    }

    fn eventDrawing(event_num: usize) void {
        if (levelStatement == .COMPLETED or levelStatement == .PRE_COMPLETED or level.events[level.i_event].already_triggered) {
            return;
        }
        const event: Event = level.events[event_num];

        const c_x: f32 = event.areas.completed_area.x;
        const c_y: f32 = event.areas.completed_area.y;
        const c_w: f32 = event.areas.completed_area.w;
        const c_h: f32 = event.areas.completed_area.z;

        const t_x: f32 = event.areas.trigger_area.x;
        const t_y: f32 = event.areas.trigger_area.y;
        const t_w: f32 = event.areas.trigger_area.w;
        const t_h: f32 = event.areas.trigger_area.z;

        const grid: Grid = Grid.selfReturn();

        rl.drawRectangleRec(.init(c_x, c_y, c_w, c_h), rl.Color.alpha(.green, 250));

        rl.drawRectangleRec(.init(t_x, t_y, t_w, t_h), rl.Color.alpha(.yellow, 250));

        const cell: Cell = grid.cells[event.grid_objects[0].y][event.grid_objects[0].x];
        rl.drawRectangleRec(.init(cell.x, cell.y, cell.width, cell.height), .beige);
    }
};
