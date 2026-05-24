const std = @import("std");

// ── Knowledge Graph Engine ─────────────────────────────────────
// Triple store (subject-predicate-object) with query by any
// position. Foundation for semantic reasoning.

const MAX_TRIPLES = 512;
const MAX_STR = 128;

const Triple = struct {
    subject: [MAX_STR]u8 = [_]u8{0} ** MAX_STR,
    subject_len: u16 = 0,
    predicate: [MAX_STR]u8 = [_]u8{0} ** MAX_STR,
    predicate_len: u16 = 0,
    object: [MAX_STR]u8 = [_]u8{0} ** MAX_STR,
    object_len: u16 = 0,
    active: bool = false,
};

var triples: [MAX_TRIPLES]Triple = [_]Triple{.{}} ** MAX_TRIPLES;
var triple_count: u32 = 0;

fn str_eq(a: []const u8, b: [*]const u8, b_len: usize) bool {
    if (a.len != b_len) return false;
    return std.mem.eql(u8, a, b[0..b_len]);
}

pub fn kg_add(s: [*]const u8, sl: i32, p: [*]const u8, pl: i32, o: [*]const u8, ol: i32) callconv(.c) i32 {
    if (sl <= 0 or pl <= 0 or ol <= 0) return -1;
    if (sl > MAX_STR or pl > MAX_STR or ol > MAX_STR) return -2;
    const slen: usize = @intCast(sl);
    const plen: usize = @intCast(pl);
    const olen: usize = @intCast(ol);

    for (0..MAX_TRIPLES) |i| {
        if (triples[i].active and
            str_eq(triples[i].subject[0..triples[i].subject_len], s, slen) and
            str_eq(triples[i].predicate[0..triples[i].predicate_len], p, plen) and
            str_eq(triples[i].object[0..triples[i].object_len], o, olen))
            return -3;
    }

    for (0..MAX_TRIPLES) |i| {
        if (!triples[i].active) {
            @memcpy(triples[i].subject[0..slen], s[0..slen]);
            triples[i].subject_len = @intCast(slen);
            @memcpy(triples[i].predicate[0..plen], p[0..plen]);
            triples[i].predicate_len = @intCast(plen);
            @memcpy(triples[i].object[0..olen], o[0..olen]);
            triples[i].object_len = @intCast(olen);
            triples[i].active = true;
            triple_count += 1;
            return @intCast(i);
        }
    }
    return -4;
}

pub fn kg_count() callconv(.c) i32 {
    return @intCast(triple_count);
}

pub fn kg_remove(idx: i32) callconv(.c) i32 {
    if (idx < 0 or idx >= MAX_TRIPLES) return -1;
    const i: usize = @intCast(idx);
    if (!triples[i].active) return -2;
    triples[i].active = false;
    if (triple_count > 0) triple_count -= 1;
    return 0;
}

pub fn kg_query_subject(subj: [*]const u8, subj_len: i32, result_indices: [*]i32) callconv(.c) i32 {
    if (subj_len <= 0) return 0;
    const slen: usize = @intCast(subj_len);
    var count: i32 = 0;
    for (0..MAX_TRIPLES) |i| {
        if (triples[i].active and str_eq(triples[i].subject[0..triples[i].subject_len], subj, slen)) {
            result_indices[@intCast(count)] = @intCast(i);
            count += 1;
            if (count >= 256) break;
        }
    }
    return count;
}

pub fn kg_query_predicate(pred: [*]const u8, pred_len: i32, result_indices: [*]i32) callconv(.c) i32 {
    if (pred_len <= 0) return 0;
    const plen: usize = @intCast(pred_len);
    var count: i32 = 0;
    for (0..MAX_TRIPLES) |i| {
        if (triples[i].active and str_eq(triples[i].predicate[0..triples[i].predicate_len], pred, plen)) {
            result_indices[@intCast(count)] = @intCast(i);
            count += 1;
            if (count >= 256) break;
        }
    }
    return count;
}

pub fn kg_query_object(obj: [*]const u8, obj_len: i32, result_indices: [*]i32) callconv(.c) i32 {
    if (obj_len <= 0) return 0;
    const olen: usize = @intCast(obj_len);
    var count: i32 = 0;
    for (0..MAX_TRIPLES) |i| {
        if (triples[i].active and str_eq(triples[i].object[0..triples[i].object_len], obj, olen)) {
            result_indices[@intCast(count)] = @intCast(i);
            count += 1;
            if (count >= 256) break;
        }
    }
    return count;
}

pub fn kg_get_subject(idx: i32, out: [*]u8) callconv(.c) i32 {
    if (idx < 0 or idx >= MAX_TRIPLES) return -1;
    const i: usize = @intCast(idx);
    if (!triples[i].active) return -2;
    const len = triples[i].subject_len;
    @memcpy(out[0..len], triples[i].subject[0..len]);
    return @intCast(len);
}

pub fn kg_get_predicate(idx: i32, out: [*]u8) callconv(.c) i32 {
    if (idx < 0 or idx >= MAX_TRIPLES) return -1;
    const i: usize = @intCast(idx);
    if (!triples[i].active) return -2;
    const len = triples[i].predicate_len;
    @memcpy(out[0..len], triples[i].predicate[0..len]);
    return @intCast(len);
}

pub fn kg_get_object(idx: i32, out: [*]u8) callconv(.c) i32 {
    if (idx < 0 or idx >= MAX_TRIPLES) return -1;
    const i: usize = @intCast(idx);
    if (!triples[i].active) return -2;
    const len = triples[i].object_len;
    @memcpy(out[0..len], triples[i].object[0..len]);
    return @intCast(len);
}

pub fn kg_clear() callconv(.c) void {
    for (0..MAX_TRIPLES) |i| {
        triples[i] = .{};
    }
    triple_count = 0;
}

pub fn kg_has_triple(s: [*]const u8, sl: i32, p: [*]const u8, pl: i32, o: [*]const u8, ol: i32) callconv(.c) i32 {
    if (sl <= 0 or pl <= 0 or ol <= 0) return 0;
    const slen: usize = @intCast(sl);
    const plen: usize = @intCast(pl);
    const olen: usize = @intCast(ol);
    for (0..MAX_TRIPLES) |i| {
        if (triples[i].active and
            str_eq(triples[i].subject[0..triples[i].subject_len], s, slen) and
            str_eq(triples[i].predicate[0..triples[i].predicate_len], p, plen) and
            str_eq(triples[i].object[0..triples[i].object_len], o, olen))
            return 1;
    }
    return 0;
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_kg_add(s: [*]const u8, sl: i32, p: [*]const u8, pl: i32, o: [*]const u8, ol: i32) callconv(.c) i32 { return kg_add(s, sl, p, pl, o, ol); }
pub export fn stz_kg_count() callconv(.c) i32 { return kg_count(); }
pub export fn stz_kg_remove(i: i32) callconv(.c) i32 { return kg_remove(i); }
pub export fn stz_kg_query_subject(s: [*]const u8, sl: i32, r: [*]i32) callconv(.c) i32 { return kg_query_subject(s, sl, r); }
pub export fn stz_kg_query_predicate(p: [*]const u8, pl: i32, r: [*]i32) callconv(.c) i32 { return kg_query_predicate(p, pl, r); }
pub export fn stz_kg_query_object(o: [*]const u8, ol: i32, r: [*]i32) callconv(.c) i32 { return kg_query_object(o, ol, r); }
pub export fn stz_kg_get_subject(i: i32, o: [*]u8) callconv(.c) i32 { return kg_get_subject(i, o); }
pub export fn stz_kg_get_predicate(i: i32, o: [*]u8) callconv(.c) i32 { return kg_get_predicate(i, o); }
pub export fn stz_kg_get_object(i: i32, o: [*]u8) callconv(.c) i32 { return kg_get_object(i, o); }
pub export fn stz_kg_clear() callconv(.c) void { kg_clear(); }
pub export fn stz_kg_has_triple(s: [*]const u8, sl: i32, p: [*]const u8, pl: i32, o: [*]const u8, ol: i32) callconv(.c) i32 { return kg_has_triple(s, sl, p, pl, o, ol); }

// ── Tests ────────────────────────────────────────────────────

test "knowgraph: add and count" {
    kg_clear();
    const idx = kg_add("Alice", 5, "knows", 5, "Bob", 3);
    try std.testing.expect(idx >= 0);
    try std.testing.expectEqual(@as(i32, 1), kg_count());
}

test "knowgraph: duplicate rejected" {
    kg_clear();
    _ = kg_add("Alice", 5, "knows", 5, "Bob", 3);
    try std.testing.expectEqual(@as(i32, -3), kg_add("Alice", 5, "knows", 5, "Bob", 3));
}

test "knowgraph: query by subject" {
    kg_clear();
    _ = kg_add("Alice", 5, "knows", 5, "Bob", 3);
    _ = kg_add("Alice", 5, "likes", 5, "Carol", 5);
    _ = kg_add("Bob", 3, "knows", 5, "Carol", 5);
    var results: [256]i32 = undefined;
    const count = kg_query_subject("Alice", 5, &results);
    try std.testing.expectEqual(@as(i32, 2), count);
}

test "knowgraph: query by predicate" {
    kg_clear();
    _ = kg_add("Alice", 5, "knows", 5, "Bob", 3);
    _ = kg_add("Bob", 3, "knows", 5, "Carol", 5);
    var results: [256]i32 = undefined;
    const count = kg_query_predicate("knows", 5, &results);
    try std.testing.expectEqual(@as(i32, 2), count);
}

test "knowgraph: get parts" {
    kg_clear();
    const idx = kg_add("Alice", 5, "knows", 5, "Bob", 3);
    var buf: [128]u8 = undefined;
    const sl = kg_get_subject(idx, &buf);
    try std.testing.expectEqualStrings("Alice", buf[0..@intCast(sl)]);
    const pl = kg_get_predicate(idx, &buf);
    try std.testing.expectEqualStrings("knows", buf[0..@intCast(pl)]);
    const ol = kg_get_object(idx, &buf);
    try std.testing.expectEqualStrings("Bob", buf[0..@intCast(ol)]);
}

test "knowgraph: has_triple" {
    kg_clear();
    _ = kg_add("Alice", 5, "knows", 5, "Bob", 3);
    try std.testing.expectEqual(@as(i32, 1), kg_has_triple("Alice", 5, "knows", 5, "Bob", 3));
    try std.testing.expectEqual(@as(i32, 0), kg_has_triple("Alice", 5, "knows", 5, "Carol", 5));
}

test "knowgraph: remove" {
    kg_clear();
    const idx = kg_add("Alice", 5, "knows", 5, "Bob", 3);
    try std.testing.expectEqual(@as(i32, 0), kg_remove(idx));
    try std.testing.expectEqual(@as(i32, 0), kg_count());
    try std.testing.expectEqual(@as(i32, 0), kg_has_triple("Alice", 5, "knows", 5, "Bob", 3));
}
