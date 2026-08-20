const std = @import("std");

// ═══════════════════════════════════════════════════════════════════════
//  SCHEMA -> GBNF -- the grammar half of the structured-output rung
// ═══════════════════════════════════════════════════════════════════════
//
// base/neural/stzOutputSchema.ring declares a structure and CHECKS what the
// model already said. This file compiles that same declaration into a
// grammar, which is the artifact a sampler needs to make a violating token
// unemittable rather than caught.
//
// WHY IT MATTERS, MEASURED RATHER THAN ASSUMED. Against the model this
// repository ships (smollm2-135m-instruct-q8_0), ten structured prompts:
//
//     first attempt valid          2 / 10
//     valid within four attempts   6 / 10
//     attempts per valid answer    5.0
//     never valid at all           4 / 10
//
// Five model calls per answer, and four inputs in ten that no number of
// retries rescues. That is the case for this rung, and it is a measurement
// (base/test/neural/_measure_structured.ring) rather than a belief.
//
// ─── WHAT A GRAMMAR CANNOT CARRY, SAID OUT LOUD ───────────────────────
//
// THE MOST IMPORTANT LINE IN THIS FILE. A grammar constrains SHAPE. It
// cannot constrain VALUE: no context-free rule says "this number is
// between 0 and 130". So every `:must` clause in a declaration is dropped
// by this compiler -- and dropping it silently would be the worst outcome
// available, because the surface above would report "constrained" while the
// band went unenforced.
//
// So the compiler REFUSES to be quiet about it: stz_gbnf_unenforced()
// lists, by field and by operator, every constraint the emitted grammar
// does NOT carry. The Ring-side court in stzOutputSchema therefore stays
// after constrained decoding lands -- it is not made redundant by it, it is
// the half that checks what a grammar structurally cannot.
//
// AND THE OTHER HALF OF THE HONESTY: stz_gbnf_decoding_supported() answers
// whether anything actually CONSTRAINS DECODING with this grammar. Compiling
// a grammar and constraining a sampler are two rungs, and a caller must be
// able to tell which one it got. It answered 0 for as long as that was true;
// gbnf_machine.zig is the second rung, so it answers 1 now.

const MAX_FIELDS: usize = 64;
const MAX_NAME: usize = 64;
const MAX_CHOICES: usize = 512;
const MAX_OUT: usize = 8192;
const MAX_DIAG: usize = 512;
const MAX_UNENF: usize = 1024;

pub const T_STRING: i32 = 0;
pub const T_NUMBER: i32 = 1;
pub const T_BOOLEAN: i32 = 2;
pub const T_ONEOF: i32 = 3;
pub const T_LIST: i32 = 4;
pub const T_STRUCTURE: i32 = 5;

const Field = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    ftype: i32 = T_STRING,
    required: bool = true,
    of: i32 = T_STRING, // element type for a list
    choices: [MAX_CHOICES]u8 = undefined, // comma-separated, for oneof
    choices_len: usize = 0,
    musts: [MAX_CHOICES]u8 = undefined, // comma-separated op names, for the report
    musts_len: usize = 0,
};

var fields: [MAX_FIELDS]Field = [_]Field{.{}} ** MAX_FIELDS;
var field_count: usize = 0;

var out_buf: [MAX_OUT]u8 = undefined;
var out_len: usize = 0;

var diag: [MAX_DIAG]u8 = undefined;
var diag_len: usize = 0;

var unenf: [MAX_UNENF]u8 = undefined;
var unenf_len: usize = 0;

pub const RC_OK: i32 = 0;
pub const RC_FULL: i32 = -1;
pub const RC_NO_FIELDS: i32 = -2;
pub const RC_BAD_TYPE: i32 = -3;
pub const RC_NO_CHOICES: i32 = -4;
pub const RC_NESTED: i32 = -5;
pub const RC_OVERFLOW: i32 = -6;
pub const RC_BAD_NAME: i32 = -7;

fn setDiag(comptime fmt: []const u8, args: anytype) void {
    var fbs = std.io.fixedBufferStream(&diag);
    fbs.writer().print(fmt, args) catch {};
    diag_len = fbs.pos;
}

// ─── declaring the schema, one field at a time ───

pub export fn stz_gbnf_begin() void {
    field_count = 0;
    out_len = 0;
    diag_len = 0;
    unenf_len = 0;
}

pub export fn stz_gbnf_field(
    name: [*]const u8,
    name_len: usize,
    ftype: i32,
    required: i32,
    of: i32,
    choices: [*]const u8,
    choices_len: usize,
    musts: [*]const u8,
    musts_len: usize,
) i32 {
    if (field_count >= MAX_FIELDS) {
        setDiag("GBNF-F1: more than {d} fields; the compiler holds {d}.", .{ MAX_FIELDS, MAX_FIELDS });
        return RC_FULL;
    }
    if (name_len == 0 or name_len > MAX_NAME) {
        setDiag("GBNF-F7: a field name of {d} bytes cannot be compiled (1..{d}).", .{ name_len, MAX_NAME });
        return RC_BAD_NAME;
    }
    if (ftype < T_STRING or ftype > T_STRUCTURE) {
        setDiag("GBNF-F3: field type {d} is not a type this compiler knows.", .{ftype});
        return RC_BAD_TYPE;
    }
    // A nested structure is a legal DECLARATION and this compiler does not
    // emit it. Refused BY NAME rather than flattened, because a grammar
    // that quietly drops a nested field would accept text the schema
    // refuses -- the two layers must not disagree about what is legal.
    if (ftype == T_STRUCTURE or (ftype == T_LIST and of == T_STRUCTURE)) {
        var fbs = std.io.fixedBufferStream(&diag);
        fbs.writer().print("GBNF-F5: field '{s}' is a nested structure. This compiler emits FLAT memo grammars only, and refuses rather than emitting a grammar that would accept what the schema rejects. Validate this schema with the Ring court instead, or flatten it.", .{name[0..name_len]}) catch {};
        diag_len = fbs.pos;
        return RC_NESTED;
    }
    if (ftype == T_ONEOF and choices_len == 0) {
        var fbs = std.io.fixedBufferStream(&diag);
        fbs.writer().print("GBNF-F4: field '{s}' is a closed enumeration with no choices; there is nothing to alternate.", .{name[0..name_len]}) catch {};
        diag_len = fbs.pos;
        return RC_NO_CHOICES;
    }

    var f = &fields[field_count];
    f.* = .{};
    @memcpy(f.name[0..name_len], name[0..name_len]);
    f.name_len = name_len;
    f.ftype = ftype;
    f.required = required != 0;
    f.of = of;
    const cl = @min(choices_len, MAX_CHOICES);
    @memcpy(f.choices[0..cl], choices[0..cl]);
    f.choices_len = cl;
    const ml = @min(musts_len, MAX_CHOICES);
    @memcpy(f.musts[0..ml], musts[0..ml]);
    f.musts_len = ml;
    field_count += 1;
    return RC_OK;
}

// ─── emitting ───

const W = std.io.FixedBufferStream([]u8).Writer;

fn ruleNameInto(w: anytype, f: *const Field) !void {
    // GBNF rule names take [a-zA-Z0-9-]; fold anything else to '-'
    for (f.name[0..f.name_len]) |ch| {
        const ok = (ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z') or
            (ch >= '0' and ch <= '9') or ch == '-';
        try w.writeByte(if (ok) ch else '-');
    }
}

// A newline inside a quoted terminal must be written as the two
// characters backslash-n, not as a raw 0x0A -- a raw one ENDS the
// terminal and splits the rule across two lines, which is not the
// grammar anybody meant. Found by reading the emitted text, which is
// why there is now a test that reads it too.
fn emitLiteral(w: anytype, s: []const u8) !void {
    try w.writeByte('"');
    for (s) |ch| {
        switch (ch) {
            '"', '\\' => {
                try w.writeByte('\\');
                try w.writeByte(ch);
            },
            '\n' => try w.writeAll("\\n"),
            '\r' => try w.writeAll("\\r"),
            '\t' => try w.writeAll("\\t"),
            else => try w.writeByte(ch),
        }
    }
    try w.writeByte('"');
}

// The value production for one field, in the MEMO shape the prompt clause
// actually asks the model for ("name: value" lines).
fn emitValue(w: anytype, f: *const Field) !void {
    switch (f.ftype) {
        T_NUMBER => try w.writeAll("number"),
        T_BOOLEAN => try w.writeAll("boolean"),
        T_ONEOF => {
            var it = std.mem.splitScalar(u8, f.choices[0..f.choices_len], ',');
            var first = true;
            try w.writeAll("(");
            while (it.next()) |ch| {
                const t = std.mem.trim(u8, ch, " ");
                if (t.len == 0) continue;
                if (!first) try w.writeAll(" | ");
                try emitLiteral(w, t);
                first = false;
            }
            try w.writeAll(")");
        },
        else => try w.writeAll("text"),
    }
}

pub export fn stz_gbnf_compile() i32 {
    out_len = 0;
    unenf_len = 0;
    diag_len = 0;

    if (field_count == 0) {
        setDiag("GBNF-F2: no fields were declared; there is no grammar to emit.", .{});
        return RC_NO_FIELDS;
    }

    var fbs = std.io.fixedBufferStream(&out_buf);
    const w = fbs.writer();

    // root
    w.writeAll("root ::=") catch return overflow();
    for (0..field_count) |i| {
        w.writeAll(" ") catch return overflow();
        ruleNameInto(w, &fields[i]) catch return overflow();
        w.writeAll("-line") catch return overflow();
        if (!fields[i].required) w.writeAll("?") catch return overflow();
    }
    w.writeAll("\n") catch return overflow();

    // one rule per field
    for (0..field_count) |i| {
        const f = &fields[i];
        ruleNameInto(w, f) catch return overflow();
        w.writeAll("-line ::= ") catch return overflow();

        if (f.ftype == T_LIST) {
            // "tags:\n" then one "  - value" line per element
            var head: [MAX_NAME + 2]u8 = undefined;
            @memcpy(head[0..f.name_len], f.name[0..f.name_len]);
            head[f.name_len] = ':';
            head[f.name_len + 1] = '\n';
            emitLiteral(w, head[0 .. f.name_len + 2]) catch return overflow();
            w.writeAll(" (\"  - \" ") catch return overflow();
            switch (f.of) {
                T_NUMBER => w.writeAll("number") catch return overflow(),
                T_BOOLEAN => w.writeAll("boolean") catch return overflow(),
                else => w.writeAll("text") catch return overflow(),
            }
            const tail = if (f.required) " \"\\n\")+\n" else " \"\\n\")*\n";
            w.writeAll(tail) catch return overflow();
        } else {
            var head: [MAX_NAME + 2]u8 = undefined;
            @memcpy(head[0..f.name_len], f.name[0..f.name_len]);
            head[f.name_len] = ':';
            head[f.name_len + 1] = ' ';
            emitLiteral(w, head[0 .. f.name_len + 2]) catch return overflow();
            w.writeAll(" ") catch return overflow();
            emitValue(w, f) catch return overflow();
            w.writeAll(" \"\\n\"\n") catch return overflow();
        }
    }

    // the shared terminals
    w.writeAll("text ::= [^\\n]+\n") catch return overflow();
    w.writeAll("number ::= \"-\"? [0-9]+ (\".\" [0-9]+)?\n") catch return overflow();
    w.writeAll("boolean ::= (\"yes\" | \"no\" | \"true\" | \"false\")\n") catch return overflow();

    out_len = fbs.pos;

    // and the report of what this grammar does NOT carry
    var ufbs = std.io.fixedBufferStream(&unenf);
    const uw = ufbs.writer();
    for (0..field_count) |i| {
        const f = &fields[i];
        if (f.musts_len == 0) continue;
        var it = std.mem.splitScalar(u8, f.musts[0..f.musts_len], ',');
        while (it.next()) |m| {
            const t = std.mem.trim(u8, m, " ");
            if (t.len == 0) continue;
            uw.print("{s}: '{s}' is NOT enforced by the grammar (a grammar constrains shape, never value) -- the Ring court still checks it.\n", .{ f.name[0..f.name_len], t }) catch {};
        }
    }
    unenf_len = ufbs.pos;

    return RC_OK;
}

fn overflow() i32 {
    setDiag("GBNF-F6: the emitted grammar exceeded {d} bytes.", .{MAX_OUT});
    out_len = 0;
    return RC_OVERFLOW;
}

pub export fn stz_gbnf_text(out: [*]u8) i32 {
    if (out_len == 0) return 0;
    @memcpy(out[0..out_len], out_buf[0..out_len]);
    return @intCast(out_len);
}

pub export fn stz_gbnf_last_refusal(out: [*]u8) i32 {
    if (diag_len == 0) return 0;
    @memcpy(out[0..diag_len], diag[0..diag_len]);
    return @intCast(diag_len);
}

// Every constraint the emitted grammar does NOT carry, by field and by
// operator. Empty means the grammar carries everything the schema declared.
pub export fn stz_gbnf_unenforced(out: [*]u8) i32 {
    if (unenf_len == 0) return 0;
    @memcpy(out[0..unenf_len], unenf[0..unenf_len]);
    return @intCast(unenf_len);
}

// ─── the honest report (prompt 42 item 3, answered by prompt 43) ───
//
// Does anything CONSTRAIN DECODING with this grammar? YES, since
// gbnf_machine.zig landed: the sampler in neural_gen.zig judges every
// candidate against the grammar and draws only from the survivors.
//
// This answer stayed 0 for as long as it was true, and that was the point
// of it. It says 1 now because the rung underneath it exists -- not because
// a grammar exists, which was never the same claim.
pub export fn stz_gbnf_decoding_supported() i32 {
    return 1;
}

pub export fn stz_gbnf_decoding_status(out: [*]u8) i32 {
    const s =
        "CONSTRAINED. A grammar installed with StzGenerateXT([:Grammar = ...]) " ++
        "is enforced AT THE SAMPLER: every candidate token is judged against a " ++
        "GBNF stack machine and a token whose bytes cannot continue the grammar " ++
        "is never drawn -- unemittable, not caught afterwards. A token whose " ++
        "bytes are a valid PREFIX and an invalid completion is refused too: the " ++
        "whole piece must survive. End-of-generation is legal only where the " ++
        "grammar is satisfied. " ++
        "WHAT IT DOES NOT DO: it constrains SHAPE, never VALUE and never TRUTH. " ++
        "No context-free rule says 'between 0 and 130', so every :must clause is " ++
        "still checked by the Ring court in stzOutputSchema, and " ++
        "UnenforcedByGrammar() lists them by name. A schema-valid lie is still a " ++
        "lie. Nested structures, left recursion and non-ASCII character classes " ++
        "are refused by name rather than approximated.";
    @memcpy(out[0..s.len], s);
    return @intCast(s.len);
}

// ═══ tests ════════════════════════════════════════════════════════════

fn field(name: []const u8, t: i32, req: i32, of: i32, choices: []const u8, musts: []const u8) i32 {
    return stz_gbnf_field(name.ptr, name.len, t, req, of, choices.ptr, choices.len, musts.ptr, musts.len);
}

fn text() []const u8 {
    return out_buf[0..out_len];
}

test "a flat schema compiles to a grammar with a rule per field" {
    stz_gbnf_begin();
    try std.testing.expectEqual(RC_OK, field("city", T_STRING, 1, 0, "", ""));
    try std.testing.expectEqual(RC_OK, field("founded", T_NUMBER, 1, 0, "", ""));
    try std.testing.expectEqual(RC_OK, stz_gbnf_compile());

    const g = text();
    try std.testing.expect(std.mem.indexOf(u8, g, "root ::= city-line founded-line") != null);
    try std.testing.expect(std.mem.indexOf(u8, g, "city-line ::= \"city: \" text") != null);
    try std.testing.expect(std.mem.indexOf(u8, g, "founded-line ::= \"founded: \" number") != null);
    try std.testing.expect(std.mem.indexOf(u8, g, "number ::= \"-\"? [0-9]+") != null);
}

test "a closed enumeration becomes a closed alternation" {
    stz_gbnf_begin();
    _ = field("mood", T_ONEOF, 1, 0, "positive,negative", "");
    try std.testing.expectEqual(RC_OK, stz_gbnf_compile());
    try std.testing.expect(std.mem.indexOf(u8, text(), "(\"positive\" | \"negative\")") != null);
}

test "an optional field is optional in the root" {
    stz_gbnf_begin();
    _ = field("city", T_STRING, 1, 0, "", "");
    _ = field("note", T_STRING, 0, 0, "", "");
    _ = stz_gbnf_compile();
    try std.testing.expect(std.mem.indexOf(u8, text(), "note-line?") != null);
}

test "a list of scalars repeats; required means at least one" {
    stz_gbnf_begin();
    _ = field("tags", T_LIST, 1, T_STRING, "", "");
    _ = stz_gbnf_compile();
    try std.testing.expect(std.mem.indexOf(u8, text(), "(\"  - \" text \"\\n\")+") != null);

    stz_gbnf_begin();
    _ = field("tags", T_LIST, 0, T_STRING, "", "");
    _ = stz_gbnf_compile();
    try std.testing.expect(std.mem.indexOf(u8, text(), "(\"  - \" text \"\\n\")*") != null);
}

// THE REFUSALS. Each one is a construct the schema can express and the
// grammar cannot -- named, never flattened into something subtly different.
test "a nested structure is REFUSED by name, not flattened" {
    stz_gbnf_begin();
    const rc = field("author", T_STRUCTURE, 1, 0, "", "");
    try std.testing.expectEqual(RC_NESTED, rc);
    var buf: [MAX_DIAG]u8 = undefined;
    const l = stz_gbnf_last_refusal(&buf);
    const d = buf[0..@intCast(l)];
    try std.testing.expect(std.mem.indexOf(u8, d, "GBNF-F5") != null);
    try std.testing.expect(std.mem.indexOf(u8, d, "author") != null);
    try std.testing.expect(std.mem.indexOf(u8, d, "accept what the schema rejects") != null);
}

test "a list OF structures is refused for the same reason" {
    stz_gbnf_begin();
    try std.testing.expectEqual(RC_NESTED, field("steps", T_LIST, 1, T_STRUCTURE, "", ""));
}

test "an enumeration with no choices is refused" {
    stz_gbnf_begin();
    try std.testing.expectEqual(RC_NO_CHOICES, field("mood", T_ONEOF, 1, 0, "", ""));
}

test "compiling nothing is refused rather than emitting an empty grammar" {
    stz_gbnf_begin();
    try std.testing.expectEqual(RC_NO_FIELDS, stz_gbnf_compile());
}

// THE LINE THAT MATTERS MOST: a grammar constrains shape, never value, and
// the compiler says which constraints it dropped.
test "value constraints are reported as UNENFORCED, never dropped in silence" {
    stz_gbnf_begin();
    _ = field("age", T_NUMBER, 1, 0, "", "greaterequal,lessequal");
    _ = field("city", T_STRING, 1, 0, "", "");
    try std.testing.expectEqual(RC_OK, stz_gbnf_compile());

    var buf: [MAX_UNENF]u8 = undefined;
    const l = stz_gbnf_unenforced(&buf);
    try std.testing.expect(l > 0);
    const u = buf[0..@intCast(l)];
    try std.testing.expect(std.mem.indexOf(u8, u, "age") != null);
    try std.testing.expect(std.mem.indexOf(u8, u, "greaterequal") != null);
    try std.testing.expect(std.mem.indexOf(u8, u, "lessequal") != null);
    try std.testing.expect(std.mem.indexOf(u8, u, "never value") != null);
    // and the negative sibling: a field with no :must contributes nothing
    try std.testing.expect(std.mem.indexOf(u8, u, "city") == null);
}

test "a schema with no value constraints reports nothing unenforced" {
    stz_gbnf_begin();
    _ = field("city", T_STRING, 1, 0, "", "");
    _ = stz_gbnf_compile();
    var buf: [MAX_UNENF]u8 = undefined;
    try std.testing.expectEqual(@as(i32, 0), stz_gbnf_unenforced(&buf));
}

// THE ANTI-STUB. Compiling a grammar and constraining a sampler are two
// rungs and a caller must be able to tell which one it got.
test "the build reports that decoding IS constrained, and says what that does not cover" {
    try std.testing.expectEqual(@as(i32, 1), stz_gbnf_decoding_supported());
    var buf: [1024]u8 = undefined;
    const l = stz_gbnf_decoding_status(&buf);
    const s = buf[0..@intCast(l)];
    try std.testing.expect(std.mem.indexOf(u8, s, "CONSTRAINED") != null);
    try std.testing.expect(std.mem.indexOf(u8, s, "unemittable") != null);
    // the coverage statement is not optional: the claim and its limits
    // travel together or the claim is dishonest
    try std.testing.expect(std.mem.indexOf(u8, s, "never VALUE and never TRUTH") != null);
    try std.testing.expect(std.mem.indexOf(u8, s, "UnenforcedByGrammar") != null);
}

// THE DEFECT THE FIRST EMITTER SHIPPED: the list header carried a RAW
// newline inside its quoted terminal, which ends the terminal and splits
// the rule over two lines. Every emitted line must be a whole rule.
test "no emitted terminal contains a raw newline" {
    stz_gbnf_begin();
    _ = field("tags", T_LIST, 1, T_STRING, "", "");
    _ = field("city", T_STRING, 1, 0, "", "");
    _ = stz_gbnf_compile();
    const g = text();
    try std.testing.expect(std.mem.indexOf(u8, g, "\"tags:\\n\"") != null);
    var it = std.mem.splitScalar(u8, g, '\n');
    while (it.next()) |line| {
        if (line.len == 0) continue;
        try std.testing.expect(std.mem.indexOf(u8, line, "::=") != null);
    }
}

test "a field name with awkward characters still yields a legal rule name" {
    stz_gbnf_begin();
    _ = field("first name", T_STRING, 1, 0, "", "");
    _ = stz_gbnf_compile();
    // the LINE prefix keeps the real name; only the RULE name is folded
    try std.testing.expect(std.mem.indexOf(u8, text(), "first-name-line") != null);
    try std.testing.expect(std.mem.indexOf(u8, text(), "\"first name: \"") != null);
}

// ═══ the two halves, checked against each other ═══════════════════════
//
// THE COMPILER AND THE MACHINE MUST AGREE. This file emits GBNF; the
// machine in gbnf_machine.zig parses it and enforces it. A grammar that
// this compiler emits and that machine cannot parse would be a rung
// broken in the middle, and neither file alone would notice -- so the
// check lives here, where the text is produced.
const gm = @import("gbnf_machine.zig");

test "every grammar this compiler emits is one the machine can parse and walk" {
    stz_gbnf_begin();
    _ = field("city", T_STRING, 1, 0, "", "");
    _ = field("mood", T_ONEOF, 1, 0, "positive,negative", "");
    _ = field("founded", T_NUMBER, 1, 0, "", "greaterequal");
    _ = field("tags", T_LIST, 0, T_STRING, "", "");
    try std.testing.expectEqual(RC_OK, stz_gbnf_compile());

    const g = text();
    try std.testing.expectEqual(gm.RC_OK, gm.stz_grammar_set(g.ptr, g.len));

    // and it enforces what the declaration said
    try std.testing.expect(gm.canAcceptBytes("city: Paris\n"));
    try std.testing.expect(!gm.canAcceptBytes("town: Paris\n")); // wrong field name
    _ = gm.acceptBytes("city: Paris\nmood: ");
    try std.testing.expect(gm.canAcceptBytes("positive"));
    try std.testing.expect(!gm.canAcceptBytes("delighted")); // outside the closed set
    _ = gm.acceptBytes("positive\nfounded: ");
    try std.testing.expect(!gm.canAcceptBytes("<")); // the measured failure
    try std.testing.expect(gm.canAcceptBytes("52"));

    // THE VALUE CONSTRAINT IS NOT ENFORCED HERE, and the report says so:
    // 'founded >= 1' passes the grammar at any number.
    _ = gm.acceptBytes("0\n");
    var ub: [MAX_UNENF]u8 = undefined;
    const ul = stz_gbnf_unenforced(&ub);
    try std.testing.expect(std.mem.indexOf(u8, ub[0..@intCast(ul)], "greaterequal") != null);
}

test "an optional field really is optional to the machine, and a required one is not" {
    stz_gbnf_begin();
    _ = field("city", T_STRING, 1, 0, "", "");
    _ = field("note", T_STRING, 0, 0, "", "");
    _ = stz_gbnf_compile();
    const g = text();
    try std.testing.expectEqual(gm.RC_OK, gm.stz_grammar_set(g.ptr, g.len));
    _ = gm.acceptBytes("city: Paris\n");
    try std.testing.expectEqual(@as(i32, 1), gm.stz_grammar_can_end()); // note may be skipped
    try std.testing.expect(gm.canAcceptBytes("note: quiet\n"));

    // the required one, by contrast, cannot be skipped
    stz_gbnf_begin();
    _ = field("city", T_STRING, 1, 0, "", "");
    _ = field("country", T_STRING, 1, 0, "", "");
    _ = stz_gbnf_compile();
    const g2 = text();
    try std.testing.expectEqual(gm.RC_OK, gm.stz_grammar_set(g2.ptr, g2.len));
    _ = gm.acceptBytes("city: Paris\n");
    try std.testing.expectEqual(@as(i32, 0), gm.stz_grammar_can_end());
}
