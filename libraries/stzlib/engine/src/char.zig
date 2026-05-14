// Softanza Engine -- Unicode Character Operations (Tier 1)
//
// Delegates to utf8proc via unicode.zig for full Unicode coverage.
// All functions use C ABI for Ring FFI compatibility.

const std = @import("std");
const unicode = @import("unicode.zig");

pub fn stz_char_unicode(utf8_char: [*c]const u8) callconv(.c) u32 {
    if (utf8_char == null) return 0;
    const byte = utf8_char[0];
    const seq_len = std.unicode.utf8ByteSequenceLength(byte) catch return 0;
    const slice: []const u8 = utf8_char[0..seq_len];
    const cp = std.unicode.utf8Decode(slice) catch return 0;
    return cp;
}

pub fn stz_char_to_utf8(codepoint: u32, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (buf == null or buf_len == 0) return 0;
    const cp: u21 = std.math.cast(u21, codepoint) orelse return 0;
    const len = std.unicode.utf8CodepointSequenceLength(cp) catch return 0;
    if (len > buf_len) return 0;
    var out: [4]u8 = undefined;
    const written = std.unicode.utf8Encode(cp, &out) catch return 0;
    @memcpy(buf[0..written], out[0..written]);
    return written;
}

pub fn stz_char_is_letter(codepoint: u32) callconv(.c) c_int {
    return unicode.stz_unicode_is_letter(@intCast(codepoint));
}

pub fn stz_char_is_digit(codepoint: u32) callconv(.c) c_int {
    return unicode.stz_unicode_is_digit(@intCast(codepoint));
}

pub fn stz_char_is_upper(codepoint: u32) callconv(.c) c_int {
    return unicode.stz_unicode_is_upper(@intCast(codepoint));
}

pub fn stz_char_is_lower(codepoint: u32) callconv(.c) c_int {
    return unicode.stz_unicode_is_lower(@intCast(codepoint));
}

// ─── Tests ───

test "char unicode from ascii" {
    try std.testing.expectEqual(@as(u32, 'A'), stz_char_unicode("A"));
    try std.testing.expectEqual(@as(u32, 'z'), stz_char_unicode("z"));
    try std.testing.expectEqual(@as(u32, '0'), stz_char_unicode("0"));
}

test "char unicode from utf8" {
    // e-acute: U+00E9 = 0xC3 0xA9
    try std.testing.expectEqual(@as(u32, 0xE9), stz_char_unicode("\xC3\xA9"));
    // Arabic alef: U+0627 = 0xD8 0xA7
    try std.testing.expectEqual(@as(u32, 0x627), stz_char_unicode("\xD8\xA7"));
}

test "char to utf8" {
    var buf: [4]u8 = undefined;
    const len = stz_char_to_utf8('A', &buf, 4);
    try std.testing.expectEqual(@as(usize, 1), len);
    try std.testing.expectEqual(@as(u8, 'A'), buf[0]);

    // e-acute: U+00E9
    const len2 = stz_char_to_utf8(0xE9, &buf, 4);
    try std.testing.expectEqual(@as(usize, 2), len2);
    try std.testing.expectEqual(@as(u8, 0xC3), buf[0]);
    try std.testing.expectEqual(@as(u8, 0xA9), buf[1]);
}

test "char classification" {
    try std.testing.expectEqual(@as(c_int, 1), stz_char_is_letter('A'));
    try std.testing.expectEqual(@as(c_int, 1), stz_char_is_letter('z'));
    try std.testing.expectEqual(@as(c_int, 0), stz_char_is_letter('5'));
    try std.testing.expectEqual(@as(c_int, 0), stz_char_is_letter(' '));

    try std.testing.expectEqual(@as(c_int, 1), stz_char_is_digit('0'));
    try std.testing.expectEqual(@as(c_int, 1), stz_char_is_digit('9'));
    try std.testing.expectEqual(@as(c_int, 0), stz_char_is_digit('A'));

    try std.testing.expectEqual(@as(c_int, 1), stz_char_is_upper('A'));
    try std.testing.expectEqual(@as(c_int, 0), stz_char_is_upper('a'));
    try std.testing.expectEqual(@as(c_int, 1), stz_char_is_lower('a'));
    try std.testing.expectEqual(@as(c_int, 0), stz_char_is_lower('A'));
}

test "unicode letter detection" {
    try std.testing.expectEqual(@as(c_int, 1), stz_char_is_letter(0xE9)); // e-acute
    try std.testing.expectEqual(@as(c_int, 1), stz_char_is_letter(0x627)); // Arabic alef
    try std.testing.expectEqual(@as(c_int, 1), stz_char_is_letter(0x4E00)); // CJK
    try std.testing.expectEqual(@as(c_int, 0), stz_char_is_letter(0x2500)); // Box drawing
}

test "unicode case detection non-ascii" {
    try std.testing.expectEqual(@as(c_int, 1), stz_char_is_upper(0x391)); // Greek Alpha
    try std.testing.expectEqual(@as(c_int, 1), stz_char_is_lower(0x3B1)); // Greek alpha
    try std.testing.expectEqual(@as(c_int, 1), stz_char_is_upper(0x410)); // Cyrillic A
    try std.testing.expectEqual(@as(c_int, 1), stz_char_is_lower(0x430)); // Cyrillic a
}
