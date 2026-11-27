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
const Rd = @import("testoor_reader.zig");
const Hg = @import("testoor_harograph.zig");
const P = @import("testoor_probe.zig");
const Rp = @import("testoor_report.zig");

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
    if (rj.get("ladder")) |x| st.ladder = x.truthy();
    if (rj.get("impact")) |x| st.impact = try Ev.impactFromValue(a, x);
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

/// the judge folder a run's cases live in: protocol 3's when its first case is there, else protocol 2's
fn judgeDirFor(a: Allocator, dir: []const u8, lsub: []const u8, case: []const u8) ![]const u8 {
    const rj = try J.parse(a, try readAll(a, dir, try std.fs.path.join(a, &.{ lsub, case, "run.json" })));
    const cs = rj.get("cases").?.items();
    if (cs.len == 0) return "protocol2/judge";
    const probe = try std.fs.path.join(a, &.{ dir, "protocol3/judge", cs[0].str_() });
    std.fs.cwd().access(probe, .{}) catch return "protocol2/judge";
    return "protocol3/judge";
}

test "protocol 3: the judge cases of V2 (a property held, failed and shrunk, held over text)" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    failures = 0;
    try judgeCases(a, dir, "protocol3/judge", 3);
    std.debug.print("  protocol 3 judge: {d} expected files compared in all\n", .{compared});
    try std.testing.expectEqual(@as(usize, 0), failures);
}

test "protocol 3: the evidence ladder (V1, V2) with a graph and without one" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    const cases = try caseNames(a, dir, "protocol3/logbook");
    try std.testing.expect(cases.len >= 4);
    failures = 0;
    for (cases) |case| try logbookCase(a, dir, "protocol3/logbook", try judgeDirFor(a, dir, "protocol3/logbook", case), case);
    std.debug.print("  protocol 3 logbook: {d} expected files compared in all\n", .{compared});
    try std.testing.expectEqual(@as(usize, 0), failures);
}

test "protocol 3: the impact record widened by an open node, and the nodes it caps (V4)" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    const cases = try caseNames(a, dir, "protocol3/impact");
    try std.testing.expect(cases.len >= 1);
    failures = 0;
    for (cases) |case| {
        const req = try readAll(a, dir, try std.fs.path.join(a, &.{ "protocol3/impact", case, "request.json" }));
        var got: std.ArrayList(u8) = .empty;
        try got.appendSlice(a, try A.impactJson(a, req));
        try got.append(a, '\n');
        try expectFile(a, dir, try std.fs.path.join(a, &.{ "protocol3/impact", case, "expected.json" }), got.items);
    }
    try std.testing.expectEqual(@as(usize, 0), failures);
}

test "the Haro face judges a narrated tour from its THEN lines only (P3.6)" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    failures = 0;
    try judgeCases(a, dir, "haro/judge", 4);
    try std.testing.expectEqual(@as(usize, 0), failures);
}

test "the Haro face reads haro graph's lines into the graph record (BUSINESS-LEADS-DELIVER-01, A1 (1))" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    failures = 0;
    const cases = try caseNames(a, dir, "haro/graph");
    try std.testing.expect(cases.len >= 1);
    for (cases) |case| {
        const lines = try readAll(a, dir, try std.fs.path.join(a, &.{ "haro/graph", case, "lines.txt" }));
        // a case with a src folder hands the face the unit's files; one without reads none
        const src = try std.fs.path.join(a, &.{ dir, "haro/graph", case, "src" });
        var root: ?[]const u8 = null;
        if (std.fs.cwd().access(src, .{})) |_| root = src else |_| {}
        try expectFile(a, dir, try std.fs.path.join(a, &.{ "haro/graph", case, "expected.json" }), try Hg.fromLines(a, lines, root));
    }
    try std.testing.expectEqual(@as(usize, 0), failures);
}

test "testoor probe: a call before the first statement of each body, no line moved, and the record of what it probed (6.8)" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    failures = 0;
    const cases = try caseNames(a, dir, "haro/probe");
    try std.testing.expect(cases.len >= 1);
    for (cases) |case| {
        const lines = try readAll(a, dir, try std.fs.path.join(a, &.{ "haro/probe", case, "lines.txt" }));
        // the file haro graph was asked about is the first FILE line's, under src/
        const first = std.mem.sliceTo(lines, '\n');
        const name = first["FILE|".len..];
        const src = try readAll(a, dir, try std.fs.path.join(a, &.{ "haro/probe", case, "src", name }));
        const blk = try P.firstBlock(a, lines);
        // a golden source is named <file>.txt, so no sweep of .haro files reads it; the placement is the file's
        const real = if (std.mem.endsWith(u8, name, ".txt")) name[0 .. name.len - 4] else name;
        const r = try P.instrument(a, src, blk.defs, blk.starts, 1, P.probe_file, P.placeFor(real));
        try expectFile(a, dir, try std.fs.path.join(a, &.{ "haro/probe", case, "expected.haro.txt" }), r.text);
        try expectFile(a, dir, try std.fs.path.join(a, &.{ "haro/probe", case, "expected_probe.haro.txt" }), try P.probeSource(a, r.ids, false));
        var b = T.Buf.init(a);
        for (r.skipped) |s| {
            try b.s(s.id);
            try b.c('|');
            try b.int(s.line);
            try b.c('|');
            try b.s(s.why);
            try b.c('\n');
        }
        try expectFile(a, dir, try std.fs.path.join(a, &.{ "haro/probe", case, "expected_skipped.txt" }), try b.done());
        const root = try std.fs.path.join(a, &.{ dir, "haro/probe", case, "src" });
        // the record: cut from the unit's record -- one file that loads none is its own unit -- to the file's definitions
        var own: std.ArrayList(P.Own) = .empty;
        for (blk.defs) |d| try own.append(a, .{ .def = d, .file = name });
        const unit = try Hg.fromLinesWith(a, lines, root, .{ .subject = "src" });
        try expectFile(a, dir, try std.fs.path.join(a, &.{ "haro/probe", case, "expected_graph.json" }), try P.ownRecord(a, unit, own.items, &.{name}, "src"));
    }
    try std.testing.expectEqual(@as(usize, 0), failures);
}

test "testoor report: the evidence report from a logbook, its graph and an impact (6.9)" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    failures = 0;
    const cases = try caseNames(a, dir, "haro/report");
    try std.testing.expect(cases.len >= 1);
    for (cases) |case| {
        const lb = try J.parse(a, try readAll(a, dir, try std.fs.path.join(a, &.{ "haro/report", case, "logbook.json" })));
        const g = try G.fromValue(a, try J.parse(a, try readAll(a, dir, try std.fs.path.join(a, &.{ "haro/report", case, "graph.json" }))));
        const meta = try J.parse(a, try readAll(a, dir, try std.fs.path.join(a, &.{ "haro/report", case, "meta.json" })));
        var stamp: std.ArrayList([]const u8) = .empty;
        if (meta.get("stamp")) |s| for (s.items()) |l| try stamp.append(a, l.str_());
        // the impact records: impact.json, then impact2.json, ... as the case holds them
        var impacts: std.ArrayList(J.Value) = .empty;
        var k: usize = 1;
        while (true) : (k += 1) {
            const name = if (k == 1) "impact.json" else try std.fmt.allocPrint(a, "impact{d}.json", .{k});
            const t = (try readOpt(a, dir, try std.fs.path.join(a, &.{ "haro/report", case, name }))) orelse break;
            try impacts.append(a, try J.parse(a, t));
        }
        const page = try Rp.markdown(a, lb, g, impacts.items, .{ .title = if (meta.get("title")) |t| t.str_() else "", .stamp = stamp.items });
        try expectFile(a, dir, try std.fs.path.join(a, &.{ "haro/report", case, "expected.md" }), page);
    }
    try std.testing.expectEqual(@as(usize, 0), failures);
}

test "testoor impact over a Haro unit: the face's names select the tours (BUSINESS-LEADS-DELIVER-01, A1 (3))" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    failures = 0;
    const cases = try caseNames(a, dir, "haro/impact");
    try std.testing.expect(cases.len >= 2);
    for (cases) |case| {
        const graph = try readAll(a, dir, try std.fs.path.join(a, &.{ "haro/impact", case, "graph.json" }));
        // the change: ids named, a diff (diff.patch, its paths and the graph's from the case's own folder), or both
        const changed = (try readOpt(a, dir, try std.fs.path.join(a, &.{ "haro/impact", case, "changed.txt" }))) orelse "";
        const diff = try readOpt(a, dir, try std.fs.path.join(a, &.{ "haro/impact", case, "diff.patch" }));
        // the tours, by name: what `testoor impact --tours` hands the core
        var names: std.ArrayList([]const u8) = .empty;
        const tdir = try std.fs.path.join(a, &.{ dir, "haro/impact", case, "tours" });
        var d = try std.fs.cwd().openDir(tdir, .{ .iterate = true });
        defer d.close();
        var it = d.iterate();
        while (try it.next()) |e| if (e.kind == .file) try names.append(a, try a.dupe(u8, e.name));
        std.mem.sort([]const u8, names.items, {}, struct {
            fn lt(_: void, x: []const u8, y: []const u8) bool {
                return std.mem.lessThan(u8, x, y);
            }
        }.lt);
        var b = T.Buf.init(a);
        try b.s("{\"protocol\":3,\"graph\":");
        try b.s(graph);
        try b.s(",\"changed\":[");
        var first = true;
        var cl = std.mem.splitScalar(u8, changed, '\n');
        while (cl.next()) |c| {
            const id = std.mem.trim(u8, c, " \r");
            if (id.len == 0) continue;
            if (!first) try b.c(',');
            first = false;
            try b.js(id);
        }
        try b.c(']');
        if (diff) |patch| {
            try b.s(",\"diff\":");
            try b.js(patch);
            try b.s(",\"root\":\"\",\"repo\":\"\",\"texts\":[");
            // src/: each file's text after the change, named with `.txt` after its path
            const sdir = try std.fs.path.join(a, &.{ dir, "haro/impact", case, "src" });
            if (std.fs.cwd().openDir(sdir, .{ .iterate = true })) |opened| {
                var sd = opened;
                defer sd.close();
                var w = try sd.walk(a);
                defer w.deinit();
                var n_src: usize = 0;
                while (try w.next()) |e| {
                    if (e.kind != .file or !std.mem.endsWith(u8, e.path, ".txt")) continue;
                    const rel = try a.dupe(u8, e.path[0 .. e.path.len - 4]);
                    for (rel) |*ch| {
                        if (ch.* == '\\') ch.* = '/';
                    }
                    if (n_src > 0) try b.c(',');
                    n_src += 1;
                    try b.s("{\"path\":");
                    try b.js(rel);
                    try b.s(",\"text\":");
                    try b.js(try readAll(a, sdir, e.path));
                    try b.c('}');
                }
            } else |_| {}
            try b.c(']');
        }
        try b.s(",\"tours\":[");
        for (names.items, 0..) |nm, k| {
            if (k > 0) try b.c(',');
            const src = try readAll(a, dir, try std.fs.path.join(a, &.{ "haro/impact", case, "tours", nm }));
            try b.s("{\"file\":");
            try b.js(nm);
            if (diff != null) {
                try b.s(",\"at\":");
                try b.js(try std.mem.concat(a, u8, &.{ "tours/", nm }));
            }
            try b.s(",\"names\":[");
            for (try Rd.namesOf(a, src), 0..) |n, j| {
                if (j > 0) try b.c(',');
                try b.js(n);
            }
            try b.s("]}");
        }
        try b.s("]}");
        var got: std.ArrayList(u8) = .empty;
        try got.appendSlice(a, try A.impactJson(a, try b.done()));
        try got.append(a, '\n');
        try expectFile(a, dir, try std.fs.path.join(a, &.{ "haro/impact", case, "expected.json" }), got.items);
    }
    try std.testing.expectEqual(@as(usize, 0), failures);
}

test "the recall record: what each tour of a probed walk ran beyond what its names reach in the graph (P4)" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    failures = 0;
    const cases = try caseNames(a, dir, "haro/recall");
    try std.testing.expect(cases.len >= 1);
    for (cases) |case| {
        const case_dir = try std.fs.path.join(a, &.{ dir, "haro/recall", case });
        const graph = try readAll(a, case_dir, "graph.json");
        const log = try J.parse(a, try readAll(a, case_dir, "logbook.json"));
        // what `testoor recall` hands the core: each tour's names, read from its file where the logbook names it, and the
        // ids it ran, its observed nodes
        var b = T.Buf.init(a);
        try b.s("{\"graph\":");
        try b.s(graph);
        try b.s(",\"tours\":[");
        for ((log.get("tours") orelse return error.NoTours).items(), 0..) |t, k| {
            if (k > 0) try b.c(',');
            const file = (t.get("file") orelse return error.NoFile).str_();
            try b.s("{\"file\":");
            try b.js(file);
            try b.s(",\"names\":[");
            // a tour is kept as `<file>.txt`, so no sweep of `.haro` files counts a fixture
            for (try Rd.namesOf(a, try readAll(a, case_dir, try std.mem.concat(a, u8, &.{ file, ".txt" }))), 0..) |n, j| {
                if (j > 0) try b.c(',');
                try b.js(n);
            }
            try b.s("],\"ran\":[");
            var n_ran: usize = 0;
            for ((t.get("nodes") orelse return error.NoNodes).items()) |n| {
                if (!std.mem.eql(u8, (n.get("evidence") orelse continue).str_(), "observed")) continue;
                if (n_ran > 0) try b.c(',');
                n_ran += 1;
                try b.js((n.get("id") orelse continue).str_());
            }
            try b.s("]}");
        }
        try b.s("]}");
        var got: std.ArrayList(u8) = .empty;
        try got.appendSlice(a, try A.recallJson(a, try b.done()));
        try got.append(a, '\n');
        try expectFile(a, dir, try std.fs.path.join(a, &.{ "haro/recall", case, "expected.json" }), got.items);
    }
    try std.testing.expectEqual(@as(usize, 0), failures);
}

test "the Haro face reads a .haro tour into the record the judge reads (P3.6)" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    const cases = try caseNames(a, dir, "haro/reader");
    try std.testing.expect(cases.len >= 2);
    failures = 0;
    for (cases) |case| {
        const path = try std.fs.path.join(a, &.{ dir, "haro/reader", case, "tour.haro" });
        const src = try std.fs.cwd().readFileAlloc(a, path, 1 << 20);
        var b = T.Buf.init(a);
        try Rd.writeRecord(&b, try Rd.readHaro(a, "tour.haro", src));
        try b.c('\n');
        try expectFile(a, dir, try std.fs.path.join(a, &.{ "haro/reader", case, "expected.json" }), try b.done());
    }
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
