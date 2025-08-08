const rl = @import("raylib");
const std = @import("std");
const btns = @import("../ui/buttons_panel.zig");
pub var soundControl = SoundDisplay{};
pub var soundsets = SoundSet{};
pub var canPlayMusic: bool = true;

pub const VOLUME_MAX: f32 = 5.0;
pub const VOLUME_MIN: f32 = 0.0;
pub var currentVolume: f32 = 0.0;

pub fn run() void {
    if (canPlayMusic) {
        soundControl.play(soundsets.theme_music);
        canPlayMusic = false;
    }

    var ctn = btns.btns_panel;

    const basic_btn: bool = ctn.settings.isClicked() or
        ctn.res.isClicked() or
        ctn.option.isClicked() or
        ctn.mute.isClicked() or
        ctn.unmute.isClicked();

    const back_btn: bool = ctn.back.isClicked() or
        ctn.menu.isClicked() or
        ctn.back_option.isClicked();

    if (basic_btn) soundControl.play(soundsets.basic_btn_sound);
    if (back_btn) soundControl.play(soundsets.back_btn_sound);
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
    back_btn_sound: rl.Sound = undefined,
    theme_music: rl.Sound = undefined,

    fn init() !void {
        soundsets.basic_btn_sound = try rl.loadSound("sounds/basic_btn.mp3");
        soundsets.back_btn_sound = try rl.loadSound("sounds/back_btn.mp3");
        soundsets.theme_music = try rl.loadSound("sounds/theme_music.mp3");
    }

    pub fn deinit(self: *SoundSet) void {
        rl.unloadSound(self.basic_btn_sound);
        rl.unloadSound(self.back_btn_sound);
        rl.unloadSound(self.theme_music);
    }
};

pub fn decreaseVolume() void {
    if (rl.isAudioDeviceReady()) {
        rl.setMasterVolume(rl.getMasterVolume() - 0.25);
    }
    if (currentVolume < VOLUME_MAX) {
        currentVolume += 1;
    }
}

pub fn increaseVolume() void {
    if (rl.isAudioDeviceReady()) {
        rl.setMasterVolume(rl.getMasterVolume() + 0.25);
    }
    if (currentVolume > VOLUME_MIN) {
        currentVolume -= 1;
    }

    soundControl.play(soundsets.basic_btn_sound);
}

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

    pub fn playMusic(self: *const SoundDisplay, music: rl.Music) void {
        if (self.canPlayAllSound) {
            rl.playMusicStream(music);
        }
    }

    pub fn muteAll(self: *SoundDisplay) void {
        self.canPlayAllSound = false;
    }

    pub fn unmuteAll(self: *SoundDisplay) void {
        self.canPlayAllSound = true;
    }
};
