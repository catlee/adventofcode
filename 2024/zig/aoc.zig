const std = @import("std");

const Allocator = std.mem.Allocator;
const max_input_size = 1_000_000;

const HttpError = error{DownloadError};
const AocError = error{
    DownloadError,
    TokenError,
};

fn getSessionToken(alloc: Allocator) ![]const u8 {
    // Look in ENV for AOC_SESSION_TOKEN
    // Or in ~/.adventofcode.session
    if (std.posix.getenv("AOC_SESSION_TOKEN")) |token| {
        std.debug.print("Got {s} as the token\n", .{token});
        return token;
    }

    const home = std.posix.getenv("HOME") orelse "";
    var filenamebuf: [1000]u8 = undefined;
    const filename = try std.fmt.bufPrint(&filenamebuf, "{s}/.adventofcode.session", .{home});

    const token = try std.fs.cwd().readFileAlloc(alloc, filename, 1000);
    return token;
}

fn fetchInput(alloc: Allocator, year: u16, day: u8) ![]u8 {
    var client = std.http.Client{ .allocator = alloc };
    defer client.deinit();

    // Allocate a buffer for server headers
    var buf: [4096]u8 = undefined;

    // Start the HTTP request
    const url_str = try std.fmt.bufPrint(&buf, "https://adventofcode.com/{d}/day/{d}/input", .{ year, day });

    const uri = try std.Uri.parse(url_str);

    const token = try getSessionToken(alloc);
    defer alloc.free(token);

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

    var bbuffer: [1_000_000]u8 = undefined;
    const blength = try req.readAll(&bbuffer);

    if (@intFromEnum(req.response.status) >= 200 and @intFromEnum(req.response.status) <= 299) {
        return bbuffer[0..blength];
    } else {
        std.debug.print("Error fetching {s}\n", .{url_str});
        std.debug.print("status={d}\n", .{req.response.status});
        std.debug.print("{d} header bytes returned:\n{s}\n", .{ hlength, buf[0..hlength] });
        std.debug.print("{s}\n", .{bbuffer[0..blength]});
        return HttpError.DownloadError;
    }
}

pub fn getData(alloc: Allocator, year: u16, day: u8) ![]u8 {
    var pathbuf: [100]u8 = undefined;
    const file_path = try std.fmt.bufPrint(&pathbuf, "inputs/{d}-{:0>2}.txt", .{ year, day });

    std.debug.print("Reading file: {s}\n", .{file_path});

    return if (std.fs.cwd().readFileAlloc(alloc, file_path, max_input_size)) |data| {
        return data;
    } else |_| {
        if (fetchInput(alloc, year, day)) |data| {
            // Write to the file and then return the data
            std.debug.print("Writing to {s}\n", .{file_path});
            try std.fs.cwd().makePath("inputs");
            try std.fs.cwd().writeFile(.{ .sub_path = file_path, .data = data });
            return data;
        } else |err1| {
            std.debug.print("Error fetching input: {!}\n", .{err1});
        }
        return undefined;
    };
}

pub fn main() !void {
    // Create a general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    if (getData(alloc, 2024, 1)) |data| {
        std.debug.print("Got: {s}\n", .{data});
    } else |err| {
        std.debug.print("Error: {!}\n", .{err});
    }

    return;
}
