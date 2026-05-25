const std = @import("std");

// ─── Embedding Store Engine ───
// 64 named embedding vectors (up to 512 dimensions each).

const MAX_EMBEDDINGS: usize = 64;
const MAX_DIM: usize = 512;
const MAX_NAME: usize = 64;

const Embedding = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    data: [MAX_DIM]f64 = [_]f64{0.0} ** MAX_DIM,
    dim: usize = 0,
    active: bool = false,
};

var embeddings: [MAX_EMBEDDINGS]Embedding = [_]Embedding{.{}} ** MAX_EMBEDDINGS;
var emb_count: usize = 0;

fn findByName(name: [*]const u8, len: usize) ?usize {
    for (0..MAX_EMBEDDINGS) |idx| {
        if (embeddings[idx].active and embeddings[idx].name_len == len) {
            if (std.mem.eql(u8, embeddings[idx].name[0..len], name[0..len])) return idx;
        }
    }
    return null;
}

// ─── C ABI ───

pub export fn stz_emb_store(name: [*]const u8, name_len: usize, vec: [*]const f64, dim: i32) i32 {
    if (dim <= 0 or dim > @as(i32, MAX_DIM)) return -1;
    const d: usize = @intCast(dim);

    if (findByName(name, name_len)) |idx| {
        @memcpy(embeddings[idx].data[0..d], vec[0..d]);
        embeddings[idx].dim = d;
        return @intCast(idx);
    }

    for (0..MAX_EMBEDDINGS) |idx| {
        if (!embeddings[idx].active) {
            const nl = @min(name_len, MAX_NAME);
            @memcpy(embeddings[idx].name[0..nl], name[0..nl]);
            embeddings[idx].name_len = nl;
            @memcpy(embeddings[idx].data[0..d], vec[0..d]);
            embeddings[idx].dim = d;
            embeddings[idx].active = true;
            emb_count += 1;
            return @intCast(idx);
        }
    }
    return -1;
}

pub export fn stz_emb_get(name: [*]const u8, name_len: usize, out: [*]f64) i32 {
    const idx = findByName(name, name_len) orelse return 0;
    const d = embeddings[idx].dim;
    @memcpy(out[0..d], embeddings[idx].data[0..d]);
    return @intCast(d);
}

pub export fn stz_emb_dim(name: [*]const u8, name_len: usize) i32 {
    const idx = findByName(name, name_len) orelse return 0;
    return @intCast(embeddings[idx].dim);
}

pub export fn stz_emb_cosine(name_a: [*]const u8, a_len: usize, name_b: [*]const u8, b_len: usize) f64 {
    const ia = findByName(name_a, a_len) orelse return 0.0;
    const ib = findByName(name_b, b_len) orelse return 0.0;
    if (embeddings[ia].dim != embeddings[ib].dim) return 0.0;
    const d = embeddings[ia].dim;
    var dot: f64 = 0.0;
    var mag_a: f64 = 0.0;
    var mag_b: f64 = 0.0;
    for (0..d) |k| {
        dot += embeddings[ia].data[k] * embeddings[ib].data[k];
        mag_a += embeddings[ia].data[k] * embeddings[ia].data[k];
        mag_b += embeddings[ib].data[k] * embeddings[ib].data[k];
    }
    const denom = @sqrt(mag_a) * @sqrt(mag_b);
    if (denom == 0.0) return 0.0;
    return dot / denom;
}

pub export fn stz_emb_count() i32 {
    return @intCast(emb_count);
}

pub export fn stz_emb_has(name: [*]const u8, name_len: usize) i32 {
    return if (findByName(name, name_len) != null) @as(i32, 1) else @as(i32, 0);
}

pub export fn stz_emb_remove(name: [*]const u8, name_len: usize) i32 {
    const idx = findByName(name, name_len) orelse return 0;
    embeddings[idx].active = false;
    emb_count -= 1;
    return 1;
}

pub export fn stz_emb_clear() void {
    for (0..MAX_EMBEDDINGS) |idx| embeddings[idx].active = false;
    emb_count = 0;
}

// ─── Tests ───

test "store and retrieve embedding" {
    stz_emb_clear();
    const v = [_]f64{ 1.0, 2.0, 3.0 };
    const idx = stz_emb_store("word1", 5, &v, 3);
    try std.testing.expect(idx >= 0);
    try std.testing.expectEqual(@as(i32, 3), stz_emb_dim("word1", 5));
    var out: [512]f64 = undefined;
    const d = stz_emb_get("word1", 5, &out);
    try std.testing.expectEqual(@as(i32, 3), d);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0), out[1], 0.001);
    stz_emb_clear();
}

test "cosine similarity between embeddings" {
    stz_emb_clear();
    const a = [_]f64{ 1.0, 0.0, 0.0 };
    const b = [_]f64{ 1.0, 0.0, 0.0 };
    _ = stz_emb_store("x", 1, &a, 3);
    _ = stz_emb_store("y", 1, &b, 3);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), stz_emb_cosine("x", 1, "y", 1), 0.001);
    stz_emb_clear();
}

test "has and remove" {
    stz_emb_clear();
    const v = [_]f64{1.0};
    _ = stz_emb_store("e", 1, &v, 1);
    try std.testing.expectEqual(@as(i32, 1), stz_emb_has("e", 1));
    _ = stz_emb_remove("e", 1);
    try std.testing.expectEqual(@as(i32, 0), stz_emb_has("e", 1));
    stz_emb_clear();
}

test "update existing" {
    stz_emb_clear();
    const v1 = [_]f64{ 1.0, 2.0 };
    _ = stz_emb_store("e", 1, &v1, 2);
    const v2 = [_]f64{ 3.0, 4.0, 5.0 };
    _ = stz_emb_store("e", 1, &v2, 3);
    try std.testing.expectEqual(@as(i32, 1), stz_emb_count());
    try std.testing.expectEqual(@as(i32, 3), stz_emb_dim("e", 1));
    stz_emb_clear();
}
