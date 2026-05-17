// Softanza Engine -- String Compare/Set Operations (Phase D)
//
// Comparison, common prefix/suffix, commonality, and set-difference
// operations extracted from string.zig.
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
const decodeCodepoint = core.decodeCodepoint;
const utf8CodepointCount = core.utf8CodepointCount;

// ─── Compare ───

pub fn str_compare(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
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

// ─── HasPrefix / HasSuffix with count (how many times a prefix/suffix repeats) ───

pub fn str_prefix_count(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize) callconv(.c) c_int {
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

pub fn str_suffix_count(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize) callconv(.c) c_int {
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

pub fn str_common_prefix(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
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

pub fn str_common_suffix(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
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

// ─── Common / Diff chars (set operations) ───

/// Return characters common to both strings (unique, in order of appearance in h1).
/// Returns new handle.
pub fn str_common_chars(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const src1 = s1.slice();
    const src2 = s2.slice();

    const result = str_new() orelse return null;
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

// ─── Longest common prefix/suffix (byte-level) ───

/// Longest common prefix between two handles.
pub export fn str_longest_common_prefix(h1: ?*StzString, h2: ?*StzString) callconv(.c) ?*StzString {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const src1 = s1.slice();
    const src2 = s2.slice();
    const result = str_new() orelse return null;

    const min_len = if (src1.len < src2.len) src1.len else src2.len;
    var i: usize = 0;
    while (i < min_len and src1[i] == src2[i]) : (i += 1) {}
    result.data.appendSlice(gpa, src1[0..i]) catch {
        setError(.out_of_memory);
    };
    return result;
}

/// Longest common suffix between two handles.
pub export fn str_longest_common_suffix(h1: ?*StzString, h2: ?*StzString) callconv(.c) ?*StzString {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const src1 = s1.slice();
    const src2 = s2.slice();
    const result = str_new() orelse return null;

    const min_len = if (src1.len < src2.len) src1.len else src2.len;
    var i: usize = 0;
    while (i < min_len and src1[src1.len - 1 - i] == src2[src2.len - 1 - i]) : (i += 1) {}
    if (i > 0) result.data.appendSlice(gpa, src1[src1.len - i ..]) catch {
        setError(.out_of_memory);
    };
    return result;
}

// ─── Hamming weight ───

/// Hamming weight: count of 1-bits across all bytes.
pub export fn str_hamming_weight(handle: ?*StzString) callconv(.c) c_int {
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

// ─── Commonality / Diff ───

pub export fn str_commonality(handle: ?*StzString, other: ?*StzString) callconv(.c) c_int {
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

pub export fn str_diff_chars(handle: ?*StzString, other: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const o = other orelse return null;
    const src = s.slice();
    const oth = o.slice();
    const result = str_new() orelse return null;
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

// ─── Tests ───

const str_data = core.str_data;
const str_size = core.str_size;
const str_free = core.str_free;

test "str_compare basic" {
    const a = str_from("abc", 3);
    const b = str_from("abd", 3);
    defer str_free(a);
    defer str_free(b);
    try std.testing.expectEqual(@as(c_int, -1), str_compare(a, b));
    try std.testing.expectEqual(@as(c_int, 0), str_compare(a, a));
}

test "str_prefix_count" {
    const s = str_from("ababab_rest", 11);
    defer str_free(s);
    try std.testing.expectEqual(@as(c_int, 3), str_prefix_count(s, "ab", 2));
}

test "str_suffix_count" {
    const s = str_from("rest_ababab", 11);
    defer str_free(s);
    try std.testing.expectEqual(@as(c_int, 3), str_suffix_count(s, "ab", 2));
}

test "str_common_prefix basic" {
    const a = str_from("hello world", 11);
    const b = str_from("hello there", 11);
    defer str_free(a);
    defer str_free(b);
    const r = str_common_prefix(a, b);
    defer str_free(r);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello "));
}

test "str_hamming_weight" {
    const s = str_from("A", 1); // 0x41 = 0100_0001 => 2 bits
    defer str_free(s);
    try std.testing.expectEqual(@as(c_int, 2), str_hamming_weight(s));
}

test "str_commonality" {
    const a = str_from("abc", 3);
    const b = str_from("bcd", 3);
    defer str_free(a);
    defer str_free(b);
    try std.testing.expectEqual(@as(c_int, 2), str_commonality(a, b)); // 'b','c'
}
