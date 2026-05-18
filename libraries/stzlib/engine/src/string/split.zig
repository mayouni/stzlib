// Softanza Engine -- String Split/Word/Line/Partition (Phase D)
//
// Split, word, line, partition, and chunk operations extracted
// from string.zig. All functions use C calling convention.

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
const decodeCodepoint = core.decodeCodepoint;
const ciMatch = core.ciMatch;
const INDEX_BASE = core.INDEX_BASE;

// ─── Split by separator ───

pub fn str_split_count(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize) callconv(.c) c_int {
    return str_split_count_cs(handle, sep, sep_len, 1);
}

pub fn str_split_get(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize, index: c_int) callconv(.c) StzStringHandle {
    return str_split_get_cs(handle, sep, sep_len, index, 1);
}

/// Unified split_count with case sensitivity parameter.
pub fn str_split_count_cs(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize, case: c_int) callconv(.c) c_int {
    if (handle) |s| {
        if (sep == null or sep_len == 0) return 1;
        const hay = s.slice();
        const d = sep[0..sep_len];
        var count: c_int = 1;
        var pos: usize = 0;
        while (pos + d.len <= hay.len) {
            const matches = if (case == 0) ciMatch(hay[pos..][0..d.len], d) else mem.eql(u8, hay[pos..][0..d.len], d);
            if (matches) {
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

/// Unified split_get with case sensitivity parameter.
pub fn str_split_get_cs(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize, index: c_int, case: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        if (sep == null or sep_len == 0 or index < 0) return null;
        const hay = s.slice();
        const d = sep[0..sep_len];
        const target: usize = @intCast(index);
        var part: usize = 0;
        var start: usize = 0;
        var pos: usize = 0;
        while (pos + d.len <= hay.len) {
            const matches = if (case == 0) ciMatch(hay[pos..][0..d.len], d) else mem.eql(u8, hay[pos..][0..d.len], d);
            if (matches) {
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

// ─── Lines ───

/// Count lines (splits by \n). A string with no newlines = 1 line.
pub fn str_lines_count(handle: StzStringHandle) callconv(.c) c_int {
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

/// Split string by lines (LF, CR, CRLF). Returns count of lines.
pub fn str_lines_split_count(handle: StzStringHandle) callconv(.c) c_int {
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

/// Get nth line (1-based from host, converted to 0-based internally). Returns new handle. Splits by LF/CR/CRLF.
pub fn str_line_at(handle: StzStringHandle, line_index: c_int) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    if (line_index < INDEX_BASE) return null;
    const target: usize = @intCast(line_index - INDEX_BASE);

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
                return str_from(bytes[line_start..i_pos].ptr, i_pos - line_start);
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

/// Count the number of lines (separated by \n). Pub export variant.
pub export fn str_count_lines(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;
    var count: c_int = 1;
    for (src) |c| {
        if (c == '\n') count += 1;
    }
    return count;
}

/// Sort lines alphabetically (by raw byte order). Returns new handle with sorted lines
/// joined by \n. Splits by LF/CR/CRLF, emits LF.
pub fn str_sort_lines(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    if (bytes.len == 0) return str_new();

    // Collect line slices
    var lines = std.ArrayListUnmanaged([]const u8){};
    defer lines.deinit(gpa);

    var line_start: usize = 0;
    var i: usize = 0;
    while (i < bytes.len) {
        if (bytes[i] == '\r') {
            lines.append(gpa, bytes[line_start..i]) catch return null;
            if (i + 1 < bytes.len and bytes[i + 1] == '\n') i += 1;
            line_start = i + 1;
        } else if (bytes[i] == '\n') {
            lines.append(gpa, bytes[line_start..i]) catch return null;
            line_start = i + 1;
        }
        i += 1;
    }
    if (line_start <= bytes.len) {
        lines.append(gpa, bytes[line_start..bytes.len]) catch return null;
    }

    // Sort
    const items = lines.items;
    std.mem.sort([]const u8, items, {}, struct {
        fn lessThan(_: void, a: []const u8, b: []const u8) bool {
            return std.mem.order(u8, a, b) == .lt;
        }
    }.lessThan);

    // Join with \n
    const result = str_new() orelse return null;
    for (items, 0..) |line, idx| {
        if (idx > 0) result.data.append(gpa, '\n') catch {
            core.str_free(result);
            return null;
        };
        result.data.appendSlice(gpa, line) catch {
            core.str_free(result);
            return null;
        };
    }
    result.invalidateCache();
    return result;
}

/// Deduplicate lines, preserving order of first occurrence. Returns new handle
/// with unique lines joined by \n.
pub fn str_unique_lines(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    if (bytes.len == 0) return str_new();

    // Collect line slices
    var lines = std.ArrayListUnmanaged([]const u8){};
    defer lines.deinit(gpa);

    var line_start: usize = 0;
    var i: usize = 0;
    while (i < bytes.len) {
        if (bytes[i] == '\r') {
            lines.append(gpa, bytes[line_start..i]) catch return null;
            if (i + 1 < bytes.len and bytes[i + 1] == '\n') i += 1;
            line_start = i + 1;
        } else if (bytes[i] == '\n') {
            lines.append(gpa, bytes[line_start..i]) catch return null;
            line_start = i + 1;
        }
        i += 1;
    }
    if (line_start <= bytes.len) {
        lines.append(gpa, bytes[line_start..bytes.len]) catch return null;
    }

    // Deduplicate using a hashmap for O(n) lookup
    var seen = std.StringHashMap(void).init(gpa);
    defer seen.deinit();

    var unique = std.ArrayListUnmanaged([]const u8){};
    defer unique.deinit(gpa);

    for (lines.items) |line| {
        const entry = seen.getOrPut(line) catch return null;
        if (!entry.found_existing) {
            unique.append(gpa, line) catch return null;
        }
    }

    // Join with \n
    const result = str_new() orelse return null;
    for (unique.items, 0..) |line, idx| {
        if (idx > 0) result.data.append(gpa, '\n') catch {
            core.str_free(result);
            return null;
        };
        result.data.appendSlice(gpa, line) catch {
            core.str_free(result);
            return null;
        };
    }
    result.invalidateCache();
    return result;
}

// ─── Words ───

/// Count words (sequences of non-whitespace separated by whitespace).
pub fn str_word_count(handle: StzStringHandle) callconv(.c) c_int {
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

/// Count words (Unicode-aware). Alternate implementation using utf8Decode.
pub fn str_count_words(handle: StzStringHandle) callconv(.c) c_int {
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

/// Get nth word (1-based from host, converted to 0-based internally), words separated by whitespace (ASCII fast-path).
pub fn str_word_at(handle: StzStringHandle, word_index: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    const target: usize = if (word_index >= INDEX_BASE) @intCast(word_index - INDEX_BASE) else return null;

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

/// Get nth word (1-based from host, converted to 0-based internally), Unicode-aware whitespace.
pub fn str_nth_word(handle: StzStringHandle, n: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    if (n < INDEX_BASE) return str_new();
    const target: usize = @intCast(n - INDEX_BASE);

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
                    return str_from(src[word_start..off].ptr, off - word_start);
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
        return str_from(src[word_start..off].ptr, off - word_start);
    }

    return str_new();
}

pub export fn str_first_word(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    var pos: usize = 0;
    while (pos < src.len and src[pos] == ' ') pos += 1;
    while (pos < src.len and src[pos] != ' ') {
        result.data.appendSlice(gpa, &[_]u8{src[pos]}) catch break;
        pos += 1;
    }
    return result;
}

pub export fn str_last_word(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    if (src.len == 0) return result;
    var end: usize = src.len;
    while (end > 0 and src[end - 1] == ' ') end -= 1;
    if (end == 0) return result;
    var start: usize = end;
    while (start > 0 and src[start - 1] != ' ') start -= 1;
    result.data.appendSlice(gpa, src[start..end]) catch {
        setError(.out_of_memory);
    };
    return result;
}

/// Swap two words at given indices (1-based from host, converted to 0-based internally). Words separated by spaces.
pub export fn str_swap_words(handle: ?*StzString, idx1: c_int, idx2: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const pos1: usize = if (idx1 >= INDEX_BASE) @intCast(idx1 - INDEX_BASE) else return result;
    const pos2: usize = if (idx2 >= INDEX_BASE) @intCast(idx2 - INDEX_BASE) else return result;

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
        result.data.appendSlice(gpa, src) catch {
            setError(.out_of_memory);
        };
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

pub export fn str_sentence_count(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c == '.' or c == '!' or c == '?') count += 1;
    }
    return count;
}

// ─── Partition ───

/// Split string at first occurrence of separator into [before, separator, after].
/// Returns the "before" part.
pub fn str_partition(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const needle = if (sep_len > 0) sep[0..sep_len] else return str_from(src.ptr, src.len);

    // Find first occurrence
    if (mem.indexOf(u8, src, needle)) |pos| {
        return str_from(src.ptr, pos);
    }
    // Not found: return full string
    return str_from(src.ptr, src.len);
}

/// Get the "after" part of a partition (everything after first occurrence of separator).
pub fn str_partition_after(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const needle = if (sep_len > 0) sep[0..sep_len] else return str_new();

    if (mem.indexOf(u8, src, needle)) |pos| {
        const after_start = pos + needle.len;
        return str_from(src.ptr + after_start, src.len - after_start);
    }
    return str_new();
}

/// Split string at LAST occurrence of separator. Returns the "before" part.
pub fn str_rpartition(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const needle = if (sep_len > 0) sep[0..sep_len] else return str_new();

    // Find last occurrence
    if (mem.lastIndexOf(u8, src, needle)) |pos| {
        return str_from(src.ptr, pos);
    }
    return str_new();
}

/// Get the "after" part of a rpartition (everything after last occurrence of separator).
pub fn str_rpartition_after(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const needle = if (sep_len > 0) sep[0..sep_len] else return str_from(src.ptr, src.len);

    if (mem.lastIndexOf(u8, src, needle)) |pos| {
        const after_start = pos + needle.len;
        return str_from(src.ptr + after_start, src.len - after_start);
    }
    // Not found: return full string
    return str_from(src.ptr, src.len);
}

// ─── Chunk ───

/// Return the nth chunk (1-based from host, converted to 0-based internally) when string is split into chunks of `size` codepoints.
/// Last chunk may be shorter. Returns null if out of range.
pub fn str_chunk(handle: StzStringHandle, size: c_int, n: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or size <= 0 or n < INDEX_BASE) return null;

    const sz: usize = @intCast(size);
    const idx: usize = @intCast(n - INDEX_BASE);
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
    return str_from(src[start..].ptr, off - start);
}

// ─── Chars split ───

/// Split string into individual codepoint strings, null-separated.
pub export fn str_chars_split(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
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

// ─── Private helpers ───

fn isWhitespace(c: u8) bool {
    return c == ' ' or c == '\t' or c == '\n' or c == '\r';
}

// ─── Tests ───

const testing = std.testing;
const str_free = core.str_free;
const str_data = core.str_data;
const str_size = core.str_size;

test "split_count" {
    const s = str_from("a,b,c", 5);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 3), str_split_count(s, ",", 1));
}

test "split_count_cs" {
    const s = str_from("aXbXc", 5);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 3), str_split_count_cs(s, "X", 1, 1));
    // case insensitive: "x" matches "X"
    try testing.expectEqual(@as(c_int, 3), str_split_count_cs(s, "x", 1, 0));
}

test "split_get" {
    const s = str_from("hello world foo", 15);
    defer str_free(s);
    const w0 = str_split_get(s, " ", 1, 0);
    defer str_free(w0);
    try testing.expect(w0 != null);
    try testing.expectEqualStrings("hello", w0.?.slice());

    const w2 = str_split_get(s, " ", 1, 2);
    defer str_free(w2);
    try testing.expect(w2 != null);
    try testing.expectEqualStrings("foo", w2.?.slice());
}

test "split_get_cs" {
    const s = str_from("AaBbAaCc", 8);
    defer str_free(s);
    // Case sensitive: split by "Aa"
    const cs0 = str_split_get_cs(s, "Aa", 2, 0, 1);
    defer str_free(cs0);
    try testing.expect(cs0 != null);
    try testing.expectEqualStrings("", cs0.?.slice());

    const cs1 = str_split_get_cs(s, "Aa", 2, 1, 1);
    defer str_free(cs1);
    try testing.expect(cs1 != null);
    try testing.expectEqualStrings("Bb", cs1.?.slice());
}

test "lines_count" {
    const s = str_from("line1\nline2\nline3", 17);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 3), str_lines_count(s));

    const s2 = str_from("no newline", 10);
    defer str_free(s2);
    try testing.expectEqual(@as(c_int, 1), str_lines_count(s2));

    // Null handle
    try testing.expectEqual(@as(c_int, 0), str_lines_count(null));
}

test "lines_split_count_crlf" {
    const s = str_from("a\r\nb\rc\nd", 8);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 4), str_lines_split_count(s));
}

test "line_at" {
    const s = str_from("first\nsecond\nthird", 18);
    defer str_free(s);

    const l1 = str_line_at(s, 1);
    defer str_free(l1);
    try testing.expect(l1 != null);
    try testing.expectEqualStrings("first", l1.?.slice());

    const l3 = str_line_at(s, 3);
    defer str_free(l3);
    try testing.expect(l3 != null);
    try testing.expectEqualStrings("third", l3.?.slice());

    // Out of range
    try testing.expect(str_line_at(s, 6) == null);
}

test "count_lines_export" {
    const s = str_from("a\nb\nc", 5);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 3), str_count_lines(s));
}

test "word_count" {
    const s = str_from("hello  world  foo", 17);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 3), str_word_count(s));
}

test "count_words" {
    const s = str_from("  one  two  three  ", 19);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 3), str_count_words(s));
}

test "word_at" {
    const s = str_from("  alpha  beta  gamma  ", 22);
    defer str_free(s);

    const w1 = str_word_at(s, 1);
    defer str_free(w1);
    try testing.expect(w1 != null);
    try testing.expectEqualStrings("alpha", w1.?.slice());

    const w3 = str_word_at(s, 3);
    defer str_free(w3);
    try testing.expect(w3 != null);
    try testing.expectEqualStrings("gamma", w3.?.slice());
}

test "nth_word" {
    const s = str_from("one two three", 13);
    defer str_free(s);

    const w2 = str_nth_word(s, 2);
    defer str_free(w2);
    try testing.expect(w2 != null);
    try testing.expectEqualStrings("two", w2.?.slice());
}

test "first_word" {
    const s = str_from("  hello world", 13);
    defer str_free(s);
    const fw = str_first_word(s);
    defer str_free(fw);
    try testing.expect(fw != null);
    try testing.expectEqualStrings("hello", fw.?.slice());
}

test "last_word" {
    const s = str_from("hello world  ", 13);
    defer str_free(s);
    const lw = str_last_word(s);
    defer str_free(lw);
    try testing.expect(lw != null);
    try testing.expectEqualStrings("world", lw.?.slice());
}

test "swap_words" {
    const s = str_from("one two three", 13);
    defer str_free(s);
    const sw = str_swap_words(s, 1, 3);
    defer str_free(sw);
    try testing.expect(sw != null);
    try testing.expectEqualStrings("three two one", sw.?.slice());
}

test "sentence_count" {
    const s = str_from("Hello. World! How?", 18);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 3), str_sentence_count(s));
}

test "partition" {
    const s = str_from("hello=world=foo", 15);
    defer str_free(s);

    const before = str_partition(s, "=", 1);
    defer str_free(before);
    try testing.expect(before != null);
    try testing.expectEqualStrings("hello", before.?.slice());

    const after = str_partition_after(s, "=", 1);
    defer str_free(after);
    try testing.expect(after != null);
    try testing.expectEqualStrings("world=foo", after.?.slice());
}

test "rpartition" {
    const s = str_from("hello=world=foo", 15);
    defer str_free(s);

    const before = str_rpartition(s, "=", 1);
    defer str_free(before);
    try testing.expect(before != null);
    try testing.expectEqualStrings("hello=world", before.?.slice());

    const after = str_rpartition_after(s, "=", 1);
    defer str_free(after);
    try testing.expect(after != null);
    try testing.expectEqualStrings("foo", after.?.slice());
}

test "chunk" {
    const s = str_from("abcdefgh", 8);
    defer str_free(s);

    const c1 = str_chunk(s, 3, 1);
    defer str_free(c1);
    try testing.expect(c1 != null);
    try testing.expectEqualStrings("abc", c1.?.slice());

    const c3 = str_chunk(s, 3, 3);
    defer str_free(c3);
    try testing.expect(c3 != null);
    try testing.expectEqualStrings("gh", c3.?.slice()); // last chunk shorter

    // Out of range
    try testing.expect(str_chunk(s, 3, 6) == null);
}

test "chars_split" {
    const s = str_from("abc", 3);
    defer str_free(s);
    const cs = str_chars_split(s);
    defer str_free(cs);
    try testing.expect(cs != null);
    // "a\x00b\x00c"
    try testing.expectEqual(@as(usize, 5), cs.?.slice().len);
    try testing.expectEqual(@as(u8, 'a'), cs.?.slice()[0]);
    try testing.expectEqual(@as(u8, 0), cs.?.slice()[1]);
    try testing.expectEqual(@as(u8, 'b'), cs.?.slice()[2]);
}
