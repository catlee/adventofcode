const aoc = @import("aoc.zig");
const std = @import("std");
const containers = @import("containers.zig");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;

const example =
    \\kh-tc
    \\qp-kh
    \\de-cg
    \\ka-co
    \\yn-aq
    \\qp-ub
    \\cg-tb
    \\vc-aq
    \\tb-ka
    \\wh-tc
    \\yn-cg
    \\kh-ub
    \\ta-co
    \\de-co
    \\tc-td
    \\tb-wq
    \\wh-td
    \\ta-ka
    \\td-qp
    \\aq-cg
    \\wq-ub
    \\ub-vc
    \\de-ta
    \\wq-aq
    \\wq-vc
    \\wh-yn
    \\ka-de
    \\kh-ta
    \\co-tc
    \\wh-qp
    \\tb-vc
    \\td-yn
;

const StringSet = struct {
    items: std.StringHashMap(void),

    const Self = @This();

    fn init() Self {
        return .{
            .items = std.StringHashMap(void).init(alloc),
        };
    }

    fn deinit(self: *Self) void {
        self.items.deinit();
    }

    fn count(self: *const Self) usize {
        return self.items.count();
    }

    fn add(self: *Self, item: []const u8) !void {
        try self.items.put(item, {});
    }

    fn remove(self: *Self, item: []const u8) void {
        _ = self.items.remove(item);
    }

    fn has(self: *const Self, item: []const u8) bool {
        return self.items.contains(item);
    }

    fn keys(self: *const Self) !std.ArrayList([]const u8) {
        var k = std.ArrayList([]const u8).init(alloc);
        var it = self.items.keyIterator();
        while (it.next()) |key| {
            try k.append(key.*);
        }
        return k;
    }

    fn intersect(self: *const Self, other: *const Self) !Self {
        var result = Self.init();
        var it = self.items.keyIterator();
        while (it.next()) |key| {
            if (other.items.contains(key.*)) {
                try result.add(key.*);
            }
        }
        return result;
    }

    fn union_(self: *const Self, other: *const Self) !Self {
        var result = Self.init();
        var it = self.items.keyIterator();
        while (it.next()) |key| {
            try result.add(key.*);
        }
        it = other.items.keyIterator();
        while (it.next()) |key| {
            try result.add(key.*);
        }
        return result;
    }

    fn difference(self: *const Self, other: *const Self) !Self {
        var result = Self.init();
        var it = self.items.keyIterator();
        while (it.next()) |key| {
            if (!other.items.contains(key.*)) {
                try result.add(key.*);
            }
        }
        return result;
    }
};

const Connections = struct {
    by_name: std.StringHashMap(StringSet),

    const Self = @This();

    fn init() Self {
        return .{
            .by_name = std.StringHashMap(StringSet).init(alloc),
        };
    }

    fn deinit(self: *Self) void {
        var iter = self.by_name.valueIterator();
        while (iter.next()) |value_ptr| {
            value_ptr.deinit();
        }
        self.by_name.deinit();
    }

    fn add(self: *Self, a: []const u8, b: []const u8) !void {
        var a_entry = try self.by_name.getOrPutValue(a, StringSet.init());
        try a_entry.value_ptr.add(b);

        var b_entry = try self.by_name.getOrPutValue(b, StringSet.init());
        try b_entry.value_ptr.add(a);
    }

    fn are_connected(self: *const Self, a: []const u8, b: []const u8) bool {
        if (self.by_name.get(a)) |a_set| {
            return a_set.has(b);
        }
        return false;
    }
};

fn startsWithT(a: []const u8) bool {
    return a[0] == 't';
}

fn part1(data: []const u8) !usize {
    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();

    var connections = Connections.init();
    defer connections.deinit();

    for (lines.items) |line| {
        if (line.len == 0) continue;
        try connections.add(line[0..2], line[3..5]);
    }

    var count: usize = 0;

    var checked = StringSet.init();
    defer checked.deinit();

    var a_iter = connections.by_name.iterator();

    while (a_iter.next()) |entry| {
        const n1 = entry.key_ptr.*;
        try checked.add(n1);
        var connected = try entry.value_ptr.keys();
        defer connected.deinit();
        for (0..connected.items.len - 1) |i| {
            const n2 = connected.items[i];
            if (checked.has(n2)) continue;
            for (i + 1..connected.items.len) |j| {
                const n3 = connected.items[j];
                if (checked.has(n3)) continue;
                if (connections.are_connected(n2, n3)) {
                    if (startsWithT(n1) or startsWithT(n2) or startsWithT(n3)) {
                        count += 1;
                    }
                }
            }
        }
    }

    return count;
}

test "part1 example" {
    try expect(7, try part1(example));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 23);
    defer alloc.free(data);
    try expect(1110, try part1(data));
}

fn stringLessThan(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs) == .lt;
}
const Results = std.ArrayList([]const u8);
fn findCliques(R: *StringSet, P: *StringSet, X: *StringSet, connections: *const Connections, results: *Results) !void {
    if (P.count() == 0 and X.count() == 0) {
        var keys = try R.keys();
        defer keys.deinit();
        std.mem.sort([]const u8, keys.items, {}, stringLessThan);
        const result = try std.mem.join(alloc, ",", keys.items);
        try results.append(result);
        return;
    }

    // Try pivot optimization
    // Choose u from P u X, where u is maximally connected
    var pivot: []const u8 = undefined;
    var max_connections: usize = 0;
    var PuX = try P.union_(X);
    defer PuX.deinit();
    var it = PuX.items.keyIterator();
    while (it.next()) |key| {
        const u = key.*;
        const neighbors = connections.by_name.get(u) orelse unreachable;
        if (neighbors.count() > max_connections) {
            max_connections = neighbors.count();
            pivot = u;
        }
    }

    // Then visit (P - N(u))
    var neighbors = connections.by_name.get(pivot) orelse unreachable;
    const neighbor_keys = try neighbors.keys();
    defer neighbor_keys.deinit();

    var Nu = StringSet.init();
    defer Nu.deinit();

    for (neighbor_keys.items) |n| {
        try Nu.add(n);
    }

    var P_minus_Nu = try P.difference(&Nu);
    defer P_minus_Nu.deinit();

    var nodes = try P_minus_Nu.keys();
    defer nodes.deinit();

    for (nodes.items) |n| {
        var n_set = StringSet.init();
        defer n_set.deinit();
        try n_set.add(n);

        var R1 = try R.union_(&n_set);
        defer R1.deinit();

        neighbors = connections.by_name.get(n) orelse unreachable;

        var P1 = try P.intersect(&neighbors);
        defer P1.deinit();

        var X1 = try X.intersect(&neighbors);
        defer X1.deinit();

        try findCliques(&R1, &P1, &X1, connections, results);

        P.remove(n);
        try X.add(n);
    }
}

fn part2(data: []const u8) ![]const u8 {
    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();
    var connections = Connections.init();
    defer connections.deinit();

    var nodes = StringSet.init();
    defer nodes.deinit();

    for (lines.items) |line| {
        if (line.len == 0) continue;
        try connections.add(line[0..2], line[3..5]);
        try nodes.add(line[0..2]);
        try nodes.add(line[3..5]);
    }

    var results = Results.init(alloc);
    defer results.deinit();

    var R = StringSet.init();
    defer R.deinit();

    var X = StringSet.init();
    defer X.deinit();

    try findCliques(&R, &nodes, &X, &connections, &results);

    var best: usize = 0;
    var result: []const u8 = undefined;

    for (results.items) |r| {
        // print("{s}\n", .{r});
        if (r.len > best) {
            if (best > 0) {
                alloc.free(result);
            }
            best = r.len;
            result = r;
        } else {
            alloc.free(r);
        }
    }

    return result;
}

test "part2 example" {
    const result = try part2(example);
    defer alloc.free(result);
    try std.testing.expectEqualStrings("co,de,ka,ta", result);
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 23);
    defer alloc.free(data);
    const result = try part2(data);
    defer alloc.free(result);
    try std.testing.expectEqualStrings("ej,hm,ks,ms,ns,rb,rq,sc,so,un,vb,vd,wd", result);
}
