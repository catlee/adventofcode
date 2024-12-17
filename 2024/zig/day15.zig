const aoc = @import("aoc.zig");
const std = @import("std");
const containers = @import("containers.zig");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;
const ArrayList = std.ArrayList;

const example1 =
    \\########
    \\#..O.O.#
    \\##@.O..#
    \\#...O..#
    \\#.#.O..#
    \\#...O..#
    \\#......#
    \\########
    \\
    \\<^^>>>vv<v>>v<<
;

const example2 =
    \\##########
    \\#..O..O.O#
    \\#......O.#
    \\#.OO..O.O#
    \\#..O@..O.#
    \\#O#..O...#
    \\#O..O..O.#
    \\#.OO.O.OO#
    \\#....O...#
    \\##########
    \\
    \\<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
    \\vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
    \\><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
    \\<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
    \\^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
    \\^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
    \\>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
    \\<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
    \\^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
    \\v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
;

const Warehouse = struct {
    const HashGrid = containers.HashGrid(isize, void);
    const Point = containers.Point(isize);
    const Points = ArrayList(Point);

    walls: HashGrid,
    boxes: containers.HashGrid(isize, u8),
    robot: Point,
    directions: []const u8,
    box_width: isize = 1,

    const Self = @This();

    fn init() Self {
        return Self{
            .walls = HashGrid.init(alloc),
            .boxes = containers.HashGrid(isize, u8).init(alloc),
            .robot = undefined,
            .directions = undefined,
            .box_width = 1,
        };
    }

    fn deinit(self: *Self) void {
        self.walls.deinit();
        self.boxes.deinit();
    }

    fn parse(self: *Self, data: []const u8) !void {
        var parts_iter = std.mem.splitSequence(u8, data, "\n\n");

        const part = parts_iter.next() orelse unreachable;
        try self.parseGrid(part);

        self.directions = parts_iter.next() orelse unreachable;
    }

    fn parseGrid(self: *Self, data: []const u8) !void {
        var line_iter = std.mem.tokenizeScalar(u8, data, '\n');
        var line_num: isize = 0;
        while (line_iter.next()) |line| : (line_num += 1) {
            for (line, 0..) |c, x| {
                const p = Point{ .x = self.box_width * @as(isize, @intCast(x)), .y = line_num };
                switch (c) {
                    '#' => {
                        try self.walls.set(p, {});
                        if (self.box_width == 2) {
                            try self.walls.set(.{ .x = p.x + 1, .y = p.y }, {});
                        }
                    },
                    'O' => {
                        if (self.box_width == 1) {
                            try self.boxes.set(p, 'O');
                        } else {
                            try self.boxes.set(p, '[');
                            try self.boxes.set(.{ .x = p.x + 1, .y = p.y }, ']');
                        }
                    },
                    '@' => self.robot = p,
                    '.' => {},
                    else => unreachable,
                }
            }
        }
    }

    fn print(self: *const Self) void {
        for (0..@intCast(self.walls.height)) |y| {
            for (0..@intCast(self.walls.width)) |x| {
                const p = Point{ .x = @intCast(x), .y = @intCast(y) };
                if (self.walls.get(p) != null) {
                    std.debug.print("#", .{});
                } else if (self.boxes.get(p)) |c| {
                    std.debug.print("{c}", .{c});
                } else if (p.x == self.robot.x and p.y == self.robot.y) {
                    std.debug.print("@", .{});
                } else {
                    std.debug.print(".", .{});
                }
            }
            std.debug.print("\n", .{});
        }
    }

    fn run(self: *Self) !void {
        for (self.directions) |d| {
            try self.moveRobot(d);
        }
    }

    fn gpsSum(self: *Self) usize {
        var sum: usize = 0;
        var iter = self.boxes.grid.keyIterator();
        while (iter.next()) |p| {
            const box_type = self.boxes.get(p.*) orelse unreachable;
            if (box_type == 'O' or box_type == '[') {
                sum += @intCast(p.x + 100 * p.y);
            }
        }
        return sum;
    }

    fn moveRobot(self: *Self, d: u8) !void {
        const dir = switch (d) {
            '^' => Point{ .x = 0, .y = -1 },
            'v' => Point{ .x = 0, .y = 1 },
            '<' => Point{ .x = -1, .y = 0 },
            '>' => Point{ .x = 1, .y = 0 },
            '\n' => return,
            else => unreachable,
        };
        const next_pos = self.robot.add(dir);
        if (self.walls.get(next_pos) != null) {
            return;
        }
        // std.debug.print("Robot: {any}; move: {c}\n", .{ self.robot, d });
        var box_positions = Points.init(alloc);
        defer box_positions.deinit();
        try self.getBoxPositions(next_pos, dir, &box_positions);

        // std.debug.print("box_positions: {any}\n", .{box_positions.items});
        // self.print();
        // std.debug.print("\n\n", .{});

        // Check if all the next positions for boxes are not walls
        for (box_positions.items) |p| {
            const next_box_pos = p.add(dir);
            if (self.walls.get(next_box_pos) != null) {
                return;
            }
        }

        self.robot = next_pos;

        // std.mem.reverse(Point, box_positions.items);
        var to_move = std.AutoHashMap(Point, u8).init(alloc);
        defer to_move.deinit();

        for (box_positions.items) |p| {
            const next_box_pos = p.add(dir);
            const box = self.boxes.get(p) orelse unreachable;
            try to_move.put(next_box_pos, box);
            self.boxes.unset(p);
        }

        var iter = to_move.iterator();
        while (iter.next()) |e| {
            const p = e.key_ptr.*;
            const box = e.value_ptr.*;
            try self.boxes.set(p, box);
        }
    }

    // Collect the positions of all boxes connected in direction `dir`
    fn getBoxPositions(self: *Self, pos: Point, dir: Point, result: *Points) !void {
        for (result.items) |old_pos| {
            if (old_pos.x == pos.x and old_pos.y == pos.y) {
                return;
            }
        }

        const box_type = self.boxes.get(pos) orelse return;
        // std.debug.print("getBoxPositions: {any} {any} {c}\n", .{ pos, dir, box_type });

        try result.append(pos);

        switch (box_type) {
            'O' => {
                try self.getBoxPositions(pos.add(dir), dir, result);
            },
            '[' => {
                try result.append(pos.add(.{ .x = 1, .y = 0 }));
                try self.getBoxPositions(pos.add(dir), dir, result);
                try self.getBoxPositions(pos.add(dir).add(.{ .x = 1, .y = 0 }), dir, result);
            },
            ']' => {
                try result.append(pos.add(.{ .x = -1, .y = 0 }));
                try self.getBoxPositions(pos.add(dir), dir, result);
                try self.getBoxPositions(pos.add(dir).add(.{ .x = -1, .y = 0 }), dir, result);
            },
            else => {
                unreachable;
            },
        }
    }
};

fn part1(data: []const u8) !usize {
    var warehouse = Warehouse.init();
    defer warehouse.deinit();
    try warehouse.parse(data);

    try warehouse.run();

    return warehouse.gpsSum();
}

fn part2(data: []const u8) !usize {
    var warehouse = Warehouse.init();
    warehouse.box_width = 2;
    defer warehouse.deinit();
    try warehouse.parse(data);

    try warehouse.run();

    return warehouse.gpsSum();
}

test "part1 example1" {
    try expect(2028, try part1(example1));
}

test "part1 example2" {
    try expect(10092, try part1(example2));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 15);
    defer alloc.free(data);
    try expect(1517819, try part1(data));
}

test "part2 example2" {
    try expect(9021, try part2(example2));
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 15);
    defer alloc.free(data);
    try expect(1538862, try part2(data));
}
