const std = @import("std");

// ── Pattern Engine ──────────────────────────────────────────
// Pattern matching and detection for strings: repeated patterns,
// palindromes, arithmetic/geometric sequences in numeric lists,
// pattern extraction.

const MAX_PATTERN_LEN = 1024;
var pattern_buf: [MAX_PATTERN_LEN]u8 = undefined;
var pattern_len: usize = 0;

pub fn is_palindrome(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len <= 1) return 1;
    const data = ptr[0..len];
    var i: usize = 0;
    var j: usize = len - 1;
    while (i < j) : ({
        i += 1;
        j -= 1;
    }) {
        if (data[i] != data[j]) return 0;
    }
    return 1;
}

pub fn find_repeat_len(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var period: usize = 1;
    while (period <= len / 2) : (period += 1) {
        var matches = true;
        for (0..len) |i| {
            if (data[i] != data[i % period]) {
                matches = false;
                break;
            }
        }
        if (matches) return @intCast(period);
    }
    return @intCast(len);
}

pub fn count_repeats(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const period: usize = @intCast(find_repeat_len(ptr, len));
    if (period == len) return 1;
    return @intCast(len / period);
}

pub fn extract_repeat(ptr: [*]const u8, len: usize, out: [*]u8) callconv(.c) i32 {
    if (len == 0) return 0;
    const period: usize = @intCast(find_repeat_len(ptr, len));
    const copy_len = @min(period, MAX_PATTERN_LEN);
    @memcpy(out[0..copy_len], ptr[0..copy_len]);
    return @intCast(copy_len);
}

pub fn has_prefix_pattern(src_ptr: [*]const u8, src_len: usize, pat_ptr: [*]const u8, pat_len: usize) callconv(.c) i32 {
    if (pat_len == 0 or pat_len > src_len) return 0;
    return if (std.mem.eql(u8, src_ptr[0..pat_len], pat_ptr[0..pat_len])) 1 else 0;
}

pub fn has_suffix_pattern(src_ptr: [*]const u8, src_len: usize, pat_ptr: [*]const u8, pat_len: usize) callconv(.c) i32 {
    if (pat_len == 0 or pat_len > src_len) return 0;
    return if (std.mem.eql(u8, src_ptr[src_len - pat_len .. src_len], pat_ptr[0..pat_len])) 1 else 0;
}

pub fn is_arithmetic_seq(vals: [*]const f64, count: usize) callconv(.c) i32 {
    if (count <= 2) return 1;
    const diff = vals[1] - vals[0];
    for (2..count) |i| {
        if (@abs(vals[i] - vals[i - 1] - diff) > 1e-9) return 0;
    }
    return 1;
}

pub fn arithmetic_diff(vals: [*]const f64, count: usize) callconv(.c) f64 {
    if (count < 2) return 0.0;
    return vals[1] - vals[0];
}

pub fn is_geometric_seq(vals: [*]const f64, count: usize) callconv(.c) i32 {
    if (count <= 2) return 1;
    if (vals[0] == 0.0) return 0;
    const ratio = vals[1] / vals[0];
    for (2..count) |i| {
        if (vals[i - 1] == 0.0) return 0;
        if (@abs(vals[i] / vals[i - 1] - ratio) > 1e-9) return 0;
    }
    return 1;
}

pub fn geometric_ratio(vals: [*]const f64, count: usize) callconv(.c) f64 {
    if (count < 2 or vals[0] == 0.0) return 0.0;
    return vals[1] / vals[0];
}

pub fn is_constant_seq(vals: [*]const f64, count: usize) callconv(.c) i32 {
    if (count <= 1) return 1;
    for (1..count) |i| {
        if (@abs(vals[i] - vals[0]) > 1e-9) return 0;
    }
    return 1;
}

pub fn count_pattern_occurrences(src_ptr: [*]const u8, src_len: usize, pat_ptr: [*]const u8, pat_len: usize) callconv(.c) i32 {
    if (pat_len == 0 or pat_len > src_len) return 0;
    const src = src_ptr[0..src_len];
    const pat = pat_ptr[0..pat_len];
    var count: i32 = 0;
    var pos: usize = 0;
    while (pos + pat_len <= src_len) : (pos += 1) {
        if (std.mem.eql(u8, src[pos .. pos + pat_len], pat)) {
            count += 1;
            pos += pat_len - 1;
        }
    }
    return count;
}

pub fn longest_common_prefix(a_ptr: [*]const u8, a_len: usize, b_ptr: [*]const u8, b_len: usize) callconv(.c) i32 {
    const min_len = @min(a_len, b_len);
    for (0..min_len) |i| {
        if (a_ptr[i] != b_ptr[i]) return @intCast(i);
    }
    return @intCast(min_len);
}

pub fn longest_common_suffix(a_ptr: [*]const u8, a_len: usize, b_ptr: [*]const u8, b_len: usize) callconv(.c) i32 {
    const min_len = @min(a_len, b_len);
    for (0..min_len) |i| {
        if (a_ptr[a_len - 1 - i] != b_ptr[b_len - 1 - i]) return @intCast(i);
    }
    return @intCast(min_len);
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_pattern_is_palindrome(p: [*]const u8, l: usize) callconv(.c) i32 { return is_palindrome(p, l); }
pub export fn stz_pattern_repeat_len(p: [*]const u8, l: usize) callconv(.c) i32 { return find_repeat_len(p, l); }
pub export fn stz_pattern_repeat_count(p: [*]const u8, l: usize) callconv(.c) i32 { return count_repeats(p, l); }
pub export fn stz_pattern_extract_repeat(p: [*]const u8, l: usize, o: [*]u8) callconv(.c) i32 { return extract_repeat(p, l, o); }
pub export fn stz_pattern_has_prefix(s: [*]const u8, sl: usize, p: [*]const u8, pl: usize) callconv(.c) i32 { return has_prefix_pattern(s, sl, p, pl); }
pub export fn stz_pattern_has_suffix(s: [*]const u8, sl: usize, p: [*]const u8, pl: usize) callconv(.c) i32 { return has_suffix_pattern(s, sl, p, pl); }
pub export fn stz_pattern_is_arith(v: [*]const f64, c: usize) callconv(.c) i32 { return is_arithmetic_seq(v, c); }
pub export fn stz_pattern_arith_diff(v: [*]const f64, c: usize) callconv(.c) f64 { return arithmetic_diff(v, c); }
pub export fn stz_pattern_is_geo(v: [*]const f64, c: usize) callconv(.c) i32 { return is_geometric_seq(v, c); }
pub export fn stz_pattern_geo_ratio(v: [*]const f64, c: usize) callconv(.c) f64 { return geometric_ratio(v, c); }
pub export fn stz_pattern_is_const(v: [*]const f64, c: usize) callconv(.c) i32 { return is_constant_seq(v, c); }
pub export fn stz_pattern_count_occ(s: [*]const u8, sl: usize, p: [*]const u8, pl: usize) callconv(.c) i32 { return count_pattern_occurrences(s, sl, p, pl); }
pub export fn stz_pattern_lcp(a: [*]const u8, al: usize, b: [*]const u8, bl: usize) callconv(.c) i32 { return longest_common_prefix(a, al, b, bl); }
pub export fn stz_pattern_lcs(a: [*]const u8, al: usize, b: [*]const u8, bl: usize) callconv(.c) i32 { return longest_common_suffix(a, al, b, bl); }

// ── Tests ────────────────────────────────────────────────────

test "pattern: palindrome" {
    try std.testing.expectEqual(@as(i32, 1), is_palindrome("abcba", 5));
    try std.testing.expectEqual(@as(i32, 0), is_palindrome("abcde", 5));
    try std.testing.expectEqual(@as(i32, 1), is_palindrome("a", 1));
    try std.testing.expectEqual(@as(i32, 1), is_palindrome("", 0));
}

test "pattern: repeat detection" {
    try std.testing.expectEqual(@as(i32, 2), find_repeat_len("abababab", 8));
    try std.testing.expectEqual(@as(i32, 4), count_repeats("abababab", 8));
    try std.testing.expectEqual(@as(i32, 1), find_repeat_len("aaaa", 4));
    try std.testing.expectEqual(@as(i32, 5), find_repeat_len("hello", 5));
}

test "pattern: extract repeat" {
    var buf: [MAX_PATTERN_LEN]u8 = undefined;
    const len = extract_repeat("abcabc", 6, &buf);
    try std.testing.expectEqualStrings("abc", buf[0..@intCast(len)]);
}

test "pattern: prefix/suffix" {
    try std.testing.expectEqual(@as(i32, 1), has_prefix_pattern("hello world", 11, "hello", 5));
    try std.testing.expectEqual(@as(i32, 0), has_prefix_pattern("hello world", 11, "world", 5));
    try std.testing.expectEqual(@as(i32, 1), has_suffix_pattern("hello world", 11, "world", 5));
}

test "pattern: arithmetic sequence" {
    const arith = [_]f64{ 2, 4, 6, 8, 10 };
    try std.testing.expectEqual(@as(i32, 1), is_arithmetic_seq(&arith, 5));
    try std.testing.expectEqual(@as(f64, 2.0), arithmetic_diff(&arith, 5));
    const non_arith = [_]f64{ 1, 2, 4, 7 };
    try std.testing.expectEqual(@as(i32, 0), is_arithmetic_seq(&non_arith, 4));
}

test "pattern: geometric sequence" {
    const geo = [_]f64{ 2, 6, 18, 54 };
    try std.testing.expectEqual(@as(i32, 1), is_geometric_seq(&geo, 4));
    try std.testing.expectEqual(@as(f64, 3.0), geometric_ratio(&geo, 4));
}

test "pattern: constant sequence" {
    const c = [_]f64{ 5, 5, 5, 5 };
    try std.testing.expectEqual(@as(i32, 1), is_constant_seq(&c, 4));
    const nc = [_]f64{ 5, 5, 6, 5 };
    try std.testing.expectEqual(@as(i32, 0), is_constant_seq(&nc, 4));
}

test "pattern: count occurrences" {
    try std.testing.expectEqual(@as(i32, 3), count_pattern_occurrences("abcabcabc", 9, "abc", 3));
    try std.testing.expectEqual(@as(i32, 0), count_pattern_occurrences("hello", 5, "xyz", 3));
}

test "pattern: longest common prefix/suffix" {
    try std.testing.expectEqual(@as(i32, 4), longest_common_prefix("abcdef", 6, "abcdxy", 6));
    try std.testing.expectEqual(@as(i32, 3), longest_common_suffix("abcxyz", 6, "defxyz", 6));
}
