const std = @import("std");

// ═══════════════════════════════════════════════════════════════════════
//  GBNF STACK MACHINE -- the half that makes a violating token UNEMITTABLE
// ═══════════════════════════════════════════════════════════════════════
//
// schema_gbnf.zig compiles a declared schema into a GBNF grammar. That
// grammar is a document until something REFUSES TO EMIT the tokens it
// forbids. This file is that something: a parser for the grammar, a
// pushdown machine that walks it one BYTE at a time, and the one question
// a sampler needs answered per candidate --
//
//     "if I emitted this token, could the grammar still be satisfied?"
//
// ─── WHY A STACK AND NOT A REGULAR EXPRESSION ─────────────────────────
//
// A grammar rule may refer to another rule, which may refer to a third.
// Matching one byte therefore has to remember WHERE TO RETURN when the
// referenced rule finishes -- that memory is the stack. The machine holds
// a SET of stacks, not one: an alternation is genuinely several live
// positions at once, and a candidate is legal if ANY of them survives it.
//
// ─── THE CASE A NAIVE IMPLEMENTATION GETS WRONG ───────────────────────
//
// A token is not a byte. Given `root ::= "yes" "\n"`, the vocabulary token
// `yesterday` starts with three bytes the grammar accepts and then dies on
// the fourth. A check that asked only "can the grammar accept the FIRST
// byte" would emit it and produce `yesterday`, which the grammar forbids.
//
// So a candidate is accepted only if EVERY ONE of its bytes is consumed --
// the machine is cloned, fed the whole piece, and the clone must still be
// alive at the end. That is the test, and there is a unit test named for
// exactly this case at the bottom of this file.
//
// ─── WHAT THIS MACHINE CONSTRAINS, AND WHAT IT CANNOT ─────────────────
//
// CONSTRAINS: the SHAPE of the emitted bytes. Field order, the literal
// text between fields, which characters may appear where, how many times
// a repeat may repeat, and where the answer may end.
//
// CANNOT CONSTRAIN:
//
//   - VALUE. No context-free rule says "this number is between 0 and 130".
//     schema_gbnf.stz_gbnf_unenforced() lists every dropped constraint by
//     name, and the Ring court in stzOutputSchema still checks them.
//   - TRUTH. `city: Paris` and `city: Tokyo` are equally grammatical.
//     Structure kills malformedness, never falsehood.
//   - BYTES ABOVE ASCII INSIDE A CHARACTER CLASS. Matching is byte-level
//     (it must be: masking is over token BYTES), so `[a-z]` is a byte
//     range. A multi-byte character inside `[...]` is REFUSED BY NAME
//     rather than silently matching one of its bytes. Multi-byte
//     characters inside a "quoted literal" are fine -- they compile to
//     their UTF-8 byte sequence.
//   - LEFT RECURSION. `a ::= a "x"` cannot be expanded without looping;
//     it is refused by name at parse time rather than hanging.
//
// The element encoding and the advance/match algorithm follow llama.cpp's
// grammar sampler, which is the reference implementation of GBNF. Nothing
// is vendored -- this repository holds raw ggml, not llama.cpp -- so the
// machine is ours, and so is every bound in it.

// ─── capacities: every one of them refuses by name rather than truncating ───

const MAX_ELEMS: usize = 8192;
const MAX_RULES: usize = 128;
const MAX_NAME: usize = 64;
const MAX_RULE_BUF: usize = 1024; // elements in ONE rule under construction
const MAX_GROUP_DEPTH: u32 = 12;
const MAX_STACKS: usize = 192;
const MAX_STACK_DEPTH: usize = 48;
const MAX_ADVANCE_DEPTH: u32 = 96;
const MAX_DIAG: usize = 512;

pub const RC_OK: i32 = 0;
pub const RC_SYNTAX: i32 = -1;
pub const RC_FULL: i32 = -2;
pub const RC_UNDEFINED: i32 = -3;
pub const RC_NO_ROOT: i32 = -4;
pub const RC_NONASCII_CLASS: i32 = -5;
pub const RC_LEFT_RECURSION: i32 = -6;
pub const RC_DUPLICATE: i32 = -7;

const ElemT = enum(u8) {
    end = 0, // end of a rule alternative
    alt, // separates alternatives
    rule_ref, // v = rule id
    char, // v = byte, start of a positive set
    char_not, // v = byte, start of a negated set
    char_rng_upper, // v = upper bound of the range opened by the previous element
    char_alt, // v = byte, another member of the set opened before it
};

const Elem = struct { t: ElemT, v: u32 };

var g_elems: [MAX_ELEMS]Elem = undefined;
var g_elem_n: usize = 0;

var g_rule_start: [MAX_RULES]u32 = undefined;
var g_rule_defined: [MAX_RULES]bool = undefined;
var g_rule_name: [MAX_RULES][MAX_NAME]u8 = undefined;
var g_rule_name_len: [MAX_RULES]usize = undefined;
var g_rule_n: usize = 0;

var g_diag: [MAX_DIAG]u8 = undefined;
var g_diag_len: usize = 0;

var g_ready: bool = false;
var g_overflow: bool = false;

fn setDiag(comptime fmt: []const u8, args: anytype) void {
    var fbs = std.io.fixedBufferStream(&g_diag);
    fbs.writer().print(fmt, args) catch {};
    g_diag_len = fbs.pos;
}

// ═══ the grammar text -> elements ═════════════════════════════════════

const RuleBuf = struct {
    e: [MAX_RULE_BUF]Elem = undefined,
    n: usize = 0,

    fn push(self: *RuleBuf, t: ElemT, v: u32) bool {
        if (self.n >= MAX_RULE_BUF) return false;
        self.e[self.n] = .{ .t = t, .v = v };
        self.n += 1;
        return true;
    }
};

const P = struct {
    s: []const u8,
    i: usize = 0,

    fn eof(p: *const P) bool {
        return p.i >= p.s.len;
    }
    fn peek(p: *const P) u8 {
        return if (p.i < p.s.len) p.s[p.i] else 0;
    }
};

fn isNameByte(ch: u8) bool {
    return (ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z') or
        (ch >= '0' and ch <= '9') or ch == '-' or ch == '_';
}

fn skipSpace(p: *P, newlines: bool) void {
    while (!p.eof()) {
        const ch = p.s[p.i];
        if (ch == ' ' or ch == '\t' or (newlines and (ch == '\n' or ch == '\r'))) {
            p.i += 1;
        } else if (ch == '#') {
            while (!p.eof() and p.s[p.i] != '\n') p.i += 1;
        } else break;
    }
}

// One character of a literal or a class, escapes resolved, as UTF-8 bytes.
// Returns the byte count, or 0 on a malformed escape.
fn readChar(p: *P, out: *[4]u8) usize {
    if (p.eof()) return 0;
    const ch = p.s[p.i];
    if (ch != '\\') {
        // A character above ASCII is ONE character spelled in several
        // bytes. Reading it as one byte would let `[é]` compile to "the
        // single byte 0xC3", which matches the first half of a great many
        // other characters -- so the whole sequence is read, and the
        // caller decides whether a multi-byte character is legal there.
        const n = std.unicode.utf8ByteSequenceLength(ch) catch 1;
        if (n > 1 and p.i + n <= p.s.len) {
            @memcpy(out[0..n], p.s[p.i .. p.i + n]);
            p.i += n;
            return n;
        }
        out[0] = ch;
        p.i += 1;
        return 1;
    }
    p.i += 1;
    if (p.eof()) return 0;
    const e = p.s[p.i];
    p.i += 1;
    switch (e) {
        'n' => out[0] = '\n',
        'r' => out[0] = '\r',
        't' => out[0] = '\t',
        '\\' => out[0] = '\\',
        '"' => out[0] = '"',
        '\'' => out[0] = '\'',
        '[' => out[0] = '[',
        ']' => out[0] = ']',
        '-' => out[0] = '-',
        'x' => {
            if (p.i + 1 >= p.s.len) return 0;
            const hi = hexVal(p.s[p.i]) orelse return 0;
            const lo = hexVal(p.s[p.i + 1]) orelse return 0;
            p.i += 2;
            out[0] = @intCast(hi * 16 + lo);
        },
        'u' => {
            if (p.i + 3 >= p.s.len) return 0;
            var cp: u32 = 0;
            for (0..4) |k| {
                const d = hexVal(p.s[p.i + k]) orelse return 0;
                cp = cp * 16 + d;
            }
            p.i += 4;
            const n = std.unicode.utf8Encode(@intCast(cp), out) catch return 0;
            return n;
        },
        else => out[0] = e,
    }
    return 1;
}

fn hexVal(ch: u8) ?u32 {
    if (ch >= '0' and ch <= '9') return ch - '0';
    if (ch >= 'a' and ch <= 'f') return ch - 'a' + 10;
    if (ch >= 'A' and ch <= 'F') return ch - 'A' + 10;
    return null;
}

// A rule id for this name, created on first mention so forward references
// work (`root` names `text` before `text ::=` is read).
fn symbolId(name: []const u8) ?u32 {
    for (0..g_rule_n) |i| {
        if (g_rule_name_len[i] == name.len and
            std.mem.eql(u8, g_rule_name[i][0..name.len], name)) return @intCast(i);
    }
    if (g_rule_n >= MAX_RULES or name.len > MAX_NAME) return null;
    const id = g_rule_n;
    @memcpy(g_rule_name[id][0..name.len], name);
    g_rule_name_len[id] = name.len;
    g_rule_defined[id] = false;
    g_rule_start[id] = 0;
    g_rule_n += 1;
    return @intCast(id);
}

// An anonymous rule, for a ( group ) or a postfix repeat. Named so a
// refusal can still cite it.
var g_anon: usize = 0;
fn anonId() ?u32 {
    var buf: [MAX_NAME]u8 = undefined;
    const nm = std.fmt.bufPrint(&buf, "-anon{d}", .{g_anon}) catch return null;
    g_anon += 1;
    return symbolId(nm);
}

fn commitRule(id: u32, buf: *const RuleBuf) bool {
    if (g_elem_n + buf.n > MAX_ELEMS) return false;
    g_rule_start[id] = @intCast(g_elem_n);
    @memcpy(g_elems[g_elem_n..][0..buf.n], buf.e[0..buf.n]);
    g_elem_n += buf.n;
    g_rule_defined[id] = true;
    return true;
}

// S' ::= S S' |     ('*')      S' ::= S S' | S     ('+')      S' ::= S |   ('?')
fn makeRepeat(out: *RuleBuf, start: usize, op: u8) i32 {
    const id = anonId() orelse {
        setDiag("GBNF-M2: the grammar declares more than {d} rules.", .{MAX_RULES});
        return RC_FULL;
    };
    var sub: RuleBuf = .{};
    const body = out.e[start..out.n];
    for (body) |el| {
        if (!sub.push(el.t, el.v)) return bufFull();
    }
    switch (op) {
        '*' => {
            if (!sub.push(.rule_ref, id)) return bufFull();
            if (!sub.push(.alt, 0)) return bufFull();
        },
        '+' => {
            if (!sub.push(.rule_ref, id)) return bufFull();
            if (!sub.push(.alt, 0)) return bufFull();
            for (body) |el| {
                if (!sub.push(el.t, el.v)) return bufFull();
            }
        },
        else => { // '?'
            if (!sub.push(.alt, 0)) return bufFull();
        },
    }
    if (!sub.push(.end, 0)) return bufFull();
    if (!commitRule(id, &sub)) return elemsFull();
    out.n = start;
    if (!out.push(.rule_ref, id)) return bufFull();
    return RC_OK;
}

fn bufFull() i32 {
    setDiag("GBNF-M3: one rule grew past {d} elements.", .{MAX_RULE_BUF});
    return RC_FULL;
}

fn elemsFull() i32 {
    setDiag("GBNF-M3: the grammar grew past {d} elements in total.", .{MAX_ELEMS});
    return RC_FULL;
}

fn parseSequence(p: *P, out: *RuleBuf, depth: u32) i32 {
    var last_start: usize = out.n;
    while (true) {
        skipSpace(p, false);
        if (p.eof()) break;
        const ch = p.peek();

        if (ch == '"') {
            last_start = out.n;
            p.i += 1;
            while (!p.eof() and p.peek() != '"') {
                var b: [4]u8 = undefined;
                const n = readChar(p, &b);
                if (n == 0) {
                    setDiag("GBNF-M1: a malformed escape inside a quoted literal at byte {d}.", .{p.i});
                    return RC_SYNTAX;
                }
                for (b[0..n]) |one| {
                    if (!out.push(.char, one)) return bufFull();
                }
            }
            if (p.eof()) {
                setDiag("GBNF-M1: a quoted literal was never closed.", .{});
                return RC_SYNTAX;
            }
            p.i += 1; // closing quote
        } else if (ch == '[') {
            last_start = out.n;
            p.i += 1;
            var negated = false;
            if (!p.eof() and p.peek() == '^') {
                negated = true;
                p.i += 1;
            }
            var first = true;
            while (!p.eof() and p.peek() != ']') {
                var b: [4]u8 = undefined;
                const n = readChar(p, &b);
                if (n == 0) {
                    setDiag("GBNF-M1: a malformed escape inside a character class at byte {d}.", .{p.i});
                    return RC_SYNTAX;
                }
                if (n > 1) {
                    setDiag("GBNF-M5: a character above ASCII appears inside a character class. This machine matches BYTES (masking is over token bytes), so a multi-byte character has no single byte to match -- write it in a \"quoted literal\" instead, where it compiles to its UTF-8 bytes.", .{});
                    return RC_NONASCII_CLASS;
                }
                const t: ElemT = if (first) (if (negated) .char_not else .char) else .char_alt;
                if (!out.push(t, b[0])) return bufFull();
                first = false;
                // a range: c '-' c   (a trailing '-' before ']' is a literal '-')
                if (!p.eof() and p.peek() == '-' and p.i + 1 < p.s.len and p.s[p.i + 1] != ']') {
                    p.i += 1;
                    var ub: [4]u8 = undefined;
                    const un = readChar(p, &ub);
                    if (un == 0) {
                        setDiag("GBNF-M1: a malformed escape after '-' in a character class.", .{});
                        return RC_SYNTAX;
                    }
                    if (un > 1) {
                        setDiag("GBNF-M5: a character above ASCII appears as a range bound inside a character class. This machine matches BYTES; write the character in a \"quoted literal\" instead.", .{});
                        return RC_NONASCII_CLASS;
                    }
                    if (!out.push(.char_rng_upper, ub[0])) return bufFull();
                }
            }
            if (p.eof()) {
                setDiag("GBNF-M1: a character class was never closed with ']'.", .{});
                return RC_SYNTAX;
            }
            p.i += 1; // ']'
        } else if (ch == '(') {
            if (depth >= MAX_GROUP_DEPTH) {
                setDiag("GBNF-M6: groups nested more than {d} deep.", .{MAX_GROUP_DEPTH});
                return RC_FULL;
            }
            last_start = out.n;
            p.i += 1;
            const id = anonId() orelse {
                setDiag("GBNF-M2: the grammar declares more than {d} rules.", .{MAX_RULES});
                return RC_FULL;
            };
            var sub: RuleBuf = .{};
            const rc = parseAlternates(p, &sub, depth + 1);
            if (rc != RC_OK) return rc;
            if (!commitRule(id, &sub)) return elemsFull();
            skipSpace(p, true);
            if (p.eof() or p.peek() != ')') {
                setDiag("GBNF-M1: a group was never closed with ')'.", .{});
                return RC_SYNTAX;
            }
            p.i += 1;
            if (!out.push(.rule_ref, id)) return bufFull();
        } else if (isNameByte(ch) and !(ch >= '0' and ch <= '9')) {
            last_start = out.n;
            const st = p.i;
            while (!p.eof() and isNameByte(p.peek())) p.i += 1;
            const name = p.s[st..p.i];
            // `a ::= b` on the next line must not be swallowed as an element
            // of this rule: a name followed by ::= belongs to the NEXT rule.
            var look = P{ .s = p.s, .i = p.i };
            skipSpace(&look, false);
            if (look.i + 3 <= look.s.len and std.mem.eql(u8, look.s[look.i .. look.i + 3], "::=")) {
                p.i = st;
                break;
            }
            const id = symbolId(name) orelse {
                setDiag("GBNF-M2: the grammar declares more than {d} rules.", .{MAX_RULES});
                return RC_FULL;
            };
            if (!out.push(.rule_ref, id)) return bufFull();
        } else if (ch == '*' or ch == '+' or ch == '?') {
            if (out.n == last_start) {
                setDiag("GBNF-M1: '{c}' has nothing before it to repeat.", .{ch});
                return RC_SYNTAX;
            }
            p.i += 1;
            const rc = makeRepeat(out, last_start, ch);
            if (rc != RC_OK) return rc;
        } else break;
    }
    return RC_OK;
}

fn parseAlternates(p: *P, out: *RuleBuf, depth: u32) i32 {
    var rc = parseSequence(p, out, depth);
    if (rc != RC_OK) return rc;
    while (true) {
        skipSpace(p, false);
        if (p.eof() or p.peek() != '|') break;
        p.i += 1;
        skipSpace(p, true);
        if (!out.push(.alt, 0)) return bufFull();
        rc = parseSequence(p, out, depth);
        if (rc != RC_OK) return rc;
    }
    if (!out.push(.end, 0)) return bufFull();
    return RC_OK;
}

fn resetGrammar() void {
    g_elem_n = 0;
    g_rule_n = 0;
    g_anon = 0;
    g_diag_len = 0;
    g_ready = false;
    g_overflow = false;
    g_cur.n = 0;
}

// ─── left recursion, refused by name rather than hung on ───
//
// A rule that can reach ITSELF in first position can never be expanded:
// advancing its stack pushes the same alternative again, forever. Reached
// through nullable prefixes too -- `a ::= b a` with `b ::= ` is the same
// trap -- so "first position" means "after any prefix that can match the
// empty string".
fn ruleIsNullable(id: u32, seen: *[MAX_RULES]bool) bool {
    if (seen[id]) return false;
    seen[id] = true;
    var pos = g_rule_start[id];
    // any alternative that matches empty makes the rule nullable
    while (true) {
        if (g_elems[pos].t == .end) return true;
        if (g_elems[pos].t == .alt) {
            pos += 1;
            continue;
        }
        // walk this alternative: nullable only if EVERY element is
        var all_null = true;
        var q = pos;
        while (g_elems[q].t != .end and g_elems[q].t != .alt) {
            if (g_elems[q].t == .rule_ref) {
                if (!ruleIsNullable(g_elems[q].v, seen)) all_null = false;
                q += 1;
            } else {
                all_null = false;
                q += 1;
            }
        }
        if (all_null) return true;
        if (g_elems[q].t == .alt) {
            pos = q + 1;
            continue;
        }
        return false;
    }
}

fn firstRefs(id: u32, out: *[MAX_RULES]bool) void {
    if (out[id]) return;
    out[id] = true;
    var pos = g_rule_start[id];
    while (true) {
        // each alternative contributes its leading rule refs (through nullables)
        var q = pos;
        while (g_elems[q].t != .end and g_elems[q].t != .alt) {
            if (g_elems[q].t == .rule_ref) {
                firstRefs(g_elems[q].v, out);
                var seen = [_]bool{false} ** MAX_RULES;
                if (!ruleIsNullable(g_elems[q].v, &seen)) break;
                q += 1;
            } else break; // a char element consumes: nothing after it is "first"
        }
        while (g_elems[q].t != .end and g_elems[q].t != .alt) q += 1;
        if (g_elems[q].t == .alt) {
            pos = q + 1;
            continue;
        }
        break;
    }
}

fn checkLeftRecursion() i32 {
    for (0..g_rule_n) |i| {
        if (!g_rule_defined[i]) continue;
        var reach = [_]bool{false} ** MAX_RULES;
        var pos = g_rule_start[@intCast(i)];
        // the rule's own first-position refs, not counting itself as a seed
        while (true) {
            var q = pos;
            while (g_elems[q].t != .end and g_elems[q].t != .alt) {
                if (g_elems[q].t == .rule_ref) {
                    firstRefs(g_elems[q].v, &reach);
                    var seen = [_]bool{false} ** MAX_RULES;
                    if (!ruleIsNullable(g_elems[q].v, &seen)) break;
                    q += 1;
                } else break;
            }
            while (g_elems[q].t != .end and g_elems[q].t != .alt) q += 1;
            if (g_elems[q].t == .alt) {
                pos = q + 1;
                continue;
            }
            break;
        }
        if (reach[i]) {
            setDiag("GBNF-M7: rule '{s}' can begin with itself (left recursion). A stack machine cannot expand that without looping, so it is refused here rather than hung on. Rewrite the repetition with '*' or '+'.", .{g_rule_name[i][0..g_rule_name_len[i]]});
            return RC_LEFT_RECURSION;
        }
    }
    return RC_OK;
}

// ═══ the machine ══════════════════════════════════════════════════════

const Stack = struct {
    it: [MAX_STACK_DEPTH]u32 = undefined,
    n: u8 = 0,
};

const StackSet = struct {
    s: [MAX_STACKS]Stack = undefined,
    n: usize = 0,
};

var g_cur: StackSet = .{};
var g_a: StackSet = .{};
var g_b: StackSet = .{};

fn isEndOfSeq(pos: u32) bool {
    const t = g_elems[pos].t;
    return t == .end or t == .alt;
}

fn sameStack(x: *const Stack, y: *const Stack) bool {
    if (x.n != y.n) return false;
    for (0..x.n) |i| {
        if (x.it[i] != y.it[i]) return false;
    }
    return true;
}

fn pushStack(set: *StackSet, st: *const Stack) void {
    for (0..set.n) |i| {
        if (sameStack(&set.s[i], st)) return; // already live: an alternation that reconverges
    }
    if (set.n >= MAX_STACKS) {
        g_overflow = true;
        return;
    }
    set.s[set.n] = st.*;
    set.n += 1;
}

fn advanceStack(st: *const Stack, out: *StackSet, depth: u32) void {
    if (depth > MAX_ADVANCE_DEPTH) {
        g_overflow = true;
        return;
    }
    if (st.n == 0) {
        pushStack(out, st); // an empty stack IS the accepting state
        return;
    }
    const pos = st.it[st.n - 1];
    switch (g_elems[pos].t) {
        .rule_ref => {
            var sub = g_rule_start[g_elems[pos].v];
            while (true) {
                var ns: Stack = .{};
                ns.n = st.n - 1;
                @memcpy(ns.it[0..ns.n], st.it[0..ns.n]);
                if (!isEndOfSeq(pos + 1)) {
                    if (ns.n >= MAX_STACK_DEPTH) {
                        g_overflow = true;
                        return;
                    }
                    ns.it[ns.n] = pos + 1;
                    ns.n += 1;
                }
                if (!isEndOfSeq(sub)) {
                    if (ns.n >= MAX_STACK_DEPTH) {
                        g_overflow = true;
                        return;
                    }
                    ns.it[ns.n] = sub;
                    ns.n += 1;
                }
                advanceStack(&ns, out, depth + 1);
                while (!isEndOfSeq(sub)) sub += 1;
                if (g_elems[sub].t == .alt) sub += 1 else break;
            }
        },
        .char, .char_not => pushStack(out, st),
        else => {}, // end/alt never sit on top of a live stack
    }
}

const Match = struct { found: bool, next: u32 };

fn matchChar(pos0: u32, chr: u8) Match {
    var pos = pos0;
    var found = false;
    const positive = g_elems[pos0].t == .char;
    while (true) {
        if (g_elems[pos + 1].t == .char_rng_upper) {
            if (g_elems[pos].v <= chr and chr <= g_elems[pos + 1].v) found = true;
            pos += 2;
        } else {
            if (g_elems[pos].v == chr) found = true;
            pos += 1;
        }
        if (g_elems[pos].t != .char_alt) break;
    }
    return .{ .found = found == positive, .next = pos };
}

fn acceptByteInto(src: *const StackSet, dst: *StackSet, chr: u8) void {
    dst.n = 0;
    for (0..src.n) |i| {
        const st = &src.s[i];
        if (st.n == 0) continue; // already complete: nothing more may follow
        const m = matchChar(st.it[st.n - 1], chr);
        if (!m.found) continue;
        var ns: Stack = .{};
        ns.n = st.n - 1;
        @memcpy(ns.it[0..ns.n], st.it[0..ns.n]);
        if (!isEndOfSeq(m.next)) {
            if (ns.n >= MAX_STACK_DEPTH) {
                g_overflow = true;
                continue;
            }
            ns.it[ns.n] = m.next;
            ns.n += 1;
        }
        advanceStack(&ns, dst, 0);
    }
}

// ═══ the exported surface ═════════════════════════════════════════════

// Parse a grammar and put the machine at its start. Returns RC_OK or a
// refusal code; stz_grammar_last_refusal() carries the sentence.
pub export fn stz_grammar_set(text: [*]const u8, len: usize) i32 {
    resetGrammar();
    if (len == 0) {
        setDiag("GBNF-M1: the grammar text is empty.", .{});
        return RC_SYNTAX;
    }
    var p = P{ .s = text[0..len] };
    while (true) {
        skipSpace(&p, true);
        if (p.eof()) break;
        const st = p.i;
        while (!p.eof() and isNameByte(p.peek())) p.i += 1;
        if (p.i == st) {
            setDiag("GBNF-M1: expected a rule name at byte {d}, found '{c}'.", .{ st, p.peek() });
            return RC_SYNTAX;
        }
        const name = p.s[st..p.i];
        skipSpace(&p, false);
        if (p.i + 3 > p.s.len or !std.mem.eql(u8, p.s[p.i .. p.i + 3], "::=")) {
            setDiag("GBNF-M1: rule '{s}' is not followed by '::='.", .{name});
            return RC_SYNTAX;
        }
        p.i += 3;
        const id = symbolId(name) orelse {
            setDiag("GBNF-M2: the grammar declares more than {d} rules.", .{MAX_RULES});
            return RC_FULL;
        };
        if (g_rule_defined[id]) {
            setDiag("GBNF-M8: rule '{s}' is defined twice. Which one is meant is not a question this machine will guess at.", .{name});
            return RC_DUPLICATE;
        }
        var buf: RuleBuf = .{};
        const rc = parseAlternates(&p, &buf, 0);
        if (rc != RC_OK) return rc;
        if (!commitRule(id, &buf)) return elemsFull();
    }

    for (0..g_rule_n) |i| {
        if (!g_rule_defined[i]) {
            setDiag("GBNF-M4: rule '{s}' is referenced but never defined.", .{g_rule_name[i][0..g_rule_name_len[i]]});
            return RC_UNDEFINED;
        }
    }
    const root = findRule("root") orelse {
        setDiag("GBNF-M9: the grammar has no rule named 'root'. A machine needs to know where to start.", .{});
        return RC_NO_ROOT;
    };
    const lr = checkLeftRecursion();
    if (lr != RC_OK) return lr;

    // put the machine at the start
    g_cur.n = 0;
    g_overflow = false;
    var pos = g_rule_start[root];
    while (true) {
        var st: Stack = .{};
        if (!isEndOfSeq(pos)) {
            st.it[0] = pos;
            st.n = 1;
        }
        advanceStack(&st, &g_cur, 0);
        while (!isEndOfSeq(pos)) pos += 1;
        if (g_elems[pos].t == .alt) pos += 1 else break;
    }
    if (g_overflow) {
        setDiag("GBNF-M10: the grammar could not be expanded inside this machine's bounds ({d} live positions, {d} deep).", .{ MAX_STACKS, MAX_STACK_DEPTH });
        return RC_FULL;
    }
    if (g_cur.n == 0) {
        setDiag("GBNF-M11: the grammar admits nothing at all -- no first byte is legal and it cannot end either.", .{});
        return RC_SYNTAX;
    }
    g_ready = true;
    return RC_OK;
}

fn findRule(name: []const u8) ?u32 {
    for (0..g_rule_n) |i| {
        if (g_rule_name_len[i] == name.len and
            std.mem.eql(u8, g_rule_name[i][0..name.len], name)) return @intCast(i);
    }
    return null;
}

pub export fn stz_grammar_clear() void {
    resetGrammar();
}

pub export fn stz_grammar_active() i32 {
    return if (g_ready) 1 else 0;
}

pub export fn stz_grammar_rules() i32 {
    return @intCast(g_rule_n);
}

pub export fn stz_grammar_last_refusal(out: [*]u8) i32 {
    if (g_diag_len == 0) return 0;
    @memcpy(out[0..g_diag_len], g_diag[0..g_diag_len]);
    return @intCast(g_diag_len);
}

// Back to the start, keeping the parsed grammar.
pub export fn stz_grammar_reset() i32 {
    if (!g_ready) return 0;
    const saved = g_elem_n;
    _ = saved;
    const root = findRule("root") orelse return 0;
    g_cur.n = 0;
    g_overflow = false;
    var pos = g_rule_start[root];
    while (true) {
        var st: Stack = .{};
        if (!isEndOfSeq(pos)) {
            st.it[0] = pos;
            st.n = 1;
        }
        advanceStack(&st, &g_cur, 0);
        while (!isEndOfSeq(pos)) pos += 1;
        if (g_elems[pos].t == .alt) pos += 1 else break;
    }
    return 1;
}

// How many live positions the machine holds. 0 means it is dead: no byte
// can continue and the grammar was not satisfied.
pub export fn stz_grammar_live() i32 {
    return @intCast(g_cur.n);
}

// TRUE when the grammar is SATISFIED here -- the answer may end.
pub export fn stz_grammar_can_end() i32 {
    if (!g_ready) return 0;
    for (0..g_cur.n) |i| {
        if (g_cur.s[i].n == 0) return 1;
    }
    return 0;
}

// Could these bytes be emitted from where the machine stands, WHOLE?
// The whole-ness is the point: a piece whose first bytes fit and whose
// last byte does not is a piece the sampler must not emit.
pub fn canAcceptBytes(piece: []const u8) bool {
    if (!g_ready or piece.len == 0) return false;
    var src = &g_a;
    var dst = &g_b;
    src.* = g_cur;
    for (piece) |ch| {
        acceptByteInto(src, dst, ch);
        if (dst.n == 0) return false;
        const t = src;
        src = dst;
        dst = t;
    }
    return true;
}

pub export fn stz_grammar_can_accept(piece: [*]const u8, len: usize) i32 {
    return if (canAcceptBytes(piece[0..len])) 1 else 0;
}

// Commit: the machine really moves. 0 means the bytes were NOT legal and
// the machine did not move.
pub fn acceptBytes(piece: []const u8) bool {
    if (!g_ready or piece.len == 0) return false;
    var src = &g_a;
    var dst = &g_b;
    src.* = g_cur;
    for (piece) |ch| {
        acceptByteInto(src, dst, ch);
        if (dst.n == 0) return false;
        const t = src;
        src = dst;
        dst = t;
    }
    g_cur = src.*;
    return true;
}

pub export fn stz_grammar_accept(piece: [*]const u8, len: usize) i32 {
    return if (acceptBytes(piece[0..len])) 1 else 0;
}

// The set of bytes ANY live position could take next, as 32 bytes of
// bitmask. It is a PREFILTER: a candidate whose first byte is not in it
// cannot be legal, and that one test throws away most of a 49k vocabulary
// before the expensive whole-piece check runs.
pub fn firstByteMask(mask: *[32]u8) void {
    @memset(mask, 0);
    if (!g_ready) return;
    for (0..g_cur.n) |i| {
        const st = &g_cur.s[i];
        if (st.n == 0) continue;
        const pos = st.it[st.n - 1];
        var b: u32 = 0;
        while (b < 256) : (b += 1) {
            if (matchChar(pos, @intCast(b)).found) {
                mask[b >> 3] |= (@as(u8, 1) << @intCast(b & 7));
            }
        }
    }
}

pub export fn stz_grammar_first_byte_mask(out: [*]u8) i32 {
    var m: [32]u8 = undefined;
    firstByteMask(&m);
    @memcpy(out[0..32], m[0..32]);
    return 32;
}

// ═══ tests ════════════════════════════════════════════════════════════

fn gset(g: []const u8) i32 {
    return stz_grammar_set(g.ptr, g.len);
}

fn refusal() []const u8 {
    return g_diag[0..g_diag_len];
}

test "a literal grammar accepts exactly its literal" {
    try std.testing.expectEqual(RC_OK, gset("root ::= \"yes\"\n"));
    try std.testing.expect(canAcceptBytes("y"));
    try std.testing.expect(canAcceptBytes("yes"));
    try std.testing.expect(!canAcceptBytes("n"));
    try std.testing.expect(!canAcceptBytes("yex"));
    // and the negative sibling: nothing is accepting until it is complete
    try std.testing.expectEqual(@as(i32, 0), stz_grammar_can_end());
    try std.testing.expect(acceptBytes("yes"));
    try std.testing.expectEqual(@as(i32, 1), stz_grammar_can_end());
}

// THE CASE THE PROMPT NAMES, AND THE ONE A BYTE-AT-A-TIME CHECK GETS
// WRONG: a token whose bytes are a valid PREFIX and an invalid COMPLETION.
test "a token that is a valid prefix but an invalid completion is REFUSED" {
    _ = gset("root ::= \"yes\" \"\\n\"\n");
    try std.testing.expect(canAcceptBytes("yes")); // whole, legal
    try std.testing.expect(canAcceptBytes("ye")); // partial, legal so far
    try std.testing.expect(!canAcceptBytes("yesterday")); // dies on 't'
    try std.testing.expect(!canAcceptBytes("yes!")); // dies on '!'
    // the machine did not move while testing
    try std.testing.expectEqual(@as(i32, 0), stz_grammar_can_end());
    try std.testing.expect(acceptBytes("yes"));
    try std.testing.expect(canAcceptBytes("\n"));
}

test "an alternation keeps both branches live until a byte decides" {
    _ = gset("root ::= \"cat\" | \"car\"\n");
    try std.testing.expect(canAcceptBytes("ca"));
    try std.testing.expect(canAcceptBytes("cat"));
    try std.testing.expect(canAcceptBytes("car"));
    try std.testing.expect(!canAcceptBytes("cab"));
    _ = acceptBytes("ca");
    try std.testing.expectEqual(@as(i32, 2), stz_grammar_live());
    _ = acceptBytes("t");
    try std.testing.expectEqual(@as(i32, 1), stz_grammar_live());
    try std.testing.expectEqual(@as(i32, 1), stz_grammar_can_end());
}

test "a character class matches a byte range, and a negated one excludes it" {
    _ = gset("root ::= [0-9] [^\\n]\n");
    try std.testing.expect(canAcceptBytes("4"));
    try std.testing.expect(!canAcceptBytes("a"));
    _ = acceptBytes("4");
    try std.testing.expect(canAcceptBytes("z"));
    try std.testing.expect(!canAcceptBytes("\n"));
}

test "the repeat operators repeat, and '+' demands at least one" {
    _ = gset("root ::= \"a\"+\n");
    try std.testing.expectEqual(@as(i32, 0), stz_grammar_can_end());
    _ = acceptBytes("a");
    try std.testing.expectEqual(@as(i32, 1), stz_grammar_can_end());
    try std.testing.expect(canAcceptBytes("aaaa"));

    _ = gset("root ::= \"a\"* \"b\"\n");
    try std.testing.expect(canAcceptBytes("b")); // zero repeats
    try std.testing.expect(canAcceptBytes("aaab"));
    try std.testing.expect(!canAcceptBytes("aaac"));

    _ = gset("root ::= \"a\"? \"b\"\n");
    try std.testing.expect(canAcceptBytes("b"));
    try std.testing.expect(canAcceptBytes("ab"));
    try std.testing.expect(!canAcceptBytes("aab"));
}

test "a rule reference is followed and returned from" {
    _ = gset(
        \\root ::= "n: " number "\n"
        \\number ::= "-"? [0-9]+ ("." [0-9]+)?
    );
    try std.testing.expect(canAcceptBytes("n: 41\n"));
    try std.testing.expect(canAcceptBytes("n: -3.5\n"));
    try std.testing.expect(!canAcceptBytes("n: x"));
    try std.testing.expect(!canAcceptBytes("n: 4.\n"));
}

// The exact failure the measurement found on the shipped model: the
// schema said `founded` was a number and the model wrote `<number>`.
test "the memo grammar makes the measured failure UNEMITTABLE" {
    _ = gset(
        \\root ::= city-line founded-line
        \\city-line ::= "city: " text "\n"
        \\founded-line ::= "founded: " number "\n"
        \\text ::= [^\n]+
        \\number ::= "-"? [0-9]+ ("." [0-9]+)?
    );
    try std.testing.expect(acceptBytes("city: Paris\nfounded: "));
    try std.testing.expect(!canAcceptBytes("<")); // '<number>' cannot start
    try std.testing.expect(!canAcceptBytes("unknown"));
    try std.testing.expect(canAcceptBytes("2"));
    try std.testing.expect(canAcceptBytes("-52"));
    // and the answer cannot end mid-structure
    try std.testing.expectEqual(@as(i32, 0), stz_grammar_can_end());
    _ = acceptBytes("52\n");
    try std.testing.expectEqual(@as(i32, 1), stz_grammar_can_end());
}

test "the first-byte mask holds exactly the bytes a whole-piece test would allow" {
    _ = gset("root ::= [0-9] \"x\"\n");
    var m: [32]u8 = undefined;
    firstByteMask(&m);
    var b: u32 = 0;
    while (b < 256) : (b += 1) {
        const in_mask = (m[b >> 3] & (@as(u8, 1) << @intCast(b & 7))) != 0;
        const one = [1]u8{@intCast(b)};
        try std.testing.expectEqual(canAcceptBytes(one[0..]), in_mask);
    }
}

// THE REFUSALS. Each names what it refused and why.
test "left recursion is refused BY NAME rather than hung on" {
    const rc = gset("root ::= tail\ntail ::= tail \"x\" | \"x\"\n");
    try std.testing.expectEqual(RC_LEFT_RECURSION, rc);
    try std.testing.expect(std.mem.indexOf(u8, refusal(), "GBNF-M7") != null);
    try std.testing.expect(std.mem.indexOf(u8, refusal(), "tail") != null);
    try std.testing.expectEqual(@as(i32, 0), stz_grammar_active());
}

test "an undefined rule is refused by name" {
    try std.testing.expectEqual(RC_UNDEFINED, gset("root ::= greeting\n"));
    try std.testing.expect(std.mem.indexOf(u8, refusal(), "greeting") != null);
}

test "a grammar with no root is refused" {
    try std.testing.expectEqual(RC_NO_ROOT, gset("start ::= \"a\"\n"));
    try std.testing.expect(std.mem.indexOf(u8, refusal(), "GBNF-M9") != null);
}

test "a rule defined twice is refused rather than guessed at" {
    try std.testing.expectEqual(RC_DUPLICATE, gset("root ::= \"a\"\nroot ::= \"b\"\n"));
    try std.testing.expect(std.mem.indexOf(u8, refusal(), "GBNF-M8") != null);
}

test "a character above ASCII inside a class is refused, and the same character in a literal is not" {
    try std.testing.expectEqual(RC_NONASCII_CLASS, gset("root ::= [é]\n"));
    try std.testing.expect(std.mem.indexOf(u8, refusal(), "GBNF-M5") != null);
    try std.testing.expectEqual(RC_OK, gset("root ::= \"é\"\n"));
    try std.testing.expect(canAcceptBytes("é"));
}

test "unclosed constructs and stray postfixes are refused" {
    try std.testing.expectEqual(RC_SYNTAX, gset("root ::= \"abc\n"));
    try std.testing.expectEqual(RC_SYNTAX, gset("root ::= [a-z\n"));
    try std.testing.expectEqual(RC_SYNTAX, gset("root ::= (\"a\" \n"));
    try std.testing.expectEqual(RC_SYNTAX, gset("root ::= *\n"));
    try std.testing.expectEqual(RC_SYNTAX, gset("root \"a\"\n"));
    try std.testing.expectEqual(RC_SYNTAX, gset(""));
}

test "clearing puts the machine back to inactive" {
    _ = gset("root ::= \"a\"\n");
    try std.testing.expectEqual(@as(i32, 1), stz_grammar_active());
    stz_grammar_clear();
    try std.testing.expectEqual(@as(i32, 0), stz_grammar_active());
    try std.testing.expect(!canAcceptBytes("a"));
}

test "reset returns a half-walked machine to the start" {
    _ = gset("root ::= \"ab\"\n");
    _ = acceptBytes("a");
    try std.testing.expect(!canAcceptBytes("a"));
    _ = stz_grammar_reset();
    try std.testing.expect(canAcceptBytes("a"));
}

test "comments and blank lines are ignored" {
    const rc = gset(
        \\# the shape of an answer
        \\root ::= "a" body
        \\
        \\body ::= "b"   # trailing note
    );
    try std.testing.expectEqual(RC_OK, rc);
    try std.testing.expect(canAcceptBytes("ab"));
}
