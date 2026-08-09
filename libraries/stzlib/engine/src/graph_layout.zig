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
pub fn sweep(
    off: []const u32,
    src: []const u32,
    layer: []const u32,
    order: []u32,
    starts: []const u32,
    nsweeps: u32,
) i32 {
    const n = order.len;
    if (n == 0 or starts.len < 2) return BAD_ARG;

    const pos = alloc.alloc(u32, n) catch return BAD_ARG;
    defer alloc.free(pos);

    var widest: usize = 0;
    for (0..starts.len - 1) |L| {
        const w = starts[L + 1] - starts[L];
        if (w > widest) widest = w;
    }
    const keys = alloc.alloc(Key, widest) catch return BAD_ARG;
    defer alloc.free(keys);

    var s: u32 = 0;
    while (s < nsweeps) : (s += 1) {
        // positions from the current order -- derived, never carried
        for (0..starts.len - 1) |L| {
            var i = starts[L];
            var p: u32 = 1;
            while (i < starts[L + 1]) : (i += 1) {
                pos[order[i]] = p;
                p += 1;
            }
        }

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
    }

    // leave positions consistent with the order we return
    for (0..starts.len - 1) |L| {
        var i = starts[L];
        var p: u32 = 1;
        while (i < starts[L + 1]) : (i += 1) {
            pos[order[i]] = p;
            p += 1;
        }
    }
    return OK;
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
