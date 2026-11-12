//! testoor -- the native Testoor runner (roadmap P3.5). No Ring virtual machine: a program that is
//! not Ring (the `stz` command line, a Haro program, a continuous-integration step) calls it as a
//! CHILD, hands it a manifest of tours, and reads the logbook and the exit code.
//!
//!   testoor run MANIFEST.json [--json | --prose] [--seed N] [--repeat N] [--timeout MS] [--ladder]
//!   testoor walk FOLDER [--suffix S] [--haro PATH] [the same options]
//!   testoor version
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
    say("usage: testoor run MANIFEST.json [--json | --prose] [--seed N] [--repeat N] [--timeout MS] [--ladder]\n       testoor walk FOLDER [--suffix S] [--haro PATH] [--json | --prose] [--seed N] [--repeat N] [--timeout MS] [--ladder]\n       testoor version\n");
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
    if (args.len < 3 or (!eq(args[1], "run") and !eq(args[1], "walk"))) usage();
    const walking = eq(args[1], "walk");
    var suffix: []const u8 = "_narrated.haro";
    var haro: []const u8 = std.process.getEnvVarOwned(a, "HARO_EXE") catch "haro";

    var mode: Mode = .auto;
    var seed: ?f64 = null;
    var repeat: ?f64 = null;
    var timeout: ?f64 = null;
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
        } else if ((eq(args[i], "--seed") or eq(args[i], "--repeat") or eq(args[i], "--timeout")) and i + 1 < args.len) {
            const v = T.parseNumber(args[i + 1]) orelse refuse(a, mode, "a number is wanted after the flag");
            if (eq(args[i], "--seed")) seed = v else if (eq(args[i], "--repeat")) repeat = v else timeout = v;
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
        // a guard's FIRST run on haro.exe after the library changes compiles its image of the library: measured 5 to 11
        // minutes a guard on 2026-11-12 (49.5 MB each), then seconds. A two-minute deadline would call every first run hung
        m = .{ .settings = .{ .root = args[2], .timeout_ms = 1_200_000 }, .tours = specs };
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
