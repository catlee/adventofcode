const aoc = @import("aoc.zig");
const std = @import("std");
const containers = @import("containers.zig");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;

const example =
    \\#####
    \\.####
    \\.####
    \\.####
    \\.#.#.
    \\.#...
    \\.....
    \\
    \\#####
    \\##.##
    \\.#.##
    \\...##
    \\...#.
    \\...#.
    \\.....
    \\
    \\.....
    \\#....
    \\#....
    \\#...#
    \\#.#.#
    \\#.###
    \\#####
    \\
    \\.....
    \\.....
    \\#.#..
    \\###..
    \\###.#
    \\###.#
    \\#####
    \\
    \\.....
    \\.....
    \\.....
    \\#....
    \\#.#..
    \\#.#.#
    \\#####
;

const Heights = [5]usize;
const HeightsList = std.ArrayList(Heights);

const Parsed = struct {
    locks: HeightsList,
    keys: HeightsList,

    fn init(allocator: std.mem.Allocator) Parsed {
        return Parsed{
            .locks = HeightsList.init(allocator),
            .keys = HeightsList.init(allocator),
        };
    }

    fn deinit(self: *const Parsed) void {
        self.locks.deinit();
        self.keys.deinit();
    }
};

fn parse(data: []const u8) !Parsed {
    var iter = std.mem.splitSequence(u8, data, "\n\n");

    var result = Parsed.init(alloc);

    while (iter.next()) |item| {
        var iter2 = std.mem.splitScalar(u8, item, '\n');
        const header = iter2.next().?;

        if (header[0] == '#') {
            // Lock
            var heights = [_]usize{ 0, 0, 0, 0, 0 };
            var y: usize = 1;
            while (iter2.next()) |line| : (y += 1) {
                for (line, 0..) |c, x| {
                    if (c == '#') {
                        heights[x] = y;
                    }
                }
            }
            // print("Lock: {any}\n", .{heights});
            try result.locks.append(heights);
        } else {
            // Key
            var heights = [_]usize{ 5, 5, 5, 5, 5 };
            var y: usize = 1;
            while (iter2.next()) |line| : (y += 1) {
                for (line, 0..) |c, x| {
                    if (c == '.') {
                        heights[x] = 5 - y;
                    }
                }
            }
            // print("Key: {any}\n", .{heights});
            try result.keys.append(heights);
        }
    }

    return result;
}

fn part1(data: []const u8) !usize {
    const keys_and_locks = try parse(data);
    defer keys_and_locks.deinit();

    var matches: usize = 0;
    for (keys_and_locks.keys.items) |key| {
        for (keys_and_locks.locks.items) |lock| {
            for (0..5) |i| {
                if (key[i] + lock[i] >= 6) {
                    break;
                }
            } else {
                matches += 1;
            }
        }
    }
    return matches;
}

test "part1 example" {
    try expect(3, try part1(example));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 25);
    defer alloc.free(data);
    try expect(3114, try part1(data));
}
