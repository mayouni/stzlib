//! Testoor core -- THE EVIDENCE REPORT (TESTOOR_PROTOCOL_3.md section 6.9): a walk's logbook, the graph it was judged against
//! and the impact of the changes named, written as one page a person reads. Lead offer 1 of the business desk
//! (stz-business board/offers/testoor-evidence-report.md, section 5) names what a customer receives; the parts that are data
//! are written here, in that order:
//!
//!   1. the ladder               every function with its grade, counted in all and file by file
//!   2. what no tour ran          the functions at grade 0: owed a tour, or capped by an open function, file by file,
//!                                then each with the functions that call it
//!   3. run only by a failing tour   the functions at grade 1, each with the tours that ran it and their state
//!   4. the tours                 each tour's state, its claims, and how many functions it ran
//!   5. what a change reaches     each impact record: the reach the compiler bound, the reach widened, the tours to walk again
//!   6. where the evidence is thinnest   the functions below exemplified, the most called first: where a check buys most
//!   7. what the report does not claim
//!
//! The reading for a person -- one page on what is proven and what is not -- is the business desk's to shape; section 6 is
//! the list it is read from. Nothing here is computed that the logbook, the graph and the impact records do not hold: the
//! report adds no figure of its own except counts of what they list. Callers are DIRECT callers: a count of every function
//! that depends on one at any depth is a walk of the graph per function, and on a library-sized graph (48,939 nodes) that
//! is not a report's cost.

const std = @import("std");
const Allocator = std.mem.Allocator;
const T = @import("testoor_text.zig");
const J = @import("testoor_json.zig");
const G = @import("testoor_graph.zig");

pub const Meta = struct {
    /// the report's title; the graph's subject when empty
    title: []const u8 = "",
    /// the lines that say what the report holds for: the commit, the runtime, the judge -- the caller states them
    stamp: []const []const u8 = &.{},
};

const Grade = struct { key: []const u8, rank: u8, says: []const u8 };

const grades = [_]Grade{
    .{ .key = "exhausted", .rank = 4, .says = "every value of its declared finite domain held" },
    .{ .key = "generalised", .rank = 3, .says = "a property held on the inputs drawn for it" },
    .{ .key = "exemplified", .rank = 2, .says = "a tour that kept its claims and finished ran it" },
    .{ .key = "observed", .rank = 1, .says = "a tour ran it; none that ran it kept its claims and finished" },
    .{ .key = "named", .rank = 0, .says = "no tour ran it" },
};

fn rankOf(name: []const u8) u8 {
    for (grades) |g| if (std.mem.eql(u8, g.key, name)) return g.rank;
    return 0;
}

const Row = struct { grade: []const u8 = "named", tours: []const J.Value = &.{} };

fn plural(a: Allocator, n: usize, one: []const u8, many: []const u8) ![]u8 {
    return std.fmt.allocPrint(a, "{d} {s}", .{ n, if (n == 1) one else many });
}

/// up to `max` items, then "and N more"
fn listOf(b: *T.Buf, items: []const []const u8, max: usize) !void {
    for (items, 0..) |it, k| {
        if (k == max) {
            try b.s(try std.fmt.allocPrint(b.a, ", and {d} more", .{items.len - max}));
            return;
        }
        if (k > 0) try b.s(", ");
        try b.s(it);
    }
}

fn key(a: Allocator, g: G.Graph, id: []const u8) ![]const u8 {
    return if (g.fold == .ascii) try T.lowerAscii(a, id) else id;
}

/// the direct callers of a node, each once, in the edges' order
fn callers(a: Allocator, g: G.Graph, ix: *const G.Index, id: []const u8) ![]const []const u8 {
    var out: std.ArrayList([]const u8) = .empty;
    var seen = std.StringHashMap(void).init(a);
    for (G.edgesInto(ix, g, id)) |k| {
        const from = g.edges[k].from;
        const fk = try key(a, g, from);
        if (seen.contains(fk)) continue;
        try seen.put(fk, {});
        try out.append(a, from);
    }
    return out.items;
}

pub fn markdown(a: Allocator, logbook: J.Value, unit: G.Graph, impacts: []const J.Value, meta: Meta) ![]u8 {
    // a file's own statements are no function: every tour that loads the file runs them, and no probe observes them
    const g = try G.functionsOnly(a, unit);
    const ix = try G.ixOf(a, g);
    const lad = logbook.get("ladder") orelse return error.NoLadder;

    // each node's grade: the ladder's row, else grade 0
    var rows = std.StringHashMap(Row).init(a);
    if (lad.get("nodes")) |ns| for (ns.items()) |n| {
        const id = (n.get("id") orelse continue).str_();
        try rows.put(try key(a, g, id), .{ .grade = (n.get("grade") orelse continue).str_(), .tours = if (n.get("tours")) |t| t.items() else &.{} });
    };
    const node_grade = try a.alloc(Row, g.nodes.len);
    for (g.nodes, 0..) |n, i| node_grade[i] = rows.get(try key(a, g, n.id)) orelse .{};

    // the grades the ladder carries, highest first; named always, since the report has a graph
    var shown: std.ArrayList(Grade) = .empty;
    for (grades) |gr| {
        if (std.mem.eql(u8, gr.key, "named") or lad.get(gr.key) != null) try shown.append(a, gr);
    }
    const count = try a.alloc(usize, shown.items.len);
    @memset(count, 0);
    for (node_grade) |r| for (shown.items, 0..) |gr, k| {
        if (std.mem.eql(u8, gr.key, r.grade)) count[k] += 1;
    };
    var only_functions = true;
    for (g.nodes) |n| {
        if (!std.mem.eql(u8, n.kind, "function") and !std.mem.eql(u8, n.kind, "method")) only_functions = false;
    }
    const noun: []const u8 = if (only_functions) "functions and methods" else "nodes";

    // the tours' states, by file
    var state_of = std.StringHashMap([]const u8).init(a);
    const tours = if (logbook.get("tours")) |t| t.items() else &[_]J.Value{};
    for (tours) |t| try state_of.put((t.get("file") orelse continue).str_(), if (t.get("state")) |s| s.str_() else "");

    var b = T.Buf.init(a);
    try b.s("# Evidence report: ");
    try b.s(if (meta.title.len > 0) meta.title else g.subject);
    try b.s("\n\n");
    for (meta.stamp) |l| {
        try b.s("- ");
        try b.s(l);
        try b.c('\n');
    }
    if (meta.stamp.len > 0) try b.c('\n');

    // 1. the ladder
    try b.s("## 1. The ladder\n\n");
    try b.s(try std.fmt.allocPrint(a, "{d} {s}: **", .{ g.nodes.len, noun }));
    for (shown.items, 0..) |gr, k| {
        if (k > 0) try b.s(", ");
        try b.s(try std.fmt.allocPrint(a, "{d} {s}", .{ count[k], gr.key }));
    }
    try b.s(".**\n\n| grade | what it says | functions |\n|---|---|---:|\n");
    for (shown.items, 0..) |gr, k| try b.s(try std.fmt.allocPrint(a, "| {s} | {s} | {d} |\n", .{ gr.key, gr.says, count[k] }));
    try b.s("\n| file | functions");
    for (shown.items) |gr| {
        try b.s(" | ");
        try b.s(gr.key);
    }
    try b.s(" |\n|---|---:");
    for (shown.items) |_| try b.s("|---:");
    try b.s("|\n");
    var files: std.ArrayList([]const u8) = .empty;
    for (g.nodes) |n| {
        var have = false;
        for (files.items) |f| if (std.mem.eql(u8, f, n.file)) {
            have = true;
        };
        if (!have) try files.append(a, n.file);
    }
    for (files.items) |f| {
        var total: usize = 0;
        const per = try a.alloc(usize, shown.items.len);
        @memset(per, 0);
        for (g.nodes, 0..) |n, i| {
            if (!std.mem.eql(u8, n.file, f)) continue;
            total += 1;
            for (shown.items, 0..) |gr, k| if (std.mem.eql(u8, gr.key, node_grade[i].grade)) {
                per[k] += 1;
            };
        }
        try b.s(try std.fmt.allocPrint(a, "| {s} | {d}", .{ f, total }));
        for (per) |c| try b.s(try std.fmt.allocPrint(a, " | {d}", .{c}));
        try b.s(" |\n");
    }

    // 2. what no tour ran: OWED a tour when nothing caps it, CAPPED when it is open or calls an open function at some
    // depth (roadmap P4, node-level route coverage); the owner of each is its file
    try b.s("\n## 2. What no tour ran\n\n");
    const cap = try G.cappedBy(a, g);
    var n_owed: usize = 0;
    var n_capped: usize = 0;
    for (g.nodes, 0..) |_, i| {
        if (!std.mem.eql(u8, node_grade[i].grade, "named")) continue;
        if (cap[i] == null) n_owed += 1 else n_capped += 1;
    }
    if (n_owed + n_capped == 0) {
        try b.s("Every function of the graph was run by a tour.\n");
    } else {
        try b.s(try std.fmt.allocPrint(a, "No tour ran {d} of the {d} {s}: **{d} owed a tour** -- the graph holds every call each " ++
            "makes, so a tour can prove it -- and **{d} capped**: open, or calling an open function at some depth -- one that " ++
            "dispatches by a name built at run time, or that the compiler could not finish -- so no floor above exemplified " ++
            "holds through it.\n\n| file | owed | capped |\n|---|---:|---:|\n", .{ n_owed + n_capped, g.nodes.len, noun, n_owed, n_capped }));
        for (files.items) |f| {
            var o: usize = 0;
            var c: usize = 0;
            for (g.nodes, 0..) |n, i| {
                if (!std.mem.eql(u8, n.file, f) or !std.mem.eql(u8, node_grade[i].grade, "named")) continue;
                if (cap[i] == null) o += 1 else c += 1;
            }
            if (o + c > 0) try b.s(try std.fmt.allocPrint(a, "| {s} | {d} | {d} |\n", .{ f, o, c }));
        }
        try b.s("\n| function | file | line | called by | owed or capped |\n|---|---|---:|---|---|\n");
        for (g.nodes, 0..) |n, i| {
            if (!std.mem.eql(u8, node_grade[i].grade, "named")) continue;
            try b.s(try std.fmt.allocPrint(a, "| {s} | {s} | {d} | ", .{ n.id, n.file, n.line }));
            const cs = try callers(a, g, ix, n.id);
            if (cs.len == 0) try b.s("no function of the graph") else try listOf(&b, cs, 3);
            if (cap[i]) |by| {
                if (n.open) try b.s(" | open |\n") else try b.s(try std.fmt.allocPrint(a, " | capped by {s} |\n", .{by}));
            } else try b.s(" | owed |\n");
        }
    }
    var any = false;

    // 3. run only by a tour that did not keep its claims
    try b.s("\n## 3. Run only by a tour that did not keep its claims\n\n");
    any = false;
    for (g.nodes, 0..) |n, i| {
        if (!std.mem.eql(u8, node_grade[i].grade, "observed")) continue;
        if (!any) try b.s("| function | file | line | run by |\n|---|---|---:|---|\n");
        any = true;
        try b.s(try std.fmt.allocPrint(a, "| {s} | {s} | {d} | ", .{ n.id, n.file, n.line }));
        var by: std.ArrayList([]const u8) = .empty;
        for (node_grade[i].tours) |t| {
            const f = t.str_();
            try by.append(a, try std.fmt.allocPrint(a, "{s} ({s})", .{ f, state_of.get(f) orelse "" }));
        }
        try listOf(&b, by.items, 3);
        try b.s(" |\n");
    }
    if (!any) try b.s("Every function a tour ran was run by one that kept its claims and finished.\n");

    // 4. the tours
    try b.s("\n## 4. The tours\n\n| tour | state | kept | diverged | unreached | unjudged | functions run |\n|---|---|---:|---:|---:|---:|---:|\n");
    for (tours) |t| {
        var run: usize = 0;
        if (t.get("nodes")) |ns| for (ns.items()) |n| {
            if (n.get("evidence")) |e| if (std.mem.eql(u8, e.str_(), "observed")) {
                run += 1;
            };
        };
        try b.s(try std.fmt.allocPrint(a, "| {s} | {s} | {d} | {d} | {d} | {d} | {d} |\n", .{
            (t.get("file") orelse continue).str_(),
            if (t.get("state")) |s| s.str_() else "",
            if (t.get("kept")) |x| x.int_() else 0,
            if (t.get("diverged")) |x| x.int_() else 0,
            if (t.get("unreached")) |x| x.int_() else 0,
            if (t.get("unjudged")) |x| x.int_() else 0,
            run,
        }));
    }

    // 5. what a change reaches
    try b.s("\n## 5. What a change reaches\n\n");
    if (impacts.len == 0) try b.s("No change was named for this report.\n");
    for (impacts, 0..) |im, k| {
        if (k > 0) try b.c('\n');
        var changed: std.ArrayList([]const u8) = .empty;
        if (im.get("changed")) |cs| for (cs.items()) |c| try changed.append(a, c.str_());
        const reach = if (im.get("reach")) |r| r.items() else &[_]J.Value{};
        const widened = if (im.get("widened")) |w| w.items() else &[_]J.Value{};
        var bound = reach.len;
        if (widened.len > 0) for (reach, 0..) |r, i| {
            if (std.mem.eql(u8, r.str_(), widened[0].str_())) {
                bound = i;
                break;
            }
        };
        var bound_ids: std.ArrayList([]const u8) = .empty;
        for (reach[0..bound]) |r| try bound_ids.append(a, r.str_());
        try b.s("**A change to ");
        for (changed.items, 0..) |c, i| {
            if (i > 0) try b.s(if (i + 1 == changed.items.len) " and " else ", ");
            try b.s(c);
        }
        try b.s(try std.fmt.allocPrint(a, "** reaches {s} by calls the compiler bound: ", .{try plural(a, bound, "function", "functions")}));
        try listOf(&b, bound_ids.items, 8);
        try b.c('.');
        if (widened.len > 0) {
            try b.s(try std.fmt.allocPrint(a, " Once {s} and their callers widen it, it reaches {d}.", .{
                try plural(a, widened.len, "open function", "open functions"), reach.len,
            }));
        }
        const sel = if (im.get("selected")) |s| s.items() else &[_]J.Value{};
        const skip = if (im.get("skipped")) |s| s.items() else &[_]J.Value{};
        var sel_ids: std.ArrayList([]const u8) = .empty;
        for (sel) |s| try sel_ids.append(a, s.str_());
        try b.s(try std.fmt.allocPrint(a, " Tours to walk again: {d} of {d}", .{ sel.len, sel.len + skip.len }));
        if (sel.len > 0) {
            try b.s(" (");
            try listOf(&b, sel_ids.items, 8);
            try b.c(')');
        }
        try b.c('.');
        const complete = if (im.get("complete")) |c| c.truthy() else true;
        if (!complete) {
            try b.s(" The graph is not complete, so every tour is walked again: ");
            try b.s(if (im.get("why")) |w| w.str_() else "");
            try b.c('.');
        }
        try b.c('\n');
    }

    // 6. where the evidence is thinnest
    try b.s("\n## 6. Where the evidence is thinnest\n\n");
    const Thin = struct { i: usize, calls: usize };
    var thin: std.ArrayList(Thin) = .empty;
    for (g.nodes, 0..) |n, i| {
        if (rankOf(node_grade[i].grade) >= 2) continue;
        try thin.append(a, .{ .i = i, .calls = (try callers(a, g, ix, n.id)).len });
    }
    if (thin.items.len == 0) {
        try b.s("No function stands below exemplified.\n");
    } else {
        std.mem.sort(Thin, thin.items, {}, struct {
            fn lt(_: void, x: Thin, y: Thin) bool {
                if (x.calls != y.calls) return x.calls > y.calls;
                return x.i < y.i;
            }
        }.lt);
        try b.s("The functions below exemplified, the one the most functions call first.\n\n| function | grade | functions that call it |\n|---|---|---:|\n");
        for (thin.items[0..@min(5, thin.items.len)]) |t| {
            try b.s(try std.fmt.allocPrint(a, "| {s} | {s} | {d} |\n", .{ g.nodes[t.i].id, node_grade[t.i].grade, t.calls }));
        }
        if (thin.items.len > 5) try b.s(try std.fmt.allocPrint(a, "\n{d} more stand below exemplified; sections 2 and 3 list them all.\n", .{thin.items.len - 5}));
    }

    // 7. what the report does not claim
    try b.s("\n## 7. What this report does not claim\n\n");
    const never = [_][]const u8{
        "that a function no tour ran is wrong, or that one a tour ran is correct;",
        "a proof: every grade here is evidence from examples;",
        "a percentage: evidence is counted function by function;",
        "more than its grade: exemplified means the checks a tour made held, on the inputs it used;",
        "beyond its stamp: it holds for the commit, the runtime and the judge named above;",
        "an exact reach where the graph is not complete: the reach is widened then, and the report says why;",
        "a verdict on what a person perceives, such as a sound, a picture or a sentence.",
    };
    for (never) |l| {
        try b.s("- ");
        try b.s(l);
        try b.c('\n');
    }
    return b.done();
}

// ── tests ────────────────────────────────────────────────────

const testing = std.testing;

test "a list longer than its room names how many more" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    var b = T.Buf.init(arena.allocator());
    try listOf(&b, &.{ "A", "B", "C", "D", "E" }, 3);
    try testing.expectEqualStrings("A, B, C, and 2 more", try b.done());
}
