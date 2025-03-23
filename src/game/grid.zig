const std = @import("std");
const rl = @import("raylib");

const GRID_X: f32 = 50;
const GRID_Y: f32 = 50;

const NB_ROWS: usize = 20;
const NB_COLS: usize = 25;

const CELL_WIDTH: f32 = 32;
const CELL_HEIGHT: f32 = 32;

pub const Cell = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
};

pub const Grid = struct {
    x: f32,
    y: f32,
    nb_rows: usize,
    nb_cols: usize,

    cells: [][]Cell,

    pub fn init(allocator: std.mem.Allocator) !@This() {
        const cells = try allocator.alloc([]Cell, NB_ROWS);

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

        return Grid{
            .x = GRID_X,
            .y = GRID_Y,
            .nb_rows = NB_ROWS,
            .nb_cols = NB_COLS,
            .cells = cells,
        };
    }

    pub fn deinit(self: *Grid, allocator: std.mem.Allocator) void {
        for (self.cells) |row| {
            allocator.free(row);
        }
        allocator.free(self.cells);
    }
};
