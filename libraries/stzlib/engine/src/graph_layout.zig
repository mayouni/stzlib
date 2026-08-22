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

/// X coordinates for a layered graph whose ORDER is already decided.
///
/// THE SWEEP ABOVE ANSWERS "WHO SITS BESIDE WHOM", AND NOTHING ANSWERED
/// "WHERE". The face filled that gap with `position / (width + 1)` -- every
/// layer spread evenly across the whole picture, however many nodes it held.
/// So a layer of nine was stretched to the same width as a layer of sixteen,
/// and a node's children were placed by their ORDINAL rather than under
/// their parent. On a 40-node binary tree the bottom row fanned across the
/// entire canvas and its edges became long diagonal sweeps that crossed
/// three other rows. Ordering was optimal and the drawing was still wrong,
/// because the two questions are not the same question.
///
/// WHAT IT SOLVES, EXACTLY. Each layer is placed to minimise the squared
/// distance from every node to the mean of its neighbours in the adjacent
/// layer, subject to keeping the given order with at least `sep` between
/// consecutive nodes. That constrained least-squares problem is isotonic
/// regression after the substitution u[k] = t[k] - k*sep, which turns
/// "x[k+1] >= x[k] + sep" into "u non-decreasing". Pool-adjacent-violators
/// solves it EXACTLY in one pass -- so this is not a relaxation heuristic
/// per layer, it is the optimum for that layer given its neighbours.
///
/// Alternating down (from predecessors) and up (from successors) is what
/// makes a parent centre over its children AND a child sit under its
/// parents. Down-only would leave every root where it started.
///
/// DETERMINISM, as everywhere in this file: no sort is involved, the
/// arithmetic runs in a fixed order, and equal inputs pool identically. The
/// same graph gives the same coordinates bit for bit.
/// `extra` is a PER-NODE half-width demand, in the same units as `sep`, and
/// it is what lets something wider than a node steer the layout. The
/// minimum separation between two neighbours becomes
/// `sep + extra[a] + extra[b]` instead of a flat `sep`.
///
/// It exists for EDGE LABELS. A label is drawn between two ranks, so no
/// node owns it and nothing in a uniform-separation layout could reserve
/// room for it: labels were placed after the fact and nudged when they
/// collided, which moves the label rather than making space for it. dot
/// reserves the room by giving each label its own virtual node with a
/// width; a per-node demand buys the same thing without doubling the rank
/// count -- a node whose incoming edge carries a wide label asks for more
/// elbow room, and its whole rank spreads to give it.
///
/// Pass an empty slice for uniform separation.
/// A PIN IS AN ORDER, NOT A POSITION -- and this comment is the second
/// version of itself, because the first design was wrong in a way only a
/// picture could show.
///
/// It began as an override: the author's position restored after every
/// pass, so no pass could argue with it. That honoured the pin exactly
/// and broke everything else. A pinned cell escaped the minimum
/// separation and sat touching its neighbour; it escaped the family air,
/// so grouping vanished; it escaped centring, so parents leaned; and it
/// escaped the order the crossing sweep had settled, so edges tangled
/// into shapes no rule in this file would ever produce. The Principal
/// read one such picture and named every violation in it.
///
/// The lesson is that positions are not what an author owns. In a
/// layered drawing the metric placement IS the visual contract --
/// separation, rhythm, grouping, centring, the lot -- and overriding one
/// number in it overrides the contract. What an author actually means by
/// dragging a cell is WHERE IT SITS AMONG ITS NEIGHBOURS, which is an
/// ordering claim, and an ordering claim the layout can honour while
/// keeping every law intact.
///
/// So pins are applied by the face, to the rank ORDER, before this
/// function runs (stzGraphCanvas), and this function lays the result out
/// with no override at all. yFiles calls the same idea layout-from-
/// sketch: the sketch decides the arrangement, the layout decides the
/// geometry.

pub fn coords(
    in_off: []const u32,
    in_src: []const u32,
    out_off: []const u32,
    out_dst: []const u32,
    order: []const u32,
    starts: []const u32,
    sep: f64,
    iters: u32,
    extra: []const f64,
    x: []f64,
) i32 {
    const n = x.len;
    if (order.len != n) return BAD_ARG;
    if (starts.len < 2) return BAD_ARG;
    if (in_off.len != n + 1 or out_off.len != n + 1) return BAD_ARG;
    if (!(sep > 0)) return BAD_ARG;
    if (extra.len != 0 and extra.len != n) return BAD_ARG;
    const nl = starts.len - 1;
    if (starts[nl] != n) return BAD_ARG;
    for (order) |v| if (v >= n) return BAD_ARG;

    // widest layer -- the scratch buffers are sized once for all of them
    var maxw: usize = 0;
    for (0..nl) |L| {
        if (starts[L + 1] < starts[L]) return BAD_ARG;
        const w = starts[L + 1] - starts[L];
        if (w > maxw) maxw = w;
    }
    if (maxw == 0) return OK;

    const t = alloc.alloc(f64, maxw) catch return BAD_ARG;
    defer alloc.free(t);
    const bval = alloc.alloc(f64, maxw) catch return BAD_ARG;
    defer alloc.free(bval);
    const bcnt = alloc.alloc(f64, maxw) catch return BAD_ARG;
    defer alloc.free(bcnt);
    const cofs = alloc.alloc(f64, maxw) catch return BAD_ARG;
    defer alloc.free(cofs);

    // the even spread is the STARTING point, not the answer -- but it
    // still has to be FEASIBLE, so it accumulates the same demands the
    // relaxation will enforce
    for (0..nl) |L| {
        var k: usize = 0;
        var acc: f64 = 0;
        while (starts[L] + k < starts[L + 1]) : (k += 1) {
            const v = order[starts[L] + k];
            if (k > 0) {
                const prev = order[starts[L] + k - 1];
                acc += sep + demand(extra, prev) + demand(extra, v);
            }
            x[v] = acc;
        }
    }

    var it: u32 = 0;
    while (it < iters) : (it += 1) {
        var L: usize = 1;
        while (L < nl) : (L += 1) {
            relaxLayer(in_off, in_src, order, starts, L, sep, extra, x, t, bval, bcnt, cofs);
        }
        var Lu: usize = nl - 1;
        while (Lu > 0) {
            Lu -= 1;
            relaxLayer(out_off, out_dst, order, starts, Lu, sep, extra, x, t, bval, bcnt, cofs);
        }

        // THE COMBINED PASS, and it is what makes the picture tight.
        //
        // Down-then-up alternately answers "where do my parents want me"
        // and "where do my children want me", and the fixed point of that
        // pins every node at the MEAN of one side or the other. A parent
        // ends up exactly at its children's mean with no freedom left, so
        // sparse upper ranks are dragged apart by the width of the
        // subtrees below them. Measured against dot on the same 40-node
        // tree: the dense ranks matched to within 3%, the rank of four was
        // 1.21x too wide and the rank of TWO was 2.09x.
        //
        // dot has that freedom because network simplex minimises total
        // ABSOLUTE edge length: a parent sitting anywhere between its
        // children costs the same, and the slack is spent shortening the
        // edge to its own parent. Relaxing against BOTH directions at once
        // is the least that recovers it here -- a node answers to its
        // parents and its children in one solve, so the whole tree
        // shortens together instead of each rank being satisfied in turn.
        var Lb: usize = 0;
        while (Lb < nl) : (Lb += 1) {
            relaxLayerBoth(in_off, in_src, out_off, out_dst, order, starts, Lb, sep, extra, x, t, bval, bcnt, cofs);
        }
    }

    // ALIGNMENT SNAP, last of all, because it is the polish the Principal
    // kept marking and every earlier pass kept undoing. Relaxation places a
    // node NEAR the mean of its neighbours; cohesion and territories then
    // shift it a little; the result is a cell ALMOST under its counterpart
    // -- and an almost-vertical edge reads as a mistake where a clearly
    // slanted one reads as a decision. dot never ships that case: its
    // network simplex makes some edge of every node exactly straight, which
    // is why its pictures have vertical spines. This is the cheap form of
    // the same idea (Brandes-Koepf vertical alignment): if a node can sit
    // EXACTLY on a neighbour's cross-position without violating its rank's
    // separations, put it there. All or nothing -- a partial move would
    // just manufacture a new near-miss, the very thing being killed.
    snapAlign(in_off, in_src, out_off, out_dst, order, starts, sep, extra, x);

    // LAST, and only on a forest. The relaxation produces a good-looking
    // arrangement that can still put a node inside another branch's span;
    // this makes territories disjoint by construction. It runs after the
    // relaxation rather than instead of it, because the relaxation is what
    // decides the SHAPE and this only enforces the one property it cannot
    // see.
    if (isForest(in_off, n)) {
        _ = tidyTerritories(in_off, in_src, out_off, out_dst, order, starts, sep, extra, x);
    }

    // AND THE PARENT IS CENTRED OVER ITS CHILDREN, last of all, because
    // the Principal's rule is unconditional: the mother cell must ALWAYS
    // be centred. Every pass above respects the children's span without
    // insisting on its middle -- the compaction clamps INTO the span on
    // purpose, since pinning at the mean during compaction repealed the
    // tightening and spans sprang back -- and snapAlign then actively
    // breaks centring whenever the child count is EVEN: a parent correctly
    // centred over four children sits half a slot from the two middle
    // ones, inside the snap tolerance, so it is pulled onto one of them
    // and the fan leans. That is the picture the Principal circled.
    //
    // Safe here in a way it is not inside the compaction: the centre of a
    // span lies within that span, so no territory grows and no rank widens
    // -- the pass can only move a parent between positions it was already
    // allowed to hold. Bottom-up, so a grandparent centres over children
    // that have already taken their own final places.
    // AIR BETWEEN FAMILIES, on every graph and not only on trees.
    //
    // tidyTerritories already opens a gap between cousins -- but it is
    // FOREST ONLY, because it shifts whole subtrees and a node with two
    // parents belongs to two of them. So the moment a graph gains one
    // shared child, every rank in it goes back to being evenly spaced:
    // six nodes in two families of three, all 57px apart, and a reader
    // cannot see where one family ends. The structure was right and the
    // grouping was gone -- and real diagrams are DAGs far more often
    // than they are trees.
    //
    // Whitespace is a semantic channel: proximity is the oldest grouping
    // cue a reader has, so equal spacing states equal relatedness. This
    // pass claims none of tidyTerritories' subtree reasoning. It asks
    // only what a reader asks -- do these two neighbours share a parent
    // -- and opens the same 0.40 of a separation when they do not, by
    // sliding the rest of the rank along. Idempotent with the forest
    // pass, which has already opened exactly that much.
    familyAir(in_off, in_src, order, starts, sep, extra, x);

    // ALIGNMENT IS THE LAST WORD, AND IT HAS TO ACTUALLY BE LAST. The
    // snap above runs before tidyTerritories and familyAir, both of
    // which MOVE nodes -- so every column the snap had made exact was
    // left a few pixels off by a later pass. Measured on the shipped
    // service diagram: a web tier sat 47px from the API it feeds and an
    // API 79px from its database, which is precisely the near-miss band
    // this library forbids elsewhere and had been quietly producing in
    // its own default picture. Neither aligned nor clearly slanted is
    // the one thing a reader cannot parse.
    snapAlign(in_off, in_src, out_off, out_dst, order, starts, sep, extra, x);

    centerParents(in_off, out_off, out_dst, order, starts, sep, extra, x);
    return OK;
}

/// Two nodes are SIBLINGS when their parent sets meet, and COUSINS when
/// they do not. A tree makes this "same parent"; a DAG needs the sets,
/// and the sets are what a reader is judging anyway -- two nodes fed by
/// the same thing look like a pair whether or not the graph is a tree.
fn sharesParent(in_off: []const u32, in_src: []const u32, a: u32, b: u32) bool {
    var i = in_off[a];
    while (i < in_off[a + 1]) : (i += 1) {
        var j = in_off[b];
        while (j < in_off[b + 1]) : (j += 1) {
            if (in_src[i] == in_src[j]) return true;
        }
    }
    return false;
}

/// The gap that makes a family visible. Applied per rank, sliding the
/// remainder of the rank rather than any subtree, so it is safe on a
/// graph tidyTerritories must refuse.
fn familyAir(
    in_off: []const u32,
    in_src: []const u32,
    order: []const u32,
    starts: []const u32,
    sep: f64,
    extra: []const f64,
    x: []f64,
) void {
    const nl = starts.len - 1;
    var L: usize = 0;
    while (L < nl) : (L += 1) {
        const s = starts[L];
        const e = starts[L + 1];
        var k = s + 1;
        while (k < e) : (k += 1) {
            const prev = order[k - 1];
            const cur = order[k];
            if (sharesParent(in_off, in_src, prev, cur)) continue;
            const want = x[prev] + sep + demand(extra, prev) +
                demand(extra, cur) + sep * 0.40;
            const need = want - x[cur];
            if (need > 0) {
                var j = k;
                while (j < e) : (j += 1) {
                    x[order[j]] += need;
                }
            }
        }
    }
}

/// A parent sits at the MIDDLE of its children's span, not merely inside
/// it. One child is the same statement as alignment, so chains keep their
/// spines; three children put the middle one under the parent, which is
/// alignment again; four make the difference visible, and that is where
/// the eye reads a lean as a claim about the graph.
///
/// Moves only when the whole distance is available: a partial slide
/// manufactures the near-miss that snapAlign exists to kill, and a
/// half-centred parent states nothing.
fn centerParents(
    in_off: []const u32,
    out_off: []const u32,
    out_dst: []const u32,
    order: []const u32,
    starts: []const u32,
    sep: f64,
    extra: []const f64,
    x: []f64,
) void {
    // how far the graph continues below each node, so a parent can tell
    // a passing branch from the line that carries on
    const n = x.len;
    const height = alloc.alloc(u32, n) catch return;
    defer alloc.free(height);
    @memset(height, 0);
    var hl: usize = starts.len - 1;
    while (hl > 0) {
        hl -= 1;
        var hk = starts[hl];
        while (hk < starts[hl + 1]) : (hk += 1) {
            const v = order[hk];
            var hj = out_off[v];
            var best: u32 = 0;
            while (hj < out_off[v + 1]) : (hj += 1) {
                const c = out_dst[hj];
                if (height[c] + 1 > best) best = height[c] + 1;
            }
            height[v] = best;
        }
    }

    var L: usize = starts.len - 1;
    while (L > 0) {
        L -= 1;
        const s = starts[L];
        const e = starts[L + 1];
        var k = s;
        while (k < e) : (k += 1) {
            const v = order[k];
            if (out_off[v + 1] - out_off[v] < 2) continue;
            // OWNED CHILDREN ONLY. A child with more than one parent
            // belongs to no single parent's territory -- the same reason
            // tidyTerritories runs on forests alone -- and counting it
            // drags its parents toward it from both sides. Seen live: a
            // service whose two children were a database inside its
            // cluster and a shared logger far outside it was pulled to
            // the midpoint between them, out of its own cluster's column
            // and off the spine it had with its own parent, to state a
            // centring over a child it does not own.
            var clo: f64 = 0;
            var chi: f64 = 0;
            var owned: u32 = 0;
            var j = out_off[v];
            while (j < out_off[v + 1]) : (j += 1) {
                const c = out_dst[j];
                if (in_off[c + 1] - in_off[c] != 1) continue;
                const cx = x[c];
                if (owned == 0) {
                    clo = cx;
                    chi = cx;
                } else {
                    if (cx < clo) clo = cx;
                    if (cx > chi) chi = cx;
                }
                owned += 1;
            }
            if (owned < 2) continue;
            // ...AND A SPINE OUTRANKS THE MIDDLE, where one exists.
            //
            // Centring a parent between a chain child and a leaf child
            // moves it half a pitch off the chain, and over five ranks
            // that accumulates: a five-stage pipeline drew as a diagonal
            // staircase 468px wide, with the main line -- the thing a
            // reader follows -- the least visible structure in the
            // picture.
            //
            // So the two rules become one: a parent stands over the child
            // that carries the LONGEST CONTINUATION when exactly one
            // child does, and at the middle of its children when none
            // stands out. A fan's children are all leaves and tie at
            // once, so centring is untouched; two branches of equal depth
            // tie too, which is why a balanced tree keeps its centred
            // root. Only where the graph itself says "this way onward"
            // does the picture say it as well.
            var target = (clo + chi) / 2;
            var best_h: u32 = 0;
            var best_c: u32 = 0;
            var ties: u32 = 0;
            j = out_off[v];
            while (j < out_off[v + 1]) : (j += 1) {
                const c = out_dst[j];
                if (in_off[c + 1] - in_off[c] != 1) continue;
                if (height[c] > best_h or ties == 0) {
                    if (height[c] > best_h) {
                        best_h = height[c];
                        best_c = c;
                        ties = 1;
                    } else if (ties == 0) {
                        best_h = height[c];
                        best_c = c;
                        ties = 1;
                    }
                } else if (height[c] == best_h) {
                    ties += 1;
                }
            }
            if (ties == 1 and best_h > 0) target = x[best_c];
            const mid = target;
            if (@abs(mid - x[v]) < 0.0001) continue;
            if (k > s) {
                const p = order[k - 1];
                if (mid < x[p] + sep + demand(extra, p) + demand(extra, v)) continue;
            }
            if (k + 1 < e) {
                const nx = order[k + 1];
                if (mid > x[nx] - sep - demand(extra, nx) - demand(extra, v)) continue;
            }
            x[v] = mid;
        }
    }
}

/// SUBTREE TERRITORIES MUST NOT OVERLAP -- no node may stand inside
/// another subtree's horizontal span.
///
/// The rank solver satisfies every rank on its own and nothing relates
/// them, so a node can be correctly ordered, correctly separated from its
/// own neighbours, and still land under a DIFFERENT branch of the tree.
/// Seen on the 40-node tree: node 39, a child of 19, sat between the two
/// children of node 10 -- so the edge down to it crossed the edge coming
/// out of 10, and a reader tracing the picture reads 39 as belonging to a
/// family it has nothing to do with. Order was right, separation was
/// right, and the drawing still lied about the structure.
///
/// The fix is Reingold-Tilford's contract done rank by rank instead of
/// recursively: work bottom-up, and at each rank push each node's WHOLE
/// SUBTREE right until it clears the previous sibling's subtree. A rigid
/// shift cannot disturb the layout inside a subtree, so by induction
/// every rank above inherits disjoint blocks and the property holds for
/// the whole tree by construction rather than by iteration.
///
/// FOREST ONLY, and that is a real limit rather than laziness: with two
/// parents a node belongs to two territories and "its subtree" names
/// nothing. Multi-parent graphs keep the relaxation, which is why this
/// returns a flag instead of asserting.
/// See the call site for why. Two passes, fixed order, deterministic: a
/// snap freed by an earlier snap in the same pass is caught by the second.
pub fn snapAlign(
    in_off: []const u32,
    in_src: []const u32,
    out_off: []const u32,
    out_dst: []const u32,
    order: []const u32,
    starts: []const u32,
    sep: f64,
    extra: []const f64,
    x: []f64,
) void {
    const nl = starts.len - 1;
    const tol = sep * 0.75;
    var pass: u32 = 0;
    while (pass < 2) : (pass += 1) {
        var L: usize = 0;
        while (L < nl) : (L += 1) {
            const s = starts[L];
            const e = starts[L + 1];
            var k = s;
            while (k < e) : (k += 1) {
                const v = order[k];
                // the nearest cross-position among parents and children,
                // within tolerance; parents scanned first so a tie goes to
                // the parent, deterministically
                var best = tol;
                var target: f64 = 0;
                var found = false;
                var j = in_off[v];
                while (j < in_off[v + 1]) : (j += 1) {
                    const c = x[in_src[j]];
                    const d = @abs(c - x[v]);
                    if (d > 0.0001 and d < best) {
                        best = d;
                        target = c;
                        found = true;
                    }
                }
                j = out_off[v];
                while (j < out_off[v + 1]) : (j += 1) {
                    const c = x[out_dst[j]];
                    const d = @abs(c - x[v]);
                    if (d > 0.0001 and d < best) {
                        best = d;
                        target = c;
                        found = true;
                    }
                }
                if (!found) continue;
                // reachable EXACTLY, or not at all
                if (k > s) {
                    const p = order[k - 1];
                    if (target < x[p] + sep + demand(extra, p) + demand(extra, v)) continue;
                }
                if (k + 1 < e) {
                    const nx = order[k + 1];
                    if (target > x[nx] - sep - demand(extra, nx) - demand(extra, v)) continue;
                }
                x[v] = target;
            }
        }
    }

    // AND THE EXACT POSITION OF A PARENT IS ITS CHILDREN'S MIDDLE, so the
    // snap ends by restoring it. Snapping alone actively destroys centring
    // when a parent has an EVEN number of children: correctly centred, it
    // stands half a slot from the two middle ones -- inside the tolerance
    // -- and gets pulled onto one, which states a closeness to that child
    // the graph does not contain.
    //
    // Here rather than only in the coordinate pass because this function
    // is what a face re-invokes when it has moved things itself (cluster
    // cohesion and boundary air are Ring-side), and alignment is only
    // worth having if it is the last word. Centring is the same claim for
    // a node that has children, so it has to be the last word in the same
    // places.
    centerParents(in_off, out_off, out_dst, order, starts, sep, extra, x);
}

fn isForest(in_off: []const u32, n: usize) bool {
    for (0..n) |v| {
        if (in_off[v + 1] - in_off[v] > 1) return false;
    }
    return true;
}

/// The one parent of v in a forest, or maxInt when it is a root. Two
/// nodes whose parents differ are cousins, and cousins are what a gap has
/// to make visible.
fn parentOf(in_off: []const u32, in_src: []const u32, v: u32) u32 {
    if (in_off[v + 1] > in_off[v]) return in_src[in_off[v]];
    return std.math.maxInt(u32);
}

/// Shift v and everything below it by d. Iterative: a path-shaped tree is
/// as deep as it is long, and 10,000 frames of recursion is a crash, not a
/// layout.
fn shiftSubtree(out_off: []const u32, out_dst: []const u32, v: u32, d: f64, x: []f64, lo: []f64, hi: []f64, stack: []u32) void {
    var sp: usize = 0;
    stack[sp] = v;
    sp += 1;
    while (sp > 0) {
        sp -= 1;
        const u = stack[sp];
        x[u] += d;
        lo[u] += d;
        hi[u] += d;
        var j = out_off[u];
        while (j < out_off[u + 1]) : (j += 1) {
            if (sp < stack.len) {
                stack[sp] = out_dst[j];
                sp += 1;
            }
        }
    }
}

fn tidyTerritories(
    in_off: []const u32,
    in_src: []const u32,
    out_off: []const u32,
    out_dst: []const u32,
    order: []const u32,
    starts: []const u32,
    sep: f64,
    extra: []const f64,
    x: []f64,
) i32 {
    const n = x.len;
    const nl = starts.len - 1;
    if (nl == 0) return OK;

    const lo = alloc.alloc(f64, n) catch return BAD_ARG;
    defer alloc.free(lo);
    const hi = alloc.alloc(f64, n) catch return BAD_ARG;
    defer alloc.free(hi);
    const stack = alloc.alloc(u32, n) catch return BAD_ARG;
    defer alloc.free(stack);

    for (0..n) |v| {
        const h = sep / 2 + demand(extra, @intCast(v));
        lo[v] = x[v] - h;
        hi[v] = x[v] + h;
    }

    var L: usize = nl;
    while (L > 0) {
        L -= 1;
        const s = starts[L];
        const e = starts[L + 1];

        // a parent sits over its own children, then owns their whole span
        var k = s;
        while (k < e) : (k += 1) {
            const v = order[k];
            if (out_off[v + 1] == out_off[v]) continue;
            // CLAMPED INTO ITS CHILDREN'S SPAN, not pinned to their mean.
            //
            // Both extremes were tried and both were wrong. PINNING the
            // parent at the mean is exactly what the combined relaxation
            // exists to undo, and it repealed it: every span sprang back,
            // the rank of two to 2.25x, worse than before any of this.
            // NOT MOVING the parent at all is worse still -- shifting a
            // subtree moves the children while the parent keeps a stale
            // position, so its territory stretches from where it was to
            // where they went, and the next rank has to clear that whole
            // width. Spans reached 3.7x and the pass panicked.
            //
            // Clamping keeps whichever position the relaxation chose
            // whenever it already lies over the children -- the normal
            // case, so the tightening survives -- and pulls the parent
            // only as far as the nearest child when it does not, which is
            // the least that keeps a territory from stretching.
            var clo: f64 = 0;
            var chi: f64 = 0;
            var first = true;
            var j = out_off[v];
            while (j < out_off[v + 1]) : (j += 1) {
                const cx = x[out_dst[j]];
                if (first) {
                    clo = cx;
                    chi = cx;
                    first = false;
                } else {
                    if (cx < clo) clo = cx;
                    if (cx > chi) chi = cx;
                }
            }
            if (x[v] < clo) x[v] = clo;
            if (x[v] > chi) x[v] = chi;

            const h = sep / 2 + demand(extra, v);
            lo[v] = x[v] - h;
            hi[v] = x[v] + h;
            j = out_off[v];
            while (j < out_off[v + 1]) : (j += 1) {
                const c = out_dst[j];
                if (lo[c] < lo[v]) lo[v] = lo[c];
                if (hi[c] > hi[v]) hi[v] = hi[c];
            }
        }

        // then no two siblings' territories may touch
        k = s + 1;
        while (k < e) : (k += 1) {
            const prev = order[k - 1];
            const cur = order[k];
            // TWO FAMILIES NEED MORE AIR THAN TWO SIBLINGS, which is
            // Walker's distinction between sibling separation and
            // SUBTREE separation and the thing a reader is actually
            // using to parse the picture. With one uniform gap every
            // node in a rank is equidistant, so where one parent's
            // children end and the next parent's begin is invisible --
            // the structure is correct and unreadable.
            //
            // Nothing is added between siblings: each territory already
            // carries the node's own half-slot on both sides, so two
            // that merely TOUCH are exactly one minimum separation
            // apart. Adding sep on top charged the separation twice and
            // doubled the picture to 5938px against dot's 2682 -- what
            // an off-by-one looks like when the unit is a distance
            // rather than an index.
            var gap: f64 = 0;
            if (parentOf(in_off, in_src, prev) != parentOf(in_off, in_src, cur)) {
                gap = sep * 0.40;
            }
            const need = hi[prev] + gap - lo[cur];
            if (need > 0) {
                shiftSubtree(out_off, out_dst, cur, need, x, lo, hi, stack);
            }
        }
    }
    return OK;
}

/// THE SOLVER, extracted so the two relaxation passes cannot drift apart.
/// It was copied once and that copy is exactly how a second pass ends up
/// enforcing a slightly different separation than the first.
fn solveLayer(
    order: []const u32,
    starts: []const u32,
    L: usize,
    sep: f64,
    extra: []const f64,
    x: []f64,
    t: []const f64,
    bval: []f64,
    bcnt: []f64,
    cofs: []f64,
) void {
    const s = starts[L];
    const w = starts[L + 1] - s;
    if (w == 0) return;

    // POOL ADJACENT VIOLATORS on u[k] = t[k] - c[k], where c[k] is the
    // CUMULATIVE minimum offset of position k from the start of the layer.
    // With a flat separation that is just k*sep; with per-node demands the
    // offsets are uneven, and the substitution is the general form of the
    // same idea -- "x[k+1] >= x[k] + minsep(k)" becomes "u non-decreasing"
    // either way, so isotonic regression still solves it exactly. Each
    // pooled block takes the mean of the targets it absorbed, which is the
    // L2 optimum for a run of nodes forced hard against each other.
    var nb: usize = 0;
    var cum: f64 = 0;
    for (0..w) |k| {
        if (k > 0) {
            cum += sep + demand(extra, order[s + k - 1]) + demand(extra, order[s + k]);
        }
        cofs[k] = cum;
        bval[nb] = t[k] - cum;
        bcnt[nb] = 1;
        nb += 1;
        while (nb > 1 and bval[nb - 1] < bval[nb - 2]) {
            const c1 = bcnt[nb - 2];
            const c2 = bcnt[nb - 1];
            bval[nb - 2] = (bval[nb - 2] * c1 + bval[nb - 1] * c2) / (c1 + c2);
            bcnt[nb - 2] = c1 + c2;
            nb -= 1;
        }
    }

    var k: usize = 0;
    for (0..nb) |b| {
        var c: f64 = 0;
        while (c < bcnt[b]) : (c += 1) {
            x[order[s + k]] = bval[b] + cofs[k];
            k += 1;
        }
    }
}

/// One layer, placed optimally against its neighbours in BOTH directions.
/// Same solver as relaxLayer -- only the target differs, being the mean
/// over predecessors and successors together rather than one side.
fn relaxLayerBoth(
    a_off: []const u32,
    a_adj: []const u32,
    b_off: []const u32,
    b_adj: []const u32,
    order: []const u32,
    starts: []const u32,
    L: usize,
    sep: f64,
    extra: []const f64,
    x: []f64,
    t: []f64,
    bval: []f64,
    bcnt: []f64,
    cofs: []f64,
) void {
    const s = starts[L];
    const e = starts[L + 1];
    const w = e - s;
    if (w == 0) return;

    for (0..w) |k| {
        const v = order[s + k];
        var sum: f64 = 0;
        var cnt: f64 = 0;
        var j = a_off[v];
        while (j < a_off[v + 1]) : (j += 1) {
            sum += x[a_adj[j]];
            cnt += 1;
        }
        var j2 = b_off[v];
        while (j2 < b_off[v + 1]) : (j2 += 1) {
            sum += x[b_adj[j2]];
            cnt += 1;
        }
        t[k] = if (cnt > 0) sum / cnt else x[v];
    }

    solveLayer(order, starts, L, sep, extra, x, t, bval, bcnt, cofs);
}

/// One layer, placed optimally against its neighbours in `adj`.
fn relaxLayer(
    adj_off: []const u32,
    adj: []const u32,
    order: []const u32,
    starts: []const u32,
    L: usize,
    sep: f64,
    extra: []const f64,
    x: []f64,
    t: []f64,
    bval: []f64,
    bcnt: []f64,
    cofs: []f64,
) void {
    const s = starts[L];
    const e = starts[L + 1];
    const w = e - s;
    if (w == 0) return;

    // where each node WANTS to be: the mean of its neighbours. A node with
    // no neighbour in that direction wants to stay where it is, so an
    // isolated node is carried along rather than collapsed onto zero.
    for (0..w) |k| {
        const v = order[s + k];
        var sum: f64 = 0;
        var cnt: f64 = 0;
        var j = adj_off[v];
        while (j < adj_off[v + 1]) : (j += 1) {
            sum += x[adj[j]];
            cnt += 1;
        }
        t[k] = if (cnt > 0) sum / cnt else x[v];
    }

    solveLayer(order, starts, L, sep, extra, x, t, bval, bcnt, cofs);
}

/// A node's extra half-width demand, or zero when none was supplied.
fn demand(extra: []const f64, v: u32) f64 {
    if (extra.len == 0) return 0;
    const i: usize = @intCast(v);
    if (i >= extra.len) return 0;
    const d = extra[i];
    if (!(d > 0)) return 0;
    return d;
}
