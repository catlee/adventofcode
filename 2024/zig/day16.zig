const aoc = @import("aoc.zig");
const std = @import("std");
const containers = @import("containers.zig");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;
const Direction = aoc.Direction;

const Tile = enum {
    Wall,
    Empty,
};

const Point = @Vector(2, isize);
const Tiles = []Tile;
const Reindeer = struct {
    pos: Point,
    direction: Direction,
};

const Directions = [4]Point{
    Point{ 0, -1 },
    Point{ 1, 0 },
    Point{ 0, 1 },
    Point{ -1, 0 },
};

const Maze = struct {
    width: usize,
    height: usize,
    grid: Tiles,
    start: Point,
    end: Point,

    const Self = @This();

    fn set(self: *Self, pos: Point, t: Tile) void {
        self.grid[@as(usize, @intCast(pos[0])) + @as(usize, @intCast(pos[1])) * self.width] = t;
    }

    fn get(self: *const Self, pos: Point) Tile {
        return self.grid[@as(usize, @intCast(pos[0])) + @as(usize, @intCast(pos[1])) * self.width];
    }

    fn deinit(self: *Self) void {
        alloc.free(self.grid);
    }

    fn parse(data: []const u8) !Self {
        const lines = try aoc.splitLines(alloc, data);
        defer lines.deinit();

        const width = lines.items[0].len;
        const height = lines.items.len;

        const grid = try alloc.alloc(Tile, @intCast(width * height));

        var maze = Self{
            .width = width,
            .height = height,
            .grid = grid,
            .start = undefined,
            .end = undefined,
        };

        for (lines.items, 0..) |line, y| {
            for (line, 0..) |c, x| {
                const p = Point{ @intCast(x), @intCast(y) };
                switch (c) {
                    'S' => {
                        maze.set(p, Tile.Empty);
                        maze.start = p;
                    },
                    'E' => {
                        maze.set(p, Tile.Empty);
                        maze.end = p;
                    },
                    '#' => maze.set(p, Tile.Wall),
                    '.' => maze.set(p, Tile.Empty),
                    else => unreachable,
                }
            }
        }

        return maze;
    }

    fn findBestPath(self: *Self) !struct { cost: usize, tiles: usize } {
        var arena = std.heap.ArenaAllocator.init(alloc);
        defer arena.deinit();
        const arena_allocator = arena.allocator();
        const TileSet = std.AutoHashMap(Point, void);

        const Item = struct {
            pos: Point,
            facing: isize,
            distance: usize,
            tiles: TileSet,

            fn compare(_: void, a: @This(), b: @This()) std.math.Order {
                return std.math.order(a.distance, b.distance);
            }
        };

        var queue = std.PriorityDequeue(Item, void, Item.compare).init(alloc, {});
        defer queue.deinit();

        try queue.add(.{ .pos = self.start, .facing = 1, .distance = 0, .tiles = TileSet.init(arena_allocator) });

        const SeenItem = struct { pos: Point, facing: isize };
        var seen = std.AutoHashMap(SeenItem, usize).init(alloc);
        defer seen.deinit();

        var best_cost: ?usize = null;
        var best_tiles = TileSet.init(arena_allocator);
        try best_tiles.put(self.start, {});

        while (queue.count() > 0) {
            const item = queue.removeMin();
            if (best_cost != null and item.distance > best_cost.?) {
                break;
            }
            if (std.meta.eql(item.pos, self.end)) {
                // print("Found end at with cost {d}\n", .{item.distance});
                if (best_cost != null) {
                    if (item.distance < best_cost.?) {
                        unreachable;
                    }
                }
                best_cost = item.distance;
                var key_iter = item.tiles.keyIterator();
                while (key_iter.next()) |pos_ptr| {
                    try best_tiles.put(pos_ptr.*, {});
                }
                continue;
            }
            const seen_item = SeenItem{ .pos = item.pos, .facing = item.facing };
            if (seen.get(seen_item)) |d| {
                if (d < item.distance) {
                    continue;
                }
            }
            try seen.put(seen_item, item.distance);

            for (Directions, 0..) |d, dv| {
                const next_pos = item.pos + d;
                if (self.get(next_pos) == Tile.Wall) {
                    continue;
                }
                const delta = @abs(item.facing - @as(isize, @intCast(dv)));
                const turn_cost: usize = switch (delta) {
                    0 => 0,
                    1, 3 => 1000,
                    2 => 2000,
                    else => unreachable,
                };
                var new_tiles = TileSet.init(arena_allocator);
                var key_iter = item.tiles.keyIterator();
                while (key_iter.next()) |pos_ptr| {
                    try new_tiles.put(pos_ptr.*, {});
                }
                try new_tiles.put(next_pos, {});
                try queue.add(.{ .pos = next_pos, .distance = item.distance + 1 + turn_cost, .facing = @intCast(dv), .tiles = new_tiles });
            }
        }

        // for (0..self.height) |y| {
        //     for (0..self.width) |x| {
        //         const p = Point{ @intCast(x), @intCast(y) };
        //         const t = self.get(p);
        //         if (best_tiles.get(p) != null) {
        //             std.debug.print("O", .{});
        //         } else {
        //             switch (t) {
        //                 Tile.Wall => std.debug.print("#", .{}),
        //                 Tile.Empty => std.debug.print(".", .{}),
        //             }
        //         }
        //     }
        //     std.debug.print("\n", .{});
        // }

        return .{ .cost = best_cost.?, .tiles = best_tiles.count() };
    }
};

const example1 =
    \\###############
    \\#.......#....E#
    \\#.#.###.#.###.#
    \\#.....#.#...#.#
    \\#.###.#####.#.#
    \\#.#.#.......#.#
    \\#.#.#####.###.#
    \\#...........#.#
    \\###.#.#####.#.#
    \\#...#.....#.#.#
    \\#.#.#.###.#.#.#
    \\#.....#...#.#.#
    \\#.###.#.#.#.#.#
    \\#S..#.....#...#
    \\###############
;

const example2 =
    \\#################
    \\#...#...#...#..E#
    \\#.#.#.#.#.#.#.#.#
    \\#.#.#.#...#...#.#
    \\#.#.#.#.###.#.#.#
    \\#...#.#.#.....#.#
    \\#.#.#.#.#.#####.#
    \\#.#...#.#.#.....#
    \\#.#.#####.#.###.#
    \\#.#.#.......#...#
    \\#.#.###.#####.###
    \\#.#.#...#.....#.#
    \\#.#.#.#####.###.#
    \\#.#.#.........#.#
    \\#.#.#.#########.#
    \\#S#.............#
    \\#################
;

fn part1(data: []const u8) !?usize {
    var maze = try Maze.parse(data);
    defer maze.deinit();

    return (try maze.findBestPath()).cost;
}

fn part2(data: []const u8) !?usize {
    var maze = try Maze.parse(data);
    defer maze.deinit();

    return (try maze.findBestPath()).tiles;
}

test "part1 example1" {
    try expect(7036, try part1(example1));
}

test "part1 example2" {
    try expect(11048, try part1(example2));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 16);
    defer alloc.free(data);
    try expect(107512, try part1(data));
}

test "part2 example1" {
    try expect(45, try part2(example1));
}

test "part2 example2" {
    try expect(64, try part2(example2));
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 16);
    defer alloc.free(data);
    try expect(561, try part2(data));
}
