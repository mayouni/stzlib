const std = @import("std");

// ── Advanced Splitter ───────────────────────────────────────
// Split strings by delimiters, fixed widths, predicates.
// Returns results via slot-based API (up to 256 parts).

const MAX_PARTS = 256;
const MAX_PART_LEN = 4096;

var part_buf: [MAX_PARTS][MAX_PART_LEN]u8 = undefined;
var part_lens: [MAX_PARTS]usize = undefined;
var part_count: usize = 0;

fn storePart(data: []const u8) void {
    if (part_count >= MAX_PARTS) return;
    const len = @min(data.len, MAX_PART_LEN);
    @memcpy(part_buf[part_count][0..len], data[0..len]);
    part_lens[part_count] = len;
    part_count += 1;
}

pub fn split_by_str(src_ptr: [*]const u8, src_len: usize, delim_ptr: [*]const u8, delim_len: usize) callconv(.c) i32 {
    part_count = 0;
    if (src_len == 0) return 0;
    if (delim_len == 0) {
        storePart(src_ptr[0..src_len]);
        return @intCast(part_count);
    }
    const src = src_ptr[0..src_len];
    const delim = delim_ptr[0..delim_len];
    var start: usize = 0;
    while (start <= src_len) {
        if (start + delim_len <= src_len and std.mem.eql(u8, src[start .. start + delim_len], delim)) {
            storePart(src[start - (start - (if (start > 0 and part_count == 0) 0 else start)) .. start]);
            break;
        }
        var found = false;
        var pos = start;
        while (pos + delim_len <= src_len) : (pos += 1) {
            if (std.mem.eql(u8, src[pos .. pos + delim_len], delim)) {
                storePart(src[start..pos]);
                start = pos + delim_len;
                found = true;
                break;
            }
        }
        if (!found) {
            storePart(src[start..src_len]);
            break;
        }
    }
    return @intCast(part_count);
}

pub fn split_by_width(src_ptr: [*]const u8, src_len: usize, width: i32) callconv(.c) i32 {
    part_count = 0;
    if (src_len == 0 or width <= 0) return 0;
    const w: usize = @intCast(width);
    var pos: usize = 0;
    while (pos < src_len) {
        const end = @min(pos + w, src_len);
        storePart(src_ptr[pos..end]);
        pos = end;
    }
    return @intCast(part_count);
}

pub fn split_by_any_char(src_ptr: [*]const u8, src_len: usize, chars_ptr: [*]const u8, chars_len: usize) callconv(.c) i32 {
    part_count = 0;
    if (src_len == 0) return 0;
    const src = src_ptr[0..src_len];
    const chars = chars_ptr[0..chars_len];
    var start: usize = 0;
    for (0..src_len) |i| {
        var is_delim = false;
        for (chars) |c| {
            if (src[i] == c) {
                is_delim = true;
                break;
            }
        }
        if (is_delim) {
            if (i > start) storePart(src[start..i]);
            start = i + 1;
        }
    }
    if (start < src_len) storePart(src[start..src_len]);
    return @intCast(part_count);
}

pub fn split_keep_delim(src_ptr: [*]const u8, src_len: usize, delim_ptr: [*]const u8, delim_len: usize) callconv(.c) i32 {
    part_count = 0;
    if (src_len == 0) return 0;
    if (delim_len == 0) {
        storePart(src_ptr[0..src_len]);
        return @intCast(part_count);
    }
    const src = src_ptr[0..src_len];
    const delim = delim_ptr[0..delim_len];
    var start: usize = 0;
    var pos: usize = 0;
    while (pos + delim_len <= src_len) : (pos += 1) {
        if (std.mem.eql(u8, src[pos .. pos + delim_len], delim)) {
            if (pos > start) storePart(src[start..pos]);
            storePart(delim);
            start = pos + delim_len;
            pos = start -| 1;
        }
    }
    if (start < src_len) storePart(src[start..src_len]);
    return @intCast(part_count);
}

pub fn split_limit(src_ptr: [*]const u8, src_len: usize, delim_ptr: [*]const u8, delim_len: usize, max_parts: i32) callconv(.c) i32 {
    part_count = 0;
    if (src_len == 0 or max_parts <= 0) return 0;
    if (delim_len == 0) {
        storePart(src_ptr[0..src_len]);
        return @intCast(part_count);
    }
    const src = src_ptr[0..src_len];
    const delim = delim_ptr[0..delim_len];
    const limit: usize = @intCast(max_parts);
    var start: usize = 0;
    var pos: usize = 0;
    while (pos + delim_len <= src_len and part_count + 1 < limit) : (pos += 1) {
        if (std.mem.eql(u8, src[pos .. pos + delim_len], delim)) {
            storePart(src[start..pos]);
            start = pos + delim_len;
            pos = start -| 1;
        }
    }
    if (start <= src_len) storePart(src[start..src_len]);
    return @intCast(part_count);
}

pub fn split_lines(src_ptr: [*]const u8, src_len: usize) callconv(.c) i32 {
    part_count = 0;
    if (src_len == 0) return 0;
    const src = src_ptr[0..src_len];
    var start: usize = 0;
    for (0..src_len) |i| {
        if (src[i] == '\n') {
            const end = if (i > start and src[i - 1] == '\r') i - 1 else i;
            storePart(src[start..end]);
            start = i + 1;
        }
    }
    if (start < src_len) storePart(src[start..src_len]);
    return @intCast(part_count);
}

pub fn split_words(src_ptr: [*]const u8, src_len: usize) callconv(.c) i32 {
    part_count = 0;
    if (src_len == 0) return 0;
    const src = src_ptr[0..src_len];
    var start: usize = 0;
    var in_word = false;
    for (0..src_len) |i| {
        const is_space = src[i] == ' ' or src[i] == '\t' or src[i] == '\n' or src[i] == '\r';
        if (is_space) {
            if (in_word) {
                storePart(src[start..i]);
                in_word = false;
            }
        } else {
            if (!in_word) {
                start = i;
                in_word = true;
            }
        }
    }
    if (in_word) storePart(src[start..src_len]);
    return @intCast(part_count);
}

pub fn part_at(idx: i32, out: [*]u8) callconv(.c) i32 {
    const i: usize = @intCast(idx);
    if (i >= part_count) return 0;
    const len = part_lens[i];
    @memcpy(out[0..len], part_buf[i][0..len]);
    return @intCast(len);
}

pub fn part_len_at(idx: i32) callconv(.c) i32 {
    const i: usize = @intCast(idx);
    if (i >= part_count) return 0;
    return @intCast(part_lens[i]);
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_splitter_by_str(s: [*]const u8, sl: usize, d: [*]const u8, dl: usize) callconv(.c) i32 { return split_by_str(s, sl, d, dl); }
pub export fn stz_splitter_by_width(s: [*]const u8, sl: usize, w: i32) callconv(.c) i32 { return split_by_width(s, sl, w); }
pub export fn stz_splitter_by_any_char(s: [*]const u8, sl: usize, c: [*]const u8, cl: usize) callconv(.c) i32 { return split_by_any_char(s, sl, c, cl); }
pub export fn stz_splitter_keep_delim(s: [*]const u8, sl: usize, d: [*]const u8, dl: usize) callconv(.c) i32 { return split_keep_delim(s, sl, d, dl); }
pub export fn stz_splitter_limit(s: [*]const u8, sl: usize, d: [*]const u8, dl: usize, m: i32) callconv(.c) i32 { return split_limit(s, sl, d, dl, m); }
pub export fn stz_splitter_lines(s: [*]const u8, sl: usize) callconv(.c) i32 { return split_lines(s, sl); }
pub export fn stz_splitter_words(s: [*]const u8, sl: usize) callconv(.c) i32 { return split_words(s, sl); }
pub export fn stz_splitter_part_at(i: i32, o: [*]u8) callconv(.c) i32 { return part_at(i, o); }
pub export fn stz_splitter_part_len(i: i32) callconv(.c) i32 { return part_len_at(i); }

// ── Tests ────────────────────────────────────────────────────

test "splitter: by width" {
    const count = split_by_width("HelloWorld!!", 12, 5);
    try std.testing.expectEqual(@as(i32, 3), count);
    var buf: [MAX_PART_LEN]u8 = undefined;
    const len0 = part_at(0, &buf);
    try std.testing.expectEqualStrings("Hello", buf[0..@intCast(len0)]);
    const len1 = part_at(1, &buf);
    try std.testing.expectEqualStrings("World", buf[0..@intCast(len1)]);
    const len2 = part_at(2, &buf);
    try std.testing.expectEqualStrings("!!", buf[0..@intCast(len2)]);
}

test "splitter: by any char" {
    const count = split_by_any_char("a,b;c.d", 7, ",;.", 3);
    try std.testing.expectEqual(@as(i32, 4), count);
    var buf: [MAX_PART_LEN]u8 = undefined;
    _ = part_at(0, &buf);
    try std.testing.expectEqualStrings("a", buf[0..1]);
    _ = part_at(3, &buf);
    try std.testing.expectEqualStrings("d", buf[0..1]);
}

test "splitter: lines" {
    const count = split_lines("line1\nline2\r\nline3", 18);
    try std.testing.expectEqual(@as(i32, 3), count);
    var buf: [MAX_PART_LEN]u8 = undefined;
    const len1 = part_at(1, &buf);
    try std.testing.expectEqualStrings("line2", buf[0..@intCast(len1)]);
}

test "splitter: words" {
    const count = split_words("  hello   world  ", 17);
    try std.testing.expectEqual(@as(i32, 2), count);
    var buf: [MAX_PART_LEN]u8 = undefined;
    const len0 = part_at(0, &buf);
    try std.testing.expectEqualStrings("hello", buf[0..@intCast(len0)]);
}

test "splitter: keep delimiters" {
    const count = split_keep_delim("a::b::c", 7, "::", 2);
    try std.testing.expectEqual(@as(i32, 5), count);
    var buf: [MAX_PART_LEN]u8 = undefined;
    const len0 = part_at(0, &buf);
    try std.testing.expectEqualStrings("a", buf[0..@intCast(len0)]);
    const len1 = part_at(1, &buf);
    try std.testing.expectEqualStrings("::", buf[0..@intCast(len1)]);
}

test "splitter: limit" {
    const count = split_limit("a,b,c,d,e", 9, ",", 1, 3);
    try std.testing.expectEqual(@as(i32, 3), count);
    var buf: [MAX_PART_LEN]u8 = undefined;
    const len2 = part_at(2, &buf);
    try std.testing.expectEqualStrings("c,d,e", buf[0..@intCast(len2)]);
}

test "splitter: empty input" {
    try std.testing.expectEqual(@as(i32, 0), split_by_width("", 0, 5));
    try std.testing.expectEqual(@as(i32, 0), split_words("", 0));
    try std.testing.expectEqual(@as(i32, 0), split_lines("", 0));
}
