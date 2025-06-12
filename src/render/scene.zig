const std = @import("std");
const print = std.debug.print;

const terrain = @import("../terrain/grid.zig");
const Grid = terrain.Grid;
const CellType = terrain.CellType;
const Cell = terrain.Cell;

const object = @import("../game/terrain_object.zig");
const rl = @import("raylib");
const anim = @import("../game/animations/animations_manager.zig");
const textures = @import("textures.zig");
const Sprite = textures.Sprite;
const SpriteDefaultConfig = textures.SpriteDefaultConfig;

const player = @import("../entity/elf.zig");
const Inventory = @import("../game/inventory.zig").Inventory;
const CursorManager = @import("../game/cursor.zig").CursorManager;
const hud = @import("../interface/hud.zig");
const Interface = hud.Interface;
const Selector = @import("../interface/selector.zig").Selector;
const scenarios = @import("../game/level/cutscene_manager.zig");

//Tmp Drawing
pub fn drawScene() !void {
    // rl.clearBackground(.white);
    drawBackgrounds();

    drawGrid();
    drawGround();

    drawUnderGroundDeco();
    drawIndications();
    drawInventory();

    //try drawItemNumber();

    CursorManager.spriteUnderCursor();
}

fn drawGrid() void {
    const grid: Grid = Grid.selfReturn();

    for (0..grid.nb_rows) |r| {
        for (0..grid.nb_cols) |c| {
            const cell = grid.cells[r][c];

            //drawcell(cell.x, cell.y, cell.width, cell.height, 0, false, .black);
            //drawcell(cell.x, cell.y, cell.width, cell.height, 0, false, .black)

            if (cell.isSelected) {
                // drawcell(cell.x, cell.y, cell.width, cell.height, cell.padding, false, .black);
                drawSelectedSlot(
                    cell.x,
                    cell.y,
                    cell.width,
                    cell.height,
                    0,
                    100,
                );
            }
            if (r < grid.nb_rows - 2) {
                switch (cell.object.type) {
                    .AIR => {},
                    .GROUND => {
                        var sprite: Sprite = textures.sprites.granite_l3;
                        if (cell.object.canPlayerTake) {
                            sprite = textures.sprites.granite_pure_l4;
                        }
                        Sprite.draw(textures.spriteSheet, sprite, rl.Vector2{ .x = cell.x, .y = cell.y }, 4.15, .white);
                    },
                    .SPIKE => {
                        //drawSpike(cell.x, cell.y, cell.width, cell.height, cell.padding, .red);
                        // Sprite.draw(textures.all_weapons, textures.sprites.simple_spike, .init(cell.x, cell.y + 10), 3.90, .white);
                        Sprite.draw(textures.all_weapons, textures.sprites.wood_block_spikes, .init(cell.x - 10, cell.y - 8), 2.80, .white);
                    },
                    .PAD => {
                        //anim.jumper_sprite.resetPos();
                        pad_drawing(c, r, cell);
                    },
                    .UP_PAD => {
                        pad_drawing(c, r, cell);
                    },
                    .DOOR => {
                        //drawcell(cell.x, cell.y, cell.width, cell.height, 0, true, .brown);
                    },
                    .BOOST => {
                        //drawcell(cell.x, cell.y, cell.width, cell.height, 0, true, .beige),
                        //  print("r : {d} c : {d}\n", .{ r, c });
                        var x = cell.x + cell.width;
                        if (grid.cells[r][c].object.tail) {
                            x -= cell.width / 4 + 1;
                            //cell.padding;
                        }
                        anim.boost_sprite.setPos(c, r);
                        anim.boost_sprite.isRunning = true;
                        anim.boost_sprite.update(rl.getFrameTime() / (player.time_divisor / 2), 1);
                        anim.boost_sprite.draw(.{ .x = x, .y = cell.y + cell.padding }, 3.1, 90, 200, c, r);
                    },
                    else => drawcell(cell.x, cell.y, cell.width, cell.height, 0, true, .gray),
                }
            }
        }
    }
}

fn pad_drawing(c: usize, r: usize, cell: Cell) void {
    if (anim.jumper_sprite.x != c and anim.jumper_sprite.y != r) {
        Sprite.drawWithRotation(
            anim.jumper_sprite.texture,
            anim.jumper_sprite.sprite,
            rl.Vector2{ .x = cell.x, .y = cell.y + cell.height / 4 + 5 },
            2.7,
            0,
            255,
            false,
        );
    } else {
        //anim.jumper_sprite.x = 0;
        //anim.jumper_sprite.y = 0;
        anim.jumper_sprite.isRunning = true;
        anim.jumper_sprite.update(rl.getFrameTime(), 1);
        anim.jumper_sprite.draw(.{ .x = cell.x, .y = cell.y + cell.height / 4 + 5 }, 2.7, 0, 255, c, r);
    }
}

fn drawBackgrounds() void {
    // const grid = Grid.selfReturn();

    // textures .Sprite.draw(textures.forest_background, textures.sprites.forest_background, .init(-100, 0), 0.85);
    textures.Sprite.draw(textures.oak_bg_lyr_1, textures.sprites.oak_bg_lyr_1, .init(-100, 0), 3.5, .white);
    textures.Sprite.draw(textures.oak_bg_lyr_2, textures.sprites.oak_bg_lyr_2, .init(-100 + 0.02 * player.elf.x, 0), 3.5 + 0.00001 * player.elf.x, .white);
    textures.Sprite.draw(textures.oak_bg_lyr_3, textures.sprites.oak_bg_lyr_3, .init(-100 - 0.01 * player.elf.x, 0), 3.5, .white);

    Spawndoor();

    drawBorders();
}

fn Spawndoor() void {
    const door_is_opened: bool = scenarios.door_opened;
    const quiet_door: bool = scenarios.quiet_closed_door;

    const scale = 4.0;
    const x: f32 = 56;
    const y: f32 = 382;
    const bw: f32 = 16 * scale;
    const bh: f32 = 16 * scale;
    const color: rl.Color = .gray;

    object.DoorPos = rl.Vector2.init(x + 25, y + bh + 25);

    const door_color: rl.Color = if (door_is_opened) .black else .white;
    const closed_door_color: rl.Color = if (quiet_door) .gray else .white;

    textures.Sprite.draw(textures.dungeons_tile, textures.sprites.dungeon_stair_right, .init(x, y), scale, color);

    textures.Sprite.draw(textures.dungeons_tile, textures.sprites.dungeon_stair_right, .init(x + bw, y + bh), scale, color);

    textures.Sprite.draw(textures.dungeons_tile, textures.sprites.dungeon_stair_right, .init(x + bw * 2, y + bh * 2), scale, color);

    textures.Sprite.draw(textures.dungeons_tile, textures.sprites.dungeon_wall_right_1, .init(x, y + bh), scale, color);

    textures.Sprite.draw(textures.dungeons_tile, textures.sprites.dungeon_long_wall_1, .init(x, y + bh * 2), scale, color);

    textures.Sprite.draw(textures.dungeons_tile, textures.sprites.dungeon_closed_door, .init(object.DoorPos.x, object.DoorPos.y), 3.2, door_color);

    if (door_is_opened) {
        textures.Sprite.draw(textures.dungeons_tile, textures.sprites.dungeon_opened_door, .init(x, y + bh + 25), 3.2, closed_door_color);
    }
}

fn drawBorders() void {
    const height: usize = Grid.selfReturn().nb_rows + 2;

    //Left Side
    for (0..height) |r| {
        textures.Sprite.drawWithRotation(
            textures.spriteSheet,
            textures.sprites.granite_border,
            rl.Vector2.init(0.0, @as(f32, @floatFromInt(r)) * textures.BLOCK_SIZE * 4.17),
            4.17,
            270.0,
            255,
            false,
        );
    }

    //Right Side
    for (0..height - 1) |r| {
        textures.Sprite.drawWithRotation(
            textures.spriteSheet,
            textures.sprites.granite_border,
            rl.Vector2.init(1000.0, @as(f32, @floatFromInt(r)) * textures.BLOCK_SIZE * 4.17),
            4.17,
            90.0,
            255,
            false,
        );
    }
}

fn drawUnderGroundDeco() void {
    //const grid: Grid = Grid.selfReturn();
    //const block_size = textures.BLOCK_SIZE * 4.15;
    //textures.Sprite.draw(textures.spriteSheet, textures.sprites.granite_l2, .init(grid.cells[grid.nb_rows - 1][0].x, grid.cells[grid.nb_rows - 1][0].y + block_size), 4.15, .white);

    //Good Option
    textures.Sprite.draw(textures.env_ground, textures.sprites.env_ground_leaves, .init(50, 670), 6.5, .gray);

    textures.Sprite.draw(textures.spriteSheet, textures.sprites.bushGreenBorders, .init(-200, 600), 5, .white);
    textures.Sprite.draw(textures.spriteSheet, textures.sprites.bushGreenBorders, .init(800, 600), 5, .white);
}

fn drawGround() void {
    const grid: Grid = Grid.selfReturn();
    const block_scale: f32 = 4.19;

    for (grid.nb_rows - 2..grid.nb_rows) |r| {
        for (0..grid.nb_cols) |c| {
            const cell = grid.cells[r][c];

            if (c == 0 or c == grid.nb_cols - 1) {
                if (r == grid.nb_rows - 2) {
                    Sprite.draw(textures.spriteSheet, textures.sprites.carved_granite, rl.Vector2{ .x = cell.x, .y = cell.y }, block_scale, .white);
                    Sprite.draw(textures.spriteSheet, textures.sprites.granite_pillar, rl.Vector2{ .x = cell.x, .y = cell.y + cell.height }, block_scale, .white);
                }
                continue;
            }

            if (r == grid.nb_rows - 2) {
                Sprite.draw(textures.spriteSheet, textures.sprites.granite_beam, rl.Vector2{ .x = cell.x, .y = cell.y }, block_scale, .white);

                //Scripted
                if (c == 2 or c == 5 or c == 9) {
                    Sprite.draw(textures.spriteSheet, textures.sprites.granite_pure_l4, rl.Vector2{ .x = cell.x, .y = cell.y }, block_scale, .white);
                    Sprite.draw(textures.spriteSheet, textures.sprites.granite_pure_l3, rl.Vector2{ .x = cell.x, .y = cell.y + cell.height }, block_scale, .white);
                }
                continue;
            }

            if (c != 2 and c != 5 and c != 9) {
                Sprite.draw(textures.spriteSheet, textures.sprites.granite_l3, rl.Vector2{ .x = cell.x, .y = cell.y + 1 }, block_scale, .white);
            }
        }
    }
}

pub fn getRandomNumber(min: u32, max: u32) u32 {
    // var prng = std.rand.DefaultPrng.init(@as(u64, @bitCast(std.time.milliTimestamp())));
    var prng = std.Random.DefaultPrng.init(@as(u64, @bitCast(std.time.milliTimestamp())));
    return prng.random().intRangeAtMost(u32, min, max);
}

fn drawIndications() void {
    const inv = Inventory.selfReturn();
    for (0..inv.size) |i| {
        const sprite: Sprite = Selector.indexToSprite(i);
        const slot = inv.slots[i];

        textures.Sprite.drawCustom(
            textures.keyboard_btns,
            .{
                .position = .init(slot.pos.x + slot.padding / 3, slot.pos.y - slot.height - slot.padding),
                .sprite = sprite,
                .scale = if (slot.isSelected) 3.1 else 3.0,
                .alpha = if (slot.isSelected) 0.70 else 0.90,
                .color = if (slot.isSelected) .gray else .white,
            },
        );
    }
}

fn drawInventory() void {
    const inv = Inventory.selfReturn();

    //Draw Inventory Borders
    drawcell(inv.pos.x, inv.pos.y, inv.width, inv.height, 0, false, .black);

    //textures.Sprite.draw(textures.inventory_hud, textures.sprites.inventory_hud, .init(inv.pos.x - 10, inv.pos.y - 70), 1.5, .white);
    textures.Sprite.draw(textures.simple_inventory_hud, textures.sprites.simple_inventory_hud, .init(inv.pos.x - 30, inv.pos.y - 30), 4.76, .white);

    for (0..inv.size) |i| {
        const slot = inv.slots[i];

        switch (slot.object.type) {
            .GROUND => Sprite.draw(textures.spriteSheet, textures.sprites.granite_pure_l4, rl.Vector2{ .x = slot.pos.x, .y = slot.pos.y }, 3.5, .white),
            .SPIKE => drawSpike(slot.pos.x, slot.pos.y - slot.padding, slot.width, slot.height + slot.padding, slot.padding, .red),
            .AIR => drawcell(slot.pos.x, slot.pos.y, slot.width, slot.height, 0, true, .white),
            .PAD => Sprite.drawWithRotation(anim.jumper_sprite.texture, anim.jumper_sprite.sprite, rl.Vector2{ .x = slot.pos.x, .y = slot.pos.y + slot.height / 5 }, 2.7, 0, 255, false),
            .UP_PAD => {
                Sprite.drawWithRotation(anim.jumper_sprite.texture, anim.jumper_sprite.sprite, rl.Vector2{ .x = slot.pos.x, .y = slot.pos.y + slot.height / 5 }, 2.7, 0, 255, false);
                Sprite.drawWithRotation(textures.all_weapons, textures.sprites.arrow_icn, rl.Vector2{ .x = slot.pos.x + slot.width * 0.20, .y = slot.pos.y + slot.height * 0.60 }, 1.70, 0, 255, false);
            }, //drawcell(slot.pos.x, slot.pos.y + slot.height - slot.height / 4, slot.width, slot.height / 4, 0, true, .orange),
            .BOOST => Sprite.draw(anim.boost_sprite.texture, anim.boost_sprite.sprite, rl.Vector2{ .x = slot.pos.x, .y = slot.pos.y }, 2.7, .white),
            .EMPTY => {},
            else => {},
        }

        //drawcell(, slot.width, slot.height / 4, 0, true, .yellow),

        if (slot.object.count != 0) {
            const count: f32 = @as(f32, @floatFromInt(slot.object.count));
            const x_offset: f32 = ((count - 1) * (textures.sprites.number_key.src.width - 1));
            Sprite.drawCustom(
                textures.keys_sheet,
                SpriteDefaultConfig{
                    .sprite = textures.sprites.number_key,
                    .position = .init(slot.pos.x + slot.width / 2, slot.pos.y + slot.padding),
                    .x_offset = x_offset,
                    .scale = 2.5,
                },
            );
        }

        if (slot.isSelected) {
            drawSelectedSlot(
                slot.pos.x,
                slot.pos.y,
                slot.width,
                slot.height,
                0,
                150,
            );
        }
    }
}

fn drawItemNumber() !void {
    const inv = Inventory.selfReturn();

    for (0..inv.size) |i| {
        const x: i32 = @as(i32, @intFromFloat(inv.slots[i].pos.x + inv.slots[i].width - 2 * inv.slots[i].padding));
        const y: i32 = @as(i32, @intFromFloat(inv.slots[i].pos.y));
        if (inv.slots[i].object.type != .EMPTY) {
            const slot = inv.slots[i].object;

            if (i > 0 and slot.type == .BOOST and inv.slots[i - 1].object.type == .BOOST) {
                continue;
            }
            var buf: [16:0]u8 = undefined;
            const numAsString = try std.fmt.bufPrintZ(&buf, "{}", .{slot.count});
            rl.Text(numAsString, x, y, 30, .black);
        }
    }
}
fn drawSelectedSlot(x_f32: f32, y_f32: f32, width_f32: f32, height_f32: f32, padding: f32, alpha: f32) void {
    const p: i32 = @as(i32, @intFromFloat(padding));
    const x: i32 = @as(i32, @intFromFloat(x_f32));
    const y: i32 = @as(i32, @intFromFloat(y_f32));
    const width: i32 = @as(i32, @intFromFloat(width_f32));
    const height: i32 = @as(i32, @intFromFloat(height_f32));
    const a: u8 = @as(u8, @intFromFloat(alpha));

    const grayWithAlpha = rl.Color{
        .r = 130,
        .g = 130,
        .b = 130,
        .a = a,
    };

    rl.drawRectangle(x + p, y + p, width - 2 * p, height - 2 * p, grayWithAlpha);
}

//Casting de cons
fn drawcell(x_f32: f32, y_f32: f32, width_f32: f32, height_f32: f32, padding: f32, fill: bool, color: rl.Color) void {
    const p: i32 = @as(i32, @intFromFloat(padding));
    const x: i32 = @as(i32, @intFromFloat(x_f32));
    const y: i32 = @as(i32, @intFromFloat(y_f32));
    const width: i32 = @as(i32, @intFromFloat(width_f32));
    const height: i32 = @as(i32, @intFromFloat(height_f32));
    if (fill) {
        rl.drawRectangle(x + p, y + p, width - 2 * p, height - 2 * p, color);
    }
    rl.drawRectangleLines(x + p, y + p, width - 2 * p, height - 2 * p, .black);
}

fn drawLines(xs_f32: f32, ys_f32: f32, xe_f32: f32, ye_f32: f32) void {
    const xs: i32 = @as(i32, @intFromFloat(xs_f32));
    const ys: i32 = @as(i32, @intFromFloat(ys_f32));
    const xe: i32 = @as(i32, @intFromFloat(xe_f32));
    const ye: i32 = @as(i32, @intFromFloat(ye_f32));

    rl.drawLine(xs, ys, xe, ye, .black);
}

fn drawSpike(x: f32, y: f32, width: f32, height: f32, padding: f32, color: rl.Color) void {
    rl.drawTriangle(.init(x + width / 2, y + 2 * padding), .init(x + 2 * padding, y + height), .init(x + width - 2 * padding, y + height), color);
    rl.drawTriangleLines(.init(x + width / 2, y + 2 * padding), .init(x + 2 * padding, y + height), .init(x + width - 2 * padding, y + height), .black);
}
