const elf = @import("elf.zig");
const Elf = elf.Elf;
const elf_anims = @import("../game/animations/elf_anims.zig");

const demon = @import("demon.zig");
const Demon = demon.Demon;
const demon_anims = @import("../game/animations/demon_anims.zig");

pub const Entity = struct {
    pub fn init() !void {
        elf.initElf();
        demon.init();
    }

    pub fn draw() void {
        Elf.drawElf();
        Demon.draw();
    }
};
