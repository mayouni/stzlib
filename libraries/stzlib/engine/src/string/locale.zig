// Softanza Engine -- String Locale Operations
//
// String-level script detection, bidi analysis, and locale-aware
// comparison. Built on top of unicode.zig codepoint functions.
// Part of String Engine v2 Phase F.

const std = @import("std");
const core = @import("core.zig");
const unicode = @import("../unicode.zig");

const StzString = core.StzString;
const StzStringHandle = core.StzStringHandle;
const str_from = core.str_from;
const gpa = core.gpa;

// Script IDs returned by str_detect_script
pub const SCRIPT_UNKNOWN: c_int = 0;
pub const SCRIPT_LATIN: c_int = 1;
pub const SCRIPT_ARABIC: c_int = 2;
pub const SCRIPT_HEBREW: c_int = 3;
pub const SCRIPT_CYRILLIC: c_int = 4;
pub const SCRIPT_GREEK: c_int = 5;
pub const SCRIPT_CJK: c_int = 6;
pub const SCRIPT_DEVANAGARI: c_int = 7;
pub const SCRIPT_THAI: c_int = 8;
pub const SCRIPT_MIXED: c_int = 99;

// Direction IDs returned by str_detect_direction
pub const DIR_LTR: c_int = 0;
pub const DIR_RTL: c_int = 1;
pub const DIR_MIXED: c_int = 2;
pub const DIR_NEUTRAL: c_int = 3;

fn classifyCodepoint(cp: i32) c_int {
    if (unicode.stz_unicode_is_latin(cp) == 1) return SCRIPT_LATIN;
    if (unicode.stz_unicode_is_arabic(cp) == 1) return SCRIPT_ARABIC;
    if (unicode.stz_unicode_is_hebrew(cp) == 1) return SCRIPT_HEBREW;
    if (unicode.stz_unicode_is_cyrillic(cp) == 1) return SCRIPT_CYRILLIC;
    if (unicode.stz_unicode_is_greek(cp) == 1) return SCRIPT_GREEK;
    if (unicode.stz_unicode_is_cjk(cp) == 1) return SCRIPT_CJK;
    if (unicode.stz_unicode_is_devanagari(cp) == 1) return SCRIPT_DEVANAGARI;
    if (unicode.stz_unicode_is_thai(cp) == 1) return SCRIPT_THAI;
    return SCRIPT_UNKNOWN;
}

/// Detect the dominant script of a string. Returns SCRIPT_MIXED if
/// multiple scripts appear, SCRIPT_UNKNOWN if no script characters found.
pub fn str_detect_script(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return SCRIPT_UNKNOWN;
    const data = s.slice();
    if (data.len == 0) return SCRIPT_UNKNOWN;

    var dominant: c_int = SCRIPT_UNKNOWN;
    var i: usize = 0;
    while (i < data.len) {
        const cp = unicode.stz_unicode_iterate(data.ptr, data.len, i);
        if (cp < 0) break;
        const blen = unicode.stz_unicode_cp_byte_len(data.ptr, data.len, i);
        if (blen <= 0) break;
        i += @intCast(blen);

        const script = classifyCodepoint(cp);
        if (script == SCRIPT_UNKNOWN) continue;

        if (dominant == SCRIPT_UNKNOWN) {
            dominant = script;
        } else if (dominant != script) {
            return SCRIPT_MIXED;
        }
    }
    return dominant;
}

/// Return the script name as a new StzString handle.
pub fn str_script_name(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const script = str_detect_script(handle);
    const name = switch (script) {
        SCRIPT_LATIN => "Latin",
        SCRIPT_ARABIC => "Arabic",
        SCRIPT_HEBREW => "Hebrew",
        SCRIPT_CYRILLIC => "Cyrillic",
        SCRIPT_GREEK => "Greek",
        SCRIPT_CJK => "CJK",
        SCRIPT_DEVANAGARI => "Devanagari",
        SCRIPT_THAI => "Thai",
        SCRIPT_MIXED => "Mixed",
        else => "Unknown",
    };
    return str_from(name.ptr, name.len);
}

/// Detect text direction: LTR, RTL, MIXED, or NEUTRAL.
/// Uses Unicode bidi class: R/AL/AN = RTL, L/EN = LTR.
pub fn str_detect_direction(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return DIR_NEUTRAL;
    const data = s.slice();
    if (data.len == 0) return DIR_NEUTRAL;

    var has_ltr = false;
    var has_rtl = false;
    var i: usize = 0;
    while (i < data.len) {
        const cp = unicode.stz_unicode_iterate(data.ptr, data.len, i);
        if (cp < 0) break;
        const blen = unicode.stz_unicode_cp_byte_len(data.ptr, data.len, i);
        if (blen <= 0) break;
        i += @intCast(blen);

        const bidi = unicode.stz_unicode_bidi_class(cp);
        // utf8proc bidi classes: 1=L, 2=LRE, 3=LRO, 5=R, 6=AL, 7=RLE, 8=RLO, 13=AN, 14=EN
        switch (bidi) {
            1, 14 => has_ltr = true, // L, EN
            5, 6, 13 => has_rtl = true, // R, AL, AN
            else => {},
        }

        if (has_ltr and has_rtl) return DIR_MIXED;
    }

    if (has_rtl) return DIR_RTL;
    if (has_ltr) return DIR_LTR;
    return DIR_NEUTRAL;
}

/// Return direction name as a new StzString handle.
pub fn str_direction_name(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const dir = str_detect_direction(handle);
    const name = switch (dir) {
        DIR_LTR => "LTR",
        DIR_RTL => "RTL",
        DIR_MIXED => "Mixed",
        else => "Neutral",
    };
    return str_from(name.ptr, name.len);
}

/// Check if string contains any RTL characters.
pub fn str_has_rtl(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const data = s.slice();
    var i: usize = 0;
    while (i < data.len) {
        const cp = unicode.stz_unicode_iterate(data.ptr, data.len, i);
        if (cp < 0) break;
        const blen = unicode.stz_unicode_cp_byte_len(data.ptr, data.len, i);
        if (blen <= 0) break;
        i += @intCast(blen);
        const bidi = unicode.stz_unicode_bidi_class(cp);
        if (bidi == 5 or bidi == 6 or bidi == 13) return 1;
    }
    return 0;
}

/// The DISTINCT script names of a string, in FIRST-APPEARANCE order,
/// NUL-terminated (a NUL after every item).
///
/// This mirrors Ring's _CharScriptCode range table branch for branch,
/// including its ORDER -- Common is tested before Latin, so digits and ASCII
/// punctuation are common and not latin (UAX #24) -- and its holes: combining
/// marks and the Arabic diacritics are `inherited`, not the surrounding
/// script. Names are the lowercase forms _aUnicodeScriptsXT yields.
///
/// It replaces a Ring loop that built a stzChar OBJECT for every character:
/// 139ms per call on a 200-char string, and enough repeated calls exhausted
/// object allocation outright ("Can not create char object!"), since Ring has
/// no destructors. The vocabulary is deliberately the SAME table rather than
/// the engine's own 8-script classifier, which would have collapsed Hangul,
/// Hiragana, Katakana, Armenian and Gujarati into one bucket.
// ---------------------------------------------------------------------------
// SCRIPT CLASSIFICATION FROM PCRE2's UNICODE CHARACTER DATABASE
//
// utf8proc -- what every other stz_unicode_* helper is built on -- carries NO
// Script property. That is why eight hand-written is_latin/is_arabic/... range
// tables existed, and why Ring carried its own 21-branch _CharScriptCode on
// top of them. But PCRE2 is vendored too, pcre2_ucd.c IS compiled into this
// engine (SUPPORT_UNICODE is defined, so the real 116KB tables land, not the
// stubs), and its UCD record carries a script code per codepoint for all 172
// scripts. The data was in the binary all along, linked for \p{...} and used
// for nothing else.
//
// Measured across the BMP before switching: the old table left 21,435
// codepoints `unknown` that have a real script, and gave 183 answers the UCD
// contradicts. Every one of those 183 was the range table approximating --
// unassigned holes claimed for their block, combining marks that belong to
// Inherited, currency and punctuation that belong to Common, Coptic letters
// sitting inside the Greek block.
// ---------------------------------------------------------------------------

const UcdRecord = extern struct {
    script: u8,
    chartype: u8,
    gbprop: u8,
    caseset: u8,
    other_case: i32,
    scriptx_bidiclass: u16,
    bprops: u16,
};

// @extern with an explicit name, not `extern const x: [*]const T` -- the
// latter declares a POINTER VARIABLE named x, whereas these are C ARRAYS and
// the symbol IS the data. The _8 is PCRE2's code-unit width: PRIV() looks
// suffix-free in the header, but the built symbols carry it.
const ucd_records = @extern([*]const UcdRecord, .{ .name = "_pcre2_ucd_records_8" });
const ucd_stage1 = @extern([*]const u16, .{ .name = "_pcre2_ucd_stage1_8" });
const ucd_stage2 = @extern([*]const u16, .{ .name = "_pcre2_ucd_stage2_8" });

const UCD_BLOCK_SIZE: u32 = 128;

// PCRE2's own REAL_GET_UCD, two-stage table lookup.
fn ucdScriptCode(cp: u32) u8 {
    if (cp > 0x10FFFF) return 98; // ucp_Unknown
    const s1 = ucd_stage1[cp / UCD_BLOCK_SIZE];
    const idx = ucd_stage2[@as(u32, s1) * UCD_BLOCK_SIZE + (cp % UCD_BLOCK_SIZE)];
    return ucd_records[idx].script;
}

const UCP_SCRIPT_NAMES = [_][]const u8{
    "latin",
    "greek",
    "cyrillic",
    "armenian",
    "hebrew",
    "arabic",
    "syriac",
    "thaana",
    "devanagari",
    "bengali",
    "gurmukhi",
    "gujarati",
    "oriya",
    "tamil",
    "telugu",
    "kannada",
    "malayalam",
    "sinhala",
    "thai",
    "tibetan",
    "myanmar",
    "georgian",
    "hangul",
    "ethiopic",
    "cherokee",
    "runic",
    "mongolian",
    "hiragana",
    "katakana",
    "bopomofo",
    "han",
    "yi",
    "gothic",
    "tagalog",
    "hanunoo",
    "buhid",
    "tagbanwa",
    "limbu",
    "taile",
    "linearb",
    "shavian",
    "cypriot",
    "buginese",
    "coptic",
    "glagolitic",
    "tifinagh",
    "sylotinagri",
    "phagspa",
    "nko",
    "kayahli",
    "lycian",
    "carian",
    "lydian",
    "avestan",
    "samaritan",
    "lisu",
    "javanese",
    "oldturkic",
    "kaithi",
    "mandaic",
    "chakma",
    "meroitichieroglyphs",
    "sharada",
    "takri",
    "caucasianalbanian",
    "duployan",
    "elbasan",
    "grantha",
    "khojki",
    "lineara",
    "mahajani",
    "manichaean",
    "modi",
    "oldpermic",
    "psalterpahlavi",
    "khudawadi",
    "tirhuta",
    "multani",
    "oldhungarian",
    "adlam",
    "osage",
    "tangut",
    "masaramgondi",
    "dogra",
    "gunjalagondi",
    "hanifirohingya",
    "sogdian",
    "nandinagari",
    "yezidi",
    "cyprominoan",
    "olduyghur",
    "toto",
    "garay",
    "gurungkhema",
    "olonal",
    "sunuwar",
    "todhri",
    "tulutigalari",
    "unknown",
    "common",
    "lao",
    "canadianaboriginal",
    "ogham",
    "khmer",
    "olditalic",
    "deseret",
    "inherited",
    "ugaritic",
    "osmanya",
    "braille",
    "newtailue",
    "oldpersian",
    "kharoshthi",
    "balinese",
    "cuneiform",
    "phoenician",
    "sundanese",
    "lepcha",
    "olchiki",
    "vai",
    "saurashtra",
    "rejang",
    "cham",
    "taitham",
    "taiviet",
    "egyptianhieroglyphs",
    "bamum",
    "meeteimayek",
    "imperialaramaic",
    "oldsoutharabian",
    "inscriptionalparthian",
    "inscriptionalpahlavi",
    "batak",
    "brahmi",
    "meroiticcursive",
    "miao",
    "sorasompeng",
    "bassavah",
    "pahawhhmong",
    "mendekikakui",
    "mro",
    "oldnortharabian",
    "nabataean",
    "palmyrene",
    "paucinhau",
    "siddham",
    "warangciti",
    "ahom",
    "anatolianhieroglyphs",
    "hatran",
    "signwriting",
    "bhaiksuki",
    "marchen",
    "newa",
    "nushu",
    "soyombo",
    "zanabazarsquare",
    "makasar",
    "medefaidrin",
    "oldsogdian",
    "elymaic",
    "nyiakengpuachuehmong",
    "wancho",
    "chorasmian",
    "divesakuru",
    "khitansmallscript",
    "tangsa",
    "vithkuqi",
    "kawi",
    "nagmundari",
    "kiratrai",
    "scriptcount"
};

fn ucdScriptName(cp: u32) []const u8 {
    const code = ucdScriptCode(cp);
    if (code < UCP_SCRIPT_NAMES.len) return UCP_SCRIPT_NAMES[code];
    return "unknown";
}

/// The DISTINCT script names of a string, in FIRST-APPEARANCE order,
/// NUL-terminated after every item.
pub fn str_script_names(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const result = core.str_new() orelse return null;
    const s = handle orelse return result;
    const data = s.slice();
    if (data.len == 0) return result;

    var seen: [64][]const u8 = undefined;
    var nseen: usize = 0;

    var i: usize = 0;
    while (i < data.len) {
        const cp = unicode.stz_unicode_iterate(data.ptr, data.len, i);
        if (cp < 0) break;
        const blen = unicode.stz_unicode_cp_byte_len(data.ptr, data.len, i);
        if (blen <= 0) break;
        i += @intCast(blen);

        const name = ucdScriptName(@intCast(cp));

        var already = false;
        for (seen[0..nseen]) |n| {
            if (std.mem.eql(u8, n, name)) { already = true; break; }
        }
        if (already) continue;

        if (nseen < seen.len) { seen[nseen] = name; nseen += 1; }
        result.data.appendSlice(gpa, name) catch break;
        result.data.append(gpa, 0) catch break;
    }

    return result;
}

/// Distinct script count INCLUDING Common -- the ruled definition, and the
/// one that must equal len(Scripts()).
///
/// Derived from the SAME UCD walk as str_script_names, so the two cannot
/// drift apart again. They previously disagreed because one counted
/// Common and the other did not.
pub fn str_script_count_all(handle: StzStringHandle) callconv(.c) c_int {
    return scriptCountImpl(handle, true);
}

/// Distinct script count EXCLUDING Common, Inherited and Unknown -- i.e. real
/// writing systems only. This is what IsMixedScript asks: a digit, a
/// combining mark or an unassigned codepoint is not a second writing system.
pub fn str_script_count(handle: StzStringHandle) callconv(.c) c_int {
    return scriptCountImpl(handle, false);
}

fn scriptCountImpl(handle: StzStringHandle, count_nonscripts: bool) c_int {
    const s = handle orelse return 0;
    const data = s.slice();
    if (data.len == 0) return 0;

    var seen: [200]u8 = undefined;
    var nseen: usize = 0;

    var i: usize = 0;
    while (i < data.len) {
        const cp = unicode.stz_unicode_iterate(data.ptr, data.len, i);
        if (cp < 0) break;
        const blen = unicode.stz_unicode_cp_byte_len(data.ptr, data.len, i);
        if (blen <= 0) break;
        i += @intCast(blen);

        const code = ucdScriptCode(@intCast(cp));

        if (!count_nonscripts) {
            // 98 = ucp_Unknown, 99 = ucp_Common, 106 = ucp_Inherited
            if (code == 98 or code == 99 or code == 106) continue;
        }

        var already = false;
        for (seen[0..nseen]) |c| {
            if (c == code) { already = true; break; }
        }
        if (already) continue;

        if (nseen < seen.len) { seen[nseen] = code; nseen += 1; }
    }

    return @intCast(nseen);
}

/// Unicode-aware locale comparison using casefold. Returns:
/// -1 (a < b), 0 (equal), 1 (a > b). Case-insensitive.
pub fn str_locale_compare(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    const s1 = h1 orelse return if (h2 == null) @as(c_int, 0) else -1;
    const s2 = h2 orelse return 1;

    const d1 = s1.slice();
    const d2 = s2.slice();

    // Casefold both strings for locale-insensitive comparison
    var out_len1: usize = 0;
    var out_len2: usize = 0;
    const cf1 = unicode.stz_unicode_casefold(d1.ptr, d1.len, &out_len1);
    const cf2 = unicode.stz_unicode_casefold(d2.ptr, d2.len, &out_len2);

    if (cf1 == null or cf2 == null) {
        if (cf1 != null) unicode.stz_unicode_casefold_free(cf1, out_len1);
        if (cf2 != null) unicode.stz_unicode_casefold_free(cf2, out_len2);
        return switch (std.mem.order(u8, d1, d2)) {
            .lt => -1,
            .gt => 1,
            .eq => 0,
        };
    }

    const slice1 = cf1[0..out_len1];
    const slice2 = cf2[0..out_len2];
    const result: c_int = switch (std.mem.order(u8, slice1, slice2)) {
        .lt => -1,
        .gt => 1,
        .eq => 0,
    };

    unicode.stz_unicode_casefold_free(cf1, out_len1);
    unicode.stz_unicode_casefold_free(cf2, out_len2);
    return result;
}

// ─── Tests ───

const testing = std.testing;

test "detect script Latin" {
    const s = str_from("Hello World", 11) orelse return error.SkipZigTest;
    defer core.str_free(s);
    try testing.expect(str_detect_script(s) == SCRIPT_LATIN);
}

test "detect script Arabic" {
    const s = str_from("\xd9\x85\xd8\xb1\xd8\xad\xd8\xa8\xd8\xa7", 10) orelse return error.SkipZigTest;
    defer core.str_free(s);
    try testing.expect(str_detect_script(s) == SCRIPT_ARABIC);
}

test "detect script Hebrew" {
    const s = str_from("\xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d", 8) orelse return error.SkipZigTest;
    defer core.str_free(s);
    try testing.expect(str_detect_script(s) == SCRIPT_HEBREW);
}

test "detect script CJK" {
    const s = str_from("\xe4\xb8\x96\xe7\x95\x8c", 6) orelse return error.SkipZigTest;
    defer core.str_free(s);
    try testing.expect(str_detect_script(s) == SCRIPT_CJK);
}

test "detect mixed script" {
    const s = str_from("Hello \xd9\x85\xd8\xb1\xd8\xad\xd8\xa8\xd8\xa7", 16) orelse return error.SkipZigTest;
    defer core.str_free(s);
    try testing.expect(str_detect_script(s) == SCRIPT_MIXED);
}

test "detect direction LTR" {
    const s = str_from("Hello", 5) orelse return error.SkipZigTest;
    defer core.str_free(s);
    try testing.expect(str_detect_direction(s) == DIR_LTR);
}

test "detect direction RTL" {
    const s = str_from("\xd9\x85\xd8\xb1\xd8\xad\xd8\xa8\xd8\xa7", 10) orelse return error.SkipZigTest;
    defer core.str_free(s);
    try testing.expect(str_detect_direction(s) == DIR_RTL);
}

test "detect direction mixed" {
    const s = str_from("Hello \xd9\x85\xd8\xb1\xd8\xad\xd8\xa8\xd8\xa7", 16) orelse return error.SkipZigTest;
    defer core.str_free(s);
    try testing.expect(str_detect_direction(s) == DIR_MIXED);
}

test "has_rtl true for Arabic" {
    const s = str_from("\xd9\x85", 2) orelse return error.SkipZigTest;
    defer core.str_free(s);
    try testing.expect(str_has_rtl(s) == 1);
}

test "has_rtl false for Latin" {
    const s = str_from("abc", 3) orelse return error.SkipZigTest;
    defer core.str_free(s);
    try testing.expect(str_has_rtl(s) == 0);
}

test "script count single" {
    const s = str_from("Hello", 5) orelse return error.SkipZigTest;
    defer core.str_free(s);
    try testing.expect(str_script_count(s) == 1);
}

test "script count multi" {
    const s = str_from("Hello \xd9\x85\xd8\xb1\xd8\xad\xd8\xa8\xd8\xa7", 16) orelse return error.SkipZigTest;
    defer core.str_free(s);
    try testing.expect(str_script_count(s) == 2);
}

test "locale compare case insensitive" {
    const s1 = str_from("Hello", 5) orelse return error.SkipZigTest;
    defer core.str_free(s1);
    const s2 = str_from("hello", 5) orelse return error.SkipZigTest;
    defer core.str_free(s2);
    try testing.expect(str_locale_compare(s1, s2) == 0);
}

test "locale compare ordering" {
    const s1 = str_from("apple", 5) orelse return error.SkipZigTest;
    defer core.str_free(s1);
    const s2 = str_from("banana", 6) orelse return error.SkipZigTest;
    defer core.str_free(s2);
    try testing.expect(str_locale_compare(s1, s2) == -1);
    try testing.expect(str_locale_compare(s2, s1) == 1);
}

test "script name returns correct string" {
    const s = str_from("Hello", 5) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const name = str_script_name(s) orelse return error.SkipZigTest;
    defer core.str_free(name);
    try testing.expectEqualStrings("Latin", name.slice());
}

test "direction name RTL" {
    const s = str_from("\xd9\x85\xd8\xb1\xd8\xad\xd8\xa8\xd8\xa7", 10) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const name = str_direction_name(s) orelse return error.SkipZigTest;
    defer core.str_free(name);
    try testing.expectEqualStrings("RTL", name.slice());
}
