const aoc = @import("aoc.zig");
const std = @import("std");
const containers = @import("containers.zig");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;

const example =
    \\###############
    \\#...#...#.....#
    \\#.#.#.#.#.###.#
    \\#S#...#.#.#...#
    \\#######.#.#.###
    \\#######.#.#...#
    \\#######.#.###.#
    \\###..E#...#...#
    \\###.#######.###
    \\#...###...#...#
    \\#.#####.#.###.#
    \\#.#...#.#.#...#
    \\#.#.#.#.#.#.###
    \\#...#...#...###
    \\###############
;

const Point = struct {
    x: usize,
    y: usize,
};

const Offset = struct {
    dx: isize,
    dy: isize,
};

const Directions = [4]Offset{
    .{ .dx = 0, .dy = -1 },
    .{ .dx = 0, .dy = 1 },
    .{ .dx = -1, .dy = 0 },
    .{ .dx = 1, .dy = 0 },
};

const Grid = struct {
    width: usize,
    height: usize,
    data: []u8,
    distance: []usize,

    fn init(width: usize, height: usize) !Grid {
        const data = try alloc.alloc(u8, width * height);
        const distance = try alloc.alloc(usize, width * height);
        @memset(data, 0);
        @memset(distance, 0);
        return Grid{ .width = width, .height = height, .data = data, .distance = distance };
    }

    fn parse(data: []const u8) !Grid {
        const lines = try aoc.splitLines(alloc, data);
        defer lines.deinit();

        var grid = try Grid.init(lines.items[0].len, lines.items.len);

        for (lines.items, 0..) |line, y| {
            for (line, 0..) |c, x| {
                grid.setData(.{ .x = x, .y = y }, c);
            }
        }

        return grid;
    }

    fn deinit(self: *Grid) void {
        alloc.free(self.data);
        alloc.free(self.distance);
    }

    fn offset(self: *const Grid, p: Point) usize {
        return p.y * self.width + p.x;
    }

    fn getData(self: *const Grid, p: Point) u8 {
        return self.data[self.offset(p)];
    }

    fn setData(self: *Grid, p: Point, value: u8) void {
        self.data[self.offset(p)] = value;
    }

    fn getDistance(self: *const Grid, p: Point) usize {
        return self.distance[self.offset(p)];
    }

    fn setDistance(self: *Grid, p: Point, value: usize) void {
        self.distance[self.offset(p)] = value;
    }

    fn offsetPoint(self: *const Grid, p: Point, o: Offset) ?Point {
        const nx: isize = @as(isize, @intCast(p.x)) + o.dx;
        const ny: isize = @as(isize, @intCast(p.y)) + o.dy;
        if (nx < 0 or ny < 0 or nx >= self.width or ny >= self.height) {
            return null;
        }
        return .{ .x = @intCast(nx), .y = @intCast(ny) };
    }

    fn findChar(self: *const Grid, c: u8) ?Point {
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                if (self.getData(.{ .x = x, .y = y }) == c) {
                    return .{ .x = x, .y = y };
                }
            }
        }
        return null;
    }

    // Fills self.distance with how far from p each empty square is
    fn populateDistance(self: *Grid, p: Point) !void {
        const Item = struct {
            pos: Point,

            fn compare(g: *const Grid, a: @This(), b: @This()) std.math.Order {
                const da = g.getDistance(a.pos);
                const db = g.getDistance(b.pos);
                return std.math.order(db, da);
            }
        };
        var queue = std.PriorityQueue(Item, *const Grid, Item.compare).init(alloc, self);
        defer queue.deinit();
        try queue.add(Item{ .pos = p });

        while (queue.count() > 0) {
            const item = queue.remove();

            for (Directions) |o| {
                if (self.offsetPoint(item.pos, o)) |next| {
                    if (self.getData(next) == '.' and self.getDistance(next) == 0 and !std.meta.eql(next, p)) {
                        self.setDistance(next, self.getDistance(item.pos) + 1);
                        try queue.add(Item{ .pos = next });
                    }
                }
            }
        }
    }

    fn print(self: *const Grid) void {
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                const p: Point = .{ .x = x, .y = y };
                const c = self.getData(p);
                if (c == '.') {
                    const d = self.getDistance(p);
                    std.debug.print("{d}", .{d % 10});
                } else {
                    std.debug.print("{c}", .{c});
                }
            }
            std.debug.print("\n", .{});
        }
    }
};

fn part1(data: []const u8, min_cheat_time: usize) !usize {
    var grid = try Grid.parse(data);
    defer grid.deinit();

    const start = grid.findChar('S') orelse unreachable;
    grid.setData(.{ .x = start.x, .y = start.y }, '.');
    const end = grid.findChar('E') orelse unreachable;
    grid.setData(.{ .x = end.x, .y = end.y }, '.');

    try grid.populateDistance(end);

    const start_to_end = grid.getDistance(start);

    var cheat_distance = std.ArrayList(usize).init(alloc);
    defer cheat_distance.deinit();

    for (1..grid.width - 1) |x| {
        for (1..grid.height - 1) |y| {
            const p: Point = .{ .x = x, .y = y };
            if (grid.getData(p) != '.') continue;
            for (Directions) |dir| {
                const o: Offset = .{ .dx = dir.dx * 2, .dy = dir.dy * 2 };
                if (grid.offsetPoint(p, o)) |next| {
                    if (grid.getData(next) == '.') {
                        const start_to_p = start_to_end - grid.getDistance(p);
                        const shortcut = grid.getDistance(next) + 2 + start_to_p;
                        if (shortcut <= start_to_end - min_cheat_time) {
                            try cheat_distance.append(shortcut);
                        }
                    }
                }
            }
        }
    }

    return cheat_distance.items.len;
}

fn part2(data: []const u8, min_cheat_time: usize) !usize {
    var grid = try Grid.parse(data);
    defer grid.deinit();

    const start = grid.findChar('S') orelse unreachable;
    grid.setData(.{ .x = start.x, .y = start.y }, '.');
    const end = grid.findChar('E') orelse unreachable;
    grid.setData(.{ .x = end.x, .y = end.y }, '.');

    try grid.populateDistance(end);

    const start_to_end = grid.getDistance(start);

    var cheat_distances = std.ArrayList(usize).init(alloc);
    defer cheat_distances.deinit();

    for (1..grid.width - 1) |x| {
        for (1..grid.height - 1) |y| {
            const p: Point = .{ .x = x, .y = y };
            if (grid.getData(p) != '.') continue;
            const start_to_p = start_to_end - grid.getDistance(p);

            // Look from p up to 20 distance (manhatten) away
            // for a shortcut to the end
            for (0..21) |dx| {
                for (0..21) |dy| {
                    const offsets: [4]Offset = .{
                        .{ .dx = @intCast(dx), .dy = @intCast(dy) },
                        .{ .dx = @intCast(dx), .dy = -@as(isize, @intCast(dy)) },
                        .{ .dx = -@as(isize, @intCast(dx)), .dy = @intCast(dy) },
                        .{ .dx = -@as(isize, @intCast(dx)), .dy = -@as(isize, @intCast(dy)) },
                    };

                    for (offsets, 0..) |o, oi| {
                        const cheat_distance = @abs(o.dx) + @abs(o.dy);
                        if (cheat_distance > 20 or cheat_distance == 0) continue;
                        if (o.dy == 0 and (oi == 1 or oi == 3)) continue;
                        if (o.dx == 0 and (oi == 2 or oi == 3)) continue;
                        if (grid.offsetPoint(p, o)) |next| {
                            if (grid.getData(next) == '.') {
                                // We can take a shortcut from p to next, taking less than 20 picoseconds
                                const shortcut = grid.getDistance(next) + cheat_distance + start_to_p;
                                if (shortcut <= start_to_end - min_cheat_time) {
                                    try cheat_distances.append(shortcut);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return cheat_distances.items.len;
}

test "part1 example" {
    try expect(5, try part1(example, 20));
    try expect(2, try part1(example, 40));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 20);
    defer alloc.free(data);

    try expect(1332, try part1(data, 100));
}

test "part2 example" {
    try expect(7, try part2(example, 74));
    try expect(41, try part2(example, 70));
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 20);
    defer alloc.free(data);

    try expect(987695, try part2(data, 100));
}
