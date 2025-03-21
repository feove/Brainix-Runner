const std = @import("std");
const rlz = @import("raylib_zig");

fn addAssets(b: *std.Build, exe: *std.Build.Step.Compile) void {
    const assets = [_]struct { []const u8, []const u8 }{};

    for (assets) |asset| {
        const path, const name = asset;
        exe.root_module.addAnonymousImport(name, .{ .root_source_file = b.path(path) });
    }
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
        .linux_display_backend = .X11,
    });
    
    const raylib = raylib_dep.module("raylib");
    // const raygui = raylib_dep.module("raygui");
    const raylib_artifact = raylib_dep.artifact("raylib");

    const exe = b.addExecutable(.{
        .name = "Brainix_Runner",
        .root_module = exe_mod,
    });

    addAssets(b, exe);

    exe.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);
    // exe.root_module.addImport("raygui", raygui);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
