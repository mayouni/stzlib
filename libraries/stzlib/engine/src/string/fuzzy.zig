// Softanza Engine -- Approximate / fuzzy string matching (extracted from nlp.zig)
//
// Edit-distance and similarity metrics (Levenshtein, Hamming, Jaro,
// Jaro-Winkler, Jaccard) plus greedy edit-distance CLUSTERING for fuzzy dedup /
// typo grouping. Codepoint-level (Unicode-correct). No tokenization here.

const std = @import("std");
const core = @import("core.zig");
const mem = core.mem;
const gpa = core.gpa;
const StzString = core.StzString;
const StzStringHandle = core.StzStringHandle;
const str_new = core.str_new;
const str_from = core.str_from;
const str_free = core.str_free;
const decodeCodepoint = core.decodeCodepoint;
const casefoldAlloc = core.casefoldAlloc;
const utf8CodepointCount = core.utf8CodepointCount;
const StzFindResult = core.StzFindResult;
const StzFindResultHandle = core.StzFindResultHandle;

// ─── Similarity Metrics ───

pub fn str_levenshtein(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    const s1 = (h1 orelse return 0);
    const s2 = (h2 orelse return 0);
    const b1 = s1.slice();
    const b2 = s2.slice();

    // Decode codepoints from both strings
    var cp1_buf: [4096]i32 = undefined;
    var cp2_buf: [4096]i32 = undefined;
    var len1: usize = 0;
    var len2: usize = 0;

    var i: usize = 0;
    while (i < b1.len and len1 < 4096) {
        const cp_len = std.unicode.utf8ByteSequenceLength(b1[i]) catch 1;
        cp1_buf[len1] = decodeCodepoint(b1, i, cp_len);
        len1 += 1;
        i += cp_len;
    }
    i = 0;
    while (i < b2.len and len2 < 4096) {
        const cp_len = std.unicode.utf8ByteSequenceLength(b2[i]) catch 1;
        cp2_buf[len2] = decodeCodepoint(b2, i, cp_len);
        len2 += 1;
        i += cp_len;
    }

    if (len1 == 0) return @intCast(len2);
    if (len2 == 0) return @intCast(len1);

    // Use two rows for space efficiency
    const row_alloc = gpa.alloc(c_int, len2 + 1) catch return -1;
    defer gpa.free(row_alloc);
    const prev_alloc = gpa.alloc(c_int, len2 + 1) catch return -1;
    defer gpa.free(prev_alloc);
    var prev = prev_alloc;
    var curr = row_alloc;

    for (0..len2 + 1) |j| {
        prev[j] = @intCast(j);
    }

    for (0..len1) |r| {
        curr[0] = @as(c_int, @intCast(r)) + 1;
        for (0..len2) |c| {
            const cost: c_int = if (cp1_buf[r] == cp2_buf[c]) 0 else 1;
            const del = prev[c + 1] + 1;
            const ins = curr[c] + 1;
            const sub = prev[c] + cost;
            curr[c + 1] = @min(del, @min(ins, sub));
        }
        const tmp = prev;
        prev = curr;
        curr = tmp;
    }

    return prev[len2];
}

/// Hamming distance: count of positions where codepoints differ.
/// Returns -1 if strings have different lengths.
pub fn str_hamming_distance(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    const s1 = h1 orelse return -1;
    const s2 = h2 orelse return -1;
    const src1 = s1.slice();
    const src2 = s2.slice();

    var off1: usize = 0;
    var off2: usize = 0;
    var dist: c_int = 0;

    while (off1 < src1.len and off2 < src2.len) {
        const len1 = std.unicode.utf8ByteSequenceLength(src1[off1]) catch break;
        const len2 = std.unicode.utf8ByteSequenceLength(src2[off2]) catch break;
        if (off1 + len1 > src1.len or off2 + len2 > src2.len) break;

        if (len1 != len2 or !mem.eql(u8, src1[off1..][0..len1], src2[off2..][0..len2])) {
            dist += 1;
        }
        off1 += len1;
        off2 += len2;
    }

    // If one string has remaining chars, lengths differ
    if (off1 < src1.len or off2 < src2.len) return -1;
    return dist;
}

/// Jaro similarity. Returns value * 1000 (integer to avoid float in C API).
pub fn str_jaro(h1: ?*StzString, h2: ?*StzString) callconv(.c) c_int {
    const s1 = h1 orelse return 0;
    const s2 = h2 orelse return 0;
    const a = s1.slice();
    const b = s2.slice();
    if (a.len == 0 and b.len == 0) return 1000; // identical empty
    if (a.len == 0 or b.len == 0) return 0;

    // Count codepoints
    const len_a = utf8CodepointCount(a);
    const len_b = utf8CodepointCount(b);
    if (len_a == 0 or len_b == 0) return 0;

    // Match window
    const max_len = if (len_a > len_b) len_a else len_b;
    const match_dist = if (max_len > 1) max_len / 2 - 1 else 0;

    // Collect codepoints from both strings
    var cps_a: [1024]i32 = undefined;
    var cps_b: [1024]i32 = undefined;
    const ca = @min(len_a, 1024);
    const cb = @min(len_b, 1024);

    var idx: usize = 0;
    var pos: usize = 0;
    while (idx < ca and pos < a.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(a[pos]) catch 1;
        cps_a[idx] = decodeCodepoint(a, pos, cp_len);
        pos += cp_len;
        idx += 1;
    }
    idx = 0;
    pos = 0;
    while (idx < cb and pos < b.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(b[pos]) catch 1;
        cps_b[idx] = decodeCodepoint(b, pos, cp_len);
        pos += cp_len;
        idx += 1;
    }

    // Find matches
    var matched_a: [1024]bool = [_]bool{false} ** 1024;
    var matched_b: [1024]bool = [_]bool{false} ** 1024;
    var matches: usize = 0;

    var i: usize = 0;
    while (i < ca) : (i += 1) {
        const lo = if (i > match_dist) i - match_dist else 0;
        const hi = @min(i + match_dist + 1, cb);
        var j: usize = lo;
        while (j < hi) : (j += 1) {
            if (!matched_b[j] and cps_a[i] == cps_b[j]) {
                matched_a[i] = true;
                matched_b[j] = true;
                matches += 1;
                break;
            }
        }
    }

    if (matches == 0) return 0;

    // Count transpositions
    var transpositions: usize = 0;
    var k: usize = 0;
    i = 0;
    while (i < ca) : (i += 1) {
        if (matched_a[i]) {
            while (k < cb and !matched_b[k]) k += 1;
            if (k < cb and cps_a[i] != cps_b[k]) transpositions += 1;
            k += 1;
        }
    }

    // Jaro = (m/|a| + m/|b| + (m-t/2)/m) / 3
    const m_f: f64 = @floatFromInt(matches);
    const la_f: f64 = @floatFromInt(ca);
    const lb_f: f64 = @floatFromInt(cb);
    const t_f: f64 = @floatFromInt(transpositions / 2);
    const jaro_val = (m_f / la_f + m_f / lb_f + (m_f - t_f) / m_f) / 3.0;
    return @intFromFloat(jaro_val * 1000.0);
}

/// Jaro-Winkler similarity. Returns value * 1000. Boosts for common prefix.
pub fn str_jaro_winkler(h1: ?*StzString, h2: ?*StzString) callconv(.c) c_int {
    const jaro = str_jaro(h1, h2);
    if (jaro == 0) return 0;
    const jaro_f: f64 = @as(f64, @floatFromInt(jaro)) / 1000.0;

    // Common prefix (up to 4 chars)
    const s1 = h1 orelse return jaro;
    const s2 = h2 orelse return jaro;
    const a = s1.slice();
    const b = s2.slice();
    var prefix: usize = 0;
    var pa: usize = 0;
    var pb: usize = 0;
    while (prefix < 4 and pa < a.len and pb < b.len) {
        const cpa_len = std.unicode.utf8ByteSequenceLength(a[pa]) catch break;
        const cpb_len = std.unicode.utf8ByteSequenceLength(b[pb]) catch break;
        if (cpa_len != cpb_len) break;
        if (!mem.eql(u8, a[pa..pa + cpa_len], b[pb..pb + cpb_len])) break;
        pa += cpa_len;
        pb += cpb_len;
        prefix += 1;
    }

    const p_f: f64 = @floatFromInt(prefix);
    const jw = jaro_f + p_f * 0.1 * (1.0 - jaro_f);
    return @intFromFloat(jw * 1000.0);
}

/// Jaccard similarity (byte-level character sets). Returns percentage (0-100).
pub fn str_jaccard_similarity(h1: ?*StzString, h2: ?*StzString) callconv(.c) c_int {
    const s1 = h1 orelse return 0;
    const s2 = h2 orelse return 0;
    const src1 = s1.slice();
    const src2 = s2.slice();

    // Build char sets (ASCII only for speed)
    var set1: [256]bool = [_]bool{false} ** 256;
    var set2: [256]bool = [_]bool{false} ** 256;
    for (src1) |c| set1[c] = true;
    for (src2) |c| set2[c] = true;

    var intersection: u32 = 0;
    var union_count: u32 = 0;
    for (0..256) |i| {
        if (set1[i] or set2[i]) union_count += 1;
        if (set1[i] and set2[i]) intersection += 1;
    }
    if (union_count == 0) return 100; // both empty = identical
    return @intCast((intersection * 100) / union_count);
}


// ─── Edit-distance clustering (fuzzy dedup, typo grouping) ───

fn decodeAllCp(bytes: []const u8, buf: *std.ArrayList(i32)) void {
    var i: usize = 0;
    while (i < bytes.len) {
        const cl = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        buf.append(gpa, decodeCodepoint(bytes, i, cl)) catch return;
        i += cl;
    }
}

// Codepoint Levenshtein on two byte slices (two-row DP). Cheap-exits when the
// length gap already exceeds `cap` (used to skip full DP when we only care
// whether distance <= threshold).
fn editDistCpCapped(a: []const u8, b: []const u8, cap: usize) usize {
    var ca: std.ArrayList(i32) = .{};
    defer ca.deinit(gpa);
    var cb: std.ArrayList(i32) = .{};
    defer cb.deinit(gpa);
    decodeAllCp(a, &ca);
    decodeAllCp(b, &cb);
    const n = ca.items.len;
    const m = cb.items.len;
    if (n == 0) return m;
    if (m == 0) return n;
    const gap = if (n > m) n - m else m - n;
    if (gap > cap) return gap; // cannot be <= cap
    var prev = gpa.alloc(usize, m + 1) catch return @max(n, m);
    defer gpa.free(prev);
    var curr = gpa.alloc(usize, m + 1) catch return @max(n, m);
    defer gpa.free(curr);
    var j: usize = 0;
    while (j <= m) : (j += 1) prev[j] = j;
    var i: usize = 1;
    while (i <= n) : (i += 1) {
        curr[0] = i;
        j = 1;
        while (j <= m) : (j += 1) {
            const cost: usize = if (ca.items[i - 1] == cb.items[j - 1]) 0 else 1;
            const del = prev[j] + 1;
            const ins = curr[j - 1] + 1;
            const sub = prev[j - 1] + cost;
            curr[j] = @min(@min(del, ins), sub);
        }
        std.mem.swap([]usize, &prev, &curr);
    }
    return prev[m];
}


pub fn str_edit_cluster(handle: StzStringHandle, threshold: c_int, cs: c_int) callconv(.c) StzFindResultHandle {
    const r = gpa.create(StzFindResult) catch return null;
    r.* = StzFindResult.init();
    const s = (handle orelse return r);
    const src = s.slice();
    var items: std.ArrayList([]const u8) = .{};
    defer items.deinit(gpa);
    core.splitNul(src, &items);

    const thr: usize = if (threshold < 0) 0 else @intCast(threshold);
    var reps: std.ArrayList([]const u8) = .{};
    defer reps.deinit(gpa);
    var folded: std.ArrayList([]u8) = .{}; // casefolded copies to free (cs=0)
    defer {
        for (folded.items) |f| gpa.free(f);
        folded.deinit(gpa);
    }
    for (items.items) |item| {
        const cmp: []const u8 = if (cs == 0) blk: {
            if (casefoldAlloc(item)) |f| {
                folded.append(gpa, f) catch {};
                break :blk f;
            } else break :blk item;
        } else item;
        var assigned: i64 = -1;
        for (reps.items, 0..) |rep, k| {
            if (editDistCpCapped(cmp, rep, thr) <= thr) {
                assigned = @intCast(k + 1);
                break;
            }
        }
        if (assigned < 0) {
            reps.append(gpa, cmp) catch {};
            assigned = @intCast(reps.items.len);
        }
        r.positions.append(gpa, assigned) catch break;
    }
    return r;
}


// ─── Tests ───

const testing = std.testing;

test "levenshtein distance" {
    const s1 = str_from("kitten", 6) orelse return error.SkipZigTest;
    defer str_free(s1);
    const s2 = str_from("sitting", 7) orelse return error.SkipZigTest;
    defer str_free(s2);
    try testing.expectEqual(@as(c_int, 3), str_levenshtein(s1, s2));
}

test "levenshtein identical" {
    const s1 = str_from("hello", 5) orelse return error.SkipZigTest;
    defer str_free(s1);
    const s2 = str_from("hello", 5) orelse return error.SkipZigTest;
    defer str_free(s2);
    try testing.expectEqual(@as(c_int, 0), str_levenshtein(s1, s2));
}

test "hamming distance same length" {
    const s1 = str_from("karolin", 7) orelse return error.SkipZigTest;
    defer str_free(s1);
    const s2 = str_from("kathrin", 7) orelse return error.SkipZigTest;
    defer str_free(s2);
    try testing.expectEqual(@as(c_int, 3), str_hamming_distance(s1, s2));
}

test "hamming distance different length returns -1" {
    const s1 = str_from("abc", 3) orelse return error.SkipZigTest;
    defer str_free(s1);
    const s2 = str_from("abcd", 4) orelse return error.SkipZigTest;
    defer str_free(s2);
    try testing.expectEqual(@as(c_int, -1), str_hamming_distance(s1, s2));
}

test "jaro identical" {
    const s1 = str_from("hello", 5) orelse return error.SkipZigTest;
    defer str_free(s1);
    const s2 = str_from("hello", 5) orelse return error.SkipZigTest;
    defer str_free(s2);
    try testing.expectEqual(@as(c_int, 1000), str_jaro(s1, s2));
}

test "jaro_winkler >= jaro" {
    const s1 = str_from("martha", 6) orelse return error.SkipZigTest;
    defer str_free(s1);
    const s2 = str_from("marhta", 6) orelse return error.SkipZigTest;
    defer str_free(s2);
    const j = str_jaro(s1, s2);
    const jw = str_jaro_winkler(s1, s2);
    try testing.expect(jw >= j);
}

test "jaccard similarity identical" {
    const s1 = str_from("abc", 3) orelse return error.SkipZigTest;
    defer str_free(s1);
    const s2 = str_from("abc", 3) orelse return error.SkipZigTest;
    defer str_free(s2);
    try testing.expectEqual(@as(c_int, 100), str_jaccard_similarity(s1, s2));
}

