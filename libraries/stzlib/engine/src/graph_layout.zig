//! Layered graph layout -- the CPU half of GG1.
//!
//! WHY THIS IS ENGINE CODE AND NOT A GPU KERNEL. The GG1 spike measured the
//! split honestly: layer assignment is a propagation and belongs on the GPU
//! (2,000 nodes to a fixed point in 29 ms), but the barycentre sweep is a
//! per-layer SORT, and a sort of a hundred items is not GPU work. In
//! interpreted Ring that sweep was essentially the whole cost of a 10,000
//! node layout -- 1,499 ms of a 2,000 ms budget, with the GPU contributing
//! 29 ms of it. So the fix is Zig, not more GPU.
//!
//! DETERMINISM IS THE CONSTRAINT, not speed. Slice 0 established that a
//! layout nobody can reproduce cannot be guarded, and a sort is exactly
//! where reproducibility dies: equal barycentres are common (any two nodes
//! sharing a single predecessor tie), and an unstable sort orders ties
//! however it pleases. Every comparison here is on the TOTAL order
//! (barycentre, node id), so ties are broken by identity and no sort
//! algorithm can express a preference.
//!
//! SWEEP DIRECTION IS DOWN-ONLY, and that was measured rather than assumed.
//! The textbook alternates down and up; on a band graph with a known good
//! order, started scrambled, down-only recovered 44.5% of the crossings,
//! alternating 33.4%, and alternating-with-best-keeping 38.5%. Alternating
//! oscillates between two local optima. Down-only also costs least -- no
//! out-edge index, no per-sweep crossing count.

const std = @import("std");

const alloc = std.heap.c_allocator;

pub const OK: i32 = 0;
pub const BAD_ARG: i32 = 3;

const Key = struct {
    bary: f64,
    id: u32,
};

/// The TOTAL order. `id` is in the key, not merely a tiebreak applied
/// afterwards -- that is what makes the result independent of which sort
/// runs it.
fn lessThan(_: void, a: Key, b: Key) bool {
    if (a.bary != b.bary) return a.bary < b.bary;
    return a.id < b.id;
}

/// Barycentre sweeps over a layered DAG.
///
///   off/src  CSR over IN-edges: src[off[v]..off[v+1]] are v's predecessors
///   layer    layer index per node
///   order    IN/OUT -- node ids grouped by layer, in position order
///   starts   IN -- where each layer begins in `order` (nlayers+1 entries)
///
/// `order` is rewritten in place. Positions are recomputed each sweep from
/// `order` itself, so the two can never disagree.
/// eu/ev are the edge list -- needed because the sweep now KEEPS THE BEST
/// ORDER it sees rather than whatever the last pass produced.
///
/// This is not a refinement, it is a correctness fix. Barycentre is a
/// heuristic with no monotonicity guarantee: on a deep-narrow graph whose
/// adjacency wraps around (neighbours at positions 1 and 6 average to 3.5,
/// the opposite side from where either belongs) the sweep INCREASED
/// crossings, 1947 -> 2113. A layout step that can make a picture worse is
/// not a foundation, whatever its average. Keeping the best makes "never
/// worse than the input" true by construction, on every topology.
///
/// The earlier decision to skip this was made on a single band graph, where
/// it happened to cost quality. One graph proves one graph.
pub fn sweep(
    off: []const u32,
    src: []const u32,
    layer: []const u32,
    order: []u32,
    starts: []const u32,
    nsweeps: u32,
    eu: []const u32,
    ev: []const u32,
) i32 {
    const n = order.len;
    if (n == 0 or starts.len < 2) return BAD_ARG;

    const pos = alloc.alloc(u32, n) catch return BAD_ARG;
    defer alloc.free(pos);
    const best_order = alloc.alloc(u32, n) catch return BAD_ARG;
    defer alloc.free(best_order);

    var widest: usize = 0;
    for (0..starts.len - 1) |L| {
        const w = starts[L + 1] - starts[L];
        if (w > widest) widest = w;
    }
    const keys = alloc.alloc(Key, widest) catch return BAD_ARG;
    defer alloc.free(keys);

    // the input order is the baseline to beat
    writePositions(order, starts, pos);
    var best = crossings(eu, ev, layer, pos, starts);
    @memcpy(best_order, order);

    var s: u32 = 0;
    while (s < nsweeps) : (s += 1) {
        writePositions(order, starts, pos);

        // layer 0 has no predecessors to average, so it never moves
        for (1..starts.len - 1) |L| {
            const lo = starts[L];
            const hi = starts[L + 1];
            const w = hi - lo;
            if (w < 2) continue;

            for (0..w) |k| {
                const v = order[lo + k];
                const e0 = off[v];
                const e1 = off[v + 1];
                var sum: f64 = 0;
                var cnt: u32 = 0;
                var q = e0;
                while (q < e1) : (q += 1) {
                    // only predecessors in the layer ABOVE contribute; an
                    // edge spanning several layers would otherwise pull a
                    // node toward a position on a different scale
                    const u = src[q];
                    if (layer[u] + 1 == layer[v]) {
                        sum += @floatFromInt(pos[u]);
                        cnt += 1;
                    }
                }
                keys[k] = .{
                    // no predecessor on this side: HOLD position rather than
                    // collapse to 0, which would dump every such node at the
                    // left edge in id order
                    .bary = if (cnt == 0) @floatFromInt(pos[v]) else sum / @as(f64, @floatFromInt(cnt)),
                    .id = v,
                };
            }
            std.sort.pdq(Key, keys[0..w], {}, lessThan);
            for (0..w) |k| order[lo + k] = keys[k].id;
        }

        writePositions(order, starts, pos);
        const c = crossings(eu, ev, layer, pos, starts);
        if (c < best) {
            best = c;
            @memcpy(best_order, order);
        }
    }

    @memcpy(order, best_order);
    writePositions(order, starts, pos);
    return OK;
}

fn writePositions(order: []const u32, starts: []const u32, pos: []u32) void {
    for (0..starts.len - 1) |L| {
        var i = starts[L];
        var p: u32 = 1;
        while (i < starts[L + 1]) : (i += 1) {
            pos[order[i]] = p;
            p += 1;
        }
    }
}

/// Count edge crossings between adjacent layers.
///
/// The obvious loop is every pair of edges in a layer -- O(E^2), and it was
/// the second-largest cost in the Ring version. This counts INVERSIONS with
/// a Fenwick tree instead: sort each layer's edges by the position of their
/// upper endpoint, then sweep the lower endpoints counting how many already
/// placed sit to the right. O(E log W), same answer.
pub fn crossings(
    eu: []const u32,
    ev: []const u32,
    layer: []const u32,
    pos: []const u32,
    starts: []const u32,
) f64 {
    const ne = eu.len;
    if (ne == 0 or starts.len < 2) return 0;
    const nlayers = starts.len - 1;

    var counts = alloc.alloc(u32, nlayers) catch return -1;
    defer alloc.free(counts);
    @memset(counts, 0);
    for (0..ne) |e| {
        const L = layer[eu[e]];
        if (L < nlayers) counts[L] += 1;
    }
    var lstart = alloc.alloc(u32, nlayers + 1) catch return -1;
    defer alloc.free(lstart);
    var acc: u32 = 0;
    for (0..nlayers) |L| {
        lstart[L] = acc;
        acc += counts[L];
    }
    lstart[nlayers] = acc;

    const pairs = alloc.alloc([2]u32, ne) catch return -1;
    defer alloc.free(pairs);
    const fill = alloc.alloc(u32, nlayers) catch return -1;
    defer alloc.free(fill);
    @memset(fill, 0);
    for (0..ne) |e| {
        const L = layer[eu[e]];
        if (L >= nlayers) continue;
        pairs[lstart[L] + fill[L]] = .{ pos[eu[e]], pos[ev[e]] };
        fill[L] += 1;
    }

    var maxw: usize = 0;
    for (0..nlayers) |L| {
        const w = starts[L + 1] - starts[L];
        if (w > maxw) maxw = w;
    }
    const bit = alloc.alloc(u32, maxw + 2) catch return -1;
    defer alloc.free(bit);

    var total: f64 = 0;
    for (0..nlayers) |L| {
        const lo = lstart[L];
        const hi = lstart[L + 1];
        const m = hi - lo;
        if (m < 2) continue;
        const seg = pairs[lo..hi];
        std.sort.pdq([2]u32, seg, {}, struct {
            fn f(_: void, a: [2]u32, b: [2]u32) bool {
                if (a[0] != b[0]) return a[0] < b[0];
                return a[1] < b[1];
            }
        }.f);

        @memset(bit, 0);
        var placed: u32 = 0;
        for (seg) |pr| {
            // how many already-placed lower endpoints sit strictly right of
            // this one -- each is a crossing with this edge
            var i = pr[1];
            var le: u32 = 0;
            while (i > 0) : (i -= i & (~i +% 1)) le += bit[i];
            total += @floatFromInt(placed - le);
            var j = pr[1];
            while (j <= maxw) : (j += j & (~j +% 1)) bit[j] += 1;
            placed += 1;
        }
    }
    return total;
}

// ---------------------------------------------------------------- force layout

/// Fruchterman-Reingold, seeded and deterministic, in the ENGINE.
///
/// It lives here because the Ring face grew its own copy: 443 ms for 40
/// nodes, 3.7 s for 120, and 24.5 s for 300 -- while GG1's measurement had
/// already shown the same algorithm doing 10,000 nodes in 152 ms. A second
/// implementation of something the tier below already does does not stay
/// equal; this one diverged in COST by three orders of magnitude, and it
/// was the user-facing path.
///
/// DETERMINISM, on the same terms slice 0 established: one node accumulates
/// its own forces in INDEX ORDER, no atomics, no parallel reduction, and
/// the cooling schedule is absolute (t = T0 * r^i) rather than normalised
/// by the iteration count. Same seed and same graph give the same bytes.
///
/// pos is 2*n floats, seeded by the caller and written in place.
pub fn force(
    off: []const u32,
    src: []const u32,
    pos: []f32,
    iters: u32,
    k: f32,
) i32 {
    const n = pos.len / 2;
    if (n == 0) return BAD_ARG;
    if (off.len < n + 1) return BAD_ARG;

    const disp = alloc.alloc(f32, n * 2) catch return BAD_ARG;
    defer alloc.free(disp);

    var it: u32 = 0;
    while (it < iters) : (it += 1) {
        const temp: f32 = 100.0 * std.math.pow(f32, 0.94, @floatFromInt(it));
        @memset(disp, 0);

        for (0..n) |i| {
            const px = pos[i * 2];
            const py = pos[i * 2 + 1];
            var dx: f32 = 0;
            var dy: f32 = 0;

            // repulsion from every node, in index order
            for (0..n) |j| {
                if (j == i) continue;
                const ox = px - pos[j * 2];
                const oy = py - pos[j * 2 + 1];
                var d2 = ox * ox + oy * oy;
                if (d2 < 0.01) d2 = 0.01;
                const f = (k * k) / d2;
                dx += ox * f;
                dy += oy * f;
            }

            // attraction along this node's edges, in slot order
            const s = off[i];
            const e = off[i + 1];
            var q = s;
            while (q < e) : (q += 1) {
                const j = src[q];
                if (j >= n) continue;
                const ox = pos[j * 2] - px;
                const oy = pos[j * 2 + 1] - py;
                const d = @sqrt(ox * ox + oy * oy);
                if (d > 0.0001) {
                    const f = d / k;
                    dx += ox * f;
                    dy += oy * f;
                }
            }
            disp[i * 2] = dx;
            disp[i * 2 + 1] = dy;
        }

        // integrate, capped by the temperature -- the cap is what makes the
        // convergence bound of GG1 slice 1 apply here too
        for (0..n) |i| {
            const dx = disp[i * 2];
            const dy = disp[i * 2 + 1];
            const mag = @sqrt(dx * dx + dy * dy);
            if (mag > 0.0001) {
                const capped = @min(mag, temp);
                pos[i * 2] += dx / mag * capped;
                pos[i * 2 + 1] += dy / mag * capped;
            }
        }
    }
    return OK;
}
