
const std = @import("std");

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "a+b" {
    try std.testing.expect(add(1, 2) == 3);
}

fn println_s(string: []const u8) void {
    std.debug.print("{s}\n", .{ string });
}

pub fn findFileWithExtension(
    allocator: std.mem.Allocator,
    absolute_path: []const u8,
    extension: []const u8,
) (std.fs.File.OpenError || std.fs.Dir.Iterator.Error || std.mem.Allocator.Error)!std.ArrayList(u8) {
    var dir = try std.fs.openDirAbsolute(absolute_path, .{ .iterate = true });
    defer dir.close();

    var collect = std.ArrayList(u8).init(allocator);

    var dir_iter = dir.iterate();
    while (dir_iter.next()) |i| {
        const entry = i orelse break;
        const is_file_with_extension = switch (entry.kind) {
            else => false,
            .file => std.mem.eql(u8, extension, std.fs.path.extension(entry.name)),
        };
        if (is_file_with_extension) {
            if (collect.items.len > 0) {
                try collect.appendSlice(", ");
            }
            try collect.appendSlice(entry.name);
        }
    } else |err| { return err; }
    return collect;
}

test "findFileWithExtension" {
    println_s("test findFileWithExtension =========================================================");
    const path = try std.fs.cwd().realpathAlloc(std.testing.allocator, "src");
    defer std.testing.allocator.free(path);
    std.debug.print("cwd: {s}\n", .{ path });

    const files = try findFileWithExtension(std.testing.allocator, path, ".zig");
    defer files.deinit();
    
    std.debug.print("files: {s}\n", .{ files.items });
    var iter = std.mem.splitSequence(u8, files.items, ", ");
    while (iter.next()) |i| {
        println_s(i);
    }
}