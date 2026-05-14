// Softanza Engine -- Regex Operations (Tier 3)
//
// Replaces QRegularExpression with a recursive backtracking
// pattern matcher. Supports: literal, . * + ? *? +? ?? | () [] [^]
// \d \w \s \D \W \S \p{L} \P{N} ^ $ and case-insensitive flag.
// All functions use C ABI for Ring FFI compatibility.
//
// ReDoS hardening: step budget, input/pattern length caps, nesting
// depth limit. All configurable per handle via stz_regex_set_limits.

const std = @import("std");
const mem = std.mem;
const gpa = std.heap.c_allocator;
const unicode = @import("unicode.zig");

// ─── Public handle ───

const Regex = struct {
    pattern: []const u8,
    flags: u32,
    captures: std.ArrayList(Cap),
    matched: bool,
    input: []const u8,
    max_steps: u32 = 1_000_000,
    max_input_len: u32 = 1_048_576,
    max_depth: u16 = 64,
    const Cap = struct { start: i32, end: i32 };
};

// Flags: 1=CaseInsensitive 2=DotMatchesAll 4=MultiLine
const FLAG_CASE_I: u32 = 1;
const FLAG_DOT_ALL: u32 = 2;

const MAX_PATTERN_LEN: usize = 4096;

pub fn stz_regex_new(pat: [*c]const u8, pat_len: usize, flags: u32) callconv(.c) ?*Regex {
    if (pat == null or pat_len == 0) return null;
    if (pat_len > MAX_PATTERN_LEN) return null;
    const p = gpa.dupe(u8, pat[0..pat_len]) catch return null;
    const r = gpa.create(Regex) catch { gpa.free(p); return null; };
    r.* = .{ .pattern = p, .flags = flags, .captures = .{}, .matched = false, .input = "" };
    return r;
}

pub fn stz_regex_set_limits(h: ?*Regex, max_steps: u32, max_input_len: u32, max_depth: u16) callconv(.c) void {
    const r = h orelse return;
    if (max_steps > 0) r.max_steps = max_steps;
    if (max_input_len > 0) r.max_input_len = max_input_len;
    if (max_depth > 0) r.max_depth = max_depth;
}

pub fn stz_regex_free(h: ?*Regex) callconv(.c) void {
    if (h) |r| { gpa.free(r.pattern); r.captures.deinit(gpa); gpa.destroy(r); }
}

pub fn stz_regex_match(h: ?*Regex, inp: [*c]const u8, inp_len: usize, start: usize) callconv(.c) c_int {
    const r = h orelse return 0;
    if (inp == null) { r.matched = false; return 0; }
    if (inp_len > r.max_input_len) { r.matched = false; return 0; }
    const text = inp[0..inp_len];
    r.input = text;
    r.captures.clearRetainingCapacity();
    var budget: u32 = r.max_steps;
    r.matched = doMatch(r.pattern, text, start, r.flags, &r.captures, &budget, r.max_depth);
    return if (r.matched) 1 else 0;
}

pub fn stz_regex_match_all(h: ?*Regex, inp: [*c]const u8, inp_len: usize) callconv(.c) c_int {
    const r = h orelse return 0;
    if (inp == null) return 0;
    if (inp_len > r.max_input_len) return 0;
    const text = inp[0..inp_len];
    r.input = text;
    r.captures.clearRetainingCapacity();
    var pos: usize = 0;
    var n: c_int = 0;
    var budget: u32 = r.max_steps;
    while (pos <= text.len) {
        if (budget == 0) break;
        var tmp: std.ArrayList(Regex.Cap) = .{};
        defer tmp.deinit(gpa);
        if (doMatch(r.pattern, text, pos, r.flags, &tmp, &budget, r.max_depth) and tmp.items.len > 0) {
            for (tmp.items) |cap| r.captures.append(gpa, cap) catch {};
            n += 1;
            const e: usize = @intCast(tmp.items[0].end);
            pos = if (e <= pos) pos + 1 else e;
        } else pos += 1;
    }
    r.matched = n > 0;
    return n;
}

pub fn stz_regex_has_match(h: ?*Regex) callconv(.c) c_int {
    return if (h) |r| (if (r.matched) @as(c_int, 1) else 0) else 0;
}

pub fn stz_regex_capture_count(h: ?*Regex) callconv(.c) c_int {
    return if (h) |r| @as(c_int, @intCast(r.captures.items.len)) else 0;
}

pub fn stz_regex_capture_start(h: ?*Regex, idx: c_int) callconv(.c) c_int {
    const r = h orelse return -1;
    const i: usize = @intCast(idx);
    return if (i < r.captures.items.len) r.captures.items[i].start else -1;
}

pub fn stz_regex_capture_end(h: ?*Regex, idx: c_int) callconv(.c) c_int {
    const r = h orelse return -1;
    const i: usize = @intCast(idx);
    return if (i < r.captures.items.len) r.captures.items[i].end else -1;
}

pub fn stz_regex_capture_text(h: ?*Regex, idx: c_int, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const r = h orelse return 0;
    const i: usize = @intCast(idx);
    if (i >= r.captures.items.len) return 0;
    const c = r.captures.items[i];
    if (c.start < 0 or c.end < 0) return 0;
    const s: usize = @intCast(c.start);
    const e: usize = @intCast(c.end);
    if (s >= e or e > r.input.len) return 0;
    const t = r.input[s..e];
    if (t.len > buf_len) return 0;
    @memcpy(buf[0..t.len], t);
    return t.len;
}

pub fn stz_regex_replace(h: ?*Regex, inp: [*c]const u8, inp_len: usize, repl: [*c]const u8, repl_len: usize, out_len: *usize) callconv(.c) [*c]u8 {
    out_len.* = 0;
    const r = h orelse return null;
    if (inp == null or inp_len == 0) return null;
    if (inp_len > r.max_input_len) return null;
    const text = inp[0..inp_len];
    const rep = if (repl != null and repl_len > 0) repl[0..repl_len] else "";
    var res: std.ArrayList(u8) = .{};
    var pos: usize = 0;
    var budget: u32 = r.max_steps;
    while (pos <= text.len) {
        if (budget == 0) break;
        var tmp: std.ArrayList(Regex.Cap) = .{};
        defer tmp.deinit(gpa);
        if (doMatch(r.pattern, text, pos, r.flags, &tmp, &budget, r.max_depth) and tmp.items.len > 0) {
            const s: usize = @intCast(tmp.items[0].start);
            const e: usize = @intCast(tmp.items[0].end);
            res.appendSlice(gpa, text[pos..s]) catch { res.deinit(gpa); return null; };
            res.appendSlice(gpa, rep) catch { res.deinit(gpa); return null; };
            pos = if (e <= pos) pos + 1 else e;
        } else {
            if (pos < text.len) res.append(gpa, text[pos]) catch { res.deinit(gpa); return null; };
            pos += 1;
        }
    }
    out_len.* = res.items.len;
    const buf = gpa.alloc(u8, res.items.len) catch { res.deinit(gpa); return null; };
    @memcpy(buf, res.items);
    res.deinit(gpa);
    return buf.ptr;
}

pub fn stz_regex_replace_free(ptr: [*c]u8, len: usize) callconv(.c) void {
    if (ptr != null and len > 0) gpa.free(ptr[0..len]);
}

// ─── Core matching engine ───

fn doMatch(pattern: []const u8, text: []const u8, start: usize, flags: u32, caps: *std.ArrayList(Regex.Cap), budget: *u32, max_depth: u16) bool {
    const ci = (flags & FLAG_CASE_I) != 0;
    const da = (flags & FLAG_DOT_ALL) != 0;
    var pos = start;
    const anchored = pattern.len > 0 and pattern[0] == '^';
    while (pos <= text.len) {
        if (budget.* == 0) return false;
        caps.clearRetainingCapacity();
        caps.append(gpa, .{ .start = @intCast(pos), .end = -1 }) catch {};
        if (matchHere(pattern, if (anchored) 1 else 0, text, pos, ci, da, caps, budget, max_depth)) {
            return true;
        }
        if (anchored) return false;
        pos += 1;
    }
    return false;
}

fn matchHere(pat: []const u8, pi: usize, text: []const u8, ti: usize, ci: bool, da: bool, caps: *std.ArrayList(Regex.Cap), budget: *u32, max_depth: u16) bool {
    if (budget.* == 0) return false;
    budget.* -= 1;

    var p = pi;
    var t = ti;

    while (p < pat.len) {
        if (pat[p] == '$' and (p + 1 >= pat.len or pat[p + 1] == '|')) {
            if (t == text.len) {
                updateEnd(caps, t);
                return true;
            }
            return false;
        }

        if (pat[p] == '|') {
            updateEnd(caps, t);
            return true;
        }

        if (pat[p] == '(') {
            if (max_depth == 0) return false;
            return matchGroup(pat, p, text, t, ci, da, caps, budget, max_depth - 1);
        }

        const atom_end = atomEnd(pat, p);
        if (atom_end <= p) return false;

        if (atom_end < pat.len) {
            const q = pat[atom_end];
            if (q == '*' or q == '+' or q == '?') {
                const lazy = (atom_end + 1 < pat.len and pat[atom_end + 1] == '?');
                const skip = if (lazy) atom_end + 2 else atom_end + 1;
                return matchQuantifiedEx(pat, p, atom_end, q, lazy, skip, text, t, ci, da, caps, budget, max_depth);
            }
        }

        if (t >= text.len) return false;
        if (!matchOne(pat, p, text[t], ci, da)) return false;
        t += 1;
        p = atom_end;
    }

    updateEnd(caps, t);
    return true;
}

fn matchQuantifiedEx(pat: []const u8, p: usize, _: usize, q: u8, lazy: bool, skip: usize, text: []const u8, ti: usize, ci: bool, da: bool, caps: *std.ArrayList(Regex.Cap), budget: *u32, max_depth: u16) bool {
    const min_count: usize = if (q == '+') 1 else 0;
    var max_count: usize = 0;
    var t = ti;

    while (t < text.len and matchOne(pat, p, text[t], ci, da)) {
        max_count += 1;
        t += 1;
    }

    if (q == '?') {
        if (max_count > 1) max_count = 1;
    }

    if (lazy) {
        var count: usize = min_count;
        while (count <= max_count) {
            if (budget.* == 0) return false;
            if (matchHere(pat, skip, text, ti + count, ci, da, caps, budget, max_depth)) return true;
            count += 1;
        }
    } else {
        var count: usize = max_count;
        while (true) {
            if (budget.* == 0) return false;
            if (count >= min_count) {
                if (matchHere(pat, skip, text, ti + count, ci, da, caps, budget, max_depth)) return true;
            }
            if (count == 0) break;
            count -= 1;
        }
    }
    return false;
}

fn matchGroup(pat: []const u8, p: usize, text: []const u8, ti: usize, ci: bool, da: bool, caps: *std.ArrayList(Regex.Cap), budget: *u32, max_depth: u16) bool {
    const close = findGroupClose(pat, p) orelse return false;
    const inner = pat[p + 1 .. close];
    const after = close + 1;
    const cap_idx = caps.items.len;
    caps.append(gpa, .{ .start = @intCast(ti), .end = -1 }) catch {};

    var alt_start: usize = 0;
    var i: usize = 0;
    var depth: u32 = 0;
    while (i <= inner.len) : (i += 1) {
        if (budget.* == 0) return false;
        const at_end = i == inner.len;
        const at_alt = if (!at_end) (inner[i] == '|' and depth == 0) else false;
        if (!at_end and inner[i] == '(') depth += 1;
        if (!at_end and inner[i] == ')') depth -|= 1;

        if (at_end or at_alt) {
            const alt = inner[alt_start..i];
            var sub_t = ti;
            if (matchBranch(alt, text, &sub_t, ci, da, caps, budget, max_depth)) {
                if (cap_idx < caps.items.len)
                    caps.items[cap_idx].end = @intCast(sub_t);
                var next = after;
                if (next < pat.len and (pat[next] == '*' or pat[next] == '+' or pat[next] == '?')) {
                    next += 1;
                    if (next < pat.len and pat[next] == '?') next += 1;
                }
                return matchHere(pat, next, text, sub_t, ci, da, caps, budget, max_depth);
            }
            alt_start = i + 1;
        }
    }

    if (after < pat.len and pat[after] == '?') {
        if (cap_idx < caps.items.len) {
            caps.items[cap_idx].start = -1;
            caps.items[cap_idx].end = -1;
        }
        return matchHere(pat, after + 1, text, ti, ci, da, caps, budget, max_depth);
    }

    return false;
}

fn matchBranch(branch: []const u8, text: []const u8, t: *usize, ci: bool, da: bool, caps: *std.ArrayList(Regex.Cap), budget: *u32, max_depth: u16) bool {
    var p: usize = 0;
    while (p < branch.len) {
        if (budget.* == 0) return false;
        if (branch[p] == '(') {
            if (max_depth == 0) return false;
            const close = findGroupClose(branch, p) orelse return false;
            const inner = branch[p + 1 .. close];
            const cap_idx = caps.items.len;
            caps.append(gpa, .{ .start = @intCast(t.*), .end = -1 }) catch {};

            var alt_start: usize = 0;
            var i: usize = 0;
            var depth: u32 = 0;
            var matched = false;
            while (i <= inner.len) : (i += 1) {
                if (budget.* == 0) return false;
                const at_end = i == inner.len;
                const at_alt = if (!at_end) (inner[i] == '|' and depth == 0) else false;
                if (!at_end and inner[i] == '(') depth += 1;
                if (!at_end and inner[i] == ')') depth -|= 1;
                if (at_end or at_alt) {
                    const alt = inner[alt_start..i];
                    var sub_t = t.*;
                    if (matchBranch(alt, text, &sub_t, ci, da, caps, budget, max_depth - 1)) {
                        if (cap_idx < caps.items.len)
                            caps.items[cap_idx].end = @intCast(sub_t);
                        t.* = sub_t;
                        matched = true;
                        break;
                    }
                    alt_start = i + 1;
                }
            }
            if (!matched) return false;
            p = close + 1;
            if (p < branch.len and (branch[p] == '*' or branch[p] == '+' or branch[p] == '?')) {
                p += 1;
                if (p < branch.len and branch[p] == '?') p += 1;
            }
            continue;
        }

        const ae = atomEnd(branch, p);
        if (ae <= p) return false;

        if (ae < branch.len and (branch[ae] == '*' or branch[ae] == '+' or branch[ae] == '?')) {
            const q = branch[ae];
            const min_count: usize = if (q == '+') 1 else 0;
            var count: usize = 0;
            while (t.* + count < text.len and matchOne(branch, p, text[t.* + count], ci, da)) count += 1;
            if (q == '?') { if (count > 1) count = 1; }
            if (count < min_count) return false;
            t.* += count;
            p = ae + 1;
            if (p < branch.len and branch[p] == '?') p += 1;
            continue;
        }

        if (t.* >= text.len) return false;
        if (!matchOne(branch, p, text[t.*], ci, da)) return false;
        t.* += 1;
        p = ae;
    }
    return true;
}

fn matchOne(pat: []const u8, p: usize, c: u8, ci: bool, da: bool) bool {
    if (p >= pat.len) return false;
    const pc = pat[p];

    if (pc == '.') return if (c == '\n' and !da) false else true;

    if (pc == '\\' and p + 1 < pat.len) {
        const esc = pat[p + 1];
        if ((esc == 'p' or esc == 'P') and p + 2 < pat.len and pat[p + 2] == '{') {
            if (findBrace(pat, p + 2)) |close| {
                const prop_name = pat[p + 3 .. close];
                const matches = matchUnicodeProperty(c, prop_name);
                return if (esc == 'p') matches else !matches;
            }
            return false;
        }
        return switch (esc) {
            'd' => c >= '0' and c <= '9',
            'D' => !(c >= '0' and c <= '9'),
            'w' => isWord(c),
            'W' => !isWord(c),
            's' => isSpace(c),
            'S' => !isSpace(c),
            'n' => c == '\n',
            'r' => c == '\r',
            't' => c == '\t',
            else => eqChar(c, esc, ci),
        };
    }

    if (pc == '[') return matchCharClass(pat, p, c, ci);

    return eqChar(c, pc, ci);
}

fn matchUnicodeProperty(c: u8, prop: []const u8) bool {
    const cp: i32 = @intCast(c);
    if (prop.len == 0) return false;
    if (prop.len == 1) {
        return switch (prop[0]) {
            'L' => unicode.stz_unicode_is_letter(cp) == 1,
            'N' => unicode.stz_unicode_is_number(cp) == 1,
            'P' => unicode.stz_unicode_is_punctuation(cp) == 1,
            'S' => unicode.stz_unicode_is_symbol(cp) == 1,
            'Z' => unicode.stz_unicode_is_space(cp) == 1,
            'M' => unicode.stz_unicode_is_mark(cp) == 1,
            'C' => unicode.stz_unicode_is_control(cp) == 1,
            else => false,
        };
    }
    if (prop.len == 2) {
        const cat = unicode.stz_unicode_category(cp);
        if (mem.eql(u8, prop, "Lu")) return cat == 1;
        if (mem.eql(u8, prop, "Ll")) return cat == 2;
        if (mem.eql(u8, prop, "Lt")) return cat == 3;
        if (mem.eql(u8, prop, "Lm")) return cat == 4;
        if (mem.eql(u8, prop, "Lo")) return cat == 5;
        if (mem.eql(u8, prop, "Mn")) return cat == 6;
        if (mem.eql(u8, prop, "Mc")) return cat == 7;
        if (mem.eql(u8, prop, "Me")) return cat == 8;
        if (mem.eql(u8, prop, "Nd")) return cat == 9;
        if (mem.eql(u8, prop, "Nl")) return cat == 10;
        if (mem.eql(u8, prop, "No")) return cat == 11;
        if (mem.eql(u8, prop, "Pc")) return cat == 12;
        if (mem.eql(u8, prop, "Pd")) return cat == 13;
        if (mem.eql(u8, prop, "Ps")) return cat == 14;
        if (mem.eql(u8, prop, "Pe")) return cat == 15;
        if (mem.eql(u8, prop, "Pi")) return cat == 16;
        if (mem.eql(u8, prop, "Pf")) return cat == 17;
        if (mem.eql(u8, prop, "Po")) return cat == 18;
        if (mem.eql(u8, prop, "Sm")) return cat == 19;
        if (mem.eql(u8, prop, "Sc")) return cat == 20;
        if (mem.eql(u8, prop, "Sk")) return cat == 21;
        if (mem.eql(u8, prop, "So")) return cat == 22;
        if (mem.eql(u8, prop, "Zs")) return cat == 23;
        if (mem.eql(u8, prop, "Cc")) return cat == 26;
        if (mem.eql(u8, prop, "Cf")) return cat == 27;
    }
    if (eqlAsciiI(prop, "Letter")) return unicode.stz_unicode_is_letter(cp) == 1;
    if (eqlAsciiI(prop, "Number")) return unicode.stz_unicode_is_number(cp) == 1;
    if (eqlAsciiI(prop, "Punctuation")) return unicode.stz_unicode_is_punctuation(cp) == 1;
    if (eqlAsciiI(prop, "Symbol")) return unicode.stz_unicode_is_symbol(cp) == 1;
    if (eqlAsciiI(prop, "Separator")) return unicode.stz_unicode_is_space(cp) == 1;
    if (eqlAsciiI(prop, "Mark")) return unicode.stz_unicode_is_mark(cp) == 1;
    return false;
}

fn eqlAsciiI(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) return false;
    for (a, b) |ac, bc| {
        if (toLowerAscii(ac) != toLowerAscii(bc)) return false;
    }
    return true;
}

fn findBrace(pat: []const u8, open: usize) ?usize {
    var i = open + 1;
    while (i < pat.len) : (i += 1) {
        if (pat[i] == '}') return i;
    }
    return null;
}

fn matchCharClass(pat: []const u8, p: usize, c: u8, ci: bool) bool {
    var i = p + 1;
    if (i >= pat.len) return false;
    const neg = pat[i] == '^';
    if (neg) i += 1;
    var matched = false;

    while (i < pat.len and pat[i] != ']') {
        if (pat[i] == '\\' and i + 1 < pat.len) {
            const esc = pat[i + 1];
            const m = switch (esc) {
                'd' => c >= '0' and c <= '9',
                'D' => !(c >= '0' and c <= '9'),
                'w' => isWord(c),
                'W' => !isWord(c),
                's' => isSpace(c),
                'S' => !isSpace(c),
                else => eqChar(c, esc, ci),
            };
            if (m) matched = true;
            i += 2;
        } else if (i + 2 < pat.len and pat[i + 1] == '-' and pat[i + 2] != ']') {
            const lo = if (ci) toLowerAscii(pat[i]) else pat[i];
            const hi = if (ci) toLowerAscii(pat[i + 2]) else pat[i + 2];
            const tc = if (ci) toLowerAscii(c) else c;
            if (tc >= lo and tc <= hi) matched = true;
            i += 3;
        } else {
            if (eqChar(c, pat[i], ci)) matched = true;
            i += 1;
        }
    }

    return if (neg) !matched else matched;
}

fn atomEnd(pat: []const u8, p: usize) usize {
    if (p >= pat.len) return p;
    if (pat[p] == '\\' and p + 1 < pat.len) {
        const esc = pat[p + 1];
        if ((esc == 'p' or esc == 'P') and p + 2 < pat.len and pat[p + 2] == '{') {
            if (findBrace(pat, p + 2)) |close| return close + 1;
        }
        return p + 2;
    }
    if (pat[p] == '[') {
        var i = p + 1;
        if (i < pat.len and pat[i] == '^') i += 1;
        if (i < pat.len and pat[i] == ']') i += 1;
        while (i < pat.len and pat[i] != ']') : (i += 1) {}
        return if (i < pat.len) i + 1 else pat.len;
    }
    return p + 1;
}

fn findGroupClose(pat: []const u8, open: usize) ?usize {
    var d: u32 = 0;
    var i = open;
    while (i < pat.len) : (i += 1) {
        if (pat[i] == '\\') { i += 1; continue; }
        if (pat[i] == '(') d += 1;
        if (pat[i] == ')') { d -= 1; if (d == 0) return i; }
    }
    return null;
}

fn updateEnd(caps: *std.ArrayList(Regex.Cap), t: usize) void {
    if (caps.items.len > 0) caps.items[0].end = @intCast(t);
}

fn eqChar(a: u8, b: u8, ci: bool) bool {
    if (a == b) return true;
    if (ci) return toLowerAscii(a) == toLowerAscii(b);
    return false;
}

fn toLowerAscii(c: u8) u8 {
    return if (c >= 'A' and c <= 'Z') c + 32 else c;
}

fn isWord(c: u8) bool {
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or (c >= '0' and c <= '9') or c == '_';
}

fn isSpace(c: u8) bool {
    return c == ' ' or c == '\t' or c == '\n' or c == '\r';
}

// ─── Tests ───

const TEST_BUDGET: u32 = 1_000_000;
const TEST_DEPTH: u16 = 64;

fn testMatch(pat: []const u8, text: []const u8, start: usize, flags: u32, caps: *std.ArrayList(Regex.Cap)) bool {
    var budget: u32 = TEST_BUDGET;
    return doMatch(pat, text, start, flags, caps, &budget, TEST_DEPTH);
}

test "literal match" {
    var caps: std.ArrayList(Regex.Cap) = .{};
    defer caps.deinit(gpa);
    try std.testing.expect(testMatch("hello", "say hello world", 0, 0, &caps));
    try std.testing.expectEqual(@as(i32, 4), caps.items[0].start);
    try std.testing.expectEqual(@as(i32, 9), caps.items[0].end);
}

test "dot and star" {
    var caps: std.ArrayList(Regex.Cap) = .{};
    defer caps.deinit(gpa);
    try std.testing.expect(testMatch("h.*o", "hello", 0, 0, &caps));
}

test "char class" {
    var caps: std.ArrayList(Regex.Cap) = .{};
    defer caps.deinit(gpa);
    try std.testing.expect(testMatch("[abc]+", "xxbcaxx", 0, 0, &caps));
    try std.testing.expectEqual(@as(i32, 2), caps.items[0].start);
    try std.testing.expectEqual(@as(i32, 5), caps.items[0].end);
}

test "anchors" {
    var caps: std.ArrayList(Regex.Cap) = .{};
    defer caps.deinit(gpa);
    try std.testing.expect(testMatch("^hello$", "hello", 0, 0, &caps));
    caps.clearRetainingCapacity();
    try std.testing.expect(!testMatch("^hello$", "say hello", 0, 0, &caps));
}

test "capture group" {
    var caps: std.ArrayList(Regex.Cap) = .{};
    defer caps.deinit(gpa);
    try std.testing.expect(testMatch("(\\d+)-(\\d+)", "val 123-456 end", 0, 0, &caps));
    try std.testing.expect(caps.items.len >= 3);
}

test "case insensitive" {
    var caps: std.ArrayList(Regex.Cap) = .{};
    defer caps.deinit(gpa);
    try std.testing.expect(testMatch("hello", "HELLO", 0, FLAG_CASE_I, &caps));
}

test "alternation in group" {
    var caps: std.ArrayList(Regex.Cap) = .{};
    defer caps.deinit(gpa);
    try std.testing.expect(testMatch("(cat|dog)", "I have a dog", 0, 0, &caps));
}

test "escape sequences" {
    var caps: std.ArrayList(Regex.Cap) = .{};
    defer caps.deinit(gpa);
    try std.testing.expect(testMatch("\\d+", "abc123def", 0, 0, &caps));
    try std.testing.expectEqual(@as(i32, 3), caps.items[0].start);
    try std.testing.expectEqual(@as(i32, 6), caps.items[0].end);
}

test "lazy quantifier" {
    var caps: std.ArrayList(Regex.Cap) = .{};
    defer caps.deinit(gpa);
    try std.testing.expect(testMatch("<.*>", "<a><b>", 0, 0, &caps));
    try std.testing.expectEqual(@as(i32, 0), caps.items[0].start);
    try std.testing.expectEqual(@as(i32, 6), caps.items[0].end);

    caps.clearRetainingCapacity();
    try std.testing.expect(testMatch("<.*?>", "<a><b>", 0, 0, &caps));
    try std.testing.expectEqual(@as(i32, 0), caps.items[0].start);
    try std.testing.expectEqual(@as(i32, 3), caps.items[0].end);
}

test "lazy plus" {
    var caps: std.ArrayList(Regex.Cap) = .{};
    defer caps.deinit(gpa);
    try std.testing.expect(testMatch("a+?", "aaaa", 0, 0, &caps));
    try std.testing.expectEqual(@as(i32, 0), caps.items[0].start);
    try std.testing.expectEqual(@as(i32, 1), caps.items[0].end);
}

test "unicode property \\p{L}" {
    var caps: std.ArrayList(Regex.Cap) = .{};
    defer caps.deinit(gpa);
    try std.testing.expect(testMatch("\\p{L}+", "abc123", 0, 0, &caps));
    try std.testing.expectEqual(@as(i32, 0), caps.items[0].start);
    try std.testing.expectEqual(@as(i32, 3), caps.items[0].end);
}

test "unicode property \\p{N}" {
    var caps: std.ArrayList(Regex.Cap) = .{};
    defer caps.deinit(gpa);
    try std.testing.expect(testMatch("\\p{N}+", "abc123", 0, 0, &caps));
    try std.testing.expectEqual(@as(i32, 3), caps.items[0].start);
    try std.testing.expectEqual(@as(i32, 6), caps.items[0].end);
}

test "unicode property negated \\P{L}" {
    var caps: std.ArrayList(Regex.Cap) = .{};
    defer caps.deinit(gpa);
    try std.testing.expect(testMatch("\\P{L}+", "abc 123", 0, 0, &caps));
    try std.testing.expectEqual(@as(i32, 3), caps.items[0].start);
}

test "redos budget exhaustion" {
    var caps: std.ArrayList(Regex.Cap) = .{};
    defer caps.deinit(gpa);
    var budget: u32 = 50;
    const evil_input = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaab";
    const result = doMatch("(a+)+$", evil_input, 0, 0, &caps, &budget, 64);
    try std.testing.expect(!result);
    try std.testing.expect(budget < 50);
}

test "depth limit prevents deep nesting" {
    var caps: std.ArrayList(Regex.Cap) = .{};
    defer caps.deinit(gpa);
    var budget: u32 = TEST_BUDGET;
    const result = doMatch("((((a))))", "a", 0, 0, &caps, &budget, 2);
    try std.testing.expect(!result);
}

test "pattern length limit" {
    const long_pat = "a" ** (MAX_PATTERN_LEN + 1);
    const h = stz_regex_new(long_pat.ptr, long_pat.len, 0);
    try std.testing.expect(h == null);
}

test "input length limit" {
    const h = stz_regex_new("a", 1, 0) orelse unreachable;
    defer stz_regex_free(h);
    h.max_input_len = 10;
    const long_input = "a" ** 20;
    const result = stz_regex_match(h, long_input.ptr, long_input.len, 0);
    try std.testing.expectEqual(@as(c_int, 0), result);
}
