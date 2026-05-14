// Softanza Engine -- Unicode Operations (Tier 1)
//
// Full Unicode support via utf8proc: character properties, case
// conversion, normalization (NFC/NFD/NFKC/NFKD), grapheme clusters,
// diacritic stripping. Replaces hardcoded range tables and Qt QChar.
// All functions use C ABI for Ring FFI compatibility.

const std = @import("std");
const gpa = std.heap.c_allocator;

// ─── utf8proc extern declarations ───

const c = struct {
    const int32 = i32;
    const uint8 = u8;
    const ssize = isize;

    extern fn utf8proc_iterate(str: [*]const uint8, strlen: ssize, dst: *int32) callconv(.c) ssize;
    extern fn utf8proc_encode_char(cp: int32, dst: [*]uint8) callconv(.c) ssize;
    extern fn utf8proc_codepoint_valid(cp: int32) callconv(.c) bool;
    extern fn utf8proc_get_property(cp: int32) callconv(.c) *const Property;
    extern fn utf8proc_category(cp: int32) callconv(.c) c_int;
    extern fn utf8proc_category_string(cp: int32) callconv(.c) [*:0]const u8;
    extern fn utf8proc_tolower(cp: int32) callconv(.c) int32;
    extern fn utf8proc_toupper(cp: int32) callconv(.c) int32;
    extern fn utf8proc_totitle(cp: int32) callconv(.c) int32;
    extern fn utf8proc_islower(cp: int32) callconv(.c) c_int;
    extern fn utf8proc_isupper(cp: int32) callconv(.c) c_int;
    extern fn utf8proc_charwidth(cp: int32) callconv(.c) c_int;
    extern fn utf8proc_grapheme_break_stateful(c1: int32, c2: int32, state: ?*int32) callconv(.c) bool;
    extern fn utf8proc_map(str: [*]const uint8, strlen: ssize, dstptr: *?[*]uint8, options: c_int) callconv(.c) ssize;
    extern fn utf8proc_free(ptr: ?[*]uint8) callconv(.c) void;

    const Property = extern struct {
        category: i16,
        combining_class: i16,
        bidi_class: i16,
        decomp_type: i16,
        decomp_seqindex: u16,
        casefold_seqindex: u16,
        uppercase_seqindex: u16,
        lowercase_seqindex: u16,
        titlecase_seqindex: u16,
        comb_bits: u16,
        flags1: u8,
        flags2: u8,
    };

    const OPT_STABLE: c_int = 1 << 1;
    const OPT_COMPAT: c_int = 1 << 2;
    const OPT_COMPOSE: c_int = 1 << 3;
    const OPT_DECOMPOSE: c_int = 1 << 4;
    const OPT_CASEFOLD: c_int = 1 << 10;
    const OPT_STRIPMARK: c_int = 1 << 13;
    const OPT_IGNORE: c_int = 1 << 5;

    const CAT_LU: c_int = 1;
    const CAT_LL: c_int = 2;
    const CAT_LT: c_int = 3;
    const CAT_LM: c_int = 4;
    const CAT_LO: c_int = 5;
    const CAT_MN: c_int = 6;
    const CAT_MC: c_int = 7;
    const CAT_ME: c_int = 8;
    const CAT_ND: c_int = 9;
    const CAT_NL: c_int = 10;
    const CAT_NO: c_int = 11;
    const CAT_PC: c_int = 12;
    const CAT_PD: c_int = 13;
    const CAT_PS: c_int = 14;
    const CAT_PE: c_int = 15;
    const CAT_PI: c_int = 16;
    const CAT_PF: c_int = 17;
    const CAT_PO: c_int = 18;
    const CAT_SM: c_int = 19;
    const CAT_SC: c_int = 20;
    const CAT_SK: c_int = 21;
    const CAT_SO: c_int = 22;
    const CAT_ZS: c_int = 23;
    const CAT_CC: c_int = 26;
    const CAT_CF: c_int = 27;
};

// ─── Character Properties ───

pub fn stz_unicode_category(cp: i32) callconv(.c) c_int {
    return c.utf8proc_category(cp);
}

pub fn stz_unicode_category_string(cp: i32, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const s = c.utf8proc_category_string(cp);
    const len = std.mem.len(s);
    if (len > buf_len) return 0;
    @memcpy(buf[0..len], s[0..len]);
    return len;
}

pub fn stz_unicode_is_letter(cp: i32) callconv(.c) c_int {
    const cat = c.utf8proc_category(cp);
    return if (cat >= c.CAT_LU and cat <= c.CAT_LO) 1 else 0;
}

pub fn stz_unicode_is_digit(cp: i32) callconv(.c) c_int {
    return if (c.utf8proc_category(cp) == c.CAT_ND) 1 else 0;
}

pub fn stz_unicode_is_number(cp: i32) callconv(.c) c_int {
    const cat = c.utf8proc_category(cp);
    return if (cat >= c.CAT_ND and cat <= c.CAT_NO) 1 else 0;
}

pub fn stz_unicode_is_upper(cp: i32) callconv(.c) c_int {
    return c.utf8proc_isupper(cp);
}

pub fn stz_unicode_is_lower(cp: i32) callconv(.c) c_int {
    return c.utf8proc_islower(cp);
}

pub fn stz_unicode_is_space(cp: i32) callconv(.c) c_int {
    const cat = c.utf8proc_category(cp);
    if (cat == c.CAT_ZS) return 1;
    if (cp == 0x09 or cp == 0x0A or cp == 0x0B or cp == 0x0C or cp == 0x0D or cp == 0x20 or cp == 0x85 or cp == 0xA0) return 1;
    return 0;
}

pub fn stz_unicode_is_punctuation(cp: i32) callconv(.c) c_int {
    const cat = c.utf8proc_category(cp);
    return if (cat >= c.CAT_PC and cat <= c.CAT_PO) 1 else 0;
}

pub fn stz_unicode_is_symbol(cp: i32) callconv(.c) c_int {
    const cat = c.utf8proc_category(cp);
    return if (cat >= c.CAT_SM and cat <= c.CAT_SO) 1 else 0;
}

pub fn stz_unicode_is_mark(cp: i32) callconv(.c) c_int {
    const cat = c.utf8proc_category(cp);
    return if (cat >= c.CAT_MN and cat <= c.CAT_ME) 1 else 0;
}

pub fn stz_unicode_is_control(cp: i32) callconv(.c) c_int {
    const cat = c.utf8proc_category(cp);
    return if (cat == c.CAT_CC or cat == c.CAT_CF) 1 else 0;
}

pub fn stz_unicode_bidi_class(cp: i32) callconv(.c) c_int {
    const prop = c.utf8proc_get_property(cp);
    return @intCast(prop.bidi_class);
}

pub fn stz_unicode_charwidth(cp: i32) callconv(.c) c_int {
    return c.utf8proc_charwidth(cp);
}

pub fn stz_unicode_is_valid(cp: i32) callconv(.c) c_int {
    return if (c.utf8proc_codepoint_valid(cp)) 1 else 0;
}

// ─── Case Conversion (codepoint level) ───

pub fn stz_unicode_to_lower(cp: i32) callconv(.c) i32 {
    return c.utf8proc_tolower(cp);
}

pub fn stz_unicode_to_upper(cp: i32) callconv(.c) i32 {
    return c.utf8proc_toupper(cp);
}

pub fn stz_unicode_to_title(cp: i32) callconv(.c) i32 {
    return c.utf8proc_totitle(cp);
}

// ─── String-level Case Conversion ───

pub fn stz_unicode_to_lower_str(data: [*c]const u8, len: usize, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (data == null or len == 0) return 0;
    return caseConvertStr(data[0..len], buf, buf_len, c.utf8proc_tolower);
}

pub fn stz_unicode_to_upper_str(data: [*c]const u8, len: usize, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (data == null or len == 0) return 0;
    return caseConvertStr(data[0..len], buf, buf_len, c.utf8proc_toupper);
}

pub fn stz_unicode_to_title_str(data: [*c]const u8, len: usize, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (data == null or len == 0) return 0;
    const src = data[0..len];
    var out: usize = 0;
    var pos: usize = 0;
    var after_boundary = true;
    while (pos < src.len) {
        var cp: i32 = undefined;
        const consumed = c.utf8proc_iterate(src.ptr + pos, @intCast(src.len - pos), &cp);
        if (consumed < 1) break;
        const mapped = if (after_boundary and stz_unicode_is_letter(cp) == 1)
            c.utf8proc_totitle(cp)
        else if (!after_boundary and stz_unicode_is_letter(cp) == 1)
            c.utf8proc_tolower(cp)
        else
            cp;
        var enc_buf: [4]u8 = undefined;
        const enc_len = c.utf8proc_encode_char(mapped, &enc_buf);
        if (enc_len < 1 or out + @as(usize, @intCast(enc_len)) > buf_len) break;
        @memcpy(buf[out..][0..@intCast(enc_len)], enc_buf[0..@intCast(enc_len)]);
        out += @intCast(enc_len);
        after_boundary = stz_unicode_is_letter(cp) == 0 and stz_unicode_is_digit(cp) == 0;
        pos += @intCast(consumed);
    }
    return out;
}

fn caseConvertStr(src: []const u8, buf: [*c]u8, buf_len: usize, convert: *const fn (i32) callconv(.c) i32) usize {
    var out: usize = 0;
    var pos: usize = 0;
    while (pos < src.len) {
        var cp: i32 = undefined;
        const consumed = c.utf8proc_iterate(src.ptr + pos, @intCast(src.len - pos), &cp);
        if (consumed < 1) break;
        const mapped = convert(cp);
        var enc_buf: [4]u8 = undefined;
        const enc_len = c.utf8proc_encode_char(mapped, &enc_buf);
        if (enc_len < 1 or out + @as(usize, @intCast(enc_len)) > buf_len) break;
        @memcpy(buf[out..][0..@intCast(enc_len)], enc_buf[0..@intCast(enc_len)]);
        out += @intCast(enc_len);
        pos += @intCast(consumed);
    }
    return out;
}

// ─── Normalization ───

pub fn stz_unicode_normalize(data: [*c]const u8, len: usize, form: c_int, out_len: *usize) callconv(.c) [*c]u8 {
    out_len.* = 0;
    if (data == null or len == 0) return null;
    const opts: c_int = c.OPT_STABLE | switch (form) {
        0 => c.OPT_COMPOSE, // NFC
        1 => c.OPT_DECOMPOSE, // NFD
        2 => c.OPT_COMPOSE | c.OPT_COMPAT, // NFKC
        3 => c.OPT_DECOMPOSE | c.OPT_COMPAT, // NFKD
        else => return null,
    };
    var dst_ptr: ?[*]u8 = null;
    const result = c.utf8proc_map(data, @intCast(len), &dst_ptr, opts);
    if (result < 0 or dst_ptr == null) return null;
    const rlen: usize = @intCast(result);
    const buf = gpa.alloc(u8, rlen) catch {
        c.utf8proc_free(dst_ptr);
        return null;
    };
    @memcpy(buf, dst_ptr.?[0..rlen]);
    c.utf8proc_free(dst_ptr);
    out_len.* = rlen;
    return buf.ptr;
}

pub fn stz_unicode_normalize_free(ptr: [*c]u8, len: usize) callconv(.c) void {
    if (ptr != null and len > 0) gpa.free(ptr[0..len]);
}

// ─── Case Folding ───

pub fn stz_unicode_casefold(data: [*c]const u8, len: usize, out_len: *usize) callconv(.c) [*c]u8 {
    out_len.* = 0;
    if (data == null or len == 0) return null;
    const opts: c_int = c.OPT_STABLE | c.OPT_COMPOSE | c.OPT_CASEFOLD;
    var dst_ptr: ?[*]u8 = null;
    const result = c.utf8proc_map(data, @intCast(len), &dst_ptr, opts);
    if (result < 0 or dst_ptr == null) return null;
    const rlen: usize = @intCast(result);
    const buf = gpa.alloc(u8, rlen) catch {
        c.utf8proc_free(dst_ptr);
        return null;
    };
    @memcpy(buf, dst_ptr.?[0..rlen]);
    c.utf8proc_free(dst_ptr);
    out_len.* = rlen;
    return buf.ptr;
}

pub fn stz_unicode_casefold_free(ptr: [*c]u8, len: usize) callconv(.c) void {
    if (ptr != null and len > 0) gpa.free(ptr[0..len]);
}

// ─── Strip Marks (diacritics) ───

pub fn stz_unicode_strip_marks(data: [*c]const u8, len: usize, out_len: *usize) callconv(.c) [*c]u8 {
    out_len.* = 0;
    if (data == null or len == 0) return null;
    const opts: c_int = c.OPT_STABLE | c.OPT_COMPOSE | c.OPT_STRIPMARK;
    var dst_ptr: ?[*]u8 = null;
    const result = c.utf8proc_map(data, @intCast(len), &dst_ptr, opts);
    if (result < 0 or dst_ptr == null) return null;
    const rlen: usize = @intCast(result);
    const buf = gpa.alloc(u8, rlen) catch {
        c.utf8proc_free(dst_ptr);
        return null;
    };
    @memcpy(buf, dst_ptr.?[0..rlen]);
    c.utf8proc_free(dst_ptr);
    out_len.* = rlen;
    return buf.ptr;
}

pub fn stz_unicode_strip_marks_free(ptr: [*c]u8, len: usize) callconv(.c) void {
    if (ptr != null and len > 0) gpa.free(ptr[0..len]);
}

// ─── Grapheme Clusters ───

pub fn stz_unicode_grapheme_count(data: [*c]const u8, len: usize) callconv(.c) c_int {
    if (data == null or len == 0) return 0;
    const src = data[0..len];
    var count: c_int = 0;
    var pos: usize = 0;
    var prev_cp: i32 = -1;
    var state: i32 = 0;
    while (pos < src.len) {
        var cp: i32 = undefined;
        const consumed = c.utf8proc_iterate(src.ptr + pos, @intCast(src.len - pos), &cp);
        if (consumed < 1) break;
        if (prev_cp < 0 or c.utf8proc_grapheme_break_stateful(prev_cp, cp, &state)) {
            count += 1;
        }
        prev_cp = cp;
        pos += @intCast(consumed);
    }
    return count;
}

pub fn stz_unicode_grapheme_break(cp1: i32, cp2: i32) callconv(.c) c_int {
    return if (c.utf8proc_grapheme_break_stateful(cp1, cp2, null)) 1 else 0;
}

// ─── UTF-8 Iteration ───

pub fn stz_unicode_iterate(data: [*c]const u8, len: usize, pos: usize) callconv(.c) i32 {
    if (data == null or pos >= len) return -1;
    var cp: i32 = undefined;
    const consumed = c.utf8proc_iterate(data + pos, @intCast(len - pos), &cp);
    if (consumed < 1) return -1;
    return cp;
}

pub fn stz_unicode_cp_byte_len(data: [*c]const u8, len: usize, pos: usize) callconv(.c) c_int {
    if (data == null or pos >= len) return 0;
    var cp: i32 = undefined;
    const consumed = c.utf8proc_iterate(data + pos, @intCast(len - pos), &cp);
    if (consumed < 1) return 0;
    return @intCast(consumed);
}

pub fn stz_unicode_encode(cp: i32, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (buf == null or buf_len < 4) return 0;
    const written = c.utf8proc_encode_char(cp, buf);
    if (written < 1) return 0;
    return @intCast(written);
}

// ─── Codepoint-to-byte offset mapping ───

pub fn stz_unicode_cp_to_byte(data: [*c]const u8, len: usize, cp_index: c_int) callconv(.c) c_int {
    if (data == null or len == 0 or cp_index < 0) return -1;
    const target: usize = @intCast(cp_index);
    const src = data[0..len];
    var pos: usize = 0;
    var cp_count: usize = 0;
    while (pos < src.len) {
        if (cp_count == target) return @intCast(pos);
        var cp: i32 = undefined;
        const consumed = c.utf8proc_iterate(src.ptr + pos, @intCast(src.len - pos), &cp);
        if (consumed < 1) break;
        pos += @intCast(consumed);
        cp_count += 1;
    }
    if (cp_count == target) return @intCast(pos);
    return -1;
}

pub fn stz_unicode_byte_to_cp(data: [*c]const u8, len: usize, byte_pos: c_int) callconv(.c) c_int {
    if (data == null or len == 0 or byte_pos < 0) return -1;
    const target: usize = @intCast(byte_pos);
    const src = data[0..len];
    var pos: usize = 0;
    var cp_count: usize = 0;
    while (pos < src.len) {
        if (pos == target) return @intCast(cp_count);
        var cp: i32 = undefined;
        const consumed = c.utf8proc_iterate(src.ptr + pos, @intCast(src.len - pos), &cp);
        if (consumed < 1) break;
        pos += @intCast(consumed);
        cp_count += 1;
    }
    if (pos == target) return @intCast(cp_count);
    return -1;
}

// ─── Tests ───

test "unicode category" {
    try std.testing.expectEqual(@as(c_int, c.CAT_LU), stz_unicode_category('A'));
    try std.testing.expectEqual(@as(c_int, c.CAT_LL), stz_unicode_category('a'));
    try std.testing.expectEqual(@as(c_int, c.CAT_ND), stz_unicode_category('0'));
}

test "unicode is_letter full range" {
    try std.testing.expectEqual(@as(c_int, 1), stz_unicode_is_letter('A'));
    try std.testing.expectEqual(@as(c_int, 1), stz_unicode_is_letter(0xE9)); // e-acute
    try std.testing.expectEqual(@as(c_int, 1), stz_unicode_is_letter(0x627)); // Arabic alef
    try std.testing.expectEqual(@as(c_int, 1), stz_unicode_is_letter(0x4E00)); // CJK
    try std.testing.expectEqual(@as(c_int, 0), stz_unicode_is_letter(' '));
    try std.testing.expectEqual(@as(c_int, 0), stz_unicode_is_letter('5'));
}

test "unicode case conversion" {
    try std.testing.expectEqual(@as(i32, 'a'), stz_unicode_to_lower('A'));
    try std.testing.expectEqual(@as(i32, 'A'), stz_unicode_to_upper('a'));
    // German sharp s -> no upper single codepoint, stays
    try std.testing.expectEqual(@as(i32, 0xDF), stz_unicode_to_lower(0xDF));
    // Greek alpha
    try std.testing.expectEqual(@as(i32, 0x3B1), stz_unicode_to_lower(0x391));
    try std.testing.expectEqual(@as(i32, 0x391), stz_unicode_to_upper(0x3B1));
}

test "unicode is_upper/is_lower non-ascii" {
    try std.testing.expectEqual(@as(c_int, 1), stz_unicode_is_upper(0x391)); // Greek Alpha
    try std.testing.expectEqual(@as(c_int, 1), stz_unicode_is_lower(0x3B1)); // Greek alpha
    try std.testing.expectEqual(@as(c_int, 0), stz_unicode_is_upper('5'));
}

test "unicode grapheme count" {
    // ASCII
    try std.testing.expectEqual(@as(c_int, 5), stz_unicode_grapheme_count("hello", 5));
    // e-acute (2 bytes, 1 grapheme)
    try std.testing.expectEqual(@as(c_int, 1), stz_unicode_grapheme_count("\xC3\xA9", 2));
    // e + combining acute (3 bytes, 1 grapheme)
    try std.testing.expectEqual(@as(c_int, 1), stz_unicode_grapheme_count("e\xCC\x81", 3));
}

test "unicode cp_to_byte" {
    // "Abc" = 3 bytes, 3 codepoints
    try std.testing.expectEqual(@as(c_int, 0), stz_unicode_cp_to_byte("Abc", 3, 0));
    try std.testing.expectEqual(@as(c_int, 1), stz_unicode_cp_to_byte("Abc", 3, 1));
    // e-acute (2 bytes) + "x" = byte offsets: 0, 2
    try std.testing.expectEqual(@as(c_int, 0), stz_unicode_cp_to_byte("\xC3\xA9x", 3, 0));
    try std.testing.expectEqual(@as(c_int, 2), stz_unicode_cp_to_byte("\xC3\xA9x", 3, 1));
}

test "unicode normalize" {
    // e + combining acute (NFD) -> e-acute (NFC)
    var out_len: usize = 0;
    const nfc = stz_unicode_normalize("e\xCC\x81", 3, 0, &out_len);
    if (nfc != null and out_len > 0) {
        defer stz_unicode_normalize_free(nfc, out_len);
        try std.testing.expectEqual(@as(usize, 2), out_len);
        try std.testing.expect(std.mem.eql(u8, nfc[0..out_len], "\xC3\xA9"));
    }
}

test "unicode strip marks" {
    var out_len: usize = 0;
    const stripped = stz_unicode_strip_marks("\xC3\xA9", 2, &out_len);
    if (stripped != null and out_len > 0) {
        defer stz_unicode_strip_marks_free(stripped, out_len);
        try std.testing.expect(std.mem.eql(u8, stripped[0..out_len], "e"));
    }
}

test "unicode string case" {
    var buf: [64]u8 = undefined;
    // Greek uppercase
    const upper_len = stz_unicode_to_upper_str("\xCE\xB1\xCE\xB2\xCE\xB3", 6, &buf, 64);
    try std.testing.expect(upper_len > 0);
    try std.testing.expect(std.mem.eql(u8, buf[0..upper_len], "\xCE\x91\xCE\x92\xCE\x93"));
}
