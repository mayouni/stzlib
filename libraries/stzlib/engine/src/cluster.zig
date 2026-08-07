//! K-nearest-neighbour selection and Lloyd's k-means, whole loops rather than
//! per-pair calls.
//!
//! PHASE 5, SECOND PASS. The first pass fixed these algorithms in Ring -- KNN was
//! sorting all N to take K, and that was worth removing on its own -- but stopped
//! there, and stopping there was not justified. Correct complexity in an interpreter
//! is still an interpreter. What kept them in Ring was a real constraint measured in
//! phase 3: a one-shot engine call is no faster than Ring because marshalling is the
//! whole cost. That argues for crossing the bridge ONCE FOR A WHOLE ALGORITHM, which
//! is what this module is, not for staying in Ring.
//!
//! The arithmetic that matters is the count of crossings:
//!
//!     Ring KNN         one crossing per (query, example)     N per query
//!     this             one crossing per query                1
//!     Ring k-means     one per (point, centroid, iteration)  N*K*iters
//!     this             one crossing per run                  1
//!
//! DISTANCE IS NOT REDEFINED HERE. Both functions call similarity.stz_sim_euclidean,
//! which phase 5 slice 3 made the single definition after finding three copies of it
//! (stzKMeans, stzKnn, similarity.zig). A fourth copy inside a faster loop would have
//! undone exactly what that slice bought.
//!
//! THE DECISION RULES ARE RING'S, TO THE COMPARISON. Both algorithms make choices
//! among equals -- which neighbour when two are the same distance, which centroid when
//! a point is equidistant -- and those choices are answers, not implementation detail.
//! Every comparison below is the one the Ring code made, in the same direction:
//! `<` and `>` where Ring had `<` and `>`, so a tie resolves the same way.

const std = @import("std");
const calib = @import("calib.zig");
const similarity = @import("similarity.zig");

inline fn dist(a: []const f64, b: []const f64) f64 {
    return similarity.stz_sim_euclidean(a.ptr, b.ptr, @intCast(a.len));
}

// ─── K NEAREST ───────────────────────────────────────────────────────────────

/// The K nearest rows of `points` (n x d, row-major) to `query`, ascending.
///
/// Bounded selection, never a sort: a candidate is considered only when there is
/// room or it beats the current worst, and it walks left while the neighbour is
/// STRICTLY greater. Equal distances therefore keep the order they were scanned in,
/// which is the training-set order -- the same stability Ring's insertion sort had,
/// and the thing that decides the vote when the K-th and (K+1)-th are equidistant.
///
/// Returns how many were filled (min(k, n)).
// --- Threaded top-k (M4 of the multicore tier) ---
//
// The scan chunks across threads, each running the SAME stable insertion
// below over its slice, and a merge that reproduces the serial tie
// semantics exactly: smaller distance first, equal distances -> smaller
// index (chunks are index-ordered and the merge prefers the earlier chunk
// on ties). Output-identical to serial, TIES INCLUDED -- proven in
// tools/knn_spike.zig on a quantized fixture built to collide, and pinned
// by the test below.
//
// GATE FROM MEASUREMENT (knn_spike, two runs, bar >= 1.5x on both):
//     n*d = 1.6M   1.05-1.66x  -> FAILS the bar, stays serial
//     n*d = 8M     2.4-2.6x    -> admitted
//     n*d = 12.8M  2.2-2.7x    -> admitted
// The gate is WORK (n*d), not n, so a 100k x 128 scan rates the same as an
// 800k x 16 one. PROVISIONAL until the shared calibration store (M5).
//
// The parallel path is also gated on k <= TOPK_SCRATCH: this function is
// allocation-free by contract, so per-thread candidate lists live on the
// stack. A larger k falls back to the serial scan, correct as ever.
pub var topk_gate = calib.Gate.init("cpu.topk.par_min_work", 8_000_000);
const TOPK_WORKERS = 8;
const TOPK_SCRATCH = 64;

const TopKChunk = struct {
    points: []const f64,
    d: usize,
    query: []const f64,
    take: usize,
    base: usize,
    idx: [TOPK_SCRATCH]i32 = undefined,
    dst: [TOPK_SCRATCH]f64 = undefined,
    have: usize = 0,
    fn run(self: *TopKChunk) void {
        self.have = scanInto(self.points, self.points.len / self.d, self.d, self.query, self.take, self.base, self.idx[0..self.take], self.dst[0..self.take]);
    }
};

/// The stable insertion scan over one index-ordered slice; `base` converts
/// local positions to global 1-based indices. This IS the old topK body --
/// serial callers pass base=0 over the whole range.
fn scanInto(points: []const f64, n: usize, d: usize, query: []const f64, take: usize, base: usize, out_idx: []i32, out_dist: []f64) usize {
    var have: usize = 0;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const dd = dist(query, points[i * d ..][0..d]);
        if (have < take or dd < out_dist[have - 1]) {
            var p = have;
            while (p > 0 and out_dist[p - 1] > dd) p -= 1;
            if (have < take) have += 1;
            var m = have - 1;
            while (m > p) : (m -= 1) {
                out_dist[m] = out_dist[m - 1];
                out_idx[m] = out_idx[m - 1];
            }
            out_dist[p] = dd;
            out_idx[p] = @intCast(base + i + 1); // Ring is 1-based
        }
    }
    return have;
}

pub fn topK(
    points: []const f64,
    n: usize,
    d: usize,
    query: []const f64,
    k: usize,
    out_idx: []i32,
    out_dist: []f64,
) usize {
    if (n == 0 or d == 0 or k == 0) return 0;
    const take = @min(k, n);

    if (n * d >= topk_gate.valueUsize() and take <= TOPK_SCRATCH) {
        const cpus = std.Thread.getCpuCount() catch 1;
        const nt = @min(TOPK_WORKERS, cpus);
        if (nt > 1) {
            var jobs: [TOPK_WORKERS]TopKChunk = undefined;
            var threads: [TOPK_WORKERS]std.Thread = undefined;
            const rows = n / nt;
            var spawned: usize = 0;
            for (0..nt) |t| {
                const lo = t * rows;
                const hi = if (t == nt - 1) n else lo + rows;
                jobs[t] = .{ .points = points[lo * d .. hi * d], .d = d, .query = query, .take = take, .base = lo };
                // Compact handles (the M1 lesson); a failed spawn runs inline.
                threads[spawned] = std.Thread.spawn(.{}, TopKChunk.run, .{&jobs[t]}) catch {
                    jobs[t].run();
                    continue;
                };
                spawned += 1;
            }
            for (threads[0..spawned]) |th| th.join();

            // k-way merge: min distance wins; on equal distance the EARLIER
            // chunk (lower global indices) wins, matching serial stability.
            var pos: [TOPK_WORKERS]usize = .{0} ** TOPK_WORKERS;
            var have: usize = 0;
            while (have < take) {
                var best_j: usize = std.math.maxInt(usize);
                var best_d: f64 = std.math.inf(f64);
                for (0..nt) |jix| {
                    if (pos[jix] < jobs[jix].have) {
                        const dd = jobs[jix].dst[pos[jix]];
                        if (dd < best_d) {
                            best_d = dd;
                            best_j = jix;
                        }
                    }
                }
                if (best_j == std.math.maxInt(usize)) break;
                out_dist[have] = jobs[best_j].dst[pos[best_j]];
                out_idx[have] = jobs[best_j].idx[pos[best_j]];
                pos[best_j] += 1;
                have += 1;
            }
            return have;
        }
    }

    return scanInto(points, n, d, query, take, 0, out_idx, out_dist);
}

// ─── K MEANS ─────────────────────────────────────────────────────────────────

pub const KMeansResult = struct {
    iterations: i32,
    /// how many centroids were actually seeded; fewer than k means the input did
    /// not contain k distinct points, which the caller must refuse rather than
    /// silently cluster into fewer groups
    seeded: usize,
};

/// `counts` is scratch of k entries, supplied by the caller so this stays
/// allocation-free and works for any dimension.
///
/// Lloyd's algorithm with Ring's deterministic seeding: the first k DISTINCT points,
/// in input order. No randomness anywhere, so two runs on the same data agree -- the
/// reproducibility this library treats as a law rather than a nicety.
pub fn kmeansRun(
    points: []const f64,
    n: usize,
    d: usize,
    k: usize,
    max_iter: usize,
    centroids: []f64,
    assign: []i32,
    counts: []usize,
) KMeansResult {
    if (n == 0 or d == 0 or k == 0 or n < k) return .{ .iterations = 0, .seeded = 0 };

    // seed: the first k points that are not an exact duplicate of one already taken
    var seeded: usize = 0;
    var i: usize = 0;
    while (i < n and seeded < k) : (i += 1) {
        const p = points[i * d ..][0..d];
        var dup = false;
        var c: usize = 0;
        while (c < seeded) : (c += 1) {
            if (dist(p, centroids[c * d ..][0..d]) == 0) {
                dup = true;
                break;
            }
        }
        if (!dup) {
            @memcpy(centroids[seeded * d ..][0..d], p);
            seeded += 1;
        }
    }
    if (seeded < k) return .{ .iterations = 0, .seeded = seeded };

    @memset(assign[0..n], 0);

    var iters: i32 = 0;
    var it: usize = 0;
    while (it < max_iter) : (it += 1) {
        iters = @intCast(it + 1);

        // assign. `<` is strict, so a point equidistant from two centroids stays
        // with the LOWER-numbered one -- Ring's rule.
        var changed = false;
        var pi: usize = 0;
        while (pi < n) : (pi += 1) {
            const p = points[pi * d ..][0..d];
            var best: usize = 0;
            var bd = dist(p, centroids[0..d]);
            var c: usize = 1;
            while (c < k) : (c += 1) {
                const dd = dist(p, centroids[c * d ..][0..d]);
                if (dd < bd) {
                    bd = dd;
                    best = c;
                }
            }
            const best1: i32 = @intCast(best + 1);
            if (assign[pi] != best1) {
                assign[pi] = best1;
                changed = true;
            }
        }
        if (!changed) break;

        // update: the mean of each cluster. Counting first means the accumulation
        // can happen IN the centroid array -- the old centroid is not needed once
        // assignment is done, and an empty cluster is the one case where it is, so
        // that cluster is skipped and keeps its value. Ring does the same, which is
        // why a k-means here can report fewer OCCUPIED clusters than k.
        @memset(counts[0..k], 0);
        var pc: usize = 0;
        while (pc < n) : (pc += 1) counts[@intCast(assign[pc] - 1)] += 1;

        var c: usize = 0;
        while (c < k) : (c += 1) {
            if (counts[c] > 0) @memset(centroids[c * d ..][0..d], 0);
        }
        pc = 0;
        while (pc < n) : (pc += 1) {
            const c_of: usize = @intCast(assign[pc] - 1);
            if (counts[c_of] == 0) continue;
            const row = points[pc * d ..][0..d];
            const dst = centroids[c_of * d ..][0..d];
            var t: usize = 0;
            while (t < d) : (t += 1) dst[t] += row[t];
        }
        c = 0;
        while (c < k) : (c += 1) {
            if (counts[c] == 0) continue;
            const inv = @as(f64, @floatFromInt(counts[c]));
            const dst = centroids[c * d ..][0..d];
            var t: usize = 0;
            while (t < d) : (t += 1) dst[t] /= inv;
        }
    }
    return .{ .iterations = iters, .seeded = seeded };
}


// ─── RESIDENT DATASETS ───────────────────────────────────────────────────────
//
// Sending the matrix once per query beat sending a vector per example, but only
// until it was measured against the alternative of not sending it at all. A KNN
// dataset is written once and read by every query, so re-marshalling 160000
// numbers per query was still most of the remaining cost -- 34 ms of a 34.3 ms
// classification. This is phase 3's residency keystone applied here: the points
// live in the engine, and a query crosses the bridge carrying only itself.

pub const Dataset = struct {
    data: []f64,
    n: usize,
    d: usize,
    allocator: std.mem.Allocator,

    pub fn init(alloc: std.mem.Allocator, n: usize, d: usize) !*Dataset {
        const ds = try alloc.create(Dataset);
        ds.* = .{
            .data = try alloc.alloc(f64, n * d),
            .n = n,
            .d = d,
            .allocator = alloc,
        };
        return ds;
    }

    pub fn deinit(self: *Dataset) void {
        self.allocator.free(self.data);
        self.allocator.destroy(self);
    }
};

/// The K nearest rows of a RESIDENT dataset. Identical selection and tie rule to
/// topK above -- it is the same function, given points it did not have to receive.
pub fn topKResident(
    ds: *const Dataset,
    query: []const f64,
    k: usize,
    out_idx: []i32,
    out_dist: []f64,
) usize {
    return topK(ds.data, ds.n, ds.d, query, k, out_idx, out_dist);
}

test "a resident dataset answers exactly as the passing form does" {
    const gpa = std.testing.allocator;
    const pts = [_]f64{ 0, 0, 3, 4, 1, 0, 0, 2 };
    const q = [_]f64{ 0, 0 };

    var ia: [3]i32 = undefined;
    var da: [3]f64 = undefined;
    const na = topK(&pts, 4, 2, &q, 3, &ia, &da);

    const ds = try Dataset.init(gpa, 4, 2);
    defer ds.deinit();
    @memcpy(ds.data, &pts);
    var ib: [3]i32 = undefined;
    var db: [3]f64 = undefined;
    const nb = topKResident(ds, &q, 3, &ib, &db);

    try std.testing.expectEqual(na, nb);
    for (0..na) |i| {
        try std.testing.expectEqual(ia[i], ib[i]);
        try std.testing.expectEqual(da[i], db[i]);
    }
}

// ─── tests ───────────────────────────────────────────────────────────────────

test "topK returns the k nearest, ascending" {
    const pts = [_]f64{ 0, 0, 3, 4, 1, 0, 0, 2 }; // 4 points in 2-D
    const q = [_]f64{ 0, 0 };
    var idx: [3]i32 = undefined;
    var dst: [3]f64 = undefined;
    const got = topK(&pts, 4, 2, &q, 3, &idx, &dst);
    try std.testing.expectEqual(@as(usize, 3), got);
    try std.testing.expectEqual(@as(i32, 1), idx[0]); // itself, d=0
    try std.testing.expectEqual(@as(i32, 3), idx[1]); // [1,0], d=1
    try std.testing.expectEqual(@as(i32, 4), idx[2]); // [0,2], d=2
    try std.testing.expect(dst[0] <= dst[1] and dst[1] <= dst[2]);
}

test "topK ties keep scan order -- the vote depends on it" {
    // three points all at distance 1 from the origin, given in a known order
    const pts = [_]f64{ 1, 0, 0, 1, -1, 0 };
    const q = [_]f64{ 0, 0 };
    var idx: [3]i32 = undefined;
    var dst: [3]f64 = undefined;
    _ = topK(&pts, 3, 2, &q, 3, &idx, &dst);
    try std.testing.expectEqual(@as(i32, 1), idx[0]);
    try std.testing.expectEqual(@as(i32, 2), idx[1]);
    try std.testing.expectEqual(@as(i32, 3), idx[2]);
}

test "topK with k larger than n fills only n" {
    const pts = [_]f64{ 1, 2 };
    const q = [_]f64{ 0, 0 };
    var idx: [5]i32 = undefined;
    var dst: [5]f64 = undefined;
    try std.testing.expectEqual(@as(usize, 1), topK(&pts, 1, 2, &q, 5, &idx, &dst));
}

test "kmeans separates two obvious groups" {
    const pts = [_]f64{ 0, 0, 0.1, 0.1, 10, 10, 10.1, 10.1 };
    var cent: [4]f64 = undefined;
    var asg: [4]i32 = undefined;
    var cnt: [2]usize = undefined;
    const r = kmeansRun(&pts, 4, 2, 2, 20, &cent, &asg, &cnt);
    try std.testing.expectEqual(@as(usize, 2), r.seeded);
    try std.testing.expectEqual(asg[0], asg[1]);
    try std.testing.expectEqual(asg[2], asg[3]);
    try std.testing.expect(asg[0] != asg[2]);
}

test "kmeans is deterministic -- two runs agree exactly" {
    var pts: [200]f64 = undefined;
    for (0..100) |i| {
        pts[i * 2] = @floatFromInt((i * 37) % 100);
        pts[i * 2 + 1] = @floatFromInt((i * 11) % 100);
    }
    var c1: [8]f64 = undefined;
    var c2: [8]f64 = undefined;
    var a1: [100]i32 = undefined;
    var a2: [100]i32 = undefined;
    var cn1: [4]usize = undefined;
    var cn2: [4]usize = undefined;
    const r1 = kmeansRun(&pts, 100, 2, 4, 50, &c1, &a1, &cn1);
    const r2 = kmeansRun(&pts, 100, 2, 4, 50, &c2, &a2, &cn2);
    try std.testing.expectEqual(r1.iterations, r2.iterations);
    for (0..8) |i| try std.testing.expectEqual(c1[i], c2[i]);
    for (0..100) |i| try std.testing.expectEqual(a1[i], a2[i]);
}

test "kmeans refuses when there are not k distinct points" {
    const pts = [_]f64{ 1, 1, 1, 1, 1, 1 }; // three copies of one point
    var cent: [6]f64 = undefined;
    var asg: [3]i32 = undefined;
    var cnt: [3]usize = undefined;
    const r = kmeansRun(&pts, 3, 2, 3, 10, &cent, &asg, &cnt);
    try std.testing.expectEqual(@as(usize, 1), r.seeded); // only one distinct
}

test "threaded topK is output-identical to serial, ties included" {
    const gpa2 = std.testing.allocator;
    defer topk_gate.reset();

    // Quantized coordinates so equal distances OCCUR; n not divisible by 8
    // so the last chunk is uneven.
    const n = 10_007;
    const d = 4;
    const pts = try gpa2.alloc(f64, n * d);
    defer gpa2.free(pts);
    var seed: u64 = 21;
    for (pts) |*v| {
        seed = seed *% 6364136223846793005 +% 1442695040888963407;
        v.* = @as(f64, @floatFromInt((seed >> 33) % 6));
    }
    const q = [_]f64{ 2, 2, 2, 2 };

    var ia: [12]i32 = undefined;
    var da: [12]f64 = undefined;
    topk_gate.overrideUsize(std.math.maxInt(usize)); // force serial
    const na = topK(pts, n, d, &q, 12, &ia, &da);

    var ib: [12]i32 = undefined;
    var db: [12]f64 = undefined;
    topk_gate.overrideUsize(1); // force parallel
    const nb = topK(pts, n, d, &q, 12, &ib, &db);

    try std.testing.expectEqual(na, nb);
    for (ia[0..na], ib[0..nb]) |x, y| try std.testing.expectEqual(x, y);
    for (da[0..na], db[0..nb]) |x, y| try std.testing.expect(x == y);
}
