// Softanza Engine -- Stemming (Snowball / libstemmer, 25 languages)
//
// Reduces inflected words to their stem ("running"->"run", French
// "finalement"->"final", German "gearbeitet"->"arbeit") so search, dedup and
// matching group word variants. Backed by the VENDORED Snowball libstemmer
// (vendor/snowball, BSD, the reference algorithms) -- not hand-rolled.
//
// 25 languages vendored (UTF-8): english (default) + arabic, basque, catalan,
// danish, dutch, finnish, french, german, greek, hindi, hungarian, indonesian,
// irish, italian, lithuanian, nepali, norwegian, portuguese, romanian, russian,
// spanish, swedish, tamil, turkish. Adding another = vendor its stem_UTF_8_<l>.c
// + its 3 externs + one table row.
//
// Words are tokenized through the UAX#29 seam (word_break.WordIter) and each is
// Unicode-lowercased (Snowball expects lowercase, incl. accents/Cyrillic) then
// stemmed. str_stem_text stems in place keeping separators; str_stem_words
// returns the NUL-delimited stem list. Language is selected by name (unknown ->
// english).

const std = @import("std");
const core = @import("core.zig");
const wb = @import("word_break.zig");
const unicode = core.unicode;
const gpa = core.gpa;
const StzStringHandle = core.StzStringHandle;
const str_new = core.str_new;

// Mirror of libstemmer's struct SN_env (vendor/snowball/runtime/api.h). Only p
// (the current string buffer) and l (its length) are read after stemming.
const SN_env = extern struct {
    p: [*c]u8,
    c: c_int,
    l: c_int,
    lb: c_int,
    bra: c_int,
    ket: c_int,
    S: [*c][*c]u8,
    I: [*c]c_int,
    B: [*c]u8,
};
extern fn SN_set_current(z: ?*SN_env, size: c_int, s: [*c]const u8) callconv(.c) c_int;

extern fn arabic_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn arabic_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn arabic_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn basque_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn basque_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn basque_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn catalan_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn catalan_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn catalan_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn danish_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn danish_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn danish_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn dutch_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn dutch_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn dutch_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn english_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn english_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn english_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn finnish_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn finnish_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn finnish_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn french_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn french_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn french_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn german_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn german_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn german_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn greek_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn greek_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn greek_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn hindi_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn hindi_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn hindi_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn hungarian_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn hungarian_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn hungarian_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn indonesian_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn indonesian_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn indonesian_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn irish_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn irish_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn irish_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn italian_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn italian_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn italian_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn lithuanian_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn lithuanian_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn lithuanian_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn nepali_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn nepali_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn nepali_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn norwegian_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn norwegian_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn norwegian_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn portuguese_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn portuguese_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn portuguese_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn romanian_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn romanian_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn romanian_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn russian_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn russian_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn russian_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn spanish_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn spanish_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn spanish_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn swedish_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn swedish_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn swedish_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn tamil_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn tamil_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn tamil_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn turkish_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn turkish_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn turkish_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;

const LangEntry = struct {
    name: []const u8,
    create: *const fn () callconv(.c) ?*SN_env,
    stem: *const fn (?*SN_env) callconv(.c) c_int,
    close: *const fn (?*SN_env) callconv(.c) void,
};

// english first so index 0 is the default.
const langs = [_]LangEntry{
    .{ .name = "english", .create = english_UTF_8_create_env, .stem = english_UTF_8_stem, .close = english_UTF_8_close_env },
    .{ .name = "arabic", .create = arabic_UTF_8_create_env, .stem = arabic_UTF_8_stem, .close = arabic_UTF_8_close_env },
    .{ .name = "basque", .create = basque_UTF_8_create_env, .stem = basque_UTF_8_stem, .close = basque_UTF_8_close_env },
    .{ .name = "catalan", .create = catalan_UTF_8_create_env, .stem = catalan_UTF_8_stem, .close = catalan_UTF_8_close_env },
    .{ .name = "danish", .create = danish_UTF_8_create_env, .stem = danish_UTF_8_stem, .close = danish_UTF_8_close_env },
    .{ .name = "dutch", .create = dutch_UTF_8_create_env, .stem = dutch_UTF_8_stem, .close = dutch_UTF_8_close_env },
    .{ .name = "finnish", .create = finnish_UTF_8_create_env, .stem = finnish_UTF_8_stem, .close = finnish_UTF_8_close_env },
    .{ .name = "french", .create = french_UTF_8_create_env, .stem = french_UTF_8_stem, .close = french_UTF_8_close_env },
    .{ .name = "german", .create = german_UTF_8_create_env, .stem = german_UTF_8_stem, .close = german_UTF_8_close_env },
    .{ .name = "greek", .create = greek_UTF_8_create_env, .stem = greek_UTF_8_stem, .close = greek_UTF_8_close_env },
    .{ .name = "hindi", .create = hindi_UTF_8_create_env, .stem = hindi_UTF_8_stem, .close = hindi_UTF_8_close_env },
    .{ .name = "hungarian", .create = hungarian_UTF_8_create_env, .stem = hungarian_UTF_8_stem, .close = hungarian_UTF_8_close_env },
    .{ .name = "indonesian", .create = indonesian_UTF_8_create_env, .stem = indonesian_UTF_8_stem, .close = indonesian_UTF_8_close_env },
    .{ .name = "irish", .create = irish_UTF_8_create_env, .stem = irish_UTF_8_stem, .close = irish_UTF_8_close_env },
    .{ .name = "italian", .create = italian_UTF_8_create_env, .stem = italian_UTF_8_stem, .close = italian_UTF_8_close_env },
    .{ .name = "lithuanian", .create = lithuanian_UTF_8_create_env, .stem = lithuanian_UTF_8_stem, .close = lithuanian_UTF_8_close_env },
    .{ .name = "nepali", .create = nepali_UTF_8_create_env, .stem = nepali_UTF_8_stem, .close = nepali_UTF_8_close_env },
    .{ .name = "norwegian", .create = norwegian_UTF_8_create_env, .stem = norwegian_UTF_8_stem, .close = norwegian_UTF_8_close_env },
    .{ .name = "portuguese", .create = portuguese_UTF_8_create_env, .stem = portuguese_UTF_8_stem, .close = portuguese_UTF_8_close_env },
    .{ .name = "romanian", .create = romanian_UTF_8_create_env, .stem = romanian_UTF_8_stem, .close = romanian_UTF_8_close_env },
    .{ .name = "russian", .create = russian_UTF_8_create_env, .stem = russian_UTF_8_stem, .close = russian_UTF_8_close_env },
    .{ .name = "spanish", .create = spanish_UTF_8_create_env, .stem = spanish_UTF_8_stem, .close = spanish_UTF_8_close_env },
    .{ .name = "swedish", .create = swedish_UTF_8_create_env, .stem = swedish_UTF_8_stem, .close = swedish_UTF_8_close_env },
    .{ .name = "tamil", .create = tamil_UTF_8_create_env, .stem = tamil_UTF_8_stem, .close = tamil_UTF_8_close_env },
    .{ .name = "turkish", .create = turkish_UTF_8_create_env, .stem = turkish_UTF_8_stem, .close = turkish_UTF_8_close_env },
};

// One reusable env per language (single-threaded engine), created lazily.
var envs: [langs.len]?*SN_env = [_]?*SN_env{null} ** langs.len;

fn asciiEqlFold(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) return false;
    for (a, b) |x, y| {
        const lx = if (x >= 'A' and x <= 'Z') x + 32 else x;
        if (lx != y) return false; // table names are already lowercase
    }
    return true;
}

// Language index for `name` (case-insensitive); 0 (english) if unknown/empty.
fn langIndex(name: []const u8) usize {
    if (name.len == 0) return 0;
    for (langs, 0..) |L, i| {
        if (asciiEqlFold(name, L.name)) return i;
    }
    return 0;
}

// Unicode-lowercase `word` into `buf` (Snowball expects lowercase input, incl.
// accents and Cyrillic). Returns the original word on buffer overflow.
fn lowerInto(word: []const u8, buf: []u8) []const u8 {
    var oi: usize = 0;
    var i: usize = 0;
    while (i < word.len) {
        const b = word[i];
        if (b < 0x80) {
            if (oi >= buf.len) return word;
            buf[oi] = if (b >= 'A' and b <= 'Z') b + 32 else b;
            oi += 1;
            i += 1;
            continue;
        }
        const cl = std.unicode.utf8ByteSequenceLength(b) catch {
            i += 1;
            continue;
        };
        if (i + cl > word.len) break;
        const cp = std.unicode.utf8Decode(word[i .. i + cl]) catch {
            i += cl;
            continue;
        };
        const lc: u21 = @intCast(unicode.stz_unicode_to_lower(@intCast(cp)));
        var tmp: [4]u8 = undefined;
        const n = std.unicode.utf8Encode(lc, &tmp) catch {
            i += cl;
            continue;
        };
        if (oi + n > buf.len) return word;
        @memcpy(buf[oi .. oi + n], tmp[0..n]);
        oi += n;
        i += cl;
    }
    return buf[0..oi];
}

// Stem `word` in language `li`, appending the result to `out`. On any failure
// the ORIGINAL word is appended unchanged.
fn stemInto(word: []const u8, out: *std.ArrayList(u8), li: usize) void {
    if (word.len == 0) return;
    const L = langs[li];
    if (envs[li] == null) envs[li] = L.create();
    const z = envs[li] orelse {
        out.appendSlice(gpa, word) catch {};
        return;
    };
    var buf: [256]u8 = undefined;
    const w = if (word.len <= buf.len) lowerInto(word, &buf) else word;

    if (SN_set_current(z, @intCast(w.len), w.ptr) < 0) {
        out.appendSlice(gpa, word) catch {};
        return;
    }
    if (L.stem(z) < 0) {
        out.appendSlice(gpa, word) catch {};
        return;
    }
    const n: usize = @intCast(z.l);
    out.appendSlice(gpa, z.p[0..n]) catch {};
}

fn langOf(lang: [*c]const u8, lang_len: usize) usize {
    return if (lang == null or lang_len == 0) 0 else langIndex(lang[0..lang_len]);
}

// Stem a single word (raw bytes) -> a fresh string.
pub fn str_stem_word(word: [*c]const u8, len: usize, lang: [*c]const u8, lang_len: usize) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    if (word == null or len == 0) return result;
    stemInto(word[0..len], &result.data, langOf(lang, lang_len));
    return result;
}

// Stem every word token; return them NUL-delimited (drains like Words()).
pub fn str_stem_words(handle: StzStringHandle, lang: [*c]const u8, lang_len: usize) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    const s = handle orelse return result;
    const li = langOf(lang, lang_len);
    const src = s.slice();
    var wit = wb.WordIter.init(src);
    var first = true;
    while (wit.next()) |span| {
        if (!first) result.data.append(gpa, 0) catch break;
        stemInto(src[span.start..span.end], &result.data, li);
        first = false;
    }
    return result;
}

// Stem words IN PLACE: rebuild the text, replacing each word token with its stem
// and copying the bytes between words (whitespace/punctuation) verbatim.
pub fn str_stem_text(handle: StzStringHandle, lang: [*c]const u8, lang_len: usize) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    const s = handle orelse return result;
    const li = langOf(lang, lang_len);
    const src = s.slice();
    var wit = wb.WordIter.init(src);
    var last: usize = 0;
    while (wit.next()) |span| {
        result.data.appendSlice(gpa, src[last..span.start]) catch break; // separator verbatim
        stemInto(src[span.start..span.end], &result.data, li);
        last = span.end;
    }
    result.data.appendSlice(gpa, src[last..]) catch {};
    return result;
}

const testing = std.testing;
const str_from = core.str_from;
const str_free = core.str_free;

test "stem english in place preserves separators" {
    const s = str_from("the runners are running", 23) orelse return error.SkipZigTest;
    defer str_free(s);
    const r = str_stem_text(s, "english", 7) orelse return error.SkipZigTest;
    defer str_free(r);
    try testing.expectEqualStrings("the runner are run", r.slice());
}

test "unknown language falls back to english" {
    const s = str_from("running", 7) orelse return error.SkipZigTest;
    defer str_free(s);
    const r = str_stem_text(s, "klingon", 7) orelse return error.SkipZigTest;
    defer str_free(r);
    try testing.expectEqualStrings("run", r.slice());
}
