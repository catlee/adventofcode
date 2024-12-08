const aoc = @import("aoc.zig");
const std = @import("std");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;

const Equation = struct {
    lhs: usize,
    rhs: std.ArrayList(isize),

    const Self = @This();

    fn parse(line: []const u8) !Self {
        const parts = try aoc.split(alloc, line, ':');
        defer parts.deinit();

        const lhs = try std.fmt.parseInt(usize, parts.items[0], 10);
        const rhs = try aoc.splitToNumbers(alloc, parts.items[1][1..]);
        return .{ .lhs = lhs, .rhs = rhs };
    }

    fn deinit(self: *Self) void {
        self.rhs.deinit();
    }

    fn solvable1(self: *const Self, i: usize, accum: isize) bool {
        if (i == self.rhs.items.len) {
            return (accum == self.lhs);
        }
        var s: bool = false;
        s = s or self.solvable1(i + 1, accum + self.rhs.items[i]);
        s = s or self.solvable1(i + 1, accum * self.rhs.items[i]);
        return s;
    }

    fn solvable2(self: *const Self, i: usize, accum: isize) bool {
        if (i == self.rhs.items.len) {
            return (accum == self.lhs);
        }
        var s: bool = false;
        s = self.solvable2(i + 1, accum + self.rhs.items[i]);
        if (!s) {
            s = s or self.solvable2(i + 1, accum * self.rhs.items[i]);
        }
        if (!s) {
            const digits = std.math.log10_int(@as(usize, @intCast(self.rhs.items[i])));
            const new_accum = accum * std.math.pow(isize, 10, digits + 1) + self.rhs.items[i];
            s = s or self.solvable2(i + 1, new_accum);
        }
        return s;
    }
};

fn part1(data: []const u8) !usize {
    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();

    var sum: usize = 0;
    for (lines.items) |line| {
        if (line.len == 0) {
            continue;
        }
        var eq = try Equation.parse(line);
        defer eq.deinit();
        if (eq.solvable1(0, 0)) {
            sum += eq.lhs;
        }
    }

    return sum;
}

fn part2(data: []const u8) !usize {
    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();

    var sum: usize = 0;
    for (lines.items) |line| {
        if (line.len == 0) {
            continue;
        }
        var eq = try Equation.parse(line);
        defer eq.deinit();
        if (eq.solvable2(0, 0)) {
            sum += eq.lhs;
        }
    }

    return sum;
}

const example =
    \\190: 10 19
    \\3267: 81 40 27
    \\83: 17 5
    \\156: 15 6
    \\7290: 6 8 6 15
    \\161011: 16 10 13
    \\192: 17 8 14
    \\21037: 9 7 18 13
    \\292: 11 6 16 20
;

test "part 1 example" {
    try expect(3749, try part1(example));
}

test "part 1 actual" {
    const data = try aoc.getData(alloc, 2024, 7);
    defer alloc.free(data);
    try expect(42283209483350, try part1(data));
}

test "part 2 example" {
    try expect(11387, try part2(example));
}

test "part 2 actual" {
    const data = try aoc.getData(alloc, 2024, 7);
    defer alloc.free(data);
    try expect(1026766857276279, try part2(data));
}
