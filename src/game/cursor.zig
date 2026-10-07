const rl = @import("raylib");

const terrain = @import("../terrain/grid.zig");
const Grid = terrain.Grid;
const CellType = terrain.CellType;
const Cell = terrain.Cell;

const Inventory = @import("inventory.zig").Inventory;
const InvCell = @import("inventory.zig").InvCell;
const textures = @import("../render/textures.zig");
const anim = @import("animations/animations_manager.zig");
const Sprite = textures.Sprite;
pub var cursor_manager = CursorManager{};

pub const CursorManager = struct {
    mouseX: f32 = undefined,
    mouseY: f32 = undefined,
    CanPlaced: bool = false,

    pub fn selfReturn() CursorManager {
        return cursor_manager;
    }

    pub fn refresh() void {
        cursor_manager.mouseX = @as(f32, @floatFromInt(rl.getMouseX()));
        cursor_manager.mouseY = @as(f32, @floatFromInt(rl.getMouseY()));
    }

    pub fn getMouseX() f32 {
        return cursor_manager.mouseX;
    }

    pub fn getMouseY() f32 {
        return cursor_manager.mouseY;
    }

    pub fn setPlaceAllowing(canPlaced: bool) void {
        cursor_manager.CanPlaced = canPlaced;
    }

    pub fn cursorInGrid() bool {
        const grid: Grid = Grid.selfReturn();

        const inAxeX: bool = cursor_manager.mouseX > grid.x and cursor_manager.mouseX < grid.x + grid.cells[0][0].width * grid.width;
        const inAxeY: bool = cursor_manager.mouseY > grid.y and cursor_manager.mouseY < grid.y + grid.height;

        return inAxeX and inAxeY;
    }

    pub fn cursorInCell(cell: Cell) bool {
        const inAxeX: bool = cursor_manager.mouseX > cell.x and cursor_manager.mouseX < cell.x + cell.width;
        const inAxeY: bool = cursor_manager.mouseY > cell.y and cursor_manager.mouseY < cell.y + cell.height;

        return inAxeX and inAxeY;
    }

    pub fn cursorInInventory() bool {
        const inv: Inventory = Inventory.selfReturn();

        const inAxeX: bool = cursor_manager.mouseX > inv.pos.x and cursor_manager.mouseX < inv.pos.x + inv.width;
        const inAxeY: bool = cursor_manager.mouseY > inv.pos.y and cursor_manager.mouseY < inv.pos.y + inv.height;

        return inAxeX and inAxeY;
    }

    pub fn cursorInSlot(slot: InvCell) bool {
        const inAxeX: bool = cursor_manager.mouseX > slot.pos.x and cursor_manager.mouseX < slot.pos.x + slot.width;
        const inAxeY: bool = cursor_manager.mouseY > slot.pos.y and cursor_manager.mouseY < slot.pos.y + slot.height;

        return inAxeX and inAxeY;
    }

    pub fn spriteUnderCursor() void {
        const inv = Inventory.selfReturn();

        switch (inv.cell.type) {
            .GROUND => {
                Sprite.drawWithRotation(textures.spriteSheet, textures.sprites.granite_pure_l4, rl.Vector2{ .x = cursor_manager.mouseX - 20, .y = cursor_manager.mouseY - 20 }, 3.0, 0, 150, !cursor_manager.CanPlaced);
            },
            .PAD => {
                Sprite.drawWithRotation(anim.jumper_sprite.texture, anim.jumper_sprite.sprite, rl.Vector2{ .x = cursor_manager.mouseX - 20, .y = cursor_manager.mouseY - 20 }, 3.0, 0, 150, !cursor_manager.CanPlaced);
            },
            .UP_PAD => {
                Sprite.drawWithRotation(anim.jumper_sprite.texture, anim.jumper_sprite.sprite, rl.Vector2{ .x = cursor_manager.mouseX - 20, .y = cursor_manager.mouseY - 20 }, 3.0, 0, 150, !cursor_manager.CanPlaced);
            },
            .BOOST => {
                anim.boost_sprite.draw(.{ .x = cursor_manager.mouseX + 20, .y = cursor_manager.mouseY - 20 }, 3.1, 90, 200, 0, 0);
            },
            else => {},
        }
    }
};
