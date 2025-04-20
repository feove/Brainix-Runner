const rl = @import("raylib");
const Grid = @import("grid.zig").Grid;
const Cell = @import("grid.zig").Cell;
const Inventory = @import("inventory.zig").Inventory;
const InvCell = @import("inventory.zig").InvCell;
pub var hud = HUD{};

pub const HUD = struct {
    mouseX: f32 = undefined,
    mouseY: f32 = undefined,

    pub fn selfReturn() HUD {
        return hud;
    }

    pub fn refresh(self: *HUD) void {
        self.mouseX = @as(f32, @floatFromInt(rl.getMouseX()));
        self.mouseY = @as(f32, @floatFromInt(rl.getMouseY()));
    }

    pub fn cursorInGrid() bool {
        const grid: Grid = Grid.selfReturn();

        const inAxeX: bool = hud.mouseX > grid.x and hud.mouseX < grid.x + grid.cells[0][0].width * grid.width;
        const inAxeY: bool = hud.mouseY > grid.y and hud.mouseY < grid.y + grid.height;

        return inAxeX and inAxeY;
    }

    pub fn cursorInCell(cell: Cell) bool {
        const inAxeX: bool = hud.mouseX > cell.x + cell.padding and hud.mouseX < cell.x + cell.width - cell.padding;
        const inAxeY: bool = hud.mouseY > cell.y + cell.padding and hud.mouseY < cell.y + cell.height - cell.padding;

        return inAxeX and inAxeY;
    }

    pub fn cursorInInventory() bool {
        const inv: Inventory = Inventory.selfReturn();

        const inAxeX: bool = hud.mouseX > inv.pos.x and hud.mouseX < inv.pos.x + inv.width;
        const inAxeY: bool = hud.mouseY > inv.pos.y and hud.mouseY < inv.pos.y + inv.height;

        return inAxeX and inAxeY;
    }

    pub fn cursorInSlot(slot: InvCell) bool {
        const inAxeX: bool = hud.mouseX > slot.pos.x and hud.mouseX < slot.pos.x + slot.width;
        const inAxeY: bool = hud.mouseY > slot.pos.y and hud.mouseY < slot.pos.y + slot.height;

        return inAxeX and inAxeY;
    }
};
