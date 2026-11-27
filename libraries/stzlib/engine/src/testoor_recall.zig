//! Testoor core -- the graph's recall, measured by a walk (roadmap P4, TESTOOR_PROTOCOL_3.md section 6.10).
//!
//! `testoor impact` selects from the graph alone the tours a change obliges you to walk again. A tour is selected when a
//! name it mentions names a node the change reaches through its callers: the BOUND selection. A graph that is not complete
//! selects every tour, which is safe and selects nothing away. Whether the bound selection would be safe is a question about
//! the graph's edges, and one walk of a probed codebase (section 6.8) answers it for every function at once: a tour that RAN
//! a function is a tour a change to that function can affect, so the tour must be among those the change selects.
//!
//! For each tour of a logbook: the functions it ran (its `observed` nodes), the functions its names reach (forward along the
//! edges from every node one of its names names -- the same tours `impact` selects, function by function, which a test
//! below checks), and the functions it ran outside them, MISSED: a change to one of those would leave the tour unselected.
//! A missed function none of whose callers in the graph the tour ran is an ENTRY: the run went into it by a call the graph
//! does not hold. Every other missed function has a missed caller the tour ran, so it is reached from an entry. An entry the
//! graph gives no caller at all is called by nothing the graph holds (a constructor, an operator, a name built at run time).
//!
//! A FILE'S OWN STATEMENTS are reached by every tour: a tour of the unit loads the unit, and loading a file runs its own
//! statements, so `impact` selects every tour for a change they reach (testoor_graph.zig), and here every node of kind
//! `top` is a seed of every tour. The probe observes no such node -- it holds no function -- so it is never among a tour's
//! ran; what it calls is bound for every tour. Measured on the library (2026-11-27), they were 61 percent of the pairs
//! beyond the names while the graph held no node for them.
//!
//! The record does not say which call reached an entry: a probe writes each function's first hit, not its caller. It says
//! how many open functions the tour ran (`open_ran`), since an open function calls by a name the graph cannot see, and so
//! may have made the call.

const std = @import("std");
const Allocator = std.mem.Allocator;
const G = @import("testoor_graph.zig");
const T = @import("testoor_text.zig");

/// one walked tour: its file, the names its source mentions, and the ids it ran (the logbook's observed nodes)
pub const TourRun = struct { file: []const u8, names: []const []const u8, ran: []const []const u8 };

pub const TourRecall = struct {
    file: []const u8,
    /// the ids the tour ran that the graph owns, in the logbook's order
    ran: usize,
    /// of those, the ids its names reach: a change to one of them selects the tour
    bound: usize,
    missed: []const []const u8,
    entries: []const []const u8,
    /// the open functions the tour ran: each calls by a name the graph cannot see
    open_ran: usize,
};

pub const Entry = struct { id: []const u8, callers: usize, tours: usize };

pub const Recall = struct {
    subject: []const u8,
    complete: bool,
    why: []const u8,
    tours: []const TourRecall,
    /// ids the logbook names that the graph does not own: left out of every count
    unowned: usize,
    pairs_ran: usize,
    pairs_bound: usize,
    functions_owned: usize,
    functions_ran: usize,
    functions_missed: usize,
    /// every entry, the tours it is one of first, then the order it was met
    entries: []const Entry,
};

const IdSet = std.HashMapUnmanaged([]const u8, void, G.IdCtx, 80);

/// The ids a tour's names reach: every id whose name one of the names is, then the ids those call, then the ids those call.
/// `impact` selects the tour for a change to an id exactly when the id is among them: a change reaches its callers, and a
/// tour is selected when one of its names names one of them.
pub fn reachedBy(a: Allocator, g: G.Graph, names: []const []const u8) !IdSet {
    const ix = try G.ixOf(a, g);
    const ctx = G.IdCtx{ .fold = g.fold };
    var wanted: IdSet = .{};
    for (names) |n| try wanted.putContext(a, n, {}, ctx);
    var seen: IdSet = .{};
    var queue: std.ArrayList([]const u8) = .empty;
    // the seeds: a node by its name, and an id an edge names that is no node, by itself (as `reachNames` names it)
    for (g.nodes) |n| {
        if (!wanted.containsContext(n.name, ctx)) continue;
        if ((try seen.getOrPutContext(a, n.id, ctx)).found_existing) continue;
        try queue.append(a, n.id);
    }
    for (g.edges) |e| {
        for ([_][]const u8{ e.from, e.to }) |id| {
            if (g.indexOf(id) != null or !wanted.containsContext(id, ctx)) continue;
            if ((try seen.getOrPutContext(a, id, ctx)).found_existing) continue;
            try queue.append(a, id);
        }
    }
    // every file's own statements: a tour loads the unit, whatever it names
    for (g.nodes) |n| {
        if (!G.isTop(n)) continue;
        if ((try seen.getOrPutContext(a, n.id, ctx)).found_existing) continue;
        try queue.append(a, n.id);
    }
    var at: usize = 0;
    while (at < queue.items.len) : (at += 1) {
        for (G.edgesOutOf(ix, g, queue.items[at])) |k| {
            const to = g.edges[k].to;
            if ((try seen.getOrPutContext(a, to, ctx)).found_existing) continue;
            try queue.append(a, to);
        }
    }
    return seen;
}

/// the recall of the bound selection over the tours of one walk
pub fn recall(a: Allocator, g: G.Graph, runs: []const TourRun) !Recall {
    const ix = try G.ixOf(a, g);
    const ctx = G.IdCtx{ .fold = g.fold };
    var out: std.ArrayList(TourRecall) = .empty;
    var unowned: usize = 0;
    var pairs_ran: usize = 0;
    var pairs_bound: usize = 0;
    var ran_any: IdSet = .{};
    var missed_any: IdSet = .{};
    var entry_at: std.HashMapUnmanaged([]const u8, usize, G.IdCtx, 80) = .{};
    var entries: std.ArrayList(Entry) = .empty;
    for (runs) |r| {
        const reached = try reachedBy(a, g, r.names);
        // what the tour ran, in the graph's spelling, once each
        var ran: IdSet = .{};
        var ran_list: std.ArrayList([]const u8) = .empty;
        for (r.ran) |id| {
            const i = g.indexOf(id) orelse {
                unowned += 1;
                continue;
            };
            const c = g.nodes[i].id;
            if ((try ran.getOrPutContext(a, c, ctx)).found_existing) continue;
            try ran_list.append(a, c);
        }
        var bound: usize = 0;
        var open_ran: usize = 0;
        var missed: std.ArrayList([]const u8) = .empty;
        for (ran_list.items) |id| {
            if (g.nodes[g.indexOf(id).?].open) open_ran += 1;
            try ran_any.putContext(a, id, {}, ctx);
            if (reached.containsContext(id, ctx)) {
                bound += 1;
            } else {
                try missed.append(a, id);
                try missed_any.putContext(a, id, {}, ctx);
            }
        }
        // an entry: a missed id none of whose callers the tour ran
        var tour_entries: std.ArrayList([]const u8) = .empty;
        for (missed.items) |id| {
            var called_by_ran = false;
            for (G.edgesInto(ix, g, id)) |k| {
                if (ran.containsContext(g.edges[k].from, ctx)) {
                    called_by_ran = true;
                    break;
                }
            }
            if (called_by_ran) continue;
            try tour_entries.append(a, id);
            const gop = try entry_at.getOrPutContext(a, id, ctx);
            if (gop.found_existing) {
                entries.items[gop.value_ptr.*].tours += 1;
            } else {
                gop.value_ptr.* = entries.items.len;
                try entries.append(a, .{ .id = id, .callers = try callerCount(a, g, ix, id), .tours = 1 });
            }
        }
        pairs_ran += ran_list.items.len;
        pairs_bound += bound;
        try out.append(a, .{ .file = r.file, .ran = ran_list.items.len, .bound = bound, .missed = missed.items, .entries = tour_entries.items, .open_ran = open_ran });
    }
    // the entries most tours share first; a tie keeps the order they were met
    std.mem.sort(Entry, entries.items, {}, struct {
        fn lt(_: void, x: Entry, y: Entry) bool {
            return x.tours > y.tours;
        }
    }.lt);
    return .{
        .subject = g.subject,
        .complete = g.complete,
        .why = g.why,
        .tours = out.items,
        .unowned = unowned,
        .pairs_ran = pairs_ran,
        .pairs_bound = pairs_bound,
        .functions_owned = g.nodes.len,
        .functions_ran = ran_any.count(),
        .functions_missed = missed_any.count(),
        .entries = entries.items,
    };
}

/// the distinct ids the graph says call `id`
fn callerCount(a: Allocator, g: G.Graph, ix: *const G.Index, id: []const u8) !usize {
    var seen: IdSet = .{};
    for (G.edgesInto(ix, g, id)) |k| try seen.putContext(a, g.edges[k].from, {}, .{ .fold = g.fold });
    return seen.count();
}

fn strArr(b: *T.Buf, items: []const []const u8) !void {
    try b.c('[');
    for (items, 0..) |s, k| {
        if (k > 0) try b.c(',');
        try b.js(s);
    }
    try b.c(']');
}

/// the recall record, one JSON document
pub fn recallJson(b: *T.Buf, r: Recall) !void {
    try b.s("{\"testoor\":\"logbook\",\"kind\":\"recall\",\"protocol\":3,\"subject\":");
    try b.js(r.subject);
    try b.s(",\"complete\":");
    try b.s(if (r.complete) "true" else "false");
    try b.s(",\"why\":");
    try b.js(r.why);
    try b.s(",\"pairs\":{\"ran\":");
    try b.int(@intCast(r.pairs_ran));
    try b.s(",\"bound\":");
    try b.int(@intCast(r.pairs_bound));
    try b.s(",\"missed\":");
    try b.int(@intCast(r.pairs_ran - r.pairs_bound));
    try b.s("},\"functions\":{\"owned\":");
    try b.int(@intCast(r.functions_owned));
    try b.s(",\"ran\":");
    try b.int(@intCast(r.functions_ran));
    try b.s(",\"missed\":");
    try b.int(@intCast(r.functions_missed));
    try b.s("},\"unowned\":");
    try b.int(@intCast(r.unowned));
    try b.s(",\"entries\":[");
    for (r.entries, 0..) |e, k| {
        if (k > 0) try b.c(',');
        try b.s("{\"id\":");
        try b.js(e.id);
        try b.s(",\"callers\":");
        try b.int(@intCast(e.callers));
        try b.s(",\"tours\":");
        try b.int(@intCast(e.tours));
        try b.c('}');
    }
    try b.s("],\"tours\":[");
    for (r.tours, 0..) |t, k| {
        if (k > 0) try b.c(',');
        try b.s("{\"file\":");
        try b.js(t.file);
        try b.s(",\"ran\":");
        try b.int(@intCast(t.ran));
        try b.s(",\"bound\":");
        try b.int(@intCast(t.bound));
        try b.s(",\"open_ran\":");
        try b.int(@intCast(t.open_ran));
        try b.s(",\"entries\":");
        try strArr(b, t.entries);
        try b.s(",\"missed\":");
        try strArr(b, t.missed);
        try b.c('}');
    }
    try b.s("]}");
}

// ---------------------------------------------------------------------------------------------------------------------
const testing = std.testing;
const J = @import("testoor_json.zig");

fn graphOf(a: Allocator, text: []const u8) !G.Graph {
    return G.fromValue(a, try J.parse(a, text));
}

test "A TOUR RUNS WHAT ITS NAMES REACH, AND WHAT IT RAN BEYOND THAT IS MISSED: the entry is the one no ran caller calls" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    // Total calls Rate; Rate calls Round. Make is called by nothing the graph holds (a constructor), and calls Check.
    const g = try graphOf(a,
        \\{"fold":"ascii","nodes":[{"id":"stzTax.Total","name":"Total"},{"id":"stzTax.Rate","name":"Rate"},
        \\{"id":"stzTax.Round","name":"Round"},{"id":"stzTax.init","name":"init"},{"id":"stzTax.Check","name":"Check"}],
        \\"edges":[{"from":"stzTax.Total","to":"stzTax.Rate"},{"from":"stzTax.Rate","to":"stzTax.Round"},
        \\{"from":"stzTax.init","to":"stzTax.Check"}]}
    );
    const runs = [_]TourRun{.{
        .file = "t.haro",
        .names = &.{ "total", "stzTax" },
        .ran = &.{ "stzTax.init", "stzTax.Check", "STZTAX.TOTAL", "stzTax.Rate", "stzTax.Round", "elsewhere.F" },
    }};
    const r = try recall(a, g, &runs);
    try testing.expectEqual(@as(usize, 1), r.tours.len);
    const t = r.tours[0];
    try testing.expectEqual(@as(usize, 5), t.ran);
    try testing.expectEqual(@as(usize, 3), t.bound);
    try testing.expectEqual(@as(usize, 2), t.missed.len);
    // Check is missed too, but the tour ran init, which calls it: only init is an entry
    try testing.expectEqual(@as(usize, 1), t.entries.len);
    try testing.expectEqualStrings("stzTax.init", t.entries[0]);
    try testing.expectEqual(@as(usize, 1), r.unowned);
    try testing.expectEqual(@as(usize, 0), r.entries[0].callers);
    try testing.expectEqual(@as(usize, 5), r.functions_ran);
    try testing.expectEqual(@as(usize, 2), r.functions_missed);
}

test "the ids a tour's names reach are the ids whose change selects the tour, id by id, as impact selects" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    // a cycle, a method name two classes share (two dispatch edges), an edge to an id that is no node, a fold, and a
    // file's own statements calling a function that calls another
    const g = try graphOf(a,
        \\{"fold":"ascii","nodes":[{"id":"A.Run","name":"Run"},{"id":"B.Step","name":"Step"},{"id":"C.Step","name":"Step"},
        \\{"id":"D.Loop","name":"Loop"},{"id":"E.Back","name":"Back"},{"id":"F.Alone","name":"Alone"},{"id":"Helper","name":"Helper"},
        \\{"id":"<top>:m.haro","name":"<top>","kind":"top"},{"id":"Setup","name":"Setup"},{"id":"Deep","name":"Deep"}],
        \\"edges":[{"from":"A.Run","to":"B.Step","kind":"dispatch"},{"from":"A.Run","to":"C.Step","kind":"dispatch"},
        \\{"from":"C.Step","to":"D.Loop"},{"from":"D.Loop","to":"E.Back"},{"from":"E.Back","to":"D.Loop"},
        \\{"from":"Helper","to":"external"},{"from":"external","to":"F.Alone"},
        \\{"from":"<top>:m.haro","to":"Setup"},{"from":"Setup","to":"Deep"}]}
    );
    const tours = [_]G.TourNames{
        .{ .file = "t1", .names = &.{"run"} },
        .{ .file = "t2", .names = &.{"Back"} },
        .{ .file = "t3", .names = &.{"HELPER"} },
        .{ .file = "t4", .names = &.{"external"} },
        .{ .file = "t5", .names = &.{ "Step", "Alone" } },
        .{ .file = "t6", .names = &.{} },
    };
    const ids = [_][]const u8{ "A.Run", "B.Step", "C.Step", "D.Loop", "E.Back", "F.Alone", "Helper", "external", "<top>:m.haro", "Setup", "Deep" };
    for (tours) |t| {
        const reached = try reachedBy(a, g, t.names);
        for (ids) |id| {
            const im = try G.impact(a, g, &.{id}, &.{t});
            const by_impact = im.selected.len == 1;
            const by_reach = reached.containsContext(id, .{ .fold = g.fold });
            if (by_impact != by_reach) std.debug.print("tour {s}, change {s}: impact {}, reach {}\n", .{ t.file, id, by_impact, by_reach });
            try testing.expectEqual(by_impact, by_reach);
        }
    }
}

test "an open function the tour ran is counted, and the entries most tours share come first" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const g = try graphOf(a,
        \\{"fold":"ascii","nodes":[{"id":"Go","name":"Go"},{"id":"Dyn","name":"Dyn","open":true},{"id":"X.init","name":"init"},
        \\{"id":"Y.init","name":"init"}],"edges":[{"from":"Go","to":"Dyn"}]}
    );
    const runs = [_]TourRun{
        .{ .file = "a", .names = &.{"Go"}, .ran = &.{ "Go", "Dyn", "X.init" } },
        .{ .file = "b", .names = &.{}, .ran = &.{ "Y.init", "X.init" } },
    };
    const r = try recall(a, g, &runs);
    try testing.expect(!r.complete);
    try testing.expectEqual(@as(usize, 1), r.tours[0].open_ran);
    try testing.expectEqual(@as(usize, 0), r.tours[1].open_ran);
    try testing.expectEqualStrings("X.init", r.entries[0].id);
    try testing.expectEqual(@as(usize, 2), r.entries[0].tours);
    try testing.expectEqualStrings("Y.init", r.entries[1].id);
    try testing.expectEqual(@as(usize, 5), r.pairs_ran);
    try testing.expectEqual(@as(usize, 2), r.pairs_bound);
}
