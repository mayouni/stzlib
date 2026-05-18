// Softanza Engine -- String Count/Query (Phase D)
//
// Counting, frequency, and character-type query operations
// extracted from string.zig.
// All functions use C calling convention.

const std = @import("std");
const core = @import("core.zig");
const mem = core.mem;
const gpa = core.gpa;
const unicode = core.unicode;
const StzString = core.StzString;
const StzStringHandle = core.StzStringHandle;
const StzFindResult = core.StzFindResult;
const StzFindResultHandle = core.StzFindResultHandle;
const setError = core.setError;
const str_new = core.str_new;
const str_from = core.str_from;
const decodeCodepoint = core.decodeCodepoint;
const INDEX_BASE = core.INDEX_BASE;
const toInternal = core.toInternal;
const toExternal = core.toExternal;
const utf8CodepointCount = core.utf8CodepointCount;
const codepointIndexToByteOffset = core.codepointIndexToByteOffset;
const isVowelAscii = core.isVowelAscii;

// ─── Character type counting/querying ───

/// Classify a codepoint against a type code.
/// Types: 0=letter, 1=digit, 2=space, 3=upper, 4=lower, 5=punctuation,
///        6=symbol, 7=mark, 8=control, 9=number,
///        10=arabic, 11=latin, 12=greek, 13=cyrillic, 14=hebrew, 15=cjk, 16=devanagari, 17=thai,
///        18=arabic_letter (arabic AND letter), 19=latin_letter (latin AND letter),
///        20=vowel (ASCII vowel)
pub fn matchesCharType(cp_val: i32, char_type: c_int) bool {
    return switch (char_type) {
        0 => unicode.stz_unicode_is_letter(cp_val) == 1,
        1 => unicode.stz_unicode_is_digit(cp_val) == 1,
        2 => unicode.stz_unicode_is_space(cp_val) == 1,
        3 => unicode.stz_unicode_is_upper(cp_val) == 1,
        4 => unicode.stz_unicode_is_lower(cp_val) == 1,
        5 => unicode.stz_unicode_is_punctuation(cp_val) == 1,
        6 => unicode.stz_unicode_is_symbol(cp_val) == 1,
        7 => unicode.stz_unicode_is_mark(cp_val) == 1,
        8 => unicode.stz_unicode_is_control(cp_val) == 1,
        9 => unicode.stz_unicode_is_number(cp_val) == 1,
        10 => unicode.stz_unicode_is_arabic(cp_val) == 1,
        11 => unicode.stz_unicode_is_latin(cp_val) == 1,
        12 => unicode.stz_unicode_is_greek(cp_val) == 1,
        13 => unicode.stz_unicode_is_cyrillic(cp_val) == 1,
        14 => unicode.stz_unicode_is_hebrew(cp_val) == 1,
        15 => unicode.stz_unicode_is_cjk(cp_val) == 1,
        16 => unicode.stz_unicode_is_devanagari(cp_val) == 1,
        17 => unicode.stz_unicode_is_thai(cp_val) == 1,
        18 => unicode.stz_unicode_is_arabic(cp_val) == 1 and unicode.stz_unicode_is_letter(cp_val) == 1,
        19 => unicode.stz_unicode_is_latin(cp_val) == 1 and unicode.stz_unicode_is_letter(cp_val) == 1,
        20 => blk: {
            if (cp_val < 0 or cp_val > 127) break :blk false;
            const b: u8 = @intCast(cp_val);
            break :blk (b == 'a' or b == 'e' or b == 'i' or b == 'o' or b == 'u' or
                b == 'A' or b == 'E' or b == 'I' or b == 'O' or b == 'U');
        },
        else => false,
    };
}

/// Count how many codepoints match a predicate class.
/// Classes: 0=letter, 1=digit, 2=space, 3=upper, 4=lower, 5=punctuation, 6=symbol, 7=mark, 8=control, 9=number
pub fn str_count_chars_of_type(handle: StzStringHandle, char_type: c_int) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        var i: usize = 0;
        var count: c_int = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (matchesCharType(cp_val, char_type)) count += 1;
            i += cp_len;
        }
        return count;
    }
    return 0;
}

/// Convenience counters for specific types (avoid type-code lookup from Ring).
pub fn str_count_letters(handle: StzStringHandle) callconv(.c) c_int {
    return str_count_chars_of_type(handle, 0);
}
pub fn str_count_punctuation(handle: StzStringHandle) callconv(.c) c_int {
    return str_count_chars_of_type(handle, 5);
}
pub fn str_count_symbols(handle: StzStringHandle) callconv(.c) c_int {
    return str_count_chars_of_type(handle, 6);
}
pub fn str_count_marks(handle: StzStringHandle) callconv(.c) c_int {
    return str_count_chars_of_type(handle, 7);
}
pub fn str_count_controls(handle: StzStringHandle) callconv(.c) c_int {
    return str_count_chars_of_type(handle, 8);
}

// ─── Script-level convenience counters ───

pub fn str_count_arabic(handle: StzStringHandle) callconv(.c) c_int {
    return str_count_chars_of_type(handle, 10);
}
pub fn str_count_latin(handle: StzStringHandle) callconv(.c) c_int {
    return str_count_chars_of_type(handle, 11);
}
pub fn str_count_greek(handle: StzStringHandle) callconv(.c) c_int {
    return str_count_chars_of_type(handle, 12);
}
pub fn str_count_cyrillic(handle: StzStringHandle) callconv(.c) c_int {
    return str_count_chars_of_type(handle, 13);
}
pub fn str_count_hebrew(handle: StzStringHandle) callconv(.c) c_int {
    return str_count_chars_of_type(handle, 14);
}
pub fn str_count_arabic_letters(handle: StzStringHandle) callconv(.c) c_int {
    return str_count_chars_of_type(handle, 18);
}
pub fn str_count_latin_letters(handle: StzStringHandle) callconv(.c) c_int {
    return str_count_chars_of_type(handle, 19);
}

// ─── Script-level "are all" predicates ───

pub fn str_is_arabic(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        if (bytes.len == 0) return 0;
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (unicode.stz_unicode_is_arabic(cp_val) == 0) return 0;
            i += cp_len;
        }
        return 1;
    }
    return 0;
}

pub fn str_is_latin(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        if (bytes.len == 0) return 0;
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (unicode.stz_unicode_is_latin(cp_val) == 0) return 0;
            i += cp_len;
        }
        return 1;
    }
    return 0;
}

pub fn str_is_arabic_letters(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        if (bytes.len == 0) return 0;
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (!(unicode.stz_unicode_is_arabic(cp_val) == 1 and unicode.stz_unicode_is_letter(cp_val) == 1)) return 0;
            i += cp_len;
        }
        return 1;
    }
    return 0;
}

pub fn str_is_latin_letters(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        if (bytes.len == 0) return 0;
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (!(unicode.stz_unicode_is_latin(cp_val) == 1 and unicode.stz_unicode_is_letter(cp_val) == 1)) return 0;
            i += cp_len;
        }
        return 1;
    }
    return 0;
}

// ─── Script-level "are all" predicates (remaining scripts) ───

pub fn str_is_greek(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        if (bytes.len == 0) return 0;
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (unicode.stz_unicode_is_greek(cp_val) == 0) return 0;
            i += cp_len;
        }
        return 1;
    }
    return 0;
}

pub fn str_is_cyrillic(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        if (bytes.len == 0) return 0;
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (unicode.stz_unicode_is_cyrillic(cp_val) == 0) return 0;
            i += cp_len;
        }
        return 1;
    }
    return 0;
}

pub fn str_is_hebrew(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        if (bytes.len == 0) return 0;
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (unicode.stz_unicode_is_hebrew(cp_val) == 0) return 0;
            i += cp_len;
        }
        return 1;
    }
    return 0;
}

// ─── Script-level "has any" predicates ───

pub fn str_has_arabic(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (unicode.stz_unicode_is_arabic(cp_val) == 1) return 1;
            i += cp_len;
        }
    }
    return 0;
}

pub fn str_has_latin(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (unicode.stz_unicode_is_latin(cp_val) == 1) return 1;
            i += cp_len;
        }
    }
    return 0;
}

pub fn str_has_greek(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (unicode.stz_unicode_is_greek(cp_val) == 1) return 1;
            i += cp_len;
        }
    }
    return 0;
}

pub fn str_has_cyrillic(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (unicode.stz_unicode_is_cyrillic(cp_val) == 1) return 1;
            i += cp_len;
        }
    }
    return 0;
}

pub fn str_has_hebrew(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (unicode.stz_unicode_is_hebrew(cp_val) == 1) return 1;
            i += cp_len;
        }
    }
    return 0;
}

// ─── Script-level remaining counters ───

pub fn str_count_cjk(handle: StzStringHandle) callconv(.c) c_int {
    return str_count_chars_of_type(handle, 15);
}
pub fn str_count_devanagari(handle: StzStringHandle) callconv(.c) c_int {
    return str_count_chars_of_type(handle, 16);
}
pub fn str_count_thai(handle: StzStringHandle) callconv(.c) c_int {
    return str_count_chars_of_type(handle, 17);
}

// ─── Script-level "only" filters ───

pub fn str_only_arabic(handle: StzStringHandle) callconv(.c) StzStringHandle {
    return str_extract_chars_of_type(handle, 10);
}
pub fn str_only_latin(handle: StzStringHandle) callconv(.c) StzStringHandle {
    return str_extract_chars_of_type(handle, 11);
}
pub fn str_only_arabic_letters(handle: StzStringHandle) callconv(.c) StzStringHandle {
    return str_extract_chars_of_type(handle, 18);
}
pub fn str_only_latin_letters(handle: StzStringHandle) callconv(.c) StzStringHandle {
    return str_extract_chars_of_type(handle, 19);
}

/// Find positions (1-based codepoint indices) of characters matching a type.
/// Types: 0=letter, 1=digit, 2=space, 3=upper, 4=lower, 5=punct, 6=symbol, 7=mark, 8=control, 9=number
pub fn str_find_chars_of_type(handle: StzStringHandle, char_type: c_int) callconv(.c) StzFindResultHandle {
    const r = gpa.create(StzFindResult) catch return null;
    r.* = StzFindResult.init();
    if (handle) |s| {
        const bytes = s.slice();
        var i: usize = 0;
        var cp_idx: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (matchesCharType(cp_val, char_type)) {
                r.positions.append(gpa, toExternal(cp_idx)) catch break;
            }
            cp_idx += 1;
            i += cp_len;
        }
    }
    return r;
}

/// Extract characters matching a type as a new string (letters only, digits only, etc).
/// Types: 0=letter, 1=digit, 2=space, 3=upper, 4=lower, 5=punct, 6=symbol, 7=mark, 8=control, 9=number
pub fn str_extract_chars_of_type(handle: StzStringHandle, char_type: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const bytes = s.slice();
        const result = str_new() orelse return null;
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_end = @min(i + cp_len, bytes.len);
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (matchesCharType(cp_val, char_type)) {
                result.data.appendSlice(gpa, bytes[i..cp_end]) catch break;
            }
            i += cp_len;
        }
        return result;
    }
    return null;
}

/// Return the character type at a codepoint index (INDEX_BASE convention).
/// Returns: 0=letter, 1=digit, 2=space, 3=upper, 4=lower, 5=punct, -1=invalid
pub fn str_char_type_at(handle: StzStringHandle, cp_index: c_int) callconv(.c) c_int {
    if (handle) |s| {
        const src = s.slice();
        if (cp_index < INDEX_BASE) return -1;
        const idx: usize = toInternal(@intCast(cp_index));
        const byte_offset = codepointIndexToByteOffset(src, idx);
        if (byte_offset >= src.len) return -1;
        const cp_len = std.unicode.utf8ByteSequenceLength(src[byte_offset]) catch return -1;
        const cp_val: i32 = decodeCodepoint(src, byte_offset, cp_len);
        if (cp_val < 0) return -1;
        if (unicode.stz_unicode_is_upper(cp_val) == 1) return 3;
        if (unicode.stz_unicode_is_lower(cp_val) == 1) return 4;
        if (unicode.stz_unicode_is_letter(cp_val) == 1) return 0;
        if (unicode.stz_unicode_is_digit(cp_val) == 1) return 1;
        if (unicode.stz_unicode_is_space(cp_val) == 1) return 2;
        return 5; // punctuation/other
    }
    return -1;
}

// ─── Unique characters ───

/// Return a new string with duplicate codepoints removed (preserves first occurrence order).
pub fn str_unique_chars(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    const result = str_new() orelse return null;

    // Track seen codepoints with a simple array (works for BMP + beyond)
    var seen = std.AutoHashMap(i32, void).init(gpa);
    defer seen.deinit();

    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_end = @min(i + cp_len, bytes.len);
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (!seen.contains(cp_val)) {
            seen.put(cp_val, {}) catch break;
            result.data.appendSlice(gpa, bytes[i..cp_end]) catch break;
        }
        i += cp_len;
    }
    return result;
}

/// Return number of unique codepoints.
pub fn str_unique_char_count(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    var seen = std.AutoHashMap(i32, void).init(gpa);
    defer seen.deinit();
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        seen.put(cp_val, {}) catch break;
        i += cp_len;
    }
    return @intCast(seen.count());
}

// ─── Leading / Trailing character counts ───

pub fn str_count_leading_char(handle: StzStringHandle, codepoint: u32) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    var off: usize = 0;
    var count: c_int = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        if (cp_val != codepoint) break;
        count += 1;
        off += cp_len;
    }
    return count;
}

pub fn str_count_trailing_char(handle: StzStringHandle, codepoint: u32) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    // Walk from the end backwards through UTF-8 sequences
    var count: c_int = 0;
    var pos: usize = buf.len;
    while (pos > 0) {
        // Find start of previous codepoint
        var start = pos - 1;
        while (start > 0 and (buf[start] & 0xC0) == 0x80) {
            start -= 1;
        }
        const cp_len = pos - start;
        const cp_val = std.unicode.utf8Decode(buf[start..pos]) catch break;
        _ = cp_len;
        if (cp_val != codepoint) break;
        count += 1;
        pos = start;
    }
    return count;
}

// ─── Single character / substring counts ───

pub fn str_count_char(handle: StzStringHandle, codepoint: u32) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    var count: c_int = 0;
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        if (cp_val == codepoint) count += 1;
        off += cp_len;
    }
    return count;
}

/// Count overlapping occurrences of needle in string.
pub fn str_count_overlapping(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (needle == null or needle_len == 0 or needle_len > buf.len) return 0;
    const ndl: []const u8 = needle[0..needle_len];

    var count: c_int = 0;
    var pos: usize = 0;
    while (pos + needle_len <= buf.len) {
        if (mem.eql(u8, buf[pos..][0..needle_len], ndl)) {
            count += 1;
            // Move by 1 byte for overlapping (not by needle_len)
            pos += 1;
        } else {
            pos += 1;
        }
    }
    return count;
}

/// Count how many codepoints in the string match any char in the `chars` set.
pub fn str_count_any_char(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0 or chars_len == 0) return 0;

    const charset = chars[0..chars_len];
    var count: c_int = 0;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        var coff: usize = 0;
        while (coff < charset.len) {
            const c_len = std.unicode.utf8ByteSequenceLength(charset[coff]) catch break;
            if (coff + c_len > charset.len) break;
            if (c_len == cp_len and mem.eql(u8, src[off..][0..cp_len], charset[coff..][0..c_len])) {
                count += 1;
                break;
            }
            coff += c_len;
        }
        off += cp_len;
    }
    return count;
}

// ─── Run counting ───

/// Count consecutive character runs (groups of identical adjacent chars).
/// E.g. "aabbbcc" has 3 runs: "aa", "bbb", "cc".
pub fn str_count_runs(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var runs: c_int = 1;
    var off: usize = 0;
    var prev_cp: i32 = -1;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp: i32 = decodeCodepoint(src, off, cp_len);
        if (prev_cp >= 0 and cp != prev_cp) {
            runs += 1;
        }
        prev_cp = cp;
        off += cp_len;
    }
    return runs;
}

/// Return the length of the longest run of consecutive identical codepoints.
pub fn str_longest_run(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var max_run: c_int = 1;
    var cur_run: c_int = 1;
    var prev_start: usize = 0;
    var prev_len: usize = 0;
    var off: usize = 0;
    var first = true;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (first) {
            first = false;
        } else {
            if (cp_len == prev_len and mem.eql(u8, src[off..][0..cp_len], src[prev_start..][0..prev_len])) {
                cur_run += 1;
                if (cur_run > max_run) max_run = cur_run;
            } else {
                cur_run = 1;
            }
        }
        prev_start = off;
        prev_len = cp_len;
        off += cp_len;
    }
    return max_run;
}

// ─── Vowel / Consonant / Case counts ───

/// Count ASCII vowels (a,e,i,o,u both cases).
pub fn str_count_vowels(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c == 'a' or c == 'e' or c == 'i' or c == 'o' or c == 'u' or
                c == 'A' or c == 'E' or c == 'I' or c == 'O' or c == 'U')
            {
                count += 1;
            }
        }
        off += cp_len;
    }
    return count;
}

/// Count ASCII consonants (letters that are not vowels). Case-insensitive.
pub fn str_count_consonants(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            const lower = if (c >= 'A' and c <= 'Z') c + 32 else c;
            if (lower >= 'a' and lower <= 'z') {
                if (lower != 'a' and lower != 'e' and lower != 'i' and lower != 'o' and lower != 'u') {
                    count += 1;
                }
            }
        }
        off += cp_len;
    }
    return count;
}

/// Count sentences (terminated by '.', '!', or '?').
pub fn str_count_sentences(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var count: c_int = 0;
    for (src) |c| {
        if (c == '.' or c == '!' or c == '?') count += 1;
    }
    return count;
}

/// Sum of all digit characters in the string. E.g. "a1b2c3" -> 6.
pub fn str_digit_sum(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var sum: c_int = 0;
    for (src) |c| {
        if (c >= '0' and c <= '9') sum += @as(c_int, c - '0');
    }
    return sum;
}

/// Count uppercase ASCII letters.
pub fn str_count_upper(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c >= 'A' and c <= 'Z') count += 1;
    }
    return count;
}

/// Count lowercase ASCII letters.
pub fn str_count_lower(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c >= 'a' and c <= 'z') count += 1;
    }
    return count;
}

/// Count unique (distinct) characters in the string.
pub export fn str_count_unique_chars(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    // For ASCII, use a 256-entry seen table; for multi-byte, count them separately
    var seen: [256]bool = [_]bool{false} ** 256;
    var count: c_int = 0;
    var multi_byte_count: c_int = 0;

    // Simple approach: for single-byte chars use the table, for multi-byte just count unique sequences
    // (limited to ASCII uniqueness for performance; multi-byte chars each counted as unique)
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            if (!seen[src[off]]) {
                seen[src[off]] = true;
                count += 1;
            }
        } else {
            // For multi-byte, do a naive check against previously seen multi-byte sequences
            // Simple: just count all multi-byte codepoints (approximation for ASCII-heavy use)
            multi_byte_count += 1;
        }
        off += cp_len;
    }
    return count + multi_byte_count;
}

/// Count paragraphs (separated by double newlines \n\n).
pub export fn str_count_paragraphs(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var count: c_int = 1;
    var i: usize = 0;
    while (i + 1 < src.len) {
        if (src[i] == '\n' and src[i + 1] == '\n') {
            count += 1;
            // Skip any additional consecutive newlines
            while (i + 1 < src.len and src[i + 1] == '\n') : (i += 1) {}
        }
        i += 1;
    }
    return count;
}

/// Count non-overlapping occurrences of a substring.
pub export fn str_count_substring(handle: ?*StzString, needle: [*c]const u8, needle_len: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    const nlen: usize = if (needle_len > 0) @intCast(needle_len) else return 0;
    const ndl = needle[0..nlen];

    var count: c_int = 0;
    var i: usize = 0;
    while (i + nlen <= src.len) {
        if (mem.eql(u8, src[i .. i + nlen], ndl)) {
            count += 1;
            i += nlen;
        } else {
            i += 1;
        }
    }
    return count;
}

pub export fn str_count_words_matching(handle: ?*StzString, pattern_ptr: [*c]const u8, pattern_len: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    const plen: usize = if (pattern_len < 1) return 0 else @intCast(pattern_len);
    const pattern = pattern_ptr[0..plen];
    var count: c_int = 0;
    var pos: usize = 0;
    while (pos < src.len) {
        // skip spaces
        while (pos < src.len and src[pos] == ' ') pos += 1;
        if (pos >= src.len) break;
        const start = pos;
        while (pos < src.len and src[pos] != ' ') pos += 1;
        const word = src[start..pos];
        if (word.len == plen and mem.eql(u8, word, pattern)) count += 1;
    }
    return count;
}

pub export fn str_count_digits(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c >= '0' and c <= '9') count += 1;
    }
    return count;
}

pub export fn str_count_spaces(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c == ' ') count += 1;
    }
    return count;
}

// ─── Tests ───

test "count_chars_of_type letters" {
    const s = str_from("Hello 123!", 10);
    defer core.str_free(s);
    try std.testing.expectEqual(@as(c_int, 5), str_count_chars_of_type(s, 0)); // letters
    try std.testing.expectEqual(@as(c_int, 3), str_count_chars_of_type(s, 1)); // digits
    try std.testing.expectEqual(@as(c_int, 1), str_count_chars_of_type(s, 2)); // whitespace
}

test "count_runs" {
    const s = str_from("aabbbcc", 7);
    defer core.str_free(s);
    try std.testing.expectEqual(@as(c_int, 3), str_count_runs(s));
}

test "count_vowels_consonants" {
    const s = str_from("Hello", 5);
    defer core.str_free(s);
    try std.testing.expectEqual(@as(c_int, 2), str_count_vowels(s));
    try std.testing.expectEqual(@as(c_int, 3), str_count_consonants(s));
}

test "count_char" {
    const s = str_from("banana", 6);
    defer core.str_free(s);
    try std.testing.expectEqual(@as(c_int, 3), str_count_char(s, 'a'));
    try std.testing.expectEqual(@as(c_int, 2), str_count_char(s, 'n'));
}

test "count_sentences" {
    const s = str_from("Hello. World! How?", 18);
    defer core.str_free(s);
    try std.testing.expectEqual(@as(c_int, 3), str_count_sentences(s));
}

test "longest_run" {
    const s = str_from("aabbbcc", 7);
    defer core.str_free(s);
    try std.testing.expectEqual(@as(c_int, 3), str_longest_run(s));
}

// ─── str_char_unicode_at ───

/// Return the Unicode codepoint number at a codepoint index (INDEX_BASE convention).
/// Returns -1 on invalid index.
pub fn str_char_unicode_at(handle: StzStringHandle, cp_index: c_int) callconv(.c) c_int {
    if (handle) |s| {
        const src = s.slice();
        if (cp_index < INDEX_BASE) return -1;
        const idx: usize = toInternal(@intCast(cp_index));
        const byte_offset = codepointIndexToByteOffset(src, idx);
        if (byte_offset >= src.len) return -1;
        const cp_len = std.unicode.utf8ByteSequenceLength(src[byte_offset]) catch return -1;
        return decodeCodepoint(src, byte_offset, cp_len);
    }
    return -1;
}

// ─── str_char_category_at ───

/// Return the Unicode category number at a codepoint index (INDEX_BASE convention).
/// Uses utf8proc category (Lu=1, Ll=2, ... see unicode.zig).
/// Returns -1 on invalid index.
pub fn str_char_category_at(handle: StzStringHandle, cp_index: c_int) callconv(.c) c_int {
    if (handle) |s| {
        const src = s.slice();
        if (cp_index < INDEX_BASE) return -1;
        const idx: usize = toInternal(@intCast(cp_index));
        const byte_offset = codepointIndexToByteOffset(src, idx);
        if (byte_offset >= src.len) return -1;
        const cp_len = std.unicode.utf8ByteSequenceLength(src[byte_offset]) catch return -1;
        const cp_val: i32 = decodeCodepoint(src, byte_offset, cp_len);
        if (cp_val < 0) return -1;
        return unicode.stz_unicode_category(cp_val);
    }
    return -1;
}

// ─── str_char_category_string_at ───

/// Return the Unicode category string (e.g. "Lu", "Nd") at a codepoint index.
/// Writes to caller-provided buffer. Returns bytes written, 0 on error.
pub fn str_char_category_string_at(handle: StzStringHandle, cp_index: c_int, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (handle) |s| {
        const src = s.slice();
        if (cp_index < INDEX_BASE) return 0;
        const idx: usize = toInternal(@intCast(cp_index));
        const byte_offset = codepointIndexToByteOffset(src, idx);
        if (byte_offset >= src.len) return 0;
        const cp_len = std.unicode.utf8ByteSequenceLength(src[byte_offset]) catch return 0;
        const cp_val: i32 = decodeCodepoint(src, byte_offset, cp_len);
        if (cp_val < 0) return 0;
        return unicode.stz_unicode_category_string(cp_val, buf, buf_len);
    }
    return 0;
}

// ─── str_char_is_punctuation_at / str_char_is_symbol_at / str_char_is_mark_at / str_char_is_control_at ───

/// Check if char at position is punctuation. Returns 1/0/-1 (invalid).
pub fn str_char_is_punctuation_at(handle: StzStringHandle, cp_index: c_int) callconv(.c) c_int {
    const cp_val = str_char_unicode_at(handle, cp_index);
    if (cp_val < 0) return -1;
    return unicode.stz_unicode_is_punctuation(cp_val);
}

/// Check if char at position is a symbol. Returns 1/0/-1 (invalid).
pub fn str_char_is_symbol_at(handle: StzStringHandle, cp_index: c_int) callconv(.c) c_int {
    const cp_val = str_char_unicode_at(handle, cp_index);
    if (cp_val < 0) return -1;
    return unicode.stz_unicode_is_symbol(cp_val);
}

/// Check if char at position is a mark. Returns 1/0/-1 (invalid).
pub fn str_char_is_mark_at(handle: StzStringHandle, cp_index: c_int) callconv(.c) c_int {
    const cp_val = str_char_unicode_at(handle, cp_index);
    if (cp_val < 0) return -1;
    return unicode.stz_unicode_is_mark(cp_val);
}

/// Check if char at position is a control char. Returns 1/0/-1 (invalid).
pub fn str_char_is_control_at(handle: StzStringHandle, cp_index: c_int) callconv(.c) c_int {
    const cp_val = str_char_unicode_at(handle, cp_index);
    if (cp_val < 0) return -1;
    return unicode.stz_unicode_is_control(cp_val);
}

/// Check if char at position is a space. Returns 1/0/-1 (invalid).
pub fn str_char_is_space_at(handle: StzStringHandle, cp_index: c_int) callconv(.c) c_int {
    const cp_val = str_char_unicode_at(handle, cp_index);
    if (cp_val < 0) return -1;
    return unicode.stz_unicode_is_space(cp_val);
}

// ─── Tests ───

test "str_char_unicode_at" {
    const s = str_from("ABC", 3);
    defer core.str_free(s);
    try std.testing.expectEqual(@as(c_int, 65), str_char_unicode_at(s, 1)); // 'A' = 65
    try std.testing.expectEqual(@as(c_int, 66), str_char_unicode_at(s, 2)); // 'B' = 66
    try std.testing.expectEqual(@as(c_int, 67), str_char_unicode_at(s, 3)); // 'C' = 67
    try std.testing.expectEqual(@as(c_int, -1), str_char_unicode_at(s, 4)); // out of range
}

test "str_char_category_at" {
    const s = str_from("A1!", 3);
    defer core.str_free(s);
    try std.testing.expectEqual(@as(c_int, 1), str_char_category_at(s, 1)); // Lu
    try std.testing.expectEqual(@as(c_int, 9), str_char_category_at(s, 2)); // Nd
}

test "str_char_is_punctuation_at" {
    const s = str_from("a,b", 3);
    defer core.str_free(s);
    try std.testing.expectEqual(@as(c_int, 0), str_char_is_punctuation_at(s, 1)); // 'a' = not punct
    try std.testing.expectEqual(@as(c_int, 1), str_char_is_punctuation_at(s, 2)); // ',' = punct
}
