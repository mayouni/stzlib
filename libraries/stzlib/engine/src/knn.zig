//! K-NEAREST-NEIGHBOUR CLASSIFICATION -- the whole operation, engine-side.
//!
//! ── WHY THE VOTE LIVES HERE AND NOT IN THE HOST ──
//!
//! The engine already answered "which examples are nearest". That is HALF an
//! operation: every host language then had to write the same loop -- map neighbours to
//! labels, tally them, break the tie, report the winner. Ring wrote it, and a Python
//! or C or JS face over this engine would each have to write it again, differently,
//! with its own bugs and its own tie rule.
//!
//! So a classifier is not a search plus host code. `classify` takes a query and
//! returns A VERDICT: the winning label code, how many of the k voted for it, and the
//! neighbours it reasoned from. A host binds arguments and reads a result. Nothing
//! about the decision is left for it to implement.
//!
//! This also happened to be where the time went. Measured on 20000 examples x 16
//! features, k = 5: the engine's search cost 0.09 ms and the host's post-processing
//! cost 0.89 ms -- ninety percent of the query was the interpreter finishing a job
//! the engine had left half done. Moving the vote here is the fix for both problems
//! at once, and only one of them was a performance problem.
//!
//! ── CODES, NOT STRINGS ──
//!
//! Labels cross as small integers, the same convention tree.zig's ID3 uses. Interning
//! is a marshalling concern -- every host already walks its labels once when it loads
//! a training set -- while comparing and tallying them is the algorithm, and that is
//! what lives here. It also keeps this file free of any string handling, so no host's
//! text representation leaks into the engine.
//!
//! ── EXACT OR APPROXIMATE, ONE DOOR ──
//!
//! A model is built exact or approximate and answers the same call either way, so a
//! host does not branch on it. Exact is a full scan (cluster.topK); approximate walks
//! the projection forest in ann.zig. See stzKnn's notes for why that is a decision
//! the caller makes rather than a size threshold: the forest must be built before it
//! answers anything, and only the caller knows how many queries will follow.

const std = @import("std");
const cluster = @import("cluster.zig");
const ann = @import("ann.zig");

pub const KnnError = error{ OutOfMemory, BadShape };

pub const Model = struct {
    alloc: std.mem.Allocator,
    /// row-major n * d, owned
    data: []f64,
    n: usize,
    d: usize,
    /// label code per example, owned
    codes: []u32,
    n_labels: usize,
    /// present only for an approximate model
    index: ?*ann.Index,

    pub fn deinit(self: *Model) void {
        if (self.index) |ix| ix.deinit();
        self.alloc.free(self.codes);
        self.alloc.free(self.data);
        self.alloc.destroy(self);
    }
};

/// One classification: the verdict and the reasoning behind it.
pub const Verdict = struct {
    /// winning label code
    code: u32,
    /// how many of the k neighbours carried it
    votes: u32,
    /// how many neighbours were actually consulted (min(k, n))
    used: usize,
};

pub fn modelNew(
    alloc: std.mem.Allocator,
    points: []const f64,
    n: usize,
    d: usize,
    codes: []const u32,
    n_labels: usize,
    approximate: bool,
    trees: usize,
    seed: u64,
) !*Model {
    if (n == 0 or d == 0 or points.len != n * d or codes.len != n or n_labels == 0) {
        return KnnError.BadShape;
    }
    const self = try alloc.create(Model);
    errdefer alloc.destroy(self);

    const data = try alloc.alloc(f64, n * d);
    errdefer alloc.free(data);
    @memcpy(data, points);

    const cp = try alloc.alloc(u32, n);
    errdefer alloc.free(cp);
    @memcpy(cp, codes);

    var index: ?*ann.Index = null;
    if (approximate) {
        index = try ann.build(alloc, data, n, d, trees, false, seed);
    }

    self.* = .{
        .alloc = alloc,
        .data = data,
        .n = n,
        .d = d,
        .codes = cp,
        .n_labels = n_labels,
        .index = index,
    };
    return self;
}

fn row(m: *const Model, i: usize) []const f64 {
    return m.data[i * m.d .. (i + 1) * m.d];
}

/// THE COMPLETE OPERATION: nearest neighbours, then the vote, then the verdict.
///
/// `out_idx`, `out_dist` and `out_code` receive the neighbours consulted (nearest
/// first) so a host can explain the decision without recomputing anything; they must
/// each hold at least min(k, n) entries.
pub fn classify(
    m: *Model,
    alloc: std.mem.Allocator,
    query: []const f64,
    k: usize,
    budget: usize,
    out_idx: []u32,
    out_dist: []f64,
    out_code: []u32,
) !Verdict {
    if (query.len != m.d or k == 0) return KnnError.BadShape;
    const take = @min(k, m.n);
    if (out_idx.len < take or out_dist.len < take or out_code.len < take) {
        return KnnError.BadShape;
    }

    if (m.index) |ix| {
        const got = try ann.search(ix, alloc, query, take, budget, out_idx, out_dist);
        // ann reports SQUARED euclidean; this module's contract is the true distance,
        // so the host sees the same number whichever path produced it
        for (0..got) |t| out_dist[t] = @sqrt(out_dist[t]);
        for (0..got) |t| out_code[t] = m.codes[out_idx[t]];
        return tally(m, out_code[0..got], got);
    }

    // exact: cluster.topK returns 1-BASED indices, because it was written for Ring.
    // Normalising to 0-based here means the two paths hand a host identical output and
    // no binding has to know which one ran.
    const tmp = try alloc.alloc(i32, take);
    defer alloc.free(tmp);
    const got = cluster.topK(m.data, m.n, m.d, query, take, tmp, out_dist);
    for (0..got) |t| {
        out_idx[t] = @intCast(tmp[t] - 1);
        out_code[t] = m.codes[out_idx[t]];
    }
    return tally(m, out_code[0..got], got);
}

/// The majority vote.
///
/// THE TIE RULE IS PART OF THE CONTRACT, so it is stated once here rather than
/// reinvented per host: on an equal count the SMALLEST label code wins. Codes are
/// assigned in first-appearance order by the host, so that resolves a tie in favour
/// of the label seen first in the training set -- which is what the Ring
/// implementation did with a stable scan, and now every binding inherits it.
fn tally(m: *Model, codes: []const u32, used: usize) Verdict {
    if (used == 0) return .{ .code = 0, .votes = 0, .used = 0 };

    // n_labels is small (it is a label alphabet), so a direct count beats any map
    var counts = [_]u32{0} ** 256;
    var overflow: bool = false;
    for (codes) |c| {
        if (c < counts.len) counts[c] += 1 else overflow = true;
    }

    if (!overflow) {
        var best: u32 = 0;
        var bestn: u32 = 0;
        var i: usize = 0;
        while (i < @min(counts.len, m.n_labels)) : (i += 1) {
            if (counts[i] > bestn) {
                bestn = counts[i];
                best = @intCast(i);
            }
        }
        return .{ .code = best, .votes = bestn, .used = used };
    }

    // a label alphabet past 256: fall back to counting each candidate directly, still
    // smallest-code-wins, so the answer does not depend on which branch ran
    var best: u32 = codes[0];
    var bestn: u32 = 0;
    for (codes) |c| {
        var cn: u32 = 0;
        for (codes) |o| {
            if (o == c) cn += 1;
        }
        if (cn > bestn or (cn == bestn and c < best)) {
            bestn = cn;
            best = c;
        }
    }
    return .{ .code = best, .votes = bestn, .used = used };
}

/// AGREEMENT BETWEEN AN APPROXIMATE MODEL AND EXACT SEARCH, over many queries.
///
/// Measuring the cost of approximation is not a benchmark script -- it is the only
/// way a caller can decide whether to accept it, so it belongs to the engine and
/// every binding gets it. And for a CLASSIFIER the honest measure is not how many
/// neighbours the forest missed but how often the LABEL still came out the same: a
/// majority vote absorbs a swapped neighbour that a recall figure counts as a loss.
///
/// `queries` is row-major nq * d. Returns the fraction in [0, 1].
pub fn agreementWithExact(
    m: *Model,
    alloc: std.mem.Allocator,
    queries: []const f64,
    nq: usize,
    k: usize,
    budget: usize,
) !f64 {
    if (nq == 0 or queries.len != nq * m.d) return KnnError.BadShape;
    const take = @min(k, m.n);

    const ai = try alloc.alloc(u32, take);
    defer alloc.free(ai);
    const ad = try alloc.alloc(f64, take);
    defer alloc.free(ad);
    const ac = try alloc.alloc(u32, take);
    defer alloc.free(ac);

    // the exact comparison runs against the SAME vectors, with the index bypassed --
    // no second model, so no chance of the two disagreeing about the data
    const saved = m.index;
    var same: usize = 0;
    var q: usize = 0;
    while (q < nq) : (q += 1) {
        const query = queries[q * m.d .. (q + 1) * m.d];
        m.index = saved;
        const va = try classify(m, alloc, query, take, budget, ai, ad, ac);
        m.index = null;
        const ve = try classify(m, alloc, query, take, budget, ai, ad, ac);
        if (va.code == ve.code) same += 1;
    }
    m.index = saved;
    return @as(f64, @floatFromInt(same)) / @as(f64, @floatFromInt(nq));
}

// ── tests ────────────────────────────────────────────────────────────────────

const testing = std.testing;

fn twoClusters(alloc: std.mem.Allocator, per: usize) !struct { x: []f64, c: []u32 } {
    const n = per * 2;
    const x = try alloc.alloc(f64, n * 2);
    const c = try alloc.alloc(u32, n);
    var prng = std.Random.DefaultPrng.init(99);
    const r = prng.random();
    for (0..per) |i| {
        x[i * 4 + 0] = r.float(f64);
        x[i * 4 + 1] = r.float(f64);
        c[i * 2 + 0] = 0; // "low"
        x[i * 4 + 2] = 5.0 + r.float(f64);
        x[i * 4 + 3] = 5.0 + r.float(f64);
        c[i * 2 + 1] = 1; // "high"
    }
    return .{ .x = x, .c = c };
}

test "the verdict is the whole answer: winner, count and the neighbours behind it" {
    const alloc = testing.allocator;
    const set = try twoClusters(alloc, 150);
    defer alloc.free(set.x);
    defer alloc.free(set.c);

    var m = try modelNew(alloc, set.x, 300, 2, set.c, 2, false, 0, 0);
    defer m.deinit();

    var idx = [_]u32{0} ** 5;
    var dst = [_]f64{0} ** 5;
    var cod = [_]u32{0} ** 5;

    const v = try classify(m, alloc, &[_]f64{ 0.5, 0.5 }, 5, 0, &idx, &dst, &cod);
    try testing.expectEqual(@as(u32, 0), v.code); // the low cluster
    try testing.expectEqual(@as(usize, 5), v.used);
    try testing.expect(v.votes >= 3); // a majority of five

    // the neighbours are returned so a host can explain the decision without
    // recomputing anything -- distances ascending, TRUE not squared, codes matching
    for (0..v.used) |i| {
        try testing.expect(idx[i] < 300);
        try testing.expectEqual(m.codes[idx[i]], cod[i]);
        if (i > 0) try testing.expect(dst[i] >= dst[i - 1]);
    }
    // and the distance really is the euclidean one, not its square
    const want = @sqrt(std.math.pow(f64, m.data[idx[0] * 2] - 0.5, 2) +
        std.math.pow(f64, m.data[idx[0] * 2 + 1] - 0.5, 2));
    try testing.expectApproxEqAbs(want, dst[0], 1e-12);

    const v2 = try classify(m, alloc, &[_]f64{ 5.5, 5.5 }, 5, 0, &idx, &dst, &cod);
    try testing.expectEqual(@as(u32, 1), v2.code); // the high cluster
}

test "exact and approximate answer the same call, and their output is shaped alike" {
    const alloc = testing.allocator;
    const set = try twoClusters(alloc, 400);
    defer alloc.free(set.x);
    defer alloc.free(set.c);

    var exact = try modelNew(alloc, set.x, 800, 2, set.c, 2, false, 0, 0);
    defer exact.deinit();
    var appr = try modelNew(alloc, set.x, 800, 2, set.c, 2, true, 24, 42);
    defer appr.deinit();

    var exI = [_]u32{0} ** 5;
    var exD = [_]f64{0} ** 5;
    var exC = [_]u32{0} ** 5;
    var apI = [_]u32{0} ** 5;
    var apD = [_]f64{0} ** 5;
    var apC = [_]u32{0} ** 5;

    const q = [_]f64{ 0.4, 0.6 };
    const ve = try classify(exact, alloc, &q, 5, 0, &exI, &exD, &exC);
    const va = try classify(appr, alloc, &q, 5, 0, &apI, &apD, &apC);

    try testing.expectEqual(ve.code, va.code);
    try testing.expectEqual(ve.used, va.used);
    // INDEXES ARE 0-BASED FROM BOTH PATHS even though cluster.topK is 1-based
    // internally, so no binding has to know which path ran
    for (0..ve.used) |t| {
        try testing.expect(exI[t] < 800);
        try testing.expect(apI[t] < 800);
    }
}

test "the tie rule is fixed: on an equal count the smallest code wins" {
    const alloc = testing.allocator;
    // four points, two of each label, all equidistant from the origin along the axes
    const x = [_]f64{ 1, 0, -1, 0, 0, 1, 0, -1 };
    const c = [_]u32{ 1, 1, 0, 0 };
    var m = try modelNew(alloc, &x, 4, 2, &c, 2, false, 0, 0);
    defer m.deinit();

    var idx = [_]u32{0} ** 4;
    var dst = [_]f64{0} ** 4;
    var cod = [_]u32{0} ** 4;
    const v = try classify(m, alloc, &[_]f64{ 0, 0 }, 4, 0, &idx, &dst, &cod);

    // two votes each, so the rule decides -- and it must be STATED, because a host
    // reinventing the vote would pick whichever its scan happened to see first
    try testing.expectEqual(@as(u32, 2), v.votes);
    try testing.expectEqual(@as(u32, 0), v.code);
}

test "agreement between approximate and exact is measured HERE, not by the host" {
    const alloc = testing.allocator;
    const set = try twoClusters(alloc, 500);
    defer alloc.free(set.x);
    defer alloc.free(set.c);

    var m = try modelNew(alloc, set.x, 1000, 2, set.c, 2, true, 24, 7);
    defer m.deinit();

    // queries across both clusters AND the gap between them, so agreement is not
    // measured only where the answer is obvious
    const nq = 40;
    const qs = try alloc.alloc(f64, nq * 2);
    defer alloc.free(qs);
    var prng = std.Random.DefaultPrng.init(4242);
    const r = prng.random();
    for (0..nq) |i| {
        qs[i * 2] = r.float(f64) * 6.0;
        qs[i * 2 + 1] = r.float(f64) * 6.0;
    }

    const agree = try agreementWithExact(m, alloc, qs, nq, 5, 0);
    try testing.expect(agree > 0.9);

    // and measuring must LEAVE THE MODEL APPROXIMATE -- it toggles the index
    // internally, so a bug there would silently turn the model exact
    try testing.expect(m.index != null);
}

test "the awkward shapes are refused rather than half-answered" {
    const alloc = testing.allocator;
    const x = [_]f64{ 1, 2, 3, 4 };
    const c = [_]u32{ 0, 1 };

    // codes must match the row count
    try testing.expectError(KnnError.BadShape, modelNew(alloc, &x, 2, 2, c[0..1], 2, false, 0, 0));
    // points must match n * d
    try testing.expectError(KnnError.BadShape, modelNew(alloc, &x, 3, 2, &c, 2, false, 0, 0));
    // an empty label alphabet is not a classifier
    try testing.expectError(KnnError.BadShape, modelNew(alloc, &x, 2, 2, &c, 0, false, 0, 0));

    var m = try modelNew(alloc, &x, 2, 2, &c, 2, false, 0, 0);
    defer m.deinit();
    var idx = [_]u32{0} ** 5;
    var dst = [_]f64{0} ** 5;
    var cod = [_]u32{0} ** 5;

    // k larger than the corpus gives what exists
    const v = try classify(m, alloc, &[_]f64{ 1, 2 }, 5, 0, &idx, &dst, &cod);
    try testing.expectEqual(@as(usize, 2), v.used);

    // a query of the wrong width is refused
    try testing.expectError(
        KnnError.BadShape,
        classify(m, alloc, &[_]f64{1}, 2, 0, &idx, &dst, &cod),
    );
}
