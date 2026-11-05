//! Testoor core -- the logbook: one tour as JSON and as the line a terminal shows, one run as
//! JSON, prose and an exit code. A port of `_TravRunJson`, `_TravRunProse` and the run half of
//! `stzTraveller` in the Ring reference. Key order is the reference's (`TestoorLogbookKeys()`),
//! strings carry the five escapes the reference writes and no more, and numbers print as Ring
//! prints them (whole values bare, others with two decimals).
//!
//! The exit code is the RUNNER'S, never a tour's: 0 when every stop is kept or unperceived,
//! 1 when a stop diverged, a tour did not start, broke, hung, could not be read or is flaky,
//! 2 when the runner itself refused. Unjudged is reported and is not counted against.
//! `owned` and `run` are two figures and are never summed.

const std = @import("std");
const Allocator = std.mem.Allocator;
const T = @import("testoor_text.zig");
const V = @import("testoor_verdict.zig");

const Buf = T.Buf;

fn eq(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

fn seedJson(b: *Buf, run: V.Run) !void {
    if (run.seed) |s| {
        if (s >= 0) return b.num(s);
    }
    try b.s("null");
}

/// the tour as the logbook writes it
pub fn tourJson(b: *Buf, t: V.Tour) !void {
    return tourJsonDetail(b, t, false);
}

/// `detail` adds, to each stop, the milliseconds it opened and closed at (-1 when it never
/// did): what the Ring runner's record holds beside the logbook's own fields. The logbook
/// itself never carries them, so the golden bytes are the bytes of `detail = false`.
pub fn tourJsonDetail(b: *Buf, t: V.Tour, detail: bool) !void {
    const r = t.run;
    try b.s("{\"file\":");
    try b.js(t.file);
    try b.s(",\"dialect\":");
    try b.js(t.dialect);
    try b.s(",\"state\":");
    try b.js(r.state.name());
    try b.s(",\"end\":");
    try b.js(r.end);
    try b.s(",\"exit\":");
    try b.int(r.exit);
    try b.s(",\"wall_ms\":");
    try b.num(r.wall_ms);
    try b.s(",\"seed\":");
    try seedJson(b, r);
    try b.s(",\"flaky\":");
    try b.s(if (t.flaky) "1" else "0");
    try b.s(",\"weather\":[");
    for (t.weather, 0..) |w, k| {
        if (k > 0) try b.c(',');
        try b.js(w);
    }
    try b.s("],\"kept\":");
    try b.int(r.kept);
    try b.s(",\"diverged\":");
    try b.int(r.diverged);
    try b.s(",\"unreached\":");
    try b.int(r.unreached);
    try b.s(",\"unjudged\":");
    try b.int(r.unjudged);
    try b.s(",\"stops\":[");
    for (r.stops, 0..) |st, k| {
        if (k > 0) try b.c(',');
        try b.s("{\"title\":");
        try b.js(st.title);
        try b.s(",\"line\":");
        try b.int(st.line);
        try b.s(",\"state\":");
        try b.js(st.state.name());
        try b.s(",\"wall_ms\":");
        try b.num(st.wall_ms);
        try b.s(",\"seed\":");
        try seedJson(b, r);
        try b.s(",\"claims\":[");
        for (st.claims.items, 0..) |cl, m| {
            if (m > 0) try b.c(',');
            try b.s("{\"claim\":");
            try b.js(cl.claim);
            try b.s(",\"kind\":");
            try b.js(cl.kind);
            try b.s(",\"line\":");
            try b.int(cl.line);
            try b.s(",\"state\":");
            try b.js(cl.state.name());
            try b.c('}');
        }
        try b.c(']');
        if (detail) {
            try b.s(",\"opened_ms\":");
            try b.int(if (st.opened < 0) -1 else @as(i64, @intFromFloat(@round(st.opened * 1000.0))));
            try b.s(",\"closed_ms\":");
            try b.int(if (st.closed < 0) -1 else @as(i64, @intFromFloat(@round(st.closed * 1000.0))));
        }
        try b.c('}');
    }
    try b.s("],\"routes\":[");
    for (t.routes, 0..) |rt, k| {
        if (k > 0) try b.c(',');
        try b.s("{\"item\":");
        try b.js(rt.item);
        try b.s(",\"stop\":");
        try b.js(rt.stop);
        try b.s(",\"line\":");
        try b.int(rt.line);
        try b.c('}');
    }
    try b.c(']');
    // protocol 2: a key appears only when it has something to say
    if (t.nodes.len > 0) {
        try b.s(",\"nodes\":[");
        for (t.nodes, 0..) |nd, k| {
            if (k > 0) try b.c(',');
            try b.s("{\"id\":");
            try b.js(nd.id);
            try b.s(",\"evidence\":");
            try b.js(nd.evidence);
            try b.s(",\"hits\":");
            try b.int(nd.hits);
            try b.c('}');
        }
        try b.c(']');
    }
    try b.c('}');
}

fn isTrouble(end: []const u8) bool {
    return eq(end, "not-started") or eq(end, "broke") or eq(end, "hung") or eq(end, "unreadable");
}

/// the line a terminal shows for one tour
pub fn tourProse(b: *Buf, t: V.Tour) !void {
    const r = t.run;
    const a = b.a;
    var tag: []const u8 = try T.upperAscii(a, r.state.name());
    if (isTrouble(r.end)) tag = try T.upperAscii(a, r.end);
    try b.s(tag);
    var pad = tag.len;
    while (pad < 11) : (pad += 1) try b.c(' ');
    try b.c(' ');
    try b.s(t.file);
    try b.s("  ");
    try b.int(@intCast(r.stops.len));
    try b.s(" stops: ");
    try b.int(r.kept);
    try b.s(" kept");
    if (r.diverged > 0) {
        try b.s(", ");
        try b.int(r.diverged);
        try b.s(" diverged");
    }
    if (r.unreached > 0) {
        try b.s(", ");
        try b.int(r.unreached);
        try b.s(" unreached");
    }
    if (r.unjudged > 0) {
        try b.s(", ");
        try b.int(r.unjudged);
        try b.s(" unjudged");
    }
    if (t.flaky) try b.s("  FLAKY");
    // the seed is printed when something FAILED -- a diverged or unreached claim, a tour that
    // did not finish, or a flaky one -- because that is the run somebody will want to walk
    // again. An unjudged claim is not a failure.
    const failed = r.diverged > 0 or r.unreached > 0 or t.flaky or (!eq(r.end, "finished") and !eq(r.end, "finished-timed"));
    if (failed) {
        if (r.seed) |s| {
            if (s >= 0) {
                try b.s("  seed ");
                try b.num(s);
            }
        }
    }
    try b.s("  (");
    try b.num(r.wall_ms / 1000.0);
    try b.s(" s");
    if (eq(r.end, "finished-timed")) try b.s(", finished, timed");
    try b.c(')');
    for (r.stops) |st| {
        if (st.state == .kept) continue;
        try b.s("\n    ");
        try b.s(st.state.name());
        try b.s("  ");
        try b.s(st.title);
        try b.s("  (");
        try b.num(st.wall_ms / 1000.0);
        try b.s(" s)");
        for (st.claims.items) |cl| {
            if (cl.state == .kept) continue;
            try b.s("\n        ");
            try b.s(cl.state.name());
            try b.s("  ");
            try b.s(cl.claim);
        }
    }
}

// ── one run ──────────────────────────────────────────────────

pub const Settings = struct {
    by: []const u8 = "shell",
    root: []const u8 = "",
    topic: []const u8 = "",
    subject: []const u8 = "",
    refusal: []const u8 = "",
    seed: f64 = -1,
    repeat: f64 = 1,
    timeout_ms: f64 = 120000,
    skipped: []const []const u8 = &.{},
    topics_skipped: []const []const u8 = &.{},
    /// protocol 2: the graph the run was walked against, when it had one
    graph: ?GraphSettings = null,
};

/// what the runner knows of its graph; `named` and `observed` are counted from the tours
pub const GraphSettings = struct { complete: bool = true, why: []const u8 = "", owned: i64 = 0 };

pub const Figures = struct { named: i64 = 0, observed: i64 = 0 };

/// Distinct nodes by their strongest evidence across the tours: a node is counted once, as
/// observed if any tour observed it and as named otherwise. Never summed, never a percentage.
pub fn graphFigures(a: Allocator, tours: []const V.Tour) !Figures {
    var m: std.StringHashMapUnmanaged(bool) = .empty;
    for (tours) |t| {
        for (t.nodes) |n| {
            const obs = eq(n.evidence, "observed");
            const gop = try m.getOrPut(a, n.id);
            if (!gop.found_existing) {
                gop.value_ptr.* = obs;
            } else if (obs) {
                gop.value_ptr.* = true;
            }
        }
    }
    var f = Figures{};
    var it = m.valueIterator();
    while (it.next()) |v| {
        if (v.*) f.observed += 1 else f.named += 1;
    }
    return f;
}

fn isProtocol2(st: Settings, tours: []const V.Tour) bool {
    if (st.graph != null) return true;
    for (tours) |t| if (t.nodes.len > 0) return true;
    return false;
}

pub const Counts = struct {
    kept: i64 = 0,
    diverged: i64 = 0,
    unreached: i64 = 0,
    unjudged: i64 = 0,
    finished: i64 = 0,
    finished_timed: i64 = 0,
    not_started: i64 = 0,
    broke: i64 = 0,
    hung: i64 = 0,
    unreadable: i64 = 0,
    flaky: i64 = 0,
    owned: i64 = 0,
    run: i64 = 0,
    wall_ms: f64 = 0,
};

/// owned is every tour in scope, run is every tour whose child was started
pub fn counts(tours: []const V.Tour) Counts {
    var c = Counts{};
    for (tours) |t| {
        const r = t.run;
        c.owned += 1;
        if (!eq(r.end, "unreadable")) c.run += 1;
        c.wall_ms += r.wall_ms;
        if (t.flaky) c.flaky += 1;
        c.kept += r.kept;
        c.diverged += r.diverged;
        c.unreached += r.unreached;
        c.unjudged += r.unjudged;
        if (eq(r.end, "finished")) c.finished += 1;
        if (eq(r.end, "finished-timed")) c.finished_timed += 1;
        if (eq(r.end, "not-started")) c.not_started += 1;
        if (eq(r.end, "broke")) c.broke += 1;
        if (eq(r.end, "hung")) c.hung += 1;
        if (eq(r.end, "unreadable")) c.unreadable += 1;
    }
    return c;
}

/// THE RUNNER'S exit code
pub fn exitCode(st: Settings, tours: []const V.Tour) i64 {
    if (st.refusal.len != 0) return 2;
    for (tours) |t| {
        if (t.flaky) return 1;
        if (t.run.diverged > 0) return 1;
        if (isTrouble(t.run.end)) return 1;
    }
    return 0;
}

fn strList(b: *Buf, items: []const []const u8) !void {
    for (items, 0..) |s, k| {
        if (k > 0) try b.c(',');
        try b.js(s);
    }
}

pub fn runJson(b: *Buf, st: Settings, tours: []const V.Tour) !void {
    const c = counts(tours);
    try b.s("{\"testoor\":\"logbook\",\"kind\":\"run\"");
    if (isProtocol2(st, tours)) try b.s(",\"protocol\":2");
    try b.s(",\"by\":");
    try b.js(st.by);
    try b.s(",\"root\":");
    try b.js(st.root);
    try b.s(",\"topic\":");
    try b.js(st.topic);
    try b.s(",\"subject\":");
    try b.js(st.subject);
    try b.s(",\"refusal\":");
    try b.js(st.refusal);
    try b.s(",\"exit\":");
    try b.int(exitCode(st, tours));
    try b.s(",\"owned\":");
    try b.int(c.owned);
    try b.s(",\"run\":");
    try b.int(c.run);
    try b.s(",\"wall_ms\":");
    try b.num(c.wall_ms);
    try b.s(",\"timeout_ms\":");
    try b.num(st.timeout_ms);
    try b.s(",\"seed\":");
    try b.num(st.seed);
    try b.s(",\"repeat\":");
    try b.num(st.repeat);
    try b.s(",\"flaky\":");
    try b.int(c.flaky);
    try b.s(",\"claims\":{\"kept\":");
    try b.int(c.kept);
    try b.s(",\"diverged\":");
    try b.int(c.diverged);
    try b.s(",\"unreached\":");
    try b.int(c.unreached);
    try b.s(",\"unjudged\":");
    try b.int(c.unjudged);
    try b.c('}');
    if (st.graph) |g| {
        const f = try graphFigures(b.a, tours);
        try b.s(",\"graph\":{\"complete\":");
        try b.s(if (g.complete) "true" else "false");
        if (!g.complete) {
            try b.s(",\"why\":");
            try b.js(g.why);
        }
        try b.s(",\"owned\":");
        try b.int(g.owned);
        try b.s(",\"named\":");
        try b.int(f.named);
        try b.s(",\"observed\":");
        try b.int(f.observed);
        try b.c('}');
    }
    try b.s(",\"tours_by_end\":{\"finished\":");
    try b.int(c.finished);
    try b.s(",\"finished-timed\":");
    try b.int(c.finished_timed);
    try b.s(",\"not-started\":");
    try b.int(c.not_started);
    try b.s(",\"broke\":");
    try b.int(c.broke);
    try b.s(",\"hung\":");
    try b.int(c.hung);
    try b.s(",\"unreadable\":");
    try b.int(c.unreadable);
    try b.s("},\"skipped\":[");
    try strList(b, st.skipped);
    try b.s("],\"topics_skipped\":[");
    try strList(b, st.topics_skipped);
    try b.s("],\"tours\":[");
    for (tours, 0..) |t, k| {
        if (k > 0) try b.c(',');
        try tourJson(b, t);
    }
    try b.s("]}");
}

pub fn summary(b: *Buf, st: Settings, tours: []const V.Tour) !void {
    if (st.refusal.len != 0) {
        try b.s("REFUSED: ");
        try b.s(st.refusal);
        try b.s("\nexit 2");
        return;
    }
    const c = counts(tours);
    try b.s("owned ");
    try b.int(c.owned);
    try b.s(" tours, run ");
    try b.int(c.run);
    try b.s(" (two figures, never summed)\n  claims: ");
    try b.int(c.kept);
    try b.s(" kept, ");
    try b.int(c.diverged);
    try b.s(" diverged, ");
    try b.int(c.unreached);
    try b.s(" unreached, ");
    try b.int(c.unjudged);
    try b.s(" unjudged");
    if (st.graph) |g| {
        const f = try graphFigures(b.a, tours);
        try b.s("\n  graph: ");
        try b.int(g.owned);
        try b.s(" owned, ");
        try b.int(f.named);
        try b.s(" named, ");
        try b.int(f.observed);
        try b.s(" observed (three figures, never summed)");
        if (!g.complete) {
            try b.s("\n  graph incomplete: ");
            try b.s(g.why);
            try b.s("; a selection from it takes every tour");
        }
    }
    try b.s("\n  tours: ");
    try b.int(c.finished);
    try b.s(" finished, ");
    try b.int(c.finished_timed);
    try b.s(" finished-timed, ");
    try b.int(c.not_started);
    try b.s(" not-started, ");
    try b.int(c.broke);
    try b.s(" broke, ");
    try b.int(c.hung);
    try b.s(" hung, ");
    try b.int(c.unreadable);
    try b.s(" unreadable\n  wall: ");
    try b.num(c.wall_ms / 1000.0);
    try b.s(" s, by ");
    try b.s(st.by);
    try b.s("\n  skipped by name: ");
    try b.int(@intCast(st.skipped.len));
    for (st.skipped) |s| {
        try b.s("\n    ");
        try b.s(s);
    }
    if (st.topics_skipped.len > 0) {
        try b.s("\n  topics not walked (--topic ");
        try b.s(st.topic);
        try b.s("): ");
        try b.int(@intCast(st.topics_skipped.len));
        for (st.topics_skipped) |s| {
            try b.s("\n    ");
            try b.s(s);
        }
    }
    try b.s("\nexit ");
    try b.int(exitCode(st, tours));
}

/// what a terminal shows: one line per tour, then the summary
pub fn runProse(b: *Buf, st: Settings, tours: []const V.Tour) !void {
    for (tours) |t| {
        try tourProse(b, t);
        try b.c('\n');
    }
    try summary(b, st, tours);
}
