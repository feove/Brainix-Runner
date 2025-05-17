const elf = @import("elf.zig");
const Elf = elf.Elf;
const elf_anims = @import("../game/animations/elf_anims.zig");

pub const Entity = struct {
    pub fn init() !void {
        elf.initElf();
    }

    pub fn draw() void {
        Elf.drawElf();
    }
};
