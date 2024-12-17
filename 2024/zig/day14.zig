const aoc = @import("aoc.zig");
const std = @import("std");
const containers = @import("containers.zig");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;

const Robot = struct {
    pos: aoc.Point,
    vel: aoc.Point,
};

const Robots = std.ArrayList(Robot);

const Room = struct {
    width: isize,
    height: isize,
    robots: Robots,

    const Self = @This();

    fn init(w: isize, h: isize) Self {
        return Self{
            .width = w,
            .height = h,
            .robots = Robots.init(alloc),
        };
    }

    fn deinit(self: *Self) void {
        self.robots.deinit();
    }

    fn tick(self: *Self) void {
        for (self.robots.items, 0..) |robot, i| {
            self.robots.items[i].pos.x = @mod(robot.pos.x + robot.vel.x, self.width);
            self.robots.items[i].pos.y = @mod(robot.pos.y + robot.vel.y, self.height);
        }
    }

    fn count(self: *const Self, left: isize, right: isize, top: isize, bottom: isize) usize {
        const top_left = aoc.Point{ .x = left, .y = top };
        const bottom_right = aoc.Point{ .x = right, .y = bottom };
        const box = aoc.Box{ .top_left = top_left, .bottom_right = bottom_right };
        // print("top_left: {d}, {d}, bottom_right: {d}, {d}\n", .{ top_left.x, top_left.y, bottom_right.x, bottom_right.y });
        var c: usize = 0;
        for (self.robots.items) |robot| {
            if (robot.pos.isInside(box)) {
                c += 1;
            }
        }
        return c;
    }

    fn safetyFactor(self: *const Self) usize {
        var safety: usize = 0;
        safety = self.count(0, @divFloor(self.width - 1, 2) - 1, 0, @divFloor(self.height - 1, 2) - 1); // Top-left
        safety *= self.count(@divFloor(self.width - 1, 2) + 1, self.width, 0, @divFloor(self.height - 1, 2) - 1); // Top-right
        safety *= self.count(0, @divFloor(self.width - 1, 2) - 1, @divFloor(self.height - 1, 2) + 1, self.height); // Bottom-left
        safety *= self.count(@divFloor(self.width - 1, 2) + 1, self.width, @divFloor(self.height - 1, 2) + 1, self.height); // Bottom-right
        return safety;
    }

    fn parse(self: *Self, data: []const u8) !void {
        var lineIter = std.mem.tokenizeScalar(u8, data, '\n');
        line: while (lineIter.next()) |line| {
            var it = std.mem.tokenizeAny(u8, line, ",= ");
            var r: Robot = undefined;
            _ = it.next();
            r.pos.x = try std.fmt.parseInt(isize, it.next() orelse continue :line, 10);
            r.pos.y = try std.fmt.parseInt(isize, it.next() orelse continue :line, 10);
            _ = it.next();
            r.vel.x = try std.fmt.parseInt(isize, it.next() orelse continue :line, 10);
            r.vel.y = try std.fmt.parseInt(isize, it.next() orelse continue :line, 10);
            try self.robots.append(r);
        }
    }

    // Measure how many 3x3 tiles are empty
    fn entropy(self: *const Self) usize {
        var num_full: usize = 0;
        var x: isize = 0;
        while (x < self.width) : (x += 3) {
            var y: isize = 0;
            while (y < self.height) : (y += 3) {
                if (self.count(x, x + 2, y, y + 2) > 0) {
                    num_full += 1;
                }
            }
        }
        return num_full;
    }
};

const example =
    \\p=0,4 v=3,-3
    \\p=6,3 v=-1,-3
    \\p=10,3 v=-1,2
    \\p=2,0 v=2,-1
    \\p=0,0 v=1,3
    \\p=3,0 v=-2,-2
    \\p=7,6 v=-1,-3
    \\p=3,0 v=-1,-2
    \\p=9,3 v=2,3
    \\p=7,3 v=-1,2
    \\p=2,4 v=2,-3
    \\p=9,5 v=-3,-3
;

fn part1(data: []const u8, width: isize, height: isize) !usize {
    var room = Room.init(width, height);
    try room.parse(data);
    defer room.deinit();
    for (0..100) |_| {
        room.tick();
    }
    return room.safetyFactor();
}

test "part1 example" {
    try expect(12, try part1(example, 11, 7));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 14);
    defer alloc.free(data);
    try expect(221142636, try part1(data, 101, 103));
}

fn part2(data: []const u8, width: isize, height: isize) !usize {
    var room = Room.init(width, height);
    try room.parse(data);
    defer room.deinit();

    var tick: usize = 1;
    var least_entropy: usize = 100000;
    while (true) : (tick += 1) {
        room.tick();

        const e = room.entropy();
        if (e >= least_entropy) {
            continue;
        }

        least_entropy = e;

        print("tick: {d}; entropy: {d}\n", .{ tick, e });
        for (0..@intCast(height)) |y| {
            for (0..@intCast(width)) |x| {
                var num_robots: usize = 0;
                for (room.robots.items) |robot| {
                    if (robot.pos.x == x and robot.pos.y == y) {
                        num_robots += 1;
                    }
                }
                if (num_robots > 0) {
                    print("{d}", .{num_robots});
                } else {
                    print(".", .{});
                }
            }
            print("\n", .{});
        }
    }
    return room.safetyFactor();
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 14);
    defer alloc.free(data);
    _ = try part2(data, 101, 103);
}
