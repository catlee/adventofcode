const aoc = @import("aoc.zig");
const std = @import("std");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;

const example =
    \\............
    \\........0...
    \\.....0......
    \\.......0....
    \\....0.......
    \\......A.....
    \\............
    \\............
    \\........A...
    \\.........A..
    \\............
    \\............
;

const Antennas = struct {
    width: usize = 0,
    height: usize = 0,
    antennaPositions: std.AutoHashMap(u8, std.ArrayList(aoc.Point)),
    grid: std.AutoHashMap(aoc.Point, std.ArrayList(u8)),

    const Self = @This();

    fn init(allocator: std.mem.Allocator) !Self {
        return .{
            .antennaPositions = std.AutoHashMap(u8, std.ArrayList(aoc.Point)).init(allocator),
            .grid = std.AutoHashMap(aoc.Point, std.ArrayList(u8)).init(allocator),
        };
    }

    fn deinit(self: *Self) void {
        {
            var it = self.antennaPositions.valueIterator();
            while (it.next()) |entry| {
                entry.deinit();
            }
        }
        {
            var it = self.grid.valueIterator();
            while (it.next()) |entry| {
                entry.deinit();
            }
        }
        self.grid.deinit();
        self.antennaPositions.deinit();
    }
};

fn getAntennaLocations(input: []const u8) !Antennas {
    var antennas = try Antennas.init(alloc);
    const lines = try aoc.splitLines(alloc, input);
    defer lines.deinit();
    // print("lines: {}\n", .{lines});
    antennas.width = lines.items[0].len;
    antennas.height = 0;
    for (lines.items, 0..) |line, y| {
        if (line.len > 0) {
            antennas.height += 1;
        }
        for (line, 0..) |c, x| {
            const p: aoc.Point = .{ .x = @intCast(x), .y = @intCast(y) };
            {
                var e = try antennas.grid.getOrPut(p);
                if (!e.found_existing) {
                    e.value_ptr.* = std.ArrayList(u8).init(alloc);
                }
                try e.value_ptr.append(c);
            }
            if (c != '.') {
                var e = try antennas.antennaPositions.getOrPut(c);
                if (!e.found_existing) {
                    e.value_ptr.* = std.ArrayList(aoc.Point).init(alloc);
                }
                try e.value_ptr.append(p);
            }
        }
    }
    return antennas;
}

fn calculateAntiNodes(antennas: Antennas) !aoc.HashGrid {
    var antiNodes = aoc.HashGrid.init(alloc);

    const top_left: aoc.Point = .{ .x = 0, .y = 0 };
    const bottom_right: aoc.Point = .{ .x = @intCast(antennas.width - 1), .y = @intCast(antennas.height - 1) };

    // For each antenna type, work by pairs
    var antennaIt = antennas.antennaPositions.iterator();
    while (antennaIt.next()) |e| {
        for (0..e.value_ptr.items.len - 1) |i| {
            for (i + 1..e.value_ptr.items.len) |j| {
                const p1 = e.value_ptr.items[i];
                const p2 = e.value_ptr.items[j];
                // print("Comparing postitions for antenna {c}: {} {}\n", .{ e.key_ptr.*, p1, p2 });
                const dx = p2.x - p1.x;
                const dy = p2.y - p1.y;
                const a1: aoc.Point = .{ .x = p1.x - dx, .y = p1.y - dy };
                const a2: aoc.Point = .{ .x = p2.x + dx, .y = p2.y + dy };
                if (a1.isInside(top_left, bottom_right)) {
                    try antiNodes.set(a1, '#');
                }
                if (a2.isInside(top_left, bottom_right)) {
                    try antiNodes.set(a2, '#');
                }
            }
        }
    }

    return antiNodes;
}

fn calculateAntiNodes2(antennas: Antennas) !aoc.HashGrid {
    var antiNodes = aoc.HashGrid.init(alloc);

    const top_left: aoc.Point = .{ .x = 0, .y = 0 };
    const bottom_right: aoc.Point = .{ .x = @intCast(antennas.width - 1), .y = @intCast(antennas.height - 1) };

    // For each antenna type, work by pairs
    var antennaIt = antennas.antennaPositions.iterator();
    while (antennaIt.next()) |e| {
        for (0..e.value_ptr.items.len - 1) |i| {
            for (i + 1..e.value_ptr.items.len) |j| {
                const p1 = e.value_ptr.items[i];
                const p2 = e.value_ptr.items[j];
                const dx = p2.x - p1.x;
                const dy = p2.y - p1.y;

                var a1: aoc.Point = p2;
                while (a1.isInside(top_left, bottom_right)) {
                    try antiNodes.set(a1, '#');
                    a1.x -= dx;
                    a1.y -= dy;
                }
                var a2: aoc.Point = p1;
                while (a2.isInside(top_left, bottom_right)) {
                    try antiNodes.set(a2, '#');
                    a2.x += dx;
                    a2.y += dy;
                }
            }
        }
    }

    return antiNodes;
}

fn part1(input: []const u8) !usize {
    var antennas = try getAntennaLocations(input);
    defer antennas.deinit();

    var antiNodes = try calculateAntiNodes(antennas);
    defer antiNodes.deinit();

    return antiNodes.points.count();
}

fn part2(input: []const u8) !usize {
    var antennas = try getAntennaLocations(input);
    defer antennas.deinit();

    var antiNodes = try calculateAntiNodes2(antennas);
    defer antiNodes.deinit();

    return antiNodes.points.count();
}

test "part 1 example" {
    try expect(14, try part1(example));
}

test "part 1 actual" {
    const data = try aoc.getData(alloc, 2024, 8);
    defer alloc.free(data);
    try expect(299, try part1(data));
}

test "part 2 example" {
    try expect(34, try part2(example));
}

test "part 2 actual" {
    const data = try aoc.getData(alloc, 2024, 8);
    defer alloc.free(data);
    try expect(1032, try part2(data));
}
