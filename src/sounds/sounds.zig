const rl = @import("raylib");
const std = @import("std");
const btns = @import("../ui/buttons_panel.zig");
pub var soundControl = SoundDisplay{};
pub var soundsets = SoundSet{};

pub fn run() void {
    var ctn = btns.btns_panel;

    if (ctn.settings.isClicked()) soundControl.play(soundsets.basic_btn_sound);
}

pub fn init() !void {
    if (!rl.isAudioDeviceReady()) {
        rl.initAudioDevice();
    }

    try SoundSet.init();
}

pub fn deinit() void {
    soundsets.deinit();
    rl.closeAudioDevice();
}

pub const SoundSet = struct {
    basic_btn_sound: rl.Sound = undefined,
    theme_music: rl.Sound = undefined,

    fn init() !void {
        soundsets.basic_btn_sound = try rl.loadSound("sounds/basic_btn.mp3");
        soundsets.theme_music = try rl.loadSound("sounds/theme_music.mp3");
    }

    pub fn deinit(self: *SoundSet) void {
        rl.unloadSound(self.basic_btn_sound);
    }
};

const SoundDisplay = struct {
    canPlayAllSound: bool = true,

    pub fn play(self: *const SoundDisplay, sound: rl.Sound) void {
        if (self.canPlayAllSound) {
            rl.playSound(sound);
        }
    }

    pub fn stopMusic(self: *const SoundDisplay, sound: rl.Sound) void {
        if (!self.canPlayAllSound) {
            rl.stopSound(sound);
        }
    }

    pub fn muteAll(self: *SoundDisplay) void {
        self.canPlayAllSound = false;
    }

    pub fn unmuteAll(self: *SoundDisplay) void {
        self.canPlayAllSound = true;
    }
};
