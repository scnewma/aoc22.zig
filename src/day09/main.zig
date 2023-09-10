const std = @import("std");
const io = std.io;
const math = std.math;
const mem = std.mem;
const fmt = std.fmt;

const Allocator = std.mem.Allocator;

const PART1_KNOTS = 2;
const PART2_KNOTS = 10;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try io.getStdIn().reader().readAllAlloc(allocator, math.maxInt(usize));

    std.debug.print("Part 01: {}\n", .{try solve(PART1_KNOTS, allocator, input)});
    std.debug.print("Part 02: {}\n", .{try solve(PART2_KNOTS, allocator, input)});
}

fn solve(comptime N: u8, allocator: Allocator, input: []const u8) !usize {
    var visited = std.AutoHashMap(Point, void).init(allocator);
    defer visited.deinit();

    var knots = [_]Point{.{ .x = 0, .y = 0 }} ** N;

    var lines = mem.tokenizeSequence(u8, input, "\n");
    while (lines.next()) |line| {
        // Example lines:
        //  R 2
        //  L 22
        const dir = line[0];
        const n = try fmt.parseInt(usize, line[2..], 10);

        for (0..n) |_| {
            // move head
            switch (dir) {
                'R' => knots[0].x += 1,
                'L' => knots[0].x -= 1,
                'U' => knots[0].y += 1,
                'D' => knots[0].y -= 1,
                else => unreachable,
            }

            // move rest of rope
            for (1..N) |i| {
                var dx = knots[i - 1].x - knots[i].x;
                var dy = knots[i - 1].y - knots[i].y;
                if (try math.absInt(dx) > 1 or try math.absInt(dy) > 1) {
                    knots[i].x += signum(dx);
                    knots[i].y += signum(dy);
                }

                // keep track of tail location
                if (i == N - 1) {
                    try visited.put(knots[i], {});
                }
            }
        }
    }
    return visited.count();
}

const Point = struct {
    x: i32,
    y: i32,
};

fn signum(n: i32) i32 {
    if (n == 0) {
        return 0;
    } else if (n > 0) {
        return 1;
    } else {
        return -1;
    }
}

test "examples" {
    const input =
        \\R 4
        \\U 4
        \\L 3
        \\D 1
        \\R 4
        \\D 1
        \\L 5
        \\R 2
    ;

    const ans1 = try solve(PART1_KNOTS, std.testing.allocator, input);
    try std.testing.expectEqual(@as(usize, 13), ans1);

    const ans2 = try solve(PART2_KNOTS, std.testing.allocator, input);
    try std.testing.expectEqual(@as(usize, 1), ans2);
}
