const std = @import("std");

pub fn main() !void {
    var stdin = std.io.getStdIn();
    var stdout = std.io.getStdOut();
    var reader = stdin.reader();

    var elf_calories: u32 = 0;
    var top3 = [3]u32{ 0, 0, 0 };

    while (true) {
        var buffer: [8]u8 = undefined;
        const line = try reader.readUntilDelimiterOrEof(&buffer, '\n');
        if (line) |ln| {
            if (ln.len == 0) {
                insTop3(&top3, elf_calories);
                elf_calories = 0;
                continue;
            }
            var calories = try std.fmt.parseInt(u32, ln, 10);
            elf_calories += calories;
        } else {
            // ensure we count the last elf
            insTop3(&top3, elf_calories);
            break;
        }
    }

    try stdout.writer().print("Part 01: {}\n", .{top3[2]});

    var top3Sum: u32 = 0;
    for (top3) |n| {
        top3Sum += n;
    }
    try stdout.writer().print("Part 02: {}\n", .{top3Sum});
}

fn insTop3(top3: *[3]u32, num: u32) void {
    var n = num;
    for (0..3) |idx| {
        const i = 2 - idx;
        const min = @min(top3[i], n);
        top3[i] = @max(top3[i], n);
        n = min;
    }
}
