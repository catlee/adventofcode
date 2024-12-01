const aoc = @import("aoc.zig");
const std = @import("std");
const expect = std.testing.expect;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;

const AocError = error{UnequalLength};

fn part1(input: []const u8) !u32 {
    const alloc = std.heap.page_allocator;

    var left = ArrayList(i32).init(alloc);
    var right = ArrayList(i32).init(alloc);

    defer left.deinit();
    defer right.deinit();

    // Split by lines
    var it = std.mem.splitAny(u8, input, "\n");
    while (it.next()) |line| {
        // Split each line by space
        if (line.len == 0) {
            continue;
        }

        var parts = std.mem.splitSequence(u8, line, "   ");
        if (parts.next()) |num| {
            const left_num = try std.fmt.parseInt(i32, num, 10);
            try left.append(left_num);
        }
        if (parts.next()) |num| {
            const right_num = try std.fmt.parseInt(i32, num, 10);
            try right.append(right_num);
        }
    }

    // Ensure the lists are the same length
    if (left.items.len != right.items.len) {
        return AocError.UnequalLength;
    }

    // Sort the lists
    std.mem.sort(i32, left.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, right.items, {}, comptime std.sort.asc(i32));

    var sum: u32 = 0;
    for (0..left.items.len) |i| {
        // std.debug.print("{d} {d}\n", .{ left.items[i], right.items[i] });
        const d = @abs(left.items[i] - right.items[i]);
        sum += d;
    }

    return sum;
}

fn part2(input: []const u8) !u32 {
    const alloc = std.heap.page_allocator;

    var left = ArrayList(u32).init(alloc);
    var right = AutoHashMap(u32, u32).init(alloc);

    defer left.deinit();
    defer right.deinit();

    // Split by lines
    var it = std.mem.splitAny(u8, input, "\n");
    while (it.next()) |line| {
        // Split each line by space
        if (line.len == 0) {
            continue;
        }

        var parts = std.mem.splitSequence(u8, line, "   ");
        if (parts.next()) |num| {
            const left_num = try std.fmt.parseInt(u32, num, 10);
            try left.append(left_num);
        }
        if (parts.next()) |num| {
            const right_num = try std.fmt.parseInt(u32, num, 10);
            const entry = try right.getOrPut(right_num);
            if (entry.found_existing) {
                entry.value_ptr.* += 1;
            } else {
                entry.value_ptr.* = 1;
            }
        }
    }

    var sum: u32 = 0;

    for (left.items) |left_num| {
        const count = right.get(left_num) orelse 0;
        sum += left_num * count;
    }
    return sum;
}

const example =
    \\3   4
    \\4   3
    \\2   5
    \\1   3
    \\3   9
    \\3   3
;

test "part1 example" {
    const input = example;

    const result = try part1(input);

    // std.debug.print("result: {d}\n", .{result});
    try expect(result == 11);
}

test "part1 actual" {
    const alloc = std.heap.page_allocator;
    const input = try aoc.getData(alloc, 2024, 1);

    const result = try part1(input);

    // std.debug.print("result: {d}\n", .{result});
    try expect(result == 2904518);
}

test "part2 example" {
    const input = example;
    const result = try part2(input);

    std.debug.print("result: {d}\n", .{result});
    try expect(result == 31);
}

test "part2 actual" {
    const alloc = std.heap.page_allocator;
    const input = try aoc.getData(alloc, 2024, 1);

    const result = try part2(input);

    std.debug.print("result: {d}\n", .{result});
    try expect(result == 18650129);
}
