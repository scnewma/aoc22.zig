const std = @import("std");

pub fn main() !void {
    var stdin = std.io.getStdIn();
    var stdout = std.io.getStdOut();
    var reader = stdin.reader();

    var elf_calories: u32 = 0;
    var top3 = TopN(u32, 3).new();

    while (true) {
        var buffer: [8]u8 = undefined;
        const line = try reader.readUntilDelimiterOrEof(&buffer, '\n');
        if (line) |ln| {
            if (ln.len == 0) {
                top3.insert(elf_calories);
                elf_calories = 0;
                continue;
            }
            var calories = try std.fmt.parseInt(u32, ln, 10);
            elf_calories += calories;
        } else {
            // ensure we count the last elf
            top3.insert(elf_calories);
            break;
        }
    }

    try stdout.writer().print("Part 01: {}\n", .{top3.max()});
    try stdout.writer().print("Part 02: {}\n", .{top3.sum()});
}

// n could theoretically be anything, but TopN doesn't actually implement the
// heap algorithm so you will want to keep the number of elements low
fn TopN(comptime T: type, comptime N: u8) type {
    return struct {
        elems: [N]T,

        const Self = @This();

        pub fn new() Self {
            return Self{
                .elems = std.mem.zeroes([N]T),
            };
        }

        pub fn insert(self: *Self, elem: T) void {
            var e = elem;
            for (0..N) |idx| {
                const i = 2 - idx;
                const min = @min(self.elems[i], e);
                self.elems[i] = @max(self.elems[i], e);
                e = min;
            }
        }

        pub fn max(self: *Self) T {
            return self.elems[N - 1];
        }

        pub fn sum(self: *Self) T {
            var s: u32 = 0;
            for (self.elems) |e| {
                s += e;
            }
            return s;
        }
    };
}
