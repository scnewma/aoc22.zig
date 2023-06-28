const std = @import("std");
const io = std.io;
const math = std.math;
const path = std.fs.path;
const Allocator = std.mem.Allocator;

const TOTAL_SPACE = 70000000;
const FREE_SPACE_NEEDED = 30000000;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try io.getStdIn().readToEndAlloc(allocator, math.maxInt(usize));
    defer allocator.free(input);

    const solution = try solve(allocator, input);

    const stdout = io.getStdOut().writer();
    try stdout.print("Part 01: {}\n", .{solution.part01});
    try stdout.print("Part 02: {}\n", .{solution.part02});
}

const Solution = struct {
    part01: usize,
    part02: usize,
};

fn solve(allocator: Allocator, input: []const u8) !Solution {
    var dir_sizes = std.StringHashMap(usize).init(allocator);
    defer {
        // need to explicitly free the keys as the map has ownership of the
        // memory
        var it = dir_sizes.keyIterator();
        while (it.next()) |k| {
            allocator.free(k.*);
        }
        dir_sizes.deinit();
    }

    var lines = std.mem.tokenizeSequence(u8, input, "\n");
    var cwd: []const u8 = try allocator.dupe(u8, "/");
    defer allocator.free(cwd);
    while (lines.next()) |line| {
        var words = std.mem.tokenizeSequence(u8, line, " ");
        const word0 = words.next().?;
        if (std.mem.eql(u8, word0, "$")) {
            const command = words.next().?;
            if (std.mem.eql(u8, command, "cd")) {
                const old_cwd = cwd;
                defer allocator.free(old_cwd);

                const dir = words.next().?;
                if (std.mem.eql(u8, dir, "..")) {
                    cwd = path.dirname(cwd).?;
                    // we want cwd to always be owned, and not a ref to a
                    // previous iteration otherwise freeing the memory becomes
                    // very difficult
                    cwd = try allocator.dupe(u8, cwd);
                } else {
                    cwd = try path.join(allocator, &[_][]const u8{ cwd, dir });
                }
            } else if (std.mem.eql(u8, command, "ls")) {
                // fallthrough to next iteration to handle directory contents
            } else {
                @panic("unknown command");
            }
        } else if (std.mem.eql(u8, word0, "dir")) {
            // do nothing
        } else {
            // word0 is the directory size
            const size = try std.fmt.parseInt(usize, word0, 10);
            const name = words.next().?;
            var dir: []const u8 = try path.join(allocator, &[_][]const u8{ cwd, name });
            var full_path = dir;
            defer allocator.free(full_path);
            while (path.dirname(dir)) |d| {
                if (dir_sizes.contains(d)) {
                    try dir_sizes.put(d, dir_sizes.get(d).? + size);
                } else {
                    // need to dupe the key to give ownership to the map,
                    // otherwise we free the path while the map is using it.
                    const key = try allocator.dupe(u8, d);
                    try dir_sizes.put(key, size);
                }

                dir = d;
            }
        }
    }

    var sum: usize = 0;
    var iter = dir_sizes.valueIterator();
    while (iter.next()) |entry| {
        if (entry.* < 100000) {
            sum += entry.*;
        }
    }

    const free_space = TOTAL_SPACE - dir_sizes.get("/").?;
    const free_space_needed = FREE_SPACE_NEEDED - free_space;

    var min: usize = math.maxInt(usize);
    iter = dir_sizes.valueIterator();
    while (iter.next()) |entry| {
        if (entry.* > free_space_needed) {
            min = intMin(min, entry.*);
        }
    }
    return Solution{
        .part01 = sum,
        .part02 = min,
    };
}

fn intMin(a: usize, b: usize) usize {
    return if (a < b) a else b;
}

const EXAMPLE =
    \\$ cd /
    \\$ ls
    \\dir a
    \\14848514 b.txt
    \\8504156 c.dat
    \\dir d
    \\$ cd a
    \\$ ls
    \\dir e
    \\29116 f
    \\2557 g
    \\62596 h.lst
    \\$ cd e
    \\$ ls
    \\584 i
    \\$ cd ..
    \\$ cd ..
    \\$ cd d
    \\$ ls
    \\4060174 j
    \\8033020 d.log
    \\5626152 d.ext
    \\7214296 k
;

test "solve" {
    const solution = try solve(std.testing.allocator, EXAMPLE);
    try std.testing.expect(solution.part01 == 95437);
    try std.testing.expect(solution.part02 == 24933642);
}
