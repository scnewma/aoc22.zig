const std = @import("std");
const math = std.math;

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const debug = std.debug.print;

// const Stack = ArrayList(u8);
// const Stacks = ArrayList(Stack);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const input = try std.io.getStdIn().readToEndAlloc(alloc, math.maxInt(usize));
    defer alloc.free(input);

    var sections = std.mem.splitSequence(u8, input, "\n\n");
    const initialLayout = sections.next().?;
    var p1Stacks = try Stacks.parse(alloc, initialLayout);
    defer p1Stacks.deinit();
    var p2Stacks = try Stacks.parse(alloc, initialLayout);
    defer p2Stacks.deinit();

    var moves = std.mem.splitSequence(u8, sections.next().?, "\n");
    while (moves.next()) |instr| {
        if (instr.len == 0) {
            continue;
        }

        const move = try Move.parse(instr);

        try p1Stacks.perform(move, Model.CM9000);
        try p2Stacks.perform(move, Model.CM9001);
    }

    const stdout = std.io.getStdOut().writer();
    const solution1 = try p1Stacks.solution();
    defer alloc.free(solution1);
    const solution2 = try p2Stacks.solution();
    defer alloc.free(solution2);
    try stdout.print("Part 01: {s}\n", .{solution1});
    try stdout.print("Part 02: {s}\n", .{solution2});
}

const Model = enum { CM9000, CM9001 };

const Stacks = struct {
    stacks: []ArrayList(u8),
    allocator: Allocator,

    pub fn parse(allocator: Allocator, s: []const u8) !Stacks {
        var lines = std.mem.splitBackwardsSequence(u8, s, "\n");
        const idLine = lines.next().?;
        const nStacks = (idLine.len + 1) / 4;

        var stacks = try allocator.alloc(ArrayList(u8), nStacks);
        errdefer allocator.free(stacks);
        for (0..nStacks) |i| {
            const stk = ArrayList(u8).init(allocator);
            errdefer stk.deinit();
            stacks[i] = stk;
        }

        while (lines.next()) |line| {
            var stkIdx: usize = 0;
            var i: usize = 1;
            while (i < line.len) : ({
                i += 4;
                stkIdx += 1;
            }) {
                if (line[i] != ' ') {
                    try stacks[stkIdx].append(line[i]);
                }
            }
        }

        return Stacks{ .stacks = stacks, .allocator = allocator };
    }

    pub fn perform(self: *Stacks, move: Move, model: Model) !void {
        switch (model) {
            Model.CM9000 => {
                for (0..move.nCrates) |_| {
                    const crate = self.stacks[move.fromStk - 1].pop();
                    try self.stacks[move.toStk - 1].append(crate);
                }
            },
            Model.CM9001 => {
                const fromStk = &self.stacks[move.fromStk - 1];
                const toStk = &self.stacks[move.toStk - 1];
                const i = fromStk.items.len - move.nCrates;
                try toStk.appendSlice(fromStk.items[i..]);
                fromStk.shrinkRetainingCapacity(i);
            },
        }
    }

    pub fn solution(self: Stacks) ![]u8 {
        var buf = try self.allocator.alloc(u8, self.stacks.len);
        errdefer self.allocator.free(buf);

        for (self.stacks, 0..) |stack, i| {
            buf[i] = stack.getLast();
        }
        return buf;
    }

    pub fn deinit(self: *Stacks) void {
        for (self.stacks) |*stack| {
            stack.deinit();
        }
        self.allocator.free(self.stacks);
    }
};

const Move = struct {
    nCrates: usize,
    fromStk: usize,
    toStk: usize,

    pub fn parse(s: []const u8) !Move {
        var words = std.mem.splitSequence(u8, s, " ");
        _ = words.next().?; // skip "move"
        const nCrates = try std.fmt.parseInt(usize, words.next().?, 10);
        _ = words.next().?; // skip "from"
        const fromStk = try std.fmt.parseInt(usize, words.next().?, 10);
        _ = words.next().?; // skip "to"
        const toStk = try std.fmt.parseInt(usize, words.next().?, 10);

        return Move{ .nCrates = nCrates, .fromStk = fromStk, .toStk = toStk };
    }
};
