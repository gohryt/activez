const std = @import("std");
const Build = std.Build;
const Step = Build.Step;

const Options = struct {
    target: Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
};

pub fn build(b: *Build) !void {
    var options: Options = .{
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    };

    const asphyxiaz_module: *Build.Module = b.dependency("asphyxiaz", options).module("asphyxiaz");

    const activez_module: *Build.Module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .imports = &.{
            .{ .name = "asphyxiaz", .module = asphyxiaz_module },
        },
        .target = options.target,
        .optimize = options.optimize,
    });

    // activez tests
    const activez_tests: *Step.Compile = b.addTest(.{ .root_module = activez_module });

    const activez_tests_cmd: *Step.Run = b.addRunArtifact(activez_tests);

    const test_step: *Step = b.step("test", "Run unit tests");
    test_step.dependOn(&activez_tests_cmd.step);

    try addExample(b, &options, activez_module, 1, "benchmark");
    try addExample(b, &options, activez_module, 2, "cat");
    try addExample(b, &options, activez_module, 3, "tcp-echo");
}

fn addExample(b: *Build, options: *Options, activez_module: *Build.Module, number: usize, name: []const u8) !void {
    const root_source_file: []u8 = try std.fmt.allocPrint(b.allocator, "examples/00{}-{s}.zig", .{ number, name });

    const example: *Step.Compile = b.addExecutable(.{
        .name = name,
        .root_source_file = b.path(root_source_file),
        .target = options.target,
        .optimize = options.optimize,
    });

    example.root_module.addImport("activez", activez_module);

    b.installArtifact(example);

    const example_cmd: *Step.Run = b.addRunArtifact(example);

    example_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        example_cmd.addArgs(args);
    }

    const example_step: *Step = b.step(name, "Run the example");
    example_step.dependOn(&example_cmd.step);
}
