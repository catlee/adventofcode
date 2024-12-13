const aoc = @import("aoc.zig");
const std = @import("std");
const containers = @import("containers.zig");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;
const ArrayList = std.ArrayList;

const example =
    \\Button A: X+94, Y+34
    \\Button B: X+22, Y+67
    \\Prize: X=8400, Y=5400
    \\
    \\Button A: X+26, Y+66
    \\Button B: X+67, Y+21
    \\Prize: X=12748, Y=12176
    \\
    \\Button A: X+17, Y+86
    \\Button B: X+84, Y+37
    \\Prize: X=7870, Y=6450
    \\
    \\Button A: X+69, Y+23
    \\Button B: X+27, Y+71
    \\Prize: X=18641, Y=10279
;

const Vec2 = struct {
    x: f64,
    y: f64,
};

// A 2x2 matrix
// |a b|
// |c d|
const Matrix = struct {
    a: f64,
    b: f64,
    c: f64,
    d: f64,

    const Self = @This();

    fn determinant(self: *const Self) f64 {
        return (self.a * self.d) - (self.b * self.c);
    }

    fn inverse(self: *const Self) ?Self {
        const det = self.determinant();
        if (det == 0) {
            return null;
        }

        return Self{
            .a = (self.d / det),
            .b = (-self.b / det),
            .c = (-self.c / det),
            .d = (self.a / det),
        };
    }

    fn mul(self: *const Self, v: Vec2) Vec2 {
        return Vec2{
            .x = (self.a * v.x + self.b * v.y),
            .y = (self.c * v.x + self.d * v.y),
        };
    }
};

fn cost(a: Vec2, b: Vec2, p: Vec2) ?usize {
    const A = Matrix{
        .a = a.x,
        .b = b.x,
        .c = a.y,
        .d = b.y,
    };
    if (A.inverse()) |A_inv| {
        const res = A_inv.mul(p);
        // Check if res is an integer number of presses
        const a_presses = @round(res.x);
        const b_presses = @round(res.y);
        if (a_presses * a.x + b_presses * b.x != p.x) {
            return null;
        }
        if (a_presses * a.y + b_presses * b.y != p.y) {
            return null;
        }
        return @intFromFloat(a_presses * 3 + b_presses);
    } else {
        // Button B is a multiple of button A
        // Figure out if we can get to the prize with one of them
        unreachable; // TODO
    }
}

const Machine = struct {
    a: Vec2,
    b: Vec2,
    p: Vec2,
};

fn parseButtonLine(data: []const u8) ?Vec2 {
    var plusIndex = std.mem.indexOfScalar(u8, data, '+') orelse return null;
    const commaIndex = std.mem.indexOfScalarPos(u8, data, plusIndex + 1, ',') orelse return null;
    const x = std.fmt.parseFloat(f64, data[plusIndex + 1 .. commaIndex]) catch return null;
    plusIndex = std.mem.indexOfScalarPos(u8, data, commaIndex + 1, '+') orelse return null;
    const y = std.fmt.parseFloat(f64, data[plusIndex + 1 ..]) catch return null;
    return Vec2{ .x = x, .y = y };
}

fn parsePrizeLine(data: []const u8) ?Vec2 {
    var equalIndex = std.mem.indexOfScalar(u8, data, '=') orelse return null;
    const commaIndex = std.mem.indexOfScalarPos(u8, data, equalIndex + 1, ',') orelse return null;
    const x = std.fmt.parseFloat(f64, data[equalIndex + 1 .. commaIndex]) catch return null;
    equalIndex = std.mem.indexOfScalarPos(u8, data, commaIndex + 1, '=') orelse return null;
    const y = std.fmt.parseFloat(f64, data[equalIndex + 1 ..]) catch return null;
    return Vec2{ .x = x, .y = y };
}

fn parse(data: []const u8) !ArrayList(Machine) {
    var result = ArrayList(Machine).init(alloc);

    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();

    var i: usize = 0;
    while (i < lines.items.len) : (i += 4) {
        const a = parseButtonLine(lines.items[i]) orelse continue;
        const b = parseButtonLine(lines.items[i + 1]) orelse continue;
        const p = parsePrizeLine(lines.items[i + 2]) orelse continue;
        try result.append(.{ .a = a, .b = b, .p = p });
    }
    return result;
}

fn part1(data: []const u8) !usize {
    var machines = try parse(data);
    defer machines.deinit();

    var total_cost: usize = 0;

    for (machines.items) |m| {
        if (cost(m.a, m.b, m.p)) |c| {
            total_cost += c;
        }
    }
    return total_cost;
}

fn part2(data: []const u8) !usize {
    var machines = try parse(data);
    defer machines.deinit();

    var total_cost: usize = 0;

    for (machines.items) |m| {
        var p = m.p;
        p.x += 10000000000000;
        p.y += 10000000000000;
        if (cost(m.a, m.b, p)) |c| {
            total_cost += c;
        }
    }
    return total_cost;
}

test "part1 example" {
    try expect(480, try part1(example));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 13);
    defer alloc.free(data);
    try expect(33921, try part1(data));
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 13);
    defer alloc.free(data);
    try expect(82261957837868, try part2(data));
}

test "example1" {
    const a = Vec2{ .x = 94, .y = 34 };
    const b = Vec2{ .x = 22, .y = 67 };
    const p = Vec2{ .x = 8400, .y = 5400 };

    try expect(280, cost(a, b, p));
}

test "example2" {
    const a = Vec2{ .x = 26, .y = 66 };
    const b = Vec2{ .x = 67, .y = 21 };
    const p = Vec2{ .x = 12748, .y = 12176 };

    try expect(null, cost(a, b, p));
}

test "example3" {
    const a = Vec2{ .x = 17, .y = 86 };
    const b = Vec2{ .x = 84, .y = 37 };
    const p = Vec2{ .x = 7870, .y = 6450 };

    try expect(200, cost(a, b, p));
}

test "example4" {
    const a = Vec2{ .x = 69, .y = 23 };
    const b = Vec2{ .x = 27, .y = 71 };
    const p = Vec2{ .x = 18641, .y = 10279 };

    try expect(null, cost(a, b, p));
}

test "example 5" {
    // const a = Vec2{ .x = 5, .y = 3 };
    // const b = Vec2{ .x = 10, .y = 6 };
    // const p = Vec2{ .x = 20, .y = 12 };

    // try expect(2, cost(a, b, p));
}
