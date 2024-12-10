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

    const options = .{
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

pub fn splitToNumbers(alloc: Allocator, data: []const u8) !std.ArrayList(isize) {
    var numbers = std.ArrayList(isize).init(alloc);
    var iter = std.mem.splitScalar(u8, data, ' ');
    while (iter.next()) |num| {
        const n = try std.fmt.parseInt(isize, num, 10);
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

pub const Point = struct {
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

pub const HashGrid = struct {
    width: isize = undefined,
    height: isize = undefined,
    points: HashT,

    left: isize = undefined,
    right: isize = undefined,
    top: isize = undefined,
    bottom: isize = undefined,

    const Self = @This();
    const HashT = std.AutoHashMap(Point, u8);

    pub fn init(a: std.mem.Allocator) Self {
        return .{
            .points = HashT.init(a),
        };
    }

    pub fn deinit(self: *Self) void {
        self.points.deinit();
    }

    pub fn clone(self: *const Self) !Self {
        var newGrid = Self.init(self.points.allocator);
        var iter = self.points.iterator();
        while (iter.next()) |e| {
            try newGrid.set(e.key_ptr.*, e.value_ptr.*);
        }
        return newGrid;
    }

    pub fn set(self: *Self, p: Point, v: u8) !void {
        try self.points.put(p, v);
        if (self.points.count() == 1) {
            self.left = p.x;
            self.right = p.x;
            self.top = p.y;
            self.bottom = p.y;
            self.width = 1;
            self.height = 1;
        } else {
            self.left = std.mem.min(isize, &[_]isize{ p.x, self.left });
            self.right = std.mem.max(isize, &[_]isize{ p.x, self.right });
            self.bottom = std.mem.min(isize, &[_]isize{ p.y, self.bottom });
            self.top = std.mem.max(isize, &[_]isize{ p.y, self.top });
            self.width = (self.right - self.left) + 1;
            self.height = (self.top - self.bottom) + 1;
        }
    }

    pub fn get(self: *const Self, p: Point) ?u8 {
        return self.points.get(p);
    }

    pub fn isInside(self: *const Self, p: Point) bool {
        return p.x >= self.left and p.x <= self.right and p.y >= self.bottom and p.y <= self.top;
    }

    pub fn print(self: *const Self) void {
        var y: isize = self.bottom;
        while (y <= self.top) : (y += 1) {
            var x: isize = self.left;
            while (x <= self.right) : (x += 1) {
                const p = .{ .x = x, .y = y };
                const c = self.get(p);
                if (c != null) {
                    std.debug.print("{?c}", .{c});
                } else {
                    std.debug.print(".", .{});
                }
            }
            std.debug.print("\n", .{});
        }
    }
};
