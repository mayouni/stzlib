// Softanza Engine -- String Inspect/Predicate (Phase D)
//
// Boolean predicate / check / classification functions extracted
// from string.zig.  All functions use C calling convention.

const std = @import("std");
const core = @import("core.zig");
const mem = core.mem;
const gpa = core.gpa;
const unicode = core.unicode;
const StzString = core.StzString;
const StzStringHandle = core.StzStringHandle;
const str_new = core.str_new;
const str_from = core.str_from;
const str_free = core.str_free;
const decodeCodepoint = core.decodeCodepoint;
const utf8CodepointCount = core.utf8CodepointCount;
const codepointIndexToByteOffset = core.codepointIndexToByteOffset;

// ─── str_is_empty ───

/// Returns 1 if string is empty (0 codepoints), 0 otherwise.
pub fn str_is_empty(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        return if (s.slice().len == 0) 1 else 0;
    }
    return 1; // null handle considered empty
}

// ─── str_is_numeric ───

/// Check if the string contains only digits. Returns 1 or 0.
pub fn str_is_numeric(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        if (bytes.len == 0) return 0;
        for (bytes) |b| {
            if (b < '0' or b > '9') return 0;
        }
        return 1;
    }
    return 0;
}

// ─── str_is_alpha ───

/// Check if the string contains only letters. Returns 1 or 0.
pub fn str_is_alpha(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        if (bytes.len == 0) return 0;
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (unicode.stz_unicode_is_letter(cp_val) != 1) return 0;
            i += cp_len;
        }
        return 1;
    }
    return 0;
}

// ─── str_is_palindrome ───

/// Check if the string is a palindrome (codepoint-level). Returns 1 or 0.
pub fn str_is_palindrome(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const src = s.slice();
        if (src.len == 0) return 1;
        // Count codepoints and build byte offset array
        const cp_count = utf8CodepointCount(src);
        if (cp_count <= 1) return 1;
        // Compare first with last, etc.
        var left: usize = 0;
        var right: usize = cp_count - 1;
        while (left < right) {
            const left_offset = codepointIndexToByteOffset(src, left);
            const right_offset = codepointIndexToByteOffset(src, right);
            const left_len = std.unicode.utf8ByteSequenceLength(src[left_offset]) catch 1;
            const right_len = std.unicode.utf8ByteSequenceLength(src[right_offset]) catch 1;
            if (left_len != right_len) return 0;
            if (!mem.eql(u8, src[left_offset .. left_offset + left_len], src[right_offset .. right_offset + right_len])) return 0;
            left += 1;
            right -= 1;
        }
        return 1;
    }
    return 0;
}

// ─── str_is_ascii ───

/// Check if string contains only ASCII characters (bytes 0-127). Returns 1 or 0.
/// Uses cached result when available (Phase C optimization).
pub fn str_is_ascii(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        return if (s.isAscii()) @as(c_int, 1) else @as(c_int, 0);
    }
    return 1;
}

// ─── str_is_uppercase ───

/// Check if all letter codepoints are uppercase. Returns 1 if true, 0 if false.
/// Non-letter characters are ignored. Empty string or no letters returns 0.
pub fn str_is_uppercase(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var i: usize = 0;
    var has_letter = false;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (unicode.stz_unicode_is_letter(cp_val) != 0) {
            has_letter = true;
            if (unicode.stz_unicode_is_upper(cp_val) == 0) return 0;
        }
        i += cp_len;
    }
    return if (has_letter) 1 else 0;
}

// ─── str_is_lowercase ───

/// Check if all letter codepoints are lowercase. Returns 1 if true, 0 if false.
/// Non-letter characters are ignored. Empty string or no letters returns 0.
pub fn str_is_lowercase(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var i: usize = 0;
    var has_letter = false;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (unicode.stz_unicode_is_letter(cp_val) != 0) {
            has_letter = true;
            if (unicode.stz_unicode_is_lower(cp_val) == 0) return 0;
        }
        i += cp_len;
    }
    return if (has_letter) 1 else 0;
}

// ─── str_is_whitespace ───

/// Check if the string contains only whitespace. Returns 1 if true, 0 if false.
/// Empty string returns 0.
pub fn str_is_whitespace(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (unicode.stz_unicode_is_space(cp_val) == 0) return 0;
        i += cp_len;
    }
    return 1;
}

// ─── str_is_only_type ───

/// Check if string contains only characters of a given type.
/// Types: 0=letter, 1=digit, 2=space, 3=upper, 4=lower, 5=punct
pub fn str_is_only_type(handle: StzStringHandle, char_type: c_int) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        const matches = switch (char_type) {
            0 => unicode.stz_unicode_is_letter(cp_val) != 0,
            1 => unicode.stz_unicode_is_digit(cp_val) != 0,
            2 => unicode.stz_unicode_is_space(cp_val) != 0,
            3 => unicode.stz_unicode_is_upper(cp_val) != 0,
            4 => unicode.stz_unicode_is_lower(cp_val) != 0,
            5 => blk: {
                const is_letter = unicode.stz_unicode_is_letter(cp_val) != 0;
                const is_digit = unicode.stz_unicode_is_digit(cp_val) != 0;
                const is_space = unicode.stz_unicode_is_space(cp_val) != 0;
                break :blk !is_letter and !is_digit and !is_space;
            },
            else => false,
        };
        if (!matches) return 0;
        i += cp_len;
    }
    return 1;
}

// ─── str_is_title_case ───

/// Check if string is in title case (first letter of each word uppercase, rest lowercase).
/// Returns 1 or 0.
pub fn str_is_title_case(handle: StzStringHandle) callconv(.c) c_int {
    // Title case: first letter of each word is uppercase, rest lowercase
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var after_space = true; // start of string counts as word boundary
    var has_letter = false;
    var i_pos: usize = 0;
    while (i_pos < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i_pos]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i_pos, cp_len);

        if (unicode.stz_unicode_is_letter(cp_val) != 0) {
            has_letter = true;
            if (after_space) {
                // First letter of word must be uppercase
                if (unicode.stz_unicode_is_upper(cp_val) == 0) return 0;
            } else {
                // Other letters in word must be lowercase
                if (unicode.stz_unicode_is_lower(cp_val) == 0) return 0;
            }
            after_space = false;
        } else {
            if (unicode.stz_unicode_is_space(cp_val) != 0) {
                after_space = true;
            } else {
                after_space = false;
            }
        }
        i_pos += cp_len;
    }
    return if (has_letter) @as(c_int, 1) else @as(c_int, 0);
}

// ─── str_is_alpha_only ───

/// Check if string contains only letters (Unicode-aware). Returns 1 or 0.
pub fn str_is_alpha_only(handle: StzStringHandle) callconv(.c) c_int {
    return str_is_only_type(handle, 0); // type 0 = letter
}

// ─── str_is_alnum ───

/// Check if string is alphanumeric (letters + digits only). Returns 1 or 0.
pub fn str_is_alnum(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (unicode.stz_unicode_is_letter(cp_val) == 0 and unicode.stz_unicode_is_digit(cp_val) == 0) return 0;
        i += cp_len;
    }
    return 1;
}

// ─── str_contains_char ───

/// Check if string contains char (codepoint). Returns 1 or 0.
pub fn str_contains_char(handle: StzStringHandle, codepoint: i32) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (cp_val == codepoint) return 1;
        i += cp_len;
    }
    return 0;
}

// ─── str_is_word ───

/// Check if string is a word (letters, digits, underscore, hyphen). Returns 1 or 0.
pub fn str_is_word(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return 0;
        if (off + cp_len > buf.len) return 0;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch return 0;
        // underscore=95, hyphen=45
        if (cp_val != 95 and cp_val != 45 and
            unicode.stz_unicode_is_letter(cp_val) == 0 and
            unicode.stz_unicode_is_digit(cp_val) == 0)
        {
            return 0;
        }
        off += cp_len;
    }
    return 1;
}

// ─── str_is_numeric_string ───

/// Check if string is a numeric string (all digits, optional leading +/-). Returns 1 or 0.
pub fn str_is_numeric_string(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    var off: usize = 0;
    // Allow optional leading sign
    if (buf[0] == '+' or buf[0] == '-') {
        off = 1;
        if (off >= buf.len) return 0; // sign alone is not numeric
    }

    var has_digit = false;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return 0;
        if (off + cp_len > buf.len) return 0;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch return 0;
        if (unicode.stz_unicode_is_digit(cp_val) == 0) return 0;
        has_digit = true;
        off += cp_len;
    }
    return if (has_digit) @as(c_int, 1) else @as(c_int, 0);
}

// ─── str_is_hex_string ───

/// Check if string is a hex string (0-9, a-f, A-F, optional 0x prefix). Returns 1 or 0.
pub fn str_is_hex_string(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    var off: usize = 0;
    // Skip optional 0x or 0X prefix
    if (buf.len >= 2 and buf[0] == '0' and (buf[1] == 'x' or buf[1] == 'X')) {
        off = 2;
        if (off >= buf.len) return 0;
    }

    var has_hex = false;
    while (off < buf.len) {
        const b = buf[off];
        if ((b >= '0' and b <= '9') or (b >= 'a' and b <= 'f') or (b >= 'A' and b <= 'F')) {
            has_hex = true;
        } else {
            return 0;
        }
        off += 1;
    }
    return if (has_hex) @as(c_int, 1) else @as(c_int, 0);
}

// ─── str_is_binary_string ───

/// Check if string is a binary string (0 or 1, optional 0b prefix). Returns 1 or 0.
pub fn str_is_binary_string(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    var off: usize = 0;
    if (buf.len >= 2 and buf[0] == '0' and (buf[1] == 'b' or buf[1] == 'B')) {
        off = 2;
        if (off >= buf.len) return 0;
    }

    var has_bit = false;
    while (off < buf.len) {
        if (buf[off] != '0' and buf[off] != '1') return 0;
        has_bit = true;
        off += 1;
    }
    return if (has_bit) @as(c_int, 1) else @as(c_int, 0);
}

// ─── str_is_octal_string ───

/// Check if string is an octal string (0-7, optional 0o prefix). Returns 1 or 0.
pub fn str_is_octal_string(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    var off: usize = 0;
    if (buf.len >= 2 and buf[0] == '0' and (buf[1] == 'o' or buf[1] == 'O')) {
        off = 2;
        if (off >= buf.len) return 0;
    }

    var has_oct = false;
    while (off < buf.len) {
        if (buf[off] < '0' or buf[off] > '7') return 0;
        has_oct = true;
        off += 1;
    }
    return if (has_oct) @as(c_int, 1) else @as(c_int, 0);
}

// ─── str_is_chars_sorted_asc ───

/// Check if codepoints are sorted in ascending order. Returns 1 or 0.
pub fn str_is_chars_sorted_asc(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 1;

    var off: usize = 0;
    var prev_cp: u21 = 0;
    var first = true;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return 0;
        if (off + cp_len > buf.len) return 0;
        const cp = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch return 0;
        if (!first and cp < prev_cp) return 0;
        prev_cp = cp;
        first = false;
        off += cp_len;
    }
    return 1;
}

// ─── str_is_chars_sorted_desc ───

/// Check if codepoints are sorted in descending order. Returns 1 or 0.
pub fn str_is_chars_sorted_desc(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 1;

    var off: usize = 0;
    var prev_cp: u21 = 0;
    var first = true;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return 0;
        if (off + cp_len > buf.len) return 0;
        const cp = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch return 0;
        if (!first and cp > prev_cp) return 0;
        prev_cp = cp;
        first = false;
        off += cp_len;
    }
    return 1;
}

// ─── str_contains_any_of ───

/// Check if string contains any of the characters in the given string. Returns 1 or 0.
pub fn str_contains_any_of(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (chars == null or chars_len == 0) return 0;
    const char_set: []const u8 = chars[0..chars_len];

    // Parse char_set into codepoints
    var set_cps: std.ArrayList(u21) = .{};
    defer set_cps.deinit(gpa);
    var coff: usize = 0;
    while (coff < char_set.len) {
        const cl = std.unicode.utf8ByteSequenceLength(char_set[coff]) catch break;
        if (coff + cl > char_set.len) break;
        const cv = std.unicode.utf8Decode(char_set[coff..][0..cl]) catch break;
        set_cps.append(gpa, cv) catch break;
        coff += cl;
    }

    // Check if any char in buf matches
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        for (set_cps.items) |set_cp| {
            if (cp_val == set_cp) return 1;
        }
        off += cp_len;
    }
    return 0;
}

// ─── str_contains_all_of ───

/// Check if string contains all of the characters in the given string. Returns 1 or 0.
pub fn str_contains_all_of(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (chars == null or chars_len == 0) return 1;
    const char_set: []const u8 = chars[0..chars_len];

    // Parse char_set into codepoints
    var set_cps: std.ArrayList(u21) = .{};
    defer set_cps.deinit(gpa);
    var coff: usize = 0;
    while (coff < char_set.len) {
        const cl = std.unicode.utf8ByteSequenceLength(char_set[coff]) catch break;
        if (coff + cl > char_set.len) break;
        const cv = std.unicode.utf8Decode(char_set[coff..][0..cl]) catch break;
        set_cps.append(gpa, cv) catch break;
        coff += cl;
    }

    // For each set char, check it exists in buf
    for (set_cps.items) |set_cp| {
        var found = false;
        var off: usize = 0;
        while (off < buf.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
            if (off + cp_len > buf.len) break;
            const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
            if (cp_val == set_cp) {
                found = true;
                break;
            }
            off += cp_len;
        }
        if (!found) return 0;
    }
    return 1;
}

// ─── str_is_alphanumeric ───

/// Check if string is alphanumeric (letters + digits only, Unicode-aware). Returns 1 or 0.
pub fn str_is_alphanumeric(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch return 0;
        if (off + cp_len > src.len) return 0;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch return 0;
        if (unicode.stz_unicode_is_letter(cp) == 0 and unicode.stz_unicode_is_digit(cp) == 0) return 0;
        off += cp_len;
    }
    return 1;
}

// ─── str_is_digit ───

/// Returns 1 if all codepoints in the string are digits, 0 otherwise.
/// Empty string returns 0.
pub fn str_is_digit(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch return 0;
        if (off + cp_len > src.len) return 0;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch return 0;
        if (unicode.stz_unicode_is_digit(cp) == 0) return 0;
        off += cp_len;
    }
    return 1;
}

// ─── str_is_blank ───

/// Check if string is blank (empty or contains only whitespace).
/// Returns 1 if blank, 0 otherwise.
pub fn str_is_blank(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 1; // null = blank
    const src = s.slice();
    if (src.len == 0) return 1;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp_val: i32 = decodeCodepoint(src, off, cp_len);
        if (unicode.stz_unicode_is_space(cp_val) == 0) return 0;
        off += cp_len;
    }
    return 1;
}

// ─── str_is_identifier ───

/// Check if string is a valid programming identifier (starts with letter/underscore,
/// rest are letters/digits/underscores). Returns 1 if valid, 0 otherwise.
pub fn str_is_identifier(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var off: usize = 0;
    var first = true;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp_val: i32 = decodeCodepoint(src, off, cp_len);

        if (first) {
            // First char must be letter or underscore
            if (cp_val != '_' and unicode.stz_unicode_is_letter(cp_val) == 0) return 0;
            first = false;
        } else {
            // Rest must be letter, digit, or underscore
            if (cp_val != '_' and unicode.stz_unicode_is_letter(cp_val) == 0 and unicode.stz_unicode_is_digit(cp_val) == 0) return 0;
        }
        off += cp_len;
    }
    return 1;
}

// ─── str_contains_only ───

/// Check if string contains only characters from the given set.
/// Returns 1 if all chars are in set, 0 otherwise. Empty string returns 1.
pub fn str_contains_only(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) c_int {
    const s = handle orelse return 1;
    const src = s.slice();
    if (src.len == 0) return 1;
    if (chars_len == 0) return 0;

    const charset = chars[0..chars_len];
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        var found = false;
        var coff: usize = 0;
        while (coff < charset.len) {
            const c_len = std.unicode.utf8ByteSequenceLength(charset[coff]) catch break;
            if (coff + c_len > charset.len) break;
            if (c_len == cp_len and mem.eql(u8, src[off..][0..cp_len], charset[coff..][0..c_len])) {
                found = true;
                break;
            }
            coff += c_len;
        }
        if (!found) return 0;
        off += cp_len;
    }
    return 1;
}

// ─── str_is_anagram ───

/// Check if two strings are anagrams (same chars, different order).
/// Case-sensitive. Returns 1 if anagram, 0 otherwise.
pub fn str_is_anagram(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    const s1 = h1 orelse return 0;
    const s2 = h2 orelse return 0;
    const src1 = s1.slice();
    const src2 = s2.slice();
    if (src1.len != src2.len) return 0;
    if (src1.len == 0) return 1;

    // Count codepoints in both and compare sorted
    var counts = std.AutoHashMap(i32, i32).init(gpa);
    defer counts.deinit();

    var off: usize = 0;
    while (off < src1.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src1[off]) catch break;
        if (off + cp_len > src1.len) break;
        const cp: i32 = decodeCodepoint(src1, off, cp_len);
        const entry = counts.getOrPut(cp) catch break;
        if (!entry.found_existing) entry.value_ptr.* = 0;
        entry.value_ptr.* += 1;
        off += cp_len;
    }

    off = 0;
    while (off < src2.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src2[off]) catch break;
        if (off + cp_len > src2.len) break;
        const cp: i32 = decodeCodepoint(src2, off, cp_len);
        const entry = counts.getOrPut(cp) catch break;
        if (!entry.found_existing) entry.value_ptr.* = 0;
        entry.value_ptr.* -= 1;
        off += cp_len;
    }

    var iter = counts.iterator();
    while (iter.next()) |entry| {
        if (entry.value_ptr.* != 0) return 0;
    }
    return 1;
}

// ─── str_is_pangram ───

/// Check if string is a pangram (contains every letter a-z at least once, case-insensitive).
/// Returns 1 if pangram, 0 otherwise.
pub fn str_is_pangram(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len < 26) return 0;

    var seen: [26]bool = [_]bool{false} ** 26;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c >= 'a' and c <= 'z') seen[c - 'a'] = true
            else if (c >= 'A' and c <= 'Z') seen[c - 'A'] = true;
        }
        off += cp_len;
    }

    for (seen) |s2| {
        if (!s2) return 0;
    }
    return 1;
}

// ─── str_is_balanced ───

/// Check if brackets/parentheses/braces are balanced.
/// Returns 1 if balanced, 0 otherwise.
pub fn str_is_balanced(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 1;
    const src = s.slice();
    var stack: [1024]u8 = undefined;
    var depth: usize = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c == '(' or c == '[' or c == '{') {
                if (depth >= 1024) return 0;
                stack[depth] = c;
                depth += 1;
            } else if (c == ')' or c == ']' or c == '}') {
                if (depth == 0) return 0;
                depth -= 1;
                const expected: u8 = switch (c) {
                    ')' => '(',
                    ']' => '[',
                    '}' => '{',
                    else => 0,
                };
                if (stack[depth] != expected) return 0;
            }
        }
        off += cp_len;
    }
    return if (depth == 0) @as(c_int, 1) else @as(c_int, 0);
}

// ─── str_is_email_like ───

/// Basic email format check: contains exactly one @, has text before and after @,
/// has at least one dot after @. Returns 1 if email-like, 0 otherwise.
pub fn str_is_email_like(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len < 5) return 0; // minimum: a@b.c

    var at_pos: ?usize = null;
    var at_count: usize = 0;
    for (src, 0..) |c, i| {
        if (c == '@') {
            at_count += 1;
            at_pos = i;
        }
    }
    if (at_count != 1) return 0;
    const atp = at_pos.?;
    if (atp == 0) return 0; // nothing before @
    if (atp >= src.len - 1) return 0; // nothing after @

    // Check for dot after @
    const domain = src[atp + 1 ..];
    var has_dot = false;
    for (domain) |c| {
        if (c == '.') { has_dot = true; break; }
    }
    if (!has_dot) return 0;

    // Dot shouldn't be first or last in domain
    if (domain[0] == '.' or domain[domain.len - 1] == '.') return 0;

    return 1;
}

// ─── str_is_url_like ───

/// Basic URL format check: starts with "http://" or "https://".
/// Returns 1 if URL-like, 0 otherwise.
pub fn str_is_url_like(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len >= 8 and mem.eql(u8, src[0..8], "https://")) return 1;
    if (src.len >= 7 and mem.eql(u8, src[0..7], "http://")) return 1;
    return 0;
}

// ─── str_is_float ───

/// Check if string is a valid float format (optional sign, digits, one dot, digits).
/// E.g. "3.14", "-0.5", "+123.456" are valid. Returns 1 if valid, 0 otherwise.
pub fn str_is_float(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var off: usize = 0;
    // Optional sign
    if (off < src.len and (src[off] == '+' or src[off] == '-')) off += 1;
    if (off >= src.len) return 0;

    var has_digits_before = false;
    while (off < src.len and src[off] >= '0' and src[off] <= '9') {
        has_digits_before = true;
        off += 1;
    }

    // Must have dot
    if (off >= src.len or src[off] != '.') return 0;
    off += 1;

    var has_digits_after = false;
    while (off < src.len and src[off] >= '0' and src[off] <= '9') {
        has_digits_after = true;
        off += 1;
    }

    if (off != src.len) return 0; // trailing chars
    if (!has_digits_before and !has_digits_after) return 0;
    return 1;
}

// ─── str_is_camel_case ───

/// Check if string is in camelCase format (starts lowercase, has at least one uppercase).
/// Returns 1 if camelCase, 0 otherwise.
pub fn str_is_camel_case(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len < 2) return 0;

    // First char must be lowercase letter
    if (!(src[0] >= 'a' and src[0] <= 'z')) return 0;

    // Must contain at least one uppercase
    var has_upper = false;
    for (src[1..]) |c| {
        if (c >= 'A' and c <= 'Z') { has_upper = true; break; }
    }
    if (!has_upper) return 0;

    // Must only contain letters and digits
    for (src) |c| {
        if (!((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or (c >= '0' and c <= '9'))) return 0;
    }
    return 1;
}

// ─── str_is_snake_case ───

/// Check if string is in snake_case format: lowercase + underscores, starts with letter, no consecutive underscores.
pub export fn str_is_snake_case(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;
    // Must start with lowercase letter
    if (src[0] < 'a' or src[0] > 'z') return 0;
    var prev_underscore = false;
    for (src) |c| {
        if (c >= 'a' and c <= 'z') {
            prev_underscore = false;
        } else if (c >= '0' and c <= '9') {
            prev_underscore = false;
        } else if (c == '_') {
            if (prev_underscore) return 0; // consecutive underscores
            prev_underscore = true;
        } else {
            return 0; // invalid character
        }
    }
    // Must not end with underscore
    if (src[src.len - 1] == '_') return 0;
    // Must have at least one underscore to be snake_case
    for (src) |c| {
        if (c == '_') return 1;
    }
    return 0; // single word, no underscore
}

// ─── str_is_kebab_case ───

/// Check if string is in kebab-case format: lowercase + hyphens, starts with letter, no consecutive hyphens.
pub export fn str_is_kebab_case(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;
    // Must start with lowercase letter
    if (src[0] < 'a' or src[0] > 'z') return 0;
    var prev_hyphen = false;
    for (src) |c| {
        if (c >= 'a' and c <= 'z') {
            prev_hyphen = false;
        } else if (c >= '0' and c <= '9') {
            prev_hyphen = false;
        } else if (c == '-') {
            if (prev_hyphen) return 0;
            prev_hyphen = true;
        } else {
            return 0;
        }
    }
    if (src[src.len - 1] == '-') return 0;
    // Must have at least one hyphen
    for (src) |c| {
        if (c == '-') return 1;
    }
    return 0;
}

// ─── str_is_palindrome_words ───

/// Is palindrome at word level: "dog cat dog" -> true (words reversed = same sequence).
pub export fn str_is_palindrome_words(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 1;

    // Collect word boundaries
    var starts: [256]usize = undefined;
    var ends: [256]usize = undefined;
    var wc: usize = 0;

    var i: usize = 0;
    while (i < src.len and wc < 256) {
        while (i < src.len and src[i] == ' ') : (i += 1) {}
        if (i >= src.len) break;
        starts[wc] = i;
        while (i < src.len and src[i] != ' ') : (i += 1) {}
        ends[wc] = i;
        wc += 1;
    }
    if (wc <= 1) return 1;

    // Compare word[j] with word[wc-1-j]
    var j: usize = 0;
    while (j < wc / 2) : (j += 1) {
        const w1 = src[starts[j]..ends[j]];
        const w2 = src[starts[wc - 1 - j]..ends[wc - 1 - j]];
        if (!mem.eql(u8, w1, w2)) return 0;
    }
    return 1;
}

// ─── str_is_isogram ───

/// Check if string is an isogram (no repeated letters, case-insensitive). Returns 1 or 0.
pub export fn str_is_isogram(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 1;
    var seen = [_]bool{false} ** 256;
    for (src) |c| {
        var ch = c;
        if (ch >= 'A' and ch <= 'Z') ch += 32;
        if (ch >= 'a' and ch <= 'z') {
            if (seen[ch]) return 0;
            seen[ch] = true;
        }
    }
    return 1;
}

// ─── Tests ───

test "str_is_empty" {
    const h = str_from("", 0);
    defer str_free(h);
    try std.testing.expectEqual(@as(c_int, 1), str_is_empty(h));

    const h2 = str_from("abc", 3);
    defer str_free(h2);
    try std.testing.expectEqual(@as(c_int, 0), str_is_empty(h2));
}

test "str_is_numeric" {
    const h = str_from("12345", 5);
    defer str_free(h);
    try std.testing.expectEqual(@as(c_int, 1), str_is_numeric(h));

    const h2 = str_from("12a45", 5);
    defer str_free(h2);
    try std.testing.expectEqual(@as(c_int, 0), str_is_numeric(h2));
}

test "str_is_palindrome" {
    const h = str_from("racecar", 7);
    defer str_free(h);
    try std.testing.expectEqual(@as(c_int, 1), str_is_palindrome(h));

    const h2 = str_from("hello", 5);
    defer str_free(h2);
    try std.testing.expectEqual(@as(c_int, 0), str_is_palindrome(h2));
}

test "str_is_uppercase_lowercase" {
    const h_up = str_from("HELLO", 5);
    defer str_free(h_up);
    try std.testing.expectEqual(@as(c_int, 1), str_is_uppercase(h_up));
    try std.testing.expectEqual(@as(c_int, 0), str_is_lowercase(h_up));

    const h_lo = str_from("hello", 5);
    defer str_free(h_lo);
    try std.testing.expectEqual(@as(c_int, 0), str_is_uppercase(h_lo));
    try std.testing.expectEqual(@as(c_int, 1), str_is_lowercase(h_lo));
}

test "str_is_balanced" {
    const h = str_from("(a[b{c}d]e)", 11);
    defer str_free(h);
    try std.testing.expectEqual(@as(c_int, 1), str_is_balanced(h));

    const h2 = str_from("(a[b{c]d}e)", 11);
    defer str_free(h2);
    try std.testing.expectEqual(@as(c_int, 0), str_is_balanced(h2));
}

test "str_is_email_like" {
    const h = str_from("user@example.com", 16);
    defer str_free(h);
    try std.testing.expectEqual(@as(c_int, 1), str_is_email_like(h));

    const h2 = str_from("noatsign.com", 12);
    defer str_free(h2);
    try std.testing.expectEqual(@as(c_int, 0), str_is_email_like(h2));
}

test "str_is_camel_case_and_snake_case" {
    const h = str_from("camelCase", 9);
    defer str_free(h);
    try std.testing.expectEqual(@as(c_int, 1), str_is_camel_case(h));
    try std.testing.expectEqual(@as(c_int, 0), str_is_snake_case(h));

    const h2 = str_from("snake_case", 10);
    defer str_free(h2);
    try std.testing.expectEqual(@as(c_int, 0), str_is_camel_case(h2));
    try std.testing.expectEqual(@as(c_int, 1), str_is_snake_case(h2));
}

test "str_is_pangram" {
    const h = str_from("the quick brown fox jumps over the lazy dog", 43);
    defer str_free(h);
    try std.testing.expectEqual(@as(c_int, 1), str_is_pangram(h));

    const h2 = str_from("not a pangram", 13);
    defer str_free(h2);
    try std.testing.expectEqual(@as(c_int, 0), str_is_pangram(h2));
}

test "str_is_anagram" {
    const h1 = str_from("listen", 6);
    defer str_free(h1);
    const h2 = str_from("silent", 6);
    defer str_free(h2);
    try std.testing.expectEqual(@as(c_int, 1), str_is_anagram(h1, h2));

    const h3 = str_from("hello", 5);
    defer str_free(h3);
    try std.testing.expectEqual(@as(c_int, 0), str_is_anagram(h1, h3));
}

test "str_is_hex_binary_octal" {
    const hx = str_from("0xDEAD", 6);
    defer str_free(hx);
    try std.testing.expectEqual(@as(c_int, 1), str_is_hex_string(hx));

    const bn = str_from("0b1010", 6);
    defer str_free(bn);
    try std.testing.expectEqual(@as(c_int, 1), str_is_binary_string(bn));

    const oc = str_from("0o7654", 6);
    defer str_free(oc);
    try std.testing.expectEqual(@as(c_int, 1), str_is_octal_string(oc));
}
