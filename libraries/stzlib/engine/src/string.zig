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
    // Delegate to the Unicode-aware trim implementation
    return stz_string_trim(handle);
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
        // Case-fold both haystack and needle (Unicode-correct)
        const hay_folded = casefoldAlloc(hay) orelse return -1;
        defer gpa.free(hay_folded);
        const n_folded = casefoldAlloc(n) orelse return -1;
        defer gpa.free(n_folded);
        // Skip to start_cp codepoint in the folded haystack
        var byte_pos: usize = 0;
        var cp_pos: usize = 0;
        while (cp_pos < start_cp and byte_pos < hay_folded.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay_folded[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp_pos += 1;
        }
        // Search in folded haystack for folded needle
        if (mem.indexOfPos(u8, hay_folded, byte_pos, n_folded)) |pos| {
            // Convert byte offset in folded string to codepoint index
            return @intCast(byteOffsetToCodepointIndex(hay_folded, pos));
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

/// Case-fold a UTF-8 slice using utf8proc (Unicode-correct).
/// Caller must free the returned slice with gpa.free().
/// Returns null on allocation failure or empty input.
fn casefoldAlloc(input: []const u8) ?[]u8 {
    if (input.len == 0) return null;
    var out_len: usize = 0;
    const ptr = unicode.stz_unicode_casefold(input.ptr, input.len, &out_len);
    if (ptr == null or out_len == 0) return null;
    // ptr was allocated by casefold using gpa -- we own it
    return @as([*]u8, @ptrCast(ptr))[0..out_len];
}

/// Case-insensitive byte-slice comparison using Unicode case folding.
/// Both slices are case-folded and compared. Returns true if equal.
fn ciEqlUnicode(a: []const u8, b: []const u8) bool {
    const fa = casefoldAlloc(a) orelse return mem.eql(u8, a, b);
    defer gpa.free(fa);
    const fb = casefoldAlloc(b) orelse return mem.eql(u8, a, b);
    defer gpa.free(fb);
    return mem.eql(u8, fa, fb);
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
        // Case-fold both (Unicode-correct)
        const hay_folded = casefoldAlloc(hay) orelse return r;
        defer gpa.free(hay_folded);
        const n_folded = casefoldAlloc(n) orelse return r;
        defer gpa.free(n_folded);
        // Walk folded haystack by codepoints for codepoint-based positions
        var byte_pos: usize = 0;
        var cp_pos: usize = 0;
        while (byte_pos + n_folded.len <= hay_folded.len) {
            if (mem.eql(u8, hay_folded[byte_pos..][0..n_folded.len], n_folded)) {
                r.positions.append(gpa, @intCast(cp_pos)) catch break;
            }
            const cp_len = std.unicode.utf8ByteSequenceLength(hay_folded[byte_pos]) catch 1;
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
        // Case-fold both (Unicode-correct)
        const hay_folded = casefoldAlloc(hay) orelse return 0;
        defer gpa.free(hay_folded);
        const n_folded = casefoldAlloc(n) orelse return 0;
        defer gpa.free(n_folded);
        var count: c_int = 0;
        var pos: usize = 0;
        while (pos + n_folded.len <= hay_folded.len) {
            if (mem.eql(u8, hay_folded[pos..][0..n_folded.len], n_folded)) {
                count += 1;
                pos += n_folded.len;
            } else {
                pos += 1;
            }
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
        // Case-fold both (Unicode-correct)
        const hay_folded = casefoldAlloc(hay) orelse return -1;
        defer gpa.free(hay_folded);
        const n_folded = casefoldAlloc(n) orelse return -1;
        defer gpa.free(n_folded);
        if (n_folded.len > hay_folded.len) return -1;
        // Search backwards in folded haystack
        if (mem.lastIndexOf(u8, hay_folded, n_folded)) |pos| {
            return @intCast(byteOffsetToCodepointIndex(hay_folded, pos));
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
        // Case-fold both the prefix-length portion and the prefix
        const hay_prefix = casefoldAlloc(sl[0..prefix_len]) orelse return 0;
        defer gpa.free(hay_prefix);
        const pfx_folded = casefoldAlloc(prefix[0..prefix_len]) orelse return 0;
        defer gpa.free(pfx_folded);
        return if (mem.eql(u8, hay_prefix, pfx_folded)) 1 else 0;
    }
    return 0;
}

pub fn stz_string_ends_with_ci(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize) callconv(.c) c_int {
    if (handle) |s| {
        if (suffix == null or suffix_len == 0) return 1;
        const sl = s.slice();
        if (suffix_len > sl.len) return 0;
        const start = sl.len - suffix_len;
        // Case-fold both the suffix-length tail and the suffix
        const hay_suffix = casefoldAlloc(sl[start..]) orelse return 0;
        defer gpa.free(hay_suffix);
        const sfx_folded = casefoldAlloc(suffix[0..suffix_len]) orelse return 0;
        defer gpa.free(sfx_folded);
        return if (mem.eql(u8, hay_suffix, sfx_folded)) 1 else 0;
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
    return ciEqlUnicode(a, b);
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
        const src = s.slice();

        // Case-fold both source and pattern for matching
        const src_folded = casefoldAlloc(src) orelse return;
        defer gpa.free(src_folded);
        const old_folded = casefoldAlloc(old_slice) orelse return;
        defer gpa.free(old_folded);

        var result: std.ArrayList(u8) = .{};
        var pos: usize = 0;      // position in original src
        var fpos: usize = 0;     // position in folded src

        while (pos <= src.len and fpos <= src_folded.len) {
            if (fpos + old_folded.len <= src_folded.len and
                mem.eql(u8, src_folded[fpos..][0..old_folded.len], old_folded))
            {
                result.appendSlice(gpa, new_slice) catch return;
                // Advance both positions by the original match length
                pos += old_len;
                fpos += old_folded.len;
            } else if (pos < src.len) {
                // Copy one codepoint from the original (not folded)
                const cp_len = std.unicode.utf8ByteSequenceLength(src[pos]) catch 1;
                const fcp_len = if (fpos < src_folded.len)
                    std.unicode.utf8ByteSequenceLength(src_folded[fpos]) catch 1
                else
                    1;
                result.appendSlice(gpa, src[pos..@min(pos + cp_len, src.len)]) catch return;
                pos += cp_len;
                fpos += fcp_len;
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
    // Full Unicode case folding via utf8proc (handles sharp-s -> "ss", etc.)
    if (handle) |s| {
        const src = s.slice();
        if (src.len == 0) return stz_string_new();
        const folded = casefoldAlloc(src) orelse return stz_string_new();
        // casefoldAlloc returns gpa-allocated memory, wrap it in a StzString
        const r = gpa.create(StzString) catch {
            gpa.free(folded);
            return null;
        };
        r.* = StzString.init();
        r.data.appendSlice(gpa, folded) catch {
            gpa.free(folded);
            r.deinit();
            gpa.destroy(r);
            return null;
        };
        gpa.free(folded);
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

/// Trim whitespace from the left (Unicode-aware). Returns a new handle.
/// Handles all Unicode whitespace: U+00A0, U+2003, U+3000, etc.
pub fn stz_string_trim_left(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        var i: usize = 0;
        while (i < src.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(src[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(src, i, cp_len);
            if (unicode.stz_unicode_is_space(cp_val) == 0) break;
            i += cp_len;
        }
        return stz_string_from(src[i..].ptr, src.len - i);
    }
    return stz_string_new();
}

/// Trim whitespace from the right (Unicode-aware). Returns a new handle.
/// Handles all Unicode whitespace: U+00A0, U+2003, U+3000, etc.
pub fn stz_string_trim_right(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        var end: usize = src.len;
        while (end > 0) {
            // Walk backwards to find codepoint start
            var back = end - 1;
            while (back > 0 and (src[back] & 0xC0) == 0x80) back -= 1;
            const cp_len = std.unicode.utf8ByteSequenceLength(src[back]) catch 1;
            const cp_val: i32 = decodeCodepoint(src, back, cp_len);
            if (unicode.stz_unicode_is_space(cp_val) == 0) break;
            end = back;
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
/// Uses Unicode case folding via utf8proc for correctness.
pub fn stz_string_equals_ci(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    if (h1) |s1| {
        if (h2) |s2| {
            return if (ciEqlUnicode(s1.slice(), s2.slice())) 1 else 0;
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
/// Uses Unicode case folding via utf8proc for correctness.
pub fn stz_string_find_nth_ci(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, n: c_int) callconv(.c) i64 {
    if (handle) |s| {
        if (n < 1) return -1;
        const hay = s.slice();
        const ndl = needle[0..needle_len];
        // Case-fold both (Unicode-correct)
        const hay_folded = casefoldAlloc(hay) orelse return -1;
        defer gpa.free(hay_folded);
        const ndl_folded = casefoldAlloc(ndl) orelse return -1;
        defer gpa.free(ndl_folded);
        var occurrence: c_int = 0;
        var byte_pos: usize = 0;
        while (mem.indexOfPos(u8, hay_folded, byte_pos, ndl_folded)) |pos| {
            occurrence += 1;
            if (occurrence == n) {
                return @intCast(byteOffsetToCodepointIndex(hay_folded, pos));
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
    // "H3ll0 W0rld!" -> letters: H, l, l, W, r, l, d = 7
    try std.testing.expectEqual(@as(usize, 7), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..7], "HllWrld"));
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

// batch 9 ─────────────────────────────────────────────────────────

/// Sort words alphabetically (case-sensitive). Words separated by spaces.
pub export fn stz_string_sort_words(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;

    // Collect word boundaries
    var words: [256][2]usize = undefined; // [start, end] pairs, max 256 words
    var word_count: usize = 0;
    var i: usize = 0;
    while (i < src.len and word_count < 256) {
        // Skip spaces
        while (i < src.len and src[i] == ' ') : (i += 1) {}
        if (i >= src.len) break;
        const start = i;
        while (i < src.len and src[i] != ' ') : (i += 1) {}
        words[word_count] = .{ start, i };
        word_count += 1;
    }

    // Simple insertion sort on words
    var j: usize = 1;
    while (j < word_count) : (j += 1) {
        const key = words[j];
        var k: usize = j;
        while (k > 0) {
            const w_k = src[words[k - 1][0]..words[k - 1][1]];
            const w_key = src[key[0]..key[1]];
            if (mem.order(u8, w_k, w_key) == .gt) {
                words[k] = words[k - 1];
                k -= 1;
            } else break;
        }
        words[k] = key;
    }

    // Build result
    for (0..word_count) |idx| {
        if (idx > 0) result.data.appendSlice(gpa, " ") catch break;
        result.data.appendSlice(gpa, src[words[idx][0]..words[idx][1]]) catch break;
    }
    return result;
}

/// Keep only unique words (first occurrence preserved). Words separated by spaces.
pub export fn stz_string_unique_words(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;

    // Collect words and track seen
    var seen_starts: [256]usize = undefined;
    var seen_ends: [256]usize = undefined;
    var seen_count: usize = 0;
    var first = true;

    var ii: usize = 0;
    while (ii < src.len) {
        while (ii < src.len and src[ii] == ' ') : (ii += 1) {}
        if (ii >= src.len) break;
        const start = ii;
        while (ii < src.len and src[ii] != ' ') : (ii += 1) {}
        const word = src[start..ii];

        // Check if already seen
        var found = false;
        for (0..seen_count) |si| {
            if (mem.eql(u8, src[seen_starts[si]..seen_ends[si]], word)) {
                found = true;
                break;
            }
        }
        if (!found) {
            if (!first) result.data.appendSlice(gpa, " ") catch break;
            result.data.appendSlice(gpa, word) catch break;
            if (seen_count < 256) {
                seen_starts[seen_count] = start;
                seen_ends[seen_count] = ii;
                seen_count += 1;
            }
            first = false;
        }
    }
    return result;
}

/// Decode binary representation (space-separated 8-bit groups) back to string.
pub export fn stz_string_from_binary(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;

    var ii: usize = 0;
    while (ii < src.len) {
        // Skip spaces
        while (ii < src.len and src[ii] == ' ') : (ii += 1) {}
        if (ii >= src.len) break;
        // Read 8 binary digits
        if (ii + 8 > src.len) break;
        var byte: u8 = 0;
        var valid = true;
        for (0..8) |bit| {
            if (src[ii + bit] == '1') {
                byte |= @as(u8, 1) << @intCast(7 - bit);
            } else if (src[ii + bit] != '0') {
                valid = false;
                break;
            }
        }
        if (!valid) break;
        result.data.appendSlice(gpa, &[_]u8{byte}) catch break;
        ii += 8;
    }
    return result;
}

/// Swap two words at given 0-based indices. Words separated by spaces.
pub export fn stz_string_swap_words(handle: ?*StzString, idx1: c_int, idx2: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    const pos1: usize = if (idx1 >= 0) @intCast(idx1) else return result;
    const pos2: usize = if (idx2 >= 0) @intCast(idx2) else return result;

    // Collect words
    var word_starts: [256]usize = undefined;
    var word_ends: [256]usize = undefined;
    var word_count: usize = 0;

    var ii: usize = 0;
    while (ii < src.len and word_count < 256) {
        while (ii < src.len and src[ii] == ' ') : (ii += 1) {}
        if (ii >= src.len) break;
        word_starts[word_count] = ii;
        while (ii < src.len and src[ii] != ' ') : (ii += 1) {}
        word_ends[word_count] = ii;
        word_count += 1;
    }

    if (pos1 >= word_count or pos2 >= word_count) {
        // Out of bounds, return original
        result.data.appendSlice(gpa, src) catch {};
        return result;
    }

    // Build result with swapped words
    for (0..word_count) |idx| {
        if (idx > 0) result.data.appendSlice(gpa, " ") catch break;
        const w_idx = if (idx == pos1) pos2 else if (idx == pos2) pos1 else idx;
        result.data.appendSlice(gpa, src[word_starts[w_idx]..word_ends[w_idx]]) catch break;
    }
    return result;
}

/// Simple pig latin: move leading consonants to end + "ay". Vowel-starting words get "yay".
pub export fn stz_string_to_pig_latin(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    const vowels = "aeiouAEIOU";

    var first_word = true;
    var ii: usize = 0;
    while (ii < src.len) {
        // Skip/copy spaces
        if (src[ii] == ' ') {
            result.data.appendSlice(gpa, " ") catch break;
            ii += 1;
            continue;
        }

        if (!first_word) {} // spaces already handled
        first_word = false;

        // Find word boundaries
        const word_start = ii;
        while (ii < src.len and src[ii] != ' ') : (ii += 1) {}
        const word = src[word_start..ii];

        // Check if first char is vowel
        var is_vowel_start = false;
        for (vowels) |v| {
            if (word[0] == v) {
                is_vowel_start = true;
                break;
            }
        }

        if (is_vowel_start) {
            result.data.appendSlice(gpa, word) catch break;
            result.data.appendSlice(gpa, "yay") catch break;
        } else {
            // Find first vowel position
            var vowel_pos: usize = word.len;
            for (word, 0..) |c, ci| {
                for (vowels) |v| {
                    if (c == v) {
                        vowel_pos = ci;
                        break;
                    }
                }
                if (vowel_pos != word.len) break;
            }
            if (vowel_pos == word.len) {
                // No vowel, just append + "ay"
                result.data.appendSlice(gpa, word) catch break;
                result.data.appendSlice(gpa, "ay") catch break;
            } else {
                result.data.appendSlice(gpa, word[vowel_pos..]) catch break;
                result.data.appendSlice(gpa, word[0..vowel_pos]) catch break;
                result.data.appendSlice(gpa, "ay") catch break;
            }
        }
    }
    return result;
}

// batch 10 ────────────────────────────────────────────────────────

/// Run-length encode: "aaabbc" -> "3a2b1c"
pub export fn stz_string_run_length_encode(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    if (src.len == 0) return result;

    var i: usize = 0;
    while (i < src.len) {
        const ch = src[i];
        var count: usize = 1;
        while (i + count < src.len and src[i + count] == ch) : (count += 1) {}
        // Write count as digits
        var buf: [20]u8 = undefined;
        var digits: usize = 0;
        var n = count;
        while (n > 0) {
            buf[digits] = @intCast('0' + (n % 10));
            digits += 1;
            n /= 10;
        }
        // Reverse digits into result
        var d: usize = digits;
        while (d > 0) {
            d -= 1;
            result.data.appendSlice(gpa, &[_]u8{buf[d]}) catch break;
        }
        result.data.appendSlice(gpa, &[_]u8{ch}) catch break;
        i += count;
    }
    return result;
}

/// Run-length decode: "3a2b1c" -> "aaabbc"
pub export fn stz_string_run_length_decode(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;

    var i: usize = 0;
    while (i < src.len) {
        // Parse number
        var count: usize = 0;
        while (i < src.len and src[i] >= '0' and src[i] <= '9') {
            count = count * 10 + (src[i] - '0');
            i += 1;
        }
        if (count == 0) count = 1;
        if (i >= src.len) break;
        const ch = src[i];
        i += 1;
        for (0..count) |_| {
            result.data.appendSlice(gpa, &[_]u8{ch}) catch break;
        }
    }
    return result;
}

/// Count paragraphs (separated by double newlines \n\n).
pub export fn stz_string_count_paragraphs(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var count: c_int = 1;
    var i: usize = 0;
    while (i + 1 < src.len) {
        if (src[i] == '\n' and src[i + 1] == '\n') {
            count += 1;
            // Skip any additional consecutive newlines
            while (i + 1 < src.len and src[i + 1] == '\n') : (i += 1) {}
        }
        i += 1;
    }
    return count;
}

/// Zigzag cipher encode with n rails.
pub export fn stz_string_zigzag(handle: ?*StzString, rails: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    const n: usize = if (rails >= 2) @intCast(rails) else {
        result.data.appendSlice(gpa, src) catch {};
        return result;
    };
    if (src.len == 0) return result;

    // Build rail contents
    const cycle = 2 * (n - 1);
    var rail: usize = 0;
    while (rail < n) : (rail += 1) {
        var i: usize = 0;
        while (i < src.len) {
            // Determine which rail this index belongs to
            const pos_in_cycle = i % cycle;
            const r = if (pos_in_cycle < n) pos_in_cycle else cycle - pos_in_cycle;
            if (r == rail) {
                result.data.appendSlice(gpa, &[_]u8{src[i]}) catch break;
            }
            i += 1;
        }
    }
    return result;
}

/// Convert text to Morse code (ASCII letters and digits only, space-separated, / for word breaks).
pub export fn stz_string_to_morse(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;

    const morse_table = [_][]const u8{
        ".-", "-...", "-.-.", "-..", ".", "..-.", "--.", "....", "..", // a-i
        ".---", "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.", // j-r
        "...", "-", "..-", "...-", ".--", "-..-", "-.--", "--..", // s-z
    };
    const digit_table = [_][]const u8{
        "-----", ".----", "..---", "...--", "....-", // 0-4
        ".....", "-....", "--...", "---..", "----.", // 5-9
    };

    var first = true;
    for (src) |c| {
        if (c == ' ') {
            result.data.appendSlice(gpa, " / ") catch break;
            first = true;
            continue;
        }
        const code: ?[]const u8 = if (c >= 'a' and c <= 'z')
            morse_table[c - 'a']
        else if (c >= 'A' and c <= 'Z')
            morse_table[c - 'A']
        else if (c >= '0' and c <= '9')
            digit_table[c - '0']
        else
            null;

        if (code) |morse| {
            if (!first) result.data.appendSlice(gpa, " ") catch break;
            result.data.appendSlice(gpa, morse) catch break;
            first = false;
        }
    }
    return result;
}

// batch 11 ────────────────────────────────────────────────────────

const base64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/// Base64 encode.
pub export fn stz_string_to_base64(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;

    var i: usize = 0;
    while (i < src.len) {
        const b0: u32 = src[i];
        const b1: u32 = if (i + 1 < src.len) src[i + 1] else 0;
        const b2: u32 = if (i + 2 < src.len) src[i + 2] else 0;
        const triple = (b0 << 16) | (b1 << 8) | b2;

        result.data.appendSlice(gpa, &[_]u8{base64_chars[@intCast((triple >> 18) & 0x3F)]}) catch break;
        result.data.appendSlice(gpa, &[_]u8{base64_chars[@intCast((triple >> 12) & 0x3F)]}) catch break;
        if (i + 1 < src.len) {
            result.data.appendSlice(gpa, &[_]u8{base64_chars[@intCast((triple >> 6) & 0x3F)]}) catch break;
        } else {
            result.data.appendSlice(gpa, "=") catch break;
        }
        if (i + 2 < src.len) {
            result.data.appendSlice(gpa, &[_]u8{base64_chars[@intCast(triple & 0x3F)]}) catch break;
        } else {
            result.data.appendSlice(gpa, "=") catch break;
        }
        i += 3;
    }
    return result;
}

/// Base64 decode.
pub export fn stz_string_from_base64(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;

    var i: usize = 0;
    while (i + 3 < src.len) {
        const c0 = base64Decode(src[i]);
        const c1 = base64Decode(src[i + 1]);
        const c2 = base64Decode(src[i + 2]);
        const c3 = base64Decode(src[i + 3]);
        if (c0 == 255 or c1 == 255) break;

        const byte0: u8 = @intCast((c0 << 2) | (c1 >> 4));
        result.data.appendSlice(gpa, &[_]u8{byte0}) catch break;

        if (c2 != 255) {
            const byte1: u8 = @intCast(((c1 & 0x0F) << 4) | (c2 >> 2));
            result.data.appendSlice(gpa, &[_]u8{byte1}) catch break;
        }
        if (c3 != 255) {
            const byte2: u8 = @intCast(((c2 & 0x03) << 6) | c3);
            result.data.appendSlice(gpa, &[_]u8{byte2}) catch break;
        }
        i += 4;
    }
    return result;
}

fn base64Decode(c: u8) u8 {
    if (c >= 'A' and c <= 'Z') return c - 'A';
    if (c >= 'a' and c <= 'z') return c - 'a' + 26;
    if (c >= '0' and c <= '9') return c - '0' + 52;
    if (c == '+') return 62;
    if (c == '/') return 63;
    return 255; // padding or invalid
}

/// XOR cipher: XOR each byte with key byte.
pub export fn stz_string_xor_cipher(handle: ?*StzString, key: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    const k: u8 = @intCast(key & 0xFF);

    for (src) |c| {
        result.data.appendSlice(gpa, &[_]u8{c ^ k}) catch break;
    }
    return result;
}

/// Shannon entropy * 100 (integer, to avoid floating point in C API). 0 for empty.
pub export fn stz_string_entropy(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    // Count frequencies
    var freq: [256]u32 = [_]u32{0} ** 256;
    for (src) |c| {
        freq[c] += 1;
    }

    // Calculate entropy: -sum(p * log2(p)) where p = freq/len
    // Use integer math: entropy*100 = -100 * sum(freq/len * log2(freq/len))
    // Approximation using integer log2 table
    var entropy_x1000: i64 = 0;
    const len_f: f64 = @floatFromInt(src.len);
    for (freq) |f| {
        if (f > 0) {
            const p: f64 = @as(f64, @floatFromInt(f)) / len_f;
            const log2p: f64 = @log2(p);
            entropy_x1000 -= @intFromFloat(p * log2p * 1000.0);
        }
    }
    // Return entropy * 100 (divide by 10 from *1000)
    return @intCast(@divTrunc(entropy_x1000, 10));
}

/// Return the most frequent character as a single-char string. Ties: first in byte order.
pub export fn stz_string_char_frequency_top(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    if (src.len == 0) return result;

    var freq: [256]u32 = [_]u32{0} ** 256;
    for (src) |c| {
        freq[c] += 1;
    }

    var max_idx: u8 = 0;
    var max_count: u32 = 0;
    for (0..256) |idx| {
        if (freq[idx] > max_count) {
            max_count = freq[idx];
            max_idx = @intCast(idx);
        }
    }
    result.data.appendSlice(gpa, &[_]u8{max_idx}) catch {};
    return result;
}

// batch 12 ────────────────────────────────────────────────────────

/// Jaccard similarity of character sets (unique chars) * 100. Two handles.
pub export fn stz_string_jaccard_similarity(h1: ?*StzString, h2: ?*StzString) callconv(.c) c_int {
    const s1 = h1 orelse return 0;
    const s2 = h2 orelse return 0;
    const src1 = s1.slice();
    const src2 = s2.slice();

    // Build char sets (ASCII only for speed)
    var set1: [256]bool = [_]bool{false} ** 256;
    var set2: [256]bool = [_]bool{false} ** 256;
    for (src1) |c| set1[c] = true;
    for (src2) |c| set2[c] = true;

    var intersection: u32 = 0;
    var union_count: u32 = 0;
    for (0..256) |i| {
        if (set1[i] or set2[i]) union_count += 1;
        if (set1[i] and set2[i]) intersection += 1;
    }
    if (union_count == 0) return 100; // both empty = identical
    return @intCast((intersection * 100) / union_count);
}

/// Longest common prefix between two handles.
pub export fn stz_string_longest_common_prefix(h1: ?*StzString, h2: ?*StzString) callconv(.c) ?*StzString {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const src1 = s1.slice();
    const src2 = s2.slice();
    const result = stz_string_new() orelse return null;

    const min_len = if (src1.len < src2.len) src1.len else src2.len;
    var i: usize = 0;
    while (i < min_len and src1[i] == src2[i]) : (i += 1) {}
    result.data.appendSlice(gpa, src1[0..i]) catch {};
    return result;
}

/// Longest common suffix between two handles.
pub export fn stz_string_longest_common_suffix(h1: ?*StzString, h2: ?*StzString) callconv(.c) ?*StzString {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const src1 = s1.slice();
    const src2 = s2.slice();
    const result = stz_string_new() orelse return null;

    const min_len = if (src1.len < src2.len) src1.len else src2.len;
    var i: usize = 0;
    while (i < min_len and src1[src1.len - 1 - i] == src2[src2.len - 1 - i]) : (i += 1) {}
    if (i > 0) result.data.appendSlice(gpa, src1[src1.len - i ..]) catch {};
    return result;
}

/// Wrap string with prefix and suffix: wrap("hello", "[", "]") -> "[hello]"
pub export fn stz_string_wrap_with(handle: ?*StzString, prefix: [*c]const u8, prefix_len: c_int, suffix: [*c]const u8, suffix_len: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    const plen: usize = if (prefix_len >= 0) @intCast(prefix_len) else 0;
    const slen: usize = if (suffix_len >= 0) @intCast(suffix_len) else 0;

    result.data.appendSlice(gpa, prefix[0..plen]) catch {};
    result.data.appendSlice(gpa, src) catch {};
    result.data.appendSlice(gpa, suffix[0..slen]) catch {};
    return result;
}

/// Strict title case: capitalize first letter of every word (unlike smart which skips small words).
pub export fn stz_string_to_title_case_strict(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;

    var word_start = true;
    for (src) |c| {
        if (c == ' ' or c == '\t' or c == '\n') {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            word_start = true;
        } else if (word_start) {
            if (c >= 'a' and c <= 'z') {
                result.data.appendSlice(gpa, &[_]u8{c - 32}) catch break;
            } else {
                result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            }
            word_start = false;
        } else {
            if (c >= 'A' and c <= 'Z') {
                result.data.appendSlice(gpa, &[_]u8{c + 32}) catch break;
            } else {
                result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            }
        }
    }
    return result;
}

// batch 13 ────────────────────────────────────────────────────────

/// Hamming weight: count of 1-bits across all bytes.
pub export fn stz_string_hamming_weight(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |byte| {
        var b = byte;
        while (b != 0) {
            count += 1;
            b &= b - 1; // clear lowest set bit
        }
    }
    return count;
}

/// Is palindrome at word level: "dog cat dog" -> true (words reversed = same sequence).
pub export fn stz_string_is_palindrome_words(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 1;

    // Collect word boundaries
    var starts: [256]usize = undefined;
    var ends: [256]usize = undefined;
    var wc: usize = 0;

    var i: usize = 0;
    while (i < src.len and wc < 256) {
        while (i < src.len and src[i] == ' ') : (i += 1) {}
        if (i >= src.len) break;
        starts[wc] = i;
        while (i < src.len and src[i] != ' ') : (i += 1) {}
        ends[wc] = i;
        wc += 1;
    }
    if (wc <= 1) return 1;

    // Compare word[j] with word[wc-1-j]
    var j: usize = 0;
    while (j < wc / 2) : (j += 1) {
        const w1 = src[starts[j]..ends[j]];
        const w2 = src[starts[wc - 1 - j]..ends[wc - 1 - j]];
        if (!mem.eql(u8, w1, w2)) return 0;
    }
    return 1;
}

/// Remove the nth word (0-based). Words separated by spaces.
pub export fn stz_string_remove_nth_word(handle: ?*StzString, n: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    const target: usize = if (n >= 0) @intCast(n) else {
        result.data.appendSlice(gpa, src) catch {};
        return result;
    };

    var starts: [256]usize = undefined;
    var ends_arr: [256]usize = undefined;
    var wc: usize = 0;

    var i: usize = 0;
    while (i < src.len and wc < 256) {
        while (i < src.len and src[i] == ' ') : (i += 1) {}
        if (i >= src.len) break;
        starts[wc] = i;
        while (i < src.len and src[i] != ' ') : (i += 1) {}
        ends_arr[wc] = i;
        wc += 1;
    }

    if (target >= wc) {
        result.data.appendSlice(gpa, src) catch {};
        return result;
    }

    // Build result skipping word at target index
    var first = true;
    for (0..wc) |idx| {
        if (idx == target) continue;
        if (!first) result.data.appendSlice(gpa, " ") catch break;
        result.data.appendSlice(gpa, src[starts[idx]..ends_arr[idx]]) catch break;
        first = false;
    }
    return result;
}

/// Insert a word at position n (0-based). Words separated by spaces.
pub export fn stz_string_insert_word_at(handle: ?*StzString, n: c_int, word: [*c]const u8, word_len: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    const target: usize = if (n >= 0) @intCast(n) else 0;
    const wlen: usize = if (word_len >= 0) @intCast(word_len) else 0;

    // Collect existing words
    var starts: [256]usize = undefined;
    var ends_arr: [256]usize = undefined;
    var wc: usize = 0;

    var i: usize = 0;
    while (i < src.len and wc < 256) {
        while (i < src.len and src[i] == ' ') : (i += 1) {}
        if (i >= src.len) break;
        starts[wc] = i;
        while (i < src.len and src[i] != ' ') : (i += 1) {}
        ends_arr[wc] = i;
        wc += 1;
    }

    // Build result inserting new word at position
    var first = true;
    var idx: usize = 0;
    const insert_pos = if (target > wc) wc else target;

    while (idx <= wc) : (idx += 1) {
        if (idx == insert_pos) {
            if (!first) result.data.appendSlice(gpa, " ") catch break;
            result.data.appendSlice(gpa, word[0..wlen]) catch break;
            first = false;
        }
        if (idx < wc) {
            if (!first) result.data.appendSlice(gpa, " ") catch break;
            result.data.appendSlice(gpa, src[starts[idx]..ends_arr[idx]]) catch break;
            first = false;
        }
    }
    return result;
}

/// Spongebob case: alternating case starting with UPPER (opposite of alternating_case which starts lower).
pub export fn stz_string_to_spongebob_case(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;

    var letter_idx: usize = 0;
    for (src) |c| {
        if ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z')) {
            if (letter_idx % 2 == 0) {
                // Upper
                if (c >= 'a' and c <= 'z') {
                    result.data.appendSlice(gpa, &[_]u8{c - 32}) catch break;
                } else {
                    result.data.appendSlice(gpa, &[_]u8{c}) catch break;
                }
            } else {
                // Lower
                if (c >= 'A' and c <= 'Z') {
                    result.data.appendSlice(gpa, &[_]u8{c + 32}) catch break;
                } else {
                    result.data.appendSlice(gpa, &[_]u8{c}) catch break;
                }
            }
            letter_idx += 1;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

// batch 14 ────────────────────────────────────────────────────────

/// Extract text between first occurrence of open and close delimiters.
pub export fn stz_string_between_first(handle: ?*StzString, open: [*c]const u8, open_len: c_int, close: [*c]const u8, close_len: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    const olen: usize = if (open_len >= 0) @intCast(open_len) else return result;
    const clen: usize = if (close_len >= 0) @intCast(close_len) else return result;
    if (olen == 0 or clen == 0) return result;

    // Find first open
    var i: usize = 0;
    while (i + olen <= src.len) {
        if (mem.eql(u8, src[i .. i + olen], open[0..olen])) {
            const start = i + olen;
            // Find close after open
            var j: usize = start;
            while (j + clen <= src.len) {
                if (mem.eql(u8, src[j .. j + clen], close[0..clen])) {
                    result.data.appendSlice(gpa, src[start..j]) catch {};
                    return result;
                }
                j += 1;
            }
            return result; // no close found
        }
        i += 1;
    }
    return result;
}

/// Convert camelCase/PascalCase to dot.case.
pub export fn stz_string_to_dot_case(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;

    var prev_sep = false;
    for (src, 0..) |c, idx| {
        if (c >= 'A' and c <= 'Z') {
            if (idx > 0 and !prev_sep) result.data.appendSlice(gpa, ".") catch break;
            result.data.appendSlice(gpa, &[_]u8{c + 32}) catch break;
            prev_sep = false;
        } else if (c == '_' or c == '-' or c == ' ') {
            if (!prev_sep and idx > 0) result.data.appendSlice(gpa, ".") catch break;
            prev_sep = true;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            prev_sep = false;
        }
    }
    return result;
}

/// Abbreviate: produce a string of at most max_len total characters.
/// If the string is longer, truncate to (max_len - 3) characters + "...".
/// If max_len <= 3, just return "..." truncated to max_len.
pub export fn stz_string_abbreviate(handle: ?*StzString, max_len: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    const limit: usize = if (max_len >= 0) @intCast(max_len) else return result;

    // Count total codepoints
    const cp_count = utf8CodepointCount(src);

    if (cp_count <= limit) {
        result.data.appendSlice(gpa, src) catch {};
    } else {
        // Truncate to (limit - 3) codepoints + "..."
        const text_len: usize = if (limit >= 3) limit - 3 else 0;
        var off: usize = 0;
        var cp_idx: usize = 0;
        while (off < src.len and cp_idx < text_len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
            if (off + cp_len > src.len) break;
            off += cp_len;
            cp_idx += 1;
        }
        result.data.appendSlice(gpa, src[0..off]) catch {};
        result.data.appendSlice(gpa, "...") catch {};
    }
    return result;
}

/// Count non-overlapping occurrences of a substring.
pub export fn stz_string_count_substring(handle: ?*StzString, needle: [*c]const u8, needle_len: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    const nlen: usize = if (needle_len > 0) @intCast(needle_len) else return 0;
    const ndl = needle[0..nlen];

    var count: c_int = 0;
    var i: usize = 0;
    while (i + nlen <= src.len) {
        if (mem.eql(u8, src[i .. i + nlen], ndl)) {
            count += 1;
            i += nlen;
        } else {
            i += 1;
        }
    }
    return count;
}

/// Convert camelCase/PascalCase to path/case (slash-separated).
pub export fn stz_string_to_path_case(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;

    var prev_sep = false;
    for (src, 0..) |c, idx| {
        if (c >= 'A' and c <= 'Z') {
            if (idx > 0 and !prev_sep) result.data.appendSlice(gpa, "/") catch break;
            result.data.appendSlice(gpa, &[_]u8{c + 32}) catch break;
            prev_sep = false;
        } else if (c == '_' or c == '-' or c == ' ') {
            if (!prev_sep and idx > 0) result.data.appendSlice(gpa, "/") catch break;
            prev_sep = true;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            prev_sep = false;
        }
    }
    return result;
}

// ─── Batch 15: left_pad, right_pad, is_numeric, is_alpha, is_alphanumeric ───

pub export fn stz_string_left_pad(handle: ?*StzString, width: c_int, pad_char: u8) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const w: usize = if (width < 0) 0 else @intCast(width);
    const result = stz_string_new() orelse return null;
    if (src.len >= w) {
        result.data.appendSlice(gpa, src) catch {};
        return result;
    }
    const pad_count = w - src.len;
    var i: usize = 0;
    while (i < pad_count) : (i += 1) {
        result.data.appendSlice(gpa, &[_]u8{pad_char}) catch break;
    }
    result.data.appendSlice(gpa, src) catch {};
    return result;
}

pub export fn stz_string_right_pad(handle: ?*StzString, width: c_int, pad_char: u8) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const w: usize = if (width < 0) 0 else @intCast(width);
    const result = stz_string_new() orelse return null;
    result.data.appendSlice(gpa, src) catch {};
    if (src.len >= w) return result;
    const pad_count = w - src.len;
    var i: usize = 0;
    while (i < pad_count) : (i += 1) {
        result.data.appendSlice(gpa, &[_]u8{pad_char}) catch break;
    }
    return result;
}

pub export fn stz_string_to_hex(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    const hex_chars = "0123456789abcdef";
    for (src) |c| {
        result.data.appendSlice(gpa, &[_]u8{ hex_chars[c >> 4], hex_chars[c & 0x0f] }) catch break;
    }
    return result;
}

pub export fn stz_string_from_hex(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    var i: usize = 0;
    while (i + 1 < src.len) : (i += 2) {
        const hi = hexCharToVal(src[i]) orelse break;
        const lo = hexCharToVal(src[i + 1]) orelse break;
        result.data.appendSlice(gpa, &[_]u8{(hi << 4) | lo}) catch break;
    }
    return result;
}

fn hexCharToVal(c: u8) ?u8 {
    if (c >= '0' and c <= '9') return c - '0';
    if (c >= 'a' and c <= 'f') return c - 'a' + 10;
    if (c >= 'A' and c <= 'F') return c - 'A' + 10;
    return null;
}

pub export fn stz_string_soundex(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    if (src.len == 0) return result;
    // First letter uppercase
    const first: u8 = if (src[0] >= 'a' and src[0] <= 'z') src[0] - 32 else src[0];
    result.data.appendSlice(gpa, &[_]u8{first}) catch return result;
    const map = [26]u8{ '0', '1', '2', '3', '0', '1', '2', '0', '0', '2', '2', '4', '5', '5', '0', '1', '2', '6', '2', '3', '0', '1', '0', '2', '0', '2' };
    var count: usize = 1;
    var last_code: u8 = soundexCode(first, &map);
    var idx: usize = 1;
    while (idx < src.len and count < 4) : (idx += 1) {
        const c = src[idx];
        const code = soundexCode(c, &map);
        if (code != '0' and code != last_code) {
            result.data.appendSlice(gpa, &[_]u8{code}) catch break;
            count += 1;
        }
        if (code != '0') last_code = code;
    }
    while (count < 4) : (count += 1) {
        result.data.appendSlice(gpa, &[_]u8{'0'}) catch break;
    }
    return result;
}

fn soundexCode(c: u8, map: *const [26]u8) u8 {
    if (c >= 'a' and c <= 'z') return map[c - 'a'];
    if (c >= 'A' and c <= 'Z') return map[c - 'A'];
    return '0';
}

// ─── Batch 16: vigenere_encrypt, atbash, count_words_matching, truncate_words, to_constant_case ───

pub export fn stz_string_vigenere_encrypt(handle: ?*StzString, key_ptr: [*c]const u8, key_len: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const klen: usize = if (key_len < 1) return null else @intCast(key_len);
    const key = key_ptr[0..klen];
    const result = stz_string_new() orelse return null;
    var ki: usize = 0;
    for (src) |c| {
        if (c >= 'a' and c <= 'z') {
            var k = key[ki % klen];
            if (k >= 'A' and k <= 'Z') k += 32;
            if (k >= 'a' and k <= 'z') {
                const shift: u8 = k - 'a';
                const enc: u8 = 'a' + @as(u8, @intCast((@as(u16, c - 'a') + shift) % 26));
                result.data.appendSlice(gpa, &[_]u8{enc}) catch break;
            } else {
                result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            }
            ki += 1;
        } else if (c >= 'A' and c <= 'Z') {
            var k = key[ki % klen];
            if (k >= 'A' and k <= 'Z') k += 32;
            if (k >= 'a' and k <= 'z') {
                const shift: u8 = k - 'a';
                const enc: u8 = 'A' + @as(u8, @intCast((@as(u16, c - 'A') + shift) % 26));
                result.data.appendSlice(gpa, &[_]u8{enc}) catch break;
            } else {
                result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            }
            ki += 1;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

pub export fn stz_string_atbash(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    for (src) |c| {
        if (c >= 'a' and c <= 'z') {
            result.data.appendSlice(gpa, &[_]u8{'z' - (c - 'a')}) catch break;
        } else if (c >= 'A' and c <= 'Z') {
            result.data.appendSlice(gpa, &[_]u8{'Z' - (c - 'A')}) catch break;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

pub export fn stz_string_count_words_matching(handle: ?*StzString, pattern_ptr: [*c]const u8, pattern_len: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    const plen: usize = if (pattern_len < 1) return 0 else @intCast(pattern_len);
    const pattern = pattern_ptr[0..plen];
    var count: c_int = 0;
    var pos: usize = 0;
    while (pos < src.len) {
        // skip spaces
        while (pos < src.len and src[pos] == ' ') pos += 1;
        if (pos >= src.len) break;
        const start = pos;
        while (pos < src.len and src[pos] != ' ') pos += 1;
        const word = src[start..pos];
        if (word.len == plen and mem.eql(u8, word, pattern)) count += 1;
    }
    return count;
}

pub export fn stz_string_truncate_words(handle: ?*StzString, max_words: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const max: usize = if (max_words < 1) 0 else @intCast(max_words);
    const result = stz_string_new() orelse return null;
    if (max == 0) return result;
    var word_count: usize = 0;
    var pos: usize = 0;
    var last_end: usize = 0;
    while (pos < src.len) {
        while (pos < src.len and src[pos] == ' ') pos += 1;
        if (pos >= src.len) break;
        if (word_count > 0) {
            // include the space before this word
        }
        const word_start = pos;
        _ = word_start;
        while (pos < src.len and src[pos] != ' ') pos += 1;
        word_count += 1;
        last_end = pos;
        if (word_count >= max) break;
    }
    if (last_end > 0) {
        // Find start: skip leading spaces
        var start: usize = 0;
        while (start < src.len and src[start] == ' ') start += 1;
        result.data.appendSlice(gpa, src[start..last_end]) catch {};
    }
    return result;
}

pub export fn stz_string_to_constant_case(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    var prev_was_sep = false;
    for (src, 0..) |c, idx| {
        if (c == ' ' or c == '-' or c == '\t') {
            if (!prev_was_sep and idx > 0) {
                result.data.appendSlice(gpa, &[_]u8{'_'}) catch break;
            }
            prev_was_sep = true;
        } else if (c >= 'a' and c <= 'z') {
            result.data.appendSlice(gpa, &[_]u8{c - 32}) catch break;
            prev_was_sep = false;
        } else if (c >= 'A' and c <= 'Z') {
            // Insert underscore before uppercase if preceded by lowercase
            if (idx > 0 and !prev_was_sep) {
                const prev = src[idx - 1];
                if (prev >= 'a' and prev <= 'z') {
                    result.data.appendSlice(gpa, &[_]u8{'_'}) catch break;
                }
            }
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            prev_was_sep = false;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            prev_was_sep = false;
        }
    }
    return result;
}

// ─── Batch 17: first_word, last_word, to_nato, commonality, diff_chars ───

pub export fn stz_string_first_word(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    var pos: usize = 0;
    while (pos < src.len and src[pos] == ' ') pos += 1;
    while (pos < src.len and src[pos] != ' ') {
        result.data.appendSlice(gpa, &[_]u8{src[pos]}) catch break;
        pos += 1;
    }
    return result;
}

pub export fn stz_string_last_word(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    if (src.len == 0) return result;
    var end: usize = src.len;
    while (end > 0 and src[end - 1] == ' ') end -= 1;
    if (end == 0) return result;
    var start: usize = end;
    while (start > 0 and src[start - 1] != ' ') start -= 1;
    result.data.appendSlice(gpa, src[start..end]) catch {};
    return result;
}

pub export fn stz_string_to_nato(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    const nato = [26][]const u8{ "Alfa", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet", "Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray", "Yankee", "Zulu" };
    var first = true;
    for (src) |c| {
        var idx: ?usize = null;
        if (c >= 'a' and c <= 'z') idx = c - 'a';
        if (c >= 'A' and c <= 'Z') idx = c - 'A';
        if (idx) |i| {
            if (!first) result.data.appendSlice(gpa, " ") catch {};
            result.data.appendSlice(gpa, nato[i]) catch {};
            first = false;
        } else if (c == ' ') {
            if (!first) result.data.appendSlice(gpa, " ") catch {};
            result.data.appendSlice(gpa, "[space]") catch {};
            first = false;
        }
    }
    return result;
}

pub export fn stz_string_commonality(handle: ?*StzString, other: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const o = other orelse return 0;
    const src = s.slice();
    const oth = o.slice();
    // Count chars present in both (based on set intersection)
    var seen_src = [_]bool{false} ** 256;
    for (src) |c| seen_src[c] = true;
    var count: c_int = 0;
    var seen_counted = [_]bool{false} ** 256;
    for (oth) |c| {
        if (seen_src[c] and !seen_counted[c]) {
            count += 1;
            seen_counted[c] = true;
        }
    }
    return count;
}

pub export fn stz_string_diff_chars(handle: ?*StzString, other: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const o = other orelse return null;
    const src = s.slice();
    const oth = o.slice();
    const result = stz_string_new() orelse return null;
    // Chars in src not in other (unique set)
    var in_other = [_]bool{false} ** 256;
    for (oth) |c| in_other[c] = true;
    var added = [_]bool{false} ** 256;
    for (src) |c| {
        if (!in_other[c] and !added[c]) {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            added[c] = true;
        }
    }
    return result;
}

// ─── Batch 18: rot47, is_isogram, reverse_each_word, count_digits, strip_tags ───

pub export fn stz_string_rot47(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    for (src) |c| {
        if (c >= 33 and c <= 126) {
            const rotated: u8 = 33 + ((c - 33 + 47) % 94);
            result.data.appendSlice(gpa, &[_]u8{rotated}) catch break;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

pub export fn stz_string_is_isogram(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 1;
    var seen = [_]bool{false} ** 256;
    for (src) |c| {
        var ch = c;
        if (ch >= 'A' and ch <= 'Z') ch += 32;
        if (ch >= 'a' and ch <= 'z') {
            if (seen[ch]) return 0;
            seen[ch] = true;
        }
    }
    return 1;
}

pub export fn stz_string_reverse_each_word(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    var pos: usize = 0;
    while (pos < src.len) {
        if (src[pos] == ' ') {
            result.data.appendSlice(gpa, &[_]u8{' '}) catch break;
            pos += 1;
        } else {
            const start = pos;
            while (pos < src.len and src[pos] != ' ') pos += 1;
            // Reverse the word
            var j: usize = pos;
            while (j > start) {
                j -= 1;
                result.data.appendSlice(gpa, &[_]u8{src[j]}) catch break;
            }
        }
    }
    return result;
}

pub export fn stz_string_count_digits(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c >= '0' and c <= '9') count += 1;
    }
    return count;
}

pub export fn stz_string_strip_tags(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    var in_tag = false;
    for (src) |c| {
        if (c == '<') {
            in_tag = true;
        } else if (c == '>') {
            in_tag = false;
        } else if (!in_tag) {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

// ─── Batch 19: to_slug, count_spaces, normalize_spaces, mask_email, pluralize ───

pub export fn stz_string_to_slug(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    var prev_was_dash = false;
    for (src) |c| {
        if (c >= 'A' and c <= 'Z') {
            result.data.appendSlice(gpa, &[_]u8{c + 32}) catch break;
            prev_was_dash = false;
        } else if ((c >= 'a' and c <= 'z') or (c >= '0' and c <= '9')) {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            prev_was_dash = false;
        } else if (c == ' ' or c == '_' or c == '-' or c == '\t') {
            if (!prev_was_dash) {
                result.data.appendSlice(gpa, &[_]u8{'-'}) catch break;
                prev_was_dash = true;
            }
        }
        // skip other chars
    }
    // Remove trailing dash
    const rslice = result.slice();
    if (rslice.len > 0 and rslice[rslice.len - 1] == '-') {
        _ = result.data.pop();
    }
    return result;
}

pub export fn stz_string_count_spaces(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c == ' ') count += 1;
    }
    return count;
}

pub export fn stz_string_normalize_spaces(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    var prev_space = true; // treat start as space to trim leading
    for (src) |c| {
        if (c == ' ' or c == '\t') {
            if (!prev_space) {
                result.data.appendSlice(gpa, &[_]u8{' '}) catch break;
                prev_space = true;
            }
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            prev_space = false;
        }
    }
    // Remove trailing space
    const rslice = result.slice();
    if (rslice.len > 0 and rslice[rslice.len - 1] == ' ') {
        _ = result.data.pop();
    }
    return result;
}

pub export fn stz_string_mask_email(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    // Find @ position
    var at_pos: ?usize = null;
    for (src, 0..) |c, idx| {
        if (c == '@') {
            at_pos = idx;
            break;
        }
    }
    if (at_pos) |ap| {
        if (ap > 0) {
            // Show first char, mask rest of local part
            result.data.appendSlice(gpa, &[_]u8{src[0]}) catch {};
            var i: usize = 1;
            while (i < ap) : (i += 1) {
                result.data.appendSlice(gpa, &[_]u8{'*'}) catch break;
            }
        }
        // Append @domain
        result.data.appendSlice(gpa, src[ap..]) catch {};
    } else {
        // No @, just copy
        result.data.appendSlice(gpa, src) catch {};
    }
    return result;
}

pub export fn stz_string_pluralize(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    if (src.len == 0) return result;
    result.data.appendSlice(gpa, src) catch return result;
    const last = src[src.len - 1];
    if (last == 's' or last == 'x' or last == 'z') {
        result.data.appendSlice(gpa, "es") catch {};
    } else if (last == 'y' and src.len > 1) {
        const prev = src[src.len - 2];
        if (!(prev == 'a' or prev == 'e' or prev == 'i' or prev == 'o' or prev == 'u')) {
            // Replace y with ies
            _ = result.data.pop();
            result.data.appendSlice(gpa, "ies") catch {};
        } else {
            result.data.appendSlice(gpa, "s") catch {};
        }
    } else if (src.len >= 2 and src[src.len - 2] == 'c' and last == 'h') {
        result.data.appendSlice(gpa, "es") catch {};
    } else if (src.len >= 2 and src[src.len - 2] == 's' and last == 'h') {
        result.data.appendSlice(gpa, "es") catch {};
    } else {
        result.data.appendSlice(gpa, "s") catch {};
    }
    return result;
}

// ─── Batch 20: deduplicate_lines, remove_blank_lines, extract_numbers, extract_emails, quote ───

pub export fn stz_string_deduplicate_lines(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    // Track seen lines — simple O(n^2) for correctness
    var line_starts: [1024]usize = undefined;
    var line_ends: [1024]usize = undefined;
    var line_count: usize = 0;
    // Parse lines
    var pos: usize = 0;
    var first = true;
    while (pos <= src.len and line_count < 1024) {
        const start = pos;
        while (pos < src.len and src[pos] != '\n') pos += 1;
        const end = pos;
        // Check if this line is a duplicate
        var is_dup = false;
        const line = src[start..end];
        for (0..line_count) |li| {
            const prev = src[line_starts[li]..line_ends[li]];
            if (prev.len == line.len and mem.eql(u8, prev, line)) {
                is_dup = true;
                break;
            }
        }
        if (!is_dup) {
            if (!first) result.data.appendSlice(gpa, "\n") catch {};
            result.data.appendSlice(gpa, line) catch {};
            line_starts[line_count] = start;
            line_ends[line_count] = end;
            line_count += 1;
            first = false;
        }
        if (pos < src.len) pos += 1 else break; // skip \n
    }
    return result;
}

pub export fn stz_string_remove_blank_lines(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    var pos: usize = 0;
    var first = true;
    while (pos <= src.len) {
        const start = pos;
        while (pos < src.len and src[pos] != '\n') pos += 1;
        const line = src[start..pos];
        // Check if line is blank (only spaces/tabs)
        var is_blank = true;
        for (line) |c| {
            if (c != ' ' and c != '\t' and c != '\r') {
                is_blank = false;
                break;
            }
        }
        if (!is_blank) {
            if (!first) result.data.appendSlice(gpa, "\n") catch {};
            result.data.appendSlice(gpa, line) catch {};
            first = false;
        }
        if (pos < src.len) pos += 1 else break;
    }
    return result;
}

pub export fn stz_string_extract_numbers(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    var pos: usize = 0;
    var first = true;
    while (pos < src.len) {
        if (src[pos] >= '0' and src[pos] <= '9') {
            const start = pos;
            while (pos < src.len and ((src[pos] >= '0' and src[pos] <= '9') or src[pos] == '.')) pos += 1;
            if (!first) result.data.appendSlice(gpa, " ") catch {};
            result.data.appendSlice(gpa, src[start..pos]) catch {};
            first = false;
        } else {
            pos += 1;
        }
    }
    return result;
}

pub export fn stz_string_extract_emails(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    // Simple extraction: find @ then scan backwards/forwards for valid chars
    var pos: usize = 0;
    var first = true;
    while (pos < src.len) {
        if (src[pos] == '@' and pos > 0) {
            // Scan back for local part
            var local_start = pos;
            while (local_start > 0) {
                const c = src[local_start - 1];
                if ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or (c >= '0' and c <= '9') or c == '.' or c == '_' or c == '-' or c == '+') {
                    local_start -= 1;
                } else break;
            }
            // Scan forward for domain
            var domain_end = pos + 1;
            var has_dot = false;
            while (domain_end < src.len) {
                const c = src[domain_end];
                if ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or (c >= '0' and c <= '9') or c == '.' or c == '-') {
                    if (c == '.') has_dot = true;
                    domain_end += 1;
                } else break;
            }
            if (local_start < pos and domain_end > pos + 1 and has_dot) {
                if (!first) result.data.appendSlice(gpa, " ") catch {};
                result.data.appendSlice(gpa, src[local_start..domain_end]) catch {};
                first = false;
                pos = domain_end;
            } else {
                pos += 1;
            }
        } else {
            pos += 1;
        }
    }
    return result;
}

pub export fn stz_string_quote(handle: ?*StzString, quote_char: u8) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    result.data.appendSlice(gpa, &[_]u8{quote_char}) catch {};
    result.data.appendSlice(gpa, src) catch {};
    result.data.appendSlice(gpa, &[_]u8{quote_char}) catch {};
    return result;
}

// ─── Batch 21: unquote, to_csv_field, number_lines, hide, extract_words ───

pub export fn stz_string_unquote(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    if (src.len < 2) {
        result.data.appendSlice(gpa, src) catch {};
        return result;
    }
    const first = src[0];
    const last = src[src.len - 1];
    if ((first == '"' and last == '"') or (first == '\'' and last == '\'') or (first == '`' and last == '`')) {
        result.data.appendSlice(gpa, src[1 .. src.len - 1]) catch {};
    } else {
        result.data.appendSlice(gpa, src) catch {};
    }
    return result;
}

pub export fn stz_string_to_csv_field(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    // Check if quoting needed (contains comma, quote, or newline)
    var needs_quote = false;
    for (src) |c| {
        if (c == ',' or c == '"' or c == '\n' or c == '\r') {
            needs_quote = true;
            break;
        }
    }
    if (!needs_quote) {
        result.data.appendSlice(gpa, src) catch {};
        return result;
    }
    result.data.appendSlice(gpa, "\"") catch {};
    for (src) |c| {
        if (c == '"') {
            result.data.appendSlice(gpa, "\"\"") catch break;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    result.data.appendSlice(gpa, "\"") catch {};
    return result;
}

pub export fn stz_string_number_lines(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    var line_num: usize = 1;
    var pos: usize = 0;
    while (pos <= src.len) {
        // Write line number
        var buf: [12]u8 = undefined;
        const num_len = formatUsize(line_num, &buf);
        result.data.appendSlice(gpa, buf[0..num_len]) catch {};
        result.data.appendSlice(gpa, ": ") catch {};
        // Write line content
        const start = pos;
        while (pos < src.len and src[pos] != '\n') pos += 1;
        result.data.appendSlice(gpa, src[start..pos]) catch {};
        if (pos < src.len) {
            result.data.appendSlice(gpa, "\n") catch {};
            pos += 1;
            line_num += 1;
        } else break;
    }
    return result;
}

fn formatUsize(val: usize, buf: *[12]u8) usize {
    if (val == 0) {
        buf[0] = '0';
        return 1;
    }
    var v = val;
    var len: usize = 0;
    while (v > 0) : (len += 1) {
        buf[11 - len] = '0' + @as(u8, @intCast(v % 10));
        v /= 10;
    }
    // Shift to start
    for (0..len) |i| {
        buf[i] = buf[12 - len + i];
    }
    return len;
}

pub export fn stz_string_hide(handle: ?*StzString, mask_char: u8, keep_first: c_int, keep_last: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    const kf: usize = if (keep_first < 0) 0 else @intCast(keep_first);
    const kl: usize = if (keep_last < 0) 0 else @intCast(keep_last);
    if (kf + kl >= src.len) {
        result.data.appendSlice(gpa, src) catch {};
        return result;
    }
    result.data.appendSlice(gpa, src[0..kf]) catch {};
    var i: usize = kf;
    while (i < src.len - kl) : (i += 1) {
        result.data.appendSlice(gpa, &[_]u8{mask_char}) catch break;
    }
    result.data.appendSlice(gpa, src[src.len - kl ..]) catch {};
    return result;
}

pub export fn stz_string_extract_words(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    var pos: usize = 0;
    var first = true;
    while (pos < src.len) {
        // Skip non-alpha
        while (pos < src.len and !((src[pos] >= 'a' and src[pos] <= 'z') or (src[pos] >= 'A' and src[pos] <= 'Z'))) pos += 1;
        if (pos >= src.len) break;
        const start = pos;
        while (pos < src.len and ((src[pos] >= 'a' and src[pos] <= 'z') or (src[pos] >= 'A' and src[pos] <= 'Z') or src[pos] == '\'')) pos += 1;
        if (!first) result.data.appendSlice(gpa, " ") catch {};
        result.data.appendSlice(gpa, src[start..pos]) catch {};
        first = false;
    }
    return result;
}

// ─── Batch 22: expand_tabs, sentence_count, chop, scan_int, to_ordinal ───

pub export fn stz_string_expand_tabs(handle: ?*StzString, tab_size: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const ts: usize = if (tab_size < 1) 4 else @intCast(tab_size);
    const result = stz_string_new() orelse return null;
    for (src) |c| {
        if (c == '\t') {
            var i: usize = 0;
            while (i < ts) : (i += 1) {
                result.data.appendSlice(gpa, " ") catch break;
            }
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

pub export fn stz_string_sentence_count(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c == '.' or c == '!' or c == '?') count += 1;
    }
    return count;
}

pub export fn stz_string_chop(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    if (src.len > 0) {
        result.data.appendSlice(gpa, src[0 .. src.len - 1]) catch {};
    }
    return result;
}

pub export fn stz_string_scan_int(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var val: c_int = 0;
    var neg = false;
    var started = false;
    for (src) |c| {
        if (!started and c == '-') {
            neg = true;
            started = true;
        } else if (c >= '0' and c <= '9') {
            val = val * 10 + @as(c_int, c - '0');
            started = true;
        } else if (started) break;
    }
    return if (neg) -val else val;
}

pub export fn stz_string_to_ordinal(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    result.data.appendSlice(gpa, src) catch return result;
    // Parse the number to determine suffix
    const num = stz_string_scan_int(s);
    const abs_num: u32 = if (num < 0) @intCast(-num) else @intCast(num);
    const last_two = abs_num % 100;
    const last_one = abs_num % 10;
    if (last_two >= 11 and last_two <= 13) {
        result.data.appendSlice(gpa, "th") catch {};
    } else if (last_one == 1) {
        result.data.appendSlice(gpa, "st") catch {};
    } else if (last_one == 2) {
        result.data.appendSlice(gpa, "nd") catch {};
    } else if (last_one == 3) {
        result.data.appendSlice(gpa, "rd") catch {};
    } else {
        result.data.appendSlice(gpa, "th") catch {};
    }
    return result;
}

// ─── cp_count: number of codepoints in the string ───

pub export fn stz_string_cp_count(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    return @intCast(utf8CodepointCount(src));
}

// ─── chars_split: split string into individual codepoint strings, null-separated ───
// Returns a new StzString containing codepoints separated by null bytes.

pub export fn stz_string_chars_split(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    var i: usize = 0;
    var first = true;
    while (i < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[i]) catch 1;
        const end = @min(i + cp_len, src.len);
        if (!first) {
            result.data.append(gpa, 0) catch break; // null separator
        }
        result.data.appendSlice(gpa, src[i..end]) catch break;
        first = false;
        i = end;
    }
    return result;
}

// batch 17 ─── NLP: Jaro-Winkler, Metaphone, N-grams ───

/// Jaro similarity between two strings. Returns value * 1000 (integer scaled).
/// Jaro similarity is a measure of similarity between two strings, useful for
/// fuzzy name matching in multilingual contexts.
pub export fn stz_string_jaro(h1: ?*StzString, h2: ?*StzString) callconv(.c) c_int {
    const s1 = h1 orelse return 0;
    const s2 = h2 orelse return 0;
    const a = s1.slice();
    const b = s2.slice();
    if (a.len == 0 and b.len == 0) return 1000; // identical empty
    if (a.len == 0 or b.len == 0) return 0;

    // Count codepoints
    const len_a = utf8CodepointCount(a);
    const len_b = utf8CodepointCount(b);
    if (len_a == 0 or len_b == 0) return 0;

    // Match window
    const max_len = if (len_a > len_b) len_a else len_b;
    const match_dist = if (max_len > 1) max_len / 2 - 1 else 0;

    // Collect codepoints from both strings
    var cps_a: [1024]i32 = undefined;
    var cps_b: [1024]i32 = undefined;
    const ca = @min(len_a, 1024);
    const cb = @min(len_b, 1024);

    var idx: usize = 0;
    var pos: usize = 0;
    while (idx < ca and pos < a.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(a[pos]) catch 1;
        cps_a[idx] = decodeCodepoint(a, pos, cp_len);
        pos += cp_len;
        idx += 1;
    }
    idx = 0;
    pos = 0;
    while (idx < cb and pos < b.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(b[pos]) catch 1;
        cps_b[idx] = decodeCodepoint(b, pos, cp_len);
        pos += cp_len;
        idx += 1;
    }

    // Find matches
    var matched_a: [1024]bool = [_]bool{false} ** 1024;
    var matched_b: [1024]bool = [_]bool{false} ** 1024;
    var matches: usize = 0;

    var i: usize = 0;
    while (i < ca) : (i += 1) {
        const lo = if (i > match_dist) i - match_dist else 0;
        const hi = @min(i + match_dist + 1, cb);
        var j: usize = lo;
        while (j < hi) : (j += 1) {
            if (!matched_b[j] and cps_a[i] == cps_b[j]) {
                matched_a[i] = true;
                matched_b[j] = true;
                matches += 1;
                break;
            }
        }
    }

    if (matches == 0) return 0;

    // Count transpositions
    var transpositions: usize = 0;
    var k: usize = 0;
    i = 0;
    while (i < ca) : (i += 1) {
        if (matched_a[i]) {
            while (k < cb and !matched_b[k]) k += 1;
            if (k < cb and cps_a[i] != cps_b[k]) transpositions += 1;
            k += 1;
        }
    }

    // Jaro = (m/|a| + m/|b| + (m-t/2)/m) / 3
    const m_f: f64 = @floatFromInt(matches);
    const la_f: f64 = @floatFromInt(ca);
    const lb_f: f64 = @floatFromInt(cb);
    const t_f: f64 = @floatFromInt(transpositions / 2);
    const jaro = (m_f / la_f + m_f / lb_f + (m_f - t_f) / m_f) / 3.0;
    return @intFromFloat(jaro * 1000.0);
}

/// Jaro-Winkler similarity. Returns value * 1000. Boosts for common prefix.
pub export fn stz_string_jaro_winkler(h1: ?*StzString, h2: ?*StzString) callconv(.c) c_int {
    const jaro = stz_string_jaro(h1, h2);
    if (jaro == 0) return 0;
    const jaro_f: f64 = @as(f64, @floatFromInt(jaro)) / 1000.0;

    // Common prefix (up to 4 chars)
    const s1 = h1 orelse return jaro;
    const s2 = h2 orelse return jaro;
    const a = s1.slice();
    const b = s2.slice();
    var prefix: usize = 0;
    var pa: usize = 0;
    var pb: usize = 0;
    while (prefix < 4 and pa < a.len and pb < b.len) {
        const cpa_len = std.unicode.utf8ByteSequenceLength(a[pa]) catch break;
        const cpb_len = std.unicode.utf8ByteSequenceLength(b[pb]) catch break;
        if (cpa_len != cpb_len) break;
        if (!mem.eql(u8, a[pa..pa + cpa_len], b[pb..pb + cpb_len])) break;
        pa += cpa_len;
        pb += cpb_len;
        prefix += 1;
    }

    const p_f: f64 = @floatFromInt(prefix);
    const jw = jaro_f + p_f * 0.1 * (1.0 - jaro_f);
    return @intFromFloat(jw * 1000.0);
}

/// Metaphone phonetic encoding. Returns new handle with metaphone code.
/// Implements basic metaphone algorithm for English pronunciation matching.
pub export fn stz_string_metaphone(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    if (src.len == 0) return result;

    // Work with uppercase ASCII
    var buf: [256]u8 = undefined;
    const wlen = @min(src.len, 256);
    for (0..wlen) |i| {
        buf[i] = if (src[i] >= 'a' and src[i] <= 'z') src[i] - 32 else src[i];
    }
    const word = buf[0..wlen];

    // Drop initial silent consonant pairs
    var start: usize = 0;
    if (wlen >= 2) {
        const pair = [2]u8{ word[0], word[1] };
        if (mem.eql(u8, &pair, "AE") or mem.eql(u8, &pair, "GN") or
            mem.eql(u8, &pair, "KN") or mem.eql(u8, &pair, "PN") or
            mem.eql(u8, &pair, "WR"))
        {
            start = 1;
        }
    }

    var code_len: usize = 0;
    var prev: u8 = 0;
    var i: usize = start;
    while (i < wlen and code_len < 6) {
        const c = word[i];
        const next: u8 = if (i + 1 < wlen) word[i + 1] else 0;

        if (c == prev and c != 'C') {
            i += 1;
            continue;
        }

        var out: u8 = 0;
        var skip: usize = 1;

        switch (c) {
            'B' => {
                if (i == 0 or word[i - 1] != 'M') out = 'B';
            },
            'C' => {
                if (next == 'H') {
                    out = 'X';
                    skip = 2;
                } else if (next == 'I' or next == 'E' or next == 'Y') {
                    out = 'S';
                } else {
                    out = 'K';
                }
            },
            'D' => {
                if (next == 'G' and i + 2 < wlen and
                    (word[i + 2] == 'I' or word[i + 2] == 'E' or word[i + 2] == 'Y'))
                {
                    out = 'J';
                } else {
                    out = 'T';
                }
            },
            'F' => out = 'F',
            'G' => {
                if (next == 'H' and i + 2 < wlen and !isVowelAscii(word[i + 2])) {
                    i += 2;
                    continue;
                } else if (i > 0 and (next == 'N' or (next == 0))) {
                    // silent G at end
                } else if (next == 'N' and i + 2 < wlen and word[i + 2] == 'E' and i + 3 >= wlen) {
                    // silent GNE
                } else {
                    out = if (next == 'I' or next == 'E' or next == 'Y') 'J' else 'K';
                }
            },
            'H' => {
                if (isVowelAscii(next) and (i == 0 or !isVowelAscii(word[i - 1]))) out = 'H';
            },
            'J' => out = 'J',
            'K' => {
                if (i == 0 or word[i - 1] != 'C') out = 'K';
            },
            'L' => out = 'L',
            'M' => out = 'M',
            'N' => out = 'N',
            'P' => {
                if (next == 'H') {
                    out = 'F';
                    skip = 2;
                } else {
                    out = 'P';
                }
            },
            'Q' => out = 'K',
            'R' => out = 'R',
            'S' => {
                if (next == 'H') {
                    out = 'X';
                    skip = 2;
                } else if (next == 'I' and i + 2 < wlen and (word[i + 2] == 'O' or word[i + 2] == 'A')) {
                    out = 'X';
                    skip = 3;
                } else {
                    out = 'S';
                }
            },
            'T' => {
                if (next == 'H') {
                    out = '0'; // theta
                    skip = 2;
                } else if (next == 'I' and i + 2 < wlen and (word[i + 2] == 'O' or word[i + 2] == 'A')) {
                    out = 'X';
                } else {
                    out = 'T';
                }
            },
            'V' => out = 'F',
            'W', 'Y' => {
                if (isVowelAscii(next)) out = c;
            },
            'X' => {
                result.data.appendSlice(gpa, "KS") catch break;
                code_len += 2;
                prev = 'S';
                i += 1;
                continue;
            },
            'Z' => out = 'S',
            else => {},
        }

        if (out != 0) {
            result.data.appendSlice(gpa, &[_]u8{out}) catch break;
            code_len += 1;
        }
        prev = c;
        i += skip;
    }
    return result;
}

fn isVowelAscii(c: u8) bool {
    return c == 'A' or c == 'E' or c == 'I' or c == 'O' or c == 'U';
}

/// Generate character n-grams. Returns joined result with separator "|".
/// For "hello" with n=2: "he|el|ll|lo"
pub export fn stz_string_char_ngrams(handle: ?*StzString, n: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    if (n < 1) return result;
    const ng: usize = @intCast(n);

    // Collect codepoint byte offsets
    var offsets: [4096]usize = undefined;
    var num_cps: usize = 0;
    var pos: usize = 0;
    while (pos < src.len and num_cps < 4096) {
        offsets[num_cps] = pos;
        const cp_len = std.unicode.utf8ByteSequenceLength(src[pos]) catch 1;
        pos += cp_len;
        num_cps += 1;
    }
    if (num_cps < ng) return result;

    var first = true;
    var i: usize = 0;
    while (i + ng <= num_cps) : (i += 1) {
        if (!first) result.data.appendSlice(gpa, "|") catch break;
        const start = offsets[i];
        const end = if (i + ng < num_cps) offsets[i + ng] else src.len;
        result.data.appendSlice(gpa, src[start..end]) catch break;
        first = false;
    }
    return result;
}

/// Generate word n-grams. Returns joined result with separator "|".
/// For "the quick brown fox" with n=2: "the quick|quick brown|brown fox"
pub export fn stz_string_word_ngrams(handle: ?*StzString, n: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = stz_string_new() orelse return null;
    if (n < 1) return result;
    const ng: usize = @intCast(n);

    // Collect word boundaries
    var word_starts: [1024]usize = undefined;
    var word_ends: [1024]usize = undefined;
    var num_words: usize = 0;
    var i: usize = 0;
    while (i < src.len and num_words < 1024) {
        // Skip whitespace
        while (i < src.len and (src[i] == ' ' or src[i] == '\t' or src[i] == '\n' or src[i] == '\r')) i += 1;
        if (i >= src.len) break;
        word_starts[num_words] = i;
        // Find word end
        while (i < src.len and src[i] != ' ' and src[i] != '\t' and src[i] != '\n' and src[i] != '\r') i += 1;
        word_ends[num_words] = i;
        num_words += 1;
    }
    if (num_words < ng) return result;

    var first = true;
    i = 0;
    while (i + ng <= num_words) : (i += 1) {
        if (!first) result.data.appendSlice(gpa, "|") catch break;
        const start = word_starts[i];
        const end = word_ends[i + ng - 1];
        result.data.appendSlice(gpa, src[start..end]) catch break;
        first = false;
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

test "sort_words" {
    const h = stz_string_from("banana apple cherry", 19);
    const r = stz_string_sort_words(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "apple banana cherry"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("zig is fun", 10);
    const r2 = stz_string_sort_words(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "fun is zig"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "unique_words" {
    const h = stz_string_from("the cat and the dog and cat", 27);
    const r = stz_string_unique_words(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "the cat and dog"));
    stz_string_free(r);
    stz_string_free(h);
}

test "from_binary" {
    const h = stz_string_from("01001000 01101001", 17);
    const r = stz_string_from_binary(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "Hi"));
    stz_string_free(r);
    stz_string_free(h);
}

test "swap_words" {
    const h = stz_string_from("hello world foo", 15);
    const r = stz_string_swap_words(h, 0, 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "foo world hello"));
    stz_string_free(r);
    stz_string_free(h);
}

test "to_pig_latin" {
    const h = stz_string_from("hello world", 11);
    const r = stz_string_to_pig_latin(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "ellohay orldway"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("apple is", 8);
    const r2 = stz_string_to_pig_latin(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "appleyay isyay"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "run_length_encode" {
    const h = stz_string_from("aaabbc", 6);
    const r = stz_string_run_length_encode(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "3a2b1c"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("abc", 3);
    const r2 = stz_string_run_length_encode(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "1a1b1c"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "run_length_decode" {
    const h = stz_string_from("3a2b1c", 6);
    const r = stz_string_run_length_decode(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "aaabbc"));
    stz_string_free(r);
    stz_string_free(h);
}

test "count_paragraphs" {
    const h1 = stz_string_from("para1\n\npara2\n\npara3", 19);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_count_paragraphs(h1));
    stz_string_free(h1);

    const h2 = stz_string_from("single paragraph", 16);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_count_paragraphs(h2));
    stz_string_free(h2);
}

test "zigzag" {
    const h = stz_string_from("WEAREDISCOVERED", 15);
    const r = stz_string_zigzag(h, 3);
    // Rail 0: W...E...C...R...  -> WECR (positions 0,4,8,12)
    // Rail 1: .A.R.D.S.O.E.E.  -> ARDSOEE (positions 1,3,5,7,9,11,13)
    // Rail 2: ..E...I...V...D  -> EIVD (positions 2,6,10,14)
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "WECRERDSOEEAIVD"));
    stz_string_free(r);
    stz_string_free(h);
}

test "to_morse" {
    const h = stz_string_from("SOS", 3);
    const r = stz_string_to_morse(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "... --- ..."));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("HI", 2);
    const r2 = stz_string_to_morse(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], ".... .."));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "to_base64" {
    const h = stz_string_from("Hello", 5);
    const r = stz_string_to_base64(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "SGVsbG8="));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("Hi", 2);
    const r2 = stz_string_to_base64(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "SGk="));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "from_base64" {
    const h = stz_string_from("SGVsbG8=", 8);
    const r = stz_string_from_base64(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "Hello"));
    stz_string_free(r);
    stz_string_free(h);
}

test "xor_cipher" {
    const h = stz_string_from("ABC", 3);
    const r = stz_string_xor_cipher(h, 0x20);
    // A(65)^32=97='a', B(66)^32=98='b', C(67)^32=99='c'
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "abc"));
    // XOR again to get back original
    const r2 = stz_string_xor_cipher(r, 0x20);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "ABC"));
    stz_string_free(r2);
    stz_string_free(r);
    stz_string_free(h);
}

test "entropy" {
    const h1 = stz_string_from("aaaa", 4);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_entropy(h1));
    stz_string_free(h1);

    // "ab" has entropy of 1.0 bit -> *100 = 100
    const h2 = stz_string_from("ab", 2);
    try std.testing.expectEqual(@as(c_int, 100), stz_string_entropy(h2));
    stz_string_free(h2);
}

test "char_frequency_top" {
    const h = stz_string_from("aabbbcc", 7);
    const r = stz_string_char_frequency_top(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "b"));
    stz_string_free(r);
    stz_string_free(h);
}

test "jaccard_similarity" {
    const h1 = stz_string_from("abc", 3);
    const h2 = stz_string_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 100), stz_string_jaccard_similarity(h1, h2));
    stz_string_free(h2);
    stz_string_free(h1);

    const h3 = stz_string_from("abc", 3);
    const h4 = stz_string_from("xyz", 3);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_jaccard_similarity(h3, h4));
    stz_string_free(h4);
    stz_string_free(h3);

    // "ab" and "bc" share 'b' -> intersection=1, union=3 -> 33%
    const h5 = stz_string_from("ab", 2);
    const h6 = stz_string_from("bc", 2);
    try std.testing.expectEqual(@as(c_int, 33), stz_string_jaccard_similarity(h5, h6));
    stz_string_free(h6);
    stz_string_free(h5);
}

test "longest_common_prefix" {
    const h1 = stz_string_from("hello world", 11);
    const h2 = stz_string_from("hello there", 11);
    const r = stz_string_longest_common_prefix(h1, h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "hello "));
    stz_string_free(r);
    stz_string_free(h2);
    stz_string_free(h1);
}

test "longest_common_suffix" {
    const h1 = stz_string_from("testing", 7);
    const h2 = stz_string_from("resting", 7);
    const r = stz_string_longest_common_suffix(h1, h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "esting"));
    stz_string_free(r);
    stz_string_free(h2);
    stz_string_free(h1);
}

test "wrap_with" {
    const h = stz_string_from("hello", 5);
    const r = stz_string_wrap_with(h, "[", 1, "]", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "[hello]"));
    stz_string_free(r);
    stz_string_free(h);
}

test "to_title_case_strict" {
    const h = stz_string_from("hello world foo", 15);
    const r = stz_string_to_title_case_strict(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "Hello World Foo"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("the LORD of war", 15);
    const r2 = stz_string_to_title_case_strict(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "The Lord Of War"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "hamming_weight" {
    // 'A' = 0x41 = 01000001 = 2 bits, 'B' = 0x42 = 01000010 = 2 bits
    const h = stz_string_from("AB", 2);
    try std.testing.expectEqual(@as(c_int, 4), stz_string_hamming_weight(h));
    stz_string_free(h);

    const h2 = stz_string_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_hamming_weight(h2));
    stz_string_free(h2);
}

test "is_palindrome_words" {
    const h1 = stz_string_from("dog cat dog", 11);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_palindrome_words(h1));
    stz_string_free(h1);

    const h2 = stz_string_from("a b c b a", 9);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_palindrome_words(h2));
    stz_string_free(h2);

    const h3 = stz_string_from("hello world", 11);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_palindrome_words(h3));
    stz_string_free(h3);
}

test "remove_nth_word" {
    const h = stz_string_from("hello world foo", 15);
    const r = stz_string_remove_nth_word(h, 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "hello foo"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("hello world foo", 15);
    const r2 = stz_string_remove_nth_word(h2, 0);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "world foo"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "insert_word_at" {
    const h = stz_string_from("hello foo", 9);
    const r = stz_string_insert_word_at(h, 1, "world", 5);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "hello world foo"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("world foo", 9);
    const r2 = stz_string_insert_word_at(h2, 0, "hello", 5);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "hello world foo"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "to_spongebob_case" {
    const h = stz_string_from("hello world", 11);
    const r = stz_string_to_spongebob_case(h);
    // H(0)e(1)L(2)l(3)O(4) W(5)o(6)R(7)l(8)D(9) -> "HeLlO wOrLd"
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "HeLlO wOrLd"));
    stz_string_free(r);
    stz_string_free(h);
}

test "between_first" {
    const h = stz_string_from("say [hello] world [bye]", 23);
    const r = stz_string_between_first(h, "[", 1, "]", 1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "hello"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("<b>hi</b>", 9);
    const r2 = stz_string_between_first(h2, "<b>", 3, "</b>", 4);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "hi"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "to_dot_case" {
    const h = stz_string_from("helloWorld", 10);
    const r = stz_string_to_dot_case(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "hello.world"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("MyVarName", 9);
    const r2 = stz_string_to_dot_case(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "my.var.name"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "abbreviate" {
    // abbreviate("hello world", 8) -> "hello..." (5 text + 3 dots = 8 total)
    const h = stz_string_from("hello world", 11);
    const r = stz_string_abbreviate(h, 8);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "hello..."));
    stz_string_free(r);
    stz_string_free(h);

    // abbreviate("hello world", 5) -> "he..." (2 text + 3 dots = 5 total)
    const h1b = stz_string_from("hello world", 11);
    const r1b = stz_string_abbreviate(h1b, 5);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1b)[0..@intCast(stz_string_size(r1b))], "he..."));
    stz_string_free(r1b);
    stz_string_free(h1b);

    // shorter than limit -> returned as-is
    const h2 = stz_string_from("hi", 2);
    const r2 = stz_string_abbreviate(h2, 5);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "hi"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "count_substring" {
    const h = stz_string_from("abcabcabc", 9);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_count_substring(h, "abc", 3));
    stz_string_free(h);

    const h2 = stz_string_from("aaa", 3);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_count_substring(h2, "aa", 2));
    stz_string_free(h2);
}

test "to_path_case" {
    const h = stz_string_from("helloWorld", 10);
    const r = stz_string_to_path_case(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "hello/world"));
    stz_string_free(r);
    stz_string_free(h);
}

test "left_pad" {
    const h = stz_string_from("42", 2);
    const r = stz_string_left_pad(h, 5, '0');
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "00042"));
    stz_string_free(r);
    stz_string_free(h);

    // No padding needed when already wide enough
    const h2 = stz_string_from("hello", 5);
    const r2 = stz_string_left_pad(h2, 3, 'x');
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "hello"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "right_pad" {
    const h = stz_string_from("hi", 2);
    const r = stz_string_right_pad(h, 5, '.');
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "hi..."));
    stz_string_free(r);
    stz_string_free(h);
}

test "to_hex" {
    const h = stz_string_from("ABC", 3);
    const r = stz_string_to_hex(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "414243"));
    stz_string_free(r);
    stz_string_free(h);
}

test "from_hex" {
    const h = stz_string_from("414243", 6);
    const r = stz_string_from_hex(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "ABC"));
    stz_string_free(r);
    stz_string_free(h);
}

test "soundex" {
    const h = stz_string_from("Robert", 6);
    const r = stz_string_soundex(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..@intCast(stz_string_size(r))], "R163"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("Ashcraft", 8);
    const r2 = stz_string_soundex(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2)[0..@intCast(stz_string_size(r2))], "A261"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "vigenere_encrypt" {
    const h = stz_string_from("hello", 5);
    const r = stz_string_vigenere_encrypt(h, "key", 3);
    // h+k=r, e+e=i, l+y=j, l+k=v, o+e=s
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "rijvs"));
    stz_string_free(r);
    stz_string_free(h);
}

test "atbash" {
    const h = stz_string_from("abc", 3);
    const r = stz_string_atbash(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "zyx"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("Hello", 5);
    const r2 = stz_string_atbash(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2.?)[0..@intCast(stz_string_size(r2.?))], "Svool"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "count_words_matching" {
    const h = stz_string_from("the cat and the dog", 19);
    try std.testing.expectEqual(@as(c_int, 2), stz_string_count_words_matching(h, "the", 3));
    stz_string_free(h);
}

test "truncate_words" {
    const h = stz_string_from("one two three four five", 23);
    const r = stz_string_truncate_words(h, 3);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "one two three"));
    stz_string_free(r);
    stz_string_free(h);
}

test "to_constant_case" {
    const h = stz_string_from("hello world", 11);
    const r = stz_string_to_constant_case(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "HELLO_WORLD"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("camelCase", 9);
    const r2 = stz_string_to_constant_case(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2.?)[0..@intCast(stz_string_size(r2.?))], "CAMEL_CASE"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "first_word" {
    const h = stz_string_from("hello world foo", 15);
    const r = stz_string_first_word(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "hello"));
    stz_string_free(r);
    stz_string_free(h);
}

test "last_word" {
    const h = stz_string_from("hello world foo", 15);
    const r = stz_string_last_word(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "foo"));
    stz_string_free(r);
    stz_string_free(h);
}

test "to_nato" {
    const h = stz_string_from("AB", 2);
    const r = stz_string_to_nato(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "Alfa Bravo"));
    stz_string_free(r);
    stz_string_free(h);
}

test "commonality" {
    const h1 = stz_string_from("abc", 3);
    const h2 = stz_string_from("bcd", 3);
    try std.testing.expectEqual(@as(c_int, 2), stz_string_commonality(h1, h2));
    stz_string_free(h1);
    stz_string_free(h2);
}

test "diff_chars" {
    const h1 = stz_string_from("abcd", 4);
    const h2 = stz_string_from("bc", 2);
    const r = stz_string_diff_chars(h1, h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "ad"));
    stz_string_free(r);
    stz_string_free(h1);
    stz_string_free(h2);
}

test "rot47" {
    const h = stz_string_from("Hello", 5);
    const r = stz_string_rot47(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "w6==@"));
    stz_string_free(r);
    stz_string_free(h);
}

test "is_isogram" {
    const h1 = stz_string_from("subdermatoglyphic", 17);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_is_isogram(h1));
    stz_string_free(h1);

    const h2 = stz_string_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_is_isogram(h2));
    stz_string_free(h2);
}

test "reverse_each_word" {
    const h = stz_string_from("hello world", 11);
    const r = stz_string_reverse_each_word(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "olleh dlrow"));
    stz_string_free(r);
    stz_string_free(h);
}

test "count_digits" {
    const h = stz_string_from("abc123def45", 11);
    try std.testing.expectEqual(@as(c_int, 5), stz_string_count_digits(h));
    stz_string_free(h);
}

test "strip_tags" {
    const h = stz_string_from("<b>hello</b> <i>world</i>", 25);
    const r = stz_string_strip_tags(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "hello world"));
    stz_string_free(r);
    stz_string_free(h);
}

test "to_slug" {
    const h = stz_string_from("Hello World! Test", 17);
    const r = stz_string_to_slug(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "hello-world-test"));
    stz_string_free(r);
    stz_string_free(h);
}

test "count_spaces" {
    const h = stz_string_from("hello  world  foo", 17);
    try std.testing.expectEqual(@as(c_int, 4), stz_string_count_spaces(h));
    stz_string_free(h);
}

test "normalize_spaces" {
    const h = stz_string_from("  hello   world  ", 17);
    const r = stz_string_normalize_spaces(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "hello world"));
    stz_string_free(r);
    stz_string_free(h);
}

test "mask_email" {
    const h = stz_string_from("john@example.com", 16);
    const r = stz_string_mask_email(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "j***@example.com"));
    stz_string_free(r);
    stz_string_free(h);
}

test "pluralize" {
    const h1 = stz_string_from("cat", 3);
    const r1 = stz_string_pluralize(h1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1.?)[0..@intCast(stz_string_size(r1.?))], "cats"));
    stz_string_free(r1);
    stz_string_free(h1);

    const h2 = stz_string_from("city", 4);
    const r2 = stz_string_pluralize(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2.?)[0..@intCast(stz_string_size(r2.?))], "cities"));
    stz_string_free(r2);
    stz_string_free(h2);

    const h3 = stz_string_from("box", 3);
    const r3 = stz_string_pluralize(h3);
    try std.testing.expect(mem.eql(u8, stz_string_data(r3.?)[0..@intCast(stz_string_size(r3.?))], "boxes"));
    stz_string_free(r3);
    stz_string_free(h3);
}

test "deduplicate_lines" {
    const input = "hello\nworld\nhello\nfoo";
    const h = stz_string_from(input, input.len);
    const r = stz_string_deduplicate_lines(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "hello\nworld\nfoo"));
    stz_string_free(r);
    stz_string_free(h);
}

test "remove_blank_lines" {
    const input = "hello\n\nworld\n  \nfoo";
    const h = stz_string_from(input, input.len);
    const r = stz_string_remove_blank_lines(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "hello\nworld\nfoo"));
    stz_string_free(r);
    stz_string_free(h);
}

test "extract_numbers" {
    const h = stz_string_from("price is 42.5 and qty 10", 24);
    const r = stz_string_extract_numbers(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "42.5 10"));
    stz_string_free(r);
    stz_string_free(h);
}

test "extract_emails" {
    const h = stz_string_from("contact john@example.com or jane@test.org", 41);
    const r = stz_string_extract_emails(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "john@example.com jane@test.org"));
    stz_string_free(r);
    stz_string_free(h);
}

test "quote" {
    const h = stz_string_from("hello", 5);
    const r = stz_string_quote(h, '"');
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "\"hello\""));
    stz_string_free(r);
    stz_string_free(h);
}

test "unquote" {
    const h = stz_string_from("\"hello\"", 7);
    const r = stz_string_unquote(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "hello"));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("no quotes", 9);
    const r2 = stz_string_unquote(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2.?)[0..@intCast(stz_string_size(r2.?))], "no quotes"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "to_csv_field" {
    const h = stz_string_from("hello,world", 11);
    const r = stz_string_to_csv_field(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "\"hello,world\""));
    stz_string_free(r);
    stz_string_free(h);

    const h2 = stz_string_from("simple", 6);
    const r2 = stz_string_to_csv_field(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2.?)[0..@intCast(stz_string_size(r2.?))], "simple"));
    stz_string_free(r2);
    stz_string_free(h2);
}

test "number_lines" {
    const input = "hello\nworld";
    const h = stz_string_from(input, input.len);
    const r = stz_string_number_lines(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "1: hello\n2: world"));
    stz_string_free(r);
    stz_string_free(h);
}

test "hide" {
    const h = stz_string_from("1234567890", 10);
    const r = stz_string_hide(h, '*', 2, 2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "12******90"));
    stz_string_free(r);
    stz_string_free(h);
}

test "extract_words" {
    const h = stz_string_from("hello, world! foo-bar 123", 25);
    const r = stz_string_extract_words(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "hello world foo bar"));
    stz_string_free(r);
    stz_string_free(h);
}

test "expand_tabs" {
    const h = stz_string_from("a\tb", 3);
    const r = stz_string_expand_tabs(h, 4);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "a    b"));
    stz_string_free(r);
    stz_string_free(h);
}

test "sentence_count" {
    const h = stz_string_from("Hello. How are you? Fine!", 25);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_sentence_count(h));
    stz_string_free(h);
}

test "chop" {
    const h = stz_string_from("hello", 5);
    const r = stz_string_chop(h);
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..@intCast(stz_string_size(r.?))], "hell"));
    stz_string_free(r);
    stz_string_free(h);
}

test "scan_int" {
    const h = stz_string_from("42abc", 5);
    try std.testing.expectEqual(@as(c_int, 42), stz_string_scan_int(h));
    stz_string_free(h);

    const h2 = stz_string_from("-7", 2);
    try std.testing.expectEqual(@as(c_int, -7), stz_string_scan_int(h2));
    stz_string_free(h2);
}

test "to_ordinal" {
    const h1 = stz_string_from("1", 1);
    const r1 = stz_string_to_ordinal(h1);
    try std.testing.expect(mem.eql(u8, stz_string_data(r1.?)[0..@intCast(stz_string_size(r1.?))], "1st"));
    stz_string_free(r1);
    stz_string_free(h1);

    const h2 = stz_string_from("12", 2);
    const r2 = stz_string_to_ordinal(h2);
    try std.testing.expect(mem.eql(u8, stz_string_data(r2.?)[0..@intCast(stz_string_size(r2.?))], "12th"));
    stz_string_free(r2);
    stz_string_free(h2);

    const h3 = stz_string_from("23", 2);
    const r3 = stz_string_to_ordinal(h3);
    try std.testing.expect(mem.eql(u8, stz_string_data(r3.?)[0..@intCast(stz_string_size(r3.?))], "23rd"));
    stz_string_free(r3);
    stz_string_free(h3);
}

test "left_cp" {
    const s = stz_string_from("Hello", 5);
    const r = stz_string_left_cp(s, 3);
    try std.testing.expectEqual(@as(usize, 3), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..3], "Hel"));
    stz_string_free(r);
    stz_string_free(s);
}

test "left_cp utf8" {
    // "cafe\xCC\x81" = "café" (5 bytes, 4 codepoints with combining accent)
    const s = stz_string_from("caf\xC3\xA9!", 6); // café! = 5 codepoints
    const r = stz_string_left_cp(s, 4); // "café"
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..5], "caf\xC3\xA9"));
    stz_string_free(r);
    stz_string_free(s);
}

test "right_cp" {
    const s = stz_string_from("Hello", 5);
    const r = stz_string_right_cp(s, 3);
    try std.testing.expectEqual(@as(usize, 3), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r.?)[0..3], "llo"));
    stz_string_free(r);
    stz_string_free(s);
}

test "cp_count" {
    const s1 = stz_string_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 5), stz_string_cp_count(s1));
    stz_string_free(s1);

    const s2 = stz_string_from("caf\xC3\xA9", 5); // café = 4 codepoints
    try std.testing.expectEqual(@as(c_int, 4), stz_string_cp_count(s2));
    stz_string_free(s2);
}

test "nth_char" {
    const s = stz_string_from("caf\xC3\xA9!", 6); // café! = 5 codepoints
    const c0 = stz_string_nth_char(s, 0); // 'c'
    try std.testing.expectEqual(@as(usize, 1), stz_string_size(c0));
    try std.testing.expect(mem.eql(u8, stz_string_data(c0.?)[0..1], "c"));
    stz_string_free(c0);

    const c3 = stz_string_nth_char(s, 3); // 'é'
    try std.testing.expectEqual(@as(usize, 2), stz_string_size(c3));
    try std.testing.expect(mem.eql(u8, stz_string_data(c3.?)[0..2], "\xC3\xA9"));
    stz_string_free(c3);

    const c4 = stz_string_nth_char(s, 4); // '!'
    try std.testing.expectEqual(@as(usize, 1), stz_string_size(c4));
    try std.testing.expect(mem.eql(u8, stz_string_data(c4.?)[0..1], "!"));
    stz_string_free(c4);

    stz_string_free(s);
}

// ─── Unicode CI Tests ───

test "equals_ci unicode" {
    // German sharp-s: "strasse" should equal "STRASSE" case-insensitively
    const a = stz_string_from("hello", 5);
    const b = stz_string_from("HELLO", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_equals_ci(a, b));
    stz_string_free(a);
    stz_string_free(b);

    // French accented: "cafe" vs "CAFE" (basic)
    const c = stz_string_from("caf\xC3\xA9", 5);
    const d = stz_string_from("CAF\xC3\x89", 5);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_equals_ci(c, d));
    stz_string_free(c);
    stz_string_free(d);
}

test "contains_ci unicode" {
    const s = stz_string_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_contains_ci(s, "WORLD", 5));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_contains_ci(s, "hello", 5));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_contains_ci(s, "xyz", 3));
    stz_string_free(s);
}

test "starts_with_ci unicode" {
    const s = stz_string_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_starts_with_ci(s, "HELLO", 5));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_starts_with_ci(s, "hello", 5));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_starts_with_ci(s, "world", 5));
    stz_string_free(s);
}

test "ends_with_ci unicode" {
    const s = stz_string_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), stz_string_ends_with_ci(s, "WORLD", 5));
    try std.testing.expectEqual(@as(c_int, 1), stz_string_ends_with_ci(s, "world", 5));
    try std.testing.expectEqual(@as(c_int, 0), stz_string_ends_with_ci(s, "hello", 5));
    stz_string_free(s);
}

test "find_all_ci unicode" {
    const s = stz_string_from("abcABCabc", 9);
    const r = stz_string_find_all_ci(s, "abc", 3);
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 0), stz_find_result_get(r, 0));
    try std.testing.expectEqual(@as(i64, 3), stz_find_result_get(r, 1));
    try std.testing.expectEqual(@as(i64, 6), stz_find_result_get(r, 2));
    stz_find_result_free(r);
    stz_string_free(s);
}

test "count_of_ci unicode" {
    const s = stz_string_from("abcABCabc", 9);
    try std.testing.expectEqual(@as(c_int, 3), stz_string_count_of_ci(s, "abc", 3));
    stz_string_free(s);
}

test "foldcase unicode" {
    const s = stz_string_from("Hello WORLD", 11);
    const r = stz_string_foldcase(s);
    const data = stz_string_data(r);
    try std.testing.expect(mem.eql(u8, data[0..11], "hello world"));
    stz_string_free(r);
    stz_string_free(s);
}

test "trim_left unicode whitespace" {
    // U+00A0 (no-break space) = C2 A0 in UTF-8
    const s = stz_string_from("\xC2\xA0 hello", 8);
    const r = stz_string_trim_left(s);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..5], "hello"));
    stz_string_free(r);
    stz_string_free(s);
}

test "trim_right unicode whitespace" {
    // U+00A0 (no-break space) = C2 A0 in UTF-8
    const s = stz_string_from("hello \xC2\xA0", 8);
    const r = stz_string_trim_right(s);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..5], "hello"));
    stz_string_free(r);
    stz_string_free(s);
}

test "trimmed delegates to unicode trim" {
    // U+00A0 on both sides
    const s = stz_string_from("\xC2\xA0hello\xC2\xA0", 9);
    const r = stz_string_trimmed(s);
    try std.testing.expectEqual(@as(usize, 5), stz_string_size(r));
    try std.testing.expect(mem.eql(u8, stz_string_data(r)[0..5], "hello"));
    stz_string_free(r);
    stz_string_free(s);
}

// ─── NLP Tests ───

test "jaro identical" {
    const a = stz_string_from("hello", 5);
    const b = stz_string_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 1000), stz_string_jaro(a, b));
    stz_string_free(a);
    stz_string_free(b);
}

test "jaro similar" {
    const a = stz_string_from("martha", 6);
    const b = stz_string_from("marhta", 6);
    const j = stz_string_jaro(a, b);
    // Jaro("martha", "marhta") should be ~944
    try std.testing.expect(j > 900 and j <= 1000);
    stz_string_free(a);
    stz_string_free(b);
}

test "jaro_winkler boosts prefix" {
    const a = stz_string_from("martha", 6);
    const b = stz_string_from("marhta", 6);
    const j = stz_string_jaro(a, b);
    const jw = stz_string_jaro_winkler(a, b);
    // Jaro-Winkler should be >= Jaro (prefix boost)
    try std.testing.expect(jw >= j);
    stz_string_free(a);
    stz_string_free(b);
}

test "jaro_winkler different strings" {
    const a = stz_string_from("abc", 3);
    const b = stz_string_from("xyz", 3);
    try std.testing.expectEqual(@as(c_int, 0), stz_string_jaro_winkler(a, b));
    stz_string_free(a);
    stz_string_free(b);
}

test "metaphone basic" {
    const h = stz_string_from("smith", 5);
    const r = stz_string_metaphone(h);
    try std.testing.expect(r != null);
    const data = stz_string_data(r.?);
    const size = stz_string_size(r.?);
    // Metaphone of "smith" should be "SM0" (0 = theta for TH)
    try std.testing.expect(size > 0);
    try std.testing.expect(mem.eql(u8, data[0..size], "SM0"));
    stz_string_free(r);
    stz_string_free(h);
}

test "metaphone phone" {
    const h = stz_string_from("phone", 5);
    const r = stz_string_metaphone(h);
    try std.testing.expect(r != null);
    const data = stz_string_data(r.?);
    const size = stz_string_size(r.?);
    // PH -> F, so "phone" -> "FN"
    try std.testing.expect(mem.eql(u8, data[0..size], "FN"));
    stz_string_free(r);
    stz_string_free(h);
}

test "char_ngrams bigrams" {
    const h = stz_string_from("hello", 5);
    const r = stz_string_char_ngrams(h, 2);
    try std.testing.expect(r != null);
    const data = stz_string_data(r.?);
    const size = stz_string_size(r.?);
    try std.testing.expect(mem.eql(u8, data[0..size], "he|el|ll|lo"));
    stz_string_free(r);
    stz_string_free(h);
}

test "word_ngrams bigrams" {
    const input = "the quick brown fox";
    const h = stz_string_from(input, input.len);
    const r = stz_string_word_ngrams(h, 2);
    try std.testing.expect(r != null);
    const data = stz_string_data(r.?);
    const size = stz_string_size(r.?);
    try std.testing.expect(mem.eql(u8, data[0..size], "the quick|quick brown|brown fox"));
    stz_string_free(r);
    stz_string_free(h);
}


