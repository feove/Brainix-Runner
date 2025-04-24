const std = @import("std");
const rl = @import("raylib");
const Elf = @import("player.zig").Elf;
const HUD = @import("utils.zig").HUD;
const Inventory = @import("inventory.zig").Inventory;
const print = @import("std").debug.print;

pub var grid: Grid = undefined;

const GRID_X: f32 = 50;
const GRID_Y: f32 = 50;

const OFFSET: i32 = @intFromFloat(GRID_X);

const NB_ROWS: usize = 10;
const NB_COLS: usize = 10;

var CELL_WIDTH: f32 = undefined;
var CELL_HEIGHT: f32 = undefined;

pub const CellType = enum {
    AIR,
    GROUND,
    SPIKE,
    PAD,
    EMPTY,
};

pub const CellAround = enum {
    UP,
    RIGHT,
    LEFT,
    BOTTOM,
    NONE,
};

pub const Cell = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    type: CellType = CellType.AIR,
    padding: f32 = 5,
    isSelected: bool = false,
};

fn cellSizeInit() void {
    CELL_WIDTH = @as(f32, @floatFromInt(rl.getScreenWidth() - 2 * OFFSET)) / @as(f32, @floatFromInt(NB_COLS));
    CELL_HEIGHT = @as(f32, @floatFromInt(rl.getScreenHeight() - 3 * OFFSET)) / @as(f32, @floatFromInt(NB_ROWS));
}

pub const Grid = struct {
    x: f32,
    y: f32,
    nb_rows: usize,
    nb_cols: usize,
    width: f32,
    height: f32,

    cells: [][]Cell,
    cacheCell: CellType = CellType.EMPTY,

    pub fn selfReturn() Grid {
        return grid;
    }

    pub fn interactions(self: *Grid) void {
        cellManagement();
        _ = self;
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

        grid.groundDefine(0, grid.nb_rows - 2, grid.nb_cols, 1);
    }

    fn removeCell(i: usize, j: usize) void {
        const tmpCell: CellType = grid.cells[j][i].type;
        grid.cells[j][i].type = CellType.AIR;
        grid.cacheCell = tmpCell;
    }

    pub fn cellManagement() void {
        // const hud = HUD.selfReturn();
        const inv = Inventory.selfReturn();

        if (HUD.cursorInGrid()) {
            for (0..grid.nb_cols) |i| {
                for (0..grid.nb_rows) |j| {
                    grid.cells[j][i].isSelected = false;

                    //If cursor in cell
                    if (HUD.cursorInCell(grid.cells[j][i])) {
                        grid.cells[j][i].isSelected = true;

                        if (rl.isMouseButtonPressed(rl.MouseButton.right)) {
                            removeCell(i, j);
                        }

                        if (rl.isMouseButtonPressed(rl.MouseButton.left)) {

                            //Place Item on terrain from Inventory
                            if (inv.cellFromInventory != CellType.EMPTY) {
                                if (grid.cells[j][i].type == CellType.AIR) {
                                    grid.cells[j][i].type = inv.cellFromInventory;
                                    Inventory.clearCellFromInventory();
                                }
                                continue;
                            }

                            //Take item from terrain
                            if (grid.cells[j][i].type != CellType.AIR and grid.cells[j][i].type != CellType.EMPTY) {
                                Inventory.setCellFromInventory(grid.cells[j][i].type);
                                grid.cells[j][i].type = CellType.AIR;
                            }
                        }
                    }
                }
            }
        }
    }

    pub fn groundDefine(self: *Grid, x: usize, y: usize, width: usize, height: usize) void {
        if (x + width > self.nb_cols or y + height > self.nb_rows) {
            return;
        }

        for (x..x + width) |i| {
            for (y..y + height) |j| {
                self.cells[j][i].type = CellType.GROUND;
            }
        }

        //self.cells[7][6].type = CellType.SPIKE;
        // self.cells[7][4].type = CellType.GROUND;

    }

    pub fn deinit(self: *Grid, allocator: std.mem.Allocator) void {
        for (self.cells) |row| {
            allocator.free(row);
        }
        allocator.free(self.cells);
    }
};

//Need PAD only over ground condition
