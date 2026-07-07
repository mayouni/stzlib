// Softanza Engine -- WordNet synonyms & hypernyms
//
// Lexical-semantic relations from Princeton WordNet 3.1 (WordNet License -- see
// NOTICE), COMPILED IN via @embedFile like the other classical models. To keep
// the binary lean the glosses/examples are dropped: only the two highest-value
// relations are kept, merged across parts of speech --
//   * synonyms: the union of every synset-mate of the word
//   * hypernyms: the "is-a" parents (words of the @-pointed synsets)
// Compact form: one line "word\tsyn,syn,...\thyp,hyp,..." (140k words, ~9MB vs
// the ~30MB full DB). Multiword lemmas use spaces. Lookup key is ASCII-lowercased.

const std = @import("std");
const core = @import("core.zig");
const gpa = core.gpa;
const StzStringHandle = core.StzStringHandle;
const str_new = core.str_new;

const wn_data = @embedFile("data/wordnet.txt");

var g_built = false;
var g_syn: std.StringHashMap([]const u8) = undefined; // word -> "syn,syn,..."
var g_hyp: std.StringHashMap([]const u8) = undefined; // word -> "hyp,hyp,..."

fn build() void {
    if (g_built) return;
    g_syn = std.StringHashMap([]const u8).init(gpa);
    g_hyp = std.StringHashMap([]const u8).init(gpa);
    var it = std.mem.splitScalar(u8, wn_data, '\n');
    while (it.next()) |raw| {
        const line = std.mem.trimRight(u8, raw, "\r");
        if (line.len == 0) continue;
        var f = std.mem.splitScalar(u8, line, '\t');
        const word = f.next() orelse continue;
        const syns = f.next() orelse "";
        const hyps = f.next() orelse "";
        if (word.len == 0) continue;
        if (syns.len > 0) g_syn.put(word, syns) catch {};
        if (hyps.len > 0) g_hyp.put(word, hyps) catch {};
    }
    g_built = true;
}

fn lowerAscii(w: []const u8, buf: []u8) []const u8 {
    if (w.len > buf.len) return w;
    for (w, 0..) |c, i| buf[i] = if (c >= 'A' and c <= 'Z') c + 32 else c;
    return buf[0..w.len];
}

// Append a comma-separated value list to `result` as NUL-delimited items.
fn emitCsv(result: *core.StzString, csv: []const u8) void {
    var first = true;
    var it = std.mem.splitScalar(u8, csv, ',');
    while (it.next()) |item| {
        if (item.len == 0) continue;
        if (!first) result.data.append(gpa, 0) catch return;
        result.data.appendSlice(gpa, item) catch return;
        first = false;
    }
}

fn lookup(handle: StzStringHandle, map: *std.StringHashMap([]const u8)) StzStringHandle {
    const result = str_new() orelse return null;
    const s = handle orelse return result;
    build();
    var buf: [256]u8 = undefined;
    const key = lowerAscii(s.slice(), &buf);
    if (map.get(key)) |csv| emitCsv(result, csv);
    return result;
}

pub fn str_synonyms(handle: StzStringHandle) callconv(.c) StzStringHandle {
    return lookup(handle, &g_syn);
}

pub fn str_hypernyms(handle: StzStringHandle) callconv(.c) StzStringHandle {
    return lookup(handle, &g_hyp);
}

// 1 if `other` is a WordNet synonym of the handle word (case-insensitive).
pub fn str_are_synonyms(handle: StzStringHandle, other: [*c]const u8, other_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    if (other == null or other_len == 0) return 0;
    build();
    var kb: [256]u8 = undefined;
    var ob: [256]u8 = undefined;
    const key = lowerAscii(s.slice(), &kb);
    const ol = lowerAscii(other[0..other_len], &ob);
    const csv = g_syn.get(key) orelse return 0;
    var it = std.mem.splitScalar(u8, csv, ',');
    while (it.next()) |item| {
        if (std.mem.eql(u8, item, ol)) return 1;
    }
    return 0;
}

const testing = std.testing;
const str_from = core.str_from;
const str_free = core.str_free;

test "wordnet synonyms + hypernyms" {
    const s = str_from("car", 3) orelse return error.SkipZigTest;
    defer str_free(s);
    const syn = str_synonyms(s) orelse return error.SkipZigTest;
    defer str_free(syn);
    try testing.expect(std.mem.indexOf(u8, syn.slice(), "automobile") != null);
    const hyp = str_hypernyms(s) orelse return error.SkipZigTest;
    defer str_free(hyp);
    try testing.expect(std.mem.indexOf(u8, hyp.slice(), "vehicle") != null);
    try testing.expectEqual(@as(c_int, 1), str_are_synonyms(s, "auto", 4));
    try testing.expectEqual(@as(c_int, 0), str_are_synonyms(s, "banana", 6));
}
