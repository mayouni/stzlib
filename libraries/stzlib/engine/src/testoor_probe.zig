//! Testoor core -- the PROBE: which of a Haro codebase's functions a tour reached, observed with nothing asked of haro.exe
//! (TESTOOR_PROTOCOL_3.md section 6.8). The evidence report's ladder needs, for each function, whether a tour ran it
//! (protocol 2's `[testoor node ID]`, grade 1, observed); haro.exe counts no calls (HARO-CALLCOUNT-01), so a function of a
//! Haro codebase stood at grade 0 whatever its tours did. `testoor probe FOLDER` puts one call in each function of a COPY of
//! the codebase, and a walk of its tours then says which ran.
//!
//! What a probed file holds, measured on haro.exe of 2026-11-14:
//!
//!   each function and method      the call before the first statement of its body, on that statement's line:
//!                                 `\tTestoorProbeHit(4) nSec = Floor(nMs / 1000)` -- measured before an `if`, a `for`, a
//!                                 `while`, a `try`, a print, a list written over two lines, a `return` continued on the
//!                                 next, and an `end` that closes an empty body
//!   a .haro file's last line      `load "<path>/_testoor_probe.haro"`, added on a line of its own: every block of a
//!                                 .haro file closes with `end`, so its last line is the file's own
//!   any other file's first line   the same load, at the start of the line, before what it holds (after a byte-order
//!                                 mark). In the older syntax haro.exe still reads, a region runs on to the next
//!                                 definition, and a load on the last line was not read in 165 of the 557 such files
//!                                 of stzlib's library (2026-11-27): those files, read alone, called no probe. Before a
//!                                 comment, a block comment, a blank, a `load`, a `func`, a `class` or a statement,
//!                                 the load at the start of line 1 was read; a .haro line holds one statement, so
//!                                 a .haro file keeps the last line
//!
//! NOT after the signature, on its line: `func F(nMs) TestoorProbeHit(50)` ran on haro.exe for some functions and,
//! for others, made the signature a function of one line and the body the file's own statements -- the parameter then
//! read as unset (measured on the Foundry, 2026-11-15; the probe's own check caught five such). Neither does
//! haro.exe read a call after a bare name: what follows it is its parameters. So a function whose body begins on the
//! line of its signature is not probed, and is named. No line of a file moves: a claim, an error and a graph name the
//! lines they named. `_testoor_probe.haro`, written at
//! the folder's root, holds TestoorProbeHit: on the first call of each function in a process, one line `[testoor node ID]`
//! appended to the file the variable TESTOOR_NODES names -- the walk names one for each tour, and reads it as the tour's own
//! node lines (testoor_runner.zig). With no such variable it writes nothing, so a probed copy runs as the codebase does. It
//! sets itself up on its first call (a file's own statements may call a function before a load of it is reached),
//! and a child process writes to the same file, so a function a tour ran through a program it started counts too.
//!
//! THE PROBE'S NAMES ARE ITS OWN. Its first name was TestoorNodeHit, and stzlib defines TestoorNodeHit (its node counter,
//! base/testoor/stzNodes.ring): a guard loads the library first, the first definition of a name is the one haro.exe keeps,
//! and every probed call went to the library's counter -- the Foundry's guards observed nothing in their own process, and
//! only the child programs that load the modules alone wrote a line (measured 2026-11-15). TestoorProbeHit and its globals
//! are named nowhere in stzlib; a codebase that defined one would shadow the probe the same way.
//!
//! The first call is written, never a count: the line means "reached at least once", which is grade 1. A count is
//! haro.exe's to give (HARO-CALLCOUNT-01). A function the probe cannot place a call in is named, never guessed.

const std = @import("std");
const Allocator = std.mem.Allocator;
const T = @import("testoor_text.zig");
const J = @import("testoor_json.zig");
const G = @import("testoor_graph.zig");

pub const hit_name = "TestoorProbeHit";
pub const probe_file = "_testoor_probe.haro";

/// a definition of the file haro graph was asked about: its node id and the line its signature begins on
pub const Def = struct { id: []const u8, name: []const u8, line: i64, kind: []const u8 = "function" };

/// the first block of haro graph's lines -- the file asked about, before the files it loads -- with every line a
/// definition or a class begins on
pub const Block = struct {
    defs: []const Def,
    starts: []const i64,
    unfinished: []const []const u8,
    /// the block's own lines, for the codebase's record
    lines: []const []const u8,
};

fn field(fs: []const []const u8, i: usize) []const u8 {
    return if (i < fs.len) fs[i] else "";
}

fn lineNo(s: []const u8) i64 {
    return std.fmt.parseInt(i64, std.mem.trim(u8, s, " \r"), 10) catch 0;
}

pub fn firstBlock(a: Allocator, text: []const u8) !Block {
    var defs: std.ArrayList(Def) = .empty;
    var starts: std.ArrayList(i64) = .empty;
    var unfinished: std.ArrayList([]const u8) = .empty;
    var lines: std.ArrayList([]const u8) = .empty;
    var files: usize = 0;
    var it = std.mem.splitScalar(u8, text, '\n');
    while (it.next()) |raw| {
        const ln = std.mem.trimRight(u8, raw, "\r");
        var fs: std.ArrayList([]const u8) = .empty;
        var p = std.mem.splitScalar(u8, ln, '|');
        while (p.next()) |f| try fs.append(a, f);
        const tag = field(fs.items, 0);
        if (std.mem.eql(u8, tag, "FILE")) {
            files += 1;
            if (files > 1) break;
            continue;
        }
        if (files == 0) continue;
        try lines.append(a, ln);
        if (std.mem.eql(u8, tag, "FUNC")) {
            const name = field(fs.items, 1);
            try defs.append(a, .{ .id = name, .name = name, .line = lineNo(field(fs.items, 2)) });
            try starts.append(a, lineNo(field(fs.items, 2)));
        } else if (std.mem.eql(u8, tag, "METHOD")) {
            const name = field(fs.items, 2);
            try defs.append(a, .{ .id = try std.mem.concat(a, u8, &.{ field(fs.items, 1), ".", name }), .name = name, .line = lineNo(field(fs.items, 3)), .kind = "method" });
            try starts.append(a, lineNo(field(fs.items, 3)));
        } else if (std.mem.eql(u8, tag, "CLASS")) {
            try starts.append(a, lineNo(field(fs.items, 3)));
        } else if (std.mem.eql(u8, tag, "UNFINISHED")) {
            try unfinished.append(a, field(fs.items, 1));
        }
    }
    return .{ .defs = defs.items, .starts = starts.items, .unfinished = unfinished.items, .lines = lines.items };
}

/// where the code of a line ends: at a `#` or `//` comment outside a string, else its length
fn codeEnd(line: []const u8) usize {
    var q: u8 = 0;
    var i: usize = 0;
    while (i < line.len) : (i += 1) {
        const ch = line[i];
        if (q != 0) {
            if (ch == q) q = 0;
            continue;
        }
        switch (ch) {
            '"', '\'', '`' => q = ch,
            '#' => return i,
            '/' => if (i + 1 < line.len and line[i + 1] == '/') return i,
            else => {},
        }
    }
    return line.len;
}

fn isWord(ch: u8) bool {
    return std.ascii.isAlphanumeric(ch) or ch == '_' or ch == '@';
}

/// where the definition's name ends on its line: after `func`/`def` and the name, compared without case; null when the line
/// does not begin that definition
fn afterName(line: []const u8, name: []const u8) ?usize {
    const code = line[0..codeEnd(line)];
    var i: usize = 0;
    while (i < code.len and (code[i] == ' ' or code[i] == '\t')) i += 1;
    var j = i;
    while (j < code.len and isWord(code[j])) j += 1;
    const kw = code[i..j];
    if (!std.ascii.eqlIgnoreCase(kw, "func") and !std.ascii.eqlIgnoreCase(kw, "def")) return null;
    var k = j;
    while (k < code.len and (code[k] == ' ' or code[k] == '\t')) k += 1;
    var m = k;
    while (m < code.len and isWord(code[m])) m += 1;
    if (!std.ascii.eqlIgnoreCase(code[k..m], name)) return null;
    return m;
}

pub const Skip = struct { id: []const u8, line: i64, why: []const u8 };

pub const Probed = struct {
    text: []const u8,
    /// the definitions given a call, in the order given; the call's number is `first` plus the index here
    ids: []const []const u8,
    skipped: []const Skip,
};

/// Where a file takes the load of the probe file
pub const Place = enum { last_line, first_line };

/// A .haro file takes it on a new last line; a file of any other extension at the start of its first line
pub fn placeFor(path: []const u8) Place {
    return if (std.ascii.endsWithIgnoreCase(path, ".haro")) .last_line else .first_line;
}

fn isBlank(line: []const u8) bool {
    return std.mem.trim(u8, line, " \t\r").len == 0;
}

/// The source with a call in each definition, and the load of the probe file where `place` says. `first` is the number the
/// first call takes; the calls are numbered in the order of `defs`. `starts` are the lines a definition or a class begins
/// on: a body found to begin on one has no line of its own to take the call. No line moves.
pub fn instrument(a: Allocator, source: []const u8, defs: []const Def, starts: []const i64, first: usize, probe_path: []const u8, place: Place) !Probed {
    const crlf = std.mem.indexOf(u8, source, "\r\n") != null;
    var lines: std.ArrayList([]const u8) = .empty;
    var it = std.mem.splitScalar(u8, source, '\n');
    while (it.next()) |l| try lines.append(a, l);
    // a source ending with a line end splits into a last empty piece, which is no line
    const ends_nl = source.len > 0 and source[source.len - 1] == '\n';
    if (ends_nl) _ = lines.pop();
    const n: i64 = @intCast(lines.items.len);

    var ids: std.ArrayList([]const u8) = .empty;
    var skipped: std.ArrayList(Skip) = .empty;
    for (defs) |d| {
        if (d.line < 1 or d.line > n) {
            try skipped.append(a, .{ .id = d.id, .line = d.line, .why = "its line is not in the file" });
            continue;
        }
        const at: usize = @intCast(d.line - 1);
        const line = lines.items[at];
        const after = afterName(line, d.name) orelse {
            try skipped.append(a, .{ .id = d.id, .line = d.line, .why = "its line does not begin it" });
            continue;
        };
        const k = first + ids.items.len;
        const call = try std.fmt.allocPrint(a, "{s}({d})", .{ hit_name, k });
        // where the signature ends: the line its parameters close on, else its own line
        var sig_end = at;
        var p = after;
        while (p < line.len and (line[p] == ' ' or line[p] == '\t')) p += 1;
        if (p < line.len and line[p] == '(') {
            var depth: i64 = 0;
            var row = at;
            var col = p;
            var q: u8 = 0;
            var closed = false;
            var rest_has_code = false;
            while (row < lines.items.len and !closed) : (row += 1) {
                const l = lines.items[row];
                const end = codeEnd(l);
                while (col < end) : (col += 1) {
                    const ch = l[col];
                    if (q != 0) {
                        if (ch == q) q = 0;
                        continue;
                    }
                    switch (ch) {
                        '"', '\'', '`' => q = ch,
                        '(' => depth += 1,
                        ')' => {
                            depth -= 1;
                            if (depth == 0) {
                                closed = true;
                                sig_end = row;
                                rest_has_code = std.mem.trim(u8, l[col + 1 .. end], " \t\r").len > 0;
                                break;
                            }
                        },
                        else => {},
                    }
                }
                col = 0;
            }
            if (!closed) {
                try skipped.append(a, .{ .id = d.id, .line = d.line, .why = "its signature does not close" });
                continue;
            }
            if (rest_has_code) {
                try skipped.append(a, .{ .id = d.id, .line = d.line, .why = "its body begins on the line of its signature" });
                continue;
            }
        }
        // the call before the first statement of the body
        var row = sig_end + 1;
        var in_block = false;
        var found: ?usize = null;
        while (row < lines.items.len) : (row += 1) {
            const l = lines.items[row];
            const t = std.mem.trim(u8, l, " \t\r");
            if (in_block) {
                if (std.mem.indexOf(u8, t, "*/") != null) in_block = false;
                continue;
            }
            if (t.len == 0 or t[0] == '#' or std.mem.startsWith(u8, t, "//")) continue;
            if (std.mem.startsWith(u8, t, "/*")) {
                if (std.mem.indexOf(u8, t[2..], "*/") == null) in_block = true;
                continue;
            }
            found = row;
            break;
        }
        const r = found orelse {
            try skipped.append(a, .{ .id = d.id, .line = d.line, .why = "it has no body" });
            continue;
        };
        const rl: i64 = @intCast(r + 1);
        if (std.mem.indexOfScalar(i64, starts, rl) != null) {
            try skipped.append(a, .{ .id = d.id, .line = d.line, .why = "its body begins where another definition does" });
            continue;
        }
        const l = lines.items[r];
        var w: usize = 0;
        while (w < l.len and (l[w] == ' ' or l[w] == '\t')) w += 1;
        lines.items[r] = try std.mem.concat(a, u8, &.{ l[0..w], call, " ", l[w..] });
        try ids.append(a, d.id);
    }

    // the older syntax: the load at the start of the first line, after a byte-order mark; no line moves
    if (place == .first_line and lines.items.len > 0) {
        const l0 = lines.items[0];
        const bom: usize = if (std.mem.startsWith(u8, l0, "\xEF\xBB\xBF")) 3 else 0;
        var ld = T.Buf.init(a);
        try ld.s(l0[0..bom]);
        try ld.s("load ");
        try ld.js(probe_path);
        try ld.c(' ');
        try ld.s(l0[bom..]);
        lines.items[0] = try ld.done();
    }

    const eol: []const u8 = if (crlf) "\r\n" else "\n";
    var b = T.Buf.init(a);
    for (lines.items, 0..) |l, i| {
        try b.s(l);
        // a piece split at `\n` keeps its `\r`; the last line of a source without a line end gets one
        if (i + 1 < lines.items.len or ends_nl) {
            try b.c('\n');
        } else {
            try b.s(eol);
        }
    }
    if (place == .last_line) {
        try b.s("load ");
        try b.js(probe_path);
        try b.s(eol);
    }
    return .{ .text = try b.done(), .ids = ids.items, .skipped = skipped.items };
}

/// The probe file: TestoorProbeHit, set up on its first call with the ids by number
pub fn probeSource(a: Allocator, ids: []const []const u8, crlf: bool) ![]u8 {
    const nl: []const u8 = if (crlf) "\r\n" else "\n";
    var b = T.Buf.init(a);
    const head = [_][]const u8{
        "# Written by testoor probe (TESTOOR_PROTOCOL_3.md section 6.8): which of this codebase's functions a tour reached.",
        "# Each probed function calls TestoorProbeHit with its number first. The first call of each, in each process, appends",
        "# one line `[testoor node ID]` to the file TESTOOR_NODES names; with no such variable nothing is written. Set up on",
        "# its first call, since a file's own statements may run a function before this file is loaded.",
        "",
    };
    for (head) |h| {
        try b.s(h);
        try b.s(nl);
    }
    try b.s("func " ++ hit_name ++ "(nK)");
    try b.s(nl);
    try b.s("\tif not IsGlobal(\"$vTestoorProbeSeen\")");
    try b.s(nl);
    try b.s("\t\t$vTestoorProbeIds = [");
    try b.s(nl);
    for (ids, 0..) |id, i| {
        try b.s("\t\t\t");
        try b.js(id);
        if (i + 1 < ids.len) try b.c(',');
        try b.s(nl);
    }
    try b.s("\t\t]");
    try b.s(nl);
    try b.s("\t\t$vTestoorProbeSeen = [");
    for (ids, 0..) |_, i| {
        if (i > 0) try b.s(", ");
        try b.c('0');
    }
    try b.s("]");
    try b.s(nl);
    const tail = [_][]const u8{
        "\t\t$tTestoorProbeFile = SysGet(\"TESTOOR_NODES\")",
        "\tend",
        "\tif $vTestoorProbeSeen[nK] = 0",
        "\t\t$vTestoorProbeSeen[nK] = 1",
        "\t\tif $tTestoorProbeFile != \"\"",
        "\t\t\thTestoorProbe = FOpen($tTestoorProbeFile, \"a\")",
        "\t\t\tFWrite(hTestoorProbe, \"[testoor node \" + $vTestoorProbeIds[nK] + \"]\" + Char(10))",
        "\t\t\tFClose(hTestoorProbe)",
        "\t\tend",
        "\tend",
        "end",
    };
    for (tail) |t| {
        try b.s(t);
        try b.s(nl);
    }
    return b.done();
}

/// a definition of the codebase, with the file it is in, relative to the folder probed
pub const Own = struct { def: Def, file: []const u8 };

/// THE PROBE'S RECORD: the graph record of the codebase's own functions and methods, and of each of its files' own
/// statements that call something (`<top>:FILE`, never observed, run by every tour that loads the file), cut from the record of a unit that
/// loads every file of the folder. A file read alone by haro graph names no call into another file -- a call of one module's
/// function in another left no line, measured 2026-11-15 -- so the edges come from the unit, where every call is resolved; the
/// nodes are the codebase's own, each with the file and line its own file gave, and an edge is kept when both of its ends
/// are. `complete` and `why` are the unit's: a call the unit could not resolve, in the library or not, leaves the codebase's
/// reach unknown too, and the record says so.
pub fn ownRecord(a: Allocator, unit_record: []const u8, own: []const Own, files: []const []const u8, subject: []const u8) ![]u8 {
    const g = try G.fromValue(a, try J.parse(a, unit_record));
    var keep = std.StringHashMap(void).init(a);
    for (own) |o| try keep.put(try T.lowerAscii(a, o.def.id), {});
    // a file's own statements, `<top>:FILE`, for each file of the folder: the probe observes them not, and every tour
    // that loads the file runs them, so what they call is bound for every tour (testoor_recall.zig)
    var folder_files = std.StringHashMap(void).init(a);
    for (files) |f| try folder_files.put(try T.lowerAscii(a, try slashes(a, f)), {});
    var tops: std.ArrayList(usize) = .empty;
    for (g.nodes, 0..) |n, i| {
        if (!G.isTop(n) or !folder_files.contains(try T.lowerAscii(a, n.file))) continue;
        try tops.append(a, i);
        try keep.put(try T.lowerAscii(a, n.id), {});
    }
    var b = T.Buf.init(a);
    try b.s("{\"testoor\":\"graph\",\"protocol\":2,\"subject\":");
    try b.js(subject);
    try b.s(",\"language\":\"haro\",\"fold\":\"ascii\",\"complete\":");
    try b.s(if (g.complete) "true" else "false");
    try b.s(",\"why\":");
    try b.js(g.why);
    try b.s(",\"nodes\":[");
    var first = true;
    var written = std.StringHashMap(void).init(a);
    for (own) |o| {
        const k = try T.lowerAscii(a, o.def.id);
        // a name defined in two files is one node, as haro.exe keeps the first definition
        if (written.contains(k)) continue;
        try written.put(k, {});
        const at = g.indexOf(o.def.id);
        if (!first) try b.c(',');
        first = false;
        try b.s("{\"id\":");
        try b.js(if (at) |i| g.nodes[i].id else o.def.id);
        try b.s(",\"name\":");
        try b.js(o.def.name);
        try b.s(",\"kind\":");
        try b.js(o.def.kind);
        try b.s(",\"file\":");
        try b.js(o.file);
        try b.s(",\"line\":");
        try b.int(o.def.line);
        if (at) |i| {
            if (g.nodes[i].open) try b.s(",\"open\":true");
        }
        try b.c('}');
    }
    for (tops.items) |i| {
        const n = g.nodes[i];
        if (!first) try b.c(',');
        first = false;
        try b.s("{\"id\":");
        try b.js(n.id);
        try b.s(",\"name\":\"<top>\",\"kind\":\"top\",\"file\":");
        try b.js(n.file);
        try b.s(",\"line\":0");
        if (n.open) try b.s(",\"open\":true");
        try b.c('}');
    }
    try b.s("],\"edges\":[");
    first = true;
    for (g.edges) |e| {
        if (!keep.contains(try T.lowerAscii(a, e.from)) or !keep.contains(try T.lowerAscii(a, e.to))) continue;
        if (!first) try b.c(',');
        first = false;
        try b.s("{\"from\":");
        try b.js(e.from);
        try b.s(",\"to\":");
        try b.js(e.to);
        try b.s(",\"kind\":");
        try b.js(e.kind);
        try b.s(",\"line\":0}");
    }
    try b.s("]}\n");
    return b.done();
}

fn slashes(a: Allocator, p: []const u8) ![]u8 {
    const out = try a.dupe(u8, p);
    for (out) |*c| if (c.* == '\\') {
        c.* = '/';
    };
    return out;
}

/// the relative path from folder `from` to the file `to`, both relative to one place and written with forward slashes
pub fn relPath(a: Allocator, from: []const u8, to: []const u8) ![]u8 {
    var fp: std.ArrayList([]const u8) = .empty;
    var tp: std.ArrayList([]const u8) = .empty;
    var it_from = std.mem.tokenizeAny(u8, from, "/\\");
    while (it_from.next()) |s| if (!std.mem.eql(u8, s, ".")) try fp.append(a, s);
    var it_to = std.mem.tokenizeAny(u8, to, "/\\");
    while (it_to.next()) |s| if (!std.mem.eql(u8, s, ".")) try tp.append(a, s);
    var common: usize = 0;
    while (common < fp.items.len and common + 1 < tp.items.len and std.mem.eql(u8, fp.items[common], tp.items[common])) common += 1;
    var b = T.Buf.init(a);
    for (fp.items[common..]) |_| try b.s("../");
    for (tp.items[common..], 0..) |s, k| {
        if (k > 0) try b.c('/');
        try b.s(s);
    }
    return b.done();
}

// ── tests ────────────────────────────────────────────────────

const testing = std.testing;

test "the first block is the file asked about: its definitions, the lines they begin on, its unfinished" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const b = try firstBlock(a, "FILE|inv.haro\nFUNC|Gross|3\nCLASS|Box||9\nMETHOD|Box|Area|11\nUNFINISHED|Gross\nCALL|Gross|Vat|static\nFILE|lib.haro\nFUNC|Vat|1\n");
    try testing.expectEqual(@as(usize, 2), b.defs.len);
    try testing.expectEqualStrings("Box.Area", b.defs[1].id);
    try testing.expectEqualStrings("Area", b.defs[1].name);
    try testing.expectEqual(@as(usize, 3), b.starts.len);
    try testing.expectEqual(@as(usize, 1), b.unfinished.len);
    try testing.expectEqual(@as(usize, 5), b.lines.len);
}

test "a call in each definition, and no line moves" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const src = "# inv\nfunc Gross(nX) # the gross\n\treturn nX * 1.2\nend\n\nfunc Rate(nA,\n\tnB)\n\treturn nA\nend\nclass Box\n\tdef Area\n\t\t# the area\n\n\t\treturn 4\n\tend\n\tdef Empty\n\tend\nend\n";
    const defs = [_]Def{
        .{ .id = "Gross", .name = "Gross", .line = 2 },
        .{ .id = "Rate", .name = "Rate", .line = 6 },
        .{ .id = "Box.Area", .name = "Area", .line = 11 },
        .{ .id = "Box.Empty", .name = "Empty", .line = 16 },
    };
    const r = try instrument(a, src, &defs, &.{ 2, 6, 10, 11, 16 }, 5, "../_testoor_probe.haro", .last_line);
    try testing.expectEqual(@as(usize, 4), r.ids.len);
    try testing.expectEqual(@as(usize, 0), r.skipped.len);
    try testing.expectEqualStrings("# inv\nfunc Gross(nX) # the gross\n\tTestoorProbeHit(5) return nX * 1.2\nend\n\nfunc Rate(nA,\n\tnB)\n\tTestoorProbeHit(6) return nA\nend\nclass Box\n\tdef Area\n\t\t# the area\n\n\t\tTestoorProbeHit(7) return 4\n\tend\n\tdef Empty\n\tTestoorProbeHit(8) end\nend\nload \"../_testoor_probe.haro\"\n", r.text);
}

test "a definition the probe cannot place a call in is named, never guessed" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const src = "func F(nX\nfunc G\nfunc H\n\treturn 1\nend\nx = 1\n";
    const defs = [_]Def{
        .{ .id = "F", .name = "F", .line = 1 },
        .{ .id = "G", .name = "G", .line = 2 },
        .{ .id = "Q", .name = "Q", .line = 6 },
        .{ .id = "Z", .name = "Z", .line = 40 },
    };
    const r = try instrument(a, src, &defs, &.{ 1, 2, 3 }, 1, "_testoor_probe.haro", .last_line);
    try testing.expectEqual(@as(usize, 0), r.ids.len);
    try testing.expectEqual(@as(usize, 4), r.skipped.len);
    try testing.expectEqualStrings("its signature does not close", r.skipped[0].why);
    try testing.expectEqualStrings("its body begins where another definition does", r.skipped[1].why);
    try testing.expectEqualStrings("its line does not begin it", r.skipped[2].why);
    try testing.expectEqualStrings("its line is not in the file", r.skipped[3].why);
}

test "a file's line ends are kept, and one without a last line end gets one before the load" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const defs = [_]Def{.{ .id = "F", .name = "F", .line = 1 }};
    const r = try instrument(a, "func F(nX)\r\n\treturn nX\r\nend", &defs, &.{1}, 1, "_testoor_probe.haro", .last_line);
    try testing.expectEqualStrings("func F(nX)\r\n\tTestoorProbeHit(1) return nX\r\nend\r\nload \"_testoor_probe.haro\"\r\n", r.text);
}

test "a parenthesis in a string or a comment of the signature is not the one that closes it" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const defs = [_]Def{.{ .id = "F", .name = "F", .line = 1 }};
    const r = try instrument(a, "func F(tA = \")\") # (\n\treturn tA\nend\n", &defs, &.{1}, 1, "p.haro", .last_line);
    try testing.expectEqualStrings("func F(tA = \")\") # (\n\tTestoorProbeHit(1) return tA\nend\nload \"p.haro\"\n", r.text);
}

test "a body that begins on the line of its signature is not probed, and is named" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const defs = [_]Def{ .{ .id = "One", .name = "One", .line = 1 }, .{ .id = "Two", .name = "Two", .line = 3 } };
    const r = try instrument(a, "func One(nX) return nX\nend\nfunc Two(nX) # a comment is no body\n\treturn nX\nend\n", &defs, &.{ 1, 3 }, 1, "p.haro", .last_line);
    try testing.expectEqual(@as(usize, 1), r.ids.len);
    try testing.expectEqualStrings("Two", r.ids[0]);
    try testing.expectEqual(@as(usize, 1), r.skipped.len);
    try testing.expectEqualStrings("its body begins on the line of its signature", r.skipped[0].why);
    try testing.expectEqualStrings("func One(nX) return nX\nend\nfunc Two(nX) # a comment is no body\n\tTestoorProbeHit(1) return nX\nend\nload \"p.haro\"\n", r.text);
}

test "a file of the older syntax takes the load at the start of its first line, after a byte-order mark, and no line moves" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const defs = [_]Def{ .{ .id = "F", .name = "F", .line = 2 }, .{ .id = "A.g", .name = "g", .line = 6 } };
    const src = "\xEF\xBB\xBF# c\r\nfunc F(nX)\r\n\treturn nX\r\n\r\nclass A\r\n\tdef g\r\n\t\treturn 2\r\n";
    const r = try instrument(a, src, &defs, &.{ 2, 5, 6 }, 1, "../p.haro", .first_line);
    try testing.expectEqual(@as(usize, 2), r.ids.len);
    try testing.expectEqualStrings("\xEF\xBB\xBFload \"../p.haro\" # c\r\nfunc F(nX)\r\n\tTestoorProbeHit(1) return nX\r\n\r\nclass A\r\n\tdef g\r\n\t\tTestoorProbeHit(2) return 2\r\n", r.text);
    // a definition on line 1: the load goes before it, and the call still finds its body
    const d1 = [_]Def{.{ .id = "E", .name = "E", .line = 1 }};
    const r1 = try instrument(a, "func E(pcError)\n\treturn pcError\n", &d1, &.{1}, 7, "p.haro", .first_line);
    try testing.expectEqualStrings("load \"p.haro\" func E(pcError)\n\tTestoorProbeHit(7) return pcError\n", r1.text);
    try testing.expectEqual(Place.last_line, placeFor("a/b.haro"));
    try testing.expectEqual(Place.last_line, placeFor("B.HARO"));
    try testing.expectEqual(Place.first_line, placeFor("m.old"));
}

test "the path to the probe file, from a file's folder" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    try testing.expectEqualStrings("_testoor_probe.haro", try relPath(a, "", "_testoor_probe.haro"));
    try testing.expectEqualStrings("../_testoor_probe.haro", try relPath(a, "sub", "_testoor_probe.haro"));
    try testing.expectEqualStrings("../../_testoor_probe.haro", try relPath(a, "a/b", "_testoor_probe.haro"));
}

test "the probe file numbers the ids as the calls do" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const s = try probeSource(a, &.{ "Gross", "Box.Area" }, false);
    try testing.expect(std.mem.indexOf(u8, s, "func TestoorProbeHit(nK)\n") != null);
    try testing.expect(std.mem.indexOf(u8, s, "\t\t\t\"Gross\",\n\t\t\t\"Box.Area\"\n\t\t]\n\t\t$vTestoorProbeSeen = [0, 0]\n") != null);
}
