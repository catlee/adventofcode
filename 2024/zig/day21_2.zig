const aoc = @import("aoc.zig");
const std = @import("std");
const containers = @import("containers.zig");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;
const expectEqualStrings = std.testing.expectEqualStrings;

fn diff(a: usize, b: usize) usize {
    return @abs(@as(isize, @intCast(a)) - @as(isize, @intCast(b)));
}

const Point = struct {
    x: usize,
    y: usize,

    fn eql(self: *const Point, other: Point) bool {
        return self.x == other.x and self.y == other.y;
    }

    fn distance(self: *const Point, other: Point) usize {
        return diff(self.x, other.x) + diff(self.y, other.y);
    }
};

const Command = enum(u8) {
    Up = '^',
    Down = 'v',
    Left = '<',
    Right = '>',
    Press = 'A',
};
const Commands = std.ArrayList(u8);
const Results = std.ArrayList(u8);

// Numeric keypad
// +---+---+---+
// | 7 | 8 | 9 |
// +---+---+---+
// | 4 | 5 | 6 |
// +---+---+---+
// | 1 | 2 | 3 |
// +---+---+---+
//     | 0 | A |
//     +---+---+
// y = 0 is at the bottom so that the Up command increases y
const NumericKeys = "_0A123456789";

// Directional keypad
//     +---+---+
//     | ^ | A |
// +---+---+---+
// | < | v | > |
// +---+---+---+
const DirectionalKeys = "<v>_^A";

const example =
    \\029A
    \\980A
    \\179A
    \\456A
    \\379A
;

// Generic 3xN keypad
const Keypad = struct {
    keys: []const u8,
    gap: Point,
    height: usize,

    const Self = @This();

    fn init(keys: []const u8) Self {
        var keypad = Self{ .keys = keys, .gap = undefined, .height = keys.len / 3 };
        keypad.gap = keypad.buttonPos('_');
        return keypad;
    }

    fn buttonPos(self: *const Self, button: u8) Point {
        const offset = std.mem.indexOfScalar(u8, self.keys, button) orelse unreachable;
        return .{ .x = offset % 3, .y = offset / 3 };
    }

    fn commandsForButton(self: *const Self, from_button: u8, to_button: u8) !Commands {
        var from_pos = self.buttonPos(from_button);
        const to_pos = self.buttonPos(to_button);
        const distance = from_pos.distance(to_pos);
        var commands = try Commands.initCapacity(alloc, distance + 1);

        var changes: usize = 0;

        // Prefer to move in this order: < v ^ >, while grouping together moves
        // If we would hit the gap, then skip the order and fix up at the end
        //
        // Left
        if (from_pos.x > to_pos.x and (from_pos.y != self.gap.y or to_pos.x != self.gap.x)) {
            const dx = diff(from_pos.x, to_pos.x);
            const cmd = Command.Left;
            for (0..dx) |_| {
                try commands.append(@intFromEnum(cmd));
            }
            from_pos.x = to_pos.x;
            changes += 1;
        }

        // Down
        if (from_pos.y > to_pos.y and (from_pos.x != self.gap.x or to_pos.y != self.gap.y)) {
            const dy = diff(from_pos.y, to_pos.y);
            const cmd = Command.Down;
            for (0..dy) |_| {
                try commands.append(@intFromEnum(cmd));
            }
            from_pos.y = to_pos.y;
            changes += 1;
        }

        // Up
        if (from_pos.y < to_pos.y and (from_pos.x != self.gap.x or to_pos.y != self.gap.y)) {
            const dy = diff(from_pos.y, to_pos.y);
            const cmd = Command.Up;
            for (0..dy) |_| {
                try commands.append(@intFromEnum(cmd));
            }
            from_pos.y = to_pos.y;
            changes += 1;
        }

        // Right
        if (from_pos.x < to_pos.x) {
            const dx = diff(from_pos.x, to_pos.x);
            const cmd = Command.Right;
            for (0..dx) |_| {
                try commands.append(@intFromEnum(cmd));
            }
            from_pos.x = to_pos.x;
            changes += 1;
        }

        { // Fix up X
            const dx = diff(from_pos.x, to_pos.x);
            const cmd = if (from_pos.x < to_pos.x) Command.Right else Command.Left;
            for (0..dx) |_| {
                try commands.append(@intFromEnum(cmd));
            }
            from_pos.x = to_pos.x;
            if (dx > 0) changes += 1;
        }
        { // Fix up Y
            const dy = diff(from_pos.y, to_pos.y);
            const cmd = if (from_pos.y < to_pos.y) Command.Up else Command.Down;
            for (0..dy) |_| {
                try commands.append(@intFromEnum(cmd));
            }
            from_pos.y = to_pos.y;
            if (dy > 0) changes += 1;
        }

        try commands.append(@intFromEnum(Command.Press));

        return commands;
    }
};

const NumericKeypad = Keypad.init(NumericKeys);
const DirectionalKeypad = Keypad.init(DirectionalKeys);

const CacheKey = struct {
    code: []const u8,
    keypads: usize,
};

const CacheContext = struct {
    pub fn hash(_: @This(), k: CacheKey) u64 {
        return std.hash_map.hashString(k.code) ^ k.keypads;
    }

    pub fn eql(_: @This(), a: CacheKey, b: CacheKey) bool {
        return a.keypads == b.keypads and std.mem.eql(u8, a.code, b.code);
    }
};

const Cache = std.HashMap(CacheKey, usize, CacheContext, 80);

fn shortestDirections(cache: *Cache, code: []const u8, keypads: usize) !usize {
    if (keypads == 1) {
        return code.len;
    }

    var cache_key = CacheKey{ .code = code, .keypads = keypads };
    if (cache.get(cache_key)) |result| {
        return result;
    }

    // for (0..keypads) |_| {
    //     print(" ", .{});
    // }

    // print("finding shortest path for {s} at depth {d}\n", .{ code, keypads });
    var command_length: usize = 0;
    var current: u8 = 'A';
    for (code) |c| {
        const commands = try DirectionalKeypad.commandsForButton(current, c);
        defer commands.deinit();
        // for (0..keypads) |_| {
        //     print(" ", .{});
        // }
        // print("from {c} to {c}: {s}\n", .{ current, c, commands.items });
        current = c;
        // command_length += commands.items.len;
        command_length += try shortestDirections(cache, commands.items, keypads - 1);
    }

    const my_code = try alloc.alloc(u8, code.len);
    std.mem.copyForwards(u8, my_code, code);
    cache_key.code = my_code;
    try cache.put(cache_key, command_length);

    return command_length;
}

fn shortestSequence(code: []const u8, keypads: usize) !usize {
    var current: u8 = 'A';
    var command_length: usize = 0;
    var cache = Cache.init(alloc);
    defer cache.deinit();
    // First figure out the motions on the numeric pad, e.g.
    // for 379A, we should do ^A, <<^^A, >>A, vvvA
    // Then recurse on the directional pad, breaking up sequences by strings ending with A
    for (code) |c| {
        const commands = try NumericKeypad.commandsForButton(current, c);
        defer commands.deinit();
        // print("from {c} to {c}: {s}\n", .{ current, c, commands.items });
        current = c;
        command_length += try shortestDirections(&cache, commands.items, keypads);
    }

    var it = cache.keyIterator();
    while (it.next()) |key| {
        alloc.free(key.code);
    }
    return command_length;
}

fn codeComplexity(code: []const u8, keypads: usize) !usize {
    const length = try shortestSequence(code, keypads);
    const code_value = try std.fmt.parseInt(usize, code[0..3], 10);
    return length * code_value;
}

fn part1(data: []const u8) !usize {
    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();

    var score: usize = 0;
    for (lines.items) |line| {
        if (line.len == 0) continue;
        score += try codeComplexity(line, 3);
    }

    return score;
}

fn part2(data: []const u8) !usize {
    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();

    var score: usize = 0;
    for (lines.items) |line| {
        if (line.len == 0) continue;
        score += try codeComplexity(line, 26);
    }

    return score;
}

test "numeric keypad" {
    const commands = try NumericKeypad.commandsForButton('3', '7');
    defer commands.deinit();
    try std.testing.expectEqualStrings("<<^^A", @ptrCast(commands.items));
}

test "379A" {
    const code = "379A";
    const keypads = 3;
    const result = try codeComplexity(code, keypads);
    try expect(64 * 379, result);
}

test "part1 example" {
    try expect(126384, try part1(example));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 21);
    defer alloc.free(data);
    try expect(134120, try part1(data));
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 21);
    defer alloc.free(data);
    try expect(167389793580400, try part2(data));
}
