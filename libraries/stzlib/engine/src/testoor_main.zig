//! testoor -- the native Testoor runner (roadmap P3.5). No Ring virtual machine: a program that is
//! not Ring (the `stz` command line, a Haro program, a continuous-integration step) calls it as a
//! CHILD, hands it a manifest of tours, and reads the logbook and the exit code.
//!
//!   testoor run MANIFEST.json [--json | --prose] [--seed N] [--repeat N] [--timeout MS] [--start MS] [--ladder]
//!   testoor walk FOLDER [--suffix S] [--haro PATH] [the same options]
//!   testoor graph FILE.haro [--haro PATH] [--out FILE.json]     or     testoor graph --lines LINES.txt [--root DIR] [--out FILE.json]
//!   testoor impact GRAPH.json --changed ID [--changed ID ...] [--tours FOLDER [--suffix S]] [--protocol 2]
//!   testoor probe FOLDER [--haro PATH] [--out FILE.json]
//!   testoor version
//!
//! `probe` puts a call in each function and method of the `.haro` files under FOLDER, where they stand, so a walk of the
//! codebase's tours says which each reached (testoor_probe.zig, TESTOOR_PROTOCOL_3.md 6.8); it refuses a folder in a git
//! work tree, since it is meant for a copy. It checks its work with haro graph, and writes the graph record of what it
//! probed to `--out` or the standard output, for `--graph`.
//!
//! `--graph GRAPH.json` (run, walk) judges the run against a graph record: a node line names one of its nodes, a node a tour
//! calls by name and never reached is `named`, and the ladder counts the graph's nodes no tour reached.
//!
//! `impact` writes the impact record (TESTOOR_PROTOCOL_3.md 5.1, protocol 3 unless `--protocol 2`) of a change to the
//! nodes named, over a graph record `graph` wrote: the reach, the open nodes that widen it and the nodes they cap, and
//! which tours under FOLDER a change obliges you to walk again -- a tour is selected when its source calls a name of the
//! reach (the Haro face's names, testoor_reader.zig), and every tour is when the graph is not complete. One line of
//! figures goes to the standard error, the reach the compiler bound apart from the reach the open nodes widen.
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
const A = @import("testoor_api.zig");
const Rd = @import("testoor_reader.zig");
const G = @import("testoor_graph.zig");
const P = @import("testoor_probe.zig");

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
    say("usage: testoor run MANIFEST.json [--json | --prose] [--seed N] [--repeat N] [--timeout MS] [--start MS] [--ladder] [--graph GRAPH.json]\n       testoor walk FOLDER [--suffix S] [--haro PATH] [--json | --prose] [--seed N] [--repeat N] [--timeout MS] [--start MS] [--ladder] [--graph GRAPH.json]\n       testoor graph FILE.haro [--haro PATH] [--out FILE.json] | --lines LINES.txt [--out FILE.json]\n       testoor impact GRAPH.json --changed ID [--changed ID ...] [--tours FOLDER [--suffix S]] [--protocol 2]\n       testoor probe FOLDER [--haro PATH] [--out FILE.json]\n       testoor version\n");
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

/// haro graph's first block for one file, run from the file's folder
fn graphBlock(a: std.mem.Allocator, haro: []const u8, path: []const u8) !P.Block {
    const argv = [_][]const u8{ haro, "graph", std.fs.path.basename(path) };
    const r = std.process.Child.run(.{
        .allocator = a,
        .argv = &argv,
        .cwd = std.fs.path.dirname(path) orelse ".",
        .max_output_bytes = 1 << 30,
    }) catch |e| fail(try std.fmt.allocPrint(a, "testoor probe: cannot run {s}: {s}" ++ "\n", .{ haro, @errorName(e) }));
    if (std.mem.indexOf(u8, r.stdout, "FILE|") == null) {
        fail(try std.fmt.allocPrint(a, "testoor probe: haro graph printed no unit for {s}" ++ "\n" ++ "{s}", .{ path, r.stderr }));
    }
    return P.firstBlock(a, r.stdout);
}

/// `testoor probe`: a call in each function and method of a COPY of a Haro codebase, so a walk says which a tour reached
/// (testoor_probe.zig), and the graph record of what it probed, for `run` and `walk` to judge against (`--graph`)
fn probe(a: std.mem.Allocator, args: []const []const u8) !void {
    var haro: []const u8 = std.process.getEnvVarOwned(a, "HARO_EXE") catch "haro";
    var folder: []const u8 = "";
    var out: []const u8 = "";
    var i: usize = 2;
    while (i < args.len) : (i += 1) {
        if (eq(args[i], "--haro") and i + 1 < args.len) {
            haro = args[i + 1];
            i += 1;
        } else if (eq(args[i], "--out") and i + 1 < args.len) {
            out = args[i + 1];
            i += 1;
        } else if (folder.len == 0 and !std.mem.startsWith(u8, args[i], "--")) {
            folder = args[i];
        } else {
            usage();
        }
    }
    if (folder.len == 0) usage();
    // a copy, never a repository: the files are rewritten where they stand
    const real = std.fs.cwd().realpathAlloc(a, folder) catch fail(try std.fmt.allocPrint(a, "testoor probe: no such folder: {s}" ++ "\n", .{folder}));
    var up: ?[]const u8 = real;
    while (up) |d| : (up = std.fs.path.dirname(d)) {
        const g = try std.fs.path.join(a, &.{ d, ".git" });
        if (std.fs.cwd().access(g, .{})) |_| {
            fail(try std.fmt.allocPrint(a, "testoor probe: {s} is in a git work tree ({s}); probe a copy -- the files are rewritten where they stand" ++ "\n", .{ folder, d }));
        } else |_| {}
    }
    const pf = try std.fs.path.join(a, &.{ folder, P.probe_file });
    if (std.fs.cwd().access(pf, .{})) |_| {
        fail(try std.fmt.allocPrint(a, "testoor probe: {s} is probed already ({s}); probe a fresh copy" ++ "\n", .{ folder, pf }));
    } else |_| {}
    const files = R.discover(a, folder, ".haro") catch |e|
        fail(try std.fmt.allocPrint(a, "testoor probe: cannot read {s}: {s}" ++ "\n", .{ folder, @errorName(e) }));
    if (files.len == 0) fail(try std.fmt.allocPrint(a, "testoor probe: no .haro file under {s}" ++ "\n", .{folder}));

    var ids: std.ArrayList([]const u8) = .empty;
    var lines = T.Buf.init(a);
    var notes = T.Buf.init(a);
    var n_skipped: usize = 0;
    var crlf = false;
    const Done = struct { path: []const u8, rel: []const u8, before: P.Block, ids: []const []const u8 };
    var done: std.ArrayList(Done) = .empty;
    for (files) |rel| {
        const path = try std.fs.path.join(a, &.{ folder, rel });
        const blk = try graphBlock(a, haro, path);
        try lines.s("FILE|");
        try lines.s(rel);
        try lines.s("\n");
        for (blk.lines) |l| {
            try lines.s(l);
            try lines.s("\n");
        }
        if (blk.defs.len == 0) continue;
        const src = std.fs.cwd().readFileAlloc(a, path, 256 * 1024 * 1024) catch |e|
            fail(try std.fmt.allocPrint(a, "testoor probe: cannot read {s}: {s}" ++ "\n", .{ path, @errorName(e) }));
        if (std.mem.indexOf(u8, src, "\r\n") != null) crlf = true;
        const r = try P.instrument(a, src, blk.defs, blk.starts, ids.items.len + 1, try P.relPath(a, std.fs.path.dirname(rel) orelse "", P.probe_file));
        for (r.skipped) |s| {
            if (n_skipped < 5) try notes.s(try std.fmt.allocPrint(a, "; {s} ({s}, line {d}) {s}", .{ s.id, rel, s.line, s.why }));
            n_skipped += 1;
        }
        if (r.ids.len == 0) continue;
        std.fs.cwd().writeFile(.{ .sub_path = path, .data = r.text }) catch |e|
            fail(try std.fmt.allocPrint(a, "testoor probe: cannot write {s}: {s}" ++ "\n", .{ path, @errorName(e) }));
        try ids.appendSlice(a, r.ids);
        try done.append(a, .{ .path = path, .rel = rel, .before = blk, .ids = r.ids });
    }
    std.fs.cwd().writeFile(.{ .sub_path = pf, .data = try P.probeSource(a, ids.items, crlf) }) catch |e|
        fail(try std.fmt.allocPrint(a, "testoor probe: cannot write {s}: {s}" ++ "\n", .{ pf, @errorName(e) }));

    // the check: haro graph names the same definitions on the same lines in each probed file, finishes what it finished,
    // and each probed definition calls the probe
    var wrong = T.Buf.init(a);
    for (done.items) |d| {
        const after = try graphBlock(a, haro, d.path);
        var same = after.defs.len == d.before.defs.len and after.unfinished.len == d.before.unfinished.len;
        if (same) for (after.defs, d.before.defs) |x, y| {
            if (!std.ascii.eqlIgnoreCase(x.id, y.id) or x.line != y.line) same = false;
        };
        if (!same) {
            try wrong.s(try std.fmt.allocPrint(a, "  {s}: haro graph reads other definitions, or finishes fewer, once it is probed" ++ "\n", .{d.rel}));
            continue;
        }
        for (d.ids) |id| {
            var calls = false;
            for (after.lines) |l| {
                var it = std.mem.splitScalar(u8, l, '|');
                const tag = it.next() orelse "";
                const from = it.next() orelse "";
                const to = it.next() orelse "";
                if (eq(tag, "CALL") and std.ascii.eqlIgnoreCase(from, id) and std.ascii.eqlIgnoreCase(to, P.hit_name)) calls = true;
            }
            if (!calls) try wrong.s(try std.fmt.allocPrint(a, "  {s}: {s} does not call the probe once it is probed" ++ "\n", .{ d.rel, id }));
        }
    }
    if (wrong.list.items.len > 0) fail(try std.fmt.allocPrint(a, "testoor probe: the check failed, and the copy under {s} is probed as it stands:" ++ "\n" ++ "{s}", .{ folder, wrong.list.items }));

    const record = try Hg.fromLinesWith(a, lines.list.items, folder, .{ .subject = try Hg.normPath(a, folder), .tops = false });
    if (out.len > 0) {
        std.fs.cwd().writeFile(.{ .sub_path = out, .data = record }) catch |e|
            fail(try std.fmt.allocPrint(a, "testoor probe: cannot write {s}: {s}" ++ "\n", .{ out, @errorName(e) }));
    } else {
        say(record);
    }
    const doc = try J.parse(a, record);
    const nn = (doc.get("nodes") orelse unreachable).items().len;
    const why = (doc.get("why") orelse unreachable).str_();
    var line = try std.fmt.allocPrint(a, "testoor probe: {d} file(s), {d} function(s) and method(s) probed", .{ files.len, ids.items.len });
    if (n_skipped > 0) line = try std.fmt.allocPrint(a, "{s}, {d} not{s}{s}", .{ line, n_skipped, notes.list.items, if (n_skipped > 5) "; ..." else "" });
    line = try std.fmt.allocPrint(a, "{s}; the record holds {d} node(s), {s}{s}", .{ line, nn, if (why.len == 0) "complete" else "not complete: ", why });
    std.fs.File.stderr().writeAll(try std.fmt.allocPrint(a, "{s}" ++ "\n", .{line})) catch {};
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

/// `testoor impact`: the impact record of a change, over a Haro unit's graph record, with the tours it selects
fn impact(a: std.mem.Allocator, args: []const []const u8) !void {
    const graph_file = args[2];
    var changed: std.ArrayList([]const u8) = .empty;
    var tours_dir: []const u8 = "";
    var suffix: []const u8 = "_narrated.haro";
    var protocol: []const u8 = "3";
    var i: usize = 3;
    while (i < args.len) : (i += 1) {
        if (eq(args[i], "--changed") and i + 1 < args.len) {
            try changed.append(a, args[i + 1]);
            i += 1;
        } else if (eq(args[i], "--tours") and i + 1 < args.len) {
            tours_dir = args[i + 1];
            i += 1;
        } else if (eq(args[i], "--suffix") and i + 1 < args.len) {
            suffix = args[i + 1];
            i += 1;
        } else if (eq(args[i], "--protocol") and i + 1 < args.len) {
            protocol = args[i + 1];
            i += 1;
        } else usage();
    }
    if (changed.items.len == 0) usage();
    const graph_text = std.fs.cwd().readFileAlloc(a, graph_file, 1 << 30) catch |e|
        fail(try std.fmt.allocPrint(a, "testoor impact: cannot read {s}: {s}" ++ "\n", .{ graph_file, @errorName(e) }));
    var b = T.Buf.init(a);
    try b.s("{\"protocol\":");
    try b.s(if (eq(protocol, "2")) "2" else "3");
    try b.s(",\"graph\":");
    try b.s(graph_text);
    try b.s(",\"changed\":[");
    for (changed.items, 0..) |c, k| {
        if (k > 0) try b.c(',');
        try b.js(c);
    }
    try b.s("],\"tours\":[");
    var n_tours: usize = 0;
    if (tours_dir.len > 0) {
        const found = R.discover(a, tours_dir, suffix) catch |e|
            fail(try std.fmt.allocPrint(a, "testoor impact: no such folder: {s} ({s})" ++ "\n", .{ tours_dir, @errorName(e) }));
        for (found) |rel| {
            const path = try std.fs.path.join(a, &.{ tours_dir, rel });
            const src = std.fs.cwd().readFileAlloc(a, path, 64 * 1024 * 1024) catch continue;
            if (n_tours > 0) try b.c(',');
            n_tours += 1;
            try b.s("{\"file\":");
            try b.js(rel);
            try b.s(",\"names\":[");
            for (try Rd.namesOf(a, src), 0..) |nm, k| {
                if (k > 0) try b.c(',');
                try b.js(nm);
            }
            try b.s("]}");
        }
    }
    try b.s("]}");
    const record = A.impactJson(a, try b.done()) catch |e|
        fail(try std.fmt.allocPrint(a, "testoor impact: {s} is not a graph record ({s})" ++ "\n", .{ graph_file, @errorName(e) }));
    say(record);
    say("\n");
    // the figures: the reach the compiler bound, then what the open nodes widen it to
    const doc = try J.parse(a, record);
    const sel = (doc.get("selected") orelse unreachable).items().len;
    var line = try std.fmt.allocPrint(a, "testoor impact: selected {d} of {d} tours", .{ sel, n_tours });
    if (doc.get("reach")) |rv| {
        const reach = rv.items();
        const widened = (doc.get("widened") orelse unreachable).items();
        var bound = reach.len;
        if (widened.len > 0) {
            for (reach, 0..) |r, k| {
                if (std.mem.eql(u8, r.str_(), widened[0].str_())) {
                    bound = k;
                    break;
                }
            }
        }
        line = try std.fmt.allocPrint(a, "{s}; the change reaches {d} node(s) by calls the compiler bound, and {d} once {d} open node(s) and their callers widen it; {d} capped", .{
            line, bound, reach.len, widened.len, (doc.get("capped") orelse unreachable).items().len,
        });
    }
    const why = (doc.get("why") orelse unreachable).str_();
    if (why.len > 0) line = try std.fmt.allocPrint(a, "{s}; the graph is not complete, so every tour is selected: {s}", .{ line, why });
    std.fs.File.stderr().writeAll(try std.fmt.allocPrint(a, "{s}" ++ "\n", .{line})) catch {};
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
    if (args.len >= 3 and eq(args[1], "impact")) return impact(a, args);
    if (args.len >= 3 and eq(args[1], "probe")) return probe(a, args);
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
    var graph_file: []const u8 = "";
    var i: usize = 3;
    while (i < args.len) : (i += 1) {
        if (eq(args[i], "--ladder")) {
            ladder = true;
        } else if (eq(args[i], "--graph") and i + 1 < args.len) {
            graph_file = args[i + 1];
            i += 1;
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
    if (graph_file.len > 0) {
        const gt = std.fs.cwd().readFileAlloc(a, graph_file, 1 << 30) catch |e|
            refuse(a, mode, try std.fmt.allocPrint(a, "cannot read the graph {s}: {s}", .{ graph_file, @errorName(e) }));
        const gd = J.parse(a, gt) catch refuse(a, mode, "the graph is not a JSON document");
        const g = G.fromValue(a, gd) catch refuse(a, mode, "the graph is not a graph record");
        m.graph = g;
        m.settings.graph = .{ .complete = g.complete, .why = g.why, .owned = @intCast(g.nodes.len) };
    }
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
