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

// ─── Codepoint-aware Extraction ───

/// Get nth char (0-based codepoint index). Returns new handle with that single codepoint.
pub fn stz_string_nth_char(handle: StzStringHandle, cp_index: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const hay = s.slice();
        var byte_pos: usize = 0;
        var cp: usize = 0;
        while (byte_pos < hay.len and cp < cp_index) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp += 1;
        }
        if (byte_pos < hay.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            return stz_string_from(hay[byte_pos..].ptr, cp_len);
        }
    }
    return stz_string_new();
}

/// Extract substring by codepoint range [start_cp, start_cp + cp_count).
/// Both parameters are 0-based codepoint indices.
pub fn stz_string_slice(handle: StzStringHandle, start_cp: usize, cp_count: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const hay = s.slice();
        // Find byte start
        var byte_pos: usize = 0;
        var cp: usize = 0;
        while (byte_pos < hay.len and cp < start_cp) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp += 1;
        }
        const byte_start = byte_pos;
        // Find byte end
        var count: usize = 0;
        while (byte_pos < hay.len and count < cp_count) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            count += 1;
        }
        return stz_string_from(hay[byte_start..byte_pos].ptr, byte_pos - byte_start);
    }
    return stz_string_new();
}

/// Get all chars as an array of handles. Caller must free each handle and the array.
/// Returns count via out parameter. Array allocated with c_allocator.
pub fn stz_string_chars(handle: StzStringHandle, out_count: *usize) callconv(.c) [*c]StzStringHandle {
    if (handle) |s| {
        const hay = s.slice();
        const n = utf8CodepointCount(hay);
        out_count.* = n;
        if (n == 0) return null;
        const arr = gpa.alloc(StzStringHandle, n) catch return null;
        var byte_pos: usize = 0;
        var i: usize = 0;
        while (byte_pos < hay.len and i < n) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            arr[i] = stz_string_from(hay[byte_pos..].ptr, cp_len);
            byte_pos += cp_len;
            i += 1;
        }
        return arr.ptr;
    }
    out_count.* = 0;
    return null;
}

/// Free an array of string handles returned by stz_string_chars.
pub fn stz_string_chars_free(arr: [*c]StzStringHandle, count: usize) callconv(.c) void {
    if (arr == null) return;
    for (0..count) |i| {
        stz_string_free(arr[i]);
    }
    gpa.free(arr[0..count]);
}

// ─── Search ───

pub fn stz_string_index_of(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) i64 {
    if (handle) |s| {
        if (needle == null or needle_len == 0) return -1;
        const hay = s.slice();
        const n = needle[0..needle_len];
        // Walk by codepoints, return codepoint index (0-based)
        var byte_pos: usize = 0;
        var cp_pos: usize = 0;
        while (byte_pos + n.len <= hay.len) {
            if (mem.eql(u8, hay[byte_pos..][0..n.len], n)) {
                return @intCast(cp_pos);
            }
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp_pos += 1;
        }
    }
    return -1;
}

pub fn stz_string_index_of_from(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, start_cp: usize) callconv(.c) i64 {
    // start_cp is a 0-based codepoint index
    if (handle) |s| {
        if (needle == null or needle_len == 0) return -1;
        const hay = s.slice();
        const n = needle[0..needle_len];
        // Skip to start_cp codepoint
        var byte_pos: usize = 0;
        var cp_pos: usize = 0;
        while (cp_pos < start_cp and byte_pos < hay.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp_pos += 1;
        }
        // Search from here
        while (byte_pos + n.len <= hay.len) {
            if (mem.eql(u8, hay[byte_pos..][0..n.len], n)) {
                return @intCast(cp_pos);
            }
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp_pos += 1;
        }
    }
    return -1;
}

pub fn stz_string_index_of_ci(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, start_cp: usize) callconv(.c) i64 {
    // start_cp is a 0-based codepoint index
    if (handle) |s| {
        if (needle == null or needle_len == 0) return -1;
        const hay = s.slice();
        const n = needle[0..needle_len];
        // Skip to start_cp codepoint
        var byte_pos: usize = 0;
        var cp_pos: usize = 0;
        while (cp_pos < start_cp and byte_pos < hay.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp_pos += 1;
        }
        // Search from here (case-insensitive)
        while (byte_pos + n.len <= hay.len) {
            var match = true;
            for (0..n.len) |j| {
                if (toLowerAscii(hay[byte_pos + j]) != toLowerAscii(n[j])) {
                    match = false;
                    break;
                }
            }
            if (match) return @intCast(cp_pos);
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp_pos += 1;
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

// ─── Bulk Find (returns all positions in one call) ───

const StzFindResult = struct {
    positions: std.ArrayList(i64),

    fn init() StzFindResult {
        return .{ .positions = .{} };
    }

    fn deinit(self: *StzFindResult) void {
        self.positions.deinit(gpa);
    }
};

pub const StzFindResultHandle = ?*StzFindResult;

pub fn stz_string_find_all(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) StzFindResultHandle {
    const r = gpa.create(StzFindResult) catch return null;
    r.* = StzFindResult.init();
    if (handle) |s| {
        if (needle == null or needle_len == 0) return r;
        const hay = s.slice();
        const n = needle[0..needle_len];
        // Walk by codepoints to return codepoint-based positions
        var byte_pos: usize = 0;
        var cp_pos: usize = 0;
        while (byte_pos + n.len <= hay.len) {
            if (mem.eql(u8, hay[byte_pos..][0..n.len], n)) {
                r.positions.append(gpa, @intCast(cp_pos)) catch break;
            }
            // Advance by one codepoint
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp_pos += 1;
        }
    }
    return r;
}

pub fn stz_string_find_all_ci(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) StzFindResultHandle {
    const r = gpa.create(StzFindResult) catch return null;
    r.* = StzFindResult.init();
    if (handle) |s| {
        if (needle == null or needle_len == 0) return r;
        const hay = s.slice();
        const n = needle[0..needle_len];
        // Walk by codepoints to return codepoint-based positions
        var byte_pos: usize = 0;
        var cp_pos: usize = 0;
        while (byte_pos + n.len <= hay.len) {
            var match = true;
            for (0..n.len) |j| {
                if (toLowerAscii(hay[byte_pos + j]) != toLowerAscii(n[j])) {
                    match = false;
                    break;
                }
            }
            if (match) {
                r.positions.append(gpa, @intCast(cp_pos)) catch break;
            }
            // Advance by one codepoint
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp_pos += 1;
        }
    }
    return r;
}

pub fn stz_find_result_count(result: StzFindResultHandle) callconv(.c) c_int {
    if (result) |r| return @intCast(r.positions.items.len);
    return 0;
}

pub fn stz_find_result_get(result: StzFindResultHandle, index: c_int) callconv(.c) i64 {
    if (result) |r| {
        const i: usize = @intCast(@max(index, 0));
        if (i < r.positions.items.len) return r.positions.items[i];
    }
    return -1;
}

pub fn stz_find_result_free(result: StzFindResultHandle) callconv(.c) void {
    if (result) |r| {
        r.deinit();
        gpa.destroy(r);
    }
}

pub fn stz_string_last_index_of(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) i64 {
    if (handle) |s| {
        if (needle == null or needle_len == 0) return -1;
        const hay = s.slice();
        const n = needle[0..needle_len];
        if (mem.lastIndexOf(u8, hay, n)) |byte_pos| {
            return @intCast(byteOffsetToCodepointIndex(hay, byte_pos));
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
        // Find last byte match, then convert to codepoint index
        var pos: usize = hay.len - n.len;
        while (true) {
            var match = true;
            for (0..n.len) |j| {
                if (toLowerAscii(hay[pos + j]) != toLowerAscii(n[j])) {
                    match = false;
                    break;
                }
            }
            if (match) return @intCast(byteOffsetToCodepointIndex(hay, pos));
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

// ─── Split CI ───

fn ciMatch(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) return false;
    for (0..a.len) |i| {
        if (toLowerAscii(a[i]) != toLowerAscii(b[i])) return false;
    }
    return true;
}

pub fn stz_string_split_count_ci(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize) callconv(.c) c_int {
    if (handle) |s| {
        if (sep == null or sep_len == 0) return 1;
        const hay = s.slice();
        const d = sep[0..sep_len];
        var count: c_int = 1;
        var pos: usize = 0;
        while (pos + d.len <= hay.len) {
            if (ciMatch(hay[pos..][0..d.len], d)) {
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

pub fn stz_string_split_get_ci(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize, index: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        if (sep == null or sep_len == 0 or index < 0) return null;
        const hay = s.slice();
        const d = sep[0..sep_len];
        const target: usize = @intCast(index);
        var part: usize = 0;
        var start: usize = 0;
        var pos: usize = 0;
        while (pos + d.len <= hay.len) {
            if (ciMatch(hay[pos..][0..d.len], d)) {
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

pub fn stz_string_foldcase(handle: StzStringHandle) callconv(.c) StzStringHandle {
    // Simple case folding is equivalent to lowercasing for most Unicode text.
    // Full case folding (e.g. sharp-s -> "ss") would require multi-codepoint expansion,
    // which we defer to a future enhancement.
    return stz_string_to_lower(handle);
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

/// Reverse the codepoints in the string. Returns a new handle.
pub fn stz_string_reverse(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        if (src.len == 0) return stz_string_new();

        // Count codepoints to allocate offset array
        const cp_count = utf8CodepointCount(src);
        const offsets = gpa.alloc(usize, cp_count + 1) catch return stz_string_new();
        defer gpa.free(offsets);

        // Fill offset array with byte positions of each codepoint
        var i: usize = 0;
        var idx: usize = 0;
        while (i < src.len) {
            offsets[idx] = i;
            idx += 1;
            const cp_len = std.unicode.utf8ByteSequenceLength(src[i]) catch 1;
            i += cp_len;
        }
        offsets[idx] = src.len;

        const r = stz_string_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len) catch {};

        // Walk codepoints in reverse order
        var k: usize = cp_count;
        while (k > 0) {
            k -= 1;
            const start = offsets[k];
            const end = offsets[k + 1];
            r.data.appendSlice(gpa, src[start..end]) catch {};
        }
        return r;
    }
    return stz_string_new();
}

/// Repeat the string `count` times. Returns a new handle.
pub fn stz_string_repeat(handle: StzStringHandle, count: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        if (src.len == 0 or count <= 0) return stz_string_new();
        const n: usize = @intCast(count);
        const r = stz_string_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len * n) catch {};
        for (0..n) |_| {
            r.data.appendSlice(gpa, src) catch {};
        }
        return r;
    }
    return stz_string_new();
}

/// Pad the string on the left to reach `target_cp_count` codepoints,
/// using `pad_char` (a UTF-8 encoded codepoint) as fill.
pub fn stz_string_pad_left(handle: StzStringHandle, target_cp_count: c_int, pad_char: [*c]const u8, pad_len: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const current_cp = utf8CodepointCount(src);
        const target: usize = if (target_cp_count > 0) @intCast(target_cp_count) else 0;
        if (current_cp >= target) {
            return stz_string_from(src.ptr, src.len);
        }
        const pad_needed = target - current_cp;
        const pad_slice = if (pad_char != null and pad_len > 0) pad_char[0..pad_len] else " ";
        const r = stz_string_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len + pad_needed * pad_slice.len) catch {};
        for (0..pad_needed) |_| {
            r.data.appendSlice(gpa, pad_slice) catch {};
        }
        r.data.appendSlice(gpa, src) catch {};
        return r;
    }
    return stz_string_new();
}

/// Pad the string on the right to reach `target_cp_count` codepoints,
/// using `pad_char` (a UTF-8 encoded codepoint) as fill.
pub fn stz_string_pad_right(handle: StzStringHandle, target_cp_count: c_int, pad_char: [*c]const u8, pad_len: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const current_cp = utf8CodepointCount(src);
        const target: usize = if (target_cp_count > 0) @intCast(target_cp_count) else 0;
        if (current_cp >= target) {
            return stz_string_from(src.ptr, src.len);
        }
        const pad_needed = target - current_cp;
        const pad_slice = if (pad_char != null and pad_len > 0) pad_char[0..pad_len] else " ";
        const r = stz_string_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len + pad_needed * pad_slice.len) catch {};
        r.data.appendSlice(gpa, src) catch {};
        for (0..pad_needed) |_| {
            r.data.appendSlice(gpa, pad_slice) catch {};
        }
        return r;
    }
    return stz_string_new();
}

/// Remove a range of codepoints from the string. Returns a new handle.
/// `start_cp` is 0-based, `cp_count` is the number of codepoints to remove.
pub fn stz_string_remove_range(handle: StzStringHandle, start_cp: usize, cp_count: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        if (src.len == 0 or cp_count == 0) return stz_string_from(src.ptr, src.len);

        // Find byte boundaries for the range to remove
        var byte_pos: usize = 0;
        var cp: usize = 0;
        while (byte_pos < src.len and cp < start_cp) {
            const cp_len = std.unicode.utf8ByteSequenceLength(src[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp += 1;
        }
        const remove_start = byte_pos;

        var removed: usize = 0;
        while (byte_pos < src.len and removed < cp_count) {
            const cp_len = std.unicode.utf8ByteSequenceLength(src[byte_pos]) catch 1;
            byte_pos += cp_len;
            removed += 1;
        }
        const remove_end = byte_pos;

        const r = stz_string_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len - (remove_end - remove_start)) catch {};
        if (remove_start > 0) r.data.appendSlice(gpa, src[0..remove_start]) catch {};
        if (remove_end < src.len) r.data.appendSlice(gpa, src[remove_end..]) catch {};
        return r;
    }
    return stz_string_new();
}

/// Trim whitespace from the left. Returns a new handle.
pub fn stz_string_trim_left(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        var i: usize = 0;
        while (i < src.len) {
            const byte = src[i];
            // Only ASCII whitespace (space, tab, newline, CR)
            if (byte == ' ' or byte == '\t' or byte == '\n' or byte == '\r') {
                i += 1;
            } else break;
        }
        return stz_string_from(src[i..].ptr, src.len - i);
    }
    return stz_string_new();
}

/// Trim whitespace from the right. Returns a new handle.
pub fn stz_string_trim_right(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        var end: usize = src.len;
        while (end > 0) {
            const byte = src[end - 1];
            if (byte == ' ' or byte == '\t' or byte == '\n' or byte == '\r') {
                end -= 1;
            } else break;
        }
        return stz_string_from(src[0..end].ptr, end);
    }
    return stz_string_new();
}

/// Check if two strings are equal (case-sensitive). Returns 1 or 0.
pub fn stz_string_equals(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    if (h1) |s1| {
        if (h2) |s2| {
            return if (mem.eql(u8, s1.slice(), s2.slice())) 1 else 0;
        }
    }
    return 0;
}

/// Check if two strings are equal (case-insensitive). Returns 1 or 0.
pub fn stz_string_equals_ci(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    if (h1) |s1| {
        if (h2) |s2| {
            const a = s1.slice();
            const b = s2.slice();
            // Quick check: if byte lengths differ after lowering, not equal
            // Do full Unicode casefold comparison
            const la = stz_string_to_lower(h1);
            const lb = stz_string_to_lower(h2);
            defer if (la) |p| { _ = gpa.resize(p.data.allocatedSlice(), 0); };
            defer if (lb) |p| { _ = gpa.resize(p.data.allocatedSlice(), 0); };
            if (la) |pa| {
                if (lb) |pb| {
                    return if (mem.eql(u8, pa.slice(), pb.slice())) 1 else 0;
                }
            }
            // Fallback: byte compare
            return if (mem.eql(u8, a, b)) 1 else 0;
        }
    }
    return 0;
}

// ─── Find Nth ───

/// Find the Nth occurrence (1-based) of needle. Returns 0-based codepoint index, or -1 if not found.
pub fn stz_string_find_nth(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, n: c_int) callconv(.c) i64 {
    if (handle) |s| {
        if (n < 1) return -1;
        const hay = s.slice();
        const ndl = needle[0..needle_len];
        var occurrence: c_int = 0;
        var byte_pos: usize = 0;
        while (mem.indexOfPos(u8, hay, byte_pos, ndl)) |pos| {
            occurrence += 1;
            if (occurrence == n) {
                // Convert byte pos to codepoint index
                return @intCast(byteOffsetToCodepointIndex(hay, pos));
            }
            byte_pos = pos + 1;
        }
    }
    return -1;
}

/// Find the Nth occurrence case-insensitively. Returns 0-based codepoint index, or -1.
pub fn stz_string_find_nth_ci(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, n: c_int) callconv(.c) i64 {
    if (handle) |s| {
        if (n < 1) return -1;
        const hay = s.slice();
        const ndl = needle[0..needle_len];
        // Lowercase both
        const hay_lower = stz_string_from(hay.ptr, hay.len);
        defer stz_string_free(hay_lower);
        const ndl_handle = stz_string_from(ndl.ptr, ndl.len);
        defer stz_string_free(ndl_handle);
        const hay_lc = stz_string_to_lower(hay_lower);
        defer stz_string_free(hay_lc);
        const ndl_lc = stz_string_to_lower(ndl_handle);
        defer stz_string_free(ndl_lc);
        if (hay_lc == null or ndl_lc == null) return -1;
        const hay_lc_data = hay_lc.?.slice();
        const ndl_lc_data = ndl_lc.?.slice();
        var occurrence: c_int = 0;
        var byte_pos: usize = 0;
        while (mem.indexOfPos(u8, hay_lc_data, byte_pos, ndl_lc_data)) |pos| {
            occurrence += 1;
            if (occurrence == n) {
                return @intCast(byteOffsetToCodepointIndex(hay, pos));
            }
            byte_pos = pos + 1;
        }
    }
    return -1;
}

// ─── Replace First / Last / Nth ───

/// Replace only the first occurrence of `old` with `new_str`. Returns new handle.
pub fn stz_string_replace_first(handle: StzStringHandle, old: [*c]const u8, old_len: usize, new_str: [*c]const u8, new_len: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const haystack = s.slice();
        const needle = old[0..old_len];
        const replacement = new_str[0..new_len];
        if (mem.indexOf(u8, haystack, needle)) |pos| {
            const result = stz_string_new() orelse return null;
            result.data.appendSlice(gpa, haystack[0..pos]) catch return null;
            result.data.appendSlice(gpa, replacement) catch return null;
            result.data.appendSlice(gpa, haystack[pos + old_len ..]) catch return null;
            return result;
        }
        // No match: return copy
        return stz_string_from(s.data.items.ptr, haystack.len);
    }
    return null;
}

/// Replace only the last occurrence of `old` with `new_str`. Returns new handle.
pub fn stz_string_replace_last(handle: StzStringHandle, old: [*c]const u8, old_len: usize, new_str: [*c]const u8, new_len: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const haystack = s.slice();
        const needle = old[0..old_len];
        const replacement = new_str[0..new_len];
        // Find last occurrence by scanning forward
        var last_pos: ?usize = null;
        var search_from: usize = 0;
        while (search_from <= haystack.len) {
            if (mem.indexOfPos(u8, haystack, search_from, needle)) |pos| {
                last_pos = pos;
                search_from = pos + 1;
            } else break;
        }
        if (last_pos) |pos| {
            const result = stz_string_new() orelse return null;
            result.data.appendSlice(gpa, haystack[0..pos]) catch return null;
            result.data.appendSlice(gpa, replacement) catch return null;
            result.data.appendSlice(gpa, haystack[pos + old_len ..]) catch return null;
            return result;
        }
        return stz_string_from(s.data.items.ptr, haystack.len);
    }
    return null;
}

/// Replace the Nth occurrence (1-based) of `old` with `new_str`. Returns new handle.
pub fn stz_string_replace_nth(handle: StzStringHandle, old: [*c]const u8, old_len: usize, new_str: [*c]const u8, new_len: usize, n: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        if (n < 1) return stz_string_from(s.data.items.ptr, s.slice().len);
        const haystack = s.slice();
        const needle = old[0..old_len];
        const replacement = new_str[0..new_len];
        var occurrence: c_int = 0;
        var search_from: usize = 0;
        while (search_from <= haystack.len) {
            if (mem.indexOfPos(u8, haystack, search_from, needle)) |pos| {
                occurrence += 1;
                if (occurrence == n) {
                    const result = stz_string_new() orelse return null;
                    result.data.appendSlice(gpa, haystack[0..pos]) catch return null;
                    result.data.appendSlice(gpa, replacement) catch return null;
                    result.data.appendSlice(gpa, haystack[pos + old_len ..]) catch return null;
                    return result;
                }
                search_from = pos + 1;
            } else break;
        }
        return stz_string_from(s.data.items.ptr, haystack.len);
    }
    return null;
}

// ─── String Queries ───

/// Returns 1 if string is empty (0 codepoints), 0 otherwise.
pub fn stz_string_is_empty(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        return if (s.slice().len == 0) 1 else 0;
    }
    return 1; // null handle considered empty
}

/// Extract the substring between the first occurrence of `open` and the first
/// subsequent occurrence of `close`. Returns new handle, or null if not found.
pub fn stz_string_between(handle: StzStringHandle, open: [*c]const u8, open_len: usize, close: [*c]const u8, close_len: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const haystack = s.slice();
        const open_needle = open[0..open_len];
        const close_needle = close[0..close_len];
        if (mem.indexOf(u8, haystack, open_needle)) |open_pos| {
            const after_open = open_pos + open_len;
            if (mem.indexOfPos(u8, haystack, after_open, close_needle)) |close_pos| {
                const between = haystack[after_open..close_pos];
                return stz_string_from(@ptrCast(between.ptr), between.len);
            }
        }
    }
    return null;
}

/// Count how many codepoints match a predicate class.
/// Classes: 0=letter, 1=digit, 2=whitespace, 3=uppercase, 4=lowercase, 5=punctuation
pub fn stz_string_count_chars_of_type(handle: StzStringHandle, char_type: c_int) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        var i: usize = 0;
        var count: c_int = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            const matches: bool = switch (char_type) {
                0 => unicode.stz_unicode_is_letter(cp_val) == 1,
                1 => unicode.stz_unicode_is_digit(cp_val) == 1,
                2 => unicode.stz_unicode_is_space(cp_val) == 1,
                3 => unicode.stz_unicode_is_upper(cp_val) == 1,
                4 => unicode.stz_unicode_is_lower(cp_val) == 1,
                5 => unicode.stz_unicode_is_letter(cp_val) == 0 and unicode.stz_unicode_is_digit(cp_val) == 0 and unicode.stz_unicode_is_space(cp_val) == 0 and cp_val >= 33 and cp_val <= 126,
                else => false,
            };
            if (matches) count += 1;
            i += cp_len;
        }
        return count;
    }
    return 0;
}

/// Check if the string contains only digits. Returns 1 or 0.
pub fn stz_string_is_numeric(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        if (bytes.len == 0) return 0;
        for (bytes) |b| {
            if (b < '0' or b > '9') return 0;
        }
        return 1;
    }
    return 0;
}

/// Check if the string contains only letters. Returns 1 or 0.
pub fn stz_string_is_alpha(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        if (bytes.len == 0) return 0;
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (unicode.stz_unicode_is_letter(cp_val) != 1) return 0;
            i += cp_len;
        }
        return 1;
    }
    return 0;
}

// ─── Remove / Lines / Palindrome ───

/// Remove all occurrences of `needle` from the string. Returns new handle.
pub fn stz_string_remove_all(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const hay = s.slice();
        const ndl = needle[0..needle_len];
        if (ndl.len == 0) return stz_string_from(hay.ptr, hay.len);
        const result = stz_string_new() orelse return null;
        var start: usize = 0;
        while (mem.indexOfPos(u8, hay, start, ndl)) |pos| {
            result.data.appendSlice(gpa, hay[start..pos]) catch return null;
            start = pos + ndl.len;
        }
        result.data.appendSlice(gpa, hay[start..]) catch return null;
        return result;
    }
    return null;
}

/// Count lines (splits by \n). A string with no newlines = 1 line.
pub fn stz_string_lines_count(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const hay = s.slice();
        if (hay.len == 0) return 0;
        var count: c_int = 1;
        for (hay) |byte| {
            if (byte == '\n') count += 1;
        }
        return count;
    }
    return 0;
}

/// Check if the string is a palindrome (codepoint-level). Returns 1 or 0.
pub fn stz_string_is_palindrome(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const src = s.slice();
        if (src.len == 0) return 1;
        // Count codepoints and build byte offset array
        const cp_count = utf8CodepointCount(src);
        if (cp_count <= 1) return 1;
        // Compare first with last, etc.
        var left: usize = 0;
        var right: usize = cp_count - 1;
        while (left < right) {
            const left_offset = codepointIndexToByteOffset(src, left);
            const right_offset = codepointIndexToByteOffset(src, right);
            const left_len = std.unicode.utf8ByteSequenceLength(src[left_offset]) catch 1;
            const right_len = std.unicode.utf8ByteSequenceLength(src[right_offset]) catch 1;
            if (left_len != right_len) return 0;
            if (!mem.eql(u8, src[left_offset .. left_offset + left_len], src[right_offset .. right_offset + right_len])) return 0;
            left += 1;
            right -= 1;
        }
        return 1;
    }
    return 0;
}

/// Find positions (0-based codepoint indices) of characters matching a type.
/// Types: 0=letter, 1=digit, 2=space, 3=upper, 4=lower, 5=punct
pub fn stz_string_find_chars_of_type(handle: StzStringHandle, char_type: c_int) callconv(.c) StzFindResultHandle {
    const r = gpa.create(StzFindResult) catch return null;
    r.* = StzFindResult.init();
    if (handle) |s| {
        const bytes = s.slice();
        var i: usize = 0;
        var cp_idx: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            const matches: bool = switch (char_type) {
                0 => unicode.stz_unicode_is_letter(cp_val) == 1,
                1 => unicode.stz_unicode_is_digit(cp_val) == 1,
                2 => unicode.stz_unicode_is_space(cp_val) == 1,
                3 => unicode.stz_unicode_is_upper(cp_val) == 1,
                4 => unicode.stz_unicode_is_lower(cp_val) == 1,
                5 => unicode.stz_unicode_is_letter(cp_val) == 0 and unicode.stz_unicode_is_digit(cp_val) == 0 and unicode.stz_unicode_is_space(cp_val) == 0 and cp_val >= 33 and cp_val <= 126,
                else => false,
            };
            if (matches) {
                r.positions.append(gpa, @intCast(cp_idx)) catch break;
            }
            cp_idx += 1;
            i += cp_len;
        }
    }
    return r;
}

/// Extract characters matching a type as a new string (letters only, digits only, etc).
/// Types: 0=letter, 1=digit, 2=space, 3=upper, 4=lower
pub fn stz_string_extract_chars_of_type(handle: StzStringHandle, char_type: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const bytes = s.slice();
        const result = stz_string_new() orelse return null;
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_end = @min(i + cp_len, bytes.len);
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            const matches: bool = switch (char_type) {
                0 => unicode.stz_unicode_is_letter(cp_val) == 1,
                1 => unicode.stz_unicode_is_digit(cp_val) == 1,
                2 => unicode.stz_unicode_is_space(cp_val) == 1,
                3 => unicode.stz_unicode_is_upper(cp_val) == 1,
                4 => unicode.stz_unicode_is_lower(cp_val) == 1,
                5 => unicode.stz_unicode_is_letter(cp_val) == 0 and unicode.stz_unicode_is_digit(cp_val) == 0 and unicode.stz_unicode_is_space(cp_val) == 0 and cp_val >= 33 and cp_val <= 126,
                else => false,
            };
            if (matches) {
                result.data.appendSlice(gpa, bytes[i..cp_end]) catch break;
            }
            i += cp_len;
        }
        return result;
    }
    return null;
}

/// Check if string contains only ASCII characters (bytes 0-127). Returns 1 or 0.
pub fn stz_string_is_ascii(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        if (bytes.len == 0) return 1;
        for (bytes) |b| {
            if (b > 127) return 0;
        }
        return 1;
    }
    return 1;
}

/// Remove a single codepoint at the given 0-based codepoint index. Returns new handle.
pub fn stz_string_remove_char_at(handle: StzStringHandle, cp_index: usize) callconv(.c) StzStringHandle {
    return stz_string_remove_range(handle, cp_index, 1);
}

/// Return the character type at a 0-based codepoint index.
/// Returns: 0=letter, 1=digit, 2=space, 3=upper, 4=lower, 5=punct, -1=invalid
pub fn stz_string_char_type_at(handle: StzStringHandle, cp_index: c_int) callconv(.c) c_int {
    if (handle) |s| {
        const src = s.slice();
        if (cp_index < 0) return -1;
        const idx: usize = @intCast(cp_index);
        const byte_offset = codepointIndexToByteOffset(src, idx);
        if (byte_offset >= src.len) return -1;
        const cp_len = std.unicode.utf8ByteSequenceLength(src[byte_offset]) catch return -1;
        const cp_val: i32 = decodeCodepoint(src, byte_offset, cp_len);
        if (cp_val < 0) return -1;
        if (unicode.stz_unicode_is_upper(cp_val) == 1) return 3;
        if (unicode.stz_unicode_is_lower(cp_val) == 1) return 4;
        if (unicode.stz_unicode_is_letter(cp_val) == 1) return 0;
        if (unicode.stz_unicode_is_digit(cp_val) == 1) return 1;
        if (unicode.stz_unicode_is_space(cp_val) == 1) return 2;
        return 5; // punctuation/other
    }
    return -1;
}

/// Concatenate two strings, returning a new handle.
pub fn stz_string_concat(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    const result = stz_string_new() orelse return null;
    if (h1) |s1| result.data.appendSlice(gpa, s1.slice()) catch return null;
    if (h2) |s2| result.data.appendSlice(gpa, s2.slice()) catch return null;
    return result;
}

/// Check if all letter codepoints are uppercase. Returns 1 if true, 0 if false.
/// Non-letter characters are ignored. Empty string or no letters returns 0.
pub fn stz_string_is_uppercase(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var i: usize = 0;
    var has_letter = false;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (unicode.stz_unicode_is_letter(cp_val) != 0) {
            has_letter = true;
            if (unicode.stz_unicode_is_upper(cp_val) == 0) return 0;
        }
        i += cp_len;
    }
    return if (has_letter) 1 else 0;
}

/// Check if all letter codepoints are lowercase. Returns 1 if true, 0 if false.
/// Non-letter characters are ignored. Empty string or no letters returns 0.
pub fn stz_string_is_lowercase(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var i: usize = 0;
    var has_letter = false;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (unicode.stz_unicode_is_letter(cp_val) != 0) {
            has_letter = true;
            if (unicode.stz_unicode_is_lower(cp_val) == 0) return 0;
        }
        i += cp_len;
    }
    return if (has_letter) 1 else 0;
}

/// Check if the string contains only whitespace. Returns 1 if true, 0 if false.
/// Empty string returns 0.
pub fn stz_string_is_whitespace(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (unicode.stz_unicode_is_space(cp_val) == 0) return 0;
        i += cp_len;
    }
    return 1;
}

/// Count words (sequences of non-whitespace separated by whitespace).
pub fn stz_string_word_count(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var count: c_int = 0;
    var in_word = false;
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        const is_space = unicode.stz_unicode_is_space(cp_val) != 0;
        if (!is_space and !in_word) {
            count += 1;
            in_word = true;
        } else if (is_space) {
            in_word = false;
        }
        i += cp_len;
    }
    return count;
}

/// Check if string contains only characters of a given type.
/// Types: 0=letter, 1=digit, 2=space, 3=upper, 4=lower, 5=punct
pub fn stz_string_is_only_type(handle: StzStringHandle, char_type: c_int) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        const matches = switch (char_type) {
            0 => unicode.stz_unicode_is_letter(cp_val) != 0,
            1 => unicode.stz_unicode_is_digit(cp_val) != 0,
            2 => unicode.stz_unicode_is_space(cp_val) != 0,
            3 => unicode.stz_unicode_is_upper(cp_val) != 0,
            4 => unicode.stz_unicode_is_lower(cp_val) != 0,
            5 => blk: {
                const is_letter = unicode.stz_unicode_is_letter(cp_val) != 0;
                const is_digit = unicode.stz_unicode_is_digit(cp_val) != 0;
                const is_space = unicode.stz_unicode_is_space(cp_val) != 0;
                break :blk !is_letter and !is_digit and !is_space;
            },
            else => false,
        };
        if (!matches) return 0;
        i += cp_len;
    }
    return 1;
}

/// Remove all characters of a given type. Returns new handle.
/// Types: 0=letter, 1=digit, 2=space, 3=upper, 4=lower, 5=punct
pub fn stz_string_remove_chars_of_type(handle: StzStringHandle, char_type: c_int) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    const result = stz_string_new() orelse return null;
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_end = @min(i + cp_len, bytes.len);
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        const is_type = switch (char_type) {
            0 => unicode.stz_unicode_is_letter(cp_val) != 0,
            1 => unicode.stz_unicode_is_digit(cp_val) != 0,
            2 => unicode.stz_unicode_is_space(cp_val) != 0,
            3 => unicode.stz_unicode_is_upper(cp_val) != 0,
            4 => unicode.stz_unicode_is_lower(cp_val) != 0,
            5 => blk: {
                const is_letter = unicode.stz_unicode_is_letter(cp_val) != 0;
                const is_digit = unicode.stz_unicode_is_digit(cp_val) != 0;
                const is_space = unicode.stz_unicode_is_space(cp_val) != 0;
                break :blk !is_letter and !is_digit and !is_space;
            },
            else => false,
        };
        if (!is_type) {
            result.data.appendSlice(gpa, bytes[i..cp_end]) catch break;
        }
        i += cp_len;
    }
    return result;
}

/// Trim whitespace from both ends. Returns new handle.
pub fn stz_string_trim(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    // Find start
    var start: usize = 0;
    while (start < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[start]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, start, cp_len);
        if (unicode.stz_unicode_is_space(cp_val) == 0) break;
        start += cp_len;
    }
    // Find end
    var end: usize = bytes.len;
    while (end > start) {
        // Walk backward to find start of last codepoint
        var back: usize = end - 1;
        while (back > start and (bytes[back] & 0xC0) == 0x80) back -= 1;
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[back]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, back, cp_len);
        if (unicode.stz_unicode_is_space(cp_val) == 0) break;
        end = back;
    }
    return stz_string_from(bytes[start..end].ptr, end - start);
}

/// Swap case of all letter codepoints. Returns new handle.
pub fn stz_string_swap_case(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    const result = stz_string_new() orelse return null;
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_end = @min(i + cp_len, bytes.len);
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (unicode.stz_unicode_is_upper(cp_val) != 0) {
            // Convert to lower via Engine to_lower on single char
            const tmp = stz_string_from(bytes[i..cp_end].ptr, cp_end - i) orelse {
                i += cp_len;
                continue;
            };
            const lower = stz_string_to_lower(tmp);
            if (lower) |l| {
                result.data.appendSlice(gpa, l.slice()) catch break;
                stz_string_free(lower);
            }
            stz_string_free(tmp);
        } else if (unicode.stz_unicode_is_lower(cp_val) != 0) {
            const tmp = stz_string_from(bytes[i..cp_end].ptr, cp_end - i) orelse {
                i += cp_len;
                continue;
            };
            const upper = stz_string_to_upper(tmp);
            if (upper) |u| {
                result.data.appendSlice(gpa, u.slice()) catch break;
                stz_string_free(upper);
            }
            stz_string_free(tmp);
        } else {
            result.data.appendSlice(gpa, bytes[i..cp_end]) catch break;
        }
        i += cp_len;
    }
    return result;
}

/// Simplify: trim whitespace from both ends, collapse internal whitespace runs to single space.
/// Also replaces tabs, CR, LF with spaces. Returns new handle.
pub fn stz_string_simplify(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    const result = stz_string_new() orelse return null;

    // Skip leading whitespace
    var start: usize = 0;
    while (start < bytes.len) {
        const b = bytes[start];
        if (b == ' ' or b == '\t' or b == '\n' or b == '\r') {
            start += 1;
        } else if (b < 128) {
            break;
        } else {
            // Check Unicode whitespace
            const cp_len = std.unicode.utf8ByteSequenceLength(b) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, start, cp_len);
            if (unicode.stz_unicode_is_space(cp_val) != 0) {
                start += cp_len;
            } else break;
        }
    }

    // Find end (skip trailing whitespace)
    var end: usize = bytes.len;
    while (end > start) {
        const b = bytes[end - 1];
        if (b == ' ' or b == '\t' or b == '\n' or b == '\r') {
            end -= 1;
        } else break;
    }

    // Process content: collapse whitespace runs to single space
    var i: usize = start;
    var in_space = false;
    while (i < end) {
        const b = bytes[i];
        const is_ws = (b == ' ' or b == '\t' or b == '\n' or b == '\r');
        if (is_ws) {
            if (!in_space) {
                result.data.appendSlice(gpa, " ") catch break;
                in_space = true;
            }
            i += 1;
        } else if (b >= 128) {
            const cp_len = std.unicode.utf8ByteSequenceLength(b) catch 1;
            const cp_end = @min(i + cp_len, end);
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (unicode.stz_unicode_is_space(cp_val) != 0) {
                if (!in_space) {
                    result.data.appendSlice(gpa, " ") catch break;
                    in_space = true;
                }
            } else {
                result.data.appendSlice(gpa, bytes[i..cp_end]) catch break;
                in_space = false;
            }
            i += cp_len;
        } else {
            result.data.appendSlice(gpa, bytes[i .. i + 1]) catch break;
            in_space = false;
            i += 1;
        }
    }
    return result;
}

/// Check if string starts with a digit. Returns 1 or 0.
pub fn stz_string_starts_with_digit(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;
    const cp_len = std.unicode.utf8ByteSequenceLength(bytes[0]) catch 1;
    const cp_val: i32 = decodeCodepoint(bytes, 0, cp_len);
    return if (unicode.stz_unicode_is_digit(cp_val) != 0) @as(c_int, 1) else @as(c_int, 0);
}

/// Check if string starts with a letter. Returns 1 or 0.
pub fn stz_string_starts_with_letter(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;
    const cp_len = std.unicode.utf8ByteSequenceLength(bytes[0]) catch 1;
    const cp_val: i32 = decodeCodepoint(bytes, 0, cp_len);
    return if (unicode.stz_unicode_is_letter(cp_val) != 0) @as(c_int, 1) else @as(c_int, 0);
}

/// Check if string ends with a digit. Returns 1 or 0.
pub fn stz_string_ends_with_digit(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;
    // Walk to last codepoint
    var i: usize = 0;
    var last_cp: i32 = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        last_cp = decodeCodepoint(bytes, i, cp_len);
        i += cp_len;
    }
    return if (unicode.stz_unicode_is_digit(last_cp) != 0) @as(c_int, 1) else @as(c_int, 0);
}

/// Check if string ends with a letter. Returns 1 or 0.
pub fn stz_string_ends_with_letter(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;
    var i: usize = 0;
    var last_cp: i32 = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        last_cp = decodeCodepoint(bytes, i, cp_len);
        i += cp_len;
    }
    return if (unicode.stz_unicode_is_letter(last_cp) != 0) @as(c_int, 1) else @as(c_int, 0);
}

/// Replace codepoint at a given index with a new string. Returns new handle.
pub fn stz_string_replace_char_at(handle: StzStringHandle, cp_index: c_int, replacement: [*c]const u8, rep_len: usize) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    const result = stz_string_new() orelse return null;
    if (cp_index < 0) {
        result.data.appendSlice(gpa, bytes) catch {};
        return result;
    }
    const idx: usize = @intCast(cp_index);
    var cp_count: usize = 0;
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_end = @min(i + cp_len, bytes.len);
        if (cp_count == idx) {
            // Insert replacement instead of this codepoint
            if (rep_len > 0) {
                result.data.appendSlice(gpa, replacement[0..rep_len]) catch break;
            }
        } else {
            result.data.appendSlice(gpa, bytes[i..cp_end]) catch break;
        }
        cp_count += 1;
        i += cp_len;
    }
    return result;
}

/// Compute Levenshtein edit distance between two strings (codepoint-level).
pub fn stz_string_levenshtein(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    const s1 = (h1 orelse return 0);
    const s2 = (h2 orelse return 0);
    const b1 = s1.slice();
    const b2 = s2.slice();

    // Decode codepoints from both strings
    var cp1_buf: [4096]i32 = undefined;
    var cp2_buf: [4096]i32 = undefined;
    var len1: usize = 0;
    var len2: usize = 0;

    var i: usize = 0;
    while (i < b1.len and len1 < 4096) {
        const cp_len = std.unicode.utf8ByteSequenceLength(b1[i]) catch 1;
        cp1_buf[len1] = decodeCodepoint(b1, i, cp_len);
        len1 += 1;
        i += cp_len;
    }
    i = 0;
    while (i < b2.len and len2 < 4096) {
        const cp_len = std.unicode.utf8ByteSequenceLength(b2[i]) catch 1;
        cp2_buf[len2] = decodeCodepoint(b2, i, cp_len);
        len2 += 1;
        i += cp_len;
    }

    if (len1 == 0) return @intCast(len2);
    if (len2 == 0) return @intCast(len1);

    // Use two rows for space efficiency
    const row_alloc = gpa.alloc(c_int, len2 + 1) catch return -1;
    defer gpa.free(row_alloc);
    const prev_alloc = gpa.alloc(c_int, len2 + 1) catch return -1;
    defer gpa.free(prev_alloc);
    var prev = prev_alloc;
    var curr = row_alloc;

    for (0..len2 + 1) |j| {
        prev[j] = @intCast(j);
    }

    for (0..len1) |r| {
        curr[0] = @as(c_int, @intCast(r)) + 1;
        for (0..len2) |c| {
            const cost: c_int = if (cp1_buf[r] == cp2_buf[c]) 0 else 1;
            const del = prev[c + 1] + 1;
            const ins = curr[c] + 1;
            const sub = prev[c] + cost;
            curr[c + 1] = @min(del, @min(ins, sub));
        }
        const tmp = prev;
        prev = curr;
        curr = tmp;
    }

    return prev[len2];
}

/// Check if string matches another string with case-insensitive comparison. Returns 1 or 0.
pub fn stz_string_is_title_case(handle: StzStringHandle) callconv(.c) c_int {
    // Title case: first letter of each word is uppercase, rest lowercase
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var after_space = true; // start of string counts as word boundary
    var has_letter = false;
    var i_pos: usize = 0;
    while (i_pos < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i_pos]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i_pos, cp_len);

        if (unicode.stz_unicode_is_letter(cp_val) != 0) {
            has_letter = true;
            if (after_space) {
                // First letter of word must be uppercase
                if (unicode.stz_unicode_is_upper(cp_val) == 0) return 0;
            } else {
                // Other letters in word must be lowercase
                if (unicode.stz_unicode_is_lower(cp_val) == 0) return 0;
            }
            after_space = false;
        } else {
            if (unicode.stz_unicode_is_space(cp_val) != 0) {
                after_space = true;
            } else {
                after_space = false;
            }
        }
        i_pos += cp_len;
    }
    return if (has_letter) @as(c_int, 1) else @as(c_int, 0);
}

/// Split string by lines (LF, CR, CRLF). Returns count of lines.
pub fn stz_string_lines_split_count(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var count: c_int = 1;
    var i_pos: usize = 0;
    while (i_pos < bytes.len) {
        if (bytes[i_pos] == '\r') {
            count += 1;
            if (i_pos + 1 < bytes.len and bytes[i_pos + 1] == '\n') {
                i_pos += 1; // skip LF of CRLF
            }
        } else if (bytes[i_pos] == '\n') {
            count += 1;
        }
        i_pos += 1;
    }
    return count;
}

/// Get nth line (0-based). Returns new handle. Splits by LF/CR/CRLF.
pub fn stz_string_line_at(handle: StzStringHandle, line_index: c_int) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    if (line_index < 0) return null;
    const target: usize = @intCast(line_index);

    var line_num: usize = 0;
    var line_start: usize = 0;
    var i_pos: usize = 0;
    while (i_pos <= bytes.len) {
        const at_end = (i_pos == bytes.len);
        const is_cr = (!at_end and bytes[i_pos] == '\r');
        const is_lf = (!at_end and bytes[i_pos] == '\n');
        const is_eol = is_cr or is_lf or at_end;

        if (is_eol) {
            if (line_num == target) {
                return stz_string_from(bytes[line_start..i_pos].ptr, i_pos - line_start);
            }
            line_num += 1;
            if (is_cr and i_pos + 1 < bytes.len and bytes[i_pos + 1] == '\n') {
                i_pos += 1; // skip LF of CRLF
            }
            line_start = i_pos + 1;
            if (at_end) break;
        }
        i_pos += 1;
    }
    return null;
}

/// Return a new string with duplicate codepoints removed (preserves first occurrence order).
pub fn stz_string_unique_chars(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    const result = stz_string_new() orelse return null;

    // Track seen codepoints with a simple array (works for BMP + beyond)
    var seen = std.AutoHashMap(i32, void).init(gpa);
    defer seen.deinit();

    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_end = @min(i + cp_len, bytes.len);
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (!seen.contains(cp_val)) {
            seen.put(cp_val, {}) catch break;
            result.data.appendSlice(gpa, bytes[i..cp_end]) catch break;
        }
        i += cp_len;
    }
    return result;
}

/// Remove all occurrences of needle (case-insensitive). Returns new handle.
pub fn stz_string_remove_all_ci(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) StzStringHandle {
    // Replace all occurrences with empty string (case-insensitive)
    const s = (handle orelse return null);
    _ = s;
    const result = stz_string_new() orelse return null;
    if (handle) |src| {
        result.data.appendSlice(gpa, src.slice()) catch return null;
    }
    stz_string_replace_ci(result, needle, needle_len, "".ptr, 0);
    return result;
}

/// Check if string contains only letters (Unicode-aware). Returns 1 or 0.
pub fn stz_string_is_alpha_only(handle: StzStringHandle) callconv(.c) c_int {
    return stz_string_is_only_type(handle, 0); // type 0 = letter
}

/// Check if string is alphanumeric (letters + digits only). Returns 1 or 0.
pub fn stz_string_is_alnum(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (unicode.stz_unicode_is_letter(cp_val) == 0 and unicode.stz_unicode_is_digit(cp_val) == 0) return 0;
        i += cp_len;
    }
    return 1;
}

/// Return number of unique codepoints.
pub fn stz_string_unique_char_count(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    var seen = std.AutoHashMap(i32, void).init(gpa);
    defer seen.deinit();
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        seen.put(cp_val, {}) catch break;
        i += cp_len;
    }
    return @intCast(seen.count());
}

/// Check if string contains char (codepoint). Returns 1 or 0.
pub fn stz_string_contains_char(handle: StzStringHandle, codepoint: i32) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (cp_val == codepoint) return 1;
        i += cp_len;
    }
    return 0;
}

/// Return a substring between two delimiters, searching from a given occurrence.
/// nth=0 means first occurrence of open delimiter. Returns new handle.
pub fn stz_string_between_nth(handle: StzStringHandle, open: [*c]const u8, open_len: usize, close: [*c]const u8, close_len: usize, nth: c_int) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    if (open_len == 0 or close_len == 0) return null;
    const open_s = open[0..open_len];
    const close_s = close[0..close_len];

    var occurrence: c_int = 0;
    var i: usize = 0;
    while (i + open_len <= bytes.len) {
        if (std.mem.eql(u8, bytes[i..][0..open_len], open_s)) {
            if (occurrence == nth) {
                const after_open = i + open_len;
                var j = after_open;
                while (j + close_len <= bytes.len) {
                    if (std.mem.eql(u8, bytes[j..][0..close_len], close_s)) {
                        return stz_string_from(bytes[after_open..j].ptr, j - after_open);
                    }
                    j += 1;
                }
                return null;
            }
            occurrence += 1;
            i += open_len;
        } else {
            i += 1;
        }
    }
    return null;
}

/// Count occurrences of a substring between two delimiters.
pub fn stz_string_count_between(handle: StzStringHandle, open: [*c]const u8, open_len: usize, close: [*c]const u8, close_len: usize) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (open_len == 0 or close_len == 0) return 0;
    const open_s = open[0..open_len];
    const close_s = close[0..close_len];

    var count: c_int = 0;
    var i: usize = 0;
    while (i + open_len <= bytes.len) {
        if (std.mem.eql(u8, bytes[i..][0..open_len], open_s)) {
            const after_open = i + open_len;
            var j = after_open;
            while (j + close_len <= bytes.len) {
                if (std.mem.eql(u8, bytes[j..][0..close_len], close_s)) {
                    count += 1;
                    i = j + close_len;
                    break;
                }
                j += 1;
            } else {
                break;
            }
            continue;
        }
        i += 1;
    }
    return count;
}

/// Decode a codepoint from UTF-8 bytes at a given position.
fn decodeCodepoint(bytes: []const u8, pos: usize, cp_len: usize) i32 {
    if (cp_len == 1) return @intCast(bytes[pos]);
    if (cp_len == 2 and pos + 1 < bytes.len)
        return @intCast((@as(u21, bytes[pos] & 0x1F) << 6) | (bytes[pos + 1] & 0x3F));
    if (cp_len == 3 and pos + 2 < bytes.len)
        return @intCast((@as(u21, bytes[pos] & 0x0F) << 12) | (@as(u21, bytes[pos + 1] & 0x3F) << 6) | (bytes[pos + 2] & 0x3F));
    if (cp_len == 4 and pos + 3 < bytes.len)
        return @intCast((@as(u21, bytes[pos] & 0x07) << 18) | (@as(u21, bytes[pos + 1] & 0x3F) << 12) | (@as(u21, bytes[pos + 2] & 0x3F) << 6) | (bytes[pos + 3] & 0x3F));
    return 0;
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

/// Convert a byte offset to a 0-based codepoint index.
fn byteOffsetToCodepointIndex(bytes: []const u8, byte_offset: usize) usize {
    var cp_idx: usize = 0;
    var i: usize = 0;
    while (i < byte_offset and i < bytes.len) {
        const byte = bytes[i];
        const cp_len = std.unicode.utf8ByteSequenceLength(byte) catch 1;
        cp_idx += 1;
        i += cp_len;
    }
    return cp_idx;
}

/// Convert a 0-based codepoint index to a byte offset.
fn codepointIndexToByteOffset(bytes: []const u8, cp_index: usize) usize {
    var cp_count: usize = 0;
    var i: usize = 0;
    while (i < bytes.len and cp_count < cp_index) {
        const byte = bytes[i];
        const cp_len = std.unicode.utf8ByteSequenceLength(byte) catch 1;
        cp_count += 1;
        i += cp_len;
    }
    return i;
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

test "string find_all" {
    const s = stz_string_from("ring is ring and ring", 21);
    const r = stz_string_find_all(s, "ring", 4);
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 0), stz_find_result_get(r, 0));
    try std.testing.expectEqual(@as(i64, 8), stz_find_result_get(r, 1));
    try std.testing.expectEqual(@as(i64, 17), stz_find_result_get(r, 2));
    stz_find_result_free(r);

    // Not found
    const r2 = stz_string_find_all(s, "xyz", 3);
    try std.testing.expectEqual(@as(c_int, 0), stz_find_result_count(r2));
    stz_find_result_free(r2);
    stz_string_free(s);
}

test "string find_all_ci" {
    const s = stz_string_from("Ring RING ring", 14);
    const r = stz_string_find_all_ci(s, "ring", 4);
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 0), stz_find_result_get(r, 0));
    try std.testing.expectEqual(@as(i64, 5), stz_find_result_get(r, 1));
    try std.testing.expectEqual(@as(i64, 10), stz_find_result_get(r, 2));
    stz_find_result_free(r);
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

test "string split_count_ci" {
    const s = stz_string_from("oneABCtwoabcthree", 17);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_split_count_ci(s, "abc", 3));
    stz_string_free(s);
}

test "string split_get_ci" {
    const s = stz_string_from("oneABCtwoAbCthree", 17);
    const p0 = stz_string_split_get_ci(s, "abc", 3, 0);
    try std.testing.expect(mem.eql(u8, stz_string_data(p0)[0..stz_string_size(p0)], "one"));
    stz_string_free(p0);
    const p1 = stz_string_split_get_ci(s, "abc", 3, 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(p1)[0..stz_string_size(p1)], "two"));
    stz_string_free(p1);
    const p2 = stz_string_split_get_ci(s, "abc", 3, 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(p2)[0..stz_string_size(p2)], "three"));
    stz_string_free(p2);
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

// ─── Unicode codepoint-position tests ───

test "find_all unicode codepoint positions" {
    // "bullet heart bullet bullet bullet bullet heart bullet bullet"
    // Each char is 3 bytes (U+2022=E2 80 A2, U+2665=E2 99 A5)
    // String: bullet(0) heart(1) bullet(2) bullet(3) bullet(4) bullet(5) heart(6) bullet(7) bullet(8)
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x80\xa2\xe2\x80\xa2\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x80\xa2";
    const s = stz_string_from(str, 27);
    try std.testing.expectEqual(@as(usize, 9), stz_string_count(s));

    // Find heart (E2 99 A5) -- should be at codepoint positions 1 and 6
    const r = stz_string_find_all(s, "\xe2\x99\xa5", 3);
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r, 0));
    try std.testing.expectEqual(@as(i64, 6), stz_find_result_get(r, 1));
    stz_find_result_free(r);

    // Find "bullet heart bullet" (9 bytes) -- at codepoint positions 0 and 5
    const sub = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2";
    const r2 = stz_string_find_all(s, sub, 9);
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(r2));
    try std.testing.expectEqual(@as(i64, 0), stz_find_result_get(r2, 0));
    try std.testing.expectEqual(@as(i64, 5), stz_find_result_get(r2, 1));
    stz_find_result_free(r2);

    stz_string_free(s);
}

test "index_of unicode codepoint position" {
    // "cafe" with e-acute: "caf\xC3\xA9X" -- 5 bytes, 4 codepoints + X
    const s = stz_string_from("caf\xC3\xA9X", 6);
    try std.testing.expectEqual(@as(usize, 5), stz_string_count(s));
    // 'X' is at byte 5 but codepoint index 4
    try std.testing.expectEqual(@as(i64, 4), stz_string_index_of(s, "X", 1));
    stz_string_free(s);
}

test "last_index_of unicode" {
    // Two hearts in multibyte string
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x99\xa5";
    const s = stz_string_from(str, 12); // 4 chars, 12 bytes
    try std.testing.expectEqual(@as(usize, 4), stz_string_count(s));
    // Last heart at codepoint 3
    try std.testing.expectEqual(@as(i64, 3), stz_string_last_index_of(s, "\xe2\x99\xa5", 3));
    stz_string_free(s);
}

test "nth_char unicode" {
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2";
    const s = stz_string_from(str, 9); // 3 chars
    // nth_char(1) should be heart
    const ch = stz_string_nth_char(s, 1);
    try std.testing.expectEqual(@as(usize, 3), stz_string_size(ch));
    try std.testing.expect(mem.eql(u8, stz_string_data(ch)[0..3], "\xe2\x99\xa5"));
    stz_string_free(ch);
    stz_string_free(s);
}

test "slice unicode" {
    // "bullet heart bullet bullet heart" = 5 chars
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x80\xa2\xe2\x99\xa5";
    const s = stz_string_from(str, 15);
    // slice(1, 3) = chars 1,2,3 = heart bullet bullet
    const sl = stz_string_slice(s, 1, 3);
    try std.testing.expectEqual(@as(usize, 9), stz_string_size(sl));
    try std.testing.expect(mem.eql(u8, stz_string_data(sl)[0..3], "\xe2\x99\xa5"));
    stz_string_free(sl);
    stz_string_free(s);
}

test "reverse ascii" {
    const s = stz_string_from("hello", 5);
    const r = stz_string_reverse(s);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..5], "olleh"));
    stz_string_free(r);
    stz_string_free(s);
}

test "reverse unicode" {
    // ABC where A=bullet(3b), B=heart(3b), C=bullet(3b)
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2";
    const s = stz_string_from(str, 9);
    const r = stz_string_reverse(s);
    // reversed = C B A = bullet heart bullet (same bytes, different order)
    try std.testing.expectEqual(@as(usize, 9), stz_string_size(r));
    // First char should be the LAST original char (bullet)
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..3], "\xe2\x80\xa2"));
    // Second char should be heart
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[3..6], "\xe2\x99\xa5"));
    // Third char should be bullet
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[6..9], "\xe2\x80\xa2"));
    stz_string_free(r);
    stz_string_free(s);
}

test "reverse mixed ascii unicode" {
    // "aBC" where a='a'(1b), B=heart(3b), C='z'(1b)
    const s = stz_string_from("a\xe2\x99\xa5z", 5);
    const r = stz_string_reverse(s);
    // reversed = "z heart a"
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..1], "z"));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[1..4], "\xe2\x99\xa5"));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[4..5], "a"));
    stz_string_free(r);
    stz_string_free(s);
}

test "repeat" {
    const s = stz_string_from("ab", 2);
    const r = stz_string_repeat(s, 3);
    try std.testing.expectEqual(@as(usize, 6), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..6], "ababab"));
    stz_string_free(r);
    stz_string_free(s);
}

test "repeat unicode" {
    // heart = 3 bytes
    const s = stz_string_from("\xe2\x99\xa5", 3);
    const r = stz_string_repeat(s, 4);
    try std.testing.expectEqual(@as(usize, 12), stz_string_size(r));
    try std.testing.expectEqual(@as(usize, 4), stz_string_count(r));
    stz_string_free(r);
    stz_string_free(s);
}

test "repeat zero" {
    const s = stz_string_from("hello", 5);
    const r = stz_string_repeat(s, 0);
    try std.testing.expectEqual(@as(usize, 0), stz_string_size(r));
    stz_string_free(r);
    stz_string_free(s);
}

test "pad_left ascii" {
    const s = stz_string_from("hi", 2);
    const r = stz_string_pad_left(s, 5, ".", 1);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..5], "...hi"));
    stz_string_free(r);
    stz_string_free(s);
}

test "pad_left unicode fill" {
    // Pad "ab" to 5 codepoints using heart (3 bytes each)
    const s = stz_string_from("ab", 2);
    const r = stz_string_pad_left(s, 5, "\xe2\x99\xa5", 3);
    // Result: heart heart heart a b = 3*3 + 2 = 11 bytes, 5 codepoints
    try std.testing.expectEqual(@as(usize, 11), stz_string_size(r));
    try std.testing.expectEqual(@as(usize, 5), stz_string_count(r));
    // First 9 bytes = 3 hearts
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..3], "\xe2\x99\xa5"));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[9..11], "ab"));
    stz_string_free(r);
    stz_string_free(s);
}

test "pad_left no padding needed" {
    const s = stz_string_from("hello", 5);
    const r = stz_string_pad_left(s, 3, " ", 1);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..5], "hello"));
    stz_string_free(r);
    stz_string_free(s);
}

test "pad_right ascii" {
    const s = stz_string_from("hi", 2);
    const r = stz_string_pad_right(s, 5, ".", 1);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..5], "hi..."));
    stz_string_free(r);
    stz_string_free(s);
}

test "pad_right unicode content" {
    // heart(3b) padded right to 4 codepoints with spaces
    const s = stz_string_from("\xe2\x99\xa5", 3);
    const r = stz_string_pad_right(s, 4, " ", 1);
    // Result: heart + 3 spaces = 3 + 3 = 6 bytes, 4 codepoints
    try std.testing.expectEqual(@as(usize, 6), stz_string_size(r));
    try std.testing.expectEqual(@as(usize, 4), stz_string_count(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..3], "\xe2\x99\xa5"));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[3..6], "   "));
    stz_string_free(r);
    stz_string_free(s);
}

test "remove_range ascii" {
    const s = stz_string_from("hello world", 11);
    // Remove "lo " (codepoints 3,4,5 = 0-based)
    const r = stz_string_remove_range(s, 3, 3);
    try std.testing.expectEqual(@as(usize, 8), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..8], "helworld"));
    stz_string_free(r);
    stz_string_free(s);
}

test "remove_range unicode" {
    // "a heart b" = a(1b) heart(3b) b(1b) = 3 codepoints
    const s = stz_string_from("a\xe2\x99\xa5b", 5);
    // Remove heart (codepoint 1, count 1)
    const r = stz_string_remove_range(s, 1, 1);
    try std.testing.expectEqual(@as(usize, 2), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..2], "ab"));
    stz_string_free(r);
    stz_string_free(s);
}

test "trim_left" {
    const s = stz_string_from("  \thello", 8);
    const r = stz_string_trim_left(s);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..5], "hello"));
    stz_string_free(r);
    stz_string_free(s);
}

test "trim_right" {
    const s = stz_string_from("hello  \t", 8);
    const r = stz_string_trim_right(s);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..5], "hello"));
    stz_string_free(r);
    stz_string_free(s);
}

test "trim_left preserves unicode" {
    // spaces + heart
    const s = stz_string_from("  \xe2\x99\xa5", 5);
    const r = stz_string_trim_left(s);
    try std.testing.expectEqual(@as(usize, 3), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..3], "\xe2\x99\xa5"));
    stz_string_free(r);
    stz_string_free(s);
}

test "equals" {
    const a = stz_string_from("hello", 5);
    const b = stz_string_from("hello", 5);
    const c = stz_string_from("world", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_equals(a, b));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_equals(a, c));
    stz_string_free(a);
    stz_string_free(b);
    stz_string_free(c);
}

test "replace_first" {
    const s = stz_string_from("aXbXc", 5);
    const r = stz_string_replace_first(s, "X", 1, "YY", 2);
    try std.testing.expectEqual(@as(usize, 6), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..6], "aYYbXc"));
    stz_string_free(r);
    stz_string_free(s);
}

test "replace_last" {
    const s = stz_string_from("aXbXc", 5);
    const r = stz_string_replace_last(s, "X", 1, "ZZ", 2);
    try std.testing.expectEqual(@as(usize, 6), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..6], "aXbZZc"));
    stz_string_free(r);
    stz_string_free(s);
}

test "replace_nth" {
    const s = stz_string_from("aXbXcXd", 7);
    // Replace 2nd occurrence
    const r = stz_string_replace_nth(s, "X", 1, "**", 2, 2);
    try std.testing.expectEqual(@as(usize, 8), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..8], "aXb**cXd"));
    stz_string_free(r);
    stz_string_free(s);
}

test "replace_first no match" {
    const s = stz_string_from("hello", 5);
    const r = stz_string_replace_first(s, "Z", 1, "X", 1);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..5], "hello"));
    stz_string_free(r);
    stz_string_free(s);
}

test "is_empty" {
    const empty = stz_string_new();
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_empty(empty));
    stz_string_free(empty);

    const nonempty = stz_string_from("x", 1);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_empty(nonempty));
    stz_string_free(nonempty);
}

test "between" {
    const s = stz_string_from("hello [world] end", 17);
    const r = stz_string_between(s, "[", 1, "]", 1);
    try std.testing.expect(r != null);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..5], "world"));
    stz_string_free(r);
    stz_string_free(s);
}

test "between multi-char delimiters" {
    const s = stz_string_from("start<<content>>end", 19);
    const r = stz_string_between(s, "<<", 2, ">>", 2);
    try std.testing.expect(r != null);
    try std.testing.expectEqual(@as(usize, 7), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..7], "content"));
    stz_string_free(r);
    stz_string_free(s);
}

test "between not found" {
    const s = stz_string_from("hello world", 11);
    const r = stz_string_between(s, "[", 1, "]", 1);
    try std.testing.expect(r == null);
    stz_string_free(s);
}

test "is_numeric" {
    const num = stz_string_from("12345", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_numeric(num));
    stz_string_free(num);

    const mixed = stz_string_from("12a45", 5);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_numeric(mixed));
    stz_string_free(mixed);

    const empty = stz_string_new();
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_numeric(empty));
    stz_string_free(empty);
}

test "is_alpha" {
    const alpha = stz_string_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_alpha(alpha));
    stz_string_free(alpha);

    const mixed = stz_string_from("Hello1", 6);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_alpha(mixed));
    stz_string_free(mixed);

    // Unicode letters
    const uni = stz_string_from("caf\xC3\xA9", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_alpha(uni));
    stz_string_free(uni);
}

test "count_chars_of_type letters" {
    const s = stz_string_from("Hello 123!", 10);
    // Type 0 = letters: H,e,l,l,o = 5
    try std.testing.expectEqual(@as(c_int, 5), stz_string_count_chars_of_type(s, 0));
    // Type 1 = digits: 1,2,3 = 3
    try std.testing.expectEqual(@as(c_int, 3), stz_string_count_chars_of_type(s, 1));
    // Type 2 = whitespace: 1 space
    try std.testing.expectEqual(@as(c_int, 1), stz_string_count_chars_of_type(s, 2));
    stz_string_free(s);
}

test "find_nth" {
    const s = stz_string_from("aXbXcXd", 7);
    // 1st X at codepoint 1
    try std.testing.expectEqual(@as(i64, 1), stz_string_find_nth(s, "X", 1, 1));
    // 2nd X at codepoint 3
    try std.testing.expectEqual(@as(i64, 3), stz_string_find_nth(s, "X", 1, 2));
    // 3rd X at codepoint 5
    try std.testing.expectEqual(@as(i64, 5), stz_string_find_nth(s, "X", 1, 3));
    // 4th X doesn't exist
    try std.testing.expectEqual(@as(i64, -1), stz_string_find_nth(s, "X", 1, 4));
    stz_string_free(s);
}

test "find_nth unicode" {
    // "heart bullet heart bullet heart" = 5 chars
    const str = "\xe2\x99\xa5\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x99\xa5";
    const s = stz_string_from(str, 15);
    // 1st heart at codepoint 0
    try std.testing.expectEqual(@as(i64, 0), stz_string_find_nth(s, "\xe2\x99\xa5", 3, 1));
    // 2nd heart at codepoint 2
    try std.testing.expectEqual(@as(i64, 2), stz_string_find_nth(s, "\xe2\x99\xa5", 3, 2));
    // 3rd heart at codepoint 4
    try std.testing.expectEqual(@as(i64, 4), stz_string_find_nth(s, "\xe2\x99\xa5", 3, 3));
    stz_string_free(s);
}

test "remove_all" {
    const s = stz_string_from("aXbXcXd", 7);
    const r = stz_string_remove_all(s, "X", 1);
    try std.testing.expectEqual(@as(usize, 4), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..4], "abcd"));
    stz_string_free(r);
    stz_string_free(s);
}

test "remove_all multi-byte" {
    // Remove heart from "a heart b heart c"
    const s = stz_string_from("a\xe2\x99\xa5b\xe2\x99\xa5c", 9);
    const r = stz_string_remove_all(s, "\xe2\x99\xa5", 3);
    try std.testing.expectEqual(@as(usize, 3), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..3], "abc"));
    stz_string_free(r);
    stz_string_free(s);
}

test "lines_count" {
    const s1 = stz_string_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_lines_count(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("a\nb\nc", 5);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_lines_count(s2));
    stz_string_free(s2);

    const s3 = stz_string_new();
    try std.testing.expectEqual(@as(c_int, 0), stz_string_lines_count(s3));
    stz_string_free(s3);
}

test "is_palindrome ascii" {
    const s1 = stz_string_from("racecar", 7);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_palindrome(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_palindrome(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("a", 1);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_palindrome(s3));
    stz_string_free(s3);
}

test "is_palindrome unicode" {
    // heart bullet heart = palindrome
    const str = "\xe2\x99\xa5\xe2\x80\xa2\xe2\x99\xa5";
    const s = stz_string_from(str, 9);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_palindrome(s));
    stz_string_free(s);
}

test "concat" {
    const h1 = stz_string_from("Hello", 5);
    const h2 = stz_string_from(" World", 6);
    const r = stz_string_concat(h1, h2);
    try std.testing.expectEqual(@as(usize, 11), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..11], "Hello World"));
    stz_string_free(r);
    stz_string_free(h1);
    stz_string_free(h2);
}

test "is_ascii" {
    const ascii = stz_string_from("Hello 123!", 10);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_ascii(ascii));
    stz_string_free(ascii);

    const uni = stz_string_from("caf\xC3\xA9", 5);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_ascii(uni));
    stz_string_free(uni);
}

test "remove_char_at" {
    const s = stz_string_from("abcde", 5);
    // Remove 'c' at index 2
    const r = stz_string_remove_char_at(s, 2);
    try std.testing.expectEqual(@as(usize, 4), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..4], "abde"));
    stz_string_free(r);
    stz_string_free(s);
}

test "char_type_at" {
    const s = stz_string_from("A1 z!", 5);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_char_type_at(s, 0)); // 'A' = upper
    try std.testing.expectEqual(@as(c_int, 1), stz_string_char_type_at(s, 1)); // '1' = digit
    try std.testing.expectEqual(@as(c_int, 2), stz_string_char_type_at(s, 2)); // ' ' = space
    try std.testing.expectEqual(@as(c_int, 4), stz_string_char_type_at(s, 3)); // 'z' = lower
    try std.testing.expectEqual(@as(c_int, 5), stz_string_char_type_at(s, 4)); // '!' = punct
    stz_string_free(s);
}

test "find_chars_of_type letters" {
    const s = stz_string_from("a1b2c", 5);
    const r = stz_string_find_chars_of_type(s, 0); // letters
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 0), stz_find_result_get(r, 0)); // 'a'
    try std.testing.expectEqual(@as(i64, 2), stz_find_result_get(r, 1)); // 'b'
    try std.testing.expectEqual(@as(i64, 4), stz_find_result_get(r, 2)); // 'c'
    stz_find_result_free(r);
    stz_string_free(s);
}

test "find_chars_of_type digits" {
    const s = stz_string_from("a1b2c", 5);
    const r = stz_string_find_chars_of_type(s, 1); // digits
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r, 0)); // '1'
    try std.testing.expectEqual(@as(i64, 3), stz_find_result_get(r, 1)); // '2'
    stz_find_result_free(r);
    stz_string_free(s);
}

test "extract_chars_of_type letters" {
    const s = stz_string_from("H3ll0 W0rld!", 12);
    const r = stz_string_extract_chars_of_type(s, 0); // letters
    try std.testing.expectEqual(@as(usize, 6), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..6], "HllWrl"));
    stz_string_free(r);
    stz_string_free(s);
}

test "extract_chars_of_type digits" {
    const s = stz_string_from("abc123def456", 12);
    const r = stz_string_extract_chars_of_type(s, 1); // digits
    try std.testing.expectEqual(@as(usize, 6), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..6], "123456"));
    stz_string_free(r);
    stz_string_free(s);
}

test "is_uppercase" {
    const s1 = stz_string_from("HELLO", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_uppercase(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_uppercase(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("HELLO 123!", 10);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_uppercase(s3));
    stz_string_free(s3);

    const s4 = stz_string_from("123", 3);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_uppercase(s4));
    stz_string_free(s4);
}

test "is_lowercase" {
    const s1 = stz_string_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_lowercase(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_lowercase(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("hello 123!", 10);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_lowercase(s3));
    stz_string_free(s3);
}

test "is_whitespace" {
    const s1 = stz_string_from("   ", 3);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_whitespace(s1));
    stz_string_free(s1);

    const s2 = stz_string_from(" a ", 3);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_whitespace(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_whitespace(s3));
    stz_string_free(s3);
}

test "word_count" {
    const s1 = stz_string_from("hello world", 11);
    try std.testing.expectEqual(@as(c_int, 2), stz_string_word_count(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("  hello   world  ", 17);
    try std.testing.expectEqual(@as(c_int, 2), stz_string_word_count(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("one", 3);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_word_count(s3));
    stz_string_free(s3);

    const s4 = stz_string_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_word_count(s4));
    stz_string_free(s4);
}

test "is_only_type" {
    const s1 = stz_string_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_only_type(s1, 0)); // letters
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_only_type(s1, 1)); // digits
    stz_string_free(s1);

    const s2 = stz_string_from("123", 3);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_only_type(s2, 1)); // digits
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_only_type(s2, 0)); // letters
    stz_string_free(s2);

    const s3 = stz_string_from("   ", 3);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_only_type(s3, 2)); // space
    stz_string_free(s3);
}

test "trim" {
    const s1 = stz_string_from("  hello  ", 9);
    const r1 = stz_string_trim(s1);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(r1));
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..5], "hello"));
    stz_string_free(r1);
    stz_string_free(s1);

    const s2 = stz_string_from("hello", 5);
    const r2 = stz_string_trim(s2);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(r2));
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..5], "hello"));
    stz_string_free(r2);
    stz_string_free(s2);

    const s3 = stz_string_from("   ", 3);
    const r3 = stz_string_trim(s3);
    try std.testing.expectEqual(@as(usize, 0), stz_string_size(r3));
    stz_string_free(r3);
    stz_string_free(s3);
}

test "swap_case" {
    const s1 = stz_string_from("Hello World", 11);
    const r1 = stz_string_swap_case(s1);
    try std.testing.expectEqual(@as(usize, 11), stz_string_size(r1));
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..11], "hELLO wORLD"));
    stz_string_free(r1);
    stz_string_free(s1);

    const s2 = stz_string_from("123", 3);
    const r2 = stz_string_swap_case(s2);
    try std.testing.expectEqual(@as(usize, 3), stz_string_size(r2));
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..3], "123"));
    stz_string_free(r2);
    stz_string_free(s2);
}

test "remove_chars_of_type" {
    const s1 = stz_string_from("Hello 123 World!", 16);
    // Remove digits
    const r1 = stz_string_remove_chars_of_type(s1, 1);
    try std.testing.expectEqual(@as(usize, 13), stz_string_size(r1));
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..13], "Hello  World!"));
    stz_string_free(r1);
    // Remove spaces
    const r2 = stz_string_remove_chars_of_type(s1, 2);
    try std.testing.expectEqual(@as(usize, 14), stz_string_size(r2));
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..14], "Hello123World!"));
    stz_string_free(r2);
    // Remove punctuation
    const r3 = stz_string_remove_chars_of_type(s1, 5);
    try std.testing.expectEqual(@as(usize, 15), stz_string_size(r3));
    try std.testing.expect(mem.eql(u8, stz_string_data(r3)[0..15], "Hello 123 World"));
    stz_string_free(r3);
    stz_string_free(s1);
}

test "unique_chars" {
    const s = stz_string_from("aabbcc", 6);
    const u = stz_string_unique_chars(s);
    try std.testing.expectEqual(@as(usize, 3), stz_string_size(u));
    try std.testing.expect(mem.eql(u8, stz_string_data(u)[0..3], "abc"));
    stz_string_free(u);
    stz_string_free(s);

    const s_hello = stz_string_from("Hello", 5);
    const u_hello = stz_string_unique_chars(s_hello);
    try std.testing.expectEqual(@as(usize, 4), stz_string_size(u_hello));
    try std.testing.expect(mem.eql(u8, stz_string_data(u_hello)[0..4], "Helo"));
    stz_string_free(u_hello);
    stz_string_free(s_hello);
}

test "unique_char_count" {
    const s = stz_string_from("aabbcc", 6);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_unique_char_count(s));
    stz_string_free(s);

    const s_hello = stz_string_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 4), stz_string_unique_char_count(s_hello));
    stz_string_free(s_hello);
}

test "remove_all_ci" {
    const s = stz_string_from("Hello HELLO hello", 17);
    const r = stz_string_remove_all_ci(s, "hello", 5);
    try std.testing.expectEqual(@as(usize, 2), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..2], "  "));
    stz_string_free(r);
    stz_string_free(s);
}

test "is_alpha_only" {
    const s1 = stz_string_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_alpha_only(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("Hello123", 8);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_alpha_only(s2));
    stz_string_free(s2);
}

test "is_alnum" {
    const s1 = stz_string_from("Hello123", 8);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_alnum(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("Hello 123", 9);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_alnum(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_alnum(s3));
    stz_string_free(s3);
}

test "contains_char" {
    const s = stz_string_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_contains_char(s, 'H'));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_contains_char(s, 'o'));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_contains_char(s, 'Z'));
    stz_string_free(s);
}

test "between_nth" {
    const s = stz_string_from("[a] [b] [c]", 11);
    const r0 = stz_string_between_nth(s, "[", 1, "]", 1, 0);
    try std.testing.expect(r0 != null);
    try std.testing.expect(mem.eql(u8, stz_string_data(r0)[0..1], "a"));
    stz_string_free(r0);

    const r1 = stz_string_between_nth(s, "[", 1, "]", 1, 1);
    try std.testing.expect(r1 != null);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..1], "b"));
    stz_string_free(r1);

    const r2 = stz_string_between_nth(s, "[", 1, "]", 1, 2);
    try std.testing.expect(r2 != null);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..1], "c"));
    stz_string_free(r2);

    const r3 = stz_string_between_nth(s, "[", 1, "]", 1, 3);
    try std.testing.expect(r3 == null);
    stz_string_free(s);
}

test "count_between" {
    const s = stz_string_from("[a] [b] [c]", 11);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_count_between(s, "[", 1, "]", 1));
    stz_string_free(s);

    const s2 = stz_string_from("no brackets", 11);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_count_between(s2, "[", 1, "]", 1));
    stz_string_free(s2);
}

test "replace_char_at" {
    const s = stz_string_from("Hello", 5);
    const r = stz_string_replace_char_at(s, 0, "J", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..5], "Jello"));
    stz_string_free(r);

    // Replace with multi-byte
    const r2 = stz_string_replace_char_at(s, 4, "!", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..5], "Hell!"));
    stz_string_free(r2);

    // Replace with empty (deletion)
    const r3 = stz_string_replace_char_at(s, 0, "", 0);
    try std.testing.expectEqual(@as(usize, 4), stz_string_size(r3));
    try std.testing.expect(mem.eql(u8, stz_string_data(r3)[0..4], "ello"));
    stz_string_free(r3);

    stz_string_free(s);
}

test "levenshtein" {
    const s1 = stz_string_from("kitten", 6);
    const s2 = stz_string_from("sitting", 7);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_levenshtein(s1, s2));
    stz_string_free(s1);
    stz_string_free(s2);

    const s3 = stz_string_from("hello", 5);
    const s4 = stz_string_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_levenshtein(s3, s4));
    stz_string_free(s3);
    stz_string_free(s4);

    const s5 = stz_string_from("", 0);
    const s6 = stz_string_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_levenshtein(s5, s6));
    stz_string_free(s5);
    stz_string_free(s6);
}

test "is_title_case" {
    const s1 = stz_string_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_title_case(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("hello world", 11);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_title_case(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("HELLO", 5);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_title_case(s3));
    stz_string_free(s3);

    const s4 = stz_string_from("A", 1);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_title_case(s4));
    stz_string_free(s4);
}

test "line_at" {
    const s = stz_string_from("line1\nline2\nline3", 17);
    const l0 = stz_string_line_at(s, 0);
    try std.testing.expect(mem.eql(u8, stz_string_data(l0)[0..5], "line1"));
    stz_string_free(l0);

    const l1 = stz_string_line_at(s, 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(l1)[0..5], "line2"));
    stz_string_free(l1);

    const l2 = stz_string_line_at(s, 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(l2)[0..5], "line3"));
    stz_string_free(l2);

    try std.testing.expect(stz_string_line_at(s, 3) == null);
    stz_string_free(s);

    // CRLF
    const s2 = stz_string_from("a\r\nb\r\nc", 7);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_lines_split_count(s2));
    const la = stz_string_line_at(s2, 0);
    try std.testing.expect(mem.eql(u8, stz_string_data(la)[0..1], "a"));
    stz_string_free(la);
    stz_string_free(s2);
}

test "simplify" {
    const s1 = stz_string_from("  hello   world  ", 17);
    const r1 = stz_string_simplify(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..11], "hello world"));
    try std.testing.expectEqual(@as(usize, 11), stz_string_size(r1));
    stz_string_free(r1);
    stz_string_free(s1);

    // Tabs and newlines
    const s2 = stz_string_from("\thello\n\n  world\r\n", 18);
    const r2 = stz_string_simplify(s2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..11], "hello world"));
    stz_string_free(r2);
    stz_string_free(s2);
}

test "starts_with_digit_letter" {
    const s1 = stz_string_from("123abc", 6);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_starts_with_digit(s1));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_starts_with_letter(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_starts_with_digit(s2));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_starts_with_letter(s2));
    stz_string_free(s2);
}

test "ends_with_digit_letter" {
    const s1 = stz_string_from("abc123", 6);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_ends_with_digit(s1));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_ends_with_letter(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_ends_with_digit(s2));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_ends_with_letter(s2));
    stz_string_free(s2);
}

// ─── IsWord: letters, digits, underscore, hyphen ───

pub fn stz_string_is_word(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return 0;
        if (off + cp_len > buf.len) return 0;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch return 0;
        // underscore=95, hyphen=45
        if (cp_val != 95 and cp_val != 45 and
            unicode.stz_unicode_is_letter(cp_val) == 0 and
            unicode.stz_unicode_is_digit(cp_val) == 0)
        {
            return 0;
        }
        off += cp_len;
    }
    return 1;
}

// ─── CountLeadingChar / CountTrailingChar ───

pub fn stz_string_count_leading_char(handle: StzStringHandle, codepoint: u32) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    var off: usize = 0;
    var count: c_int = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        if (cp_val != codepoint) break;
        count += 1;
        off += cp_len;
    }
    return count;
}

pub fn stz_string_count_trailing_char(handle: StzStringHandle, codepoint: u32) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    // Walk from the end backwards through UTF-8 sequences
    var count: c_int = 0;
    var pos: usize = buf.len;
    while (pos > 0) {
        // Find start of previous codepoint
        var start = pos - 1;
        while (start > 0 and (buf[start] & 0xC0) == 0x80) {
            start -= 1;
        }
        const cp_len = pos - start;
        const cp_val = std.unicode.utf8Decode(buf[start..pos]) catch break;
        _ = cp_len;
        if (cp_val != codepoint) break;
        count += 1;
        pos = start;
    }
    return count;
}

// ─── IsNumericString: all digits, optional leading +/- ───

pub fn stz_string_is_numeric_string(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    var off: usize = 0;
    // Allow optional leading sign
    if (buf[0] == '+' or buf[0] == '-') {
        off = 1;
        if (off >= buf.len) return 0; // sign alone is not numeric
    }

    var has_digit = false;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return 0;
        if (off + cp_len > buf.len) return 0;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch return 0;
        if (unicode.stz_unicode_is_digit(cp_val) == 0) return 0;
        has_digit = true;
        off += cp_len;
    }
    return if (has_digit) @as(c_int, 1) else @as(c_int, 0);
}

// ─── URLEncode ───

pub fn stz_string_url_encode(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    const hex = "0123456789ABCDEF";
    for (buf) |byte| {
        if (isUnreserved(byte)) {
            result.data.append(gpa, byte) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        } else {
            result.data.appendSlice(gpa, &[_]u8{
                '%',
                hex[byte >> 4],
                hex[byte & 0x0F],
            }) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        }
    }
    return result;
}

fn isUnreserved(c: u8) bool {
    return (c >= 'A' and c <= 'Z') or
        (c >= 'a' and c <= 'z') or
        (c >= '0' and c <= '9') or
        c == '-' or c == '_' or c == '.' or c == '~';
}

// ─── URLDecode ───

pub fn stz_string_url_decode(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var i: usize = 0;
    while (i < buf.len) {
        if (buf[i] == '%' and i + 2 < buf.len) {
            const hi = hexVal(buf[i + 1]);
            const lo = hexVal(buf[i + 2]);
            if (hi != null and lo != null) {
                result.data.append(gpa, (hi.? << 4) | lo.?) catch {
                    result.deinit();
                    gpa.destroy(result);
                    return null;
                };
                i += 3;
                continue;
            }
        }
        result.data.append(gpa, buf[i]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        i += 1;
    }
    return result;
}

fn hexVal(c: u8) ?u8 {
    if (c >= '0' and c <= '9') return c - '0';
    if (c >= 'A' and c <= 'F') return c - 'A' + 10;
    if (c >= 'a' and c <= 'f') return c - 'a' + 10;
    return null;
}

// ─── CharAtToString: return codepoint at cp-index as UTF-8 string handle ───

pub fn stz_string_char_at_to_string(handle: StzStringHandle, cp_index: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    const idx: usize = if (cp_index >= 0) @intCast(cp_index) else return null;

    var off: usize = 0;
    var cp_i: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return null;
        if (off + cp_len > buf.len) return null;
        if (cp_i == idx) {
            const result = gpa.create(StzString) catch return null;
            result.* = StzString.init();
            result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            return result;
        }
        off += cp_len;
        cp_i += 1;
    }
    return null;
}

// ─── SpacifyChars: "abc" → "a b c" (codepoint-aware) ───

pub fn stz_string_spacify(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        return result;
    }

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var off: usize = 0;
    var first = true;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        if (!first) {
            result.data.append(gpa, ' ') catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        }
        result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        first = false;
        off += cp_len;
    }
    return result;
}

// ─── NumberOfBytesPerChar: returns list as "1 1 2 3" for mixed-byte chars ───

pub fn stz_string_bytes_per_char(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var off: usize = 0;
    var first = true;
    var num_buf: [4]u8 = undefined;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        if (!first) {
            result.data.append(gpa, ' ') catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        }
        // cp_len is 1..4, write as ASCII digit
        num_buf[0] = '0' + @as(u8, @intCast(cp_len));
        result.data.append(gpa, num_buf[0]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        first = false;
        off += cp_len;
    }
    return result;
}

// ─── Tests for new functions ───

test "is_word" {
    const s1 = stz_string_from("hello-world_123", 15);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_word(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("hello world", 11);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_word(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_word(s3));
    stz_string_free(s3);
}

test "count_leading_trailing_char" {
    const s1 = stz_string_from("   hello", 8);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_count_leading_char(s1, ' '));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_count_trailing_char(s1, ' '));
    stz_string_free(s1);

    const s2 = stz_string_from("hello...", 8);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_count_leading_char(s2, '.'));
    try std.testing.expectEqual(@as(c_int, 3), stz_string_count_trailing_char(s2, '.'));
    stz_string_free(s2);
}

test "is_numeric_string" {
    const s1 = stz_string_from("12345", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_numeric_string(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("+42", 3);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_numeric_string(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("-7", 2);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_numeric_string(s3));
    stz_string_free(s3);

    const s4 = stz_string_from("12.5", 4);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_numeric_string(s4));
    stz_string_free(s4);

    const s5 = stz_string_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_numeric_string(s5));
    stz_string_free(s5);
}

test "url_encode_decode" {
    const s1 = stz_string_from("hello world", 11);
    const enc = stz_string_url_encode(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(enc)[0..@intCast(stz_string_size(enc))], "hello%20world"));

    const dec = stz_string_url_decode(enc);
    try std.testing.expect(mem.eql(u8, stz_string_data(dec)[0..@intCast(stz_string_size(dec))], "hello world"));

    stz_string_free(dec);
    stz_string_free(enc);
    stz_string_free(s1);
}

test "char_at_to_string" {
    const s1 = stz_string_from("Hello", 5);
    const ch = stz_string_char_at_to_string(s1, 0);
    try std.testing.expect(ch != null);
    try std.testing.expect(mem.eql(u8, stz_string_data(ch)[0..@intCast(stz_string_size(ch))], "H"));
    stz_string_free(ch);
    stz_string_free(s1);
}

test "spacify" {
    const s1 = stz_string_from("abc", 3);
    const sp = stz_string_spacify(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(sp)[0..@intCast(stz_string_size(sp))], "a b c"));
    stz_string_free(sp);
    stz_string_free(s1);
}

test "bytes_per_char" {
    const s1 = stz_string_from("ab", 2);
    const bp = stz_string_bytes_per_char(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(bp)[0..@intCast(stz_string_size(bp))], "1 1"));
    stz_string_free(bp);
    stz_string_free(s1);
}

// ─── IsHexString: all chars are 0-9, a-f, A-F, optional 0x prefix ───

pub fn stz_string_is_hex_string(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    var off: usize = 0;
    // Skip optional 0x or 0X prefix
    if (buf.len >= 2 and buf[0] == '0' and (buf[1] == 'x' or buf[1] == 'X')) {
        off = 2;
        if (off >= buf.len) return 0;
    }

    var has_hex = false;
    while (off < buf.len) {
        const b = buf[off];
        if ((b >= '0' and b <= '9') or (b >= 'a' and b <= 'f') or (b >= 'A' and b <= 'F')) {
            has_hex = true;
        } else {
            return 0;
        }
        off += 1;
    }
    return if (has_hex) @as(c_int, 1) else @as(c_int, 0);
}

// ─── IsBinaryString: all chars are 0 or 1, optional 0b prefix ───

pub fn stz_string_is_binary_string(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    var off: usize = 0;
    if (buf.len >= 2 and buf[0] == '0' and (buf[1] == 'b' or buf[1] == 'B')) {
        off = 2;
        if (off >= buf.len) return 0;
    }

    var has_bit = false;
    while (off < buf.len) {
        if (buf[off] != '0' and buf[off] != '1') return 0;
        has_bit = true;
        off += 1;
    }
    return if (has_bit) @as(c_int, 1) else @as(c_int, 0);
}

// ─── IsOctalString: all chars are 0-7, optional 0o prefix ───

pub fn stz_string_is_octal_string(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    var off: usize = 0;
    if (buf.len >= 2 and buf[0] == '0' and (buf[1] == 'o' or buf[1] == 'O')) {
        off = 2;
        if (off >= buf.len) return 0;
    }

    var has_oct = false;
    while (off < buf.len) {
        if (buf[off] < '0' or buf[off] > '7') return 0;
        has_oct = true;
        off += 1;
    }
    return if (has_oct) @as(c_int, 1) else @as(c_int, 0);
}

// ─── WordAt: get nth word (0-based), words separated by whitespace ───

pub fn stz_string_word_at(handle: StzStringHandle, word_index: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    const target: usize = if (word_index >= 0) @intCast(word_index) else return null;

    var wi: usize = 0;
    var i: usize = 0;

    // Skip leading whitespace
    while (i < buf.len and isWhitespace(buf[i])) : (i += 1) {}

    while (i < buf.len) {
        // Find word start (already at non-space)
        const start = i;
        // Find word end
        while (i < buf.len and !isWhitespace(buf[i])) : (i += 1) {}
        if (wi == target) {
            const result = gpa.create(StzString) catch return null;
            result.* = StzString.init();
            result.data.appendSlice(gpa, buf[start..i]) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            return result;
        }
        wi += 1;
        // Skip whitespace between words
        while (i < buf.len and isWhitespace(buf[i])) : (i += 1) {}
    }
    return null;
}

fn isWhitespace(c: u8) bool {
    return c == ' ' or c == '\t' or c == '\n' or c == '\r';
}

// ─── CenterPad: pad string to target width, centering content ───

pub fn stz_string_center(handle: StzStringHandle, target_width: c_int, pad_char: u32) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    const tw: usize = if (target_width >= 0) @intCast(target_width) else return null;

    // Count codepoints
    var cp_count: usize = 0;
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        cp_count += 1;
        off += cp_len;
    }

    if (cp_count >= tw) {
        // Already wide enough, return copy
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        result.data.appendSlice(gpa, buf) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        return result;
    }

    const total_pad = tw - cp_count;
    const left_pad = total_pad / 2;
    const right_pad = total_pad - left_pad;

    var pad_bytes: [4]u8 = undefined;
    const pad_cp: u21 = @intCast(pad_char);
    const pad_len = std.unicode.utf8Encode(pad_cp, &pad_bytes) catch return null;

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    // Left padding
    for (0..left_pad) |_| {
        result.data.appendSlice(gpa, pad_bytes[0..pad_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    // Content
    result.data.appendSlice(gpa, buf) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    // Right padding
    for (0..right_pad) |_| {
        result.data.appendSlice(gpa, pad_bytes[0..pad_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── RemoveConsecutiveDuplicates: "aabbcc" → "abc" ───

pub fn stz_string_remove_consecutive_duplicates(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    if (buf.len == 0) return result;

    var off: usize = 0;
    var prev_cp: u21 = 0x10FFFF; // max valid codepoint, used as sentinel
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        if (cp_val != prev_cp) {
            result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            prev_cp = cp_val;
        }
        off += cp_len;
    }
    return result;
}

// ─── Tests for new batch ───

test "is_hex_string" {
    const s1 = stz_string_from("0xFF", 4);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_hex_string(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("deadBEEF", 8);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_hex_string(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("0xGG", 4);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_hex_string(s3));
    stz_string_free(s3);
}

test "is_binary_string" {
    const s1 = stz_string_from("0b1010", 6);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_binary_string(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("1100", 4);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_binary_string(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("1020", 4);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_binary_string(s3));
    stz_string_free(s3);
}

test "is_octal_string" {
    const s1 = stz_string_from("0o777", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_octal_string(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("0o89", 4);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_octal_string(s2));
    stz_string_free(s2);
}

test "word_at" {
    const s1 = stz_string_from("hello world foo", 15);
    const w0 = stz_string_word_at(s1, 0);
    try std.testing.expect(mem.eql(u8, stz_string_data(w0)[0..@intCast(stz_string_size(w0))], "hello"));
    stz_string_free(w0);

    const w2 = stz_string_word_at(s1, 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(w2)[0..@intCast(stz_string_size(w2))], "foo"));
    stz_string_free(w2);

    const w3 = stz_string_word_at(s1, 3);
    try std.testing.expectEqual(@as(StzStringHandle, null), w3);
    stz_string_free(s1);
}

test "center" {
    const s1 = stz_string_from("hi", 2);
    const c1 = stz_string_center(s1, 6, ' ');
    try std.testing.expect(mem.eql(u8, stz_string_data(c1)[0..@intCast(stz_string_size(c1))], "  hi  "));
    stz_string_free(c1);
    stz_string_free(s1);
}

test "remove_consecutive_duplicates" {
    const s1 = stz_string_from("aabbcc", 6);
    const r1 = stz_string_remove_consecutive_duplicates(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "abc"));
    stz_string_free(r1);
    stz_string_free(s1);

    const s2 = stz_string_from("mississippi", 11);
    const r2 = stz_string_remove_consecutive_duplicates(s2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "misisipi"));
    stz_string_free(r2);
    stz_string_free(s2);
}

// ─── Substring: extract between two 0-based codepoint positions (inclusive) ───

pub fn stz_string_substring(handle: StzStringHandle, from_cp: c_int, to_cp: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    const from: usize = if (from_cp >= 0) @intCast(from_cp) else return null;
    const to: usize = if (to_cp >= 0) @intCast(to_cp) else return null;
    if (to < from) return null;

    var off: usize = 0;
    var cp_i: usize = 0;
    var start_byte: usize = 0;
    var end_byte: usize = 0;
    var found_start = false;

    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        if (cp_i == from) {
            start_byte = off;
            found_start = true;
        }
        if (cp_i == to) {
            end_byte = off + cp_len;
            break;
        }
        off += cp_len;
        cp_i += 1;
    }

    if (!found_start) return null;
    // Handle case where to_cp is the last codepoint
    if (end_byte == 0 and cp_i == to) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return null;
        end_byte = off + cp_len;
    }

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, buf[start_byte..end_byte]) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    return result;
}

// ─── ReplaceSubstring: replace codepoint range [from..to] with new string ───

pub fn stz_string_replace_substring(handle: StzStringHandle, from_cp: c_int, to_cp: c_int, replacement: [*c]const u8, rep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    const from: usize = if (from_cp >= 0) @intCast(from_cp) else return null;
    const to: usize = if (to_cp >= 0) @intCast(to_cp) else return null;
    if (to < from) return null;

    var off: usize = 0;
    var cp_i: usize = 0;
    var start_byte: usize = 0;
    var end_byte: usize = buf.len;
    var found_start = false;

    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        if (cp_i == from) {
            start_byte = off;
            found_start = true;
        }
        if (cp_i == to) {
            end_byte = off + cp_len;
            break;
        }
        off += cp_len;
        cp_i += 1;
    }

    if (!found_start) return null;

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    // Before range
    result.data.appendSlice(gpa, buf[0..start_byte]) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    // Replacement
    if (replacement != null and rep_len > 0) {
        result.data.appendSlice(gpa, replacement[0..rep_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    // After range
    if (end_byte < buf.len) {
        result.data.appendSlice(gpa, buf[end_byte..]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── HasPrefix / HasSuffix with count (how many times a prefix/suffix repeats) ───

pub fn stz_string_prefix_count(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (prefix == null or prefix_len == 0 or buf.len == 0) return 0;
    const pref = prefix[0..prefix_len];

    var count: c_int = 0;
    var off: usize = 0;
    while (off + prefix_len <= buf.len) {
        if (mem.eql(u8, buf[off .. off + prefix_len], pref)) {
            count += 1;
            off += prefix_len;
        } else {
            break;
        }
    }
    return count;
}

pub fn stz_string_suffix_count(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (suffix == null or suffix_len == 0 or buf.len == 0) return 0;
    const suf = suffix[0..suffix_len];

    var count: c_int = 0;
    var pos: usize = buf.len;
    while (pos >= suffix_len) {
        if (mem.eql(u8, buf[pos - suffix_len .. pos], suf)) {
            count += 1;
            pos -= suffix_len;
        } else {
            break;
        }
    }
    return count;
}

// ─── CommonPrefix / CommonSuffix between two strings ───

pub fn stz_string_common_prefix(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const b1 = s1.slice();
    const b2 = s2.slice();

    var off: usize = 0;
    var last_cp_end: usize = 0;
    while (off < b1.len and off < b2.len) {
        const len1 = std.unicode.utf8ByteSequenceLength(b1[off]) catch break;
        const len2 = std.unicode.utf8ByteSequenceLength(b2[off]) catch break;
        if (len1 != len2 or off + len1 > b1.len or off + len2 > b2.len) break;
        if (!mem.eql(u8, b1[off .. off + len1], b2[off .. off + len2])) break;
        off += len1;
        last_cp_end = off;
    }

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    if (last_cp_end > 0) {
        result.data.appendSlice(gpa, b1[0..last_cp_end]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

pub fn stz_string_common_suffix(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const b1 = s1.slice();
    const b2 = s2.slice();

    if (b1.len == 0 or b2.len == 0) {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        return result;
    }

    // Walk backwards byte by byte, but verify codepoint boundaries
    var i: usize = 0;
    const min_len = @min(b1.len, b2.len);
    while (i < min_len) {
        if (b1[b1.len - 1 - i] != b2[b2.len - 1 - i]) break;
        i += 1;
    }

    // Adjust to codepoint boundary
    const start = b1.len - i;
    var adjusted_start = start;
    while (adjusted_start < b1.len and (b1[adjusted_start] & 0xC0) == 0x80) {
        adjusted_start += 1;
    }

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    if (adjusted_start < b1.len) {
        result.data.appendSlice(gpa, b1[adjusted_start..]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── Tests for new batch ───

test "substring" {
    const s1 = stz_string_from("Hello World", 11);
    const sub = stz_string_substring(s1, 0, 4);
    try std.testing.expect(mem.eql(u8, stz_string_data(sub)[0..@intCast(stz_string_size(sub))], "Hello"));
    stz_string_free(sub);

    const sub2 = stz_string_substring(s1, 6, 10);
    try std.testing.expect(mem.eql(u8, stz_string_data(sub2)[0..@intCast(stz_string_size(sub2))], "World"));
    stz_string_free(sub2);
    stz_string_free(s1);
}

test "replace_substring" {
    const s1 = stz_string_from("Hello World", 11);
    const r1 = stz_string_replace_substring(s1, 6, 10, "Zig", 3);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "Hello Zig"));
    stz_string_free(r1);
    stz_string_free(s1);
}

test "prefix_suffix_count" {
    const s1 = stz_string_from("ababab", 6);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_prefix_count(s1, "ab", 2));
    stz_string_free(s1);

    const s2 = stz_string_from("xyzxyzxyz", 9);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_suffix_count(s2, "xyz", 3));
    stz_string_free(s2);
}

test "common_prefix_suffix" {
    const s1 = stz_string_from("hello world", 11);
    const s2 = stz_string_from("hello there", 11);
    const cp = stz_string_common_prefix(s1, s2);
    try std.testing.expect(mem.eql(u8, stz_string_data(cp)[0..@intCast(stz_string_size(cp))], "hello "));
    stz_string_free(cp);
    stz_string_free(s2);
    stz_string_free(s1);

    const s3 = stz_string_from("testing", 7);
    const s4 = stz_string_from("working", 7);
    const cs = stz_string_common_suffix(s3, s4);
    try std.testing.expect(mem.eql(u8, stz_string_data(cs)[0..@intCast(stz_string_size(cs))], "ing"));
    stz_string_free(cs);
    stz_string_free(s4);
    stz_string_free(s3);
}

// ─── SortChars: sort codepoints ascending/descending ───

pub fn stz_string_sort_chars_asc(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        return result;
    }

    // Collect codepoints
    var cps: std.ArrayList(u21) = .{};
    defer cps.deinit(gpa);
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        cps.append(gpa, cp_val) catch return null;
        off += cp_len;
    }

    // Sort ascending
    std.mem.sort(u21, cps.items, {}, std.sort.asc(u21));

    // Rebuild UTF-8
    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    var enc_buf: [4]u8 = undefined;
    for (cps.items) |cp| {
        const enc_len = std.unicode.utf8Encode(cp, &enc_buf) catch continue;
        result.data.appendSlice(gpa, enc_buf[0..enc_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

pub fn stz_string_sort_chars_desc(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        return result;
    }

    var cps: std.ArrayList(u21) = .{};
    defer cps.deinit(gpa);
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        cps.append(gpa, cp_val) catch return null;
        off += cp_len;
    }

    // Sort descending
    std.mem.sort(u21, cps.items, {}, std.sort.desc(u21));

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    var enc_buf: [4]u8 = undefined;
    for (cps.items) |cp| {
        const enc_len = std.unicode.utf8Encode(cp, &enc_buf) catch continue;
        result.data.appendSlice(gpa, enc_buf[0..enc_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── FindAllChar: find all positions of a codepoint ───

pub fn stz_string_find_all_char(handle: StzStringHandle, codepoint: u32) callconv(.c) StzFindResultHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    var positions: std.ArrayList(i64) = .{};
    var off: usize = 0;
    var cp_i: i64 = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        if (cp_val == codepoint) {
            positions.append(gpa, cp_i) catch return null;
        }
        off += cp_len;
        cp_i += 1;
    }

    const fr = gpa.create(StzFindResult) catch return null;
    fr.* = .{ .positions = positions };
    return fr;
}

// ─── Hash: simple FNV-1a hash of the string bytes ───

pub fn stz_string_hash(handle: StzStringHandle) callconv(.c) u64 {
    const s = handle orelse return 0;
    const buf = s.slice();
    var hash: u64 = 0xcbf29ce484222325; // FNV offset basis
    for (buf) |byte| {
        hash ^= byte;
        hash *%= 0x100000001b3; // FNV prime
    }
    return hash;
}

// ─── CountChar: count occurrences of a specific codepoint ───

pub fn stz_string_count_char(handle: StzStringHandle, codepoint: u32) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    var count: c_int = 0;
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        if (cp_val == codepoint) count += 1;
        off += cp_len;
    }
    return count;
}

// ─── ReplaceChar: replace all occurrences of one codepoint with another ───

pub fn stz_string_replace_char(handle: StzStringHandle, old_cp: u32, new_cp: u32) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var new_bytes: [4]u8 = undefined;
    const new_cp21: u21 = @intCast(new_cp);
    const new_len = std.unicode.utf8Encode(new_cp21, &new_bytes) catch return null;

    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        if (cp_val == old_cp) {
            result.data.appendSlice(gpa, new_bytes[0..new_len]) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        } else {
            result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        }
        off += cp_len;
    }
    return result;
}

// ─── Copy ───

pub fn stz_string_copy(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, buf) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    return result;
}

// ─── Compare ───

pub fn stz_string_compare(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    const s1 = h1 orelse return -2;
    const s2 = h2 orelse return -2;
    const buf1 = s1.slice();
    const buf2 = s2.slice();

    // Codepoint-by-codepoint comparison
    var off1: usize = 0;
    var off2: usize = 0;
    while (off1 < buf1.len and off2 < buf2.len) {
        const len1 = std.unicode.utf8ByteSequenceLength(buf1[off1]) catch return -2;
        const len2 = std.unicode.utf8ByteSequenceLength(buf2[off2]) catch return -2;
        if (off1 + len1 > buf1.len or off2 + len2 > buf2.len) return -2;
        const cp1 = std.unicode.utf8Decode(buf1[off1..][0..len1]) catch return -2;
        const cp2 = std.unicode.utf8Decode(buf2[off2..][0..len2]) catch return -2;
        if (cp1 < cp2) return -1;
        if (cp1 > cp2) return 1;
        off1 += len1;
        off2 += len2;
    }
    if (off1 < buf1.len) return 1; // s1 longer
    if (off2 < buf2.len) return -1; // s2 longer
    return 0;
}

// ─── RemoveFirstOccurrence ───

pub fn stz_string_remove_first_occurrence(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (needle == null or needle_len == 0 or needle_len > buf.len) {
        // Return copy of original
        return stz_string_copy(handle);
    }
    const n: []const u8 = needle[0..needle_len];

    if (mem.indexOf(u8, buf, n)) |pos| {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        result.data.appendSlice(gpa, buf[0..pos]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        result.data.appendSlice(gpa, buf[pos + needle_len ..]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        return result;
    }
    return stz_string_copy(handle);
}

// ─── RemoveLastOccurrence ───

pub fn stz_string_remove_last_occurrence(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (needle == null or needle_len == 0 or needle_len > buf.len) {
        return stz_string_copy(handle);
    }
    const n: []const u8 = needle[0..needle_len];

    // Find last occurrence by scanning all
    var last_pos: ?usize = null;
    var search_start: usize = 0;
    while (search_start + needle_len <= buf.len) {
        if (mem.indexOf(u8, buf[search_start..], n)) |rel_pos| {
            last_pos = search_start + rel_pos;
            search_start = search_start + rel_pos + 1;
        } else break;
    }

    if (last_pos) |pos| {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        result.data.appendSlice(gpa, buf[0..pos]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        result.data.appendSlice(gpa, buf[pos + needle_len ..]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        return result;
    }
    return stz_string_copy(handle);
}

// ─── IsCharsSortedAsc ───

pub fn stz_string_is_chars_sorted_asc(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 1;

    var off: usize = 0;
    var prev_cp: u21 = 0;
    var first = true;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return 0;
        if (off + cp_len > buf.len) return 0;
        const cp = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch return 0;
        if (!first and cp < prev_cp) return 0;
        prev_cp = cp;
        first = false;
        off += cp_len;
    }
    return 1;
}

// ─── IsCharsSortedDesc ───

pub fn stz_string_is_chars_sorted_desc(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 1;

    var off: usize = 0;
    var prev_cp: u21 = 0;
    var first = true;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return 0;
        if (off + cp_len > buf.len) return 0;
        const cp = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch return 0;
        if (!first and cp > prev_cp) return 0;
        prev_cp = cp;
        first = false;
        off += cp_len;
    }
    return 1;
}

// ─── RemoveNthOccurrence ───

pub fn stz_string_remove_nth_occurrence(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, n: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (needle == null or needle_len == 0 or n < 0 or needle_len > buf.len) {
        return stz_string_copy(handle);
    }
    const ndl: []const u8 = needle[0..needle_len];

    var count: c_int = 0;
    var search_start: usize = 0;
    while (search_start + needle_len <= buf.len) {
        if (mem.indexOf(u8, buf[search_start..], ndl)) |rel_pos| {
            if (count == n) {
                const pos = search_start + rel_pos;
                const result = gpa.create(StzString) catch return null;
                result.* = StzString.init();
                result.data.appendSlice(gpa, buf[0..pos]) catch {
                    result.deinit();
                    gpa.destroy(result);
                    return null;
                };
                result.data.appendSlice(gpa, buf[pos + needle_len ..]) catch {
                    result.deinit();
                    gpa.destroy(result);
                    return null;
                };
                return result;
            }
            count += 1;
            search_start = search_start + rel_pos + 1;
        } else break;
    }
    return stz_string_copy(handle);
}

// ─── RepeatChar ───

pub fn stz_string_repeat_char(cp: u32, count: c_int) callconv(.c) StzStringHandle {
    if (count <= 0) return stz_string_new();

    var char_bytes: [4]u8 = undefined;
    const cp21: u21 = @intCast(cp);
    const char_len = std.unicode.utf8Encode(cp21, &char_bytes) catch return null;

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    const n: usize = @intCast(count);
    result.data.ensureTotalCapacity(gpa, n * char_len) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    for (0..n) |_| {
        result.data.appendSlice(gpa, char_bytes[0..char_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── InsertBeforeEach ───

pub fn stz_string_insert_before_each(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, ins: [*c]const u8, ins_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (needle == null or ins == null or needle_len == 0) return stz_string_copy(handle);
    const ndl: []const u8 = needle[0..needle_len];
    const insert: []const u8 = ins[0..ins_len];

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var pos: usize = 0;
    while (pos < buf.len) {
        if (pos + needle_len <= buf.len and mem.eql(u8, buf[pos..][0..needle_len], ndl)) {
            result.data.appendSlice(gpa, insert) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            result.data.appendSlice(gpa, ndl) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            pos += needle_len;
        } else {
            result.data.append(gpa, buf[pos]) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            pos += 1;
        }
    }
    return result;
}

// ─── InsertAfterEach ───

pub fn stz_string_insert_after_each(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, ins: [*c]const u8, ins_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (needle == null or ins == null or needle_len == 0) return stz_string_copy(handle);
    const ndl: []const u8 = needle[0..needle_len];
    const insert: []const u8 = ins[0..ins_len];

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var pos: usize = 0;
    while (pos < buf.len) {
        if (pos + needle_len <= buf.len and mem.eql(u8, buf[pos..][0..needle_len], ndl)) {
            result.data.appendSlice(gpa, ndl) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            result.data.appendSlice(gpa, insert) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            pos += needle_len;
        } else {
            result.data.append(gpa, buf[pos]) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            pos += 1;
        }
    }
    return result;
}

// ─── Truncate ───

pub fn stz_string_truncate(handle: StzStringHandle, max_cp: c_int, ellipsis: [*c]const u8, ell_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (max_cp <= 0) return stz_string_new();

    // Count codepoints
    var cp_count: usize = 0;
    var off: usize = 0;
    var cut_off: usize = 0;
    const max: usize = @intCast(max_cp);
    while (off < buf.len) {
        if (cp_count == max) {
            cut_off = off;
            break;
        }
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        off += cp_len;
        cp_count += 1;
    }

    // If string fits, return copy
    if (cp_count <= max and off >= buf.len) return stz_string_copy(handle);

    // Need truncation
    if (cut_off == 0) cut_off = off;
    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, buf[0..cut_off]) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    if (ellipsis != null and ell_len > 0) {
        result.data.appendSlice(gpa, ellipsis[0..ell_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── WrapAt ───

pub fn stz_string_wrap_at(handle: StzStringHandle, width: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (width <= 0) return stz_string_copy(handle);
    const w: usize = @intCast(width);

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var line_cp: usize = 0;
    var last_space_result_pos: ?usize = null;
    var off: usize = 0;

    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;

        if (cp_val == '\n') {
            result.data.append(gpa, '\n') catch break;
            off += cp_len;
            line_cp = 0;
            last_space_result_pos = null;
            continue;
        }

        if (cp_val == ' ') {
            last_space_result_pos = result.data.items.len;
        }

        result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch break;
        off += cp_len;
        line_cp += 1;

        if (line_cp >= w and last_space_result_pos != null) {
            // Replace last space with newline
            result.data.items[last_space_result_pos.?] = '\n';
            line_cp = result.data.items.len - last_space_result_pos.? - 1;
            last_space_result_pos = null;
        }
    }
    return result;
}

// ─── RemovePrefix ───

pub fn stz_string_remove_prefix(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (prefix == null or prefix_len == 0 or prefix_len > buf.len) return stz_string_copy(handle);
    const pfx: []const u8 = prefix[0..prefix_len];
    if (mem.startsWith(u8, buf, pfx)) {
        return stz_string_from(buf[prefix_len..].ptr, buf.len - prefix_len);
    }
    return stz_string_copy(handle);
}

// ─── RemoveSuffix ───

pub fn stz_string_remove_suffix(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (suffix == null or suffix_len == 0 or suffix_len > buf.len) return stz_string_copy(handle);
    const sfx: []const u8 = suffix[0..suffix_len];
    if (mem.endsWith(u8, buf, sfx)) {
        return stz_string_from(buf.ptr, buf.len - suffix_len);
    }
    return stz_string_copy(handle);
}

// ─── EnsurePrefix ───

pub fn stz_string_ensure_prefix(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (prefix == null or prefix_len == 0) return stz_string_copy(handle);
    const pfx: []const u8 = prefix[0..prefix_len];
    if (mem.startsWith(u8, buf, pfx)) return stz_string_copy(handle);

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, pfx) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    result.data.appendSlice(gpa, buf) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    return result;
}

// ─── EnsureSuffix ───

pub fn stz_string_ensure_suffix(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (suffix == null or suffix_len == 0) return stz_string_copy(handle);
    const sfx: []const u8 = suffix[0..suffix_len];
    if (mem.endsWith(u8, buf, sfx)) return stz_string_copy(handle);

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, buf) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    result.data.appendSlice(gpa, sfx) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    return result;
}

// ─── SqueezeChar ───

pub fn stz_string_squeeze_char(handle: StzStringHandle, cp: u32) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var off: usize = 0;
    var prev_was_target = false;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        if (cp_val == cp) {
            if (!prev_was_target) {
                result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch break;
                prev_was_target = true;
            }
        } else {
            result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch break;
            prev_was_target = false;
        }
        off += cp_len;
    }
    return result;
}

// ─── CapitalizeFirst ───

pub fn stz_string_capitalize_first(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) return stz_string_new();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    const first_len = std.unicode.utf8ByteSequenceLength(buf[0]) catch {
        result.deinit();
        gpa.destroy(result);
        return stz_string_copy(handle);
    };
    if (first_len > buf.len) return stz_string_copy(handle);
    const first_cp = std.unicode.utf8Decode(buf[0..first_len]) catch return stz_string_copy(handle);

    if (first_cp >= 'a' and first_cp <= 'z') {
        const upper_cp: u21 = @intCast(first_cp - 32);
        var upper_bytes: [4]u8 = undefined;
        const upper_len = std.unicode.utf8Encode(upper_cp, &upper_bytes) catch return stz_string_copy(handle);
        result.data.appendSlice(gpa, upper_bytes[0..upper_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    } else {
        result.data.appendSlice(gpa, buf[0..first_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    if (first_len < buf.len) {
        result.data.appendSlice(gpa, buf[first_len..]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── DecapitalizeFirst ───

pub fn stz_string_decapitalize_first(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) return stz_string_new();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    const first_len = std.unicode.utf8ByteSequenceLength(buf[0]) catch return stz_string_copy(handle);
    if (first_len > buf.len) return stz_string_copy(handle);
    const first_cp = std.unicode.utf8Decode(buf[0..first_len]) catch return stz_string_copy(handle);

    if (first_cp >= 'A' and first_cp <= 'Z') {
        const lower_cp: u21 = @intCast(first_cp + 32);
        var lower_bytes: [4]u8 = undefined;
        const lower_len = std.unicode.utf8Encode(lower_cp, &lower_bytes) catch return stz_string_copy(handle);
        result.data.appendSlice(gpa, lower_bytes[0..lower_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    } else {
        result.data.appendSlice(gpa, buf[0..first_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    if (first_len < buf.len) {
        result.data.appendSlice(gpa, buf[first_len..]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── ZFill ───

pub fn stz_string_zfill(handle: StzStringHandle, width: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (width <= 0) return stz_string_copy(handle);
    const w: usize = @intCast(width);

    var cp_count: usize = 0;
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        off += cp_len;
        cp_count += 1;
    }

    if (cp_count >= w) return stz_string_copy(handle);

    const pad_count = w - cp_count;
    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    for (0..pad_count) |_| {
        result.data.append(gpa, '0') catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    result.data.appendSlice(gpa, buf) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    return result;
}

// ─── TabExpand ───

pub fn stz_string_tab_expand(handle: StzStringHandle, tab_width: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (tab_width <= 0) return stz_string_copy(handle);
    const tw: usize = @intCast(tab_width);

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    for (buf) |byte| {
        if (byte == '\t') {
            for (0..tw) |_| {
                result.data.append(gpa, ' ') catch {
                    result.deinit();
                    gpa.destroy(result);
                    return null;
                };
            }
        } else {
            result.data.append(gpa, byte) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        }
    }
    return result;
}

// ─── CountOverlapping ───
// Count overlapping occurrences of needle in string

pub fn stz_string_count_overlapping(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (needle == null or needle_len == 0 or needle_len > buf.len) return 0;
    const ndl: []const u8 = needle[0..needle_len];

    var count: c_int = 0;
    var pos: usize = 0;
    while (pos + needle_len <= buf.len) {
        if (mem.eql(u8, buf[pos..][0..needle_len], ndl)) {
            count += 1;
            // Move by 1 byte for overlapping (not by needle_len)
            pos += 1;
        } else {
            pos += 1;
        }
    }
    return count;
}

// ─── ReplaceAt ───
// Replace a specific codepoint position range with a new string

pub fn stz_string_replace_at(handle: StzStringHandle, cp_pos: c_int, cp_count: c_int, rep: [*c]const u8, rep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (cp_pos < 0 or cp_count <= 0) return stz_string_copy(handle);

    const target_start: usize = @intCast(cp_pos);
    const target_count: usize = @intCast(cp_count);

    // Find byte offsets for codepoint positions
    var off: usize = 0;
    var cp_idx: usize = 0;
    var start_byte: usize = 0;
    var end_byte: usize = 0;
    var found_start = false;

    while (off < buf.len) {
        if (cp_idx == target_start) {
            start_byte = off;
            found_start = true;
        }
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        off += cp_len;
        cp_idx += 1;
        if (found_start and cp_idx == target_start + target_count) {
            end_byte = off;
            break;
        }
    }
    if (!found_start) return stz_string_copy(handle);
    if (end_byte == 0) end_byte = off; // To end of string

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, buf[0..start_byte]) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    if (rep != null and rep_len > 0) {
        result.data.appendSlice(gpa, rep[0..rep_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    if (end_byte < buf.len) {
        result.data.appendSlice(gpa, buf[end_byte..]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── CharFrequency ───
// Returns "char:count" pairs separated by newlines, e.g. "a:3\nb:2\n"

pub fn stz_string_char_frequency(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) return stz_string_new();

    // Collect codepoints and count them
    var cps: std.ArrayList(u21) = .{};
    defer cps.deinit(gpa);
    var counts: std.ArrayList(usize) = .{};
    defer counts.deinit(gpa);

    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        off += cp_len;

        // Find if already tracked
        var found = false;
        for (cps.items, 0..) |existing, i| {
            if (existing == cp_val) {
                counts.items[i] += 1;
                found = true;
                break;
            }
        }
        if (!found) {
            cps.append(gpa, cp_val) catch break;
            counts.append(gpa, 1) catch break;
        }
    }

    // Build result string
    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    for (cps.items, 0..) |cp_val, i| {
        var cp_bytes: [4]u8 = undefined;
        const cp_byte_len = std.unicode.utf8Encode(cp_val, &cp_bytes) catch continue;
        result.data.appendSlice(gpa, cp_bytes[0..cp_byte_len]) catch break;
        result.data.append(gpa, ':') catch break;

        // Number to string
        var num_buf: [20]u8 = undefined;
        const num_str = std.fmt.bufPrint(&num_buf, "{d}", .{counts.items[i]}) catch break;
        result.data.appendSlice(gpa, num_str) catch break;
        result.data.append(gpa, '\n') catch break;
    }
    return result;
}

// ─── ContainsAnyOf ───
// Check if string contains any of the characters in the given string

pub fn stz_string_contains_any_of(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (chars == null or chars_len == 0) return 0;
    const char_set: []const u8 = chars[0..chars_len];

    // Parse char_set into codepoints
    var set_cps: std.ArrayList(u21) = .{};
    defer set_cps.deinit(gpa);
    var coff: usize = 0;
    while (coff < char_set.len) {
        const cl = std.unicode.utf8ByteSequenceLength(char_set[coff]) catch break;
        if (coff + cl > char_set.len) break;
        const cv = std.unicode.utf8Decode(char_set[coff..][0..cl]) catch break;
        set_cps.append(gpa, cv) catch break;
        coff += cl;
    }

    // Check if any char in buf matches
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        for (set_cps.items) |set_cp| {
            if (cp_val == set_cp) return 1;
        }
        off += cp_len;
    }
    return 0;
}

// ─── ContainsAllOf ───

pub fn stz_string_contains_all_of(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (chars == null or chars_len == 0) return 1;
    const char_set: []const u8 = chars[0..chars_len];

    // Parse char_set into codepoints
    var set_cps: std.ArrayList(u21) = .{};
    defer set_cps.deinit(gpa);
    var coff: usize = 0;
    while (coff < char_set.len) {
        const cl = std.unicode.utf8ByteSequenceLength(char_set[coff]) catch break;
        if (coff + cl > char_set.len) break;
        const cv = std.unicode.utf8Decode(char_set[coff..][0..cl]) catch break;
        set_cps.append(gpa, cv) catch break;
        coff += cl;
    }

    // For each set char, check it exists in buf
    for (set_cps.items) |set_cp| {
        var found = false;
        var off: usize = 0;
        while (off < buf.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
            if (off + cp_len > buf.len) break;
            const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
            if (cp_val == set_cp) {
                found = true;
                break;
            }
            off += cp_len;
        }
        if (!found) return 0;
    }
    return 1;
}

// ─── Center Pad ───

pub fn stz_string_center_pad(handle: StzStringHandle, width: c_int, pad_char: [*c]const u8, pad_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    const w: usize = if (width > 0) @intCast(width) else return stz_string_from(src.ptr, src.len);

    // Get codepoint count of source
    const cp_count = utf8CodepointCount(src);
    if (cp_count >= w) return stz_string_from(src.ptr, src.len);

    // Get pad codepoint (first codepoint from pad_char)
    if (pad_char == null or pad_len == 0) return stz_string_from(src.ptr, src.len);
    const pad_bytes: []const u8 = pad_char[0..pad_len];

    const total_pad = w - cp_count;
    const left_pad = total_pad / 2;
    const right_pad = total_pad - left_pad;

    const r = stz_string_new() orelse return null;
    r.data.ensureTotalCapacity(gpa, src.len + total_pad * pad_len) catch {};

    // Add left padding
    for (0..left_pad) |_| {
        r.data.appendSlice(gpa, pad_bytes) catch {};
    }
    // Add source
    r.data.appendSlice(gpa, src) catch {};
    // Add right padding
    for (0..right_pad) |_| {
        r.data.appendSlice(gpa, pad_bytes) catch {};
    }

    return r;
}

// ─── Only Letters / Digits ───

pub fn stz_string_only_letters(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    const r = stz_string_new() orelse return null;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;
        if (unicode.stz_unicode_is_letter(cp) != 0) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch {};
        }
        off += cp_len;
    }
    return r;
}

pub fn stz_string_only_digits(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    const r = stz_string_new() orelse return null;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;
        if (unicode.stz_unicode_is_digit(cp) != 0) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch {};
        }
        off += cp_len;
    }
    return r;
}

// ─── Remove Whitespace ───

pub fn stz_string_remove_whitespace(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    const r = stz_string_new() orelse return null;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;
        if (unicode.stz_unicode_is_space(cp) == 0) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch {};
        }
        off += cp_len;
    }
    return r;
}

// (stz_string_is_palindrome already defined above)

// ─── IsAlphanumeric ───

pub fn stz_string_is_alphanumeric(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch return 0;
        if (off + cp_len > src.len) return 0;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch return 0;
        if (unicode.stz_unicode_is_letter(cp) == 0 and unicode.stz_unicode_is_digit(cp) == 0) return 0;
        off += cp_len;
    }
    return 1;
}

// ─── Left/Right Justify (pad to width) ───

pub fn stz_string_ljust(handle: StzStringHandle, width: c_int, pad_char: [*c]const u8, pad_len: usize) callconv(.c) StzStringHandle {
    // Left-justify: content on left, padding on right
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    const w: usize = if (width > 0) @intCast(width) else return stz_string_from(src.ptr, src.len);

    const cp_count = utf8CodepointCount(src);
    if (cp_count >= w) return stz_string_from(src.ptr, src.len);

    if (pad_char == null or pad_len == 0) return stz_string_from(src.ptr, src.len);
    const pad_bytes: []const u8 = pad_char[0..pad_len];

    const r = stz_string_new() orelse return null;
    r.data.appendSlice(gpa, src) catch {};
    const needed = w - cp_count;
    for (0..needed) |_| {
        r.data.appendSlice(gpa, pad_bytes) catch {};
    }
    return r;
}

pub fn stz_string_rjust(handle: StzStringHandle, width: c_int, pad_char: [*c]const u8, pad_len: usize) callconv(.c) StzStringHandle {
    // Right-justify: padding on left, content on right
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    const w: usize = if (width > 0) @intCast(width) else return stz_string_from(src.ptr, src.len);

    const cp_count = utf8CodepointCount(src);
    if (cp_count >= w) return stz_string_from(src.ptr, src.len);

    if (pad_char == null or pad_len == 0) return stz_string_from(src.ptr, src.len);
    const pad_bytes: []const u8 = pad_char[0..pad_len];

    const r = stz_string_new() orelse return null;
    const needed = w - cp_count;
    for (0..needed) |_| {
        r.data.appendSlice(gpa, pad_bytes) catch {};
    }
    r.data.appendSlice(gpa, src) catch {};
    return r;
}

// (stz_string_common_prefix already defined above)

// ─── Count Words ───

pub fn stz_string_count_words(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var count: c_int = 0;
    var in_word = false;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;
        if (unicode.stz_unicode_is_space(cp) != 0) {
            if (in_word) {
                in_word = false;
            }
        } else {
            if (!in_word) {
                in_word = true;
                count += 1;
            }
        }
        off += cp_len;
    }
    return count;
}

// ─── Nth Word ───

pub fn stz_string_nth_word(handle: StzStringHandle, n: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    if (n < 0) return stz_string_new();
    const target: usize = @intCast(n);

    var word_idx: usize = 0;
    var in_word = false;
    var word_start: usize = 0;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;
        const is_ws = unicode.stz_unicode_is_space(cp) != 0;

        if (is_ws) {
            if (in_word) {
                if (word_idx == target) {
                    return stz_string_from(src[word_start..off].ptr, off - word_start);
                }
                word_idx += 1;
                in_word = false;
            }
        } else {
            if (!in_word) {
                word_start = off;
                in_word = true;
            }
        }
        off += cp_len;
    }

    // Handle last word
    if (in_word and word_idx == target) {
        return stz_string_from(src[word_start..off].ptr, off - word_start);
    }

    return stz_string_new();
}

// ─── Chars Between Positions ───

pub fn stz_string_chars_between(handle: StzStringHandle, cp_from: c_int, cp_to: c_int) callconv(.c) StzStringHandle {
    // Extract characters between two 0-based codepoint positions (exclusive on both ends)
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    if (cp_from < 0 or cp_to < 0 or cp_to <= cp_from + 1) return stz_string_new();

    const start_cp = cp_from + 1;
    const count_cp = cp_to - cp_from - 1;
    if (count_cp <= 0) return stz_string_new();

    const byte_start = unicode.stz_unicode_cp_to_byte(src.ptr, src.len, start_cp);
    if (byte_start < 0) return stz_string_new();
    const byte_end = unicode.stz_unicode_cp_to_byte(src.ptr, src.len, start_cp + count_cp);
    const end: usize = if (byte_end < 0) src.len else @intCast(byte_end);
    const start: usize = @intCast(byte_start);
    if (start >= end) return stz_string_new();

    return stz_string_from(src[start..end].ptr, end - start);
}

// ─── Indent / Dedent ───

pub fn stz_string_indent(handle: StzStringHandle, spaces: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    const n: usize = if (spaces > 0) @intCast(spaces) else return stz_string_from(src.ptr, src.len);

    const r = stz_string_new() orelse return null;
    r.data.ensureTotalCapacity(gpa, src.len + src.len / 10 * n) catch {};

    // Add indent before first line
    for (0..n) |_| {
        r.data.append(gpa, ' ') catch {};
    }

    for (src) |byte| {
        r.data.append(gpa, byte) catch {};
        if (byte == '\n') {
            // Add indent after each newline
            for (0..n) |_| {
                r.data.append(gpa, ' ') catch {};
            }
        }
    }
    return r;
}

pub fn stz_string_dedent(handle: StzStringHandle) callconv(.c) StzStringHandle {
    // Remove common leading whitespace from all lines
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    if (src.len == 0) return stz_string_new();

    // Find minimum indentation across non-empty lines
    var min_indent: usize = std.math.maxInt(usize);
    var line_start: usize = 0;
    var i: usize = 0;
    while (i <= src.len) : (i += 1) {
        if (i == src.len or src[i] == '\n') {
            const line = src[line_start..i];
            if (line.len > 0) {
                var indent: usize = 0;
                for (line) |c| {
                    if (c == ' ' or c == '\t') {
                        indent += 1;
                    } else break;
                }
                if (indent < line.len) { // non-whitespace-only line
                    min_indent = @min(min_indent, indent);
                }
            }
            line_start = i + 1;
        }
    }

    if (min_indent == std.math.maxInt(usize) or min_indent == 0) {
        return stz_string_from(src.ptr, src.len);
    }

    // Rebuild with indentation removed
    const r = stz_string_new() orelse return null;
    line_start = 0;
    i = 0;
    while (i <= src.len) : (i += 1) {
        if (i == src.len or src[i] == '\n') {
            const line = src[line_start..i];
            if (line.len > min_indent) {
                r.data.appendSlice(gpa, line[min_indent..]) catch {};
            }
            if (i < src.len) {
                r.data.append(gpa, '\n') catch {};
            }
            line_start = i + 1;
        }
    }
    return r;
}

// ─── CamelCase / SnakeCase / KebabCase ───

pub fn stz_string_to_camel_case(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    if (src.len == 0) return stz_string_new();

    const r = stz_string_new() orelse return null;
    var capitalize_next = false;
    var first = true;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;

        if (cp == ' ' or cp == '_' or cp == '-' or cp == '\t') {
            capitalize_next = true;
        } else {
            if (first) {
                // First char: lowercase
                const lc = unicode.stz_unicode_to_lower(cp);
                var buf: [4]u8 = undefined;
                const enc_len = std.unicode.utf8Encode(@intCast(lc), &buf) catch break;
                r.data.appendSlice(gpa, buf[0..enc_len]) catch {};
                first = false;
            } else if (capitalize_next) {
                const uc = unicode.stz_unicode_to_upper(cp);
                var buf: [4]u8 = undefined;
                const enc_len = std.unicode.utf8Encode(@intCast(uc), &buf) catch break;
                r.data.appendSlice(gpa, buf[0..enc_len]) catch {};
                capitalize_next = false;
            } else {
                r.data.appendSlice(gpa, src[off..][0..cp_len]) catch {};
            }
        }
        off += cp_len;
    }
    return r;
}

pub fn stz_string_to_snake_case(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    if (src.len == 0) return stz_string_new();

    const r = stz_string_new() orelse return null;
    var prev_was_lower = false;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;

        if (cp == ' ' or cp == '-' or cp == '\t') {
            r.data.append(gpa, '_') catch {};
            prev_was_lower = false;
        } else if (unicode.stz_unicode_is_upper(cp) != 0) {
            if (prev_was_lower) {
                r.data.append(gpa, '_') catch {};
            }
            const lc = unicode.stz_unicode_to_lower(cp);
            var buf: [4]u8 = undefined;
            const enc_len = std.unicode.utf8Encode(@intCast(lc), &buf) catch break;
            r.data.appendSlice(gpa, buf[0..enc_len]) catch {};
            prev_was_lower = false;
        } else {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch {};
            prev_was_lower = unicode.stz_unicode_is_lower(cp) != 0;
        }
        off += cp_len;
    }
    return r;
}

pub fn stz_string_to_kebab_case(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    if (src.len == 0) return stz_string_new();

    const r = stz_string_new() orelse return null;
    var prev_was_lower = false;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;

        if (cp == ' ' or cp == '_' or cp == '\t') {
            r.data.append(gpa, '-') catch {};
            prev_was_lower = false;
        } else if (unicode.stz_unicode_is_upper(cp) != 0) {
            if (prev_was_lower) {
                r.data.append(gpa, '-') catch {};
            }
            const lc = unicode.stz_unicode_to_lower(cp);
            var buf: [4]u8 = undefined;
            const enc_len = std.unicode.utf8Encode(@intCast(lc), &buf) catch break;
            r.data.appendSlice(gpa, buf[0..enc_len]) catch {};
            prev_was_lower = false;
        } else {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch {};
            prev_was_lower = unicode.stz_unicode_is_lower(cp) != 0;
        }
        off += cp_len;
    }
    return r;
}

// ─── Partition ───

/// Split string at first occurrence of separator into [before, separator, after].
/// Returns a handle to the "before" part. Caller must also get sep and after via
/// stz_string_partition_sep and stz_string_partition_after.
pub fn stz_string_partition(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    const needle = if (sep_len > 0) sep[0..sep_len] else return stz_string_from(src.ptr, src.len);

    // Find first occurrence
    if (mem.indexOf(u8, src, needle)) |pos| {
        return stz_string_from(src.ptr, pos);
    }
    // Not found: return full string
    return stz_string_from(src.ptr, src.len);
}

/// Get the "after" part of a partition (everything after first occurrence of separator).
/// If separator not found, returns empty string.
pub fn stz_string_partition_after(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    const needle = if (sep_len > 0) sep[0..sep_len] else return stz_string_new();

    if (mem.indexOf(u8, src, needle)) |pos| {
        const after_start = pos + needle.len;
        return stz_string_from(src.ptr + after_start, src.len - after_start);
    }
    return stz_string_new();
}

/// Split string at LAST occurrence of separator.
/// Returns the "before" part. Use rpartition_after for the rest.
pub fn stz_string_rpartition(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    const needle = if (sep_len > 0) sep[0..sep_len] else return stz_string_new();

    // Find last occurrence
    if (mem.lastIndexOf(u8, src, needle)) |pos| {
        return stz_string_from(src.ptr, pos);
    }
    return stz_string_new();
}

/// Get the "after" part of a rpartition (everything after last occurrence of separator).
pub fn stz_string_rpartition_after(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    const needle = if (sep_len > 0) sep[0..sep_len] else return stz_string_from(src.ptr, src.len);

    if (mem.lastIndexOf(u8, src, needle)) |pos| {
        const after_start = pos + needle.len;
        return stz_string_from(src.ptr + after_start, src.len - after_start);
    }
    // Not found: return full string
    return stz_string_from(src.ptr, src.len);
}

// ─── Squeeze (all consecutive duplicates) ───

/// Reduce all runs of consecutive identical codepoints to a single codepoint.
pub fn stz_string_squeeze(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    if (src.len == 0) return stz_string_new();

    const r = stz_string_new() orelse return null;
    var prev_cp: u32 = 0;
    var off: usize = 0;
    var first = true;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;

        if (first or cp != prev_cp) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch {};
            prev_cp = cp;
            first = false;
        }
        off += cp_len;
    }
    return r;
}

// ─── IsDigit (all chars are digits) ───

/// Returns 1 if all codepoints in the string are digits, 0 otherwise.
/// Empty string returns 0.
pub fn stz_string_is_digit(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch return 0;
        if (off + cp_len > src.len) return 0;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch return 0;
        if (unicode.stz_unicode_is_digit(cp) == 0) return 0;
        off += cp_len;
    }
    return 1;
}

// ─── StringMultiply (interleave) ───

/// Interleave: place separator between each codepoint. "abc" with "," => "a,b,c"
pub fn stz_string_interleave(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    if (src.len == 0) return stz_string_new();

    const separator = if (sep_len > 0) sep[0..sep_len] else return stz_string_from(src.ptr, src.len);
    const r = stz_string_new() orelse return null;
    var first = true;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        if (!first) {
            r.data.appendSlice(gpa, separator) catch {};
        }
        r.data.appendSlice(gpa, src[off..][0..cp_len]) catch {};
        first = false;
        off += cp_len;
    }
    return r;
}

// ─── StripChars ───

/// Remove all codepoints that appear in the `chars` set string.
/// E.g., strip_chars("hello world!", "lo") => "he wrd!"
pub fn stz_string_strip_chars(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    if (src.len == 0 or chars_len == 0) return stz_string_from(src.ptr, src.len);

    const charset = if (chars_len > 0) chars[0..chars_len] else return stz_string_from(src.ptr, src.len);

    // Build set of codepoints to strip
    const r = stz_string_new() orelse return null;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        // Check if this char appears in the charset
        var found = false;
        var coff: usize = 0;
        while (coff < charset.len) {
            const c_len = std.unicode.utf8ByteSequenceLength(charset[coff]) catch break;
            if (coff + c_len > charset.len) break;
            if (c_len == cp_len and mem.eql(u8, src[off..][0..cp_len], charset[coff..][0..c_len])) {
                found = true;
                break;
            }
            coff += c_len;
        }

        if (!found) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch {};
        }
        off += cp_len;
    }
    return r;
}

// ─── KeepChars ───

/// Keep only codepoints that appear in the `chars` set string.
/// E.g., keep_chars("hello world!", "lo") => "llool"
pub fn stz_string_keep_chars(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    if (src.len == 0 or chars_len == 0) return stz_string_new();

    const charset = if (chars_len > 0) chars[0..chars_len] else return stz_string_new();

    const r = stz_string_new() orelse return null;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        // Check if this char appears in the charset
        var coff: usize = 0;
        while (coff < charset.len) {
            const c_len = std.unicode.utf8ByteSequenceLength(charset[coff]) catch break;
            if (coff + c_len > charset.len) break;
            if (c_len == cp_len and mem.eql(u8, src[off..][0..cp_len], charset[coff..][0..c_len])) {
                r.data.appendSlice(gpa, src[off..][0..cp_len]) catch {};
                break;
            }
            coff += c_len;
        }
        off += cp_len;
    }
    return r;
}

// ─── ReplaceMultiple ───

/// Replace first occurrence of old1 with new1, old2 with new2, etc.
/// Takes alternating old/new pairs as a single concatenated buffer with lengths.
/// Simpler interface: replace two substrings in one pass.
pub fn stz_string_replace2(handle: StzStringHandle, old1: [*c]const u8, old1_len: usize, new1: [*c]const u8, new1_len: usize, old2: [*c]const u8, old2_len: usize, new2: [*c]const u8, new2_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    if (src.len == 0) return stz_string_new();

    // First replace old1 with new1
    const needle1 = if (old1_len > 0) old1[0..old1_len] else "";
    const repl1 = if (new1_len > 0) new1[0..new1_len] else "";
    const needle2 = if (old2_len > 0) old2[0..old2_len] else "";
    const repl2 = if (new2_len > 0) new2[0..new2_len] else "";

    const r = stz_string_new() orelse return null;
    var off: usize = 0;

    while (off < src.len) {
        // Try needle1
        if (needle1.len > 0 and off + needle1.len <= src.len and mem.eql(u8, src[off..][0..needle1.len], needle1)) {
            r.data.appendSlice(gpa, repl1) catch {};
            off += needle1.len;
            continue;
        }
        // Try needle2
        if (needle2.len > 0 and off + needle2.len <= src.len and mem.eql(u8, src[off..][0..needle2.len], needle2)) {
            r.data.appendSlice(gpa, repl2) catch {};
            off += needle2.len;
            continue;
        }
        r.data.append(gpa, src[off]) catch {};
        off += 1;
    }
    return r;
}

// ─── Surround ───

/// Wrap string with prefix and suffix: surround("hello", "[", "]") => "[hello]"
pub fn stz_string_surround(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize, suffix: [*c]const u8, suffix_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();

    const r = stz_string_new() orelse return null;
    if (prefix_len > 0) r.data.appendSlice(gpa, prefix[0..prefix_len]) catch {};
    r.data.appendSlice(gpa, src) catch {};
    if (suffix_len > 0) r.data.appendSlice(gpa, suffix[0..suffix_len]) catch {};
    return r;
}

// ─── ReplaceAnyChar ───

/// Replace any codepoint found in `chars` set with `replacement`.
/// E.g., replace_any_char("hello", "lo", "*") => "he***"
pub fn stz_string_replace_any_char(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize, repl: [*c]const u8, repl_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return stz_string_new();
    const src = s.slice();
    if (src.len == 0) return stz_string_new();

    const charset = if (chars_len > 0) chars[0..chars_len] else return stz_string_from(src.ptr, src.len);
    const replacement = if (repl_len > 0) repl[0..repl_len] else "";

    const r = stz_string_new() orelse return null;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        var found = false;
        var coff: usize = 0;
        while (coff < charset.len) {
            const c_len = std.unicode.utf8ByteSequenceLength(charset[coff]) catch break;
            if (coff + c_len > charset.len) break;
            if (c_len == cp_len and mem.eql(u8, src[off..][0..cp_len], charset[coff..][0..c_len])) {
                found = true;
                break;
            }
            coff += c_len;
        }

        if (found) {
            r.data.appendSlice(gpa, replacement) catch {};
        } else {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch {};
        }
        off += cp_len;
    }
    return r;
}

// ─── CountMatches ───

/// Count how many codepoints in the string match any char in the `chars` set.
pub fn stz_string_count_any_char(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0 or chars_len == 0) return 0;

    const charset = chars[0..chars_len];
    var count: c_int = 0;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        var coff: usize = 0;
        while (coff < charset.len) {
            const c_len = std.unicode.utf8ByteSequenceLength(charset[coff]) catch break;
            if (coff + c_len > charset.len) break;
            if (c_len == cp_len and mem.eql(u8, src[off..][0..cp_len], charset[coff..][0..c_len])) {
                count += 1;
                break;
            }
            coff += c_len;
        }
        off += cp_len;
    }
    return count;
}

/// Rotate codepoints left by `n` positions. Negative n rotates right.
/// Returns new handle with rotated string.
pub fn stz_string_rotate(handle: StzStringHandle, n: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, src.len);

    // Count codepoints
    var cp_count: usize = 0;
    var i: usize = 0;
    while (i < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[i]) catch break;
        if (i + cp_len > src.len) break;
        cp_count += 1;
        i += cp_len;
    }
    if (cp_count == 0) return stz_string_from(src.ptr, src.len);

    // Normalize rotation amount
    const cpi: i64 = @intCast(cp_count);
    var rot: i64 = @rem(@as(i64, n), cpi);
    if (rot < 0) rot += cpi;
    if (rot == 0) return stz_string_from(src.ptr, src.len);

    // Find byte offset of rotation point
    var off: usize = 0;
    var cp_idx: usize = 0;
    while (cp_idx < @as(usize, @intCast(rot)) and off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        off += cp_len;
        cp_idx += 1;
    }

    const result = stz_string_new() orelse return null;
    result.data.appendSlice(gpa, src[off..]) catch {
        stz_string_free(result);
        return null;
    };
    result.data.appendSlice(gpa, src[0..off]) catch {
        stz_string_free(result);
        return null;
    };
    return result;
}

/// Repeat string to fill exactly `target_len` codepoints.
/// Returns new handle.
pub fn stz_string_repeat_to_length(handle: StzStringHandle, target_len: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or target_len <= 0) return stz_string_new();

    const target: usize = @intCast(target_len);

    // Count codepoints in source
    var cp_count: usize = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        cp_count += 1;
        off += cp_len;
    }
    if (cp_count == 0) return stz_string_new();

    const result = stz_string_new() orelse return null;
    var written: usize = 0;
    while (written < target) {
        const remaining = target - written;
        if (remaining >= cp_count) {
            // Append full copy
            result.data.appendSlice(gpa, src) catch break;
            written += cp_count;
        } else {
            // Append partial: walk `remaining` codepoints
            var poff: usize = 0;
            var pidx: usize = 0;
            while (pidx < remaining and poff < src.len) {
                const plen = std.unicode.utf8ByteSequenceLength(src[poff]) catch break;
                if (poff + plen > src.len) break;
                poff += plen;
                pidx += 1;
            }
            result.data.appendSlice(gpa, src[0..poff]) catch break;
            written += remaining;
        }
    }
    return result;
}

/// Remove text between first occurrence of `open` and matching `close` (inclusive of delimiters).
/// Returns new handle.
pub fn stz_string_remove_between(handle: StzStringHandle, open: [*c]const u8, open_len: usize, close: [*c]const u8, close_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or open_len == 0 or close_len == 0) return stz_string_from(src.ptr, src.len);

    const open_s = open[0..open_len];
    const close_s = close[0..close_len];

    // Find first open
    const open_pos = mem.indexOf(u8, src, open_s) orelse return stz_string_from(src.ptr, src.len);
    // Find first close after open
    const search_start = open_pos + open_len;
    if (search_start > src.len) return stz_string_from(src.ptr, src.len);
    const close_rel = mem.indexOf(u8, src[search_start..], close_s) orelse return stz_string_from(src.ptr, src.len);
    const close_end = search_start + close_rel + close_len;

    const result = stz_string_new() orelse return null;
    result.data.appendSlice(gpa, src[0..open_pos]) catch {
        stz_string_free(result);
        return null;
    };
    if (close_end < src.len) {
        result.data.appendSlice(gpa, src[close_end..]) catch {
            stz_string_free(result);
            return null;
        };
    }
    return result;
}

/// Check if string is blank (empty or contains only whitespace).
/// Returns 1 if blank, 0 otherwise.
pub fn stz_string_is_blank(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 1; // null = blank
    const src = s.slice();
    if (src.len == 0) return 1;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp_val: i32 = decodeCodepoint(src, off, cp_len);
        if (unicode.stz_unicode_is_space(cp_val) == 0) return 0;
        off += cp_len;
    }
    return 1;
}

/// Convert to PascalCase: first letter of each word uppercase, rest lowercase.
/// Word boundaries: spaces, underscores, hyphens, camelCase transitions.
/// Returns new handle.
pub fn stz_string_to_pascal_case(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);

    const result = stz_string_new() orelse return null;
    var capitalize_next = true;
    var prev_was_lower = false;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp_val: i32 = decodeCodepoint(src, off, cp_len);

        // Check if this is a word separator
        if (unicode.stz_unicode_is_space(cp_val) != 0 or cp_val == '_' or cp_val == '-') {
            capitalize_next = true;
            prev_was_lower = false;
            off += cp_len;
            continue;
        }

        // camelCase boundary: lowercase followed by uppercase
        const is_upper = unicode.stz_unicode_is_upper(cp_val) != 0;
        if (prev_was_lower and is_upper) {
            capitalize_next = true;
        }

        if (capitalize_next) {
            // Uppercase this char
            var upper_buf: [4]u8 = undefined;
            const upper_cp = unicode.stz_unicode_to_upper(cp_val);
            const upper_u21: u21 = if (upper_cp >= 0) @intCast(@as(u32, @intCast(upper_cp))) else @intCast(@as(u32, @intCast(cp_val)));
            const enc_len = std.unicode.utf8Encode(upper_u21, &upper_buf) catch {
                off += cp_len;
                continue;
            };
            result.data.appendSlice(gpa, upper_buf[0..enc_len]) catch break;
            capitalize_next = false;
            prev_was_lower = !is_upper;
        } else {
            // Lowercase this char
            var lower_buf: [4]u8 = undefined;
            const lower_cp = unicode.stz_unicode_to_lower(cp_val);
            const lower_u21: u21 = if (lower_cp >= 0) @intCast(@as(u32, @intCast(lower_cp))) else @intCast(@as(u32, @intCast(cp_val)));
            const enc_len = std.unicode.utf8Encode(lower_u21, &lower_buf) catch {
                off += cp_len;
                continue;
            };
            result.data.appendSlice(gpa, lower_buf[0..enc_len]) catch break;
            prev_was_lower = !is_upper;
        }
        off += cp_len;
    }
    return result;
}

/// Check if string is a valid programming identifier (starts with letter/underscore,
/// rest are letters/digits/underscores). Returns 1 if valid, 0 otherwise.
pub fn stz_string_is_identifier(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var off: usize = 0;
    var first = true;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp_val: i32 = decodeCodepoint(src, off, cp_len);

        if (first) {
            // First char must be letter or underscore
            if (cp_val != '_' and unicode.stz_unicode_is_letter(cp_val) == 0) return 0;
            first = false;
        } else {
            // Rest must be letter, digit, or underscore
            if (cp_val != '_' and unicode.stz_unicode_is_letter(cp_val) == 0 and unicode.stz_unicode_is_digit(cp_val) == 0) return 0;
        }
        off += cp_len;
    }
    return 1;
}

/// Replace content between first `open` and matching `close` (inclusive of delimiters)
/// with `replacement`. Returns new handle.
pub fn stz_string_replace_between(handle: StzStringHandle, open: [*c]const u8, open_len: usize, close: [*c]const u8, close_len: usize, rep: [*c]const u8, rep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or open_len == 0 or close_len == 0) return stz_string_from(src.ptr, src.len);

    const open_s = open[0..open_len];
    const close_s = close[0..close_len];

    // Find first open
    const open_pos = mem.indexOf(u8, src, open_s) orelse return stz_string_from(src.ptr, src.len);
    const search_start = open_pos + open_len;
    if (search_start > src.len) return stz_string_from(src.ptr, src.len);
    const close_rel = mem.indexOf(u8, src[search_start..], close_s) orelse return stz_string_from(src.ptr, src.len);
    const close_end = search_start + close_rel + close_len;

    const result = stz_string_new() orelse return null;
    result.data.appendSlice(gpa, src[0..open_pos]) catch {
        stz_string_free(result);
        return null;
    };
    if (rep_len > 0) {
        result.data.appendSlice(gpa, rep[0..rep_len]) catch {
            stz_string_free(result);
            return null;
        };
    }
    if (close_end < src.len) {
        result.data.appendSlice(gpa, src[close_end..]) catch {
            stz_string_free(result);
            return null;
        };
    }
    return result;
}

/// Check if string contains only characters from the given set.
/// Returns 1 if all chars are in set, 0 otherwise. Empty string returns 1.
pub fn stz_string_contains_only(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) c_int {
    const s = handle orelse return 1;
    const src = s.slice();
    if (src.len == 0) return 1;
    if (chars_len == 0) return 0;

    const charset = chars[0..chars_len];
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        var found = false;
        var coff: usize = 0;
        while (coff < charset.len) {
            const c_len = std.unicode.utf8ByteSequenceLength(charset[coff]) catch break;
            if (coff + c_len > charset.len) break;
            if (c_len == cp_len and mem.eql(u8, src[off..][0..cp_len], charset[coff..][0..c_len])) {
                found = true;
                break;
            }
            coff += c_len;
        }
        if (!found) return 0;
        off += cp_len;
    }
    return 1;
}

/// Capitalize first letter of each whitespace-delimited word.
/// Unlike to_title (Unicode titlecase), this simply uppercases the first char of each word.
/// Returns new handle.
pub fn stz_string_capitalize_words(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);

    const result = stz_string_new() orelse return null;
    var capitalize_next = true;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp_val: i32 = decodeCodepoint(src, off, cp_len);

        if (unicode.stz_unicode_is_space(cp_val) != 0) {
            // Copy space as-is
            result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
            capitalize_next = true;
        } else if (capitalize_next) {
            // Uppercase this char
            var upper_buf: [4]u8 = undefined;
            const upper_cp = unicode.stz_unicode_to_upper(cp_val);
            const upper_u21: u21 = if (upper_cp >= 0) @intCast(@as(u32, @intCast(upper_cp))) else @intCast(@as(u32, @intCast(cp_val)));
            const enc_len = std.unicode.utf8Encode(upper_u21, &upper_buf) catch {
                off += cp_len;
                continue;
            };
            result.data.appendSlice(gpa, upper_buf[0..enc_len]) catch break;
            capitalize_next = false;
        } else {
            // Copy as-is (don't lowercase)
            result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
        }
        off += cp_len;
    }
    return result;
}

/// Swap characters at two codepoint positions (0-based). Returns new handle.
pub fn stz_string_swap_chars(handle: StzStringHandle, pos1: c_int, pos2: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or pos1 < 0 or pos2 < 0 or pos1 == pos2) return stz_string_from(src.ptr, src.len);

    const p1: usize = @intCast(pos1);
    const p2: usize = @intCast(pos2);

    // Build array of byte-offset ranges for each codepoint
    var offsets: [32768]struct { start: usize, len: usize } = undefined;
    var cp_count: usize = 0;
    var off: usize = 0;
    while (off < src.len and cp_count < 32768) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        offsets[cp_count] = .{ .start = off, .len = cp_len };
        cp_count += 1;
        off += cp_len;
    }

    if (p1 >= cp_count or p2 >= cp_count) return stz_string_from(src.ptr, src.len);

    const result = stz_string_new() orelse return null;
    var idx: usize = 0;
    while (idx < cp_count) {
        const actual = if (idx == p1) p2 else if (idx == p2) p1 else idx;
        const o = offsets[actual];
        result.data.appendSlice(gpa, src[o.start..][0..o.len]) catch break;
        idx += 1;
    }
    return result;
}

/// Encode each byte of the string as two hex characters (lowercase). Returns new handle.
pub fn stz_string_encode_hex(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    const hex_chars = "0123456789abcdef";

    for (src) |byte| {
        const hi: u8 = hex_chars[byte >> 4];
        const lo: u8 = hex_chars[byte & 0x0F];
        result.data.appendSlice(gpa, &[_]u8{ hi, lo }) catch break;
    }
    return result;
}

/// Decode a hex string (pairs of hex digits) back to bytes. Returns new handle.
/// Invalid hex chars are skipped.
pub fn stz_string_decode_hex(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;

    var i: usize = 0;
    while (i + 1 < src.len) {
        const hi = hexDigitValue(src[i]);
        const lo = hexDigitValue(src[i + 1]);
        if (hi != null and lo != null) {
            const byte: u8 = (@as(u8, hi.?) << 4) | @as(u8, lo.?);
            result.data.appendSlice(gpa, &[_]u8{byte}) catch break;
        }
        i += 2;
    }
    return result;
}

fn hexDigitValue(c: u8) ?u4 {
    if (c >= '0' and c <= '9') return @intCast(c - '0');
    if (c >= 'a' and c <= 'f') return @intCast(c - 'a' + 10);
    if (c >= 'A' and c <= 'F') return @intCast(c - 'A' + 10);
    return null;
}

/// Reverse the order of words in the string. Words are whitespace-delimited.
/// Returns new handle.
pub fn stz_string_reverse_words(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);

    // Collect word boundaries (start, end byte offsets)
    var words: [8192]struct { start: usize, end: usize } = undefined;
    var word_count: usize = 0;
    var off: usize = 0;
    var in_word = false;
    var word_start: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp_val: i32 = decodeCodepoint(src, off, cp_len);
        const is_space = unicode.stz_unicode_is_space(cp_val) != 0;

        if (!is_space and !in_word) {
            word_start = off;
            in_word = true;
        } else if (is_space and in_word) {
            if (word_count < 8192) {
                words[word_count] = .{ .start = word_start, .end = off };
                word_count += 1;
            }
            in_word = false;
        }
        off += cp_len;
    }
    if (in_word and word_count < 8192) {
        words[word_count] = .{ .start = word_start, .end = off };
        word_count += 1;
    }

    if (word_count == 0) return stz_string_from(src.ptr, src.len);

    const result = stz_string_new() orelse return null;
    var i: usize = word_count;
    while (i > 0) {
        i -= 1;
        if (i < word_count - 1) {
            result.data.appendSlice(gpa, " ") catch break;
        }
        const w = words[i];
        result.data.appendSlice(gpa, src[w.start..w.end]) catch break;
    }
    return result;
}

/// Collapse multiple consecutive spaces/whitespace to a single space.
/// Also trims leading/trailing whitespace. Returns new handle.
pub fn stz_string_collapse_spaces(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);

    const result = stz_string_new() orelse return null;
    var off: usize = 0;
    var prev_was_space = true; // treat start as space to trim leading

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp_val: i32 = decodeCodepoint(src, off, cp_len);
        const is_space = unicode.stz_unicode_is_space(cp_val) != 0;

        if (is_space) {
            if (!prev_was_space) {
                result.data.appendSlice(gpa, " ") catch break;
            }
            prev_was_space = true;
        } else {
            result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
            prev_was_space = false;
        }
        off += cp_len;
    }

    // Trim trailing space
    const rslice = result.slice();
    if (rslice.len > 0 and rslice[rslice.len - 1] == ' ') {
        _ = result.data.pop();
    }
    return result;
}

/// Check if two strings are anagrams (same chars, different order).
/// Case-sensitive. Returns 1 if anagram, 0 otherwise.
pub fn stz_string_is_anagram(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    const s1 = h1 orelse return 0;
    const s2 = h2 orelse return 0;
    const src1 = s1.slice();
    const src2 = s2.slice();
    if (src1.len != src2.len) return 0;
    if (src1.len == 0) return 1;

    // Count codepoints in both and compare sorted
    var counts = std.AutoHashMap(i32, i32).init(gpa);
    defer counts.deinit();

    var off: usize = 0;
    while (off < src1.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src1[off]) catch break;
        if (off + cp_len > src1.len) break;
        const cp: i32 = decodeCodepoint(src1, off, cp_len);
        const entry = counts.getOrPut(cp) catch break;
        if (!entry.found_existing) entry.value_ptr.* = 0;
        entry.value_ptr.* += 1;
        off += cp_len;
    }

    off = 0;
    while (off < src2.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src2[off]) catch break;
        if (off + cp_len > src2.len) break;
        const cp: i32 = decodeCodepoint(src2, off, cp_len);
        const entry = counts.getOrPut(cp) catch break;
        if (!entry.found_existing) entry.value_ptr.* = 0;
        entry.value_ptr.* -= 1;
        off += cp_len;
    }

    var iter = counts.iterator();
    while (iter.next()) |entry| {
        if (entry.value_ptr.* != 0) return 0;
    }
    return 1;
}

/// Mask the string: replace middle characters with mask_char, keeping `keep` chars visible
/// at start and end. E.g. mask("hello@mail.com", '*', 2) -> "he*********om"
/// Returns new handle.
pub fn stz_string_mask(handle: StzStringHandle, mask_char: [*c]const u8, mask_len: usize, keep: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or mask_len == 0) return stz_string_from(src.ptr, src.len);

    const keep_n: usize = if (keep >= 0) @intCast(keep) else 0;
    const mask_s = mask_char[0..mask_len];

    // Count codepoints
    var cp_count: usize = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        cp_count += 1;
        off += cp_len;
    }

    if (cp_count <= keep_n * 2) return stz_string_from(src.ptr, src.len);

    const result = stz_string_new() orelse return null;
    off = 0;
    var idx: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        if (idx < keep_n or idx >= cp_count - keep_n) {
            result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
        } else {
            result.data.appendSlice(gpa, mask_s) catch break;
        }
        idx += 1;
        off += cp_len;
    }
    return result;
}

/// Count consecutive character runs (groups of identical adjacent chars).
/// E.g. "aabbbcc" has 3 runs: "aa", "bbb", "cc".
pub fn stz_string_count_runs(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var runs: c_int = 1;
    var off: usize = 0;
    var prev_cp: i32 = -1;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp: i32 = decodeCodepoint(src, off, cp_len);
        if (prev_cp >= 0 and cp != prev_cp) {
            runs += 1;
        }
        prev_cp = cp;
        off += cp_len;
    }
    return runs;
}

/// Hamming distance: count positions where corresponding codepoints differ.
/// Strings must be same codepoint length; returns -1 if different lengths.
pub fn stz_string_hamming_distance(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    const s1 = h1 orelse return -1;
    const s2 = h2 orelse return -1;
    const src1 = s1.slice();
    const src2 = s2.slice();

    var off1: usize = 0;
    var off2: usize = 0;
    var dist: c_int = 0;

    while (off1 < src1.len and off2 < src2.len) {
        const len1 = std.unicode.utf8ByteSequenceLength(src1[off1]) catch break;
        const len2 = std.unicode.utf8ByteSequenceLength(src2[off2]) catch break;
        if (off1 + len1 > src1.len or off2 + len2 > src2.len) break;

        if (len1 != len2 or !mem.eql(u8, src1[off1..][0..len1], src2[off2..][0..len2])) {
            dist += 1;
        }
        off1 += len1;
        off2 += len2;
    }

    // If one string has remaining chars, lengths differ
    if (off1 < src1.len or off2 < src2.len) return -1;
    return dist;
}

/// Remove ASCII vowels (a,e,i,o,u both cases) from the string. Returns new handle.
pub fn stz_string_remove_vowels(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);

    const result = stz_string_new() orelse return null;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c == 'a' or c == 'e' or c == 'i' or c == 'o' or c == 'u' or
                c == 'A' or c == 'E' or c == 'I' or c == 'O' or c == 'U')
            {
                off += 1;
                continue;
            }
        }
        result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
        off += cp_len;
    }
    return result;
}

/// Keep only ASCII vowels (a,e,i,o,u both cases). Returns new handle.
pub fn stz_string_only_vowels(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);

    const result = stz_string_new() orelse return null;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c == 'a' or c == 'e' or c == 'i' or c == 'o' or c == 'u' or
                c == 'A' or c == 'E' or c == 'I' or c == 'O' or c == 'U')
            {
                result.data.appendSlice(gpa, src[off..][0..1]) catch break;
            }
        }
        off += cp_len;
    }
    return result;
}

/// Check if string is a pangram (contains every letter a-z at least once, case-insensitive).
/// Returns 1 if pangram, 0 otherwise.
pub fn stz_string_is_pangram(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len < 26) return 0;

    var seen: [26]bool = [_]bool{false} ** 26;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c >= 'a' and c <= 'z') seen[c - 'a'] = true
            else if (c >= 'A' and c <= 'Z') seen[c - 'A'] = true;
        }
        off += cp_len;
    }

    for (seen) |s2| {
        if (!s2) return 0;
    }
    return 1;
}

/// Return the nth n-gram (0-based) of `size` codepoints from the string.
/// E.g. ngram("hello", 2, 0) = "he", ngram("hello", 2, 1) = "el", etc.
/// Returns new handle, or null if out of range.
pub fn stz_string_ngram(handle: StzStringHandle, size: c_int, n: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or size <= 0 or n < 0) return null;

    const sz: usize = @intCast(size);
    const idx: usize = @intCast(n);

    // Walk to start position (codepoint idx)
    var off: usize = 0;
    var cp_idx: usize = 0;
    while (cp_idx < idx and off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        off += cp_len;
        cp_idx += 1;
    }
    if (cp_idx != idx) return null;

    const start = off;
    // Walk `size` codepoints
    var count: usize = 0;
    while (count < sz and off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        off += cp_len;
        count += 1;
    }
    if (count != sz) return null;

    return stz_string_from(src[start..].ptr, off - start);
}

/// Count the number of n-grams of given size in the string.
/// E.g. ngram_count("hello", 2) = 4 (he, el, ll, lo).
pub fn stz_string_ngram_count(handle: StzStringHandle, size: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0 or size <= 0) return 0;

    const sz: usize = @intCast(size);

    // Count codepoints
    var cp_count: usize = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        cp_count += 1;
        off += cp_len;
    }

    if (cp_count < sz) return 0;
    return @intCast(cp_count - sz + 1);
}

/// Count ASCII consonants (letters that are not vowels). Case-insensitive.
pub fn stz_string_count_consonants(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            const lower = if (c >= 'A' and c <= 'Z') c + 32 else c;
            if (lower >= 'a' and lower <= 'z') {
                if (lower != 'a' and lower != 'e' and lower != 'i' and lower != 'o' and lower != 'u') {
                    count += 1;
                }
            }
        }
        off += cp_len;
    }
    return count;
}

/// Convert to sentence case: first character uppercase, rest lowercase.
/// Returns new handle.
pub fn stz_string_to_sentence_case(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);

    const result = stz_string_new() orelse return null;
    var off: usize = 0;
    var first_letter_done = false;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        if (cp_len == 1 and !first_letter_done) {
            const c = src[off];
            if ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z')) {
                const upper = if (c >= 'a' and c <= 'z') c - 32 else c;
                result.data.appendSlice(gpa, &[_]u8{upper}) catch break;
                first_letter_done = true;
                off += 1;
                continue;
            }
        } else if (cp_len == 1 and first_letter_done) {
            const c = src[off];
            if (c >= 'A' and c <= 'Z') {
                result.data.appendSlice(gpa, &[_]u8{c + 32}) catch break;
                off += 1;
                continue;
            }
        }
        result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
        if (!first_letter_done and cp_len == 1) {
            // non-letter single byte, keep going
        } else if (!first_letter_done and cp_len > 1) {
            first_letter_done = true;
        }
        off += cp_len;
    }
    return result;
}

/// Check if brackets/parentheses/braces are balanced.
/// Returns 1 if balanced, 0 otherwise.
pub fn stz_string_is_balanced(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 1;
    const src = s.slice();
    var stack: [1024]u8 = undefined;
    var depth: usize = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c == '(' or c == '[' or c == '{') {
                if (depth >= 1024) return 0;
                stack[depth] = c;
                depth += 1;
            } else if (c == ')' or c == ']' or c == '}') {
                if (depth == 0) return 0;
                depth -= 1;
                const expected: u8 = switch (c) {
                    ')' => '(',
                    ']' => '[',
                    '}' => '{',
                    else => 0,
                };
                if (stack[depth] != expected) return 0;
            }
        }
        off += cp_len;
    }
    return if (depth == 0) @as(c_int, 1) else @as(c_int, 0);
}

/// Convert to URL-friendly slug: lowercase, spaces/underscores to hyphens,
/// remove non-alphanumeric (except hyphens), collapse consecutive hyphens.
/// Returns new handle.
pub fn stz_string_slug(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);

    const result = stz_string_new() orelse return null;
    var prev_hyphen = true; // suppress leading hyphen
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c >= 'A' and c <= 'Z') {
                result.data.appendSlice(gpa, &[_]u8{c + 32}) catch break;
                prev_hyphen = false;
            } else if ((c >= 'a' and c <= 'z') or (c >= '0' and c <= '9')) {
                result.data.appendSlice(gpa, &[_]u8{c}) catch break;
                prev_hyphen = false;
            } else if (c == ' ' or c == '_' or c == '-' or c == '\t') {
                if (!prev_hyphen) {
                    result.data.appendSlice(gpa, "-") catch break;
                    prev_hyphen = true;
                }
            }
            // else: skip non-alnum
        }
        // skip multi-byte codepoints for slug
        off += cp_len;
    }
    // Remove trailing hyphen
    const rsl = result.slice();
    if (rsl.len > 0 and rsl[rsl.len - 1] == '-') {
        _ = result.data.pop();
    }
    return result;
}

/// Return the nth chunk (0-based) when string is split into chunks of `size` codepoints.
/// Last chunk may be shorter. Returns null if out of range.
pub fn stz_string_chunk(handle: StzStringHandle, size: c_int, n: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or size <= 0 or n < 0) return null;

    const sz: usize = @intCast(size);
    const idx: usize = @intCast(n);
    const skip_cps = idx * sz;

    // Walk to start
    var off: usize = 0;
    var cp_idx: usize = 0;
    while (cp_idx < skip_cps and off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        off += cp_len;
        cp_idx += 1;
    }
    if (cp_idx != skip_cps) return null;
    if (off >= src.len) return null;

    const start = off;
    var count: usize = 0;
    while (count < sz and off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        off += cp_len;
        count += 1;
    }
    if (count == 0) return null;
    return stz_string_from(src[start..].ptr, off - start);
}

/// Count ASCII vowels (a,e,i,o,u both cases).
pub fn stz_string_count_vowels(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c == 'a' or c == 'e' or c == 'i' or c == 'o' or c == 'u' or
                c == 'A' or c == 'E' or c == 'I' or c == 'O' or c == 'U')
            {
                count += 1;
            }
        }
        off += cp_len;
    }
    return count;
}

/// Return the length of the longest run of consecutive identical codepoints.
pub fn stz_string_longest_run(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var max_run: c_int = 1;
    var cur_run: c_int = 1;
    var prev_start: usize = 0;
    var prev_len: usize = 0;
    var off: usize = 0;
    var first = true;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (first) {
            first = false;
        } else {
            if (cp_len == prev_len and mem.eql(u8, src[off..][0..cp_len], src[prev_start..][0..prev_len])) {
                cur_run += 1;
                if (cur_run > max_run) max_run = cur_run;
            } else {
                cur_run = 1;
            }
        }
        prev_start = off;
        prev_len = cp_len;
        off += cp_len;
    }
    return max_run;
}

/// Trim specific characters from both ends of the string.
/// `chars` is a UTF-8 string of characters to trim.
/// Returns new handle.
pub fn stz_string_trim_chars(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);
    if (chars_len == 0) return stz_string_from(src.ptr, @intCast(src.len));

    const trim_set = chars[0..chars_len];

    // Find start (skip leading chars in set)
    var start: usize = 0;
    while (start < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[start]) catch break;
        if (start + cp_len > src.len) break;
        const cp_slice = src[start..][0..cp_len];
        if (!isInCharSet(cp_slice, trim_set)) break;
        start += cp_len;
    }

    // Find end (skip trailing chars in set)
    var end: usize = src.len;
    while (end > start) {
        // Walk backwards to find start of last codepoint
        var back: usize = end - 1;
        while (back > start and (src[back] & 0xC0) == 0x80) back -= 1;
        const cp_len = std.unicode.utf8ByteSequenceLength(src[back]) catch break;
        if (back + cp_len != end) break;
        const cp_slice = src[back..][0..cp_len];
        if (!isInCharSet(cp_slice, trim_set)) break;
        end = back;
    }

    return stz_string_from(src[start..].ptr, end - start);
}

fn isInCharSet(cp_slice: []const u8, char_set: []const u8) bool {
    var off: usize = 0;
    while (off < char_set.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(char_set[off]) catch return false;
        if (off + cp_len > char_set.len) return false;
        if (cp_len == cp_slice.len and mem.eql(u8, char_set[off..][0..cp_len], cp_slice)) return true;
        off += cp_len;
    }
    return false;
}

/// Basic email format check: contains exactly one @, has text before and after @,
/// has at least one dot after @. Returns 1 if email-like, 0 otherwise.
pub fn stz_string_is_email_like(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len < 5) return 0; // minimum: a@b.c

    var at_pos: ?usize = null;
    var at_count: usize = 0;
    for (src, 0..) |c, i| {
        if (c == '@') {
            at_count += 1;
            at_pos = i;
        }
    }
    if (at_count != 1) return 0;
    const atp = at_pos.?;
    if (atp == 0) return 0; // nothing before @
    if (atp >= src.len - 1) return 0; // nothing after @

    // Check for dot after @
    const domain = src[atp + 1 ..];
    var has_dot = false;
    for (domain) |c| {
        if (c == '.') { has_dot = true; break; }
    }
    if (!has_dot) return 0;

    // Dot shouldn't be first or last in domain
    if (domain[0] == '.' or domain[domain.len - 1] == '.') return 0;

    return 1;
}

/// Split camelCase/PascalCase into space-separated words.
/// E.g. "camelCaseString" -> "camel Case String"
/// Returns new handle.
pub fn stz_string_camel_to_words(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);

    const result = stz_string_new() orelse return null;
    var i: usize = 0;
    while (i < src.len) {
        const c = src[i];
        // Insert space before uppercase that follows lowercase
        if (i > 0 and c >= 'A' and c <= 'Z') {
            const prev = src[i - 1];
            if (prev >= 'a' and prev <= 'z') {
                result.data.appendSlice(gpa, " ") catch break;
            } else if (prev >= 'A' and prev <= 'Z' and i + 1 < src.len and src[i + 1] >= 'a' and src[i + 1] <= 'z') {
                // ABCdef -> AB Cdef
                result.data.appendSlice(gpa, " ") catch break;
            }
        }
        result.data.appendSlice(gpa, src[i..][0..1]) catch break;
        i += 1;
    }
    return result;
}

/// Extract initials (first letter of each word). Words separated by spaces.
/// E.g. "Hello World" -> "HW", "united states of america" -> "usoa"
/// Returns new handle.
pub fn stz_string_initials(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);

    const result = stz_string_new() orelse return null;
    var in_word = false;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1 and (src[off] == ' ' or src[off] == '\t' or src[off] == '\n' or src[off] == '\r')) {
            in_word = false;
        } else {
            if (!in_word) {
                result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
                in_word = true;
            }
        }
        off += cp_len;
    }
    return result;
}

/// Remove duplicate words (keeping first occurrence). Words separated by spaces.
/// E.g. "the the cat sat on the mat" -> "the cat sat on mat"
/// Returns new handle.
pub fn stz_string_remove_duplicate_words(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);

    const result = stz_string_new() orelse return null;

    // Simple approach: split by spaces, track seen words
    var seen_words: [256]struct { start: usize, len: usize } = undefined;
    var seen_count: usize = 0;
    var off: usize = 0;
    var first_word = true;

    while (off < src.len) {
        // Skip spaces
        while (off < src.len and (src[off] == ' ' or src[off] == '\t')) off += 1;
        if (off >= src.len) break;

        // Find word end
        const word_start = off;
        while (off < src.len and src[off] != ' ' and src[off] != '\t') off += 1;
        const word_len = off - word_start;
        if (word_len == 0) continue;

        const word = src[word_start..][0..word_len];

        // Check if already seen
        var is_dup = false;
        var i: usize = 0;
        while (i < seen_count) : (i += 1) {
            if (seen_words[i].len == word_len and
                mem.eql(u8, src[seen_words[i].start..][0..seen_words[i].len], word))
            {
                is_dup = true;
                break;
            }
        }

        if (!is_dup) {
            if (!first_word) {
                result.data.appendSlice(gpa, " ") catch break;
            }
            result.data.appendSlice(gpa, word) catch break;
            first_word = false;
            if (seen_count < 256) {
                seen_words[seen_count] = .{ .start = word_start, .len = word_len };
                seen_count += 1;
            }
        }
    }
    return result;
}

/// Basic URL format check: starts with "http://" or "https://".
/// Returns 1 if URL-like, 0 otherwise.
pub fn stz_string_is_url_like(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len >= 8 and mem.eql(u8, src[0..8], "https://")) return 1;
    if (src.len >= 7 and mem.eql(u8, src[0..7], "http://")) return 1;
    return 0;
}

/// Escape HTML special characters: & -> &amp; < -> &lt; > -> &gt; " -> &quot; ' -> &#39;
/// Returns new handle.
pub fn stz_string_escape_html(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);

    const result = stz_string_new() orelse return null;
    for (src) |c| {
        switch (c) {
            '&' => result.data.appendSlice(gpa, "&amp;") catch break,
            '<' => result.data.appendSlice(gpa, "&lt;") catch break,
            '>' => result.data.appendSlice(gpa, "&gt;") catch break,
            '"' => result.data.appendSlice(gpa, "&quot;") catch break,
            '\'' => result.data.appendSlice(gpa, "&#39;") catch break,
            else => result.data.appendSlice(gpa, &[_]u8{c}) catch break,
        }
    }
    return result;
}

/// Unescape HTML entities: &amp; &lt; &gt; &quot; &#39; back to their characters.
/// Returns new handle.
pub fn stz_string_unescape_html(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);

    const result = stz_string_new() orelse return null;
    var off: usize = 0;
    while (off < src.len) {
        if (src[off] == '&') {
            if (off + 4 <= src.len and mem.eql(u8, src[off..][0..4], "&lt;")) {
                result.data.appendSlice(gpa, "<") catch break;
                off += 4;
            } else if (off + 4 <= src.len and mem.eql(u8, src[off..][0..4], "&gt;")) {
                result.data.appendSlice(gpa, ">") catch break;
                off += 4;
            } else if (off + 5 <= src.len and mem.eql(u8, src[off..][0..5], "&amp;")) {
                result.data.appendSlice(gpa, "&") catch break;
                off += 5;
            } else if (off + 6 <= src.len and mem.eql(u8, src[off..][0..6], "&quot;")) {
                result.data.appendSlice(gpa, "\"") catch break;
                off += 6;
            } else if (off + 5 <= src.len and mem.eql(u8, src[off..][0..5], "&#39;")) {
                result.data.appendSlice(gpa, "'") catch break;
                off += 5;
            } else {
                result.data.appendSlice(gpa, &[_]u8{src[off]}) catch break;
                off += 1;
            }
        } else {
            result.data.appendSlice(gpa, &[_]u8{src[off]}) catch break;
            off += 1;
        }
    }
    return result;
}

/// Count sentences (terminated by '.', '!', or '?').
pub fn stz_string_count_sentences(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var count: c_int = 0;
    for (src) |c| {
        if (c == '.' or c == '!' or c == '?') count += 1;
    }
    return count;
}

/// Smart titlecase: capitalize words except small words (the, a, an, of, in, on, at, to, for, and, but, or, is).
/// First word is always capitalized. Returns new handle.
pub fn stz_string_title_smart(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);

    const small_words = [_][]const u8{ "the", "a", "an", "of", "in", "on", "at", "to", "for", "and", "but", "or", "is" };

    const result = stz_string_new() orelse return null;
    var off: usize = 0;
    var first_word = true;

    while (off < src.len) {
        // Skip spaces
        while (off < src.len and (src[off] == ' ' or src[off] == '\t')) {
            result.data.appendSlice(gpa, src[off..][0..1]) catch break;
            off += 1;
        }
        if (off >= src.len) break;

        // Find word end
        const word_start = off;
        while (off < src.len and src[off] != ' ' and src[off] != '\t') off += 1;
        const word = src[word_start..off];

        if (first_word or !isSmallWord(word, &small_words)) {
            // Capitalize first letter
            if (word.len > 0 and word[0] >= 'a' and word[0] <= 'z') {
                result.data.appendSlice(gpa, &[_]u8{word[0] - 32}) catch break;
                if (word.len > 1) result.data.appendSlice(gpa, word[1..]) catch break;
            } else {
                result.data.appendSlice(gpa, word) catch break;
            }
        } else {
            result.data.appendSlice(gpa, word) catch break;
        }
        first_word = false;
    }
    return result;
}

fn isSmallWord(word: []const u8, small_words: []const []const u8) bool {
    // Compare lowercase
    var buf: [16]u8 = undefined;
    if (word.len > 16) return false;
    for (word, 0..) |c, i| {
        buf[i] = if (c >= 'A' and c <= 'Z') c + 32 else c;
    }
    const lower = buf[0..word.len];
    for (small_words) |sw| {
        if (mem.eql(u8, lower, sw)) return true;
    }
    return false;
}

/// Remove all ASCII punctuation characters. Returns new handle.
pub fn stz_string_remove_punctuation(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);

    const result = stz_string_new() orelse return null;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (!((c >= '!' and c <= '/') or (c >= ':' and c <= '@') or
                (c >= '[' and c <= '`') or (c >= '{' and c <= '~')))
            {
                result.data.appendSlice(gpa, src[off..][0..1]) catch break;
            }
        } else {
            result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
        }
        off += cp_len;
    }
    return result;
}

/// Check if string is a valid float format (optional sign, digits, one dot, digits).
/// E.g. "3.14", "-0.5", "+123.456" are valid. Returns 1 if valid, 0 otherwise.
pub fn stz_string_is_float(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var off: usize = 0;
    // Optional sign
    if (off < src.len and (src[off] == '+' or src[off] == '-')) off += 1;
    if (off >= src.len) return 0;

    var has_digits_before = false;
    while (off < src.len and src[off] >= '0' and src[off] <= '9') {
        has_digits_before = true;
        off += 1;
    }

    // Must have dot
    if (off >= src.len or src[off] != '.') return 0;
    off += 1;

    var has_digits_after = false;
    while (off < src.len and src[off] >= '0' and src[off] <= '9') {
        has_digits_after = true;
        off += 1;
    }

    if (off != src.len) return 0; // trailing chars
    if (!has_digits_before and !has_digits_after) return 0;
    return 1;
}

/// Sum of all digit characters in the string. E.g. "a1b2c3" -> 6.
pub fn stz_string_digit_sum(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var sum: c_int = 0;
    for (src) |c| {
        if (c >= '0' and c <= '9') sum += @as(c_int, c - '0');
    }
    return sum;
}

/// Convert to alternating case: first letter lower, second upper, etc.
/// E.g. "hello world" -> "hElLo wOrLd". Non-letters don't count.
/// Returns new handle.
pub fn stz_string_to_alternating_case(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return stz_string_from(src.ptr, 0);

    const result = stz_string_new() orelse return null;
    var letter_idx: usize = 0;
    for (src) |c| {
        if ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z')) {
            if (letter_idx % 2 == 0) {
                // lowercase
                const lower = if (c >= 'A' and c <= 'Z') c + 32 else c;
                result.data.appendSlice(gpa, &[_]u8{lower}) catch break;
            } else {
                // uppercase
                const upper = if (c >= 'a' and c <= 'z') c - 32 else c;
                result.data.appendSlice(gpa, &[_]u8{upper}) catch break;
            }
            letter_idx += 1;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

/// Count uppercase ASCII letters.
pub fn stz_string_count_upper(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c >= 'A' and c <= 'Z') count += 1;
    }
    return count;
}

/// Count lowercase ASCII letters.
pub fn stz_string_count_lower(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c >= 'a' and c <= 'z') count += 1;
    }
    return count;
}

/// Check if string is in camelCase format (starts lowercase, has at least one uppercase).
/// Returns 1 if camelCase, 0 otherwise.
pub fn stz_string_is_camel_case(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len < 2) return 0;

    // First char must be lowercase letter
    if (!(src[0] >= 'a' and src[0] <= 'z')) return 0;

    // Must contain at least one uppercase
    var has_upper = false;
    for (src[1..]) |c| {
        if (c >= 'A' and c <= 'Z') { has_upper = true; break; }
    }
    if (!has_upper) return 0;

    // Must only contain letters and digits
    for (src) |c| {
        if (!((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or (c >= '0' and c <= '9'))) return 0;
    }
    return 1;
}

/// Return characters common to both strings (unique, in order of appearance in h1).
/// Returns new handle.
pub fn stz_string_common_chars(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const src1 = s1.slice();
    const src2 = s2.slice();

    const result = stz_string_new() orelse return null;
    var seen: [256]bool = [_]bool{false} ** 256;

    var off: usize = 0;
    while (off < src1.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src1[off]) catch break;
        if (off + cp_len > src1.len) break;
        if (cp_len == 1) {
            const c = src1[off];
            if (!seen[c]) {
                // Check if this char exists in src2
                for (src2) |c2| {
                    if (c2 == c) {
                        result.data.appendSlice(gpa, &[_]u8{c}) catch break;
                        seen[c] = true;
                        break;
                    }
                }
            }
        }
        off += cp_len;
    }
    return result;
}

// batch 7 ─────────────────────────────────────────────────────────

/// Count the number of lines (separated by \n). A string with no newline = 1 line.
pub export fn stz_string_count_lines(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;
    var count: c_int = 1;
    for (src) |c| {
        if (c == '\n') count += 1;
    }
    return count;
}

/// Check if string is in snake_case format: lowercase + underscores, starts with letter, no consecutive underscores.
pub export fn stz_string_is_snake_case(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;
    // Must start with lowercase letter
    if (src[0] < 'a' or src[0] > 'z') return 0;
    var prev_underscore = false;
    for (src) |c| {
        if (c >= 'a' and c <= 'z') {
            prev_underscore = false;
        } else if (c >= '0' and c <= '9') {
            prev_underscore = false;
        } else if (c == '_') {
            if (prev_underscore) return 0; // consecutive underscores
            prev_underscore = true;
        } else {
            return 0; // invalid character
        }
    }
    // Must not end with underscore
    if (src[src.len - 1] == '_') return 0;
    // Must have at least one underscore to be snake_case
    for (src) |c| {
        if (c == '_') return 1;
    }
    return 0; // single word, no underscore
}

/// Check if string is in kebab-case format: lowercase + hyphens, starts with letter, no consecutive hyphens.
pub export fn stz_string_is_kebab_case(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;
    // Must start with lowercase letter
    if (src[0] < 'a' or src[0] > 'z') return 0;
    var prev_hyphen = false;
    for (src) |c| {
        if (c >= 'a' and c <= 'z') {
            prev_hyphen = false;
        } else if (c >= '0' and c <= '9') {
            prev_hyphen = false;
        } else if (c == '-') {
            if (prev_hyphen) return 0;
            prev_hyphen = true;
        } else {
            return 0;
        }
    }
    if (src[src.len - 1] == '-') return 0;
    // Must have at least one hyphen
    for (src) |c| {
        if (c == '-') return 1;
    }
    return 0;
}

/// Count unique (distinct) characters in the string.
pub export fn stz_string_count_unique_chars(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    // For ASCII, use a 256-entry seen table; for multi-byte, count them separately
    var seen: [256]bool = [_]bool{false} ** 256;
    var count: c_int = 0;
    var multi_byte_count: c_int = 0;

    // Simple approach: for single-byte chars use the table, for multi-byte just count unique sequences
    // (limited to ASCII uniqueness for performance; multi-byte chars each counted as unique)
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            if (!seen[src[off]]) {
                seen[src[off]] = true;
                count += 1;
            }
        } else {
            // For multi-byte, do a naive check against previously seen multi-byte sequences
            // Simple: just count all multi-byte codepoints (approximation for ASCII-heavy use)
            multi_byte_count += 1;
        }
        off += cp_len;
    }
    return count + multi_byte_count;
}

/// Caesar cipher: shift each ASCII letter by n positions (wrapping). Non-letters unchanged.
pub export fn stz_string_caesar(handle: ?*StzString, shift: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;

    // Normalize shift to 0-25 range
    const n: u8 = @intCast(@mod(shift, 26));

    for (src) |c| {
        if (c >= 'a' and c <= 'z') {
            const shifted: u8 = 'a' + @as(u8, @intCast((@as(u16, c - 'a') + n) % 26));
            result.data.appendSlice(gpa, &[_]u8{shifted}) catch break;
        } else if (c >= 'A' and c <= 'Z') {
            const shifted: u8 = 'A' + @as(u8, @intCast((@as(u16, c - 'A') + n) % 26));
            result.data.appendSlice(gpa, &[_]u8{shifted}) catch break;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

// batch 8 ─────────────────────────────────────────────────────────

/// Mirror/reflect: "abc" -> "abccba"
pub export fn stz_string_mirror(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;

    // Append original
    result.data.appendSlice(gpa, src) catch return result;
    // Append reversed
    var off: usize = src.len;
    while (off > 0) {
        // Walk backwards to find start of previous codepoint
        off -= 1;
        while (off > 0 and (src[off] & 0xC0) == 0x80) {
            off -= 1;
        }
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        result.data.appendSlice(gpa, src[off .. off + cp_len]) catch break;
        if (off == 0) break;
    }
    return result;
}

/// Repeat each character n times: "abc", 2 -> "aabbcc"
pub export fn stz_string_repeat_each_char(handle: ?*StzString, n: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    if (n <= 0) return result;
    const count: usize = @intCast(n);

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const ch = src[off .. off + cp_len];
        for (0..count) |_| {
            result.data.appendSlice(gpa, ch) catch break;
        }
        off += cp_len;
    }
    return result;
}

/// Check if string starts with any of the given prefixes (pipe-separated: "http|ftp|ssh")
pub export fn stz_string_starts_with_any(handle: ?*StzString, prefixes: [*c]const u8, prefixes_len: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    const plen: usize = if (prefixes_len >= 0) @intCast(prefixes_len) else return 0;
    const pstr = prefixes[0..plen];

    // Split by pipe and check each
    var start: usize = 0;
    var i: usize = 0;
    while (i <= pstr.len) : (i += 1) {
        if (i == pstr.len or pstr[i] == '|') {
            const prefix = pstr[start..i];
            if (prefix.len > 0 and prefix.len <= src.len) {
                if (mem.eql(u8, src[0..prefix.len], prefix)) return 1;
            }
            start = i + 1;
        }
    }
    return 0;
}

/// Check if string ends with any of the given suffixes (pipe-separated: ".txt|.md|.zig")
pub export fn stz_string_ends_with_any(handle: ?*StzString, suffixes: [*c]const u8, suffixes_len: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    const slen: usize = if (suffixes_len >= 0) @intCast(suffixes_len) else return 0;
    const sstr = suffixes[0..slen];

    var start: usize = 0;
    var i: usize = 0;
    while (i <= sstr.len) : (i += 1) {
        if (i == sstr.len or sstr[i] == '|') {
            const suffix = sstr[start..i];
            if (suffix.len > 0 and suffix.len <= src.len) {
                if (mem.eql(u8, src[src.len - suffix.len ..], suffix)) return 1;
            }
            start = i + 1;
        }
    }
    return 0;
}

/// Convert string to binary representation: each byte as 8 binary digits, space-separated.
pub export fn stz_string_to_binary(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;

    for (src, 0..) |byte, idx| {
        if (idx > 0) result.data.appendSlice(gpa, " ") catch break;
        var buf: [8]u8 = undefined;
        for (0..8) |bit| {
            buf[bit] = if ((byte >> @intCast(7 - bit)) & 1 == 1) '1' else '0';
        }
        result.data.appendSlice(gpa, &buf) catch break;
    }
    return result;
}

// ─── Tests ───

test "sort_chars" {
    const s1 = stz_string_from("dcba", 4);
    const asc = stz_string_sort_chars_asc(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(asc)[0..@intCast(stz_string_size(asc))], "abcd"));
    stz_string_free(asc);

    const desc = stz_string_sort_chars_desc(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(desc)[0..@intCast(stz_string_size(desc))], "dcba"));
    stz_string_free(desc);
    stz_string_free(s1);
}

test "find_all_char" {
    const s1 = stz_string_from("abcabc", 6);
    const fr = stz_string_find_all_char(s1, 'a');
    try std.testing.expect(fr != null);
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(fr));
    try std.testing.expectEqual(@as(c_int, 0), stz_find_result_get(fr, 0));
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_get(fr, 1));
    stz_find_result_free(fr);
    stz_string_free(s1);
}

test "hash" {
    const s1 = stz_string_from("hello", 5);
    const h1 = stz_string_hash(s1);
    const s2 = stz_string_from("hello", 5);
    const h2 = stz_string_hash(s2);
    try std.testing.expectEqual(h1, h2);
    stz_string_free(s2);

    const s3 = stz_string_from("world", 5);
    const h3 = stz_string_hash(s3);
    try std.testing.expect(h1 != h3);
    stz_string_free(s3);
    stz_string_free(s1);
}

test "count_char" {
    const s1 = stz_string_from("mississippi", 11);
    try std.testing.expectEqual(@as(c_int, 4), stz_string_count_char(s1, 's'));
    try std.testing.expectEqual(@as(c_int, 2), stz_string_count_char(s1, 'p'));
    try std.testing.expectEqual(@as(c_int, 4), stz_string_count_char(s1, 'i'));
    stz_string_free(s1);
}

test "replace_char" {
    const s1 = stz_string_from("hello", 5);
    const r1 = stz_string_replace_char(s1, 'l', 'r');
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "herro"));
    stz_string_free(r1);
    stz_string_free(s1);
}

test "copy" {
    const s1 = stz_string_from("hello", 5);
    const s2 = stz_string_copy(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(s2)[0..@intCast(stz_string_size(s2))], "hello"));
    stz_string_free(s2);
    stz_string_free(s1);
}

test "compare" {
    const s1 = stz_string_from("abc", 3);
    const s2 = stz_string_from("abc", 3);
    const s3 = stz_string_from("abd", 3);
    const s4 = stz_string_from("ab", 2);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_compare(s1, s2));
    try std.testing.expectEqual(@as(c_int, -1), stz_string_compare(s1, s3));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_compare(s3, s1));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_compare(s1, s4));
    try std.testing.expectEqual(@as(c_int, -1), stz_string_compare(s4, s1));
    stz_string_free(s4);
    stz_string_free(s3);
    stz_string_free(s2);
    stz_string_free(s1);
}

test "remove_first_occurrence" {
    const s1 = stz_string_from("hello world hello", 17);
    const r1 = stz_string_remove_first_occurrence(s1, "hello", 5);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], " world hello"));
    stz_string_free(r1);
    stz_string_free(s1);
}

test "remove_last_occurrence" {
    const s1 = stz_string_from("hello world hello", 17);
    const r1 = stz_string_remove_last_occurrence(s1, "hello", 5);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "hello world "));
    stz_string_free(r1);
    stz_string_free(s1);
}

test "remove_nth_occurrence" {
    const s1 = stz_string_from("abcabcabc", 9);
    const r0 = stz_string_remove_nth_occurrence(s1, "abc", 3, 0);
    try std.testing.expect(mem.eql(u8, stz_string_data(r0)[0..@intCast(stz_string_size(r0))], "abcabc"));
    stz_string_free(r0);
    const r1 = stz_string_remove_nth_occurrence(s1, "abc", 3, 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "abcabc"));
    stz_string_free(r1);
    const r2 = stz_string_remove_nth_occurrence(s1, "abc", 3, 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "abcabc"));
    stz_string_free(r2);
    stz_string_free(s1);
}

test "repeat_char" {
    const r1 = stz_string_repeat_char('*', 5);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "*****"));
    stz_string_free(r1);

    const r2 = stz_string_repeat_char('-', 0);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_size(r2));
    stz_string_free(r2);
}

test "insert_before_each" {
    const s1 = stz_string_from("abcabc", 6);
    const r1 = stz_string_insert_before_each(s1, "abc", 3, "[", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "[abc[abc"));
    stz_string_free(r1);
    stz_string_free(s1);
}

test "insert_after_each" {
    const s1 = stz_string_from("abcabc", 6);
    const r1 = stz_string_insert_after_each(s1, "abc", 3, "]", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "abc]abc]"));
    stz_string_free(r1);
    stz_string_free(s1);
}

test "truncate" {
    const s1 = stz_string_from("Hello World", 11);
    const r1 = stz_string_truncate(s1, 5, "...", 3);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "Hello..."));
    stz_string_free(r1);

    // String shorter than max - no truncation
    const r2 = stz_string_truncate(s1, 20, "...", 3);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "Hello World"));
    stz_string_free(r2);
    stz_string_free(s1);
}

test "wrap_at" {
    const s1 = stz_string_from("hello world foo bar", 19);
    const r1 = stz_string_wrap_at(s1, 10);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "hello\nworld foo\nbar"));
    stz_string_free(r1);
    stz_string_free(s1);
}

test "is_chars_sorted" {
    const s1 = stz_string_from("abcd", 4);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_chars_sorted_asc(s1));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_chars_sorted_desc(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("dcba", 4);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_chars_sorted_asc(s2));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_chars_sorted_desc(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("a", 1);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_chars_sorted_asc(s3));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_chars_sorted_desc(s3));
    stz_string_free(s3);
}

test "remove_prefix_suffix" {
    const s1 = stz_string_from("Hello World", 11);
    const r1 = stz_string_remove_prefix(s1, "Hello ", 6);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "World"));
    stz_string_free(r1);

    const r2 = stz_string_remove_suffix(s1, " World", 6);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "Hello"));
    stz_string_free(r2);

    // No match - returns copy
    const r3 = stz_string_remove_prefix(s1, "xyz", 3);
    try std.testing.expect(mem.eql(u8, stz_string_data(r3)[0..@intCast(stz_string_size(r3))], "Hello World"));
    stz_string_free(r3);
    stz_string_free(s1);
}

test "ensure_prefix_suffix" {
    const s1 = stz_string_from("world", 5);
    const r1 = stz_string_ensure_prefix(s1, "hello ", 6);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "hello world"));
    stz_string_free(r1);
    stz_string_free(s1);

    const s2 = stz_string_from("hello world", 11);
    const r2 = stz_string_ensure_prefix(s2, "hello", 5);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "hello world"));
    stz_string_free(r2);

    const r3 = stz_string_ensure_suffix(s2, ".txt", 4);
    try std.testing.expect(mem.eql(u8, stz_string_data(r3)[0..@intCast(stz_string_size(r3))], "hello world.txt"));
    stz_string_free(r3);
    stz_string_free(s2);
}

test "squeeze_char" {
    const s1 = stz_string_from("heeellooo", 9);
    const r1 = stz_string_squeeze_char(s1, 'e');
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "hellooo"));
    stz_string_free(r1);

    const r2 = stz_string_squeeze_char(s1, 'o');
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "heeello"));
    stz_string_free(r2);
    stz_string_free(s1);
}

test "capitalize_decapitalize_first" {
    const s1 = stz_string_from("hello world", 11);
    const r1 = stz_string_capitalize_first(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "Hello world"));
    stz_string_free(r1);
    stz_string_free(s1);

    const s2 = stz_string_from("Hello", 5);
    const r2 = stz_string_decapitalize_first(s2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "hello"));
    stz_string_free(r2);
    stz_string_free(s2);
}

test "zfill" {
    const s1 = stz_string_from("42", 2);
    const r1 = stz_string_zfill(s1, 5);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "00042"));
    stz_string_free(r1);

    const r2 = stz_string_zfill(s1, 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "42"));
    stz_string_free(r2);
    stz_string_free(s1);
}

test "tab_expand" {
    const s1 = stz_string_from("a\tb\tc", 5);
    const r1 = stz_string_tab_expand(s1, 4);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "a    b    c"));
    stz_string_free(r1);
    stz_string_free(s1);
}

test "count_overlapping" {
    const s1 = stz_string_from("aaaa", 4);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_count_overlapping(s1, "aa", 2));
    stz_string_free(s1);

    const s2 = stz_string_from("abcabc", 6);
    try std.testing.expectEqual(@as(c_int, 2), stz_string_count_overlapping(s2, "abc", 3));
    stz_string_free(s2);
}

test "replace_at" {
    const s1 = stz_string_from("Hello World", 11);
    const r1 = stz_string_replace_at(s1, 5, 1, "-", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "Hello-World"));
    stz_string_free(r1);
    stz_string_free(s1);
}

test "contains_any_of" {
    const s1 = stz_string_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_contains_any_of(s1, "aeiou", 5));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_contains_any_of(s1, "xyz", 3));
    stz_string_free(s1);
}

test "contains_all_of" {
    const s1 = stz_string_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_contains_all_of(s1, "helo", 4));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_contains_all_of(s1, "heloz", 5));
    stz_string_free(s1);
}

test "foldcase" {
    const s1 = stz_string_from("Hello WORLD", 11);
    const folded = stz_string_foldcase(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(folded)[0..@intCast(stz_string_size(folded))], "hello world"));
    stz_string_free(folded);
    stz_string_free(s1);
}

test "center_pad" {
    const s1 = stz_string_from("hi", 2);
    const padded = stz_string_center_pad(s1, 6, "-", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(padded)[0..@intCast(stz_string_size(padded))], "--hi--"));
    stz_string_free(padded);

    const padded_odd = stz_string_center_pad(s1, 7, "*", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(padded_odd)[0..@intCast(stz_string_size(padded_odd))], "**hi***"));
    stz_string_free(padded_odd);
    stz_string_free(s1);
}

test "only_letters" {
    const s1 = stz_string_from("h3ll0 w0rld!", 12);
    const letters = stz_string_only_letters(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(letters)[0..@intCast(stz_string_size(letters))], "hllwrld"));
    stz_string_free(letters);
    stz_string_free(s1);
}

test "only_digits" {
    const s1 = stz_string_from("a1b2c3", 6);
    const digits = stz_string_only_digits(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(digits)[0..@intCast(stz_string_size(digits))], "123"));
    stz_string_free(digits);
    stz_string_free(s1);
}

test "remove_whitespace" {
    const s1 = stz_string_from("h e l l o", 9);
    const nows = stz_string_remove_whitespace(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(nows)[0..@intCast(stz_string_size(nows))], "hello"));
    stz_string_free(nows);
    stz_string_free(s1);
}

test "is_palindrome" {
    const s1 = stz_string_from("abcba", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_palindrome(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("abcd", 4);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_palindrome(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("a", 1);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_palindrome(s3));
    stz_string_free(s3);
}

test "count_words" {
    const s1 = stz_string_from("hello world foo", 15);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_count_words(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("  hello  ", 9);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_count_words(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_count_words(s3));
    stz_string_free(s3);
}

test "nth_word" {
    const s1 = stz_string_from("hello world foo", 15);
    const w0 = stz_string_nth_word(s1, 0);
    try std.testing.expect(mem.eql(u8, stz_string_data(w0)[0..@intCast(stz_string_size(w0))], "hello"));
    stz_string_free(w0);

    const w1 = stz_string_nth_word(s1, 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(w1)[0..@intCast(stz_string_size(w1))], "world"));
    stz_string_free(w1);

    const w2 = stz_string_nth_word(s1, 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(w2)[0..@intCast(stz_string_size(w2))], "foo"));
    stz_string_free(w2);
    stz_string_free(s1);
}

test "chars_between" {
    const s1 = stz_string_from("abcdef", 6);
    const between = stz_string_chars_between(s1, 1, 4);
    try std.testing.expect(mem.eql(u8, stz_string_data(between)[0..@intCast(stz_string_size(between))], "cd"));
    stz_string_free(between);
    stz_string_free(s1);
}

test "is_alphanumeric" {
    const s1 = stz_string_from("hello123", 8);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_alphanumeric(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("hello 123", 9);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_alphanumeric(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_alphanumeric(s3));
    stz_string_free(s3);
}

test "ljust_rjust" {
    const s1 = stz_string_from("hi", 2);
    const lj = stz_string_ljust(s1, 5, ".", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(lj)[0..@intCast(stz_string_size(lj))], "hi..."));
    stz_string_free(lj);

    const rj = stz_string_rjust(s1, 5, ".", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(rj)[0..@intCast(stz_string_size(rj))], "...hi"));
    stz_string_free(rj);
    stz_string_free(s1);
}

test "common_prefix" {
    const s1 = stz_string_from("hello world", 11);
    const s2 = stz_string_from("hello there", 11);
    const cp = stz_string_common_prefix(s1, s2);
    try std.testing.expect(mem.eql(u8, stz_string_data(cp)[0..@intCast(stz_string_size(cp))], "hello "));
    stz_string_free(cp);
    stz_string_free(s2);
    stz_string_free(s1);
}

test "indent_dedent" {
    const s1 = stz_string_from("line1\nline2", 11);
    const indented = stz_string_indent(s1, 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(indented)[0..@intCast(stz_string_size(indented))], "  line1\n  line2"));
    stz_string_free(indented);
    stz_string_free(s1);

    const s2 = stz_string_from("    hello\n    world", 19);
    const dedented = stz_string_dedent(s2);
    try std.testing.expect(mem.eql(u8, stz_string_data(dedented)[0..@intCast(stz_string_size(dedented))], "hello\nworld"));
    stz_string_free(dedented);
    stz_string_free(s2);
}

test "camel_snake_kebab" {
    const s1 = stz_string_from("hello world", 11);
    const camel = stz_string_to_camel_case(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(camel)[0..@intCast(stz_string_size(camel))], "helloWorld"));
    stz_string_free(camel);
    stz_string_free(s1);

    const s2 = stz_string_from("helloWorld", 10);
    const snake = stz_string_to_snake_case(s2);
    try std.testing.expect(mem.eql(u8, stz_string_data(snake)[0..@intCast(stz_string_size(snake))], "hello_world"));
    stz_string_free(snake);

    const kebab = stz_string_to_kebab_case(s2);
    try std.testing.expect(mem.eql(u8, stz_string_data(kebab)[0..@intCast(stz_string_size(kebab))], "hello-world"));
    stz_string_free(kebab);
    stz_string_free(s2);
}

test "partition" {
    const s1 = stz_string_from("hello:world:foo", 15);
    const before = stz_string_partition(s1, ":", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(before)[0..@intCast(stz_string_size(before))], "hello"));
    stz_string_free(before);

    const after = stz_string_partition_after(s1, ":", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(after)[0..@intCast(stz_string_size(after))], "world:foo"));
    stz_string_free(after);

    // Not found
    const before2 = stz_string_partition(s1, "xyz", 3);
    try std.testing.expect(mem.eql(u8, stz_string_data(before2)[0..@intCast(stz_string_size(before2))], "hello:world:foo"));
    stz_string_free(before2);

    const after2 = stz_string_partition_after(s1, "xyz", 3);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_size(after2));
    stz_string_free(after2);
    stz_string_free(s1);
}

test "rpartition" {
    const s1 = stz_string_from("hello:world:foo", 15);
    const before = stz_string_rpartition(s1, ":", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(before)[0..@intCast(stz_string_size(before))], "hello:world"));
    stz_string_free(before);

    const after = stz_string_rpartition_after(s1, ":", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(after)[0..@intCast(stz_string_size(after))], "foo"));
    stz_string_free(after);
    stz_string_free(s1);
}

test "squeeze" {
    const s1 = stz_string_from("heeellooo", 9);
    const r1 = stz_string_squeeze(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "helo"));
    stz_string_free(r1);
    stz_string_free(s1);

    const s2 = stz_string_from("aabbcc", 6);
    const r2 = stz_string_squeeze(s2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "abc"));
    stz_string_free(r2);
    stz_string_free(s2);
}

test "is_digit" {
    const s1 = stz_string_from("12345", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_digit(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("123a5", 5);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_digit(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_digit(s3));
    stz_string_free(s3);
}

test "interleave" {
    const s1 = stz_string_from("abc", 3);
    const r1 = stz_string_interleave(s1, ",", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "a,b,c"));
    stz_string_free(r1);

    const r2 = stz_string_interleave(s1, " - ", 3);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "a - b - c"));
    stz_string_free(r2);
    stz_string_free(s1);
}

test "strip_chars" {
    const s1 = stz_string_from("hello world!", 12);
    const r1 = stz_string_strip_chars(s1, "lo", 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "he wrd!"));
    stz_string_free(r1);
    stz_string_free(s1);

    // Strip vowels
    const s2 = stz_string_from("programming", 11);
    const r2 = stz_string_strip_chars(s2, "aeiou", 5);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "prgrmmng"));
    stz_string_free(r2);
    stz_string_free(s2);
}

test "keep_chars" {
    const s1 = stz_string_from("hello world!", 12);
    const r1 = stz_string_keep_chars(s1, "lo", 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "llool"));
    stz_string_free(r1);
    stz_string_free(s1);
}

test "replace2" {
    const s1 = stz_string_from("hello world", 11);
    const r1 = stz_string_replace2(s1, "hello", 5, "hi", 2, "world", 5, "earth", 5);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "hi earth"));
    stz_string_free(r1);
    stz_string_free(s1);
}

test "rotate" {
    const s1 = stz_string_from("abcde", 5);
    const r1 = stz_string_rotate(s1, 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "cdeab"));
    stz_string_free(r1);

    // Rotate right (negative)
    const r2 = stz_string_rotate(s1, -1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "eabcd"));
    stz_string_free(r2);

    // Rotate by length = no change
    const r3 = stz_string_rotate(s1, 5);
    try std.testing.expect(mem.eql(u8, stz_string_data(r3)[0..@intCast(stz_string_size(r3))], "abcde"));
    stz_string_free(r3);
    stz_string_free(s1);
}

test "repeat_to_length" {
    const s1 = stz_string_from("abc", 3);
    const r1 = stz_string_repeat_to_length(s1, 7);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "abcabca"));
    stz_string_free(r1);

    const r2 = stz_string_repeat_to_length(s1, 3);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "abc"));
    stz_string_free(r2);

    const r3 = stz_string_repeat_to_length(s1, 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r3)[0..@intCast(stz_string_size(r3))], "a"));
    stz_string_free(r3);
    stz_string_free(s1);
}

test "remove_between" {
    const s1 = stz_string_from("hello [world] end", 17);
    const r1 = stz_string_remove_between(s1, "[", 1, "]", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "hello  end"));
    stz_string_free(r1);
    stz_string_free(s1);

    // HTML tags
    const s2 = stz_string_from("before<tag>inside</tag>after", 28);
    const r2 = stz_string_remove_between(s2, "<tag>", 5, "</tag>", 6);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "beforeafter"));
    stz_string_free(r2);
    stz_string_free(s2);
}

test "is_blank" {
    const s1 = stz_string_from("   ", 3);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_blank(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("", 0);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_blank(s2));
    stz_string_free(s2);

    const s3 = stz_string_from(" a ", 3);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_blank(s3));
    stz_string_free(s3);
}

test "to_pascal_case" {
    const s1 = stz_string_from("hello_world", 11);
    const r1 = stz_string_to_pascal_case(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "HelloWorld"));
    stz_string_free(r1);
    stz_string_free(s1);

    const s2 = stz_string_from("my-kebab-case", 13);
    const r2 = stz_string_to_pascal_case(s2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "MyKebabCase"));
    stz_string_free(r2);
    stz_string_free(s2);

    const s3 = stz_string_from("already PascalCase", 18);
    const r3 = stz_string_to_pascal_case(s3);
    try std.testing.expect(mem.eql(u8, stz_string_data(r3)[0..@intCast(stz_string_size(r3))], "AlreadyPascalCase"));
    stz_string_free(r3);
    stz_string_free(s3);
}

test "is_identifier" {
    const s1 = stz_string_from("hello_world", 11);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_identifier(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("_private", 8);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_identifier(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("3invalid", 8);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_identifier(s3));
    stz_string_free(s3);

    const s4 = stz_string_from("has space", 9);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_identifier(s4));
    stz_string_free(s4);

    const s5 = stz_string_from("CamelCase123", 12);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_identifier(s5));
    stz_string_free(s5);
}

test "replace_between" {
    const s1 = stz_string_from("hello [world] end", 17);
    const r1 = stz_string_replace_between(s1, "[", 1, "]", 1, "REPLACED", 8);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "hello REPLACED end"));
    stz_string_free(r1);
    stz_string_free(s1);

    // Replace with empty
    const s2 = stz_string_from("a<b>c", 5);
    const r2 = stz_string_replace_between(s2, "<", 1, ">", 1, "", 0);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "ac"));
    stz_string_free(r2);
    stz_string_free(s2);
}

test "contains_only" {
    const s1 = stz_string_from("aabbcc", 6);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_contains_only(s1, "abc", 3));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_contains_only(s1, "ab", 2));
    stz_string_free(s1);

    const s2 = stz_string_from("12345", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_contains_only(s2, "0123456789", 10));
    stz_string_free(s2);
}

test "capitalize_words" {
    const s1 = stz_string_from("hello world", 11);
    const r1 = stz_string_capitalize_words(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "Hello World"));
    stz_string_free(r1);
    stz_string_free(s1);

    const s2 = stz_string_from("already OK here", 15);
    const r2 = stz_string_capitalize_words(s2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "Already OK Here"));
    stz_string_free(r2);
    stz_string_free(s2);
}

test "swap_chars" {
    const s1 = stz_string_from("abcde", 5);
    const r1 = stz_string_swap_chars(s1, 0, 4);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "ebcda"));
    stz_string_free(r1);

    const r2 = stz_string_swap_chars(s1, 1, 3);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "adcbe"));
    stz_string_free(r2);
    stz_string_free(s1);
}

test "encode_hex" {
    const s1 = stz_string_from("Hi", 2);
    const r1 = stz_string_encode_hex(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "4869"));
    stz_string_free(r1);
    stz_string_free(s1);
}

test "decode_hex" {
    const s1 = stz_string_from("4869", 4);
    const r1 = stz_string_decode_hex(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "Hi"));
    stz_string_free(r1);
    stz_string_free(s1);
}

test "reverse_words" {
    const s1 = stz_string_from("hello world foo", 15);
    const r1 = stz_string_reverse_words(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "foo world hello"));
    stz_string_free(r1);
    stz_string_free(s1);

    const s2 = stz_string_from("single", 6);
    const r2 = stz_string_reverse_words(s2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "single"));
    stz_string_free(r2);
    stz_string_free(s2);
}

test "collapse_spaces" {
    const s1 = stz_string_from("  hello   world  ", 17);
    const r1 = stz_string_collapse_spaces(s1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "hello world"));
    stz_string_free(r1);
    stz_string_free(s1);

    const s2 = stz_string_from("no extra spaces", 15);
    const r2 = stz_string_collapse_spaces(s2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "no extra spaces"));
    stz_string_free(r2);
    stz_string_free(s2);
}

test "is_anagram" {
    const s1 = stz_string_from("listen", 6);
    const s2 = stz_string_from("silent", 6);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_anagram(s1, s2));
    stz_string_free(s2);

    const s3 = stz_string_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_anagram(s1, s3));
    stz_string_free(s3);
    stz_string_free(s1);
}

test "mask" {
    const s1 = stz_string_from("hello@mail.com", 14);
    const r1 = stz_string_mask(s1, "*", 1, 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "he**********om"));
    stz_string_free(r1);
    stz_string_free(s1);

    const s2 = stz_string_from("ab", 2);
    const r2 = stz_string_mask(s2, "*", 1, 2);
    // Too short to mask (2 chars, keep 2+2=4), returns as-is
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "ab"));
    stz_string_free(r2);
    stz_string_free(s2);
}

test "count_runs" {
    const s1 = stz_string_from("aabbbcc", 7);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_count_runs(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("abcde", 5);
    try std.testing.expectEqual(@as(c_int, 5), stz_string_count_runs(s2));
    stz_string_free(s2);

    const s3 = stz_string_from("aaaa", 4);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_count_runs(s3));
    stz_string_free(s3);
}

test "hamming_distance" {
    const s1 = stz_string_from("karolin", 7);
    const s2 = stz_string_from("kathrin", 7);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_hamming_distance(s1, s2));
    stz_string_free(s2);
    stz_string_free(s1);

    const s3 = stz_string_from("abc", 3);
    const s4 = stz_string_from("abcd", 4);
    try std.testing.expectEqual(@as(c_int, -1), stz_string_hamming_distance(s3, s4));
    stz_string_free(s4);
    stz_string_free(s3);
}

test "remove_vowels" {
    const h = stz_string_from("Hello World", 11);
    const r = stz_string_remove_vowels(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "Hll Wrld"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("aeiou", 5);
    const r2 = stz_string_remove_vowels(h2);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_size(r2));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "only_vowels" {
    const h = stz_string_from("Hello World", 11);
    const r = stz_string_only_vowels(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "eoo"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("xyz", 3);
    const r2 = stz_string_only_vowels(h2);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_size(r2));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "is_pangram" {
    const h = stz_string_from("The quick brown fox jumps over the lazy dog", 43);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_pangram(h));
    stz_string_free(h);

    const h2 = stz_string_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_pangram(h2));
    stz_string_free(h2);
}

test "ngram" {
    const h = stz_string_from("hello", 5);
    const r = stz_string_ngram(h, 2, 0);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "he"));
    stz_string_free(r);

    const r2 = stz_string_ngram(h, 2, 3);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "lo"));
    stz_string_free(r2);

    const r3 = stz_string_ngram(h, 2, 4);
    try std.testing.expectEqual(@as(StzStringHandle, null), r3);
    stz_string_free(h);
}

test "ngram_count" {
    const h = stz_string_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 4), stz_string_ngram_count(h, 2));
    try std.testing.expectEqual(@as(c_int, 3), stz_string_ngram_count(h, 3));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_ngram_count(h, 5));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_ngram_count(h, 6));
    stz_string_free(h);
}

test "count_consonants" {
    const h = stz_string_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 7), stz_string_count_consonants(h));
    stz_string_free(h);

    const h2 = stz_string_from("aeiou", 5);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_count_consonants(h2));
    stz_string_free(h2);
}

test "to_sentence_case" {
    const h = stz_string_from("hELLO WORLD", 11);
    const r = stz_string_to_sentence_case(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "Hello world"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("already lowercase", 17);
    const r2 = stz_string_to_sentence_case(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "Already lowercase"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "is_balanced" {
    const h1 = stz_string_from("(hello [world])", 15);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_balanced(h1));
    stz_string_free(h1);

    const h2 = stz_string_from("(hello [world)", 14);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_balanced(h2));
    stz_string_free(h2);

    const h3 = stz_string_from("{[()]}", 6);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_balanced(h3));
    stz_string_free(h3);
}

test "slug" {
    const h = stz_string_from("Hello World! This is a Test", 27);
    const r = stz_string_slug(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "hello-world-this-is-a-test"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("  Multiple   Spaces  ", 21);
    const r2 = stz_string_slug(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "multiple-spaces"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "chunk" {
    const h = stz_string_from("abcdefgh", 8);
    const r0 = stz_string_chunk(h, 3, 0);
    try std.testing.expect(mem.eql(u8, stz_string_data(r0)[0..@intCast(stz_string_size(r0))], "abc"));
    stz_string_free(r0);

    const r1 = stz_string_chunk(h, 3, 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "def"));
    stz_string_free(r1);

    const r2 = stz_string_chunk(h, 3, 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "gh"));
    stz_string_free(r2);

    const r3 = stz_string_chunk(h, 3, 3);
    try std.testing.expectEqual(@as(StzStringHandle, null), r3);
    stz_string_free(h);
}

test "count_vowels" {
    const h = stz_string_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_count_vowels(h));
    stz_string_free(h);

    const h2 = stz_string_from("bcdfg", 5);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_count_vowels(h2));
    stz_string_free(h2);
}

test "longest_run" {
    const h = stz_string_from("aabbbcccc", 9);
    try std.testing.expectEqual(@as(c_int, 4), stz_string_longest_run(h));
    stz_string_free(h);

    const h2 = stz_string_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_longest_run(h2));
    stz_string_free(h2);
}

test "trim_chars" {
    const h = stz_string_from("***hello***", 11);
    const r = stz_string_trim_chars(h, "*", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "hello"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("--=hello=--", 11);
    const r2 = stz_string_trim_chars(h2, "-=", 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "hello"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "is_email_like" {
    const h1 = stz_string_from("user@example.com", 16);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_email_like(h1));
    stz_string_free(h1);

    const h2 = stz_string_from("no-at-sign.com", 14);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_email_like(h2));
    stz_string_free(h2);

    const h3 = stz_string_from("@nodomain", 9);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_email_like(h3));
    stz_string_free(h3);
}

test "camel_to_words" {
    const h = stz_string_from("camelCaseString", 15);
    const r = stz_string_camel_to_words(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "camel Case String"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("HTMLParser", 10);
    const r2 = stz_string_camel_to_words(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "HTML Parser"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "initials" {
    const h = stz_string_from("Hello World", 11);
    const r = stz_string_initials(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "HW"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("united states of america", 24);
    const r2 = stz_string_initials(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "usoa"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "remove_duplicate_words" {
    const h = stz_string_from("the the cat sat on the mat", 26);
    const r = stz_string_remove_duplicate_words(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "the cat sat on mat"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("abc def abc", 11);
    const r2 = stz_string_remove_duplicate_words(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "abc def"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "is_url_like" {
    const h1 = stz_string_from("https://example.com", 19);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_url_like(h1));
    stz_string_free(h1);

    const h2 = stz_string_from("http://example.com", 18);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_url_like(h2));
    stz_string_free(h2);

    const h3 = stz_string_from("ftp://files.com", 15);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_url_like(h3));
    stz_string_free(h3);
}

test "escape_html" {
    const h = stz_string_from("<b>&hi</b>", 10);
    const r = stz_string_escape_html(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "&lt;b&gt;&amp;hi&lt;/b&gt;"));
    stz_string_free(r);
    stz_string_free(h);
}

test "unescape_html" {
    const h = stz_string_from("&lt;b&gt;hello&lt;/b&gt;", 24);
    const r = stz_string_unescape_html(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "<b>hello</b>"));
    stz_string_free(r);
    stz_string_free(h);
}

test "count_sentences" {
    const h = stz_string_from("Hello. How are you? Fine!", 25);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_count_sentences(h));
    stz_string_free(h);

    const h2 = stz_string_from("No sentence end", 15);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_count_sentences(h2));
    stz_string_free(h2);
}

test "title_smart" {
    const h = stz_string_from("the lord of the rings", 21);
    const r = stz_string_title_smart(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "The Lord of the Rings"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("a tale of two cities", 20);
    const r2 = stz_string_title_smart(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "A Tale of Two Cities"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "remove_punctuation" {
    const h = stz_string_from("Hello, World! How's it?", 23);
    const r = stz_string_remove_punctuation(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "Hello World Hows it"));
    stz_string_free(r);
    stz_string_free(h);
}

test "is_float" {
    const h1 = stz_string_from("3.14", 4);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_float(h1));
    stz_string_free(h1);

    const h2 = stz_string_from("-0.5", 4);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_float(h2));
    stz_string_free(h2);

    const h3 = stz_string_from("42", 2);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_float(h3));
    stz_string_free(h3);

    const h4 = stz_string_from("1.2.3", 5);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_float(h4));
    stz_string_free(h4);
}

test "digit_sum" {
    const h = stz_string_from("a1b2c3", 6);
    try std.testing.expectEqual(@as(c_int, 6), stz_string_digit_sum(h));
    stz_string_free(h);

    const h2 = stz_string_from("999", 3);
    try std.testing.expectEqual(@as(c_int, 27), stz_string_digit_sum(h2));
    stz_string_free(h2);

    const h3 = stz_string_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_digit_sum(h3));
    stz_string_free(h3);
}

test "to_alternating_case" {
    const h = stz_string_from("hello world", 11);
    const r = stz_string_to_alternating_case(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "hElLo WoRlD"));
    stz_string_free(r);
    stz_string_free(h);
}

test "count_upper_lower" {
    const h = stz_string_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 2), stz_string_count_upper(h));
    try std.testing.expectEqual(@as(c_int, 8), stz_string_count_lower(h));
    stz_string_free(h);
}

test "is_camel_case" {
    const h1 = stz_string_from("camelCase", 9);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_camel_case(h1));
    stz_string_free(h1);

    const h2 = stz_string_from("PascalCase", 10);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_camel_case(h2));
    stz_string_free(h2);

    const h3 = stz_string_from("lowercase", 9);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_camel_case(h3));
    stz_string_free(h3);

    const h4 = stz_string_from("has space", 9);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_camel_case(h4));
    stz_string_free(h4);
}

test "common_chars" {
    const h1 = stz_string_from("hello", 5);
    const h2 = stz_string_from("world", 5);
    const r = stz_string_common_chars(h1, h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "lo"));
    stz_string_free(r);
    stz_string_free(h2);
    stz_string_free(h1);
}

test "count_lines" {
    const h1 = stz_string_from("hello\nworld\nfoo", 15);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_count_lines(h1));
    stz_string_free(h1);

    const h2 = stz_string_from("single line", 11);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_count_lines(h2));
    stz_string_free(h2);

    const h3 = stz_string_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_count_lines(h3));
    stz_string_free(h3);
}

test "is_snake_case" {
    const h1 = stz_string_from("hello_world", 11);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_snake_case(h1));
    stz_string_free(h1);

    const h2 = stz_string_from("my_var_name", 11);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_snake_case(h2));
    stz_string_free(h2);

    const h3 = stz_string_from("camelCase", 9);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_snake_case(h3));
    stz_string_free(h3);

    const h4 = stz_string_from("hello__world", 12);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_snake_case(h4));
    stz_string_free(h4);

    const h5 = stz_string_from("single", 6);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_snake_case(h5));
    stz_string_free(h5);
}

test "is_kebab_case" {
    const h1 = stz_string_from("hello-world", 11);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_kebab_case(h1));
    stz_string_free(h1);

    const h2 = stz_string_from("my-var-name", 11);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_kebab_case(h2));
    stz_string_free(h2);

    const h3 = stz_string_from("camelCase", 9);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_kebab_case(h3));
    stz_string_free(h3);

    const h4 = stz_string_from("hello--world", 12);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_kebab_case(h4));
    stz_string_free(h4);
}

test "count_unique_chars" {
    const h1 = stz_string_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 4), stz_string_count_unique_chars(h1));
    stz_string_free(h1);

    const h2 = stz_string_from("aaa", 3);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_count_unique_chars(h2));
    stz_string_free(h2);

    const h3 = stz_string_from("abcdef", 6);
    try std.testing.expectEqual(@as(c_int, 6), stz_string_count_unique_chars(h3));
    stz_string_free(h3);
}

test "caesar" {
    const h1 = stz_string_from("abc", 3);
    const r1 = stz_string_caesar(h1, 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1)[0..@intCast(stz_string_size(r1))], "bcd"));
    stz_string_free(r1);
    stz_string_free(h1);

    const h2 = stz_string_from("xyz", 3);
    const r2 = stz_string_caesar(h2, 3);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "abc"));
    stz_string_free(r2);
    stz_string_free(h2);

    const h3 = stz_string_from("Hello, World!", 13);
    const r3 = stz_string_caesar(h3, 13);
    try std.testing.expect(mem.eql(u8, stz_string_data(r3)[0..@intCast(stz_string_size(r3))], "Uryyb, Jbeyq!"));
    stz_string_free(r3);
    stz_string_free(h3);
}

test "mirror" {
    const h = stz_string_from("abc", 3);
    const r = stz_string_mirror(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "abccba"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("a", 1);
    const r2 = stz_string_mirror(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "aa"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "repeat_each_char" {
    const h = stz_string_from("abc", 3);
    const r = stz_string_repeat_each_char(h, 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "aabbcc"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("hi", 2);
    const r2 = stz_string_repeat_each_char(h2, 3);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "hhhiii"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "starts_with_any" {
    const h = stz_string_from("https://example.com", 19);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_starts_with_any(h, "http|ftp|ssh", 12));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_starts_with_any(h, "ftp|ssh", 7));
    stz_string_free(h);
}

test "ends_with_any" {
    const h = stz_string_from("file.zig", 8);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_ends_with_any(h, ".txt|.zig|.rs", 13));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_ends_with_any(h, ".txt|.rs|.go", 12));
    stz_string_free(h);
}

test "to_binary" {
    const h = stz_string_from("Hi", 2);
    const r = stz_string_to_binary(h);
    // H = 72 = 01001000, i = 105 = 01101001
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "01001000 01101001"));
    stz_string_free(r);
    stz_string_free(h);
}

