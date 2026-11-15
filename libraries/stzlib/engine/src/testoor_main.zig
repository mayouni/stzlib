//! testoor -- the native Testoor runner (roadmap P3.5). No Ring virtual machine: a program that is
//! not Ring (the `stz` command line, a Haro program, a continuous-integration step) calls it as a
//! CHILD, hands it a manifest of tours, and reads the logbook and the exit code.
//!
//!   testoor run MANIFEST.json [--json | --prose] [--seed N] [--repeat N] [--timeout MS] [--start MS] [--ladder]
//!   testoor walk FOLDER [--suffix S] [--haro PATH] [the same options]
//!   testoor graph FILE.haro [--haro PATH] [--out FILE.json]     or     testoor graph --lines LINES.txt [--root DIR] [--out FILE.json]
//!   testoor version
//!
//! `graph` writes the graph record of a Haro unit (testoor_harograph.zig): it runs `haro graph FILE` from the file's folder
//! and reads its lines, or reads lines `haro graph` wrote earlier (`--root` names the folder it ran in, where the unit's files are
//! read for calls by a name built at run time; without it they are not read, and the record says so). The record goes to `--out` or the standard output, and one
//! line of figures to the standard error. Exit 0, or 2 when haro.exe cannot be run or the file cannot be read.
//!
//! `--timeout` is the tour's deadline, counted from its first output; `--start` is the deadline for that first output,
//! counted from the tour's start (0, the default of `run`, is the tour's deadline). `walk` defaults to 20 minutes to
//! start and 10 to run: the start of a .haro tour is haro.exe compiling its image of the library.
//!
//! `walk` finds the `.haro` tours under FOLDER itself (names ending with `_narrated.haro` unless `--suffix` says
//! otherwise; a name beginning with `_` or `.` is never walked), reads each with the Haro face and launches it on
//! haro.exe: `--haro`, else the HARO_EXE variable, else `haro` on the path. No manifest and no other language.
//!
//! `--ladder` writes the evidence ladder (TESTOOR_PROTOCOL_3.md section 2): each node's highest grade.
//!
//! MANIFEST is a file, or `-` for standard input; its shape is in testoor_runner.zig. The logbook is
//! JSON when standard output is a pipe and prose when it is a terminal, unless `--json` or `--prose`
//! says which -- the convention of the Ring runner. Prose streams: each tour's line is written as the
//! tour is judged, and the summary last.
//!
//! The exit code is the RUNNER'S, as the Ring runner's is: 0 when every stop is kept or unperceived,
//! 1 when a stop diverged, a tour did not start, broke, hung, could not be read or is flaky, and 2
//! when the runner itself refused (no manifest, a manifest that is not JSON, a refusal it carries).

const std = @import("std");
const builtin = @import("builtin");
const T = @import("testoor_text.zig");
const J = @import("testoor_json.zig");
const L = @import("testoor_logbook.zig");
const V = @import("testoor_verdict.zig");
const R = @import("testoor_runner.zig");
const W = @import("testoor_walk.zig");
const Hg = @import("testoor_harograph.zig");

const version_line = "testoor 3.5 (protocol 2; the Zig core)";

const Mode = enum { auto, json, prose };

var g_a: std.mem.Allocator = undefined;
var g_out: std.fs.File = undefined;

fn eq(x: []const u8, y: []const u8) bool {
    return std.mem.eql(u8, x, y);
}

fn say(s: []const u8) void {
    g_out.writeAll(s) catch {};
}

fn usage() noreturn {
    say("usage: testoor run MANIFEST.json [--json | --prose] [--seed N] [--repeat N] [--timeout MS] [--start MS] [--ladder]\n       testoor walk FOLDER [--suffix S] [--haro PATH] [--json | --prose] [--seed N] [--repeat N] [--timeout MS] [--start MS] [--ladder]\n       testoor graph FILE.haro [--haro PATH] [--out FILE.json] | --lines LINES.txt [--out FILE.json]\n       testoor version\n");
    std.process.exit(2);
}

/// a tour's line, as soon as the tour is judged
fn streamTour(t: V.Tour) void {
    var b = T.Buf.init(g_a);
    L.tourProse(&b, t) catch return;
    b.c('\n') catch return;
    say(b.done() catch return);
}

fn emit(a: std.mem.Allocator, as_json: bool, streamed: bool, st: L.Settings, tours: []const V.Tour) !void {
    var b = T.Buf.init(a);
    if (as_json) {
        try L.runJson(&b, st, tours);
    } else if (streamed) {
        try L.summary(&b, st, tours);
    } else {
        try L.runProse(&b, st, tours);
    }
    try b.c('\n');
    say(try b.done());
}

fn refuse(a: std.mem.Allocator, mode: Mode, why: []const u8) noreturn {
    const as_json = switch (mode) {
        .json => true,
        .prose => false,
        .auto => !g_out.isTty(),
    };
    const st = L.Settings{ .by = "testoor", .refusal = why };
    emit(a, as_json, false, st, &.{}) catch {};
    std.process.exit(2);
}

fn fail(why: []const u8) noreturn {
    std.fs.File.stderr().writeAll(why) catch {};
    std.process.exit(2);
}

/// `testoor graph`: a Haro unit's graph record, from haro.exe or from lines it printed earlier
fn graph(a: std.mem.Allocator, args: []const []const u8) !void {
    var haro: []const u8 = std.process.getEnvVarOwned(a, "HARO_EXE") catch "haro";
    var file: []const u8 = "";
    var lines_file: []const u8 = "";
    var root: ?[]const u8 = null;
    var out: []const u8 = "";
    var i: usize = 2;
    while (i < args.len) : (i += 1) {
        if (eq(args[i], "--haro") and i + 1 < args.len) {
            haro = args[i + 1];
            i += 1;
        } else if (eq(args[i], "--out") and i + 1 < args.len) {
            out = args[i + 1];
            i += 1;
        } else if (eq(args[i], "--lines") and i + 1 < args.len) {
            lines_file = args[i + 1];
            i += 1;
        } else if (eq(args[i], "--root") and i + 1 < args.len) {
            root = args[i + 1];
            i += 1;
        } else if (file.len == 0 and !std.mem.startsWith(u8, args[i], "--")) {
            file = args[i];
        } else {
            usage();
        }
    }
    var text: []const u8 = undefined;
    if (lines_file.len > 0) {
        text = std.fs.cwd().readFileAlloc(a, lines_file, 1 << 30) catch |e|
            fail(try std.fmt.allocPrint(a, "testoor graph: cannot read {s}: {s}" ++ "\n", .{ lines_file, @errorName(e) }));
    } else {
        if (file.len == 0) usage();
        std.fs.cwd().access(file, .{}) catch fail(try std.fmt.allocPrint(a, "testoor graph: no such file: {s}" ++ "\n", .{file}));
        const argv = [_][]const u8{ haro, "graph", std.fs.path.basename(file) };
        const r = std.process.Child.run(.{
            .allocator = a,
            .argv = &argv,
            .cwd = std.fs.path.dirname(file) orelse ".",
            .max_output_bytes = 1 << 30,
        }) catch |e| fail(try std.fmt.allocPrint(a, "testoor graph: cannot run {s}: {s}" ++ "\n", .{ haro, @errorName(e) }));
        text = r.stdout;
        root = std.fs.path.dirname(file) orelse ".";
        if (std.mem.indexOf(u8, text, "FILE|") == null) {
            fail(try std.fmt.allocPrint(a, "testoor graph: haro graph printed no unit for {s}" ++ "\n" ++ "{s}", .{ file, r.stderr }));
        }
    }
    const record = try Hg.fromLines(a, text, root);
    if (out.len > 0) {
        std.fs.cwd().writeFile(.{ .sub_path = out, .data = record }) catch |e|
            fail(try std.fmt.allocPrint(a, "testoor graph: cannot write {s}: {s}" ++ "\n", .{ out, @errorName(e) }));
    } else {
        say(record);
    }
    const doc = try J.parse(a, record);
    const nn = (doc.get("nodes") orelse unreachable).items().len;
    const ne = (doc.get("edges") orelse unreachable).items().len;
    const why = (doc.get("why") orelse unreachable).str_();
    std.fs.File.stderr().writeAll(try std.fmt.allocPrint(a, "testoor graph: {d} nodes, {d} edges, {s}{s}" ++ "\n", .{
        nn, ne, if (why.len == 0) "complete" else "not complete: ", why,
    })) catch {};
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const a = arena.allocator();
    g_a = a;
    g_out = std.fs.File.stdout();
    const args = try std.process.argsAlloc(a);
    if (args.len >= 2 and (eq(args[1], "version") or eq(args[1], "--version"))) {
        say(version_line ++ "\n");
        return;
    }
    if (args.len >= 3 and eq(args[1], "graph")) return graph(a, args);
    if (args.len < 3 or (!eq(args[1], "run") and !eq(args[1], "walk"))) usage();
    const walking = eq(args[1], "walk");
    var suffix: []const u8 = "_narrated.haro";
    var haro: []const u8 = std.process.getEnvVarOwned(a, "HARO_EXE") catch "haro";

    var mode: Mode = .auto;
    var seed: ?f64 = null;
    var repeat: ?f64 = null;
    var timeout: ?f64 = null;
    var start: ?f64 = null;
    var ladder = false;
    var i: usize = 3;
    while (i < args.len) : (i += 1) {
        if (eq(args[i], "--ladder")) {
            ladder = true;
        } else if (walking and eq(args[i], "--suffix") and i + 1 < args.len) {
            suffix = args[i + 1];
            i += 1;
        } else if (walking and eq(args[i], "--haro") and i + 1 < args.len) {
            haro = args[i + 1];
            i += 1;
        } else if (eq(args[i], "--json")) {
            mode = .json;
        } else if (eq(args[i], "--prose")) {
            mode = .prose;
        } else if ((eq(args[i], "--seed") or eq(args[i], "--repeat") or eq(args[i], "--timeout") or eq(args[i], "--start")) and i + 1 < args.len) {
            const v = T.parseNumber(args[i + 1]) orelse refuse(a, mode, "a number is wanted after the flag");
            if (eq(args[i], "--seed")) seed = v else if (eq(args[i], "--repeat")) repeat = v else if (eq(args[i], "--start")) start = v else timeout = v;
            i += 1;
        } else {
            usage();
        }
    }

    var m: R.Manifest = undefined;
    if (walking) {
        // P3.6: the tours under a folder, read by the Haro face -- no manifest, no other language
        const found = R.discover(a, args[2], suffix) catch |e|
            refuse(a, mode, try std.fmt.allocPrint(a, "no such root: {s} ({s})", .{ args[2], @errorName(e) }));
        var specs = try a.alloc(R.TourSpec, found.len);
        for (found, 0..) |rel, k| specs[k] = try R.haroTour(a, args[2], rel, haro);
        // a guard's FIRST run on haro.exe after the library changes compiles its image of the library before it prints:
        // measured 5 to 11 minutes a guard on 2026-11-12 (49.5 MB each), 20 s to 182 s on 2026-11-13, then seconds. So
        // 20 minutes to start, and 10 to run once it has printed (TESTOOR-COLD-DEADLINE-01)
        m = .{ .settings = .{ .root = args[2], .timeout_ms = 600_000, .start_ms = 1_200_000 }, .tours = specs };
    } else {
        const text = (if (eq(args[2], "-"))
            std.fs.File.stdin().readToEndAlloc(a, 256 * 1024 * 1024)
        else
            std.fs.cwd().readFileAlloc(a, args[2], 256 * 1024 * 1024)) catch |e|
            refuse(a, mode, try std.fmt.allocPrint(a, "cannot read the manifest {s}: {s}", .{ args[2], @errorName(e) }));
        const doc = J.parse(a, text) catch refuse(a, mode, "the manifest is not a JSON document");
        m = R.fromValue(a, doc) catch refuse(a, mode, "the manifest is missing a field the runner reads");
    }
    if (seed) |v| m.settings.seed = v;
    if (repeat) |v| m.settings.repeat = v;
    if (timeout) |v| m.settings.timeout_ms = v;
    if (start) |v| m.settings.start_ms = v;
    if (ladder) m.settings.ladder = true;
    if (m.settings.by.len == 0 or eq(m.settings.by, "shell")) m.settings.by = "testoor";

    const as_json = switch (mode) {
        .json => true,
        .prose => false,
        .auto => !g_out.isTty(),
    };
    const res = try R.run(a, m, if (as_json) null else streamTour);
    try emit(a, as_json, !as_json and res.settings.refusal.len == 0, res.settings, res.tours);
    const code: u8 = @intCast(L.exitCode(res.settings, res.tours));
    // a reader let go (a descendant escaped the job and holds a pipe) can make a normal exit wait on it
    if (builtin.os.tag == .windows and W.leaked_readers.load(.acquire) > 0) {
        _ = std.os.windows.kernel32.TerminateProcess(std.os.windows.GetCurrentProcess(), code);
    }
    std.process.exit(code);
}
