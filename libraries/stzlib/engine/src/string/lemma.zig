// Softanza Engine -- Lemmatization (dictionary + rule fallback), English
//
// Reduces a word to its DICTIONARY form (lemma): "was"->"be", "better"->"good",
// "mice"->"mouse", "running"->"run". Unlike stemming (algorithmic, "was"->"wa"),
// lemmatization handles irregulars and returns real words. Backed by a vendored
// lemma dictionary (src/string/data/lemmatization-en.txt, Wiktionary-derived,
// ODbL -- see its NOTICE) COMPILED IN via @embedFile: no runtime data files,
// same "everything in the binary" model as utf8proc/pcre2/snowball tables.
// (@embedFile requires the data under the module's src/ tree, not vendor/.)
//
// Strategy (spaCy "lookup" lemmatizer + WordNet-morphy-style fallback):
//   1. exact lookup form -> lemma (covers all irregulars + common inflections);
//   2. if missing, strip regular English suffixes (-s/-es/-ies/-ed/-ing, incl.
//      doubled consonants and silent-e) and accept a candidate ONLY if it is a
//      known lemma -- the lemma column doubles as the validation dictionary;
//   3. else return the word unchanged (never mangle).
// English only for now; other languages are a drop-in (embed lemmatization-<l>.txt
// + one table row). Words are tokenized through the UAX#29 seam (WordIter).

const std = @import("std");
const core = @import("core.zig");
const wb = @import("word_break.zig");
const gpa = core.gpa;
const StzStringHandle = core.StzStringHandle;
const str_new = core.str_new;

const lemma_en_data = @embedFile("data/lemmatization-en.txt");

// Lazily-built once. Keys/values are SLICES INTO the embedded static data
// (comptime bytes, valid for the program's lifetime) -- no per-entry allocation.
var g_built = false;
var g_form2lemma: std.StringHashMap([]const u8) = undefined;
var g_lemmas: std.StringHashMap(void) = undefined;

fn buildTables() void {
    if (g_built) return;
    g_form2lemma = std.StringHashMap([]const u8).init(gpa);
    g_lemmas = std.StringHashMap(void).init(gpa);
    var it = std.mem.splitScalar(u8, lemma_en_data, '\n');
    while (it.next()) |raw| {
        const line = std.mem.trimRight(u8, raw, "\r");
        if (line.len == 0) continue;
        const tab = std.mem.indexOfScalar(u8, line, '\t') orelse continue;
        const lemma = line[0..tab];
        const form = line[tab + 1 ..];
        if (lemma.len == 0 or form.len == 0) continue;
        g_form2lemma.put(form, lemma) catch {};
        g_lemmas.put(lemma, {}) catch {};
    }
    g_built = true;
}

fn isKnownLemma(s: []const u8) bool {
    return g_lemmas.contains(s);
}

// Regular-inflection detachment rules. Writes each candidate into `cbuf`, returns
// the first that is a known lemma (a static slice via the lemma set), else null.
fn ruleFallback(w: []const u8, cbuf: []u8) ?[]const u8 {
    const n = w.len;
    // helper: validate a candidate built from a base slice (+ optional suffix)
    const Try = struct {
        fn ok(base: []const u8, suffix: []const u8, buf: []u8) ?[]const u8 {
            if (base.len + suffix.len > buf.len) return null;
            @memcpy(buf[0..base.len], base);
            @memcpy(buf[base.len .. base.len + suffix.len], suffix);
            const cand = buf[0 .. base.len + suffix.len];
            return if (g_lemmas.contains(cand)) cand else null;
        }
    };

    // plurals / 3rd person: -ies -> -y ; -es -> "" ; -s -> ""
    if (n > 4 and std.mem.endsWith(u8, w, "ies")) {
        if (Try.ok(w[0 .. n - 3], "y", cbuf)) |c| return c;
    }
    if (n > 3 and std.mem.endsWith(u8, w, "es")) {
        if (Try.ok(w[0 .. n - 2], "", cbuf)) |c| return c; // boxes -> box
        if (Try.ok(w[0 .. n - 1], "", cbuf)) |c| return c; // uses -> use
    }
    if (n > 2 and w[n - 1] == 's' and w[n - 2] != 's') {
        if (Try.ok(w[0 .. n - 1], "", cbuf)) |c| return c; // cats -> cat
    }
    // past tense: -ed -> "" / +e / doubled-consonant
    if (n > 3 and std.mem.endsWith(u8, w, "ed")) {
        if (Try.ok(w[0 .. n - 1], "", cbuf)) |c| return c; // used -> use
        if (Try.ok(w[0 .. n - 2], "", cbuf)) |c| return c; // walked -> walk
        if (n > 4 and w[n - 3] == w[n - 4]) {
            if (Try.ok(w[0 .. n - 3], "", cbuf)) |c| return c; // stopped -> stop
        }
    }
    // present participle / gerund: -ing -> "" / +e / doubled-consonant
    if (n > 4 and std.mem.endsWith(u8, w, "ing")) {
        if (Try.ok(w[0 .. n - 3], "e", cbuf)) |c| return c; // making -> make
        if (Try.ok(w[0 .. n - 3], "", cbuf)) |c| return c; // reading -> read
        if (n > 5 and w[n - 4] == w[n - 5]) {
            if (Try.ok(w[0 .. n - 4], "", cbuf)) |c| return c; // running -> run
        }
    }
    // comparative/superlative: -er/-est -> "" / +e (validated)
    if (n > 3 and std.mem.endsWith(u8, w, "er")) {
        if (Try.ok(w[0 .. n - 2], "", cbuf)) |c| return c;
        if (Try.ok(w[0 .. n - 1], "", cbuf)) |c| return c;
    }
    if (n > 4 and std.mem.endsWith(u8, w, "est")) {
        if (Try.ok(w[0 .. n - 3], "", cbuf)) |c| return c;
        if (Try.ok(w[0 .. n - 2], "", cbuf)) |c| return c;
    }
    return null;
}

// Lemmatize `word` into `out`. Found -> canonical (lowercase) lemma; unknown ->
// the ORIGINAL word unchanged (case preserved). lang != english -> passthrough
// (only English data is embedded so far).
fn lemmatizeInto(word: []const u8, out: *std.ArrayList(u8), english: bool) void {
    if (word.len == 0) return;
    if (!english) {
        out.appendSlice(gpa, word) catch {};
        return;
    }
    buildTables();
    var lbuf: [128]u8 = undefined;
    var cbuf: [160]u8 = undefined;
    // ASCII-lowercase the lookup key (English lemma data is ASCII).
    const key: []const u8 = if (word.len <= lbuf.len) blk: {
        for (word, 0..) |ch, i| lbuf[i] = if (ch >= 'A' and ch <= 'Z') ch + 32 else ch;
        break :blk lbuf[0..word.len];
    } else word;

    if (g_form2lemma.get(key)) |lemma| {
        out.appendSlice(gpa, lemma) catch {};
        return;
    }
    if (ruleFallback(key, &cbuf)) |cand| {
        out.appendSlice(gpa, cand) catch {};
        return;
    }
    out.appendSlice(gpa, word) catch {}; // unknown -> leave as-is
}

fn isEnglish(lang: [*c]const u8, lang_len: usize) bool {
    if (lang == null or lang_len == 0) return true;
    const s = lang[0..lang_len];
    if (s.len != 7) return false;
    var buf: [7]u8 = undefined;
    for (s, 0..) |ch, i| buf[i] = if (ch >= 'A' and ch <= 'Z') ch + 32 else ch;
    return std.mem.eql(u8, &buf, "english");
}

pub fn str_lemmatize_word(word: [*c]const u8, len: usize, lang: [*c]const u8, lang_len: usize) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    if (word == null or len == 0) return result;
    lemmatizeInto(word[0..len], &result.data, isEnglish(lang, lang_len));
    return result;
}

pub fn str_lemmatize_words(handle: StzStringHandle, lang: [*c]const u8, lang_len: usize) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    const s = handle orelse return result;
    const en = isEnglish(lang, lang_len);
    const src = s.slice();
    var wit = wb.WordIter.init(src);
    var first = true;
    while (wit.next()) |span| {
        if (!first) result.data.append(gpa, 0) catch break;
        lemmatizeInto(src[span.start..span.end], &result.data, en);
        first = false;
    }
    return result;
}

pub fn str_lemmatize_text(handle: StzStringHandle, lang: [*c]const u8, lang_len: usize) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    const s = handle orelse return result;
    const en = isEnglish(lang, lang_len);
    const src = s.slice();
    var wit = wb.WordIter.init(src);
    var last: usize = 0;
    while (wit.next()) |span| {
        result.data.appendSlice(gpa, src[last..span.start]) catch break; // separators verbatim
        lemmatizeInto(src[span.start..span.end], &result.data, en);
        last = span.end;
    }
    result.data.appendSlice(gpa, src[last..]) catch {};
    return result;
}

const testing = std.testing;
const str_from = core.str_from;
const str_free = core.str_free;

test "lemmatize irregulars + regulars in place" {
    const s = str_from("the mice were running better", 28) orelse return error.SkipZigTest;
    defer str_free(s);
    const r = str_lemmatize_text(s, "english", 7) orelse return error.SkipZigTest;
    defer str_free(r);
    try testing.expectEqualStrings("the mouse be run good", r.slice());
}

test "unknown word passes through" {
    const s = str_from("Zorptastic", 10) orelse return error.SkipZigTest;
    defer str_free(s);
    const r = str_lemmatize_text(s, "english", 7) orelse return error.SkipZigTest;
    defer str_free(r);
    try testing.expectEqualStrings("Zorptastic", r.slice());
}
