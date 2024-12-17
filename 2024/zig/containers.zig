const std = @import("std");
const expect = std.testing.expect;

pub fn Point(K: type) type {
    return struct {
        x: K,
        y: K,
        const T = K;
        const Self = @This();

        pub fn isInside(self: *const Self, b: Box(K)) bool {
            return self.x >= b.top_left.x and self.x <= b.bottom_right.x and self.y >= b.top_left.y and self.y <= b.bottom_right.y;
        }

        pub fn add(self: *const Self, other: Self) Self {
            return .{ .x = self.x + other.x, .y = self.y + other.y };
        }
    };
}

pub fn Box(K: type) type {
    return struct {
        top_left: Point(K),
        bottom_right: Point(K),
        const T = K;
    };
}

pub fn HashGrid(P: type, K: type) type {
    return struct {
        allocator: std.mem.Allocator,
        grid: std.AutoHashMap(PointType, K),

        left: P = undefined,
        right: P = undefined,
        top: P = undefined,
        bottom: P = undefined,
        width: P = undefined,
        height: P = undefined,

        pub const DataType = K;
        pub const PointType = Point(P);
        const Self = @This();

        pub fn init(allocator: std.mem.Allocator) Self {
            const grid = std.AutoHashMap(PointType, K).init(allocator);
            return .{ .allocator = allocator, .grid = grid };
        }

        pub fn deinit(self: *Self) void {
            self.grid.deinit();
        }

        pub fn set(self: *Self, p: PointType, v: K) !void {
            try self.grid.put(p, v);
            if (self.grid.count() == 1) {
                self.left = p.x;
                self.right = p.x;
                self.top = p.y;
                self.bottom = p.y;
                self.width = 1;
                self.height = 1;
            } else {
                self.left = std.mem.min(P, &[_]P{ p.x, self.left });
                self.right = std.mem.max(P, &[_]P{ p.x, self.right });
                self.bottom = std.mem.min(P, &[_]P{ p.y, self.bottom });
                self.top = std.mem.max(P, &[_]P{ p.y, self.top });
                self.width = (self.right - self.left) + 1;
                self.height = (self.top - self.bottom) + 1;
            }
        }

        pub fn get(self: *const Self, p: PointType) ?K {
            return self.grid.get(p);
        }

        pub fn unset(self: *Self, p: PointType) void {
            _ = self.grid.remove(p);
        }
    };
}

test "hash grid" {
    const alloc = std.testing.allocator;
    var g = HashGrid(u8, isize).init(alloc);
    defer g.deinit();

    try g.set(.{ .x = 0, .y = 0 }, 1);
    try expect(g.get(.{ .x = 0, .y = 0 }) == 1);
}

test "point and box" {
    const p = Point(isize){ .x = 0, .y = 0 };
    const b = Box(isize){ .top_left = p, .bottom_right = p };
    try expect(p.isInside(b));
}
