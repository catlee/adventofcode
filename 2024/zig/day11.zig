const aoc = @import("aoc.zig");
const std = @import("std");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;

fn part1(data: []const u8) !usize {
    var numbers: std.ArrayList(usize) = try aoc.splitToNumbers(usize, alloc, data);
    defer numbers.deinit();

    var blinker = Blinker.init(alloc);
    defer blinker.deinit();

    var sum: usize = 0;

    for (numbers.items) |num| {
        sum += try blinker.blink(num, 25);
    }

    return sum;
}

fn part2(data: []const u8) !usize {
    var numbers: std.ArrayList(usize) = try aoc.splitToNumbers(usize, alloc, data);
    defer numbers.deinit();

    var blinker = Blinker.init(alloc);
    defer blinker.deinit();

    var sum: usize = 0;

    for (numbers.items) |num| {
        sum += try blinker.blink(num, 75);
    }

    return sum;
}

fn numDigits(n: usize) usize {
    if (n == 0) {
        return 1;
    }
    return std.math.log10_int(n) + 1;
}

const BlinkerItem = struct {
    num: usize,
    blinks: usize,
};
const Blinker = struct {
    cache: std.AutoHashMap(BlinkerItem, usize),

    const Self = @This();

    fn init(a: std.mem.Allocator) Self {
        return .{ .cache = std.AutoHashMap(BlinkerItem, usize).init(a) };
    }

    fn deinit(self: *Self) void {
        self.cache.deinit();
    }

    // Returns how many numbers num turns into after blinks blinks
    fn blink(self: *Self, num: usize, blinks: usize) !usize {
        if (blinks == 0) {
            return 1;
        }
        if (self.cache.get(.{ .num = num, .blinks = blinks })) |count| {
            return count;
        }
        if (num == 0) {
            const b = try self.blink(1, blinks - 1);
            try self.cache.put(.{ .num = num, .blinks = blinks }, b);
            return b;
        }
        const d = numDigits(num);
        if (d % 2 == 0) {
            const m = std.math.pow(usize, 10, d / 2);
            var b = try self.blink(num / m, blinks - 1);
            b += try self.blink(num % m, blinks - 1);
            try self.cache.put(.{ .num = num, .blinks = blinks }, b);
            return b;
        }
        const b = try self.blink(num * 2024, blinks - 1);
        try self.cache.put(.{ .num = num, .blinks = blinks }, b);
        return b;
    }
};

test "blinker" {
    var blinker = Blinker.init(alloc);
    defer blinker.deinit();

    try expect(1, try blinker.blink(1, 1));
    try expect(2, try blinker.blink(17, 1));
}

test "part1 example" {
    const example = "125 17";
    try expect(55312, try part1(example));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 11);
    defer alloc.free(data);
    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();

    try expect(194557, try part1(lines.items[0]));
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 11);
    defer alloc.free(data);
    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();

    const start = std.time.milliTimestamp();
    try expect(231532558973909, try part2(lines.items[0]));
    const end = std.time.milliTimestamp();

    print("Time: {}\n", .{end - start});
}
