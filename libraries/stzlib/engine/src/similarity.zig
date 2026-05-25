const std = @import("std");

// ─── Similarity Engine ───
// Generic similarity metrics for numeric vectors (cosine, Euclidean, Manhattan,
// Jaccard on sets represented as sorted arrays).

const MAX_DIM: usize = 1024;

// ─── C ABI ───

pub export fn stz_sim_cosine(a_ptr: [*]const f64, b_ptr: [*]const f64, dim: i32) f64 {
    if (dim <= 0 or dim > @as(i32, MAX_DIM)) return 0.0;
    const n: usize = @intCast(dim);
    var dot: f64 = 0.0;
    var mag_a: f64 = 0.0;
    var mag_b: f64 = 0.0;
    for (0..n) |idx| {
        dot += a_ptr[idx] * b_ptr[idx];
        mag_a += a_ptr[idx] * a_ptr[idx];
        mag_b += b_ptr[idx] * b_ptr[idx];
    }
    const denom = @sqrt(mag_a) * @sqrt(mag_b);
    if (denom == 0.0) return 0.0;
    return dot / denom;
}

pub export fn stz_sim_euclidean(a_ptr: [*]const f64, b_ptr: [*]const f64, dim: i32) f64 {
    if (dim <= 0 or dim > @as(i32, MAX_DIM)) return 0.0;
    const n: usize = @intCast(dim);
    var sum: f64 = 0.0;
    for (0..n) |idx| {
        const diff = a_ptr[idx] - b_ptr[idx];
        sum += diff * diff;
    }
    return @sqrt(sum);
}

pub export fn stz_sim_manhattan(a_ptr: [*]const f64, b_ptr: [*]const f64, dim: i32) f64 {
    if (dim <= 0 or dim > @as(i32, MAX_DIM)) return 0.0;
    const n: usize = @intCast(dim);
    var sum: f64 = 0.0;
    for (0..n) |idx| {
        const diff = a_ptr[idx] - b_ptr[idx];
        sum += if (diff < 0.0) -diff else diff;
    }
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
    if (dim <= 0 or dim > @as(i32, MAX_DIM)) return 0.0;
    const n: usize = @intCast(dim);
    var dot: f64 = 0.0;
    for (0..n) |idx| {
        dot += a_ptr[idx] * b_ptr[idx];
    }
    return dot;
}

pub export fn stz_sim_normalize(vec: [*]f64, dim: i32) void {
    if (dim <= 0 or dim > @as(i32, MAX_DIM)) return;
    const n: usize = @intCast(dim);
    var mag: f64 = 0.0;
    for (0..n) |idx| {
        mag += vec[idx] * vec[idx];
    }
    mag = @sqrt(mag);
    if (mag == 0.0) return;
    for (0..n) |idx| {
        vec[idx] /= mag;
    }
}

// ─── Tests ───

test "cosine similarity" {
    const a = [_]f64{ 1.0, 0.0, 0.0 };
    const b = [_]f64{ 1.0, 0.0, 0.0 };
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), stz_sim_cosine(&a, &b, 3), 0.001);

    const c = [_]f64{ 0.0, 1.0, 0.0 };
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), stz_sim_cosine(&a, &c, 3), 0.001);
}

test "euclidean distance" {
    const a = [_]f64{ 0.0, 0.0 };
    const b = [_]f64{ 3.0, 4.0 };
    try std.testing.expectApproxEqAbs(@as(f64, 5.0), stz_sim_euclidean(&a, &b, 2), 0.001);
}

test "manhattan distance" {
    const a = [_]f64{ 1.0, 2.0, 3.0 };
    const b = [_]f64{ 4.0, 6.0, 3.0 };
    try std.testing.expectApproxEqAbs(@as(f64, 7.0), stz_sim_manhattan(&a, &b, 3), 0.001);
}

test "jaccard on sorted sets" {
    const a = [_]i64{ 1, 2, 3, 4 };
    const b = [_]i64{ 2, 3, 5 };
    // intersection = {2,3} = 2, union = {1,2,3,4,5} = 5
    try std.testing.expectApproxEqAbs(@as(f64, 0.4), stz_sim_jaccard_sorted(&a, 4, &b, 3), 0.001);
}

test "dot product" {
    const a = [_]f64{ 1.0, 2.0, 3.0 };
    const b = [_]f64{ 4.0, 5.0, 6.0 };
    try std.testing.expectApproxEqAbs(@as(f64, 32.0), stz_sim_dot_product(&a, &b, 3), 0.001);
}

test "normalize" {
    var v = [_]f64{ 3.0, 4.0 };
    stz_sim_normalize(&v, 2);
    try std.testing.expectApproxEqAbs(@as(f64, 0.6), v[0], 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 0.8), v[1], 0.001);
}
