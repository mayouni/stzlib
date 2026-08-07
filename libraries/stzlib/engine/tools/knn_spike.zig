// KNN / DISTANCE-SCAN THREADING SPIKE (M4).
//
// Run:  zig run tools/knn_spike.zig -OReleaseSafe
//
// Two scans, two shapes:
//   A. all-pairs exact kNN (umap.knnExact): O(n^2 d), each point's row fully
//      independent -- OUTPUT PARTITION, bit-identical by construction. Only
//      runs below the ANN switch (n < 8192), so the interesting sizes are
//      1k..8k.
//   B. single-query top-k (cluster.topK): one streaming pass with stable-
//      by-index insertion. Threading = chunk the points, local top-k per
//      thread with the SAME insertion, then a merge that must reproduce the
//      serial tie semantics EXACTLY (smaller distance wins; equal distance
//      -> smaller index). Identity is asserted, ties included.
//
// SHIP BAR: >= 1.5x on BOTH runs at some thread count, per scan, per size
// class -- gates go where the bar clears, nothing below it changes.

const std = @import("std");

fn sqDist(a: []const f64, b: []const f64) f64 {
    var s: f64 = 0;
    for (a, b) |x, y| {
        const t = x - y;
        s += t * t;
    }
    return s;
}

// ── A: all-pairs, replicated from umap.knnExact ──
fn knnRow(x: []const f64, n: usize, d: usize, k: usize, i: usize, cand: []f64, idx_out: []u32, dist_out: []f64) void {
    for (0..n) |j| cand[j] = if (j == i) std.math.inf(f64) else @sqrt(sqDist(x[i * d ..][0..d], x[j * d ..][0..d]));
    for (0..k) |slot| {
        var best: usize = 0;
        var bestv = std.math.inf(f64);
        for (0..n) |j| {
            if (cand[j] < bestv) {
                bestv = cand[j];
                best = j;
            }
        }
        idx_out[i * k + slot] = @intCast(best);
        dist_out[i * k + slot] = bestv;
        cand[best] = std.math.inf(f64);
    }
}

const RowJob = struct {
    x: []const f64,
    n: usize,
    d: usize,
    k: usize,
    i0: usize,
    i1: usize,
    cand: []f64,
    idx_out: []u32,
    dist_out: []f64,
    fn run(self: *const RowJob) void {
        var i = self.i0;
        while (i < self.i1) : (i += 1) {
            knnRow(self.x, self.n, self.d, self.k, i, self.cand, self.idx_out, self.dist_out);
        }
    }
};

// ── B: single-query top-k, replicated from cluster.topK (1-based idx) ──
fn topKSerial(points: []const f64, n: usize, d: usize, query: []const f64, k: usize, out_idx: []i32, out_dist: []f64) usize {
    const take = @min(k, n);
    var have: usize = 0;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const dd = @sqrt(sqDist(query, points[i * d ..][0..d]));
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
            out_idx[p] = @intCast(i + 1);
        }
    }
    return have;
}

const ChunkJob = struct {
    points: []const f64,
    d: usize,
    query: []const f64,
    k: usize,
    base: usize, // global index offset of this chunk
    out_idx: []i32,
    out_dist: []f64,
    have: usize = 0,
    fn run(self: *ChunkJob) void {
        const n = self.points.len / self.d;
        const take = @min(self.k, n);
        var have: usize = 0;
        var i: usize = 0;
        while (i < n) : (i += 1) {
            const dd = @sqrt(sqDist(self.query, self.points[i * self.d ..][0..self.d]));
            if (have < take or dd < self.out_dist[have - 1]) {
                var p = have;
                while (p > 0 and self.out_dist[p - 1] > dd) p -= 1;
                if (have < take) have += 1;
                var m = have - 1;
                while (m > p) : (m -= 1) {
                    self.out_dist[m] = self.out_dist[m - 1];
                    self.out_idx[m] = self.out_idx[m - 1];
                }
                self.out_dist[p] = dd;
                self.out_idx[p] = @intCast(self.base + i + 1);
            }
        }
        self.have = have;
    }
};

// Merge thread-local sorted top-k lists, reproducing serial tie semantics:
// smaller distance first; equal distances -> smaller global index. Chunks
// are index-ordered and each local list is stable, so picking the LOWEST
// chunk among equal heads preserves the serial order exactly.
fn mergeTopK(jobs: []ChunkJob, k: usize, out_idx: []i32, out_dist: []f64) usize {
    var pos: [12]usize = .{0} ** 12;
    var have: usize = 0;
    while (have < k) {
        var best_j: usize = std.math.maxInt(usize);
        var best_d: f64 = std.math.inf(f64);
        for (jobs, 0..) |*jb, jix| {
            if (pos[jix] < jb.have) {
                const dd = jb.out_dist[pos[jix]];
                if (dd < best_d) {
                    best_d = dd;
                    best_j = jix;
                }
                // equal: keep the earlier chunk (lower global indices)
            }
        }
        if (best_j == std.math.maxInt(usize)) break;
        out_dist[have] = jobs[best_j].out_dist[pos[best_j]];
        out_idx[have] = jobs[best_j].out_idx[pos[best_j]];
        pos[best_j] += 1;
        have += 1;
    }
    return have;
}

fn ms(ns: u64) f64 {
    return @as(f64, @floatFromInt(ns)) / 1_000_000.0;
}

pub fn main() !void {
    var gpa_state = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa_state.allocator();
    var timer = try std.time.Timer.start();
    const REPS = 3;

    // ── A: all-pairs ──
    for ([_][2]usize{ .{ 1024, 32 }, .{ 2048, 32 }, .{ 4096, 32 }, .{ 4096, 8 } }) |cfg| {
        const n = cfg[0];
        const d = cfg[1];
        const k = 15;
        const x = try alloc.alloc(f64, n * d);
        defer alloc.free(x);
        var seed: u64 = 3;
        for (x) |*v| {
            seed = seed *% 6364136223846793005 +% 1442695040888963407;
            v.* = @as(f64, @floatFromInt((seed >> 33) % 1000)) / 999.0;
        }
        const idx_s = try alloc.alloc(u32, n * k);
        defer alloc.free(idx_s);
        const dist_s = try alloc.alloc(f64, n * k);
        defer alloc.free(dist_s);
        const idx_p = try alloc.alloc(u32, n * k);
        defer alloc.free(idx_p);
        const dist_p = try alloc.alloc(f64, n * k);
        defer alloc.free(dist_p);
        const cand1 = try alloc.alloc(f64, n);
        defer alloc.free(cand1);

        var t_ser: u64 = std.math.maxInt(u64);
        for (0..REPS) |_| {
            timer.reset();
            for (0..n) |i| knnRow(x, n, d, k, i, cand1, idx_s, dist_s);
            t_ser = @min(t_ser, timer.read());
        }
        std.debug.print("allpairs n={d:>5} d={d:>3}: serial {d:8.2} ms  ", .{ n, d, ms(t_ser) });

        for ([_]usize{ 4, 8 }) |nt| {
            const cands = try alloc.alloc(f64, n * nt);
            defer alloc.free(cands);
            var jobs: [12]RowJob = undefined;
            var ths: [12]std.Thread = undefined;
            var t_par: u64 = std.math.maxInt(u64);
            for (0..REPS) |_| {
                timer.reset();
                const per = (n + nt - 1) / nt;
                for (0..nt) |t| {
                    jobs[t] = .{ .x = x, .n = n, .d = d, .k = k, .i0 = @min(t * per, n), .i1 = @min((t + 1) * per, n), .cand = cands[t * n .. (t + 1) * n], .idx_out = idx_p, .dist_out = dist_p };
                    ths[t] = try std.Thread.spawn(.{}, RowJob.run, .{&jobs[t]});
                }
                for (ths[0..nt]) |th| th.join();
                t_par = @min(t_par, timer.read());
            }
            for (idx_p, idx_s) |a2, b2| if (a2 != b2) return error.IdxMismatch;
            for (dist_p, dist_s) |a2, b2| if (a2 != b2) return error.DistMismatch;
            std.debug.print("T{d}={d:4.2}x ", .{ nt, @as(f64, @floatFromInt(t_ser)) / @as(f64, @floatFromInt(t_par)) });
        }
        std.debug.print("(identical)\n", .{});
    }
    std.debug.print("\n", .{});

    // ── B: single-query top-k, WITH a tie-heavy fixture ──
    for ([_][2]usize{ .{ 100_000, 16 }, .{ 500_000, 16 }, .{ 100_000, 128 } }) |cfg| {
        const n = cfg[0];
        const d = cfg[1];
        const k = 10;
        const pts = try alloc.alloc(f64, n * d);
        defer alloc.free(pts);
        var seed: u64 = 9;
        // Quantized coordinates so EQUAL DISTANCES actually occur -- the tie
        // path must be exercised, not assumed away by continuous data.
        for (pts) |*v| {
            seed = seed *% 6364136223846793005 +% 1442695040888963407;
            v.* = @as(f64, @floatFromInt((seed >> 33) % 8));
        }
        const q = try alloc.alloc(f64, d);
        defer alloc.free(q);
        for (q) |*v| v.* = 3.0;

        var idx_s: [10]i32 = undefined;
        var dist_s: [10]f64 = undefined;
        var t_ser: u64 = std.math.maxInt(u64);
        var have_s: usize = 0;
        for (0..REPS) |_| {
            timer.reset();
            have_s = topKSerial(pts, n, d, q, k, &idx_s, &dist_s);
            std.mem.doNotOptimizeAway(&have_s);
            t_ser = @min(t_ser, timer.read());
        }
        std.debug.print("topk n={d:>7} d={d:>3}: serial {d:7.2} ms  ", .{ n, d, ms(t_ser) });

        for ([_]usize{ 4, 8 }) |nt| {
            var jobs: [12]ChunkJob = undefined;
            var ths: [12]std.Thread = undefined;
            var li: [12][10]i32 = undefined;
            var ld: [12][10]f64 = undefined;
            var idx_m: [10]i32 = undefined;
            var dist_m: [10]f64 = undefined;
            var have_m: usize = 0;
            var t_par: u64 = std.math.maxInt(u64);
            for (0..REPS) |_| {
                timer.reset();
                const rows = n / nt;
                for (0..nt) |t| {
                    const lo = t * rows;
                    const hi = if (t == nt - 1) n else lo + rows;
                    jobs[t] = .{ .points = pts[lo * d .. hi * d], .d = d, .query = q, .k = k, .base = lo, .out_idx = &li[t], .out_dist = &ld[t] };
                    ths[t] = try std.Thread.spawn(.{}, ChunkJob.run, .{&jobs[t]});
                }
                for (ths[0..nt]) |th| th.join();
                have_m = mergeTopK(jobs[0..nt], k, &idx_m, &dist_m);
                std.mem.doNotOptimizeAway(&have_m);
                t_par = @min(t_par, timer.read());
            }
            if (have_m != have_s) return error.HaveMismatch;
            for (idx_m[0..have_m], idx_s[0..have_s]) |a2, b2| if (a2 != b2) return error.TopkIdxMismatch;
            for (dist_m[0..have_m], dist_s[0..have_s]) |a2, b2| if (a2 != b2) return error.TopkDistMismatch;
            std.debug.print("T{d}={d:4.2}x ", .{ nt, @as(f64, @floatFromInt(t_ser)) / @as(f64, @floatFromInt(t_par)) });
        }
        std.debug.print("(identical, ties included)\n", .{});
    }
}
