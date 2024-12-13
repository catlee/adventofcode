const aoc = @import("aoc.zig");
const std = @import("std");
const containers = @import("containers.zig");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;

const example =
    \\
;

fn part1(data: []const u8) !usize {
    _ = data;
    return 0;
}

test "part1 example" {
    try expect(0, try part1(example));
}
