//! Testoor core -- the route join (roadmap P3.3). A port of the counting and the two faces of
//! `stzRouteMap` in the Ring reference (base/testoor/stzRoute.ring).
//!
//! A ROUTE is a plan item, declared before it is walked; a TOUR walks it by saying so. The face
//! reads the plans (the court's own reader), the tours' declarations and the map of untouched
//! methods; this module does the JOIN: which routes are owned, which are walked, which no tour
//! walks, which walk names a route no plan owns, and the findings the join itself raises.
//! Owned and walked are two figures and are never summed, and no percentage is printed.
//!
//! The court's own plan findings (the Ring court, `StzCheckPlanCoverage`) are not reproduced
//! here: the face hands them over as data and they come first, as in the reference.
//!
//! Nothing here imports Ring. Ids compare as exact bytes, as Ring's `=` does.

const std = @import("std");
const Allocator = std.mem.Allocator;
const T = @import("testoor_text.zig");

/// a plan item the plans own: [ id, status, line, label ] in the reference
pub const Item = struct { id: []const u8, status: []const u8, line: i64, label: []const u8 };

/// a route a tour declares: [ id, file, stop, line ]
pub const Walk = struct { id: []const u8, file: []const u8, stop: []const u8, line: i64 };

/// a public method no tour names: [ class, line, method, file ]
pub const Untouched = struct { class: []const u8, line: i64, method: []const u8, file: []const u8 };

pub const Finding = struct { rule: []const u8, severity: []const u8, where: []const u8, message: []const u8 };

pub const Map = struct {
    items: []const Item = &.{},
    walks: []const Walk = &.{},
    untouched: []const Untouched = &.{},
    /// the court's findings, in the reference's order, to be written before the join's own
    court: []const Finding = &.{},
};

fn has(list: []const []const u8, id: []const u8) bool {
    for (list) |x| if (std.mem.eql(u8, x, id)) return true;
    return false;
}

/// the distinct ids the plans own, in the order they were first met
pub fn owned(a: Allocator, m: Map) ![]const []const u8 {
    var out: std.ArrayList([]const u8) = .empty;
    for (m.items) |it| if (!has(out.items, it.id)) try out.append(a, it.id);
    return out.items;
}

pub fn isWalked(m: Map, id: []const u8) bool {
    for (m.walks) |w| if (std.mem.eql(u8, w.id, id)) return true;
    return false;
}

/// how many owned routes have at least one tour
pub fn walkedCount(a: Allocator, m: Map) !usize {
    var n: usize = 0;
    for (try owned(a, m)) |id| if (isWalked(m, id)) {
        n += 1;
    };
    return n;
}

/// every owned route no tour walks, as the first plan row that defines it, in plan order
pub fn unwalked(a: Allocator, m: Map) ![]const Item {
    var out: std.ArrayList(Item) = .empty;
    var seen: std.ArrayList([]const u8) = .empty;
    for (m.items) |it| {
        if (has(seen.items, it.id)) continue;
        try seen.append(a, it.id);
        if (!isWalked(m, it.id)) try out.append(a, it);
    }
    return out.items;
}

/// every walk that names a route no plan defines
pub fn unknownWalks(a: Allocator, m: Map) ![]const Walk {
    const own = try owned(a, m);
    var out: std.ArrayList(Walk) = .empty;
    for (m.walks) |w| if (!has(own, w.id)) try out.append(a, w);
    return out.items;
}

/// the court's findings, then route_without_tour for each unwalked route (a WARNING when the plan
/// reads it closed -- something is claimed done that nothing walks -- and INFO otherwise, which is
/// expected: nobody has promised it yet), then method_without_tour for each untouched method
pub fn findings(a: Allocator, m: Map) ![]const Finding {
    var out: std.ArrayList(Finding) = .empty;
    for (m.court) |f| try out.append(a, f);
    for (try unwalked(a, m)) |u| {
        const closed = std.mem.eql(u8, u.status, "closed");
        const why: []const u8 = if (closed)
            "the plan reads it closed, and no tour walks it: something is claimed done that nothing walks"
        else
            try std.fmt.allocPrint(a, "the plan reads it {s}, which is expected: nobody has promised it yet", .{u.status});
        try out.append(a, .{
            .rule = "route_without_tour",
            .severity = if (closed) "warning" else "info",
            .where = try std.fmt.allocPrint(a, "{s}:{d}", .{ u.label, u.line }),
            .message = try std.fmt.allocPrint(a, "route {s} has no tour -- {s}", .{ u.id, why }),
        });
    }
    for (m.untouched) |u| {
        try out.append(a, .{
            .rule = "method_without_tour",
            .severity = "info",
            .where = try std.fmt.allocPrint(a, "{s}:{d}", .{ u.file, u.line }),
            .message = try std.fmt.allocPrint(a, "method {s} is named by no tour in scope (a static name join, not execution coverage)", .{u.method}),
        });
    }
    return out.items;
}

/// the routes report as text: the counts, then each unwalked route, unknown walk and untouched method
pub fn prose(b: *T.Buf, m: Map) !void {
    const a = b.a;
    const own = try owned(a, m);
    const un = try unwalked(a, m);
    try b.s("routes owned ");
    try b.int(@intCast(own.len));
    try b.s(", walked ");
    try b.int(@intCast(try walkedCount(a, m)));
    try b.s(", unwalked ");
    try b.int(@intCast(un.len));
    try b.s("  (counts, never summed, never a percentage)\n");
    for (un) |u| {
        try b.s("  UNWALKED  ");
        try b.s(u.id);
        try b.s("  (");
        try b.s(u.status);
        try b.s(")  ");
        try b.s(u.label);
        try b.c(':');
        try b.int(u.line);
        try b.c('\n');
    }
    for (try unknownWalks(a, m)) |w| {
        try b.s("  UNKNOWN   ");
        try b.s(w.id);
        try b.s("  declared in ");
        try b.s(w.file);
        try b.c('\n');
    }
    if (m.untouched.len > 0) {
        try b.s("untouched methods (a static name join, not execution coverage): ");
        try b.int(@intCast(m.untouched.len));
        try b.c('\n');
        for (m.untouched) |u| {
            try b.s("  ");
            try b.s(u.class);
            try b.c('.');
            try b.s(u.method);
            try b.s("  line ");
            try b.int(u.line);
            try b.c('\n');
        }
    }
}

/// the routes report as JSON: the counts, the unwalked and unknown routes, untouched methods and findings
pub fn json(b: *T.Buf, m: Map) !void {
    const a = b.a;
    const own = try owned(a, m);
    try b.s("{\"testoor\":\"logbook\",\"kind\":\"routes\",\"owned\":");
    try b.int(@intCast(own.len));
    try b.s(",\"walked\":");
    try b.int(@intCast(try walkedCount(a, m)));
    try b.s(",\"unwalked\":[");
    for (try unwalked(a, m), 0..) |u, k| {
        if (k > 0) try b.c(',');
        try b.s("{\"route\":");
        try b.js(u.id);
        try b.s(",\"status\":");
        try b.js(u.status);
        try b.s(",\"where\":");
        try b.js(try std.fmt.allocPrint(a, "{s}:{d}", .{ u.label, u.line }));
        try b.c('}');
    }
    try b.s("],\"unknown\":[");
    for (try unknownWalks(a, m), 0..) |w, k| {
        if (k > 0) try b.c(',');
        try b.s("{\"route\":");
        try b.js(w.id);
        try b.s(",\"tour\":");
        try b.js(w.file);
        try b.c('}');
    }
    try b.s("],\"untouched_methods\":[");
    for (m.untouched, 0..) |u, k| {
        if (k > 0) try b.c(',');
        try b.s("{\"class\":");
        try b.js(u.class);
        try b.s(",\"method\":");
        try b.js(u.method);
        try b.s(",\"line\":");
        try b.int(u.line);
        try b.c('}');
    }
    try b.s("],\"findings\":[");
    for (try findings(a, m), 0..) |f, k| {
        if (k > 0) try b.c(',');
        try b.s("{\"rule\":");
        try b.js(f.rule);
        try b.s(",\"severity\":");
        try b.js(f.severity);
        try b.s(",\"where\":");
        try b.js(f.where);
        try b.s(",\"message\":");
        try b.js(f.message);
        try b.c('}');
    }
    try b.s("]}");
}

// ── tests ────────────────────────────────────────────────────

const testing = std.testing;

fn sample() Map {
    return .{
        .items = &.{
            .{ .id = "GG1", .status = "closed", .line = 3, .label = "plan.md" },
            .{ .id = "GG2", .status = "open", .line = 4, .label = "plan.md" },
            .{ .id = "GG3", .status = "closed", .line = 5, .label = "plan.md" },
            .{ .id = "GG1", .status = "open", .line = 9, .label = "other.md" }, // met again: one route, first row wins
        },
        .walks = &.{
            .{ .id = "GG3", .file = "t/a.ring", .stop = "first", .line = 2 },
            .{ .id = "ZZ9", .file = "t/b.ring", .stop = "", .line = 7 }, // no plan owns it
        },
        .untouched = &.{.{ .class = "stzTax", .line = 12, .method = "Total", .file = "tax/stzTax.ring" }},
        .court = &.{.{ .rule = "guard_discharges_unknown_item", .severity = "error", .where = "t/b.ring:7", .message = "names ZZ9" }},
    };
}

test "owned and walked are two figures: a route met twice is one, a walk of an unowned route is not walked" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const m = sample();
    try testing.expectEqual(@as(usize, 3), (try owned(a, m)).len);
    try testing.expectEqual(@as(usize, 1), try walkedCount(a, m));
    const un = try unwalked(a, m);
    try testing.expectEqual(@as(usize, 2), un.len);
    try testing.expectEqualStrings("GG1", un[0].id);
    try testing.expectEqualStrings("closed", un[0].status); // the first plan row that defines it
    try testing.expectEqualStrings("plan.md", un[0].label);
    const uk = try unknownWalks(a, m);
    try testing.expectEqual(@as(usize, 1), uk.len);
    try testing.expectEqualStrings("ZZ9", uk[0].id);
}

test "ids are exact bytes: GG3 is not gg3" {
    const m = Map{
        .items = &.{.{ .id = "GG3", .status = "open", .line = 1, .label = "p" }},
        .walks = &.{.{ .id = "gg3", .file = "t", .stop = "", .line = 1 }},
    };
    try testing.expect(!isWalked(m, "GG3"));
}

test "findings: the court first, then a warning for a closed route nobody walks, then info" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const f = try findings(a, sample());
    try testing.expectEqual(@as(usize, 4), f.len);
    try testing.expectEqualStrings("guard_discharges_unknown_item", f[0].rule);
    try testing.expectEqualStrings("route_without_tour", f[1].rule);
    try testing.expectEqualStrings("warning", f[1].severity);
    try testing.expectEqualStrings("plan.md:3", f[1].where);
    try testing.expectEqualStrings("route GG1 has no tour -- the plan reads it closed, and no tour walks it: something is claimed done that nothing walks", f[1].message);
    try testing.expectEqualStrings("info", f[2].severity);
    try testing.expectEqualStrings("route GG2 has no tour -- the plan reads it open, which is expected: nobody has promised it yet", f[2].message);
    try testing.expectEqualStrings("method_without_tour", f[3].rule);
    try testing.expectEqualStrings("tax/stzTax.ring:12", f[3].where);
}

test "the prose and the JSON are the reference's bytes" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var p = T.Buf.init(a);
    try prose(&p, sample());
    try testing.expectEqualStrings(
        "routes owned 3, walked 1, unwalked 2  (counts, never summed, never a percentage)\n" ++
            "  UNWALKED  GG1  (closed)  plan.md:3\n" ++
            "  UNWALKED  GG2  (open)  plan.md:4\n" ++
            "  UNKNOWN   ZZ9  declared in t/b.ring\n" ++
            "untouched methods (a static name join, not execution coverage): 1\n" ++
            "  stzTax.Total  line 12\n",
        try p.done(),
    );
    var j = T.Buf.init(a);
    try json(&j, Map{ .items = &.{.{ .id = "A1", .status = "open", .line = 2, .label = "p.md" }} });
    try testing.expectEqualStrings(
        "{\"testoor\":\"logbook\",\"kind\":\"routes\",\"owned\":1,\"walked\":0,\"unwalked\":[{\"route\":\"A1\",\"status\":\"open\",\"where\":\"p.md:2\"}]," ++
            "\"unknown\":[],\"untouched_methods\":[],\"findings\":[{\"rule\":\"route_without_tour\",\"severity\":\"info\",\"where\":\"p.md:2\"," ++
            "\"message\":\"route A1 has no tour -- the plan reads it open, which is expected: nobody has promised it yet\"}]}",
        try j.done(),
    );
}

test "an empty map reports zero and no untouched section in the prose" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var p = T.Buf.init(a);
    try prose(&p, Map{});
    try testing.expectEqualStrings("routes owned 0, walked 0, unwalked 0  (counts, never summed, never a percentage)\n", try p.done());
}
