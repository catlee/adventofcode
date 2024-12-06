const aoc = @import("aoc.zig");
const std = @import("std");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;
// const alloc = std.heap.page_allocator;

const Rule = struct {
    before: i16,
    after: i16,
};

const example =
    \\47|53
    \\97|13
    \\97|61
    \\97|47
    \\75|29
    \\61|13
    \\75|53
    \\29|13
    \\97|29
    \\53|29
    \\61|53
    \\97|53
    \\61|29
    \\47|13
    \\75|47
    \\97|75
    \\47|61
    \\75|61
    \\47|29
    \\75|13
    \\53|13
    \\
    \\75,47,61,53,29
    \\97,61,53,29,13
    \\75,29,13
    \\75,97,47,61,53
    \\61,13,29
    \\97,13,75,29,47
;

fn is_valid(update: []const i16, rules: std.AutoHashMap(i16, std.ArrayList(i16))) bool {
    for (0..update.len - 1) |i| {
        for (i + 1..update.len) |j| {
            const e = rules.get(update[j]) orelse continue;
            for (e.items) |after| {
                if (after == update[i]) {
                    return false;
                }
            }
        }
    }
    return true;
}

const PrintQueue = struct {
    rules: std.AutoHashMap(i16, std.ArrayList(i16)),
    updates: std.ArrayList(std.ArrayList(i16)),

    fn parse(a: std.mem.Allocator, data: []const u8) !@This() {
        const lines = try aoc.splitLines(a, data);
        defer lines.deinit();

        var rules = std.AutoHashMap(i16, std.ArrayList(i16)).init(a);

        var updates = std.ArrayList(std.ArrayList(i16)).init(a);

        var capturingRules = true;
        for (lines.items) |line| {
            if (line.len == 0) {
                capturingRules = false;
                continue;
            }

            if (capturingRules) {
                var parts = std.mem.splitScalar(u8, line, '|');
                if (parts.next()) |before_str| {
                    if (parts.next()) |after_str| {
                        const before = try std.fmt.parseInt(i16, before_str, 10);
                        const after = try std.fmt.parseInt(i16, after_str, 10);
                        var entry = try rules.getOrPut(before);
                        if (!entry.found_existing) {
                            entry.value_ptr.* = std.ArrayList(i16).init(a);
                        }
                        try entry.value_ptr.append(after);
                    }
                }
            } else {
                var parts = std.mem.splitScalar(u8, line, ',');
                var update = std.ArrayList(i16).init(a);

                while (parts.next()) |s| {
                    const n = try std.fmt.parseInt(i16, s, 10);
                    try update.append(n);
                }

                try updates.append(update);
            }
        }
        return .{ .rules = rules, .updates = updates };
    }

    fn deinit(self: *@This()) void {
        for (self.updates.items) |update| {
            update.deinit();
        }
        self.updates.deinit();
        var iter = self.rules.valueIterator();
        while (iter.next()) |value| {
            value.deinit();
        }
        self.rules.deinit();
    }
};

fn part1(data: []const u8) !usize {
    var pq = try PrintQueue.parse(alloc, data);
    defer pq.deinit();

    var sum: i16 = 0;
    for (pq.updates.items) |update| {
        if (is_valid(update.items, pq.rules)) {
            sum += update.items[(update.items.len - 1) / 2];
        }
    }

    return @intCast(sum);
}

test "part1 example" {
    try expect(143, try part1(example));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 5);
    defer alloc.free(data);
    try expect(5651, try part1(data));
}

fn sortFunc(ctx: Context, a: i16, b: i16) bool {
    if (ctx.rules.get(a)) |e| {
        for (e.items) |after| {
            if (after == b) {
                return true;
            }
        }
    }
    return false;
}

const Context = struct {
    rules: std.AutoHashMap(i16, std.ArrayList(i16)),
};

fn part2(data: []const u8) !usize {
    var pq = try PrintQueue.parse(alloc, data);
    defer pq.deinit();

    var sum: i16 = 0;
    for (pq.updates.items) |update| {
        if (!is_valid(update.items, pq.rules)) {
            // Sort update.items
            const ctx: Context = .{ .rules = pq.rules };
            std.mem.sort(i16, update.items, ctx, sortFunc);
            sum += update.items[(update.items.len - 1) / 2];
        }
    }
    return @intCast(sum);
}

test "part2 example" {
    try expect(123, try part2(example));
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 5);
    defer alloc.free(data);
    try expect(4743, try part2(data));
}
