const aoc = @import("aoc.zig");
const std = @import("std");
const containers = @import("containers.zig");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;

const example =
    \\Register A: 729
    \\Register B: 0
    \\Register C: 0
    \\
    \\Program: 0,1,5,4,3,0
;

const CPU = struct {
    program: std.ArrayList(u8),
    ip: usize,
    registers: [3]i64,
    output: std.ArrayList(u8),

    pub fn new(program: []const u8) !CPU {
        var p = std.ArrayList(u8).init(alloc);
        for (program) |opcode| {
            try p.append(opcode);
        }

        return CPU{ .program = p, .ip = 0, .registers = .{ 0, 0, 0 }, .output = std.ArrayList(u8).init(alloc) };
    }

    pub fn deinit(self: *CPU) void {
        self.output.deinit();
        self.program.deinit();
    }

    pub fn tick(self: *CPU) bool {
        if (self.ip >= self.program.items.len) {
            return false;
        }
        const opcode = self.program.items[self.ip];
        switch (opcode) {
            0 => { // adv
                const operand: u6 = @intCast(self.getComboOperand() orelse return false);
                const one: i64 = 1;
                const result = @divTrunc(self.registers[0], @shlExact(one, operand));
                self.registers[0] = result;
                self.ip += 2;
                return true;
            },
            1 => { // bxl
                const operand = self.getLiteralOperand() orelse return false;
                self.registers[1] = operand ^ self.registers[1];
                self.ip += 2;
                return true;
            },
            2 => {
                const operand = self.getComboOperand() orelse return false;
                self.registers[1] = @mod(operand, 8);
                self.ip += 2;
                return true;
            },
            3 => { // jnz
                const operand = self.getLiteralOperand() orelse return false;
                if (self.registers[0] == 0) {
                    self.ip += 2;
                    return true;
                } else {
                    self.ip = operand;
                    return true;
                }
            },
            4 => { // bxc
                _ = self.getLiteralOperand() orelse return false;
                self.registers[1] = self.registers[1] ^ self.registers[2];
                self.ip += 2;
                return true;
            },
            5 => { // output
                const operand = self.getComboOperand() orelse return false;
                self.output.append(@intCast(@rem(operand, 8))) catch return false;
                self.ip += 2;
                return true;
            },
            6 => { // bdv
                const operand: u6 = @intCast(self.getComboOperand() orelse return false);
                const one: i64 = 1;
                const result = @divTrunc(self.registers[0], @shlExact(one, operand));
                self.registers[1] = result;
                self.ip += 2;
                return true;
            },
            7 => { // cdv
                const operand: u6 = @intCast(self.getComboOperand() orelse return false);
                const one: i64 = 1;
                const result = @divTrunc(self.registers[0], @shlExact(one, operand));
                self.registers[2] = result;
                self.ip += 2;
                return true;
            },
            else => {
                return false;
            },
        }
    }

    pub fn getLiteralOperand(self: *CPU) ?u8 {
        if (self.ip + 1 >= self.program.items.len) {
            return null;
        }
        return self.program.items[self.ip + 1];
    }

    pub fn getComboOperand(self: *CPU) ?i64 {
        if (self.ip + 1 >= self.program.items.len) {
            return null;
        }
        switch (self.program.items[self.ip + 1]) {
            0...3 => return self.program.items[self.ip + 1],
            4 => return self.registers[0],
            5 => return self.registers[1],
            6 => return self.registers[2],
            else => unreachable,
        }
    }

    pub fn parse(data: []const u8) !CPU {
        var cpu = try CPU.new("");

        var iter = std.mem.tokenizeAny(u8, data, ": \n");
        _ = iter.next(); // Register
        _ = iter.next(); // "A"
        var s = iter.next().?;
        cpu.registers[0] = try std.fmt.parseInt(isize, s, 10);

        _ = iter.next(); // Register
        _ = iter.next(); // "B"
        s = iter.next().?;
        cpu.registers[1] = try std.fmt.parseInt(isize, s, 10);

        _ = iter.next(); // Register
        _ = iter.next(); // "C"
        s = iter.next().?;
        cpu.registers[2] = try std.fmt.parseInt(isize, s, 10);

        _ = iter.next(); // Program
        s = iter.next().?;

        var iter1 = std.mem.tokenizeScalar(u8, s, ',');
        while (iter1.next()) |n| {
            try cpu.program.append(try std.fmt.parseInt(u8, n, 10));
        }

        return cpu;
    }
};

fn programValue(program: []const u8) usize {
    var value: usize = 0;
    for (program) |opcode| {
        value = value * 10 + opcode;
    }
    return value;
}

fn part1(data: []const u8) ![]u8 {
    var cpu = try CPU.parse(data);
    defer cpu.deinit();

    while (cpu.tick()) {}

    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    const arena_allocator = arena.allocator();
    var output_strings = std.ArrayList([]const u8).init(arena_allocator);
    for (cpu.output.items) |i| {
        const s = try std.fmt.allocPrint(arena_allocator, "{d}", .{i});
        try output_strings.append(s);
    }
    const result = try std.mem.join(alloc, ",", output_strings.items);
    return result;
}

test "adv" {
    var cpu = try CPU.new(&[_]u8{ 0, 2 });
    defer cpu.deinit();
    cpu.registers[0] = 20;
    try expect(true, cpu.tick());
    try expect(2, cpu.ip);
    try expect(5, cpu.registers[0]);
}

test "bxl" {
    var cpu = try CPU.new(&[_]u8{ 1, 3 });
    defer cpu.deinit();
    cpu.registers[1] = 0b100;
    try expect(true, cpu.tick());
    try expect(2, cpu.ip);
    try expect(3 ^ 0b100, cpu.registers[1]);
}
test "bst" {
    var cpu = try CPU.new(&[_]u8{ 2, 4 });
    defer cpu.deinit();
    cpu.registers[0] = 15;
    try expect(true, cpu.tick());
    try expect(2, cpu.ip);
    try expect(7, cpu.registers[1]);
}

test "jnz" {
    var cpu = try CPU.new(&[_]u8{ 3, 1 });
    defer cpu.deinit();
    cpu.registers[0] = 0;
    try expect(true, cpu.tick());
    try expect(2, cpu.ip);

    cpu.ip = 0;
    cpu.registers[0] = 1;
    try expect(true, cpu.tick());
    try expect(1, cpu.ip);
}

test "bxc" {
    var cpu = try CPU.new(&[_]u8{ 4, 3 });
    defer cpu.deinit();
    cpu.registers[1] = 0b101;
    cpu.registers[2] = 0b110;
    try expect(true, cpu.tick());
    try expect(2, cpu.ip);
    try expect(0b101 ^ 0b110, cpu.registers[1]);
}

test "out" {
    var cpu = try CPU.new(&[_]u8{ 5, 3 });
    defer cpu.deinit();
    try expect(true, cpu.tick());
    try expect(2, cpu.ip);
    try expect(3, cpu.output.items[0]);
}

test "bdv" {
    var cpu = try CPU.new(&[_]u8{ 6, 2 });
    defer cpu.deinit();
    cpu.registers[0] = 20;
    try expect(true, cpu.tick());
    try expect(2, cpu.ip);
    try expect(5, cpu.registers[1]);
}

test "cdv" {
    var cpu = try CPU.new(&[_]u8{ 7, 2 });
    defer cpu.deinit();
    cpu.registers[0] = 20;
    try expect(true, cpu.tick());
    try expect(2, cpu.ip);
    try expect(5, cpu.registers[2]);
}

test "example" {
    var cpu = try CPU.new(&[_]u8{ 0, 1, 5, 4, 3, 0 });
    defer cpu.deinit();
    cpu.registers[0] = 729;
    cpu.registers[1] = 0;
    cpu.registers[2] = 0;

    while (cpu.tick()) {}

    try std.testing.expectEqualDeep(&[_]u8{ 4, 6, 3, 5, 6, 3, 5, 2, 1, 0 }, cpu.output.items);
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 17);
    defer alloc.free(data);

    const result = try part1(data);
    defer alloc.free(result);
    try std.testing.expectEqualStrings("7,5,4,3,4,5,3,4,6", result);
}

const example2 =
    \\Register A: 2024
    \\Register B: 0
    \\Register C: 0
    \\
    \\Program: 0,3,5,4,3,0
;

fn part2(data: []const u8) !i64 {
    var cpu = try CPU.parse(data);
    defer cpu.deinit();

    const targetValue = programValue(cpu.program.items);

    var a: i64 = std.math.pow(i64, 8, @intCast(cpu.program.items.len - 1));
    // print("\n", .{});
    while (targetValue != programValue(cpu.output.items)) {
        cpu.registers[0] = a;
        cpu.registers[1] = 0;
        cpu.registers[2] = 0;
        cpu.ip = 0;
        cpu.output.clearRetainingCapacity();
        while (cpu.tick()) {}
        // print("a={d} program={any} output={any}\n", .{ a, cpu.program.items, cpu.output.items });
        if (cpu.output.items.len < cpu.program.items.len) {
            a *= 8;
            continue;
        }
        var matching: usize = 0;
        const n = cpu.program.items.len - 1;
        for (0..cpu.output.items.len) |i| {
            if (cpu.output.items[n - i] == cpu.program.items[n - i]) {
                matching += 1;
            } else {
                break;
            }
        }
        if (matching == cpu.program.items.len) {
            break;
        }
        const scale = std.math.pow(isize, 8, @intCast(n - matching));
        a += scale;
    }

    return a;
}

test "part2 example" {
    try expect(117440, try part2(example2));
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 17);
    defer alloc.free(data);
    try expect(164278899142333, try part2(data));
}
