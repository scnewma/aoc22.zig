const std = @import("std");

// n could theoretically be anything, but TopN doesn't actually implement the
// heap algorithm so you will want to keep the number of elements low
pub fn TopN(comptime T: type, comptime N: u8) type {
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

pub const RangeDirection = enum { forward, reverse };

pub const RangeIterator = struct {
    start: usize,
    end: usize, // exclusive
    direction: RangeDirection = .forward,

    pub fn next(self: *RangeIterator) ?usize {
        return switch (self.direction) {
            .forward => self.step_next(),
            .reverse => self.step_next_back(),
        };
    }

    pub fn next_back(self: *RangeIterator) ?usize {
        return switch (self.direction) {
            .forward => self.step_next_back(),
            .reverse => self.step_next(),
        };
    }

    fn step_next(self: *RangeIterator) ?usize {
        if (self.start >= self.end) {
            return null;
        }
        const n = self.start;
        self.start += 1;
        return n;
    }

    fn step_next_back(self: *RangeIterator) ?usize {
        if (self.start >= self.end) {
            return null;
        }
        self.end -= 1;
        return self.end;
    }

    pub fn clone(self: RangeIterator) RangeIterator {
        return .{ .start = self.start, .end = self.end, .direction = self.direction };
    }
};
