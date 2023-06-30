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
