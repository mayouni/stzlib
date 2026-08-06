// Softanza Engine -- Lemmatization (dictionary + rule fallback), multi-language
//
// Reduces a word to its DICTIONARY form (lemma): "was"->"be", "mice"->"mouse";
// French "chevaux"->"cheval", "mangé"->"manger". Unlike stemming (algorithmic),
// lemmatization handles irregulars and returns real words. Backed by vendored
// lemma dictionaries (michmech/lemmatization-lists, ODbL -- see NOTICE) COMPILED
// IN via @embedFile: no runtime files, same model as utf8proc/pcre2/snowball.
// (@embedFile requires the data under src/, so it lives in src/string/data/.)
//
// Per language: exact lookup form->lemma; for English also a regular-suffix
// fallback validated against the lemma set (the lemma column doubles as the
// validation dictionary); else the word is returned unchanged (never mangled).
// The lookup key is UNICODE-lowercased (needed for accented forms). Adding a
// language = @embedFile lemmatization-<l>.txt + one row in `langs`.

const std = @import("std");
const ascii = @import("../ascii.zig");
const core = @import("core.zig");
const wb = @import("word_break.zig");
const unicode = core.unicode;
const mem = core.mem;
const gpa = core.gpa;
const StzStringHandle = core.StzStringHandle;
const str_new = core.str_new;

const lemma_en_data = @embedFile("data/lemmatization-en.txt");
const lemma_fr_data = @embedFile("data/lemmatization-fr.txt");
const lemma_ar_data = @embedFile("data/lemmatization-ar.txt");

const Lang = struct {
    name: []const u8,
    data: []const u8,
    rules: bool, // apply the English regular-suffix fallback
};

// english first so index 0 is the default.
const langs = [_]Lang{
    .{ .name = "english", .data = lemma_en_data, .rules = true },
    .{ .name = "french", .data = lemma_fr_data, .rules = false },
    // Arabic: UD-PADT-derived (~15k), diacritics stripped -- see NOTICE. Coverage
    // is treebank-bound; StemmedInLanguage("arabic") complements OOV words.
    .{ .name = "arabic", .data = lemma_ar_data, .rules = false },
};

// Arabic diacritics / tatweel -- stripped from the lookup key so undiacritized
// input matches the (diacritic-stripped) Arabic dictionary.
fn isArabicDiacritic(cp: u21) bool {
    return cp == 0x0640 or (cp >= 0x064B and cp <= 0x065F) or cp == 0x0670;
}

const Maps = struct {
    f2l: std.StringHashMap([]const u8) = undefined,
    lemmas: std.StringHashMap(void) = undefined,
    built: bool = false,
};
var g_maps: [langs.len]Maps = [_]Maps{.{}} ** langs.len;

fn buildLang(li: usize) void {
    if (g_maps[li].built) return;
    g_maps[li].f2l = std.StringHashMap([]const u8).init(gpa);
    g_maps[li].lemmas = std.StringHashMap(void).init(gpa);
    var it = std.mem.splitScalar(u8, langs[li].data, '\n');
    while (it.next()) |raw| {
        const line = std.mem.trimRight(u8, raw, "\r");
        const tab = std.mem.indexOfScalar(u8, line, '\t') orelse continue;
        const lemma = line[0..tab];
        const form = line[tab + 1 ..];
        if (lemma.len == 0 or form.len == 0) continue;
        // TIE-BREAK, and it is currently an ARTIFACT rather than a policy: a form
        // can be an inflection of several lemmas ("better" of both good and well;
        // "worse" of bad, ill and wrong; "asses" of both ass and asse), and `put`
        // OVERWRITES, so the LAST matching row wins. The file is sorted by lemma,
        // which makes the effective rule "the alphabetically last lemma wins" --
        // a criterion with no linguistic content. It yields worse->wrong,
        // asses->asse and arses->arsis.
        //
        // 172 of the 41582 English forms are ambiguous this way. Resolving them
        // properly needs either POS at the call site (this function has none) or a
        // deliberate preference rule; prefer-shortest fixes most of the bad cases
        // but not all (altercations->alteration is a data error that last-wins
        // happens to dodge). Left as-is on purpose, documented, and pinned by
        // "lemmatize: an ambiguous form resolves by the map tie-break" below, so
        // any change to it is a decision rather than a surprise.
        g_maps[li].f2l.put(form, lemma) catch {};
        g_maps[li].lemmas.put(lemma, {}) catch {};
    }
    g_maps[li].built = true;
}

// Language index for `name` (case-insensitive ASCII); 0 (english) if unknown.
fn langIndex(name: []const u8) usize {
    if (name.len == 0) return 0;
    var buf: [16]u8 = undefined;
    if (name.len > buf.len) return 0;
    for (name, 0..) |c, i| buf[i] = ascii.lower(c);
    const key = buf[0..name.len];
    for (langs, 0..) |L, i| {
        if (mem.eql(u8, key, L.name)) return i;
    }
    return 0;
}

// Unicode-lowercase `word` into `buf` (needed for accented forms -- French "Été"
// -> "été"; ASCII fast path). Returns the original word on buffer overflow.
fn lowerUnicode(word: []const u8, buf: []u8) []const u8 {
    var oi: usize = 0;
    var i: usize = 0;
    while (i < word.len) {
        const b = word[i];
        if (b < 0x80) {
            if (oi >= buf.len) return word;
            buf[oi] = ascii.lower(b);
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
        if (isArabicDiacritic(cp)) {
            i += cl; // drop diacritics/tatweel from the key
            continue;
        }
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

// English regular-inflection detachment rules; accept a candidate only if it is
// a known lemma of `lemmas`. Writes candidates into `cbuf`.
fn ruleFallback(w: []const u8, cbuf: []u8, lemmas: *std.StringHashMap(void)) ?[]const u8 {
    const n = w.len;
    const Try = struct {
        fn ok(base: []const u8, suffix: []const u8, buf: []u8, set: *std.StringHashMap(void)) ?[]const u8 {
            if (base.len + suffix.len > buf.len) return null;
            @memcpy(buf[0..base.len], base);
            @memcpy(buf[base.len .. base.len + suffix.len], suffix);
            const cand = buf[0 .. base.len + suffix.len];
            return if (set.contains(cand)) cand else null;
        }
    };
    if (n > 4 and std.mem.endsWith(u8, w, "ies")) {
        if (Try.ok(w[0 .. n - 3], "y", cbuf, lemmas)) |c| return c;
    }
    if (n > 3 and std.mem.endsWith(u8, w, "es")) {
        if (Try.ok(w[0 .. n - 2], "", cbuf, lemmas)) |c| return c;
        if (Try.ok(w[0 .. n - 1], "", cbuf, lemmas)) |c| return c;
    }
    if (n > 2 and w[n - 1] == 's' and w[n - 2] != 's') {
        if (Try.ok(w[0 .. n - 1], "", cbuf, lemmas)) |c| return c;
    }
    if (n > 3 and std.mem.endsWith(u8, w, "ed")) {
        if (Try.ok(w[0 .. n - 1], "", cbuf, lemmas)) |c| return c;
        if (Try.ok(w[0 .. n - 2], "", cbuf, lemmas)) |c| return c;
        if (n > 4 and w[n - 3] == w[n - 4]) {
            if (Try.ok(w[0 .. n - 3], "", cbuf, lemmas)) |c| return c;
        }
    }
    if (n > 4 and std.mem.endsWith(u8, w, "ing")) {
        if (Try.ok(w[0 .. n - 3], "e", cbuf, lemmas)) |c| return c;
        if (Try.ok(w[0 .. n - 3], "", cbuf, lemmas)) |c| return c;
        if (n > 5 and w[n - 4] == w[n - 5]) {
            if (Try.ok(w[0 .. n - 4], "", cbuf, lemmas)) |c| return c;
        }
    }
    if (n > 3 and std.mem.endsWith(u8, w, "er")) {
        if (Try.ok(w[0 .. n - 2], "", cbuf, lemmas)) |c| return c;
        if (Try.ok(w[0 .. n - 1], "", cbuf, lemmas)) |c| return c;
    }
    if (n > 4 and std.mem.endsWith(u8, w, "est")) {
        if (Try.ok(w[0 .. n - 3], "", cbuf, lemmas)) |c| return c;
        if (Try.ok(w[0 .. n - 2], "", cbuf, lemmas)) |c| return c;
    }
    return null;
}

fn lemmatizeInto(word: []const u8, out: *std.ArrayList(u8), li: usize) void {
    if (word.len == 0) return;
    buildLang(li);
    var lbuf: [128]u8 = undefined;
    var cbuf: [160]u8 = undefined;
    const key = lowerUnicode(word, &lbuf);
    if (g_maps[li].f2l.get(key)) |lemma| {
        out.appendSlice(gpa, lemma) catch {};
        return;
    }
    if (langs[li].rules) {
        if (ruleFallback(key, &cbuf, &g_maps[li].lemmas)) |cand| {
            out.appendSlice(gpa, cand) catch {};
            return;
        }
    }
    out.appendSlice(gpa, word) catch {}; // unknown -> leave as-is
}

fn langOf(lang: [*c]const u8, lang_len: usize) usize {
    return if (lang == null or lang_len == 0) 0 else langIndex(lang[0..lang_len]);
}

pub fn str_lemmatize_word(word: [*c]const u8, len: usize, lang: [*c]const u8, lang_len: usize) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    if (word == null or len == 0) return result;
    lemmatizeInto(word[0..len], &result.data, langOf(lang, lang_len));
    return result;
}

pub fn str_lemmatize_words(handle: StzStringHandle, lang: [*c]const u8, lang_len: usize) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    const s = handle orelse return result;
    const li = langOf(lang, lang_len);
    const src = s.slice();
    var wit = wb.WordIter.init(src);
    var first = true;
    while (wit.next()) |span| {
        if (!first) result.data.append(gpa, 0) catch break;
        lemmatizeInto(src[span.start..span.end], &result.data, li);
        first = false;
    }
    return result;
}

pub fn str_lemmatize_text(handle: StzStringHandle, lang: [*c]const u8, lang_len: usize) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    const s = handle orelse return result;
    const li = langOf(lang, lang_len);
    const src = s.slice();
    var wit = wb.WordIter.init(src);
    var last: usize = 0;
    while (wit.next()) |span| {
        result.data.appendSlice(gpa, src[last..span.start]) catch break; // separators verbatim
        lemmatizeInto(src[span.start..span.end], &result.data, li);
        last = span.end;
    }
    result.data.appendSlice(gpa, src[last..]) catch {};
    return result;
}

const testing = std.testing;
const str_from = core.str_from;
const str_free = core.str_free;

test "lemmatize english irregulars in place" {
    // UPDATED 2026-07-25. This asserted "the mouse be run good" and was getting
    // "...run well". NEITHER the test nor the implementation was simply wrong:
    // "better" is the comparative of BOTH "good" (adjective) and "well" (adverb),
    // the dictionary holds both rows, and this lemmatizer is POS-BLIND -- it looks
    // a form up by itself. So which lemma comes out is decided by the map-build
    // tie-break, not by grammar (see buildLang).
    //
    // The test now asserts what its NAME claims: the unambiguous irregulars.
    const s = str_from("the mice were running", 21) orelse return error.SkipZigTest;
    defer str_free(s);
    const r = str_lemmatize_text(s, "english", 7) orelse return error.SkipZigTest;
    defer str_free(r);
    try testing.expectEqualStrings("the mouse be run", r.slice());
}

test "lemmatize: an ambiguous form resolves by the map tie-break, not by grammar" {
    // PINNED DELIBERATELY. "better" -> "well" is not a linguistic judgement; it is
    // the last matching row in lemmatization-en.txt winning, because that file is
    // sorted by lemma and StringHashMap.put overwrites. There are 172 such
    // ambiguous forms in the English data.
    //
    // This test exists so that a future data edit -- or a change to the tie-break
    // -- FAILS LOUDLY here instead of silently altering 172 lemmas. If the
    // tie-break policy is ever made principled (prefer-shortest, POS-aware, or a
    // curated preference list), update this expectation on purpose.
    const s = str_from("better", 6) orelse return error.SkipZigTest;
    defer str_free(s);
    const r = str_lemmatize_text(s, "english", 7) orelse return error.SkipZigTest;
    defer str_free(r);
    try testing.expectEqualStrings("well", r.slice());

    // and the one that shows the cost of an unprincipled tie-break: "worse" is the
    // comparative of bad / ill / wrong, and the alphabetically last of those wins.
    const s2 = str_from("worse", 5) orelse return error.SkipZigTest;
    defer str_free(s2);
    const r2 = str_lemmatize_text(s2, "english", 7) orelse return error.SkipZigTest;
    defer str_free(r2);
    try testing.expectEqualStrings("wrong", r2.slice());
}
