const std = @import("std");

// ── String Art ──────────────────────────────────────────────
// Text boxing, alignment, padding, centering, visual formatting.

const MAX_LINE = 4096;
var out_buf: [MAX_LINE]u8 = undefined;
var out_len: usize = 0;

pub fn pad_left(src_ptr: [*]const u8, src_len: usize, total_width: i32, pad_char: u8, out: [*]u8) callconv(.c) i32 {
    if (total_width <= 0) return 0;
    const tw: usize = @intCast(total_width);
    if (src_len >= tw) {
        @memcpy(out[0..src_len], src_ptr[0..src_len]);
        return @intCast(src_len);
    }
    const pad_count = tw - src_len;
    @memset(out[0..pad_count], pad_char);
    @memcpy(out[pad_count .. pad_count + src_len], src_ptr[0..src_len]);
    return @intCast(tw);
}

pub fn pad_right(src_ptr: [*]const u8, src_len: usize, total_width: i32, pad_char: u8, out: [*]u8) callconv(.c) i32 {
    if (total_width <= 0) return 0;
    const tw: usize = @intCast(total_width);
    if (src_len >= tw) {
        @memcpy(out[0..src_len], src_ptr[0..src_len]);
        return @intCast(src_len);
    }
    @memcpy(out[0..src_len], src_ptr[0..src_len]);
    @memset(out[src_len..tw], pad_char);
    return @intCast(tw);
}

pub fn center(src_ptr: [*]const u8, src_len: usize, total_width: i32, pad_char: u8, out: [*]u8) callconv(.c) i32 {
    if (total_width <= 0) return 0;
    const tw: usize = @intCast(total_width);
    if (src_len >= tw) {
        @memcpy(out[0..src_len], src_ptr[0..src_len]);
        return @intCast(src_len);
    }
    const pad_total = tw - src_len;
    const left_pad = pad_total / 2;
    const right_pad = pad_total - left_pad;
    @memset(out[0..left_pad], pad_char);
    @memcpy(out[left_pad .. left_pad + src_len], src_ptr[0..src_len]);
    @memset(out[left_pad + src_len .. left_pad + src_len + right_pad], pad_char);
    return @intCast(tw);
}

pub fn repeat_str(src_ptr: [*]const u8, src_len: usize, count: i32, out: [*]u8) callconv(.c) i32 {
    if (count <= 0 or src_len == 0) return 0;
    const n: usize = @intCast(count);
    const total = @min(src_len * n, MAX_LINE);
    var pos: usize = 0;
    while (pos + src_len <= total) {
        @memcpy(out[pos .. pos + src_len], src_ptr[0..src_len]);
        pos += src_len;
    }
    if (pos < total) {
        @memcpy(out[pos..total], src_ptr[0 .. total - pos]);
    }
    return @intCast(total);
}

pub fn box_line(src_ptr: [*]const u8, src_len: usize, width: i32, border: u8, out: [*]u8) callconv(.c) i32 {
    if (width <= 2) return 0;
    const w: usize = @intCast(width);
    const inner = w - 2;
    out[0] = border;
    if (src_len >= inner) {
        @memcpy(out[1 .. 1 + inner], src_ptr[0..inner]);
    } else {
        @memcpy(out[1 .. 1 + src_len], src_ptr[0..src_len]);
        @memset(out[1 + src_len .. 1 + inner], ' ');
    }
    out[w - 1] = border;
    return @intCast(w);
}

pub fn box_top(width: i32, corner: u8, horiz: u8, out: [*]u8) callconv(.c) i32 {
    if (width <= 2) return 0;
    const w: usize = @intCast(width);
    out[0] = corner;
    @memset(out[1 .. w - 1], horiz);
    out[w - 1] = corner;
    return @intCast(w);
}

pub fn indent(src_ptr: [*]const u8, src_len: usize, spaces: i32, out: [*]u8) callconv(.c) i32 {
    if (spaces <= 0) {
        @memcpy(out[0..src_len], src_ptr[0..src_len]);
        return @intCast(src_len);
    }
    const sp: usize = @intCast(spaces);
    @memset(out[0..sp], ' ');
    @memcpy(out[sp .. sp + src_len], src_ptr[0..src_len]);
    return @intCast(sp + src_len);
}

pub fn truncate_ellipsis(src_ptr: [*]const u8, src_len: usize, max_width: i32, out: [*]u8) callconv(.c) i32 {
    if (max_width <= 0) return 0;
    const mw: usize = @intCast(max_width);
    if (src_len <= mw) {
        @memcpy(out[0..src_len], src_ptr[0..src_len]);
        return @intCast(src_len);
    }
    if (mw <= 3) {
        @memset(out[0..mw], '.');
        return @intCast(mw);
    }
    @memcpy(out[0 .. mw - 3], src_ptr[0 .. mw - 3]);
    out[mw - 3] = '.';
    out[mw - 2] = '.';
    out[mw - 1] = '.';
    return @intCast(mw);
}

pub fn visible_len(src_ptr: [*]const u8, src_len: usize) callconv(.c) i32 {
    _ = src_ptr;
    return @intCast(src_len);
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_stringart_pad_left(s: [*]const u8, sl: usize, w: i32, c: u8, o: [*]u8) callconv(.c) i32 { return pad_left(s, sl, w, c, o); }
pub export fn stz_stringart_pad_right(s: [*]const u8, sl: usize, w: i32, c: u8, o: [*]u8) callconv(.c) i32 { return pad_right(s, sl, w, c, o); }
pub export fn stz_stringart_center(s: [*]const u8, sl: usize, w: i32, c: u8, o: [*]u8) callconv(.c) i32 { return center(s, sl, w, c, o); }
pub export fn stz_stringart_repeat(s: [*]const u8, sl: usize, n: i32, o: [*]u8) callconv(.c) i32 { return repeat_str(s, sl, n, o); }
pub export fn stz_stringart_box_line(s: [*]const u8, sl: usize, w: i32, b: u8, o: [*]u8) callconv(.c) i32 { return box_line(s, sl, w, b, o); }
pub export fn stz_stringart_box_top(w: i32, c: u8, h: u8, o: [*]u8) callconv(.c) i32 { return box_top(w, c, h, o); }
pub export fn stz_stringart_indent(s: [*]const u8, sl: usize, sp: i32, o: [*]u8) callconv(.c) i32 { return indent(s, sl, sp, o); }
pub export fn stz_stringart_truncate(s: [*]const u8, sl: usize, mw: i32, o: [*]u8) callconv(.c) i32 { return truncate_ellipsis(s, sl, mw, o); }
pub export fn stz_stringart_visible_len(s: [*]const u8, sl: usize) callconv(.c) i32 { return visible_len(s, sl); }

// ── Tests ────────────────────────────────────────────────────

test "stringart: pad_left" {
    var buf: [64]u8 = undefined;
    const len = pad_left("hi", 2, 6, ' ', &buf);
    try std.testing.expectEqualStrings("    hi", buf[0..@intCast(len)]);
}

test "stringart: pad_right" {
    var buf: [64]u8 = undefined;
    const len = pad_right("hi", 2, 6, '.', &buf);
    try std.testing.expectEqualStrings("hi....", buf[0..@intCast(len)]);
}

test "stringart: center" {
    var buf: [64]u8 = undefined;
    const len = center("hi", 2, 8, ' ', &buf);
    try std.testing.expectEqualStrings("   hi   ", buf[0..@intCast(len)]);
}

test "stringart: repeat" {
    var buf: [64]u8 = undefined;
    const len = repeat_str("ab", 2, 3, &buf);
    try std.testing.expectEqualStrings("ababab", buf[0..@intCast(len)]);
}

test "stringart: box_top" {
    var buf: [64]u8 = undefined;
    const len = box_top(10, '+', '-', &buf);
    try std.testing.expectEqualStrings("+--------+", buf[0..@intCast(len)]);
}

test "stringart: box_line" {
    var buf: [64]u8 = undefined;
    const len = box_line("hi", 2, 10, '|', &buf);
    try std.testing.expectEqualStrings("|hi      |", buf[0..@intCast(len)]);
}

test "stringart: indent" {
    var buf: [64]u8 = undefined;
    const len = indent("hello", 5, 4, &buf);
    try std.testing.expectEqualStrings("    hello", buf[0..@intCast(len)]);
}

test "stringart: truncate_ellipsis" {
    var buf: [64]u8 = undefined;
    const len = truncate_ellipsis("hello world", 11, 8, &buf);
    try std.testing.expectEqualStrings("hello...", buf[0..@intCast(len)]);
    const len2 = truncate_ellipsis("hi", 2, 8, &buf);
    try std.testing.expectEqualStrings("hi", buf[0..@intCast(len2)]);
}
