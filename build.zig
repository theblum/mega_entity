const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe_options = b.addOptions();
    exe_options.addOption([:0]const u8, "programName", if (mode == .Debug) "mega_entity_debug" else "mega_entity");

    const zlm = std.build.Pkg{ .name = "zlm", .path = std.build.FileSource.relative("vendor/zlm/zlm.zig") };
    const engine = std.build.Pkg{
        .name = "engine",
        .path = std.build.FileSource.relative("lib/engine/src/engine.zig"),
        .dependencies = &.{zlm},
    };

    const exe = b.addExecutable("mega_entity", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.addOptions("build_options", exe_options);
    exe.addPackage(zlm);
    exe.addPackage(engine);
    exe.linkSystemLibrary("csfml-graphics");
    exe.linkSystemLibrary("csfml-window");
    exe.linkSystemLibrary("csfml-system");
    exe.linkLibC();
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
