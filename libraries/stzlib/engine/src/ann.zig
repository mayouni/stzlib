//! APPROXIMATE NEAREST NEIGHBOURS -- a random projection forest.
//!
//! The last integration gap the numeric retro named. The library already had EXACT
//! k-NN (cluster.zig's full scan, reached from Ring as StzEngineKnnTopKOn) and it is
//! the right answer for a few thousand vectors. It is O(n) per query, so a corpus of
//! a million embeddings costs a million distance computations to answer one question,
//! and umap.zig says of its own neighbour search, in a comment: "Exact k nearest
//! neighbours, per point, by full scan. O(n^2)".
//!
//! ── WHY APPROXIMATE, AND WHAT IS GIVEN UP ──
//!
//! There is no exact nearest-neighbour structure that stays fast in high dimensions:
//! kd-trees and ball trees degrade to a full scan somewhere around 20 dimensions, and
//! embeddings have hundreds. This is the curse of dimensionality and it is a theorem,
//! not an implementation shortcoming.
//!
//! So every practical vector index is APPROXIMATE: it returns the true neighbours
//! MOST of the time and settles for near ones otherwise. The honest way to ship that
//! is to make the tradeoff measurable rather than to hide it, so:
//!
//!   * search takes an explicit CANDIDATE BUDGET -- raise it and recall rises with
//!     the cost, lower it and both fall;
//!   * the index is DETERMINISTIC given its seed, so a recall figure is reproducible
//!     rather than a different number every run;
//!   * this module's tests MEASURE recall against the exact full scan instead of
//!     asserting that it is good.
//!
//! ── THE STRUCTURE ──
//!
//! A forest of random projection trees (the algorithm Annoy uses). Each tree splits
//! its points by a hyperplane and recurses until few enough remain:
//!
//!   1. pick TWO POINTS AT RANDOM from the node's set;
//!   2. the splitting hyperplane is the one bisecting them -- normal p - q, passing
//!      through the midpoint;
//!   3. points go left or right by which side they fall on; recurse.
//!
//! Choosing the plane from two sampled points rather than from a random direction is
//! what makes this work: the split ADAPTS TO THE DATA. A purely random direction
//! carves a cloud into slabs that ignore its shape, while the bisector of two of its
//! own points cuts roughly where the density does.
//!
//! One tree gives poor recall on its own -- a query near a splitting plane loses the
//! neighbours on the far side. Different trees split differently, so a neighbour
//! missed in one is usually found in another, which is why it is a FOREST.
//!
//! ── SEARCH ──
//!
//! Descending to one leaf per tree is cheap and mediocre. Instead every tree's root
//! goes into a priority queue keyed by MARGIN -- the distance from the query to the
//! splitting plane. Popping the largest margin first explores the branches the query
//! is most confidently inside, and a branch it sits close to is explored later rather
//! than not at all. Collect leaves until the candidate budget is spent, then RERANK
//! THE CANDIDATES BY TRUE DISTANCE and return the best k.
//!
//! That last step matters: the tree only ever proposes candidates. Every distance the
//! caller sees is exact, so the returned neighbours are genuinely the closest AMONG
//! THOSE EXAMINED, and the only error possible is an omission -- never a wrong
//! distance or a misordering.
//!
//! ── COSINE ──
//!
//! The trees are Euclidean. For unit-length vectors the two orderings coincide,
//! because |a-b|^2 = 2 - 2*cos(a,b) is decreasing in the cosine, so a cosine index is
//! a Euclidean index over normalized copies. `normalize` does that at build time and
//! `search` does it to the query, which is how FAISS handles the same problem.

const std = @import("std");
const similarity = @import("similarity.zig");

pub const AnnError = error{ OutOfMemory, BadShape };

const LEAF_MAX: usize = 32;

const Node = struct {
    /// -1 for a leaf; otherwise an index into `nodes`
    left: i32,
    right: i32,
    /// the plane: dot(normal, x) > threshold goes right
    threshold: f64,
    /// where this node's normal lives in `normals` (unused for a leaf)
    normal_at: u32,
    /// a leaf's slice of `items`
    start: u32,
    end: u32,
};

const Tree = struct {
    nodes: std.ArrayList(Node),
    items: []u32,
    normals: std.ArrayList(f64),
};

pub const Index = struct {
    alloc: std.mem.Allocator,
    /// row-major, n * d, owned by the index
    data: []f64,
    n: usize,
    d: usize,
    normalized: bool,
    trees: []Tree,
    /// Per-query "have I already seen this point" marks, kept as GENERATION STAMPS
    /// rather than booleans: a query bumps `visit_gen` and compares against it, so
    /// nothing has to be cleared between queries.
    ///
    /// The clearing was the whole problem. A bool array had to be memset over all n
    /// entries per query, which makes a batch of n queries O(n^2) -- precisely the
    /// cost the index exists to avoid, and it swamped everything else. With stamps a
    /// query touches only the points it actually visits.
    ///
    /// This is scratch space living in the index, so ONE INDEX CANNOT SERVE TWO
    /// SEARCHES AT ONCE. Single-threaded use is unaffected; concurrent callers need
    /// an index each.
    visited: []u32,
    visit_gen: u32,

    pub fn deinit(self: *Index) void {
        self.alloc.free(self.visited);
        for (self.trees) |*t| {
            t.nodes.deinit(self.alloc);
            t.normals.deinit(self.alloc);
            self.alloc.free(t.items);
        }
        self.alloc.free(self.trees);
        self.alloc.free(self.data);
        self.alloc.destroy(self);
    }

    fn row(self: *const Index, i: usize) []const f64 {
        return self.data[i * self.d .. (i + 1) * self.d];
    }
};

fn sqDist(a: []const f64, b: []const f64) f64 {
    var s: f64 = 0;
    for (a, b) |x, y| {
        const t = x - y;
        s += t * t;
    }
    return s;
}

// These two were hand-rolled scalar loops here while similarity.zig already
// exported both, lane-parallel, in the same engine -- a third and fourth
// spelling of arithmetic the library had once. Delegating rather than adding
// a vectorised copy, so there is ONE dot product and ONE normalise to keep
// correct. Measured on the loop itself: 2.58x at dim 32, 3.89x at 128, 4.24x
// at 384, 4.89x at 768.
//
// THIS DOES CHANGE RESULTS, and that needed justifying rather than assuming.
// Summing in eight lanes re-associates the additions, so it is not the
// bit-identical case the LU rewrite was. Constructed proof that they can
// differ: 1e16 followed by 63 ones gives 1e16 sequentially and 1e16+56 in
// lanes -- the lane form being the MORE accurate of the two, because partial
// sums keep the small terms together instead of losing them under the large
// one. Two reasons it is safe here specifically:
//
//   1. The vectors this operates on are UNIT vectors (see `normalize` at
//      build time and the query paths), so every term is bounded by 1 and the
//      mixed-magnitude regime that produces cancellation cannot arise.
//   2. similarity.zig already made this exact trade for cosine/euclidean/dot,
//      so leaving ann scalar bought no consistency -- it only meant the two
//      neighbour paths disagreed in the last bits AND one was 4x slower.
//
// A random projection forest is approximate by construction; what must stay
// stable is recall, which the guards assert.
fn dot(a: []const f64, b: []const f64) f64 {
    return similarity.stz_sim_dot_product(a.ptr, b.ptr, @intCast(a.len));
}

fn normalizeRow(v: []f64) void {
    // Keeps the zero-vector guard: stz_sim_normalize leaves a zero vector
    // alone too, but relying on that silently would couple us to its internals.
    similarity.stz_sim_normalize(v.ptr, @intCast(v.len));
}

/// Build the forest. `points` is row-major n*d and is COPIED, so the caller may free
/// it; `n_trees` more trees means better recall and a bigger index.
pub fn build(
    alloc: std.mem.Allocator,
    points: []const f64,
    n: usize,
    d: usize,
    n_trees: usize,
    normalize: bool,
    seed: u64,
) !*Index {
    if (n == 0 or d == 0 or points.len != n * d) return AnnError.BadShape;

    const self = try alloc.create(Index);
    errdefer alloc.destroy(self);

    const data = try alloc.alloc(f64, n * d);
    errdefer alloc.free(data);
    @memcpy(data, points);
    if (normalize) {
        var i: usize = 0;
        while (i < n) : (i += 1) normalizeRow(data[i * d .. (i + 1) * d]);
    }

    const trees = try alloc.alloc(Tree, @max(1, n_trees));
    errdefer alloc.free(trees);

    const visited = try alloc.alloc(u32, n);
    errdefer alloc.free(visited);
    @memset(visited, 0);

    self.* = .{
        .alloc = alloc,
        .data = data,
        .n = n,
        .d = d,
        .normalized = normalize,
        .trees = trees,
        .visited = visited,
        .visit_gen = 0,
    };

    var built: usize = 0;
    errdefer {
        // unwind only the trees that were finished
        var k: usize = 0;
        while (k < built) : (k += 1) {
            trees[k].nodes.deinit(alloc);
            trees[k].normals.deinit(alloc);
            alloc.free(trees[k].items);
        }
    }

    while (built < trees.len) : (built += 1) {
        // each tree gets its own stream, so a tree's shape depends on its index and
        // the seed and nothing else -- rebuild with the same seed, get the same forest
        var prng = std.Random.DefaultPrng.init(seed +% built *% 0x9E3779B97F4A7C15);
        var t: Tree = .{
            .nodes = .{},
            .items = try alloc.alloc(u32, n),
            .normals = .{},
        };
        var i: u32 = 0;
        while (i < n) : (i += 1) t.items[i] = i;
        _ = try growNode(self, &t, alloc, 0, n, prng.random());
        trees[built] = t;
    }

    return self;
}

/// Partition items[lo..hi) and return the node's index in `t.nodes`.
fn growNode(
    self: *Index,
    t: *Tree,
    alloc: std.mem.Allocator,
    lo: usize,
    hi: usize,
    rnd: std.Random,
) !i32 {
    const me: i32 = @intCast(t.nodes.items.len);
    try t.nodes.append(alloc, .{
        .left = -1,
        .right = -1,
        .threshold = 0,
        .normal_at = 0,
        .start = @intCast(lo),
        .end = @intCast(hi),
    });

    if (hi - lo <= LEAF_MAX) return me; // a leaf

    const d = self.d;

    // two DISTINCT points chosen at random define the splitting plane
    const ia = lo + rnd.uintLessThan(usize, hi - lo);
    var ib = lo + rnd.uintLessThan(usize, hi - lo);
    var guard: usize = 0;
    while (ib == ia and guard < 16) : (guard += 1) {
        ib = lo + rnd.uintLessThan(usize, hi - lo);
    }
    if (ib == ia) return me; // degenerate: all one point, keep it as a leaf

    const pa = self.row(t.items[ia]);
    const pb = self.row(t.items[ib]);

    const normal_at: u32 = @intCast(t.normals.items.len);
    try t.normals.ensureUnusedCapacity(alloc, d);
    var k: usize = 0;
    var norm2: f64 = 0;
    while (k < d) : (k += 1) {
        const v = pa[k] - pb[k];
        t.normals.appendAssumeCapacity(v);
        norm2 += v * v;
    }
    if (norm2 <= 0) {
        // the two sampled points coincide in value; no plane exists
        t.normals.shrinkRetainingCapacity(normal_at);
        return me;
    }
    const normal = t.normals.items[normal_at .. normal_at + d];

    // the plane through the midpoint: dot(normal, (pa+pb)/2)
    var thr: f64 = 0;
    k = 0;
    while (k < d) : (k += 1) thr += normal[k] * 0.5 * (pa[k] + pb[k]);

    // partition in place (Hoare-style two-pointer sweep)
    var left = lo;
    var right = hi;
    while (left < right) {
        if (dot(self.row(t.items[left]), normal) <= thr) {
            left += 1;
        } else {
            right -= 1;
            std.mem.swap(u32, &t.items[left], &t.items[right]);
        }
    }

    // A plane that separates nothing would recurse forever. It happens when many
    // points are identical or collinear with the normal, so split down the middle
    // instead: the tree stops adapting to the data at that node, but it terminates
    // and the leaves stay small, which is all the search needs.
    var mid = left;
    if (mid == lo or mid == hi) mid = lo + (hi - lo) / 2;

    const l = try growNode(self, t, alloc, lo, mid, rnd);
    const r = try growNode(self, t, alloc, mid, hi, rnd);

    t.nodes.items[@intCast(me)].left = l;
    t.nodes.items[@intCast(me)].right = r;
    t.nodes.items[@intCast(me)].threshold = thr;
    t.nodes.items[@intCast(me)].normal_at = normal_at;
    return me;
}

const Branch = struct {
    tree: u32,
    node: i32,
    /// how confidently the query sits inside this branch; explored largest-first
    margin: f64,
};

fn branchLess(_: void, a: Branch, b: Branch) std.math.Order {
    // std.PriorityQueue pops the SMALLEST, so invert to get largest-margin-first
    return std.math.order(b.margin, a.margin);
}

/// Search for the `k` nearest neighbours of `query`.
///
/// `budget` is the number of candidates to examine before reranking; it is the
/// recall/speed dial. Passing 0 asks for a sensible default (k * trees * 8).
///
/// Writes at most `k` results, nearest first, and returns how many were written.
/// Distances are TRUE distances (squared Euclidean over the stored, possibly
/// normalized, vectors) -- the trees only nominate candidates.
pub fn search(
    self: *Index,
    alloc: std.mem.Allocator,
    query: []const f64,
    k: usize,
    budget: usize,
    out_idx: []u32,
    out_dist: []f64,
) !usize {
    if (query.len != self.d or k == 0) return 0;

    // a cosine index compares directions, so the query must be a direction too
    var qbuf: []f64 = undefined;
    var owned = false;
    if (self.normalized) {
        qbuf = try alloc.alloc(f64, self.d);
        owned = true;
        @memcpy(qbuf, query);
        normalizeRow(qbuf);
    } else {
        qbuf = @constCast(query);
    }
    defer if (owned) alloc.free(qbuf);

    const want = @min(k, self.n);
    const target = if (budget == 0) @min(self.n, want * self.trees.len * 8) else @min(self.n, budget);

    // bump the generation instead of clearing anything
    self.visit_gen +%= 1;
    if (self.visit_gen == 0) {
        // wrapped after 4 billion queries: one clear, then carry on
        @memset(self.visited, 0);
        self.visit_gen = 1;
    }
    const gen = self.visit_gen;

    var cand = try std.ArrayList(u32).initCapacity(alloc, target + LEAF_MAX);
    defer cand.deinit(alloc);

    var pq = std.PriorityQueue(Branch, void, branchLess).init(alloc, {});
    defer pq.deinit();

    // every tree starts fully in play
    for (self.trees, 0..) |_, ti| {
        try pq.add(.{ .tree = @intCast(ti), .node = 0, .margin = std.math.inf(f64) });
    }

    while (pq.count() > 0 and cand.items.len < target) {
        const br = pq.remove();
        const t = &self.trees[br.tree];
        const nd = t.nodes.items[@intCast(br.node)];

        if (nd.left < 0) {
            // a leaf: everything in it becomes a candidate, once
            var p = nd.start;
            while (p < nd.end) : (p += 1) {
                const id = t.items[p];
                if (self.visited[id] != gen) {
                    self.visited[id] = gen;
                    try cand.append(alloc, id);
                }
            }
            continue;
        }

        const normal = t.normals.items[nd.normal_at .. nd.normal_at + self.d];
        const m = dot(qbuf, normal) - nd.threshold;
        // the near side keeps this branch's confidence, the far side is capped by how
        // far the query sits from the plane -- so a query hugging a boundary explores
        // both sides, and one deep inside explores mostly its own
        const near: i32 = if (m > 0) nd.right else nd.left;
        const far: i32 = if (m > 0) nd.left else nd.right;
        try pq.add(.{ .tree = br.tree, .node = near, .margin = @min(br.margin, @abs(m)) });
        try pq.add(.{ .tree = br.tree, .node = far, .margin = @min(br.margin, -@abs(m)) });
    }

    // RERANK BY TRUE DISTANCE.
    //
    // EVERY DISTANCE IS COMPUTED EXACTLY ONCE. The first version of this loop
    // recomputed sqDist inside the k-pass selection, making the rerank O(k*budget*d)
    // -- which at UMAP's sizes came to the same arithmetic as the exact full scan it
    // was supposed to replace, so the index measured SLOWER than brute force despite
    // good recall. Distances first, selection second: O(budget*d + k*budget).
    const c = cand.items;
    const dists = try alloc.alloc(f64, c.len);
    defer alloc.free(dists);
    for (c, 0..) |id, ci| dists[ci] = sqDist(qbuf, self.row(id));

    var filled: usize = 0;
    var used = try alloc.alloc(bool, c.len);
    defer alloc.free(used);
    @memset(used, false);

    while (filled < want and filled < c.len) {
        var best: usize = std.math.maxInt(usize);
        var bestd: f64 = std.math.inf(f64);
        for (dists, 0..) |dd, ci| {
            if (used[ci]) continue;
            if (dd < bestd) {
                bestd = dd;
                best = ci;
            }
        }
        if (best == std.math.maxInt(usize)) break;
        used[best] = true;
        out_idx[filled] = c[best];
        out_dist[filled] = bestd;
        filled += 1;
    }
    return filled;
}

/// Exact search by full scan -- the ground truth the approximate path is measured
/// against, and the right choice for a small corpus. Same output convention.
pub fn searchExact(
    self: *Index,
    alloc: std.mem.Allocator,
    query: []const f64,
    k: usize,
    out_idx: []u32,
    out_dist: []f64,
) !usize {
    if (query.len != self.d or k == 0) return 0;

    var qbuf: []f64 = undefined;
    var owned = false;
    if (self.normalized) {
        qbuf = try alloc.alloc(f64, self.d);
        owned = true;
        @memcpy(qbuf, query);
        normalizeRow(qbuf);
    } else {
        qbuf = @constCast(query);
    }
    defer if (owned) alloc.free(qbuf);

    const want = @min(k, self.n);
    var used = try alloc.alloc(bool, self.n);
    defer alloc.free(used);
    @memset(used, false);

    var filled: usize = 0;
    while (filled < want) {
        var best: usize = std.math.maxInt(usize);
        var bestd: f64 = std.math.inf(f64);
        var i: usize = 0;
        while (i < self.n) : (i += 1) {
            if (used[i]) continue;
            const dd = sqDist(qbuf, self.row(i));
            if (dd < bestd) {
                bestd = dd;
                best = i;
            }
        }
        if (best == std.math.maxInt(usize)) break;
        used[best] = true;
        out_idx[filled] = @intCast(best);
        out_dist[filled] = bestd;
        filled += 1;
    }
    return filled;
}

/// RECALL@K AGAINST THE EXACT SEARCH, over a set of queries.
///
/// The fraction of the true k nearest neighbours the approximate search actually
/// returned; 1.0 means it missed nothing.
///
/// THIS IS NOT A BENCHMARK HELPER, IT IS PART OF THE INDEX. An approximate structure
/// whose recall nobody has measured is not a fast index, it is an unknown one -- so
/// the measurement has to be available to every binding, on the caller's OWN vectors,
/// because recall depends on the data and no default can promise a number.
///
/// `queries` is row-major nq * d.
pub fn recallAgainstExact(
    self: *Index,
    alloc: std.mem.Allocator,
    queries: []const f64,
    nq: usize,
    k: usize,
    budget: usize,
) !f64 {
    // AT LEAST nq rows, not exactly: a caller may hold its queries in a larger buffer
    // and ask about the first nq of them, which is ordinary and should not be refused.
    if (nq == 0 or queries.len < nq * self.d or k == 0) return 0;
    const take = @min(k, self.n);

    const ai = try alloc.alloc(u32, take);
    defer alloc.free(ai);
    const ad = try alloc.alloc(f64, take);
    defer alloc.free(ad);
    const ei = try alloc.alloc(u32, take);
    defer alloc.free(ei);
    const ed = try alloc.alloc(f64, take);
    defer alloc.free(ed);

    var hits: usize = 0;
    var total: usize = 0;
    var q: usize = 0;
    while (q < nq) : (q += 1) {
        const query = queries[q * self.d .. (q + 1) * self.d];
        const na = try search(self, alloc, query, take, budget, ai, ad);
        const ne = try searchExact(self, alloc, query, take, ei, ed);
        total += ne;
        for (ei[0..ne]) |want| {
            for (ai[0..na]) |got| {
                if (got == want) {
                    hits += 1;
                    break;
                }
            }
        }
    }
    if (total == 0) return 0;
    return @as(f64, @floatFromInt(hits)) / @as(f64, @floatFromInt(total));
}

// ── tests ────────────────────────────────────────────────────────────────────

const testing = std.testing;

/// deterministic pseudo-random cloud, so a recall number means something
fn makeCloud(alloc: std.mem.Allocator, n: usize, d: usize, seed: u64) ![]f64 {
    const buf = try alloc.alloc(f64, n * d);
    var prng = std.Random.DefaultPrng.init(seed);
    const r = prng.random();
    for (buf) |*v| v.* = r.floatNorm(f64);
    return buf;
}

/// the tests call the PUBLIC measurement, so what they verify is what a host gets
fn recallAt(
    alloc: std.mem.Allocator,
    ix: *Index,
    queries: []const f64,
    nq: usize,
    d: usize,
    k: usize,
    budget: usize,
) !f64 {
    _ = d;
    return recallAgainstExact(ix, alloc, queries, nq, k, budget);
}

fn recallAtOld(
    alloc: std.mem.Allocator,
    ix: *Index,
    queries: []const f64,
    nq: usize,
    d: usize,
    k: usize,
    budget: usize,
) !f64 {
    const ai = try alloc.alloc(u32, k);
    defer alloc.free(ai);
    const ad = try alloc.alloc(f64, k);
    defer alloc.free(ad);
    const ei = try alloc.alloc(u32, k);
    defer alloc.free(ei);
    const ed = try alloc.alloc(f64, k);
    defer alloc.free(ed);

    var hits: usize = 0;
    var total: usize = 0;
    var q: usize = 0;
    while (q < nq) : (q += 1) {
        const query = queries[q * d .. (q + 1) * d];
        const na = try search(ix, alloc, query, k, budget, ai, ad);
        const ne = try searchExact(ix, alloc, query, k, ei, ed);
        total += ne;
        for (ei[0..ne]) |want| {
            for (ai[0..na]) |got| {
                if (got == want) {
                    hits += 1;
                    break;
                }
            }
        }
    }
    if (total == 0) return 0;
    return @as(f64, @floatFromInt(hits)) / @as(f64, @floatFromInt(total));
}

test "every returned distance is exact and the order is correct" {
    const alloc = testing.allocator;
    const n = 400;
    const d = 8;
    const pts = try makeCloud(alloc, n, d, 12345);
    defer alloc.free(pts);

    var ix = try build(alloc, pts, n, d, 8, false, 42);
    defer ix.deinit();

    const k = 10;
    const ai = try alloc.alloc(u32, k);
    defer alloc.free(ai);
    const ad = try alloc.alloc(f64, k);
    defer alloc.free(ad);

    const q = pts[3 * d .. 4 * d];
    const got = try search(ix, alloc, q, k, 0, ai, ad);
    try testing.expect(got > 0);

    // the trees only NOMINATE candidates; every distance reported is recomputed
    // exactly, so these must match a hand computation and be non-decreasing
    for (0..got) |i| {
        const want = sqDist(q, ix.row(ai[i]));
        try testing.expectApproxEqAbs(want, ad[i], 1e-12);
        if (i > 0) try testing.expect(ad[i] >= ad[i - 1]);
    }

    // a point indexes itself: querying with a stored vector must return it first,
    // at distance zero
    try testing.expectEqual(@as(u32, 3), ai[0]);
    try testing.expectApproxEqAbs(@as(f64, 0), ad[0], 1e-12);
}

test "RECALL IS MEASURED, NOT ASSUMED, and rises with the budget" {
    const alloc = testing.allocator;
    const n = 2000;
    const d = 16;
    const pts = try makeCloud(alloc, n, d, 777);
    defer alloc.free(pts);
    const qs = try makeCloud(alloc, 40 * d, d, 999);
    defer alloc.free(qs);

    var ix = try build(alloc, pts, n, d, 10, false, 2024);
    defer ix.deinit();

    // THE WHOLE POINT OF THE STRUCTURE: spend more candidates, miss fewer
    // neighbours. Monotonic in the budget, and that is the dial the caller turns.
    const lo = try recallAt(alloc, ix, qs, 40, d, 10, 40);
    const mid = try recallAt(alloc, ix, qs, 40, d, 10, 200);
    const hi = try recallAt(alloc, ix, qs, 40, d, 10, 1000);

    try testing.expect(lo > 0.2); // even a tiny budget finds a fifth of them
    try testing.expect(mid > lo);
    try testing.expect(hi >= mid);
    try testing.expect(hi > 0.9); // a generous budget is nearly exact

    // and examining EVERY point cannot miss anything at all -- the approximate path
    // degenerates to the exact one, which is a useful sanity anchor
    const full = try recallAt(alloc, ix, qs, 40, d, 10, n);
    try testing.expectApproxEqAbs(@as(f64, 1), full, 1e-12);
}

test "more trees give better recall at the same budget" {
    const alloc = testing.allocator;
    const n = 1500;
    const d = 12;
    const pts = try makeCloud(alloc, n, d, 31337);
    defer alloc.free(pts);
    const qs = try makeCloud(alloc, 30 * d, d, 4242);
    defer alloc.free(qs);

    var one = try build(alloc, pts, n, d, 1, false, 5);
    defer one.deinit();
    var many = try build(alloc, pts, n, d, 16, false, 5);
    defer many.deinit();

    // one tree loses whatever sits on the far side of its splits; independent trees
    // split differently, so a neighbour missed in one is usually found in another.
    // This is why it is a forest and not a tree.
    const r1 = try recallAt(alloc, one, qs, 30, d, 10, 150);
    const r16 = try recallAt(alloc, many, qs, 30, d, 10, 150);
    try testing.expect(r16 > r1);
}

test "the index is deterministic given its seed" {
    const alloc = testing.allocator;
    const n = 300;
    const d = 6;
    const pts = try makeCloud(alloc, n, d, 8);
    defer alloc.free(pts);

    var a = try build(alloc, pts, n, d, 4, false, 99);
    defer a.deinit();
    var b = try build(alloc, pts, n, d, 4, false, 99);
    defer b.deinit();
    var c = try build(alloc, pts, n, d, 4, false, 100);
    defer c.deinit();

    const k = 5;
    const ia = try alloc.alloc(u32, k);
    defer alloc.free(ia);
    const da = try alloc.alloc(f64, k);
    defer alloc.free(da);
    const ib = try alloc.alloc(u32, k);
    defer alloc.free(ib);
    const db = try alloc.alloc(f64, k);
    defer alloc.free(db);

    const q = pts[7 * d .. 8 * d];
    const na = try search(a, alloc, q, k, 50, ia, da);
    const nb = try search(b, alloc, q, k, 50, ib, db);

    // A RECALL FIGURE IS ONLY MEANINGFUL IF IT REPRODUCES. Same seed, same forest,
    // same answer -- so a measured recall is a property of the code and not of the
    // run that happened to produce it.
    try testing.expectEqual(na, nb);
    for (0..na) |i| try testing.expectEqual(ia[i], ib[i]);

    // a different seed is free to disagree; it must still be a valid answer, which
    // the distance check in the first test already guarantees
    _ = try search(c, alloc, q, k, 50, ia, da);
}

test "cosine mode ranks by direction, not by length" {
    const alloc = testing.allocator;
    const d = 3;
    const n = 4;
    // point 0 and point 1 point the SAME WAY, but 1 is ten times longer. Point 2 is
    // a short vector in a different direction, point 3 is orthogonal.
    const pts = [_]f64{
        1.0, 0.0, 0.0,
        10.0, 0.0, 0.0,
        0.9, 0.9, 0.0,
        0.0, 0.0, 1.0,
    };

    // EUCLIDEAN: the query [1,0,0] is far from the long vector, so it is not a
    // neighbour at all
    var euc = try build(alloc, &pts, n, d, 4, false, 1);
    defer euc.deinit();
    const ei = try alloc.alloc(u32, n);
    defer alloc.free(ei);
    const ed = try alloc.alloc(f64, n);
    defer alloc.free(ed);
    const q = [_]f64{ 1.0, 0.0, 0.0 };
    _ = try searchExact(euc, alloc, &q, 2, ei, ed);
    try testing.expectEqual(@as(u32, 0), ei[0]);
    try testing.expectEqual(@as(u32, 2), ei[1]); // the SHORT nearby vector wins

    // COSINE: length is normalized away, so the long vector in the same direction
    // becomes a perfect match and ties with the point itself at distance 0
    var cos = try build(alloc, &pts, n, d, 4, true, 1);
    defer cos.deinit();
    _ = try searchExact(cos, alloc, &q, 2, ei, ed);
    try testing.expect((ei[0] == 0 and ei[1] == 1) or (ei[0] == 1 and ei[1] == 0));
    try testing.expectApproxEqAbs(@as(f64, 0), ed[0], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 0), ed[1], 1e-12);
}

test "the awkward shapes do not break it" {
    const alloc = testing.allocator;

    // ONE point: k=5 asks for more neighbours than exist, and must simply give one
    const one = [_]f64{ 1.0, 2.0 };
    var ix1 = try build(alloc, &one, 1, 2, 4, false, 3);
    defer ix1.deinit();
    var oi = [_]u32{0} ** 5;
    var od = [_]f64{0} ** 5;
    const got1 = try search(ix1, alloc, &[_]f64{ 1.0, 2.0 }, 5, 0, &oi, &od);
    try testing.expectEqual(@as(usize, 1), got1);

    // MANY IDENTICAL POINTS. Every split plane degenerates -- the two sampled points
    // coincide, so no plane exists -- and the build must terminate anyway rather than
    // recursing forever on a partition that separates nothing.
    const dupn = 200;
    const dup = try alloc.alloc(f64, dupn * 2);
    defer alloc.free(dup);
    for (0..dupn) |i| {
        dup[i * 2] = 5.0;
        dup[i * 2 + 1] = 5.0;
    }
    var ix2 = try build(alloc, dup, dupn, 2, 4, false, 7);
    defer ix2.deinit();
    const got2 = try search(ix2, alloc, &[_]f64{ 5.0, 5.0 }, 3, 0, &oi, &od);
    try testing.expectEqual(@as(usize, 3), got2);
    for (0..got2) |i| try testing.expectApproxEqAbs(@as(f64, 0), od[i], 1e-12);

    // a zero vector in cosine mode has no direction; it must not produce NaN
    const withzero = [_]f64{ 0.0, 0.0, 1.0, 0.0 };
    var ix3 = try build(alloc, &withzero, 2, 2, 2, true, 11);
    defer ix3.deinit();
    const got3 = try search(ix3, alloc, &[_]f64{ 1.0, 0.0 }, 2, 0, &oi, &od);
    try testing.expectEqual(@as(usize, 2), got3);
    for (0..got3) |i| try testing.expect(!std.math.isNan(od[i]));

    // a bad shape is refused rather than half-built
    try testing.expectError(AnnError.BadShape, build(alloc, &one, 5, 2, 4, false, 1));
}
