//! Testoor core -- the Haro face's GRAPH: what `haro graph FILE` prints, read into the graph record the core judges by
//! (TESTOOR_PROTOCOL_2.md section 2, TESTOOR_PROTOCOL_3.md section 5). The first of the pieces the evidence report on a
//! codebase that is not the library needs (BUSINESS-LEADS-DELIVER-01, A1 (1)): with it, the ladder can name the functions no
//! tour reached, and an impact can be computed over a Haro unit.
//!
//! haro.exe resolves the unit (D:\GitHub\haro\vm\src\graph.zig) and prints one line a fact; this module reads those lines and
//! never the source:
//!
//!   FILE|path                      the file the following lines belong to; the first one is the record's subject
//!   FUNC|name|line                 a node `name`, kind function
//!   METHOD|class|name|line         a node `class.name`, kind method, named `name`
//!   CALL|from|to|static            an edge, kind call: the compiler bound the call to that one function
//!   CALL|from|name|dynamic|n       an edge, kind dispatch, to EVERY method of the unit named `name` -- the compiler could only
//!                                  dispatch it by name, so each candidate is a callee. Exact as a set of possible callees, and
//!                                  the graph stays complete; measured on a Foundry guard's unit (2026-11-15): 8,769 such calls
//!                                  over 2,342 names make 129,943 edges beside 66,951 static ones. A name no method carries is
//!                                  a callee nobody can name: its caller is OPEN
//!   UNFINISHED|function            the compiler could not finish it, so its calls are MISSING: the node is OPEN
//!   CLASS, IMPORT, the summary     not nodes; read past
//!
//! A CALL BY A NAME BUILT AT RUN TIME -- `call tName()`, `eval(...)` -- left no line in haro graph until v0.77, which prints
//! `CALL|caller|*|late|n` for `call` (HARO-GRAPH-LATECALL-01): the face reads that line as the caller open, with no edge, and
//! still reads the files, since `eval` has no such line. Before v0.77 a call by a name built at run time left no line, and a graph that missed one
//! would say complete with a hole in it. So the face reads each file of the unit (given its folder), and a function whose code
//! holds one is OPEN, as protocol 2 section 2 says: "dispatches by a name built at run time". A file it cannot read, or a run
//! that gives it no folder, leaves the graph not complete, saying why: it never certifies what it did not read. Strings and
//! comments are skipped, a string over as many lines as it runs; a `.call` is a method's name, not the keyword, and
//! `def Eval(` is a definition, not a call. Asked of haro.exe too (HARO-GRAPH-LATECALL-01). Measured on a Foundry guard's
//! unit (2026-11-27): the late lines open 117 functions, every one of them among the files' reading, and the files open 42
//! more, each one an `eval` caller -- so the files are read for as long as `eval` has no line of its own.
//!
//! `<top>`, a file's own statements, is a node `<top>:FILE` of kind top, made when it first calls something. Ids are compared
//! folded to ASCII lower case (`fold: ascii`), since the unit's .ring files fold case; an edge is written in its node's
//! spelling. A path is written with forward slashes and its `.` and `..` resolved.
//!
//! Imports no Ring.

const std = @import("std");
const Allocator = std.mem.Allocator;
const T = @import("testoor_text.zig");

const Node = struct {
    id: []const u8,
    name: []const u8,
    kind: []const u8,
    file: []const u8,
    line: i64,
    open: bool = false,
};

const Edge = struct { from: []const u8, to: []const u8, kind: []const u8 };

const Call = struct { from: []const u8, to: []const u8, dynamic: bool };

/// where a definition begins in its file: a function's or method's node, or a class (null), whose body is no function's
const Def = struct { line: i64, node: ?usize };

const File = struct { raw: []const u8, norm: []const u8, defs: std.ArrayList(Def) = .empty };

fn isWord(ch: u8) bool {
    return std.ascii.isAlphanumeric(ch) or ch == '_';
}

/// what the reading of a file carries from one line to the next: a /* comment, or a string not yet closed. A literal of
/// any of the three forms runs over lines to its own delimiter, with no escape (a `\` is a character like any other), as
/// the compiler reads it: a program held in a string -- a Python one is, in a .ring file of the library -- is text, not
/// code. Until 2026-11-27 a string ended with its line, and that program's `eval(obj)` opened the file's statements
pub const Scan = struct { block: bool = false, q: u8 = 0 };

/// does this line of code call by a name built at run time? `st` carries a /* comment and an open string across lines,
/// and the whole line is read after a hit, so what it opens is carried. A definition's own name is not a call:
/// `def Eval(pnX)` declares a method named Eval (until 2026-11-27 it opened that method)
pub fn lateCall(line: []const u8, st: *Scan) bool {
    var hit = false;
    var decl = false;
    var i: usize = 0;
    while (i < line.len) : (i += 1) {
        const ch = line[i];
        if (st.block) {
            if (ch == '*' and i + 1 < line.len and line[i + 1] == '/') {
                st.block = false;
                i += 1;
            }
            continue;
        }
        if (st.q != 0) {
            if (ch == st.q) st.q = 0;
            continue;
        }
        switch (ch) {
            '"', '\'', '`' => st.q = ch,
            '#' => return hit,
            '/' => {
                if (i + 1 < line.len and line[i + 1] == '/') return hit;
                if (i + 1 < line.len and line[i + 1] == '*') {
                    st.block = true;
                    i += 1;
                }
            },
            else => {
                if (!std.ascii.isAlphabetic(ch) or (i > 0 and (isWord(line[i - 1]) or line[i - 1] == '.'))) continue;
                var j = i;
                while (j < line.len and isWord(line[j])) j += 1;
                const w = line[i..j];
                if (!decl) {
                    if (std.ascii.eqlIgnoreCase(w, "call") and j < line.len and (line[j] == ' ' or line[j] == '\t')) hit = true;
                    if (std.ascii.eqlIgnoreCase(w, "eval")) {
                        var k = j;
                        while (k < line.len and (line[k] == ' ' or line[k] == '\t')) k += 1;
                        if (k < line.len and line[k] == '(') hit = true;
                    }
                }
                decl = std.ascii.eqlIgnoreCase(w, "def") or std.ascii.eqlIgnoreCase(w, "func");
                i = j - 1;
            },
        }
    }
    return hit;
}

/// a path with forward slashes, `.` dropped and `..` taken back where it can be
pub fn normPath(a: Allocator, p: []const u8) ![]const u8 {
    var parts: std.ArrayList([]const u8) = .empty;
    var it = std.mem.tokenizeAny(u8, p, "/\\");
    while (it.next()) |seg| {
        if (std.mem.eql(u8, seg, ".")) continue;
        if (std.mem.eql(u8, seg, "..") and parts.items.len > 0 and !std.mem.eql(u8, parts.items[parts.items.len - 1], "..")) {
            _ = parts.pop();
            continue;
        }
        try parts.append(a, seg);
    }
    return std.mem.join(a, "/", parts.items);
}

fn fold(a: Allocator, s: []const u8) ![]const u8 {
    return T.lowerAscii(a, s);
}

fn field(fs: []const []const u8, i: usize) []const u8 {
    return if (i < fs.len) fs[i] else "";
}

fn lineNo(s: []const u8) i64 {
    return std.fmt.parseInt(i64, T.trimSp(s), 10) catch 0;
}

/// haro graph's lines in, the graph record out (one JSON line, a line feed after it). `root` is the folder haro graph ran in,
/// where the unit's files are read for calls by a name built at run time; null reads none, and the record says so
pub fn fromLines(a: Allocator, text: []const u8, root: ?[]const u8) ![]u8 {
    return fromLinesWith(a, text, root, .{});
}

/// what a caller may ask of the record beyond what the lines say
pub const Opts = struct {
    /// the record's subject, when it is not the first file (testoor probe: the folder probed)
    subject: ?[]const u8 = null,
    /// false: a file's own statements are no node -- their calls and their calls by a built name are read past. The probe's
    /// record holds what the probe observes, and it observes functions and methods (testoor_probe.zig)
    tops: bool = true,
};

pub fn fromLinesWith(a: Allocator, text: []const u8, root: ?[]const u8, opts: Opts) ![]u8 {
    var nodes: std.ArrayList(Node) = .empty;
    var index = std.StringHashMap(usize).init(a);
    var by_name = std.StringHashMap(std.ArrayList(usize)).init(a);
    var calls: std.ArrayList(Call) = .empty;
    // `CALL|caller|*|late|n` (haro v0.77, HARO-GRAPH-LATECALL-01): the caller holds n calls by a name built at run time
    var late_callers: std.ArrayList([]const u8) = .empty;
    var unfinished: std.ArrayList([]const u8) = .empty;
    var subject: []const u8 = "";
    var file: []const u8 = "";
    var files: std.ArrayList(File) = .empty;

    const add = struct {
        fn node(al: Allocator, ns: *std.ArrayList(Node), ix: *std.StringHashMap(usize), n: Node) !void {
            const k = try fold(al, n.id);
            if (ix.contains(k)) return; // a name defined twice: the first stands, as the graph's order says
            try ix.put(k, ns.items.len);
            try ns.append(al, n);
        }
    };

    var lines = std.mem.splitScalar(u8, text, '\n');
    while (lines.next()) |raw| {
        const ln = std.mem.trimRight(u8, raw, "\r");
        var fs: std.ArrayList([]const u8) = .empty;
        var it = std.mem.splitScalar(u8, ln, '|');
        while (it.next()) |f| try fs.append(a, f);
        const tag = field(fs.items, 0);
        if (std.mem.eql(u8, tag, "FILE")) {
            file = try normPath(a, field(fs.items, 1));
            if (subject.len == 0) subject = file;
            try files.append(a, .{ .raw = field(fs.items, 1), .norm = file });
        } else if (std.mem.eql(u8, tag, "CLASS")) {
            if (files.items.len > 0) try files.items[files.items.len - 1].defs.append(a, .{ .line = lineNo(field(fs.items, 3)), .node = null });
        } else if (std.mem.eql(u8, tag, "FUNC")) {
            const name = field(fs.items, 1);
            try add.node(a, &nodes, &index, .{ .id = name, .name = name, .kind = "function", .file = file, .line = lineNo(field(fs.items, 2)) });
            if (files.items.len > 0) try files.items[files.items.len - 1].defs.append(a, .{ .line = lineNo(field(fs.items, 2)), .node = index.get(try fold(a, name)) });
        } else if (std.mem.eql(u8, tag, "METHOD")) {
            const name = field(fs.items, 2);
            const id = try std.mem.concat(a, u8, &.{ field(fs.items, 1), ".", name });
            const before = nodes.items.len;
            try add.node(a, &nodes, &index, .{ .id = id, .name = name, .kind = "method", .file = file, .line = lineNo(field(fs.items, 3)) });
            if (nodes.items.len > before) {
                const k = try fold(a, name);
                const gop = try by_name.getOrPut(k);
                if (!gop.found_existing) gop.value_ptr.* = .empty;
                try gop.value_ptr.append(a, before);
            }
            if (files.items.len > 0) try files.items[files.items.len - 1].defs.append(a, .{ .line = lineNo(field(fs.items, 3)), .node = index.get(try fold(a, id)) });
        } else if (std.mem.eql(u8, tag, "UNFINISHED")) {
            try unfinished.append(a, field(fs.items, 1));
        } else if (std.mem.eql(u8, tag, "CALL")) {
            var from = field(fs.items, 1);
            if (std.mem.eql(u8, from, "<top>")) {
                if (!opts.tops) continue;
                from = try std.mem.concat(a, u8, &.{ "<top>:", file });
                try add.node(a, &nodes, &index, .{ .id = from, .name = "<top>", .kind = "top", .file = file, .line = 0 });
            }
            // a call by a name built at run time names no callee: no edge, the caller open
            if (std.mem.eql(u8, field(fs.items, 3), "late")) {
                try late_callers.append(a, from);
                continue;
            }
            try calls.append(a, .{ .from = from, .to = field(fs.items, 2), .dynamic = std.mem.eql(u8, field(fs.items, 3), "dynamic") });
        }
    }

    // the edges, each end in its node's spelling; a dispatch to every method of the name
    var edges: std.ArrayList(Edge) = .empty;
    var no_callee: usize = 0;
    for (calls.items) |c| {
        const from = if (index.get(try fold(a, c.from))) |i| nodes.items[i].id else c.from;
        if (!c.dynamic) {
            const to = if (index.get(try fold(a, c.to))) |i| nodes.items[i].id else c.to;
            try edges.append(a, .{ .from = from, .to = to, .kind = "call" });
            continue;
        }
        if (by_name.get(try fold(a, c.to))) |cands| {
            for (cands.items) |i| try edges.append(a, .{ .from = from, .to = nodes.items[i].id, .kind = "dispatch" });
        } else if (index.get(try fold(a, c.from))) |i| {
            if (!nodes.items[i].open) no_callee += 1;
            nodes.items[i].open = true;
        }
    }
    var first_unfinished: []const u8 = "";
    var n_unfinished: usize = 0;
    for (unfinished.items) |u| {
        if (index.get(try fold(a, u))) |i| {
            if (n_unfinished == 0) first_unfinished = nodes.items[i].id;
            n_unfinished += 1;
            nodes.items[i].open = true;
        }
    }

    // calls by a name built at run time, read from the unit's files
    var n_late: usize = 0;
    var first_late: []const u8 = "";
    var unread: usize = 0;
    var unclosed: usize = 0;
    var first_unclosed: []const u8 = "";
    // the ones haro graph names (v0.77 on): each caller open, counted once with what the files' reading below finds
    for (late_callers.items) |c| {
        const i = index.get(try fold(a, c)) orelse continue;
        if (!nodes.items[i].open) {
            if (n_late == 0) first_late = try std.fmt.allocPrint(a, "{s} ({s})", .{ nodes.items[i].id, nodes.items[i].file });
            n_late += 1;
        }
        nodes.items[i].open = true;
    }
    if (root) |r| {
        for (files.items) |f| {
            const path = try std.fs.path.join(a, &.{ r, f.raw });
            const src = std.fs.cwd().readFileAlloc(a, path, 256 * 1024 * 1024) catch {
                unread += 1;
                continue;
            };
            var st: Scan = .{};
            var no: i64 = 0;
            var it = std.mem.splitScalar(u8, src, '\n');
            while (it.next()) |raw| {
                no += 1;
                if (!lateCall(raw, &st)) continue;
                // the definition the line is in: the last one beginning at or before it. Before any, or in a class's own
                // body, the line is the file's own statements
                var owner: ?usize = null;
                for (f.defs.items) |d| {
                    if (d.line > no) break;
                    owner = d.node;
                }
                if (owner == null and !opts.tops) continue;
                const at = if (owner) |o| o else blk: {
                    const tid = try std.mem.concat(a, u8, &.{ "<top>:", f.norm });
                    try add.node(a, &nodes, &index, .{ .id = tid, .name = "<top>", .kind = "top", .file = f.norm, .line = 0 });
                    break :blk index.get(try fold(a, tid)).?;
                };
                if (!nodes.items[at].open) {
                    if (n_late == 0) first_late = try std.fmt.allocPrint(a, "{s} ({s}, line {d})", .{ nodes.items[at].id, f.norm, no });
                    n_late += 1;
                }
                nodes.items[at].open = true;
            }
            // the compiler refuses a string that never closes, so a reading that ends inside one read the file otherwise
            // than the compiler did, and what followed the quote it took for an opening went unread
            if (st.q != 0) {
                if (unclosed == 0) first_unclosed = f.norm;
                unclosed += 1;
            }
        }
    }

    var why: std.ArrayList(u8) = .empty;
    if (n_unfinished == 1) {
        try why.appendSlice(a, try std.fmt.allocPrint(a, "1 function the compiler could not finish, its calls missing: {s}", .{first_unfinished}));
    } else if (n_unfinished > 1) {
        try why.appendSlice(a, try std.fmt.allocPrint(a, "{d} functions the compiler could not finish, their calls missing; the first: {s}", .{ n_unfinished, first_unfinished }));
    }
    if (no_callee > 0) {
        if (why.items.len > 0) try why.appendSlice(a, "; ");
        try why.appendSlice(a, try std.fmt.allocPrint(a, "{d} function(s) calling a method by a name no method of the unit carries", .{no_callee}));
    }
    if (n_late > 0) {
        if (why.items.len > 0) try why.appendSlice(a, "; ");
        try why.appendSlice(a, try std.fmt.allocPrint(a, "{d} node(s) dispatching by a name built at run time; the first: {s}", .{ n_late, first_late }));
    }
    if (root == null) {
        if (why.items.len > 0) try why.appendSlice(a, "; ");
        try why.appendSlice(a, "calls by a name built at run time not looked for: the unit's files were not read");
    } else if (unread > 0) {
        if (why.items.len > 0) try why.appendSlice(a, "; ");
        try why.appendSlice(a, try std.fmt.allocPrint(a, "{d} file(s) of the unit could not be read for calls by a name built at run time", .{unread}));
    }
    if (unclosed > 0) {
        if (why.items.len > 0) try why.appendSlice(a, "; ");
        try why.appendSlice(a, try std.fmt.allocPrint(a, "{d} file(s) whose reading ended inside a string, so what follows the quote that opened it was not read as code; the first: {s}", .{ unclosed, first_unclosed }));
    }

    var b = T.Buf.init(a);
    try b.s("{\"testoor\":\"graph\",\"protocol\":2,\"subject\":");
    try b.js(opts.subject orelse subject);
    try b.s(",\"language\":\"haro\",\"fold\":\"ascii\",\"complete\":");
    try b.s(if (why.items.len == 0) "true" else "false");
    try b.s(",\"why\":");
    try b.js(why.items);
    try b.s(",\"nodes\":[");
    for (nodes.items, 0..) |n, k| {
        if (k > 0) try b.c(',');
        try b.s("{\"id\":");
        try b.js(n.id);
        try b.s(",\"name\":");
        try b.js(n.name);
        try b.s(",\"kind\":");
        try b.js(n.kind);
        try b.s(",\"file\":");
        try b.js(n.file);
        try b.s(",\"line\":");
        try b.int(n.line);
        if (n.open) try b.s(",\"open\":true");
        try b.c('}');
    }
    try b.s("],\"edges\":[");
    for (edges.items, 0..) |e, k| {
        if (k > 0) try b.c(',');
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

// ── tests ────────────────────────────────────────────────────

const testing = std.testing;

test "a path is written with forward slashes, its . dropped and its .. taken back" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    try testing.expectEqualStrings("lib/money.ring", try normPath(a, ".\\lib/../lib\\money.ring"));
    try testing.expectEqualStrings("../.stzlib/core/x.haro", try normPath(a, ".\\../.stzlib/base\\../core\\x.haro"));
    try testing.expectEqualStrings("inv.haro", try normPath(a, "inv.haro"));
}

test "a call by a name no method carries leaves its caller open, and the graph says why" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const r = try fromLines(a, "FILE|t.haro\nFUNC|Use|1\nCALL|Use|Nowhere|dynamic|0\n", null);
    try testing.expect(std.mem.indexOf(u8, r, "\"complete\":false") != null);
    try testing.expect(std.mem.indexOf(u8, r, "{\"id\":\"Use\",\"name\":\"Use\",\"kind\":\"function\",\"file\":\"t.haro\",\"line\":1,\"open\":true}") != null);
    try testing.expect(std.mem.indexOf(u8, r, "1 function(s) calling a method by a name no method of the unit carries") != null);
    try testing.expect(std.mem.indexOf(u8, r, "\"edges\":[]") != null);
}

test "a unit read from its lines alone is not complete, and a name defined twice keeps its first" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const r = try fromLines(a, "FILE|a.haro\nFUNC|F|1\nFILE|b.ring\nFUNC|f|9\nCALL|<top>|f|static\n", null);
    try testing.expect(std.mem.indexOf(u8, r, "\"complete\":false,\"why\":\"calls by a name built at run time not looked for: the unit's files were not read\"") != null);
    try testing.expect(std.mem.indexOf(u8, r, "\"line\":9") == null);
    try testing.expect(std.mem.indexOf(u8, r, "{\"from\":\"<top>:b.ring\",\"to\":\"F\",\"kind\":\"call\",\"line\":0}") != null);
}

test "a call by a name built at run time is found in code, and never in a string, a comment or a method's name" {
    var b: Scan = .{};
    try testing.expect(lateCall("\treturn call tName(nX)", &b));
    try testing.expect(lateCall("eval(tCode)", &b));
    try testing.expect(lateCall("  x = Eval (t)", &b));
    try testing.expect(!lateCall("? \"call me\"", &b));
    try testing.expect(!lateCall("x = 1 # call it", &b));
    try testing.expect(!lateCall("oX.call(y)", &b));
    try testing.expect(!lateCall("nRecall = 2", &b));
    try testing.expect(!lateCall("/* call x", &b));
    try testing.expect(b.block);
    try testing.expect(!lateCall("still call inside */ y = 1", &b));
    try testing.expect(!b.block);
}

test "A STRING RUNS OVER LINES TO ITS OWN QUOTE, AND A DEFINITION'S NAME IS NO CALL: a program held in a string is text" {
    var b: Scan = .{};
    // a Python program held in a Ring string: its eval is text until the string's own quote closes it
    try testing.expect(!lateCall("$cPy = '", &b));
    try testing.expectEqual(@as(u8, '\''), b.q);
    try testing.expect(!lateCall("        x = eval(obj)", &b));
    try testing.expect(!lateCall("    return \"[\" + x + \"]\"", &b));
    try testing.expect(!lateCall("'", &b));
    try testing.expectEqual(@as(u8, 0), b.q);
    // the line is read to its end after a hit, so a string it opens is carried to the next line
    try testing.expect(lateCall("eval(tCode)  cNext = \"", &b));
    try testing.expectEqual(@as(u8, '"'), b.q);
    try testing.expect(!lateCall("call me, says the text", &b));
    try testing.expect(lateCall("\"  call tName()", &b));
    // a method named Eval, declared, is no call; called, it is still the method, after a dot
    b = .{};
    try testing.expect(!lateCall("\t\tdef Eval(pnX)", &b));
    try testing.expect(!lateCall("func eval (x)", &b));
    try testing.expect(!lateCall("\treturn oPoly.Eval(3)", &b));
    try testing.expect(lateCall("def F(x) eval(x)", &b));
}

test "a file whose reading ends inside a string leaves the graph not complete, naming the file" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var tmp = testing.tmpDir(.{});
    defer tmp.cleanup();
    try tmp.dir.writeFile(.{ .sub_path = "good.ring", .data = "func G()\n\tcPy = '\n\tx = eval(obj)\n'\n\treturn 1\n\nfunc H(t)\n\teval(t)\n" });
    try tmp.dir.writeFile(.{ .sub_path = "open.ring", .data = "func K()\n\t? \"never closed\n" });
    const root = try tmp.dir.realpathAlloc(a, ".");
    const r = try fromLines(a, "FILE|good.ring\nFUNC|G|1\nFUNC|H|7\nFILE|open.ring\nFUNC|K|1\n", root);
    // G holds its eval in a string: not open; H calls eval: open
    try testing.expect(std.mem.indexOf(u8, r, "{\"id\":\"G\",\"name\":\"G\",\"kind\":\"function\",\"file\":\"good.ring\",\"line\":1}") != null);
    try testing.expect(std.mem.indexOf(u8, r, "{\"id\":\"H\",\"name\":\"H\",\"kind\":\"function\",\"file\":\"good.ring\",\"line\":7,\"open\":true}") != null);
    try testing.expect(std.mem.indexOf(u8, r, "\"complete\":false") != null);
    try testing.expect(std.mem.indexOf(u8, r, "1 file(s) whose reading ended inside a string, so what follows the quote that opened it was not read as code; the first: open.ring") != null);
}
