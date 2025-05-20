const std = @import("std");
const rl = @import("raylib");
const print = std.debug.print;

const player = @import("../entity/elf.zig");
const Elf = player.Elf;
const HitBox = player.HitBox;

const HUD = @import("../game/utils.zig").HUD;
const Inventory = @import("../game/inventory.zig").Inventory;

const AroundConfig = @import("../game/terrain_object.zig").AroundConfig;
const Object = @import("../game/terrain_object.zig").Object;

const WizardManager = @import("../game/animations/wizard_anims.zig").WizardManager;
const EffectManager = @import("../game/animations/effects_spawning.zig").EffectManager;

pub var grid: Grid = undefined;

const GRID_X: f32 = 65;
const GRID_Y: f32 = 50;

const OFFSET: i32 = @intFromFloat(GRID_X);

const NB_ROWS: usize = 10;
const NB_COLS: usize = 13;

var CELL_WIDTH: f32 = undefined;
var CELL_HEIGHT: f32 = undefined;

var GROUND_POS: rl.Vector2 = undefined;

pub const CellType = enum {
    AIR,
    GROUND,
    SPIKE,
    PAD,
    UP_PAD,
    EMPTY,
    ANY,
    VOID,
    DOOR,
    BOOST,
};

pub var replaceable: []CellType = undefined;

pub const Cell = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    object: Object,
    padding: f32 = 5,
    isSelected: bool = false,
    CanBeMove: bool = false,
};

fn cellSizeInit() void {
    CELL_WIDTH = @as(f32, @floatFromInt(rl.getScreenWidth() - 2 * OFFSET)) / @as(f32, @floatFromInt(NB_COLS));
    CELL_HEIGHT = @as(f32, @floatFromInt(rl.getScreenHeight() - 3 * OFFSET)) / @as(f32, @floatFromInt(NB_ROWS)) + 5;
}

pub const Grid = struct {
    x: f32,
    y: f32,
    nb_rows: usize,
    nb_cols: usize,
    width: f32,
    height: f32,

    cells: [][]Cell,
    cacheCell: CellType = .EMPTY,

    pub fn selfReturn() Grid {
        return grid;
    }

    pub fn interactions(self: *Grid) void {
        cellManagement();
        _ = self;
    }

    pub fn getFrontEndPostion(i: usize, j: usize) rl.Vector2 {
        return .init(grid.cells[j][i].x, grid.cells[j][i].y);
    }

    pub fn init(allocator: std.mem.Allocator) !void {
        const cells = try allocator.alloc([]Cell, NB_ROWS);

        cellSizeInit();

        for (cells, 0..) |*row, i| {
            row.* = try allocator.alloc(Cell, NB_COLS);

            for (row.*, 0..) |*cell, j| {
                cell.* = Cell{
                    .x = GRID_X + @as(f32, @floatFromInt(j)) * CELL_WIDTH,
                    .y = GRID_Y + @as(f32, @floatFromInt(i)) * CELL_HEIGHT,
                    .width = CELL_WIDTH,
                    .height = CELL_HEIGHT,
                    .object = Object{
                        .x = i,
                        .y = j,
                        .type = .AIR,
                    },
                };
            }
        }

        grid = Grid{
            .x = GRID_X,
            .y = GRID_Y,
            .nb_rows = NB_ROWS,
            .nb_cols = NB_COLS,
            .cells = cells,
            .width = CELL_WIDTH * NB_COLS,
            .height = CELL_HEIGHT * NB_ROWS,
        };

        replaceable = try allocator.alloc(CellType, 3);
        replaceable[0] = .AIR;
        replaceable[1] = .EMPTY;
        replaceable[2] = .DOOR;

        reset();
    }

    pub fn reset() void {
        for (0..NB_ROWS) |j| {
            for (0..NB_COLS) |i| {
                grid.cells[j][i].object = Object{ .type = .AIR, .canPlayerTake = false };
            }
        }

        grid.cacheCell = .EMPTY;
        Inventory.clearinv_cell();

        //Anims
        WizardManager.reset();

        grid.groundDefine(0, grid.nb_rows - 2, grid.nb_cols, 1);

        grid.setExitDoor(grid.nb_cols - 1, 6);
    }

    fn removeCell(i: usize, j: usize) void {
        const tmpCell: CellType = grid.cells[j][i].object.type;
        grid.cells[j][i].object.type = .AIR;
        grid.cacheCell = tmpCell;
    }

    fn canGetCell(cell: CellType) bool {
        for (replaceable) |cellReplace| {
            if (cell == cellReplace) {
                return false;
            }
        }
        return true;
    }

    fn cellSet(i: usize, j: usize, cell: CellType) bool {
        const object_size: usize = Object.objectSize(cell);

        if (object_size == 1) {
            grid.cells[j][i].object.type = cell;
            return true;
        }

        if (i < grid.nb_cols - 1 and grid.cells[j][i + 1].object.type == .AIR) {
            grid.cells[j][i].object.type = cell;
            grid.cells[j][i + 1].object.type = cell;
            grid.cells[j][i + 1].object.canPlayerTake = true;
            grid.cells[j][i + 1].object.tail = true;
            grid.cells[j][i].object.tail = false;
            return true;
        }

        return false;
    }

    fn removeFromGrid(i: usize, j: usize, cell: CellType) void {
        const object_size: usize = Object.objectSize(cell);
        const current_cell = grid.cells[j][i].object;

        var next_cell = current_cell;
        if (i + 1 <= grid.nb_cols - 1) {
            next_cell = grid.cells[j][i + 1].object;
        }

        grid.cells[j][i].object.type = .AIR;

        if (object_size > 1) {
            if (i <= grid.nb_cols - 1 and next_cell.type == cell) {
                if (!current_cell.tail) {
                    grid.cells[j][i + 1].object.type = .AIR;
                    return;
                }
            }
            grid.cells[j][i - 1].object.type = .AIR;
        }
    }

    fn playerOnCell(cell: *Cell, invType: CellType) bool {
        const elf = Elf.selfReturn();
        const rec1: rl.Rectangle = .init(cell.x, cell.y, cell.width, cell.height);
        const rec2: rl.Rectangle = .init(elf.x + elf.width * 0.3, elf.y, elf.width * 0.4, elf.height * 0.4);

        const CanBePlaced: bool = rl.Rectangle.checkCollision(rec1, rec2) and invType == .GROUND;

        return CanBePlaced;
    }

    pub fn cellManagement() void {
        // const hud = HUD.selfReturn();
        const inv = Inventory.selfReturn();

        var canBePlaced: bool = true;
        var left_click: bool = false;
        var anyCellSelected: bool = false;
        const cursorInGrid: bool = HUD.cursorInGrid();
        //HUD.setPlaceAllowing(inv.anySlotSelected);

        if (cursorInGrid) {
            for (0..grid.nb_cols) |i| {
                for (0..grid.nb_rows) |j| {
                    grid.cells[j][i].isSelected = false;

                    if (HUD.cursorInCell(grid.cells[j][i])) {
                        grid.cells[j][i].isSelected = true;
                        anyCellSelected = true;

                        const PlayerOnCell: bool = playerOnCell(&grid.cells[j][i], inv.cell.type);
                        canBePlaced = (!canBePlaced or !PlayerOnCell) and grid.cells[j][i].object.type == .AIR;

                        if (rl.isMouseButtonPressed(rl.MouseButton.right)) {
                            removeCell(i, j);
                        }

                        left_click = rl.isMouseButtonPressed(rl.MouseButton.left);

                        //Place Item over terrain from Inventory
                        if (inv.cell.type != .EMPTY) {
                            if (grid.cells[j][i].object.type == .AIR) {
                                if (AroundConfig.cellAroundchecking(i, j, inv.cell.type) or PlayerOnCell) {
                                    canBePlaced = false;
                                    continue;
                                }

                                if (left_click and cellSet(i, j, inv.cell.type)) {
                                    grid.cells[j][i].object.canPlayerTake = true;
                                    Inventory.clearinv_cell();
                                }
                            }
                            continue;
                        }

                        //Take item from terrain .object.playerCanTake
                        if (left_click and grid.cells[j][i].object.canPlayerTake) {
                            Inventory.setinv_cell(grid.cells[j][i].object.type);
                            removeFromGrid(i, j, grid.cells[j][i].object.type);
                        }
                    }
                }
            }
            canBePlaced = canBePlaced and anyCellSelected;
        }
        canBePlaced = canBePlaced and (cursorInGrid != HUD.cursorInInventory());

        HUD.setPlaceAllowing(canBePlaced);
    }

    pub fn getGroundPos() rl.Vector2 {
        return GROUND_POS;
    }

    fn groundDefine(self: *Grid, x: usize, y: usize, width: usize, height: usize) void {
        if (x + width > self.nb_cols or y + height > self.nb_rows) {
            return;
        }

        for (x..x + width) |i| {
            for (y..y + height) |j| {
                self.cells[j][i].object.type = .GROUND;
            }
        }

        GROUND_POS = .init(self.cells[y][x].x, self.cells[y][x].y);

        //self.cells[7][6].type = .SPIKE;
        // self.cells[7][4].type = .GROUND;

    }

    fn setExitDoor(self: *Grid, x: usize, y: usize) void {
        if (x > self.nb_cols or y + 1 > self.nb_rows) {
            return;
        }
        self.cells[y][x].object.type = .DOOR;
        self.cells[y + 1][x].object.type = .DOOR;
    }

    pub fn deinit(self: *Grid, allocator: std.mem.Allocator) void {
        for (self.cells) |row| {
            allocator.free(row);
        }
        allocator.free(self.cells);
    }
};
