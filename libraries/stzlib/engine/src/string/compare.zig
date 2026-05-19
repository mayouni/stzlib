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

/// Compare two strings. case=1: codepoint comparison, case=0: casefold comparison.
/// Returns -1 (s1 < s2), 0 (equal), 1 (s1 > s2), -2 (error/null).
pub fn str_compare_cs(h1: StzStringHandle, h2: StzStringHandle, case: c_int) callconv(.c) c_int {
    const s1 = h1 orelse return -2;
    const s2 = h2 orelse return -2;

    if (case == 0) {
        // CI: casefold both, then compare
        const f1 = core.casefoldAlloc(s1.slice()) orelse return -2;
        defer gpa.free(f1);
        const f2 = core.casefoldAlloc(s2.slice()) orelse return -2;
        defer gpa.free(f2);
        return compareBufs(f1, f2);
    } else {
        return compareBufs(s1.slice(), s2.slice());
    }
}

fn compareBufs(buf1: []const u8, buf2: []const u8) c_int {
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
    if (off1 < buf1.len) return 1;
    if (off2 < buf2.len) return -1;
    return 0;
}

pub fn str_compare(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    return str_compare_cs(h1, h2, 1);
}

// ─── HasPrefix / HasSuffix with count (how many times a prefix/suffix repeats) ───

pub fn str_prefix_count_cs(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize, case: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (prefix == null or prefix_len == 0 or buf.len == 0) return 0;
    const pref = prefix[0..prefix_len];

    var count: c_int = 0;
    var off: usize = 0;
    while (off + prefix_len <= buf.len) {
        const matches = if (case == 0) core.ciMatch(buf[off..][0..prefix_len], pref) else mem.eql(u8, buf[off .. off + prefix_len], pref);
        if (matches) {
            count += 1;
            off += prefix_len;
        } else {
            break;
        }
    }
    return count;
}

pub fn str_prefix_count(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize) callconv(.c) c_int {
    return str_prefix_count_cs(handle, prefix, prefix_len, 1);
}

pub fn str_suffix_count_cs(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize, case: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (suffix == null or suffix_len == 0 or buf.len == 0) return 0;
    const suf = suffix[0..suffix_len];

    var count: c_int = 0;
    var pos: usize = buf.len;
    while (pos >= suffix_len) {
        const matches = if (case == 0) core.ciMatch(buf[pos - suffix_len .. pos], suf) else mem.eql(u8, buf[pos - suffix_len .. pos], suf);
        if (matches) {
            count += 1;
            pos -= suffix_len;
        } else {
            break;
        }
    }
    return count;
}

pub fn str_suffix_count(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize) callconv(.c) c_int {
    return str_suffix_count_cs(handle, suffix, suffix_len, 1);
}

// ─── CommonPrefix / CommonSuffix between two strings ───

/// Common prefix between two strings. case=0: casefold comparison.
pub fn str_common_prefix_cs(h1: StzStringHandle, h2: StzStringHandle, case: c_int) callconv(.c) StzStringHandle {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const b1 = s1.slice();
    const b2 = s2.slice();

    if (case == 0) {
        // CI: casefold both, find common prefix length in folded, map back to b1 codepoints
        const f1 = core.casefoldAlloc(b1) orelse return null;
        defer gpa.free(f1);
        const f2 = core.casefoldAlloc(b2) orelse return null;
        defer gpa.free(f2);

        // Walk folded versions to find common prefix byte length
        var foff: usize = 0;
        while (foff < f1.len and foff < f2.len) {
            const fl1 = std.unicode.utf8ByteSequenceLength(f1[foff]) catch break;
            const fl2 = std.unicode.utf8ByteSequenceLength(f2[foff]) catch break;
            if (fl1 != fl2 or foff + fl1 > f1.len or foff + fl2 > f2.len) break;
            if (!mem.eql(u8, f1[foff..][0..fl1], f2[foff..][0..fl2])) break;
            foff += fl1;
        }
        // Count codepoints in folded prefix
        var cp_count: usize = 0;
        var off: usize = 0;
        while (off < foff and off < f1.len) {
            const l = std.unicode.utf8ByteSequenceLength(f1[off]) catch break;
            off += l;
            cp_count += 1;
        }
        // Map cp_count codepoints back to b1 byte offset
        var b1_off: usize = 0;
        var cp_i: usize = 0;
        while (cp_i < cp_count and b1_off < b1.len) {
            const l = std.unicode.utf8ByteSequenceLength(b1[b1_off]) catch break;
            b1_off += l;
            cp_i += 1;
        }
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        if (b1_off > 0) {
            result.data.appendSlice(gpa, b1[0..b1_off]) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        }
        return result;
    }

    // CS path
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

pub fn str_common_prefix(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    return str_common_prefix_cs(h1, h2, 1);
}

/// Common suffix between two strings. case=0: casefold comparison.
pub fn str_common_suffix_cs(h1: StzStringHandle, h2: StzStringHandle, case: c_int) callconv(.c) StzStringHandle {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const b1 = s1.slice();
    const b2 = s2.slice();

    if (b1.len == 0 or b2.len == 0) {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        return result;
    }

    if (case == 0) {
        // CI: casefold both, find common suffix in folded, map back
        const f1 = core.casefoldAlloc(b1) orelse return null;
        defer gpa.free(f1);
        const f2 = core.casefoldAlloc(b2) orelse return null;
        defer gpa.free(f2);

        var i: usize = 0;
        const min_len = @min(f1.len, f2.len);
        while (i < min_len) {
            if (f1[f1.len - 1 - i] != f2[f2.len - 1 - i]) break;
            i += 1;
        }
        // Adjust to codepoint boundary in folded
        const fstart = f1.len - i;
        var adj = fstart;
        while (adj < f1.len and (f1[adj] & 0xC0) == 0x80) adj += 1;
        // Count codepoints in folded suffix
        var cp_count: usize = 0;
        var off: usize = adj;
        while (off < f1.len) {
            const l = std.unicode.utf8ByteSequenceLength(f1[off]) catch break;
            off += l;
            cp_count += 1;
        }
        // Map cp_count codepoints from end of b1
        const total_cps = core.utf8CodepointCount(b1);
        const start_cp = if (total_cps >= cp_count) total_cps - cp_count else 0;
        var b1_off: usize = 0;
        var cp_i: usize = 0;
        while (cp_i < start_cp and b1_off < b1.len) {
            const l = std.unicode.utf8ByteSequenceLength(b1[b1_off]) catch break;
            b1_off += l;
            cp_i += 1;
        }
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        if (b1_off < b1.len) {
            result.data.appendSlice(gpa, b1[b1_off..]) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        }
        return result;
    }

    // CS path: walk backwards byte by byte
    var i: usize = 0;
    const min_len = @min(b1.len, b2.len);
    while (i < min_len) {
        if (b1[b1.len - 1 - i] != b2[b2.len - 1 - i]) break;
        i += 1;
    }
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

pub fn str_common_suffix(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    return str_common_suffix_cs(h1, h2, 1);
}

// ─── Common / Diff chars (set operations) ───

/// Return characters common to both strings (unique, in order of appearance in h1).
/// case=0: casefold comparison. Returns new handle.
pub fn str_common_chars_cs(h1: StzStringHandle, h2: StzStringHandle, case: c_int) callconv(.c) StzStringHandle {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const src1 = s1.slice();
    const src2 = s2.slice();

    const result = str_new() orelse return null;

    if (case == 0) {
        // CI: use codepoint-level comparison with casefold
        var seen = std.AutoHashMap(i32, void).init(gpa);
        defer seen.deinit();
        // Build set of casefolded codepoints from src2
        var set2 = std.AutoHashMap(i32, void).init(gpa);
        defer set2.deinit();
        var off2: usize = 0;
        while (off2 < src2.len) {
            const cl = std.unicode.utf8ByteSequenceLength(src2[off2]) catch break;
            if (off2 + cl > src2.len) break;
            const cp: i32 = core.decodeCodepoint(src2, off2, cl);
            const folded = unicode.stz_unicode_to_lower(cp);
            set2.put(folded, {}) catch break;
            off2 += cl;
        }
        var off1: usize = 0;
        while (off1 < src1.len) {
            const cl = std.unicode.utf8ByteSequenceLength(src1[off1]) catch break;
            if (off1 + cl > src1.len) break;
            const cp: i32 = core.decodeCodepoint(src1, off1, cl);
            const folded = unicode.stz_unicode_to_lower(cp);
            if (set2.contains(folded) and !seen.contains(folded)) {
                seen.put(folded, {}) catch break;
                result.data.appendSlice(gpa, src1[off1..][0..cl]) catch break;
            }
            off1 += cl;
        }
    } else {
        // CS: ASCII fast path
        var seen_cs: [256]bool = [_]bool{false} ** 256;
        var off: usize = 0;
        while (off < src1.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(src1[off]) catch break;
            if (off + cp_len > src1.len) break;
            if (cp_len == 1) {
                const c = src1[off];
                if (!seen_cs[c]) {
                    for (src2) |c2| {
                        if (c2 == c) {
                            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
                            seen_cs[c] = true;
                            break;
                        }
                    }
                }
            }
            off += cp_len;
        }
    }
    return result;
}

pub fn str_common_chars(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    return str_common_chars_cs(h1, h2, 1);
}

// ─── Longest common prefix/suffix (byte-level) ───

/// Longest common prefix. case=0: casefold byte comparison.
pub export fn str_longest_common_prefix_cs(h1: ?*StzString, h2: ?*StzString, case: c_int) callconv(.c) ?*StzString {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const src1 = s1.slice();
    const src2 = s2.slice();

    if (case == 0) {
        return str_common_prefix_cs(h1, h2, 0); // reuse the codepoint-aware CI version
    }

    const result = str_new() orelse return null;
    const min_len = if (src1.len < src2.len) src1.len else src2.len;
    var i: usize = 0;
    while (i < min_len and src1[i] == src2[i]) : (i += 1) {}
    result.data.appendSlice(gpa, src1[0..i]) catch {
        setError(.out_of_memory);
    };
    return result;
}

pub export fn str_longest_common_prefix(h1: ?*StzString, h2: ?*StzString) callconv(.c) ?*StzString {
    return str_longest_common_prefix_cs(h1, h2, 1);
}

/// Longest common suffix. case=0: casefold byte comparison.
pub export fn str_longest_common_suffix_cs(h1: ?*StzString, h2: ?*StzString, case: c_int) callconv(.c) ?*StzString {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const src1 = s1.slice();
    const src2 = s2.slice();

    if (case == 0) {
        return str_common_suffix_cs(h1, h2, 0);
    }

    const result = str_new() orelse return null;
    const min_len = if (src1.len < src2.len) src1.len else src2.len;
    var i: usize = 0;
    while (i < min_len and src1[src1.len - 1 - i] == src2[src2.len - 1 - i]) : (i += 1) {}
    if (i > 0) result.data.appendSlice(gpa, src1[src1.len - i ..]) catch {
        setError(.out_of_memory);
    };
    return result;
}

pub export fn str_longest_common_suffix(h1: ?*StzString, h2: ?*StzString) callconv(.c) ?*StzString {
    return str_longest_common_suffix_cs(h1, h2, 1);
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

pub export fn str_commonality_cs(handle: ?*StzString, other: ?*StzString, case: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const o = other orelse return 0;
    const src = s.slice();
    const oth = o.slice();

    if (case == 0) {
        // CI: use codepoint-level casefold comparison
        var set_src = std.AutoHashMap(i32, void).init(gpa);
        defer set_src.deinit();
        var off: usize = 0;
        while (off < src.len) {
            const cl = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
            if (off + cl > src.len) break;
            const cp: i32 = core.decodeCodepoint(src, off, cl);
            set_src.put(unicode.stz_unicode_to_lower(cp), {}) catch break;
            off += cl;
        }
        var count: c_int = 0;
        var counted = std.AutoHashMap(i32, void).init(gpa);
        defer counted.deinit();
        off = 0;
        while (off < oth.len) {
            const cl = std.unicode.utf8ByteSequenceLength(oth[off]) catch break;
            if (off + cl > oth.len) break;
            const cp: i32 = core.decodeCodepoint(oth, off, cl);
            const folded = unicode.stz_unicode_to_lower(cp);
            if (set_src.contains(folded) and !counted.contains(folded)) {
                count += 1;
                counted.put(folded, {}) catch break;
            }
            off += cl;
        }
        return count;
    }

    // CS: ASCII byte-level
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

pub export fn str_commonality(handle: ?*StzString, other: ?*StzString) callconv(.c) c_int {
    return str_commonality_cs(handle, other, 1);
}

pub export fn str_diff_chars_cs(handle: ?*StzString, other: ?*StzString, case: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const o = other orelse return null;
    const src = s.slice();
    const oth = o.slice();
    const result = str_new() orelse return null;

    if (case == 0) {
        // CI: codepoint-level casefold
        var in_oth = std.AutoHashMap(i32, void).init(gpa);
        defer in_oth.deinit();
        var off: usize = 0;
        while (off < oth.len) {
            const cl = std.unicode.utf8ByteSequenceLength(oth[off]) catch break;
            if (off + cl > oth.len) break;
            const cp: i32 = core.decodeCodepoint(oth, off, cl);
            in_oth.put(unicode.stz_unicode_to_lower(cp), {}) catch break;
            off += cl;
        }
        var added = std.AutoHashMap(i32, void).init(gpa);
        defer added.deinit();
        off = 0;
        while (off < src.len) {
            const cl = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
            if (off + cl > src.len) break;
            const cp: i32 = core.decodeCodepoint(src, off, cl);
            const folded = unicode.stz_unicode_to_lower(cp);
            if (!in_oth.contains(folded) and !added.contains(folded)) {
                result.data.appendSlice(gpa, src[off..][0..cl]) catch break;
                added.put(folded, {}) catch break;
            }
            off += cl;
        }
    } else {
        var in_other = [_]bool{false} ** 256;
        for (oth) |c| in_other[c] = true;
        var added_cs = [_]bool{false} ** 256;
        for (src) |c| {
            if (!in_other[c] and !added_cs[c]) {
                result.data.appendSlice(gpa, &[_]u8{c}) catch break;
                added_cs[c] = true;
            }
        }
    }
    return result;
}

pub export fn str_diff_chars(handle: ?*StzString, other: ?*StzString) callconv(.c) ?*StzString {
    return str_diff_chars_cs(handle, other, 1);
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

test "str_compare_cs CI" {
    const a = str_from("Hello", 5);
    const b = str_from("hello", 5);
    defer str_free(a);
    defer str_free(b);
    try std.testing.expectEqual(@as(c_int, 0), str_compare_cs(a, b, 0)); // CI: equal
    try std.testing.expect(str_compare_cs(a, b, 1) != 0); // CS: not equal
}

test "str_prefix_count_cs CI" {
    const s = str_from("AbAbAb_rest", 11);
    defer str_free(s);
    try std.testing.expectEqual(@as(c_int, 3), str_prefix_count_cs(s, "ab", 2, 0));
    try std.testing.expectEqual(@as(c_int, 0), str_prefix_count_cs(s, "ab", 2, 1)); // CS: "Ab" != "ab"
}

test "str_commonality_cs CI" {
    const a = str_from("ABC", 3);
    const b = str_from("bcd", 3);
    defer str_free(a);
    defer str_free(b);
    try std.testing.expectEqual(@as(c_int, 2), str_commonality_cs(a, b, 0)); // CI: B/b and C/c
    try std.testing.expectEqual(@as(c_int, 0), str_commonality_cs(a, b, 1)); // CS: no overlap
}
