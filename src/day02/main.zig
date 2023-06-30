const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut();
    const stdin = std.io.getStdIn();
    var bufr = std.io.bufferedReader(stdin.reader());
    var reader = bufr.reader();

    var p1score: u32 = 0;
    var p2score: u32 = 0;

    var buffer: [8]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const opponent = Move.decode(line[0]) orelse unreachable;
        const p1move = Move.decode(line[2]) orelse unreachable;
        const p2res = GameResult.decode(line[2]) orelse unreachable;

        p1score += @intFromEnum(GameResult.decide(opponent, p1move));
        p1score += @intFromEnum(p1move);

        p2score += @intFromEnum(p2res);
        p2score += @intFromEnum(switch (p2res) {
            .draw => opponent,
            .win => opponent.losesAgainst(),
            .lose => opponent.losesAgainst(),
        });
    }

    try stdout.writer().print("Part 01: {}\n", .{p1score});
    try stdout.writer().print("Part 02: {}\n", .{p2score});
}

const Move = enum(u8) {
    rock = 1,
    paper = 2,
    scissors = 3,

    const Self = @This();

    pub fn decode(c: u8) ?Move {
        return switch (c) {
            'A', 'X' => .rock,
            'B', 'Y' => .paper,
            'C', 'Z' => .scissors,
            else => null,
        };
    }

    pub fn losesAgainst(self: Self) Move {
        return switch (self) {
            .rock => .paper,
            .paper => .scissors,
            .scissors => .rock,
        };
    }

    pub fn winsAgainst(self: Self) Move {
        return switch (self) {
            .rock => .scissors,
            .paper => .rock,
            .scissors => .paper,
        };
    }
};

const GameResult = enum(u8) {
    win = 6,
    lose = 0,
    draw = 3,

    pub fn decode(c: u8) ?GameResult {
        return switch (c) {
            'X' => .lose,
            'Y' => .draw,
            'Z' => .win,
            else => null,
        };
    }

    pub fn decide(opponent: Move, me: Move) GameResult {
        if (opponent == me) {
            return .draw;
        }

        const iWin = (opponent == .rock and me == .paper) or
            (opponent == .paper and me == .scissors) or
            (opponent == .scissors and me == .rock);
        return if (iWin) .win else .lose;
    }
};
