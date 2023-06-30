const std = @import("std");

const DAY_SOLVED = 8;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    var day_counter: usize = 1;
    while (day_counter <= DAY_SOLVED) : (day_counter += 1) {
        const name = b.fmt("day{:0>2}", .{day_counter});
        const exe = b.addExecutable(.{
            .name = name,
            .root_source_file = .{ .path = b.fmt("{s}/main.zig", .{name}) },
            .target = target,
            .optimize = optimize,
        });

        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());

        const run_step = b.step(b.fmt("run_{s}", .{name}), b.fmt("Run {s}", .{name}));
        run_step.dependOn(&run_cmd.step);

        const unit_tests = b.addTest(.{
            .root_source_file = .{ .path = b.fmt("{s}/main.zig", .{name}) },
            .target = target,
            .optimize = optimize,
        });
        const run_unit_tests = b.addRunArtifact(unit_tests);

        const test_step = b.step(b.fmt("test_{s}", .{name}), b.fmt("Test {s}", .{name}));
        test_step.dependOn(&run_unit_tests.step);
    }
}
