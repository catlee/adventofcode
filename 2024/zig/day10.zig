const aoc = @import("aoc.zig");
const std = @import("std");
const print = std.debug.print;
const expect = aoc.expect;
// const alloc = std.testing.allocator;
const alloc = std.heap.page_allocator;

fn parse(data: []const u8) !aoc.HashGrid {
    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();

    var g = aoc.HashGrid.init(alloc);

    for (lines.items, 0..) |line, y| {
        if (line.len == 0) {
            continue;
        }
        for (line, 0..) |c, x| {
            const p = aoc.Point{ .x = @intCast(x), .y = @intCast(y) };
            try g.set(p, c);
        }
    }

    return g;
}

const PointSet = std.AutoHashMap(aoc.Point, void);

const Directions = [_]aoc.Point{
    .{ .x = -1, .y = 0 },
    .{ .x = 1, .y = 0 },
    .{ .x = 0, .y = 1 },
    .{ .x = 0, .y = -1 },
};

fn findTrails(g: *const aoc.HashGrid, start: aoc.Point, results: *PointSet) !usize {
    const c = g.get(start) orelse return 0;

    var numPaths: usize = 0;

    for (Directions) |d| {
        const p = aoc.Point{ .x = start.x + d.x, .y = start.y + d.y };
        const cnext = g.get(p) orelse continue;
        if (cnext != c + 1) {
            continue;
        }
        if (cnext == '9') {
            try results.put(p, void{});
            numPaths += 1;
            continue;
        }
        numPaths += try findTrails(g, p, results);
    }
    return numPaths;
}

fn part1(data: []const u8) !usize {
    var g = try parse(data);
    defer g.deinit();

    var sum: usize = 0;
    for (0..@intCast(g.height)) |y| {
        for (0..@intCast(g.width)) |x| {
            const p = aoc.Point{ .x = @intCast(x), .y = @intCast(y) };
            if (g.get(p) == '0') {
                var results = PointSet.init(alloc);
                defer results.deinit();
                _ = try findTrails(&g, p, &results);
                sum += results.count();
            }
        }
    }
    return sum;
}

fn part2(data: []const u8) !usize {
    var g = try parse(data);
    defer g.deinit();

    var sum: usize = 0;
    for (0..@intCast(g.height)) |y| {
        for (0..@intCast(g.width)) |x| {
            const p = aoc.Point{ .x = @intCast(x), .y = @intCast(y) };
            if (g.get(p) == '0') {
                var results = PointSet.init(alloc);
                defer results.deinit();
                sum += try findTrails(&g, p, &results);
            }
        }
    }
    return sum;
}

const example =
    \\89010123
    \\78121874
    \\87430965
    \\96549874
    \\45678903
    \\32019012
    \\01329801
    \\10456732
;

test "part 1 example" {
    try expect(36, try part1(example));
}

test "part 1 actual" {
    const data = try aoc.getData(alloc, 2024, 10);
    defer alloc.free(data);
    try expect(531, try part1(data));
}

test "part 2 example" {
    try expect(81, try part2(example));
}

test "part 2 actual" {
    const data = try aoc.getData(alloc, 2024, 10);
    defer alloc.free(data);
    try expect(1210, try part2(data));
}
