const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try std.io.getStdIn().reader().readAllAlloc(allocator, std.math.maxInt(usize));
    var lines = std.mem.tokenizeSequence(u8, input, "\n");

    var crt = Crt.new();
    while (lines.next()) |line| {
        const i = try Instruction.decode(line);
        crt.process(i);
    }

    std.debug.print("Part 01: {}\n", .{crt.signal_strength});
    std.debug.print("Part 02:\n", .{});
    for (crt.screen, 0..) |pixel, i| {
        if (i > 0 and i % W == 0) {
            std.debug.print("\n", .{});
        }

        const ch: u8 = if (pixel == 1) '#' else '.';
        std.debug.print("{c}", .{ch});
    }
}

const W: usize = 40;
const H: usize = 6;

const Crt = struct {
    cycle: usize,
    x: i32,
    screen: [W * H]u8,
    signal_strength: i32, // part 1

    const Self = @This();

    pub fn new() Crt {
        return Crt{
            .cycle = 0,
            .x = 1,
            .signal_strength = 0,
            .screen = [_]u8{0} ** (W * H),
        };
    }

    pub fn process(self: *Self, i: Instruction) void {
        switch (i) {
            InstructionType.noop => self.tick(),
            InstructionType.addx => |v| {
                self.tick();
                self.tick();
                self.x += v;
            },
        }
    }

    fn tick(self: *Self) void {
        const w = self.cycle % W;
        if (w >= self.x - 1 and w <= self.x + 1) {
            self.screen[self.cycle] = 1;
        }
        self.cycle += 1;
        // TODO: would like to make this a probe function instead of
        // hardcoding the calculation here directly, but Zig doesn't have
        // closures. wasn't quite sure how to setup dynamic disptach
        // either.
        if (self.cycle % 40 == 20) {
            self.signal_strength += @as(i32, @intCast(self.cycle)) * self.x;
        }
    }
};

const InstructionType = enum {
    noop,
    addx,
};

const Instruction = union(InstructionType) {
    noop: void,
    addx: i32,

    pub fn decode(s: []const u8) !Instruction {
        var words = std.mem.splitSequence(u8, s, " ");
        const cmd = words.next().?;
        if (std.mem.eql(u8, cmd, "noop")) {
            return Instruction{ .noop = {} };
        } else if (std.mem.eql(u8, cmd, "addx")) {
            const amt = try std.fmt.parseInt(i32, words.next().?, 10);
            return Instruction{ .addx = amt };
        } else {
            return error.InvalidInstruction;
        }
    }
};

test "Instruction.parse" {
    const expect = std.testing.expect;

    var i = try Instruction.decode("noop");
    try expect(@as(InstructionType, i) == InstructionType.noop);

    i = try Instruction.decode("addx 20");
    try expect(@as(InstructionType, i) == InstructionType.addx);
    switch (i) {
        InstructionType.noop => unreachable,
        InstructionType.addx => |v| try expect(v == 20),
    }

    i = try Instruction.decode("addx -20");
    try expect(@as(InstructionType, i) == InstructionType.addx);
    switch (i) {
        InstructionType.noop => unreachable,
        InstructionType.addx => |v| try expect(v == -20),
    }
}
