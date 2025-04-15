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
    EMPTY,
};

pub const CellAround = enum {
    UP,
    RIGHT,
    LEFT,
    BOTTOM,
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
    width: f32,
    height: f32,

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
            .width = CELL_WIDTH * NB_COLS,
            .height = CELL_HEIGHT * NB_ROWS,
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

        //self.cells[3][3].type = CellType.GROUND;
        self.cells[6][8].type = CellType.GROUND;
        self.cells[7][7].type = CellType.GROUND;
    }

    fn i_and_j_assign(self: *Grid, i: *usize, j: *usize, x: f32, y: f32, x_offset: f32, y_offset: f32) void {
        i.* = @intFromFloat((x - self.x + x_offset) / CELL_WIDTH);
        j.* = @intFromFloat((y - self.y + y_offset) / CELL_HEIGHT);
    }

    pub fn playerCellAround(self: *Grid, x: f32, y: f32, cellAround: CellAround) CellType {
        var i: usize = 0;
        var j: usize = 0;

        switch (cellAround) {
            CellAround.UP => i_and_j_assign(self, &i, &j, x, y, 0, 0),
            CellAround.BOTTOM => i_and_j_assign(self, &i, &j, x, y, 0, -30),
            CellAround.LEFT => i_and_j_assign(self, &i, &j, x, y, 0, 0),
            CellAround.RIGHT => i_and_j_assign(self, &i, &j, x, y, 0, 0),
        }

        std.debug.print("i : {any} || j : {any}\n", .{ i, j });
        // Bounds check
        if (j >= self.cells.len or i >= self.cells[0].len) {
            return CellType.EMPTY;
        }

        return self.cells[j][i].type;
    }

    pub fn deinit(self: *Grid, allocator: std.mem.Allocator) void {
        for (self.cells) |row| {
            allocator.free(row);
        }
        allocator.free(self.cells);
    }
};
