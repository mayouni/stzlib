const std = @import("std");

// ─── Context Engine ───
// 32 named context scopes, each holding key-value pairs (64 max per scope).
// Scopes can nest: child inherits parent's keys.

const MAX_SCOPES: usize = 32;
const MAX_PAIRS: usize = 64;
const MAX_STR: usize = 128;

const Pair = struct {
    key: [MAX_STR]u8 = undefined,
    key_len: usize = 0,
    val: [MAX_STR]u8 = undefined,
    val_len: usize = 0,
    active: bool = false,
};

const Scope = struct {
    name: [MAX_STR]u8 = undefined,
    name_len: usize = 0,
    parent: i32 = -1,
    pairs: [MAX_PAIRS]Pair = [_]Pair{.{}} ** MAX_PAIRS,
    pair_count: usize = 0,
    active: bool = false,
};

var scopes: [MAX_SCOPES]Scope = [_]Scope{.{}} ** MAX_SCOPES;
var scope_count: usize = 0;

fn findScopeByName(name: [*]const u8, len: usize) ?usize {
    for (0..MAX_SCOPES) |idx| {
        if (scopes[idx].active and scopes[idx].name_len == len) {
            if (std.mem.eql(u8, scopes[idx].name[0..len], name[0..len])) return idx;
        }
    }
    return null;
}

fn findPairInScope(si: usize, key: [*]const u8, klen: usize) ?usize {
    for (0..MAX_PAIRS) |pi| {
        if (scopes[si].pairs[pi].active and scopes[si].pairs[pi].key_len == klen) {
            if (std.mem.eql(u8, scopes[si].pairs[pi].key[0..klen], key[0..klen])) return pi;
        }
    }
    return null;
}

// ─── C ABI ───

pub export fn stz_ctx_create(name: [*]const u8, name_len: usize, parent_idx: i32) i32 {
    for (0..MAX_SCOPES) |idx| {
        if (!scopes[idx].active) {
            const cl = @min(name_len, MAX_STR);
            @memcpy(scopes[idx].name[0..cl], name[0..cl]);
            scopes[idx].name_len = cl;
            scopes[idx].parent = parent_idx;
            scopes[idx].pair_count = 0;
            for (0..MAX_PAIRS) |pi| {
                scopes[idx].pairs[pi].active = false;
            }
            scopes[idx].active = true;
            scope_count += 1;
            return @intCast(idx);
        }
    }
    return -1;
}

pub export fn stz_ctx_set(scope_idx: i32, key: [*]const u8, key_len: usize, val: [*]const u8, val_len: usize) i32 {
    if (scope_idx < 0 or scope_idx >= @as(i32, MAX_SCOPES)) return 0;
    const si: usize = @intCast(scope_idx);
    if (!scopes[si].active) return 0;

    if (findPairInScope(si, key, key_len)) |pi| {
        const vl = @min(val_len, MAX_STR);
        @memcpy(scopes[si].pairs[pi].val[0..vl], val[0..vl]);
        scopes[si].pairs[pi].val_len = vl;
        return 1;
    }

    for (0..MAX_PAIRS) |pi| {
        if (!scopes[si].pairs[pi].active) {
            const kl = @min(key_len, MAX_STR);
            @memcpy(scopes[si].pairs[pi].key[0..kl], key[0..kl]);
            scopes[si].pairs[pi].key_len = kl;
            const vl = @min(val_len, MAX_STR);
            @memcpy(scopes[si].pairs[pi].val[0..vl], val[0..vl]);
            scopes[si].pairs[pi].val_len = vl;
            scopes[si].pairs[pi].active = true;
            scopes[si].pair_count += 1;
            return 1;
        }
    }
    return 0;
}

pub export fn stz_ctx_get(scope_idx: i32, key: [*]const u8, key_len: usize, out: [*]u8) i32 {
    if (scope_idx < 0 or scope_idx >= @as(i32, MAX_SCOPES)) return 0;
    var si: usize = @intCast(scope_idx);
    while (true) {
        if (!scopes[si].active) return 0;
        if (findPairInScope(si, key, key_len)) |pi| {
            const len = scopes[si].pairs[pi].val_len;
            @memcpy(out[0..len], scopes[si].pairs[pi].val[0..len]);
            return @intCast(len);
        }
        if (scopes[si].parent < 0) return 0;
        si = @intCast(scopes[si].parent);
    }
}

pub export fn stz_ctx_has(scope_idx: i32, key: [*]const u8, key_len: usize) i32 {
    if (scope_idx < 0 or scope_idx >= @as(i32, MAX_SCOPES)) return 0;
    var si: usize = @intCast(scope_idx);
    while (true) {
        if (!scopes[si].active) return 0;
        if (findPairInScope(si, key, key_len) != null) return 1;
        if (scopes[si].parent < 0) return 0;
        si = @intCast(scopes[si].parent);
    }
}

pub export fn stz_ctx_pair_count(scope_idx: i32) i32 {
    if (scope_idx < 0 or scope_idx >= @as(i32, MAX_SCOPES)) return 0;
    const si: usize = @intCast(scope_idx);
    if (!scopes[si].active) return 0;
    return @intCast(scopes[si].pair_count);
}

pub export fn stz_ctx_scope_count() i32 {
    return @intCast(scope_count);
}

pub export fn stz_ctx_destroy(scope_idx: i32) void {
    if (scope_idx < 0 or scope_idx >= @as(i32, MAX_SCOPES)) return;
    const si: usize = @intCast(scope_idx);
    if (scopes[si].active) {
        scopes[si].active = false;
        scope_count -= 1;
    }
}

pub export fn stz_ctx_clear() void {
    for (0..MAX_SCOPES) |idx| {
        scopes[idx].active = false;
    }
    scope_count = 0;
}

// ─── Tests ───

test "create scope and set/get" {
    stz_ctx_clear();
    const s = stz_ctx_create("main", 4, -1);
    try std.testing.expect(s >= 0);
    _ = stz_ctx_set(s, "user", 4, "alice", 5);
    var buf: [128]u8 = undefined;
    const len = stz_ctx_get(s, "user", 4, &buf);
    try std.testing.expectEqualSlices(u8, "alice", buf[0..@intCast(len)]);
    stz_ctx_clear();
}

test "parent scope inheritance" {
    stz_ctx_clear();
    const parent = stz_ctx_create("root", 4, -1);
    _ = stz_ctx_set(parent, "env", 3, "prod", 4);
    const child = stz_ctx_create("child", 5, parent);
    var buf: [128]u8 = undefined;
    const len = stz_ctx_get(child, "env", 3, &buf);
    try std.testing.expectEqualSlices(u8, "prod", buf[0..@intCast(len)]);
    try std.testing.expectEqual(@as(i32, 1), stz_ctx_has(child, "env", 3));
    stz_ctx_clear();
}

test "child overrides parent" {
    stz_ctx_clear();
    const parent = stz_ctx_create("p", 1, -1);
    _ = stz_ctx_set(parent, "k", 1, "parent_val", 10);
    const child = stz_ctx_create("c", 1, parent);
    _ = stz_ctx_set(child, "k", 1, "child_val", 9);
    var buf: [128]u8 = undefined;
    const len = stz_ctx_get(child, "k", 1, &buf);
    try std.testing.expectEqualSlices(u8, "child_val", buf[0..@intCast(len)]);
    stz_ctx_clear();
}

test "scope count" {
    stz_ctx_clear();
    _ = stz_ctx_create("a", 1, -1);
    _ = stz_ctx_create("b", 1, -1);
    try std.testing.expectEqual(@as(i32, 2), stz_ctx_scope_count());
    stz_ctx_clear();
    try std.testing.expectEqual(@as(i32, 0), stz_ctx_scope_count());
}

test "pair count" {
    stz_ctx_clear();
    const s = stz_ctx_create("pairs", 5, -1);
    try std.testing.expectEqual(@as(i32, 0), stz_ctx_pair_count(s));
    _ = stz_ctx_set(s, "k1", 2, "v1", 2);
    _ = stz_ctx_set(s, "k2", 2, "v2", 2);
    _ = stz_ctx_set(s, "k3", 2, "v3", 2);
    try std.testing.expectEqual(@as(i32, 3), stz_ctx_pair_count(s));
    stz_ctx_clear();
}

test "destroy scope" {
    stz_ctx_clear();
    const s1 = stz_ctx_create("d1", 2, -1);
    _ = stz_ctx_create("d2", 2, -1);
    try std.testing.expectEqual(@as(i32, 2), stz_ctx_scope_count());
    stz_ctx_destroy(s1);
    try std.testing.expectEqual(@as(i32, 1), stz_ctx_scope_count());
    stz_ctx_clear();
}

test "has returns false for missing key" {
    stz_ctx_clear();
    const s = stz_ctx_create("chk", 3, -1);
    try std.testing.expectEqual(@as(i32, 0), stz_ctx_has(s, "missing", 7));
    _ = stz_ctx_set(s, "exists", 6, "val", 3);
    try std.testing.expectEqual(@as(i32, 1), stz_ctx_has(s, "exists", 6));
    stz_ctx_clear();
}
