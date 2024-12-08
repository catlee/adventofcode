const aoc = @import("aoc.zig");
const std = @import("std");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;

const Point = struct {
    x: isize,
    y: isize,
};

const Direction = enum {
    North,
    East,
    South,
    West,
};

const Guard = struct {
    pos: Point,
    facing: Direction,

    const Self = @This();

    fn turnRight(self: *Self) void {
        self.facing = @enumFromInt((@as(u8, @intFromEnum(self.facing)) + 1) % 4);
    }

    fn nextPos(self: *const Self) Point {
        switch (self.facing) {
            Direction.North => {
                return .{ .x = self.pos.x, .y = self.pos.y - 1 };
            },
            Direction.East => {
                return .{ .x = self.pos.x + 1, .y = self.pos.y };
            },
            Direction.South => {
                return .{ .x = self.pos.x, .y = self.pos.y + 1 };
            },
            Direction.West => {
                return .{ .x = self.pos.x - 1, .y = self.pos.y };
            },
        }
    }

    fn moveForward(self: *Self) void {
        // We consider North to be up on the screen, lower row number, so north is negative
        self.pos = self.nextPos();
    }
};

const HashGrid = struct {
    width: isize = undefined,
    height: isize = undefined,
    points: HashT,

    left: isize = undefined,
    right: isize = undefined,
    top: isize = undefined,
    bottom: isize = undefined,

    const Self = @This();
    const HashT = std.AutoHashMap(Point, u8);

    fn init(a: std.mem.Allocator) Self {
        return .{
            .points = HashT.init(a),
        };
    }

    fn deinit(self: *Self) void {
        self.points.deinit();
    }

    fn clone(self: *const Self) !Self {
        var newGrid = Self.init(self.points.allocator);
        var iter = self.points.iterator();
        while (iter.next()) |e| {
            try newGrid.set(e.key_ptr.*, e.value_ptr.*);
        }
        return newGrid;
    }

    fn set(self: *Self, p: Point, v: u8) !void {
        try self.points.put(p, v);
        if (self.points.count() == 1) {
            self.left = p.x;
            self.right = p.x;
            self.top = p.y;
            self.bottom = p.y;
            self.width = 1;
            self.height = 1;
        } else {
            self.left = std.mem.min(isize, &[_]isize{ p.x, self.left });
            self.right = std.mem.max(isize, &[_]isize{ p.x, self.right });
            self.bottom = std.mem.min(isize, &[_]isize{ p.y, self.bottom });
            self.top = std.mem.max(isize, &[_]isize{ p.y, self.top });
            self.width = (self.right - self.left) + 1;
            self.height = (self.top - self.bottom) + 1;
        }
    }

    fn get(self: *const Self, p: Point) ?u8 {
        return self.points.get(p);
    }

    fn isInside(self: *const Self, p: Point) bool {
        return p.x >= self.left and p.x <= self.right and p.y >= self.bottom and p.y <= self.top;
    }

    fn print(self: *const Self) void {
        var y: isize = self.bottom;
        while (y <= self.top) : (y += 1) {
            var x: isize = self.left;
            while (x <= self.right) : (x += 1) {
                const p = .{ .x = x, .y = y };
                const c = self.get(p);
                if (c != null) {
                    std.debug.print("{?c}", .{c});
                } else {
                    std.debug.print(".", .{});
                }
            }
            std.debug.print("\n", .{});
        }
    }
};

const example =
    \\....#.....
    \\.........#
    \\..........
    \\..#.......
    \\.......#..
    \\..........
    \\.#..^.....
    \\........#.
    \\#.........
    \\......#...
;

fn parse(input: []const u8) !struct { HashGrid, Guard } {
    const lines = try aoc.splitLines(alloc, input);
    defer lines.deinit();
    var g = HashGrid.init(alloc);

    var guard: Guard = undefined;

    for (lines.items, 0..) |line, y| {
        for (line, 0..) |c, x| {
            if (c == '^') {
                guard.pos = .{ .x = @intCast(x), .y = @intCast(y) };
                guard.facing = Direction.North;
                try g.set(.{ .x = @intCast(x), .y = @intCast(y) }, '.');
            }
            try g.set(.{ .x = @intCast(x), .y = @intCast(y) }, c);
        }
    }
    return .{ g, guard };
}

fn getVisited(grid: HashGrid, g: Guard) !std.AutoHashMap(Point, bool) {
    var guard = g;
    var visited = std.AutoHashMap(Point, bool).init(alloc);
    while (grid.isInside(guard.pos)) {
        try visited.put(guard.pos, true);
        var nextPos = guard.nextPos();
        while (grid.get(nextPos) == '#') {
            guard.turnRight();
            nextPos = guard.nextPos();
        }
        guard.moveForward();
    }
    return visited;
}

fn guardLoops(grid: HashGrid, g: Guard) !bool {
    var visited = std.AutoHashMap(Guard, bool).init(alloc);
    defer visited.deinit();
    var guard = g;
    while (grid.isInside(guard.pos)) {
        if (visited.get(guard) != null) {
            return true;
        }
        try visited.put(guard, true);
        var nextPos = guard.nextPos();
        while (grid.get(nextPos) == '#') {
            guard.turnRight();
            nextPos = guard.nextPos();
        }
        guard.moveForward();
    }
    return false;
}

fn printVisited(visited: std.AutoHashMap(Point, bool), g: HashGrid) !void {
    var grid = try g.clone();
    defer grid.deinit();

    var iter = visited.keyIterator();
    while (iter.next()) |pos| {
        try grid.set(pos.*, 'o');
    }
    grid.print();
}

fn part1(input: []const u8) !usize {
    const parsed = try parse(input);
    var grid = parsed[0];
    defer grid.deinit();
    const guard = parsed[1];

    var visited = try getVisited(grid, guard);
    defer visited.deinit();

    return visited.count();
}

fn part2(input: []const u8) !usize {
    const parsed = try parse(input);
    var grid = parsed[0];
    defer grid.deinit();
    const guard = parsed[1];
    const start = guard.pos;

    var visited = try getVisited(grid, guard);
    defer visited.deinit();

    var good_placements: usize = 0;

    var iter = visited.keyIterator();
    while (iter.next()) |pos| {
        if (std.meta.eql(pos.*, start)) {
            continue;
        }

        var new_grid = try grid.clone();
        try new_grid.set(pos.*, '#');
        defer new_grid.deinit();
        if (try guardLoops(new_grid, guard)) {
            good_placements += 1;
        }
    }
    return good_placements;
}

test "part1 example" {
    try expect(41, try part1(example));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 6);
    defer alloc.free(data);
    try expect(4602, try part1(data));
}

test "part2 example" {
    try expect(6, try part2(example));
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 6);
    defer alloc.free(data);
    try expect(1703, try part2(data));
}
