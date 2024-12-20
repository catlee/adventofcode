const std = @import("std");

const Allocator = std.mem.Allocator;
const max_input_size = 1_000_000;

const AocError = error{
    DownloadError,
};

var _token: [1000]u8 = undefined;

fn getSessionToken() ![]const u8 {
    // Look in ENV for AOC_SESSION_TOKEN
    // Or in ~/.adventofcode.session
    if (std.posix.getenv("AOC_SESSION_TOKEN")) |token| {
        return token;
    }

    const home = std.posix.getenv("HOME") orelse "";
    var filenamebuf: [1000]u8 = undefined;
    const filename = try std.fmt.bufPrint(&filenamebuf, "{s}/.adventofcode.session", .{home});

    const token = try std.fs.cwd().readFile(filename, &_token);
    return _token[0..token.len];
}

fn fetchInput(alloc: Allocator, year: u16, day: u8) ![]u8 {
    var client = std.http.Client{ .allocator = alloc };
    defer client.deinit();

    // Allocate a buffer for server headers
    var buf: [4096]u8 = undefined;

    // Start the HTTP request
    const url_str = try std.fmt.bufPrint(&buf, "https://adventofcode.com/{d}/day/{d}/input", .{ year, day });

    const uri = try std.Uri.parse(url_str);

    const token = try getSessionToken();
    // defer alloc.free(token);

    const cookie_header = try std.fmt.allocPrint(alloc, "session={s}", .{token});
    defer alloc.free(cookie_header);

    const extra_headers = [_]std.http.Header{.{ .name = "Cookie", .value = cookie_header }};

    const options: std.http.Client.RequestOptions = .{
        .server_header_buffer = &buf,
        .headers = .{ .user_agent = .{ .override = "catlee's agent github.com/catlee/adventofcode" } },
        .extra_headers = &extra_headers,
    };

    var req = try client.open(.GET, uri, options);
    defer req.deinit();

    // Send the HTTP request headers
    try req.send();
    // Finish the body of a request
    try req.finish();

    // Waits for a response from the server and parses any headers that are sent
    try req.wait();

    const hlength = req.response.parser.header_bytes_len;

    const body = try alloc.alloc(u8, 1_000_000);
    defer alloc.free(body);
    const bodysize = try req.readAll(body);

    if (@intFromEnum(req.response.status) >= 200 and @intFromEnum(req.response.status) <= 299) {
        const bodycopy = try alloc.alloc(u8, bodysize);
        @memcpy(bodycopy, body[0..bodysize]);
        return bodycopy;
    } else {
        std.debug.print("Error fetching {s}\n", .{url_str});
        std.debug.print("status={d}\n", .{req.response.status});
        std.debug.print("{d} header bytes returned:\n{s}\n", .{ hlength, buf[0..hlength] });
        std.debug.print("{s}\n", .{body[0..bodysize]});
        return AocError.DownloadError;
    }
}

pub fn getData(alloc: Allocator, year: u16, day: u8) ![]u8 {
    var pathbuf: [100]u8 = undefined;
    const file_path = try std.fmt.bufPrint(&pathbuf, "inputs/{d}-{:0>2}.txt", .{ year, day });

    return if (std.fs.cwd().readFileAlloc(alloc, file_path, max_input_size)) |data| {
        return data;
    } else |_| {
        if (fetchInput(alloc, year, day)) |data| {
            // Write to the file and then return the data
            try std.fs.cwd().makePath("inputs");
            try std.fs.cwd().writeFile(.{ .sub_path = file_path, .data = data });
            return data;
        } else |err1| {
            std.debug.print("Error fetching input: {!}\n", .{err1});
        }
        return undefined;
    };
}

pub fn split(alloc: Allocator, data: []const u8, sep: u8) !std.ArrayList([]const u8) {
    var parts = std.ArrayList([]const u8).init(alloc);
    var iter = std.mem.splitScalar(u8, data, sep);
    while (iter.next()) |part| {
        try parts.append(part);
    }
    return parts;
}

pub fn splitLines(alloc: Allocator, data: []const u8) !std.ArrayList([]const u8) {
    return split(alloc, data, '\n');
}

pub fn splitToNumbers(T: type, alloc: Allocator, data: []const u8) !std.ArrayList(T) {
    var numbers = std.ArrayList(T).init(alloc);
    var iter = std.mem.splitScalar(u8, data, ' ');
    while (iter.next()) |num| {
        if (num.len == 0) {
            continue;
        }
        const n = try std.fmt.parseInt(T, num, 10);
        try numbers.append(n);
    }
    return numbers;
}

pub fn main() !void {
    // Create a general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // const token = try getSessionToken();
    // std.debug.print("Got token: {s} {d}\n", .{ token, token.len });

    if (getData(alloc, 2024, 1)) |data| {
        defer alloc.free(data);
        std.debug.print("Got: {s}\n", .{data});
    } else |err| {
        std.debug.print("Error: {!}\n", .{err});
    }

    return;
}

pub fn expect(expected: anytype, actual: anytype) !void {
    if (expected == actual) {
        return;
    }
    std.debug.print("expected {any}; got {any}\n", .{ expected, actual });
    return error.TestUnexpectedResult;
}

pub const Point1 = struct {
    x: isize,
    y: isize,

    pub fn isInside(self: Point, top_left: Point, bottom_right: Point) bool {
        return self.x >= top_left.x and self.x <= bottom_right.x and self.y >= top_left.y and self.y <= bottom_right.y;
    }
};

pub const Direction = enum {
    North,
    East,
    South,
    West,
};

const containers = @import("containers.zig");
pub const HashGrid = containers.HashGrid(isize, u8);
pub const Point = containers.Point(isize);
pub const Box = containers.Box(isize);
