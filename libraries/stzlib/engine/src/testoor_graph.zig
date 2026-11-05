//! Testoor core -- the graph store (roadmap P3.3, TESTOOR_PROTOCOL_2.md sections 2 to 5).
//!
//! A program (or its face) hands Testoor its own graph; the core never reads source. This module
//! reads the graph record, compares two ids under the graph's declared fold and never parses
//! one, closes a change over its callers (the REACH), picks the tours that must be walked again,
//! and joins what a tour reported with what the graph owns into the nodes record.
//!
//! Nothing here imports Ring. Decisions P3.3 took where the draft left a gap, each pinned by a
//! golden under golden/protocol2/ or by a test below:
//!   * a node line `[testoor node ID]` is one hit and `[testoor node ID N]` is N hits; a line whose
//!     count is not a non-negative integer, or that has more than an id and a count, is IGNORED
//!   * a node is OBSERVED when its hits are above zero, NAMED when only the tour's source mentions
//!     its name, and is listed under the stronger of the two; a node with neither is not listed
//!   * with a graph, nodes are listed in the graph's order under the graph's spelling and an
//!     observed id the graph does not own is dropped; without one they are listed as reported,
//!     first seen first
//!   * a node may carry `name`, the identifier a tour mentions it by (default: its id)
//!   * the run's `named` counts nodes that were named and never observed; `observed` counts nodes
//!     observed; a node is in one of them at most, and neither is a percentage of `owned`

const std = @import("std");
const Allocator = std.mem.Allocator;
const J = @import("testoor_json.zig");
const T = @import("testoor_text.zig");

pub const Fold = enum { none, ascii };

/// two ids are the same under the fold: exact bytes, or A to Z folded to a to z and nothing else
pub fn sameId(fold: Fold, x: []const u8, y: []const u8) bool {
    if (x.len != y.len) return false;
    switch (fold) {
        .none => return std.mem.eql(u8, x, y),
        .ascii => {
            for (x, y) |p, q| {
                if (std.ascii.toLower(p) != std.ascii.toLower(q)) return false;
            }
            return true;
        },
    }
}

pub const Node = struct {
    id: []const u8,
    /// the identifier a tour mentions the node by; the id when the record gives none
    name: []const u8,
    kind: []const u8 = "",
    file: []const u8 = "",
    line: i64 = 0,
    open: bool = false,
};

pub const Edge = struct { from: []const u8, to: []const u8, kind: []const u8 = "", line: i64 = 0 };

pub const Graph = struct {
    subject: []const u8 = "",
    language: []const u8 = "",
    fold: Fold = .none,
    complete: bool = true,
    why: []const u8 = "",
    nodes: []const Node = &.{},
    edges: []const Edge = &.{},

    /// the index of the node with that id under the graph's fold
    pub fn indexOf(g: Graph, id: []const u8) ?usize {
        for (g.nodes, 0..) |n, i| if (sameId(g.fold, n.id, id)) return i;
        return null;
    }
};

/// A graph record, read. A key it does not know is ignored, a kind it does not know is kept as
/// text. COMPLETENESS is the load-bearing field: a record that says `complete:false`, or holds an
/// `open` node, is not complete; when no reason is given the first open node names one.
pub fn fromValue(a: Allocator, v: J.Value) !Graph {
    var g = Graph{};
    if (v.get("subject")) |x| g.subject = x.str_();
    if (v.get("language")) |x| g.language = x.str_();
    if (v.get("fold")) |x| {
        if (std.mem.eql(u8, x.str_(), "ascii")) g.fold = .ascii;
    }
    var complete = true;
    if (v.get("complete")) |x| complete = x.truthy();
    if (v.get("why")) |x| g.why = x.str_();
    var nodes: std.ArrayList(Node) = .empty;
    var first_open: ?Node = null;
    if (v.get("nodes")) |nv| {
        for (nv.items()) |n| {
            const id = (n.get("id") orelse continue).str_();
            const node = Node{
                .id = id,
                .name = if (n.get("name")) |x| x.str_() else id,
                .kind = if (n.get("kind")) |x| x.str_() else "",
                .file = if (n.get("file")) |x| x.str_() else "",
                .line = if (n.get("line")) |x| x.int_() else 0,
                .open = if (n.get("open")) |x| x.truthy() else false,
            };
            if (node.open) {
                complete = false;
                if (first_open == null) first_open = node;
            }
            try nodes.append(a, node);
        }
    }
    var edges: std.ArrayList(Edge) = .empty;
    if (v.get("edges")) |ev| {
        for (ev.items()) |e| {
            const from = (e.get("from") orelse continue).str_();
            const to = (e.get("to") orelse continue).str_();
            try edges.append(a, .{
                .from = from,
                .to = to,
                .kind = if (e.get("kind")) |x| x.str_() else "",
                .line = if (e.get("line")) |x| x.int_() else 0,
            });
        }
    }
    g.complete = complete;
    if (!complete and g.why.len == 0) {
        if (first_open) |n| {
            g.why = try std.fmt.allocPrint(a, "node {s} dispatches by a name built at run time (line {d})", .{ n.id, n.line });
        } else {
            g.why = "the graph is not complete";
        }
    }
    g.nodes = nodes.items;
    g.edges = edges.items;
    return g;
}

fn indexIn(fold: Fold, list: []const []const u8, id: []const u8) ?usize {
    for (list, 0..) |x, i| if (sameId(fold, x, id)) return i;
    return null;
}

/// The reach of a change: the ids that change, then the callers of those, then the callers of
/// those, in the order they were found. An edge counts when its `to` is an id already reached.
pub fn reach(a: Allocator, g: Graph, changed: []const []const u8) ![]const []const u8 {
    var out: std.ArrayList([]const u8) = .empty;
    for (changed) |c| {
        if (indexIn(g.fold, out.items, c) == null) try out.append(a, c);
    }
    var at: usize = 0;
    while (at < out.items.len) : (at += 1) {
        const cur = out.items[at];
        for (g.edges) |e| {
            if (sameId(g.fold, e.to, cur) and indexIn(g.fold, out.items, e.from) == null) try out.append(a, e.from);
        }
    }
    return out.items;
}

/// the names a tour would mention the reached ids by: a node's `name`, else the id itself; under
/// an `ascii` fold they are lower-cased, which is how a name is compared, and each appears once
pub fn reachNames(a: Allocator, g: Graph, ids: []const []const u8) ![]const []const u8 {
    var out: std.ArrayList([]const u8) = .empty;
    for (ids) |id| {
        const raw = if (g.indexOf(id)) |i| g.nodes[i].name else id;
        const nm = if (g.fold == .ascii) try T.lowerAscii(a, raw) else raw;
        if (indexIn(g.fold, out.items, nm) == null) try out.append(a, nm);
    }
    return out.items;
}

pub const TourNames = struct { file: []const u8, names: []const []const u8 };

pub const Impact = struct {
    subject: []const u8,
    changed: []const []const u8,
    complete: bool,
    why: []const u8,
    names: []const []const u8,
    selected: []const []const u8,
    skipped: []const []const u8,
};

/// Which tours a change obliges you to walk again. A graph that is not complete selects EVERY
/// tour and skips none: a selection is only as small as the graph is complete.
pub fn impact(a: Allocator, g: Graph, changed: []const []const u8, tours: []const TourNames) !Impact {
    const ids = try reach(a, g, changed);
    const names = try reachNames(a, g, ids);
    var sel: std.ArrayList([]const u8) = .empty;
    var skip: std.ArrayList([]const u8) = .empty;
    for (tours) |t| {
        var hit = !g.complete;
        if (!hit) {
            outer: for (t.names) |tn| {
                for (names) |rn| {
                    if (sameId(g.fold, tn, rn)) {
                        hit = true;
                        break :outer;
                    }
                }
            }
        }
        if (hit) try sel.append(a, t.file) else try skip.append(a, t.file);
    }
    return .{ .subject = g.subject, .changed = changed, .complete = g.complete, .why = g.why, .names = names, .selected = sel.items, .skipped = skip.items };
}

fn strArr(b: *T.Buf, items: []const []const u8) !void {
    try b.c('[');
    for (items, 0..) |s, k| {
        if (k > 0) try b.c(',');
        try b.js(s);
    }
    try b.c(']');
}

/// the impact record (protocol 2 section 5), one JSON document
pub fn impactJson(b: *T.Buf, im: Impact) !void {
    try b.s("{\"testoor\":\"logbook\",\"kind\":\"impact\",\"protocol\":2,\"subject\":");
    try b.js(im.subject);
    try b.s(",\"changed\":");
    try strArr(b, im.changed);
    try b.s(",\"method\":");
    try b.js(if (im.changed.len > 0) im.changed[0] else "");
    try b.s(",\"complete\":");
    try b.s(if (im.complete) "true" else "false");
    try b.s(",\"why\":");
    try b.js(im.why);
    try b.s(",\"names\":");
    try strArr(b, im.names);
    try b.s(",\"selected\":");
    try strArr(b, im.selected);
    try b.s(",\"skipped\":");
    try strArr(b, im.skipped);
    try b.c('}');
}

// ── what a tour reported, and what it named ──────────────────

/// a node a tour reported reaching, with how many times
pub const Hit = struct { id: []const u8, hits: i64 };

/// one row of a tour's nodes record
pub const NodeEv = struct { id: []const u8, evidence: []const u8, hits: i64 };

const max_count_digits = 15;

/// A `[testoor node ID]` or `[testoor node ID N]` line, or null when the line is not one or its
/// count is malformed (a malformed line is ignored and stays ordinary output). `t` is trimmed.
pub fn parseNodeLine(t: []const u8) ?Hit {
    const open = "[testoor node ";
    if (!T.startsWith(t, open)) return null;
    if (t.len < open.len + 1 or t[t.len - 1] != ']') return null;
    const inner = T.trimSp(t[open.len .. t.len - 1]);
    var it = std.mem.tokenizeScalar(u8, inner, ' ');
    const id = it.next() orelse return null;
    const count = it.next() orelse return .{ .id = id, .hits = 1 };
    if (it.next() != null) return null;
    if (count.len == 0 or count.len > max_count_digits) return null;
    var n: i64 = 0;
    for (count) |ch| {
        if (ch < '0' or ch > '9') return null;
        n = n * 10 + (ch - '0');
    }
    return .{ .id = id, .hits = n };
}

/// The nodes record of one tour. With a graph the rows follow the graph's order and spelling;
/// without one, the ids as the tour reported them, first seen first.
pub fn nodeEvidence(a: Allocator, g: ?Graph, reported: []const Hit, names: []const []const u8) ![]const NodeEv {
    var out: std.ArrayList(NodeEv) = .empty;
    if (g) |gr| {
        for (gr.nodes) |n| {
            var hits: i64 = 0;
            for (reported) |h| if (sameId(gr.fold, h.id, n.id)) {
                hits +|= h.hits;
            };
            if (hits > 0) {
                try out.append(a, .{ .id = n.id, .evidence = "observed", .hits = hits });
                continue;
            }
            var named = false;
            for (names) |nm| if (sameId(gr.fold, nm, n.name)) {
                named = true;
                break;
            };
            if (named) try out.append(a, .{ .id = n.id, .evidence = "named", .hits = 0 });
        }
        return out.items;
    }
    for (reported) |h| {
        var seen = false;
        for (out.items) |*o| if (std.mem.eql(u8, o.id, h.id)) {
            o.hits +|= h.hits;
            seen = true;
            break;
        };
        // a first report of zero hits proves nothing, but a later report may add to it
        if (!seen) try out.append(a, .{ .id = h.id, .evidence = "observed", .hits = h.hits });
    }
    // drop the ones that never got a hit
    var kept: std.ArrayList(NodeEv) = .empty;
    for (out.items) |o| if (o.hits > 0) try kept.append(a, o);
    return kept.items;
}

// ── tests ────────────────────────────────────────────────────

const testing = std.testing;

test "ids compare under the declared fold and nothing else" {
    try testing.expect(sameId(.none, "Total", "Total"));
    try testing.expect(!sameId(.none, "Total", "total"));
    try testing.expect(sameId(.ascii, "Total", "tOTAL"));
    try testing.expect(!sameId(.ascii, "Éa", "éa")); // A to Z only: non-ASCII letters are not folded
    try testing.expect(!sameId(.ascii, "ab", "abc"));
}

test "a node line is one hit, or the count it carries, or it is ignored" {
    try testing.expectEqual(@as(i64, 1), parseNodeLine("[testoor node a.b]").?.hits);
    try testing.expectEqualStrings("a.b", parseNodeLine("[testoor node a.b]").?.id);
    try testing.expectEqual(@as(i64, 7), parseNodeLine("[testoor node a.b 7]").?.hits);
    try testing.expectEqual(@as(i64, 0), parseNodeLine("[testoor node a.b 0]").?.hits);
    try testing.expectEqual(@as(i64, 3), parseNodeLine("[testoor node   a.b   3 ]").?.hits);
    try testing.expect(parseNodeLine("[testoor node a.b x]") == null);
    try testing.expect(parseNodeLine("[testoor node a.b -1]") == null);
    try testing.expect(parseNodeLine("[testoor node a.b 1.5]") == null);
    try testing.expect(parseNodeLine("[testoor node a.b 1 2]") == null);
    try testing.expect(parseNodeLine("[testoor node a.b 1234567890123456]") == null); // too many digits
    try testing.expect(parseNodeLine("[testoor node]") == null);
    try testing.expect(parseNodeLine("[testoor node ]") == null);
    try testing.expect(parseNodeLine("[testoor node a.b") == null);
    try testing.expect(parseNodeLine("[testoor route a.b]") == null);
}

test "the graph record: unknown keys are ignored, an open node makes it incomplete and names the cause" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const doc =
        \\{"testoor":"graph","protocol":2,"fold":"ascii","future":1,
        \\ "nodes":[{"id":"f.A","name":"A","line":3,"colour":"red"},{"id":"f.B","open":true,"line":9}],
        \\ "edges":[{"from":"f.B","to":"f.A","kind":"call","line":10},{"to":"no-from"}]}
    ;
    const g = try fromValue(a, try J.parse(a, doc));
    try testing.expect(!g.complete);
    try testing.expectEqualStrings("node f.B dispatches by a name built at run time (line 9)", g.why);
    try testing.expectEqual(@as(usize, 2), g.nodes.len);
    try testing.expectEqualStrings("A", g.nodes[0].name);
    try testing.expectEqualStrings("f.B", g.nodes[1].name); // no name given: the id
    try testing.expectEqual(@as(usize, 1), g.edges.len); // an edge with no `from` is dropped
    // a record that says complete:false keeps its own reason
    const g2 = try fromValue(a, try J.parse(a, "{\"complete\":false,\"why\":\"gave up at line 4\"}"));
    try testing.expect(!g2.complete);
    try testing.expectEqualStrings("gave up at line 4", g2.why);
    // an empty record is a complete, empty graph
    const g3 = try fromValue(a, try J.parse(a, "{}"));
    try testing.expect(g3.complete);
}

test "the reach is the closure of callers, found in order, and a cycle ends" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const g = Graph{ .fold = .ascii, .edges = &.{
        .{ .from = "B", .to = "A" },
        .{ .from = "C", .to = "B" },
        .{ .from = "A", .to = "C" }, // a cycle back
        .{ .from = "D", .to = "Z" },
    } };
    const r = try reach(a, g, &.{"a"});
    try testing.expectEqual(@as(usize, 3), r.len);
    try testing.expectEqualStrings("a", r[0]);
    try testing.expectEqualStrings("B", r[1]);
    try testing.expectEqualStrings("C", r[2]);
    // two changed ids, none repeated
    const r2 = try reach(a, g, &.{ "Z", "z", "A" });
    try testing.expectEqual(@as(usize, 5), r2.len); // Z, A, D, B, C
}

test "a complete graph selects by name; an incomplete one selects every tour" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var g = Graph{ .fold = .ascii, .edges = &.{.{ .from = "Caller", .to = "Callee" }} };
    const tours = [_]TourNames{
        .{ .file = "t1", .names = &.{"callee"} },
        .{ .file = "t2", .names = &.{"CALLER"} },
        .{ .file = "t3", .names = &.{"other"} },
        .{ .file = "t4", .names = &.{} },
    };
    const im = try impact(a, g, &.{"Callee"}, &tours);
    try testing.expectEqual(@as(usize, 2), im.selected.len);
    try testing.expectEqual(@as(usize, 2), im.skipped.len);
    g.complete = false;
    g.why = "open";
    const all = try impact(a, g, &.{"Callee"}, &tours);
    try testing.expectEqual(@as(usize, 4), all.selected.len);
    try testing.expectEqual(@as(usize, 0), all.skipped.len);
}

test "evidence: observed beats named, order follows the graph, an unknown id is dropped" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const g = Graph{ .fold = .ascii, .nodes = &.{
        .{ .id = "x.One", .name = "One" },
        .{ .id = "x.Two", .name = "Two" },
        .{ .id = "x.Three", .name = "Three" },
    } };
    const rep = [_]Hit{ .{ .id = "X.TWO", .hits = 2 }, .{ .id = "x.two", .hits = 1 }, .{ .id = "ghost", .hits = 9 }, .{ .id = "x.Three", .hits = 0 } };
    const ev = try nodeEvidence(a, g, &rep, &.{ "one", "THREE", "two" });
    try testing.expectEqual(@as(usize, 3), ev.len);
    try testing.expectEqualStrings("x.One", ev[0].id);
    try testing.expectEqualStrings("named", ev[0].evidence);
    try testing.expectEqualStrings("x.Two", ev[1].id);
    try testing.expectEqualStrings("observed", ev[1].evidence);
    try testing.expectEqual(@as(i64, 3), ev[1].hits);
    try testing.expectEqualStrings("x.Three", ev[2].id); // zero hits, but named
    try testing.expectEqualStrings("named", ev[2].evidence);
}

test "without a graph the ids are listed as reported, first seen first, and a zero proves nothing" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const rep = [_]Hit{ .{ .id = "b", .hits = 0 }, .{ .id = "a", .hits = 1 }, .{ .id = "b", .hits = 2 }, .{ .id = "c", .hits = 0 }, .{ .id = "A", .hits = 1 } };
    const ev = try nodeEvidence(a, null, &rep, &.{"a"});
    try testing.expectEqual(@as(usize, 3), ev.len);
    try testing.expectEqualStrings("b", ev[0].id);
    try testing.expectEqual(@as(i64, 2), ev[0].hits);
    try testing.expectEqualStrings("a", ev[1].id);
    try testing.expectEqualStrings("A", ev[2].id); // no graph, no fold: a different id
}
