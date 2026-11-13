//! Testoor core -- THE RUNNER (roadmap P3.5): a manifest of tours in, the logbook out, with no Ring
//! virtual machine anywhere. It is what a program that is not Ring (the `stz` command line, a Haro
//! program, a continuous-integration step) calls as a CHILD, the way Central ruled the stz CLI would
//! call Testoor's runner: it reads a manifest, walks each tour (testoor_walk.zig), judges each walk
//! (testoor_verdict.zig), and writes the run (testoor_logbook.zig) as JSON or as prose, with the
//! exit code of the Ring runner: 0 when every stop is kept or unperceived, 1 when a stop diverged, a
//! tour did not start, broke, hung, could not be read or is flaky, 2 when the runner itself refused.
//!
//! WHAT THE RUNNER DOES NOT DO is read a source file into a tour record: that is the FACE's work
//! (TESTOOR_ZIG_CORE.md section 1), and a manifest is what a face hands over -- for each tour the
//! record it read (the golden `record.json`), the argv that launches it, the folder to launch it
//! from, and its ending rules as data. A tour with no record is a self-describing one (it prints
//! `[testoor stop ...]`, `[testoor ok ...]`) and is judged from what it says.
//!
//! The manifest, one JSON document:
//!   {"run":{"by","root","topic","subject","seed","repeat","timeout_ms","refusal"},
//!    "skipped":[..],"topics_skipped":[..],
//!    "tours":[{"file","cwd","argv":[..],"env":{..},"readable":1,"record":{..},
//!              "face":{"ignore":"","endings":[[text,ending],..]}}]}
//! `{seed}` in an argv element is replaced by the run's seed (drawn from the clock when none is given),
//! as the Ring runner does for a face's launch template.
//!
//! Imports no Ring.

const std = @import("std");
const Allocator = std.mem.Allocator;
const T = @import("testoor_text.zig");
const J = @import("testoor_json.zig");
const V = @import("testoor_verdict.zig");
const L = @import("testoor_logbook.zig");
const W = @import("testoor_walk.zig");
const K = @import("testoor_clock.zig");
const Ev = @import("testoor_evidence.zig");
const Rd = @import("testoor_reader.zig");

pub const TourSpec = struct {
    file: []const u8,
    cwd: ?[]const u8 = null,
    argv: []const []const u8 = &.{},
    env: []const W.Env = &.{},
    /// false: the face could not read it, or has no way to launch it; it is named, not guessed, and not run
    readable: bool = true,
    record: V.Record,
    face: V.Face = .{},
};

pub const Manifest = struct {
    settings: L.Settings = .{},
    tours: []const TourSpec = &.{},
};

pub const Result = struct {
    settings: L.Settings,
    tours: []V.Tour,
};

fn firstThree(s: []const u8) []const u8 {
    return s[0..@min(3, s.len)];
}

/// What a walk read, in one line, so two walks of one tour can be compared: the state and the ending,
/// then the first three letters of every claim's state. The Ring runner's `_TravSignature`.
pub fn signature(a: Allocator, t: V.Tour) ![]u8 {
    var b = T.Buf.init(a);
    try b.s(t.run.state.name());
    try b.c('/');
    try b.s(t.run.end);
    for (t.run.stops) |st| {
        for (st.claims.items) |cl| {
            try b.c(',');
            try b.s(firstThree(cl.state.name()));
        }
    }
    return b.done();
}

/// argv with `{seed}` replaced by the seed as Ring prints it
pub fn seedArgv(a: Allocator, argv: []const []const u8, seed: f64) ![]const []const u8 {
    const sd = try T.fmtNum(a, seed);
    const out = try a.alloc([]const u8, argv.len);
    for (argv, 0..) |s, i| out[i] = try T.replaceAll(a, s, "{seed}", sd);
    return out;
}

/// ONE walk of ONE tour, judged: the tour as the logbook writes it
pub fn walkOnce(a: Allocator, ts: TourSpec, seed: f64, timeout_ms: f64) !V.Tour {
    if (!ts.readable or ts.argv.len == 0) {
        return V.verdict(a, ts.record, &.{}, .{ .exit = -1, .hung = false, .stderr = "", .wall_ms = 0, .seed = null, .unreadable = true, .face = ts.face });
    }
    const w = try W.walk(a, .{ .argv = try seedArgv(a, ts.argv, seed), .cwd = ts.cwd, .env = ts.env, .timeout_ms = timeout_ms });
    return V.verdict(a, ts.record, w.lines, .{
        .exit = w.exit,
        .hung = w.hung,
        .stderr = w.stderr,
        .wall_ms = w.wall_ms,
        .seed = seed,
        .unreadable = false,
        .face = ts.face,
    });
}

pub const OnTour = *const fn (V.Tour) void;

// ── P3.6: tours found under a folder, read by the Haro face ──────────

fn lessThan(_: void, x: []const u8, y: []const u8) bool {
    return std.mem.lessThan(u8, x, y);
}

/// The tours under `root`: files whose name ends with `suffix`, in any folder below it, sorted. A file or a folder whose
/// name begins with `_` or `.` is not a tour (measurement scripts, planted fixtures, data), so it is never walked.
pub fn discover(a: Allocator, root: []const u8, suffix: []const u8) ![]const []const u8 {
    var dir = try std.fs.cwd().openDir(root, .{ .iterate = true });
    defer dir.close();
    var walker = try dir.walk(a);
    defer walker.deinit();
    var out: std.ArrayList([]const u8) = .empty;
    while (try walker.next()) |e| {
        if (e.kind != .file) continue;
        if (!std.mem.endsWith(u8, e.basename, suffix)) continue;
        var hidden = false;
        var parts = std.mem.tokenizeAny(u8, e.path, "/\\");
        while (parts.next()) |part| {
            if (part.len > 0 and (part[0] == '_' or part[0] == '.')) hidden = true;
        }
        if (hidden) continue;
        const rel = try a.dupe(u8, e.path);
        for (rel) |*ch| if (ch.* == '\\') {
            ch.* = '/';
        };
        try out.append(a, rel);
    }
    std.mem.sort([]const u8, out.items, {}, lessThan);
    return out.items;
}

/// One `.haro` tour as the native runner walks it: read by the Haro face, launched as `<haro> <file>` from the tour's
/// own folder (a guard loads the library by a path relative to it), its endings the Haro face's. A file that cannot be
/// read is named and not walked.
pub fn haroTour(a: Allocator, root: []const u8, rel: []const u8, program: []const u8) !TourSpec {
    const path = try std.fmt.allocPrint(a, "{s}/{s}", .{ std.mem.trimRight(u8, root, "/\\"), rel });
    const text = std.fs.cwd().readFileAlloc(a, path, 64 * 1024 * 1024) catch {
        return .{ .file = path, .readable = false, .record = .{ .file = path, .dialect = "unknown", .asserts = 0, .stops = &.{}, .routes = &.{} }, .face = Rd.face };
    };
    const rd = try Rd.readHaro(a, path, text);
    const argv = try a.alloc([]const u8, 2);
    argv[0] = program;
    argv[1] = std.fs.path.basename(path);
    return .{ .file = path, .cwd = std.fs.path.dirname(path) orelse ".", .argv = argv, .record = rd.record, .face = Rd.face };
}

/// Walk every tour of the manifest, each once and, when `repeat` asks for more, again with the same
/// seed: a tour whose verdict differs between its walks is FLAKY, and the walk that differed is the
/// proof. The run's wall time is the sum of every walk's, repeats included, as the Ring runner's is.
pub fn run(a: Allocator, m: Manifest, on_tour: ?OnTour) !Result {
    var st = m.settings;
    if (st.refusal.len != 0) return .{ .settings = st, .tours = &.{} };
    if (st.seed < 0) st.seed = K.World.draw(@floatFromInt(@as(i64, @intCast(@mod(std.time.milliTimestamp(), 1_000_000_000)))));
    const repeat: usize = if (st.repeat < 1) 1 else @intFromFloat(@min(st.repeat, 1000));
    var tours: std.ArrayList(V.Tour) = .empty;
    var wall: f64 = 0;
    for (m.tours) |ts| {
        var first = try walkOnce(a, ts, st.seed, st.timeout_ms);
        wall += first.run.wall_ms;
        if (ts.readable and ts.argv.len > 0) {
            const sig = try signature(a, first);
            var k: usize = 2;
            while (k <= repeat) : (k += 1) {
                const again = try walkOnce(a, ts, st.seed, st.timeout_ms);
                wall += again.run.wall_ms;
                if (!std.mem.eql(u8, sig, try signature(a, again))) {
                    first.flaky = true;
                    break;
                }
            }
        }
        if (on_tour) |f| f(first);
        try tours.append(a, first);
    }
    st.wall_ms = wall;
    return .{ .settings = st, .tours = tours.items };
}

// ── the manifest, read ───────────────────────────────────────

fn strings(a: Allocator, v: ?J.Value) ![]const []const u8 {
    var out: std.ArrayList([]const u8) = .empty;
    if (v) |x| for (x.items()) |s| try out.append(a, s.str_());
    return out.items;
}

fn faceFrom(a: Allocator, v: ?J.Value) !V.Face {
    var f = V.Face{};
    const fv = v orelse return f;
    if (fv.get("ignore")) |x| f.ignore = x.str_();
    var endings: std.ArrayList(V.Ending) = .empty;
    if (fv.get("endings")) |ev| {
        for (ev.items()) |e| {
            const pair = e.items();
            if (pair.len >= 2) try endings.append(a, .{ .text = pair[0].str_(), .ending = pair[1].str_() });
        }
    }
    f.endings = endings.items;
    return f;
}

/// the record of a self-describing tour: it says what it is as it runs
fn selfDescribing(file: []const u8) V.Record {
    return .{ .file = file, .dialect = "protocol", .asserts = 1, .stops = &.{}, .routes = &.{} };
}

pub fn fromValue(a: Allocator, v: J.Value) !Manifest {
    var m = Manifest{};
    if (v.get("run")) |rv| {
        if (rv.get("by")) |x| m.settings.by = x.str_();
        if (rv.get("root")) |x| m.settings.root = x.str_();
        if (rv.get("topic")) |x| m.settings.topic = x.str_();
        if (rv.get("subject")) |x| m.settings.subject = x.str_();
        if (rv.get("refusal")) |x| m.settings.refusal = x.str_();
        if (rv.get("seed")) |x| m.settings.seed = x.num_();
        if (rv.get("repeat")) |x| m.settings.repeat = x.num_();
        if (rv.get("timeout_ms")) |x| m.settings.timeout_ms = x.num_();
        if (rv.get("evidence")) |x| m.settings.evidence = Ev.fromValue(x);
        if (rv.get("ladder")) |x| m.settings.ladder = x.truthy();
        if (rv.get("impact")) |x| m.settings.impact = try Ev.impactFromValue(a, x);
    }
    m.settings.skipped = try strings(a, v.get("skipped"));
    m.settings.topics_skipped = try strings(a, v.get("topics_skipped"));
    var tours: std.ArrayList(TourSpec) = .empty;
    if (v.get("tours")) |tv| {
        for (tv.items()) |t| {
            const file = if (t.get("file")) |x| x.str_() else "";
            var env: std.ArrayList(W.Env) = .empty;
            if (t.get("env")) |ev| switch (ev) {
                .obj => |pairs| for (pairs) |p| try env.append(a, .{ .key = p.key, .value = p.val.str_() }),
                else => {},
            };
            try tours.append(a, .{
                .file = file,
                .cwd = if (t.get("cwd")) |x| (if (x.str_().len > 0) x.str_() else null) else null,
                .argv = try strings(a, t.get("argv")),
                .env = env.items,
                .readable = if (t.get("readable")) |x| x.truthy() else true,
                .record = if (t.get("record")) |rv| try V.recordFromValue(a, rv) else selfDescribing(file),
                .face = try faceFrom(a, t.get("face")),
            });
        }
    }
    m.tours = tours.items;
    return m;
}

// ── tests ────────────────────────────────────────────────────

const testing = std.testing;
const builtin = @import("builtin");

test "a signature is the state and the ending, then three letters of each claim" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const lines = [_]V.Line{
        .{ .text = "[testoor stop s]", .at = 0.25 },
        .{ .text = "[testoor ok one]", .at = 0.5 },
        .{ .text = "[testoor fail two]", .at = 0.75 },
    };
    const t = try V.verdict(a, selfDescribing("t.py"), &lines, .{ .exit = 0, .hung = false, .stderr = "", .wall_ms = 1000, .seed = 5, .unreadable = false, .face = .{} });
    try testing.expectEqualStrings("diverged/finished,kep,div", try signature(a, t));
}

test "{seed} in an argv element is replaced by the seed, as Ring prints it" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const out = try seedArgv(a, &.{ "prog", "--testoor-seed", "{seed}", "x{seed}y" }, 42);
    try testing.expectEqualStrings("42", out[2]);
    try testing.expectEqualStrings("x42y", out[3]);
    try testing.expectEqualStrings("prog", out[0]);
}

test "a manifest is read: settings, skipped, a tour with a record and one that describes itself" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const doc =
        \\{"run":{"by":"stz","root":"t","seed":7,"repeat":2,"timeout_ms":5000},
        \\ "skipped":["x.ring"],
        \\ "tours":[{"file":"a.py","cwd":"t","argv":["python","a.py"],"env":{"K":"V"}},
        \\          {"file":"b.ring","readable":0,"record":{"file":"b.ring","dialect":"narrated","asserts":1,"stops":[],"routes":[]}}]}
    ;
    const m = try fromValue(a, try J.parse(a, doc));
    try testing.expectEqualStrings("stz", m.settings.by);
    try testing.expectEqual(@as(f64, 7), m.settings.seed);
    try testing.expectEqual(@as(f64, 2), m.settings.repeat);
    try testing.expectEqual(@as(usize, 1), m.settings.skipped.len);
    try testing.expectEqual(@as(usize, 2), m.tours.len);
    try testing.expectEqualStrings("protocol", m.tours[0].record.dialect);
    try testing.expectEqualStrings("V", m.tours[0].env[0].value);
    try testing.expect(!m.tours[1].readable);
}

test "a tour that cannot be read is named and not run; a refused run walks nothing" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const ts = TourSpec{ .file = "b.ring", .readable = false, .record = .{ .file = "b.ring", .dialect = "narrated", .asserts = 1, .stops = &.{}, .routes = &.{} } };
    const r = try run(a, .{ .settings = .{ .seed = 3 }, .tours = &.{ts} }, null);
    try testing.expectEqual(@as(usize, 1), r.tours.len);
    try testing.expectEqualStrings("unreadable", r.tours[0].run.end);
    try testing.expectEqual(@as(i64, 1), L.exitCode(r.settings, r.tours));
    const refused = try run(a, .{ .settings = .{ .refusal = "no such root: x" }, .tours = &.{ts} }, null);
    try testing.expectEqual(@as(usize, 0), refused.tours.len);
    try testing.expectEqual(@as(i64, 2), L.exitCode(refused.settings, refused.tours));
}

test "a self-describing tour is walked and judged end to end, with the exit the runner owns" {
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const argv_ok = [_][]const u8{ "cmd.exe", "/c", "echo [testoor stop first]&& echo [testoor ok it holds]&& echo [testoor end timed]" };
    const argv_bad = [_][]const u8{ "cmd.exe", "/c", "echo [testoor stop second]&& echo [testoor fail it does not]" };
    const specs = [_]TourSpec{
        .{ .file = "ok.py", .argv = &argv_ok, .record = selfDescribing("ok.py") },
        .{ .file = "bad.py", .argv = &argv_bad, .record = selfDescribing("bad.py") },
    };
    const r = try run(a, .{ .settings = .{ .seed = 9, .timeout_ms = 20000 }, .tours = &specs }, null);
    try testing.expectEqual(@as(usize, 2), r.tours.len);
    try testing.expectEqualStrings("kept", r.tours[0].run.state.name());
    try testing.expectEqualStrings("diverged", r.tours[1].run.state.name());
    try testing.expectEqual(@as(i64, 1), L.exitCode(r.settings, r.tours));
    var b = T.Buf.init(a);
    try L.runJson(&b, r.settings, r.tours);
    const j = try b.done();
    try testing.expect(std.mem.indexOf(u8, j, "\"owned\":2,\"run\":2") != null);
    try testing.expect(std.mem.indexOf(u8, j, "\"seed\":9") != null);
}

test "a tour whose walks disagree is flaky, and one whose walks agree is not" {
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    // the marker file is the ambient fact: the first walk fails and leaves it, the second passes
    const marker = "testoor_flaky_marker.tmp";
    std.fs.cwd().deleteFile(marker) catch {};
    defer std.fs.cwd().deleteFile(marker) catch {};
    const cmd = "if exist testoor_flaky_marker.tmp (echo [testoor stop s]&& echo [testoor ok lucky]) else (echo x>testoor_flaky_marker.tmp&& echo [testoor stop s]&& echo [testoor fail unlucky])";
    const argv_flaky = [_][]const u8{ "cmd.exe", "/c", cmd };
    const argv_stable = [_][]const u8{ "cmd.exe", "/c", "echo [testoor stop s]&& echo [testoor ok same]" };
    const specs = [_]TourSpec{
        .{ .file = "flaky.py", .argv = &argv_flaky, .record = selfDescribing("flaky.py") },
        .{ .file = "stable.py", .argv = &argv_stable, .record = selfDescribing("stable.py") },
    };
    const r = try run(a, .{ .settings = .{ .seed = 1, .repeat = 2, .timeout_ms = 20000 }, .tours = &specs }, null);
    try testing.expect(r.tours[0].flaky);
    try testing.expect(!r.tours[1].flaky);
    try testing.expectEqual(@as(i64, 1), L.exitCode(r.settings, r.tours));
}
