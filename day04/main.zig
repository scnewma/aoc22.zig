const std = @import("std");

const Range = struct {
    start: usize,
    end: usize,

    pub fn fromStr(s: []const u8) !Range {
        const parseInt = std.fmt.parseInt;

        var it = std.mem.splitSequence(u8, s, "-");
        return Range{
            .start = try parseInt(usize, it.next().?, 10),
            .end = try parseInt(usize, it.next().?, 10),
        };
    }

    pub fn overlaps(self: Range, o: Range) bool {
        var low: Range = o;
        var high: Range = self;
        if (self.start < o.start) {
            low = self;
            high = o;
        }

        return low.end >= high.start;
    }

    pub fn fullOverlap(self: Range, o: Range) bool {
        return (self.start <= o.start and self.end >= o.end) or
            (o.start <= self.start and o.end >= self.end);
    }
};

pub fn main() !void {
    const stdin = std.io.getStdIn();
    var bufr = std.io.bufferedReader(stdin.reader());
    var reader = bufr.reader();

    var nFullOverlap: u32 = 0;
    var nOverlap: u32 = 0;

    var buf: [32]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var ranges = std.mem.splitSequence(u8, line, ",");
        var first = try Range.fromStr(ranges.next().?);
        var second = try Range.fromStr(ranges.next().?);

        if (first.fullOverlap(second)) {
            nFullOverlap += 1;
        }
        if (first.overlaps(second)) {
            nOverlap += 1;
        }
    }

    try std.io.getStdOut().writer().print("Part 01: {}\n", .{nFullOverlap});
    try std.io.getStdOut().writer().print("Part 02: {}\n", .{nOverlap});
}
