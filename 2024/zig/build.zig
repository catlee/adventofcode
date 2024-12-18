const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const alloc = std.heap.page_allocator;

    var walker = (std.fs.cwd().openDir(".", .{ .iterate = true }) catch unreachable).walk(alloc) catch unreachable;
    defer walker.deinit();
    while (walker.next() catch unreachable) |entry| {
        if (entry.kind == std.fs.File.Kind.file and std.mem.eql(u8, entry.basename[0..3], "day")) {
            const dot_index = std.mem.indexOfScalar(u8, entry.basename, '.') orelse continue;
            const day_number = entry.basename[3..dot_index];

            const unit_tests = b.addTest(.{
                .root_source_file = b.path(entry.basename),
                .test_runner = b.path("test_runner.zig"),
                .target = target,
                .optimize = optimize,
            });

            const run_unit_tests = b.addRunArtifact(unit_tests);
            var buffer: [30]u8 = undefined;
            const test_name = std.fmt.bufPrint(&buffer, "Run day {s} tests", .{day_number}) catch unreachable;
            const test_step = b.step(day_number, test_name);
            test_step.dependOn(&run_unit_tests.step);
        }
    }
}
