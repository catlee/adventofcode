const aoc = @import("aoc.zig");
const std = @import("std");
const expect = std.testing.expect;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const example =
    \\7 6 4 2 1
    \\1 2 7 8 9
    \\9 7 6 2 1
    \\1 3 2 4 5
    \\8 6 4 4 1
    \\1 3 6 7 9
;

fn is_safe(numbers: []isize) bool {
    var last: ?isize = null;
    var direction: ?isize = null;
    // std.debug.print("report: {s}\n", .{report});
    for (numbers) |n| {
        // std.debug.print("\nn: {d}\n", .{n});
        if (last == null) {
            last = n;
            continue;
        }
        const delta: isize = n - last.?;
        last = n;
        // std.debug.print("delta: {d}={d}-{d}\n", .{ delta, n, last.? });
        if (@abs(delta) < 1 or @abs(delta) > 3) {
            // std.debug.print("unsafe; delta out of range", .{});
            return false;
        }
        if (direction == null) {
            direction = std.math.sign(delta);
            // std.debug.print("direction: {d}\n", .{direction.?});
        } else if (direction != std.math.sign(delta)) {
            // std.debug.print("unsafe; wrong direction", .{});
            return false;
        }
    }
    // std.debug.print("safe!\n", .{});
    return true;
}

fn could_be_safe(numbers: []isize) !bool {
    if (is_safe(numbers)) {
        // std.debug.print("safe: {d}\n", .{numbers});
        return true;
    }

    const alloc = gpa.allocator();

    for (0..numbers.len) |i| {
        var new_numbers = try alloc.alloc(isize, numbers.len - 1);
        defer alloc.free(new_numbers);

        @memcpy(new_numbers[0..i], numbers[0..i]);
        @memcpy(new_numbers[i..], numbers[i + 1 ..]);
        if (is_safe(new_numbers)) {
            // std.debug.print("safe: {d}\n", .{new_numbers});
            return true;
        }
    }
    return false;
}

fn part1(input: []const u8) !usize {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();

    const alloc = gpa.allocator();
    const lines = try aoc.splitLines(alloc, input);
    defer _ = lines.deinit();

    var safe_reports: usize = 0;
    for (lines.items) |line| {
        const numbers = try aoc.splitToNumbers(alloc, line);
        defer _ = numbers.deinit();
        if (is_safe(numbers.items)) {
            safe_reports += 1;
        }
    }

    return safe_reports;
}

fn part2(input: []const u8) !usize {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();

    const alloc = gpa.allocator();
    const lines = try aoc.splitLines(alloc, input);
    defer _ = lines.deinit();

    var safe_reports: usize = 0;
    for (lines.items) |line| {
        const numbers = try aoc.splitToNumbers(alloc, line);
        defer _ = numbers.deinit();
        if (try could_be_safe(numbers.items)) {
            safe_reports += 1;
        }
    }

    return safe_reports;
}

test "part1 example" {
    const input = example;
    const result = try part1(input);
    std.debug.print("result: {d}\n", .{result});
    try expect(result == 2);
}

test "part1 actual" {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const input = try aoc.getData(alloc, 2024, 2);
    defer _ = alloc.free(input);

    const result = try part1(input);
    std.debug.print("result: {d}\n", .{result});
    try expect(result == 411);
}

test "part2 example" {
    const input = example;
    const result = try part2(input);
    std.debug.print("result: {d}\n", .{result});
    try expect(result == 4);
}

test "part2 actual" {
    const alloc = gpa.allocator();
    const input = try aoc.getData(alloc, 2024, 2);
    // defer _ = alloc.free(input);

    const result = try part2(input);
    std.debug.print("result: {d}\n", .{result});
    try expect(result == 465);
}
