const elf = @import("elf.zig");
const Elf = elf.Elf;
const elf_anims = @import("../game/animations/elf_anims.zig");

const wizard = @import("wizard.zig");
const Wizard = wizard.Wizard;
const wizard_anims = @import("../game/animations/wizard_anims.zig");

const flying = @import("flying_platform.zig");

pub const Entity = struct {
    pub fn init() !void {
        elf.initElf();
        wizard.init();
        flying.init();
    }

    pub fn draw() void {
        if (Elf.selfReturn().canDraw) Elf.drawElf();
        if (Wizard.SelfReturn().canDraw) Wizard.draw();
    }
};
