const aoc = @import("aoc.zig");
const std = @import("std");
const expect = aoc.expect;

const alloc = std.testing.allocator;

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
    for (numbers) |n| {
        if (last == null) {
            last = n;
            continue;
        }
        const delta: isize = n - last.?;
        last = n;
        if (@abs(delta) < 1 or @abs(delta) > 3) {
            return false;
        }
        if (direction == null) {
            direction = std.math.sign(delta);
        } else if (direction != std.math.sign(delta)) {
            return false;
        }
    }
    return true;
}

fn could_be_safe(numbers: []isize) !bool {
    if (is_safe(numbers)) {
        return true;
    }

    for (0..numbers.len) |i| {
        var new_numbers = try alloc.alloc(isize, numbers.len - 1);
        defer alloc.free(new_numbers);

        @memcpy(new_numbers[0..i], numbers[0..i]);
        @memcpy(new_numbers[i..], numbers[i + 1 ..]);
        if (is_safe(new_numbers)) {
            return true;
        }
    }
    return false;
}

fn part1(input: []const u8) !usize {
    const lines = try aoc.splitLines(alloc, input);
    defer _ = lines.deinit();

    var safe_reports: usize = 0;
    for (lines.items) |line| {
        if (line.len == 0) {
            continue;
        }
        const numbers = try aoc.splitToNumbers(alloc, line);
        defer _ = numbers.deinit();
        if (is_safe(numbers.items)) {
            safe_reports += 1;
        }
    }

    return safe_reports;
}

fn part2(input: []const u8) !usize {
    const lines = try aoc.splitLines(alloc, input);
    defer _ = lines.deinit();

    var safe_reports: usize = 0;
    for (lines.items) |line| {
        if (line.len == 0) {
            continue;
        }
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
    try expect(2, result);
}

test "part1 actual" {
    const input = try aoc.getData(alloc, 2024, 2);
    defer _ = alloc.free(input);

    const result = try part1(input);

    try expect(411, result);
}

test "part2 example" {
    const input = example;
    const result = try part2(input);
    try expect(4, result);
}

test "part2 actual" {
    const input = try aoc.getData(alloc, 2024, 2);
    defer _ = alloc.free(input);

    const result = try part2(input);
    try expect(465, result);
}
