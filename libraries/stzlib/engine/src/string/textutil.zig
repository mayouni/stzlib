// Softanza Engine -- Text utilities: stopwords + readability
//
// Cheap, commonly-needed text helpers that compose the UAX#29 seams.
//   * Stopwords: drop/keep the ~120 English function words (search, keyword
//     extraction). List @embedFile'd (stopwords_en.txt).
//   * Readability: Flesch Reading Ease + Flesch-Kincaid Grade Level, from
//     word/sentence counts (WordIter/SentenceIter) and a syllable heuristic.

const std = @import("std");
const core = @import("core.zig");
const wb = @import("word_break.zig");
const gpa = core.gpa;
const StzStringHandle = core.StzStringHandle;
const str_new = core.str_new;

const stopwords_data = @embedFile("data/stopwords_en.txt");

var g_sw_built = false;
var g_stopwords: std.StringHashMap(void) = undefined;

fn buildSw() void {
    if (g_sw_built) return;
    g_stopwords = std.StringHashMap(void).init(gpa);
    var it = std.mem.splitScalar(u8, stopwords_data, '\n');
    while (it.next()) |raw| {
        const w = std.mem.trimRight(u8, raw, "\r");
        if (w.len > 0) g_stopwords.put(w, {}) catch {};
    }
    g_sw_built = true;
}

fn lowerAscii(w: []const u8, buf: []u8) []const u8 {
    if (w.len > buf.len) return w;
    for (w, 0..) |c, i| buf[i] = if (c >= 'A' and c <= 'Z') c + 32 else c;
    return buf[0..w.len];
}

// Non-stopword ("content") word tokens, NUL-delimited (original case kept).
pub fn str_content_words(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    const s = handle orelse return result;
    buildSw();
    const src = s.slice();
    var buf: [128]u8 = undefined;
    var wit = wb.WordIter.init(src);
    var first = true;
    while (wit.next()) |sp| {
        const w = src[sp.start..sp.end];
        if (g_stopwords.contains(lowerAscii(w, &buf))) continue;
        if (!first) result.data.append(gpa, 0) catch break;
        result.data.appendSlice(gpa, w) catch break;
        first = false;
    }
    return result;
}

// Text with stopword tokens dropped; content words re-joined by single spaces.
pub fn str_without_stopwords(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    const s = handle orelse return result;
    buildSw();
    const src = s.slice();
    var buf: [128]u8 = undefined;
    var wit = wb.WordIter.init(src);
    var first = true;
    while (wit.next()) |sp| {
        const w = src[sp.start..sp.end];
        if (g_stopwords.contains(lowerAscii(w, &buf))) continue;
        if (!first) result.data.append(gpa, ' ') catch break;
        result.data.appendSlice(gpa, w) catch break;
        first = false;
    }
    return result;
}

// 1 if the whole (lowercased) string is a stopword.
pub fn str_is_stopword(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    buildSw();
    var buf: [128]u8 = undefined;
    return if (g_stopwords.contains(lowerAscii(s.slice(), &buf))) 1 else 0;
}

fn isVowel(c: u8) bool {
    const l = if (c >= 'A' and c <= 'Z') c + 32 else c;
    return l == 'a' or l == 'e' or l == 'i' or l == 'o' or l == 'u' or l == 'y';
}

// Heuristic syllable count: vowel groups, minus a silent trailing 'e' (but not
// "-le"), minimum 1. Good enough for readability aggregates.
fn syllables(word: []const u8) usize {
    if (word.len == 0) return 0;
    var n: usize = 0;
    var prev_v = false;
    for (word) |c| {
        const v = isVowel(c);
        if (v and !prev_v) n += 1;
        prev_v = v;
    }
    if (word.len >= 2 and (word[word.len - 1] == 'e' or word[word.len - 1] == 'E') and
        !(word[word.len - 2] == 'l' or word[word.len - 2] == 'L') and n > 1) n -= 1;
    return if (n == 0) 1 else n;
}

// mode 0 = Flesch Reading Ease, 1 = Flesch-Kincaid Grade Level.
pub fn str_readability(handle: StzStringHandle, mode: c_int) callconv(.c) f64 {
    const s = handle orelse return 0;
    const src = s.slice();
    var words: usize = 0;
    var syl: usize = 0;
    {
        var wit = wb.WordIter.init(src);
        while (wit.next()) |sp| {
            words += 1;
            syl += syllables(src[sp.start..sp.end]);
        }
    }
    if (words == 0) return 0;
    var sentences: usize = 0;
    {
        var sit = wb.SentenceIter.init(src);
        while (sit.next()) |sp| {
            if (wb.countWords(src[sp.start..sp.end]) > 0) sentences += 1;
        }
    }
    if (sentences == 0) sentences = 1;
    const wps = @as(f64, @floatFromInt(words)) / @as(f64, @floatFromInt(sentences));
    const spw = @as(f64, @floatFromInt(syl)) / @as(f64, @floatFromInt(words));
    return switch (mode) {
        0 => 206.835 - 1.015 * wps - 84.6 * spw,
        1 => 0.39 * wps + 11.8 * spw - 15.59,
        else => 0,
    };
}

const testing = std.testing;
const str_from = core.str_from;
const str_free = core.str_free;

test "content words drop stopwords" {
    const s = str_from("the quick brown fox and the lazy dog", 36) orelse return error.SkipZigTest;
    defer str_free(s);
    const r = str_content_words(s) orelse return error.SkipZigTest;
    defer str_free(r);
    try testing.expectEqualStrings("quick\x00brown\x00fox\x00lazy\x00dog", r.slice());
}
