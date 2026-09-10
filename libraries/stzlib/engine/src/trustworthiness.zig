//! trustworthiness.zig -- the embedding witness (Venna & Kaski 2006), as
//! scikit-learn computes it and as cuML's UMAP paper reports it beside every
//! timing (SOFTANZA_GPU_PLAN.md, GS6f).
//!
//!     T(k) = 1 - 2 / (n k (2n - 3k - 1)) * sum_i sum_{j in U_i^k} (r(i, j) - k)
//!
//! U_i^k = the points among the k nearest neighbours of i IN THE EMBEDDING that
//! are NOT among its k nearest in the INPUT; r(i, j) = the rank of j in the
//! input-space neighbour ordering of i (1 = nearest, i itself excluded). A
//! neighbour the layout invented is penalised by how far down the input
//! ordering it really sat; 1.0 means the embedding invented nothing.
//!
//! WHY THIS AND NOT PURITY. Blob purity needs labels and a blob generator;
//! trustworthiness needs only the input and the embedding, it is the number
//! the field compares on, and it lets this library's tables sit beside the
//! paper's. It is a ranking statistic, so f32 on the device and f64 here
//! give the SAME integer ranks wherever the two kernels agree on the
//! neighbour sets -- the tie rule is the k-NN kernel's (the lower index
//! wins) on both routes, and the guard holds the two answers equal.
//!
//! Cost: O(n^2 (d + dims)) on the CPU; on the device it is two k-NN passes
//! and one rank pass over n*k threads. Both routes here; the device's lives
//! in umap_gpu.zig beside the kernel it reuses.

const std = @import("std");
const umap_gpu = @import("umap_gpu.zig");

pub const Error = error{ BadShape, OutOfMemory };

fn dist2(a: []const f64, b: []const f64) f64 {
    var s: f64 = 0;
    for (a, b) |p, q| {
        const df = p - q;
        s += df * df;
    }
    return s;
}

/// Is l closer to i than j is, under the k-NN kernel's tie rule (equal
/// distance: the lower index is nearer)?
inline fn nearer(dl: f64, l: usize, dj: f64, j: usize) bool {
    return dl < dj or (dl == dj and l < j);
}

/// The k nearest of point i by the row of squared distances `drow` (i
/// itself excluded), with the kernel's tie rule; writes k indices.
fn selectK(drow: []const f64, i: usize, k: usize, out: []usize) void {
    var have: usize = 0;
    for (drow, 0..) |dj, j| {
        if (j == i) continue;
        // insertion into a sorted k-array: walk left while the neighbour is
        // strictly farther (or equal with a higher index)
        if (have < k or nearer(dj, j, drow[out[have - 1]], out[have - 1])) {
            var pos = have;
            while (pos > 0 and nearer(dj, j, drow[out[pos - 1]], out[pos - 1])) pos -= 1;
            if (have < k) have += 1;
            var m = have - 1;
            while (m > pos) : (m -= 1) out[m] = out[m - 1];
            out[pos] = j;
        }
    }
}

/// The exact CPU witness. x is n x d row-major, y is n x dims row-major.
pub fn cpu(alloc: std.mem.Allocator, x: []const f64, n: usize, d: usize, y: []const f64, dims: usize, k: usize) Error!f64 {
    if (n < 2 or d == 0 or dims == 0 or k == 0 or k >= n or x.len < n * d or y.len < n * dims) return Error.BadShape;
    if (2 * n < 3 * k + 1) return Error.BadShape; // the normaliser's domain (sklearn's too)
    const din = try alloc.alloc(f64, n);
    defer alloc.free(din);
    const dem = try alloc.alloc(f64, n);
    defer alloc.free(dem);
    const kin = try alloc.alloc(usize, k);
    defer alloc.free(kin);
    const kem = try alloc.alloc(usize, k);
    defer alloc.free(kem);
    var penalty: f64 = 0;
    for (0..n) |i| {
        const xi = x[i * d ..][0..d];
        const yi = y[i * dims ..][0..dims];
        for (0..n) |l| {
            din[l] = dist2(xi, x[l * d ..][0..d]);
            dem[l] = dist2(yi, y[l * dims ..][0..dims]);
        }
        selectK(din, i, k, kin);
        selectK(dem, i, k, kem);
        for (kem) |j| {
            var member = false;
            for (kin) |q| {
                if (q == j) member = true;
            }
            if (member) continue;
            // the rank of j in i's input ordering: one more than the count of
            // points nearer than j
            var count: usize = 0;
            for (0..n) |l| {
                if (l == i or l == j) continue;
                if (nearer(din[l], l, din[j], j)) count += 1;
            }
            const rank = count + 1;
            penalty += @as(f64, @floatFromInt(rank)) - @as(f64, @floatFromInt(k));
        }
    }
    const nf: f64 = @floatFromInt(n);
    const kf: f64 = @floatFromInt(k);
    return 1.0 - 2.0 / (nf * kf * (2.0 * nf - 3.0 * kf - 1.0)) * penalty;
}

/// The witness by whichever route serves: the device from its gate (or when
/// forced), the CPU otherwise -- the same number either way.
pub fn run(alloc: std.mem.Allocator, x: []const f64, n: usize, d: usize, y: []const f64, dims: usize, k: usize, mode: u8) Error!f64 {
    // mode: 0 = the engine decides, 1 = the CPU, 2 = the device past its gate
    if (mode != 1) {
        if (umap_gpu.trustworthiness(x, n, d, y, dims, k, mode == 2)) |t| return t;
    }
    return cpu(alloc, x, n, d, y, dims, k);
}

// ---------------------------------------------------------------- tests

test "the hand-computed case: five points on a line, one point folded back, T = 0.4" {
    // input 0 1 2 3 10; embedding 0 1 2 3 0.5 -- point 4 lands next to 0 and 1
    // i=0: emb-nearest 4, input-nearest 1 -> rank of 4 is 4 -> penalty 3
    // i=1: emb-nearest 4 (0.5), input-nearest 0 (tie with 2, lower wins) -> rank 4 -> 3
    // i=2: emb-nearest 1 (tie with 3, lower wins), input-nearest 1 -> 0
    // i=3: emb-nearest 2, input-nearest 2 -> 0
    // i=4: emb-nearest 0, input-nearest 3 -> rank of 0 is 4 -> 3
    // sum 9; normaliser 2/(5*1*(10-3-1)) = 1/15; T = 1 - 9/15 = 0.4
    const x = [_]f64{ 0, 1, 2, 3, 10 };
    const y = [_]f64{ 0, 1, 2, 3, 0.5 };
    const t = try cpu(std.testing.allocator, &x, 5, 1, &y, 1, 1);
    try std.testing.expectApproxEqAbs(@as(f64, 0.4), t, 1e-12);
}

test "an embedding that keeps every neighbour scores exactly 1" {
    const x = [_]f64{ 0, 0, 1, 0, 2, 0, 3, 0, 10, 0, 11, 0 };
    const y = [_]f64{ 0, 1, 2, 3, 10, 11 }; // the same ordering, one dimension
    const t = try cpu(std.testing.allocator, &x, 6, 2, &y, 1, 2);
    try std.testing.expectEqual(@as(f64, 1.0), t);
}

test "shapes outside the definition are refused, not answered" {
    const x = [_]f64{ 0, 1, 2, 3 };
    const y = [_]f64{ 0, 1, 2, 3 };
    try std.testing.expectError(Error.BadShape, cpu(std.testing.allocator, &x, 4, 1, &y, 1, 4)); // k >= n
    try std.testing.expectError(Error.BadShape, cpu(std.testing.allocator, &x, 4, 1, &y, 1, 3)); // 2n < 3k + 1
}
