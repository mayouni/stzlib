const std = @import("std");
const stats = @import("stats.zig");

// ─── Similarity Engine ───
// Metrics for numeric vectors (cosine, Euclidean, Manhattan, dot product) plus
// Jaccard over sets represented as sorted arrays.
//
// PHASE 4 OF THE NUMERIC FOUNDATION, slice 6. Two things were wrong here, and the
// first was not a performance problem.
//
// THE CAP. Every function began `if (dim > 1024) return 0.0`. Not an error, not a
// clamp -- a SILENT ZERO. Two identical 1536-dimension vectors would have scored 0
// cosine similarity, which reads as "completely unrelated". Modern sentence
// embeddings are 384, 768, 1024 and 1536, so the cap sat exactly at the boundary of
// what a real model produces. It was LATENT rather than live only because
// ring_bridge_similarity.zig exposed just a hardcoded 3-dimension variant, so Ring
// could never reach the check -- and the plan's claim that this module was "on the
// hot path for every embedding comparison" was therefore wrong. Both halves are
// fixed in the same slice, because widening the bridge without removing the cap
// would have converted a latent trap into a live one.
//
// There is nothing to cap: every function is handed its length and reads exactly
// that many elements. The guard now rejects only a non-positive length.
//
// THE SCALAR LOOPS. Vectorised with the same @Vector(8) shape as stats.zig's
// summation and centered sum of squares. Cosine is the interesting one -- it
// accumulates THREE quantities in one pass (dot, |a|^2, |b|^2), so it does three
// times the arithmetic per element loaded and benefits more than a plain dot
// product, which is bandwidth-bound.

const LANES = 8;
const V = @Vector(LANES, f64);

// ─── C ABI ───

/// Cosine similarity. Three accumulators in one pass over both vectors -- dot,
/// and the two squared magnitudes -- so the data is read once rather than three
/// times.
pub export fn stz_sim_cosine(a_ptr: [*]const f64, b_ptr: [*]const f64, dim: i32) f64 {
    if (dim <= 0) return 0.0;
    const n: usize = @intCast(dim);
    const a = a_ptr[0..n];
    const b = b_ptr[0..n];

    var vdot: V = @splat(0);
    var vma: V = @splat(0);
    var vmb: V = @splat(0);
    var i: usize = 0;
    while (i + LANES <= n) : (i += LANES) {
        const va: V = a[i..][0..LANES].*;
        const vb: V = b[i..][0..LANES].*;
        vdot += va * vb;
        vma += va * va;
        vmb += vb * vb;
    }
    var dot = @reduce(.Add, vdot);
    var mag_a = @reduce(.Add, vma);
    var mag_b = @reduce(.Add, vmb);
    while (i < n) : (i += 1) {
        dot += a[i] * b[i];
        mag_a += a[i] * a[i];
        mag_b += b[i] * b[i];
    }

    const denom = @sqrt(mag_a) * @sqrt(mag_b);
    if (denom == 0.0) return 0.0;
    return dot / denom;
}

pub export fn stz_sim_euclidean(a_ptr: [*]const f64, b_ptr: [*]const f64, dim: i32) f64 {
    if (dim <= 0) return 0.0;
    const n: usize = @intCast(dim);
    const a = a_ptr[0..n];
    const b = b_ptr[0..n];

    var acc: V = @splat(0);
    var i: usize = 0;
    while (i + LANES <= n) : (i += LANES) {
        const d = @as(V, a[i..][0..LANES].*) - @as(V, b[i..][0..LANES].*);
        acc += d * d;
    }
    var sum = @reduce(.Add, acc);
    while (i < n) : (i += 1) {
        const d = a[i] - b[i];
        sum += d * d;
    }
    return @sqrt(sum);
}

/// Squared euclidean distance -- the same sum as above WITHOUT the final
/// @sqrt.
///
/// Added because callers that want the square kept re-deriving it, badly:
/// density.zig had this loop written out inline in index form inside an
/// O(n^2) double loop, and squaring the rooted result back would have thrown
/// away a bit of precision for no reason. Ranking and comparison work
/// (nearest-neighbour, radius tests) never needs the root -- sqrt is
/// monotone -- so this is the primitive most callers actually wanted.
pub export fn stz_sim_euclidean_sq(a_ptr: [*]const f64, b_ptr: [*]const f64, dim: i32) f64 {
    if (dim <= 0) return 0.0;
    const n: usize = @intCast(dim);
    const a = a_ptr[0..n];
    const b = b_ptr[0..n];

    var acc: V = @splat(0);
    var i: usize = 0;
    while (i + LANES <= n) : (i += LANES) {
        const d = @as(V, a[i..][0..LANES].*) - @as(V, b[i..][0..LANES].*);
        acc += d * d;
    }
    var sum = @reduce(.Add, acc);
    while (i < n) : (i += 1) {
        const d = a[i] - b[i];
        sum += d * d;
    }
    return sum;
}

pub export fn stz_sim_manhattan(a_ptr: [*]const f64, b_ptr: [*]const f64, dim: i32) f64 {
    if (dim <= 0) return 0.0;
    const n: usize = @intCast(dim);
    const a = a_ptr[0..n];
    const b = b_ptr[0..n];

    var acc: V = @splat(0);
    var i: usize = 0;
    while (i + LANES <= n) : (i += LANES) {
        acc += @abs(@as(V, a[i..][0..LANES].*) - @as(V, b[i..][0..LANES].*));
    }
    var sum = @reduce(.Add, acc);
    while (i < n) : (i += 1) sum += @abs(a[i] - b[i]);
    return sum;
}

pub export fn stz_sim_jaccard_sorted(a_ptr: [*]const i64, a_len: i32, b_ptr: [*]const i64, b_len: i32) f64 {
    if (a_len <= 0 or b_len <= 0) return 0.0;
    const na: usize = @intCast(a_len);
    const nb: usize = @intCast(b_len);
    var ia: usize = 0;
    var ib: usize = 0;
    var intersection: usize = 0;
    var union_size: usize = 0;
    // A merge of two sorted runs -- inherently sequential, so there is nothing for
    // @Vector to do here. Left as it was rather than contorted.
    while (ia < na and ib < nb) {
        if (a_ptr[ia] == b_ptr[ib]) {
            intersection += 1;
            union_size += 1;
            ia += 1;
            ib += 1;
        } else if (a_ptr[ia] < b_ptr[ib]) {
            union_size += 1;
            ia += 1;
        } else {
            union_size += 1;
            ib += 1;
        }
    }
    union_size += (na - ia) + (nb - ib);
    if (union_size == 0) return 1.0;
    return @as(f64, @floatFromInt(intersection)) / @as(f64, @floatFromInt(union_size));
}

pub export fn stz_sim_dot_product(a_ptr: [*]const f64, b_ptr: [*]const f64, dim: i32) f64 {
    if (dim <= 0) return 0.0;
    const n: usize = @intCast(dim);
    const a = a_ptr[0..n];
    const b = b_ptr[0..n];

    var acc: V = @splat(0);
    var i: usize = 0;
    while (i + LANES <= n) : (i += LANES) {
        acc += @as(V, a[i..][0..LANES].*) * @as(V, b[i..][0..LANES].*);
    }
    var dot = @reduce(.Add, acc);
    while (i < n) : (i += 1) dot += a[i] * b[i];
    return dot;
}

pub export fn stz_sim_normalize(vec: [*]f64, dim: i32) void {
    if (dim <= 0) return;
    const n: usize = @intCast(dim);
    const v = vec[0..n];

    var acc: V = @splat(0);
    var i: usize = 0;
    while (i + LANES <= n) : (i += LANES) {
        const x: V = v[i..][0..LANES].*;
        acc += x * x;
    }
    var mag = @reduce(.Add, acc);
    while (i < n) : (i += 1) mag += v[i] * v[i];

    mag = @sqrt(mag);
    if (mag == 0.0) return;
    const vm: V = @splat(mag);
    i = 0;
    while (i + LANES <= n) : (i += LANES) {
        const q: V = @as(V, v[i..][0..LANES].*) / vm;
        v[i..][0..LANES].* = q;
    }
    while (i < n) : (i += 1) v[i] /= mag;
}

// ─── Tests ───

const testing = std.testing;

test "cosine similarity" {
    const a = [_]f64{ 1.0, 0.0, 0.0 };
    const b = [_]f64{ 1.0, 0.0, 0.0 };
    try testing.expectApproxEqAbs(@as(f64, 1.0), stz_sim_cosine(&a, &b, 3), 0.001);

    const c = [_]f64{ 0.0, 1.0, 0.0 };
    try testing.expectApproxEqAbs(@as(f64, 0.0), stz_sim_cosine(&a, &c, 3), 0.001);
}

test "euclidean distance" {
    const a = [_]f64{ 0.0, 0.0 };
    const b = [_]f64{ 3.0, 4.0 };
    try testing.expectApproxEqAbs(@as(f64, 5.0), stz_sim_euclidean(&a, &b, 2), 0.001);
}

test "manhattan distance" {
    const a = [_]f64{ 1.0, 2.0, 3.0 };
    const b = [_]f64{ 4.0, 6.0, 3.0 };
    try testing.expectApproxEqAbs(@as(f64, 7.0), stz_sim_manhattan(&a, &b, 3), 0.001);
}

test "jaccard on sorted sets" {
    const a = [_]i64{ 1, 2, 3, 4 };
    const b = [_]i64{ 2, 3, 5 };
    // intersection = {2,3} = 2, union = {1,2,3,4,5} = 5
    try testing.expectApproxEqAbs(@as(f64, 0.4), stz_sim_jaccard_sorted(&a, 4, &b, 3), 0.001);
}

test "dot product" {
    const a = [_]f64{ 1.0, 2.0, 3.0 };
    const b = [_]f64{ 4.0, 5.0, 6.0 };
    try testing.expectApproxEqAbs(@as(f64, 32.0), stz_sim_dot_product(&a, &b, 3), 0.001);
}

test "normalize" {
    var v = [_]f64{ 3.0, 4.0 };
    stz_sim_normalize(&v, 2);
    try testing.expectApproxEqAbs(@as(f64, 0.6), v[0], 0.001);
    try testing.expectApproxEqAbs(@as(f64, 0.8), v[1], 0.001);
}

test "similarity: THE 1024 CAP IS GONE, and it was a silent zero" {
    // Every function used to answer 0.0 above dim 1024 -- not an error, not a
    // clamp. Two IDENTICAL 1536-dimension vectors scored 0 cosine similarity,
    // which reads as "completely unrelated". Modern sentence embeddings are 384,
    // 768, 1024 and 1536, so the cap sat exactly where real models live.
    inline for (.{ 384, 768, 1024, 1025, 1536, 4096 }) |dim| {
        var a: [dim]f64 = undefined;
        var b: [dim]f64 = undefined;
        for (&a, &b, 0..) |*x, *y, i| {
            const fi: f64 = @floatFromInt(i % 17);
            x.* = fi + 1.0;
            y.* = fi + 1.0;
        }
        // a vector is perfectly similar to itself, at EVERY dimension
        try testing.expectApproxEqAbs(@as(f64, 1.0), stz_sim_cosine(&a, &b, dim), 1e-12);
        // and at zero distance from itself
        try testing.expectApproxEqAbs(@as(f64, 0.0), stz_sim_euclidean(&a, &b, dim), 1e-12);
        try testing.expectApproxEqAbs(@as(f64, 0.0), stz_sim_manhattan(&a, &b, dim), 1e-12);
        try testing.expect(stz_sim_dot_product(&a, &b, dim) > 0);
    }

    // a non-positive length is still refused
    const z = [_]f64{ 1, 2, 3 };
    try testing.expectEqual(@as(f64, 0), stz_sim_cosine(&z, &z, 0));
    try testing.expectEqual(@as(f64, 0), stz_sim_cosine(&z, &z, -1));
}

test "similarity: the vectorised forms agree with plain scalar loops" {
    // Every length across the vector boundary -- fewer than one register, exactly
    // one, several plus every possible remainder.
    var a: [40]f64 = undefined;
    var b: [40]f64 = undefined;
    for (&a, &b, 0..) |*x, *y, i| {
        const fi: f64 = @floatFromInt(i);
        x.* = fi * 0.5 - 3.0;
        y.* = 7.0 - fi * 0.25;
    }

    for (0..a.len + 1) |n| {
        if (n == 0) continue;
        const dim: i32 = @intCast(n);

        var dot: f64 = 0;
        var ma: f64 = 0;
        var mb: f64 = 0;
        var euc: f64 = 0;
        var man: f64 = 0;
        for (a[0..n], b[0..n]) |x, y| {
            dot += x * y;
            ma += x * x;
            mb += y * y;
            euc += (x - y) * (x - y);
            man += @abs(x - y);
        }

        try testing.expectApproxEqRel(dot, stz_sim_dot_product(&a, &b, dim), 1e-13);
        try testing.expectApproxEqRel(@sqrt(euc), stz_sim_euclidean(&a, &b, dim), 1e-13);
        try testing.expectApproxEqRel(man, stz_sim_manhattan(&a, &b, dim), 1e-13);
        const denom = @sqrt(ma) * @sqrt(mb);
        if (denom != 0) {
            try testing.expectApproxEqRel(dot / denom, stz_sim_cosine(&a, &b, dim), 1e-13);
        }

        // normalize must leave a unit vector, at every length
        var v: [40]f64 = undefined;
        @memcpy(&v, &a);
        stz_sim_normalize(&v, dim);
        var m2: f64 = 0;
        for (v[0..n]) |x| m2 += x * x;
        try testing.expectApproxEqAbs(@as(f64, 1.0), @sqrt(m2), 1e-12);
    }

    // an all-zero vector cannot be normalised, and is left alone rather than
    // filled with NaN
    var zeros = [_]f64{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    stz_sim_normalize(&zeros, 10);
    for (zeros) |x| try testing.expectEqual(@as(f64, 0), x);
}

test "similarity: the identities a metric must satisfy" {
    const a = [_]f64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 };
    const b = [_]f64{ 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 };

    // symmetric
    try testing.expectApproxEqRel(stz_sim_cosine(&a, &b, 12), stz_sim_cosine(&b, &a, 12), 1e-15);
    try testing.expectApproxEqRel(stz_sim_euclidean(&a, &b, 12), stz_sim_euclidean(&b, &a, 12), 1e-15);

    // cosine of a vector with its own negation is -1
    var neg: [12]f64 = undefined;
    for (&neg, a) |*x, v| x.* = -v;
    try testing.expectApproxEqAbs(@as(f64, -1.0), stz_sim_cosine(&a, &neg, 12), 1e-14);

    // scaling a vector cannot change a COSINE (it is an angle) but does change a
    // distance -- the property that makes cosine the right choice for embeddings
    var scaled: [12]f64 = undefined;
    for (&scaled, a) |*x, v| x.* = v * 100.0;
    try testing.expectApproxEqAbs(
        stz_sim_cosine(&a, &b, 12),
        stz_sim_cosine(&scaled, &b, 12),
        1e-14,
    );
    try testing.expect(stz_sim_euclidean(&scaled, &b, 12) > stz_sim_euclidean(&a, &b, 12));

    // Manhattan >= Euclidean, always
    try testing.expect(stz_sim_manhattan(&a, &b, 12) >= stz_sim_euclidean(&a, &b, 12));

    // a normalised vector's dot product with another normalised vector IS their
    // cosine -- which is the identity StzSemanticSimilarity relies on
    var na: [12]f64 = undefined;
    var nb: [12]f64 = undefined;
    @memcpy(&na, &a);
    @memcpy(&nb, &b);
    stz_sim_normalize(&na, 12);
    stz_sim_normalize(&nb, 12);
    try testing.expectApproxEqAbs(
        stz_sim_cosine(&a, &b, 12),
        stz_sim_dot_product(&na, &nb, 12),
        1e-14,
    );
}
