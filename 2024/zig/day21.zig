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
const Commands = std.ArrayList(Command);
const Results = std.ArrayList(u8);

// Generic 3xN keypad
const Keypad = struct {
    keys: []const u8,
    pos: Point,
    gap: Point,
    height: usize,

    const Self = @This();

    fn init(keys: []const u8) Self {
        var keypad = Self{ .keys = keys, .gap = undefined, .pos = undefined, .height = keys.len / 3 };
        keypad.gap = keypad.buttonPos('_');
        keypad.pos = keypad.buttonPos('A');
        return keypad;
    }

    fn buttonPos(self: *const Self, button: u8) Point {
        const offset = std.mem.indexOfScalar(u8, self.keys, button) orelse unreachable;
        return .{ .x = offset % 3, .y = offset / 3 };
    }

    fn doChar(self: *Self, c: u8) ?u8 {
        return self.doCommand(@enumFromInt(c));
    }

    fn doChars(self: *Self, chars: []const u8) !Results {
        var results = Results.init(alloc);
        for (chars) |c| {
            if (self.doChar(c)) |result| {
                try results.append(result);
            }
        }
        return results;
    }

    fn doCommand(self: *Self, c: Command) ?u8 {
        switch (c) {
            Command.Up => {
                if (self.pos.y < self.height) self.pos.y += 1;
            },
            Command.Down => {
                if (self.pos.y > 0) self.pos.y -= 1;
            },
            Command.Left => {
                if (self.pos.x > 0) self.pos.x -= 1;
            },
            Command.Right => {
                if (self.pos.x < 2) self.pos.x += 1;
            },
            Command.Press => {
                if (self.pos.eql(self.gap)) unreachable;
                const offset = self.pos.y * 3 + self.pos.x;
                return self.keys[offset];
            },
        }
        if (self.pos.eql(self.gap)) {
            std.debug.panic("hit the gap doing {}\n", .{c});
        }
        return null;
    }

    fn doCommands(self: *Self, commands: []const Command) !Results {
        var results = Results.init(alloc);
        for (commands) |c| {
            if (self.doCommand(c)) |result| {
                try results.append(result);
            }
        }
        return results;
    }

    fn pressButton(self: *Self, button: u8) !Commands {
        const button_pos = self.buttonPos(button);
        const distance = self.pos.distance(button_pos);
        var commands = try Commands.initCapacity(alloc, distance + 1);

        // Prefer to move in this order: < v > ^, while grouping together moves
        // If we would hit the gap, then skip the order and fix up at the end
        //
        // Left
        if (self.pos.x > button_pos.x and (self.pos.y != self.gap.y or button_pos.x != self.gap.x)) {
            const dx = diff(self.pos.x, button_pos.x);
            const cmd = Command.Left;
            for (0..dx) |_| {
                try commands.append(cmd);
            }
            self.pos.x = button_pos.x;
        }

        // Down
        if (self.pos.y > button_pos.y and (self.pos.x != self.gap.x or button_pos.y != self.gap.y)) {
            const dy = diff(self.pos.y, button_pos.y);
            const cmd = Command.Down;
            for (0..dy) |_| {
                try commands.append(cmd);
            }
            self.pos.y = button_pos.y;
        }

        // Right
        if (self.pos.x < button_pos.x) {
            const dx = diff(self.pos.x, button_pos.x);
            const cmd = Command.Right;
            for (0..dx) |_| {
                try commands.append(cmd);
            }
            self.pos.x = button_pos.x;
        }

        // Up
        if (self.pos.y < button_pos.y and (self.pos.x != self.gap.x or button_pos.y != self.gap.y)) {
            const dy = diff(self.pos.y, button_pos.y);
            const cmd = Command.Up;
            for (0..dy) |_| {
                try commands.append(cmd);
            }
            self.pos.y = button_pos.y;
        }

        { // Fix up X
            const dx = diff(self.pos.x, button_pos.x);
            const cmd = if (self.pos.x < button_pos.x) Command.Right else Command.Left;
            for (0..dx) |_| {
                try commands.append(cmd);
            }
            self.pos.x = button_pos.x;
        }
        { // Fix up Y
            const dy = diff(self.pos.y, button_pos.y);
            const cmd = if (self.pos.y < button_pos.y) Command.Up else Command.Down;
            for (0..dy) |_| {
                try commands.append(cmd);
            }
            self.pos.y = button_pos.y;
        }

        try commands.append(Command.Press);
        return commands;
    }

    fn pressButtons(self: *Self, buttons: []const u8) !Commands {
        var commands = Commands.init(alloc);
        for (buttons) |b| {
            const presses = try self.pressButton(b);
            defer presses.deinit();
            try commands.appendSlice(presses.items);
        }
        return commands;
    }
};

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

fn part1_expand(buttons: []const u8) !Commands {
    var n1 = Keypad.init(NumericKeys);
    var d1 = Keypad.init(DirectionalKeys);
    var d2 = Keypad.init(DirectionalKeys);

    var n1_commands = Commands.init(alloc);
    defer n1_commands.deinit();
    for (buttons) |b| {
        const presses = try n1.pressButton(b);
        defer presses.deinit();
        try n1_commands.appendSlice(presses.items);
    }
    // print("n1_commands: {s}\n", .{n1_commands.items});

    var d1_commands = Commands.init(alloc);
    defer d1_commands.deinit();
    for (n1_commands.items) |b| {
        const presses = try d1.pressButton(@intFromEnum(b));
        defer presses.deinit();
        try d1_commands.appendSlice(presses.items);
    }

    // print("d1_commands: {s}\n", .{d1_commands.items});

    var d2_commands = Commands.init(alloc);
    for (d1_commands.items) |b| {
        const presses = try d2.pressButton(@intFromEnum(b));
        defer presses.deinit();
        try d2_commands.appendSlice(presses.items);
    }
    // print("d2_commands: {s}\n", .{d2_commands.items});
    return d2_commands;
}

fn expand(buttons: []const u8, keypads: []Keypad) !Commands {
    var commands = Commands.init(alloc);
    try commands.appendSlice(@ptrCast(buttons));

    for (0..keypads.len) |i| {
        print("keypad {d}; buttons: {d}\n", .{ i, commands.items.len });
        var kp = keypads[i];
        const presses = try kp.pressButtons(@ptrCast(commands.items));
        commands.deinit();
        commands = presses;
    }

    return commands;
}

fn part1(data: []const u8) !usize {
    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();

    var scores: usize = 0;
    for (lines.items) |line| {
        if (line.len == 0) continue;
        const code = try std.fmt.parseInt(usize, line[0..3], 10);
        var keypads = try makeKeypads(2);
        defer keypads.deinit();
        const commands = try expand(line, keypads.items);
        defer commands.deinit();
        scores += code * commands.items.len;
    }
    return scores;
}

fn makeKeypads(n: usize) !std.ArrayList(Keypad) {
    var keypads = std.ArrayList(Keypad).init(alloc);
    try keypads.append(Keypad.init(NumericKeys));
    for (0..n) |_| {
        try keypads.append(Keypad.init(DirectionalKeys));
    }
    return keypads;
}

fn part2(data: []const u8) !usize {
    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();

    var scores: usize = 0;
    for (lines.items) |line| {
        if (line.len == 0) continue;
        const code = try std.fmt.parseInt(usize, line[0..3], 10);
        var keypads = try makeKeypads(26);
        defer keypads.deinit();
        const commands = try expand(line, keypads.items);
        defer commands.deinit();
        scores += code * commands.items.len;
    }
    return scores;
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
    try expect(0, try part2(data));
}

test "NumericKeypad" {
    var keypad = Keypad.init(NumericKeys);

    const commands = try keypad.pressButton('1');
    defer commands.deinit();
    try std.testing.expectEqualStrings("^<<A", @ptrCast(commands.items));

    keypad.pos = .{ .x = 2, .y = 0 };
    const results = try keypad.doCommands(commands.items);
    defer results.deinit();
    try std.testing.expectEqualStrings("1", @ptrCast(results.items));
}

test "part1 example numeric keypad" {
    var keypad = Keypad.init(NumericKeys);

    var commands = Commands.init(alloc);
    defer commands.deinit();

    const buttons = "029A";

    for (buttons) |b| {
        const presses = try keypad.pressButton(b);
        defer presses.deinit();
        try commands.appendSlice(presses.items);
    }

    try std.testing.expectEqualStrings("<A^A>^^AvvvA", @ptrCast(commands.items));
}

test "part1 example directional keypad" {
    var keypad = Keypad.init(DirectionalKeys);

    var commands = Commands.init(alloc);
    defer commands.deinit();

    const buttons = "<A^A>^^AvvvA";

    for (buttons) |b| {
        const presses = try keypad.pressButton(b);
        defer presses.deinit();
        try commands.appendSlice(presses.items);
    }

    try std.testing.expectEqualStrings("v<<A>>^A<A>AvA<^AA>A<vAAA>^A", @ptrCast(commands.items));
}

fn part1_run(buttons: []const u8) !Results {
    var n1 = Keypad.init(NumericKeys);
    var d1 = Keypad.init(DirectionalKeys);
    var d2 = Keypad.init(DirectionalKeys);

    var results = Results.init(alloc);
    for (buttons) |b1| {
        if (d2.doChar(b1)) |b2| {
            if (d1.doChar(b2)) |b3| {
                if (n1.doChar(b3)) |c| {
                    try results.append(c);
                }
            }
        }
    }
    return results;
}

test "part1 run" {
    const buttons = "<vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A";
    try expect(68, buttons.len);
    var results = try part1_run(buttons);
    defer results.deinit();
    try std.testing.expectEqualStrings("029A", @ptrCast(results.items));
}

test "part1 expand 029A" {
    const buttons = "029A";
    const results = try part1_expand(buttons);
    defer results.deinit();

    const r1 = try part1_run(@ptrCast(results.items));
    defer r1.deinit();
    // print("{s}\n", .{r1.items});
    try std.testing.expectEqualStrings("029A", @ptrCast(r1.items));
    // print("{s}\n", .{@as([]u8, @ptrCast(results.items))});
    // print("<vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A\n", .{});
    try expect(68, results.items.len);
}

fn splitToArray(data: []const u8, separator: u8) !std.ArrayList([]const u8) {
    var iter = std.mem.splitScalar(u8, data, separator);
    var results = std.ArrayList([]const u8).init(alloc);
    while (iter.next()) |slice| {
        try results.append(slice);
    }
    return results;
}

test "part1 expand 379A" {
    const buttons = "379A";
    const results = try part1_expand(buttons);
    defer results.deinit();

    // var n1 = Keypad.init(NumericKeys);
    // var d1 = Keypad.init(DirectionalKeys);
    // var d2 = Keypad.init(DirectionalKeys);

    // var commands = try n1.pressButtons(buttons);
    // defer commands.deinit();
    // print("{s}\n", .{@as([]u8, @ptrCast(commands.items))});
    //
    // var d1_commands = try d1.pressButtons(@ptrCast(commands.items));
    // defer d1_commands.deinit();
    // print("{s}\n", .{@as([]u8, @ptrCast(d1_commands.items))});

    // var d2_commands = try d1.pressButtons(@ptrCast(d1_commands.items));
    // defer d2_commands.deinit();
    // print("{s}\n", .{@as([]u8, @ptrCast(d2_commands.items))});

    const r1 = try part1_run(@ptrCast(results.items));
    defer r1.deinit();
    // print("{s}\n", .{r1.items});
    try std.testing.expectEqualStrings("379A", @ptrCast(r1.items));

    // const theirs = "<v<A>>^AvA^A<vA<AA>>^AAvA<^A>AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A";
    // print("mine:   {s}\n", .{@as([]u8, @ptrCast(results.items))});
    // print("theirs: {s}\n", .{theirs});
    // print("\n", .{});

    // {
    //     var d = Keypad.init(DirectionalKeys);
    //     var s1 = try d.doChars(@ptrCast(results.items));
    //     defer s1.deinit();
    //     print("mine step1:   {s}\n", .{s1.items});
    //     d = Keypad.init(DirectionalKeys);
    //     var s2 = try d.doChars(@ptrCast(s1.items));
    //     defer s2.deinit();
    //     print("mine step2:   {s}\n", .{s2.items});
    // }
    // {
    //     var d = Keypad.init(DirectionalKeys);
    //     var s1 = try d.doChars(theirs);
    //     defer s1.deinit();
    //     print("theirs step1: {s}\n", .{s1.items});
    //     var s2 = try d.doChars(@ptrCast(s1.items));
    //     defer s2.deinit();
    //     print("theirs step2: {s}\n", .{s2.items});
    // }

    // const result_parts = try splitToArray(@ptrCast(results.items), 'A');
    // defer result_parts.deinit();
    // print("{s}\n", .{result_parts.items});
    //
    // const actual_parts = try splitToArray("<v<A>>^AvA^A<vA<AA>>^AAvA<^A>AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A", 'A');
    // defer actual_parts.deinit();
    // print("{s}\n", .{actual_parts.items});
    try expect(64, results.items.len);
}

test "keypad" {
    var keypad = Keypad.init("_0A123456789");
    try std.testing.expectEqualDeep(Point{ .x = 2, .y = 0 }, keypad.pos);

    _ = keypad.doChar('^');
    try std.testing.expectEqualDeep(Point{ .x = 2, .y = 1 }, keypad.pos);
    _ = keypad.doChar('^');
}
