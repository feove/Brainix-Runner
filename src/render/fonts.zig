const std = @import("std");
const rl = @import("raylib");

pub var fontManager: FontManager = undefined;

pub const FontManager = struct {
    fonts: std.AutoHashMapUnmanaged(u32, rl.Font),

    pub fn init(allocator: std.mem.Allocator) !void {
        fontManager = FontManager{
            .fonts = .{},
        };

        try fontManager.loadFont(allocator, 32);
        try fontManager.loadFont(allocator, 26);
        try fontManager.loadFont(allocator, 24);
        try fontManager.loadFont(allocator, 16);
    }

    pub fn loadFont(self: *FontManager, allocator: std.mem.Allocator, size: u32) !void {
        const path = "assets/fonts/pixelart.ttf";

        if (self.fonts.get(size)) |_| return;

        const font = try rl.loadFontEx(path, @as(i32, @intCast(size)), null);
        try self.fonts.put(allocator, size, font);
    }

    pub fn get(self: *FontManager, size: u32) ?rl.Font {
        return self.fonts.get(size);
    }

    pub fn drawText(text: [:0]const u8, x: f32, y: f32, size: u32, spacing: f32, color: rl.Color) void {
        if (fontManager.get(size)) |font| {
            rl.drawTextEx(font, text, .init(x, y), @as(f32, @floatFromInt(size)), spacing, color);
        }
    }

    pub fn deinit() void {
        var it = fontManager.fonts.iterator();
        while (it.next()) |entry| {
            rl.unloadFont(entry.value_ptr.*);
        }
    }
};
