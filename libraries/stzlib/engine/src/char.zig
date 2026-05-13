// Softanza Engine -- Unicode Character Operations (Tier 1)
//
// Replaces QChar with Zig's std.unicode.
// All functions use C ABI for Ring FFI compatibility.

const std = @import("std");

// Extract the unicode codepoint from a UTF-8 encoded character
pub fn stz_char_unicode(utf8_char: [*c]const u8) callconv(.c) u32 {
    if (utf8_char == null) return 0;

    const byte = utf8_char[0];
    const seq_len = std.unicode.utf8ByteSequenceLength(byte) catch return 0;
    const slice: []const u8 = utf8_char[0..seq_len];
    const cp = std.unicode.utf8Decode(slice) catch return 0;
    return cp;
}

// Encode a codepoint to UTF-8, returns number of bytes written
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
    if (codepoint <= 127) {
        return if (std.ascii.isAlphabetic(@intCast(codepoint))) 1 else 0;
    }
    // For non-ASCII, use Unicode general category
    // Letters are Lu, Ll, Lt, Lm, Lo
    return if (isUnicodeLetter(codepoint)) 1 else 0;
}

pub fn stz_char_is_digit(codepoint: u32) callconv(.c) c_int {
    if (codepoint >= '0' and codepoint <= '9') return 1;
    return 0;
}

pub fn stz_char_is_upper(codepoint: u32) callconv(.c) c_int {
    if (codepoint <= 127) {
        return if (std.ascii.isUpper(@intCast(codepoint))) 1 else 0;
    }
    return 0;
}

pub fn stz_char_is_lower(codepoint: u32) callconv(.c) c_int {
    if (codepoint <= 127) {
        return if (std.ascii.isLower(@intCast(codepoint))) 1 else 0;
    }
    return 0;
}

// ─── Helpers ───

fn isUnicodeLetter(codepoint: u32) bool {
    // Basic Latin letters
    if (codepoint >= 'A' and codepoint <= 'Z') return true;
    if (codepoint >= 'a' and codepoint <= 'z') return true;
    // Latin-1 Supplement letters
    if (codepoint >= 0xC0 and codepoint <= 0xFF and codepoint != 0xD7 and codepoint != 0xF7) return true;
    // Latin Extended-A
    if (codepoint >= 0x100 and codepoint <= 0x24F) return true;
    // Arabic
    if (codepoint >= 0x0600 and codepoint <= 0x06FF) return true;
    // CJK Unified Ideographs
    if (codepoint >= 0x4E00 and codepoint <= 0x9FFF) return true;
    // Hangul Syllables
    if (codepoint >= 0xAC00 and codepoint <= 0xD7AF) return true;
    // Cyrillic
    if (codepoint >= 0x0400 and codepoint <= 0x04FF) return true;
    // Greek
    if (codepoint >= 0x0370 and codepoint <= 0x03FF) return true;
    // Hebrew
    if (codepoint >= 0x0590 and codepoint <= 0x05FF) return true;
    // Devanagari
    if (codepoint >= 0x0900 and codepoint <= 0x097F) return true;
    // Other scripts: conservatively return true for non-symbol ranges
    if (codepoint > 0xFF and codepoint < 0x10000) {
        // Exclude common non-letter ranges
        if (codepoint >= 0x2000 and codepoint <= 0x206F) return false; // General Punctuation
        if (codepoint >= 0x2070 and codepoint <= 0x209F) return false; // Superscripts
        if (codepoint >= 0x20A0 and codepoint <= 0x20CF) return false; // Currency
        if (codepoint >= 0x2100 and codepoint <= 0x214F) return false; // Letterlike Symbols
        if (codepoint >= 0x2190 and codepoint <= 0x21FF) return false; // Arrows
        if (codepoint >= 0x2200 and codepoint <= 0x22FF) return false; // Math Operators
        if (codepoint >= 0x2300 and codepoint <= 0x23FF) return false; // Misc Technical
        if (codepoint >= 0x2500 and codepoint <= 0x257F) return false; // Box Drawing
        if (codepoint >= 0x2580 and codepoint <= 0x259F) return false; // Block Elements
        if (codepoint >= 0x25A0 and codepoint <= 0x25FF) return false; // Geometric Shapes
        if (codepoint >= 0x2600 and codepoint <= 0x26FF) return false; // Misc Symbols
        if (codepoint >= 0x2700 and codepoint <= 0x27BF) return false; // Dingbats
        if (codepoint >= 0xFE00 and codepoint <= 0xFE0F) return false; // Variation Selectors
        if (codepoint >= 0xFFF0 and codepoint <= 0xFFFF) return false; // Specials
    }
    return false;
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
    // Latin-1 supplement: e-acute
    try std.testing.expectEqual(@as(c_int, 1), stz_char_is_letter(0xE9));
    // Arabic alef
    try std.testing.expectEqual(@as(c_int, 1), stz_char_is_letter(0x627));
    // CJK ideograph
    try std.testing.expectEqual(@as(c_int, 1), stz_char_is_letter(0x4E00));
    // Box drawing character (not a letter)
    try std.testing.expectEqual(@as(c_int, 0), stz_char_is_letter(0x2500));
}
