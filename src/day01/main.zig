const std = @import("std");
const lib = @import("aoclib");

pub fn main() !void {
    var stdin = std.io.getStdIn();
    var stdout = std.io.getStdOut();
    var bufr = std.io.bufferedReader(stdin.reader());
    var reader = bufr.reader();

    var elf_calories: u32 = 0;
    var top3 = lib.TopN(u32, 3).new();

    var buffer: [8]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        if (line.len == 0) {
            top3.insert(elf_calories);
            elf_calories = 0;
            continue;
        }
        var calories = try std.fmt.parseInt(u32, line, 10);
        elf_calories += calories;
    }
    // ensure we count the last elf
    top3.insert(elf_calories);

    try stdout.writer().print("Part 01: {}\n", .{top3.max()});
    try stdout.writer().print("Part 02: {}\n", .{top3.sum()});
}
