const aoc = @import("aoc.zig");
const std = @import("std");
const containers = @import("containers.zig");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;

const example =
    \\1
    \\10
    \\100
    \\2024
;

const Prune = 16777216; // 2^24

fn simulateOnce(secret: usize) usize {
    const s0 = secret;
    const s1 = s0 << 6;
    const s2 = (s1 ^ s0) % Prune;
    const s3 = s2 >> 5;
    const s4 = (s3 ^ s2) % Prune;
    const s5 = s4 << 11;
    const s6 = (s5 ^ s4) % Prune;
    return s6;
}

fn simulate(secret: usize, times: usize) usize {
    var s = secret;
    for (0..times) |_| {
        s = simulateOnce(s);
    }
    return s;
}

fn part1(data: []const u8) !usize {
    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();

    var secrets: usize = 0;

    for (lines.items) |line| {
        if (line.len == 0) {
            continue;
        }
        var secret = try std.fmt.parseInt(usize, line, 10);
        secret = simulate(secret, 2000);
        secrets += secret;
    }

    return secrets;
}

test "part1 example" {
    try expect(37327623, try part1(example));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 22);
    defer alloc.free(data);
    try expect(18317943467, try part1(data));
}

const Sequence = [4]isize;

const SequenceValue = std.AutoHashMap(Sequence, usize);

fn sellPrice(secret: usize, target_sequence: Sequence) !?usize {
    var s = secret;
    var cur_sequence: Sequence = undefined;
    var last: usize = s;

    for (0..4) |i| {
        s = simulateOnce(s);
        const delta = @as(isize, @intCast(s % 10)) - @as(isize, @intCast(last % 10));
        // print("{d}: {d} ({d})\n", .{ s, s % 10, delta });
        cur_sequence[i] = delta;
        last = s;
    }

    var i: usize = 0;
    while (i < 2000 - 4) : (i += 1) {
        if (std.mem.eql(isize, &cur_sequence, &target_sequence)) {
            return s % 10;
        }
        s = simulateOnce(s);
        const delta = @as(isize, @intCast(s % 10)) - @as(isize, @intCast(last % 10));
        // print("{d}: {d} ({d})\n", .{ s, s % 10, delta });
        std.mem.copyForwards(isize, &cur_sequence, cur_sequence[1..4]);
        cur_sequence[3] = delta;
        last = s;
    }

    return null;
}

fn updateSequenceValues(secret: usize, values: *SequenceValue) !void {
    var s = secret;
    var cur_sequence: Sequence = undefined;
    var last: usize = s;
    var seen = std.AutoHashMap(Sequence, void).init(alloc);
    defer seen.deinit();

    for (0..4) |i| {
        s = simulateOnce(s);
        const delta = @as(isize, @intCast(s % 10)) - @as(isize, @intCast(last % 10));
        // print("{d}: {d} ({d})\n", .{ s, s % 10, delta });
        cur_sequence[i] = delta;
        last = s;
    }
    var e = try values.getOrPutValue(cur_sequence, 0);
    e.value_ptr.* += s % 10;

    var i: usize = 0;
    while (i < 2000 - 4) : (i += 1) {
        s = simulateOnce(s);
        const delta = @as(isize, @intCast(s % 10)) - @as(isize, @intCast(last % 10));
        std.mem.copyForwards(isize, &cur_sequence, cur_sequence[1..4]);
        cur_sequence[3] = delta;
        // print("{d}: {d} ({d}) {d}\n", .{ s, s % 10, delta, cur_sequence });
        last = s;
        if (seen.contains(cur_sequence)) continue;
        try seen.put(cur_sequence, void{});
        e = try values.getOrPutValue(cur_sequence, 0);
        e.value_ptr.* += s % 10;
    }
}

test "sellPrice" {
    const secret = 123;

    const target_sequence = .{ -1, -1, 0, 2 };

    const p = try sellPrice(secret, target_sequence);
    try expect(6, p);
}

test "updateSequenceValues" {
    var values = SequenceValue.init(alloc);
    defer values.deinit();

    try updateSequenceValues(1, &values);
    try updateSequenceValues(2, &values);
    try updateSequenceValues(3, &values);
    try updateSequenceValues(2024, &values);

    try expect(23, values.get(.{ -2, 1, -1, 3 }));
}

fn part2(data: []const u8) !usize {
    var values = SequenceValue.init(alloc);
    defer values.deinit();

    const lines = try aoc.splitLines(alloc, data);
    defer lines.deinit();

    for (lines.items) |line| {
        if (line.len == 0) {
            continue;
        }
        const secret = try std.fmt.parseInt(usize, line, 10);
        try updateSequenceValues(secret, &values);
    }

    var best: usize = 0;
    var it = values.iterator();
    while (it.next()) |e| {
        if (e.value_ptr.* > best) {
            // print("{d} is current best with {d}\n", .{ e.key_ptr.*, e.value_ptr.* });
            best = e.value_ptr.*;
        }
    }

    return best;
}

test "part2 example" {
    const data =
        \\1
        \\2
        \\3
        \\2024
    ;

    try expect(23, try part2(data));
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 22);
    defer alloc.free(data);
    try expect(2018, try part2(data));
}
