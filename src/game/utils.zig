const rl = @import("raylib");
const Grid = @import("grid.zig").Grid;
pub var hud = HUD{};

pub const HUD = struct {
    mouseX: i32 = undefined,
    mouseY: i32 = undefined,

    pub fn selfReturn() HUD {
        return hud;
    }

    pub fn refresh(self: *HUD) void {
        self.mouseX = rl.getMouseX();
        self.mouseY = rl.getMouseY();
    }

    pub fn cursorInGrid() bool {
        const grid: Grid = Grid.selfReturn();
        const grid_x = @as(i32, @intFromFloat(grid.x));
        const grid_y = @as(i32, @intFromFloat(grid.y));
        const grid_width = @as(i32, @intFromFloat(grid.cells[0][0].width)) * @as(i32, @intCast(grid.nb_rows));
        const grid_height = @as(i32, @intFromFloat(grid.height));

        const inAxeX: bool = hud.mouseX > grid_x and hud.mouseX < grid_x + grid_width;
        const inAxeY: bool = hud.mouseY > grid_y and hud.mouseY < grid_y + grid_height; 

        return inAxeX and inAxeY;
    }
};
