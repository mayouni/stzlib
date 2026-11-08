//! Testoor core -- THE EVIDENCE LADDER, step V1 (TESTOOR_EVIDENCE_LADDER.md, TESTOOR_PROTOCOL_3.md section 2).
//!
//! For each node of the graph, the highest grade of evidence the run holds, and the tours that gave it:
//!
//!   0 named        the graph holds the node (counted, never listed: owned minus the listed rows)
//!   1 observed     a tour reached it (`[testoor node ID]`, hits above zero)
//!   2 exemplified  a tour that EXEMPLIFIES reached it
//!
//! A tour exemplifies when it kept at least one claim and did not fail: no claim diverged or unreached,
//! not flaky, and it finished (timed or not). The same definition of failure as the tour line's seed.
//! A tour's own `named` evidence (its source mentions the node) is a proxy and raises no grade.
//!
//!   3 generalised  a property HELD over generated inputs, in a tour that did not fail, about the node (V2)
//!   4 exhausted    the same, over every value of a finite domain (V2)
//!
//! A property raises the nodes its line names that the same tour observed, or, naming none, every node that tour
//! observed: it cannot raise a node no tour reached. Grade 5 (proved) is V5. Nothing here reads a clock or a file.

const std = @import("std");
const T = @import("testoor_text.zig");
const V = @import("testoor_verdict.zig");

const Allocator = std.mem.Allocator;
const Buf = T.Buf;

pub const Grade = enum(u8) {
    named,
    observed,
    exemplified,
    generalised,
    exhausted,

    pub fn name(self: Grade) []const u8 {
        return switch (self) {
            .named => "named",
            .observed => "observed",
            .exemplified => "exemplified",
            .generalised => "generalised",
            .exhausted => "exhausted",
        };
    }
    fn above(self: Grade, other: Grade) bool {
        return @intFromEnum(self) > @intFromEnum(other);
    }
};

pub const Row = struct {
    id: []const u8,
    grade: Grade,
    /// the tours that gave the node its grade, in run order, each once
    tours: std.ArrayList([]const u8) = .empty,
    /// grades 3 and 4: the properties that gave it, in run order, each once
    properties: std.ArrayList([]const u8) = .empty,
};

pub const Ladder = struct {
    rows: []Row,
    observed: i64,
    exemplified: i64,
    generalised: i64 = 0,
    exhausted: i64 = 0,
    /// any tour of the run printed a property: the counts of grades 3 and 4 are then written, zeros included
    with_properties: bool = false,
};

fn eq(x: []const u8, y: []const u8) bool {
    return std.mem.eql(u8, x, y);
}

/// a tour that did not fail: no claim diverged or unreached, not flaky, finished
pub fn holdsUp(t: V.Tour) bool {
    const r = t.run;
    if (t.flaky) return false;
    if (r.diverged > 0 or r.unreached > 0) return false;
    return eq(r.end, "finished") or eq(r.end, "finished-timed");
}

/// a tour that kept a claim and did not fail
pub fn exemplifies(t: V.Tour) bool {
    return holdsUp(t) and t.run.kept >= 1;
}

fn addOnce(a: Allocator, list: *std.ArrayList([]const u8), x: []const u8) !void {
    for (list.items) |f| if (eq(f, x)) return;
    try list.append(a, x);
}

fn propertyAbout(nodes: ?[]const []const u8, id: []const u8) bool {
    const ns = nodes orelse return true;
    for (ns) |n| if (eq(n, id)) return true;
    return false;
}

/// Rows in the order the run first OBSERVED each node (tours in run order, each tour's nodes in its own
/// order, which is the graph's when it had one). Ids are compared exactly: with a graph they are already
/// the graph's spelling, and without one there is no fold to apply.
pub fn build(a: Allocator, tours: []const V.Tour) !Ladder {
    var rows: std.ArrayList(Row) = .empty;
    var index: std.StringHashMapUnmanaged(usize) = .empty;
    var with_props = false;
    for (tours) |t| {
        if (t.properties.len > 0) with_props = true;
        const ex = exemplifies(t);
        const up = holdsUp(t);
        for (t.nodes) |n| {
            if (!eq(n.evidence, "observed") or n.hits <= 0) continue;
            // the grade THIS tour gives the node, and the properties that gave it
            var g: Grade = if (ex) .exemplified else .observed;
            var by: std.ArrayList([]const u8) = .empty;
            if (up) for (t.properties) |pr| {
                if (!pr.held or !propertyAbout(pr.nodes, n.id)) continue;
                const pg: Grade = if (pr.exhaustive) .exhausted else .generalised;
                if (pg.above(g)) {
                    g = pg;
                    by.clearRetainingCapacity();
                }
                if (pg == g) try addOnce(a, &by, pr.id);
            };
            const gop = try index.getOrPut(a, n.id);
            if (!gop.found_existing) {
                gop.value_ptr.* = rows.items.len;
                try rows.append(a, .{ .id = n.id, .grade = g });
            }
            const row = &rows.items[gop.value_ptr.*];
            if (g.above(row.grade)) {
                row.grade = g;
                row.tours.clearRetainingCapacity();
                row.properties.clearRetainingCapacity();
            }
            if (g == row.grade) {
                try addOnce(a, &row.tours, t.file);
                for (by.items) |id| try addOnce(a, &row.properties, id);
            }
        }
    }
    var l = Ladder{ .rows = rows.items, .observed = 0, .exemplified = 0, .with_properties = with_props };
    for (rows.items) |r| switch (r.grade) {
        .observed => l.observed += 1,
        .exemplified => l.exemplified += 1,
        .generalised => l.generalised += 1,
        .exhausted => l.exhausted += 1,
        .named => {},
    };
    return l;
}

/// grade 0: the owned nodes no tour reached; never below zero, whatever `owned` the runner was told
pub fn namedCount(l: Ladder, owned: i64) i64 {
    const listed: i64 = @intCast(l.rows.len);
    return if (owned > listed) owned - listed else 0;
}

/// `"ladder":{...}` without its key. `owned` is the graph's size when the run had a graph, else null,
/// and then `owned` and `named` are absent: grade 0 cannot be counted without a graph.
pub fn writeJson(b: *Buf, l: Ladder, owned: ?i64) !void {
    try b.c('{');
    if (owned) |w| {
        try b.s("\"owned\":");
        try b.int(w);
        try b.s(",\"named\":");
        try b.int(namedCount(l, w));
        try b.c(',');
    }
    try b.s("\"observed\":");
    try b.int(l.observed);
    try b.s(",\"exemplified\":");
    try b.int(l.exemplified);
    if (l.with_properties) {
        try b.s(",\"generalised\":");
        try b.int(l.generalised);
        try b.s(",\"exhausted\":");
        try b.int(l.exhausted);
    }
    try b.s(",\"nodes\":[");
    for (l.rows, 0..) |r, k| {
        if (k > 0) try b.c(',');
        try b.s("{\"id\":");
        try b.js(r.id);
        try b.s(",\"grade\":");
        try b.js(r.grade.name());
        try b.s(",\"tours\":[");
        for (r.tours.items, 0..) |f, j| {
            if (j > 0) try b.c(',');
            try b.js(f);
        }
        try b.c(']');
        if (r.grade.above(.exemplified)) {
            try b.s(",\"properties\":[");
            for (r.properties.items, 0..) |id, j| {
                if (j > 0) try b.c(',');
                try b.js(id);
            }
            try b.c(']');
        }
        try b.c('}');
    }
    try b.s("]}");
}

/// the summary line, without its leading newline and indent
pub fn writeProse(b: *Buf, l: Ladder, owned: ?i64) !void {
    try b.s("ladder: ");
    if (l.with_properties) {
        try b.int(l.exhausted);
        try b.s(" exhausted, ");
        try b.int(l.generalised);
        try b.s(" generalised, ");
    }
    try b.int(l.exemplified);
    try b.s(" exemplified, ");
    try b.int(l.observed);
    try b.s(" observed");
    if (owned) |w| {
        try b.s(", ");
        try b.int(namedCount(l, w));
        try b.s(" named, of ");
        try b.int(w);
        try b.s(" owned");
    } else {
        try b.s("; no graph, so named nodes are not counted");
    }
}

// ── tests ────────────────────────────────────────────────────

const testing = std.testing;
const G = @import("testoor_graph.zig");

fn tour(file: []const u8, end: []const u8, kept: i64, div: i64, unr: i64, flaky: bool, nodes: []const G.NodeEv) V.Tour {
    return .{
        .file = file,
        .dialect = "protocol",
        .flaky = flaky,
        .weather = &.{},
        .routes = &.{},
        .nodes = nodes,
        .run = .{ .end = end, .exit = 0, .wall_ms = 0, .seed = null, .state = .kept, .kept = kept, .diverged = div, .unreached = unr, .unjudged = 0, .stops = &.{} },
    };
}

test "a tour exemplifies only when it kept a claim and did not fail" {
    try testing.expect(exemplifies(tour("a", "finished", 1, 0, 0, false, &.{})));
    try testing.expect(exemplifies(tour("a", "finished-timed", 3, 0, 0, false, &.{})));
    try testing.expect(!exemplifies(tour("a", "finished", 0, 0, 0, false, &.{}))); // judged nothing
    try testing.expect(!exemplifies(tour("a", "finished", 2, 1, 0, false, &.{}))); // a claim diverged
    try testing.expect(!exemplifies(tour("a", "finished", 2, 0, 1, false, &.{}))); // a claim unreached
    try testing.expect(!exemplifies(tour("a", "finished", 2, 0, 0, true, &.{}))); // flaky
    try testing.expect(!exemplifies(tour("a", "broke", 2, 0, 0, false, &.{}))); // did not finish
    try testing.expect(!exemplifies(tour("a", "hung", 2, 0, 0, false, &.{})));
}

test "a node takes its highest grade, and only the tours that gave it" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const n_ab = [_]G.NodeEv{ .{ .id = "A", .evidence = "observed", .hits = 1 }, .{ .id = "B", .evidence = "observed", .hits = 4 } };
    const n_a = [_]G.NodeEv{.{ .id = "A", .evidence = "observed", .hits = 2 }};
    const n_c = [_]G.NodeEv{ .{ .id = "C", .evidence = "named", .hits = 0 }, .{ .id = "B", .evidence = "observed", .hits = 0 } };
    const tours = [_]V.Tour{
        tour("bad", "finished", 1, 1, 0, false, &n_ab), // diverged: A and B observed
        tour("good", "finished", 1, 0, 0, false, &n_a), // A exemplified, "bad" leaves A's list
        tour("good", "finished", 1, 0, 0, false, &n_a), // the same file again is listed once
        tour("namer", "finished", 1, 0, 0, false, &n_c), // a mention and a zero count raise nothing
    };
    const l = try build(a, &tours);
    try testing.expectEqual(@as(usize, 2), l.rows.len);
    try testing.expectEqualStrings("A", l.rows[0].id);
    try testing.expectEqual(Grade.exemplified, l.rows[0].grade);
    try testing.expectEqual(@as(usize, 1), l.rows[0].tours.items.len);
    try testing.expectEqualStrings("good", l.rows[0].tours.items[0]);
    try testing.expectEqualStrings("B", l.rows[1].id);
    try testing.expectEqual(Grade.observed, l.rows[1].grade);
    try testing.expectEqualStrings("bad", l.rows[1].tours.items[0]);
    try testing.expectEqual(@as(i64, 1), l.observed);
    try testing.expectEqual(@as(i64, 1), l.exemplified);
    try testing.expectEqual(@as(i64, 4), namedCount(l, 6));
    try testing.expectEqual(@as(i64, 0), namedCount(l, 1)); // a runner told too small a graph: never negative
}

test "the record with and without a graph, and an empty run" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const n_a = [_]G.NodeEv{.{ .id = "A\"x", .evidence = "observed", .hits = 1 }};
    const tours = [_]V.Tour{tour("t.py", "finished", 1, 0, 0, false, &n_a)};
    const l = try build(a, &tours);
    var b = Buf.init(a);
    try writeJson(&b, l, 3);
    try testing.expectEqualStrings("{\"owned\":3,\"named\":2,\"observed\":0,\"exemplified\":1,\"nodes\":[{\"id\":\"A\\\"x\",\"grade\":\"exemplified\",\"tours\":[\"t.py\"]}]}", try b.done());
    var p = Buf.init(a);
    try writeProse(&p, l, null);
    try testing.expectEqualStrings("ladder: 1 exemplified, 0 observed; no graph, so named nodes are not counted", try p.done());
    const empty = try build(a, &.{});
    var e = Buf.init(a);
    try writeJson(&e, empty, null);
    try testing.expectEqualStrings("{\"observed\":0,\"exemplified\":0,\"nodes\":[]}", try e.done());
}
