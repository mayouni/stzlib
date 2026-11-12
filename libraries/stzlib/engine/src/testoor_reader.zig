//! Testoor core -- THE HARO FACE's reader (P3.6, TESTOOR_PROTOCOL_3.md section 6).
//!
//! Reading a tour's source into the record the judge reads was the Ring face's work, in Ring. Since the Principal ruled
//! that no new code is written in the retired language (PRINCIPAL-NORING-01, 2026-11-09) and the estate's tests are
//! written in Haro, the face for `.haro` tours lives here, in the core, so the native runner walks them with no other
//! language involved.
//!
//! A `.haro` guard is NARRATED: `Scenario("...")` opens a stop and `Then("...", got, wanted)` is a claim of the stop in
//! progress; it prints `SCENARIO: <title>` and `  THEN  <claim>  [PASS]` or `[FAIL]`, the lines the judge already
//! reads. The rules:
//!
//!   * a stop is a line that begins with `Scenario(` whose first argument is ONE text literal; a claim, a line that
//!     begins with `Then(` likewise. A claim whose text is built at run time (`Then("a" + x, ...)`) is counted in
//!     `asserts` but not recorded: the judge adds it when its verdict line is printed, so it is never guessed
//!   * claims are read at the top level and inside the file's own functions, never inside a HELPER's body: a
//!     function named Then, Scenario, Summary, Chk, ChkEq or Sec, or one whose body prints `[PASS]`, `[FAIL]` or
//!     `[OK]` -- that is the verdict's shape, not a claim of the file. A class body is not read either
//!   * a line that begins with `#` is a comment; a claim before any stop opens the stop `(the tour)`
//!   * a file with no `Scenario(` and no `Then(` is of dialect `unknown`, and a self-describing one is judged from
//!     the `[testoor ...]` lines it prints, as before
//!
//! Imports no other language.

const std = @import("std");
const T = @import("testoor_text.zig");
const V = @import("testoor_verdict.zig");

const Allocator = std.mem.Allocator;
const Buf = T.Buf;

pub const Read = struct { record: V.Record, lines: usize };

fn trimWs(s: []const u8) []const u8 {
    return std.mem.trim(u8, s, " \t\r");
}

fn startsCi(s: []const u8, prefix: []const u8) bool {
    return s.len >= prefix.len and std.ascii.eqlIgnoreCase(s[0..prefix.len], prefix);
}

/// the name after `func `, up to its parenthesis or a space
fn funcName(t: []const u8) []const u8 {
    const rest = trimWs(t[5..]);
    var n: usize = 0;
    while (n < rest.len and rest[n] != '(' and rest[n] != ' ' and rest[n] != '\t') n += 1;
    return rest[0..n];
}

/// the text of a call's first argument when it is ONE literal -- `"..."` or `'...'` followed by `,` or `)` -- else null
fn literalArg(t: []const u8, call_len: usize) ?[]const u8 {
    var i = call_len;
    while (i < t.len and (t[i] == ' ' or t[i] == '\t')) i += 1;
    if (i >= t.len or (t[i] != '"' and t[i] != '\'')) return null;
    const q = t[i];
    const start = i + 1;
    const end = std.mem.indexOfScalarPos(u8, t, start, q) orelse return null;
    var j = end + 1;
    while (j < t.len and (t[j] == ' ' or t[j] == '\t')) j += 1;
    if (j >= t.len or (t[j] != ',' and t[j] != ')')) return null;
    return t[start..end];
}

const helper_names = [_][]const u8{ "then", "scenario", "summary", "chk", "chkeq", "sec" };

fn isHelperName(name: []const u8) bool {
    for (helper_names) |h| if (std.ascii.eqlIgnoreCase(h, name)) return true;
    return false;
}

fn printsVerdict(t: []const u8) bool {
    return std.mem.indexOf(u8, t, "[PASS]") != null or std.mem.indexOf(u8, t, "[FAIL]") != null or std.mem.indexOf(u8, t, "[OK]") != null;
}

const Stop = struct { title: []const u8, line: i64, claims: std.ArrayList(V.RClaim) = .empty };

/// a `.haro` tour's source read into the record the judge reads
pub fn readHaro(a: Allocator, file: []const u8, source: []const u8) !Read {
    const text = try T.removeCr(a, source);
    var lines = try T.splitLines(a, text);
    if (lines.len > 0 and lines[lines.len - 1].len == 0) lines = lines[0 .. lines.len - 1];

    // pass 1: which of the file's functions are helpers
    var helpers: std.ArrayList([]const u8) = .empty;
    var i: usize = 0;
    while (i < lines.len) : (i += 1) {
        const t = trimWs(lines[i]);
        if (!startsCi(t, "func ")) continue;
        const name = funcName(t);
        var helper = isHelperName(name);
        var j = i + 1;
        while (!helper and j < lines.len) : (j += 1) {
            const u = trimWs(lines[j]);
            if (startsCi(u, "func ") or startsCi(u, "class ")) break;
            if (u.len > 0 and u[0] != '#' and printsVerdict(u)) helper = true;
        }
        if (helper) try helpers.append(a, name);
    }

    // pass 2: stops and claims
    var stops: std.ArrayList(Stop) = .empty;
    var cur: ?usize = null;
    var muted = false;
    var asserts: i64 = 0;
    var narrated = false;
    for (lines, 0..) |raw, k| {
        const n: i64 = @intCast(k + 1);
        const t = trimWs(raw);
        if (t.len == 0 or t[0] == '#') continue;
        if (startsCi(t, "func ")) {
            const name = funcName(t);
            muted = false;
            for (helpers.items) |h| if (std.ascii.eqlIgnoreCase(h, name)) {
                muted = true;
            };
            continue;
        }
        if (startsCi(t, "class ")) {
            muted = true;
            continue;
        }
        if (muted) continue;
        if (startsCi(t, "scenario(")) {
            narrated = true;
            if (literalArg(t, "scenario(".len)) |title| {
                try stops.append(a, .{ .title = title, .line = n });
                cur = stops.items.len - 1;
            }
            continue;
        }
        if (startsCi(t, "then(")) {
            narrated = true;
            asserts += 1;
            const claim = literalArg(t, "then(".len) orelse continue;
            if (cur == null) {
                try stops.append(a, .{ .title = "(the tour)", .line = 1 });
                cur = stops.items.len - 1;
            }
            try stops.items[cur.?].claims.append(a, .{ .line = n, .kind = "sees", .claim = claim, .want = "" });
        }
    }
    var rstops = try a.alloc(V.RStop, stops.items.len);
    for (stops.items, 0..) |s, k| rstops[k] = .{ .title = s.title, .line = s.line, .claims = s.claims.items };
    return .{
        .record = .{ .file = file, .dialect = if (narrated) "narrated" else "unknown", .asserts = asserts, .stops = rstops, .routes = &.{} },
        .lines = lines.len,
    };
}

/// the record as the Ring face wrote it (`record.json` in the goldens), on one line
pub fn writeRecord(b: *Buf, rd: Read) !void {
    const r = rd.record;
    try b.s("{\"file\":");
    try b.js(r.file);
    try b.s(",\"readable\":1,\"why\":\"\",\"dialect\":");
    try b.js(r.dialect);
    try b.s(",\"lines\":");
    try b.int(@intCast(rd.lines));
    try b.s(",\"asserts\":");
    try b.int(r.asserts);
    try b.s(",\"stops\":[");
    for (r.stops, 0..) |s, k| {
        if (k > 0) try b.c(',');
        try b.s("{\"title\":");
        try b.js(s.title);
        try b.s(",\"line\":");
        try b.int(s.line);
        try b.s(",\"claims\":[");
        for (s.claims, 0..) |c, j| {
            if (j > 0) try b.c(',');
            try b.s("{\"line\":");
            try b.int(c.line);
            try b.s(",\"kind\":");
            try b.js(c.kind);
            try b.s(",\"claim\":");
            try b.js(c.claim);
            try b.s(",\"want\":");
            try b.js(c.want);
            try b.c('}');
        }
        try b.s("]}");
    }
    try b.s("],\"routes\":[]}");
}

/// the Haro face: how its tours end, as data. A refused statement or a runtime error broke the tour; a guard that
/// printed its own `TOTAL:` line FINISHED, whatever its exit code (it exits with its failure count, and those failures
/// are diverged claims, not a break). Verdict lines are not read for endings: a claim's text may hold any of these
pub const face = V.Face{
    .ignore = "THEN  ",
    .verdicts = "THEN ",
    .endings = &.{
        .{ .text = "Haro refused this statement", .ending = "broke" },
        .{ .text = "Error (R", .ending = "broke" },
        .{ .text = "TOTAL: ", .ending = "finished" },
    },
};

// ── tests ────────────────────────────────────────────────────

const testing = std.testing;

test "a literal is one quoted text followed by a comma or a parenthesis; anything built is not" {
    try testing.expectEqualStrings("one is one", literalArg("Then(\"one is one\", n, 1)", 5).?);
    try testing.expectEqualStrings("q", literalArg("Then( 'q' )", 5).?);
    try testing.expect(literalArg("Then(\"a\" + tX, 1, 1)", 5) == null);
    try testing.expect(literalArg("Then(tName, 1, 1)", 5) == null);
    try testing.expect(literalArg("Then(\"never closed, 1, 1)", 5) == null);
}

test "a helper is named so, or prints a verdict; its body holds no claim" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const src = "Scenario(\"s\")\nCheck(1)\nfunc Check(nX)\n\tif nX = 1\n\t\t? \"  [OK] fine\"\n\tend\n\tThen(\"inside a helper\", 1, 1)\nend\n";
    const r = try readHaro(a, "h.haro", src);
    try testing.expectEqual(@as(usize, 1), r.record.stops.len);
    try testing.expectEqual(@as(usize, 0), r.record.stops[0].claims.len);
    try testing.expectEqual(@as(i64, 0), r.record.asserts);
}
