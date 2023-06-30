const std = @import("std");
const lib = @import("aoclib");
const io = std.io;
const math = std.math;
const mem = std.mem;
const fmt = std.fmt;
const ArrayList = std.ArrayList;

const Tree = struct {
    height: usize,
    visible: bool,
};

const Grove = ArrayList(ArrayList(Tree));

fn range(comptime direction: lib.RangeDirection, start: usize, end: usize) lib.RangeIterator {
    if (start > end) {
        @panic("invalid range");
    }
    return .{ .start = start, .end = end, .direction = direction };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try io.getStdIn().reader().readAllAlloc(allocator, math.maxInt(usize));
    var grove = try parse_grove(allocator, input);
    defer free_grove(grove);

    std.debug.print("Part 01: {}\n", .{try part01(grove)});
    std.debug.print("Part 02: {}\n", .{try part02(grove)});
}

fn parse_grove(allocator: std.mem.Allocator, input: []const u8) !Grove {
    var grove = Grove.init(allocator);

    var lines = mem.tokenizeSequence(u8, input, "\n");
    while (lines.next()) |line| {
        var row = ArrayList(Tree).init(allocator);
        for (line) |ch| {
            try row.append(Tree{ .height = ch - '0', .visible = false });
        }
        try grove.append(row);
    }

    return grove;
}

fn free_grove(grove: Grove) void {
    for (grove.items) |row| {
        row.deinit();
    }
    grove.deinit();
}

fn part01(grove: Grove) !usize {
    const grove_h = grove.items.len;
    const grove_w = grove.items[0].items.len;

    const deltas = [_][2]isize{ .{ -1, 0 }, .{ 0, -1 }, .{ 1, 0 }, .{ 0, 1 } };
    for (deltas) |delta| {
        const dr = delta[0];
        const dc = delta[1];
        var memo = try clone_grove(grove);
        defer free_grove(memo);

        var row_range = range(.forward, 0, grove_h);
        var col_range = range(.forward, 0, grove_w);
        if (dr == 1 or dc == 1) {
            row_range.direction = .reverse;
            col_range.direction = .reverse;
        }

        while (row_range.next()) |r| {
            var c_range = col_range.clone();
            while (c_range.next()) |c| {
                const tree = grove.items[r].items[c];
                // visible if:
                // * already known visible
                // * on the edge
                // * all trees in this line to edge are shorter
                grove.items[r].items[c].visible = tree.visible or
                    r == 0 or r == grove_h - 1 or
                    c == 0 or c == grove_w - 1 or
                    memo.items[add(r, dr)].items[c].height < tree.height or
                    memo.items[r].items[add(c, dc)].height < tree.height;

                var max_h = tree.height;
                if (r > 0 and r < grove_h - 1) {
                    max_h = @max(max_h, memo.items[add(r, dr)].items[c].height);
                }
                if (c > 0 and c < grove_w - 1) {
                    max_h = @max(max_h, memo.items[r].items[add(c, dc)].height);
                }
                memo.items[r].items[c].height = max_h;
            }
        }
    }

    var n_visible: usize = 0;
    for (grove.items) |row| {
        for (row.items) |col| {
            if (col.visible) {
                n_visible += 1;
            }
        }
    }
    return n_visible;
}

fn part02(grove: Grove) !usize {
    const grove_h = grove.items.len;
    const grove_w = grove.items[0].items.len;

    var row_range = range(.forward, 0, grove_h);
    var col_range = range(.forward, 0, grove_w);

    var max_scenic_score: usize = 0;
    while (row_range.next()) |r| {
        var c_range = col_range.clone();
        while (c_range.next()) |c| {
            const left = calcScenicScore(grove, r, c, @constCast(&range(.reverse, 0, c)), .col);
            const right = calcScenicScore(grove, r, c, @constCast(&range(.forward, c + 1, grove_w)), .col);
            const top = calcScenicScore(grove, r, c, @constCast(&range(.reverse, 0, r)), .row);
            const bottom = calcScenicScore(grove, r, c, @constCast(&range(.forward, r + 1, grove_h)), .row);

            const score = left * right * top * bottom;
            max_scenic_score = @max(max_scenic_score, score);
        }
    }

    return max_scenic_score;
}

const RowOrCol = enum { row, col };

fn calcScenicScore(grove: Grove, r: usize, c: usize, check_range: *lib.RangeIterator, comptime range_type: RowOrCol) usize {
    const tree = grove.items[r].items[c];
    var trees_visible: usize = 0;
    while (check_range.next()) |x| {
        trees_visible += 1;

        var row = if (range_type == .row) x else r;
        var col = if (range_type == .col) x else c;
        if (tree.height <= grove.items[row].items[col].height) {
            break;
        }
    }
    return trees_visible;
}

fn add(x: usize, dx: isize) usize {
    if (dx < 0) {
        // Assumption: abs(dx) <= x
        return x - math.absCast(dx);
    }
    return x + math.absCast(dx);
}

test "add" {
    try std.testing.expectEqual(add(1, 1), 2);
    try std.testing.expectEqual(add(1, -1), 0);
}

fn print_grove(grove: Grove, w_visibility: bool) void {
    for (grove.items) |row| {
        for (row.items) |col| {
            std.debug.print("{}", .{col.height});
        }
        if (w_visibility) {
            std.debug.print("  ", .{});
            for (row.items) |col| {
                const ch = if (col.visible) "X" else ".";
                std.debug.print("{s}", .{ch});
            }
        }
        std.debug.print("\n", .{});
    }
}

fn clone_grove(grove: Grove) !Grove {
    var n = Grove.init(grove.allocator);
    for (grove.items) |row| {
        try n.append(try row.clone());
    }
    return n;
}

test "example" {
    const input =
        \\30373
        \\25512
        \\65332
        \\33549
        \\35390
    ;
    var grove = try parse_grove(std.testing.allocator, input);
    defer free_grove(grove);

    try std.testing.expectEqual(try part01(grove), 21);
    try std.testing.expectEqual(try part02(grove), 8);
}
