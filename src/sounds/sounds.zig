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
}

pub fn init() !void {
    rl.initAudioDevice();

    if (!rl.isAudioDeviceReady()) {
        return error.AudioDeviceNotReady;
    }

    try SoundSet.init();
}

pub fn deinit() void {
    soundsets.deinit();
    rl.closeAudioDevice();
}

pub const SoundSet = struct {
    basic_btn: rl.Sound = undefined,
    back_btn: rl.Sound = undefined,
    arrow: rl.Sound = undefined,
    theme_music: rl.Sound = undefined,
    play_btn: rl.Sound = undefined,
    boom: rl.Sound = undefined,
    woosh_1: rl.Sound = undefined,
    martial_arts: rl.Sound = undefined,

    fn init() !void {
        soundsets.basic_btn = try rl.loadSound("sounds/basic_btn.mp3");
        soundsets.back_btn = try rl.loadSound("sounds/back_btn.mp3");
        soundsets.arrow = try rl.loadSound("sounds/arrow_button.mp3");
        soundsets.theme_music = try rl.loadSound("sounds/theme_music.mp3");
        soundsets.boom = try rl.loadSound("sounds/boom.mp3");
        soundsets.play_btn = try rl.loadSound("sounds/play_btn_sound.mp3");
        soundsets.woosh_1 = try rl.loadSound("sounds/woosh_1_sound.mp3");
        soundsets.martial_arts = try rl.loadSound("sounds/martial_arts.wav");
    }

    pub fn deinit(self: *SoundSet) void {
        rl.unloadSound(self.basic_btn);
        rl.unloadSound(self.back_btn);
        rl.unloadSound(self.arrow);
        rl.unloadSound(self.theme_music);
        rl.unloadSound(self.play_btn);
        rl.unloadSound(self.boom);
        rl.unloadSound(self.woosh_1);
        rl.unloadSound(self.martial_arts);
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
}

pub const SoundType = enum {
    BASIC,
    BACK,
    ARROW,
    THEME,
    PLAY,
    BOOM,
    WOOSH_1,
    MARTIAL_ARTS,
};

pub const SoundDisplay = struct {
    canPlayAllSound: bool = true,

    pub fn makeSound(soundtype: SoundType) void {
        const sound: rl.Sound = switch (soundtype) {
            .BASIC => soundsets.basic_btn,
            .BACK => soundsets.back_btn,
            .ARROW => soundsets.arrow,
            .THEME => soundsets.theme_music,
            .PLAY => soundsets.play_btn,
            .BOOM => soundsets.boom,
            .WOOSH_1 => soundsets.woosh_1,
            .MARTIAL_ARTS => soundsets.martial_arts,
        };
        rl.playSound(sound);
    }

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
