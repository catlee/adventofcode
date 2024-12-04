const aoc = @import("aoc.zig");
const std = @import("std");
const print = std.debug.print;
const expect = aoc.expect;
const ArrayList = std.ArrayList;
const alloc = std.testing.allocator;

fn find_substr(needle: []const u8, haystack: []const u8, offset: usize) ?usize {
    if (needle.len == 0) {
        return null;
    }
    if (needle.len > haystack.len) {
        return null;
    }
    for (offset..haystack.len) |i| {
        for (needle, 0..) |needle_char, j| {
            if (i + j >= haystack.len) {
                break;
            }

            if (haystack[i + j] != needle_char) {
                break;
            }
        } else {
            return i;
        }
    }
    return null;
}

fn parse(s: []const u8) ?struct { a: usize, b: usize } {
    var a: usize = 0;
    var b: usize = 0;
    var i: usize = 0;
    while (s[i] != ',') {
        if (!std.ascii.isDigit(s[i])) {
            return null;
        }
        a = a * 10 + (s[i] - '0');
        i += 1;
        if (i >= s.len) {
            return null;
        }
    }
    i += 1;
    while (i < s.len) {
        if (!std.ascii.isDigit(s[i])) {
            return null;
        }
        b = b * 10 + (s[i] - '0');
        i += 1;
    }
    return .{ .a = a, .b = b };
}

fn part1(program: []const u8) !usize {
    var offset: ?usize = 0;
    var sum: usize = 0;
    while (true) {
        if (find_substr("mul(", program, offset.?)) |o| {
            if (find_substr(")", program, o)) |closing| {
                if (parse(program[o + 4 .. closing])) |numbers| {
                    sum += numbers.a * numbers.b;
                }
            }
            offset = o + 1;
        } else {
            break;
        }
    }
    return sum;
}

fn part2(program: []const u8) !usize {
    var offset: usize = 0;
    var sum: usize = 0;
    var disable_offset = find_substr("don't()", program, 0) orelse program.len;
    while (true) {
        if (find_substr("mul(", program, offset)) |o| {
            offset = o;
            if (offset > disable_offset) {
                offset = find_substr("do()", program, disable_offset) orelse program.len;
                disable_offset = find_substr("don't()", program, offset) orelse program.len;
            } else if (find_substr(")", program, offset)) |closing| {
                if (parse(program[offset + 4 .. closing])) |numbers| {
                    sum += numbers.a * numbers.b;
                }
                offset = offset + 1;
            }
        } else {
            break;
        }
    }
    return sum;
}

test "part1 example" {
    const example = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
    try expect(161, try part1(example));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 3);
    defer alloc.free(data);
    try expect(153469856, try part1(data));
}

test "part2 example" {
    const example = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";
    try expect(48, try part2(example));
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 3);
    defer alloc.free(data);
    try expect(77055967, try part2(data));
}
