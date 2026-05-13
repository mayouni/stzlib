// Softanza Engine -- String Operations (Tier 1)
//
// Replaces QString2 with pure Zig UTF-8 string handling.
// All functions use C ABI for Ring FFI compatibility.

const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;

const gpa = std.heap.c_allocator;

pub const StzStringHandle = ?*StzString;

const StzString = struct {
    data: std.ArrayList(u8),

    fn init() StzString {
        return .{ .data = .{} };
    }

    fn deinit(self: *StzString) void {
        self.data.deinit(gpa);
    }

    fn slice(self: *const StzString) []const u8 {
        return self.data.items;
    }
};

// ─── Lifecycle ───

pub fn stz_string_new() callconv(.c) StzStringHandle {
    const s = gpa.create(StzString) catch return null;
    s.* = StzString.init();
    return s;
}

pub fn stz_string_from(utf8: [*c]const u8, len: usize) callconv(.c) StzStringHandle {
    const s = gpa.create(StzString) catch return null;
    s.* = StzString.init();
    if (utf8 != null and len > 0) {
        const src: []const u8 = utf8[0..len];
        s.data.appendSlice(gpa, src) catch {
            s.deinit();
            gpa.destroy(s);
            return null;
        };
    }
    return s;
}

pub fn stz_string_free(handle: StzStringHandle) callconv(.c) void {
    if (handle) |s| {
        s.deinit();
        gpa.destroy(s);
    }
}

// ─── Content ───

pub fn stz_string_data(handle: StzStringHandle) callconv(.c) [*c]const u8 {
    if (handle) |s| {
        if (s.data.items.len == 0) return "";
        return s.data.items.ptr;
    }
    return "";
}

pub fn stz_string_size(handle: StzStringHandle) callconv(.c) usize {
    if (handle) |s| return s.data.items.len;
    return 0;
}

pub fn stz_string_count(handle: StzStringHandle) callconv(.c) usize {
    if (handle) |s| {
        return utf8CodepointCount(s.slice());
    }
    return 0;
}

// ─── Mutation ───

pub fn stz_string_append(handle: StzStringHandle, utf8: [*c]const u8, len: usize) callconv(.c) void {
    if (handle) |s| {
        if (utf8 != null and len > 0) {
            s.data.appendSlice(gpa, utf8[0..len]) catch {};
        }
    }
}

pub fn stz_string_insert(handle: StzStringHandle, byte_pos: usize, utf8: [*c]const u8, len: usize) callconv(.c) void {
    if (handle) |s| {
        if (utf8 == null or len == 0) return;
        const pos = @min(byte_pos, s.data.items.len);
        s.data.insertSlice(gpa, pos, utf8[0..len]) catch {};
    }
}

// ─── Extraction ───

pub fn stz_string_mid(handle: StzStringHandle, start: usize, length: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const sl = s.slice();
        if (start >= sl.len) return stz_string_new();
        const end = @min(start + length, sl.len);
        return stz_string_from(sl[start..end].ptr, end - start);
    }
    return stz_string_new();
}

pub fn stz_string_left(handle: StzStringHandle, length: usize) callconv(.c) StzStringHandle {
    return stz_string_mid(handle, 0, length);
}

pub fn stz_string_right(handle: StzStringHandle, length: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const sl = s.slice();
        if (length >= sl.len) return stz_string_from(sl.ptr, sl.len);
        const start = sl.len - length;
        return stz_string_from(sl[start..].ptr, length);
    }
    return stz_string_new();
}

pub fn stz_string_trimmed(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const trimmed = mem.trim(u8, s.slice(), " \t\n\r");
        return stz_string_from(trimmed.ptr, trimmed.len);
    }
    return stz_string_new();
}

// ─── Search ───

pub fn stz_string_index_of(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) i64 {
    if (handle) |s| {
        if (needle == null or needle_len == 0) return -1;
        const haystack = s.slice();
        const n = needle[0..needle_len];
        if (mem.indexOf(u8, haystack, n)) |pos| {
            return @intCast(pos);
        }
    }
    return -1;
}

pub fn stz_string_last_index_of(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) i64 {
    if (handle) |s| {
        if (needle == null or needle_len == 0) return -1;
        const haystack = s.slice();
        const n = needle[0..needle_len];
        if (mem.lastIndexOf(u8, haystack, n)) |pos| {
            return @intCast(pos);
        }
    }
    return -1;
}

pub fn stz_string_contains(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) c_int {
    return if (stz_string_index_of(handle, needle, needle_len) >= 0) 1 else 0;
}

pub fn stz_string_starts_with(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize) callconv(.c) c_int {
    if (handle) |s| {
        if (prefix == null or prefix_len == 0) return 1;
        const sl = s.slice();
        if (prefix_len > sl.len) return 0;
        return if (mem.eql(u8, sl[0..prefix_len], prefix[0..prefix_len])) 1 else 0;
    }
    return 0;
}

pub fn stz_string_ends_with(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize) callconv(.c) c_int {
    if (handle) |s| {
        if (suffix == null or suffix_len == 0) return 1;
        const sl = s.slice();
        if (suffix_len > sl.len) return 0;
        const start = sl.len - suffix_len;
        return if (mem.eql(u8, sl[start..], suffix[0..suffix_len])) 1 else 0;
    }
    return 0;
}

// ─── Transform ───

pub fn stz_string_replace(handle: StzStringHandle, old: [*c]const u8, old_len: usize, new: [*c]const u8, new_len: usize) callconv(.c) void {
    if (handle) |s| {
        if (old == null or old_len == 0) return;
        const old_slice = old[0..old_len];
        const new_slice = if (new != null and new_len > 0) new[0..new_len] else "";

        var result: std.ArrayList(u8) = .{};
        var pos: usize = 0;
        const src = s.slice();

        while (pos <= src.len) {
            if (pos + old_len <= src.len and mem.eql(u8, src[pos..][0..old_len], old_slice)) {
                result.appendSlice(gpa, new_slice) catch return;
                pos += old_len;
            } else if (pos < src.len) {
                result.append(gpa, src[pos]) catch return;
                pos += 1;
            } else {
                break;
            }
        }

        s.data.deinit(gpa);
        s.data = result;
    }
}

pub fn stz_string_to_upper(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const r = stz_string_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len) catch {};
        for (src) |byte| {
            r.data.append(gpa, std.ascii.toUpper(byte)) catch {};
        }
        return r;
    }
    return stz_string_new();
}

pub fn stz_string_to_lower(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const r = stz_string_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len) catch {};
        for (src) |byte| {
            r.data.append(gpa, std.ascii.toLower(byte)) catch {};
        }
        return r;
    }
    return stz_string_new();
}

// ─── Helpers ───

fn utf8CodepointCount(bytes: []const u8) usize {
    var count: usize = 0;
    var i: usize = 0;
    while (i < bytes.len) {
        const byte = bytes[i];
        const cp_len = std.unicode.utf8ByteSequenceLength(byte) catch 1;
        count += 1;
        i += cp_len;
    }
    return count;
}

// ─── Tests ───

test "string lifecycle" {
    const s = stz_string_new();
    try std.testing.expect(s != null);
    try std.testing.expectEqual(@as(usize, 0), stz_string_size(s));

    stz_string_append(s, "Hello", 5);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(s));

    stz_string_append(s, " World", 6);
    try std.testing.expectEqual(@as(usize, 11), stz_string_size(s));

    stz_string_free(s);
}

test "string from" {
    const s = stz_string_from("Softanza", 8);
    try std.testing.expect(s != null);
    try std.testing.expectEqual(@as(usize, 8), stz_string_size(s));
    try std.testing.expectEqual(@as(usize, 8), stz_string_count(s));

    const data = stz_string_data(s);
    try std.testing.expect(mem.eql(u8, data[0..8], "Softanza"));

    stz_string_free(s);
}

test "string unicode count" {
    const s = stz_string_from("caf\xC3\xA9", 5);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(s));
    try std.testing.expectEqual(@as(usize, 4), stz_string_count(s));
    stz_string_free(s);
}

test "string search" {
    const s = stz_string_from("Hello Ring World", 16);

    try std.testing.expectEqual(@as(i64, 6), stz_string_index_of(s, "Ring", 4));
    try std.testing.expectEqual(@as(i64, -1), stz_string_index_of(s, "Zig", 3));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_contains(s, "World", 5));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_starts_with(s, "Hello", 5));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_ends_with(s, "World", 5));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_starts_with(s, "Ring", 4));

    stz_string_free(s);
}

test "string mid/left/right" {
    const s = stz_string_from("Softanza", 8);

    const mid = stz_string_mid(s, 4, 4);
    try std.testing.expect(mem.eql(u8, stz_string_data(mid)[0..4], "anza"));
    stz_string_free(mid);

    const left = stz_string_left(s, 4);
    try std.testing.expect(mem.eql(u8, stz_string_data(left)[0..4], "Soft"));
    stz_string_free(left);

    const right = stz_string_right(s, 4);
    try std.testing.expect(mem.eql(u8, stz_string_data(right)[0..4], "anza"));
    stz_string_free(right);

    stz_string_free(s);
}

test "string replace" {
    const s = stz_string_from("Hello Qt World", 14);
    stz_string_replace(s, "Qt", 2, "Zig", 3);
    try std.testing.expectEqual(@as(usize, 15), stz_string_size(s));
    try std.testing.expect(mem.eql(u8, stz_string_data(s)[0..15], "Hello Zig World"));
    stz_string_free(s);
}

test "string trimmed" {
    const s = stz_string_from("  hello  ", 9);
    const trimmed = stz_string_trimmed(s);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(trimmed));
    try std.testing.expect(mem.eql(u8, stz_string_data(trimmed)[0..5], "hello"));
    stz_string_free(trimmed);
    stz_string_free(s);
}

test "string case" {
    const s = stz_string_from("Hello", 5);

    const upper = stz_string_to_upper(s);
    try std.testing.expect(mem.eql(u8, stz_string_data(upper)[0..5], "HELLO"));
    stz_string_free(upper);

    const lower = stz_string_to_lower(s);
    try std.testing.expect(mem.eql(u8, stz_string_data(lower)[0..5], "hello"));
    stz_string_free(lower);

    stz_string_free(s);
}

test "string insert" {
    const s = stz_string_from("Helo", 4);
    stz_string_insert(s, 2, "l", 1);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(s));
    try std.testing.expect(mem.eql(u8, stz_string_data(s)[0..5], "Hello"));
    stz_string_free(s);
}
