//! Testoor core -- THE VERDICT: the whole judgement of one walked tour, as a pure function of
//! its transcript. A port of `TestoorVerdict` and everything it calls in the Ring reference
//! (base/testoor/stzTraveller.ring). The same record, lines, exit and face rules must give the
//! same bytes here as there; golden/ holds the proof and testoor_golden_test.zig reads it.
//!
//! Five states and no sixth (ruling 2): kept, diverged, unreached, unjudged, unperceived.
//! A stop is as bad as its worst claim: diverged, then unreached, then unjudged, then kept; a
//! stop with no claim is unjudged. The reader assigns none of these; the judge assigns all.
//!
//! Times: a line's arrival is `ms / 1000` as an f64 and a stop's time is
//! `floor((closed - opened) * 1000)` in f64, exactly as the reference computes it, so that a
//! millisecond lost to floating point is lost in both places and a difference test finds none.
//!
//! Where the reference would RAISE on input it cannot read (`0 + "abc"` is R41 on both Ring and
//! Ring++), the core ignores the line and judges the rest. That is a deliberate difference and
//! the only kind this file makes; each is marked `DEVIATION`.

const std = @import("std");
const Allocator = std.mem.Allocator;
const T = @import("testoor_text.zig");
const P = @import("testoor_promises.zig");
const J = @import("testoor_json.zig");
const G = @import("testoor_graph.zig");
const Pr = @import("testoor_property.zig");

pub const State = enum {
    none,
    kept,
    diverged,
    unreached,
    unjudged,
    unperceived,

    pub fn name(self: State) []const u8 {
        return switch (self) {
            .none => "",
            .kept => "kept",
            .diverged => "diverged",
            .unreached => "unreached",
            .unjudged => "unjudged",
            .unperceived => "unperceived",
        };
    }
    fn rank(self: State) u8 {
        return switch (self) {
            .none => 0,
            .kept => 1,
            .unperceived => 2,
            .unjudged => 3,
            .unreached => 4,
            .diverged => 5,
        };
    }
};

pub fn worst(x: State, y: State) State {
    return if (y.rank() > x.rank()) y else x;
}

// ── the inputs ───────────────────────────────────────────────

pub const RClaim = struct { line: i64, kind: []const u8, claim: []const u8, want: []const u8 };
pub const RStop = struct { title: []const u8, line: i64, claims: []const RClaim };
pub const RRoute = struct { item: []const u8, stop: []const u8, line: i64 };

/// what a face read: only the fields the judge reads
pub const Record = struct {
    file: []const u8,
    dialect: []const u8,
    asserts: i64,
    stops: []const RStop,
    routes: []const RRoute,
};

pub const Line = struct { text: []const u8, at: f64 };

pub const Ending = struct { text: []const u8, ending: []const u8 };

/// a face's ending rules, as DATA (TESTOOR_PROTOCOL.md section 5)
pub const Face = struct { ignore: []const u8 = "", endings: []const Ending = &.{} };

pub const Meta = struct {
    exit: i64,
    hung: bool,
    stderr: []const u8,
    wall_ms: f64,
    seed: ?f64,
    unreadable: bool,
    face: Face,
    /// protocol 2: the program's graph and the names the tour's source mentions, both from the
    /// face; without a graph a tour's node lines are listed as reported
    graph: ?G.Graph = null,
    names: []const []const u8 = &.{},
};

// ── the outputs ──────────────────────────────────────────────

pub const Claim = struct { claim: []const u8, kind: []const u8, line: i64, want: []const u8, state: State };

pub const Stop = struct {
    title: []const u8,
    line: i64,
    state: State = .none,
    opened: f64 = -1,
    closed: f64 = -1,
    wall_ms: f64 = 0,
    claims: std.ArrayList(Claim) = .empty,
};

pub const Run = struct {
    end: []const u8,
    exit: i64,
    wall_ms: f64,
    seed: ?f64,
    state: State,
    kept: i64,
    diverged: i64,
    unreached: i64,
    unjudged: i64,
    stops: []Stop,
};

pub const Tour = struct {
    file: []const u8,
    dialect: []const u8,
    run: Run,
    flaky: bool,
    weather: []const []const u8,
    routes: []const RRoute,
    /// protocol 2: the nodes this tour reached or named; empty (and absent from the logbook) otherwise
    nodes: []const G.NodeEv = &.{},
    /// protocol 3 (V2): the property lines it printed, in order; empty (and absent from the logbook) otherwise
    properties: []const Pr.Record = &.{},
};

// ── how a tour ended ─────────────────────────────────────────

/// How a tour ENDED, from its output, its error stream and its exit code. What a language's
/// errors LOOK like is the face's business (its endings, tried in order); the core knows only
/// the neutral line "[testoor end timed]", a non-zero exit as broke and a zero exit as finished.
pub fn endingOf(a: Allocator, lines: []const Line, err: []const u8, exit: i64, hung: bool, face: Face) ![]const u8 {
    if (hung) return "hung";
    var all: std.ArrayList(u8) = .empty;
    try all.appendSlice(a, err);
    for (lines) |l| {
        if (face.ignore.len != 0 and T.startsWith(T.trimSp(l.text), face.ignore)) continue;
        try all.append(a, '\n');
        try all.appendSlice(a, l.text);
    }
    if (T.find(all.items, "[testoor end timed]") > 0) return "finished-timed";
    for (face.endings) |e| {
        if (T.find(all.items, e.text) > 0) return e.ending;
    }
    if (exit != 0) return "broke";
    return "finished";
}

// ── reading one printed line ─────────────────────────────────

const Verdict = struct { state: State, text: []const u8 };

fn verdictOf(a: Allocator, line: []const u8) !Verdict {
    const t = T.trimSp(line);
    const lt = try T.lowerAscii(a, t);
    const tn: i64 = @intCast(t.len);
    if (T.find(lt, "[pass]") > 0 or T.find(lt, "[ok]") > 0) return .{ .state = .kept, .text = try claimTextOf(a, t) };
    if (T.find(lt, "[fail]") > 0) return .{ .state = .diverged, .text = try claimTextOf(a, t) };
    if (T.startsWith(t, "ok   ")) return .{ .state = .kept, .text = T.trimSp(T.sub(t, 6, tn - 5)) };
    if (T.startsWith(t, "FAIL  ")) return .{ .state = .diverged, .text = T.trimSp(T.sub(t, 7, tn - 6)) };
    return .{ .state = .none, .text = "" };
}

/// "THEN  the bare form is 32 chars  [PASS]" -> "the bare form is 32 chars"
fn claimTextOf(a: Allocator, trimmed: []const u8) ![]const u8 {
    var c: []const u8 = trimmed;
    if (T.startsWith(c, "THEN ")) c = T.trimSp(T.sub(c, 6, @as(i64, @intCast(c.len)) - 5));
    const markers = [_][]const u8{ "[PASS]", "[FAIL]", "[OK]", "[ok]", "[pass]", "[fail]", "[Ok]" };
    for (markers) |m| {
        const n = T.find(c, m);
        if (n > 0) {
            const head = T.sub(c, 1, @as(i64, @intCast(n)) - 1);
            const tail = T.sub(c, @as(i64, @intCast(n + m.len)), @as(i64, @intCast(c.len)));
            c = try std.mem.concat(a, u8, &.{ head, tail });
            break;
        }
    }
    return T.trimSp(c);
}

/// a printed line that opens a stop: its 1-based index, or 0
fn stopOpened(line: []const u8, stops: []const Stop) usize {
    var t = T.trimSp(line);
    if (t.len == 0) return 0;
    if (T.startsWith(t, "SCENARIO: ")) t = T.sub(t, 11, @as(i64, @intCast(t.len)) - 10);
    for (stops, 0..) |s, k| {
        if (std.mem.eql(u8, s.title, t)) return k + 1;
    }
    return 0;
}

const Where = struct { s: usize, c: usize };

/// the claim a verdict text names, by exact text, else by the longest claim text the verdict
/// text begins with (chkeq adds "  [got x, want y]" after the claim)
fn claimNamed(text: []const u8, stops: []const Stop) ?Where {
    var best: ?Where = null;
    var n_best: usize = 0;
    for (stops, 0..) |st, s| {
        for (st.claims.items, 0..) |cl, c| {
            if (cl.claim.len == 0) continue;
            if (std.mem.eql(u8, cl.claim, text)) {
                if (cl.state == .none) return .{ .s = s, .c = c };
                if (best == null) best = .{ .s = s, .c = c };
            } else if (T.startsWith(text, cl.claim) and cl.claim.len > n_best and cl.state == .none) {
                best = .{ .s = s, .c = c };
                n_best = cl.claim.len;
            }
        }
    }
    return best;
}

/// a wanted promise as the child prints it is handled by the promise rules; this keeps a stop
/// list from being empty where the reference would index past its end
fn ensureStop(a: Allocator, stops: *std.ArrayList(Stop)) !void {
    if (stops.items.len == 0) try stops.append(a, .{ .title = "(the tour)", .line = 1 });
}

fn keptAnErrorPromise(a: Allocator, stops: []const Stop) !bool {
    for (stops) |st| {
        for (st.claims.items) |cl| {
            if (std.mem.eql(u8, cl.kind, "promise") and cl.state == .kept and try P.isErrorPromise(a, cl.want)) return true;
        }
    }
    return false;
}

// ── THE JUDGEMENT of one tour ────────────────────────────────

pub fn judge(a: Allocator, rec: Record, lines: []const Line, end: []const u8, exit: i64, wall: f64) !Run {
    var stops: std.ArrayList(Stop) = .empty;
    for (rec.stops) |rs| {
        var st = Stop{ .title = rs.title, .line = rs.line };
        for (rs.claims) |rc| {
            try st.claims.append(a, .{ .claim = rc.claim, .kind = rc.kind, .line = rc.line, .want = rc.want, .state = .none });
        }
        try stops.append(a, st);
    }

    // pass 1: stops open, verdicts land
    const nl = lines.len;
    var cur: usize = 0;
    for (lines) |ln| {
        const open = stopOpened(ln.text, stops.items);
        if (open > 0 and open != cur) {
            if (cur > 0 and stops.items[cur - 1].closed < 0) stops.items[cur - 1].closed = ln.at;
            cur = open;
            if (stops.items[cur - 1].opened < 0) stops.items[cur - 1].opened = ln.at;
            continue;
        }
        const v = try verdictOf(a, ln.text);
        if (v.state != .none) {
            if (claimNamed(v.text, stops.items)) |w| {
                stops.items[w.s].claims.items[w.c].state = v.state;
                if (stops.items[w.s].opened < 0) stops.items[w.s].opened = ln.at;
            } else {
                // a verdict the reader had no claim for (a dynamic text, a Then() in a loop):
                // it joins the stop in progress as its own
                try ensureStop(a, &stops);
                const to = if (cur == 0) 1 else cur;
                try stops.items[to - 1].claims.append(a, .{ .claim = v.text, .kind = "sees", .line = 0, .want = "", .state = v.state });
            }
        }
    }
    if (cur > 0 and stops.items[cur - 1].closed < 0 and nl > 0) stops.items[cur - 1].closed = lines[nl - 1].at;

    // PROMISES, walked in order against the output: an ordered subsequence. A promise that is
    // not found consumes one line, so one divergence cannot hand its line to the next. A file
    // that RAISED part-way, never started or was killed has not broken the promises below it:
    // they are unreached.
    const raised = std.mem.eql(u8, end, "broke") or std.mem.eql(u8, end, "not-started") or
        std.mem.eql(u8, end, "hung") or std.mem.eql(u8, end, "unreadable");
    const normed = try a.alloc([]const u8, nl);
    for (lines, 0..) |ln, i| normed[i] = try P.norm(a, ln.text);
    var cursor: usize = 1;
    for (stops.items) |*st| {
        for (st.claims.items) |*cl| {
            if (std.mem.eql(u8, cl.kind, "prose")) {
                cl.state = .unjudged; // a note, not a checkable promise: reported, never judged
                continue;
            }
            if (!std.mem.eql(u8, cl.kind, "promise")) continue;
            const found = try P.promiseAt(a, cl.want, normed, cursor);
            if (found > 0) {
                cl.state = .kept;
                if (!try P.isErrorPromise(a, cl.want)) cursor = found + 1;
            } else if (raised) {
                cl.state = .unreached;
            } else {
                cl.state = .diverged;
                if (cursor <= nl) cursor += 1;
            }
        }
    }

    // PICTURES: a success prints nothing, so which picture failed cannot be read from the
    // output, only that one did and which row. A mismatch joins the stop in progress as a
    // diverged claim of its own, and the file's picture claims are unjudged.
    var mis: []const u8 = "";
    for (lines, 0..) |ln, i| {
        if (T.find(ln.text, "DOES NOT MATCH") > 0) {
            mis = T.trimSp(ln.text);
            if (i + 2 < nl and T.find(lines[i + 2].text, "first difference at row") > 0) {
                mis = try std.mem.concat(a, u8, &.{ mis, " -- ", T.trimSp(lines[i + 2].text) });
            }
            try ensureStop(a, &stops);
            const to = if (cur == 0) 1 else cur;
            try stops.items[to - 1].claims.append(a, .{ .claim = mis, .kind = "picture", .line = 0, .want = "", .state = .diverged });
            break;
        }
    }
    const finished = std.mem.eql(u8, end, "finished") or std.mem.eql(u8, end, "finished-timed");
    for (stops.items) |*st| {
        for (st.claims.items) |*cl| {
            if (!std.mem.eql(u8, cl.kind, "picture")) continue;
            if (cl.state != .none) continue;
            if (mis.len != 0) {
                cl.state = .unjudged;
            } else if (finished) {
                cl.state = .kept;
            }
        }
    }

    // pass 2: what printed nothing is unreached or unjudged by how the tour ended
    var silent: State = .unjudged;
    if (std.mem.eql(u8, end, "broke") or std.mem.eql(u8, end, "hung") or std.mem.eql(u8, end, "not-started")) silent = .unreached;
    var tour_state: State = .kept;
    var n_kept: i64 = 0;
    var n_div: i64 = 0;
    var n_unr: i64 = 0;
    var n_unj: i64 = 0;
    const ns = stops.items.len;
    for (stops.items, 0..) |*st, s| {
        var cst: State = .kept;
        if (st.claims.items.len == 0) cst = .unjudged;
        for (st.claims.items) |*cl| {
            if (cl.state == .none) cl.state = silent;
            cst = worst(cst, cl.state);
            switch (cl.state) {
                .kept => n_kept += 1,
                .diverged => n_div += 1,
                .unreached => n_unr += 1,
                .unjudged => n_unj += 1,
                else => {},
            }
        }
        st.state = cst;
        tour_state = worst(tour_state, cst);
        // wall time: from the stop's opening line to the next stop's, else to the end
        const n_o = st.opened;
        var n_cl = st.closed;
        if (n_o >= 0 and n_cl < 0) {
            if (s + 1 < ns and stops.items[s + 1].opened >= 0) {
                n_cl = stops.items[s + 1].opened;
            } else {
                n_cl = wall / 1000.0;
            }
        }
        if (n_o >= 0 and n_cl >= n_o) st.wall_ms = @floor((n_cl - n_o) * 1000.0);
    }

    // A RAISE THAT WAS PROMISED IS NOT A BREAK
    var c_end = end;
    if (std.mem.eql(u8, c_end, "broke") and n_div == 0 and n_unr == 0 and try keptAnErrorPromise(a, stops.items)) c_end = "finished";
    return .{
        .end = c_end,
        .exit = exit,
        .wall_ms = wall,
        .seed = null,
        .state = tour_state,
        .kept = n_kept,
        .diverged = n_div,
        .unreached = n_unr,
        .unjudged = n_unj,
        .stops = stops.items,
    };
}

// ── a self-describing tour ───────────────────────────────────

fn hasProtocolVerdicts(lines: []const Line) bool {
    for (lines) |l| {
        const t = T.trimSp(l.text);
        if (T.startsWith(t, "[testoor ok ") or T.startsWith(t, "[testoor fail ") or T.startsWith(t, "[testoor stop ")) return true;
        if (Pr.looksLikeLine(t)) return true;
    }
    return false;
}

fn endsBracket(t: []const u8) bool {
    return t.len > 0 and t[t.len - 1] == ']';
}

const Adopted = struct { rec: Record, lines: []const Line };

/// A SELF-DESCRIBING tour (TESTOOR_PROTOCOL.md section 3) is turned into the record a reader
/// would have made and the lines the judge already understands: [testoor stop T] opens a stop
/// titled T, [testoor ok X] and [testoor fail X] are claims with their verdict, [testoor plan N]
/// announces claims the tour owes, [testoor route ID] is a route. One judge, any language.
fn adoptProtocol(a: Allocator, rec: Record, lines: []const Line) !Adopted {
    var stops: std.ArrayList(RStop) = .empty;
    var claims: std.ArrayList(std.ArrayList(RClaim)) = .empty;
    var routes: std.ArrayList(RRoute) = .empty;
    var out: std.ArrayList(Line) = .empty;
    var cur: usize = 0;
    var printed: i64 = 0;
    var plan: f64 = 0;
    for (lines, 0..) |ln, idx| {
        const i: i64 = @intCast(idx + 1);
        const t = T.trimSp(ln.text);
        const tn: i64 = @intCast(t.len);
        if (T.startsWith(t, "[testoor stop ") and endsBracket(t)) {
            const title = T.sub(t, 15, tn - 15);
            try stops.append(a, .{ .title = title, .line = i, .claims = &.{} });
            try claims.append(a, .empty);
            cur = stops.items.len;
            try out.append(a, .{ .text = title, .at = ln.at });
        } else if ((T.startsWith(t, "[testoor ok ") or T.startsWith(t, "[testoor fail ")) and endsBracket(t)) {
            const ok = T.startsWith(t, "[testoor ok ");
            const text = if (ok) T.sub(t, 13, tn - 13) else T.sub(t, 15, tn - 15);
            if (cur == 0) {
                try stops.append(a, .{ .title = "(the tour)", .line = 1, .claims = &.{} });
                try claims.append(a, .empty);
                cur = 1;
                try out.append(a, .{ .text = "(the tour)", .at = ln.at });
            }
            try claims.items[cur - 1].append(a, .{ .line = i, .kind = "sees", .claim = text, .want = "" });
            printed += 1;
            const shown = try std.mem.concat(a, u8, &.{ if (ok) "  [OK] " else "  [FAIL] ", text });
            try out.append(a, .{ .text = shown, .at = ln.at });
        } else if (try Pr.parseLine(a, t)) |pr| {
            // protocol 3 (V2): in a self-describing tour a property is a claim of the stop it is printed in
            const text = try std.mem.concat(a, u8, &.{ "property ", pr.id });
            if (cur == 0) {
                try stops.append(a, .{ .title = "(the tour)", .line = 1, .claims = &.{} });
                try claims.append(a, .empty);
                cur = 1;
                try out.append(a, .{ .text = "(the tour)", .at = ln.at });
            }
            try claims.items[cur - 1].append(a, .{ .line = i, .kind = "property", .claim = text, .want = "" });
            printed += 1;
            const shown = try std.mem.concat(a, u8, &.{ if (pr.held) "  [OK] " else "  [FAIL] ", text });
            try out.append(a, .{ .text = shown, .at = ln.at });
        } else if (T.startsWith(t, "[testoor route ") and endsBracket(t)) {
            const where = if (cur > 0) stops.items[cur - 1].title else "";
            try routes.append(a, .{ .item = T.sub(t, 16, tn - 16), .stop = where, .line = i });
        } else if (T.startsWith(t, "[testoor plan ") and endsBracket(t)) {
            // DEVIATION: the reference raises R41 on a plan that is not a number; the core
            // ignores the number and keeps the line
            if (T.parseNumber(T.sub(t, 15, tn - 15))) |n| plan = n;
            try out.append(a, ln);
        } else {
            try out.append(a, ln);
        }
    }
    // the claims a tour announced and never printed
    const plan_cap: f64 = 1.0e6;
    if (plan > @as(f64, @floatFromInt(printed))) {
        if (cur == 0) {
            try stops.append(a, .{ .title = "(the tour)", .line = 1, .claims = &.{} });
            try claims.append(a, .empty);
            cur = 1;
        }
        var k: i64 = printed + 1;
        const last: i64 = @intFromFloat(@min(@floor(plan), plan_cap));
        while (k <= last) : (k += 1) {
            const text = try std.fmt.allocPrint(a, "(planned claim {d})", .{k});
            try claims.items[cur - 1].append(a, .{ .line = 0, .kind = "sees", .claim = text, .want = "" });
        }
    }
    if (stops.items.len == 0) {
        try stops.append(a, .{ .title = "(the tour)", .line = 1, .claims = &.{} });
        try claims.append(a, .empty);
    }
    for (stops.items, 0..) |*st, k| st.claims = claims.items[k].items;
    return .{
        .rec = .{ .file = rec.file, .dialect = "protocol", .asserts = 1, .stops = stops.items, .routes = routes.items },
        .lines = out.items,
    };
}

// ── THE VERDICT ──────────────────────────────────────────────

/// The whole judgement of ONE walked tour. `seed` is the seed the child was handed; a seed
/// the tour printed wins. Answers the tour as the logbook writes it.
pub fn verdict(a: Allocator, rec: Record, lines: []const Line, meta: Meta) !Tour {
    if (meta.unreadable) {
        // the reader could not read the file: nothing ran, nothing is claimed
        var run = try judge(a, rec, &.{}, "unreadable", -1, 0);
        run.end = "unreadable";
        return .{ .file = rec.file, .dialect = rec.dialect, .run = run, .flaky = false, .weather = &.{}, .routes = rec.routes };
    }
    const end = try endingOf(a, lines, meta.stderr, meta.exit, meta.hung, meta.face);
    var r = rec;
    var ls = lines;
    // a self-describing tour has no static record: build it from what it said
    if (std.mem.eql(u8, r.dialect, "protocol") or (r.asserts == 0 and hasProtocolVerdicts(ls))) {
        const ad = try adoptProtocol(a, r, ls);
        r = ad.rec;
        ls = ad.lines;
    }
    var run = try judge(a, r, ls, end, meta.exit, meta.wall_ms);
    // the seed the child walked with: the runner's, unless the tour printed its own
    run.seed = meta.seed;
    var weather: std.ArrayList([]const u8) = .empty;
    var hits: std.ArrayList(G.Hit) = .empty;
    var props: std.ArrayList(Pr.Record) = .empty;
    // the lines as the child printed them: adoption above turns a property line into its verdict, and node, seed and
    // weather lines pass through it unchanged
    for (lines) |ln| {
        const t = T.trimSp(ln.text);
        const tn: i64 = @intCast(t.len);
        if (T.startsWith(t, "[testoor property ")) {
            // protocol 3 (V2): every tour keeps its property lines; a malformed one stays ordinary output
            if (try Pr.parseLine(a, t)) |pr| try props.append(a, pr);
        } else if (T.startsWith(t, "[testoor node ")) {
            // protocol 2; a line whose count is malformed is ignored and stays ordinary output
            if (G.parseNodeLine(t)) |h| try hits.append(a, h);
        } else if (T.startsWith(t, "[testoor seed ")) {
            // DEVIATION: the reference raises R41 on a seed that is not a number
            if (T.parseNumber(T.sub(t, 15, tn - 15))) |n| run.seed = n;
        } else if (T.startsWith(t, "[testoor weather ") and !T.startsWith(t, "[testoor weather fired ")) {
            try weather.append(a, T.sub(t, 18, tn - 18));
        }
    }
    const nodes = try G.nodeEvidence(a, meta.graph, hits.items, meta.names);
    return .{ .file = r.file, .dialect = r.dialect, .run = run, .flaky = false, .weather = weather.items, .routes = r.routes, .nodes = nodes, .properties = props.items };
}

// ── reading the goldens' input formats ───────────────────────

/// a field the request must carry; its absence is an error the caller can name, never a panic
fn need(v: J.Value, key: []const u8) error{BadRequest}!J.Value {
    return v.get(key) orelse error.BadRequest;
}

pub fn recordFromValue(a: Allocator, v: J.Value) !Record {
    var stops: std.ArrayList(RStop) = .empty;
    for ((try need(v, "stops")).items()) |sv| {
        var cl: std.ArrayList(RClaim) = .empty;
        for ((try need(sv, "claims")).items()) |cv| {
            try cl.append(a, .{
                .line = (try need(cv, "line")).int_(),
                .kind = (try need(cv, "kind")).str_(),
                .claim = (try need(cv, "claim")).str_(),
                .want = (try need(cv, "want")).str_(),
            });
        }
        try stops.append(a, .{ .title = (try need(sv, "title")).str_(), .line = (try need(sv, "line")).int_(), .claims = cl.items });
    }
    var routes: std.ArrayList(RRoute) = .empty;
    for ((try need(v, "routes")).items()) |rv| {
        try routes.append(a, .{ .item = (try need(rv, "item")).str_(), .stop = (try need(rv, "stop")).str_(), .line = (try need(rv, "line")).int_() });
    }
    return .{
        .file = (try need(v, "file")).str_(),
        .dialect = (try need(v, "dialect")).str_(),
        .asserts = (try need(v, "asserts")).int_(),
        .stops = stops.items,
        .routes = routes.items,
    };
}

pub fn metaFromValue(a: Allocator, v: J.Value) !Meta {
    var endings: std.ArrayList(Ending) = .empty;
    var ignore: []const u8 = "";
    if (v.get("face")) |f| {
        if (f.get("ignore")) |ig| ignore = ig.str_();
        if (f.get("endings")) |ev| {
            for (ev.items()) |e| {
                const pair = e.items();
                if (pair.len >= 2) try endings.append(a, .{ .text = pair[0].str_(), .ending = pair[1].str_() });
            }
        }
    }
    var seed: ?f64 = null;
    if (v.get("seed")) |sv| switch (sv) {
        .num => |n| seed = n,
        else => {},
    };
    return .{
        .exit = (try need(v, "exit")).int_(),
        .hung = (try need(v, "hung")).truthy(),
        .stderr = (try need(v, "stderr")).str_(),
        .wall_ms = (try need(v, "wall_ms")).num_(),
        .seed = seed,
        .unreadable = if (v.get("unreadable")) |u| u.truthy() else false,
        .face = .{ .ignore = ignore, .endings = endings.items },
    };
}

/// output.txt: "<ms><TAB><text>" per line, carriage returns removed first, a line with no TAB
/// skipped. DEVIATION: a first field that is not a number is an error here, where the
/// reference would raise.
pub fn linesFromText(a: Allocator, text: []const u8) ![]Line {
    const clean = try T.removeCr(a, text);
    const rows = try T.splitLines(a, clean);
    var out: std.ArrayList(Line) = .empty;
    for (rows) |row| {
        const tab = T.find(row, "\t");
        if (tab == 0) continue;
        const ms = T.parseNumber(T.sub(row, 1, @as(i64, @intCast(tab)) - 1)) orelse return error.BadOutputLine;
        const rest = T.sub(row, @as(i64, @intCast(tab)) + 1, @as(i64, @intCast(row.len)) - @as(i64, @intCast(tab)));
        try out.append(a, .{ .text = rest, .at = ms / 1000.0 });
    }
    return out.items;
}

/// the live form: an array of [text, arrival in milliseconds] pairs, which keeps a carriage
/// return that sits inside a line, where the text form of the goldens removes it
pub fn linesFromValue(a: Allocator, v: J.Value) ![]Line {
    var out: std.ArrayList(Line) = .empty;
    for (v.items()) |pair| {
        const p = pair.items();
        if (p.len < 2) return error.BadOutputLine;
        try out.append(a, .{ .text = p[0].str_(), .at = p[1].num_() / 1000.0 });
    }
    return out.items;
}
