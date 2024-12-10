const aoc = @import("aoc.zig");
const std = @import("std");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;

const example = "2333133121414131402";

const Range = struct {
    start: usize, // Inclusive
    end: usize, // Exclusive
    id: ?usize,

    fn empty(self: *const Range) bool {
        return self.id == null;
    }

    fn size(self: *const Range) usize {
        return self.end - self.start;
    }
};

const Ranges = struct {
    data: std.ArrayList(Range),
    alloc: std.mem.Allocator,

    const Self = @This();

    fn init(a: std.mem.Allocator) Self {
        return Self{
            .alloc = a,
            .data = std.ArrayList(Range).init(a),
        };
    }

    fn deinit(self: *Self) void {
        self.data.deinit();
    }

    fn append(self: *Self, r: Range) !void {
        try self.data.append(r);
    }

    fn findEmptyIndex(self: *const Self) ?usize {
        for (self.data.items, 0..) |r, i| {
            if (r.empty()) {
                return i;
            }
        }
        return null;
    }

    fn defragBlock(self: *Self) !bool {
        // Nowhere to put stuff
        const nextEmpty = self.findEmptyIndex() orelse return false;

        // Find last non-empty range
        var lastIndex = self.data.items.len - 1;
        var lastRange = &self.data.items[lastIndex];
        while (lastRange.empty()) : (lastIndex -= 1) {
            lastRange = &self.data.items[lastIndex];
        }
        if (nextEmpty > lastIndex) {
            return false;
        }

        // Shrink it by one
        lastRange.end -= 1;

        // Shrink the empty range
        var emptyRange = &self.data.items[nextEmpty];
        emptyRange.start += 1;

        // Insert a new range before the empty range
        const r = Range{
            .id = lastRange.id,
            .start = emptyRange.start - 1,
            .end = emptyRange.start,
        };

        try self.data.insert(nextEmpty, r);

        try self.normalize();
        return true;
    }

    fn normalize(self: *Self) !void {
        var i: usize = 0;
        while (i < self.data.items.len) {
            // Remove empty ranges
            if (self.data.items[i].size() == 0) {
                _ = self.data.orderedRemove(i);
                continue;
            }

            // Merge with the next range if it has the same id
            if (i < self.data.items.len - 1) {
                if (self.data.items[i].id == self.data.items[i + 1].id) {
                    (&self.data.items[i]).end = self.data.items[i + 1].end;
                    _ = self.data.orderedRemove(i + 1);
                }
            }

            i += 1;
        }
        return;
    }

    fn checkSum(self: *const Self) usize {
        var sum: usize = 0;
        for (self.data.items) |r| {
            if (r.id == null) {
                continue;
            }
            for (r.start..r.end) |i| {
                sum += i * r.id.?;
            }
        }
        return sum;
    }

    fn print(self: *const Self) void {
        for (self.data.items) |r| {
            for (r.start..r.end) |_| {
                if (r.id == null) {
                    std.debug.print(".", .{});
                } else {
                    std.debug.print("{?d}", .{r.id});
                }
            }
        }
        std.debug.print(" (next_empty: {?})\n", .{self.findEmptyIndex()});
    }

    fn defragFile(self: *Self, id: usize) !void {
        // Search for the range with this id
        var i = self.data.items.len - 1;
        while (self.data.items[i].id != id) : (i -= 1) {}
        var r = self.data.items[i];
        const n = r.size();

        // Search for the earliest empty range that's big enough
        var emptyIndex: usize = 0;
        while (emptyIndex < self.data.items.len) : (emptyIndex += 1) {
            if (self.data.items[emptyIndex].empty() and self.data.items[emptyIndex].size() >= n) {
                break;
            }
        } else {
            return;
        }

        if (emptyIndex > i) {
            return;
        }

        var emptyRange = &self.data.items[emptyIndex];
        r.start = emptyRange.start;
        r.end = r.start + n;

        emptyRange.start += n;

        _ = self.data.orderedRemove(i);
        try self.data.insert(emptyIndex, r);
        try self.normalize();
    }
};

fn diskMaptoRanges(disk_map: []const u8) !Ranges {
    var id: usize = 0;
    var i: usize = 0;
    var offset: usize = 0;
    var results = Ranges.init(alloc);
    while (i < disk_map.len) {
        if (disk_map[i] < '0') {
            i += 1;
            continue;
        }
        const d = disk_map[i] - '0';
        if (d == 0) {
            i += 1;
            continue;
        }
        var r = Range{
            .id = null,
            .start = offset,
            .end = offset + d,
        };
        if (i % 2 == 0) {
            r.id = id;
            id += 1;
        }
        offset += d;
        try results.append(r);
        i += 1;
    }
    return results;
}

fn part1(data: []const u8) !usize {
    var ranges = try diskMaptoRanges(data);
    defer ranges.deinit();

    while (try ranges.defragBlock()) {}

    return ranges.checkSum();
}

fn part2(data: []const u8) !usize {
    var ranges = try diskMaptoRanges(data);
    defer ranges.deinit();

    var id = ranges.data.items[ranges.data.items.len - 1].id.?;

    while (id >= 0) : (id -= 1) {
        try ranges.defragFile(id);
        if (id == 0) {
            break;
        }
    }

    return ranges.checkSum();
}

test "part 1 example" {
    try expect(1928, try part1(example));
    try expect(60, try part1("12345"));
}

test "part 1 actual" {
    const data = try aoc.getData(alloc, 2024, 9);
    defer alloc.free(data);
    try expect(6341711060162, try part1(data));
}

test "part 2 example" {
    try expect(2858, try part2(example));
}

test "part 2 actual" {
    const data = try aoc.getData(alloc, 2024, 9);
    defer alloc.free(data);
    try expect(6377400869326, try part2(data));
}
