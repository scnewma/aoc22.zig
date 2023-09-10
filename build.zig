const std = @import("std");

const DAY_SOLVED = 9;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const lib_module = b.createModule(.{
        .source_file = .{ .path = "src/lib.zig" },
    });

    const test_step = b.step("test", "Run all tests.");

    var day_counter: usize = 1;
    while (day_counter <= DAY_SOLVED) : (day_counter += 1) {
        const name = b.fmt("day{:0>2}", .{day_counter});
        const exe = b.addExecutable(.{
            .name = name,
            .root_source_file = .{ .path = b.fmt("src/{s}/main.zig", .{name}) },
            .target = target,
            .optimize = optimize,
        });
        exe.addModule("aoclib", lib_module);

        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());

        const run_step = b.step(b.fmt("run_{s}", .{name}), b.fmt("Run {s}", .{name}));
        run_step.dependOn(&run_cmd.step);

        const unit_tests = b.addTest(.{
            .root_source_file = .{ .path = b.fmt("src/{s}/main.zig", .{name}) },
            .target = target,
            .optimize = optimize,
        });
        unit_tests.addModule("aoclib", lib_module);
        const run_unit_tests = b.addRunArtifact(unit_tests);

        const day_test_step = b.step(b.fmt("test_{s}", .{name}), b.fmt("Test {s}", .{name}));
        day_test_step.dependOn(&run_unit_tests.step);
        test_step.dependOn(&run_unit_tests.step);
    }
}
