const elf = @import("elf.zig");
const Elf = elf.Elf;
const elf_anims = @import("../game/animations/elf_anims.zig");

const wizard = @import("wizard.zig");
const Wizard = wizard.Wizard;
const wizard_anims = @import("../game/animations/wizard_anims.zig");

pub const Entity = struct {
    pub fn init() !void {
        elf.initElf();
        wizard.init();
    }

    pub fn draw() void {
        Elf.drawElf();
        Wizard.draw();
    }
};
