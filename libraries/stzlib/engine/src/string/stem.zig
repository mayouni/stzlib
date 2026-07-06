// Softanza Engine -- Stemming (Snowball / libstemmer, English)
//
// Reduces inflected words to their stem ("running"/"runs"/"ran"->"run",
// "connection"/"connected"->"connect") so search, dedup and matching group word
// variants. Backed by the VENDORED Snowball English UTF-8 stemmer
// (vendor/snowball, BSD, the reference Porter2 algorithm) -- not hand-rolled.
// English only for now; other languages are a drop-in extension (vendor the
// corresponding stem_UTF_8_<lang>.c and add a create/stem/close set).
//
// Words are tokenized through the UAX#29 seam (word_break.WordIter) and each is
// stemmed; str_stem_text rebuilds the text stemming words in place and copying
// the inter-word separators verbatim.

const std = @import("std");
const core = @import("core.zig");
const wb = @import("word_break.zig");
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
extern fn english_UTF_8_create_env() callconv(.c) ?*SN_env;
extern fn english_UTF_8_close_env(z: ?*SN_env) callconv(.c) void;
extern fn english_UTF_8_stem(z: ?*SN_env) callconv(.c) c_int;
extern fn SN_set_current(z: ?*SN_env, size: c_int, s: [*c]const u8) callconv(.c) c_int;

// One reusable stemmer env (single-threaded engine). Created lazily.
var g_env: ?*SN_env = null;

fn envGet() ?*SN_env {
    if (g_env == null) g_env = english_UTF_8_create_env();
    return g_env;
}

// Stem `word` and append the result to `out`. On any failure the original word
// is appended unchanged. The Snowball English algorithm expects lowercase input,
// so ASCII letters are lowercased into a scratch buffer first (stems are
// lowercase by definition). Non-ASCII / very long words pass through as-is.
fn stemInto(word: []const u8, out: *std.ArrayList(u8)) void {
    if (word.len == 0) return;
    const z = envGet() orelse {
        out.appendSlice(gpa, word) catch {};
        return;
    };
    var buf: [128]u8 = undefined;
    const w: []const u8 = if (word.len <= buf.len) blk: {
        for (word, 0..) |ch, i| buf[i] = if (ch >= 'A' and ch <= 'Z') ch + 32 else ch;
        break :blk buf[0..word.len];
    } else word;

    if (SN_set_current(z, @intCast(w.len), w.ptr) < 0) {
        out.appendSlice(gpa, word) catch {};
        return;
    }
    if (english_UTF_8_stem(z) < 0) {
        out.appendSlice(gpa, word) catch {};
        return;
    }
    const n: usize = @intCast(z.l);
    out.appendSlice(gpa, z.p[0..n]) catch {};
}

// Stem a single word (raw bytes) -> a fresh string.
pub fn str_stem_word(word: [*c]const u8, len: usize) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    if (word == null or len == 0) return result;
    stemInto(word[0..len], &result.data);
    return result;
}

// Stem every word token; return them NUL-delimited (drains like Words()).
pub fn str_stem_words(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    const s = handle orelse return result;
    const src = s.slice();
    var wit = wb.WordIter.init(src);
    var first = true;
    while (wit.next()) |span| {
        if (!first) result.data.append(gpa, 0) catch break;
        stemInto(src[span.start..span.end], &result.data);
        first = false;
    }
    return result;
}

// Stem words IN PLACE: rebuild the text, replacing each word token with its stem
// and copying the bytes between words (whitespace/punctuation) verbatim.
pub fn str_stem_text(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    const s = handle orelse return result;
    const src = s.slice();
    var wit = wb.WordIter.init(src);
    var last: usize = 0;
    while (wit.next()) |span| {
        result.data.appendSlice(gpa, src[last..span.start]) catch break; // separator verbatim
        stemInto(src[span.start..span.end], &result.data);
        last = span.end;
    }
    result.data.appendSlice(gpa, src[last..]) catch {};
    return result;
}

const testing = std.testing;
const str_from = core.str_from;
const str_free = core.str_free;

test "stem english words" {
    const s = str_from("running", 7) orelse return error.SkipZigTest;
    defer str_free(s);
    const r = str_stem_text(s) orelse return error.SkipZigTest;
    defer str_free(r);
    try testing.expectEqualStrings("run", r.slice());
}

test "stem in place preserves separators" {
    const s = str_from("the runners are running", 23) orelse return error.SkipZigTest;
    defer str_free(s);
    const r = str_stem_text(s) orelse return error.SkipZigTest;
    defer str_free(r);
    try testing.expectEqualStrings("the runner are run", r.slice());
}
