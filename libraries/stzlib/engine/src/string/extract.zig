// Softanza Engine -- String Extract/Substring (Phase D)
//
// Mid, left, right, slice, chars, between, substring, and
// related extraction operations extracted from string.zig.
// All functions use C calling convention.

const std = @import("std");
const core = @import("core.zig");
const mem = core.mem;
const gpa = core.gpa;
const unicode = core.unicode;
const StzString = core.StzString;
const StzStringHandle = core.StzStringHandle;
const setError = core.setError;
const str_new = core.str_new;
const str_from = core.str_from;
const str_free = core.str_free;
const decodeCodepoint = core.decodeCodepoint;
const INDEX_BASE = core.INDEX_BASE;
const toInternal = core.toInternal;
const toExternal = core.toExternal;
const utf8CodepointCount = core.utf8CodepointCount;
const codepointIndexToByteOffset = core.codepointIndexToByteOffset;
const casefoldAlloc = core.casefoldAlloc;

// ─── Byte-level Extraction ───

pub fn str_mid(handle: StzStringHandle, start: usize, length: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const sl = s.slice();
        if (start >= sl.len) return str_new();
        const end = @min(start + length, sl.len);
        return str_from(sl[start..end].ptr, end - start);
    }
    return str_new();
}

pub fn str_left(handle: StzStringHandle, length: usize) callconv(.c) StzStringHandle {
    return str_mid(handle, 0, length);
}

pub fn str_right(handle: StzStringHandle, length: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const sl = s.slice();
        if (length >= sl.len) return str_from(sl.ptr, sl.len);
        const start = sl.len - length;
        return str_from(sl[start..].ptr, length);
    }
    return str_new();
}

/// Trim whitespace from both ends. Returns new handle.
/// (Inlined trim logic to avoid circular dependency with trim.zig.)
pub fn str_trimmed(handle: StzStringHandle) callconv(.c) StzStringHandle {
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
    return str_from(bytes[start..end].ptr, end - start);
}

// ─── Codepoint-aware Extraction ───

/// Get nth char (INDEX_BASE-based codepoint position). Returns new handle with that single codepoint.
pub fn str_nth_char(handle: StzStringHandle, cp_index: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const hay = s.slice();
        const internal_idx = toInternal(@intCast(cp_index));
        var byte_pos: usize = 0;
        var cp: usize = 0;
        while (byte_pos < hay.len and cp < internal_idx) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp += 1;
        }
        if (byte_pos < hay.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            return str_from(hay[byte_pos..].ptr, cp_len);
        }
    }
    return str_new();
}

/// Extract substring by codepoint range [start_cp, start_cp + cp_count).
/// start_cp is 1-based from host (converted to 0-based internally). cp_count is a length (not a position).
pub fn str_slice(handle: StzStringHandle, start_cp: usize, cp_count_arg: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const hay = s.slice();
        const internal_start = toInternal(@intCast(start_cp));
        // Find byte start
        var byte_pos: usize = 0;
        var cp: usize = 0;
        while (byte_pos < hay.len and cp < internal_start) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp += 1;
        }
        const byte_start = byte_pos;
        // Find byte end
        var count: usize = 0;
        while (byte_pos < hay.len and count < cp_count_arg) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            count += 1;
        }
        return str_from(hay[byte_start..byte_pos].ptr, byte_pos - byte_start);
    }
    return str_new();
}

/// Get all chars as an array of handles. Caller must free each handle and the array.
/// Returns count via out parameter. Array allocated with c_allocator.
pub fn str_chars(handle: StzStringHandle, out_count: *usize) callconv(.c) [*c]StzStringHandle {
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
            arr[i] = str_from(hay[byte_pos..].ptr, cp_len);
            byte_pos += cp_len;
            i += 1;
        }
        return arr.ptr;
    }
    out_count.* = 0;
    return null;
}

/// Free an array of string handles returned by str_chars.
pub fn str_chars_free(arr: [*c]StzStringHandle, count: usize) callconv(.c) void {
    if (arr == null) return;
    for (0..count) |i| {
        str_free(arr[i]);
    }
    gpa.free(arr[0..count]);
}

pub fn str_char_at(handle: StzStringHandle, cp_index: c_int) callconv(.c) i32 {
    if (handle) |s| {
        const internal = toInternal(@as(i64, cp_index));
        const byte_off = s.cpToByteCached(internal) orelse return -1;
        return unicode.stz_unicode_iterate(s.data.items.ptr, s.data.items.len, @intCast(byte_off));
    }
    return -1;
}

pub fn str_mid_cp(handle: StzStringHandle, cp_start: c_int, cp_count_arg: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const internal_start = toInternal(@as(i64, cp_start));
        const count: usize = if (cp_count_arg > 0) @intCast(cp_count_arg) else 0;
        const byte_start = s.cpToByteCached(internal_start) orelse return str_new();
        const end_cp = internal_start + count;
        const byte_end = s.cpToByteCached(end_cp) orelse src.len;
        return str_from(src[byte_start..byte_end].ptr, byte_end - byte_start);
    }
    return str_new();
}

pub fn str_left_cp(handle: StzStringHandle, cp_count_arg: c_int) callconv(.c) StzStringHandle {
    // left_cp takes a COUNT, not a position -- pass internal 0 as start
    return str_mid_cp(handle, INDEX_BASE, cp_count_arg);
}

pub fn str_right_cp(handle: StzStringHandle, cp_count_arg: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const total_cp = utf8CodepointCount(src);
        // right_cp: start from (total - count), expressed in 1-based host convention
        const start_cp: c_int = @intCast(total_cp -| @as(usize, @intCast(@max(cp_count_arg, 0))));
        return str_mid_cp(handle, start_cp + INDEX_BASE, cp_count_arg);
    }
    return str_new();
}

// ─── Unicode Properties ───

pub fn str_grapheme_count(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        return unicode.stz_unicode_grapheme_count(s.data.items.ptr, s.data.items.len);
    }
    return 0;
}

pub fn str_normalize(handle: StzStringHandle, form: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        var out_len: usize = 0;
        const result = unicode.stz_unicode_normalize(s.data.items.ptr, s.data.items.len, form, &out_len);
        if (result == null or out_len == 0) return str_new();
        defer unicode.stz_unicode_normalize_free(result, out_len);
        return str_from(result, out_len);
    }
    return str_new();
}

pub fn str_strip_marks(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        var out_len: usize = 0;
        const result = unicode.stz_unicode_strip_marks(s.data.items.ptr, s.data.items.len, &out_len);
        if (result == null or out_len == 0) return str_new();
        defer unicode.stz_unicode_strip_marks_free(result, out_len);
        return str_from(result, out_len);
    }
    return str_new();
}

// ─── Between Delimiters ───

pub fn str_between(handle: StzStringHandle, open: [*c]const u8, open_len: usize, close: [*c]const u8, close_len: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const haystack = s.slice();
        const open_needle = open[0..open_len];
        const close_needle = close[0..close_len];
        if (mem.indexOf(u8, haystack, open_needle)) |open_pos| {
            const after_open = open_pos + open_len;
            if (mem.indexOfPos(u8, haystack, after_open, close_needle)) |close_pos| {
                const between = haystack[after_open..close_pos];
                return str_from(@ptrCast(between.ptr), between.len);
            }
        }
    }
    return null;
}

pub fn str_between_nth(handle: StzStringHandle, open: [*c]const u8, open_len: usize, close: [*c]const u8, close_len: usize, nth: c_int) callconv(.c) StzStringHandle {
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
                        return str_from(bytes[after_open..j].ptr, j - after_open);
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
pub fn str_count_between(handle: StzStringHandle, open: [*c]const u8, open_len: usize, close: [*c]const u8, close_len: usize) callconv(.c) c_int {
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

// ─── Substring / CharsBetween ───

/// Extract between two codepoint positions (inclusive, 1-based from host).
pub fn str_substring(handle: StzStringHandle, from_cp: c_int, to_cp: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    const from: usize = if (from_cp >= INDEX_BASE) toInternal(@intCast(from_cp)) else return null;
    const to: usize = if (to_cp >= INDEX_BASE) toInternal(@intCast(to_cp)) else return null;
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

pub fn str_chars_between(handle: StzStringHandle, cp_from: c_int, cp_to: c_int) callconv(.c) StzStringHandle {
    // Extract characters between two codepoint positions (exclusive on both ends, 1-based from host)
    const s = handle orelse return str_new();
    const src = s.slice();
    if (cp_from < INDEX_BASE or cp_to < INDEX_BASE or cp_to <= cp_from + 1) return str_new();

    // Convert to internal 0-based, then get the range between (exclusive)
    const from_internal = toInternal(@as(i64, cp_from));
    const to_internal = toInternal(@as(i64, cp_to));
    if (to_internal <= from_internal + 1) return str_new();
    const start_cp = from_internal + 1;
    const end_cp = to_internal;

    const byte_start = s.cpToByteCached(start_cp) orelse return str_new();
    const byte_end = s.cpToByteCached(end_cp) orelse src.len;
    if (byte_start >= byte_end) return str_new();

    return str_from(src[byte_start..byte_end].ptr, byte_end - byte_start);
}

// ─── CharAtToString ───

/// Return codepoint at cp-index as UTF-8 string handle.
pub fn str_char_at_to_string(handle: StzStringHandle, cp_index: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (cp_index < INDEX_BASE) return null;
    const idx = toInternal(@as(i64, cp_index));
    const off = s.cpToByteCached(idx) orelse return null;
    if (off >= buf.len) return null;
    const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return null;
    if (off + cp_len > buf.len) return null;

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    return result;
}

// ─── Export-convention variants ───

/// Extract text between first occurrence of open and close delimiters.
pub export fn str_between_first(handle: ?*StzString, open: [*c]const u8, open_len: c_int, close: [*c]const u8, close_len: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
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
                    result.data.appendSlice(gpa, src[start..j]) catch {
                        setError(.out_of_memory);
                    };
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

/// Number of codepoints in the string.
pub export fn str_cp_count(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    return @intCast(utf8CodepointCount(src));
}

// ─── BetweenAll: return ALL substrings between delimiter pairs ───

/// Return all substrings between open/close pairs as null-delimited buffer.
/// E.g. "[a][b][c]" with "[" and "]" → "a\0b\0c"
/// Returns empty handle if no match found.
pub fn str_between_all(handle: StzStringHandle, open: [*c]const u8, open_len: usize, close: [*c]const u8, close_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    if (src.len == 0 or open_len == 0 or close_len == 0) return str_new();

    const open_s = open[0..open_len];
    const close_s = close[0..close_len];

    const result = str_new() orelse return null;
    var i: usize = 0;
    var found_any = false;

    while (i + open_len <= src.len) {
        if (mem.eql(u8, src[i..][0..open_len], open_s)) {
            const after_open = i + open_len;
            var j = after_open;
            while (j + close_len <= src.len) {
                if (mem.eql(u8, src[j..][0..close_len], close_s)) {
                    // Add null separator before second+ match
                    if (found_any) {
                        result.data.append(gpa, 0) catch break;
                    }
                    result.data.appendSlice(gpa, src[after_open..j]) catch break;
                    found_any = true;
                    i = j + close_len;
                    break;
                }
                j += 1;
            } else {
                // No close found for this open — stop
                break;
            }
            continue;
        }
        i += 1;
    }

    return result;
}

/// Return all substrings between open/close pairs with case sensitivity.
/// Returns null-delimited buffer.
pub fn str_between_all_cs(handle: StzStringHandle, open: [*c]const u8, open_len: usize, close: [*c]const u8, close_len: usize, case: c_int) callconv(.c) StzStringHandle {
    if (case != 0) {
        // Case-sensitive — use the plain version
        return str_between_all(handle, open, open_len, close, close_len);
    }

    // Case-insensitive
    const s = handle orelse return str_new();
    const src = s.slice();
    if (src.len == 0 or open_len == 0 or close_len == 0) return str_new();

    const open_s = open[0..open_len];
    const close_s = close[0..close_len];

    // Case-fold the needles
    const folded_open = casefoldAlloc(open_s) orelse return null;
    defer gpa.free(folded_open);
    const folded_close = casefoldAlloc(close_s) orelse return null;
    defer gpa.free(folded_close);
    // Case-fold the haystack
    const folded_src = casefoldAlloc(src) orelse return null;
    defer gpa.free(folded_src);

    const result = str_new() orelse return null;
    var i: usize = 0;
    var found_any = false;

    while (i + folded_open.len <= folded_src.len) {
        if (mem.eql(u8, folded_src[i..][0..folded_open.len], folded_open)) {
            const after_open = i + folded_open.len;
            var j = after_open;
            while (j + folded_close.len <= folded_src.len) {
                if (mem.eql(u8, folded_src[j..][0..folded_close.len], folded_close)) {
                    if (found_any) {
                        result.data.append(gpa, 0) catch break;
                    }
                    // Use original src bytes (not folded) for content
                    result.data.appendSlice(gpa, src[after_open..j]) catch break;
                    found_any = true;
                    i = j + folded_close.len;
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

    return result;
}

// ─── Tests ───

const testing = std.testing;

fn h(comptime s: []const u8) StzStringHandle {
    return str_from(s.ptr, s.len);
}

fn expectStr(handle: StzStringHandle, expected: []const u8) !void {
    const s = handle orelse return error.TestUnexpectedResult;
    defer str_free(s);
    try testing.expectEqualSlices(u8, expected, s.slice());
}

test "str_mid: basic byte extraction" {
    const s = h("Hello, World!");
    defer str_free(s);
    try expectStr(str_mid(s, 0, 5), "Hello");
    try expectStr(str_mid(s, 7, 5), "World");
}

test "str_mid: beyond end returns truncated" {
    const s = h("abc");
    defer str_free(s);
    try expectStr(str_mid(s, 1, 100), "bc");
}

test "str_mid: null handle returns empty" {
    try expectStr(str_mid(null, 0, 5), "");
}

test "str_left: extract prefix" {
    const s = h("Hello");
    defer str_free(s);
    try expectStr(str_left(s, 3), "Hel");
    try expectStr(str_left(s, 0), "");
    try expectStr(str_left(s, 100), "Hello");
}

test "str_right: extract suffix" {
    const s = h("Hello");
    defer str_free(s);
    try expectStr(str_right(s, 3), "llo");
    try expectStr(str_right(s, 100), "Hello");
}

test "str_trimmed: whitespace trim" {
    const s = h("  hello  ");
    defer str_free(s);
    try expectStr(str_trimmed(s), "hello");
}

test "str_nth_char: codepoint indexing" {
    // "cafe\xCC\x81" = "café" (e + combining acute)
    const s = h("abc");
    defer str_free(s);
    try expectStr(str_nth_char(s, INDEX_BASE + 0), "a");
    try expectStr(str_nth_char(s, INDEX_BASE + 1), "b");
    try expectStr(str_nth_char(s, INDEX_BASE + 2), "c");
}

test "str_nth_char: multibyte chars" {
    const s = h("\xC3\xA9\xC3\xA8"); // "éè"
    defer str_free(s);
    try expectStr(str_nth_char(s, INDEX_BASE + 0), "\xC3\xA9"); // é
    try expectStr(str_nth_char(s, INDEX_BASE + 1), "\xC3\xA8"); // è
}

test "str_slice: codepoint range extraction" {
    const s = h("Hello");
    defer str_free(s);
    try expectStr(str_slice(s, INDEX_BASE + 1, 3), "ell");
}

test "str_slice: multibyte extraction" {
    const s = h("H\xC3\xA9llo"); // "Héllo"
    defer str_free(s);
    try expectStr(str_slice(s, INDEX_BASE, 3), "H\xC3\xA9l");
}

test "str_chars: decompose into codepoints" {
    const s = h("ab\xC3\xA9"); // "abé"
    defer str_free(s);
    var count: usize = 0;
    const arr = str_chars(s, &count);
    try testing.expectEqual(@as(usize, 3), count);
    if (arr) |a| {
        // Check content before freeing
        const s0 = a[0].?.slice();
        const s1 = a[1].?.slice();
        const s2 = a[2].?.slice();
        try testing.expectEqualSlices(u8, "a", s0);
        try testing.expectEqualSlices(u8, "b", s1);
        try testing.expectEqualSlices(u8, "\xC3\xA9", s2);
        str_chars_free(a, count);
    }
}

test "str_char_at: codepoint value" {
    const s = h("A");
    defer str_free(s);
    try testing.expectEqual(@as(i32, 65), str_char_at(s, INDEX_BASE));
}

test "str_mid_cp: codepoint-based mid" {
    const s = h("H\xC3\xA9llo"); // "Héllo"
    defer str_free(s);
    try expectStr(str_mid_cp(s, INDEX_BASE + 1, 2), "\xC3\xA9l");
}

test "str_left_cp: codepoint left" {
    const s = h("\xC3\xA9\xC3\xA8\xC3\xA0"); // "éèà"
    defer str_free(s);
    try expectStr(str_left_cp(s, 2), "\xC3\xA9\xC3\xA8");
}

test "str_right_cp: codepoint right" {
    const s = h("\xC3\xA9\xC3\xA8\xC3\xA0"); // "éèà"
    defer str_free(s);
    try expectStr(str_right_cp(s, 2), "\xC3\xA8\xC3\xA0");
}

test "str_between: extract between delimiters" {
    const s = h("[hello]");
    defer str_free(s);
    try expectStr(str_between(s, "[", 1, "]", 1), "hello");
}

test "str_between: multi-char delimiters" {
    const s = h("<<content>>");
    defer str_free(s);
    try expectStr(str_between(s, "<<", 2, ">>", 2), "content");
}

test "str_between: no match returns null" {
    const s = h("no brackets here");
    defer str_free(s);
    try testing.expectEqual(@as(StzStringHandle, null), str_between(s, "[", 1, "]", 1));
}

test "str_between_nth: specific occurrence" {
    const s = h("[a][b][c]");
    defer str_free(s);
    try expectStr(str_between_nth(s, "[", 1, "]", 1, 0), "a");
    try expectStr(str_between_nth(s, "[", 1, "]", 1, 1), "b");
    try expectStr(str_between_nth(s, "[", 1, "]", 1, 2), "c");
}

test "str_count_between: count delimiter pairs" {
    const s = h("[a][b][c]");
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 3), str_count_between(s, "[", 1, "]", 1));
}

test "str_substring: inclusive range" {
    const s = h("Hello");
    defer str_free(s);
    try expectStr(str_substring(s, INDEX_BASE + 1, INDEX_BASE + 3), "ell");
}

test "str_chars_between: exclusive range" {
    const s = h("abcde");
    defer str_free(s);
    try expectStr(str_chars_between(s, INDEX_BASE, INDEX_BASE + 4), "bcd");
}

test "str_char_at_to_string: returns string" {
    const s = h("Hello");
    defer str_free(s);
    try expectStr(str_char_at_to_string(s, INDEX_BASE), "H");
    try expectStr(str_char_at_to_string(s, INDEX_BASE + 4), "o");
}

test "str_between_first: export variant" {
    const s = h("[first][second]");
    defer str_free(s);
    try expectStr(str_between_first(s, "[", 1, "]", 1), "first");
}

test "str_cp_count: codepoint counting" {
    const s = h("\xC3\xA9\xC3\xA8\xC3\xA0"); // "éèà"
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 3), str_cp_count(s));
}

test "str_grapheme_count: basic graphemes" {
    const s = h("Hello");
    defer str_free(s);
    try testing.expect(str_grapheme_count(s) >= 5);
}

test "str_between_all: multiple matches" {
    const s = h("[a][b][c]");
    defer str_free(s);
    const r = str_between_all(s, "[", 1, "]", 1);
    defer str_free(r);
    // Result should be "a\0b\0c"
    const sl = r.?.slice();
    try testing.expectEqual(@as(usize, 5), sl.len); // "a" + \0 + "b" + \0 + "c"
    try testing.expectEqual(@as(u8, 'a'), sl[0]);
    try testing.expectEqual(@as(u8, 0), sl[1]);
    try testing.expectEqual(@as(u8, 'b'), sl[2]);
    try testing.expectEqual(@as(u8, 0), sl[3]);
    try testing.expectEqual(@as(u8, 'c'), sl[4]);
}

test "str_between_all: single match" {
    const s = h("[hello]");
    defer str_free(s);
    const r = str_between_all(s, "[", 1, "]", 1);
    // expectStr frees handle, no extra defer
    try expectStr(r, "hello");
}

test "str_between_all: no match" {
    const s = h("no brackets");
    defer str_free(s);
    const r = str_between_all(s, "[", 1, "]", 1);
    try expectStr(r, "");
}

test "str_between_all: multi-char delimiters" {
    const s = h("<<first>>middle<<second>>");
    defer str_free(s);
    const r = str_between_all(s, "<<", 2, ">>", 2);
    defer str_free(r);
    const sl = r.?.slice();
    // "first\0second"
    try testing.expectEqual(@as(usize, 12), sl.len);
    try testing.expectEqualSlices(u8, "first", sl[0..5]);
    try testing.expectEqual(@as(u8, 0), sl[5]);
    try testing.expectEqualSlices(u8, "second", sl[6..12]);
}

test "str_between_all_cs: case insensitive" {
    const s = h("[A]text[B]more[C]");
    defer str_free(s);
    // Case-sensitive
    const r1 = str_between_all_cs(s, "[", 1, "]", 1, 1);
    defer str_free(r1);
    const sl1 = r1.?.slice();
    try testing.expectEqual(@as(usize, 5), sl1.len); // "A\0B\0C"
    // Case-insensitive (same result for brackets, but test the path)
    const r2 = str_between_all_cs(s, "[", 1, "]", 1, 0);
    defer str_free(r2);
    const sl2 = r2.?.slice();
    try testing.expectEqual(@as(usize, 5), sl2.len);
}
