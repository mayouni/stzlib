//! Testoor core -- THE EVIDENCE FLOOR (TESTOOR_PROTOCOL_2.md section 6).
//!
//! A gate -- a refinement step, a commit hook, an agent's patch -- can demand a FLOOR of evidence
//! before it accepts a change. The record states what the floor was, what the walk found, and
//! whether the walk met it. The policy that picks a floor is data the library holds and is NOT here;
//! only the comparison is. `met` is computed from the counts and the floor and from nothing else.
//!
//! A run that carries a floor exits 1 when the floor is not met, which a gate reads as a refusal (a
//! refused change rolls back). A run without a floor is untouched: a version 2 key appears only when
//! it has something to say.
//!
//! Decisions P3.3's successor took where the draft was silent, each pinned by a golden (L7, L8) or a
//! test below:
//!   * a claim that DIVERGED, or a claim never REACHED, fails every floor: no floor can accept a
//!     change a tour says is wrong or whose tour broke before it could say
//!   * `allow_unjudged` absent means false: unjudged claims are refused unless the floor allows them
//!     out loud. An unjudged claim never raises `kept`
//!   * the record carries FIVE counts: kept, diverged, unreached, unjudged, routes_walked (the draft's
//!     example showed four; unreached is a claim state too, and the floor reads it)
//!   * `routes_walked` counts DISTINCT route ids walked by all the tours
//!   * the reason given is the FIRST failing check, in this order: diverged, unreached, kept below
//!     `min_kept`, unjudged not allowed, routes below `min_routes`
//!   * a floor field the floor does not set is omitted from the record; the floor is echoed in the
//!     order min_kept, allow_unjudged, min_routes
//!
//! PROTOCOL 3 (V4, TESTOOR_PROTOCOL_3.md section 5): a floor may ask for a GRADE -- `min_grade` -- over the impact
//! set of the change (`over:"impact"`, the only set so far). Every node of the set, as the core's impact record gave it
//! (the reach widened by the open nodes), must stand on that grade of the evidence ladder; a node an open node caps can
//! never stand above exemplified. The grade check comes after the five counts' checks, and its reason names the first
//! node of the set, in its order, that falls short.
//!
//! Imports no Ring.

const std = @import("std");
const Allocator = std.mem.Allocator;
const T = @import("testoor_text.zig");
const J = @import("testoor_json.zig");
const V = @import("testoor_verdict.zig");
const Ld = @import("testoor_ladder.zig");

pub const Floor = struct {
    min_kept: ?f64 = null,
    allow_unjudged: ?bool = null,
    min_routes: ?f64 = null,
    /// protocol 3 (V4): the grade every node of the set must stand on, and the set ("impact")
    min_grade: ?[]const u8 = null,
    over: ?[]const u8 = null,
};

/// the set a grade is judged over: the reach of the core's impact record, and the nodes an open node caps
pub const Cap = struct { id: []const u8, by: []const u8 };
pub const ImpactSet = struct { reach: []const []const u8, capped: []const Cap };

pub fn impactFromValue(a: Allocator, v: J.Value) !ImpactSet {
    var reach: std.ArrayList([]const u8) = .empty;
    if (v.get("reach")) |r| for (r.items()) |x| try reach.append(a, x.str_());
    var capped: std.ArrayList(Cap) = .empty;
    if (v.get("capped")) |c| for (c.items()) |x| try capped.append(a, .{
        .id = if (x.get("id")) |i| i.str_() else "",
        .by = if (x.get("by")) |i| i.str_() else "",
    });
    return .{ .reach = reach.items, .capped = capped.items };
}

const grade_names = [_][]const u8{ "named", "observed", "exemplified", "generalised", "exhausted", "proved" };

/// a grade's place on the ladder, 0 to 5, or null for a name that is not a grade
pub fn gradeRank(name: []const u8) ?u8 {
    for (grade_names, 0..) |g, i| if (std.mem.eql(u8, g, name)) return @intCast(i);
    return null;
}

const exemplified_rank: u8 = 2;

/// what the gate asks: who proposed the change, how risky the thing changed is, and the floor
pub const Settings = struct {
    posture: []const u8 = "",
    tier: []const u8 = "",
    floor: Floor = .{},
};

pub const Counts = struct {
    kept: i64 = 0,
    diverged: i64 = 0,
    unreached: i64 = 0,
    unjudged: i64 = 0,
    routes_walked: i64 = 0,
    /// protocol 3 (V4), only when the floor asks for a grade: the nodes of the set, those below the grade, the first
    /// reason, or why the grade could not be judged at all
    reach: i64 = 0,
    below: i64 = 0,
    grade_why: []const u8 = "",
};

pub const Verdict = struct { counts: Counts, met: bool, why: []const u8 };

pub fn fromValue(v: J.Value) Settings {
    var s = Settings{};
    if (v.get("posture")) |x| s.posture = x.str_();
    if (v.get("tier")) |x| s.tier = x.str_();
    if (v.get("floor")) |f| {
        if (f.get("min_kept")) |x| s.floor.min_kept = x.num_();
        if (f.get("allow_unjudged")) |x| s.floor.allow_unjudged = x.truthy();
        if (f.get("min_routes")) |x| s.floor.min_routes = x.num_();
        if (f.get("min_grade")) |x| s.floor.min_grade = x.str_();
        if (f.get("over")) |x| s.floor.over = x.str_();
    }
    return s;
}

/// the five counts, read from the walk
pub fn countsOf(a: Allocator, tours: []const V.Tour) !Counts {
    var c = Counts{};
    var seen: std.StringHashMapUnmanaged(void) = .empty;
    for (tours) |t| {
        c.kept += t.run.kept;
        c.diverged += t.run.diverged;
        c.unreached += t.run.unreached;
        c.unjudged += t.run.unjudged;
        for (t.routes) |r| {
            if (r.item.len == 0) continue;
            if ((try seen.getOrPut(a, r.item)).found_existing) continue;
            c.routes_walked += 1;
        }
    }
    return c;
}

/// the five counts and, when the floor asks for a grade, the grade check over the impact set
pub fn countsFor(a: Allocator, s: Settings, tours: []const V.Tour, impact: ?ImpactSet) !Counts {
    var c = try countsOf(a, tours);
    const want_name = s.floor.min_grade orelse return c;
    const want = gradeRank(want_name) orelse {
        c.grade_why = try std.fmt.allocPrint(a, "the floor's min_grade {s} is not a grade", .{want_name});
        return c;
    };
    const over = s.floor.over orelse "impact";
    if (!std.mem.eql(u8, over, "impact")) {
        c.grade_why = try std.fmt.allocPrint(a, "the floor's over {s} is not a set this core knows", .{over});
        return c;
    }
    const set = impact orelse {
        c.grade_why = "the floor asks for a grade over the impact set, and the run carries no impact record";
        return c;
    };
    const lad = try Ld.build(a, tours);
    c.reach = @intCast(set.reach.len);
    for (set.reach) |id| {
        var have: u8 = 0;
        for (lad.rows) |r| if (std.mem.eql(u8, r.id, id)) {
            have = @intFromEnum(r.grade);
        };
        var by: ?[]const u8 = null;
        for (set.capped) |cp| if (std.mem.eql(u8, cp.id, id)) {
            by = cp.by;
        };
        var why: ?[]const u8 = null;
        if (by != null and want > exemplified_rank) {
            why = if (std.mem.eql(u8, by.?, id))
                try std.fmt.allocPrint(a, "{s} dispatches by a name built at run time: it can reach no grade above exemplified", .{id})
            else
                try std.fmt.allocPrint(a, "{s} can reach no grade above exemplified: it calls {s}, which is open", .{ id, by.? });
        } else if (have < want) {
            why = try std.fmt.allocPrint(a, "{s} is {s}, below the floor's min_grade {s}", .{ id, grade_names[have], want_name });
        }
        if (why) |w| {
            c.below += 1;
            if (c.grade_why.len == 0) c.grade_why = w;
        }
    }
    return c;
}

fn claimsText(a: Allocator, n: i64) ![]const u8 {
    return std.fmt.allocPrint(a, "{d} {s}", .{ n, if (n == 1) "claim" else "claims" });
}

/// met or not, and the first reason it was not
pub fn judge(a: Allocator, s: Settings, c: Counts) !Verdict {
    const f = s.floor;
    if (c.diverged > 0) return .{ .counts = c, .met = false, .why = try std.fmt.allocPrint(a, "{s} diverged", .{try claimsText(a, c.diverged)}) };
    if (c.unreached > 0) return .{ .counts = c, .met = false, .why = try std.fmt.allocPrint(a, "{s} never reached", .{try claimsText(a, c.unreached)}) };
    if (f.min_kept) |m| {
        if (@as(f64, @floatFromInt(c.kept)) < m) {
            return .{ .counts = c, .met = false, .why = try std.fmt.allocPrint(a, "kept {d} is below the floor's min_kept {s}", .{ c.kept, try T.fmtNum(a, m) }) };
        }
    }
    if (c.unjudged > 0 and !(f.allow_unjudged orelse false)) {
        return .{ .counts = c, .met = false, .why = try std.fmt.allocPrint(a, "{s} unjudged, and the floor does not allow it", .{try claimsText(a, c.unjudged)}) };
    }
    if (f.min_routes) |m| {
        if (@as(f64, @floatFromInt(c.routes_walked)) < m) {
            return .{ .counts = c, .met = false, .why = try std.fmt.allocPrint(a, "routes walked {d} is below the floor's min_routes {s}", .{ c.routes_walked, try T.fmtNum(a, m) }) };
        }
    }
    if (f.min_grade != null and c.grade_why.len > 0) return .{ .counts = c, .met = false, .why = c.grade_why };
    return .{ .counts = c, .met = true, .why = "" };
}

/// the evidence record, one JSON object
pub fn writeJson(b: *T.Buf, s: Settings, v: Verdict) !void {
    try b.s("{\"posture\":");
    try b.js(s.posture);
    try b.s(",\"tier\":");
    try b.js(s.tier);
    try b.s(",\"floor\":{");
    var first = true;
    if (s.floor.min_kept) |m| {
        try b.s("\"min_kept\":");
        try b.num(m);
        first = false;
    }
    if (s.floor.allow_unjudged) |x| {
        if (!first) try b.c(',');
        try b.s("\"allow_unjudged\":");
        try b.s(if (x) "true" else "false");
        first = false;
    }
    if (s.floor.min_routes) |m| {
        if (!first) try b.c(',');
        try b.s("\"min_routes\":");
        try b.num(m);
        first = false;
    }
    if (s.floor.min_grade) |g| {
        if (!first) try b.c(',');
        try b.s("\"min_grade\":");
        try b.js(g);
        try b.s(",\"over\":");
        try b.js(s.floor.over orelse "impact");
    }
    try b.s("},\"kept\":");
    try b.int(v.counts.kept);
    try b.s(",\"diverged\":");
    try b.int(v.counts.diverged);
    try b.s(",\"unreached\":");
    try b.int(v.counts.unreached);
    try b.s(",\"unjudged\":");
    try b.int(v.counts.unjudged);
    try b.s(",\"routes_walked\":");
    try b.int(v.counts.routes_walked);
    if (s.floor.min_grade != null) {
        try b.s(",\"reach\":");
        try b.int(v.counts.reach);
        try b.s(",\"below\":");
        try b.int(v.counts.below);
    }
    try b.s(",\"met\":");
    try b.s(if (v.met) "true" else "false");
    try b.s(",\"why\":");
    try b.js(v.why);
    try b.c('}');
}

/// the line a terminal shows, indented as the summary's lines are, with no line feed
pub fn writeProse(b: *T.Buf, s: Settings, v: Verdict) !void {
    const a = b.a;
    try b.s("  evidence: ");
    if (v.met) {
        try b.s("met -- ");
    } else {
        try b.s("NOT MET -- ");
        try b.s(v.why);
        try b.s("; ");
    }
    try b.s(try std.fmt.allocPrint(a, "{d} kept, {d} diverged, {d} unreached, {d} unjudged, {d} routes walked", .{
        v.counts.kept,
        v.counts.diverged,
        v.counts.unreached,
        v.counts.unjudged,
        v.counts.routes_walked,
    }));
    if (s.floor.min_grade) |g| {
        try b.s(try std.fmt.allocPrint(a, ", {d} of {d} nodes in the impact set below {s}", .{ v.counts.below, v.counts.reach, g }));
    }
    try b.s(try std.fmt.allocPrint(a, " (posture {s}, tier {s})", .{
        if (s.posture.len == 0) "unstated" else s.posture,
        if (s.tier.len == 0) "unstated" else s.tier,
    }));
}

// ── tests ────────────────────────────────────────────────────

const testing = std.testing;

fn counts(k: i64, d: i64, u: i64, j: i64, r: i64) Counts {
    return .{ .kept = k, .diverged = d, .unreached = u, .unjudged = j, .routes_walked = r };
}

test "a floor that the walk meets is met, and says nothing" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const v = try judge(arena.allocator(), .{ .floor = .{ .min_kept = 3, .allow_unjudged = false, .min_routes = 1 } }, counts(4, 0, 0, 0, 2));
    try testing.expect(v.met);
    try testing.expectEqualStrings("", v.why);
}

test "a floor the walk falls short of names its first reason, in a fixed order" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const floor = Settings{ .floor = .{ .min_kept = 5, .min_routes = 3 } };
    // kept below min_kept comes before routes below min_routes
    try testing.expectEqualStrings("kept 4 is below the floor's min_kept 5", (try judge(a, floor, counts(4, 0, 0, 0, 2))).why);
    // with kept enough, the routes are what is short
    try testing.expectEqualStrings("routes walked 2 is below the floor's min_routes 3", (try judge(a, floor, counts(5, 0, 0, 0, 2))).why);
    // a diverged claim comes before everything, one claim or three
    try testing.expectEqualStrings("1 claim diverged", (try judge(a, floor, counts(0, 1, 2, 1, 0))).why);
    try testing.expectEqualStrings("3 claims diverged", (try judge(a, floor, counts(9, 3, 0, 0, 9))).why);
    // then a claim never reached
    try testing.expectEqualStrings("2 claims never reached", (try judge(a, floor, counts(9, 0, 2, 0, 9))).why);
}

test "no floor accepts a diverged claim or a tour that broke before it could speak" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const open = Settings{}; // a floor that asks for nothing
    try testing.expect(!(try judge(a, open, counts(100, 1, 0, 0, 100))).met);
    try testing.expect(!(try judge(a, open, counts(100, 0, 1, 0, 100))).met);
    try testing.expect((try judge(a, open, counts(0, 0, 0, 0, 0))).met);
}

test "unjudged is refused unless the floor allows it out loud, and it never raises kept" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    // absent allow_unjudged is false
    const silent = try judge(a, .{ .floor = .{ .min_kept = 1 } }, counts(2, 0, 0, 1, 0));
    try testing.expect(!silent.met);
    try testing.expectEqualStrings("1 claim unjudged, and the floor does not allow it", silent.why);
    // allowed out loud
    try testing.expect((try judge(a, .{ .floor = .{ .min_kept = 1, .allow_unjudged = true } }, counts(2, 0, 0, 1, 0))).met);
    // saying false is the same as saying nothing
    try testing.expect(!(try judge(a, .{ .floor = .{ .allow_unjudged = false } }, counts(2, 0, 0, 5, 0))).met);
    // five unjudged claims do not make up for a missing kept one
    const short = try judge(a, .{ .floor = .{ .min_kept = 3, .allow_unjudged = true } }, counts(2, 0, 0, 5, 0));
    try testing.expect(!short.met);
    try testing.expectEqualStrings("kept 2 is below the floor's min_kept 3", short.why);
}

test "the routes walked are the distinct ones, across all the tours" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const stops = try a.alloc(V.Stop, 0);
    const one = V.Tour{ .file = "a", .dialect = "protocol", .flaky = false, .weather = &.{}, .routes = &.{
        .{ .item = "ZA1", .stop = "", .line = 1 },
        .{ .item = "ZA1", .stop = "x", .line = 4 },
        .{ .item = "", .stop = "", .line = 5 },
    }, .run = .{ .end = "finished", .exit = 0, .wall_ms = 0, .seed = null, .state = .kept, .kept = 2, .diverged = 0, .unreached = 0, .unjudged = 1, .stops = stops } };
    const two = V.Tour{ .file = "b", .dialect = "protocol", .flaky = false, .weather = &.{}, .routes = &.{
        .{ .item = "ZA2", .stop = "", .line = 1 },
        .{ .item = "ZA1", .stop = "", .line = 2 },
    }, .run = .{ .end = "finished", .exit = 0, .wall_ms = 0, .seed = null, .state = .kept, .kept = 3, .diverged = 0, .unreached = 0, .unjudged = 0, .stops = stops } };
    const c = try countsOf(a, &.{ one, two });
    try testing.expectEqual(@as(i64, 5), c.kept);
    try testing.expectEqual(@as(i64, 1), c.unjudged);
    try testing.expectEqual(@as(i64, 2), c.routes_walked); // ZA1 twice and the empty id do not count
}

test "the record omits a floor field the floor does not set, and echoes the rest in a fixed order" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const s = Settings{ .posture = "trusted", .tier = "low", .floor = .{ .min_routes = 2 } };
    var b = T.Buf.init(a);
    try writeJson(&b, s, try judge(a, s, counts(0, 0, 0, 0, 2)));
    try testing.expectEqualStrings(
        "{\"posture\":\"trusted\",\"tier\":\"low\",\"floor\":{\"min_routes\":2},\"kept\":0,\"diverged\":0,\"unreached\":0,\"unjudged\":0,\"routes_walked\":2,\"met\":true,\"why\":\"\"}",
        try b.done(),
    );
    var e = T.Buf.init(a);
    try writeJson(&e, .{}, try judge(a, .{}, counts(0, 0, 0, 0, 0)));
    try testing.expect(std.mem.indexOf(u8, try e.done(), "\"floor\":{},") != null);
}

test "a floor asking for a grade with no impact record, or a grade that is not one, is not met" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const s = Settings{ .floor = .{ .min_grade = "exemplified" } };
    const none = try judge(a, s, try countsFor(a, s, &.{}, null));
    try testing.expect(!none.met);
    try testing.expectEqualStrings("the floor asks for a grade over the impact set, and the run carries no impact record", none.why);
    const bad = Settings{ .floor = .{ .min_grade = "excellent" } };
    try testing.expectEqualStrings("the floor's min_grade excellent is not a grade", (try judge(a, bad, try countsFor(a, bad, &.{}, .{ .reach = &.{}, .capped = &.{} }))).why);
    // an empty set meets any grade, proved included: nothing was changed that anything calls
    const proved = Settings{ .floor = .{ .min_grade = "proved" } };
    try testing.expect((try judge(a, proved, try countsFor(a, proved, &.{}, .{ .reach = &.{}, .capped = &.{} }))).met);
    // a node no tour reached is named, and a node an open node caps is held at exemplified
    const set = ImpactSet{ .reach = &.{ "A", "B" }, .capped = &.{.{ .id = "B", .by = "B" }} };
    const ex = Settings{ .floor = .{ .min_grade = "observed" } };
    const v = try judge(a, ex, try countsFor(a, ex, &.{}, set));
    try testing.expectEqualStrings("A is named, below the floor's min_grade observed", v.why);
    try testing.expectEqual(@as(i64, 2), v.counts.below);
    const gen = Settings{ .floor = .{ .min_grade = "generalised" } };
    const c2 = try countsFor(a, gen, &.{}, .{ .reach = &.{"B"}, .capped = &.{.{ .id = "B", .by = "B" }} });
    try testing.expectEqualStrings("B dispatches by a name built at run time: it can reach no grade above exemplified", c2.grade_why);
}

test "the settings are read from the document a gate hands over" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const s = fromValue(try J.parse(a, "{\"posture\":\"llm\",\"tier\":\"critical\",\"floor\":{\"min_kept\":3,\"allow_unjudged\":true,\"unknown\":9}}"));
    try testing.expectEqualStrings("llm", s.posture);
    try testing.expectEqual(@as(?f64, 3), s.floor.min_kept);
    try testing.expectEqual(@as(?bool, true), s.floor.allow_unjudged);
    try testing.expectEqual(@as(?f64, null), s.floor.min_routes);
}
