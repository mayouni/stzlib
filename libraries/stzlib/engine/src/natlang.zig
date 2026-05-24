const std = @import("std");

// ── Natural Language Utilities ──────────────────────────────
// Word/sentence boundary detection, basic stemming, word counting,
// reading level estimation, syllable counting.

pub fn word_count(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var count: i32 = 0;
    var in_word = false;
    for (data) |c| {
        const is_ws = c == ' ' or c == '\t' or c == '\n' or c == '\r';
        if (!is_ws and !in_word) {
            count += 1;
            in_word = true;
        } else if (is_ws) {
            in_word = false;
        }
    }
    return count;
}

pub fn sentence_count(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var count: i32 = 0;
    for (0..len) |i| {
        if (data[i] == '.' or data[i] == '!' or data[i] == '?') {
            if (i + 1 >= len or data[i + 1] == ' ' or data[i + 1] == '\n' or data[i + 1] == '\r') {
                count += 1;
            }
        }
    }
    if (count == 0 and len > 0) count = 1;
    return count;
}

pub fn char_count(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    var count: i32 = 0;
    for (ptr[0..len]) |c| {
        if (c != ' ' and c != '\t' and c != '\n' and c != '\r') count += 1;
    }
    return count;
}

pub fn syllable_count_word(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var count: i32 = 0;
    var prev_vowel = false;
    for (0..len) |i| {
        const c = if (data[i] >= 'A' and data[i] <= 'Z') data[i] + 32 else data[i];
        const is_vowel = c == 'a' or c == 'e' or c == 'i' or c == 'o' or c == 'u' or c == 'y';
        if (is_vowel and !prev_vowel) count += 1;
        prev_vowel = is_vowel;
    }
    if (count == 0) count = 1;
    if (len >= 2) {
        const last = if (data[len - 1] >= 'A' and data[len - 1] <= 'Z') data[len - 1] + 32 else data[len - 1];
        if (last == 'e' and count > 1) count -= 1;
    }
    return count;
}

pub fn avg_word_len(ptr: [*]const u8, len: usize) callconv(.c) f64 {
    if (len == 0) return 0.0;
    const wc = word_count(ptr, len);
    if (wc == 0) return 0.0;
    const cc = char_count(ptr, len);
    return @as(f64, @floatFromInt(cc)) / @as(f64, @floatFromInt(wc));
}

pub fn is_uppercase_word(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    for (ptr[0..len]) |c| {
        if (c >= 'a' and c <= 'z') return 0;
    }
    return 1;
}

pub fn is_lowercase_word(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    for (ptr[0..len]) |c| {
        if (c >= 'A' and c <= 'Z') return 0;
    }
    return 1;
}

pub fn is_titlecase_word(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    if (ptr[0] < 'A' or ptr[0] > 'Z') return 0;
    for (ptr[1..len]) |c| {
        if (c >= 'A' and c <= 'Z') return 0;
    }
    return 1;
}

pub fn has_digits(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    for (ptr[0..len]) |c| {
        if (c >= '0' and c <= '9') return 1;
    }
    return 0;
}

pub fn is_all_alpha(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    for (ptr[0..len]) |c| {
        if (!((c >= 'A' and c <= 'Z') or (c >= 'a' and c <= 'z'))) return 0;
    }
    return 1;
}

pub fn is_all_alnum(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    for (ptr[0..len]) |c| {
        if (!((c >= 'A' and c <= 'Z') or (c >= 'a' and c <= 'z') or (c >= '0' and c <= '9'))) return 0;
    }
    return 1;
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_natlang_word_count(p: [*]const u8, l: usize) callconv(.c) i32 { return word_count(p, l); }
pub export fn stz_natlang_sentence_count(p: [*]const u8, l: usize) callconv(.c) i32 { return sentence_count(p, l); }
pub export fn stz_natlang_char_count(p: [*]const u8, l: usize) callconv(.c) i32 { return char_count(p, l); }
pub export fn stz_natlang_syllable_count(p: [*]const u8, l: usize) callconv(.c) i32 { return syllable_count_word(p, l); }
pub export fn stz_natlang_avg_word_len(p: [*]const u8, l: usize) callconv(.c) f64 { return avg_word_len(p, l); }
pub export fn stz_natlang_is_upper(p: [*]const u8, l: usize) callconv(.c) i32 { return is_uppercase_word(p, l); }
pub export fn stz_natlang_is_lower(p: [*]const u8, l: usize) callconv(.c) i32 { return is_lowercase_word(p, l); }
pub export fn stz_natlang_is_title(p: [*]const u8, l: usize) callconv(.c) i32 { return is_titlecase_word(p, l); }
pub export fn stz_natlang_has_digits(p: [*]const u8, l: usize) callconv(.c) i32 { return has_digits(p, l); }
pub export fn stz_natlang_is_alpha(p: [*]const u8, l: usize) callconv(.c) i32 { return is_all_alpha(p, l); }
pub export fn stz_natlang_is_alnum(p: [*]const u8, l: usize) callconv(.c) i32 { return is_all_alnum(p, l); }

// ── Tests ────────────────────────────────────────────────────

test "natlang: word_count" {
    try std.testing.expectEqual(@as(i32, 4), word_count("hello world foo bar", 19));
    try std.testing.expectEqual(@as(i32, 1), word_count("hello", 5));
    try std.testing.expectEqual(@as(i32, 0), word_count("", 0));
    try std.testing.expectEqual(@as(i32, 3), word_count("  a  b  c  ", 11));
}

test "natlang: sentence_count" {
    try std.testing.expectEqual(@as(i32, 2), sentence_count("Hello. World.", 13));
    try std.testing.expectEqual(@as(i32, 1), sentence_count("Hello!", 6));
    try std.testing.expectEqual(@as(i32, 1), sentence_count("Hello", 5));
}

test "natlang: char_count" {
    try std.testing.expectEqual(@as(i32, 10), char_count("hello world", 11));
}

test "natlang: syllable_count" {
    try std.testing.expectEqual(@as(i32, 2), syllable_count_word("hello", 5));
    try std.testing.expectEqual(@as(i32, 1), syllable_count_word("cat", 3));
    try std.testing.expectEqual(@as(i32, 3), syllable_count_word("beautiful", 9));
}

test "natlang: avg_word_len" {
    const avg = avg_word_len("hi there", 8);
    try std.testing.expect(avg > 3.0 and avg < 4.0);
}

test "natlang: case checks" {
    try std.testing.expectEqual(@as(i32, 1), is_uppercase_word("ABC", 3));
    try std.testing.expectEqual(@as(i32, 0), is_uppercase_word("Abc", 3));
    try std.testing.expectEqual(@as(i32, 1), is_lowercase_word("abc", 3));
    try std.testing.expectEqual(@as(i32, 1), is_titlecase_word("Hello", 5));
    try std.testing.expectEqual(@as(i32, 0), is_titlecase_word("hELLO", 5));
}

test "natlang: content checks" {
    try std.testing.expectEqual(@as(i32, 1), has_digits("abc123", 6));
    try std.testing.expectEqual(@as(i32, 0), has_digits("abc", 3));
    try std.testing.expectEqual(@as(i32, 1), is_all_alpha("Hello", 5));
    try std.testing.expectEqual(@as(i32, 0), is_all_alpha("Hello1", 6));
    try std.testing.expectEqual(@as(i32, 1), is_all_alnum("Hello1", 6));
}
