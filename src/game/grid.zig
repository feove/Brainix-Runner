const std = @import("std");
const rl = @import("raylib");

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
    OBSTACLE,
};

pub const Cell = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    type: CellType = CellType.AIR,
};

fn cellSizeInit() void {
    CELL_WIDTH = @as(f32, @floatFromInt(rl.getScreenWidth() - 2 * OFFSET)) / @as(f32, @floatFromInt(NB_COLS));
    CELL_HEIGHT = @as(f32, @floatFromInt(rl.getScreenHeight() - 2 * OFFSET)) / @as(f32, @floatFromInt(NB_ROWS));
}

pub const Grid = struct {
    x: f32,
    y: f32,
    nb_rows: usize,
    nb_cols: usize,

    cells: [][]Cell,

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
        };

        grid.groundDefine(1, grid.nb_rows - 2, grid.nb_cols - 2, 1);
    }

    pub fn selfReturn() Grid {
        return grid;
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
    }

    pub fn deinit(self: *Grid, allocator: std.mem.Allocator) void {
        for (self.cells) |row| {
            allocator.free(row);
        }
        allocator.free(self.cells);
    }
};
