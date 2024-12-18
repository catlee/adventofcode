const aoc = @import("aoc.zig");
const std = @import("std");
const containers = @import("containers.zig");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;

const example =
    \\5,4
    \\4,2
    \\4,5
    \\3,0
    \\2,1
    \\6,3
    \\2,4
    \\1,5
    \\0,6
    \\3,3
    \\2,6
    \\5,1
    \\1,2
    \\5,5
    \\2,5
    \\6,5
    \\1,4
    \\0,4
    \\6,4
    \\1,1
    \\6,1
    \\1,0
    \\0,5
    \\1,6
    \\2,0
;

const Point = @Vector(2, u8);
const Points = std.ArrayList(Point);

fn parsePoints(data: []const u8) !Points {
    var iter = std.mem.tokenizeAny(u8, data, "\n,");
    var results = Points.init(alloc);
    while (true) {
        var point: Point = undefined;
        point[0] = try std.fmt.parseInt(u8, iter.next() orelse return results, 10);
        point[1] = try std.fmt.parseInt(u8, iter.next() orelse return results, 10);
        try results.append(point);
    }
    return results;
}

fn printGrid(size: comptime_int, grid: [size][size]u8) void {
    for (grid) |row| {
        for (row) |cell| {
            print("{c}", .{cell});
        }
        print("\n", .{});
    }
}

fn part1(points: Points, size: comptime_int, bytes: usize) !?usize {
    var grid: [size][size]u8 = .{.{'.'} ** size} ** size;

    for (0..bytes) |i| {
        const point = points.items[i];
        grid[point[0]][point[1]] = '#';
    }

    const end = Point{ size - 1, size - 1 };

    const Item = struct {
        pos: Point,
        distance: usize,
        fn compareFn(_: void, a: @This(), b: @This()) std.math.Order {
            return std.math.order(a.distance, b.distance);
        }
    };

    var queue = std.PriorityDequeue(Item, void, Item.compareFn).init(alloc, {});
    try queue.ensureTotalCapacity(size * size);
    defer queue.deinit();
    try queue.add(Item{ .pos = Point{ 0, 0 }, .distance = 0 });
    var seen = std.AutoHashMap(Point, void).init(alloc);
    try seen.ensureTotalCapacity(size * size);
    defer seen.deinit();

    while (queue.count() > 0) {
        const item = queue.removeMin();
        if (seen.contains(item.pos)) {
            continue;
        }
        try seen.put(item.pos, {});
        const x = item.pos[0];
        const y = item.pos[1];

        if (std.meta.eql(item.pos, end)) {
            return item.distance;
        }
        if (x > 0 and grid[x - 1][y] == '.') {
            try queue.add(Item{ .pos = Point{ x - 1, y }, .distance = item.distance + 1 });
        }
        if (x < size - 1 and grid[x + 1][y] == '.') {
            try queue.add(Item{ .pos = Point{ x + 1, y }, .distance = item.distance + 1 });
        }
        if (y > 0 and grid[x][y - 1] == '.') {
            try queue.add(Item{ .pos = Point{ x, y - 1 }, .distance = item.distance + 1 });
        }
        if (y < size - 1 and grid[x][y + 1] == '.') {
            try queue.add(Item{ .pos = Point{ x, y + 1 }, .distance = item.distance + 1 });
        }
    }

    return null;
}

test "part1 example" {
    var points = try parsePoints(example);
    defer points.deinit();

    try expect(22, try part1(points, 7, 12));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 18);
    defer alloc.free(data);
    var points = try parsePoints(data);
    defer points.deinit();
    try expect(454, try part1(points, 71, 1024));
}

fn part2(data: []const u8, size: comptime_int, start: usize) !?Point {
    var points = try parsePoints(data);
    defer points.deinit();
    var last_good: usize = start;
    var first_bad: usize = points.items.len - 1;
    while (true) {
        const guess = (last_good + first_bad) / 2;
        if (try part1(points, size, guess) == null) {
            first_bad = guess;
        } else {
            last_good = guess;
        }
        if (first_bad == last_good + 1) {
            return points.items[first_bad - 1];
        }
    }
}

test "part2 example" {
    const result = try part2(example, 7, 12);
    try std.testing.expectEqual(Point{ 6, 1 }, result);
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 18);
    defer alloc.free(data);
    const result = try part2(data, 71, 1024);
    try std.testing.expectEqual(Point{ 8, 51 }, result);
}
