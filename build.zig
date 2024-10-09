const std = @import("std");
const Build = std.Build;
const Step = Build.Step;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const activez_module: *Build.Module = b.addModule("activez", .{
        .root_source_file = b.path("src/root.zig"),
    });

    // activez tests
    const activez_tests: *Step.Compile = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const activez_tests_cmd: *Step.Run = b.addRunArtifact(activez_tests);

    const test_step: *Step = b.step("test", "Run unit tests");
    test_step.dependOn(&activez_tests_cmd.step);

    // cat example
    const cat: *Step.Compile = b.addExecutable(.{
        .name = "cat",
        .root_source_file = b.path("examples/001-cat.zig"),
        .target = target,
        .optimize = optimize,
    });

    cat.root_module.addImport("activez", activez_module);

    b.installArtifact(cat);

    const cat_cmd: *Step.Run = b.addRunArtifact(cat);

    cat_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        cat_cmd.addArgs(args);
    }

    const cat_step = b.step("cat", "Run the cat example");
    cat_step.dependOn(&cat_cmd.step);
}
