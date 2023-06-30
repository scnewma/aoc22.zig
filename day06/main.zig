const std = @import("std");
const io = std.io;
const assert = std.debug.assert;

pub fn main() !void {
    const stdin = io.getStdIn();
    const stdout = io.getStdOut().writer();
    var buf: [4096]u8 = undefined;
    const n = try stdin.read(&buf);
    try stdout.print("Part 01: {}\n", .{findNonRepeating(buf[0..n], 4)});
    try stdout.print("Part 02: {}\n", .{findNonRepeating(buf[0..n], 14)});
}

fn findNonRepeating(input: []const u8, n_distinct: usize) usize {
    var counts = [_]u8{0} ** 26;
    for (0..input.len) |i| {
        if (i > (n_distinct - 1)) {
            counts[input[i - n_distinct] - 'a'] -= 1;
        }
        counts[input[i] - 'a'] += 1;

        if (countUnique(counts) == n_distinct) {
            return i + 1;
        }
    }

    return input.len + 1;
}

fn countUnique(counts: [26]u8) usize {
    var n: usize = 0;
    for (0..26) |i| {
        if (counts[i] > 0) {
            n += 1;
        }
    }
    return n;
}

test "examples" {
    testBoth("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 7, 19);
    testBoth("bvwbjplbgvbhsrlpgdmjqwftvncz", 5, 23);
    testBoth("nppdvjthqldpwncqszvftbrmjlhg", 6, 23);
    testBoth("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 10, 29);
    testBoth("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 11, 26);
}

fn testBoth(input: []const u8, sop: usize, som: usize) void {
    assert(findNonRepeating(input, 4) == sop);
    assert(findNonRepeating(input, 14) == som);
}
