const aoc = @import("aoc.zig");
const std = @import("std");
const containers = @import("containers.zig");
const print = std.debug.print;
const expect = aoc.expect;
const alloc = std.testing.allocator;

const Operation = enum {
    AND,
    OR,
    XOR,
};

const FuncType = fn (usize, usize) usize;

const Gates = struct {
    gates: std.StringHashMap(Gate),

    num_inputs: usize = 0,

    const Self = @This();

    fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .gates = std.StringHashMap(Gate).init(allocator),
        };
    }

    fn deinit(self: *Self) void {
        self.gates.deinit();
    }

    fn parse(data: []const u8) !Self {
        var part_iter = std.mem.splitSequence(u8, data, "\n\n");

        const gate_data = part_iter.next().?;

        var gates = Self.init(alloc);

        var line_iter = std.mem.splitSequence(u8, gate_data, "\n");
        while (line_iter.next()) |line| {
            const name = line[0..3];
            const value = line[5] == '1';
            const g = Gate.init(name, null, value);
            try gates.gates.put(name, g);

            if (name[0] == 'x') {
                const num = std.fmt.parseInt(usize, name[1..3], 10) catch unreachable;
                gates.num_inputs = std.mem.max(usize, &[_]usize{ gates.num_inputs, num + 1 });
            }
        }

        const op_data = part_iter.next().?;
        line_iter = std.mem.splitSequence(u8, op_data, "\n");
        while (line_iter.next()) |line| {
            if (line.len == 0) continue;
            var space_iter = std.mem.splitScalar(u8, line, ' ');
            const input1_name = space_iter.next().?;
            const op_name = space_iter.next().?;
            const input2_name = space_iter.next().?;
            _ = space_iter.next();
            const output_name = space_iter.next().?;

            var op: ?Operation = null;
            if (std.mem.eql(u8, "AND", op_name)) {
                op = Operation.AND;
            } else if (std.mem.eql(u8, "OR", op_name)) {
                op = Operation.OR;
            } else if (std.mem.eql(u8, "XOR", op_name)) {
                op = Operation.XOR;
            } else {
                std.debug.panic("unknown operation\n", .{});
            }

            const output_entry = try gates.gates.getOrPutValue(output_name, Gate.init(output_name, op, null));

            output_entry.value_ptr.input1 = input1_name;
            output_entry.value_ptr.input2 = input2_name;
        }

        return gates;
    }

    fn getGate(self: *const Gates, name: []const u8) ?*Gate {
        return self.gates.getPtr(name);
    }

    fn getValue(self: *const Gates, name: []const u8) bool {
        const g = self.getGate(name) orelse unreachable;
        if (g.value != null) {
            return g.value.?;
        }
        if (g.input1 == null or g.input2 == null or g.op == null) {
            std.debug.panic("inputs can't be null when value isn't set\n", .{});
        }
        // print("getting value for {s} {*}\n", .{ self.name, self.input1 });
        const input1 = self.getValue(g.input1.?);
        const input2 = self.getValue(g.input2.?);

        const value = switch (g.op.?) {
            Operation.AND => input1 and input2,
            Operation.OR => input1 or input2,
            Operation.XOR => input1 != input2,
        };
        return value;
    }

    fn setGates(self: *const Gates, prefix: u8, value: usize) void {
        var digit: usize = 0;
        var name: [3]u8 = undefined;
        var val = value;
        while (digit < self.num_inputs) : (digit += 1) {
            _ = std.fmt.bufPrint(&name, "{c}{d:02}", .{ prefix, digit }) catch unreachable;
            const g = self.getGate(&name) orelse break;
            g.value = val & 1 == 1;
            val >>= 1;
        }
    }

    fn readGates(self: *const Gates, prefix: u8) usize {
        var result: usize = 0;
        var digit: usize = 0;
        var name: [3]u8 = undefined;
        while (digit < self.num_inputs) : (digit += 1) {
            _ = std.fmt.bufPrint(&name, "{c}{d:02}", .{ prefix, digit }) catch unreachable;
            _ = self.getGate(&name) orelse break;
            if (self.getValue(&name)) {
                result += std.math.shl(usize, 1, digit);
            }
        }
        return result;
    }

    fn eval(self: *const Self, x: usize, y: usize) usize {
        self.setGates('x', x);
        self.setGates('y', y);

        return self.readGates('z');
    }

    fn badGates(self: *const Self, expected: usize, actual: usize) !std.ArrayList(*Gate) {
        var gate_status = std.StringHashMap(bool).init(alloc);
        defer gate_status.deinit();

        // Initialize all gates to good
        var iter = self.gates.valueIterator();
        while (iter.next()) |entry| {
            try gate_status.put(entry.name, true);
        }

        var i: usize = 0;
        var name: [3]u8 = undefined;
        while (i < self.num_inputs) : (i += 1) {
            _ = std.fmt.bufPrint(&name, "z{d:02}", .{i}) catch unreachable;
            const gate = self.getGate(&name) orelse unreachable;
            if (std.math.shr(usize, expected, i) & 1 != std.math.shr(usize, actual, i) & 1) {
                var it = try GateParentIterator.init(gate, self);
                while (try it.next()) |gate_ptr| {
                    // Gates without an operator can't be bad
                    if (gate_ptr.op != null) {
                        try gate_status.put(gate_ptr.name, false);
                    }
                }
            }
        }

        var bad_gates = std.ArrayList(*Gate).init(alloc);
        var status_iter = gate_status.iterator();
        while (status_iter.next()) |e| {
            if (!e.value_ptr.*) {
                try bad_gates.append(self.getGate(e.key_ptr.*) orelse unreachable);
            }
        }
        return bad_gates;
    }

    // Is n an ancestor of child?
    fn isAncestor(self: *const Self, child: []const u8, n: []const u8) bool {
        const g = self.getGate(child) orelse unreachable;
        if (g.input1 == null or g.input2 == null) {
            return false;
        }
        if (std.mem.eql(u8, g.input1.?, n)) {
            return true;
        }
        if (std.mem.eql(u8, g.input2.?, n)) {
            return true;
        }
        if (self.isAncestor(g.input1.?, n)) {
            return true;
        }
        if (self.isAncestor(g.input2.?, n)) {
            return true;
        }
        return false;
    }
};

const Gate = struct {
    name: []const u8,

    op: ?Operation,

    input1: ?[]const u8,
    input2: ?[]const u8,

    value: ?bool,

    fn init(name: []const u8, op: ?Operation, value: ?bool) Gate {
        return Gate{
            .name = name,
            .op = op,
            .input1 = null,
            .input2 = null,
            .value = value,
        };
    }
};

fn part1(data: []const u8) !usize {
    var gates = try Gates.parse(data);
    defer gates.deinit();

    var result: usize = 0;
    var digit: usize = 0;
    while (true) {
        var name: [3]u8 = undefined;
        _ = try std.fmt.bufPrint(&name, "z{d:02}", .{digit});

        _ = gates.getGate(&name) orelse break;

        const v = gates.getValue(&name);
        if (v) {
            result += std.math.shl(usize, 1, digit);
        }
        digit += 1;
    }

    return result;
}

const example1 =
    \\x00: 1
    \\x01: 1
    \\x02: 1
    \\y00: 0
    \\y01: 1
    \\y02: 0
    \\
    \\x00 AND y00 -> z00
    \\x01 XOR y01 -> z01
    \\x02 OR y02 -> z02
;

test "part1 example1" {
    try expect(4, try part1(example1));
}

const example2 =
    \\x00: 1
    \\x01: 0
    \\x02: 1
    \\x03: 1
    \\x04: 0
    \\y00: 1
    \\y01: 1
    \\y02: 1
    \\y03: 1
    \\y04: 1
    \\
    \\ntg XOR fgs -> mjb
    \\y02 OR x01 -> tnw
    \\kwq OR kpj -> z05
    \\x00 OR x03 -> fst
    \\tgd XOR rvg -> z01
    \\vdt OR tnw -> bfw
    \\bfw AND frj -> z10
    \\ffh OR nrd -> bqk
    \\y00 AND y03 -> djm
    \\y03 OR y00 -> psh
    \\bqk OR frj -> z08
    \\tnw OR fst -> frj
    \\gnj AND tgd -> z11
    \\bfw XOR mjb -> z00
    \\x03 OR x00 -> vdt
    \\gnj AND wpb -> z02
    \\x04 AND y00 -> kjc
    \\djm OR pbm -> qhw
    \\nrd AND vdt -> hwm
    \\kjc AND fst -> rvg
    \\y04 OR y02 -> fgs
    \\y01 AND x02 -> pbm
    \\ntg OR kjc -> kwq
    \\psh XOR fgs -> tgd
    \\qhw XOR tgd -> z09
    \\pbm OR djm -> kpj
    \\x03 XOR y03 -> ffh
    \\x00 XOR y04 -> ntg
    \\bfw OR bqk -> z06
    \\nrd XOR fgs -> wpb
    \\frj XOR qhw -> z04
    \\bqk OR frj -> z07
    \\y03 OR x01 -> nrd
    \\hwm AND bqk -> z03
    \\tgd XOR rvg -> z12
    \\tnw OR pbm -> gnj
;

test "part1 example2" {
    try expect(2024, try part1(example2));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 24);
    defer alloc.free(data);
    try expect(58639252480880, try part1(data));
}

const example3 =
    \\x00: 0
    \\x01: 1
    \\x02: 0
    \\x03: 1
    \\x04: 0
    \\x05: 1
    \\y00: 0
    \\y01: 0
    \\y02: 1
    \\y03: 1
    \\y04: 0
    \\y05: 1
    \\
    \\x00 AND y00 -> z05
    \\x01 AND y01 -> z02
    \\x02 AND y02 -> z01
    \\x03 AND y03 -> z03
    \\x04 AND y04 -> z04
    \\x05 AND y05 -> z00
;

const GateParentIterator = struct {
    gates: *const Gates,
    current: *const Gate,
    to_visit: std.ArrayList(*const Gate),

    const Self = @This();

    fn init(start: *const Gate, gates: *const Gates) !Self {
        var to_visit = std.ArrayList(*const Gate).init(alloc);
        try to_visit.append(start);
        return Self{
            .current = start,
            .gates = gates,
            .to_visit = to_visit,
        };
    }

    fn next(self: *Self) !?*const Gate {
        if (self.to_visit.items.len == 0) {
            self.to_visit.deinit();
            return null;
        }
        const current = self.to_visit.pop();

        if (current.input1 != null) {
            const input1 = self.gates.getGate(current.input1.?) orelse unreachable;
            try self.to_visit.append(input1);
        }
        if (current.input2 != null) {
            const input2 = self.gates.getGate(current.input2.?) orelse unreachable;
            try self.to_visit.append(input2);
        }

        return current;
    }
};

fn swapGates(g1: *Gate, g2: *Gate) void {
    var t_name = g1.input1;
    g1.input1 = g2.input1;
    g2.input1 = t_name;

    t_name = g1.input2;
    g1.input2 = g2.input2;
    g2.input2 = t_name;

    const t_op = g1.op;
    g1.op = g2.op;
    g2.op = t_op;
}

fn countBits(comptime T: type, val: T) usize {
    var count: usize = 0;
    var v = val;
    while (v > 0) {
        count += v & 1;
        v >>= 1;
    }
    return count;
}

fn stringLessThan(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs) == .lt;
}

fn part2_add(data: []const u8) ![]const u8 {
    // z = func(x, y)
    var gates = try Gates.parse(data);
    defer gates.deinit();

    // Rule 1 - if the output of a gate is Z, then it must be a XOR
    // Rule 2 - if the output of a gate is not Z, and its inputs are not x,y
    //          then it must be an AND or OR, but not XOR

    var bad_gates = std.ArrayList([]const u8).init(alloc);
    defer bad_gates.deinit();

    var iter = gates.gates.valueIterator();
    while (iter.next()) |gate| {
        if (gate.input1 == null or gate.input2 == null) {
            continue;
        }

        if (gate.name[0] == 'z') {
            if (gate.op != Operation.XOR and !std.mem.eql(u8, "z45", gate.name)) {
                print("bad gate1: {s} {?}\n", .{ gate.name, gate.op });
                try bad_gates.append(gate.name);
            }
        } else if (!(gate.input1.?[0] == 'x' or gate.input1.?[0] == 'y') and !(gate.input2.?[0] == 'x' or gate.input2.?[0] == 'y')) {
            if (gate.op == Operation.XOR) {
                print("bad gate2: {s} {?} {?s} {?s}\n", .{ gate.name, gate.op, gate.input1, gate.input2 });
                try bad_gates.append(gate.name);
            }
        } else if (gate.op == Operation.XOR) {
            if ((gate.input1.?[0] == 'x' or gate.input1.?[0] == 'y') and (gate.input2.?[0] == 'x' or gate.input2.?[0] == 'y')) {
                // There should be another XOR gate with this as input; otherwise this one is faulty
                var iter2 = gates.gates.valueIterator();
                while (iter2.next()) |g2| {
                    if (g2.op == Operation.XOR and (std.mem.eql(u8, g2.input1.?, gate.name) or std.mem.eql(u8, g2.input2.?, gate.name))) {
                        break;
                    }
                } else {
                    print("bad gate3: {s} {?} {?s} {?s}\n", .{ gate.name, gate.op, gate.input1, gate.input2 });
                    try bad_gates.append(gate.name);
                }
            }
        } else if (gate.op == Operation.AND and !std.mem.eql(u8, gate.input1.?, "x00")) {
            // There should be an OR gate with this as input; otherwise this one is faulty
            var iter2 = gates.gates.valueIterator();
            while (iter2.next()) |g2| {
                if (g2.op == Operation.OR and (std.mem.eql(u8, g2.input1.?, gate.name) or std.mem.eql(u8, g2.input2.?, gate.name))) {
                    break;
                }
            } else {
                print("bad gate4: {s} {?} {?s} {?s}\n", .{ gate.name, gate.op, gate.input1, gate.input2 });
                try bad_gates.append(gate.name);
            }
        }
    }

    print("bad gates: {d}\n", .{bad_gates.items.len});

    std.mem.sort([]const u8, bad_gates.items, {}, stringLessThan);

    const result = try std.mem.join(alloc, ",", bad_gates.items);
    return result;
}

test "part2 actual" {
    const data = try aoc.getData(alloc, 2024, 24);
    defer alloc.free(data);

    const result = try part2_add(data);
    defer alloc.free(result);
    try std.testing.expectEqualStrings("bkr,mqh,rnq,tfb,vvr,z08,z28,z39", result);
}
