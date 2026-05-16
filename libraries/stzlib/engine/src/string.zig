// Softanza Engine -- String Operations (Tier 1)
//
// Replaces QString2 with pure Zig UTF-8 string handling.
// All functions use C ABI for Ring FFI compatibility.

const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;

const gpa = std.heap.c_allocator;
const unicode = @import("unicode.zig");

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

pub fn stz_string_index_of_from(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, start_byte: usize) callconv(.c) i64 {
    if (handle) |s| {
        if (needle == null or needle_len == 0) return -1;
        const haystack = s.slice();
        if (start_byte >= haystack.len) return -1;
        const n = needle[0..needle_len];
        if (mem.indexOf(u8, haystack[start_byte..], n)) |pos| {
            return @intCast(start_byte + pos);
        }
    }
    return -1;
}

pub fn stz_string_index_of_ci(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, start_byte: usize) callconv(.c) i64 {
    if (handle) |s| {
        if (needle == null or needle_len == 0) return -1;
        const hay = s.slice();
        if (start_byte >= hay.len) return -1;
        const n = needle[0..needle_len];

        var pos = start_byte;
        outer: while (pos + n.len <= hay.len) : (pos += 1) {
            for (0..n.len) |j| {
                if (toLowerAscii(hay[pos + j]) != toLowerAscii(n[j])) continue :outer;
            }
            return @intCast(pos);
        }
    }
    return -1;
}

pub fn stz_string_byte_to_cp(handle: StzStringHandle, byte_pos: usize) callconv(.c) i64 {
    if (handle) |s| {
        return unicode.stz_unicode_byte_to_cp(s.data.items.ptr, s.data.items.len, @intCast(byte_pos));
    }
    return -1;
}

pub fn stz_string_count_of(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) c_int {
    if (handle) |s| {
        if (needle == null or needle_len == 0) return 0;
        const hay = s.slice();
        const n = needle[0..needle_len];
        var count: c_int = 0;
        var pos: usize = 0;
        while (pos + n.len <= hay.len) {
            if (mem.eql(u8, hay[pos..][0..n.len], n)) {
                count += 1;
                pos += n.len;
            } else {
                pos += 1;
            }
        }
        return count;
    }
    return 0;
}

pub fn stz_string_replace_range(handle: StzStringHandle, start: usize, range: usize, new: [*c]const u8, new_len: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const hay = s.slice();
        const end = @min(start + range, hay.len);
        const result_len = start + new_len + (hay.len - end);
        const out = gpa.create(StzString) catch return null;
        out.* = StzString.init();
        out.data.ensureTotalCapacity(gpa, result_len) catch {
            out.deinit();
            gpa.destroy(out);
            return null;
        };
        out.data.appendSlice(gpa, hay[0..start]) catch unreachable;
        if (new != null and new_len > 0) {
            out.data.appendSlice(gpa, new[0..new_len]) catch unreachable;
        }
        if (end < hay.len) {
            out.data.appendSlice(gpa, hay[end..]) catch unreachable;
        }
        return out;
    }
    return null;
}

pub fn stz_string_split_count(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize) callconv(.c) c_int {
    if (handle) |s| {
        if (sep == null or sep_len == 0) return 1;
        const hay = s.slice();
        const d = sep[0..sep_len];
        var count: c_int = 1;
        var pos: usize = 0;
        while (pos + d.len <= hay.len) {
            if (mem.eql(u8, hay[pos..][0..d.len], d)) {
                count += 1;
                pos += d.len;
            } else {
                pos += 1;
            }
        }
        return count;
    }
    return 0;
}

pub fn stz_string_split_get(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize, index: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        if (sep == null or sep_len == 0 or index < 0) return null;
        const hay = s.slice();
        const d = sep[0..sep_len];
        const target: usize = @intCast(index);
        var part: usize = 0;
        var start: usize = 0;
        var pos: usize = 0;
        while (pos + d.len <= hay.len) {
            if (mem.eql(u8, hay[pos..][0..d.len], d)) {
                if (part == target) {
                    const out = gpa.create(StzString) catch return null;
                    out.* = StzString.init();
                    out.data.appendSlice(gpa, hay[start..pos]) catch {
                        out.deinit();
                        gpa.destroy(out);
                        return null;
                    };
                    return out;
                }
                part += 1;
                pos += d.len;
                start = pos;
            } else {
                pos += 1;
            }
        }
        if (part == target) {
            const out = gpa.create(StzString) catch return null;
            out.* = StzString.init();
            out.data.appendSlice(gpa, hay[start..]) catch {
                out.deinit();
                gpa.destroy(out);
                return null;
            };
            return out;
        }
    }
    return null;
}

fn toLowerAscii(c: u8) u8 {
    return if (c >= 'A' and c <= 'Z') c + 32 else c;
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

pub fn stz_string_count_of_ci(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) c_int {
    if (handle) |s| {
        if (needle == null or needle_len == 0) return 0;
        const hay = s.slice();
        const n = needle[0..needle_len];
        var count: c_int = 0;
        var pos: usize = 0;
        outer: while (pos + n.len <= hay.len) {
            for (0..n.len) |j| {
                if (toLowerAscii(hay[pos + j]) != toLowerAscii(n[j])) {
                    pos += 1;
                    continue :outer;
                }
            }
            count += 1;
            pos += n.len;
        }
        return count;
    }
    return 0;
}

pub fn stz_string_last_index_of_ci(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) i64 {
    if (handle) |s| {
        if (needle == null or needle_len == 0) return -1;
        const hay = s.slice();
        const n = needle[0..needle_len];
        if (n.len > hay.len) return -1;
        var pos: usize = hay.len - n.len;
        while (true) {
            var match = true;
            for (0..n.len) |j| {
                if (toLowerAscii(hay[pos + j]) != toLowerAscii(n[j])) {
                    match = false;
                    break;
                }
            }
            if (match) return @intCast(pos);
            if (pos == 0) break;
            pos -= 1;
        }
    }
    return -1;
}

pub fn stz_string_contains_ci(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) c_int {
    return if (stz_string_index_of_ci(handle, needle, needle_len, 0) >= 0) 1 else 0;
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

pub fn stz_string_starts_with_ci(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize) callconv(.c) c_int {
    if (handle) |s| {
        if (prefix == null or prefix_len == 0) return 1;
        const sl = s.slice();
        if (prefix_len > sl.len) return 0;
        const p = prefix[0..prefix_len];
        for (0..prefix_len) |i| {
            if (toLowerAscii(sl[i]) != toLowerAscii(p[i])) return 0;
        }
        return 1;
    }
    return 0;
}

pub fn stz_string_ends_with_ci(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize) callconv(.c) c_int {
    if (handle) |s| {
        if (suffix == null or suffix_len == 0) return 1;
        const sl = s.slice();
        if (suffix_len > sl.len) return 0;
        const start = sl.len - suffix_len;
        const sf = suffix[0..suffix_len];
        for (0..suffix_len) |i| {
            if (toLowerAscii(sl[start + i]) != toLowerAscii(sf[i])) return 0;
        }
        return 1;
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

pub fn stz_string_replace_ci(handle: StzStringHandle, old: [*c]const u8, old_len: usize, new: [*c]const u8, new_len: usize) callconv(.c) void {
    if (handle) |s| {
        if (old == null or old_len == 0) return;
        const old_slice = old[0..old_len];
        const new_slice = if (new != null and new_len > 0) new[0..new_len] else "";

        var result: std.ArrayList(u8) = .{};
        var pos: usize = 0;
        const src = s.slice();

        outer: while (pos <= src.len) {
            if (pos + old_len <= src.len) {
                // Case-insensitive comparison
                var matched = true;
                for (0..old_len) |j| {
                    if (toLowerAscii(src[pos + j]) != toLowerAscii(old_slice[j])) {
                        matched = false;
                        break;
                    }
                }
                if (matched) {
                    result.appendSlice(gpa, new_slice) catch return;
                    pos += old_len;
                    continue :outer;
                }
            }
            if (pos < src.len) {
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
        r.data.ensureTotalCapacity(gpa, src.len * 2) catch {};
        var buf: [64]u8 = undefined;
        const len = unicode.stz_unicode_to_upper_str(src.ptr, src.len, &buf, 64);
        if (len > 0 and len <= 64) {
            r.data.appendSlice(gpa, buf[0..len]) catch {};
        } else if (src.len > 0) {
            const big_buf = gpa.alloc(u8, src.len * 4) catch return r;
            defer gpa.free(big_buf);
            const big_len = unicode.stz_unicode_to_upper_str(src.ptr, src.len, big_buf.ptr, big_buf.len);
            if (big_len > 0) r.data.appendSlice(gpa, big_buf[0..big_len]) catch {};
        }
        return r;
    }
    return stz_string_new();
}

pub fn stz_string_to_lower(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const r = stz_string_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len * 2) catch {};
        var buf: [64]u8 = undefined;
        const len = unicode.stz_unicode_to_lower_str(src.ptr, src.len, &buf, 64);
        if (len > 0 and len <= 64) {
            r.data.appendSlice(gpa, buf[0..len]) catch {};
        } else if (src.len > 0) {
            const big_buf = gpa.alloc(u8, src.len * 4) catch return r;
            defer gpa.free(big_buf);
            const big_len = unicode.stz_unicode_to_lower_str(src.ptr, src.len, big_buf.ptr, big_buf.len);
            if (big_len > 0) r.data.appendSlice(gpa, big_buf[0..big_len]) catch {};
        }
        return r;
    }
    return stz_string_new();
}

// ─── Codepoint-aware Operations ───

pub fn stz_string_char_at(handle: StzStringHandle, cp_index: c_int) callconv(.c) i32 {
    if (handle) |s| {
        const byte_off = unicode.stz_unicode_cp_to_byte(s.data.items.ptr, s.data.items.len, cp_index);
        if (byte_off < 0) return -1;
        return unicode.stz_unicode_iterate(s.data.items.ptr, s.data.items.len, @intCast(byte_off));
    }
    return -1;
}

pub fn stz_string_mid_cp(handle: StzStringHandle, cp_start: c_int, cp_count: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const byte_start = unicode.stz_unicode_cp_to_byte(src.ptr, src.len, cp_start);
        if (byte_start < 0) return stz_string_new();
        const byte_end = unicode.stz_unicode_cp_to_byte(src.ptr, src.len, cp_start + cp_count);
        const end: usize = if (byte_end < 0) src.len else @intCast(byte_end);
        const start: usize = @intCast(byte_start);
        return stz_string_from(src[start..end].ptr, end - start);
    }
    return stz_string_new();
}

pub fn stz_string_left_cp(handle: StzStringHandle, cp_count: c_int) callconv(.c) StzStringHandle {
    return stz_string_mid_cp(handle, 0, cp_count);
}

pub fn stz_string_right_cp(handle: StzStringHandle, cp_count: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const total_cp = utf8CodepointCount(src);
        const start_cp: c_int = @intCast(total_cp -| @as(usize, @intCast(@max(cp_count, 0))));
        return stz_string_mid_cp(handle, start_cp, cp_count);
    }
    return stz_string_new();
}

pub fn stz_string_insert_cp(handle: StzStringHandle, cp_pos: c_int, utf8: [*c]const u8, len: usize) callconv(.c) void {
    if (handle) |s| {
        if (utf8 == null or len == 0) return;
        const byte_pos = unicode.stz_unicode_cp_to_byte(s.data.items.ptr, s.data.items.len, cp_pos);
        if (byte_pos < 0) return;
        s.data.insertSlice(gpa, @intCast(byte_pos), utf8[0..len]) catch {};
    }
}

pub fn stz_string_grapheme_count(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        return unicode.stz_unicode_grapheme_count(s.data.items.ptr, s.data.items.len);
    }
    return 0;
}

pub fn stz_string_normalize(handle: StzStringHandle, form: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        var out_len: usize = 0;
        const result = unicode.stz_unicode_normalize(s.data.items.ptr, s.data.items.len, form, &out_len);
        if (result == null or out_len == 0) return stz_string_new();
        defer unicode.stz_unicode_normalize_free(result, out_len);
        return stz_string_from(result, out_len);
    }
    return stz_string_new();
}

pub fn stz_string_strip_marks(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        var out_len: usize = 0;
        const result = unicode.stz_unicode_strip_marks(s.data.items.ptr, s.data.items.len, &out_len);
        if (result == null or out_len == 0) return stz_string_new();
        defer unicode.stz_unicode_strip_marks_free(result, out_len);
        return stz_string_from(result, out_len);
    }
    return stz_string_new();
}

pub fn stz_string_to_title(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const r = stz_string_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len * 2) catch {};
        const big_buf = gpa.alloc(u8, src.len * 4) catch return r;
        defer gpa.free(big_buf);
        const len = unicode.stz_unicode_to_title_str(src.ptr, src.len, big_buf.ptr, big_buf.len);
        if (len > 0) r.data.appendSlice(gpa, big_buf[0..len]) catch {};
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

test "string unicode case" {
    // Greek lowercase -> uppercase
    const s = stz_string_from("\xCE\xB1\xCE\xB2\xCE\xB3", 6);
    const upper = stz_string_to_upper(s);
    try std.testing.expectEqual(@as(usize, 6), stz_string_size(upper));
    try std.testing.expect(mem.eql(u8, stz_string_data(upper)[0..6], "\xCE\x91\xCE\x92\xCE\x93"));
    stz_string_free(upper);
    stz_string_free(s);
}

test "string char_at codepoint" {
    // "cafe\xCC\x81" = c(0x63) a(0x61) f(0x66) e-acute(0xE9 as 2 bytes)
    const s = stz_string_from("caf\xC3\xA9", 5);
    try std.testing.expectEqual(@as(i32, 'c'), stz_string_char_at(s, 0));
    try std.testing.expectEqual(@as(i32, 'a'), stz_string_char_at(s, 1));
    try std.testing.expectEqual(@as(i32, 'f'), stz_string_char_at(s, 2));
    try std.testing.expectEqual(@as(i32, 0xE9), stz_string_char_at(s, 3));
    try std.testing.expectEqual(@as(i32, -1), stz_string_char_at(s, 4));
    stz_string_free(s);
}

test "string mid_cp" {
    // "cafe\xCC\x81" (4 codepoints, 5 bytes)
    const s = stz_string_from("caf\xC3\xA9", 5);
    const mid = stz_string_mid_cp(s, 2, 2);
    try std.testing.expectEqual(@as(usize, 3), stz_string_size(mid));
    try std.testing.expect(mem.eql(u8, stz_string_data(mid)[0..3], "f\xC3\xA9"));
    stz_string_free(mid);
    stz_string_free(s);
}

test "string grapheme count" {
    // e + combining acute = 1 grapheme
    const s = stz_string_from("e\xCC\x81", 3);
    try std.testing.expectEqual(@as(usize, 2), stz_string_count(s)); // 2 codepoints
    try std.testing.expectEqual(@as(c_int, 1), stz_string_grapheme_count(s)); // 1 grapheme
    stz_string_free(s);
}

test "string normalize" {
    // NFD: e + combining acute -> NFC: e-acute
    const s = stz_string_from("e\xCC\x81", 3);
    const nfc = stz_string_normalize(s, 0);
    try std.testing.expectEqual(@as(usize, 2), stz_string_size(nfc));
    try std.testing.expect(mem.eql(u8, stz_string_data(nfc)[0..2], "\xC3\xA9"));
    stz_string_free(nfc);
    stz_string_free(s);
}

test "string strip marks" {
    const s = stz_string_from("\xC3\xA9", 2); // e-acute
    const stripped = stz_string_strip_marks(s);
    try std.testing.expectEqual(@as(usize, 1), stz_string_size(stripped));
    try std.testing.expect(mem.eql(u8, stz_string_data(stripped)[0..1], "e"));
    stz_string_free(stripped);
    stz_string_free(s);
}

test "string insert" {
    const s = stz_string_from("Helo", 4);
    stz_string_insert(s, 2, "l", 1);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(s));
    try std.testing.expect(mem.eql(u8, stz_string_data(s)[0..5], "Hello"));
    stz_string_free(s);
}

test "string index_of_from" {
    const s = stz_string_from("abcabcabc", 9);
    try std.testing.expectEqual(@as(i64, 0), stz_string_index_of_from(s, "abc", 3, 0));
    try std.testing.expectEqual(@as(i64, 3), stz_string_index_of_from(s, "abc", 3, 1));
    try std.testing.expectEqual(@as(i64, 6), stz_string_index_of_from(s, "abc", 3, 4));
    try std.testing.expectEqual(@as(i64, -1), stz_string_index_of_from(s, "abc", 3, 7));
    stz_string_free(s);
}

test "string index_of_ci" {
    const s = stz_string_from("Hello WORLD", 11);
    try std.testing.expectEqual(@as(i64, 0), stz_string_index_of_ci(s, "hello", 5, 0));
    try std.testing.expectEqual(@as(i64, 6), stz_string_index_of_ci(s, "world", 5, 0));
    try std.testing.expectEqual(@as(i64, -1), stz_string_index_of_ci(s, "xyz", 3, 0));
    try std.testing.expectEqual(@as(i64, 6), stz_string_index_of_ci(s, "WORLD", 5, 3));
    stz_string_free(s);
}

test "string count_of_ci" {
    const s = stz_string_from("Hello hello HELLO hElLo", 23);
    try std.testing.expectEqual(@as(c_int, 4), stz_string_count_of_ci(s, "hello", 5));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_count_of_ci(s, "xyz", 3));
    stz_string_free(s);
}

test "string last_index_of_ci" {
    const s = stz_string_from("abc-ABC-Abc", 11);
    try std.testing.expectEqual(@as(i64, 8), stz_string_last_index_of_ci(s, "abc", 3));
    try std.testing.expectEqual(@as(i64, -1), stz_string_last_index_of_ci(s, "xyz", 3));
    stz_string_free(s);
}

test "string starts_with_ci" {
    const s = stz_string_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_starts_with_ci(s, "hello", 5));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_starts_with_ci(s, "HELLO", 5));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_starts_with_ci(s, "world", 5));
    stz_string_free(s);
}

test "string ends_with_ci" {
    const s = stz_string_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_ends_with_ci(s, "world", 5));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_ends_with_ci(s, "WORLD", 5));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_ends_with_ci(s, "hello", 5));
    stz_string_free(s);
}

test "string contains_ci" {
    const s = stz_string_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_contains_ci(s, "WORLD", 5));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_contains_ci(s, "hello", 5));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_contains_ci(s, "xyz", 3));
    stz_string_free(s);
}

test "string replace_ci" {
    const s = stz_string_from("Hello hello HELLO", 17);
    stz_string_replace_ci(s, "hello", 5, "hi", 2);
    try std.testing.expectEqual(@as(usize, 8), stz_string_size(s));
    try std.testing.expect(mem.eql(u8, stz_string_data(s)[0..8], "hi hi hi"));
    stz_string_free(s);
}

test "string count_of" {
    const s = stz_string_from("abcabcabc", 9);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_count_of(s, "abc", 3));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_count_of(s, "xyz", 3));
    stz_string_free(s);
}

test "string byte_to_cp" {
    // "caf\xC3\xA9" = c(0) a(1) f(2) e-acute(3,4 bytes -> cp 3)
    const s = stz_string_from("caf\xC3\xA9", 5);
    try std.testing.expectEqual(@as(i64, 0), stz_string_byte_to_cp(s, 0));
    try std.testing.expectEqual(@as(i64, 1), stz_string_byte_to_cp(s, 1));
    try std.testing.expectEqual(@as(i64, 2), stz_string_byte_to_cp(s, 2));
    try std.testing.expectEqual(@as(i64, 3), stz_string_byte_to_cp(s, 3));
    stz_string_free(s);
}

test "string replace_range" {
    const s = stz_string_from("Hello World", 11);
    const r = stz_string_replace_range(s, 5, 1, "_beautiful_", 11);
    try std.testing.expectEqual(@as(usize, 21), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..21], "Hello_beautiful_World"));
    stz_string_free(r);
    stz_string_free(s);
}

test "string replace_range at edges" {
    const s = stz_string_from("abc", 3);
    const r1 = stz_string_replace_range(s, 0, 1, "X", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..3], "Xbc"));
    stz_string_free(r1);
    const r2 = stz_string_replace_range(s, 2, 1, "Z", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..3], "abZ"));
    stz_string_free(r2);
    stz_string_free(s);
}

test "string split_count" {
    const s = stz_string_from("a:b:c", 5);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_split_count(s, ":", 1));
    stz_string_free(s);
}

test "string split_get" {
    const s = stz_string_from("one::two::three", 15);
    const p0 = stz_string_split_get(s, "::", 2, 0);
    try std.testing.expect(mem.eql(u8, stz_string_data(p0)[0..stz_string_size(p0)], "one"));
    stz_string_free(p0);
    const p1 = stz_string_split_get(s, "::", 2, 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(p1)[0..stz_string_size(p1)], "two"));
    stz_string_free(p1);
    const p2 = stz_string_split_get(s, "::", 2, 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(p2)[0..stz_string_size(p2)], "three"));
    stz_string_free(p2);
    stz_string_free(s);
}
