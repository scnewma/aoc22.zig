const std = @import("std");

const AlphaBitSet = std.bit_set.IntegerBitSet(52);
const Compartment = struct {
    pub fn init(inv: []u8) AlphaBitSet {
        var bitset = AlphaBitSet.initEmpty();
        for (inv) |snack| {
            bitset.set(snackIndex(snack));
        }
        return bitset;
    }

    pub fn initFull() AlphaBitSet {
        return AlphaBitSet.initFull();
    }

    fn snackIndex(snack: u8) u8 {
        if (snack - 'A' < 26) {
            return snack - 'A' + 26;
        } else {
            return snack - 'a';
        }
    }
};

pub fn main() !void {
    const stdin = std.io.getStdIn();
    var bufr = std.io.bufferedReader(stdin.reader());
    var reader = bufr.reader();

    var part01: usize = 0;
    var part02: usize = 0;
    var group = Compartment.initFull();

    var n: usize = 1;
    var buf: [64]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| : (n += 1) {
        // part 1
        const mid = line.len / 2;
        var left = Compartment.init(line[0..mid]);
        var right = Compartment.init(line[mid..]);
        const intersect = left.intersectWith(right);
        // +1 because the priorities are 1 indexed
        part01 += intersect.findFirstSet().? + 1;

        // part 2
        group.setIntersection(Compartment.init(line));
        if (n % 3 == 0) {
            // +1 because the priorities are 1 indexed
            part02 += group.findFirstSet().? + 1;
            group = Compartment.initFull();
        }
    }

    const stdout = std.io.getStdOut();
    try stdout.writer().print("Part 01: {}\n", .{part01});
    try stdout.writer().print("Part 02: {}\n", .{part02});
}
