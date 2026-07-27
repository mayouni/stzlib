//! ID3 decision trees over categorical features.
//!
//! PHASE 5, SECOND PASS. The first pass took this from 1.434s to 0.308s at 4000x8 by
//! removing three Ring-side mistakes -- a case fold redone at every node, copied
//! example rows, and the HasKey counting idiom. All three were real, and none of them
//! changed the fact that ID3 was running in an interpreter: 40000 x 10 still took
//! 3.965 seconds of arithmetic that is not hard.
//!
//! CATEGORIES ARE INTEGERS HERE, which is the whole reason this can be a clean move.
//! Ring interns feature values and labels to codes once -- it already had to fold and
//! scan them -- so nothing in this file compares a string. Entropy over integer codes
//! is counting, and counting over a small dense range is an array index, not a hash.
//!
//! THE CHOICES ARE RING'S. ID3 picks among equals constantly -- which feature when two
//! carry the same information gain, which label when a node is evenly split, which
//! order the branches come out in -- and every one of those is visible in the tree the
//! user reads. So:
//!
//!   * the best feature is the FIRST to achieve the maximum gain (strict `>`),
//!     scanning the remaining features in their original order;
//!   * the majority label is the FIRST to achieve the maximum count, in the order the
//!     labels were first seen IN THAT SUBSET -- not in code order, which is why
//!     firstSeenOrder below exists rather than a plain argmax over counts;
//!   * branch values come out in the order they are first seen in the subset, again
//!     not in code order;
//!   * a pure node becomes a leaf before the "no features left" check, so a pure node
//!     with no features left is labelled by its content and not by its majority.
//!
//! Get any of those wrong and the tree is still a valid ID3 tree, still classifies
//! most things the same way, and quietly disagrees on the cases that made someone
//! choose a decision tree for its explainability in the first place.

const std = @import("std");

/// A node in the flat encoding sent back to Ring.
pub const Node = struct {
    /// leaf: label code. decision: -1
    leaf_label: i32,
    /// decision: feature index (0-based). leaf: -1
    feature: i32,
    /// decision: majority label used for an unseen value at classify time
    default_label: i32,
    /// index into `branch_values` / `branch_children` of this node's first branch
    branch_start: u32,
    branch_count: u32,
};

pub const Tree = struct {
    nodes: std.ArrayList(Node),
    branch_values: std.ArrayList(i32),
    branch_children: std.ArrayList(u32),

    pub fn deinit(self: *Tree, alloc: std.mem.Allocator) void {
        self.nodes.deinit(alloc);
        self.branch_values.deinit(alloc);
        self.branch_children.deinit(alloc);
    }
};

const Ctx = struct {
    feat: []const i32,
    labels: []const i32,
    n: usize,
    d: usize,
    n_labels: usize,
    n_values: usize,
    alloc: std.mem.Allocator,
    tree: *Tree,
    /// scratch, n_labels wide
    counts: []usize,
    /// scratch, n_values wide
    vcounts: []usize,
};

/// Counts of each label over `pos`, plus the labels in FIRST-SEEN order.
/// The order is what breaks ties in the majority vote, so it is computed rather
/// than assumed to match the code order.
fn labelCounts(ctx: *Ctx, pos: []const u32, order: []i32) usize {
    @memset(ctx.counts[0..ctx.n_labels], 0);
    var n_distinct: usize = 0;
    for (pos) |p| {
        const l: usize = @intCast(ctx.labels[p]);
        if (ctx.counts[l] == 0) {
            order[n_distinct] = @intCast(l);
            n_distinct += 1;
        }
        ctx.counts[l] += 1;
    }
    return n_distinct;
}

fn majority(ctx: *Ctx, pos: []const u32, order: []i32) i32 {
    const n_distinct = labelCounts(ctx, pos, order);
    var best: i32 = if (n_distinct > 0) order[0] else 0;
    var best_n: usize = 0;
    for (order[0..n_distinct]) |l| {
        const c = ctx.counts[@intCast(l)];
        if (c > best_n) { // strict: the FIRST to reach the max wins
            best_n = c;
            best = l;
        }
    }
    return best;
}

fn entropy(ctx: *Ctx, pos: []const u32, order: []i32) f64 {
    if (pos.len == 0) return 0;
    const n_distinct = labelCounts(ctx, pos, order);
    const total: f64 = @floatFromInt(pos.len);
    var h: f64 = 0;
    for (order[0..n_distinct]) |l| {
        const p = @as(f64, @floatFromInt(ctx.counts[@intCast(l)])) / total;
        h -= p * (@log(p) / @log(2.0));
    }
    return h;
}

fn isPure(ctx: *Ctx, pos: []const u32) bool {
    if (pos.len == 0) return true;
    const first = ctx.labels[pos[0]];
    for (pos[1..]) |p| {
        if (ctx.labels[p] != first) return false;
    }
    return true;
}

/// The distinct values of feature `f` over `pos`, in first-seen order.
fn valuesOf(ctx: *Ctx, pos: []const u32, f: usize, out: []i32) usize {
    @memset(ctx.vcounts[0..ctx.n_values], 0);
    var n_distinct: usize = 0;
    for (pos) |p| {
        const v: usize = @intCast(ctx.feat[p * ctx.d + f]);
        if (ctx.vcounts[v] == 0) {
            out[n_distinct] = @intCast(v);
            n_distinct += 1;
        }
        ctx.vcounts[v] += 1;
    }
    return n_distinct;
}

fn build(ctx: *Ctx, pos: []const u32, feats: []const u32) error{OutOfMemory}!u32 {
    const order = try ctx.alloc.alloc(i32, ctx.n_labels);
    defer ctx.alloc.free(order);

    const maj = majority(ctx, pos, order);

    // pure -> leaf, checked BEFORE the no-features case
    if (isPure(ctx, pos)) {
        try ctx.tree.nodes.append(ctx.alloc, .{
            .leaf_label = if (pos.len > 0) ctx.labels[pos[0]] else maj,
            .feature = -1,
            .default_label = -1,
            .branch_start = 0,
            .branch_count = 0,
        });
        return @intCast(ctx.tree.nodes.items.len - 1);
    }
    if (feats.len == 0) {
        try ctx.tree.nodes.append(ctx.alloc, .{
            .leaf_label = maj,
            .feature = -1,
            .default_label = -1,
            .branch_start = 0,
            .branch_count = 0,
        });
        return @intCast(ctx.tree.nodes.items.len - 1);
    }

    const base = entropy(ctx, pos, order);
    const vals = try ctx.alloc.alloc(i32, ctx.n_values);
    defer ctx.alloc.free(vals);

    var best_f: usize = feats[0];
    var best_gain: f64 = -1;
    for (feats) |f| {
        // weighted entropy of the split on f
        const nv = valuesOf(ctx, pos, f, vals);
        var h: f64 = 0;
        const total: f64 = @floatFromInt(pos.len);
        for (vals[0..nv]) |v| {
            var sub = try std.ArrayList(u32).initCapacity(ctx.alloc, 0);
            defer sub.deinit(ctx.alloc);
            for (pos) |p| {
                if (ctx.feat[p * ctx.d + f] == v) try sub.append(ctx.alloc, p);
            }
            const w = @as(f64, @floatFromInt(sub.items.len)) / total;
            h += w * entropy(ctx, sub.items, order);
        }
        const gain = base - h;
        if (gain > best_gain) { // strict: the FIRST feature to reach the max wins
            best_gain = gain;
            best_f = f;
        }
    }

    const nv = valuesOf(ctx, pos, best_f, vals);

    // the remaining features, order preserved
    var rest = try std.ArrayList(u32).initCapacity(ctx.alloc, feats.len);
    defer rest.deinit(ctx.alloc);
    for (feats) |f| {
        if (f != best_f) try rest.append(ctx.alloc, f);
    }

    // reserve this node before recursing, so children get later indices
    try ctx.tree.nodes.append(ctx.alloc, .{
        .leaf_label = -1,
        .feature = @intCast(best_f),
        .default_label = maj,
        .branch_start = 0,
        .branch_count = 0,
    });
    const me: u32 = @intCast(ctx.tree.nodes.items.len - 1);

    const my_values = try ctx.alloc.alloc(i32, nv);
    defer ctx.alloc.free(my_values);
    @memcpy(my_values, vals[0..nv]);

    const children = try ctx.alloc.alloc(u32, nv);
    defer ctx.alloc.free(children);

    for (my_values, 0..) |v, bi| {
        var sub = try std.ArrayList(u32).initCapacity(ctx.alloc, 0);
        defer sub.deinit(ctx.alloc);
        for (pos) |p| {
            if (ctx.feat[p * ctx.d + best_f] == v) try sub.append(ctx.alloc, p);
        }
        children[bi] = try build(ctx, sub.items, rest.items);
    }

    const start: u32 = @intCast(ctx.tree.branch_values.items.len);
    for (my_values, 0..) |v, bi| {
        try ctx.tree.branch_values.append(ctx.alloc, v);
        try ctx.tree.branch_children.append(ctx.alloc, children[bi]);
    }
    ctx.tree.nodes.items[me].branch_start = start;
    ctx.tree.nodes.items[me].branch_count = @intCast(nv);
    return me;
}

/// Build an ID3 tree. `feat` is n*d feature codes (row-major, each 0..n_values-1),
/// `labels` is n label codes (each 0..n_labels-1). Caller owns the returned tree.
pub fn id3(
    alloc: std.mem.Allocator,
    feat: []const i32,
    labels: []const i32,
    n: usize,
    d: usize,
    n_labels: usize,
    n_values: usize,
) !Tree {
    var tree = Tree{
        .nodes = try std.ArrayList(Node).initCapacity(alloc, 0),
        .branch_values = try std.ArrayList(i32).initCapacity(alloc, 0),
        .branch_children = try std.ArrayList(u32).initCapacity(alloc, 0),
    };
    errdefer tree.deinit(alloc);

    const counts = try alloc.alloc(usize, @max(n_labels, 1));
    defer alloc.free(counts);
    const vcounts = try alloc.alloc(usize, @max(n_values, 1));
    defer alloc.free(vcounts);

    const pos = try alloc.alloc(u32, n);
    defer alloc.free(pos);
    for (0..n) |i| pos[i] = @intCast(i);

    const feats = try alloc.alloc(u32, d);
    defer alloc.free(feats);
    for (0..d) |i| feats[i] = @intCast(i);

    var ctx = Ctx{
        .feat = feat,
        .labels = labels,
        .n = n,
        .d = d,
        .n_labels = n_labels,
        .n_values = n_values,
        .alloc = alloc,
        .tree = &tree,
        .counts = counts,
        .vcounts = vcounts,
    };
    _ = try build(&ctx, pos, feats);
    return tree;
}

// ─── tests ───────────────────────────────────────────────────────────────────

test "a pure set is a single leaf" {
    const alloc = std.testing.allocator;
    const feat = [_]i32{ 0, 1, 1, 0 };
    const labels = [_]i32{ 0, 0 };
    var t = try id3(alloc, &feat, &labels, 2, 2, 1, 2);
    defer t.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 1), t.nodes.items.len);
    try std.testing.expectEqual(@as(i32, 0), t.nodes.items[0].leaf_label);
}

test "the weather example splits on outlook" {
    const alloc = std.testing.allocator;
    // outlook(0) humidity(1) wind(2); outlook: sunny=0 overcast=1 rain=2
    const feat = [_]i32{
        0, 0, 0, // sunny high weak    -> no
        0, 0, 1, // sunny high strong  -> no
        1, 0, 0, // overcast high weak -> yes
        2, 0, 0, // rain high weak     -> yes
        2, 1, 0, // rain normal weak   -> yes
        2, 1, 1, // rain normal strong -> no
        1, 1, 1, // overcast normal strong -> yes
        0, 1, 0, // sunny normal weak  -> yes
    };
    const labels = [_]i32{ 0, 0, 1, 1, 1, 0, 1, 1 };
    var t = try id3(alloc, &feat, &labels, 8, 3, 2, 3);
    defer t.deinit(alloc);
    try std.testing.expectEqual(@as(i32, 0), t.nodes.items[0].feature); // outlook
    try std.testing.expect(t.nodes.items[0].branch_count == 3);
}

test "branch values come out in first-seen order, not code order" {
    const alloc = std.testing.allocator;
    // one feature whose values appear as 2, 0, 1 -- the tree must list them that way
    const feat = [_]i32{ 2, 0, 1, 2, 0, 1 };
    const labels = [_]i32{ 0, 1, 2, 0, 1, 2 };
    var t = try id3(alloc, &feat, &labels, 6, 1, 3, 3);
    defer t.deinit(alloc);
    const root = t.nodes.items[0];
    try std.testing.expectEqual(@as(u32, 3), root.branch_count);
    const bv = t.branch_values.items[root.branch_start..][0..3];
    try std.testing.expectEqual(@as(i32, 2), bv[0]);
    try std.testing.expectEqual(@as(i32, 0), bv[1]);
    try std.testing.expectEqual(@as(i32, 1), bv[2]);
}

test "majority breaks ties toward the first label seen in the subset" {
    const alloc = std.testing.allocator;
    // two features that carry no information, labels evenly split: the root becomes
    // a decision node whose DEFAULT is the first-seen label
    const feat = [_]i32{ 0, 0, 0, 0, 0, 0, 0, 0 };
    const labels = [_]i32{ 1, 0, 1, 0 };
    var t = try id3(alloc, &feat, &labels, 4, 2, 2, 1);
    defer t.deinit(alloc);
    // all features useless -> the recursion exhausts them and leaves a majority leaf
    var found: i32 = -1;
    for (t.nodes.items) |nd| {
        if (nd.leaf_label >= 0) {
            found = nd.leaf_label;
            break;
        }
    }
    try std.testing.expectEqual(@as(i32, 1), found); // label 1 was seen first
}
