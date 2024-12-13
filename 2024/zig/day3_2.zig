const aoc = @import("aoc.zig");
const std = @import("std");
const print = std.debug.print;
const expect = aoc.expect;
const ArrayList = std.ArrayList;
const alloc = std.testing.allocator;

const Tokenizer = struct {
    buffer: []const u8,
    index: usize,

    const Self = @This();

    pub fn init(buffer: []const u8) Self {
        return Tokenizer{ .buffer = buffer, .index = 0 };
    }

    const State = enum {
        start,
        int,
        ident,
    };

    const Tag = enum {
        int,
        l_paren,
        r_paren,
        ident,
        comma,
        end,
        garbage,
    };

    const Token = struct {
        tag: Tag,
        start: usize,
        end: usize,
    };

    fn next(self: *Self) Token {
        var result: Token = .{
            .tag = undefined,
            .start = self.index,
            .end = self.index,
        };

        if (self.index >= self.buffer.len) {
            result.tag = Tag.end;
            return result;
        }

        state: switch (State.start) {
            .start => switch (self.buffer[self.index]) {
                0 => {
                    result.tag = Tag.end;
                    return result;
                },
                '0'...'9' => {
                    result.tag = Tag.int;
                    self.index += 1;
                    continue :state .int;
                },
                'm', 'd' => {
                    result.tag = Tag.ident;
                    self.index += 1;
                    continue :state .ident;
                },
                '(' => {
                    result.tag = Tag.l_paren;
                    self.index += 1;
                },
                ')' => {
                    result.tag = Tag.r_paren;
                    self.index += 1;
                },
                ',' => {
                    result.tag = Tag.comma;
                    self.index += 1;
                },
                else => {
                    self.index += 1;
                    result.tag = Tag.garbage;
                },
            },
            .int => switch (self.buffer[self.index]) {
                '0'...'9' => {
                    self.index += 1;
                    continue :state .int;
                },
                else => {},
            },
            .ident => switch (self.buffer[self.index]) {
                'a'...'z', '\'' => {
                    self.index += 1;
                    continue :state .ident;
                },
                else => {},
            },
        }
        result.end = self.index;

        return result;
    }

    fn tokens(self: *Self) !ArrayList(Token) {
        var result = ArrayList(Token).init(alloc);
        while (true) {
            const token = self.next();
            try result.append(token);
            if (token.tag == Tag.end) {
                break;
            }
        }
        return result;
    }
};

fn part1(program: []const u8) !usize {
    var tokenizer = Tokenizer.init(program);
    var sum: usize = 0;

    const State = enum {
        start,
        mul,
        l_paren,
        int1,
        comma,
        int2,
        // r_paren,
    };

    var int1: usize = 0;
    var int2: usize = 0;

    state: switch (State.start) {
        .start => {
            const token = tokenizer.next();
            if (token.tag == .end) {
                return sum;
            }
            if (token.tag == .ident) {
                const ident = program[token.start..token.end];
                if (std.mem.eql(u8, "mul", ident)) {
                    continue :state .mul;
                }
            }
            continue :state .start;
        },
        .mul => {
            const token = tokenizer.next();
            if (token.tag == .l_paren) {
                continue :state .l_paren;
            }
            continue :state .start;
        },
        .l_paren => {
            const token = tokenizer.next();
            if (token.tag == .int) {
                int1 = try std.fmt.parseInt(usize, program[token.start..token.end], 10);
                continue :state .int1;
            }
            continue :state .start;
        },
        .int1 => {
            const token = tokenizer.next();
            if (token.tag == .comma) {
                continue :state .comma;
            }
            continue :state .start;
        },
        .comma => {
            const token = tokenizer.next();
            if (token.tag == .int) {
                int2 = try std.fmt.parseInt(usize, program[token.start..token.end], 10);
                continue :state .int2;
            }
            continue :state .start;
        },
        .int2 => {
            const token = tokenizer.next();
            if (token.tag == .r_paren) {
                sum += int1 * int2;
                continue :state .start;
            }
            continue :state .start;
        },
    }
    return sum;
}

test "part1 example" {
    const example = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
    try expect(161, try part1(example));
}

test "part1 actual" {
    const data = try aoc.getData(alloc, 2024, 3);
    defer alloc.free(data);
    try expect(153469856, try part1(data));
}

// test "part2 example" {
//     const example = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";
//     try expect(48, try part2(example));
// }
//
// test "part2 actual" {
//     const data = try aoc.getData(alloc, 2024, 3);
//     defer alloc.free(data);
//     try expect(77055967, try part2(data));
// }
