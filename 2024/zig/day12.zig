const aoc = @import("aoc.zig");
const std = @import("std");
const containers = @import("containers.zig");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;
const AutoHashMap = std.AutoHashMap;
const ArrayList = std.ArrayList;

const Offset = containers.Point(isize);
const HashGrid = containers.HashGrid(isize, u8);
const Point = HashGrid.PointType;
const Points = ArrayList(Point);

fn parseGrid(data: []const u8) !HashGrid {
    var g = HashGrid.init(alloc);

    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();

    for (lines.items, 0..) |line, y| {
        if (line.len == 0) {
            continue;
        }
        for (line, 0..) |c, x| {
            try g.set(.{ .x = @intCast(x), .y = @intCast(y) }, c);
        }
    }

    return g;
}

const Directions = [_]containers.Point(isize){
    .{ .x = -1, .y = 0 },
    .{ .x = 1, .y = 0 },
    .{ .x = 0, .y = -1 },
    .{ .x = 0, .y = 1 },
};

const Region = struct {
    plant: u8,
    positions: ArrayList(Point),

    const Self = @This();

    fn init(p: u8) Self {
        return .{
            .plant = p,
            .positions = Points.init(alloc),
        };
    }

    fn deinit(self: *Self) void {
        self.positions.deinit();
    }

    fn cost(self: *const Self, g: HashGrid) usize {
        const area = self.positions.items.len;
        var perimeter: usize = 0;

        for (self.positions.items) |p| {
            // Check neighbours
            for (Directions) |d| {
                const np = Point{ .x = p.x + d.x, .y = p.y + d.y };
                if (g.get(np) != self.plant) {
                    perimeter += 1;
                }
            }
        }
        return area * perimeter;
    }

    fn bulkCost(self: *const Self, g: HashGrid) usize {
        const area = self.positions.items.len;
        var corners: usize = 0;

        for (self.positions.items) |p| {
            corners += countCorners(p, g);
        }
        return area * corners;
    }
};

const Regions = struct {
    by_plant: AutoHashMap(u8, ArrayList(Region)),
    by_position: AutoHashMap(Point, *Region),

    const Self = @This();

    fn init() Self {
        return .{
            .by_plant = AutoHashMap(u8, ArrayList(Region)).init(alloc),
            .by_position = AutoHashMap(Point, *Region).init(alloc),
        };
    }

    fn deinit(self: *Self) void {
        var iter = self.by_plant.valueIterator();
        while (iter.next()) |regions| {
            for (0..regions.items.len) |i| {
                var region = regions.items[i];
                region.deinit();
            }
            regions.deinit();
        }
        self.by_plant.deinit();
        self.by_position.deinit();
    }

    fn addRegion(self: *Self, plant: u8, region: Region) !void {
        var e = try self.by_plant.getOrPut(plant);
        if (!e.found_existing) {
            e.value_ptr.* = ArrayList(Region).init(alloc);
        }
        try e.value_ptr.*.append(region);

        const region_ptr = &e.value_ptr.items[e.value_ptr.items.len - 1];

        for (region.positions.items) |pos| {
            try self.by_position.put(pos, region_ptr);
        }
    }
};

fn exploreRegion(g: HashGrid, plant: u8, pos: Point) !Region {
    var result = Region.init(plant);

    var to_visit = ArrayList(Point).init(alloc);
    defer to_visit.deinit();
    var seen = AutoHashMap(Point, void).init(alloc);
    defer seen.deinit();

    try to_visit.append(pos);

    while (to_visit.items.len > 0) {
        const p = to_visit.pop();
        if (seen.get(p) != null) {
            continue;
        }
        try seen.put(p, {});

        const pl = g.get(p) orelse continue;
        if (pl != plant) {
            continue;
        }
        try result.positions.append(p);

        for (Directions) |d| {
            const np = Point{ .x = p.x + d.x, .y = p.y + d.y };
            try to_visit.append(np);
        }
    }

    return result;
}

fn getRegions(g: HashGrid) !Regions {
    var regions = Regions.init();

    for (0..@intCast(g.width)) |x| {
        for (0..@intCast(g.height)) |y| {
            const pos = Point{ .x = @intCast(x), .y = @intCast(y) };
            const plant = g.get(pos) orelse continue;
            // Skip positions we've already seen
            if (regions.by_position.get(pos) != null) {
                continue;
            }

            // DFS for connected plots
            const region = try exploreRegion(g, plant, pos);
            try regions.addRegion(plant, region);
        }
    }
    return regions;
}

fn countCorners(pos: Point, g: HashGrid) usize {
    // Offsets to two adjacent neighbours, and the diagonal neighbour
    const offsets = [_][3]Offset{
        .{ Offset{ .x = -1, .y = 0 }, Offset{ .x = 0, .y = -1 }, Offset{ .x = -1, .y = -1 } }, // Top left
        .{ Offset{ .x = 1, .y = 0 }, Offset{ .x = 0, .y = -1 }, Offset{ .x = 1, .y = -1 } }, // Top right
        .{ Offset{ .x = -1, .y = 0 }, Offset{ .x = 0, .y = 1 }, Offset{ .x = -1, .y = 1 } }, // Bottom left
        .{ Offset{ .x = 1, .y = 0 }, Offset{ .x = 0, .y = 1 }, Offset{ .x = 1, .y = 1 } }, // Bottom right
    };

    var corners: usize = 0;

    const plant = g.get(pos) orelse return 0;

    for (offsets) |offset| {
        const a1pos = Point{ .x = pos.x + offset[0].x, .y = pos.y + offset[0].y };
        const a2pos = Point{ .x = pos.x + offset[1].x, .y = pos.y + offset[1].y };
        const dpos = Point{ .x = pos.x + offset[2].x, .y = pos.y + offset[2].y };

        const a1 = g.get(a1pos);
        const a2 = g.get(a2pos);
        const d = g.get(dpos);

        if (a1 == plant and a2 == plant and d != plant) {
            corners += 1;
        } else if (a1 != plant and a2 != plant) {
            corners += 1;
        }
    }

    return corners;
}

fn part1(data: []const u8) !usize {
    var g = try parseGrid(data);
    defer g.deinit();

    var regions = try getRegions(g);
    defer regions.deinit();

    var iter = regions.by_plant.iterator();

    var cost: usize = 0;
    while (iter.next()) |e| {
        const region_list = e.value_ptr.*;
        for (region_list.items) |region| {
            cost += region.cost(g);
        }
    }
    return cost;
}

fn part2(data: []const u8) !usize {
    var g = try parseGrid(data);
    defer g.deinit();

    var regions = try getRegions(g);
    defer regions.deinit();

    var iter = regions.by_plant.iterator();

    var cost: usize = 0;
    while (iter.next()) |e| {
        const region_list = e.value_ptr.*;
        for (region_list.items) |region| {
            cost += region.bulkCost(g);
        }
    }
    return cost;
}

const example1 =
    \\AAAA
    \\BBCD
    \\BBCC
    \\EEEC
;

const example2 =
    \\OOOOO
    \\OXOXO
    \\OOOOO
    \\OXOXO
    \\OOOOO
;

const example3 =
    \\RRRRIICCFF
    \\RRRRIICCCF
    \\VVRRRCCFFF
    \\VVRCCCJFFF
    \\VVVVCJJCFE
    \\VVIVCCJJEE
    \\VVIIICJJEE
    \\MIIIIIJJEE
    \\MIIISIJEEE
    \\MMMISSJEEE
;

test "part1 example1" {
    try expect(140, try part1(example1));
}

test "part1 example2" {
    try expect(772, try part1(example2));
}

test "part1 example3" {
    try expect(1930, try part1(example3));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 12);
    defer alloc.free(data);

    try expect(1465112, try part1(data));
}

const example4 =
    \\EEEEE
    \\EXXXX
    \\EEEEE
    \\EXXXX
    \\EEEEE
;

const example5 =
    \\AAAAAA
    \\AAABBA
    \\AAABBA
    \\ABBAAA
    \\ABBAAA
    \\AAAAAA
;

test "part2 example1" {
    try expect(80, try part2(example1));
}

test "part2 example2" {
    try expect(436, try part2(example2));
}

test "part2 example4" {
    try expect(236, try part2(example4));
}

test "part2 example5" {
    try expect(368, try part2(example5));
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 12);
    defer alloc.free(data);
    try expect(893790, try part2(data));
}
