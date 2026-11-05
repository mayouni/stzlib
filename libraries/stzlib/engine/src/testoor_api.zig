//! Testoor core -- the text-in, text-out surface the Ring bridge calls. Pure Zig: a request is
//! a JSON document, an answer is the bytes the reference would have written. Nothing here
//! imports Ring, so the same functions are tested without a virtual machine and linked into
//! a native `stz guard` child later (roadmap P3.5).
//!
//!   verdict   {"record":<tour record>,"output":"<ms TAB text per line>" or [[text, ms]...],"meta":<walk facts>}
//!             -> the tour as the logbook writes it; with "detail":1 each stop also says the
//!                milliseconds it opened and closed at, which the Ring runner's record keeps
//!   run       {"run":<settings>,"tours":[<tour as the logbook writes it>...]}
//!             -> the run as JSON, as prose, or as the runner's exit code
//!
//! The formats are the golden logbooks' own (base/testoor/golden/README.md), so a request can
//! be built from the committed inputs and an answer compared with the committed expected files.

const std = @import("std");
const Allocator = std.mem.Allocator;
const T = @import("testoor_text.zig");
const J = @import("testoor_json.zig");
const V = @import("testoor_verdict.zig");
const L = @import("testoor_logbook.zig");

pub const Error = error{ BadRequest, OutOfMemory, BadOutputLine, BadJson };

fn field(v: J.Value, key: []const u8) Error!J.Value {
    return v.get(key) orelse Error.BadRequest;
}

/// the judgement of one walked tour
pub fn verdictJson(a: Allocator, request: []const u8) Error![]u8 {
    const req = try J.parse(a, request);
    const rec = try V.recordFromValue(a, try field(req, "record"));
    const meta = try V.metaFromValue(a, try field(req, "meta"));
    const out_v = try field(req, "output");
    const lines = switch (out_v) {
        .arr => try V.linesFromValue(a, out_v),
        else => try V.linesFromText(a, out_v.str_()),
    };
    const tour = try V.verdict(a, rec, lines, meta);
    const detail = if (req.get("detail")) |d| d.truthy() else false;
    var b = T.Buf.init(a);
    try L.tourJsonDetail(&b, tour, detail);
    return b.done();
}

fn stateFromName(name: []const u8) V.State {
    const all = [_]V.State{ .kept, .diverged, .unreached, .unjudged, .unperceived };
    for (all) |s| if (std.mem.eql(u8, s.name(), name)) return s;
    return .none;
}

/// a tour as the logbook writes it, read back
pub fn tourFromValue(a: Allocator, v: J.Value) Error!V.Tour {
    var stops: std.ArrayList(V.Stop) = .empty;
    for ((try field(v, "stops")).items()) |sv| {
        var st = V.Stop{
            .title = (try field(sv, "title")).str_(),
            .line = (try field(sv, "line")).int_(),
            .state = stateFromName((try field(sv, "state")).str_()),
            .wall_ms = (try field(sv, "wall_ms")).num_(),
        };
        for ((try field(sv, "claims")).items()) |cv| {
            try st.claims.append(a, .{
                .claim = (try field(cv, "claim")).str_(),
                .kind = (try field(cv, "kind")).str_(),
                .line = (try field(cv, "line")).int_(),
                .want = "",
                .state = stateFromName((try field(cv, "state")).str_()),
            });
        }
        try stops.append(a, st);
    }
    var routes: std.ArrayList(V.RRoute) = .empty;
    for ((try field(v, "routes")).items()) |rv| {
        try routes.append(a, .{
            .item = (try field(rv, "item")).str_(),
            .stop = (try field(rv, "stop")).str_(),
            .line = (try field(rv, "line")).int_(),
        });
    }
    var weather: std.ArrayList([]const u8) = .empty;
    for ((try field(v, "weather")).items()) |w| try weather.append(a, w.str_());
    var seed: ?f64 = null;
    switch (try field(v, "seed")) {
        .num => |n| seed = n,
        else => {},
    }
    return .{
        .file = (try field(v, "file")).str_(),
        .dialect = (try field(v, "dialect")).str_(),
        .flaky = (try field(v, "flaky")).truthy(),
        .weather = weather.items,
        .routes = routes.items,
        .run = .{
            .end = (try field(v, "end")).str_(),
            .exit = (try field(v, "exit")).int_(),
            .wall_ms = (try field(v, "wall_ms")).num_(),
            .seed = seed,
            .state = stateFromName((try field(v, "state")).str_()),
            .kept = (try field(v, "kept")).int_(),
            .diverged = (try field(v, "diverged")).int_(),
            .unreached = (try field(v, "unreached")).int_(),
            .unjudged = (try field(v, "unjudged")).int_(),
            .stops = stops.items,
        },
    };
}

fn strings(a: Allocator, v: ?J.Value) Error![]const []const u8 {
    var out: std.ArrayList([]const u8) = .empty;
    if (v) |x| for (x.items()) |s| try out.append(a, s.str_());
    return out.items;
}

const Run = struct { settings: L.Settings, tours: []V.Tour };

fn readRun(a: Allocator, request: []const u8) Error!Run {
    const req = try J.parse(a, request);
    const rv = try field(req, "run");
    var st = L.Settings{};
    if (rv.get("by")) |x| st.by = x.str_();
    if (rv.get("root")) |x| st.root = x.str_();
    if (rv.get("topic")) |x| st.topic = x.str_();
    if (rv.get("subject")) |x| st.subject = x.str_();
    if (rv.get("refusal")) |x| st.refusal = x.str_();
    if (rv.get("seed")) |x| st.seed = x.num_();
    if (rv.get("repeat")) |x| st.repeat = x.num_();
    if (rv.get("timeout_ms")) |x| st.timeout_ms = x.num_();
    st.skipped = try strings(a, rv.get("skipped"));
    st.topics_skipped = try strings(a, rv.get("topics_skipped"));
    var tours: std.ArrayList(V.Tour) = .empty;
    if (req.get("tours")) |tv| for (tv.items()) |t| try tours.append(a, try tourFromValue(a, t));
    return .{ .settings = st, .tours = tours.items };
}

pub fn runJson(a: Allocator, request: []const u8) Error![]u8 {
    const r = try readRun(a, request);
    var b = T.Buf.init(a);
    try L.runJson(&b, r.settings, r.tours);
    return b.done();
}

pub fn runProse(a: Allocator, request: []const u8) Error![]u8 {
    const r = try readRun(a, request);
    var b = T.Buf.init(a);
    try L.runProse(&b, r.settings, r.tours);
    return b.done();
}

pub fn runExit(a: Allocator, request: []const u8) Error!i64 {
    const r = try readRun(a, request);
    return L.exitCode(r.settings, r.tours);
}

pub fn tourProseJson(a: Allocator, tour_json: []const u8) Error![]u8 {
    const t = try tourFromValue(a, try J.parse(a, tour_json));
    var b = T.Buf.init(a);
    try L.tourProse(&b, t);
    return b.done();
}

// ── tests: the same goldens, through the text surface ────────

const testing = std.testing;

fn goldenDir(a: Allocator) ![]const u8 {
    return std.process.getEnvVarOwned(a, "TESTOOR_GOLDEN") catch try a.dupe(u8, "../base/testoor/golden");
}

fn readClean(a: Allocator, dir: []const u8, rel: []const u8) ![]u8 {
    const path = try std.fs.path.join(a, &.{ dir, rel });
    const raw = try std.fs.cwd().readFileAlloc(a, path, 64 * 1024 * 1024);
    return T.removeCr(a, raw);
}

test "a verdict request built from the committed inputs gives the committed tour" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    const jdir = try std.fs.path.join(a, &.{ dir, "judge" });
    var d = try std.fs.cwd().openDir(jdir, .{ .iterate = true });
    defer d.close();
    var it = d.iterate();
    var n: usize = 0;
    while (try it.next()) |e| {
        if (e.kind != .directory or e.name[0] == '.' or e.name[0] == '_') continue;
        const base = try std.fs.path.join(a, &.{ "judge", e.name });
        const rec = try readClean(a, dir, try std.fs.path.join(a, &.{ base, "record.json" }));
        const meta = try readClean(a, dir, try std.fs.path.join(a, &.{ base, "meta.json" }));
        const out = try readClean(a, dir, try std.fs.path.join(a, &.{ base, "output.txt" }));
        const want = try readClean(a, dir, try std.fs.path.join(a, &.{ base, "expected.json" }));
        var rb = T.Buf.init(a);
        try rb.s("{\"record\":");
        try rb.s(rec);
        try rb.s(",\"output\":");
        try rb.js(out);
        try rb.s(",\"meta\":");
        try rb.s(meta);
        try rb.c('}');
        const got = try verdictJson(a, try rb.done());
        try testing.expectEqualStrings(std.mem.trimRight(u8, want, "\n"), got);
        // and the tour read back writes itself the same way: the round trip is the identity
        const again = try tourFromValue(a, try J.parse(a, got));
        var jb = T.Buf.init(a);
        try L.tourJson(&jb, again);
        try testing.expectEqualStrings(got, try jb.done());
        n += 1;
    }
    try testing.expect(n >= 14);
}

test "a run request built from the committed tours gives the committed logbook" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    const ldir = try std.fs.path.join(a, &.{ dir, "logbook" });
    var d = try std.fs.cwd().openDir(ldir, .{ .iterate = true });
    defer d.close();
    var it = d.iterate();
    var n: usize = 0;
    while (try it.next()) |e| {
        if (e.kind != .directory or e.name[0] == '.' or e.name[0] == '_') continue;
        const base = try std.fs.path.join(a, &.{ "logbook", e.name });
        const rj = try J.parse(a, try readClean(a, dir, try std.fs.path.join(a, &.{ base, "run.json" })));
        var rb = T.Buf.init(a);
        const refuse = (try field(rj, "refuse_root")).str_();
        try rb.s("{\"run\":{\"by\":");
        try rb.js((try field(rj, "by")).str_());
        try rb.s(",\"root\":");
        try rb.js(if (refuse.len != 0) refuse else (try field(rj, "root")).str_());
        try rb.s(",\"topic\":");
        try rb.js((try field(rj, "topic")).str_());
        try rb.s(",\"subject\":");
        try rb.js((try field(rj, "subject")).str_());
        try rb.s(",\"refusal\":");
        try rb.js(if (refuse.len != 0) try std.fmt.allocPrint(a, "no such root: {s}", .{refuse}) else "");
        try rb.s(",\"seed\":");
        try rb.num((try field(rj, "seed")).num_());
        try rb.s(",\"repeat\":");
        try rb.num((try field(rj, "repeat")).num_());
        try rb.s(",\"timeout_ms\":");
        try rb.num((try field(rj, "timeout_ms")).num_());
        try rb.s(",\"skipped\":[");
        if (refuse.len == 0) for ((try field(rj, "skipped")).items(), 0..) |s, k| {
            if (k > 0) try rb.c(',');
            try rb.js(s.str_());
        };
        try rb.s("],\"topics_skipped\":[");
        if (refuse.len == 0) for ((try field(rj, "topics_skipped")).items(), 0..) |s, k| {
            if (k > 0) try rb.c(',');
            try rb.js(s.str_());
        };
        try rb.s("]},\"tours\":[");
        if (refuse.len == 0) {
            const flaky = (try field(rj, "flaky")).items();
            for ((try field(rj, "cases")).items(), 0..) |cv, k| {
                if (k > 0) try rb.c(',');
                var tj = std.mem.trimRight(u8, try readClean(a, dir, try std.fs.path.join(a, &.{ "judge", cv.str_(), "expected.json" })), "\n");
                for (flaky) |f| if (std.mem.eql(u8, f.str_(), cv.str_())) {
                    tj = try T.replaceAll(a, tj, "\"flaky\":0,", "\"flaky\":1,");
                };
                try rb.s(tj);
            }
        }
        try rb.s("]}");
        const req = try rb.done();
        const want_json = try readClean(a, dir, try std.fs.path.join(a, &.{ base, "expected.json" }));
        const want_txt = try readClean(a, dir, try std.fs.path.join(a, &.{ base, "expected.txt" }));
        const want_exit = try readClean(a, dir, try std.fs.path.join(a, &.{ base, "expected.exit" }));
        try testing.expectEqualStrings(std.mem.trimRight(u8, want_json, "\n"), try runJson(a, req));
        try testing.expectEqualStrings(std.mem.trimRight(u8, want_txt, "\n"), try runProse(a, req));
        try testing.expectEqual(try std.fmt.parseInt(i64, std.mem.trim(u8, want_exit, "\n"), 10), try runExit(a, req));
        n += 1;
    }
    try testing.expect(n >= 5);
}

test "a request missing a field is an error, never a panic" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    try testing.expectError(error.BadRequest, verdictJson(a, "{}"));
    try testing.expectError(error.BadRequest, verdictJson(a, "{\"record\":{}}"));
    try testing.expectError(error.BadJson, verdictJson(a, "this is not json"));
    try testing.expectError(error.BadRequest, runExit(a, "{\"tours\":[]}"));
    // a number too large to be an integer is read as 0, not trapped
    const huge = "{\"record\":{\"file\":\"x\",\"dialect\":\"chk\",\"asserts\":1e999,\"stops\":[],\"routes\":[]}," ++
        "\"output\":\"\",\"meta\":{\"exit\":1e999,\"hung\":0,\"stderr\":\"\",\"wall_ms\":1e999,\"seed\":null,\"unreadable\":0}}";
    _ = try verdictJson(a, huge);
}

test "a request cut at any byte is answered or refused, and never panics" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    const base = "judge/05_broke_midway";
    const rec = try readClean(a, dir, base ++ "/record.json");
    const meta = try readClean(a, dir, base ++ "/meta.json");
    const out = try readClean(a, dir, base ++ "/output.txt");
    var rb = T.Buf.init(a);
    try rb.s("{\"record\":");
    try rb.s(rec);
    try rb.s(",\"output\":");
    try rb.js(out);
    try rb.s(",\"meta\":");
    try rb.s(meta);
    try rb.c('}');
    const req = try rb.done();
    var answered: usize = 0;
    var i: usize = 0;
    while (i < req.len) : (i += 3) {
        var sub_arena = std.heap.ArenaAllocator.init(testing.allocator);
        defer sub_arena.deinit();
        if (verdictJson(sub_arena.allocator(), req[0..i])) |_| answered += 1 else |_| {}
    }
    try testing.expectEqual(@as(usize, 0), answered); // a truncated document is never a request
}

test "detail mode adds each stop's opening and closing millisecond and nothing else" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const dir = try goldenDir(a);
    const base = "judge/05_broke_midway";
    const rec = try readClean(a, dir, base ++ "/record.json");
    const meta = try readClean(a, dir, base ++ "/meta.json");
    const out = try readClean(a, dir, base ++ "/output.txt");
    var rb = T.Buf.init(a);
    try rb.s("{\"detail\":1,\"record\":");
    try rb.s(rec);
    try rb.s(",\"output\":");
    try rb.js(out);
    try rb.s(",\"meta\":");
    try rb.s(meta);
    try rb.c('}');
    const got = try verdictJson(a, try rb.done());
    try testing.expect(std.mem.indexOf(u8, got, "\"opened_ms\":250,\"closed_ms\":750") != null);
    try testing.expect(std.mem.indexOf(u8, got, "\"opened_ms\":750,\"closed_ms\":1250") != null);
    // taking the detail keys out gives the golden tour back
    const want = std.mem.trimRight(u8, try readClean(a, dir, base ++ "/expected.json"), "\n");
    var plain = got;
    for ([_][]const u8{ ",\"opened_ms\":250,\"closed_ms\":750", ",\"opened_ms\":750,\"closed_ms\":1250" }) |cut| {
        plain = try T.replaceAll(a, plain, cut, "");
    }
    try testing.expectEqualStrings(want, plain);
}
