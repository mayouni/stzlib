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
/// start_cp uses INDEX_BASE convention. cp_count is a length (not a position).
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
        const internal: c_int = @intCast(toInternal(cp_index));
        const byte_off = unicode.stz_unicode_cp_to_byte(s.data.items.ptr, s.data.items.len, internal);
        if (byte_off < 0) return -1;
        return unicode.stz_unicode_iterate(s.data.items.ptr, s.data.items.len, @intCast(byte_off));
    }
    return -1;
}

pub fn str_mid_cp(handle: StzStringHandle, cp_start: c_int, cp_count_arg: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const internal_start: c_int = @intCast(toInternal(cp_start));
        const byte_start = unicode.stz_unicode_cp_to_byte(src.ptr, src.len, internal_start);
        if (byte_start < 0) return str_new();
        const byte_end = unicode.stz_unicode_cp_to_byte(src.ptr, src.len, internal_start + cp_count_arg);
        const end: usize = if (byte_end < 0) src.len else @intCast(byte_end);
        const start: usize = @intCast(byte_start);
        return str_from(src[start..end].ptr, end - start);
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
        // right_cp: start from (total - count), expressed in INDEX_BASE convention
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

/// Extract between two codepoint positions (inclusive, INDEX_BASE convention).
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
    // Extract characters between two codepoint positions (exclusive on both ends, INDEX_BASE convention)
    const s = handle orelse return str_new();
    const src = s.slice();
    if (cp_from < INDEX_BASE or cp_to < INDEX_BASE or cp_to <= cp_from + 1) return str_new();

    // Convert to internal 0-based, then get the range between (exclusive)
    const from_internal: c_int = @intCast(toInternal(@intCast(cp_from)));
    const to_internal: c_int = @intCast(toInternal(@intCast(cp_to)));
    const start_cp = from_internal + 1;
    const count_cp = to_internal - from_internal - 1;
    if (count_cp <= 0) return str_new();

    const byte_start = unicode.stz_unicode_cp_to_byte(src.ptr, src.len, start_cp);
    if (byte_start < 0) return str_new();
    const byte_end = unicode.stz_unicode_cp_to_byte(src.ptr, src.len, start_cp + count_cp);
    const end: usize = if (byte_end < 0) src.len else @intCast(byte_end);
    const start: usize = @intCast(byte_start);
    if (start >= end) return str_new();

    return str_from(src[start..end].ptr, end - start);
}

// ─── CharAtToString ───

/// Return codepoint at cp-index as UTF-8 string handle.
pub fn str_char_at_to_string(handle: StzStringHandle, cp_index: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    const idx: usize = if (cp_index >= INDEX_BASE) toInternal(@intCast(cp_index)) else return null;

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
