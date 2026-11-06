//! Testoor core -- the GOLDEN HARNESS (roadmap P3.0). It reads base/testoor/golden/, judges
//! every case with the Zig core and compares every expected file byte for byte, with carriage
//! returns removed as the reference's reader removes them. It knows nothing the goldens do
//! not say, and it is the whole of the acceptance test for step P3.1: the Ring reference
//! produced these files, a human read them against the intent table in the Ring guard, and
//! the Zig core must reproduce them without having seen the Ring code run.
//!
//! golden/protocol2/ (P3.3) holds the cases version 2 added. The Ring reference cannot judge them,
//! so their expected files were written by hand from TESTOOR_PROTOCOL_2.md before any code, and
//! the core is the only implementation held to them.
//!
//! The folder is found from the working directory (`../base/testoor/golden` from the engine
//! folder, which `zig build test-testoor` sets) or from TESTOOR_GOLDEN.

const std = @import("std");
const T = @import("testoor_text.zig");
const J = @import("testoor_json.zig");
const V = @import("testoor_verdict.zig");
const L = @import("testoor_logbook.zig");
const G = @import("testoor_graph.zig");
const A = @import("testoor_api.zig");
const Ev = @import("testoor_evidence.zig");

const Allocator = std.mem.Allocator;

fn goldenDir(a: Allocator) ![]const u8 {
    return std.process.getEnvVarOwned(a, "TESTOOR_GOLDEN") catch try a.dupe(u8, "../base/testoor/golden");
}

fn readAll(a: Allocator, dir: []const u8, rel: []const u8) ![]u8 {
    const path = try std.fs.path.join(a, &.{ dir, rel });
    const raw = try std.fs.cwd().readFileAlloc(a, path, 64 * 1024 * 1024);
    return T.removeCr(a, raw);
}

/// a file a case may or may not have
fn readOpt(a: Allocator, dir: []const u8, rel: []const u8) !?[]u8 {
    return readAll(a, dir, rel) catch |e| {
        if (e == error.FileNotFound) return null;
        return e;
    };
}

fn caseNames(a: Allocator, dir: []const u8, sub: []const u8) ![][]const u8 {
    const path = try std.fs.path.join(a, &.{ dir, sub });
    var d = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer d.close();
    var out: std.ArrayList([]const u8) = .empty;
    var it = d.iterate();
    while (try it.next()) |e| {
        if (e.kind != .directory) continue;
        if (e.name[0] == '.' or e.name[0] == '_') continue;
        try out.append(a, try a.dupe(u8, e.name));
    }
    std.mem.sort([]const u8, out.items, {}, struct {
        fn lt(_: void, x: []const u8, y: []const u8) bool {
            return std.mem.lessThan(u8, x, y);
        }
    }.lt);
    return out.items;
}

/// ONE tour, judged from its committed inputs; a case that carries a graph.json and a names.txt
/// (protocol 2) is judged against them
fn judgeCase(a: Allocator, dir: []const u8, sub: []const u8, case: []const u8) !V.Tour {
    const base = try std.fs.path.join(a, &.{ sub, case });
    const rec_t = try readAll(a, dir, try std.fs.path.join(a, &.{ base, "record.json" }));
    const meta_t = try readAll(a, dir, try std.fs.path.join(a, &.{ base, "meta.json" }));
    const out_t = try readAll(a, dir, try std.fs.path.join(a, &.{ base, "output.txt" }));
    const rec = try V.recordFromValue(a, try J.parse(a, rec_t));
    var meta = try V.metaFromValue(a, try J.parse(a, meta_t));
    if (try readOpt(a, dir, try std.fs.path.join(a, &.{ base, "graph.json" }))) |gt| {
        meta.graph = try G.fromValue(a, try J.parse(a, gt));
    }
    if (try readOpt(a, dir, try std.fs.path.join(a, &.{ base, "names.txt" }))) |nt| {
        var names: std.ArrayList([]const u8) = .empty;
        for (try T.splitLines(a, nt)) |ln| if (ln.len != 0) try names.append(a, ln);
        meta.names = names.items;
    }
    const lines = try V.linesFromText(a, out_t);
    return V.verdict(a, rec, lines, meta);
}

var failures: usize = 0;
var compared: usize = 0;

fn report(what: []const u8, got: []const u8, want: []const u8) void {
    failures += 1;
    var i: usize = 0;
    const n = @min(got.len, want.len);
    while (i < n and got[i] == want[i]) i += 1;
    const from = if (i > 40) i - 40 else 0;
    std.debug.print("\nGOLDEN MISMATCH {s}\n  first difference at byte {d} (got {d} bytes, want {d})\n  got : {s}\n  want: {s}\n", .{
        what,
        i,
        got.len,
        want.len,
        got[from..@min(got.len, i + 60)],
        want[from..@min(want.len, i + 60)],
    });
}

fn expectFile(a: Allocator, dir: []const u8, rel: []const u8, got: []const u8) !void {
    compared += 1;
    const want = readAll(a, dir, rel) catch {
        failures += 1;
        std.debug.print("\nGOLDEN MISSING {s}\n", .{rel});
        return;
    };
    if (!std.mem.eql(u8, got, want)) report(rel, got, want);
}

fn judgeCases(a: Allocator, dir: []const u8, sub: []const u8, at_least: usize) !void {
    const cases = try caseNames(a, dir, sub);
    try std.testing.expect(cases.len >= at_least);
    for (cases) |case| {
        const tour = try judgeCase(a, dir, sub, case);
        var jb = T.Buf.init(a);
        try L.tourJson(&jb, tour);
        try jb.c('\n');
        try expectFile(a, dir, try std.fs.path.join(a, &.{ sub, case, "expected.json" }), try jb.done());
        var pb = T.Buf.init(a);
        try L.tourProse(&pb, tour);
        try pb.c('\n');
        try expectFile(a, dir, try std.fs.path.join(a, &.{ sub, case, "expected.txt" }), try pb.done());
    }
}

/// ONE run, built from judge cases under `jsub`, compared with the three files under `lsub`
fn logbookCase(a: Allocator, dir: []const u8, lsub: []const u8, jsub: []const u8, case: []const u8) !void {
    const run_t = try readAll(a, dir, try std.fs.path.join(a, &.{ lsub, case, "run.json" }));
    const rj = try J.parse(a, run_t);
    var st = L.Settings{
        .by = rj.get("by").?.str_(),
        .root = rj.get("root").?.str_(),
        .topic = rj.get("topic").?.str_(),
        .subject = rj.get("subject").?.str_(),
        .seed = rj.get("seed").?.num_(),
        .repeat = rj.get("repeat").?.num_(),
        .timeout_ms = rj.get("timeout_ms").?.num_(),
    };
    if (rj.get("graph")) |gv| st.graph = .{
        .complete = if (gv.get("complete")) |x| x.truthy() else true,
        .why = if (gv.get("why")) |x| x.str_() else "",
        .owned = if (gv.get("owned")) |x| x.int_() else 0,
    };
    if (rj.get("evidence")) |ev| st.evidence = Ev.fromValue(ev);
    var tours: std.ArrayList(V.Tour) = .empty;
    const refuse = rj.get("refuse_root").?.str_();
    if (refuse.len != 0) {
        // the runner is pointed at a root that is not there: nothing is walked
        st.root = refuse;
        st.refusal = try std.fmt.allocPrint(a, "no such root: {s}", .{refuse});
    } else {
        var sk: std.ArrayList([]const u8) = .empty;
        for (rj.get("skipped").?.items()) |v| try sk.append(a, v.str_());
        st.skipped = sk.items;
        var ts: std.ArrayList([]const u8) = .empty;
        for (rj.get("topics_skipped").?.items()) |v| try ts.append(a, v.str_());
        st.topics_skipped = ts.items;
        const flaky = rj.get("flaky").?.items();
        for (rj.get("cases").?.items()) |cv| {
            var tour = try judgeCase(a, dir, jsub, cv.str_());
            for (flaky) |f| if (std.mem.eql(u8, f.str_(), cv.str_())) {
                tour.flaky = true;
            };
            try tours.append(a, tour);
        }
    }
    var jb = T.Buf.init(a);
    try L.runJson(&jb, st, tours.items);
    try jb.c('\n');
    try expectFile(a, dir, try std.fs.path.join(a, &.{ lsub, case, "expected.json" }), try jb.done());
    var pb = T.Buf.init(a);
    try L.runProse(&pb, st, tours.items);
    try pb.c('\n');
    try expectFile(a, dir, try std.fs.path.join(a, &.{ lsub, case, "expected.txt" }), try pb.done());
    const ex = try std.fmt.allocPrint(a, "{d}\n", .{L.exitCode(st, tours.items)});
    try expectFile(a, dir, try std.fs.path.join(a, &.{ lsub, case, "expected.exit" }), ex);
}

test "every judge case reproduces its expected files" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    failures = 0;
    try judgeCases(a, dir, "judge", 14);
    std.debug.print("  judge: {d} expected files compared\n", .{compared});
    try std.testing.expectEqual(@as(usize, 0), failures);
}

test "every logbook case reproduces its expected files" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    const cases = try caseNames(a, dir, "logbook");
    try std.testing.expect(cases.len >= 5);
    failures = 0;
    for (cases) |case| try logbookCase(a, dir, "logbook", "judge", case);
    std.debug.print("  judge + logbook: {d} expected files compared\n", .{compared});
    try std.testing.expectEqual(@as(usize, 0), failures);
}

test "protocol 2: the judge cases (node lines, named and observed evidence) reproduce their expected files" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    failures = 0;
    try judgeCases(a, dir, "protocol2/judge", 2);
    std.debug.print("  protocol 2 judge: {d} expected files compared in all\n", .{compared});
    try std.testing.expectEqual(@as(usize, 0), failures);
}

test "protocol 2: a run whose graph is incomplete still exits 0, and says so" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    const cases = try caseNames(a, dir, "protocol2/logbook");
    try std.testing.expect(cases.len >= 1);
    failures = 0;
    for (cases) |case| try logbookCase(a, dir, "protocol2/logbook", "protocol2/judge", case);
    std.debug.print("  protocol 2 logbook: {d} expected files compared in all\n", .{compared});
    try std.testing.expectEqual(@as(usize, 0), failures);
}

test "protocol 2: the impact record for a complete graph, an open graph and two changed nodes" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    const cases = try caseNames(a, dir, "protocol2/impact");
    try std.testing.expect(cases.len >= 3);
    failures = 0;
    for (cases) |case| {
        const req = try readAll(a, dir, try std.fs.path.join(a, &.{ "protocol2/impact", case, "request.json" }));
        var got: std.ArrayList(u8) = .empty;
        try got.appendSlice(a, try A.impactJson(a, req));
        try got.append(a, '\n');
        try expectFile(a, dir, try std.fs.path.join(a, &.{ "protocol2/impact", case, "expected.json" }), got.items);
    }
    std.debug.print("  protocol 2 impact: {d} expected files compared in all\n", .{compared});
    try std.testing.expectEqual(@as(usize, 0), failures);
}
