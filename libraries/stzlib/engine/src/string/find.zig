// Softanza Engine -- String Find/Search/Match (Phase D)
//
// Index-of, find-all, contains, starts/ends-with, equals,
// count-of operations extracted from string.zig.
// All functions use C calling convention.

const std = @import("std");
const core = @import("core.zig");
const mem = core.mem;
const gpa = core.gpa;
const unicode = core.unicode;
const StzString = core.StzString;
const StzStringHandle = core.StzStringHandle;
const StzFindResult = core.StzFindResult;
const StzFindResultHandle = core.StzFindResultHandle;
const INDEX_BASE = core.INDEX_BASE;
const toInternal = core.toInternal;
const toExternal = core.toExternal;
const casefoldAlloc = core.casefoldAlloc;
const ciEqlUnicode = core.ciEqlUnicode;
const ciMatch = core.ciMatch;
const bmhSearch = core.bmhSearch;
const decodeCodepoint = core.decodeCodepoint;
const byteOffsetToCodepointIndex = core.byteOffsetToCodepointIndex;
const str_new = core.str_new;
const str_from = core.str_from;

// ─── Index Of ───

pub fn str_index_of_cs(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, case: c_int) callconv(.c) i64 {
    if (case == 0) return str_index_of_from_cs(handle, needle, needle_len, @intCast(INDEX_BASE), 0);
    if (handle) |s| {
        if (needle == null or needle_len == 0) return -1;
        const hay = s.slice();
        const n = needle[0..needle_len];

        // ASCII + BMH fast-path: byte pos == cp pos
        if (s.isAscii() and n.len > 4) {
            if (bmhSearch(hay, n, 0)) |byte_pos| {
                return toExternal(byte_pos);
            }
            return -1;
        }

        var byte_pos: usize = 0;
        var cp_pos: usize = 0;
        while (byte_pos + n.len <= hay.len) {
            if (mem.eql(u8, hay[byte_pos..][0..n.len], n)) {
                return toExternal(cp_pos);
            }
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp_pos += 1;
        }
    }
    return -1;
}

pub fn str_index_of(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) i64 {
    return str_index_of_cs(handle, needle, needle_len, 1);
}

/// Unified index_of_from with case sensitivity parameter.
pub fn str_index_of_from_cs(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, start_cp: usize, case: c_int) callconv(.c) i64 {
    if (handle) |s| {
        if (needle == null or needle_len == 0) return -1;
        const hay = s.slice();
        const n = needle[0..needle_len];
        const internal_start = toInternal(@intCast(start_cp));

        if (case == 0) {
            // Case-insensitive
            const hay_folded = casefoldAlloc(hay) orelse return -1;
            defer gpa.free(hay_folded);
            const n_folded = casefoldAlloc(n) orelse return -1;
            defer gpa.free(n_folded);
            var byte_pos: usize = 0;
            var cp_pos: usize = 0;
            while (cp_pos < internal_start and byte_pos < hay_folded.len) {
                const cp_len = std.unicode.utf8ByteSequenceLength(hay_folded[byte_pos]) catch 1;
                byte_pos += cp_len;
                cp_pos += 1;
            }
            if (mem.indexOfPos(u8, hay_folded, byte_pos, n_folded)) |pos| {
                return toExternal(byteOffsetToCodepointIndex(hay_folded, pos));
            }
        } else {
            // Case-sensitive
            var byte_pos: usize = 0;
            var cp_pos: usize = 0;
            while (cp_pos < internal_start and byte_pos < hay.len) {
                const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
                byte_pos += cp_len;
                cp_pos += 1;
            }
            while (byte_pos + n.len <= hay.len) {
                if (mem.eql(u8, hay[byte_pos..][0..n.len], n)) {
                    return toExternal(cp_pos);
                }
                const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
                byte_pos += cp_len;
                cp_pos += 1;
            }
        }
    }
    return -1;
}

pub fn str_index_of_from(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, start_cp: usize) callconv(.c) i64 {
    return str_index_of_from_cs(handle, needle, needle_len, start_cp, 1);
}

// ─── Byte to Codepoint position ───

pub fn str_byte_to_cp(handle: StzStringHandle, byte_pos: usize) callconv(.c) i64 {
    if (handle) |s| {
        const result = unicode.stz_unicode_byte_to_cp(s.data.items.ptr, s.data.items.len, @intCast(byte_pos));
        return result;
    }
    return -1;
}

// ─── Count Of ───

pub fn str_count_of(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) c_int {
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

/// Unified count_of with case sensitivity parameter.
pub fn str_count_of_cs(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, case: c_int) callconv(.c) c_int {
    if (handle) |s| {
        if (needle == null or needle_len == 0) return 0;
        const hay = s.slice();
        const n = needle[0..needle_len];
        if (case == 0) {
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
        } else {
            return str_count_of(handle, needle, needle_len);
        }
    }
    return 0;
}

// ─── Find All ───

/// Unified find_all with case sensitivity parameter.
/// case=1: case-sensitive, case=0: case-insensitive (Unicode casefold).
pub fn str_find_all_cs(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, case: c_int) callconv(.c) StzFindResultHandle {
    const r = gpa.create(StzFindResult) catch return null;
    r.* = StzFindResult.init();
    if (handle) |s| {
        if (needle == null or needle_len == 0) return r;
        const hay = s.slice();
        const n = needle[0..needle_len];

        if (case == 0) {
            // Case-insensitive: casefold both
            const hay_folded = casefoldAlloc(hay) orelse return r;
            defer gpa.free(hay_folded);
            const n_folded = casefoldAlloc(n) orelse return r;
            defer gpa.free(n_folded);
            var byte_pos: usize = 0;
            var cp_pos: usize = 0;
            while (byte_pos + n_folded.len <= hay_folded.len) {
                if (mem.eql(u8, hay_folded[byte_pos..][0..n_folded.len], n_folded)) {
                    r.positions.append(gpa, toExternal(cp_pos)) catch break;
                }
                const cp_len = std.unicode.utf8ByteSequenceLength(hay_folded[byte_pos]) catch 1;
                byte_pos += cp_len;
                cp_pos += 1;
            }
        } else {
            // Case-sensitive: direct comparison
            var byte_pos: usize = 0;
            var cp_pos: usize = 0;
            while (byte_pos + n.len <= hay.len) {
                if (mem.eql(u8, hay[byte_pos..][0..n.len], n)) {
                    r.positions.append(gpa, toExternal(cp_pos)) catch break;
                }
                const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
                byte_pos += cp_len;
                cp_pos += 1;
            }
        }
    }
    return r;
}

pub fn str_find_all(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) StzFindResultHandle {
    return str_find_all_cs(handle, needle, needle_len, 1);
}

// ─── Find Result Accessors ───

pub fn stz_find_result_count(result: StzFindResultHandle) callconv(.c) c_int {
    if (result) |r| return @intCast(r.positions.items.len);
    return 0;
}

pub fn stz_find_result_get(result: StzFindResultHandle, index: c_int) callconv(.c) i64 {
    if (result) |r| {
        if (index < 1) return -1;
        const i: usize = @intCast(index - 1);
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

// ─── Last Index Of ───

/// Unified last_index_of with case sensitivity parameter.
pub fn str_last_index_of_cs(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, case: c_int) callconv(.c) i64 {
    if (handle) |s| {
        if (needle == null or needle_len == 0) return -1;
        const hay = s.slice();
        const n = needle[0..needle_len];
        if (case == 0) {
            const hay_folded = casefoldAlloc(hay) orelse return -1;
            defer gpa.free(hay_folded);
            const n_folded = casefoldAlloc(n) orelse return -1;
            defer gpa.free(n_folded);
            if (n_folded.len > hay_folded.len) return -1;
            if (mem.lastIndexOf(u8, hay_folded, n_folded)) |pos| {
                return toExternal(byteOffsetToCodepointIndex(hay_folded, pos));
            }
        } else {
            if (mem.lastIndexOf(u8, hay, n)) |byte_pos| {
                return toExternal(byteOffsetToCodepointIndex(hay, byte_pos));
            }
        }
    }
    return -1;
}

pub fn str_last_index_of(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) i64 {
    return str_last_index_of_cs(handle, needle, needle_len, 1);
}

// ─── Contains ───

/// Unified contains with case sensitivity parameter.
pub fn str_contains_cs(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, case: c_int) callconv(.c) c_int {
    return if (str_index_of_cs(handle, needle, needle_len, case) >= 0) 1 else 0;
}

pub fn str_contains(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) c_int {
    return str_contains_cs(handle, needle, needle_len, 1);
}

// ─── Starts With ───

/// Unified starts_with with case sensitivity parameter.
pub fn str_starts_with_cs(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize, case: c_int) callconv(.c) c_int {
    if (handle) |s| {
        if (prefix == null or prefix_len == 0) return 1;
        const sl = s.slice();
        if (prefix_len > sl.len) return 0;
        if (case == 0) {
            const hay_prefix = casefoldAlloc(sl[0..prefix_len]) orelse return 0;
            defer gpa.free(hay_prefix);
            const pfx_folded = casefoldAlloc(prefix[0..prefix_len]) orelse return 0;
            defer gpa.free(pfx_folded);
            return if (mem.eql(u8, hay_prefix, pfx_folded)) 1 else 0;
        } else {
            return if (mem.eql(u8, sl[0..prefix_len], prefix[0..prefix_len])) 1 else 0;
        }
    }
    return 0;
}

pub fn str_starts_with(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize) callconv(.c) c_int {
    return str_starts_with_cs(handle, prefix, prefix_len, 1);
}

// ─── Ends With ───

/// Unified ends_with with case sensitivity parameter.
pub fn str_ends_with_cs(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize, case: c_int) callconv(.c) c_int {
    if (handle) |s| {
        if (suffix == null or suffix_len == 0) return 1;
        const sl = s.slice();
        if (suffix_len > sl.len) return 0;
        const start = sl.len - suffix_len;
        if (case == 0) {
            const hay_suffix = casefoldAlloc(sl[start..]) orelse return 0;
            defer gpa.free(hay_suffix);
            const sfx_folded = casefoldAlloc(suffix[0..suffix_len]) orelse return 0;
            defer gpa.free(sfx_folded);
            return if (mem.eql(u8, hay_suffix, sfx_folded)) 1 else 0;
        } else {
            return if (mem.eql(u8, sl[start..], suffix[0..suffix_len])) 1 else 0;
        }
    }
    return 0;
}

pub fn str_ends_with(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize) callconv(.c) c_int {
    return str_ends_with_cs(handle, suffix, suffix_len, 1);
}

// ─── Equals ───

pub fn str_equals_cs(h1: StzStringHandle, h2: StzStringHandle, case: c_int) callconv(.c) c_int {
    if (h1) |s1| {
        if (h2) |s2| {
            if (case == 0) return if (ciEqlUnicode(s1.slice(), s2.slice())) 1 else 0;
            return if (mem.eql(u8, s1.slice(), s2.slice())) 1 else 0;
        }
    }
    return 0;
}

pub fn str_equals(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    return str_equals_cs(h1, h2, 1);
}

// ─── Find Nth ───

/// Unified find_nth with case sensitivity parameter.
pub fn str_find_nth_cs(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, n: c_int, case: c_int) callconv(.c) i64 {
    if (handle) |s| {
        if (n < 1) return -1;
        const hay = s.slice();
        const ndl = needle[0..needle_len];
        if (case == 0) {
            const hay_folded = casefoldAlloc(hay) orelse return -1;
            defer gpa.free(hay_folded);
            const ndl_folded = casefoldAlloc(ndl) orelse return -1;
            defer gpa.free(ndl_folded);
            var occurrence: c_int = 0;
            var byte_pos: usize = 0;
            while (mem.indexOfPos(u8, hay_folded, byte_pos, ndl_folded)) |pos| {
                occurrence += 1;
                if (occurrence == n) {
                    return toExternal(byteOffsetToCodepointIndex(hay_folded, pos));
                }
                byte_pos = pos + 1;
            }
        } else {
            var occurrence: c_int = 0;
            var byte_pos: usize = 0;
            while (mem.indexOfPos(u8, hay, byte_pos, ndl)) |pos| {
                occurrence += 1;
                if (occurrence == n) {
                    return toExternal(byteOffsetToCodepointIndex(hay, pos));
                }
                byte_pos = pos + 1;
            }
        }
    }
    return -1;
}

pub fn str_find_nth(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, n: c_int) callconv(.c) i64 {
    return str_find_nth_cs(handle, needle, needle_len, n, 1);
}

// ─── Character-level find ───

/// Check if string starts with a digit. Returns 1 or 0.
pub fn str_starts_with_digit(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;
    const cp_len = std.unicode.utf8ByteSequenceLength(bytes[0]) catch 1;
    const cp_val: i32 = decodeCodepoint(bytes, 0, cp_len);
    return if (unicode.stz_unicode_is_digit(cp_val) != 0) @as(c_int, 1) else @as(c_int, 0);
}

/// Check if string starts with a letter. Returns 1 or 0.
pub fn str_starts_with_letter(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;
    const cp_len = std.unicode.utf8ByteSequenceLength(bytes[0]) catch 1;
    const cp_val: i32 = decodeCodepoint(bytes, 0, cp_len);
    return if (unicode.stz_unicode_is_letter(cp_val) != 0) @as(c_int, 1) else @as(c_int, 0);
}

/// Check if string ends with a digit. Returns 1 or 0.
pub fn str_ends_with_digit(handle: StzStringHandle) callconv(.c) c_int {
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
pub fn str_ends_with_letter(handle: StzStringHandle) callconv(.c) c_int {
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

/// Find all positions of a codepoint.
pub fn str_find_all_char(handle: StzStringHandle, codepoint: u32) callconv(.c) StzFindResultHandle {
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
            positions.append(gpa, toExternal(@intCast(cp_i))) catch return null;
        }
        off += cp_len;
        cp_i += 1;
    }

    const fr = gpa.create(StzFindResult) catch return null;
    fr.* = .{ .positions = positions };
    return fr;
}

// ─── Starts/Ends With Any ───

/// Check if string starts with any of given prefixes (pipe-separated).
pub export fn str_starts_with_any_cs(handle: ?*StzString, prefixes: [*c]const u8, prefixes_len: c_int, case: c_int) callconv(.c) c_int {
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
                if (case != 0) {
                    if (mem.eql(u8, src[0..prefix.len], prefix)) return 1;
                } else {
                    if (ciMatch(src[0..prefix.len], prefix)) return 1;
                }
            }
            start = i + 1;
        }
    }
    return 0;
}

pub export fn str_starts_with_any(handle: ?*StzString, prefixes: [*c]const u8, prefixes_len: c_int) callconv(.c) c_int {
    return str_starts_with_any_cs(handle, prefixes, prefixes_len, 1);
}

/// Check if string ends with any of given suffixes (pipe-separated).
pub export fn str_ends_with_any_cs(handle: ?*StzString, suffixes: [*c]const u8, suffixes_len: c_int, case: c_int) callconv(.c) c_int {
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
                if (case != 0) {
                    if (mem.eql(u8, src[src.len - suffix.len ..], suffix)) return 1;
                } else {
                    if (ciMatch(src[src.len - suffix.len ..], suffix)) return 1;
                }
            }
            start = i + 1;
        }
    }
    return 0;
}

pub export fn str_ends_with_any(handle: ?*StzString, suffixes: [*c]const u8, suffixes_len: c_int) callconv(.c) c_int {
    return str_ends_with_any_cs(handle, suffixes, suffixes_len, 1);
}

// ─── Duplicate Substrings ───

const codepointIndexToByteOffset = core.codepointIndexToByteOffset;
const utf8CodepointCount = core.utf8CodepointCount;

/// Find all substrings (of any length) that appear more than once.
/// Returns null-delimited list of unique duplicate substrings.
/// case = 1: case-sensitive, case = 0: case-insensitive.
pub fn str_duplicate_substrings_cs(handle: StzStringHandle, case: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const buf = s.slice();
    if (buf.len == 0) return str_new();

    const n = utf8CodepointCount(buf);
    if (n < 2) return str_new();

    // Build codepoint offset table for O(1) codepoint-to-byte lookups
    var cp_offsets = std.ArrayListUnmanaged(usize){};
    defer cp_offsets.deinit(gpa);
    {
        var off: usize = 0;
        while (off < buf.len) {
            cp_offsets.append(gpa, off) catch return null;
            const seq = std.unicode.utf8ByteSequenceLength(buf[off]) catch 1;
            off += seq;
        }
        cp_offsets.append(gpa, buf.len) catch return null; // sentinel
    }

    // Track seen substrings: key = substring bytes (or casefolded), value = count
    // Also track which originals we've already emitted
    var seen = std.StringHashMap(u8).init(gpa); // 0 = seen once, 1 = emitted
    defer {
        var it = seen.keyIterator();
        while (it.next()) |key| gpa.free(key.*);
        seen.deinit();
    }

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    var first = true;

    // Iterate all substrings by codepoint indices
    var i: usize = 0;
    while (i < n) : (i += 1) {
        var j: usize = i + 1;
        while (j <= n) : (j += 1) {
            const byte_start = cp_offsets.items[i];
            const byte_end = cp_offsets.items[j];
            const substr = buf[byte_start..byte_end];

            // Get the comparison key
            const key_slice = if (case == 0) (casefoldAlloc(substr) orelse continue) else (gpa.dupe(u8, substr) catch continue);

            const entry = seen.getOrPut(key_slice) catch {
                gpa.free(key_slice);
                continue;
            };
            if (entry.found_existing) {
                // Already seen — free the duplicate key
                gpa.free(key_slice);
                if (entry.value_ptr.* == 0) {
                    // First duplicate — emit it
                    entry.value_ptr.* = 1;
                    if (!first) {
                        result.data.append(gpa, 0) catch break; // null separator
                    }
                    result.data.appendSlice(gpa, substr) catch break;
                    first = false;
                }
                // Already emitted — skip
            } else {
                // First occurrence
                entry.value_ptr.* = 0;
            }
        }
    }

    return result;
}

// ─── Tests ───

const testing = std.testing;
const str_free = core.str_free;
const str_data = core.str_data;
const str_size = core.str_size;

test "index_of" {
    const s = str_from("hello world", 11);
    defer str_free(s);
    try testing.expectEqual(@as(i64, 1), str_index_of(s, "hello", 5));
    try testing.expectEqual(@as(i64, 7), str_index_of(s, "world", 5));
    try testing.expectEqual(@as(i64, -1), str_index_of(s, "xyz", 3));
}

test "index_of_cs" {
    const s = str_from("Hello World", 11);
    defer str_free(s);
    // Case sensitive: "hello" not found
    try testing.expectEqual(@as(i64, -1), str_index_of_cs(s, "hello", 5, 1));
    // Case insensitive: "hello" found at 1
    try testing.expectEqual(@as(i64, 1), str_index_of_cs(s, "hello", 5, 0));
}

test "index_of_from" {
    const s = str_from("abcabc", 6);
    defer str_free(s);
    try testing.expectEqual(@as(i64, 4), str_index_of_from(s, "abc", 3, 4));
}

test "byte_to_cp" {
    const s = str_from("abc", 3);
    defer str_free(s);
    try testing.expectEqual(@as(i64, 1), str_byte_to_cp(s, 1));
}

test "count_of" {
    const s = str_from("abcabcabc", 9);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 3), str_count_of(s, "abc", 3));
}

test "count_of_cs" {
    const s = str_from("AbcABCabc", 9);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 1), str_count_of_cs(s, "Abc", 3, 1));
    try testing.expectEqual(@as(c_int, 3), str_count_of_cs(s, "abc", 3, 0));
}

test "find_all" {
    const s = str_from("abcabc", 6);
    defer str_free(s);
    const fr = str_find_all(s, "abc", 3);
    defer stz_find_result_free(fr);
    try testing.expect(fr != null);
    try testing.expectEqual(@as(c_int, 2), stz_find_result_count(fr));
    try testing.expectEqual(@as(i64, 1), stz_find_result_get(fr, 1));
    try testing.expectEqual(@as(i64, 4), stz_find_result_get(fr, 2));
}

test "last_index_of" {
    const s = str_from("abcabc", 6);
    defer str_free(s);
    try testing.expectEqual(@as(i64, 4), str_last_index_of(s, "abc", 3));
}

test "contains" {
    const s = str_from("hello world", 11);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 1), str_contains(s, "world", 5));
    try testing.expectEqual(@as(c_int, 0), str_contains(s, "xyz", 3));
}

test "contains_cs" {
    const s = str_from("Hello", 5);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 0), str_contains_cs(s, "hello", 5, 1));
    try testing.expectEqual(@as(c_int, 1), str_contains_cs(s, "hello", 5, 0));
}

test "starts_with" {
    const s = str_from("hello world", 11);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 1), str_starts_with(s, "hello", 5));
    try testing.expectEqual(@as(c_int, 0), str_starts_with(s, "world", 5));
}

test "ends_with" {
    const s = str_from("hello world", 11);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 1), str_ends_with(s, "world", 5));
    try testing.expectEqual(@as(c_int, 0), str_ends_with(s, "hello", 5));
}

test "equals" {
    const s1 = str_from("hello", 5);
    defer str_free(s1);
    const s2 = str_from("hello", 5);
    defer str_free(s2);
    const s3 = str_from("Hello", 5);
    defer str_free(s3);
    try testing.expectEqual(@as(c_int, 1), str_equals(s1, s2));
    try testing.expectEqual(@as(c_int, 0), str_equals(s1, s3));
    try testing.expectEqual(@as(c_int, 1), str_equals_cs(s1, s3, 0));
}

test "find_nth" {
    const s = str_from("abcabcabc", 9);
    defer str_free(s);
    try testing.expectEqual(@as(i64, 1), str_find_nth(s, "abc", 3, 1));
    try testing.expectEqual(@as(i64, 4), str_find_nth(s, "abc", 3, 2));
    try testing.expectEqual(@as(i64, 7), str_find_nth(s, "abc", 3, 3));
    try testing.expectEqual(@as(i64, -1), str_find_nth(s, "abc", 3, 4));
}

test "starts_with_digit_letter" {
    const s1 = str_from("123abc", 6);
    defer str_free(s1);
    try testing.expectEqual(@as(c_int, 1), str_starts_with_digit(s1));
    try testing.expectEqual(@as(c_int, 0), str_starts_with_letter(s1));

    const s2 = str_from("abc123", 6);
    defer str_free(s2);
    try testing.expectEqual(@as(c_int, 0), str_starts_with_digit(s2));
    try testing.expectEqual(@as(c_int, 1), str_starts_with_letter(s2));
}

test "ends_with_digit_letter" {
    const s1 = str_from("abc123", 6);
    defer str_free(s1);
    try testing.expectEqual(@as(c_int, 1), str_ends_with_digit(s1));
    try testing.expectEqual(@as(c_int, 0), str_ends_with_letter(s1));
}

test "find_all_char" {
    const s = str_from("abcabc", 6);
    defer str_free(s);
    const fr = str_find_all_char(s, 'a');
    defer stz_find_result_free(fr);
    try testing.expect(fr != null);
    try testing.expectEqual(@as(c_int, 2), stz_find_result_count(fr));
    try testing.expectEqual(@as(i64, 1), stz_find_result_get(fr, 1));
    try testing.expectEqual(@as(i64, 4), stz_find_result_get(fr, 2));
}

test "starts_with_any" {
    const s = str_from("hello.zig", 9);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 1), str_starts_with_any(s, "hello|world", 11));
    try testing.expectEqual(@as(c_int, 0), str_starts_with_any(s, "foo|bar", 7));
}

test "ends_with_any" {
    const s = str_from("hello.zig", 9);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 1), str_ends_with_any(s, ".txt|.zig", 9));
    try testing.expectEqual(@as(c_int, 0), str_ends_with_any(s, ".md|.rs", 6));
}

test "starts_with_any_cs CI" {
    const s = str_from("Hello.zig", 9);
    defer str_free(s);
    // CS: "hello" won't match "Hello"
    try testing.expectEqual(@as(c_int, 0), str_starts_with_any_cs(s, "hello|world", 11, 1));
    // CI: "hello" matches "Hello"
    try testing.expectEqual(@as(c_int, 1), str_starts_with_any_cs(s, "hello|world", 11, 0));
}

test "ends_with_any_cs CI" {
    const s = str_from("hello.ZIG", 9);
    defer str_free(s);
    // CS: ".zig" won't match ".ZIG"
    try testing.expectEqual(@as(c_int, 0), str_ends_with_any_cs(s, ".txt|.zig", 9, 1));
    // CI: ".zig" matches ".ZIG"
    try testing.expectEqual(@as(c_int, 1), str_ends_with_any_cs(s, ".txt|.zig", 9, 0));
}
