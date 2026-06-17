// Softanza Engine -- File Operations (Tier 2)
//
// Replaces QFile, QDir, QFileInfo with Zig std.fs.
// All functions use C ABI for Ring FFI compatibility.
// Paths are UTF-8 encoded.

const std = @import("std");
const fs = std.fs;
const mem = std.mem;

const gpa = std.heap.c_allocator;

// ─── File Info ───

pub fn stz_file_exists(path: [*c]const u8, path_len: usize) callconv(.c) c_int {
    if (path == null or path_len == 0) return 0;
    const p = path[0..path_len];
    const stat = fs.cwd().statFile(p) catch return 0;
    _ = stat;
    return 1;
}

pub fn stz_file_size(path: [*c]const u8, path_len: usize) callconv(.c) i64 {
    if (path == null or path_len == 0) return -1;
    const p = path[0..path_len];
    const stat = fs.cwd().statFile(p) catch return -1;
    return @intCast(stat.size);
}

// Last-modification time as Unix epoch SECONDS (-1 if the file is missing).
// stat.mtime is nanoseconds since the epoch; Ring formats it via
// stzDateTime([:FromEpochSeconds=...]).
pub fn stz_file_mtime(path: [*c]const u8, path_len: usize) callconv(.c) i64 {
    if (path == null or path_len == 0) return -1;
    const p = path[0..path_len];
    const stat = fs.cwd().statFile(p) catch return -1;
    return @intCast(@divFloor(stat.mtime, std.time.ns_per_s));
}

// ─── File Read ───

pub fn stz_file_read(path: [*c]const u8, path_len: usize, out_len: *usize) callconv(.c) [*c]u8 {
    if (path == null or path_len == 0) {
        out_len.* = 0;
        return null;
    }
    const p = path[0..path_len];
    const data = fs.cwd().readFileAlloc(gpa, p, 64 * 1024 * 1024) catch {
        out_len.* = 0;
        return null;
    };
    out_len.* = data.len;
    return data.ptr;
}

pub fn stz_file_read_free(ptr: [*c]u8, len: usize) callconv(.c) void {
    if (ptr != null and len > 0) {
        gpa.free(ptr[0..len]);
    }
}

// ─── File Write ───

pub fn stz_file_write(path: [*c]const u8, path_len: usize, data: [*c]const u8, data_len: usize) callconv(.c) c_int {
    if (path == null or path_len == 0) return 0;
    const p = path[0..path_len];
    const content = if (data != null and data_len > 0) data[0..data_len] else "";
    const file = fs.cwd().createFile(p, .{}) catch return 0;
    defer file.close();
    file.writeAll(content) catch return 0;
    return 1;
}

pub fn stz_file_append(path: [*c]const u8, path_len: usize, data: [*c]const u8, data_len: usize) callconv(.c) c_int {
    if (path == null or path_len == 0) return 0;
    if (data == null or data_len == 0) return 1;
    const p = path[0..path_len];
    const file = fs.cwd().openFile(p, .{ .mode = .write_only }) catch {
        const new_file = fs.cwd().createFile(p, .{}) catch return 0;
        defer new_file.close();
        new_file.writeAll(data[0..data_len]) catch return 0;
        return 1;
    };
    defer file.close();
    file.seekFromEnd(0) catch return 0;
    file.writeAll(data[0..data_len]) catch return 0;
    return 1;
}

// ─── File Delete ───

pub fn stz_file_delete(path: [*c]const u8, path_len: usize) callconv(.c) c_int {
    if (path == null or path_len == 0) return 0;
    const p = path[0..path_len];
    fs.cwd().deleteFile(p) catch return 0;
    return 1;
}

// ─── File Copy ───

pub fn stz_file_copy(src: [*c]const u8, src_len: usize, dst: [*c]const u8, dst_len: usize) callconv(.c) c_int {
    if (src == null or src_len == 0 or dst == null or dst_len == 0) return 0;
    const s = src[0..src_len];
    const d = dst[0..dst_len];
    fs.cwd().copyFile(s, fs.cwd(), d, .{}) catch return 0;
    return 1;
}

// ─── Directory ───

pub fn stz_dir_exists(path: [*c]const u8, path_len: usize) callconv(.c) c_int {
    if (path == null or path_len == 0) return 0;
    const p = path[0..path_len];
    var dir = fs.cwd().openDir(p, .{}) catch return 0;
    dir.close();
    return 1;
}

pub fn stz_dir_create(path: [*c]const u8, path_len: usize) callconv(.c) c_int {
    if (path == null or path_len == 0) return 0;
    const p = path[0..path_len];
    fs.cwd().makeDir(p) catch return 0;
    return 1;
}

pub fn stz_dir_create_path(path: [*c]const u8, path_len: usize) callconv(.c) c_int {
    if (path == null or path_len == 0) return 0;
    const p = path[0..path_len];
    fs.cwd().makePath(p) catch return 0;
    return 1;
}

pub fn stz_dir_delete(path: [*c]const u8, path_len: usize) callconv(.c) c_int {
    if (path == null or path_len == 0) return 0;
    const p = path[0..path_len];
    fs.cwd().deleteDir(p) catch return 0;
    return 1;
}

// ─── Directory Counting ───

pub fn stz_dir_count_files(path: [*c]const u8, path_len: usize) callconv(.c) i32 {
    if (path == null or path_len == 0) return -1;
    const p = path[0..path_len];
    var dir = fs.cwd().openDir(p, .{ .iterate = true }) catch return -1;
    defer dir.close();
    var count: i32 = 0;
    var it = dir.iterate();
    while (it.next() catch null) |entry| {
        if (entry.kind == .file) count += 1;
    }
    return count;
}

pub fn stz_dir_count_dirs(path: [*c]const u8, path_len: usize) callconv(.c) i32 {
    if (path == null or path_len == 0) return -1;
    const p = path[0..path_len];
    var dir = fs.cwd().openDir(p, .{ .iterate = true }) catch return -1;
    defer dir.close();
    var count: i32 = 0;
    var it = dir.iterate();
    while (it.next() catch null) |entry| {
        if (entry.kind == .directory) count += 1;
    }
    return count;
}

// ─── Path Utilities ───

pub fn stz_path_extension(path: [*c]const u8, path_len: usize, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (path == null or path_len == 0) return 0;
    const p = path[0..path_len];
    // Find last dot after last separator
    var last_dot: ?usize = null;
    var last_sep: usize = 0;
    for (p, 0..) |c, i| {
        if (c == '/' or c == '\\') last_sep = i + 1;
        if (c == '.') last_dot = i;
    }
    const dot = last_dot orelse return 0;
    if (dot < last_sep) return 0;
    const ext = p[dot..];
    if (ext.len > buf_len) return 0;
    @memcpy(buf[0..ext.len], ext);
    return ext.len;
}

pub fn stz_path_basename(path: [*c]const u8, path_len: usize, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (path == null or path_len == 0) return 0;
    const p = path[0..path_len];
    // Find last separator (either / or \)
    var last_sep: usize = 0;
    var found = false;
    for (p, 0..) |c, i| {
        if (c == '/' or c == '\\') {
            last_sep = i + 1;
            found = true;
        }
    }
    const start = if (found) last_sep else 0;
    const base = p[start..];
    if (base.len > buf_len) return 0;
    @memcpy(buf[0..base.len], base);
    return base.len;
}

pub fn stz_path_dirname(path: [*c]const u8, path_len: usize, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (path == null or path_len == 0) return 0;
    const p = path[0..path_len];
    // Find last separator
    var last_sep: ?usize = null;
    for (p, 0..) |c, i| {
        if (c == '/' or c == '\\') last_sep = i;
    }
    const sep = last_sep orelse return 0;
    if (sep > buf_len) return 0;
    @memcpy(buf[0..sep], p[0..sep]);
    return sep;
}

// ─── Tests ───

test "file write and read" {
    const test_path = "stz_test_file.tmp";

    const ok_write = stz_file_write(test_path, test_path.len, "Hello Engine", 12);
    try std.testing.expectEqual(@as(c_int, 1), ok_write);

    try std.testing.expectEqual(@as(c_int, 1), stz_file_exists(test_path, test_path.len));
    try std.testing.expectEqual(@as(i64, 12), stz_file_size(test_path, test_path.len));

    var out_len: usize = 0;
    const data = stz_file_read(test_path, test_path.len, &out_len);
    try std.testing.expectEqual(@as(usize, 12), out_len);
    try std.testing.expect(mem.eql(u8, data[0..out_len], "Hello Engine"));
    stz_file_read_free(data, out_len);

    const ok_del = stz_file_delete(test_path, test_path.len);
    try std.testing.expectEqual(@as(c_int, 1), ok_del);
    try std.testing.expectEqual(@as(c_int, 0), stz_file_exists(test_path, test_path.len));
}

test "file append" {
    const test_path = "stz_test_append.tmp";
    _ = stz_file_write(test_path, test_path.len, "Hello", 5);
    _ = stz_file_append(test_path, test_path.len, " World", 6);

    var out_len: usize = 0;
    const data = stz_file_read(test_path, test_path.len, &out_len);
    try std.testing.expectEqual(@as(usize, 11), out_len);
    try std.testing.expect(mem.eql(u8, data[0..out_len], "Hello World"));
    stz_file_read_free(data, out_len);

    _ = stz_file_delete(test_path, test_path.len);
}

test "dir operations" {
    const test_dir = "stz_test_dir_tmp";

    try std.testing.expectEqual(@as(c_int, 1), stz_dir_create(test_dir, test_dir.len));
    try std.testing.expectEqual(@as(c_int, 1), stz_dir_exists(test_dir, test_dir.len));

    // Create a file inside
    const inner_path = "stz_test_dir_tmp/inner.txt";
    _ = stz_file_write(inner_path, inner_path.len, "test", 4);
    try std.testing.expectEqual(@as(i32, 1), stz_dir_count_files(test_dir, test_dir.len));
    try std.testing.expectEqual(@as(i32, 0), stz_dir_count_dirs(test_dir, test_dir.len));

    _ = stz_file_delete(inner_path, inner_path.len);
    try std.testing.expectEqual(@as(c_int, 1), stz_dir_delete(test_dir, test_dir.len));
    try std.testing.expectEqual(@as(c_int, 0), stz_dir_exists(test_dir, test_dir.len));
}

test "path utilities" {
    var buf: [256]u8 = undefined;

    const ext_len = stz_path_extension("document.txt", 12, &buf, 256);
    try std.testing.expect(mem.eql(u8, buf[0..ext_len], ".txt"));

    // Our path functions handle both / and \ on all platforms
    const fwd = "path/to/file.zig";
    const base_len = stz_path_basename(fwd, fwd.len, &buf, 256);
    try std.testing.expect(mem.eql(u8, buf[0..base_len], "file.zig"));

    const dir_len = stz_path_dirname(fwd, fwd.len, &buf, 256);
    try std.testing.expect(mem.eql(u8, buf[0..dir_len], "path/to"));

    // Backslash variant
    const bck = "path\\to\\file.zig";
    const base_len2 = stz_path_basename(bck, bck.len, &buf, 256);
    try std.testing.expect(mem.eql(u8, buf[0..base_len2], "file.zig"));
}

test "nonexistent file" {
    try std.testing.expectEqual(@as(c_int, 0), stz_file_exists("no_such_file_xyz.tmp", 20));
    try std.testing.expectEqual(@as(i64, -1), stz_file_size("no_such_file_xyz.tmp", 20));
}
