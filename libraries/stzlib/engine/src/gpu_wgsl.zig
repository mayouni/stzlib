//! The W-string -> WGSL transpiler -- G4's engine substance
//! (SOFTANZA_GPU_PLAN.md; the stzRegexMaker precedent: the user DESCRIBES
//! the computation, the engine generates and validates the kernel).
//!
//! Lives in the ENGINE deliberately: the transpiler is the capability, and
//! any binding gets it -- the Ring stzKernelMaker is one face over this.
//!
//! Input: a line-based SPEC (what the face's declarations collapse into):
//!
//!     in a
//!     in b
//!     scalar alpha
//!     out c
//!     body @c = alpha * @a + @b
//!
//! Output: a complete elementwise WGSL kernel on the ops binding contract
//! (tile uniform @0, params uniform @1 with n + declared scalars, inputs
//! read at @2.., the single output read_write last), workgroup 256.
//!
//! The W lessons apply and are enforced, not hoped for:
//!   - the body is LITERAL: one assignment `@out = expression`; the
//!     expression admits declared names, f32 arithmetic (+ - * / %),
//!     parentheses, numeric literals, commas, and a WHITELISTED function
//!     set. Anything else -- semicolons, indexing, unknown identifiers,
//!     string quotes -- REFUSES with a message naming the offender.
//!   - the transpile is DOCUMENTED BY ITS OUTPUT: the face exposes the
//!     generated WGSL verbatim (ToWGSL), nothing is hidden.
//!
//! Name mangling: vectors become `v_<name>[i]`, scalars `p.s_<name>` --
//! the prefixes keep user names ("in", "let", "p") from colliding with
//! WGSL keywords or the kernel's own identifiers. Names fold to lowercase
//! (Ring is case-insensitive; the kernel must agree with the face).

const std = @import("std");

// ZERO-ALLOCATION by design: this module also compiles into stz.wasm
// (freestanding wasm32, no libc, no allocator) -- the edge authors kernels
// with the SAME code. Everything builds in fixed stack buffers through the
// overflow-checked Cursor below.

const Cursor = struct {
    buf: []u8,
    len: usize = 0,
    overflow: bool = false,

    fn put(self: *Cursor, s: []const u8) void {
        if (self.overflow or self.len + s.len > self.buf.len) {
            self.overflow = true;
            return;
        }
        @memcpy(self.buf[self.len..][0..s.len], s);
        self.len += s.len;
    }

    fn putc(self: *Cursor, ch: u8) void {
        self.put(&[_]u8{ch});
    }

    fn items(self: *const Cursor) []const u8 {
        return self.buf[0..self.len];
    }
};

pub const MAX_VECS = 6; // inputs + the output must fit the 8-buffer dispatch
pub const MAX_SCALARS = 14; // 64-byte params uniform: 8B (n+pad) + 14*4B

const FUNC_WHITELIST = [_][]const u8{
    "abs", "min", "max", "sqrt", "exp", "log", "sin", "cos", "tan",
    "floor", "ceil", "pow", "clamp", "sign", "fract", "round",
    // GK4: the backbone's GELU is written with tanh; a description of it must
    // be able to say so (the fused epilogue that needed it measured within
    // noise and was removed; the word stays, in both readers)
    "tanh",
    // A SURFACE language needs the surface verbs. Without mix and
    // smoothstep a material cannot blend or make a soft edge, which is most
    // of what materials do -- the list was a compute kernel's list.
    "mix", "smoothstep", "step", "dot", "cross", "normalize", "length",
    "distance", "reflect", "atan2", "asin", "acos", "inverseSqrt",
};

var err_buf: [256]u8 = @splat(0);
var err_len: usize = 0;

fn fail(comptime fmt: []const u8, args: anytype) i32 {
    const msg = std.fmt.bufPrint(&err_buf, fmt, args) catch {
        err_len = 0;
        return -1;
    };
    err_len = msg.len;
    return -1;
}

pub fn stz_gpu_wgsl_error(out: [*]u8, cap: f64) callconv(.c) i32 {
    const n = @min(err_len, @as(usize, @intFromFloat(cap)));
    @memcpy(out[0..n], err_buf[0..n]);
    return @intCast(n);
}

const Name = struct {
    buf: [32]u8 = @splat(0),
    len: usize = 0,

    fn slice(self: *const Name) []const u8 {
        return self.buf[0..self.len];
    }
};

fn validIdent(s: []const u8) bool {
    if (s.len == 0 or s.len > 32) return false;
    for (s, 0..) |ch, i| {
        const ok = (ch >= 'a' and ch <= 'z') or ch == '_' or
            (i > 0 and ch >= '0' and ch <= '9');
        if (!ok) return false;
    }
    return true;
}

fn lowerInto(dst: *Name, src: []const u8) bool {
    if (src.len > dst.buf.len) return false;
    for (src, 0..) |ch, i| {
        dst.buf[i] = std.ascii.toLower(ch);
    }
    dst.len = src.len;
    return true;
}

fn nameIn(list: []const Name, count: usize, s: []const u8) ?usize {
    for (0..count) |i| {
        if (std.mem.eql(u8, list[i].slice(), s)) return i;
    }
    return null;
}

/// The declarations a spec makes, and its body's right-hand side -- what
/// the transpiler EMITS and (GK6) what the interpreter EVALUATES, read by
/// one parser so the two can never disagree about what a spec says.
// KP3: workgroup memory. A spec may declare up to MAX_SHARED arrays of f32
// in the group's shared memory, MAX_SHARED_SIZE floats each (4 x 1024 x 4 B =
// 16 KB, WebGPU's default workgroup storage limit), and a SCHEDULE of items
// that run before the body: a STAGE (every thread writes one slot, then a
// barrier), a REDUCE (the halving tree over one array, barriers between its
// steps, the result in slot 0) and, inside a `tiles` loop, an ACCUMULATE (a
// per-thread running value, @acc). Items after the `tiles` line belong to the
// loop; items before it run once.
pub const MAX_SHARED = 4;
pub const MAX_SHARED_SIZE = 1024;
pub const MAX_ITEMS = 12;
pub const GROUP = 256;
pub const TILE = 16; // a `width` kernel's group is a TILE x TILE square of the output

pub const ItemKind = enum(u8) { stage, reduce, accumulate };
pub const ReduceOp = enum(u8) { sum, max, min };
pub const Item = struct {
    kind: ItemKind = .stage,
    shared: usize = 0, // stage / reduce: which array
    index: []const u8 = "", // stage: the slot expression
    value: []const u8 = "", // stage: the value; accumulate: the new @acc
    op: ReduceOp = .sum,
    line: u16 = 0, // GZ0: the description's line, 1-based, for the sanitizer's reports
};

pub const Decl = struct {
    ins: [MAX_VECS]Name = undefined,
    n_ins: usize = 0,
    scalars: [MAX_SCALARS]Name = undefined,
    n_scalars: usize = 0,
    out_name: Name = .{},
    // GL0 (types): which declarations hold ints ('in k int'); f32 otherwise
    in_int: [MAX_VECS]bool = @splat(false),
    sc_int: [MAX_SCALARS]bool = @splat(false),
    out_int: bool = false,
    // GL0 (typed buffers): floats per element, 1 or a vector's 2 to 4. A vecN
    // buffer holds element i at floats N*i .. N*i + N - 1, packed.
    in_w: [MAX_VECS]u8 = @splat(1),
    out_w: u8 = 1,
    rhs: []const u8 = "",
    // KP0: the guard line. null = the engine's default (i < n, as every kernel
    // had before); "none" = the learner omits it; anything else = the
    // learner's own boolean expression over @i, n, the scalars and the inputs.
    guard: ?[]const u8 = null,
    // KP3
    shared: [MAX_SHARED]Name = undefined,
    shared_size: [MAX_SHARED]usize = @splat(0),
    n_shared: usize = 0,
    items: [MAX_ITEMS]Item = undefined,
    n_items: usize = 0,
    loop_from: ?usize = null, // the first item inside the `tiles` loop
    tiles: []const u8 = "", // the loop count expression (empty: no loop)
    tilevar: Name = .{},
    width: []const u8 = "", // a scalar name or a literal (empty: 1-D)
    has_acc: bool = false,
    body_line: u16 = 0, // GZ0
    guard_line: u16 = 0,

    fn sharedIndex(self: *const Decl, s: []const u8) ?usize {
        return nameIn(self.shared[0..], self.n_shared, s);
    }
};

// KP0: names the grammar keeps for itself. `i` is the element index (@i in
// a body), `n` the element count (bare, in a body or a guard). A vector or
// scalar may not take them. KP3 adds the group's names.
fn reservedName(s: []const u8) ?[]const u8 {
    if (std.mem.eql(u8, s, "i")) return "'i' is the element index (@i); it cannot be declared";
    if (std.mem.eql(u8, s, "n")) return "'n' is the element count; it cannot be declared";
    if (std.mem.eql(u8, s, "l")) return "'l' is the thread's index in its group (@l); it cannot be declared";
    if (std.mem.eql(u8, s, "g")) return "'g' is the group's index (@g); it cannot be declared";
    if (std.mem.eql(u8, s, "lx") or std.mem.eql(u8, s, "ly") or std.mem.eql(u8, s, "row") or std.mem.eql(u8, s, "col"))
        return "'lx', 'ly', 'row' and 'col' are the tile's names (@row, @col); they cannot be declared";
    if (std.mem.eql(u8, s, "acc")) return "'acc' is the accumulator (@acc); it cannot be declared";
    return null;
}

fn parseSize(s: []const u8) ?usize {
    if (s.len == 0 or s.len > 6) return null;
    var v: usize = 0;
    for (s) |ch| {
        if (ch < '0' or ch > '9') return null;
        v = v * 10 + (ch - '0');
    }
    return v;
}

fn isPow2(v: usize) bool {
    return v != 0 and (v & (v - 1)) == 0;
}

/// GL0: a declaration's name and its type word: 'k' or 'k float' is a float,
/// 'k int' an int. Null, with the reason, for any other word.
fn declType(rest: []const u8, int: *bool, w: *u8) ?[]const u8 {
    int.* = false;
    w.* = 1;
    const sp = std.mem.indexOfAny(u8, rest, " \t") orelse return rest;
    const ty = std.mem.trim(u8, rest[sp..], " \t");
    if (std.ascii.eqlIgnoreCase(ty, "int")) {
        int.* = true;
    } else if (std.ascii.eqlIgnoreCase(ty, "vec2") or std.ascii.eqlIgnoreCase(ty, "vec3") or std.ascii.eqlIgnoreCase(ty, "vec4")) {
        w.* = ty[3] - '0'; // GL0 (typed buffers)
    } else if (!std.ascii.eqlIgnoreCase(ty, "float")) {
        _ = fail("'{s}' is not a type: a declaration ends with int, float, vec2, vec3 or vec4, or with its name", .{ty});
        return null;
    }
    return rest[0..sp];
}

// `{ ... }` -> the inside, trimmed; the braces are the W-string's and optional
fn unbrace(s: []const u8) []const u8 {
    var b = std.mem.trim(u8, s, " \t");
    if (b.len >= 2 and b[0] == '{' and b[b.len - 1] == '}')
        b = std.mem.trim(u8, b[1 .. b.len - 1], " \t");
    return b;
}

/// Parse the directive lines and the single assignment. Returns 0, or -1
/// with the reason in the error slot. Every refusal message is the one the
/// transpiler has always given; only its home moved.
fn parseDecl(text: []const u8, d: *Decl) i32 {
    var have_out = false;
    var body: []const u8 = "";

    // ---- parse the directive lines
    var lines = std.mem.splitScalar(u8, text, '\n');
    var line_no: u16 = 0;
    while (lines.next()) |raw| {
        line_no +|= 1;
        const line = std.mem.trim(u8, raw, " \t\r");
        if (line.len == 0) continue;
        if (std.mem.startsWith(u8, line, "in ")) {
            var int = false;
            var w: u8 = 1;
            const nm = declType(std.mem.trim(u8, line[3..], " \t"), &int, &w) orelse return -1;
            d.in_int[d.n_ins] = int;
            d.in_w[d.n_ins] = w;
            var lowered: Name = .{};
            if (!lowerInto(&lowered, nm) or !validIdent(lowered.slice()))
                return fail("bad input name: '{s}'", .{nm});
            if (reservedName(lowered.slice())) |why| return fail("{s}", .{why});
            if (d.n_ins == MAX_VECS - 1)
                return fail("too many inputs (max {d})", .{MAX_VECS - 1});
            d.ins[d.n_ins] = lowered;
            d.n_ins += 1;
        } else if (std.mem.startsWith(u8, line, "scalar ")) {
            var int = false;
            var w: u8 = 1;
            const nm = declType(std.mem.trim(u8, line[7..], " \t"), &int, &w) orelse return -1;
            if (w != 1) return fail("a scalar is one number: '{s}' cannot be a vector", .{nm});
            if (d.n_scalars < MAX_SCALARS) d.sc_int[d.n_scalars] = int;
            var lowered: Name = .{};
            if (!lowerInto(&lowered, nm) or !validIdent(lowered.slice()))
                return fail("bad scalar name: '{s}'", .{nm});
            if (reservedName(lowered.slice())) |why| return fail("{s}", .{why});
            if (d.n_scalars == MAX_SCALARS)
                return fail("too many scalars (max {d})", .{MAX_SCALARS});
            d.scalars[d.n_scalars] = lowered;
            d.n_scalars += 1;
        } else if (std.mem.startsWith(u8, line, "out ")) {
            const nm = declType(std.mem.trim(u8, line[4..], " \t"), &d.out_int, &d.out_w) orelse return -1;
            if (have_out) return fail("only one output (ForEachElement writes one vector)", .{});
            if (!lowerInto(&d.out_name, nm) or !validIdent(d.out_name.slice()))
                return fail("bad output name: '{s}'", .{nm});
            if (reservedName(d.out_name.slice())) |why| return fail("{s}", .{why});
            have_out = true;
        } else if (std.mem.startsWith(u8, line, "body ")) {
            body = std.mem.trim(u8, line[5..], " \t");
            d.body_line = line_no;
        } else if (std.mem.startsWith(u8, line, "guard ")) {
            d.guard_line = line_no;
            var g = std.mem.trim(u8, line[6..], " \t");
            if (g.len >= 2 and g[0] == '{' and g[g.len - 1] == '}')
                g = std.mem.trim(u8, g[1 .. g.len - 1], " \t");
            if (g.len == 0) return fail("empty guard (write 'guard none' to omit it)", .{});
            if (d.guard != null) return fail("only one guard line", .{});
            d.guard = g;
        } else if (std.mem.startsWith(u8, line, "shared ")) {
            // KP3: `shared NAME SIZE`
            const rest = std.mem.trim(u8, line[7..], " \t");
            const sp = std.mem.indexOfAny(u8, rest, " \t") orelse
                return fail("shared needs a name and a size: 'shared t 256'", .{});
            var lowered: Name = .{};
            if (!lowerInto(&lowered, rest[0..sp]) or !validIdent(lowered.slice()))
                return fail("bad shared name: '{s}'", .{rest[0..sp]});
            if (reservedName(lowered.slice())) |why| return fail("{s}", .{why});
            if (nameIn(d.ins[0..], d.n_ins, lowered.slice()) != null or nameIn(d.scalars[0..], d.n_scalars, lowered.slice()) != null or
                d.sharedIndex(lowered.slice()) != null)
                return fail("shared '{s}' is already a name here", .{lowered.slice()});
            const size = parseSize(std.mem.trim(u8, rest[sp..], " \t")) orelse
                return fail("shared '{s}' needs a whole number of floats: 'shared {s} 256'", .{ lowered.slice(), lowered.slice() });
            if (size == 0 or size > MAX_SHARED_SIZE)
                return fail("shared '{s}': {d} floats; a group's array holds 1 to {d}", .{ lowered.slice(), size, MAX_SHARED_SIZE });
            if (d.n_shared == MAX_SHARED) return fail("too many shared arrays (max {d})", .{MAX_SHARED});
            var total: usize = size;
            for (0..d.n_shared) |s| total += d.shared_size[s];
            if (total > MAX_SHARED_SIZE * MAX_SHARED)
                return fail("shared memory over {d} floats in all (a group has 16 KB)", .{MAX_SHARED_SIZE * MAX_SHARED});
            d.shared[d.n_shared] = lowered;
            d.shared_size[d.n_shared] = size;
            d.n_shared += 1;
        } else if (std.mem.startsWith(u8, line, "stage ")) {
            // KP3: `stage { @t[index] = value }` -- one write per thread, then a barrier
            const b = unbrace(line[6..]);
            if (b.len == 0 or b[0] != '@') return fail("a stage is '@shared[index] = expression'", .{});
            const eq = std.mem.indexOfScalar(u8, b, '=') orelse return fail("stage has no '='", .{});
            const lhs = std.mem.trim(u8, b[1..eq], " \t");
            const br = std.mem.indexOfScalar(u8, lhs, '[') orelse
                return fail("a stage writes one slot of a shared array: '@t[@l] = ...'", .{});
            var lowered: Name = .{};
            if (!lowerInto(&lowered, std.mem.trim(u8, lhs[0..br], " \t")))
                return fail("bad shared name in the stage", .{});
            const si = d.sharedIndex(lowered.slice()) orelse
                return fail("stage writes '@{s}', which is not a shared array (declare it: 'shared {s} 256')", .{ lowered.slice(), lowered.slice() });
            if (lhs[lhs.len - 1] != ']') return fail("stage's slot is missing ']'", .{});
            const index = std.mem.trim(u8, lhs[br + 1 .. lhs.len - 1], " \t");
            if (index.len == 0) return fail("stage's slot is empty: '@{s}[@l]'", .{lowered.slice()});
            const value = std.mem.trim(u8, b[eq + 1 ..], " \t");
            if (value.len == 0) return fail("stage has no value after '='", .{});
            if (d.n_items == MAX_ITEMS) return fail("too many stages (max {d})", .{MAX_ITEMS});
            d.items[d.n_items] = .{ .kind = .stage, .shared = si, .index = index, .value = value, .line = line_no };
            d.n_items += 1;
        } else if (std.mem.startsWith(u8, line, "reduce ")) {
            // KP3: `reduce NAME sum|max|min`
            const rest = std.mem.trim(u8, line[7..], " \t");
            const sp = std.mem.indexOfAny(u8, rest, " \t") orelse
                return fail("reduce needs an array and an operation: 'reduce t sum'", .{});
            var lowered: Name = .{};
            if (!lowerInto(&lowered, rest[0..sp])) return fail("bad shared name in reduce", .{});
            const si = d.sharedIndex(lowered.slice()) orelse
                return fail("reduce over '{s}', which is not a shared array", .{lowered.slice()});
            if (!isPow2(d.shared_size[si]) or d.shared_size[si] > GROUP)
                return fail("reduce over '{s}' needs a size that is a power of two up to {d}, not {d}", .{ lowered.slice(), GROUP, d.shared_size[si] });
            var opn: Name = .{};
            if (!lowerInto(&opn, std.mem.trim(u8, rest[sp..], " \t"))) return fail("bad reduce operation", .{});
            const op: ReduceOp = if (std.mem.eql(u8, opn.slice(), "sum")) .sum else if (std.mem.eql(u8, opn.slice(), "max")) .max else if (std.mem.eql(u8, opn.slice(), "min")) .min else return fail("reduce knows sum, max and min, not '{s}'", .{opn.slice()});
            if (d.n_items == MAX_ITEMS) return fail("too many stages (max {d})", .{MAX_ITEMS});
            d.items[d.n_items] = .{ .kind = .reduce, .shared = si, .op = op, .line = line_no };
            d.n_items += 1;
        } else if (std.mem.startsWith(u8, line, "accumulate ")) {
            // KP3: `accumulate { @acc = expression }` -- inside the tiles loop only
            if (d.tiles.len == 0) return fail("accumulate belongs inside a tiles loop: write the 'tiles' line first", .{});
            if (d.has_acc) return fail("only one accumulate line", .{});
            const b = unbrace(line[11..]);
            const eq = std.mem.indexOfScalar(u8, b, '=') orelse return fail("accumulate is '@acc = expression'", .{});
            var lowered: Name = .{};
            const lhs = std.mem.trim(u8, b[0..eq], " \t");
            if (lhs.len < 2 or lhs[0] != '@' or !lowerInto(&lowered, lhs[1..]) or !std.mem.eql(u8, lowered.slice(), "acc"))
                return fail("accumulate assigns '@acc', not '{s}'", .{lhs});
            const value = std.mem.trim(u8, b[eq + 1 ..], " \t");
            if (value.len == 0) return fail("accumulate has no value after '='", .{});
            if (d.n_items == MAX_ITEMS) return fail("too many stages (max {d})", .{MAX_ITEMS});
            d.items[d.n_items] = .{ .kind = .accumulate, .value = value, .line = line_no };
            d.n_items += 1;
            d.has_acc = true;
        } else if (std.mem.startsWith(u8, line, "width ")) {
            // KP3: `width w` -- a scalar name or a literal; the output is 2-D, the group a 16x16 tile
            if (d.width.len != 0) return fail("only one width line", .{});
            d.width = std.mem.trim(u8, line[6..], " \t");
            if (d.width.len == 0) return fail("width needs a scalar or a number: 'width w'", .{});
        } else if (std.mem.startsWith(u8, line, "tiles ")) {
            // KP3: `tiles t { count }` -- the items after this line repeat count times
            if (d.tiles.len != 0) return fail("only one tiles line", .{});
            const rest = std.mem.trim(u8, line[6..], " \t");
            const sp = std.mem.indexOfAny(u8, rest, " \t{") orelse
                return fail("tiles needs a variable and a count: 'tiles t {{ k / 16 }}'", .{});
            if (!lowerInto(&d.tilevar, rest[0..sp]) or !validIdent(d.tilevar.slice()))
                return fail("tiles' variable must be a name, got '{s}'", .{rest[0..sp]});
            if (reservedName(d.tilevar.slice()) != null or nameIn(d.ins[0..], d.n_ins, d.tilevar.slice()) != null or
                nameIn(d.scalars[0..], d.n_scalars, d.tilevar.slice()) != null or d.sharedIndex(d.tilevar.slice()) != null)
                return fail("tiles' variable '{s}' is already a name here", .{d.tilevar.slice()});
            const cnt = unbrace(rest[sp..]);
            if (cnt.len == 0) return fail("tiles needs a count: 'tiles t {{ k / 16 }}'", .{});
            d.tiles = cnt;
            d.loop_from = d.n_items;
        } else {
            return fail("unknown spec line: '{s}'", .{line});
        }
    }
    if (!have_out) return fail("no output declared (ReturnsVector missing)", .{});
    if (d.n_ins == 0) return fail("no inputs declared (TakesVector missing)", .{});
    if (body.len == 0) return fail("no body (ForEachElement missing)", .{});
    if (nameIn(d.ins[0..], d.n_ins, d.out_name.slice()) != null)
        return fail("'{s}' is both input and output", .{d.out_name.slice()});
    if (d.tiles.len != 0 and d.loop_from.? == d.n_items)
        return fail("the tiles loop is empty: a stage or an accumulate must follow the tiles line", .{});
    if (d.width.len != 0) {
        if (parseSize(d.width)) |v| {
            if (v == 0 or v % TILE != 0) return fail("width {d} is not a multiple of {d}", .{ v, TILE });
        } else {
            var lowered: Name = .{};
            if (!lowerInto(&lowered, d.width) or nameIn(d.scalars[0..], d.n_scalars, lowered.slice()) == null)
                return fail("width must be a declared scalar or a number, not '{s}'", .{d.width});
        }
    }

    // tolerate the W-string's outer braces: '{ @c = ... }'
    var b = body;
    if (b.len >= 2 and b[0] == '{' and b[b.len - 1] == '}')
        b = std.mem.trim(u8, b[1 .. b.len - 1], " \t");

    // ---- the single assignment: @out = rhs
    if (b.len == 0 or b[0] != '@')
        return fail("body must be '@{s} = expression'", .{d.out_name.slice()});
    const eq = std.mem.indexOfScalar(u8, b, '=') orelse
        return fail("body has no '='", .{});
    const lhs = std.mem.trim(u8, b[1..eq], " \t");
    var lhs_lower: Name = .{};
    if (!lowerInto(&lhs_lower, lhs) or !std.mem.eql(u8, lhs_lower.slice(), d.out_name.slice()))
        return fail("body assigns '@{s}' but the output is '@{s}'", .{ lhs, d.out_name.slice() });
    d.rhs = std.mem.trim(u8, b[eq + 1 ..], " \t");
    if (d.rhs.len == 0) return fail("empty expression", .{});
    return 0;
}

/// GL0 (typed buffers): the output's store. One float per element is the
/// store every kernel always had, byte for byte; a vecN output stores its
/// components at N*i .. N*i + N - 1.
fn putStore(w: *Cursor, d: *const Decl, expr: []const u8) void {
    const o = d.out_name.slice();
    if (d.out_w == 1) {
        w.put("v_");
        w.put(o);
        w.put("[i] = ");
        w.put(expr);
        w.putc(';');
        return;
    }
    w.put("let o_ = ");
    w.put(expr);
    w.putc(';');
    var num: [4]u8 = undefined;
    const ns = std.fmt.bufPrint(&num, "{d}", .{d.out_w}) catch return;
    for (0..d.out_w) |j| {
        w.put(" v_");
        w.put(o);
        w.putc('[');
        w.put(ns);
        w.put("u * i");
        if (j > 0) {
            w.put(" + ");
            w.putc("0123"[j]);
            w.putc('u');
        }
        w.put("] = o_.");
        w.putc("xyzw"[j]);
        w.putc(';');
    }
}

/// A neighbour read of input `name`: 0 (or a zero vector) outside its range.
fn putRd(w: *Cursor, name: []const u8, width: u8) void {
    if (width == 1) {
        w.put("fn rd_");
        w.put(name);
        w.put("(k : i32) -> f32 {\n  if (k < 0 || u32(k) >= arrayLength(&v_");
        w.put(name);
        w.put(")) { return 0.0; }\n  return v_");
        w.put(name);
        w.put("[u32(k)];\n}\n");
        return;
    }
    const ty = if (width == 2) "vec2<f32>" else if (width == 3) "vec3<f32>" else "vec4<f32>";
    var num: [4]u8 = undefined;
    const ns = std.fmt.bufPrint(&num, "{d}", .{width}) catch return;
    w.put("fn rd_");
    w.put(name);
    w.put("(k : i32) -> ");
    w.put(ty);
    w.put(" {\n  if (k < 0 || u32(k) >= arrayLength(&v_");
    w.put(name);
    w.put(") / ");
    w.put(ns);
    w.put("u) { return ");
    w.put(ty);
    w.put("(0.0); }\n  let b = ");
    w.put(ns);
    w.put("u * u32(k);\n  return ");
    w.put(ty);
    w.put("(");
    for (0..width) |j| {
        if (j > 0) w.put(", ");
        w.put("v_");
        w.put(name);
        w.put(if (j == 0) "[b" else "[b + ");
        if (j > 0) {
            w.putc("0123"[j]);
            w.putc('u');
        }
        w.put("]");
    }
    w.put(");\n}\n");
}

fn usesRem(texts: []const []const u8) bool {
    for (texts) |t| {
        if (std.mem.indexOf(u8, t, "stz_rem(") != null) return true;
    }
    return false;
}

fn widthText(d: *const Decl, buf: []u8) ?[]const u8 {
    if (parseSize(d.width)) |v| return std.fmt.bufPrint(buf, "{d}u", .{v}) catch null;
    var lowered: Name = .{};
    if (!lowerInto(&lowered, d.width)) return null;
    return std.fmt.bufPrint(buf, "u32(p.s_{s})", .{lowered.slice()}) catch null;
}

/// KP3: the kernel of a spec that uses the group -- shared arrays, a schedule
/// of stages, reduces and a tiles loop with an accumulator, or the group's own
/// names. Every thread of a group reaches every barrier: the schedule runs
/// for all of them, the guard wraps the body only.
fn emitGroupKernel(w: *Cursor, d: *const Decl, rw: *const Rewriter, expr: []const u8, prelude: []const u8, guard: []const u8, gpre: []const u8, guard_none: bool, guard_custom: bool, items: []const u8) i32 {
    var num: [32]u8 = undefined;
    w.put("struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }\n");
    w.put("@group(0) @binding(0) var<uniform> tile : StzTile;\n");
    w.put("struct P { n : u32, pad : u32");
    for (0..d.n_scalars) |s| {
        w.put(", s_");
        w.put(d.scalars[s].slice());
        w.put(" : f32");
    }
    w.put(" }\n@group(0) @binding(1) var<uniform> p : P;\n");
    var bind: usize = 2;
    for (0..d.n_ins) |s| {
        const ns = std.fmt.bufPrint(&num, "{d}", .{bind}) catch return -1;
        w.put("@group(0) @binding(");
        w.put(ns);
        w.put(") var<storage, read> v_");
        w.put(d.ins[s].slice());
        w.put(" : array<f32>;\n");
        bind += 1;
    }
    {
        const ns = std.fmt.bufPrint(&num, "{d}", .{bind}) catch return -1;
        w.put("@group(0) @binding(");
        w.put(ns);
        w.put(") var<storage, read_write> v_");
        w.put(d.out_name.slice());
        w.put(" : array<f32>;\n");
    }
    for (0..d.n_shared) |s| {
        const ns = std.fmt.bufPrint(&num, "{d}", .{d.shared_size[s]}) catch return -1;
        w.put("var<workgroup> w_");
        w.put(d.shared[s].slice());
        w.put(" : array<f32, ");
        w.put(ns);
        w.put(">;\n");
    }
    if (usesRem(&.{ expr, prelude, guard, gpre, items })) w.put(REM_WGSL);
    for (0..d.n_ins) |s| {
        if (!rw.used_rd[s]) continue;
        putRd(w, d.ins[s].slice(), d.in_w[s]);
    }
    for (0..d.n_shared) |s| {
        if (!rw.used_sh[s]) continue;
        const ns = std.fmt.bufPrint(&num, "{d}", .{d.shared_size[s]}) catch return -1;
        w.put("fn sh_");
        w.put(d.shared[s].slice());
        w.put("(k : i32) -> f32 {\n  if (k < 0 || k >= ");
        w.put(ns);
        w.put(") { return 0.0; }\n  return w_");
        w.put(d.shared[s].slice());
        w.put("[u32(k)];\n}\n");
    }
    w.put("@compute @workgroup_size(256)\n");
    w.put("fn main(@builtin(workgroup_id) wid : vec3<u32>, @builtin(local_invocation_index) l : u32) {\n");
    w.put("  let g = wid.x + tile.xoff;\n");
    if (d.width.len == 0) {
        w.put("  let i = g * 256u + l;\n");
    } else {
        var wb: [64]u8 = undefined;
        const wt = widthText(d, &wb) orelse return fail("bad width '{s}'", .{d.width});
        w.put("  let tpr = ");
        w.put(wt);
        w.put(" / 16u;\n  let row = (g / tpr) * 16u + l / 16u;\n  let col = (g % tpr) * 16u + l % 16u;\n  let i = row * ");
        w.put(wt);
        w.put(" + col;\n");
    }
    w.put("  _ = p.n;\n");
    for (0..d.n_ins) |s| {
        if (rw.used_in[s]) continue;
        w.put("  _ = arrayLength(&v_");
        w.put(d.ins[s].slice());
        w.put(");\n");
    }
    if (d.has_acc) w.put("  var acc : f32 = 0.0;\n");
    // WGSL promises zeroed workgroup memory; wgpu-native 29 on this machine did
    // not give it (measured 2026-10-27: a kernel with no stage read the previous
    // kernel's values on the RTX 3050 and passed the visible shape). The kernel
    // keeps the promise itself, so every runtime means what the interpreter means.
    if (d.n_shared > 0) {
        for (0..d.n_shared) |s| {
            const ns = std.fmt.bufPrint(&num, "{d}", .{d.shared_size[s]}) catch return -1;
            w.put("  for (var z_ : u32 = l; z_ < ");
            w.put(ns);
            w.put("u; z_ = z_ + 256u) { w_");
            w.put(d.shared[s].slice());
            w.put("[z_] = 0.0; }\n");
        }
        w.put("  workgroupBarrier();\n");
    }
    w.put(items);
    if (!guard_none) {
        if (guard_custom) {
            w.put(gpre);
            w.put("  if (");
            w.put(guard);
            w.put(") {\n");
        } else w.put("  if (i < p.n) {\n");
    }
    w.put(prelude);
    w.put("    ");
    putStore(w, d, expr);
    w.put("\n");
    if (!guard_none) w.put("  }\n");
    w.put("}\n");
    if (w.overflow) return fail("kernel too large for the output buffer", .{});
    return @intCast(w.len);
}

/// Transpile a spec into WGSL. Returns the WGSL length written into `out`
/// (capacity `cap`), or -1 with the reason available via stz_gpu_wgsl_error.
/// Pure text work: needs no device, works on a GPU-less machine.
pub fn stz_gpu_wgsl_elementwise(spec: [*]const u8, spec_len: f64, out: [*]u8, cap: f64) callconv(.c) i32 {
    const text = spec[0..@intFromFloat(spec_len)];
    err_len = 0;

    var d: Decl = .{};
    if (parseDecl(text, &d) < 0) return -1;
    const ins = &d.ins;
    const n_ins = d.n_ins;
    const scalars = &d.scalars;
    const n_scalars = d.n_scalars;
    const out_name = d.out_name;
    const rhs = d.rhs;

    // ---- transpile the rhs (and the guard) through the rewriter
    var expr_buf: [4096]u8 = undefined;
    var expr = Cursor{ .buf = &expr_buf };
    var prelude_buf: [4096]u8 = undefined;
    var prelude = Cursor{ .buf = &prelude_buf };
    var rw = Rewriter{ .d = &d, .prelude = &prelude };
    if (d.out_int) expr.put("f32(");
    if (rw.top(rhs, &expr, .body) < 0) return -1;
    if (d.out_int) expr.put(")");
    if (expr.overflow or prelude.overflow) return fail("expression too long", .{});
    var guard_buf: [1024]u8 = undefined;
    var guard = Cursor{ .buf = &guard_buf };
    var gpre_buf: [2048]u8 = undefined;
    var gpre = Cursor{ .buf = &gpre_buf };
    var guard_kind: enum { default, none, custom } = .default;
    if (d.guard) |g| {
        if (std.mem.eql(u8, g, "none")) {
            guard_kind = .none;
        } else {
            guard_kind = .custom;
            if (!condShape(g)) return fail(MSG_COND, .{});
            // GL0 (found by the int fuzz): a sum in the guard writes its loop
            // into a prelude of its own, placed BEFORE the guard's if. In the
            // body's, inside the if, the guard read an accumulator not yet
            // declared, and the device refused every such kernel since KP0.
            rw.where = .guard;
            rw.prelude = &gpre;
            if (rw.top(g, &guard, .guard) < 0) return -1;
            rw.prelude = &prelude;
            rw.where = .body;
            if (gpre.overflow) return fail("guard too long", .{});
            if (guard.overflow) return fail("guard too long", .{});
        }
    }
    // ---- KP3: the schedule, rewritten item by item into one block of text
    var count_buf: [512]u8 = undefined;
    var count = Cursor{ .buf = &count_buf };
    if (d.tiles.len != 0) {
        rw.where = .count;
        if (rw.top(d.tiles, &count, .count) < 0) return -1;
        if (count.overflow) return fail("tiles count too long", .{});
    }
    var items_buf: [12288]u8 = undefined;
    var items = Cursor{ .buf = &items_buf };
    if (d.n_items > 0) {
        var idx_buf: [1024]u8 = undefined;
        var val_buf: [2048]u8 = undefined;
        var pre_buf: [2048]u8 = undefined;
        const body_prelude = rw.prelude;
        for (0..d.n_items) |k| {
            const it = d.items[k];
            const inside = d.loop_from != null and k >= d.loop_from.?;
            const ind: []const u8 = if (inside) "    " else "  ";
            if (d.loop_from) |lf| {
                if (k == lf) {
                    items.put("  for (var t_");
                    items.put(d.tilevar.slice());
                    items.put(" : i32 = 0; t_");
                    items.put(d.tilevar.slice());
                    items.put(" < i32(");
                    items.put(count.items());
                    items.put("); t_");
                    items.put(d.tilevar.slice());
                    items.put(" = t_");
                    items.put(d.tilevar.slice());
                    items.put(" + 1) {\n");
                }
            }
            var idx = Cursor{ .buf = &idx_buf };
            var val = Cursor{ .buf = &val_buf };
            var pre = Cursor{ .buf = &pre_buf };
            rw.prelude = &pre;
            rw.in_loop = inside;
            switch (it.kind) {
                .stage => {
                    rw.where = .stage;
                    rw.stage_target = it.shared;
                    if (rw.top(it.index, &idx, .stage_index) < 0) return -1;
                    if (rw.top(it.value, &val, .stage_value) < 0) return -1;
                    rw.stage_target = null;
                    var num: [16]u8 = undefined;
                    const sz = std.fmt.bufPrint(&num, "{d}", .{d.shared_size[it.shared]}) catch return -1;
                    items.put(ind);
                    items.put("{\n");
                    items.put(pre.items());
                    items.put(ind);
                    items.put("  let ix = i32(");
                    items.put(idx.items());
                    items.put(");\n");
                    items.put(ind);
                    items.put("  if (ix >= 0 && ix < ");
                    items.put(sz);
                    items.put(") { w_");
                    items.put(d.shared[it.shared].slice());
                    items.put("[ix] = ");
                    items.put(val.items());
                    items.put("; }\n");
                    items.put(ind);
                    items.put("}\n");
                    items.put(ind);
                    items.put("workgroupBarrier();\n");
                },
                .reduce => {
                    const nm = d.shared[it.shared].slice();
                    var num: [16]u8 = undefined;
                    const half = std.fmt.bufPrint(&num, "{d}u", .{d.shared_size[it.shared] / 2}) catch return -1;
                    items.put(ind);
                    items.put("for (var s_ : u32 = ");
                    items.put(half);
                    items.put("; s_ > 0u; s_ = s_ / 2u) {\n");
                    items.put(ind);
                    items.put("  if (l < s_) { w_");
                    items.put(nm);
                    items.put("[l] = ");
                    switch (it.op) {
                        .sum => {
                            items.put("w_");
                            items.put(nm);
                            items.put("[l] + w_");
                            items.put(nm);
                            items.put("[l + s_]");
                        },
                        .max, .min => {
                            items.put(if (it.op == .max) "max(w_" else "min(w_");
                            items.put(nm);
                            items.put("[l], w_");
                            items.put(nm);
                            items.put("[l + s_])");
                        },
                    }
                    items.put("; }\n");
                    items.put(ind);
                    items.put("  workgroupBarrier();\n");
                    items.put(ind);
                    items.put("}\n");
                },
                .accumulate => {
                    rw.where = .accumulate;
                    if (rw.top(it.value, &val, .acc_value) < 0) return -1;
                    items.put(ind);
                    items.put("{\n");
                    items.put(pre.items());
                    items.put(ind);
                    items.put("  acc = ");
                    items.put(val.items());
                    items.put(";\n");
                    items.put(ind);
                    items.put("}\n");
                    items.put(ind);
                    items.put("workgroupBarrier();\n");
                },
            }
            if (idx.overflow or val.overflow or pre.overflow) return fail("a stage is too long", .{});
        }
        if (d.loop_from != null) items.put("  }\n");
        rw.prelude = body_prelude;
        rw.in_loop = false;
        rw.where = .body;
        if (items.overflow) return fail("the schedule is too long", .{});
    }
    const kp3 = d.n_shared > 0 or d.n_items > 0 or d.width.len > 0 or rw.used_group;

    // ---- emit the kernel straight into the caller's buffer
    var w = Cursor{ .buf = out[0..@intFromFloat(cap)] };
    const put = struct {
        fn f(l: *Cursor, s: []const u8) void {
            l.put(s);
        }
    }.f;
    if (kp3) return emitGroupKernel(&w, &d, &rw, expr.items(), prelude.items(), guard.items(), gpre.items(), guard_kind == .none, guard_kind == .custom, items.items());

    put(&w, "struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }\n");
    put(&w, "@group(0) @binding(0) var<uniform> tile : StzTile;\n");
    put(&w, "struct P { n : u32, pad : u32");
    for (0..n_scalars) |s| {
        put(&w, ", s_");
        put(&w, scalars[s].slice());
        put(&w, " : f32");
    }
    put(&w, " }\n@group(0) @binding(1) var<uniform> p : P;\n");
    var bind: usize = 2;
    for (0..n_ins) |s| {
        var num: [8]u8 = undefined;
        const num_s = std.fmt.bufPrint(&num, "{d}", .{bind}) catch return -1;
        put(&w, "@group(0) @binding(");
        put(&w, num_s);
        put(&w, ") var<storage, read> v_");
        put(&w, ins[s].slice());
        put(&w, " : array<f32>;\n");
        bind += 1;
    }
    {
        var num: [8]u8 = undefined;
        const num_s = std.fmt.bufPrint(&num, "{d}", .{bind}) catch return -1;
        put(&w, "@group(0) @binding(");
        put(&w, num_s);
        put(&w, ") var<storage, read_write> v_");
        put(&w, out_name.slice());
        put(&w, " : array<f32>;\n");
    }
    // KP0: a neighbour read is a helper per input it is used on. Out of the
    // input's own range it answers 0.0 -- the interpreter says the same --
    // so a stencil's edges are the learner's to guard, and an unguarded edge
    // is a wrong VALUE the compare names, not undefined behaviour.
    if (usesRem(&.{ expr.items(), prelude.items(), guard.items(), gpre.items() })) put(&w, REM_WGSL);
    for (0..n_ins) |s| {
        if (!rw.used_rd[s]) continue;
        putRd(&w, ins[s].slice(), d.in_w[s]);
    }
    put(&w, "@compute @workgroup_size(256)\n");
    put(&w, "fn main(@builtin(global_invocation_id) gid : vec3<u32>) {\n");
    put(&w, "  let i = gid.x + tile.xoff * 256u;\n");
    // KP1: an input the body never reads (the cheat `@c = @i * 2`, which reads no
    // @a) would be dropped from the auto layout, and this layer's bind group
    // then carries an entry the layout lacks -- GK6's crash, on an INPUT this
    // time. A phony use keeps every declared input bound; a kernel that reads
    // all its inputs is emitted exactly as before.
    for (0..n_ins) |s| {
        if (rw.used_in[s]) continue;
        put(&w, "  _ = arrayLength(&v_");
        put(&w, ins[s].slice());
        put(&w, ");\n");
    }
    if (guard_kind == .default and prelude.len == 0) {
        // the form every kernel had before KP0, byte for byte
        put(&w, "  if (i < p.n) { ");
        putStore(&w, &d, expr.items());
        put(&w, " }\n}\n");
    } else {
        // a guard line is the learner's: the params uniform may go unread, and
        // a kernel that never reads p gets a layout without binding 1 (GK6's
        // crash). The phony assignment keeps p bound whatever the guard says.
        if (guard_kind != .default) put(&w, "  _ = p.n;\n");
        switch (guard_kind) {
            .default => put(&w, "  if (i < p.n) {\n"),
            .custom => {
                put(&w, gpre.items());
                put(&w, "  if (");
                put(&w, guard.items());
                put(&w, ") {\n");
            },
            .none => {},
        }
        put(&w, prelude.items());
        put(&w, "    ");
        putStore(&w, &d, expr.items());
        put(&w, "\n");
        if (guard_kind != .none) put(&w, "  }\n");
        put(&w, "}\n");
    }

    if (w.overflow) return fail("kernel too large for the output buffer", .{});
    return @intCast(w.len);
}

// ---------------------------------------------------------------- the rewriter (KP0)
// The body and the guard are rewritten by ONE routine, recursive so a sum's
// bounds and body, and a neighbour read's index, are the same language.
// GL0 made it a typed recursive descent beside the interpreter's (the types
// are in the GL0 block below the messages).
// What it admits beyond the GK0 grammar, each a KP0 admission:
//   @i                  the element index, as f32(i)
//   n                   the element count, as f32(p.n)
//   @a[expr]            a neighbour read: rd_a(i32(expr)), 0.0 out of range
//   sum(k, from, to, e) a bounded loop: a prelude accumulates e over k in
//                       [from, to) and the expression reads the accumulator;
//                       k is a bare name inside e; one sum may not nest in
//                       another (KP3's shared memory is the next step up)
//   < <= > >= == != and or    in a CONDITION only: the guard, or a when's first
//                       argument; a body is otherwise arithmetic
//   when(c, t, f)       GL0: select((f), (t), (c)), the false value first
// KP3: where an expression stands decides what it may read. The transpiler and
// the interpreter refuse the same things with the same words.
pub const Where = enum { body, guard, stage, accumulate, count };
const MSG_COUNT = "the tiles count must be the same for every thread: scalars, n and numbers only";
const MSG_SUMCOUNT = "a sum is not admitted in the tiles count";
const MSG_ROWCOL = "'@{s}' needs a width line (a 2-D output in 16 x 16 tiles)";
const MSG_ACC = "'@acc' is read in the accumulate line and the body, once an accumulate line exists";
const MSG_SHNOIDX = "'@{s}' is a shared array: read one slot, as in '@{s}[@l]'";
const MSG_RACE = "a stage cannot read the array it writes ('@{s}'): the threads would race; stage into a second array";
// GT0 (2026-10-28): WGSL refuses '&&' and '||' side by side without
// parentheses -- Chrome's compiler says so, naga let it through -- so the same
// guard ran on the desktop and failed in a browser. Both readers refuse it.
const MSG_MIX = "'and' and 'or' side by side need parentheses, as WGSL requires: write (A and B) or C";
// GL0 (2026-10-28): the conditional value, and the shape every condition has.
const MSG_WHEN = "when takes 3 arguments: when(condition, value if true, value if false)";
const MSG_COND = "a condition compares values, as in '@a > 0': a bare value is not a condition, and a comparison is not a value";
const MSG_CMP = "'{c}' is a comparison; comparisons belong to a guard line or to the condition of a when";

// GL0 (types, 2026-10-28): a value is an f32, an i32 or a truth value. A
// whole-number literal and the language's counting names (@i, n, @l, @g, @lx,
// @ly, @row, @col, a sum's variable, the tiles variable) are UNTYPED: they
// take the type of the value they meet, and are f32 when they meet none --
// which is what every description before GL0 meant. An int and a float never
// meet without a conversion, int(...) or float(...), as in WGSL. Buffers stay
// f32: an int input is read through i32(...), an int output written through
// f32(...), so a value crosses exactly up to 16,777,216.
const Ty = enum(u8) { f, i, b, u, v2, v3, v4 };
fn tyOf(r: i32) Ty {
    return @enumFromInt(@as(u8, @intCast(r)));
}
fn tyR(t: Ty) i32 {
    return @intFromEnum(t);
}
const Sink = enum { body, guard, stage_index, stage_value, acc_value, count };
const MSG_MIXTY = "an int and a float meet at '{s}': convert one, with float(...) or int(...)";
const MSG_FLOATFN = "'{s}' works on floats: write {s}(float(...))";
const MSG_BIGINT = "'{s}' is too large for an int (the largest is 2147483647)";
const MSG_OUTI = "the output '@{s}' holds ints; its value is a float: write int(...)";
const MSG_OUTF = "the output '@{s}' holds floats; its value is an int: write float(...)";
const MSG_SHI = "a shared array holds floats; the value is an int: write float(...)";
const MSG_ACCI = "'@acc' holds a float; the value is an int: write float(...)";

// The rewriter writes an untyped number with a placeholder where its type
// goes -- one byte after a literal's digits, three in front of a counting
// name's parenthesis -- and settles them when the type is known.
const PH_LIT: u8 = 1;
const PH_TY: u8 = 2;
const PH_TY3 = "\x02\x02\x02";
// GL0 (measured 2026-10-28, RTX 3050, wgpu-native 29): the device takes an
// i32 '%' as UNSIGNED -- -7 % 4 is 1 there, -3 in WGSL -- while its '/', its
// wrapping and its comparisons are WGSL's. So an i32 remainder is never
// handed to it: the rewriter writes stz_rem(a, b), a - (a / b) * b with
// WGSL's answer for a zero divisor, and a float '%' stays WGSL's own. A '%'
// whose type is not known yet is written between three markers, settled
// into one form or the other.
const PH_RA: u8 = 4; // where the left operand starts
const PH_RO: u8 = 3; // the operator
const PH_RZ: u8 = 5; // where the right operand ends
const REM_WGSL = "fn stz_rem(a : i32, b : i32) -> i32 {\n  if (b == 0) { return 0; }\n  return a - (a / b) * b;\n}\n";

fn insertAt(c: *Cursor, pos: usize, ch: u8) void {
    if (c.overflow or c.len + 1 > c.buf.len) {
        c.overflow = true;
        return;
    }
    std.mem.copyBackwards(u8, c.buf[pos + 1 .. c.len + 1], c.buf[pos..c.len]);
    c.buf[pos] = ch;
    c.len += 1;
}

/// Settle every placeholder written in `c` since `from` to `to` (f or i). A
/// whole-number literal past i32 is refused there, as the interpreter refuses it.
fn settleText(c: *Cursor, from: usize, to: Ty) i32 {
    if (std.mem.indexOfAny(u8, c.buf[from..c.len], &[_]u8{ PH_RA, PH_RO, PH_RZ }) != null) {
        // a remainder's markers change the length: rebuild the tail
        var tmp: [16384]u8 = undefined;
        const tail = c.len - from;
        if (tail > tmp.len) {
            c.overflow = true;
            return 0;
        }
        @memcpy(tmp[0..tail], c.buf[from..c.len]);
        c.len = from;
        for (tmp[0..tail]) |ch| {
            switch (ch) {
                PH_RA => if (to == .i) c.put("stz_rem("),
                PH_RO => if (to == .i) {
                    while (c.len > from and c.buf[c.len - 1] == ' ') c.len -= 1;
                    c.putc(',');
                } else c.putc('%'),
                PH_RZ => if (to == .i) c.putc(')'),
                else => c.putc(ch),
            }
        }
    }
    var k = from;
    while (k < c.len) : (k += 1) {
        if (c.buf[k] == PH_LIT) {
            if (to == .i) {
                var j = k;
                while (j > 0 and std.ascii.isDigit(c.buf[j - 1])) : (j -= 1) {}
                const v = std.fmt.parseInt(i64, c.buf[j..k], 10) catch std.math.maxInt(i64);
                if (v > std.math.maxInt(i32)) return fail(MSG_BIGINT, .{c.buf[j..k]});
            }
            c.buf[k] = if (to == .i) 'i' else 'f';
        } else if (c.buf[k] == PH_TY and k + 3 <= c.len) {
            @memcpy(c.buf[k .. k + 3], if (to == .i) "i32" else "f32");
            k += 2;
        }
    }
    return 0;
}

// GL0 (vectors, 2026-10-28): vec2, vec3 and vec4 of f32, as VALUES inside a
// kernel -- built from numbers, read by component (.x, .zyx), combined
// component by component, reduced by dot, length and distance. An input or
// an output is still a number, so a vector is built at the start of an
// expression and reduced before its end. A number meeting a vector in
// arithmetic is spread across it (WGSL's own rule); a function takes one
// type, except mix's weight.
fn isVec(t: Ty) bool {
    return t == .v2 or t == .v3 or t == .v4;
}
fn vecWidth(t: Ty) u8 {
    return switch (t) {
        .v2 => 2,
        .v3 => 3,
        .v4 => 4,
        else => 1,
    };
}
fn vecOf(n: u8) Ty {
    return switch (n) {
        2 => .v2,
        3 => .v3,
        else => .v4,
    };
}
fn ctorWidth(word: []const u8) u8 {
    if (std.mem.eql(u8, word, "vec2")) return 2;
    if (std.mem.eql(u8, word, "vec3")) return 3;
    if (std.mem.eql(u8, word, "vec4")) return 4;
    return 0;
}
const MSG_VECNUM = "a vector stands where a number is needed: reduce it, with .x, dot(...) or length(...)";
const MSG_OUTV = "the output '@{s}' holds vec{d}s: its value must be a vec{d}";
const MSG_VECCMP = "a vector is not compared whole: compare a component (.x) or a length";
const MSG_VECW = "vectors of two widths meet at '{s}'";
const MSG_VECONE = "'{s}' takes values of one type: write vec{d}(x) to spread a number across a vector";
const MSG_VECINT = "a vector holds floats: write float(...)";
const MSG_VECFN = "'{s}' works on vectors: build one, as in vec3(@x, @y, @z)";
const MSG_CROSS = "cross takes two vec3s";
const MSG_CTOR = "vec{d} takes {d} numbers, vectors whose widths add to {d}, or one number to spread";
const MSG_CONVVEC = "'{s}' converts a number, not a vector";
const MSG_SWZNUM = "'.{s}' reads a vector's components, and this value is a number";
const MSG_SWZBAD = "'.{s}' is not a component of this vector: a vec{d}'s letters are {s}";

/// A number and a vector, or two vectors, meeting in arithmetic: the check
/// both readers make (the untyped side is then settled to f32 by each).
fn vecMeet(a: Ty, b: Ty, at: []const u8) i32 {
    if (a == .b or b == .b) return fail(MSG_COND, .{});
    if (isVec(a) and isVec(b)) return if (a == b) 0 else fail(MSG_VECW, .{at});
    const sc = if (isVec(a)) b else a;
    if (sc == .i) return fail(MSG_VECINT, .{});
    return 0;
}
/// when's two values, a function's arguments: one type, no spreading.
fn vecSame(a: Ty, b: Ty, at: []const u8) i32 {
    if (a == b) return 0;
    if (isVec(a) and isVec(b)) return fail(MSG_VECW, .{at});
    return fail(MSG_VECONE, .{ at, if (isVec(a)) vecWidth(a) else vecWidth(b) });
}

/// A swizzle: the value it gives and the interpreter's encoding of it --
/// the source width - 2, the count - 1, then two bits per component.
const Swz = struct { out: Ty, arg: u16 };
fn swizzleOf(t: Ty, letters: []const u8) ?Swz {
    if (!isVec(t)) {
        _ = fail(MSG_SWZNUM, .{letters});
        return null;
    }
    const n = vecWidth(t);
    const names = "xyzw"[0..n];
    if (letters.len > 4) {
        _ = fail(MSG_SWZBAD, .{ letters, n, names });
        return null;
    }
    var arg: u16 = @as(u16, n - 2) | (@as(u16, @intCast(letters.len - 1)) << 2);
    for (letters, 0..) |ch, k| {
        const ix = std.mem.indexOfScalar(u8, names, std.ascii.toLower(ch)) orelse {
            _ = fail(MSG_SWZBAD, .{ letters, n, names });
            return null;
        };
        arg |= @as(u16, @intCast(ix)) << @intCast(4 + 2 * k);
    }
    return .{ .out = if (letters.len == 1) .f else vecOf(@intCast(letters.len)), .arg = arg };
}

/// GL0 (vectors): what a call means once its arguments' types are known --
/// decided once, here, for both readers, which parse, write and compute it
/// each their own way.
const CallMode = enum { conv, scalar, vmap, vdot, vlen, vdist, vnorm, vcross, vrefl, ctor, splat };
const CallPlan = struct { mode: CallMode, result: Ty, settle: ?Ty = null, n: u8 = 1, mask: u8 = 0 };
fn planCall(name: []const u8, fun: ?Fn, conv: ?Ty, ctor: u8, args: []const Ty) ?CallPlan {
    for (args) |a| {
        if (a == .b) {
            _ = fail(MSG_COND, .{});
            return null;
        }
    }
    if (ctor != 0) {
        var total: usize = 0;
        for (args) |a| {
            if (a == .i) {
                _ = fail(MSG_VECINT, .{});
                return null;
            }
            total += vecWidth(a);
        }
        if (args.len == 1 and !isVec(args[0])) return .{ .mode = .splat, .result = vecOf(ctor), .settle = .f, .n = ctor };
        if (total != ctor) {
            _ = fail(MSG_CTOR, .{ ctor, ctor, ctor });
            return null;
        }
        return .{ .mode = .ctor, .result = vecOf(ctor), .settle = .f, .n = ctor };
    }
    if (conv) |cv| {
        if (isVec(args[0])) {
            _ = fail(MSG_CONVVEC, .{name});
            return null;
        }
        return .{ .mode = .conv, .result = cv, .settle = if (args[0] == .u) cv else null };
    }
    const f = fun.?;
    var any_vec = false;
    for (args) |a| any_vec = any_vec or isVec(a);
    const vonly = f.op == .f_dot or f.op == .f_cross or f.op == .f_normalize or f.op == .f_reflect;
    if (vonly or ((f.op == .f_length or f.op == .f_distance) and any_vec)) {
        for (args) |a| {
            if (!isVec(a)) {
                if (vonly) {
                    _ = fail(MSG_VECFN, .{name});
                } else _ = vecSame(args[0], a, name);
                return null;
            }
            if (a != args[0]) {
                _ = fail(MSG_VECW, .{name});
                return null;
            }
        }
        const n = vecWidth(args[0]);
        if (f.op == .f_cross and n != 3) {
            _ = fail(MSG_CROSS, .{});
            return null;
        }
        return switch (f.op) {
            .f_dot => .{ .mode = .vdot, .result = .f, .n = n },
            .f_length => .{ .mode = .vlen, .result = .f, .n = n },
            .f_distance => .{ .mode = .vdist, .result = .f, .n = n },
            .f_normalize => .{ .mode = .vnorm, .result = args[0], .n = n },
            .f_cross => .{ .mode = .vcross, .result = .v3, .n = 3 },
            else => .{ .mode = .vrefl, .result = args[0], .n = n },
        };
    }
    if (!any_vec) {
        if (isGeneric(f.op)) {
            var t: Ty = .u;
            for (args) |a| {
                if (t == .u) {
                    t = a;
                } else if (a != .u and a != t) {
                    _ = fail(MSG_MIXTY, .{name});
                    return null;
                }
            }
            return .{ .mode = .scalar, .result = t, .settle = if (t != .u) t else null };
        }
        for (args) |a| {
            if (a == .i) {
                _ = fail(MSG_FLOATFN, .{ name, name });
                return null;
            }
        }
        return .{ .mode = .scalar, .result = .f, .settle = .f };
    }
    // a function applied component by component
    var v: Ty = .u;
    for (args) |a| {
        if (isVec(a)) {
            v = a;
            break;
        }
    }
    var mask: u8 = 0;
    for (args, 0..) |a, k| {
        if (isVec(a)) {
            if (a != v) {
                _ = fail(MSG_VECW, .{name});
                return null;
            }
        } else if (f.op == .f_mix and k == 2 and (a == .f or a == .u)) {
            mask |= 4; // mix(v, w, t): one weight for every component, as WGSL allows
        } else if (a == .i) {
            _ = fail(MSG_VECINT, .{});
            return null;
        } else {
            _ = fail(MSG_VECONE, .{ name, vecWidth(v) });
            return null;
        }
    }
    return .{ .mode = .vmap, .result = v, .settle = .f, .n = vecWidth(v), .mask = mask };
}

/// vmap's argument: the f32 op, the width - 1, the operand count - 1, and
/// which operands are numbers spread across the width.
fn vmapArg(op: Op, n: u8, arity: u8, mask: u8) u16 {
    return @as(u16, @intFromEnum(op)) | (@as(u16, n - 1) << 7) | (@as(u16, arity - 1) << 9) | (@as(u16, mask) << 11);
}
comptime {
    std.debug.assert(@typeInfo(Op).@"enum".fields.len <= 128);
}

/// The functions WGSL gives both types; every other one takes floats.
fn isGeneric(op: Op) bool {
    return op == .f_abs or op == .f_min or op == .f_max or op == .f_clamp or op == .f_sign;
}
/// The i32 form of an f32 op (the op itself when it has none).
fn intForm(op: Op) Op {
    return switch (op) {
        .add => .i_add,
        .sub => .i_sub,
        .mul => .i_mul,
        .div => .i_div,
        .mod => .i_mod,
        .neg => .i_neg,
        .f_min => .i_min,
        .f_max => .i_max,
        .f_abs => .i_abs,
        .f_clamp => .i_clamp,
        .f_sign => .i_sign,
        .c_lt => .ic_lt,
        .c_le => .ic_le,
        .c_gt => .ic_gt,
        .c_ge => .ic_ge,
        .c_eq => .ic_eq,
        .c_ne => .ic_ne,
        else => op,
    };
}

// GL0: the SHAPE of a condition, read from its source by both readers before
// either compiles it, so they cannot split on it. A condition is comparisons
// joined by 'and' and 'or', each comparison between two values, grouped by
// parentheses; a value holds no comparison, except inside a when's own
// condition. WGSL types a comparison as bool and refuses one used as a number
// ('(@a < 0) + 1', 'max(@a < 0, 1)') or a number used as a condition
// ('guard { @a }'). Those reached the device and failed there in naga's words;
// they are refused here in the learner's.
fn identChar(c: u8) bool {
    return std.ascii.isAlphanumeric(c) or c == '_' or c == '@';
}

/// The length of a comparison operator at s[i], 0 if none. A lone '=' or '!'
/// counts, so the reader that compiles it names the right spelling.
fn relAt(s: []const u8, i: usize) usize {
    const c = s[i];
    const two = i + 1 < s.len and s[i + 1] == '=';
    if (c == '<' or c == '>' or c == '=' or c == '!') return if (two) 2 else 1;
    return 0;
}

/// The end of the bare word starting at s[i] (s[i] alphabetic or '_').
fn wordEnd(s: []const u8, i: usize) usize {
    var j = i;
    while (j < s.len and identChar(s[j])) : (j += 1) {}
    return j;
}

/// GL0: 'and' or 'or' at s[i] (after spacing), the word itself, or null --
/// so a body that uses one is told where it belongs, by both readers.
fn logicWordAt(s: []const u8, from: usize) ?[]const u8 {
    var i = from;
    while (i < s.len and (s[i] == ' ' or s[i] == '\t')) : (i += 1) {}
    if (i >= s.len or !std.ascii.isAlphabetic(s[i])) return null;
    var j = i;
    while (j < s.len and (std.ascii.isAlphanumeric(s[j]) or s[j] == '_')) : (j += 1) {}
    return if (isLogicWord(s[i..j])) s[i..j] else null;
}
const MSG_LOGIC = "'{s}' belongs to the guard line, not to a body";
const MSG_CHAR = "character '{c}' is not part of the elementwise language";
/// A character the language can write at all: a leftover one that is not is
/// named as foreign, not as an unexpected token (both readers, the same words).
fn exprChar(c: u8) bool {
    return std.ascii.isAlphanumeric(c) or std.mem.indexOfScalar(u8, "@_.()[],+-*/%<>=! \t", c) != null;
}

fn isLogicWord(w: []const u8) bool {
    return std.ascii.eqlIgnoreCase(w, "and") or std.ascii.eqlIgnoreCase(w, "or");
}

/// Split s[open+1 .. close] at the commas outside any bracket. Returns the
/// number of parts (more than parts.len means too many).
fn splitTop(s: []const u8, open: usize, close: usize, parts: [][]const u8) usize {
    var np: usize = 0;
    var start = open + 1;
    var depth: usize = 0;
    var q = open + 1;
    while (q <= close) : (q += 1) {
        const c = s[q];
        if (q < close and (c == '(' or c == '[')) depth += 1;
        if (q < close and (c == ')' or c == ']') and depth > 0) depth -= 1;
        if (q == close or (c == ',' and depth == 0)) {
            if (np < parts.len) parts[np] = std.mem.trim(u8, s[start..q], " \t");
            np += 1;
            start = q + 1;
        }
    }
    return np;
}

pub fn condShape(src: []const u8) bool {
    return isCond(std.mem.trim(u8, src, " \t"), 0);
}

fn isCond(s0: []const u8, level: usize) bool {
    const s = std.mem.trim(u8, s0, " \t");
    if (s.len == 0 or level > MAX_DEPTH) return false;
    // joined by 'and' / 'or' at the top: every part is a condition
    var depth: usize = 0;
    var start: usize = 0;
    var joined = false;
    var i: usize = 0;
    while (i < s.len) {
        const c = s[i];
        if (c == '(' or c == '[') depth += 1 else if ((c == ')' or c == ']') and depth > 0) depth -= 1 else if (depth == 0 and (std.ascii.isAlphabetic(c) or c == '_') and (i == 0 or !identChar(s[i - 1]))) {
            const j = wordEnd(s, i);
            if (isLogicWord(s[i..j])) {
                if (!isCond(s[start..i], level + 1)) return false;
                start = j;
                joined = true;
            }
            i = j;
            continue;
        }
        i += 1;
    }
    if (joined) return isCond(s[start..], level + 1);
    // a condition in parentheses
    if (s[0] == '(') {
        if (Rewriter.matching(s, 0)) |m| {
            if (m == s.len - 1) return isCond(s[1 .. s.len - 1], level + 1);
        }
    }
    // one comparison between two values
    depth = 0;
    var at: ?usize = null;
    var width: usize = 0;
    i = 0;
    while (i < s.len) : (i += 1) {
        const c = s[i];
        if (c == '(' or c == '[') depth += 1 else if ((c == ')' or c == ']') and depth > 0) depth -= 1 else if (depth == 0) {
            const r = relAt(s, i);
            if (r > 0) {
                if (at != null) return false; // 'a < b < c'
                at = i;
                width = r;
                i += r - 1;
            }
        }
    }
    const k = at orelse return false;
    return isValue(s[0..k], level + 1) and isValue(s[k + width ..], level + 1);
}

fn isValue(s0: []const u8, level: usize) bool {
    const s = std.mem.trim(u8, s0, " \t");
    if (s.len == 0) return false;
    if (level > MAX_DEPTH) return false;
    var i: usize = 0;
    var last_word: []const u8 = "";
    while (i < s.len) {
        const c = s[i];
        if (std.ascii.isAlphabetic(c) or c == '_' or c == '@') {
            const j = wordEnd(s, i);
            last_word = s[i..j];
            if (isLogicWord(last_word)) return false;
            i = j;
            continue;
        }
        if (c == '(' or c == '[') {
            const m = Rewriter.matching(s, i) orelse return true; // the reader names the missing bracket
            var parts: [8][]const u8 = undefined;
            const np = splitTop(s, i, m, &parts);
            if (c == '(' and std.ascii.eqlIgnoreCase(last_word, "when")) {
                // a when's own condition; a wrong count is the reader's to name
                if (np == 3 and (!isCond(parts[0], level + 1) or !isValue(parts[1], level + 1) or !isValue(parts[2], level + 1))) return false;
            } else {
                for (parts[0..@min(np, parts.len)]) |part| {
                    if (part.len != 0 and !isValue(part, level + 1)) return false;
                }
            }
            last_word = "";
            i = m + 1;
            continue;
        }
        if (relAt(s, i) > 0) return false;
        if (c != ' ' and c != '\t') last_word = "";
        i += 1;
    }
    return true;
}

fn groupName(s: []const u8) ?[]const u8 {
    // the WGSL each group name reads as, f32 like every value of the grammar
    if (std.mem.eql(u8, s, "l")) return "f32(l)";
    if (std.mem.eql(u8, s, "g")) return "f32(g)";
    if (std.mem.eql(u8, s, "lx")) return "f32(l % 16u)";
    if (std.mem.eql(u8, s, "ly")) return "f32(l / 16u)";
    if (std.mem.eql(u8, s, "row")) return "f32(row)";
    if (std.mem.eql(u8, s, "col")) return "f32(col)";
    return null;
}

const Rewriter = struct {
    d: *const Decl,
    prelude: *Cursor,
    nsum: usize = 0,
    loopvar: ?Name = null,
    compare: bool = false,
    used_rd: [MAX_VECS]bool = @splat(false),
    used_in: [MAX_VECS]bool = @splat(false), // KP1: an input the body never reads must still be BOUND
    // KP3
    where: Where = .body,
    in_loop: bool = false,
    stage_target: ?usize = null,
    used_group: bool = false,
    used_sh: [MAX_SHARED]bool = @splat(false),
    // GL0 (types): the rewriter is a recursive descent over the text that
    // writes WGSL as it reads, one construct for each of the interpreter's,
    // so the two refuse in the same order with the same words. It keeps the
    // source's own spacing and parentheses, so WGSL reads the precedence
    // again, by itself.
    s: []const u8 = "",
    i: usize = 0,
    out: *Cursor = undefined,
    depth: usize = 0,
    nands: i32 = 0,
    top_sums: usize = 0,

    fn matching(text: []const u8, open_at: usize) ?usize {
        var depth: usize = 0;
        var j = open_at;
        while (j < text.len) : (j += 1) {
            const ch = text[j];
            if (ch == '(' or ch == '[') depth += 1;
            if (ch == ')' or ch == ']') {
                depth -= 1;
                if (depth == 0) return j;
            }
        }
        return null;
    }

    /// Rewrite one expression of the description into `cur`, read as `sink`
    /// asks: its type settled, its trailing text refused as the interpreter
    /// refuses it. 0, or -1 with the reason.
    fn top(self: *Rewriter, text: []const u8, cur: *Cursor, sink: Sink) i32 {
        self.s = text;
        self.i = 0;
        self.out = cur;
        self.depth = 0;
        self.top_sums = 0;
        const start = cur.len;
        if (sink == .guard) {
            self.compare = true;
            const r = self.orW();
            self.compare = false;
            if (r < 0) return -1;
            if (self.peekW() != 0) return fail("unexpected '{c}' after the guard", .{self.peekW()});
            return 0;
        }
        const r = self.exprW();
        if (r < 0) return -1;
        const c = self.peekW();
        if (c != 0) {
            if (c == '<' or c == '>' or c == '=' or c == '!') return fail(MSG_CMP, .{c});
            if (logicWordAt(self.s, self.i)) |w| return fail(MSG_LOGIC, .{w});
            if (!exprChar(c)) return fail(MSG_CHAR, .{c});
            return fail("unexpected '{c}' after the expression", .{c});
        }
        return self.sinkW(tyOf(r), start, sink);
    }

    fn sinkW(self: *Rewriter, t: Ty, start: usize, sink: Sink) i32 {
        if (sink == .body and self.d.out_w > 1) {
            if (t != vecOf(self.d.out_w)) return fail(MSG_OUTV, .{ self.d.out_name.slice(), self.d.out_w, self.d.out_w });
            return 0;
        }
        if (isVec(t)) return fail(MSG_VECNUM, .{});
        switch (sink) {
            .body => {
                const want: Ty = if (self.d.out_int) .i else .f;
                if (t == .u) return settleText(self.out, start, want);
                if (t != want) return if (want == .i) fail(MSG_OUTI, .{self.d.out_name.slice()}) else fail(MSG_OUTF, .{self.d.out_name.slice()});
                return 0;
            },
            .stage_value => {
                if (t == .i) return fail(MSG_SHI, .{});
                return if (t == .u) settleText(self.out, start, .f) else 0;
            },
            .acc_value => {
                if (t == .i) return fail(MSG_ACCI, .{});
                return if (t == .u) settleText(self.out, start, .f) else 0;
            },
            .stage_index, .count => return if (t == .u) settleText(self.out, start, .f) else 0,
            .guard => return 0,
        }
    }

    /// Arithmetic: numbers unify; a vector meets one of its width, or a number spread across it.
    fn arithW(self: *Rewriter, a: Ty, b: Ty, from_a: usize, from_b: usize, at: []const u8) i32 {
        if (!isVec(a) and !isVec(b)) return self.unifyW(a, b, from_a, from_b, at);
        if (vecMeet(a, b, at) < 0) return -1;
        if (a == .u and settleText(self.out, from_a, .f) < 0) return -1;
        if (b == .u and settleText(self.out, from_b, .f) < 0) return -1;
        return tyR(if (isVec(a)) a else b);
    }
    fn unifyW(self: *Rewriter, a: Ty, b: Ty, from_a: usize, from_b: usize, at: []const u8) i32 {
        if (a == b) return tyR(a);
        if (a == .b or b == .b) return fail(MSG_COND, .{});
        if (a == .u) return if (settleText(self.out, from_a, b) < 0) -1 else tyR(b);
        if (b == .u) return if (settleText(self.out, from_b, a) < 0) -1 else tyR(a);
        return fail(MSG_MIXTY, .{at});
    }

    // ---- reading, copying the spacing as it goes
    fn skipW(self: *Rewriter) void {
        while (self.i < self.s.len and (self.s[self.i] == ' ' or self.s[self.i] == '\t')) : (self.i += 1) self.out.putc(self.s[self.i]);
    }
    fn peekW(self: *Rewriter) u8 {
        self.skipW();
        return if (self.i < self.s.len) self.s[self.i] else 0;
    }
    /// The next character after the spacing, the spacing dropped (between a
    /// name and its '[', where WGSL's text has none).
    fn peekDrop(self: *Rewriter) u8 {
        while (self.i < self.s.len and (self.s[self.i] == ' ' or self.s[self.i] == '\t')) : (self.i += 1) {}
        return if (self.i < self.s.len) self.s[self.i] else 0;
    }
    fn wordW(self: *Rewriter, w: []const u8) bool {
        self.skipW();
        if (self.i + w.len > self.s.len) return false;
        if (!std.ascii.eqlIgnoreCase(self.s[self.i .. self.i + w.len], w)) return false;
        const after = self.i + w.len;
        if (after < self.s.len and (std.ascii.isAlphanumeric(self.s[after]) or self.s[after] == '_')) return false;
        self.i = after;
        return true;
    }
    fn noCmpW(self: *Rewriter) i32 {
        const c = self.peekW();
        if (!self.compare and (c == '<' or c == '>' or c == '=' or c == '!')) return fail(MSG_CMP, .{c});
        if (!self.compare) {
            if (logicWordAt(self.s, self.i)) |w| return fail(MSG_LOGIC, .{w});
        }
        return 0;
    }

    // guard := andexpr ('or' andexpr)*
    fn orW(self: *Rewriter) i32 {
        const first = self.andW();
        if (first < 0) return -1;
        var ands = self.nands > 0;
        var ors = false;
        while (self.wordW("or")) {
            ors = true;
            self.out.put(" || ");
            const r = self.andW();
            if (r < 0) return -1;
            if (self.nands > 0) ands = true;
            if (ands) return fail(MSG_MIX, .{});
        }
        if (ors and ands) return fail(MSG_MIX, .{});
        return if (ors) tyR(.b) else first;
    }
    fn andW(self: *Rewriter) i32 {
        const first = self.cmpW();
        if (first < 0) return -1;
        var n: i32 = 0;
        while (self.wordW("and")) {
            self.out.put(" && ");
            if (self.cmpW() < 0) return -1;
            n += 1;
        }
        self.nands = n;
        return if (n > 0) tyR(.b) else first;
    }
    fn cmpW(self: *Rewriter) i32 {
        const start = self.out.len;
        const a = self.exprW();
        if (a < 0) return -1;
        const c = self.peekW();
        if (c == '<' or c == '>' or c == '=' or c == '!') {
            const two = self.i + 1 < self.s.len and self.s[self.i + 1] == '=';
            if (c == '=' and !two) return fail("use '==' to compare in a guard", .{});
            if (c == '!' and !two) return fail("'!' alone is not admitted; use '!='", .{});
            const op = self.s[self.i .. self.i + (if (two) @as(usize, 2) else 1)];
            self.out.put(op);
            self.i += op.len;
            const mid = self.out.len;
            const b = self.exprW();
            if (b < 0) return -1;
            if (isVec(tyOf(a)) or isVec(tyOf(b))) return fail(MSG_VECCMP, .{});
            const t = self.unifyW(tyOf(a), tyOf(b), start, mid, op);
            if (t < 0) return -1;
            if (tyOf(t) == .u and settleText(self.out, start, .f) < 0) return -1;
            return tyR(.b);
        }
        return a;
    }

    // expr := term (('+' | '-') term)*
    fn exprW(self: *Rewriter) i32 {
        if (self.depth >= MAX_DEPTH) return fail("expression nested too deep", .{});
        self.depth += 1;
        defer self.depth -= 1;
        const start = self.out.len;
        var t = self.termW();
        if (t < 0) return -1;
        while (true) {
            const c = self.peekW();
            if (c != '+' and c != '-') break;
            self.out.putc(c);
            self.i += 1;
            const mid = self.out.len;
            const r = self.termW();
            if (r < 0) return -1;
            t = self.arithW(tyOf(t), tyOf(r), start, mid, if (c == '+') "+" else "-");
            if (t < 0) return -1;
        }
        return t;
    }
    // term := unary (('*' | '/' | '%') unary)*
    fn termW(self: *Rewriter) i32 {
        const start = self.out.len;
        var t = self.unaryW();
        if (t < 0) return -1;
        while (true) {
            const c = self.peekW();
            if (c != '*' and c != '/' and c != '%') break;
            if (c == '%') {
                // the marker goes after the spacing the term began with
                var at = start;
                while (at < self.out.len and (self.out.buf[at] == ' ' or self.out.buf[at] == '\t')) at += 1;
                insertAt(self.out, at, PH_RA);
            }
            self.out.putc(if (c == '%') PH_RO else c);
            self.i += 1;
            const mid = self.out.len;
            const r = self.unaryW();
            if (r < 0) return -1;
            if (c == '%') self.out.putc(PH_RZ);
            t = self.arithW(tyOf(t), tyOf(r), start + @intFromBool(c == '%'), mid, if (c == '*') "*" else if (c == '/') "/" else "%");
            if (t < 0) return -1;
            if (c == '%' and tyOf(t) != .u and settleText(self.out, start, tyOf(t)) < 0) return -1;
        }
        return t;
    }
    fn unaryW(self: *Rewriter) i32 {
        const c = self.peekW();
        if (c == '-' or c == '+') {
            self.out.putc(c);
            self.i += 1;
            return self.unaryW();
        }
        return self.primaryW();
    }

    /// An index inside '[' ']': its own expression, settled to f32 when it is
    /// an untyped number (the kernel's i32(...) takes either type).
    fn indexW(self: *Rewriter, nm: []const u8) i32 {
        self.i += 1;
        const saved = self.compare;
        self.compare = false;
        const start = self.out.len;
        const r = self.exprW();
        const r2 = if (r < 0) r else self.noCmpW();
        self.compare = saved;
        if (r2 < 0) return -1;
        if (isVec(tyOf(r))) return fail(MSG_VECNUM, .{});
        if (tyOf(r) == .u and settleText(self.out, start, .f) < 0) return -1;
        if (self.peekW() != ']') return fail("missing ']' after '@{s}['", .{nm});
        self.i += 1;
        return 0;
    }

    // primary := atom ('.' components)*  -- GL0: a swizzle, written as itself
    fn primaryW(self: *Rewriter) i32 {
        const r = self.atomW();
        if (r < 0) return -1;
        var t = tyOf(r);
        while (self.i + 1 < self.s.len and self.s[self.i] == '.' and std.ascii.isAlphabetic(self.s[self.i + 1])) {
            var j = self.i + 1;
            while (j < self.s.len and std.ascii.isAlphanumeric(self.s[j])) : (j += 1) {}
            const sw = swizzleOf(t, self.s[self.i + 1 .. j]) orelse return -1;
            self.out.putc('.');
            for (self.s[self.i + 1 .. j]) |ch| self.out.putc(std.ascii.toLower(ch));
            self.i = j;
            t = sw.out;
        }
        return tyR(t);
    }
    fn atomW(self: *Rewriter) i32 {
        const c = self.peekW();
        if (c == 0) return fail("expression ends where a value was expected", .{});
        if (c == '(') {
            self.out.putc('(');
            self.i += 1;
            const r = if (self.compare) self.orW() else self.exprW();
            if (r < 0 or self.noCmpW() < 0) return -1;
            if (self.peekW() != ')') return fail("missing ')'", .{});
            self.out.putc(')');
            self.i += 1;
            return r;
        }
        if (std.ascii.isDigit(c) or c == '.') {
            var j = self.i;
            while (j < self.s.len and (std.ascii.isDigit(self.s[j]) or self.s[j] == '.')) : (j += 1) {}
            const lit = self.s[self.i..j];
            _ = std.fmt.parseFloat(f32, lit) catch return fail("bad number '{s}'", .{lit});
            self.out.put(lit);
            self.i = j;
            // GT0: every literal is written typed, never abstract. GL0: a whole
            // number takes the type of the value it meets (f32 when it meets
            // none); one with a decimal point is a float.
            if (std.mem.indexOfScalar(u8, lit, '.') != null) {
                self.out.putc('f');
                return tyR(.f);
            }
            self.out.putc(PH_LIT);
            return tyR(.u);
        }
        if (c == '@') {
            var j = self.i + 1;
            while (j < self.s.len and (std.ascii.isAlphanumeric(self.s[j]) or self.s[j] == '_')) : (j += 1) {}
            var nm: Name = .{};
            if (j == self.i + 1 or !lowerInto(&nm, self.s[self.i + 1 .. j]))
                return fail("bad @name at '{s}'", .{self.s[self.i..@min(self.i + 8, self.s.len)]});
            if (self.where == .count) return fail(MSG_COUNT, .{});
            if (std.mem.eql(u8, nm.slice(), "i")) {
                self.i = j;
                self.out.put(PH_TY3 ++ "(i)");
                return tyR(.u);
            }
            if (groupName(nm.slice())) |wg| {
                const sn = nm.slice();
                if ((std.mem.eql(u8, sn, "row") or std.mem.eql(u8, sn, "col")) and self.d.width.len == 0)
                    return fail(MSG_ROWCOL, .{sn});
                self.used_group = true;
                self.i = j;
                self.out.put(PH_TY3);
                self.out.put(wg[3..]);
                return tyR(.u);
            }
            if (std.mem.eql(u8, nm.slice(), "acc")) {
                if (!self.d.has_acc or !(self.where == .accumulate or self.where == .body)) return fail(MSG_ACC, .{});
                self.i = j;
                self.out.put("acc");
                return tyR(.f);
            }
            if (self.d.sharedIndex(nm.slice())) |si| {
                self.i = j;
                if (self.peekDrop() != '[') return fail(MSG_SHNOIDX, .{ nm.slice(), nm.slice() });
                if (self.stage_target) |st| {
                    if (st == si) return fail(MSG_RACE, .{nm.slice()});
                }
                self.out.put("sh_");
                self.out.put(nm.slice());
                self.out.put("(i32(");
                if (self.indexW(nm.slice()) < 0) return -1;
                self.out.put("))");
                self.used_sh[si] = true;
                self.used_group = true;
                return tyR(.f);
            }
            const idx = nameIn(self.d.ins[0..], self.d.n_ins, nm.slice()) orelse {
                if (std.mem.eql(u8, nm.slice(), self.d.out_name.slice()))
                    return fail("the output '@{s}' cannot be read", .{nm.slice()});
                return fail("undeclared vector '@{s}'", .{nm.slice()});
            };
            self.used_in[idx] = true;
            self.i = j;
            const int = self.d.in_int[idx];
            if (int) self.out.put("i32(");
            const here = self.i;
            const next = self.peekDrop();
            if (next != '[') self.i = here; // the spacing after a plain read is the source's
            if (next != '[' and (self.where == .stage or self.where == .accumulate)) {
                // KP3: a schedule item runs for EVERY thread of the group, the
                // ones past the input included, so its own element is a bounded read
                self.used_rd[idx] = true;
                self.out.put("rd_");
                self.out.put(nm.slice());
                self.out.put("(i32(i))");
            } else if (next == '[') {
                self.used_rd[idx] = true;
                self.out.put("rd_");
                self.out.put(nm.slice());
                self.out.put("(i32(");
                if (self.indexW(nm.slice()) < 0) return -1;
                self.out.put("))");
            } else if (self.d.in_w[idx] > 1) {
                // GL0 (typed buffers): element i of a vecN input, its N floats
                const wd = self.d.in_w[idx];
                self.out.put(if (wd == 2) "vec2<f32>(" else if (wd == 3) "vec3<f32>(" else "vec4<f32>(");
                for (0..wd) |jj| {
                    if (jj > 0) self.out.put(", ");
                    self.out.put("v_");
                    self.out.put(nm.slice());
                    self.out.putc('[');
                    self.out.putc('0' + wd);
                    self.out.put("u * i");
                    if (jj > 0) {
                        self.out.put(" + ");
                        self.out.putc('0' + @as(u8, @intCast(jj)));
                        self.out.putc('u');
                    }
                    self.out.putc(']');
                }
                self.out.putc(')');
            } else {
                self.out.put("v_");
                self.out.put(nm.slice());
                self.out.put("[i]");
            }
            if (int) self.out.put(")");
            if (self.d.in_w[idx] > 1) return tyR(vecOf(self.d.in_w[idx]));
            return tyR(if (int) .i else .f);
        }
        if (std.ascii.isAlphabetic(c) or c == '_') {
            var j = self.i;
            while (j < self.s.len and (std.ascii.isAlphanumeric(self.s[j]) or self.s[j] == '_')) : (j += 1) {}
            var nm: Name = .{};
            if (!lowerInto(&nm, self.s[self.i..j]))
                return fail("name too long at '{s}'", .{self.s[self.i..@min(self.i + 8, self.s.len)]});
            self.i = j;
            const word = nm.slice();
            if (std.mem.eql(u8, word, "n")) {
                self.out.put(PH_TY3 ++ "(p.n)");
                return tyR(.u);
            }
            if (self.loopvar) |lv| {
                if (std.mem.eql(u8, word, lv.slice())) {
                    self.out.put(PH_TY3 ++ "(k_");
                    self.out.put(word);
                    self.out.put(")");
                    return tyR(.u);
                }
            }
            if (self.in_loop and self.d.tiles.len != 0 and std.mem.eql(u8, word, self.d.tilevar.slice())) {
                self.out.put(PH_TY3 ++ "(t_");
                self.out.put(word);
                self.out.put(")");
                return tyR(.u);
            }
            if (std.mem.eql(u8, word, "and") or std.mem.eql(u8, word, "or"))
                return fail("'{s}' belongs to the guard line, not to a body", .{word});
            if (nameIn(self.d.scalars[0..], self.d.n_scalars, word)) |si| {
                const int = self.d.sc_int[si];
                if (int) self.out.put("i32(");
                self.out.put("p.s_");
                self.out.put(word);
                if (int) self.out.put(")");
                return tyR(if (int) .i else .f);
            }
            if (std.mem.eql(u8, word, "when")) return self.whenW();
            if (std.mem.eql(u8, word, "sum")) return self.sumW();
            return self.callW(word);
        }
        return fail("character '{c}' is not part of the elementwise language", .{c});
    }

    // GL0: a conditional value. WGSL's select takes the value if FALSE first
    // -- select(f, t, c) -- so the order is written here once, and the fuzz's
    // SWAP control is what proves a swapped pair would be caught.
    fn whenW(self: *Rewriter) i32 {
        if (self.peekDrop() != '(') return fail(MSG_WHEN, .{});
        const close = matching(self.s, self.i) orelse return fail("when is missing ')'", .{});
        var parts: [3][]const u8 = undefined;
        if (splitTop(self.s, self.i, close, &parts) != 3) return fail(MSG_WHEN, .{});
        if (!condShape(parts[0])) return fail(MSG_COND, .{});
        self.i += 1;
        var c_buf: [4096]u8 = undefined;
        var t_buf: [4096]u8 = undefined;
        var f_buf: [4096]u8 = undefined;
        var cnd = Cursor{ .buf = &c_buf };
        var tv = Cursor{ .buf = &t_buf };
        var fvc = Cursor{ .buf = &f_buf };
        const outer = self.out;
        const saved = self.compare;
        defer {
            self.out = outer;
            self.compare = saved;
        }
        self.out = &cnd;
        self.compare = true;
        if (self.orW() < 0) return -1;
        self.compare = false;
        if (self.peekW() != ',') return fail(MSG_WHEN, .{});
        self.i += 1;
        self.out = &tv;
        const tt = self.exprW();
        if (tt < 0 or self.noCmpW() < 0) return -1;
        if (self.peekW() != ',') return fail(MSG_WHEN, .{});
        self.i += 1;
        self.out = &fvc;
        const tf = self.exprW();
        if (tf < 0 or self.noCmpW() < 0) return -1;
        if (self.peekW() != ')') return fail("when is missing ')'", .{});
        self.i += 1;
        self.out = outer;
        if ((isVec(tyOf(tt)) or isVec(tyOf(tf))) and vecSame(tyOf(tt), tyOf(tf), "when") < 0) return -1;
        if (cnd.overflow or tv.overflow or fvc.overflow) return fail("when is too long", .{});
        const start = outer.len;
        outer.put("select((");
        outer.put(std.mem.trim(u8, fvc.items(), " \t"));
        outer.put("), (");
        outer.put(std.mem.trim(u8, tv.items(), " \t"));
        outer.put("), (");
        outer.put(std.mem.trim(u8, cnd.items(), " \t"));
        outer.put("))");
        return self.unifyW(tyOf(tt), tyOf(tf), start, start, "when");
    }

    // KP0: a bounded loop. A prelude accumulates the body over k in [from,
    // to) and the expression reads the accumulator. GL0: the accumulator has
    // the body's type, an untyped body counting as f32.
    fn sumW(self: *Rewriter) i32 {
        if (self.where == .count) return fail(MSG_SUMCOUNT, .{});
        if (self.loopvar != null) return fail("a sum inside a sum is not admitted (one level; shared memory is KP3's)", .{});
        if (self.top_sums >= MAX_SUMS) return fail("too many sums (max {d})", .{MAX_SUMS});
        if (self.peekDrop() != '(') return fail("sum needs '(var, from, to, expression)'", .{});
        {
            const close = matching(self.s, self.i) orelse return fail("sum is missing ')'", .{});
            var parts: [4][]const u8 = undefined;
            const np = splitTop(self.s, self.i, close, &parts);
            if (np != 4) return fail("sum takes 4 arguments (var, from, to, expression), got {d}", .{np});
        }
        self.i += 1;
        _ = self.peekDrop();
        var k = self.i;
        while (k < self.s.len and (std.ascii.isAlphanumeric(self.s[k]) or self.s[k] == '_')) : (k += 1) {}
        var lv: Name = .{};
        if (k == self.i or !lowerInto(&lv, self.s[self.i..k]) or !validIdent(lv.slice()))
            return fail("sum's variable must be a name, got '{s}'", .{self.s[self.i..@min(k, self.i + 8)]});
        if (reservedName(lv.slice()) != null or nameIn(self.d.ins[0..], self.d.n_ins, lv.slice()) != null or
            nameIn(self.d.scalars[0..], self.d.n_scalars, lv.slice()) != null)
            return fail("sum's variable '{s}' is already a name here", .{lv.slice()});
        self.i = k;
        if (self.peekDrop() != ',') return fail("sum takes 4 arguments (var, from, to, expression)", .{});
        self.i += 1;
        var from_buf: [512]u8 = undefined;
        var to_buf: [512]u8 = undefined;
        var body_buf: [2048]u8 = undefined;
        var from = Cursor{ .buf = &from_buf };
        var to = Cursor{ .buf = &to_buf };
        var body = Cursor{ .buf = &body_buf };
        const outer = self.out;
        const saved = self.compare;
        defer {
            self.out = outer;
            self.compare = saved;
            self.loopvar = null;
        }
        self.compare = false;
        self.out = &from;
        const tfrom = self.exprW();
        if (tfrom < 0 or self.noCmpW() < 0) return -1;
        if (isVec(tyOf(tfrom))) return fail(MSG_VECNUM, .{});
        if (tyOf(tfrom) == .u and settleText(&from, 0, .f) < 0) return -1;
        if (self.peekDrop() != ',') return fail("sum takes 4 arguments (var, from, to, expression)", .{});
        self.i += 1;
        self.out = &to;
        const tto = self.exprW();
        if (tto < 0 or self.noCmpW() < 0) return -1;
        if (isVec(tyOf(tto))) return fail(MSG_VECNUM, .{});
        if (tyOf(tto) == .u and settleText(&to, 0, .f) < 0) return -1;
        if (self.peekDrop() != ',') return fail("sum takes 4 arguments (var, from, to, expression)", .{});
        self.i += 1;
        self.top_sums += 1;
        self.loopvar = lv;
        self.out = &body;
        const tb = self.exprW();
        if (tb < 0 or self.noCmpW() < 0) return -1;
        if (isVec(tyOf(tb))) return fail(MSG_VECNUM, .{});
        self.loopvar = null;
        if (self.peekDrop() != ')') return fail("sum is missing ')'", .{});
        self.i += 1;
        const bt: Ty = if (tyOf(tb) == .u) .f else tyOf(tb);
        if (tyOf(tb) == .u and settleText(&body, 0, .f) < 0) return -1;
        if (from.overflow or to.overflow or body.overflow) return fail("sum is too long", .{});
        var num: [8]u8 = undefined;
        const acc = std.fmt.bufPrint(&num, "acc{d}", .{self.nsum}) catch return -1;
        self.nsum += 1;
        const lvs = lv.slice();
        self.prelude.put("    var ");
        self.prelude.put(acc);
        self.prelude.put(if (bt == .i) " : i32 = 0i;\n    for (var k_" else " : f32 = 0.0;\n    for (var k_");
        self.prelude.put(lvs);
        self.prelude.put(" : i32 = i32(");
        self.prelude.put(std.mem.trim(u8, from.items(), " \t"));
        self.prelude.put("); k_");
        self.prelude.put(lvs);
        self.prelude.put(" < i32(");
        self.prelude.put(std.mem.trim(u8, to.items(), " \t"));
        self.prelude.put("); k_");
        self.prelude.put(lvs);
        self.prelude.put(" = k_");
        self.prelude.put(lvs);
        self.prelude.put(" + 1) { ");
        self.prelude.put(acc);
        self.prelude.put(" = ");
        self.prelude.put(acc);
        self.prelude.put(" + (");
        self.prelude.put(std.mem.trim(u8, body.items(), " \t"));
        self.prelude.put("); }\n");
        outer.put(acc);
        return tyR(bt);
    }

    /// A function, or GL0's two conversions. abs min max clamp sign take
    /// either type and keep it; every other function takes floats.
    fn callW(self: *Rewriter, word: []const u8) i32 {
        const conv: ?Ty = if (std.mem.eql(u8, word, "int")) .i else if (std.mem.eql(u8, word, "float")) .f else null;
        const ctor = ctorWidth(word);
        var fun: ?Fn = null;
        if (conv == null and ctor == 0) {
            for (FUNCS) |f| {
                if (std.mem.eql(u8, f.name, word)) fun = f;
            }
            if (fun == null) return fail("unknown name '{s}' (not a declared scalar, not a whitelisted function)", .{word});
        }
        const name: []const u8 = if (fun) |f| f.name else word;
        if (self.peekDrop() != '(') return fail("function '{s}' needs '('", .{name});
        // the WGSL spelling: the whitelist's (inverseSqrt), a conversion's, a constructor's
        var spelled: []const u8 = name;
        if (ctor != 0) {
            spelled = if (ctor == 2) "vec2<f32>" else if (ctor == 3) "vec3<f32>" else "vec4<f32>";
        } else if (conv) |cv| spelled = if (cv == .i) "i32" else "f32" else {
            for (FUNC_WHITELIST) |f| {
                if (std.ascii.eqlIgnoreCase(f, name)) spelled = f;
            }
        }
        const start = self.out.len;
        self.out.put(spelled);
        self.out.putc('(');
        self.i += 1;
        var args: [4]Ty = undefined;
        var argc: u8 = 0;
        if (self.peekW() != ')') {
            while (true) {
                const r = self.exprW();
                if (r < 0 or self.noCmpW() < 0) return -1;
                if (argc == 4) return fail("function '{s}' takes at most 4 arguments", .{name});
                args[argc] = tyOf(r);
                argc += 1;
                if (self.peekW() == ',') {
                    self.out.putc(',');
                    self.i += 1;
                    continue;
                }
                break;
            }
        }
        if (self.peekW() != ')') return fail("function '{s}' is missing ')'", .{name});
        self.out.putc(')');
        self.i += 1;
        if (ctor == 0) {
            const arity: u8 = if (fun) |f| f.arity else 1;
            if (argc != arity) return fail("function '{s}' takes {d} argument(s), got {d}", .{ name, arity, argc });
        }
        const plan = planCall(name, fun, conv, ctor, args[0..argc]) orelse return -1;
        if (plan.settle) |st| {
            if (settleText(self.out, start, st) < 0) return -1;
        }
        return tyR(plan.result);
    }
};


// ===========================================================================
// THE ROOFS (GK3's numbers, moved here by KP3 so stz.wasm carries them): the
// copy kernel whose time is the device's bandwidth floor, and the register-
// only fma kernel whose time is its compute peak. One text for the native
// checker and for a browser measuring its own adapter.
// ===========================================================================

pub const COPY_N: usize = 4 * 1024 * 1024; // 16 MB in + 16 MB out per copy

pub const COPY_WGSL =
    \\struct StzTile { xoff: u32, p0: u32, p1: u32, p2: u32 };
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\@group(0) @binding(1) var<storage, read> a : array<f32>;
    \\@group(0) @binding(2) var<storage, read_write> o : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i < 4194304u) { o[i] = a[i]; }
    \\}
;

// ---------------------------------------------------------------- the peak kernel (GK3)
// A register-only fma kernel: `chains` independent accumulators per thread
// through p.iters rounds of fma(x, m, b) with m and b from the params uniform
// (so nothing folds at compile time), the body unrolled `unroll` times so the
// loop's counter, compare and branch are amortised over unroll*chains fmas.
// Every accumulator is a NAMED SCALAR -- GK2b's lesson: an array indexed by a
// loop variable lands in local memory and measures the memory, not the ALU.
pub fn fmaSource(comptime chains: usize, comptime unroll: usize) []const u8 {
    @setEvalBranchQuota(400000);
    {
        comptime var s: []const u8 =
            \\struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
            \\@group(0) @binding(0) var<uniform> tile : StzTile;
            \\struct P { iters : u32, n : u32, m : f32, b : f32 }
            \\@group(0) @binding(1) var<uniform> p : P;
            \\@group(0) @binding(2) var<storage, read> a : array<f32>;
            \\@group(0) @binding(3) var<storage, read_write> o : array<f32>;
            \\@compute @workgroup_size(256)
            \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
            \\  let i = gid.x + tile.xoff * 256u;
            \\  if (i >= p.n) { return; }
            \\  let s = a[i];
            \\
        ;
        for (0..chains) |k| {
            s = s ++ std.fmt.comptimePrint("  var x{d} = s + {d}.0 * 0.125;\n", .{ k, k });
        }
        s = s ++ "  for (var k = 0u; k < p.iters; k = k + 1u) {\n";
        for (0..unroll) |_| {
            for (0..chains) |k| {
                s = s ++ std.fmt.comptimePrint("    x{d} = fma(x{d}, p.m, p.b);\n", .{ k, k });
            }
        }
        s = s ++ "  }\n  o[i] = x0";
        for (1..chains) |k| {
            s = s ++ std.fmt.comptimePrint(" + x{d}", .{k});
        }
        s = s ++ ";\n}\n";
        return s;
    }
}

/// The densest variant the probe measured (16 chains, body x16: 256 fma per
/// round) reached 97% of 2048 lanes x 2 x the 3050's 2.1 GHz max clock.
pub const PEAK_CHAINS: usize = 16;
pub const PEAK_UNROLL: usize = 16;
pub const PEAK_WGSL = fmaSource(PEAK_CHAINS, PEAK_UNROLL);
pub const PEAK_THREADS: usize = 4096 * 256; // 1,048,576: enough waves for any adapter here
pub const PEAK_ROUNDS: u32 = 1024; // 4 ms on the 3050, ~35 ms on the iGPU: a BURST, on purpose
pub const PEAK_FLOPS: f64 = @as(f64, @floatFromInt(PEAK_THREADS * PEAK_CHAINS * 2)) * @as(f64, @floatFromInt(PEAK_ROUNDS));

/// KP3: the roof kernels' texts for a runner that measures its own adapter:
/// which 0 = the copy kernel, 1 = the peak kernel. Returns the length, or -1.
pub fn stz_gpu_roof_wgsl(which: i32, out: [*]u8, cap: f64) callconv(.c) i32 {
    const s: []const u8 = switch (which) {
        0 => COPY_WGSL,
        1 => PEAK_WGSL,
        else => return -1,
    };
    const c: usize = @intFromFloat(cap);
    if (s.len > c) return -1;
    @memcpy(out[0..s.len], s);
    return @intCast(s.len);
}

/// KP3: the roof kernels' numbers: 0 the copy's element count, 1 the peak's
/// thread count, 2 its loop iterations (rounds / unroll), 3 its FLOPs per dispatch.
pub fn stz_gpu_roof_number(which: i32) callconv(.c) f64 {
    return switch (which) {
        0 => @floatFromInt(COPY_N),
        1 => @floatFromInt(PEAK_THREADS),
        2 => @floatFromInt(PEAK_ROUNDS / @as(u32, @intCast(PEAK_UNROLL))),
        3 => PEAK_FLOPS,
        else => 0,
    };
}

// ===========================================================================
// THE INTERPRETER (GK6 of SOFTANZA_GPU_PLAN.md) -- the spec, evaluated on
// the CPU, as the checker's REFERENCE for a kernel that has no Zig twin
// ===========================================================================
//
// The same spec the transpiler turns into WGSL is compiled here into a
// postfix program over fixed buffers and run element by element in f32.
// The whitelist is the grammar; what the transpiler refuses, this refuses
// (a Zig test holds the two to that), and what WGSL means, this means:
//   - `%` on f32 is x - y * trunc(x / y), the truncated remainder;
//   - round() is round-half-to-EVEN (WGSL), not half-away-from-zero;
//   - the vector-only names the whitelist carries for the fragment stage
//     (dot, cross, normalize, reflect, vecN) are refused HERE by name: an
//     elementwise kernel has no vectors, and the transpiler would emit WGSL
//     that fails to compile, so the refusal only moves earlier and gets a
//     message.
// Zero-allocation and libc-free (Zig builtins and std.math only), so the
// wasm group carries it and a browser can grade a puzzle without a device.
//
// The program also COUNTS its operations per element (one per operator or
// call), which is the FLOP count the checker's compute ceiling (GK3) reads
// against -- a user kernel declares its own work by what it says.

const Op = enum(u8) {
    k_const, k_in, k_scalar, neg, add, sub, mul, div, mod,
    // KP0
    k_index, k_n, k_var, rd, sum_begin, sum_end,
    c_lt, c_le, c_gt, c_ge, c_eq, c_ne, l_and, l_or,
    // KP3
    k_local, k_group, k_lx, k_ly, k_row, k_col, k_acc, k_tile, sh_rd,
    f_abs, f_min, f_max, f_sqrt, f_exp, f_log, f_sin, f_cos, f_tan, f_floor, f_ceil,
    f_pow, f_clamp, f_sign, f_fract, f_round, f_mix, f_smoothstep, f_step, f_atan2,
    f_asin, f_acos, f_inversesqrt, f_length, f_distance,
    f_tanh, // GK4
    // GL0: when(c, t, f). w_if pops c and jumps to the false value when it is
    // 0; w_else jumps past the false value. The device computes both values
    // and selects; the interpreter computes the chosen one. Neither value has
    // a side effect, so the result is the same, and the sanitizer watches the
    // reads the result depends on.
    w_if, w_else,
    // GL0 (types): the i32 forms, and the two conversions
    i_add, i_sub, i_mul, i_div, i_mod, i_neg, i_min, i_max, i_abs, i_clamp, i_sign,
    ic_lt, ic_le, ic_gt, ic_ge, ic_eq, ic_ne,
    cv_fi, cv_if,
    // GL0 (vectors): the vector functions' names, and the vector ops
    f_dot, f_cross, f_normalize, f_reflect,
    splat, swz, vmap, v_dot, v_len, v_dist, v_norm, v_cross, v_refl,
    // GL0 (typed buffers): a vecN input's own element, and a bounded read of one
    k_inv, rdv,
};

const Fn = struct { name: []const u8, op: Op, arity: u8 };
const FUNCS = [_]Fn{
    .{ .name = "abs", .op = .f_abs, .arity = 1 },           .{ .name = "min", .op = .f_min, .arity = 2 },
    .{ .name = "max", .op = .f_max, .arity = 2 },           .{ .name = "sqrt", .op = .f_sqrt, .arity = 1 },
    .{ .name = "exp", .op = .f_exp, .arity = 1 },           .{ .name = "log", .op = .f_log, .arity = 1 },
    .{ .name = "sin", .op = .f_sin, .arity = 1 },           .{ .name = "cos", .op = .f_cos, .arity = 1 },
    .{ .name = "tan", .op = .f_tan, .arity = 1 },           .{ .name = "floor", .op = .f_floor, .arity = 1 },
    .{ .name = "ceil", .op = .f_ceil, .arity = 1 },         .{ .name = "pow", .op = .f_pow, .arity = 2 },
    .{ .name = "clamp", .op = .f_clamp, .arity = 3 },       .{ .name = "sign", .op = .f_sign, .arity = 1 },
    .{ .name = "fract", .op = .f_fract, .arity = 1 },       .{ .name = "round", .op = .f_round, .arity = 1 },
    .{ .name = "mix", .op = .f_mix, .arity = 3 },           .{ .name = "smoothstep", .op = .f_smoothstep, .arity = 3 },
    .{ .name = "step", .op = .f_step, .arity = 2 },         .{ .name = "atan2", .op = .f_atan2, .arity = 2 },
    .{ .name = "asin", .op = .f_asin, .arity = 1 },         .{ .name = "acos", .op = .f_acos, .arity = 1 },
    .{ .name = "inversesqrt", .op = .f_inversesqrt, .arity = 1 },
    .{ .name = "length", .op = .f_length, .arity = 1 },     .{ .name = "distance", .op = .f_distance, .arity = 2 },
    .{ .name = "tanh", .op = .f_tanh, .arity = 1 },
    .{ .name = "dot", .op = .f_dot, .arity = 2 },           .{ .name = "cross", .op = .f_cross, .arity = 2 },
    .{ .name = "normalize", .op = .f_normalize, .arity = 1 }, .{ .name = "reflect", .op = .f_reflect, .arity = 2 },
};

pub const MAX_OPS = 512;
pub const MAX_CONSTS = 128;
const MAX_DEPTH = 32;
const STACK = 64;
const MAX_SUMS = 4;

pub const Program = struct {
    ops: [MAX_OPS]Op = undefined,
    args: [MAX_OPS]u16 = undefined,
    n: usize = 0,
    consts: [MAX_CONSTS]u32 = undefined, // GL0: the bits, an f32's or an i32's
    n_consts: usize = 0,
    n_ins: usize = 0,
    n_scalars: usize = 0,
    flops: f64 = 0, // operations per element, loops counted once (static)
    ready: bool = false,
    // KP0
    jump: [MAX_OPS]u16 = undefined, // sum_begin -> its sum_end
    nsum: usize = 0,
    sumvar: [MAX_SUMS]Name = undefined,

    fn emit(self: *Program, op: Op, arg: u16) bool {
        if (self.n >= MAX_OPS) return false;
        self.ops[self.n] = op;
        self.args[self.n] = arg;
        self.n += 1;
        return true;
    }
};

var g_prog: Program = .{};
var g_guard: Program = .{}; // KP0: the guard's program; g_guard_kind says whether it is read
var g_guard_kind: enum { default, none, custom } = .default;
var g_eval_flops: f64 = 0; // KP0: operations executed by the last eval, loops included

// KP3: the group's description, compiled. The interpreter runs a GROUP at a
// time: every item of the schedule over all 256 threads before the next one
// starts -- which is what a barrier promises the kernel.
const Kp3 = struct {
    on: bool = false,
    n_shared: usize = 0,
    sizes: [MAX_SHARED]usize = @splat(0),
    kinds: [MAX_ITEMS]ItemKind = undefined,
    shared_of: [MAX_ITEMS]usize = undefined,
    ops: [MAX_ITEMS]ReduceOp = undefined,
    n_items: usize = 0,
    loop_from: usize = 0, // == n_items when there is no tiles loop
    has_tiles: bool = false,
    has_acc: bool = false,
    width_lit: usize = 0, // a literal width, or 0
    width_scalar: ?usize = null, // a scalar width
    lines: [MAX_ITEMS]u16 = @splat(0), // GZ0
    body_line: u16 = 0,
    guard_line: u16 = 0,
    names: [MAX_SHARED]Name = undefined,
};
var g_kp3: Kp3 = .{};
var g_item_idx: [MAX_ITEMS]Program = undefined;
var g_item_val: [MAX_ITEMS]Program = undefined;
var g_count: Program = .{};
var g_sh: [MAX_SHARED][MAX_SHARED_SIZE]f32 = undefined;
var g_acc: [GROUP]f32 = undefined;
var g_tmp_ix: [GROUP]f32 = undefined;
var g_tmp_v: [GROUP]f32 = undefined;

// ---------------------------------------------------------------- GZ0: the sanitizer
// The interpreter runs a group a stage at a time, so it sees what the device
// cannot report: which thread wrote each slot, and which reads found nothing
// written. The grammar already makes some defects unwritable -- every barrier
// stands outside any branch, a tiles count is the same for every thread, a
// stage cannot read the array it writes -- so four remain, and the sanitizer
// names each with the description's line, the threads and the slot:
//   race       two threads of one stage write one slot: the device keeps any
//              one of the writes, the interpreter the last thread's
//   dropped    a stage writes past its array: the kernel drops the write
//   past       a read past a shared array: it reads 0
//   unwritten  a read of a slot no stage of this group wrote: it reads the
//              zero the kernel filled; a max or min reduce counts such a slot
//              (the zero takes part), a sum does not (it adds nothing)
// It runs only when asked (stz_gpu_spec_sanitize); the plain evaluation pays
// one branch per read and per stage.
pub const SAN_RACE = 0;
pub const SAN_DROPPED = 1;
pub const SAN_PAST = 2;
pub const SAN_UNWRITTEN = 3;
pub const SAN_KINDS = 4;
const NOBODY: u16 = 0xFFFF;
const SanWhere = enum(u8) { stage, reduce, accumulate, body, guard };
const SanFinding = struct {
    count: f64 = 0,
    line: u16 = 0,
    where: SanWhere = .body,
    group: usize = 0,
    a: usize = 0, // the thread (for a race, the first writer)
    b: usize = 0, // a race's second writer
    slot: i64 = 0,
    arr: usize = 0,
    same: bool = true, // a race: every colliding write carried one value so far
};
var g_san: bool = false;
var g_san_f: [SAN_KINDS]SanFinding = @splat(.{});
var g_san_written: [MAX_SHARED][MAX_SHARED_SIZE]bool = undefined;
var g_san_writer: [MAX_SHARED_SIZE]u16 = undefined;
var g_san_line: u16 = 0;
var g_san_where: SanWhere = .body;
var g_san_group: usize = 0;

fn sanNote(kind: usize, f: SanFinding) void {
    const cur = &g_san_f[kind];
    if (cur.count == 0) {
        cur.* = f;
        cur.count = 1;
    } else {
        cur.count += 1;
        if (kind == SAN_RACE and !f.same) cur.same = false;
    }
}

fn sanSlot(th: *const Thread, which: usize, raw: f32) void {
    const ix_opt = toIndex(raw);
    if (ix_opt == null or ix_opt.? >= g_kp3.sizes[which]) {
        sanNote(SAN_PAST, .{ .line = g_san_line, .where = g_san_where, .group = th.g, .a = th.l, .slot = if (raw == raw and @abs(raw) < 1e15) @intFromFloat(@trunc(raw)) else -1, .arr = which });
        return;
    }
    if (!g_san_written[which][ix_opt.?])
        sanNote(SAN_UNWRITTEN, .{ .line = g_san_line, .where = g_san_where, .group = th.g, .a = th.l, .slot = @intCast(ix_opt.?), .arr = which });
}

/// Run the compiled description as stz_gpu_spec_eval_masked does, with the
/// sanitizer watching. Returns the number of defect kinds found (0: clean),
/// or -1 when the evaluation itself refused. A description with no shared
/// memory has nothing for it to watch and returns 0.
pub fn stz_gpu_spec_sanitize(ins: [*]const [*]const f32, n_ins: i32, lens: [*]const f64, scalars: [*]const f32, n_scalars: i32, nf: f64, out: [*]f32, mask: ?[*]u8) callconv(.c) i32 {
    g_san_f = @splat(.{});
    g_san = true;
    defer g_san = false;
    if (stz_gpu_spec_eval_masked(ins, n_ins, lens, scalars, n_scalars, nf, out, mask) != 0) return -1;
    var kinds: i32 = 0;
    for (g_san_f) |f| {
        if (f.count > 0) kinds += 1;
    }
    return kinds;
}

/// How many times the last sanitized run met a defect of `kind` (SAN_*).
pub fn stz_gpu_sanitize_count(kind: i32) callconv(.c) f64 {
    if (kind < 0 or kind >= SAN_KINDS) return 0;
    return g_san_f[@intCast(kind)].count;
}

/// The line of the first defect of `kind`, 0 when there is none.
pub fn stz_gpu_sanitize_line(kind: i32) callconv(.c) f64 {
    if (kind < 0 or kind >= SAN_KINDS) return 0;
    return @floatFromInt(g_san_f[@intCast(kind)].line);
}

/// The last sanitized run, one sentence per defect kind found, each naming
/// the line, the threads, the slot and what the device does instead.
pub fn stz_gpu_sanitize_report(out: [*]u8, cap: f64) callconv(.c) i32 {
    var w = Cursor{ .buf = out[0..@intFromFloat(cap)] };
    var num: [512]u8 = undefined;
    const wname = [_][]const u8{ "a stage", "a reduce", "the accumulate line", "the body", "the guard" };
    for (g_san_f, 0..) |f, k| {
        if (f.count == 0) continue;
        const arr = g_kp3.names[f.arr].slice();
        const size = g_kp3.sizes[f.arr];
        const where = wname[@intFromEnum(f.where)];
        const line = switch (k) {
            SAN_RACE => std.fmt.bufPrint(&num, "race: line {d}, {s}: threads {d} and {d} of group {d} both write slot {d} of @{s}; the device keeps any one of the writes ({d} writes collided{s})\n", .{ f.line, where, f.a, f.b, f.group, f.slot, arr, @as(u64, @intFromFloat(f.count)), if (f.same) ", each with the same value, so the answer does not depend on it" else "" }),
            SAN_DROPPED => std.fmt.bufPrint(&num, "dropped: line {d}, {s}: thread {d} of group {d} writes slot {d} of @{s}, which holds {d}; the write is dropped ({d} writes dropped)\n", .{ f.line, where, f.a, f.group, f.slot, arr, size, @as(u64, @intFromFloat(f.count)) }),
            SAN_PAST => std.fmt.bufPrint(&num, "past: line {d}, {s}: thread {d} of group {d} reads slot {d} of @{s}, which holds {d}; it reads 0 ({d} reads)\n", .{ f.line, where, f.a, f.group, f.slot, arr, size, @as(u64, @intFromFloat(f.count)) }),
            else => std.fmt.bufPrint(&num, "unwritten: line {d}, {s}: thread {d} of group {d} reads slot {d} of @{s}, which no stage wrote; it reads the 0 the kernel filled ({d} reads)\n", .{ f.line, where, f.a, f.group, f.slot, arr, @as(u64, @intFromFloat(f.count)) }),
        } catch continue;
        w.put(line);
    }
    return @intCast(w.len);
}

/// One thread, as a program sees it.
const Thread = struct {
    i: usize,
    n: usize,
    l: usize = 0,
    g: usize = 0,
    row: usize = 0,
    col: usize = 0,
    acc: f32 = 0,
    tile: f32 = 0,
};

fn compileInto(p: *Program, text: []const u8, d: *const Decl, where: Where, in_loop: bool, stage_target: ?usize, sink: Sink) i32 {
    p.* = .{};
    var ps = Parser{ .s = text, .d = d, .p = p, .where = where, .in_loop = in_loop, .stage_target = stage_target };
    const r = ps.expr();
    if (r < 0) return -1;
    if (ps.peek() != 0) {
        const c = ps.peek();
        if (c == '<' or c == '>' or c == '=' or c == '!') return fail(MSG_CMP, .{c});
        if (logicWordAt(ps.s, ps.i)) |w| return fail(MSG_LOGIC, .{w});
        if (!exprChar(c)) return fail(MSG_CHAR, .{c});
        return fail("unexpected '{c}' after the expression", .{c});
    }
    // GL0: where the value goes decides its type, as the rewriter's sinkW does
    const t = tyOf(r);
    if (sink == .body and d.out_w > 1) {
        if (t != vecOf(d.out_w)) return fail(MSG_OUTV, .{ d.out_name.slice(), d.out_w, d.out_w });
        p.n_ins = d.n_ins;
        p.n_scalars = d.n_scalars;
        p.ready = true;
        return if (ps.used_group) 1 else 0;
    }
    if (isVec(t)) return fail(MSG_VECNUM, .{});
    switch (sink) {
        .body => {
            const want: Ty = if (d.out_int) .i else .f;
            if (t == .u) {
                if (ps.settle(0, want) < 0) return -1;
            } else if (t != want) return if (want == .i) fail(MSG_OUTI, .{d.out_name.slice()}) else fail(MSG_OUTF, .{d.out_name.slice()});
            // the kernel writes f32(value) into the f32 buffer
            if (want == .i and ps.emit(.cv_if, 0) < 0) return -1;
        },
        .stage_value, .acc_value => {
            if (t == .i) return if (sink == .stage_value) fail(MSG_SHI, .{}) else fail(MSG_ACCI, .{});
            if (t == .u and ps.settle(0, .f) < 0) return -1;
        },
        .stage_index, .count => {
            if (t == .u and ps.settle(0, .f) < 0) return -1;
            if (t == .i and ps.emit(.cv_if, 0) < 0) return -1;
        },
        .guard => {},
    }
    p.n_ins = d.n_ins;
    p.n_scalars = d.n_scalars;
    p.ready = true;
    return if (ps.used_group) 1 else 0;
}

// ---- a recursive-descent compiler over the rhs, WGSL precedence
const Parser = struct {
    s: []const u8,
    i: usize = 0,
    d: *const Decl,
    p: *Program,
    depth: usize = 0,
    compare: bool = false,
    loopvar: ?Name = null,
    // KP3
    where: Where = .body,
    in_loop: bool = false,
    stage_target: ?usize = null,
    used_group: bool = false,
    // GL0 (types): the operations an untyped number wrote, in order. A
    // sub-expression's are the tail from its mark; meeting a typed value
    // settles them (an op retyped, a literal's bits rewritten), and they leave
    // the list. Settled to f32 they stay as written: f32 is how they were emitted.
    poly: [MAX_OPS]u16 = undefined,
    npoly: usize = 0,
    lit_at: [MAX_CONSTS]u16 = undefined, // a whole-number literal's place and length in s
    lit_len: [MAX_CONSTS]u8 = undefined,
    nands: i32 = 0,

    fn mark(self: *const Parser) usize {
        return self.npoly;
    }
    fn polyOp(self: *Parser) i32 {
        if (self.npoly >= MAX_OPS) return fail("expression too long (over {d} operations)", .{MAX_OPS});
        self.poly[self.npoly] = @intCast(self.p.n - 1);
        self.npoly += 1;
        return 0;
    }
    fn settle(self: *Parser, from: usize, to: Ty) i32 {
        var k = from;
        while (k < self.npoly) : (k += 1) {
            const at = self.poly[k];
            if (to == .f) continue;
            const op = self.p.ops[at];
            switch (op) {
                .k_const => {
                    const c = self.p.args[at];
                    const txt = self.s[self.lit_at[c] .. self.lit_at[c] + self.lit_len[c]];
                    const v = std.fmt.parseInt(i64, txt, 10) catch std.math.maxInt(i64);
                    if (v > std.math.maxInt(i32)) return fail(MSG_BIGINT, .{txt});
                    self.p.consts[c] = ib(@intCast(v));
                },
                .k_index, .k_n, .k_local, .k_group, .k_lx, .k_ly, .k_row, .k_col, .k_var, .k_tile => self.p.args[at] |= INT_VAL,
                else => self.p.ops[at] = intForm(op),
            }
        }
        self.npoly = from;
        return 0;
    }
    /// Arithmetic, as the rewriter's arithW: emits the op and returns its type.
    fn arith(self: *Parser, op: Op, a: Ty, b: Ty, ma: usize, mb: usize, at: []const u8) i32 {
        if (!isVec(a) and !isVec(b)) {
            const t = self.unify(a, b, ma, mb, at);
            if (t < 0) return -1;
            if (self.emitT(op, tyOf(t)) < 0) return -1;
            self.p.flops += 1;
            return t;
        }
        if (vecMeet(a, b, at) < 0) return -1;
        if (a == .u and self.settle(ma, .f) < 0) return -1;
        if (b == .u and self.settle(mb, .f) < 0) return -1;
        const v = if (isVec(a)) a else b;
        const mask: u8 = (if (isVec(a)) @as(u8, 0) else 1) | (if (isVec(b)) @as(u8, 0) else 2);
        if (self.emit(.vmap, vmapArg(op, vecWidth(v), 2, mask)) < 0) return -1;
        self.p.flops += @floatFromInt(vecWidth(v));
        return tyR(v);
    }
    fn unify(self: *Parser, a: Ty, b: Ty, ma: usize, mb: usize, at: []const u8) i32 {
        if (a == b) return tyR(a);
        if (a == .b or b == .b) return fail(MSG_COND, .{});
        if (a == .u) return if (self.settle(ma, b) < 0) -1 else tyR(b);
        if (b == .u) return if (self.settle(mb, a) < 0) -1 else tyR(a);
        return fail(MSG_MIXTY, .{at});
    }
    /// Emit the f32 form of `op` at type t: the i32 form when t is i, and
    /// remembered as untyped when t is u.
    fn emitT(self: *Parser, op: Op, t: Ty) i32 {
        if (self.emit(if (t == .i) intForm(op) else op, 0) < 0) return -1;
        if (t == .u) return self.polyOp();
        return 0;
    }

    // guard := andexpr ('or' andexpr)*   -- KP0, compare mode only
    fn orexpr(self: *Parser) i32 {
        const first = self.andexpr();
        if (first < 0) return -1;
        var ands = self.nands > 0;
        var ors = false;
        while (self.word("or")) {
            ors = true;
            const r = self.andexpr();
            if (r < 0) return -1;
            if (self.nands > 0) ands = true;
            if (ands) return fail(MSG_MIX, .{});
            if (self.emit(.l_or, 0) < 0) return -1;
            self.p.flops += 1;
        }
        if (ors and ands) return fail(MSG_MIX, .{});
        return if (ors) tyR(.b) else first;
    }
    // the type of what it joined; the number of 'and's in self.nands
    fn andexpr(self: *Parser) i32 {
        const first = self.cmp();
        if (first < 0) return -1;
        var n: i32 = 0;
        while (self.word("and")) {
            if (self.cmp() < 0) return -1;
            if (self.emit(.l_and, 0) < 0) return -1;
            self.p.flops += 1;
            n += 1;
        }
        self.nands = n;
        return if (n > 0) tyR(.b) else first;
    }
    fn cmp(self: *Parser) i32 {
        const ma = self.mark();
        const a = self.expr();
        if (a < 0) return -1;
        const c = self.peek();
        if (c == '<' or c == '>' or c == '=' or c == '!') {
            const two = self.i + 1 < self.s.len and self.s[self.i + 1] == '=';
            if (c == '=' and !two) return fail("use '==' to compare in a guard", .{});
            if (c == '!' and !two) return fail("'!' alone is not admitted; use '!='", .{});
            const op: Op = if (c == '<') (if (two) .c_le else .c_lt) else if (c == '>') (if (two) .c_ge else .c_gt) else if (c == '=') .c_eq else .c_ne;
            const txt = self.s[self.i .. self.i + (if (two) @as(usize, 2) else 1)];
            self.i += txt.len;
            const mb = self.mark();
            const b = self.expr();
            if (b < 0) return -1;
            if (isVec(tyOf(a)) or isVec(tyOf(b))) return fail(MSG_VECCMP, .{});
            const t = self.unify(tyOf(a), tyOf(b), ma, mb, txt);
            if (t < 0) return -1;
            if (tyOf(t) == .u and self.settle(ma, .f) < 0) return -1;
            if (self.emit(if (tyOf(t) == .i) intForm(op) else op, 0) < 0) return -1;
            self.p.flops += 1;
            return tyR(.b);
        }
        return a;
    }
    // consume a bare word if it is exactly `w`
    fn word(self: *Parser, w: []const u8) bool {
        self.skip();
        if (self.i + w.len > self.s.len) return false;
        if (!std.ascii.eqlIgnoreCase(self.s[self.i .. self.i + w.len], w)) return false;
        const after = self.i + w.len;
        if (after < self.s.len and (std.ascii.isAlphanumeric(self.s[after]) or self.s[after] == '_')) return false;
        self.i = after;
        return true;
    }

    fn skip(self: *Parser) void {
        while (self.i < self.s.len and (self.s[self.i] == ' ' or self.s[self.i] == '\t')) : (self.i += 1) {}
    }
    fn peek(self: *Parser) u8 {
        self.skip();
        return if (self.i < self.s.len) self.s[self.i] else 0;
    }
    // GL0: a comparison where a value ends is named as one, as the rewriter
    // names it, not as the bracket it stands before
    fn noCmp(self: *Parser) i32 {
        const c = self.peek();
        if (!self.compare and (c == '<' or c == '>' or c == '=' or c == '!')) return fail(MSG_CMP, .{c});
        if (!self.compare) {
            if (logicWordAt(self.s, self.i)) |w| return fail(MSG_LOGIC, .{w});
        }
        return 0;
    }
    fn emit(self: *Parser, op: Op, arg: u16) i32 {
        if (!self.p.emit(op, arg)) return fail("expression too long (over {d} operations)", .{MAX_OPS});
        return 0;
    }

    // expr := term (('+' | '-') term)*
    fn expr(self: *Parser) i32 {
        if (self.depth >= MAX_DEPTH) return fail("expression nested too deep", .{});
        self.depth += 1;
        defer self.depth -= 1;
        const ma = self.mark();
        var t = self.term();
        if (t < 0) return -1;
        while (true) {
            const c = self.peek();
            if (c != '+' and c != '-') break;
            self.i += 1;
            const mb = self.mark();
            const r = self.term();
            if (r < 0) return -1;
            t = self.arith(if (c == '+') .add else .sub, tyOf(t), tyOf(r), ma, mb, if (c == '+') "+" else "-");
            if (t < 0) return -1;
        }
        return t;
    }
    // term := unary (('*' | '/' | '%') unary)*
    fn term(self: *Parser) i32 {
        const ma = self.mark();
        var t = self.unary();
        if (t < 0) return -1;
        while (true) {
            const c = self.peek();
            if (c != '*' and c != '/' and c != '%') break;
            self.i += 1;
            const mb = self.mark();
            const r = self.unary();
            if (r < 0) return -1;
            t = self.arith(if (c == '*') .mul else if (c == '/') .div else .mod, tyOf(t), tyOf(r), ma, mb, if (c == '*') "*" else if (c == '/') "/" else "%");
            if (t < 0) return -1;
        }
        return t;
    }
    // unary := '-' unary | primary
    fn unary(self: *Parser) i32 {
        if (self.peek() == '-') {
            self.i += 1;
            const t = self.unary();
            if (t < 0) return -1;
            if (isVec(tyOf(t))) {
                if (self.emit(.vmap, vmapArg(.neg, vecWidth(tyOf(t)), 1, 0)) < 0) return -1;
                self.p.flops += @floatFromInt(vecWidth(tyOf(t)));
                return t;
            }
            if (self.emitT(.neg, tyOf(t)) < 0) return -1;
            self.p.flops += 1;
            return t;
        }
        if (self.peek() == '+') {
            self.i += 1;
            return self.unary();
        }
        return self.primary();
    }

    /// An index inside '[' ']': settled to f32 when untyped; an i32 index
    /// marks its read op (INT_IDX). Returns the flag to add, or -1.
    fn index(self: *Parser, nm: []const u8) i32 {
        self.i += 1;
        const saved = self.compare;
        self.compare = false;
        const m = self.mark();
        const r = self.expr();
        const r2 = if (r < 0) r else self.noCmp();
        self.compare = saved;
        if (r2 < 0) return -1;
        if (isVec(tyOf(r))) return fail(MSG_VECNUM, .{});
        if (tyOf(r) == .u and self.settle(m, .f) < 0) return -1;
        if (self.peek() != ']') return fail("missing ']' after '@{s}['", .{nm});
        self.i += 1;
        self.p.flops += 1;
        return if (tyOf(r) == .i) INT_IDX else 0;
    }

    // primary := atom ('.' components)*  -- GL0: a swizzle
    fn primary(self: *Parser) i32 {
        const r = self.atom();
        if (r < 0) return -1;
        var t = tyOf(r);
        while (self.i + 1 < self.s.len and self.s[self.i] == '.' and std.ascii.isAlphabetic(self.s[self.i + 1])) {
            var j = self.i + 1;
            while (j < self.s.len and std.ascii.isAlphanumeric(self.s[j])) : (j += 1) {}
            const sw = swizzleOf(t, self.s[self.i + 1 .. j]) orelse return -1;
            if (self.emit(.swz, sw.arg) < 0) return -1;
            self.i = j;
            t = sw.out;
        }
        return tyR(t);
    }
    // atom := number | '@' name | name '(' args ')' | scalar | '(' expr ')'
    fn atom(self: *Parser) i32 {
        const c = self.peek();
        if (c == 0) return fail("expression ends where a value was expected", .{});
        if (c == '(') {
            self.i += 1;
            // GT0 (2026-10-28): in a guard a parenthesis may hold a condition,
            // '@i < n and (A or B)', as the transpiler always let through to
            // WGSL; the interpreter read only arithmetic there and refused it
            const r = if (self.compare) self.orexpr() else self.expr();
            if (r < 0 or self.noCmp() < 0) return -1;
            if (self.peek() != ')') return fail("missing ')'", .{});
            self.i += 1;
            return r;
        }
        if (std.ascii.isDigit(c) or c == '.') {
            var j = self.i;
            while (j < self.s.len and (std.ascii.isDigit(self.s[j]) or self.s[j] == '.')) : (j += 1) {}
            const v = std.fmt.parseFloat(f32, self.s[self.i..j]) catch
                return fail("bad number '{s}'", .{self.s[self.i..j]});
            if (self.p.n_consts >= MAX_CONSTS) return fail("too many numbers in the expression", .{});
            const ci = self.p.n_consts;
            self.p.consts[ci] = fb(v);
            self.lit_at[ci] = @intCast(self.i);
            self.lit_len[ci] = @intCast(@min(j - self.i, 255));
            self.p.n_consts += 1;
            const whole = std.mem.indexOfScalar(u8, self.s[self.i..j], '.') == null;
            self.i = j;
            if (self.emit(.k_const, @intCast(ci)) < 0) return -1;
            if (!whole) return tyR(.f);
            if (self.polyOp() < 0) return -1;
            return tyR(.u);
        }
        if (c == '@') {
            var j = self.i + 1;
            while (j < self.s.len and (std.ascii.isAlphanumeric(self.s[j]) or self.s[j] == '_')) : (j += 1) {}
            var nm: Name = .{};
            if (j == self.i + 1 or !lowerInto(&nm, self.s[self.i + 1 .. j]))
                return fail("bad @name at '{s}'", .{self.s[self.i..@min(self.i + 8, self.s.len)]});
            if (self.where == .count) return fail(MSG_COUNT, .{});
            if (std.mem.eql(u8, nm.slice(), "i")) {
                self.i = j;
                if (self.emit(.k_index, 0) < 0 or self.polyOp() < 0) return -1;
                return tyR(.u);
            }
            // KP3: the group's own names, the accumulator, a shared slot
            if (groupName(nm.slice()) != null) {
                const s = nm.slice();
                if ((std.mem.eql(u8, s, "row") or std.mem.eql(u8, s, "col")) and self.d.width.len == 0)
                    return fail(MSG_ROWCOL, .{s});
                self.used_group = true;
                self.i = j;
                const op: Op = if (std.mem.eql(u8, s, "l")) .k_local else if (std.mem.eql(u8, s, "g")) .k_group else if (std.mem.eql(u8, s, "lx")) .k_lx else if (std.mem.eql(u8, s, "ly")) .k_ly else if (std.mem.eql(u8, s, "row")) .k_row else .k_col;
                if (self.emit(op, 0) < 0 or self.polyOp() < 0) return -1;
                return tyR(.u);
            }
            if (std.mem.eql(u8, nm.slice(), "acc")) {
                if (!self.d.has_acc or !(self.where == .accumulate or self.where == .body)) return fail(MSG_ACC, .{});
                self.i = j;
                if (self.emit(.k_acc, 0) < 0) return -1;
                return tyR(.f);
            }
            if (self.d.sharedIndex(nm.slice())) |si| {
                self.i = j;
                if (self.peek() != '[') return fail(MSG_SHNOIDX, .{ nm.slice(), nm.slice() });
                if (self.stage_target) |st| {
                    if (st == si) return fail(MSG_RACE, .{nm.slice()});
                }
                const flag = self.index(nm.slice());
                if (flag < 0) return -1;
                self.used_group = true;
                if (self.emit(.sh_rd, @as(u16, @intCast(si)) | @as(u16, @intCast(flag))) < 0) return -1;
                return tyR(.f);
            }
            const idx = nameIn(self.d.ins[0..], self.d.n_ins, nm.slice()) orelse {
                if (std.mem.eql(u8, nm.slice(), self.d.out_name.slice()))
                    return fail("the output '@{s}' cannot be read", .{nm.slice()});
                return fail("undeclared vector '@{s}'", .{nm.slice()});
            };
            self.i = j;
            const vflag: u16 = if (self.d.in_int[idx]) INT_VAL else 0;
            const t: Ty = if (self.d.in_w[idx] > 1) vecOf(self.d.in_w[idx]) else if (self.d.in_int[idx]) .i else .f;
            if (self.d.in_w[idx] > 1) {
                // GL0 (typed buffers): the width rides in the op's argument
                const wa: u16 = @as(u16, @intCast(idx)) | (@as(u16, self.d.in_w[idx]) << 8);
                if (self.peek() == '[') {
                    const flag = self.index(nm.slice());
                    if (flag < 0) return -1;
                    if (self.emit(.rdv, wa | @as(u16, @intCast(flag))) < 0) return -1;
                } else if (self.where == .stage or self.where == .accumulate) {
                    if (self.emit(.k_index, 0) < 0) return -1;
                    self.p.flops += 1;
                    if (self.emit(.rdv, wa) < 0) return -1;
                } else if (self.emit(.k_inv, wa) < 0) return -1;
                return tyR(t);
            }
            if (self.peek() != '[' and (self.where == .stage or self.where == .accumulate)) {
                // a schedule item's own element is a bounded read, as the kernel's rd_ is
                if (self.emit(.k_index, 0) < 0) return -1;
                self.p.flops += 1;
                if (self.emit(.rd, @as(u16, @intCast(idx)) | vflag) < 0) return -1;
                return tyR(t);
            }
            if (self.peek() == '[') {
                // a neighbour read: the index expression, then rd
                const flag = self.index(nm.slice());
                if (flag < 0) return -1;
                if (self.emit(.rd, @as(u16, @intCast(idx)) | vflag | @as(u16, @intCast(flag))) < 0) return -1;
                return tyR(t);
            }
            if (self.emit(.k_in, @as(u16, @intCast(idx)) | vflag) < 0) return -1;
            return tyR(t);
        }
        if (std.ascii.isAlphabetic(c) or c == '_') {
            var j = self.i;
            while (j < self.s.len and (std.ascii.isAlphanumeric(self.s[j]) or self.s[j] == '_')) : (j += 1) {}
            var nm: Name = .{};
            if (!lowerInto(&nm, self.s[self.i..j]))
                return fail("name too long at '{s}'", .{self.s[self.i..@min(self.i + 8, self.s.len)]});
            self.i = j;
            if (std.mem.eql(u8, nm.slice(), "n")) {
                if (self.emit(.k_n, 0) < 0 or self.polyOp() < 0) return -1;
                return tyR(.u);
            }
            if (self.loopvar) |lv| {
                if (std.mem.eql(u8, nm.slice(), lv.slice())) {
                    if (self.emit(.k_var, @intCast(self.p.nsum - 1)) < 0 or self.polyOp() < 0) return -1;
                    return tyR(.u);
                }
            }
            if (self.in_loop and self.d.tiles.len != 0 and std.mem.eql(u8, nm.slice(), self.d.tilevar.slice())) {
                if (self.emit(.k_tile, 0) < 0 or self.polyOp() < 0) return -1;
                return tyR(.u);
            }
            if (std.mem.eql(u8, nm.slice(), "and") or std.mem.eql(u8, nm.slice(), "or"))
                return fail("'{s}' belongs to the guard line, not to a body", .{nm.slice()});
            if (nameIn(self.d.scalars[0..], self.d.n_scalars, nm.slice())) |si| {
                const int = self.d.sc_int[si];
                if (self.emit(.k_scalar, @as(u16, @intCast(si)) | (if (int) INT_VAL else 0)) < 0) return -1;
                return tyR(if (int) .i else .f);
            }
            if (std.mem.eql(u8, nm.slice(), "when")) return self.when();
            if (std.mem.eql(u8, nm.slice(), "sum")) return self.sum();
            return self.call(nm.slice());
        }
        return fail("character '{c}' is not part of the elementwise language", .{c});
    }

    fn when(self: *Parser) i32 {
        if (self.peek() != '(') return fail(MSG_WHEN, .{});
        const close = Rewriter.matching(self.s, self.i) orelse return fail("when is missing ')'", .{});
        var parts: [3][]const u8 = undefined;
        if (splitTop(self.s, self.i, close, &parts) != 3) return fail(MSG_WHEN, .{});
        if (!condShape(parts[0])) return fail(MSG_COND, .{});
        self.i += 1;
        const saved = self.compare;
        defer self.compare = saved;
        self.compare = true;
        if (self.orexpr() < 0) return -1;
        self.compare = false;
        if (self.peek() != ',') return fail(MSG_WHEN, .{});
        self.i += 1;
        const at_if = self.p.n;
        if (self.emit(.w_if, 0) < 0) return -1;
        const mt = self.mark();
        const tt = self.expr();
        if (tt < 0 or self.noCmp() < 0) return -1;
        if (self.peek() != ',') return fail(MSG_WHEN, .{});
        self.i += 1;
        const at_else = self.p.n;
        if (self.emit(.w_else, 0) < 0) return -1;
        self.p.jump[at_if] = @intCast(self.p.n);
        const mf = self.mark();
        const tf = self.expr();
        if (tf < 0 or self.noCmp() < 0) return -1;
        if (self.peek() != ')') return fail("when is missing ')'", .{});
        self.i += 1;
        self.p.jump[at_else] = @intCast(self.p.n);
        self.p.flops += 1;
        if (isVec(tyOf(tt)) or isVec(tyOf(tf))) return if (vecSame(tyOf(tt), tyOf(tf), "when") < 0) -1 else tt;
        return self.unify(tyOf(tt), tyOf(tf), mt, mf, "when");
    }

    fn sum(self: *Parser) i32 {
        if (self.where == .count) return fail(MSG_SUMCOUNT, .{});
        if (self.loopvar != null) return fail("a sum inside a sum is not admitted (one level; shared memory is KP3's)", .{});
        if (self.p.nsum >= MAX_SUMS) return fail("too many sums (max {d})", .{MAX_SUMS});
        if (self.peek() != '(') return fail("sum needs '(var, from, to, expression)'", .{});
        {
            const close = Rewriter.matching(self.s, self.i) orelse return fail("sum is missing ')'", .{});
            var parts: [4][]const u8 = undefined;
            const np = splitTop(self.s, self.i, close, &parts);
            if (np != 4) return fail("sum takes 4 arguments (var, from, to, expression), got {d}", .{np});
        }
        self.i += 1;
        self.skip();
        var k = self.i;
        while (k < self.s.len and (std.ascii.isAlphanumeric(self.s[k]) or self.s[k] == '_')) : (k += 1) {}
        var lv: Name = .{};
        if (k == self.i or !lowerInto(&lv, self.s[self.i..k]) or !validIdent(lv.slice()))
            return fail("sum's variable must be a name, got '{s}'", .{self.s[self.i..@min(k, self.i + 8)]});
        if (reservedName(lv.slice()) != null or nameIn(self.d.ins[0..], self.d.n_ins, lv.slice()) != null or
            nameIn(self.d.scalars[0..], self.d.n_scalars, lv.slice()) != null)
            return fail("sum's variable '{s}' is already a name here", .{lv.slice()});
        self.i = k;
        if (self.peek() != ',') return fail("sum takes 4 arguments (var, from, to, expression)", .{});
        self.i += 1;
        const saved = self.compare;
        defer self.compare = saved;
        self.compare = false;
        // the bounds: f32 when untyped, an i32 bound read as f32 by sum_begin
        var bound: usize = 0;
        while (bound < 2) : (bound += 1) {
            const m = self.mark();
            const tb = self.expr();
            if (tb < 0 or self.noCmp() < 0) return -1;
            if (isVec(tyOf(tb))) return fail(MSG_VECNUM, .{});
            if (tyOf(tb) == .u and self.settle(m, .f) < 0) return -1;
            if (tyOf(tb) == .i and self.emit(.cv_if, 0) < 0) return -1;
            if (self.peek() != ',') return fail("sum takes 4 arguments (var, from, to, expression)", .{});
            self.i += 1;
        }
        const slot = self.p.nsum;
        self.p.sumvar[slot] = lv;
        self.p.nsum += 1;
        const begin = self.p.n;
        if (self.emit(.sum_begin, @intCast(slot)) < 0) return -1;
        self.loopvar = lv;
        const m = self.mark();
        const r = self.expr();
        const r2 = if (r < 0) r else self.noCmp();
        self.loopvar = null;
        if (r2 < 0) return -1;
        if (isVec(tyOf(r))) return fail(MSG_VECNUM, .{});
        if (self.peek() != ')') return fail("sum is missing ')'", .{});
        self.i += 1;
        const bt: Ty = if (tyOf(r) == .u) .f else tyOf(r);
        if (tyOf(r) == .u and self.settle(m, .f) < 0) return -1;
        self.p.jump[begin] = @intCast(self.p.n);
        self.p.jump[self.p.n] = @intCast(begin);
        self.p.flops += 1;
        if (self.emit(.sum_end, @as(u16, @intCast(slot)) | (if (bt == .i) INT_VAL else 0)) < 0) return -1;
        return tyR(bt);
    }

    fn call(self: *Parser, fname: []const u8) i32 {
        const conv: ?Ty = if (std.mem.eql(u8, fname, "int")) .i else if (std.mem.eql(u8, fname, "float")) .f else null;
        const ctor = ctorWidth(fname);
        var fun: ?Fn = null;
        if (conv == null and ctor == 0) {
            for (FUNCS) |f| {
                if (std.mem.eql(u8, f.name, fname)) fun = f;
            }
            if (fun == null) return fail("unknown name '{s}' (not a declared scalar, not a whitelisted function)", .{fname});
        }
        const name: []const u8 = if (fun) |f| f.name else fname;
        if (self.peek() != '(') return fail("function '{s}' needs '('", .{name});
        self.i += 1;
        const start = self.mark();
        var args: [4]Ty = undefined;
        var argc: u8 = 0;
        if (self.peek() != ')') {
            while (true) {
                const r = self.expr();
                if (r < 0 or self.noCmp() < 0) return -1;
                if (argc == 4) return fail("function '{s}' takes at most 4 arguments", .{name});
                args[argc] = tyOf(r);
                argc += 1;
                if (self.peek() == ',') {
                    self.i += 1;
                    continue;
                }
                break;
            }
        }
        if (self.peek() != ')') return fail("function '{s}' is missing ')'", .{name});
        self.i += 1;
        if (ctor == 0) {
            const arity: u8 = if (fun) |f| f.arity else 1;
            if (argc != arity) return fail("function '{s}' takes {d} argument(s), got {d}", .{ name, arity, argc });
        }
        const plan = planCall(name, fun, conv, ctor, args[0..argc]) orelse return -1;
        if (plan.settle) |st| {
            if (self.settle(start, st) < 0) return -1;
        }
        const n: f64 = @floatFromInt(plan.n);
        switch (plan.mode) {
            .conv => {
                if (conv.? == .i and args[0] == .f and self.emit(.cv_fi, 0) < 0) return -1;
                if (conv.? == .f and args[0] == .i and self.emit(.cv_if, 0) < 0) return -1;
            },
            .scalar => {
                self.p.flops += 1;
                if (self.emitT(fun.?.op, plan.result) < 0) return -1;
            },
            .vmap => {
                self.p.flops += n;
                if (self.emit(.vmap, vmapArg(fun.?.op, plan.n, argc, plan.mask)) < 0) return -1;
            },
            .ctor => {},
            .splat => if (self.emit(.splat, plan.n) < 0) return -1,
            else => {
                const op: Op = switch (plan.mode) {
                    .vdot => .v_dot,
                    .vlen => .v_len,
                    .vdist => .v_dist,
                    .vnorm => .v_norm,
                    .vcross => .v_cross,
                    else => .v_refl,
                };
                self.p.flops += 2 * n;
                if (self.emit(op, plan.n) < 0) return -1;
            },
        }
        return tyR(plan.result);
    }
};

/// Compile a spec into the interpreter's program (one slot, this module).
/// 0 = ready; -1 with the reason in stz_gpu_wgsl_error. Needs no device.
pub fn stz_gpu_spec_compile(spec: [*]const u8, spec_len: f64) callconv(.c) i32 {
    const text = spec[0..@intFromFloat(spec_len)];
    err_len = 0;
    g_prog = .{};
    g_kp3 = .{};
    var d: Decl = .{};
    if (parseDecl(text, &d) < 0) return -1;
    var used_group = false;
    {
        const r = compileInto(&g_prog, d.rhs, &d, .body, false, null, .body);
        if (r < 0) return -1;
        if (r == 1) used_group = true;
    }
    g_prog.ready = false; // set again only when everything compiled
    // KP0: the guard
    g_guard = .{};
    g_guard_kind = .default;
    if (d.guard) |g| {
        if (std.mem.eql(u8, g, "none")) {
            g_guard_kind = .none;
        } else {
            g_guard_kind = .custom;
            if (!condShape(g)) return fail(MSG_COND, .{});
            var pg = Parser{ .s = g, .d = &d, .p = &g_guard, .compare = true, .where = .guard };
            if (pg.orexpr() < 0) return -1;
            if (pg.peek() != 0) return fail("unexpected '{c}' after the guard", .{pg.peek()});
            if (pg.used_group) used_group = true;
            g_guard.ready = true;
        }
    }
    // KP3: the schedule, the tiles count, the width
    if (d.tiles.len != 0) {
        if (compileInto(&g_count, d.tiles, &d, .count, false, null, .count) < 0) return -1;
    }
    for (0..d.n_items) |k| {
        const it = d.items[k];
        const inside = d.loop_from != null and k >= d.loop_from.?;
        g_kp3.kinds[k] = it.kind;
        g_kp3.shared_of[k] = it.shared;
        g_kp3.ops[k] = it.op;
        g_kp3.lines[k] = it.line;
        switch (it.kind) {
            .stage => {
                if (compileInto(&g_item_idx[k], it.index, &d, .stage, inside, it.shared, .stage_index) < 0) return -1;
                if (compileInto(&g_item_val[k], it.value, &d, .stage, inside, it.shared, .stage_value) < 0) return -1;
                g_prog.flops += g_item_idx[k].flops + g_item_val[k].flops;
            },
            .accumulate => {
                if (compileInto(&g_item_val[k], it.value, &d, .accumulate, inside, null, .acc_value) < 0) return -1;
                g_prog.flops += g_item_val[k].flops;
            },
            .reduce => g_prog.flops += 1,
        }
    }
    g_kp3.n_items = d.n_items;
    g_kp3.loop_from = d.loop_from orelse d.n_items;
    g_kp3.has_tiles = d.tiles.len != 0;
    g_kp3.has_acc = d.has_acc;
    g_kp3.n_shared = d.n_shared;
    for (0..d.n_shared) |s| g_kp3.sizes[s] = d.shared_size[s];
    for (0..d.n_shared) |s| g_kp3.names[s] = d.shared[s];
    g_kp3.body_line = d.body_line;
    g_kp3.guard_line = d.guard_line;
    if (d.width.len != 0) {
        if (parseSize(d.width)) |v| {
            g_kp3.width_lit = v;
        } else {
            var lowered: Name = .{};
            _ = lowerInto(&lowered, d.width);
            g_kp3.width_scalar = nameIn(d.scalars[0..], d.n_scalars, lowered.slice());
        }
    }
    g_kp3.on = d.n_shared > 0 or d.n_items > 0 or d.width.len > 0 or used_group;
    g_out_w = d.out_w;
    for (0..MAX_VECS) |k| g_in_w[k] = d.in_w[k];
    g_prog.ready = true;
    return 0;
}

/// KP0: the operations the last stz_gpu_spec_eval executed, loops included --
/// the FLOP count the checker's compute ceiling reads for a spec.
pub fn stz_gpu_spec_eval_flops() callconv(.c) f64 {
    return g_eval_flops;
}

/// Operations per element of the compiled spec (0 if none is compiled).
/// GL0 (typed buffers): the floats per element of the output, and of input
/// k, in the description compiled last -- so a host sizes its buffers from
/// the engine's reading, never from its own parse of the declarations.
var g_out_w: usize = 1;
var g_in_w: [MAX_VECS]usize = @splat(1);
pub fn stz_gpu_spec_out_width() callconv(.c) f64 {
    return @floatFromInt(g_out_w);
}
pub fn stz_gpu_spec_in_width(k: i32) callconv(.c) f64 {
    if (k < 0 or k >= MAX_VECS) return 1;
    return @floatFromInt(g_in_w[@intCast(k)]);
}

pub fn stz_gpu_spec_flops() callconv(.c) f64 {
    return if (g_prog.ready) g_prog.flops else 0;
}
pub fn stz_gpu_spec_inputs() callconv(.c) i32 {
    return if (g_prog.ready) @intCast(g_prog.n_ins) else -1;
}
pub fn stz_gpu_spec_scalars() callconv(.c) i32 {
    return if (g_prog.ready) @intCast(g_prog.n_scalars) else -1;
}

fn roundEven(x: f32) f32 {
    const t = @trunc(x);
    const frac = x - t;
    if (frac == 0.5 or frac == -0.5) {
        // a tie: to the even neighbour
        return if (@rem(t, 2.0) == 0.0) t else t + (if (x > 0) @as(f32, 1.0) else @as(f32, -1.0));
    }
    return @round(x);
}

fn wgslMod(x: f32, y: f32) f32 {
    return x - y * @trunc(x / y);
}

fn toIndex(x: f32) ?usize {
    // WGSL i32(x) truncates toward zero; out of i32's range is out of range here
    if (!(x > -2147483648.0 and x < 2147483648.0)) return null;
    const k: i64 = @intFromFloat(@trunc(x));
    if (k < 0) return null;
    return @intCast(k);
}

const Frame = struct { v: f32 = 0, to: f32 = 0, acc: u32 = 0 };

// GL0 (types): a stack slot holds 32 bits, read as the op's own type. An
// f32 slot keeps its bits; a bool is 1.0 or 0.0, as the comparisons always
// pushed. The flags ride on an op's argument.
inline fn fv(x: u32) f32 {
    return @bitCast(x);
}
inline fn fb(x: f32) u32 {
    return @bitCast(x);
}
inline fn iv(x: u32) i32 {
    return @bitCast(x);
}
inline fn ib(x: i32) u32 {
    return @bitCast(x);
}
const INT_VAL: u16 = 0x8000; // the value the op pushes (or a sum accumulates) is an i32
const INT_IDX: u16 = 0x4000; // the index a read takes is an i32
const ARG_MASK: u16 = 0x3FFF;

/// WGSL's i32(f32): toward zero, saturating at the ends of the range an f32
/// can hold -- 2147483520 is the largest f32 below 2^31 (measured on the RTX
/// 3050: int(3e9) is 2147483520). NaN, which WGSL leaves to the device, is
/// the most negative int there, and here.
fn toI32(x: f32) i32 {
    if (x != x) return std.math.minInt(i32);
    if (x >= 2147483520.0) return 2147483520;
    if (x <= -2147483648.0) return std.math.minInt(i32);
    return @intFromFloat(@trunc(x));
}
/// WGSL's integer division and remainder: by zero, and the most negative
/// value by -1, give the dividend and 0 (naga writes the same polyfill).
fn iDiv(a: i32, b: i32) i32 {
    if (b == 0 or (a == std.math.minInt(i32) and b == -1)) return a;
    return @divTrunc(a, b);
}
fn iRem(a: i32, b: i32) i32 {
    if (b == 0 or (a == std.math.minInt(i32) and b == -1)) return 0;
    return @rem(a, b);
}
fn iIndex(x: i32) ?usize {
    return if (x < 0) null else @intCast(x);
}

/// The f32 meaning of an op on up to three operands -- ONE definition, used for
/// a number and for every component of a vector (GL0), so the two cannot drift.
fn applyF(op: Op, x: f32, y: f32, z: f32) f32 {
    return switch (op) {
        .add => x + y,
        .sub => x - y,
        .mul => x * y,
        .div => x / y,
        .mod => wgslMod(x, y),
        .neg => -x,
        .f_min => @min(x, y),
        .f_max => @max(x, y),
        .f_pow => std.math.pow(f32, x, y),
        .f_step => if (y < x) 0.0 else 1.0,
        .f_atan2 => std.math.atan2(x, y),
        .f_distance => @abs(x - y),
        .f_clamp => @min(@max(x, y), z),
        .f_mix => x * (1.0 - z) + y * z,
        .f_smoothstep => blk: {
            const t = @min(@max((z - x) / (y - x), 0.0), 1.0);
            break :blk t * t * (3.0 - 2.0 * t);
        },
        .f_abs, .f_length => @abs(x),
        .f_sqrt => @sqrt(x),
        .f_exp => @exp(x),
        .f_log => @log(x),
        .f_sin => @sin(x),
        .f_cos => @cos(x),
        .f_tan => @tan(x),
        .f_floor => @floor(x),
        .f_ceil => @ceil(x),
        .f_sign => if (x > 0) 1.0 else if (x < 0) -1.0 else x,
        .f_fract => x - @floor(x),
        .f_round => roundEven(x),
        .f_asin => std.math.asin(x),
        .f_acos => std.math.acos(x),
        .f_inversesqrt => 1.0 / @sqrt(x),
        .f_tanh => std.math.tanh(x),
        else => std.math.nan(f32),
    };
}

/// Run one program over element `i`. Returns the value, or null on a stack fault.
fn runProgram(p: *const Program, th: *const Thread, ins: [*]const [*]const f32, lens: [*]const f64, scalars: [*]const f32, ops_out: *f64, res: ?[]f32) ?f32 {
    const i = th.i;
    const n = th.n;
    var st: [STACK]u32 = undefined;
    var sp: usize = 0;
    var frames: [MAX_SUMS]Frame = undefined;
    var ops: f64 = 0;
    var k: usize = 0;
    while (k < p.n) {
        var next = k + 1;
        const arg = p.args[k];
        const int = arg & INT_VAL != 0;
        switch (p.ops[k]) {
            .k_const => {
                if (sp >= STACK) return null;
                st[sp] = p.consts[arg];
                sp += 1;
            },
            .k_in => {
                if (sp >= STACK) return null;
                // bounded: a host that hands an input shorter than n reads 0, never past it
                const x = if (i < @as(usize, @intFromFloat(lens[arg & ARG_MASK]))) ins[arg & ARG_MASK][i] else 0;
                st[sp] = if (int) ib(toI32(x)) else fb(x);
                sp += 1;
            },
            .k_scalar => {
                if (sp >= STACK) return null;
                const x = scalars[arg & ARG_MASK];
                st[sp] = if (int) ib(toI32(x)) else fb(x);
                sp += 1;
            },
            .k_var, .k_tile => {
                if (sp >= STACK) return null;
                const x: f32 = if (p.ops[k] == .k_var) frames[arg & ARG_MASK].v else th.tile;
                st[sp] = if (int) ib(toI32(x)) else fb(x);
                sp += 1;
            },
            .k_index, .k_n, .k_local, .k_group, .k_lx, .k_ly, .k_row, .k_col => {
                if (sp >= STACK) return null;
                const w: usize = switch (p.ops[k]) {
                    .k_index => i,
                    .k_n => n,
                    .k_local => th.l,
                    .k_group => th.g,
                    .k_lx => th.l % TILE,
                    .k_ly => th.l / TILE,
                    .k_row => th.row,
                    .k_col => th.col,
                    else => unreachable,
                };
                st[sp] = if (int) ib(@truncate(@as(i64, @intCast(w)))) else fb(@floatFromInt(w));
                sp += 1;
            },
            .k_acc => {
                if (sp >= STACK) return null;
                st[sp] = fb(th.acc);
                sp += 1;
            },
            .sh_rd => {
                if (sp < 1) return null;
                const which = arg & ARG_MASK;
                const ixo: ?usize = if (arg & INT_IDX != 0) iIndex(iv(st[sp - 1])) else toIndex(fv(st[sp - 1]));
                if (g_san) sanSlot(th, which, if (arg & INT_IDX != 0) @floatFromInt(iv(st[sp - 1])) else fv(st[sp - 1]));
                st[sp - 1] = fb(if (ixo) |ix| (if (ix < g_kp3.sizes[which]) g_sh[which][ix] else 0.0) else 0.0);
                ops += 1;
            },
            .rd => {
                if (sp < 1) return null;
                const which = arg & ARG_MASK;
                const len: usize = @intFromFloat(lens[which]);
                const ixo: ?usize = if (arg & INT_IDX != 0) iIndex(iv(st[sp - 1])) else toIndex(fv(st[sp - 1]));
                const x: f32 = if (ixo) |ix| (if (ix < len) ins[which][ix] else 0.0) else 0.0;
                st[sp - 1] = if (int) ib(toI32(x)) else fb(x);
                ops += 1;
            },
            .sum_begin => {
                if (sp < 2) return null;
                const slot = arg & ARG_MASK;
                frames[slot] = .{ .v = @trunc(fv(st[sp - 2])), .to = @trunc(fv(st[sp - 1])), .acc = 0 };
                sp -= 2;
                if (!(frames[slot].v < frames[slot].to)) {
                    // an empty range: the sum is 0, skip to after sum_end
                    if (sp >= STACK) return null;
                    st[sp] = 0; // 0.0 and 0 have the same bits
                    sp += 1;
                    next = @as(usize, p.jump[k]) + 1;
                }
            },
            .sum_end => {
                if (sp < 1) return null;
                const slot = arg & ARG_MASK;
                frames[slot].acc = if (int) ib(iv(frames[slot].acc) +% iv(st[sp - 1])) else fb(fv(frames[slot].acc) + fv(st[sp - 1]));
                sp -= 1;
                frames[slot].v += 1;
                ops += 1;
                if (frames[slot].v < frames[slot].to) {
                    next = @as(usize, p.jump[k]) + 1;
                } else {
                    if (sp >= STACK) return null;
                    st[sp] = frames[slot].acc;
                    sp += 1;
                }
            },
            .w_if => {
                if (sp < 1) return null;
                sp -= 1;
                if (fv(st[sp]) == 0) next = p.jump[k];
                ops += 1;
            },
            .w_else => next = p.jump[k],
            .k_inv, .rdv => {
                const which = arg & 0xFF & ARG_MASK & 0x0F;
                const wd: usize = (arg >> 8) & 7;
                var e: ?usize = i;
                if (p.ops[k] == .k_inv and i >= @as(usize, @intFromFloat(lens[which])) / wd) e = null; // bounded, as k_in
                if (p.ops[k] == .rdv) {
                    if (sp < 1) return null;
                    e = if (arg & INT_IDX != 0) iIndex(iv(st[sp - 1])) else toIndex(fv(st[sp - 1]));
                    sp -= 1;
                    const len: usize = @as(usize, @intFromFloat(lens[which])) / wd;
                    if (e) |ex| {
                        if (ex >= len) e = null;
                    }
                    ops += 1;
                }
                if (sp + wd > STACK) return null;
                for (0..wd) |j2| st[sp + j2] = if (e) |ex| fb(ins[which][ex * wd + j2]) else 0;
                sp += wd;
            },
            .neg => {
                if (sp < 1) return null;
                st[sp - 1] = fb(-fv(st[sp - 1]));
                ops += 1;
            },
            .i_neg, .i_abs, .i_sign, .cv_fi, .cv_if => {
                if (sp < 1) return null;
                const x = st[sp - 1];
                st[sp - 1] = switch (p.ops[k]) {
                    .i_neg => ib(0 -% iv(x)),
                    .i_abs => ib(if (iv(x) < 0) 0 -% iv(x) else iv(x)),
                    .i_sign => ib(if (iv(x) > 0) 1 else if (iv(x) < 0) -1 else 0),
                    .cv_fi => ib(toI32(fv(x))),
                    .cv_if => fb(@floatFromInt(iv(x))),
                    else => unreachable,
                };
                ops += 1;
            },
            .i_add, .i_sub, .i_mul, .i_div, .i_mod, .i_min, .i_max, .ic_lt, .ic_le, .ic_gt, .ic_ge, .ic_eq, .ic_ne => {
                if (sp < 2) return null;
                const a2 = iv(st[sp - 2]);
                const b2 = iv(st[sp - 1]);
                st[sp - 2] = switch (p.ops[k]) {
                    .i_add => ib(a2 +% b2),
                    .i_sub => ib(a2 -% b2),
                    .i_mul => ib(a2 *% b2),
                    .i_div => ib(iDiv(a2, b2)),
                    .i_mod => ib(iRem(a2, b2)),
                    .i_min => ib(@min(a2, b2)),
                    .i_max => ib(@max(a2, b2)),
                    .ic_lt => fb(if (a2 < b2) 1.0 else 0.0),
                    .ic_le => fb(if (a2 <= b2) 1.0 else 0.0),
                    .ic_gt => fb(if (a2 > b2) 1.0 else 0.0),
                    .ic_ge => fb(if (a2 >= b2) 1.0 else 0.0),
                    .ic_eq => fb(if (a2 == b2) 1.0 else 0.0),
                    .ic_ne => fb(if (a2 != b2) 1.0 else 0.0),
                    else => unreachable,
                };
                sp -= 1;
                ops += 1;
            },
            .i_clamp => {
                if (sp < 3) return null;
                st[sp - 3] = ib(@min(@max(iv(st[sp - 3]), iv(st[sp - 2])), iv(st[sp - 1])));
                sp -= 2;
                ops += 1;
            },
            .add, .sub, .mul, .div, .mod, .f_min, .f_max, .f_pow, .f_step, .f_atan2, .f_distance, .c_lt, .c_le, .c_gt, .c_ge, .c_eq, .c_ne, .l_and, .l_or => {
                if (sp < 2) return null;
                const a2 = fv(st[sp - 2]);
                const b2 = fv(st[sp - 1]);
                st[sp - 2] = fb(switch (p.ops[k]) {
                    .c_lt => if (a2 < b2) 1.0 else 0.0,
                    .c_le => if (a2 <= b2) 1.0 else 0.0,
                    .c_gt => if (a2 > b2) 1.0 else 0.0,
                    .c_ge => if (a2 >= b2) 1.0 else 0.0,
                    .c_eq => if (a2 == b2) 1.0 else 0.0,
                    .c_ne => if (a2 != b2) 1.0 else 0.0,
                    .l_and => if (a2 != 0 and b2 != 0) 1.0 else 0.0,
                    .l_or => if (a2 != 0 or b2 != 0) 1.0 else 0.0,
                    else => applyF(p.ops[k], a2, b2, 0),
                });
                sp -= 1;
                ops += 1;
            },
            .f_clamp, .f_mix, .f_smoothstep => {
                if (sp < 3) return null;
                st[sp - 3] = fb(applyF(p.ops[k], fv(st[sp - 3]), fv(st[sp - 2]), fv(st[sp - 1])));
                sp -= 2;
                ops += 1;
            },
            // GL0 (vectors): a vecN is N slots in a row
            .splat => {
                const nv: usize = arg;
                if (sp < 1 or sp - 1 + nv > STACK) return null;
                for (1..nv) |j2| st[sp - 1 + j2] = st[sp - 1];
                sp += nv - 1;
            },
            .swz => {
                const nv: usize = (arg & 3) + 2;
                const m: usize = ((arg >> 2) & 3) + 1;
                if (sp < nv or sp - nv + m > STACK) return null;
                var tmp: [4]u32 = undefined;
                for (0..nv) |j2| tmp[j2] = st[sp - nv + j2];
                sp -= nv;
                for (0..m) |q| {
                    st[sp] = tmp[(arg >> @intCast(4 + 2 * q)) & 3];
                    sp += 1;
                }
            },
            .vmap => {
                const opf: Op = @enumFromInt(arg & 0x7F);
                const nv: usize = ((arg >> 7) & 3) + 1;
                const ar: usize = ((arg >> 9) & 3) + 1;
                const mask = (arg >> 11) & 7;
                var need: usize = 0;
                for (0..ar) |q| need += if (mask & (@as(u16, 1) << @intCast(q)) != 0) 1 else nv;
                if (sp < need) return null;
                var base = sp - need;
                var from: [3]usize = undefined; // where each operand starts
                var spread: [3]bool = undefined;
                for (0..ar) |q| {
                    spread[q] = mask & (@as(u16, 1) << @intCast(q)) != 0;
                    from[q] = base;
                    base += if (spread[q]) 1 else nv;
                }
                var vres: [4]f32 = undefined;
                for (0..nv) |j2| {
                    var xs: [3]f32 = .{ 0, 0, 0 };
                    for (0..ar) |q| xs[q] = fv(st[from[q] + (if (spread[q]) 0 else j2)]);
                    vres[j2] = applyF(opf, xs[0], xs[1], xs[2]);
                }
                sp -= need;
                for (0..nv) |j2| st[sp + j2] = fb(vres[j2]);
                sp += nv;
                ops += @floatFromInt(nv);
            },
            .v_dot, .v_dist, .v_refl => {
                const nv: usize = arg;
                if (sp < 2 * nv) return null;
                const a0 = sp - 2 * nv;
                const b0 = sp - nv;
                var acc: f32 = 0;
                for (0..nv) |j2| {
                    const x = fv(st[a0 + j2]);
                    const y = fv(st[b0 + j2]);
                    acc += if (p.ops[k] == .v_dist) (x - y) * (x - y) else x * y;
                }
                if (p.ops[k] == .v_refl) {
                    // reflect(e1, e2) = e1 - 2 * dot(e2, e1) * e2
                    for (0..nv) |j2| st[a0 + j2] = fb(fv(st[a0 + j2]) - 2.0 * acc * fv(st[b0 + j2]));
                    sp = b0;
                } else {
                    st[a0] = fb(if (p.ops[k] == .v_dist) @sqrt(acc) else acc);
                    sp = a0 + 1;
                }
                ops += @floatFromInt(2 * nv);
            },
            .v_len, .v_norm => {
                const nv: usize = arg;
                if (sp < nv) return null;
                const a0 = sp - nv;
                var acc: f32 = 0;
                for (0..nv) |j2| acc += fv(st[a0 + j2]) * fv(st[a0 + j2]);
                const len = @sqrt(acc);
                if (p.ops[k] == .v_norm) {
                    for (0..nv) |j2| st[a0 + j2] = fb(fv(st[a0 + j2]) / len);
                } else {
                    st[a0] = fb(len);
                    sp = a0 + 1;
                }
                ops += @floatFromInt(2 * nv);
            },
            .v_cross => {
                if (sp < 6) return null;
                const a0 = sp - 6;
                const ax = fv(st[a0]);
                const ay = fv(st[a0 + 1]);
                const az = fv(st[a0 + 2]);
                const bx = fv(st[a0 + 3]);
                const by = fv(st[a0 + 4]);
                const bz = fv(st[a0 + 5]);
                st[a0] = fb(ay * bz - az * by);
                st[a0 + 1] = fb(az * bx - ax * bz);
                st[a0 + 2] = fb(ax * by - ay * bx);
                sp = a0 + 3;
                ops += 6;
            },
            else => {
                if (sp < 1) return null;
                st[sp - 1] = fb(applyF(p.ops[k], fv(st[sp - 1]), 0, 0));
                ops += 1;
            },
        }
        k = next;
    }
    if (res) |r| {
        // GL0 (typed buffers): a vecN body leaves its N components
        if (sp != r.len) return null;
        for (r, 0..) |*x, j2| x.* = fv(st[j2]);
        ops_out.* += ops;
        return r[0];
    }
    if (sp != 1) return null;
    ops_out.* += ops;
    return fv(st[0]);
}

/// GL0 (typed buffers): element i's value written at out[W*i ..], W the
/// output's floats per element (1, or a vector's width).
fn runBody(t: *const Thread, ins: [*]const [*]const f32, lens: [*]const f64, scalars: [*]const f32, out: [*]f32, i: usize) bool {
    const w: usize = g_out_w;
    if (w == 1) {
        out[i] = runProgram(&g_prog, t, ins, lens, scalars, &g_eval_flops, null) orelse return false;
        return true;
    }
    _ = runProgram(&g_prog, t, ins, lens, scalars, &g_eval_flops, out[w * i .. w * i + w]) orelse return false;
    return true;
}
fn unwritten(out: [*]f32, i: usize) void {
    for (0..g_out_w) |j| out[g_out_w * i + j] = std.math.nan(f32);
}

/// Evaluate the compiled spec over `n` elements: `ins` points at n_ins arrays,
/// `lens` their lengths (a neighbour read is bounded by its input's own
/// length; the inputs need not be n long), `scalars` the declared scalars in
/// order, `out` receives n f32. An element the guard refuses is left NaN --
/// unwritten, as the kernel leaves it. Returns 0, or -1 (nothing compiled /
/// wrong counts / a stack fault). The operations executed, loops included,
/// are read with stz_gpu_spec_eval_flops.
pub fn stz_gpu_spec_eval(ins: [*]const [*]const f32, n_ins: i32, lens: [*]const f64, scalars: [*]const f32, n_scalars: i32, nf: f64, out: [*]f32) callconv(.c) i32 {
    return stz_gpu_spec_eval_masked(ins, n_ins, lens, scalars, n_scalars, nf, out, null);
}

/// The same, with a WRITTEN mask: mask[i] is 1 where the element was written
/// and 0 where the guard refused it. A checker needs the two told apart from
/// a written NaN: an unwritten element must still be the fill in the
/// candidate, where a NaN the body produced agrees with nothing (GK6).
pub fn stz_gpu_spec_eval_masked(ins: [*]const [*]const f32, n_ins: i32, lens: [*]const f64, scalars: [*]const f32, n_scalars: i32, nf: f64, out: [*]f32, mask: ?[*]u8) callconv(.c) i32 {
    if (!g_prog.ready) return -1;
    if (n_ins < 0 or @as(usize, @intCast(n_ins)) != g_prog.n_ins) return -1;
    if (n_scalars < 0 or @as(usize, @intCast(n_scalars)) < g_prog.n_scalars) return -1;
    const n: usize = @intFromFloat(nf);
    g_eval_flops = 0;
    if (g_kp3.on) return evalGroups(ins, lens, scalars, n, out, mask);
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const t = Thread{ .i = i, .n = n };
        if (g_guard_kind == .custom) {
            const g = runProgram(&g_guard, &t, ins, lens, scalars, &g_eval_flops, null) orelse return -1;
            if (g == 0) {
                unwritten(out, i);
                if (mask) |m| m[i] = 0;
                continue;
            }
        }
        if (!runBody(&t, ins, lens, scalars, out, i)) return -1;
        if (mask) |m| m[i] = 1;
    }
    return 0;
}

/// The thread at local index l of group g: its element, and in a width
/// kernel its row and column -- the mapping the kernel's prologue computes.
fn threadAt(g: usize, l: usize, n: usize, width: usize) Thread {
    if (width == 0) return .{ .i = g * GROUP + l, .n = n, .l = l, .g = g };
    const tpr = width / TILE;
    const row = (g / tpr) * TILE + l / TILE;
    const col = (g % tpr) * TILE + l % TILE;
    return .{ .i = row * width + col, .n = n, .l = l, .g = g, .row = row, .col = col };
}

fn runItem(k: usize, g: usize, n: usize, width: usize, tile: f32, ins: [*]const [*]const f32, lens: [*]const f64, scalars: [*]const f32) bool {
    switch (g_kp3.kinds[k]) {
        .stage => {
            // every thread computes its slot and value from the state BEFORE the
            // stage, then all write: the barrier after it is what the kernel waits on
            g_san_line = g_kp3.lines[k];
            g_san_where = .stage;
            for (0..GROUP) |l| {
                var t = threadAt(g, l, n, width);
                t.acc = g_acc[l];
                t.tile = tile;
                g_tmp_ix[l] = runProgram(&g_item_idx[k], &t, ins, lens, scalars, &g_eval_flops, null) orelse return false;
                g_tmp_v[l] = runProgram(&g_item_val[k], &t, ins, lens, scalars, &g_eval_flops, null) orelse return false;
            }
            const s = g_kp3.shared_of[k];
            if (g_san) @memset(g_san_writer[0..g_kp3.sizes[s]], NOBODY);
            for (0..GROUP) |l| {
                if (toIndex(g_tmp_ix[l])) |ix| {
                    if (ix < g_kp3.sizes[s]) {
                        g_sh[s][ix] = g_tmp_v[l];
                        if (g_san) {
                            const prev = g_san_writer[ix];
                            if (prev != NOBODY) sanNote(SAN_RACE, .{ .line = g_kp3.lines[k], .where = .stage, .group = g, .a = prev, .b = l, .slot = @intCast(ix), .arr = s, .same = g_tmp_v[prev] == g_tmp_v[l] });
                            g_san_writer[ix] = @intCast(l);
                            g_san_written[s][ix] = true;
                        }
                        continue;
                    }
                }
                if (g_san) {
                    const raw = g_tmp_ix[l];
                    sanNote(SAN_DROPPED, .{ .line = g_kp3.lines[k], .where = .stage, .group = g, .a = l, .slot = if (raw == raw and @abs(raw) < 1e15) @intFromFloat(@trunc(raw)) else -1, .arr = s });
                }
            }
        },
        .reduce => {
            const s = g_kp3.shared_of[k];
            if (g_san and g_kp3.ops[k] != .sum) {
                // a max or a min over a slot no stage wrote counts its zero
                for (0..g_kp3.sizes[s]) |ix| {
                    if (!g_san_written[s][ix]) {
                        sanNote(SAN_UNWRITTEN, .{ .line = g_kp3.lines[k], .where = .reduce, .group = g, .a = if (ix < GROUP) ix else 0, .slot = @intCast(ix), .arr = s });
                    }
                }
            }
            var half = g_kp3.sizes[s] / 2;
            while (half > 0) : (half /= 2) {
                for (0..half) |l| {
                    const a = g_sh[s][l];
                    const b = g_sh[s][l + half];
                    g_sh[s][l] = switch (g_kp3.ops[k]) {
                        .sum => a + b,
                        .max => @max(a, b),
                        .min => @min(a, b),
                    };
                    g_eval_flops += 1;
                }
            }
        },
        .accumulate => {
            g_san_line = g_kp3.lines[k];
            g_san_where = .accumulate;
            for (0..GROUP) |l| {
                var t = threadAt(g, l, n, width);
                t.acc = g_acc[l];
                t.tile = tile;
                g_tmp_v[l] = runProgram(&g_item_val[k], &t, ins, lens, scalars, &g_eval_flops, null) orelse return false;
            }
            for (0..GROUP) |l| g_acc[l] = g_tmp_v[l];
        },
    }
    return true;
}

/// KP3: evaluate a spec that uses the group, one group at a time.
fn evalGroups(ins: [*]const [*]const f32, lens: [*]const f64, scalars: [*]const f32, n: usize, out: [*]f32, mask: ?[*]u8) i32 {
    var width: usize = g_kp3.width_lit;
    if (g_kp3.width_scalar) |si| {
        const v = scalars[si];
        if (!(v > 0 and v < 1048576.0) or @trunc(v) != v) {
            _ = fail("the width scalar must be a whole number above 0", .{});
            return -1;
        }
        width = @intFromFloat(v);
    }
    if (width != 0) {
        if (width % TILE != 0) {
            _ = fail("width {d} is not a multiple of {d}", .{ width, TILE });
            return -1;
        }
        if (n % (TILE * width) != 0) {
            _ = fail("{d} elements are not whole 16-row tiles of width {d}", .{ n, width });
            return -1;
        }
    }
    const groups = (n + GROUP - 1) / GROUP;
    for (0..groups) |g| {
        for (0..g_kp3.n_shared) |s| @memset(g_sh[s][0..g_kp3.sizes[s]], 0); // WGSL zero-initialises workgroup memory
        if (g_san) {
            for (0..g_kp3.n_shared) |s| @memset(g_san_written[s][0..g_kp3.sizes[s]], false);
        }
        @memset(&g_acc, 0);
        for (0..g_kp3.loop_from) |k| {
            if (!runItem(k, g, n, width, 0, ins, lens, scalars)) return -1;
        }
        if (g_kp3.has_tiles) {
            const t0 = Thread{ .i = 0, .n = n };
            const cf = runProgram(&g_count, &t0, ins, lens, scalars, &g_eval_flops, null) orelse return -1;
            const cnt: usize = if (toIndex(cf)) |c| c else 0;
            for (0..cnt) |tv| {
                for (g_kp3.loop_from..g_kp3.n_items) |k| {
                    if (!runItem(k, g, n, width, @floatFromInt(tv), ins, lens, scalars)) return -1;
                }
            }
        }
        for (0..GROUP) |l| {
            var t = threadAt(g, l, n, width);
            if (t.i >= n) continue;
            t.acc = g_acc[l];
            if (g_guard_kind == .custom) {
                g_san_line = g_kp3.guard_line;
                g_san_where = .guard;
                const gv = runProgram(&g_guard, &t, ins, lens, scalars, &g_eval_flops, null) orelse return -1;
                if (gv == 0) {
                    unwritten(out, t.i);
                    if (mask) |m| m[t.i] = 0;
                    continue;
                }
            }
            g_san_line = g_kp3.body_line;
            g_san_where = .body;
            if (!runBody(&t, ins, lens, scalars, out, t.i)) return -1;
            if (mask) |m| m[t.i] = 1;
        }
    }
    return 0;
}

test "GK6: the shared parser leaves the transpiler's WGSL byte-identical (the edge proof's text)" {
    const spec = "in x\nscalar k\nscalar b\nout y\nbody { @y = clamp(sqrt(abs(@x)) * k - b, 0.0, 10.5) % 3 + round(@x / 2) }";
    const expected =
        \\struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
        \\@group(0) @binding(0) var<uniform> tile : StzTile;
        \\struct P { n : u32, pad : u32, s_k : f32, s_b : f32 }
        \\@group(0) @binding(1) var<uniform> p : P;
        \\@group(0) @binding(2) var<storage, read> v_x : array<f32>;
        \\@group(0) @binding(3) var<storage, read_write> v_y : array<f32>;
        \\@compute @workgroup_size(256)
        \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
        \\  let i = gid.x + tile.xoff * 256u;
        \\  if (i < p.n) { v_y[i] = clamp(sqrt(abs(v_x[i])) * p.s_k - p.s_b, 0.0f, 10.5f) % 3f + round(v_x[i] / 2f); }
        \\}
        \\
    ;
    var buf: [4096]u8 = undefined;
    const n = stz_gpu_wgsl_elementwise(spec.ptr, @floatFromInt(spec.len), &buf, buf.len);
    try std.testing.expect(n > 0);
    try std.testing.expectEqualStrings(expected, buf[0..@intCast(n)]);
}

test "GK6: the interpreter means what WGSL means" {
    const spec = "in a\nin b\nscalar k\nout c\nbody { @c = @a % 3 + round(@b) * k - -1 }";
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_compile(spec.ptr, @floatFromInt(spec.len)));
    try std.testing.expectEqual(@as(f64, 6), stz_gpu_spec_flops()); // % round * + neg -
    const a = [_]f32{ 7, -7, 2.5, 0 };
    const b = [_]f32{ 2.5, 3.5, -2.5, 0.49 };
    const ins = [_][*]const f32{ &a, &b };
    const lens = [_]f64{ 4, 4 };
    const k = [_]f32{10};
    var out: [4]f32 = undefined;
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_eval(&ins, 2, &lens, &k, 1, 4, &out));
    // 7 % 3 = 1, round(2.5) = 2 (to even), 1 + 20 + 1 = 22
    try std.testing.expectApproxEqAbs(@as(f32, 22), out[0], 1e-6);
    // -7 % 3 = -1 (truncated), round(3.5) = 4: -1 + 40 + 1 = 40
    try std.testing.expectApproxEqAbs(@as(f32, 40), out[1], 1e-6);
    // 2.5 % 3 = 2.5, round(-2.5) = -2: 2.5 - 20 + 1 = -16.5
    try std.testing.expectApproxEqAbs(@as(f32, -16.5), out[2], 1e-6);
    // 0 % 3 = 0, round(0.49) = 0: 1
    try std.testing.expectApproxEqAbs(@as(f32, 1), out[3], 1e-6);
    // the counts are checked
    try std.testing.expectEqual(@as(i32, -1), stz_gpu_spec_eval(&ins, 1, &lens, &k, 1, 4, &out));
}

test "KP0: the four admissions, in the WGSL and in the interpreter, and p is always bound" {
    var buf: [8192]u8 = undefined;
    var out: [8]f32 = undefined;
    const a = [_]f32{ 1, 2, 3, 4, 5, 6, 7, 8 };
    const ins = [_][*]const f32{&a};
    const lens = [_]f64{8};
    const none = [_]f32{};

    // 1. the index: @i is f32(i) in WGSL and the element number in the interpreter
    const s1 = "in a\nout c\nbody { @c = @a + @i }";
    var n = stz_gpu_wgsl_elementwise(s1.ptr, @floatFromInt(s1.len), &buf, buf.len);
    try std.testing.expect(n > 0);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "v_a[i] + f32(i)") != null);
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_compile(s1.ptr, @floatFromInt(s1.len)));
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_eval(&ins, 1, &lens, &none, 0, 8, &out));
    try std.testing.expectEqual(@as(f32, 1 + 0), out[0]);
    try std.testing.expectEqual(@as(f32, 8 + 7), out[7]);

    // 2. the learner's guard: refused elements stay NaN; `_ = p.n;` keeps p bound
    const s2 = "in a\nout c\nguard { @i < n - 2 }\nbody { @c = @a * 2 }";
    n = stz_gpu_wgsl_elementwise(s2.ptr, @floatFromInt(s2.len), &buf, buf.len);
    try std.testing.expect(n > 0);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "_ = p.n;") != null);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "if (f32(i) < f32(p.n) - 2f) {") != null);
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_compile(s2.ptr, @floatFromInt(s2.len)));
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_eval(&ins, 1, &lens, &none, 0, 8, &out));
    try std.testing.expectEqual(@as(f32, 12), out[5]);
    try std.testing.expect(out[6] != out[6]); // NaN: the guard refused it
    try std.testing.expect(out[7] != out[7]);
    // guard none: no if, and still `_ = p.n;`
    const s2b = "in a\nout c\nguard none\nbody { @c = @a }";
    n = stz_gpu_wgsl_elementwise(s2b.ptr, @floatFromInt(s2b.len), &buf, buf.len);
    try std.testing.expect(n > 0);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "_ = p.n;") != null);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "if (") == null);

    // 3. the stencil: a neighbour read, 0.0 outside the input's own range on both sides
    const s3 = "in a\nout c\nbody { @c = @a[@i - 1] + @a + @a[@i + 1] }";
    n = stz_gpu_wgsl_elementwise(s3.ptr, @floatFromInt(s3.len), &buf, buf.len);
    try std.testing.expect(n > 0);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "fn rd_a(k : i32) -> f32 {") != null);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "rd_a(i32(f32(i) - 1f)) + v_a[i] + rd_a(i32(f32(i) + 1f))") != null);
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_compile(s3.ptr, @floatFromInt(s3.len)));
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_eval(&ins, 1, &lens, &none, 0, 8, &out));
    try std.testing.expectEqual(@as(f32, 0 + 1 + 2), out[0]);
    try std.testing.expectEqual(@as(f32, 2 + 3 + 4), out[2]);
    try std.testing.expectEqual(@as(f32, 7 + 8 + 0), out[7]);

    // 4. the sum: a first pass of partials (n = 2 outputs over 8 inputs), then the fold
    const s4 = "in a\nout c\nbody { @c = sum(k, 0, 4, @a[@i * 4 + k]) }";
    n = stz_gpu_wgsl_elementwise(s4.ptr, @floatFromInt(s4.len), &buf, buf.len);
    try std.testing.expect(n > 0);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "var acc0 : f32 = 0.0;") != null);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "for (var k_k : i32 = i32(0f); k_k < i32(4f); k_k = k_k + 1) { acc0 = acc0 + (rd_a(i32(f32(i) * 4f + f32(k_k)))); }") != null);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "v_c[i] = acc0;") != null);
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_compile(s4.ptr, @floatFromInt(s4.len)));
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_eval(&ins, 1, &lens, &none, 0, 2, &out));
    try std.testing.expectEqual(@as(f32, 1 + 2 + 3 + 4), out[0]);
    try std.testing.expectEqual(@as(f32, 5 + 6 + 7 + 8), out[1]);
    try std.testing.expect(stz_gpu_spec_eval_flops() > 8); // the loop's work is counted
    const s5 = "in c\nscalar m\nout d\nbody { @d = sum(k, 0, m, @c[k]) }";
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_compile(s5.ptr, @floatFromInt(s5.len)));
    const parts = [_]f32{ 10, 26 };
    const pins = [_][*]const f32{&parts};
    const plens = [_]f64{2};
    const m = [_]f32{2};
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_eval(&pins, 1, &plens, &m, 1, 1, &out));
    try std.testing.expectEqual(@as(f32, 36), out[0]);

    // the default form is unchanged: no `_ = p.n;`, the one-line if
    const s0 = "in a\nout c\nbody { @c = @a * 2 }";
    n = stz_gpu_wgsl_elementwise(s0.ptr, @floatFromInt(s0.len), &buf, buf.len);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "  if (i < p.n) { v_c[i] = v_a[i] * 2f; }\n}\n") != null);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "_ = p.n;") == null);
}

test "KP1: an input the body never reads stays bound, and a read one is emitted as before" {
    var buf: [8192]u8 = undefined;
    const cheat = "in a\nout c\nbody { @c = @i * 2 }";
    var n = stz_gpu_wgsl_elementwise(cheat.ptr, @floatFromInt(cheat.len), &buf, buf.len);
    try std.testing.expect(n > 0);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "  _ = arrayLength(&v_a);\n") != null);
    const reads = "in a\nout c\nbody { @c = @a * 2 }";
    n = stz_gpu_wgsl_elementwise(reads.ptr, @floatFromInt(reads.len), &buf, buf.len);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "arrayLength") == null);
}

test "KP0: the refusals name the offender, and the two readers agree on them" {
    const specs = [_][]const u8{
        "in i\nout c\nbody { @c = @i }", // i reserved
        "in a\nscalar n\nout c\nbody { @c = @a }", // n reserved
        "in a\nout c\nbody { @c = @a < 2 }", // a comparison in a body
        "in a\nout c\nbody { @c = sum(k, 0, 4, sum(j, 0, 2, @a[k + j])) }", // nested sums
        "in a\nout c\nbody { @c = sum(k, 0, @a[k]) }", // 3 arguments
        "in a\nout c\nbody { @c = sum(a, 0, 4, @a[k]) }", // the var is a name already
        "in a\nout c\nbody { @c = @a[ }", // missing ]
        "in a\nout c\nguard { @i = 2 }\nbody { @c = @a }", // = in a guard
        "in a\nout c\nguard { @i < 2 }\nguard none\nbody { @c = @a }", // two guards
        "in a\nout c\nbody { @c = @a and 1 }", // and in a body
        "in a\nout c\nguard { @i > 0 and @i < n - 1 }\nbody { @c = (@a[@i - 1] + @a + @a[@i + 1]) / 3 }", // admitted
    };
    var buf: [8192]u8 = undefined;
    for (specs) |s| {
        const t = stz_gpu_wgsl_elementwise(s.ptr, @floatFromInt(s.len), &buf, buf.len);
        const c = stz_gpu_spec_compile(s.ptr, @floatFromInt(s.len));
        try std.testing.expectEqual(t >= 0, c == 0);
    }
    const last = specs[specs.len - 1];
    try std.testing.expect(stz_gpu_wgsl_elementwise(last.ptr, @floatFromInt(last.len), &buf, buf.len) > 0);
    const nested = specs[3];
    try std.testing.expectEqual(@as(i32, -1), stz_gpu_spec_compile(nested.ptr, @floatFromInt(nested.len)));
    var e: [256]u8 = undefined;
    const el = stz_gpu_wgsl_error(&e, e.len);
    try std.testing.expect(std.mem.indexOf(u8, e[0..@intCast(el)], "sum inside a sum") != null);
}

test "GK6: what the transpiler refuses the interpreter refuses, and the same spec compiles on both" {
    const specs = [_][]const u8{
        "in a\nout c\nbody { @c = @a * 2 }",
        "in a\nin b\nscalar s\nout c\nbody { @c = mix(@a, @b, s) + smoothstep(0.0, 1.0, @a) }",
        "in a\nout c\nbody { @c = @a * 2; }", // a semicolon
        "in a\nout c\nbody { @c = @z * 2 }", // undeclared vector
        "in a\nout c\nbody { @c = foo(@a) }", // unknown function
        "in a\nout c\nbody { @c = @c + 1 }", // the output read
        "in a\nout c\nbody { @c = sqrt @a }", // function not called
        "in a\nout a\nbody { @a = 1 }", // input is output
        "in a\nout c\nbody { @c = \"x\" }", // a string
    };
    var buf: [8192]u8 = undefined;
    for (specs) |s| {
        const t = stz_gpu_wgsl_elementwise(s.ptr, @floatFromInt(s.len), &buf, buf.len);
        const c = stz_gpu_spec_compile(s.ptr, @floatFromInt(s.len));
        try std.testing.expectEqual(t >= 0, c == 0);
    }
    // a vector-only name: until GL0 the transpiler passed it to WGSL to fail
    // there; the typed rewriter refuses it as the interpreter does
    const vec = "in a\nin b\nout c\nbody { @c = dot(@a, @b) }";
    try std.testing.expectEqual(@as(i32, -1), stz_gpu_wgsl_elementwise(vec.ptr, @floatFromInt(vec.len), &buf, buf.len));
    try std.testing.expectEqual(@as(i32, -1), stz_gpu_spec_compile(vec.ptr, @floatFromInt(vec.len)));
    // a wrong arity is a refusal naming the function
    const ar = "in a\nout c\nbody { @c = clamp(@a, 1.0) }";
    try std.testing.expectEqual(@as(i32, -1), stz_gpu_spec_compile(ar.ptr, @floatFromInt(ar.len)));
    var e: [256]u8 = undefined;
    const el = stz_gpu_wgsl_error(&e, e.len);
    try std.testing.expect(std.mem.indexOf(u8, e[0..@intCast(el)], "clamp") != null);
}

// ===========================================================================
// THE FRAGMENT STAGE (GR4b of SOFTANZA_GRAPHICS_PLAN.md)
// ===========================================================================
//
// The same LITERAL-body discipline as the elementwise kernel, aimed at a
// surface instead of an array. A material declares the colours and scalars
// it takes, and one expression for what a fragment should be:
//
//     color base
//     scalar glow
//     body { @out = base * (1.0 + glow * @normal.y) }
//
// A declared colour or scalar is a BARE NAME. An @name is a fragment
// BUILTIN -- what the rasterizer knows at this pixel and the material did
// not have to compute:
//
//     @normal   vec3, interpolated and re-normalized
//     @position vec3, the fragment in world space
//     @uv       vec2, the mesh's texture coordinates
//     @lambert  f32, the diffuse term against the scene's light
//     @color    vec4, the instance's own colour
//
// Swizzles are allowed on builtins (@normal.y, @color.rgb) because that is
// how a surface is actually described. The output is @out, and it is a
// vec4 -- the emitted shader is COMPLETE (vertex stage included) and binds
// exactly the 3D contract the render layer already speaks, so a material
// is a drop-in pipeline rather than a fragment nobody can run.

const BUILTINS = [_][]const u8{ "normal", "position", "uv", "lambert", "color" };
pub const MAX_COLORS = 6;

// A material may declare TEXTURES. Each one costs two group(0) bindings (the
// texture and its sampler), which is why the count is small and fixed: the
// bindings are laid out at compile time and the draw path has to match them
// exactly, so an unbounded list would be a bind-group budget nobody owns.
pub const MAX_TEXTURES = 4;

fn isSwizzle(s: []const u8) bool {
    if (s.len == 0 or s.len > 4) return false;
    for (s) |ch| {
        const ok = ch == 'x' or ch == 'y' or ch == 'z' or ch == 'w' or
            ch == 'r' or ch == 'g' or ch == 'b' or ch == 'a';
        if (!ok) return false;
    }
    return true;
}

/// Transpile a material spec into a COMPLETE WGSL render shader.
/// Same contract as the elementwise entry: length written, or -1 with the
/// reason in stz_gpu_wgsl_error.
pub const MAX_LOCALS = 8;

/// Compile ONE material expression to WGSL.
///
/// Lifted out of the body parser so several statements can share it, and
/// that sharing IS the feature: a material used to be exactly one
/// assignment, so every intermediate value had to be spelled out again
/// wherever it was used. The language could describe a surface but not
/// BUILD one.
fn compileExpr(
    rhs: []const u8,
    colors: []const Name,
    scalars: []const Name,
    locals: []const Name,
    textures: []const Name,
    expr: *Cursor,
) bool {
    var i: usize = 0;
    while (i < rhs.len) {
        const ch = rhs[i];
        if (ch == '@') {
            var j = i + 1;
            while (j < rhs.len and (std.ascii.isAlphanumeric(rhs[j]) or rhs[j] == '_')) : (j += 1) {}
            var nm: Name = .{};
            if (j == i + 1 or !lowerInto(&nm, rhs[i + 1 .. j]))
                { _ = fail("bad @name at '{s}'", .{rhs[i..@min(i + 8, rhs.len)]}); return false; }
            if (std.mem.eql(u8, nm.slice(), "out"))
                { _ = fail("'@out' cannot be read, only assigned", .{}); return false; }
            var known = false;
            for (BUILTINS) |bi| {
                if (std.mem.eql(u8, bi, nm.slice())) {
                    known = true;
                    break;
                }
            }
            if (!known)
                { _ = fail("'@{s}' is not a fragment builtin (@normal @position @uv @lambert @color)", .{nm.slice()}); return false; }
            expr.put("f_");
            expr.put(nm.slice());
            i = j;
            // an optional swizzle rides along: @normal.y
            if (i < rhs.len and rhs[i] == '.') {
                var k = i + 1;
                while (k < rhs.len and std.ascii.isAlphabetic(rhs[k])) : (k += 1) {}
                const sw = rhs[i + 1 .. k];
                if (!isSwizzle(sw))
                    { _ = fail("'{s}' is not a swizzle (use x y z w or r g b a)", .{sw}); return false; }
                expr.putc('.');
                expr.put(sw);
                i = k;
            }
        } else if (std.ascii.isAlphabetic(ch) or ch == '_') {
            var j = i;
            while (j < rhs.len and (std.ascii.isAlphanumeric(rhs[j]) or rhs[j] == '_')) : (j += 1) {}
            var nm: Name = .{};
            if (!lowerInto(&nm, rhs[i..j]))
                { _ = fail("name too long at '{s}'", .{rhs[i..@min(i + 8, rhs.len)]}); return false; }
            // sample(NAME, uv) -- the ONE verb a texture answers.
            //
            // It is handled here rather than in the whitelist because its
            // first argument is not an expression: it names a declared
            // texture, and that name expands into TWO WGSL arguments (the
            // texture and its sampler). A material author never writes a
            // sampler, because a sampler is not a surface property.
            if (std.mem.eql(u8, nm.slice(), "sample")) {
                var k = j;
                while (k < rhs.len and (rhs[k] == ' ' or rhs[k] == '\t')) : (k += 1) {}
                if (k >= rhs.len or rhs[k] != '(')
                    { _ = fail("sample needs '(': sample(name, @uv)", .{}); return false; }
                k += 1;
                while (k < rhs.len and (rhs[k] == ' ' or rhs[k] == '\t')) : (k += 1) {}
                var e = k;
                while (e < rhs.len and (std.ascii.isAlphanumeric(rhs[e]) or rhs[e] == '_')) : (e += 1) {}
                var tnm: Name = .{};
                if (e == k or !lowerInto(&tnm, rhs[k..e]))
                    { _ = fail("sample's first argument must NAME a declared texture", .{}); return false; }
                if (nameIn(textures, textures.len, tnm.slice()) == null)
                    { _ = fail("'{s}' is not a declared texture (say 'texture {s}')", .{ tnm.slice(), tnm.slice() }); return false; }
                var c2 = e;
                while (c2 < rhs.len and (rhs[c2] == ' ' or rhs[c2] == '\t')) : (c2 += 1) {}
                if (c2 >= rhs.len or rhs[c2] != ',')
                    { _ = fail("sample takes a texture AND a coordinate: sample({s}, @uv)", .{tnm.slice()}); return false; }
                // NOT wrapped in a linearise: the closing paren belongs to
                // the author's own sample(...) call, so wrapping unbalances
                // it. Texture colour space is a FORMAT decision (an sRGB
                // texture view lets the sampler do it) and is its own
                // measurement, not this one.
                expr.put("textureSample(t_");
                expr.put(tnm.slice());
                expr.put(", sm_");
                expr.put(tnm.slice());
                expr.putc(',');
                i = c2 + 1; // the rest of the call compiles as ordinary text
                continue;
            }
            if (nameIn(textures, textures.len, nm.slice()) != null) {
                // A texture is not a value. Saying so beats letting it fall
                // through to "unknown name", which would send the author
                // looking for a typo.
                _ = fail("'{s}' is a texture -- read it with sample({s}, @uv)", .{ nm.slice(), nm.slice() });
                return false;
            }
            // A swizzle rides a VECTOR name as well as a builtin. It has to:
            // sample() answers a vec4, so `let k = sample(mask, @uv)`
            // followed by `k.r` is the ordinary way to use a mask, and
            // without this the only readable value would be the whole
            // colour. Colours and lets carry it; a SCALAR does not, and
            // saying so beats letting WGSL reject the emitted shader
            // somewhere the author never looks.
            var swizzlable = false;
            if (nameIn(colors, colors.len, nm.slice()) != null) {
                // lc_, not m.c_ -- the body works on LINEAR colour. See
                // the prologue: shading arithmetic on sRGB-ENCODED values
                // is the classic gamma bug, measured here as tint*0.5
                // rendering 64 where correct is 92.
                expr.put("lc_");
                expr.put(nm.slice());
                swizzlable = true;
            } else if (nameIn(scalars, scalars.len, nm.slice()) != null) {
                expr.put("m.s_");
                expr.put(nm.slice());
                if (j < rhs.len and rhs[j] == '.' and j + 1 < rhs.len and std.ascii.isAlphabetic(rhs[j + 1]))
                    { _ = fail("'{s}' is a scalar -- it has no components to swizzle", .{nm.slice()}); return false; }
            } else if (nameIn(locals, locals.len, nm.slice()) != null) {
                expr.put("v_");
                expr.put(nm.slice());
                swizzlable = true;
            } else {
                // vecN is spelled vecN<f32> in WGSL. The language keeps
                // the friendly name; the transpiler adds the type. The
                // bare name compiled to invalid WGSL, and the broken
                // pipeline then PANICKED at submit instead of refusing.
                if (std.mem.eql(u8, nm.slice(), "vec2") or
                    std.mem.eql(u8, nm.slice(), "vec3") or
                    std.mem.eql(u8, nm.slice(), "vec4"))
                {
                    expr.put(nm.slice());
                    expr.put("<f32>");
                    i = j;
                    continue;
                }
                var is_func = false;
                var fname: []const u8 = nm.slice();
                for (FUNC_WHITELIST) |f| {
                    if (std.ascii.eqlIgnoreCase(f, nm.slice())) {
                        is_func = true;
                        fname = f;
                        break;
                    }
                }
                if (!is_func)
                    { _ = fail("unknown name '{s}' (not a declared colour or scalar, not a whitelisted function)", .{nm.slice()}); return false; }
                var k = j;
                while (k < rhs.len and (rhs[k] == ' ' or rhs[k] == '\t')) : (k += 1) {}
                if (k >= rhs.len or rhs[k] != '(')
                {
                    _ = fail("function '{s}' needs '('", .{nm.slice()});
                    return false;
                }
                expr.put(fname);
            }
            i = j;
            if (swizzlable and i < rhs.len and rhs[i] == '.') {
                var k = i + 1;
                while (k < rhs.len and std.ascii.isAlphabetic(rhs[k])) : (k += 1) {}
                const sw = rhs[i + 1 .. k];
                if (!isSwizzle(sw))
                    { _ = fail("'{s}' is not a swizzle (use x y z w or r g b a)", .{sw}); return false; }
                expr.putc('.');
                expr.put(sw);
                i = k;
            }
        } else if (std.ascii.isDigit(ch) or ch == '.') {
            var j = i;
            while (j < rhs.len and (std.ascii.isDigit(rhs[j]) or rhs[j] == '.')) : (j += 1) {}
            expr.put(rhs[i..j]);
            i = j;
        } else if (ch == '+' or ch == '-' or ch == '*' or ch == '/' or ch == '%' or
            ch == '(' or ch == ')' or ch == ',' or ch == ' ' or ch == '\t')
        {
            expr.putc(ch);
            i += 1;
        } else {
            { _ = fail("character '{c}' is not part of the material language", .{ch}); return false; }
        }
    }
    return true;
}

pub fn stz_gpu_wgsl_fragment(spec: [*]const u8, spec_len: f64, out: [*]u8, cap: f64) callconv(.c) i32 {
    const text = spec[0..@intFromFloat(spec_len)];
    err_len = 0;

    var colors: [MAX_COLORS]Name = undefined;
    var n_colors: usize = 0;
    var scalars: [MAX_SCALARS]Name = undefined;
    var n_scalars: usize = 0;
    var textures: [MAX_TEXTURES]Name = undefined;
    var n_textures: usize = 0;
    var body: []const u8 = "";

    var lines = std.mem.splitScalar(u8, text, '\n');
    while (lines.next()) |raw| {
        const line = std.mem.trim(u8, raw, " \t\r");
        if (line.len == 0) continue;
        if (std.mem.startsWith(u8, line, "color ")) {
            const nm = std.mem.trim(u8, line[6..], " \t");
            var lowered: Name = .{};
            if (!lowerInto(&lowered, nm) or !validIdent(lowered.slice()))
                return fail("bad colour name: '{s}'", .{nm});
            if (n_colors == MAX_COLORS)
                return fail("too many colours (max {d})", .{MAX_COLORS});
            colors[n_colors] = lowered;
            n_colors += 1;
        } else if (std.mem.startsWith(u8, line, "scalar ")) {
            const nm = std.mem.trim(u8, line[7..], " \t");
            var lowered: Name = .{};
            if (!lowerInto(&lowered, nm) or !validIdent(lowered.slice()))
                return fail("bad scalar name: '{s}'", .{nm});
            if (n_scalars == MAX_SCALARS)
                return fail("too many scalars (max {d})", .{MAX_SCALARS});
            scalars[n_scalars] = lowered;
            n_scalars += 1;
        } else if (std.mem.startsWith(u8, line, "texture ")) {
            const nm = std.mem.trim(u8, line[8..], " \t");
            var lowered: Name = .{};
            if (!lowerInto(&lowered, nm) or !validIdent(lowered.slice()))
                return fail("bad texture name: '{s}'", .{nm});
            if (n_textures == MAX_TEXTURES)
                return fail("too many textures (max {d})", .{MAX_TEXTURES});
            if (nameIn(colors[0..], n_colors, lowered.slice()) != null or
                nameIn(scalars[0..], n_scalars, lowered.slice()) != null or
                nameIn(textures[0..], n_textures, lowered.slice()) != null)
                return fail("'{s}' is already a name in this material", .{lowered.slice()});
            textures[n_textures] = lowered;
            n_textures += 1;
        } else if (std.mem.startsWith(u8, line, "body ")) {
            body = std.mem.trim(u8, line[5..], " \t");
        } else {
            return fail("unknown spec line: '{s}'", .{line});
        }
    }
    if (body.len == 0) return fail("no body (ForEachFragment missing)", .{});

    var b = body;
    if (b.len >= 2 and b[0] == '{' and b[b.len - 1] == '}')
        b = std.mem.trim(u8, b[1 .. b.len - 1], " \t");
    if (b.len == 0) return fail("empty body", .{});

    // MULTI-STATEMENT BODIES. Statements are separated by ';' -- not by
    // newlines, because Ring has no reliable multi-line string literal and
    // a one-line W-string has to be able to carry them:
    //
    //   let d = @normal.y; let band = fract(d * rings); @out = mix(a, b, band)
    //
    // Each let becomes a WGSL let, visible to every statement AFTER it and
    // to none before -- so a name cannot be used before it exists, and the
    // transpiler says so rather than emitting a shader that fails to
    // compile somewhere the caller never sees.
    var locals: [MAX_LOCALS]Name = undefined;
    var n_locals: usize = 0;
    var lets_buf: [8192]u8 = undefined;
    var lets = Cursor{ .buf = &lets_buf };
    var expr_buf: [4096]u8 = undefined;
    var expr = Cursor{ .buf = &expr_buf };
    var saw_out = false;

    var stmts = std.mem.splitScalar(u8, b, ';');
    while (stmts.next()) |raw_st| {
        const st = std.mem.trim(u8, raw_st, " \t\r\n");
        if (st.len == 0) continue;
        if (saw_out) return fail("'@out' must be the LAST statement", .{});

        if (std.mem.startsWith(u8, st, "let ")) {
            const rest = std.mem.trim(u8, st[4..], " \t");
            const eq2 = std.mem.indexOfScalar(u8, rest, '=') orelse
                return fail("a let needs '=': 'let name = expression'", .{});
            const lname = std.mem.trim(u8, rest[0..eq2], " \t");
            var lnm: Name = .{};
            if (!lowerInto(&lnm, lname) or !validIdent(lnm.slice()))
                return fail("bad let name: '{s}'", .{lname});
            if (n_locals == MAX_LOCALS)
                return fail("too many lets (max {d})", .{MAX_LOCALS});
            if (nameIn(colors[0..], n_colors, lnm.slice()) != null or
                nameIn(scalars[0..], n_scalars, lnm.slice()) != null or
                nameIn(textures[0..], n_textures, lnm.slice()) != null or
                nameIn(locals[0..], n_locals, lnm.slice()) != null)
                return fail("'{s}' is already a name in this material", .{lnm.slice()});
            const lrhs = std.mem.trim(u8, rest[eq2 + 1 ..], " \t");
            if (lrhs.len == 0) return fail("let '{s}' has no expression", .{lnm.slice()});
            var one_buf: [4096]u8 = undefined;
            var one = Cursor{ .buf = &one_buf };
            if (!compileExpr(lrhs, colors[0..n_colors], scalars[0..n_scalars], locals[0..n_locals], textures[0..n_textures], &one))
                return -1;
            if (one.overflow) return fail("let '{s}' is too long", .{lnm.slice()});
            lets.put("  let v_");
            lets.put(lnm.slice());
            lets.put(" = ");
            lets.put(one.items());
            lets.put(";\n");
            locals[n_locals] = lnm;
            n_locals += 1;
        } else if (st[0] == '@') {
            const eq = std.mem.indexOfScalar(u8, st, '=') orelse
                return fail("body has no '='", .{});
            const lhs = std.mem.trim(u8, st[1..eq], " \t");
            var lhs_lower: Name = .{};
            if (!lowerInto(&lhs_lower, lhs) or !std.mem.eql(u8, lhs_lower.slice(), "out"))
                return fail("a material assigns '@out', not '@{s}'", .{lhs});
            const rhs = std.mem.trim(u8, st[eq + 1 ..], " \t");
            if (rhs.len == 0) return fail("empty expression", .{});
            if (!compileExpr(rhs, colors[0..n_colors], scalars[0..n_scalars], locals[0..n_locals], textures[0..n_textures], &expr))
                return -1;
            saw_out = true;
        } else {
            return fail("a statement is 'let name = ...' or '@out = ...'", .{});
        }
    }
    if (!saw_out) return fail("no '@out = ...' -- a material must produce a colour", .{});
    if (lets.overflow) return fail("too much material code", .{});
    if (expr.overflow) return fail("expression too long", .{});

    // ---- emit a COMPLETE shader on the render layer's 3D contract
    var w = Cursor{ .buf = out[0..@intFromFloat(cap)] };
    const put = struct {
        fn f(l: *Cursor, s: []const u8) void {
            l.put(s);
        }
    }.f;

    put(&w, "struct Frame { viewProj : mat4x4<f32>, lightDir : vec4<f32>, lightColor : vec4<f32>, ambient : vec4<f32> }\n");
    put(&w, "struct Instance { model : mat4x4<f32>, normalMat : mat4x4<f32>, color : vec4<f32> }\n");
    put(&w, "struct M {");
    var first = true;
    for (0..n_colors) |c| {
        if (!first) put(&w, ",");
        put(&w, " c_");
        put(&w, colors[c].slice());
        put(&w, " : vec4<f32>");
        first = false;
    }
    for (0..n_scalars) |s| {
        if (!first) put(&w, ",");
        put(&w, " s_");
        put(&w, scalars[s].slice());
        put(&w, " : f32");
        first = false;
    }
    if (first) put(&w, " unused : f32"); // WGSL has no empty struct
    put(&w, " }\n");
    put(&w, "@group(0) @binding(0) var<storage, read> frame : Frame;\n");
    put(&w, "@group(0) @binding(1) var<storage, read> instances : array<Instance>;\n");
    put(&w, "@group(0) @binding(2) var<storage, read> m : M;\n");
    // TEXTURES take group(0) bindings from 3 up, two apiece, in DECLARATION
    // order. The draw path builds the bind group from the same order, so the
    // layout is a shared convention rather than something either side infers.
    for (0..n_textures) |t| {
        var nb: [8]u8 = undefined;
        put(&w, "@group(0) @binding(");
        put(&w, std.fmt.bufPrint(&nb, "{d}", .{3 + 2 * t}) catch "0");
        put(&w, ") var t_");
        put(&w, textures[t].slice());
        put(&w, " : texture_2d<f32>;\n@group(0) @binding(");
        put(&w, std.fmt.bufPrint(&nb, "{d}", .{4 + 2 * t}) catch "0");
        put(&w, ") var sm_");
        put(&w, textures[t].slice());
        put(&w, " : sampler;\n");
    }
    // The sRGB transfer pair as the standard defines it -- the piecewise
    // curve, not a gamma of 2.2. The linear segment near black is exactly
    // where dark colours live, and an approximation there is visible.
    put(&w, "fn stzToLinear3(c : vec3<f32>) -> vec3<f32> {\n");
    put(&w, "  let hi = pow((c + vec3<f32>(0.055)) / vec3<f32>(1.055), vec3<f32>(2.4));\n");
    put(&w, "  let lo = c / vec3<f32>(12.92);\n");
    put(&w, "  return select(hi, lo, c <= vec3<f32>(0.04045));\n}\n");
    put(&w, "fn stzToLinear4(c : vec4<f32>) -> vec4<f32> {\n");
    put(&w, "  return vec4<f32>(stzToLinear3(c.rgb), c.a);\n}\n");
    put(&w, "fn stzToSrgb3(c : vec3<f32>) -> vec3<f32> {\n");
    put(&w, "  let v = max(c, vec3<f32>(0.0));\n");
    put(&w, "  let hi = vec3<f32>(1.055) * pow(v, vec3<f32>(1.0 / 2.4)) - vec3<f32>(0.055);\n");
    put(&w, "  let lo = v * vec3<f32>(12.92);\n");
    put(&w, "  return select(hi, lo, v <= vec3<f32>(0.0031308));\n}\n");
    put(&w, "struct VSOut { @builtin(position) pos : vec4<f32>, @location(0) nrm : vec3<f32>, @location(1) col : vec4<f32>, @location(2) uv : vec2<f32>, @location(3) wpos : vec3<f32> }\n");
    put(&w, "@vertex\n");
    put(&w, "fn vmain(@location(0) position : vec3<f32>, @location(1) normal : vec3<f32>, @location(2) uv : vec2<f32>, @builtin(instance_index) ii : u32) -> VSOut {\n");
    put(&w, "  let inst = instances[ii];\n");
    put(&w, "  let world = inst.model * vec4<f32>(position, 1.0);\n");
    put(&w, "  var o : VSOut;\n");
    put(&w, "  o.pos = frame.viewProj * world;\n");
    put(&w, "  o.nrm = normalize((inst.normalMat * vec4<f32>(normal, 0.0)).xyz);\n");
    put(&w, "  o.col = inst.color;\n  o.uv = uv;\n  o.wpos = world.xyz;\n  return o;\n}\n");
    put(&w, "@fragment\n");
    put(&w, "fn fmain(in : VSOut) -> @location(0) vec4<f32> {\n");
    put(&w, "  let f_normal = normalize(in.nrm);\n");
    put(&w, "  let f_position = in.wpos;\n");
    put(&w, "  let f_uv = in.uv;\n");
    put(&w, "  let f_color = stzToLinear4(in.col);\n");
    put(&w, "  let f_lambert = max(dot(f_normal, -normalize(frame.lightDir.xyz)), 0.0);\n");
    // LINEARISED COPIES of every declared colour. The body multiplies,
    // mixes and powers these, and all of that arithmetic is only
    // meaningful on LINEAR light. Measured before the fix: a material
    // saying `tint * k` with tint #808080 and k 0.5 rendered 64, where the
    // physically correct answer is 92 -- shadows far too dark, mid-tones
    // muddy. The classic gamma bug.
    for (0..n_colors) |ci| {
        put(&w, "  let lc_");
        put(&w, colors[ci].slice());
        put(&w, " = stzToLinear4(m.c_");
        put(&w, colors[ci].slice());
        put(&w, ");\n");
    }
    // KEEP THE MATERIAL BINDING ALIVE. A material may declare a colour or
    // scalar its body never reads; naga then strips @binding(2) from the
    // pipeline layout, the draw still binds three buffers, and wgpu PANICS
    // at submit -- the same shape as the layout:"auto" tile trap, where a
    // binding mistake reports at SUBMIT and never at the line responsible.
    // The comparison below is always false for real data but it READS the
    // struct, so the binding survives optimisation.
    put(&w, "  if (");
    if (n_colors > 0) {
        put(&w, "m.c_");
        put(&w, colors[0].slice());
        put(&w, ".a");
    } else if (n_scalars > 0) {
        put(&w, "m.s_");
        put(&w, scalars[0].slice());
    } else {
        put(&w, "m.unused");
    }
    put(&w, " < -1.0e30) { discard; }\n");
    // Same keep-alive, same reason, for every declared TEXTURE: a texture
    // the body never samples is stripped from the layout while the draw
    // still binds it. Applied here BEFORE it could bite, because the colour
    // case already cost a process panic to find.
    for (0..n_textures) |t| {
        put(&w, "  if (textureSample(t_");
        put(&w, textures[t].slice());
        put(&w, ", sm_");
        put(&w, textures[t].slice());
        put(&w, ", vec2<f32>(0.5, 0.5)).a < -1.0e30) { discard; }\n");
    }
    put(&w, lets.items());   // the material's own let bindings, in order
    // ENCODE ON THE WAY OUT. The body worked in linear; the target holds
    // sRGB-encoded bytes, so the last act is the inverse transfer. Alpha is
    // NOT encoded -- it is coverage, not light.
    put(&w, "  let stz_out = ");
    put(&w, expr.items());
    put(&w, ";\n");
    put(&w, "  return vec4<f32>(stzToSrgb3(stz_out.rgb), stz_out.a);\n}\n");

    if (w.overflow) return fail("material too large for the output buffer", .{});
    return @intCast(w.len);
}

test "fragment transpile: builtins, swizzles, and refusals" {
    var buf: [8192]u8 = undefined;
    const spec = "color base\nscalar glow\nbody { @out = base * (1.0 + glow * @normal.y) }";
    const n = stz_gpu_wgsl_fragment(spec.ptr, @floatFromInt(spec.len), &buf, buf.len);
    try std.testing.expect(n > 0);
    const wgsl = buf[0..@intCast(n)];
    // since C4 (f96f03093, 2026-08-12) a colour is shaded in LINEAR light and
    // encoded to sRGB once, at the return; this line still expected the old
    // sRGB-space form and had failed since that commit (found by GT0's run of
    // this module's tests, 2026-10-28)
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "let stz_out = lc_base * (1.0 + m.s_glow * f_normal.y);") != null);
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "stzToSrgb3(stz_out.rgb)") != null);
    // it must be a COMPLETE shader, not a loose fragment
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "@vertex") != null);
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "@fragment") != null);
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "f_lambert") != null);

    // every refusal names its offender
    const cases = [_][]const u8{
        "color base\nbody { @out = @gloss }", // not a builtin
        "color base\nbody { @out = base.q }", // bad swizzle... (bare name, no swizzle)
        "color base\nbody { @out = missing * 2.0 }", // undeclared
        "color base\nbody { @c = base }", // wrong lhs
        "color base\nbody { @out = @out }", // reads the output
        "color base\nbody { @out = base $ 2.0 }", // foreign character
        "color base\n", // no body
    };
    for (cases) |c| {
        try std.testing.expectEqual(@as(i32, -1), stz_gpu_wgsl_fragment(c.ptr, @floatFromInt(c.len), &buf, buf.len));
    }
}

test "GT0: a camel-case WGSL function is admitted in any case and emitted in WGSL's spelling" {
    var buf: [4096]u8 = undefined;
    const spec = "in a\nout c\nbody { @c = inversesqrt(abs(@a) + 0.5) + InverseSqrt(2) }";
    const n = stz_gpu_wgsl_elementwise(spec.ptr, @floatFromInt(spec.len), &buf, buf.len);
    try std.testing.expect(n > 0);
    const w = buf[0..@intCast(n)];
    try std.testing.expect(std.mem.indexOf(u8, w, "inverseSqrt(abs(v_a[i]) + 0.5f) + inverseSqrt(2f") != null);
    try std.testing.expect(std.mem.indexOf(u8, w, "inversesqrt") == null);
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_compile(spec.ptr, @floatFromInt(spec.len)));
    // the material language shares the whitelist
    const frag = "color base\nbody { @out = base * inversesqrt(2.0) }";
    const fnn = stz_gpu_wgsl_fragment(frag.ptr, @floatFromInt(frag.len), &buf, buf.len);
    try std.testing.expect(fnn > 0);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(fnn)], "inverseSqrt(2.0)") != null);
}

test "GT0: a guard's parenthesis may hold a condition, in both readers, with one meaning" {
    var buf: [4096]u8 = undefined;
    const spec = "in a\nout c\nguard { @i < n and (@a > 1 or @i < 2) }\nbody { @c = @a * 2 }";
    try std.testing.expect(stz_gpu_wgsl_elementwise(spec.ptr, @floatFromInt(spec.len), &buf, buf.len) > 0);
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_compile(spec.ptr, @floatFromInt(spec.len)));
    const a = [_]f32{ 0, 0, 0, 3, 0.5 };
    const ins = [_][*]const f32{&a};
    const lens = [_]f64{5};
    const sc = [_]f32{0};
    var out: [5]f32 = undefined;
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_eval(&ins, 1, &lens, &sc, 0, 5, &out));
    // elements 0 and 1 by the index, 3 by the value; 2 and 4 refused (NaN: unwritten)
    try std.testing.expectEqual(@as(f32, 0), out[0]);
    try std.testing.expectEqual(@as(f32, 0), out[1]);
    try std.testing.expect(out[2] != out[2]);
    try std.testing.expectEqual(@as(f32, 6), out[3]);
    try std.testing.expect(out[4] != out[4]);
    // a body still reads a parenthesis as arithmetic only
    const body = "in a\nout c\nbody { @c = (@a > 1) }";
    try std.testing.expectEqual(@as(i32, -1), stz_gpu_spec_compile(body.ptr, @floatFromInt(body.len)));
}

test "GT0: 'and' beside 'or' without parentheses is refused by both readers, as WGSL refuses it" {
    var buf: [4096]u8 = undefined;
    const mixed = [_][]const u8{
        "in a\nout c\nguard { @i < n and @a > 0 or @a < -1 }\nbody { @c = @a }",
        "in a\nout c\nguard { @a < -1 or @i < n and @a > 0 }\nbody { @c = @a }",
        "in a\nout c\nguard { @i < n and (@a > 0 or @a < -1 and @a > -5) }\nbody { @c = @a }",
    };
    for (mixed) |m| {
        try std.testing.expectEqual(@as(i32, -1), stz_gpu_wgsl_elementwise(m.ptr, @floatFromInt(m.len), &buf, buf.len));
        try std.testing.expectEqual(@as(i32, -1), stz_gpu_spec_compile(m.ptr, @floatFromInt(m.len)));
        var e: [256]u8 = undefined;
        const el = stz_gpu_wgsl_error(&e, e.len);
        try std.testing.expect(std.mem.indexOf(u8, e[0..@intCast(el)], "need parentheses") != null);
    }
    const ok = [_][]const u8{
        "in a\nout c\nguard { (@i < n and @a > 0) or (@i < n and @a < -1) }\nbody { @c = @a }",
        "in a\nout c\nguard { @i < n and @a > 0 and @a < 5 }\nbody { @c = @a }",
        "in a\nout c\nguard { @i < 2 or @i > 5 or @a > 1 }\nbody { @c = @a }",
        "in a\nout c\nguard { @i < n and (@a > 0 or @a < -1) }\nbody { @c = max(@a, 1) }",
    };
    for (ok) |o| {
        try std.testing.expect(stz_gpu_wgsl_elementwise(o.ptr, @floatFromInt(o.len), &buf, buf.len) > 0);
        try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_compile(o.ptr, @floatFromInt(o.len)));
    }
}

fn evalOne(spec: []const u8, a: []const f32, sc: []const f32, out: []f32) !void {
    if (stz_gpu_spec_compile(spec.ptr, @floatFromInt(spec.len)) != 0) return error.Refused;
    const ins = [_][*]const f32{a.ptr};
    const lens = [_]f64{@floatFromInt(a.len)};
    if (stz_gpu_spec_eval(&ins, 1, &lens, sc.ptr, @intCast(sc.len), @floatFromInt(out.len), out.ptr) != 0) return error.EvalFailed;
}

test "GL0: when(c, t, f) is one value in both readers, and WGSL's select gets its false value first" {
    var buf: [8192]u8 = undefined;
    const relu = "in a\nout c\nbody { @c = when(@a > 0, @a, 0) }";
    const n = stz_gpu_wgsl_elementwise(relu.ptr, @floatFromInt(relu.len), &buf, buf.len);
    try std.testing.expect(n > 0);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "select((0f), (v_a[i]), (v_a[i]>0f))") != null or
        std.mem.indexOf(u8, buf[0..@intCast(n)], "select((0f), (v_a[i]), (v_a[i] > 0f))") != null);
    const a = [_]f32{ -2, -0.5, 0, 0.5, 3 };
    var out: [5]f32 = undefined;
    try evalOne(relu, &a, &.{}, &out);
    try std.testing.expectEqualSlices(f32, &.{ 0, 0, 0, 0.5, 3 }, &out);
    // nested, with and/or, a neighbour and a sum in its values, a scalar in its condition
    const deep = "in a\nscalar s\nout c\nbody { @c = when(@a < s or (@i > 2 and @a > 2), when(@a < -1, -1, @a[@i + 1]), sum(k, 0, 3, @a[k])) }";
    try std.testing.expect(stz_gpu_wgsl_elementwise(deep.ptr, @floatFromInt(deep.len), &buf, buf.len) > 0);
    try evalOne(deep, &a, &.{0}, &out);
    // @a < 0: -2 -> -1, -0.5 -> @a[2] = 0; 0 and 0.5 -> sum = -2.5; 3 at i = 4 -> @a[5] = 0 (outside)
    try std.testing.expectEqualSlices(f32, &.{ -1, 0, -2.5, -2.5, 0 }, &out);
    // the static count holds both values, the condition and the select; the run counts the path taken
    try std.testing.expect(stz_gpu_spec_flops() >= 7);
    // in a guard and in a stage, too
    const g = "in a\nout c\nguard { @i < n and when(@a > 0, @a, -@a) > 1 }\nbody { @c = 1 }";
    try std.testing.expect(stz_gpu_wgsl_elementwise(g.ptr, @floatFromInt(g.len), &buf, buf.len) > 0);
    try evalOne(g, &a, &.{}, &out);
    try std.testing.expectEqual(@as(f32, 1), out[0]);
    try std.testing.expect(out[1] != out[1]);
    try std.testing.expectEqual(@as(f32, 1), out[4]);
}

test "GL0: a condition's shape is read once, so both readers refuse the same texts with the same words" {
    var buf: [8192]u8 = undefined;
    const Case = struct { spec: []const u8, words: []const u8 };
    const refused = [_]Case{
        .{ .spec = "in a\nout c\nbody { @c = when(@a, 1, 0) }", .words = "a bare value is not a condition" },
        .{ .spec = "in a\nout c\nbody { @c = when(@a > 0, 1) }", .words = "when takes 3 arguments" },
        .{ .spec = "in a\nout c\nbody { @c = when(@a > 0, 1, 0, 2) }", .words = "when takes 3 arguments" },
        .{ .spec = "in a\nout c\nbody { @c = when }", .words = "when takes 3 arguments" },
        .{ .spec = "in a\nout c\nbody { @c = when(@a > 0, @a > 1, 0) }", .words = "is a comparison" },
        .{ .spec = "in a\nout c\nbody { @c = when((@a > 0) + 1 > 0, 1, 0) }", .words = "a comparison is not a value" },
        .{ .spec = "in a\nout c\nbody { @c = when(0 < @a < 2, 1, 0) }", .words = "a condition compares" },
        .{ .spec = "in a\nout c\nbody { @c = when(@a > 0 and @a < 1 or @a > 5, 1, 0) }", .words = "need parentheses" },
        .{ .spec = "in a\nout c\nbody { @c = when(when(@a > 0, 1, 0), 1, 0) }", .words = "a bare value is not a condition" },
        // a comparison inside a body's brackets is named as one by both readers
        .{ .spec = "in a\nout c\nbody { @c = (@a > 0) + 1 }", .words = "'>' is a comparison" },
        .{ .spec = "in a\nout c\nbody { @c = @a[@i > 0] }", .words = "'>' is a comparison" },
        .{ .spec = "in a\nout c\nbody { @c = max(@a > 0, 1) }", .words = "'>' is a comparison" },
        .{ .spec = "in a\nout c\nbody { @c = sum(k, 0, 3 > 1, @a[k]) }", .words = "'>' is a comparison" },
        // the guard's holes this closes: each reached the device and failed in naga's words
        .{ .spec = "in a\nout c\nguard { @a }\nbody { @c = 1 }", .words = "a bare value is not a condition" },
        .{ .spec = "in a\nout c\nguard { @i < n and @a }\nbody { @c = 1 }", .words = "a bare value is not a condition" },
        .{ .spec = "in a\nout c\nguard { max(@a < 0, 1) > 0 }\nbody { @c = 1 }", .words = "a comparison is not a value" },
        .{ .spec = "in a\nout c\nguard { (@i < n) * 2 > 0 }\nbody { @c = 1 }", .words = "a comparison is not a value" },
    };
    for (refused) |c| {
        var e: [256]u8 = undefined;
        try std.testing.expectEqual(@as(i32, -1), stz_gpu_wgsl_elementwise(c.spec.ptr, @floatFromInt(c.spec.len), &buf, buf.len));
        const el1 = stz_gpu_wgsl_error(&e, e.len);
        var e1: [256]u8 = undefined;
        @memcpy(e1[0..@intCast(el1)], e[0..@intCast(el1)]);
        try std.testing.expectEqual(@as(i32, -1), stz_gpu_spec_compile(c.spec.ptr, @floatFromInt(c.spec.len)));
        const el2 = stz_gpu_wgsl_error(&e, e.len);
        try std.testing.expectEqualStrings(e1[0..@intCast(el1)], e[0..@intCast(el2)]);
        if (std.mem.indexOf(u8, e[0..@intCast(el2)], c.words) == null) {
            std.debug.print("\n{s}\n  -> {s}\n", .{ c.spec, e[0..@intCast(el2)] });
            return error.WrongWords;
        }
    }
    const admitted = [_][]const u8{
        "in a\nout c\nguard { (@i < n) }\nbody { @c = 1 }",
        "in a\nout c\nguard { ((@i < n)) and (@a > 0 or @a < -1) }\nbody { @c = 1 }",
        "in a\nout c\nguard { (@a + 1) * 2 > 0 and @i < n }\nbody { @c = 1 }",
        "in a\nout c\nguard { @a[@i + 1] >= max(@a, 0) }\nbody { @c = 1 }",
        "in a\nout c\nbody { @c = when((@a > 0), 1, 0) + when(@a <= 0, 2, 3) }",
        "in a\nout c\nshared t 256\nstage { @t[@l] = when(@a > 0, @a, 0) }\nreduce t max\nbody { @c = @t[0] }",
    };
    for (admitted) |o| {
        if (stz_gpu_wgsl_elementwise(o.ptr, @floatFromInt(o.len), &buf, buf.len) <= 0 or stz_gpu_spec_compile(o.ptr, @floatFromInt(o.len)) != 0) {
            var e: [256]u8 = undefined;
            const el = stz_gpu_wgsl_error(&e, e.len);
            std.debug.print("\n{s}\n  -> {s}\n", .{ o, e[0..@intCast(el)] });
            return error.Refused;
        }
    }
}

fn evalSc(spec: []const u8, a: []const f32, sc: []const f32, out: []f32) !void {
    if (stz_gpu_spec_compile(spec.ptr, @floatFromInt(spec.len)) != 0) {
        var e: [256]u8 = undefined;
        const el = stz_gpu_wgsl_error(&e, e.len);
        std.debug.print("\n{s}\n  -> {s}\n", .{ spec, e[0..@intCast(el)] });
        return error.Refused;
    }
    const ins = [_][*]const f32{a.ptr};
    const lens = [_]f64{@floatFromInt(a.len)};
    if (stz_gpu_spec_eval(&ins, 1, &lens, sc.ptr, @intCast(sc.len), @floatFromInt(out.len), out.ptr) != 0) return error.EvalFailed;
}

fn wgslHas(spec: []const u8, needle: []const u8) !void {
    var buf: [16384]u8 = undefined;
    const n = stz_gpu_wgsl_elementwise(spec.ptr, @floatFromInt(spec.len), &buf, buf.len);
    if (n <= 0 or std.mem.indexOf(u8, buf[0..@intCast(n)], needle) == null) {
        std.debug.print("\n{s}\n  wanted: {s}\n  got: {s}\n", .{ spec, needle, if (n > 0) buf[0..@intCast(n)] else "(refused)" });
        return error.NotWritten;
    }
}

test "GL0 types: an int is declared, a whole number takes its partner's type, and i32 means what WGSL says" {
    var out: [5]f32 = undefined;
    // arithmetic: truncating division, a remainder with the dividend's sign
    const ar = "in a int\nscalar k int\nout c int\nbody { @c = (@a * 3 + k) / 2 - @a % 4 }";
    // the remainder is the helper's: the device takes an i32 '%' as unsigned
    try wgslHas(ar, "v_c[i] = f32((i32(v_a[i]) * 3i + i32(p.s_k)) / 2i - stz_rem(i32(v_a[i]), 4i));");
    try wgslHas(ar, "fn stz_rem(a : i32, b : i32) -> i32 {");
    try evalSc(ar, &.{ -7, -1, 0, 5, 9.9 }, &.{1}, &out);
    try std.testing.expectEqualSlices(f32, &.{ -7, 0, 0, 7, 13 }, &out);
    // by zero: the dividend, and 0 -- naga's polyfill, WGSL's rule
    const dz = "in a int\nout c int\nbody { @c = @a / (@a - @a) + @a % 0 }";
    var o3: [3]f32 = undefined;
    try evalSc(dz, &.{ 5, -3, 0 }, &.{}, &o3);
    try std.testing.expectEqualSlices(f32, &.{ 5, -3, 0 }, &o3);
    // the product wraps on 32 bits, as on every GPU and CPU
    const wr = "in a int\nout c int\nbody { @c = (@a * 2147483647) % 1000 }";
    var o2: [2]f32 = undefined;
    try evalSc(wr, &.{ 2, 3 }, &.{}, &o2);
    try std.testing.expectEqualSlices(f32, &.{ -2, 645 }, &o2);
    // int(x) goes toward zero and saturates at the largest f32 below 2^31;
    // NaN is the most negative int (both measured on the RTX 3050)
    const cv = "in a\nout c int\nbody { @c = int(@a) }";
    try wgslHas(cv, "v_c[i] = f32(i32(v_a[i]));");
    try evalSc(cv, &.{ 2.7, -2.7, 3e9, -3e9, std.math.nan(f32) }, &.{}, &out);
    try std.testing.expectEqualSlices(f32, &.{ 2, -2, 2147483520.0, -2147483648.0, -2147483648.0 }, &out);
    // float(i), and a whole number meeting a float stays a float
    const fl = "in a int\nout c\nbody { @c = float(@a) / 2 }";
    try wgslHas(fl, "v_c[i] = f32(i32(v_a[i])) / 2f;");
    try evalSc(fl, &.{ 3, -3, 0, 1, 2 }, &.{}, &out);
    try std.testing.expectEqualSlices(f32, &.{ 1.5, -1.5, 0, 0.5, 1 }, &out);
    // untyped alone is f32, as before GL0: 3 / 4 is 0.75
    const un = "in a\nout c\nbody { @c = 3 / 4 + @a * 0 }";
    try wgslHas(un, "3f / 4f");
    // the counting names adopt too: @i meets an int
    const ix = "in a int\nout c int\nbody { @c = @i * @a + n }";
    try wgslHas(ix, "v_c[i] = f32(i32(i) * i32(v_a[i]) + i32(p.n));");
    try evalSc(ix, &.{ 1, 1, 1, 1, 2 }, &.{}, &out);
    try std.testing.expectEqualSlices(f32, &.{ 5, 6, 7, 8, 13 }, &out);
    // a sum of ints accumulates in an i32; a when of ints; the generic functions
    const sm = "in a int\nout c int\nbody { @c = sum(k, 0, 3, @a[@i + k]) + when(@a > 2, min(@a, 4), abs(@a)) + clamp(@a, -1, 1) * sign(@a) }";
    try wgslHas(sm, "var acc0 : i32 = 0i;");
    try evalSc(sm, &.{ -2, 3, 5, 1, 9 }, &.{}, &out);
    // i0: -2+3+5=6, |-2|=2, clamp -1 * sign -1 = 1 -> 9; i1: 3+5+1=9, min(3,4)=3, 1*1 -> 13
    // i2: 5+1+9=15, 4, 1 -> 20; i3: 1+9+0=10, 1, 1 -> 12; i4: 9+0+0=9, 4, 1 -> 14
    try std.testing.expectEqualSlices(f32, &.{ 9, 13, 20, 12, 14 }, &out);
    // an int guard
    const gd = "in a int\nout c\nguard { @i < n and @a % 2 == 1 }\nbody { @c = 1 }";
    // @i and n meet each other only, so they compare as f32, as every guard did
    try wgslHas(gd, "f32(i) < f32(p.n)");
    try wgslHas(gd, "stz_rem(i32(v_a[i]), 2i) == 1i");
    // an int index reads the same element as its f32 twin
    const nb = "in a\nin q int\nout c\nbody { @c = @a[@q] }";
    try wgslHas(nb, "rd_a(i32(i32(v_q[i])))");
    // a sum in a guard: its loop is written before the guard's if, not inside
    // it (the int fuzz found every such kernel refused by the device since KP0)
    const gs = "in a\nout c\nguard { @i < n and sum(k, 0, 2, @a[@i + k]) > 0 }\nbody { @c = 1 }";
    var gb: [8192]u8 = undefined;
    const gn = stz_gpu_wgsl_elementwise(gs.ptr, @floatFromInt(gs.len), &gb, gb.len);
    try std.testing.expect(gn > 0);
    const gw = gb[0..@intCast(gn)];
    try std.testing.expect(std.mem.indexOf(u8, gw, "var acc0").? < std.mem.indexOf(u8, gw, "if (f32(i)").?);
}

test "GL0 types: the refusals, in one reader's words and the other's" {
    var buf: [8192]u8 = undefined;
    const Case = struct { spec: []const u8, words: []const u8 };
    const refused = [_]Case{
        .{ .spec = "in a int\nout c\nbody { @c = float(@a) + @a }", .words = "an int and a float meet at '+'" },
        .{ .spec = "in a int\nout c int\nbody { @c = @a + 0.5 }", .words = "meet at '+'" },
        .{ .spec = "in a int\nout c int\nbody { @c = sqrt(@a) }", .words = "'sqrt' works on floats: write sqrt(float(...))" },
        .{ .spec = "in a\nout c int\nbody { @c = @a }", .words = "holds ints; its value is a float" },
        .{ .spec = "in a int\nout c\nbody { @c = @a }", .words = "holds floats; its value is an int" },
        .{ .spec = "in a int\nout c int\nbody { @c = @a + 2147483648 }", .words = "'2147483648' is too large for an int" },
        .{ .spec = "in a int\nout c\nguard { @a > 0.5 }\nbody { @c = 1 }", .words = "meet at '>'" },
        .{ .spec = "in a int\nout c int\nbody { @c = when(@a > 0, @a, 0.5) }", .words = "meet at 'when'" },
        .{ .spec = "in a int\nout c int\nbody { @c = min(@a, 0.5) }", .words = "meet at 'min'" },
        .{ .spec = "in a word\nout c\nbody { @c = 1 }", .words = "'word' is not a type" },
        .{ .spec = "in a int\nout c\nshared t 256\nstage { @t[@l] = @a }\nbody { @c = @t[0] }", .words = "a shared array holds floats" },
        .{ .spec = "in a int\nout c\nbody { @c = int(@a, 1) }", .words = "function 'int' takes 1 argument(s), got 2" },
    };
    for (refused) |c| {
        var e: [256]u8 = undefined;
        if (stz_gpu_wgsl_elementwise(c.spec.ptr, @floatFromInt(c.spec.len), &buf, buf.len) != -1) {
            std.debug.print("\nthe transpiler admitted: {s}\n", .{c.spec});
            return error.Admitted;
        }
        const el1 = stz_gpu_wgsl_error(&e, e.len);
        var e1: [256]u8 = undefined;
        @memcpy(e1[0..@intCast(el1)], e[0..@intCast(el1)]);
        try std.testing.expectEqual(@as(i32, -1), stz_gpu_spec_compile(c.spec.ptr, @floatFromInt(c.spec.len)));
        const el2 = stz_gpu_wgsl_error(&e, e.len);
        try std.testing.expectEqualStrings(e1[0..@intCast(el1)], e[0..@intCast(el2)]);
        if (std.mem.indexOf(u8, e[0..@intCast(el2)], c.words) == null) {
            std.debug.print("\n{s}\n  -> {s}\n", .{ c.spec, e[0..@intCast(el2)] });
            return error.WrongWords;
        }
    }
}

fn evalIns(spec: []const u8, cols: []const []const f32, out: []f32) !void {
    if (stz_gpu_spec_compile(spec.ptr, @floatFromInt(spec.len)) != 0) {
        var e: [256]u8 = undefined;
        const el = stz_gpu_wgsl_error(&e, e.len);
        std.debug.print("\n{s}\n  -> {s}\n", .{ spec, e[0..@intCast(el)] });
        return error.Refused;
    }
    var ins: [4][*]const f32 = undefined;
    var lens: [4]f64 = undefined;
    for (cols, 0..) |c, k| {
        ins[k] = c.ptr;
        lens[k] = @floatFromInt(c.len);
    }
    const sc = [_]f32{0};
    if (stz_gpu_spec_eval(&ins, @intCast(cols.len), &lens, &sc, 0, @floatFromInt(out.len), out.ptr) != 0) return error.EvalFailed;
}

test "GL0 vectors: built from numbers, read by component, combined, reduced -- in both readers" {
    var o3: [3]f32 = undefined;
    const ln = "in x\nin y\nin z\nout d\nbody { @d = length(vec3(@x, @y, @z)) }";
    try wgslHas(ln, "v_d[i] = length(vec3<f32>(v_x[i], v_y[i], v_z[i]));");
    try evalIns(ln, &.{ &.{ 3, 0, 1 }, &.{ 4, 0, 2 }, &.{ 0, 0, 2 } }, &o3);
    try std.testing.expectEqualSlices(f32, &.{ 5, 0, 3 }, &o3);
    // a number spread across a vector, a swizzle of a swizzle, a dot
    const sw = "in a\nout c\nbody { @c = (vec3(@a, 1, 2) * 2 + 1).zyx.x + dot(vec2(@a, 1), vec2(3, 4)) }";
    try wgslHas(sw, "(vec3<f32>(v_a[i], 1f, 2f) * 2f + 1f).zyx.x + dot(vec2<f32>(v_a[i], 1f), vec2<f32>(3f, 4f))");
    try evalIns(sw, &.{&.{ 0, 1, 2 }}, &o3);
    try std.testing.expectEqualSlices(f32, &.{ 9, 12, 15 }, &o3);
    // cross, normalize, reflect, mix with one weight, when of vectors, floor by component
    const fx = "in a\nout c\nbody { @c = cross(vec3(1, 0, 0), vec3(0, @a, 0)).z + normalize(vec2(@a, 0)).x + reflect(vec2(1, -1), vec2(0, 1)).y + mix(vec2(0, 2), vec2(4, 6), 0.5).y + when(@a > 1, vec2(10, 20), vec2(30, 40)).y + floor(vec2(@a * 1.5, 0)).x }";
    try wgslHas(fx, "select((vec2<f32>(30f, 40f)), (vec2<f32>(10f, 20f)), (v_a[i] > 1f)).y");
    try evalIns(fx, &.{&.{ 1, 2, 3 }}, &o3);
    try std.testing.expectEqualSlices(f32, &.{ 48, 31, 33 }, &o3);
    // a constructor of a vector and numbers, and one number spread
    const ct = "in a\nout c\nbody { @c = vec4(vec2(@a, 1), 2, 3).w + vec3(@a).y - (-vec2(@a, 5)).y }";
    try evalIns(ct, &.{&.{ 0, 1, 2 }}, &o3);
    try std.testing.expectEqualSlices(f32, &.{ 8, 9, 10 }, &o3);
}

test "GL0 vectors: the refusals, in one reader's words and the other's" {
    var buf: [8192]u8 = undefined;
    const Case = struct { spec: []const u8, words: []const u8 };
    const refused = [_]Case{
        .{ .spec = "in a\nout c\nbody { @c = vec3(@a, 1, 2) }", .words = "a vector stands where a number is needed" },
        .{ .spec = "in a\nout c\nbody { @c = when(vec2(@a, 1) > 0, 1, 0) }", .words = "a vector is not compared whole" },
        .{ .spec = "in a\nout c\nbody { @c = (vec2(1, 2) + vec3(1, 2, 3)).x }", .words = "vectors of two widths meet at '+'" },
        .{ .spec = "in a\nout c\nbody { @c = min(vec2(@a, 1), 0).x }", .words = "'min' takes values of one type: write vec2(x)" },
        .{ .spec = "in a\nout c\nbody { @c = vec3(1, 2).x }", .words = "vec3 takes 3 numbers" },
        .{ .spec = "in a\nout c\nbody { @c = dot(@a, 2) }", .words = "'dot' works on vectors" },
        .{ .spec = "in a\nout c\nbody { @c = cross(vec2(1, 2), vec2(3, 4)).x }", .words = "cross takes two vec3s" },
        .{ .spec = "in a\nout c\nbody { @c = @a.x }", .words = "'.x' reads a vector's components, and this value is a number" },
        .{ .spec = "in a\nout c\nbody { @c = vec2(@a, 1).z }", .words = "'.z' is not a component of this vector: a vec2's letters are xy" },
        .{ .spec = "in k int\nout c\nbody { @c = vec2(@k, 1).x }", .words = "a vector holds floats" },
        .{ .spec = "in a\nout c\nbody { @c = int(vec2(1, 2)) }", .words = "'int' converts a number, not a vector" },
        .{ .spec = "in a\nout c\nbody { @c = @a[vec2(1, 2)] }", .words = "a vector stands where a number is needed" },
        .{ .spec = "in a\nout c\nbody { @c = sum(k, 0, 2, vec2(k, 1)).x }", .words = "a vector stands where a number is needed" },
        .{ .spec = "in a\nout c\nbody { @c = when(@a > 0, vec2(1, 2), 3).x }", .words = "'when' takes values of one type" },
    };
    for (refused) |c| {
        var e: [256]u8 = undefined;
        if (stz_gpu_wgsl_elementwise(c.spec.ptr, @floatFromInt(c.spec.len), &buf, buf.len) != -1) {
            std.debug.print("\nthe transpiler admitted: {s}\n", .{c.spec});
            return error.Admitted;
        }
        const el1 = stz_gpu_wgsl_error(&e, e.len);
        var e1: [256]u8 = undefined;
        @memcpy(e1[0..@intCast(el1)], e[0..@intCast(el1)]);
        if (stz_gpu_spec_compile(c.spec.ptr, @floatFromInt(c.spec.len)) != -1) {
            std.debug.print("\nthe interpreter admitted: {s}\n", .{c.spec});
            return error.Admitted;
        }
        const el2 = stz_gpu_wgsl_error(&e, e.len);
        if (!std.mem.eql(u8, e1[0..@intCast(el1)], e[0..@intCast(el2)]) or std.mem.indexOf(u8, e[0..@intCast(el2)], c.words) == null) {
            std.debug.print("\n{s}\n  transpiler:  {s}\n  interpreter: {s}\n", .{ c.spec, e1[0..@intCast(el1)], e[0..@intCast(el2)] });
            return error.WrongWords;
        }
    }
}

fn evalMasked(spec: []const u8, cols: []const []const f32, n: usize, out: []f32, mask: []u8) !void {
    if (stz_gpu_spec_compile(spec.ptr, @floatFromInt(spec.len)) != 0) {
        var e: [256]u8 = undefined;
        const el = stz_gpu_wgsl_error(&e, e.len);
        std.debug.print("\n{s}\n  -> {s}\n", .{ spec, e[0..@intCast(el)] });
        return error.Refused;
    }
    var ins: [4][*]const f32 = undefined;
    var lens: [4]f64 = undefined;
    for (cols, 0..) |c, k| {
        ins[k] = c.ptr;
        lens[k] = @floatFromInt(c.len);
    }
    const sc = [_]f32{0};
    if (stz_gpu_spec_eval_masked(&ins, @intCast(cols.len), &lens, &sc, 0, @floatFromInt(n), out.ptr, mask.ptr) != 0) return error.EvalFailed;
}

test "GL0 typed buffers: a vecN input or output holds N floats per element, packed" {
    var mask: [8]u8 = undefined;
    // a vec3 input: element i is floats 3i .. 3i + 2
    const ln = "in p vec3\nout c\nbody { @c = length(@p) }";
    try wgslHas(ln, "v_c[i] = length(vec3<f32>(v_p[3u * i], v_p[3u * i + 1u], v_p[3u * i + 2u]));");
    var o3: [3]f32 = undefined;
    try evalMasked(ln, &.{&.{ 3, 4, 0, 0, 0, 0, 1, 2, 2 }}, 3, &o3, &mask);
    try std.testing.expectEqualSlices(f32, &.{ 5, 0, 3 }, &o3);
    try std.testing.expectEqual(@as(f64, 3), stz_gpu_spec_in_width(0));
    try std.testing.expectEqual(@as(f64, 1), stz_gpu_spec_out_width());
    // a vec2 output: element i stored at floats 2i and 2i + 1
    const rot = "in p vec2\nout q vec2\nbody { @q = vec2(-@p.y, @p.x) }";
    try wgslHas(rot, "let o_ = vec2<f32>(-vec2<f32>(v_p[2u * i], v_p[2u * i + 1u]).y, vec2<f32>(v_p[2u * i], v_p[2u * i + 1u]).x); v_q[2u * i] = o_.x; v_q[2u * i + 1u] = o_.y; }");
    var o4: [4]f32 = undefined;
    try evalMasked(rot, &.{&.{ 1, 2, 3, 4 }}, 2, &o4, &mask);
    try std.testing.expectEqualSlices(f32, &.{ -2, 1, -4, 3 }, &o4);
    try std.testing.expectEqual(@as(f64, 2), stz_gpu_spec_out_width());
    // a neighbour of a vec2 input: a zero vector outside its elements
    const nb = "in p vec2\nout c\nbody { @c = @p[@i + 1].x + @p[@i - 1].y }";
    try wgslHas(nb, "fn rd_p(k : i32) -> vec2<f32> {\n  if (k < 0 || u32(k) >= arrayLength(&v_p) / 2u) { return vec2<f32>(0.0); }\n  let b = 2u * u32(k);\n  return vec2<f32>(v_p[b], v_p[b + 1u]);\n}\n");
    try evalMasked(nb, &.{&.{ 1, 2, 3, 4, 5, 6 }}, 3, &o3, &mask);
    try std.testing.expectEqualSlices(f32, &.{ 3, 7, 4 }, &o3);
    // a guard over a vector output: an element left unwritten is N NaNs, one mask byte
    const gd = "in p vec2\nout q vec2\nguard { @i < n and @p.x > 2 }\nbody { @q = @p * 2 }";
    try evalMasked(gd, &.{&.{ 1, 2, 3, 4 }}, 2, &o4, &mask);
    try std.testing.expect(o4[0] != o4[0] and o4[1] != o4[1]);
    try std.testing.expectEqualSlices(f32, &.{ 6, 8 }, o4[2..4]);
    try std.testing.expectEqualSlices(u8, &.{ 0, 1 }, mask[0..2]);
    // a stage reads a vector input's own element through the bounded read
    const st = "in p vec2\nout c\nshared t 256\nstage { @t[@l] = @p.x + @p.y }\nbody { @c = @t[255 - @l] }";
    var big: [512]f32 = undefined;
    for (&big, 0..) |*v, k| v.* = @floatFromInt(k);
    var o256: [256]f32 = undefined;
    var m256: [256]u8 = undefined;
    try evalMasked(st, &.{&big}, 256, &o256, &m256);
    try std.testing.expectEqual(@as(f32, 510 + 511), o256[0]);
    try std.testing.expectEqual(@as(f32, 0 + 1), o256[255]);
}

test "GL0 typed buffers: the refusals, in one reader's words and the other's" {
    var buf: [8192]u8 = undefined;
    const Case = struct { spec: []const u8, words: []const u8 };
    const refused = [_]Case{
        .{ .spec = "in p vec2\nout q vec2\nbody { @q = 1 }", .words = "the output '@q' holds vec2s: its value must be a vec2" },
        .{ .spec = "in p vec2\nout q vec3\nbody { @q = @p }", .words = "the output '@q' holds vec3s: its value must be a vec3" },
        .{ .spec = "in p vec2\nout c\nbody { @c = @p }", .words = "a vector stands where a number is needed" },
        .{ .spec = "in p vec2\nscalar s vec2\nout c\nbody { @c = 1 }", .words = "a scalar is one number" },
        .{ .spec = "in p vec5\nout c\nbody { @c = 1 }", .words = "'vec5' is not a type" },
    };
    for (refused) |c| {
        var e: [256]u8 = undefined;
        if (stz_gpu_wgsl_elementwise(c.spec.ptr, @floatFromInt(c.spec.len), &buf, buf.len) != -1) return error.Admitted;
        const el1 = stz_gpu_wgsl_error(&e, e.len);
        var e1: [256]u8 = undefined;
        @memcpy(e1[0..@intCast(el1)], e[0..@intCast(el1)]);
        if (stz_gpu_spec_compile(c.spec.ptr, @floatFromInt(c.spec.len)) != -1) return error.Admitted;
        const el2 = stz_gpu_wgsl_error(&e, e.len);
        if (!std.mem.eql(u8, e1[0..@intCast(el1)], e[0..@intCast(el2)]) or std.mem.indexOf(u8, e[0..@intCast(el2)], c.words) == null) {
            std.debug.print("\n{s}\n  transpiler:  {s}\n  interpreter: {s}\n", .{ c.spec, e1[0..@intCast(el1)], e[0..@intCast(el2)] });
            return error.WrongWords;
        }
    }
}

fn sanitizeFor(spec: []const u8, n: usize, a: []const f32) !i32 {
    if (stz_gpu_spec_compile(spec.ptr, @floatFromInt(spec.len)) != 0) return error.Refused;
    const ins = [_][*]const f32{a.ptr};
    const lens = [_]f64{@floatFromInt(a.len)};
    const sc = [_]f32{0};
    var out: [1024]f32 = undefined;
    var mask: [1024]u8 = undefined;
    return stz_gpu_spec_sanitize(&ins, 1, &lens, &sc, 0, @floatFromInt(n), &out, &mask);
}

fn sanitizeReport(buf: []u8) []const u8 {
    const n = stz_gpu_sanitize_report(buf.ptr, @floatFromInt(buf.len));
    return buf[0..@intCast(n)];
}

test "GZ0: the sanitizer names a race -- two threads of one stage, one slot -- with the line and the threads" {
    var a: [512]f32 = undefined;
    for (&a, 0..) |*v, i| v.* = @floatFromInt(i);
    var rb: [2048]u8 = undefined;
    const race = "in a\nout c\nshared t 256\nstage { @t[@l % 4] = @a }\nbody { @c = @t[0] }";
    try std.testing.expectEqual(@as(i32, 1), try sanitizeFor(race, 512, &a));
    try std.testing.expectEqual(@as(f64, 2 * 252), stz_gpu_sanitize_count(SAN_RACE)); // 252 collisions per group, 2 groups
    try std.testing.expectEqual(@as(f64, 4), stz_gpu_sanitize_line(SAN_RACE));
    const r = sanitizeReport(&rb);
    try std.testing.expect(std.mem.indexOf(u8, r, "race: line 4, a stage: threads 0 and 4 of group 0 both write slot 0 of @t") != null);
    try std.testing.expect(std.mem.indexOf(u8, r, "same value") == null);
    // one value from every thread: still named, and said to be harmless
    const same = "in a\nout c\nshared t 256\nstage { @t[@l % 4] = 1 }\nbody { @c = @t[0] }";
    try std.testing.expectEqual(@as(i32, 1), try sanitizeFor(same, 256, a[0..256]));
    try std.testing.expect(std.mem.indexOf(u8, sanitizeReport(&rb), "the same value, so the answer does not depend on it") != null);
}

test "GZ0: a write past the array, a read past it, and a read of a slot nobody wrote" {
    var a: [256]f32 = undefined;
    for (&a, 0..) |*v, i| v.* = @floatFromInt(i);
    var rb: [2048]u8 = undefined;
    // the array holds 128; threads 128 to 255 stage past it
    const dropped = "in a\nout c\nshared t 128\nstage { @t[@l] = @a }\nbody { @c = @t[@l % 128] }";
    try std.testing.expectEqual(@as(i32, 1), try sanitizeFor(dropped, 256, &a));
    try std.testing.expectEqual(@as(f64, 128), stz_gpu_sanitize_count(SAN_DROPPED));
    try std.testing.expect(std.mem.indexOf(u8, sanitizeReport(&rb), "dropped: line 4, a stage: thread 128 of group 0 writes slot 128 of @t, which holds 128") != null);
    // thread 255 reads slot 256
    const past = "in a\nout c\nshared t 256\nstage { @t[@l] = @a }\nbody { @c = @t[@l + 1] }";
    try std.testing.expectEqual(@as(i32, 1), try sanitizeFor(past, 256, &a));
    try std.testing.expectEqual(@as(f64, 1), stz_gpu_sanitize_count(SAN_PAST));
    try std.testing.expect(std.mem.indexOf(u8, sanitizeReport(&rb), "past: line 5, the body: thread 255 of group 0 reads slot 256 of @t, which holds 256; it reads 0") != null);
    // puzzle 9's second mistake: no stage at all
    const nostage = "in a\nout c\nshared t 256\nbody { @c = @t[255 - @l] }";
    try std.testing.expectEqual(@as(i32, 1), try sanitizeFor(nostage, 256, &a));
    try std.testing.expectEqual(@as(f64, 256), stz_gpu_sanitize_count(SAN_UNWRITTEN));
    try std.testing.expect(std.mem.indexOf(u8, sanitizeReport(&rb), "unwritten: line 4, the body: thread 0 of group 0 reads slot 255 of @t, which no stage wrote") != null);
}

test "GZ0: a max over slots no stage wrote counts their zero; a sum over them does not" {
    var a: [256]f32 = undefined;
    for (&a, 0..) |*v, i| v.* = -1 - @as(f32, @floatFromInt(i)); // every value negative: the zero wins a max
    var rb: [2048]u8 = undefined;
    const mx = "in a\nout c\nshared t 256\nstage { @t[@l % 128] = @a }\nreduce t max\nbody { @c = @t[0] }";
    _ = try sanitizeFor(mx, 256, &a);
    try std.testing.expect(stz_gpu_sanitize_count(SAN_UNWRITTEN) == 128); // slots 128..255
    try std.testing.expectEqual(@as(f64, 5), stz_gpu_sanitize_line(SAN_UNWRITTEN));
    try std.testing.expect(std.mem.indexOf(u8, sanitizeReport(&rb), "unwritten: line 5, a reduce:") != null);
    try std.testing.expect(stz_gpu_sanitize_count(SAN_RACE) > 0); // and @l % 128 collides: two threads per slot
    const sum = "in a\nout c\nshared t 256\nstage { @t[@l * 2] = @a }\nreduce t sum\nbody { @c = @t[0] }";
    _ = try sanitizeFor(sum, 256, &a);
    try std.testing.expectEqual(@as(f64, 0), stz_gpu_sanitize_count(SAN_UNWRITTEN));
    try std.testing.expectEqual(@as(f64, 128), stz_gpu_sanitize_count(SAN_DROPPED));
}

test "GZ0: the puzzles' references are clean, and watching does not change an answer" {
    var a: [3072]f32 = undefined;
    for (&a, 0..) |*v, i| v.* = @as(f32, @floatFromInt(i % 13)) - 6;
    const refs = [_][]const u8{
        "in a\nout c\nshared t 256\nstage { @t[@l] = @a }\nbody { @c = @t[255 - @l] }",
        "in a\nout c\nshared t 256\nstage { @t[@l] = @a }\nreduce t sum\nbody { @c = @t[0] }",
        "in a\nout c\nshared t 256\nstage { @t[@l] = @a }\nreduce t max\nbody { @c = @t[0] }",
    };
    for (refs) |r| {
        try std.testing.expectEqual(@as(i32, 0), try sanitizeFor(r, 1024, a[0..1024]));
        // the same answer with and without the sanitizer
        const ins = [_][*]const f32{&a};
        const lens = [_]f64{1024};
        const sc = [_]f32{0};
        var o1: [1024]f32 = undefined;
        var o2: [1024]f32 = undefined;
        var m: [1024]u8 = undefined;
        try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_eval(&ins, 1, &lens, &sc, 0, 1024, &o1));
        _ = stz_gpu_spec_sanitize(&ins, 1, &lens, &sc, 0, 1024, &o2, &m);
        try std.testing.expectEqualSlices(f32, &o1, &o2);
    }
    // the tiled product of puzzle 10: clean
    const mm = "in a\nin b\nscalar k\nscalar w\nout c\nwidth w\nshared ta 256\nshared tb 256\ntiles t { k / 16 }\nstage { @ta[@ly * 16 + @lx] = @a[@row * k + t * 16 + @lx] }\nstage { @tb[@ly * 16 + @lx] = @b[(t * 16 + @ly) * w + @col] }\naccumulate { @acc = @acc + sum(j, 0, 16, @ta[@ly * 16 + j] * @tb[j * 16 + @lx]) }\nbody { @c = @acc }";
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_compile(mm.ptr, @floatFromInt(mm.len)));
    const ins2 = [_][*]const f32{ &a, &a };
    const lens2 = [_]f64{ 32 * 64, 64 * 48 };
    const sc2 = [_]f32{ 64, 48 };
    var o: [32 * 48]f32 = undefined;
    var m2: [32 * 48]u8 = undefined;
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_sanitize(&ins2, 2, &lens2, &sc2, 2, 32 * 48, &o, &m2));
}

test "transpile basics" {
    var buf: [4096]u8 = undefined;
    const spec = "in a\nin b\nscalar alpha\nout c\nbody { @c = alpha * @a + @b }";
    const n = stz_gpu_wgsl_elementwise(spec.ptr, @floatFromInt(spec.len), &buf, buf.len);
    try std.testing.expect(n > 0);
    const wgsl = buf[0..@intCast(n)];
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "v_c[i] = p.s_alpha * v_a[i] + v_b[i];") != null);

    // refusals name the offender
    const bad = "in a\nout c\nbody { @c = @zz + 1 }";
    try std.testing.expectEqual(@as(i32, -1), stz_gpu_wgsl_elementwise(bad.ptr, @floatFromInt(bad.len), &buf, buf.len));
}

// ---------------------------------------------------------------- KP3 tests

fn errText(buf: []u8) []const u8 {
    const n = stz_gpu_wgsl_error(buf.ptr, @floatFromInt(buf.len));
    return buf[0..@intCast(n)];
}

test "KP3: a stage and a read across the group -- each group reversed, in the WGSL and the interpreter" {
    const spec = "in a\nout c\nshared t 256\nstage { @t[@l] = @a }\nbody { @c = @t[255 - @l] }";
    var buf: [8192]u8 = undefined;
    const wl = stz_gpu_wgsl_elementwise(spec.ptr, @floatFromInt(spec.len), &buf, buf.len);
    try std.testing.expect(wl > 0);
    const wgsl = buf[0..@intCast(wl)];
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "var<workgroup> w_t : array<f32, 256>;") != null);
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "if (ix >= 0 && ix < 256) { w_t[ix] = rd_a(i32(i)); }") != null);
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "workgroupBarrier();") != null);
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "for (var z_ : u32 = l; z_ < 256u; z_ = z_ + 256u) { w_t[z_] = 0.0; }") != null);
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "v_c[i] = sh_t(i32(255f - f32(l)));") != null);
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "_ = p.n;") != null);
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_compile(spec.ptr, @floatFromInt(spec.len)));
    var a: [512]f32 = undefined;
    for (&a, 0..) |*x, k| x.* = @floatFromInt(k);
    const ins = [_][*]const f32{&a};
    const lens = [_]f64{512};
    var out: [512]f32 = undefined;
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_eval(&ins, 1, &lens, &a, 0, 512, &out));
    try std.testing.expectEqual(@as(f32, 255), out[0]);
    try std.testing.expectEqual(@as(f32, 0), out[255]);
    try std.testing.expectEqual(@as(f32, 511), out[256]);
}

test "KP3: a reduce over a partial last group sums what is there and zero past the input" {
    const spec = "in a\nout c\nshared t 256\nstage { @t[@l] = @a }\nreduce t sum\nbody { @c = @t[0] }";
    var buf: [8192]u8 = undefined;
    const wl = stz_gpu_wgsl_elementwise(spec.ptr, @floatFromInt(spec.len), &buf, buf.len);
    try std.testing.expect(wl > 0);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(wl)], "for (var s_ : u32 = 128u; s_ > 0u; s_ = s_ / 2u) {") != null);
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_compile(spec.ptr, @floatFromInt(spec.len)));
    var a: [300]f32 = @splat(1);
    const ins = [_][*]const f32{&a};
    const lens = [_]f64{300};
    var out: [300]f32 = undefined;
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_eval(&ins, 1, &lens, &a, 0, 300, &out));
    try std.testing.expectEqual(@as(f32, 256), out[0]);
    try std.testing.expectEqual(@as(f32, 44), out[299]);
}

const MATMUL_SPEC =
    \\in a
    \\in b
    \\scalar k
    \\scalar w
    \\out c
    \\width w
    \\shared ta 256
    \\shared tb 256
    \\tiles t { k / 16 }
    \\stage { @ta[@ly * 16 + @lx] = @a[@row * k + t * 16 + @lx] }
    \\stage { @tb[@ly * 16 + @lx] = @b[(t * 16 + @ly) * w + @col] }
    \\accumulate { @acc = @acc + sum(j, 0, 16, @ta[@ly * 16 + j] * @tb[j * 16 + @lx]) }
    \\body { @c = @acc }
;

test "KP3: the tiled matmul through shared tiles equals the plain triple loop" {
    const spec = MATMUL_SPEC;
    var buf: [16384]u8 = undefined;
    const wl = stz_gpu_wgsl_elementwise(spec.ptr, @floatFromInt(spec.len), &buf, buf.len);
    if (wl < 0) {
        var e: [256]u8 = undefined;
        std.debug.print("refused: {s}\n", .{errText(&e)});
    }
    try std.testing.expect(wl > 0);
    const wgsl = buf[0..@intCast(wl)];
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "for (var t_t : i32 = 0; t_t < i32(p.s_k / 16f); t_t = t_t + 1) {") != null);
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "let i = row * u32(p.s_w) + col;") != null);
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "acc = acc + acc0;") != null);
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_compile(spec.ptr, @floatFromInt(spec.len)));
    const M = 32;
    const K = 48;
    const N = 32;
    var a: [M * K]f32 = undefined;
    var b: [K * N]f32 = undefined;
    for (&a, 0..) |*x, q| x.* = @floatFromInt((q * 7) % 13);
    for (&b, 0..) |*x, q| x.* = @floatFromInt((q * 5) % 11);
    const ins = [_][*]const f32{ &a, &b };
    const lens = [_]f64{ M * K, K * N };
    const sc = [_]f32{ K, N };
    var out: [M * N]f32 = undefined;
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_eval(&ins, 2, &lens, &sc, 2, M * N, &out));
    for (0..M) |r| {
        for (0..N) |c| {
            var s: f32 = 0;
            for (0..K) |q| s += a[r * K + q] * b[q * N + c];
            try std.testing.expectEqual(s, out[r * N + c]);
        }
    }
    // a width that does not tile the elements is said, not guessed
    var out2: [M * N]f32 = undefined;
    const sc2 = [_]f32{ K, 24 };
    try std.testing.expectEqual(@as(i32, -1), stz_gpu_spec_eval(&ins, 2, &lens, &sc2, 2, M * N, &out2));
    var e: [256]u8 = undefined;
    try std.testing.expect(std.mem.indexOf(u8, errText(&e), "not a multiple of 16") != null);
}

test "KP3: the refusals name the offender, and the two readers agree on them" {
    const Case = struct { spec: []const u8, says: []const u8 };
    const cases = [_]Case{
        .{ .spec = "in a\nout c\nshared t 256\nstage { @t[@l] = @t[@l + 1] }\nbody { @c = @t[0] }", .says = "cannot read the array it writes" },
        .{ .spec = "in a\nscalar k\nout c\nshared t 256\ntiles q { @i }\nstage { @t[@l] = @a }\nbody { @c = @t[0] }", .says = "same for every thread" },
        .{ .spec = "in a\nscalar k\nout c\nshared t 256\ntiles q { sum(j, 0, 2, k) }\nstage { @t[@l] = @a }\nbody { @c = @t[0] }", .says = "sum is not admitted in the tiles count" },
        .{ .spec = "in a\nout c\nbody { @c = @a + @row }", .says = "needs a width line" },
        .{ .spec = "in a\nout c\nshared t 256\nstage { @t[@l] = @a }\nbody { @c = @t }", .says = "read one slot" },
        .{ .spec = "in a\nout c\nshared t 300\nstage { @t[@l] = @a }\nreduce t sum\nbody { @c = @t[0] }", .says = "power of two" },
        .{ .spec = "in a\nout c\nshared t 256\naccumulate { @acc = @a }\nbody { @c = @acc }", .says = "inside a tiles loop" },
        .{ .spec = "in a\nout c\nshared t 2000\nbody { @c = @a }", .says = "holds 1 to 1024" },
        .{ .spec = "in a\nout c\nstage { @t[@l] = @a }\nbody { @c = @a }", .says = "not a shared array" },
        .{ .spec = "in a\nout c\nshared t 256\nreduce t mean\nbody { @c = @a }", .says = "sum, max and min" },
        .{ .spec = "in a\nout c\nbody { @c = @acc }", .says = "'@acc' is read" },
        .{ .spec = "in a\nscalar k\nout c\nshared t 16\ntiles q { k }\nstage { @t[@l] = @a }\nbody { @c = @a + q }", .says = "unknown name 'q'" },
        .{ .spec = "in a\nout c\nwidth 24\nbody { @c = @a }", .says = "not a multiple of 16" },
        .{ .spec = "in a\nout c\nwidth w\nbody { @c = @a }", .says = "declared scalar or a number" },
    };
    var buf: [16384]u8 = undefined;
    var e1: [256]u8 = undefined;
    var e2: [256]u8 = undefined;
    for (cases) |cs| {
        const t = stz_gpu_wgsl_elementwise(cs.spec.ptr, @floatFromInt(cs.spec.len), &buf, buf.len);
        const m1 = errText(&e1);
        const c = stz_gpu_spec_compile(cs.spec.ptr, @floatFromInt(cs.spec.len));
        const m2 = errText(&e2);
        if (t >= 0 or c == 0 or std.mem.indexOf(u8, m1, cs.says) == null or !std.mem.eql(u8, m1, m2))
            std.debug.print("case {s}\n  transpile {d} '{s}'\n  compile {d} '{s}'\n", .{ cs.spec, t, m1, c, m2 });
        try std.testing.expect(t < 0);
        try std.testing.expectEqual(@as(i32, -1), c);
        try std.testing.expect(std.mem.indexOf(u8, m1, cs.says) != null);
        try std.testing.expectEqualStrings(m1, m2);
    }
}

test "GK4: tanh means in the interpreter what it means in WGSL, and the transpiler emits it as itself" {
    const gelu = "in x\nout y\nbody { @y = 0.5 * @x * (1 + tanh(0.7978845608 * @x * (1 + 0.044715 * @x * @x))) }";
    var buf: [2048]u8 = undefined;
    const n = stz_gpu_wgsl_elementwise(gelu.ptr, @floatFromInt(gelu.len), &buf, buf.len);
    try std.testing.expect(n > 0);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "tanh(0.7978845608f * v_x[i]") != null);
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_compile(gelu.ptr, @floatFromInt(gelu.len)));
    const x = [_]f32{ -3, -0.5, 0, 0.5, 3 };
    const ins = [_][*]const f32{&x};
    const lens = [_]f64{5};
    var out: [5]f32 = undefined;
    try std.testing.expectEqual(@as(i32, 0), stz_gpu_spec_eval(&ins, 1, &lens, &x, 0, 5, &out));
    for (x, out) |xi, yi| {
        const want = 0.5 * xi * (1 + std.math.tanh(0.7978845608 * xi * (1 + 0.044715 * xi * xi)));
        try std.testing.expectApproxEqAbs(want, yi, 1e-6);
    }
}
