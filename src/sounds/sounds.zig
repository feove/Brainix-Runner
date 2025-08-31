const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;
const btns = @import("../ui/buttons_panel.zig");
pub var soundControl = SoundDisplay{};
pub var soundsets = SoundSet{};
pub var canPlayMusic: bool = true;

pub const VOLUME_MAX: f32 = 5.0;
pub const VOLUME_MIN: f32 = 0.0;
pub var currentVolume: f32 = 0.0;

pub fn run() void {
    if (canPlayMusic) {
        soundControl.playMusic(soundsets.theme_music);
        //soundControl.play(soundsets.theme_music);
        // canPlayMusic = false;
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
    theme_music: rl.Music = undefined,
    basic_btn: rl.Sound = undefined,
    back_btn: rl.Sound = undefined,
    arrow: rl.Sound = undefined,
    play_btn: rl.Sound = undefined,
    boom: rl.Sound = undefined,
    woosh_1: rl.Sound = undefined,
    martial_arts: rl.Sound = undefined,
    jump: rl.Sound = undefined,
    completion: rl.Sound = undefined,
    spell: rl.Sound = undefined,
    door: rl.Sound = undefined,
    take_item: rl.Sound = undefined,
    attacking_1: rl.Sound = undefined,
    death: rl.Sound = undefined,

    fn init() !void {
        soundsets.theme_music = try rl.loadMusicStream("sounds/theme_music.mp3");

        soundsets.basic_btn = try rl.loadSound("sounds/basic_btn.mp3");
        soundsets.back_btn = try rl.loadSound("sounds/back_btn.mp3");
        soundsets.arrow = try rl.loadSound("sounds/arrow_button.mp3");
        soundsets.boom = try rl.loadSound("sounds/boom.mp3");
        soundsets.play_btn = try rl.loadSound("sounds/play_btn_sound.mp3");
        soundsets.woosh_1 = try rl.loadSound("sounds/woosh_1_sound.mp3");
        soundsets.martial_arts = try rl.loadSound("sounds/martial_arts.wav");
        soundsets.jump = try rl.loadSound("sounds/jump.wav");
        soundsets.completion = try rl.loadSound("sounds/complete.mp3");
        soundsets.spell = try rl.loadSound("sounds/spell.wav");
        soundsets.door = try rl.loadSound("sounds/door.wav");
        soundsets.take_item = try rl.loadSound("sounds/take_item.mp3");
        soundsets.attacking_1 = try rl.loadSound("sounds/attacking_1.mp3");
        soundsets.death = try rl.loadSound("sounds/death.mp3");
    }

    pub fn deinit(self: *SoundSet) void {
        rl.unloadMusicStream(self.theme_music);

        rl.unloadSound(self.basic_btn);
        rl.unloadSound(self.back_btn);
        rl.unloadSound(self.arrow);
        rl.unloadSound(self.play_btn);
        rl.unloadSound(self.boom);
        rl.unloadSound(self.woosh_1);
        rl.unloadSound(self.martial_arts);
        rl.unloadSound(self.jump);
        rl.unloadSound(self.completion);
        rl.unloadSound(self.spell);
        rl.unloadSound(self.door);
        rl.unloadSound(self.take_item);
        rl.unloadSound(self.attacking_1);
        rl.unloadSound(self.death);
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
    //   THEME,
    PLAY,
    BOOM,
    WOOSH_1,
    MARTIAL_ARTS,
    JUMP,
    COMPLETION,
    SPELL,
    DOOR,
    TAKE_ITEM,
    ATTACKING_1,
    DEATH,
};

pub const SoundDisplay = struct {
    canPlayAllSound: bool = true,

    pub fn makeSound(soundtype: SoundType) void {
        if (soundControl.canPlayAllSound == false) return;

        const sound: rl.Sound = switch (soundtype) {
            .BASIC => soundsets.basic_btn,
            .BACK => soundsets.back_btn,
            .ARROW => soundsets.arrow,
            // .THEME => soundsets.theme_music,
            .PLAY => soundsets.play_btn,
            .BOOM => soundsets.boom,
            .WOOSH_1 => soundsets.woosh_1,
            .MARTIAL_ARTS => soundsets.martial_arts,
            .JUMP => soundsets.jump,
            .COMPLETION => soundsets.completion,
            .SPELL => soundsets.spell,
            .DOOR => soundsets.door,
            .TAKE_ITEM => soundsets.take_item,
            .ATTACKING_1 => soundsets.attacking_1,
            .DEATH => soundsets.death,
        };
        rl.playSound(sound);
    }

    pub fn play(sound: rl.Sound) void {
        rl.playSound(sound);
    }

    pub fn stopMusic(sound: rl.Sound) void {
        if (!soundControl.canPlayAllSound) {
            rl.stopSound(sound);
        }
    }

    pub fn playMusic(self: *const SoundDisplay, music: rl.Music) void {
        if (self.canPlayAllSound) {
            if (rl.isMusicValid(music)) {
                rl.playMusicStream(music);
            } else {
                print("Music is not valid\n", .{});
            }
        }
    }

    pub fn muteAll() void {
        soundControl.canPlayAllSound = false;
    }

    pub fn unmuteAll() void {
        soundControl.canPlayAllSound = true;
    }
};
