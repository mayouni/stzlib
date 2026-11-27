//! Testoor core -- what a change touched: a unified diff (`git diff`), read into the ids of the graph's nodes its lines
//! fall in (roadmap P4, "selection from a change": an agent asks what its patch reached; TESTOOR_PROTOCOL_3.md 6.7).
//!
//! THE GRAPH IS THE CODE AFTER THE CHANGE -- the code the tours will run -- so a diff is read on its new side. An added
//! line names the definition it stands in; a removed line, the definition the line before it stands in (0, the file's
//! start, when nothing is before it). A definition runs from its own line to the next definition of its file, the rule
//! the Haro face reads the files by (testoor_harograph.zig), so a line is placed as the face placed the calls on it:
//!
//!   in a function or a method          that node
//!   in a class's own body (attributes) every method of the class and of the classes derived from it, as far as they go
//!   before any definition              the file's own statements, `<top>:FILE`, when the graph holds that node
//!   anywhere else                      no node: the record is NOT complete, and `why` names the file and the line
//!
//! A REMOVED DEFINITION is no node of the graph any more. Its callers that called it by its name alone now dispatch to
//! whatever else answers that name, so every node of that name is changed; a caller left with nothing to call is one the
//! compiler could not finish, which the graph already holds open (measured on haro.exe v0.78, 2026-11-27: `Gone(2)` and
//! `This.Missing()` each leave their function UNFINISHED). A file changed that is a tour is selected for itself; a file
//! that is neither the unit's nor a tour is listed, and obliges nothing.
//!
//! A LINE THAT HOLDS NO CODE CHANGES NOTHING -- a comment, a blank line, a line inside a /* comment -- and is counted
//! `quiet`, placed nowhere. Which lines hold code is read from the file's text after the change, when the runner gives it
//! (`texts`), with the face's own rule for strings and comments (testoor_harograph.zig, `holdsCode`): a `#` line inside a
//! string is the string's text, so it is code. A removed line is quiet when its own text reads as a comment and the place
//! it was removed from is in no string, or when that place is inside a /* comment. A file whose text is not given has
//! every changed line taken as code. Measured on 82 commits of stzlib over a Foundry guard's unit (2026-11-27): 769 of the
//! 31,969 changed lines hold no code, and reading them so took the files with a line no node holds from 7 to 3; the 3 left
//! are a file's own statements the graph holds no node for -- global values and `load` lines -- so the record says so.
//!
//! Paths: the diff names a file from the top of its repository (`repo`), the graph from the folder haro graph ran in
//! (`root`), and the two need not be one tree -- a unit loads a library from beside it, `../.stzlib/...`, and the
//! library's diff names `libraries/...`. So each is joined to its own folder and the two compared, `.` and `..` taken
//! back and without regard to ASCII case; the runner hands both folders in absolute (testoor_main.zig). A tour is named
//! by its own path (`at`), on the same footing.
//!
//! Imports no Ring.

const std = @import("std");
const Allocator = std.mem.Allocator;
const G = @import("testoor_graph.zig");
const Hg = @import("testoor_harograph.zig");

/// one file of a diff, as its headers and hunks say
pub const FileChange = struct {
    /// the path before the change, "" when the file is new
    old: []const u8 = "",
    /// the path after, "" when the file is deleted
    new: []const u8 = "",
    hunks: usize = 0,
    /// added and removed lines, counted
    changed: usize = 0,
    /// where each changed line lands on the new side: an added line on its own line, a removed one on the line before it
    at: std.ArrayList(Mark) = .empty,
    /// the definitions a removed line began, and the names an added line began
    removed: std.ArrayList(Removal) = .empty,
    added: std.ArrayList([]const u8) = .empty,
};

/// a changed line: where it lands, whether it was removed, and whether its own text reads as a comment or a blank
pub const Mark = struct { line: i64, removed: bool = false, comment: bool = false };

/// a definition a removed line began: its name, and the mark of that line
pub const Removal = struct { name: []const u8, mark: usize };

/// a file's text after the change, by the path the diff names it with
pub const Text = struct { path: []const u8, text: []const u8 };

/// does a line's own text read as a comment or a blank: nothing but spaces, or a `#` or `//` first
pub fn looksComment(line: []const u8) bool {
    const t = std.mem.trim(u8, line, " \t\r");
    return t.len == 0 or t[0] == '#' or std.mem.startsWith(u8, t, "//");
}

/// the name a line of code defines, when it begins `def`, `func` or `class`: `def Eval(pnX)` is `Eval`
pub fn definedName(line: []const u8) ?[]const u8 {
    const t = std.mem.trimLeft(u8, line, " \t");
    var j: usize = 0;
    while (j < t.len and std.ascii.isAlphabetic(t[j])) j += 1;
    const w = t[0..j];
    if (!(std.ascii.eqlIgnoreCase(w, "def") or std.ascii.eqlIgnoreCase(w, "func") or std.ascii.eqlIgnoreCase(w, "class"))) return null;
    if (j >= t.len or (t[j] != ' ' and t[j] != '\t')) return null;
    while (j < t.len and (t[j] == ' ' or t[j] == '\t')) j += 1;
    const s = j;
    while (j < t.len and (std.ascii.isAlphanumeric(t[j]) or t[j] == '_' or t[j] == '@' or t[j] == '$')) j += 1;
    return if (j > s) t[s..j] else null;
}

/// a header's path: a timestamp after a tab cut, quotes taken off, `/dev/null` read as no file
fn headerPath(raw: []const u8) []const u8 {
    var p = std.mem.trimRight(u8, raw, "\r");
    if (std.mem.indexOfScalar(u8, p, '\t')) |k| p = p[0..k];
    if (p.len >= 2 and p[0] == '"' and p[p.len - 1] == '"') p = p[1 .. p.len - 1];
    return if (std.mem.eql(u8, p, "/dev/null")) "" else p;
}

/// `-a,b` or `+c,d` of a hunk header: the start and the count, a count left out being 1
fn range(s: []const u8) struct { start: i64, count: i64 } {
    const body = s[1..];
    if (std.mem.indexOfScalar(u8, body, ',')) |k| {
        return .{ .start = std.fmt.parseInt(i64, body[0..k], 10) catch 0, .count = std.fmt.parseInt(i64, body[k + 1 ..], 10) catch 0 };
    }
    return .{ .start = std.fmt.parseInt(i64, body, 10) catch 0, .count = 1 };
}

/// git's prefixes taken off when both sides carry them (`a/` before, `b/` after, a missing side counting as either)
fn dropPrefixes(fc: *FileChange) void {
    const a_ok = fc.old.len == 0 or std.mem.startsWith(u8, fc.old, "a/");
    const b_ok = fc.new.len == 0 or std.mem.startsWith(u8, fc.new, "b/");
    if (!(a_ok and b_ok) or (fc.old.len == 0 and fc.new.len == 0)) return;
    if (fc.old.len > 0) fc.old = fc.old[2..];
    if (fc.new.len > 0) fc.new = fc.new[2..];
}

/// A unified diff, read: each file with the new-side lines its changes land on. A hunk is read by its counts, so a
/// removed line that reads `--- x` is a line, never a header.
pub fn parse(a: Allocator, text: []const u8) ![]FileChange {
    var out: std.ArrayList(FileChange) = .empty;
    var pos: i64 = 0;
    var old_left: i64 = 0;
    var new_left: i64 = 0;
    var headed = false; // the current file has had its `+++` line
    var lines = std.mem.splitScalar(u8, text, '\n');
    while (lines.next()) |raw| {
        const ln = std.mem.trimRight(u8, raw, "\r");
        if (old_left > 0 or new_left > 0) {
            if (ln.len == 0) {
                // a context line whose single space an editor took off
                pos += 1;
                old_left -= 1;
                new_left -= 1;
                continue;
            }
            const fc = &out.items[out.items.len - 1];
            switch (ln[0]) {
                ' ' => {
                    pos += 1;
                    old_left -= 1;
                    new_left -= 1;
                },
                '+' => {
                    pos += 1;
                    new_left -= 1;
                    fc.changed += 1;
                    try fc.at.append(a, .{ .line = pos });
                    if (definedName(ln[1..])) |n| try fc.added.append(a, n);
                },
                '-' => {
                    old_left -= 1;
                    fc.changed += 1;
                    try fc.at.append(a, .{ .line = pos, .removed = true, .comment = looksComment(ln[1..]) });
                    if (definedName(ln[1..])) |n| try fc.removed.append(a, .{ .name = n, .mark = fc.at.items.len - 1 });
                },
                '\\' => {}, // "\ No newline at end of file"
                else => {
                    old_left = 0;
                    new_left = 0;
                },
            }
            continue;
        }
        if (std.mem.startsWith(u8, ln, "diff --git ")) {
            try out.append(a, .{});
            headed = false;
            // the paths, when no `---`/`+++` line follows (a rename, a mode change): `a/X b/Y`
            const rest = ln["diff --git ".len..];
            if (std.mem.lastIndexOf(u8, rest, " b/")) |k| {
                out.items[out.items.len - 1].old = rest[0..k];
                out.items[out.items.len - 1].new = rest[k + 1 ..];
            }
        } else if (std.mem.startsWith(u8, ln, "--- ")) {
            if (out.items.len == 0 or headed) {
                try out.append(a, .{});
                headed = false;
            }
            out.items[out.items.len - 1].old = headerPath(ln[4..]);
        } else if (std.mem.startsWith(u8, ln, "+++ ")) {
            if (out.items.len == 0) try out.append(a, .{});
            out.items[out.items.len - 1].new = headerPath(ln[4..]);
            headed = true;
        } else if (std.mem.startsWith(u8, ln, "rename from ") and out.items.len > 0) {
            out.items[out.items.len - 1].old = try std.mem.concat(a, u8, &.{ "a/", headerPath(ln["rename from ".len..]) });
        } else if (std.mem.startsWith(u8, ln, "rename to ") and out.items.len > 0) {
            out.items[out.items.len - 1].new = try std.mem.concat(a, u8, &.{ "b/", headerPath(ln["rename to ".len..]) });
        } else if (std.mem.startsWith(u8, ln, "@@ -") and out.items.len > 0) {
            var it = std.mem.tokenizeScalar(u8, ln[3..], ' ');
            const o = range(it.next() orelse continue);
            const n = range(it.next() orelse continue);
            old_left = o.count;
            new_left = n.count;
            // a hunk that adds no line names the line before the removal; one that does, its first line
            pos = if (n.count == 0) n.start else n.start - 1;
            out.items[out.items.len - 1].hunks += 1;
        }
    }
    for (out.items) |*fc| dropPrefixes(fc);
    return out.items;
}

/// a tour, by its file (as the record lists it) and its path, joined to its folder as `root` and `repo` are
pub const Tour = struct { file: []const u8, at: []const u8 };

pub const Mapping = struct {
    /// the ids the change touched, each once, in the diff's order
    changed: []const []const u8,
    /// empty, or why the selection cannot rest on the graph: a line no node holds
    why: []const u8,
    summary: G.DiffSummary,
};

fn samePath(x: []const u8, y: []const u8) bool {
    return std.ascii.eqlIgnoreCase(x, y);
}

/// a path joined to its folder, as a key paths are compared by
fn key(a: Allocator, base: []const u8, p: []const u8) ![]const u8 {
    if (base.len == 0) return Hg.normPath(a, p);
    return Hg.normPath(a, try std.mem.concat(a, u8, &.{ base, "/", p }));
}

/// the class named, folded
fn sameName(x: []const u8, y: []const u8) bool {
    return std.ascii.eqlIgnoreCase(x, y);
}

/// what a file's text says of each of its lines: whether it holds code, and whether a string or a /* comment is still
/// open after it (index 0: before the first line)
const Lines = struct { code: []bool, in_string: []bool, in_block: []bool };

fn readLines(a: Allocator, text: []const u8) !Lines {
    var n: usize = 1;
    for (text) |ch| {
        if (ch == '\n') n += 1;
    }
    const code = try a.alloc(bool, n + 1);
    const in_string = try a.alloc(bool, n + 1);
    const in_block = try a.alloc(bool, n + 1);
    code[0] = false;
    in_string[0] = false;
    in_block[0] = false;
    var st: Hg.Scan = .{};
    var i: usize = 1;
    var it = std.mem.splitScalar(u8, text, '\n');
    while (it.next()) |ln| : (i += 1) {
        code[i] = Hg.holdsCode(ln, &st);
        in_string[i] = st.q != 0;
        in_block[i] = st.block;
    }
    while (i <= n) : (i += 1) {
        code[i] = true;
        in_string[i] = false;
        in_block[i] = false;
    }
    return .{ .code = code, .in_string = in_string, .in_block = in_block };
}

/// does a changed line change code? With no text, every line does
fn changesCode(ls: ?Lines, m: Mark) bool {
    const l = ls orelse return true;
    if (m.line < 0 or @as(usize, @intCast(m.line)) >= l.code.len) return true;
    const k: usize = @intCast(m.line);
    if (!m.removed) return k == 0 or l.code[k];
    // removed: from inside a string it was the string's text; from inside a /* comment, comment; else its own text says
    if (l.in_string[k]) return true;
    if (l.in_block[k]) return false;
    return !m.comment;
}

/// The ids a diff touched, over the graph it changed into. `root` is the folder the graph's paths start from, `repo` the
/// one the diff's start from; `tours` are the walkable tours; `texts` the files' texts after the change, where known.
pub fn map(a: Allocator, g: G.Graph, changes: []const FileChange, root: []const u8, repo: []const u8, tours: []const Tour, texts: []const Text) !Mapping {
    var changed: std.ArrayList([]const u8) = .empty;
    var touched: std.ArrayList([]const u8) = .empty;
    var outside: std.ArrayList([]const u8) = .empty;
    var removed: std.ArrayList([]const u8) = .empty;
    var why: std.ArrayList(u8) = .empty;
    var n_hunks: usize = 0;
    var n_lines: usize = 0;
    var n_quiet: usize = 0;

    const put = struct {
        fn id(al: Allocator, list: *std.ArrayList([]const u8), x: []const u8) !void {
            for (list.items) |y| if (sameName(x, y)) return;
            try list.append(al, x);
        }
    };

    if (g.files.len == 0 and changes.len > 0) {
        try why.appendSlice(a, "the graph record names no files, so no line of the diff could be placed");
    }
    var file_keys: std.ArrayList([]const u8) = .empty;
    for (g.files) |f| try file_keys.append(a, try key(a, root, f));

    for (changes) |fc| {
        n_hunks += fc.hunks;
        n_lines += fc.changed;
        // the diff's name for the file, and its key
        const named = if (fc.new.len > 0) fc.new else fc.old;
        const k_path = try key(a, repo, named);
        var ls: ?Lines = null;
        if (fc.new.len > 0) {
            for (texts) |t| if (samePath(t.path, fc.new)) {
                ls = try readLines(a, t.text);
            };
        }
        for (fc.at.items) |m| {
            if (!changesCode(ls, m)) n_quiet += 1;
        }

        // a definition gone: whatever still answers its name is what its callers now reach
        for (fc.removed.items) |r| {
            if (!changesCode(ls, fc.at.items[r.mark])) continue;
            var again = false;
            for (fc.added.items) |x| if (sameName(x, r.name)) {
                again = true;
            };
            if (again) continue;
            try put.id(a, &removed, r.name);
            for (g.nodes) |n| if (sameName(n.name, r.name)) try put.id(a, &changed, n.id);
        }

        var tour: ?[]const u8 = null;
        for (tours) |t| if (samePath(try Hg.normPath(a, t.at), k_path)) {
            tour = t.file;
        };
        if (tour) |t| {
            if (fc.new.len > 0) try put.id(a, &touched, t);
            continue;
        }
        // the graph's own spelling of the file, which its nodes and classes carry
        var gfile: ?[]const u8 = null;
        for (file_keys.items, 0..) |fk, i| if (samePath(fk, k_path)) {
            gfile = g.files[i];
        };
        const path = gfile orelse {
            try put.id(a, &outside, named);
            continue;
        };
        if (fc.new.len == 0) {
            if (why.items.len > 0) try why.appendSlice(a, "; ");
            try why.appendSlice(a, try std.fmt.allocPrint(a, "{s} is deleted and the graph still holds it: the graph is older than the change", .{path}));
            continue;
        }

        var unplaced: std.ArrayList(i64) = .empty;
        for (fc.at.items) |mark| {
            if (!changesCode(ls, mark)) continue;
            const line = mark.line;
            // the definition the line stands in: the last beginning at or before it
            var best_line: i64 = 0;
            var best_node: ?usize = null;
            var best_class: ?usize = null;
            for (g.nodes, 0..) |n, k| {
                if (n.line <= 0 or n.line > line or !samePath(n.file, path)) continue;
                if (n.line >= best_line) {
                    best_line = n.line;
                    best_node = k;
                    best_class = null;
                }
            }
            for (g.classes, 0..) |c, k| {
                if (c.line <= 0 or c.line > line or !samePath(c.file, path)) continue;
                if (c.line > best_line or (c.line == best_line and best_node == null)) {
                    best_line = c.line;
                    best_class = k;
                    best_node = null;
                }
            }
            if (best_node) |k| {
                try put.id(a, &changed, g.nodes[k].id);
                continue;
            }
            var reached = false;
            if (best_class) |k| {
                // the class and every class deriving from it, as far as they go; then their methods
                var family: std.ArrayList([]const u8) = .empty;
                try family.append(a, g.classes[k].name);
                var at: usize = 0;
                while (at < family.items.len) : (at += 1) {
                    for (g.classes) |c| {
                        if (!sameName(c.parent, family.items[at])) continue;
                        var seen = false;
                        for (family.items) |f| if (sameName(f, c.name)) {
                            seen = true;
                        };
                        if (!seen) try family.append(a, c.name);
                    }
                }
                for (g.nodes) |n| {
                    const dot = std.mem.indexOfScalar(u8, n.id, '.') orelse continue;
                    for (family.items) |f| if (sameName(n.id[0..dot], f)) {
                        try put.id(a, &changed, n.id);
                        reached = true;
                    };
                }
            } else {
                // before any definition: the file's own statements
                const top = try std.mem.concat(a, u8, &.{ "<top>:", path });
                if (g.indexOf(top)) |k| {
                    try put.id(a, &changed, g.nodes[k].id);
                    reached = true;
                }
            }
            if (!reached) {
                var have = false;
                for (unplaced.items) |x| if (x == line) {
                    have = true;
                };
                if (!have) try unplaced.append(a, line);
            }
        }
        // one reason a file, however many of its lines no node holds
        if (unplaced.items.len > 0) {
            var first = unplaced.items[0];
            for (unplaced.items) |x| first = @min(first, x);
            if (why.items.len > 0) try why.appendSlice(a, "; ");
            try why.appendSlice(a, if (unplaced.items.len == 1)
                try std.fmt.allocPrint(a, "the change to {s} at line {d} is in no node of the graph", .{ path, first })
            else
                try std.fmt.allocPrint(a, "the change to {s} at {d} lines is in no node of the graph, the first at line {d}", .{ path, unplaced.items.len, first }));
        }
    }
    return .{
        .changed = changed.items,
        .why = why.items,
        .summary = .{
            .files = changes.len,
            .hunks = n_hunks,
            .lines = n_lines,
            .quiet = n_quiet,
            .touched = touched.items,
            .outside = outside.items,
            .removed = removed.items,
        },
    };
}

// ── tests ────────────────────────────────────────────────────

const testing = std.testing;

test "a definition's name is read from its line, and nothing else is one" {
    try testing.expectEqualStrings("Eval", definedName("\t\tdef Eval(pnX)").?);
    try testing.expectEqualStrings("Gross", definedName("func Gross(n)").?);
    try testing.expectEqualStrings("stzBox", definedName("class stzBox from stzObject").?);
    try testing.expect(definedName("\treturn Eval(3)") == null);
    try testing.expect(definedName("# def x()") == null);
    try testing.expect(definedName("define = 2") == null);
}

test "A DIFF IS READ ON ITS NEW SIDE, BY ITS COUNTS: added lines, the line before a removal, a removed header-like line" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const d =
        "diff --git a/inv.haro b/inv.haro\n" ++
        "index 1..2 100644\n" ++
        "--- a/inv.haro\n" ++
        "+++ b/inv.haro\n" ++
        "@@ -5,3 +5,3 @@ func Vat(n)\n" ++
        " func Vat(n)\n" ++
        "-\treturn n * 0.2\n" ++
        "+\treturn n * 0.19\n" ++
        " \n" ++
        "@@ -20,2 +20,0 @@\n" ++
        "--- a line that reads like a header\n" ++
        "-def Old()\n" ++
        "diff --git a/gone.ring b/gone.ring\n" ++
        "deleted file mode 100644\n" ++
        "--- a/gone.ring\n" ++
        "+++ /dev/null\n" ++
        "@@ -1 +0,0 @@\n" ++
        "-func Gone()\n";
    const fs = try parse(a, d);
    try testing.expectEqual(@as(usize, 2), fs.len);
    try testing.expectEqualStrings("inv.haro", fs[0].old);
    try testing.expectEqualStrings("inv.haro", fs[0].new);
    try testing.expectEqual(@as(usize, 2), fs[0].hunks);
    try testing.expectEqual(@as(usize, 4), fs[0].changed);
    // the removal names the line before it (5), the addition its own (6); the second hunk adds nothing after line 20
    try testing.expectEqualSlices(i64, &.{ 5, 6, 20, 20 }, try linesOf(a, fs[0]));
    try testing.expect(fs[0].at.items[0].removed and !fs[0].at.items[1].removed);
    try testing.expectEqual(@as(usize, 1), fs[0].removed.items.len);
    try testing.expectEqualStrings("Old", fs[0].removed.items[0].name);
    try testing.expectEqual(@as(usize, 3), fs[0].removed.items[0].mark);
    try testing.expectEqualStrings("gone.ring", fs[1].old);
    try testing.expectEqualStrings("", fs[1].new);
    try testing.expectEqualStrings("Gone", fs[1].removed.items[0].name);
}

test "a plain diff -u is read too, and a path with no git prefix keeps its first folder" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const fs = try parse(a, "--- lib/money.ring\t2026-11-27 06:00\n+++ lib/money.ring\t2026-11-27 06:01\n@@ -3 +3 @@\n-x\n+y\n");
    try testing.expectEqual(@as(usize, 1), fs.len);
    try testing.expectEqualStrings("lib/money.ring", fs[0].new);
    try testing.expectEqualSlices(i64, &.{ 2, 3 }, try linesOf(a, fs[0]));
}

fn linesOf(a: Allocator, fc: FileChange) ![]i64 {
    var out: std.ArrayList(i64) = .empty;
    for (fc.at.items) |m| try out.append(a, m.line);
    return out.items;
}

fn marks(a: Allocator, fc: *FileChange, lines: []const i64) !void {
    for (lines) |l| try fc.at.append(a, .{ .line = l });
}

fn graphOf(a: Allocator, json: []const u8) !G.Graph {
    return G.fromValue(a, try @import("testoor_json.zig").parse(a, json));
}

const unit =
    \\{"fold":"ascii","nodes":[
    \\{"id":"<top>:inv.haro","name":"<top>","kind":"top","file":"inv.haro","line":0},
    \\{"id":"Gross","name":"Gross","kind":"function","file":"inv.haro","line":3},
    \\{"id":"stzA.Run","name":"Run","kind":"method","file":"inv.haro","line":10},
    \\{"id":"stzB.Run","name":"Run","kind":"method","file":"inv.haro","line":15},
    \\{"id":"Round2","name":"Round2","kind":"function","file":"lib/money.ring","line":3}],
    \\"edges":[],"files":["inv.haro","lib/money.ring","lib/consts.ring"],
    \\"classes":[{"name":"stzA","parent":"","file":"inv.haro","line":8},{"name":"stzB","parent":"stzA","file":"inv.haro","line":14}]}
;

test "A LINE NAMES THE DEFINITION IT STANDS IN: a function, a class's body (its subclasses' methods too), the file's statements" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const g = try graphOf(a, unit);
    var fc: FileChange = .{ .old = "inv.haro", .new = "inv.haro", .hunks = 1, .changed = 3 };
    try marks(a, &fc, &.{ 4, 9, 1 });
    const m = try map(a, g, &.{fc}, "", "", &.{}, &.{});
    try testing.expectEqualStrings("", m.why);
    try testing.expectEqual(@as(usize, 4), m.changed.len);
    try testing.expectEqualStrings("Gross", m.changed[0]);
    try testing.expectEqualStrings("stzA.Run", m.changed[1]);
    try testing.expectEqualStrings("stzB.Run", m.changed[2]);
    try testing.expectEqualStrings("<top>:inv.haro", m.changed[3]);
}

test "a line no node holds leaves the mapping not complete; a tour is selected for itself; another file obliges nothing" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const g = try graphOf(a, unit);
    // the graph's folder is app/ of the diff's tree; the tours are in t/
    var consts: FileChange = .{ .old = "app/lib/consts.ring", .new = "app/lib/consts.ring", .hunks = 1, .changed = 1 };
    try marks(a, &consts, &.{2});
    var tour: FileChange = .{ .old = "t/t_gross.haro", .new = "t/t_gross.haro", .hunks = 1, .changed = 1 };
    try marks(a, &tour, &.{7});
    var doc: FileChange = .{ .old = "README.md", .new = "README.md", .hunks = 1, .changed = 1 };
    try marks(a, &doc, &.{1});
    var money: FileChange = .{ .old = "app/lib/money.ring", .new = "app/lib/money.ring", .hunks = 1, .changed = 1 };
    try marks(a, &money, &.{4});
    const m = try map(a, g, &.{ consts, tour, doc, money }, "D:/r/app", "D:/r", &.{.{ .file = "t_gross.haro", .at = "D:/r/app/../t/t_gross.haro" }}, &.{});
    try testing.expectEqualStrings("the change to lib/consts.ring at line 2 is in no node of the graph", m.why);
    try testing.expectEqual(@as(usize, 1), m.summary.touched.len);
    try testing.expectEqualStrings("t_gross.haro", m.summary.touched[0]);
    try testing.expectEqual(@as(usize, 1), m.summary.outside.len);
    try testing.expectEqualStrings("README.md", m.summary.outside[0]);
    try testing.expectEqual(@as(usize, 1), m.changed.len);
    try testing.expectEqualStrings("Round2", m.changed[0]);
}

test "a library beside the unit, diffed from its own tree, is placed through the two folders" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const g = try graphOf(a,
        \\{"nodes":[{"id":"stzList.Add","name":"Add","kind":"method","file":"../.stzlib/base/list/stzList.ring","line":40}],
        \\"edges":[],"files":["../.stzlib/base/list/stzList.ring"],"classes":[]}
    );
    var fc: FileChange = .{ .old = "base/list/stzList.ring", .new = "base/list/stzList.ring", .hunks = 1, .changed = 1 };
    try marks(a, &fc, &.{41});
    const m = try map(a, g, &.{fc}, "C:/f/guards", "C:/f/.stzlib", &.{}, &.{});
    try testing.expectEqualStrings("", m.why);
    try testing.expectEqualStrings("stzList.Add", m.changed[0]);
}

test "A REMOVED DEFINITION CHANGES WHATEVER STILL ANSWERS ITS NAME; one edited in place is no removal" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const g = try graphOf(a, unit);
    var gone: FileChange = .{ .old = "lib/old.ring", .new = "", .hunks = 1, .changed = 1 };
    try gone.at.append(a, .{ .line = 0, .removed = true });
    try gone.removed.append(a, .{ .name = "Run", .mark = 0 });
    var edited: FileChange = .{ .old = "inv.haro", .new = "inv.haro", .hunks = 1, .changed = 2 };
    try edited.at.append(a, .{ .line = 2, .removed = true });
    try edited.at.append(a, .{ .line = 3 });
    try edited.removed.append(a, .{ .name = "Gross", .mark = 0 });
    try edited.added.append(a, "gross");
    const m = try map(a, g, &.{ gone, edited }, "", "", &.{}, &.{});
    try testing.expectEqualStrings("", m.why);
    try testing.expectEqual(@as(usize, 1), m.summary.removed.len);
    try testing.expectEqualStrings("Run", m.summary.removed[0]);
    // the line replaced is line 3: the removal lands on line 2, the file's own statements, the addition on Gross
    try testing.expectEqual(@as(usize, 4), m.changed.len);
    try testing.expectEqualStrings("stzA.Run", m.changed[0]);
    try testing.expectEqualStrings("stzB.Run", m.changed[1]);
    try testing.expectEqualStrings("<top>:inv.haro", m.changed[2]);
    try testing.expectEqualStrings("Gross", m.changed[3]);
}

test "A LINE THAT HOLDS NO CODE CHANGES NOTHING: a comment is quiet, a # line inside a string is the string's text" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const g = try graphOf(a, unit);
    const text = "# the invoice unit\nx = 1\nfunc Gross(n)\n\treturn n * 1.2\n\tcT = '\n# a heading inside a string\n'\nclass stzA\n\tnX = 5\n\tdef Run()\n\t\treturn 1\n";
    var fc: FileChange = .{ .old = "inv.haro", .new = "inv.haro", .hunks = 2, .changed = 4 };
    try fc.at.append(a, .{ .line = 1 }); // a comment added: quiet
    try fc.at.append(a, .{ .line = 6 }); // a # line added inside a string: code, in Gross
    try fc.at.append(a, .{ .line = 8, .removed = true, .comment = true }); // a comment removed after `class stzA`: quiet
    try fc.at.append(a, .{ .line = 5, .removed = true, .comment = true }); // a # line removed from inside the string: code
    const m = try map(a, g, &.{fc}, "", "", &.{}, &.{.{ .path = "inv.haro", .text = text }});
    try testing.expectEqualStrings("", m.why);
    try testing.expectEqual(@as(usize, 2), m.summary.quiet);
    try testing.expectEqual(@as(usize, 1), m.changed.len);
    try testing.expectEqualStrings("Gross", m.changed[0]);
    // without the text, every line is code: line 1 is the file's statements, line 8 the class body
    const m2 = try map(a, g, &.{fc}, "", "", &.{}, &.{});
    try testing.expectEqual(@as(usize, 0), m2.summary.quiet);
    try testing.expectEqual(@as(usize, 4), m2.changed.len);
}

test "a removed definition that was only a comment's text removes nothing" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const g = try graphOf(a, unit);
    const fs = try parse(a, "--- a/inv.haro\n+++ b/inv.haro\n@@ -2,2 +1,0 @@\n-/* the old helper:\n-def Run()\n");
    // after the change, line 1 still opens the /* comment the two removed lines stood in
    const m = try map(a, g, fs, "", "", &.{}, &.{.{ .path = "inv.haro", .text = "/* kept\n*/\nfunc Gross(n)\n" }});
    try testing.expectEqual(@as(usize, 0), m.summary.removed.len);
    try testing.expectEqual(@as(usize, 2), m.summary.quiet);
}
