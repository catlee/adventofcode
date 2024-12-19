const aoc = @import("aoc.zig");
const std = @import("std");
const containers = @import("containers.zig");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;

const example =
    \\r, wr, b, g, bwu, rb, gb, br
    \\
    \\brwrr
    \\bggr
    \\gbbr
    \\rrbgbr
    \\ubwu
    \\bwurrg
    \\brgr
    \\bbrgwb
;

const Cache = std.StringHashMap(usize);

fn ways_to_make(cache: *Cache, design: []const u8, patterns: []const []const u8) !usize {
    if (design.len == 0) {
        return 1;
    }
    if (cache.get(design)) |rv| {
        return rv;
    }

    var count: usize = 0;
    for (patterns) |p| {
        if (p.len > design.len) {
            continue;
        }
        if (!std.mem.startsWith(u8, design, p)) {
            continue;
        }
        const suffix_ways = try ways_to_make(cache, design[p.len..], patterns);
        count += suffix_ways;
    }
    try cache.put(design, count);
    return count;
}

fn part1(data: []const u8) !usize {
    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();

    var available_patterns = std.ArrayList([]const u8).init(alloc);
    defer available_patterns.deinit();
    var comma_iter = std.mem.tokenizeAny(u8, lines.items[0], ", ");
    while (comma_iter.next()) |token| {
        try available_patterns.append(token);
    }

    var cache = Cache.init(alloc);
    defer cache.deinit();

    var count: usize = 0;
    for (lines.items[2..]) |line| {
        if (line.len == 0) {
            continue;
        }
        if (try ways_to_make(&cache, line, available_patterns.items) > 0) {
            // print("can make {s}\n", .{line});
            count += 1;
        } else {
            // print("cannot make {s}\n", .{line});
        }
    }

    return count;
}

fn part2(data: []const u8) !usize {
    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();

    var available_patterns = std.ArrayList([]const u8).init(alloc);
    defer available_patterns.deinit();
    var comma_iter = std.mem.tokenizeAny(u8, lines.items[0], ", ");
    while (comma_iter.next()) |token| {
        try available_patterns.append(token);
    }

    var cache = Cache.init(alloc);
    defer cache.deinit();

    var count: usize = 0;
    for (lines.items[2..]) |line| {
        if (line.len == 0) {
            continue;
        }
        count += try ways_to_make(&cache, line, available_patterns.items);
    }

    return count;
}

test "bwurrg" {
    const patterns = [_][]const u8{ "r", "wr", "b", "g", "bwu", "rb", "gb", "br" };
    const design = "bwurrg";
    var cache = Cache.init(alloc);
    defer cache.deinit();
    const rv = try ways_to_make(&cache, design, &patterns);
    try expect(1, rv);
}

test "ways_to_make" {
    const patterns = [_][]const u8{ "r", "wr", "b", "g", "bwu", "rb", "gb", "br" };
    var cache = Cache.init(alloc);
    defer cache.deinit();

    try expect(2, try ways_to_make(&cache, "brwrr", &patterns));
    try expect(1, try ways_to_make(&cache, "bggr", &patterns));
    try expect(6, try ways_to_make(&cache, "rrbgbr", &patterns));
}

test "part1 example" {
    try expect(6, try part1(example));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 19);
    defer alloc.free(data);
    try expect(278, try part1(data));
}

test "part2 example" {
    try expect(16, try part2(example));
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 19);
    defer alloc.free(data);
    try expect(569808947758890, try part2(data));
}
