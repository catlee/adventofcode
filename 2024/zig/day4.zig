const aoc = @import("aoc.zig");
const std = @import("std");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;

const example =
    \\MMMSXXMASM
    \\MSAMXMSMSA
    \\AMXSXMAAMM
    \\MSAMASMSMX
    \\XMASAMXAMM
    \\XXAMMXXAMA
    \\SMSMSASXSS
    \\SAXAMASAAA
    \\MAMMMXMMMM
    \\MXMXAXMASX
;

fn find_xmas(input: [][]const u8, x: usize, y: usize) usize {
    const xmas = "XMAS";
    const deltas: [3]isize = .{ -1, 0, 1 };
    var count: usize = 0;
    for (deltas) |dx| {
        for (deltas) |dy| {
            if (dx == 0 and dy == 0) {
                continue;
            }
            var i: u16 = 0;
            while (i < xmas.len) : (i += 1) {
                const nx: isize = @as(isize, @intCast(x)) + dx * @as(isize, i);
                const ny: isize = @as(isize, @intCast(y)) + dy * @as(isize, i);
                if (nx < 0 or nx >= input.len) {
                    break;
                }
                if (ny < 0 or ny >= input[x].len) {
                    break;
                }
                if (input[@intCast(nx)][@intCast(ny)] != xmas[i]) {
                    break;
                }
            } else {
                count += 1;
            }
        }
    }
    return count;
}

fn part1(input: [][]const u8) usize {
    var count: usize = 0;
    for (0..input.len) |x| {
        for (0..input[x].len) |y| {
            count += find_xmas(input, x, y);
        }
    }
    return count;
}

fn find_x_mas(input: [][]const u8, x: usize, y: usize) bool {
    const d1: [2]u8 = .{ input[x - 1][y - 1], input[x + 1][y + 1] };
    const d2: [2]u8 = .{ input[x - 1][y + 1], input[x + 1][y - 1] };

    return (std.mem.eql(u8, &d1, "MS") or std.mem.eql(u8, &d1, "SM")) and
        (std.mem.eql(u8, &d2, "MS") or std.mem.eql(u8, &d2, "SM"));
}

fn part2(input: [][]const u8) usize {
    var count: usize = 0;
    for (1..input.len - 1) |x| {
        for (1..input[x].len - 1) |y| {
            if (input[x][y] == 'A' and find_x_mas(input, x, y)) {
                count += 1;
            }
        }
    }
    return count;
}

test "part1 example" {
    const lines = try aoc.splitLines(alloc, example);
    defer lines.deinit();
    try expect(18, part1(lines.items));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 4);
    defer alloc.free(data);

    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();
    try expect(2599, part1(lines.items));
}

test "part2 example" {
    const lines = try aoc.splitLines(alloc, example);
    defer lines.deinit();
    try expect(9, part2(lines.items));
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 4);
    defer alloc.free(data);

    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();
    try expect(1948, part2(lines.items));
}
