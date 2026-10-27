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
};

pub const Decl = struct {
    ins: [MAX_VECS]Name = undefined,
    n_ins: usize = 0,
    scalars: [MAX_SCALARS]Name = undefined,
    n_scalars: usize = 0,
    out_name: Name = .{},
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
    while (lines.next()) |raw| {
        const line = std.mem.trim(u8, raw, " \t\r");
        if (line.len == 0) continue;
        if (std.mem.startsWith(u8, line, "in ")) {
            const nm = std.mem.trim(u8, line[3..], " \t");
            var lowered: Name = .{};
            if (!lowerInto(&lowered, nm) or !validIdent(lowered.slice()))
                return fail("bad input name: '{s}'", .{nm});
            if (reservedName(lowered.slice())) |why| return fail("{s}", .{why});
            if (d.n_ins == MAX_VECS - 1)
                return fail("too many inputs (max {d})", .{MAX_VECS - 1});
            d.ins[d.n_ins] = lowered;
            d.n_ins += 1;
        } else if (std.mem.startsWith(u8, line, "scalar ")) {
            const nm = std.mem.trim(u8, line[7..], " \t");
            var lowered: Name = .{};
            if (!lowerInto(&lowered, nm) or !validIdent(lowered.slice()))
                return fail("bad scalar name: '{s}'", .{nm});
            if (reservedName(lowered.slice())) |why| return fail("{s}", .{why});
            if (d.n_scalars == MAX_SCALARS)
                return fail("too many scalars (max {d})", .{MAX_SCALARS});
            d.scalars[d.n_scalars] = lowered;
            d.n_scalars += 1;
        } else if (std.mem.startsWith(u8, line, "out ")) {
            const nm = std.mem.trim(u8, line[4..], " \t");
            if (have_out) return fail("only one output (ForEachElement writes one vector)", .{});
            if (!lowerInto(&d.out_name, nm) or !validIdent(d.out_name.slice()))
                return fail("bad output name: '{s}'", .{nm});
            if (reservedName(d.out_name.slice())) |why| return fail("{s}", .{why});
            have_out = true;
        } else if (std.mem.startsWith(u8, line, "body ")) {
            body = std.mem.trim(u8, line[5..], " \t");
        } else if (std.mem.startsWith(u8, line, "guard ")) {
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
            d.items[d.n_items] = .{ .kind = .stage, .shared = si, .index = index, .value = value };
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
            d.items[d.n_items] = .{ .kind = .reduce, .shared = si, .op = op };
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
            d.items[d.n_items] = .{ .kind = .accumulate, .value = value };
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
fn emitGroupKernel(w: *Cursor, d: *const Decl, rw: *const Rewriter, expr: []const u8, prelude: []const u8, guard: []const u8, guard_none: bool, guard_custom: bool, items: []const u8) i32 {
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
    for (0..d.n_ins) |s| {
        if (!rw.used_rd[s]) continue;
        w.put("fn rd_");
        w.put(d.ins[s].slice());
        w.put("(k : i32) -> f32 {\n  if (k < 0 || u32(k) >= arrayLength(&v_");
        w.put(d.ins[s].slice());
        w.put(")) { return 0.0; }\n  return v_");
        w.put(d.ins[s].slice());
        w.put("[u32(k)];\n}\n");
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
            w.put("  if (");
            w.put(guard);
            w.put(") {\n");
        } else w.put("  if (i < p.n) {\n");
    }
    w.put(prelude);
    w.put("    v_");
    w.put(d.out_name.slice());
    w.put("[i] = ");
    w.put(expr);
    w.put(";\n");
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
    if (rw.rewrite(rhs, &expr) < 0) return -1;
    if (expr.overflow or prelude.overflow) return fail("expression too long", .{});
    var guard_buf: [1024]u8 = undefined;
    var guard = Cursor{ .buf = &guard_buf };
    var guard_kind: enum { default, none, custom } = .default;
    if (d.guard) |g| {
        if (std.mem.eql(u8, g, "none")) {
            guard_kind = .none;
        } else {
            guard_kind = .custom;
            rw.compare = true;
            rw.loopvar = null;
            rw.where = .guard;
            if (rw.rewrite(g, &guard) < 0) return -1;
            rw.where = .body;
            rw.compare = false;
            if (guard.overflow) return fail("guard too long", .{});
        }
    }
    // ---- KP3: the schedule, rewritten item by item into one block of text
    var count_buf: [512]u8 = undefined;
    var count = Cursor{ .buf = &count_buf };
    if (d.tiles.len != 0) {
        rw.where = .count;
        if (rw.rewrite(d.tiles, &count) < 0) return -1;
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
                    if (rw.rewrite(it.index, &idx) < 0) return -1;
                    if (rw.rewrite(it.value, &val) < 0) return -1;
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
                    if (rw.rewrite(it.value, &val) < 0) return -1;
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
    if (kp3) return emitGroupKernel(&w, &d, &rw, expr.items(), prelude.items(), guard.items(), guard_kind == .none, guard_kind == .custom, items.items());

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
    for (0..n_ins) |s| {
        if (!rw.used_rd[s]) continue;
        put(&w, "fn rd_");
        put(&w, ins[s].slice());
        put(&w, "(k : i32) -> f32 {\n  if (k < 0 || u32(k) >= arrayLength(&v_");
        put(&w, ins[s].slice());
        put(&w, ")) { return 0.0; }\n  return v_");
        put(&w, ins[s].slice());
        put(&w, "[u32(k)];\n}\n");
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
        put(&w, "  if (i < p.n) { v_");
        put(&w, out_name.slice());
        put(&w, "[i] = ");
        put(&w, expr.items());
        put(&w, "; }\n}\n");
    } else {
        // a guard line is the learner's: the params uniform may go unread, and
        // a kernel that never reads p gets a layout without binding 1 (GK6's
        // crash). The phony assignment keeps p bound whatever the guard says.
        if (guard_kind != .default) put(&w, "  _ = p.n;\n");
        switch (guard_kind) {
            .default => put(&w, "  if (i < p.n) {\n"),
            .custom => {
                put(&w, "  if (");
                put(&w, guard.items());
                put(&w, ") {\n");
            },
            .none => {},
        }
        put(&w, prelude.items());
        put(&w, "    v_");
        put(&w, out_name.slice());
        put(&w, "[i] = ");
        put(&w, expr.items());
        put(&w, ";\n");
        if (guard_kind != .none) put(&w, "  }\n");
        put(&w, "}\n");
    }

    if (w.overflow) return fail("kernel too large for the output buffer", .{});
    return @intCast(w.len);
}

// ---------------------------------------------------------------- the rewriter (KP0)
// The body and the guard are rewritten by ONE routine, recursive so a sum's
// bounds and body, and a neighbour read's index, are the same language.
// What it admits beyond the GK0 grammar, each a KP0 admission:
//   @i                  the element index, as f32(i)
//   n                   the element count, as f32(p.n)
//   @a[expr]            a neighbour read: rd_a(i32(expr)), 0.0 out of range
//   sum(k, from, to, e) a bounded loop: a prelude accumulates e over k in
//                       [from, to) and the expression reads the accumulator;
//                       k is a bare name inside e; one sum may not nest in
//                       another (KP3's shared memory is the next step up)
//   < <= > >= == != and or    in the GUARD only; a body stays arithmetic
// KP3: where an expression stands decides what it may read. The transpiler and
// the interpreter refuse the same things with the same words.
pub const Where = enum { body, guard, stage, accumulate, count };
const MSG_COUNT = "the tiles count must be the same for every thread: scalars, n and numbers only";
const MSG_SUMCOUNT = "a sum is not admitted in the tiles count";
const MSG_ROWCOL = "'@{s}' needs a width line (a 2-D output in 16 x 16 tiles)";
const MSG_ACC = "'@acc' is read in the accumulate line and the body, once an accumulate line exists";
const MSG_SHNOIDX = "'@{s}' is a shared array: read one slot, as in '@{s}[@l]'";
const MSG_RACE = "a stage cannot read the array it writes ('@{s}'): the threads would race; stage into a second array";

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

    fn rewrite(self: *Rewriter, rhs: []const u8, expr: *Cursor) i32 {
        var i: usize = 0;
        while (i < rhs.len) {
            const ch = rhs[i];
            if (ch == '@') {
                var j = i + 1;
                while (j < rhs.len and (std.ascii.isAlphanumeric(rhs[j]) or rhs[j] == '_')) : (j += 1) {}
                var nm: Name = .{};
                if (j == i + 1 or !lowerInto(&nm, rhs[i + 1 .. j]))
                    return fail("bad @name at '{s}'", .{rhs[i..@min(i + 8, rhs.len)]});
                if (self.where == .count) return fail(MSG_COUNT, .{});
                if (std.mem.eql(u8, nm.slice(), "i")) {
                    expr.put("f32(i)");
                    i = j;
                    continue;
                }
                // KP3: the group's own names
                if (groupName(nm.slice())) |wg| {
                    if ((std.mem.eql(u8, nm.slice(), "row") or std.mem.eql(u8, nm.slice(), "col")) and self.d.width.len == 0)
                        return fail(MSG_ROWCOL, .{nm.slice()});
                    self.used_group = true;
                    expr.put(wg);
                    i = j;
                    continue;
                }
                if (std.mem.eql(u8, nm.slice(), "acc")) {
                    if (!self.d.has_acc or !(self.where == .accumulate or self.where == .body)) return fail(MSG_ACC, .{});
                    expr.put("acc");
                    i = j;
                    continue;
                }
                if (self.d.sharedIndex(nm.slice())) |si| {
                    var k2 = j;
                    while (k2 < rhs.len and (rhs[k2] == ' ' or rhs[k2] == '\t')) : (k2 += 1) {}
                    if (k2 >= rhs.len or rhs[k2] != '[') return fail(MSG_SHNOIDX, .{ nm.slice(), nm.slice() });
                    if (self.stage_target) |st| {
                        if (st == si) return fail(MSG_RACE, .{nm.slice()});
                    }
                    const close = matching(rhs, k2) orelse return fail("missing ']' after '@{s}['", .{nm.slice()});
                    var inner_buf: [1024]u8 = undefined;
                    var inner = Cursor{ .buf = &inner_buf };
                    const saved = self.compare;
                    self.compare = false;
                    if (self.rewrite(rhs[k2 + 1 .. close], &inner) < 0) return -1;
                    self.compare = saved;
                    if (inner.len == 0) return fail("empty index in '@{s}[]'", .{nm.slice()});
                    self.used_sh[si] = true;
                    self.used_group = true;
                    expr.put("sh_");
                    expr.put(nm.slice());
                    expr.put("(i32(");
                    expr.put(inner.items());
                    expr.put("))");
                    i = close + 1;
                    continue;
                }
                const idx = nameIn(self.d.ins[0..], self.d.n_ins, nm.slice()) orelse {
                    if (std.mem.eql(u8, nm.slice(), self.d.out_name.slice()))
                        return fail("the output '@{s}' cannot be read", .{nm.slice()});
                    return fail("undeclared vector '@{s}'", .{nm.slice()});
                };
                self.used_in[idx] = true;
                // a neighbour read?
                var k = j;
                while (k < rhs.len and (rhs[k] == ' ' or rhs[k] == '\t')) : (k += 1) {}
                if (k < rhs.len and rhs[k] == '[') {
                    const close = matching(rhs, k) orelse return fail("missing ']' after '@{s}['", .{nm.slice()});
                    var inner_buf: [1024]u8 = undefined;
                    var inner = Cursor{ .buf = &inner_buf };
                    const saved = self.compare;
                    self.compare = false;
                    if (self.rewrite(rhs[k + 1 .. close], &inner) < 0) return -1;
                    self.compare = saved;
                    if (inner.len == 0) return fail("empty index in '@{s}[]'", .{nm.slice()});
                    self.used_rd[idx] = true;
                    expr.put("rd_");
                    expr.put(nm.slice());
                    expr.put("(i32(");
                    expr.put(inner.items());
                    expr.put("))");
                    i = close + 1;
                    continue;
                }
                if (self.where == .stage or self.where == .accumulate) {
                    // KP3: a schedule item runs for EVERY thread of the group, the
                    // ones past the input included, so its own element is a bounded read
                    self.used_rd[idx] = true;
                    expr.put("rd_");
                    expr.put(nm.slice());
                    expr.put("(i32(i))");
                    i = j;
                    continue;
                }
                expr.put("v_");
                expr.put(nm.slice());
                expr.put("[i]");
                i = j;
            } else if (std.ascii.isAlphabetic(ch) or ch == '_') {
                var j = i;
                while (j < rhs.len and (std.ascii.isAlphanumeric(rhs[j]) or rhs[j] == '_')) : (j += 1) {}
                var nm: Name = .{};
                if (!lowerInto(&nm, rhs[i..j]))
                    return fail("name too long at '{s}'", .{rhs[i..@min(i + 8, rhs.len)]});
                const word = nm.slice();
                if (std.mem.eql(u8, word, "n")) {
                    expr.put("f32(p.n)");
                    i = j;
                    continue;
                }
                if (self.loopvar) |lv| {
                    if (std.mem.eql(u8, word, lv.slice())) {
                        expr.put("f32(k_");
                        expr.put(word);
                        expr.put(")");
                        i = j;
                        continue;
                    }
                }
                if (self.in_loop and self.d.tiles.len != 0 and std.mem.eql(u8, word, self.d.tilevar.slice())) {
                    expr.put("f32(t_");
                    expr.put(word);
                    expr.put(")");
                    i = j;
                    continue;
                }
                if (std.mem.eql(u8, word, "and") or std.mem.eql(u8, word, "or")) {
                    if (!self.compare) return fail("'{s}' belongs to the guard line, not to a body", .{word});
                    expr.put(if (word[0] == 'a') " && " else " || ");
                    i = j;
                    continue;
                }
                if (nameIn(self.d.scalars[0..], self.d.n_scalars, word) != null) {
                    expr.put("p.s_");
                    expr.put(word);
                    i = j;
                    continue;
                }
                if (std.mem.eql(u8, word, "sum")) {
                    if (self.where == .count) return fail(MSG_SUMCOUNT, .{});
                    if (self.loopvar != null) return fail("a sum inside a sum is not admitted (one level; shared memory is KP3's)", .{});
                    var k = j;
                    while (k < rhs.len and (rhs[k] == ' ' or rhs[k] == '\t')) : (k += 1) {}
                    if (k >= rhs.len or rhs[k] != '(') return fail("sum needs '(var, from, to, expression)'", .{});
                    const close = matching(rhs, k) orelse return fail("sum is missing ')'", .{});
                    // split the four arguments at top-level commas
                    var parts: [4][]const u8 = undefined;
                    var np: usize = 0;
                    var start = k + 1;
                    var depth: usize = 0;
                    var q = k + 1;
                    while (q <= close) : (q += 1) {
                        const c2 = rhs[q];
                        if (c2 == '(' or c2 == '[') depth += 1;
                        if ((c2 == ')' or c2 == ']') and q < close) depth -= 1;
                        if (q == close or (c2 == ',' and depth == 0)) {
                            if (np == 4) return fail("sum takes 4 arguments (var, from, to, expression)", .{});
                            parts[np] = std.mem.trim(u8, rhs[start..q], " \t");
                            np += 1;
                            start = q + 1;
                        }
                    }
                    if (np != 4) return fail("sum takes 4 arguments (var, from, to, expression), got {d}", .{np});
                    var lv: Name = .{};
                    if (!lowerInto(&lv, parts[0]) or !validIdent(lv.slice()))
                        return fail("sum's variable must be a name, got '{s}'", .{parts[0]});
                    if (reservedName(lv.slice()) != null or nameIn(self.d.ins[0..], self.d.n_ins, lv.slice()) != null or
                        nameIn(self.d.scalars[0..], self.d.n_scalars, lv.slice()) != null)
                        return fail("sum's variable '{s}' is already a name here", .{lv.slice()});
                    var from_buf: [512]u8 = undefined;
                    var to_buf: [512]u8 = undefined;
                    var body_buf: [2048]u8 = undefined;
                    var from = Cursor{ .buf = &from_buf };
                    var to = Cursor{ .buf = &to_buf };
                    var body = Cursor{ .buf = &body_buf };
                    const saved = self.compare;
                    self.compare = false;
                    if (self.rewrite(parts[1], &from) < 0) return -1;
                    if (self.rewrite(parts[2], &to) < 0) return -1;
                    self.loopvar = lv;
                    const r = self.rewrite(parts[3], &body);
                    self.loopvar = null;
                    self.compare = saved;
                    if (r < 0) return -1;
                    if (from.len == 0 or to.len == 0 or body.len == 0) return fail("sum's arguments cannot be empty", .{});
                    var num: [8]u8 = undefined;
                    const acc = std.fmt.bufPrint(&num, "acc{d}", .{self.nsum}) catch return -1;
                    self.nsum += 1;
                    self.prelude.put("    var ");
                    self.prelude.put(acc);
                    self.prelude.put(" : f32 = 0.0;\n    for (var k_");
                    self.prelude.put(lv.slice());
                    self.prelude.put(" : i32 = i32(");
                    self.prelude.put(from.items());
                    self.prelude.put("); k_");
                    self.prelude.put(lv.slice());
                    self.prelude.put(" < i32(");
                    self.prelude.put(to.items());
                    self.prelude.put("); k_");
                    self.prelude.put(lv.slice());
                    self.prelude.put(" = k_");
                    self.prelude.put(lv.slice());
                    self.prelude.put(" + 1) { ");
                    self.prelude.put(acc);
                    self.prelude.put(" = ");
                    self.prelude.put(acc);
                    self.prelude.put(" + (");
                    self.prelude.put(body.items());
                    self.prelude.put("); }\n");
                    expr.put(acc);
                    i = close + 1;
                    continue;
                }
                var is_func = false;
                for (FUNC_WHITELIST) |f| {
                    if (std.mem.eql(u8, f, word)) {
                        is_func = true;
                        break;
                    }
                }
                if (std.mem.eql(u8, word, "vec2") or std.mem.eql(u8, word, "vec3") or std.mem.eql(u8, word, "vec4")) {
                    expr.put(word);
                    expr.put("<f32>");
                    i = j;
                    continue;
                }
                if (!is_func)
                    return fail("unknown name '{s}' (not a declared scalar, not a whitelisted function)", .{word});
                var k = j;
                while (k < rhs.len and (rhs[k] == ' ' or rhs[k] == '\t')) : (k += 1) {}
                if (k >= rhs.len or rhs[k] != '(')
                    return fail("function '{s}' needs '('", .{word});
                expr.put(word);
                i = j;
            } else if (std.ascii.isDigit(ch) or ch == '.') {
                var j = i;
                while (j < rhs.len and (std.ascii.isDigit(rhs[j]) or rhs[j] == '.')) : (j += 1) {}
                expr.put(rhs[i..j]);
                i = j;
            } else if (ch == '<' or ch == '>' or ch == '=' or ch == '!') {
                if (!self.compare) return fail("'{c}' is a comparison; comparisons belong to the guard line", .{ch});
                const two = i + 1 < rhs.len and rhs[i + 1] == '=';
                if (ch == '=' and !two) return fail("use '==' to compare in a guard", .{});
                if (ch == '!' and !two) return fail("'!' alone is not admitted; use '!='", .{});
                expr.put(rhs[i .. i + (if (two) @as(usize, 2) else 1)]);
                i += if (two) 2 else 1;
            } else if (ch == '+' or ch == '-' or ch == '*' or ch == '/' or ch == '%' or
                ch == '(' or ch == ')' or ch == ',' or ch == ' ' or ch == '\t')
            {
                expr.putc(ch);
                i += 1;
            } else if (ch == '[' or ch == ']') {
                return fail("'[' follows a vector name only (@a[...])", .{});
            } else {
                return fail("character '{c}' is not part of the elementwise language", .{ch});
            }
        }
        return 0;
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
};
const VECTOR_ONLY = [_][]const u8{ "dot", "cross", "normalize", "reflect", "vec2", "vec3", "vec4" };

pub const MAX_OPS = 512;
pub const MAX_CONSTS = 128;
const MAX_DEPTH = 32;
const STACK = 64;
const MAX_SUMS = 4;

pub const Program = struct {
    ops: [MAX_OPS]Op = undefined,
    args: [MAX_OPS]u16 = undefined,
    n: usize = 0,
    consts: [MAX_CONSTS]f32 = undefined,
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
};
var g_kp3: Kp3 = .{};
var g_item_idx: [MAX_ITEMS]Program = undefined;
var g_item_val: [MAX_ITEMS]Program = undefined;
var g_count: Program = .{};
var g_sh: [MAX_SHARED][MAX_SHARED_SIZE]f32 = undefined;
var g_acc: [GROUP]f32 = undefined;
var g_tmp_ix: [GROUP]f32 = undefined;
var g_tmp_v: [GROUP]f32 = undefined;

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

fn compileInto(p: *Program, text: []const u8, d: *const Decl, where: Where, in_loop: bool, stage_target: ?usize) i32 {
    p.* = .{};
    var ps = Parser{ .s = text, .d = d, .p = p, .where = where, .in_loop = in_loop, .stage_target = stage_target };
    if (ps.expr() < 0) return -1;
    if (ps.peek() != 0) {
        const c = ps.peek();
        if (c == '<' or c == '>' or c == '=' or c == '!') return fail("'{c}' is a comparison; comparisons belong to the guard line", .{c});
        return fail("unexpected '{c}' after the expression", .{c});
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

    // guard := andexpr ('or' andexpr)*   -- KP0, compare mode only
    fn orexpr(self: *Parser) i32 {
        if (self.andexpr() < 0) return -1;
        while (self.word("or")) {
            if (self.andexpr() < 0) return -1;
            if (self.emit(.l_or, 0) < 0) return -1;
            self.p.flops += 1;
        }
        return 0;
    }
    fn andexpr(self: *Parser) i32 {
        if (self.cmp() < 0) return -1;
        while (self.word("and")) {
            if (self.cmp() < 0) return -1;
            if (self.emit(.l_and, 0) < 0) return -1;
            self.p.flops += 1;
        }
        return 0;
    }
    fn cmp(self: *Parser) i32 {
        if (self.expr() < 0) return -1;
        const c = self.peek();
        if (c == '<' or c == '>' or c == '=' or c == '!') {
            const two = self.i + 1 < self.s.len and self.s[self.i + 1] == '=';
            if (c == '=' and !two) return fail("use '==' to compare in a guard", .{});
            if (c == '!' and !two) return fail("'!' alone is not admitted; use '!='", .{});
            const op: Op = if (c == '<') (if (two) .c_le else .c_lt) else if (c == '>') (if (two) .c_ge else .c_gt) else if (c == '=') .c_eq else .c_ne;
            self.i += if (two) 2 else 1;
            if (self.expr() < 0) return -1;
            if (self.emit(op, 0) < 0) return -1;
            self.p.flops += 1;
        }
        return 0;
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
    fn emit(self: *Parser, op: Op, arg: u16) i32 {
        if (!self.p.emit(op, arg)) return fail("expression too long (over {d} operations)", .{MAX_OPS});
        return 0;
    }

    // expr := term (('+' | '-') term)*
    fn expr(self: *Parser) i32 {
        if (self.depth >= MAX_DEPTH) return fail("expression nested too deep", .{});
        self.depth += 1;
        defer self.depth -= 1;
        if (self.term() < 0) return -1;
        while (true) {
            const c = self.peek();
            if (c == '+' or c == '-') {
                self.i += 1;
                if (self.term() < 0) return -1;
                if (self.emit(if (c == '+') .add else .sub, 0) < 0) return -1;
                self.p.flops += 1;
            } else break;
        }
        return 0;
    }
    // term := unary (('*' | '/' | '%') unary)*
    fn term(self: *Parser) i32 {
        if (self.unary() < 0) return -1;
        while (true) {
            const c = self.peek();
            if (c == '*' or c == '/' or c == '%') {
                self.i += 1;
                if (self.unary() < 0) return -1;
                if (self.emit(if (c == '*') .mul else if (c == '/') .div else .mod, 0) < 0) return -1;
                self.p.flops += 1;
            } else break;
        }
        return 0;
    }
    // unary := '-' unary | primary
    fn unary(self: *Parser) i32 {
        if (self.peek() == '-') {
            self.i += 1;
            if (self.unary() < 0) return -1;
            if (self.emit(.neg, 0) < 0) return -1;
            self.p.flops += 1;
            return 0;
        }
        if (self.peek() == '+') {
            self.i += 1;
            return self.unary();
        }
        return self.primary();
    }
    // primary := number | '@' name | name '(' args ')' | scalar | '(' expr ')'
    fn primary(self: *Parser) i32 {
        const c = self.peek();
        if (c == 0) return fail("expression ends where a value was expected", .{});
        if (c == '(') {
            self.i += 1;
            if (self.expr() < 0) return -1;
            if (self.peek() != ')') return fail("missing ')'", .{});
            self.i += 1;
            return 0;
        }
        if (std.ascii.isDigit(c) or c == '.') {
            var j = self.i;
            while (j < self.s.len and (std.ascii.isDigit(self.s[j]) or self.s[j] == '.')) : (j += 1) {}
            const v = std.fmt.parseFloat(f32, self.s[self.i..j]) catch
                return fail("bad number '{s}'", .{self.s[self.i..j]});
            if (self.p.n_consts >= MAX_CONSTS) return fail("too many numbers in the expression", .{});
            self.p.consts[self.p.n_consts] = v;
            const r = self.emit(.k_const, @intCast(self.p.n_consts));
            self.p.n_consts += 1;
            self.i = j;
            return r;
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
                return self.emit(.k_index, 0);
            }
            // KP3: the group's own names, the accumulator, a shared slot
            if (groupName(nm.slice()) != null) {
                const s = nm.slice();
                if ((std.mem.eql(u8, s, "row") or std.mem.eql(u8, s, "col")) and self.d.width.len == 0)
                    return fail(MSG_ROWCOL, .{s});
                self.used_group = true;
                self.i = j;
                const op: Op = if (std.mem.eql(u8, s, "l")) .k_local else if (std.mem.eql(u8, s, "g")) .k_group else if (std.mem.eql(u8, s, "lx")) .k_lx else if (std.mem.eql(u8, s, "ly")) .k_ly else if (std.mem.eql(u8, s, "row")) .k_row else .k_col;
                return self.emit(op, 0);
            }
            if (std.mem.eql(u8, nm.slice(), "acc")) {
                if (!self.d.has_acc or !(self.where == .accumulate or self.where == .body)) return fail(MSG_ACC, .{});
                self.i = j;
                return self.emit(.k_acc, 0);
            }
            if (self.d.sharedIndex(nm.slice())) |si| {
                self.i = j;
                if (self.peek() != '[') return fail(MSG_SHNOIDX, .{ nm.slice(), nm.slice() });
                if (self.stage_target) |st| {
                    if (st == si) return fail(MSG_RACE, .{nm.slice()});
                }
                self.i += 1;
                const saved = self.compare;
                self.compare = false;
                const r = self.expr();
                self.compare = saved;
                if (r < 0) return -1;
                if (self.peek() != ']') return fail("missing ']' after '@{s}['", .{nm.slice()});
                self.i += 1;
                self.used_group = true;
                self.p.flops += 1;
                return self.emit(.sh_rd, @intCast(si));
            }
            const idx = nameIn(self.d.ins[0..], self.d.n_ins, nm.slice()) orelse {
                if (std.mem.eql(u8, nm.slice(), self.d.out_name.slice()))
                    return fail("the output '@{s}' cannot be read", .{nm.slice()});
                return fail("undeclared vector '@{s}'", .{nm.slice()});
            };
            self.i = j;
            if (self.peek() != '[' and (self.where == .stage or self.where == .accumulate)) {
                // a schedule item's own element is a bounded read, as the kernel's rd_ is
                if (self.emit(.k_index, 0) < 0) return -1;
                self.p.flops += 1;
                return self.emit(.rd, @intCast(idx));
            }
            if (self.peek() == '[') {
                // a neighbour read: the index expression, then rd
                self.i += 1;
                const saved = self.compare;
                self.compare = false;
                const r = self.expr();
                self.compare = saved;
                if (r < 0) return -1;
                if (self.peek() != ']') return fail("missing ']' after '@{s}['", .{nm.slice()});
                self.i += 1;
                self.p.flops += 1;
                return self.emit(.rd, @intCast(idx));
            }
            return self.emit(.k_in, @intCast(idx));
        }
        if (std.ascii.isAlphabetic(c) or c == '_') {
            var j = self.i;
            while (j < self.s.len and (std.ascii.isAlphanumeric(self.s[j]) or self.s[j] == '_')) : (j += 1) {}
            var nm: Name = .{};
            if (!lowerInto(&nm, self.s[self.i..j]))
                return fail("name too long at '{s}'", .{self.s[self.i..@min(self.i + 8, self.s.len)]});
            self.i = j;
            if (std.mem.eql(u8, nm.slice(), "n")) return self.emit(.k_n, 0);
            if (self.loopvar) |lv| {
                if (std.mem.eql(u8, nm.slice(), lv.slice())) return self.emit(.k_var, @intCast(self.p.nsum - 1));
            }
            if (self.in_loop and self.d.tiles.len != 0 and std.mem.eql(u8, nm.slice(), self.d.tilevar.slice()))
                return self.emit(.k_tile, 0);
            if (std.mem.eql(u8, nm.slice(), "and") or std.mem.eql(u8, nm.slice(), "or"))
                return fail("'{s}' belongs to the guard line, not to a body", .{nm.slice()});
            if (nameIn(self.d.scalars[0..], self.d.n_scalars, nm.slice())) |si| {
                return self.emit(.k_scalar, @intCast(si));
            }
            if (std.mem.eql(u8, nm.slice(), "sum")) {
                if (self.where == .count) return fail(MSG_SUMCOUNT, .{});
                if (self.loopvar != null) return fail("a sum inside a sum is not admitted (one level; shared memory is KP3's)", .{});
                if (self.p.nsum >= MAX_SUMS) return fail("too many sums (max {d})", .{MAX_SUMS});
                if (self.peek() != '(') return fail("sum needs '(var, from, to, expression)'", .{});
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
                self.compare = false;
                if (self.expr() < 0) return -1; // from
                if (self.peek() != ',') return fail("sum takes 4 arguments (var, from, to, expression)", .{});
                self.i += 1;
                if (self.expr() < 0) return -1; // to
                if (self.peek() != ',') return fail("sum takes 4 arguments (var, from, to, expression)", .{});
                self.i += 1;
                const slot = self.p.nsum;
                self.p.sumvar[slot] = lv;
                self.p.nsum += 1;
                const begin = self.p.n;
                if (self.emit(.sum_begin, @intCast(slot)) < 0) return -1;
                self.loopvar = lv;
                const r = self.expr();
                self.loopvar = null;
                self.compare = saved;
                if (r < 0) return -1;
                if (self.peek() != ')') return fail("sum is missing ')'", .{});
                self.i += 1;
                self.p.jump[begin] = @intCast(self.p.n);
                self.p.jump[self.p.n] = @intCast(begin);
                self.p.flops += 1;
                return self.emit(.sum_end, @intCast(slot));
            }
            for (VECTOR_ONLY) |v| {
                if (std.mem.eql(u8, v, nm.slice()))
                    return fail("'{s}' works on vectors; an elementwise kernel has none", .{nm.slice()});
            }
            var fun: ?Fn = null;
            for (FUNCS) |f| {
                if (std.mem.eql(u8, f.name, nm.slice())) fun = f;
            }
            const f = fun orelse return fail("unknown name '{s}' (not a declared scalar, not a whitelisted function)", .{nm.slice()});
            if (self.peek() != '(') return fail("function '{s}' needs '('", .{f.name});
            self.i += 1;
            var argc: u8 = 0;
            if (self.peek() != ')') {
                while (true) {
                    if (self.expr() < 0) return -1;
                    argc += 1;
                    if (self.peek() == ',') {
                        self.i += 1;
                        continue;
                    }
                    break;
                }
            }
            if (self.peek() != ')') return fail("function '{s}' is missing ')'", .{f.name});
            self.i += 1;
            if (argc != f.arity) return fail("function '{s}' takes {d} argument(s), got {d}", .{ f.name, f.arity, argc });
            self.p.flops += 1;
            return self.emit(f.op, 0);
        }
        return fail("character '{c}' is not part of the elementwise language", .{c});
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
        const r = compileInto(&g_prog, d.rhs, &d, .body, false, null);
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
            var pg = Parser{ .s = g, .d = &d, .p = &g_guard, .compare = true, .where = .guard };
            if (pg.orexpr() < 0) return -1;
            if (pg.peek() != 0) return fail("unexpected '{c}' after the guard", .{pg.peek()});
            if (pg.used_group) used_group = true;
            g_guard.ready = true;
        }
    }
    // KP3: the schedule, the tiles count, the width
    if (d.tiles.len != 0) {
        if (compileInto(&g_count, d.tiles, &d, .count, false, null) < 0) return -1;
    }
    for (0..d.n_items) |k| {
        const it = d.items[k];
        const inside = d.loop_from != null and k >= d.loop_from.?;
        g_kp3.kinds[k] = it.kind;
        g_kp3.shared_of[k] = it.shared;
        g_kp3.ops[k] = it.op;
        switch (it.kind) {
            .stage => {
                if (compileInto(&g_item_idx[k], it.index, &d, .stage, inside, it.shared) < 0) return -1;
                if (compileInto(&g_item_val[k], it.value, &d, .stage, inside, it.shared) < 0) return -1;
                g_prog.flops += g_item_idx[k].flops + g_item_val[k].flops;
            },
            .accumulate => {
                if (compileInto(&g_item_val[k], it.value, &d, .accumulate, inside, null) < 0) return -1;
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
    g_prog.ready = true;
    return 0;
}

/// KP0: the operations the last stz_gpu_spec_eval executed, loops included --
/// the FLOP count the checker's compute ceiling reads for a spec.
pub fn stz_gpu_spec_eval_flops() callconv(.c) f64 {
    return g_eval_flops;
}

/// Operations per element of the compiled spec (0 if none is compiled).
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

const Frame = struct { v: f32 = 0, to: f32 = 0, acc: f32 = 0 };

/// Run one program over element `i`. Returns the value, or null on a stack fault.
fn runProgram(p: *const Program, th: *const Thread, ins: [*]const [*]const f32, lens: [*]const f64, scalars: [*]const f32, ops_out: *f64) ?f32 {
    const i = th.i;
    const n = th.n;
    var st: [STACK]f32 = undefined;
    var sp: usize = 0;
    var frames: [MAX_SUMS]Frame = undefined;
    var ops: f64 = 0;
    var k: usize = 0;
    while (k < p.n) {
        var next = k + 1;
        switch (p.ops[k]) {
            .k_const => {
                if (sp >= STACK) return null;
                st[sp] = p.consts[p.args[k]];
                sp += 1;
            },
            .k_in => {
                if (sp >= STACK) return null;
                st[sp] = ins[p.args[k]][i];
                sp += 1;
            },
            .k_scalar => {
                if (sp >= STACK) return null;
                st[sp] = scalars[p.args[k]];
                sp += 1;
            },
            .k_index => {
                if (sp >= STACK) return null;
                st[sp] = @floatFromInt(i);
                sp += 1;
            },
            .k_n => {
                if (sp >= STACK) return null;
                st[sp] = @floatFromInt(n);
                sp += 1;
            },
            .k_var => {
                if (sp >= STACK) return null;
                st[sp] = frames[p.args[k]].v;
                sp += 1;
            },
            .k_local, .k_group, .k_lx, .k_ly, .k_row, .k_col, .k_acc, .k_tile => {
                if (sp >= STACK) return null;
                st[sp] = switch (p.ops[k]) {
                    .k_local => @floatFromInt(th.l),
                    .k_group => @floatFromInt(th.g),
                    .k_lx => @floatFromInt(th.l % TILE),
                    .k_ly => @floatFromInt(th.l / TILE),
                    .k_row => @floatFromInt(th.row),
                    .k_col => @floatFromInt(th.col),
                    .k_acc => th.acc,
                    .k_tile => th.tile,
                    else => unreachable,
                };
                sp += 1;
            },
            .sh_rd => {
                if (sp < 1) return null;
                const which = p.args[k];
                st[sp - 1] = if (toIndex(st[sp - 1])) |ix| (if (ix < g_kp3.sizes[which]) g_sh[which][ix] else 0.0) else 0.0;
                ops += 1;
            },
            .rd => {
                if (sp < 1) return null;
                const which = p.args[k];
                const len: usize = @intFromFloat(lens[which]);
                st[sp - 1] = if (toIndex(st[sp - 1])) |ix| (if (ix < len) ins[which][ix] else 0.0) else 0.0;
                ops += 1;
            },
            .sum_begin => {
                if (sp < 2) return null;
                const slot = p.args[k];
                frames[slot] = .{ .v = @trunc(st[sp - 2]), .to = @trunc(st[sp - 1]), .acc = 0 };
                sp -= 2;
                if (!(frames[slot].v < frames[slot].to)) {
                    // an empty range: the sum is 0, skip to after sum_end
                    if (sp >= STACK) return null;
                    st[sp] = 0;
                    sp += 1;
                    next = @as(usize, p.jump[k]) + 1;
                }
            },
            .sum_end => {
                if (sp < 1) return null;
                const slot = p.args[k];
                frames[slot].acc += st[sp - 1];
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
            .neg => {
                if (sp < 1) return null;
                st[sp - 1] = -st[sp - 1];
                ops += 1;
            },
            .add, .sub, .mul, .div, .mod, .f_min, .f_max, .f_pow, .f_step, .f_atan2, .f_distance, .c_lt, .c_le, .c_gt, .c_ge, .c_eq, .c_ne, .l_and, .l_or => {
                if (sp < 2) return null;
                const a2 = st[sp - 2];
                const b2 = st[sp - 1];
                st[sp - 2] = switch (p.ops[k]) {
                    .add => a2 + b2,
                    .sub => a2 - b2,
                    .mul => a2 * b2,
                    .div => a2 / b2,
                    .mod => wgslMod(a2, b2),
                    .f_min => @min(a2, b2),
                    .f_max => @max(a2, b2),
                    .f_pow => std.math.pow(f32, a2, b2),
                    .f_step => if (b2 < a2) 0.0 else 1.0,
                    .f_atan2 => std.math.atan2(a2, b2),
                    .f_distance => @abs(a2 - b2),
                    .c_lt => if (a2 < b2) 1.0 else 0.0,
                    .c_le => if (a2 <= b2) 1.0 else 0.0,
                    .c_gt => if (a2 > b2) 1.0 else 0.0,
                    .c_ge => if (a2 >= b2) 1.0 else 0.0,
                    .c_eq => if (a2 == b2) 1.0 else 0.0,
                    .c_ne => if (a2 != b2) 1.0 else 0.0,
                    .l_and => if (a2 != 0 and b2 != 0) 1.0 else 0.0,
                    .l_or => if (a2 != 0 or b2 != 0) 1.0 else 0.0,
                    else => unreachable,
                };
                sp -= 1;
                ops += 1;
            },
            .f_clamp, .f_mix, .f_smoothstep => {
                if (sp < 3) return null;
                const x = st[sp - 3];
                const y = st[sp - 2];
                const z = st[sp - 1];
                st[sp - 3] = switch (p.ops[k]) {
                    .f_clamp => @min(@max(x, y), z),
                    .f_mix => x * (1.0 - z) + y * z,
                    .f_smoothstep => blk: {
                        const t = @min(@max((z - x) / (y - x), 0.0), 1.0);
                        break :blk t * t * (3.0 - 2.0 * t);
                    },
                    else => unreachable,
                };
                sp -= 2;
                ops += 1;
            },
            else => {
                if (sp < 1) return null;
                const x = st[sp - 1];
                st[sp - 1] = switch (p.ops[k]) {
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
                    else => unreachable,
                };
                ops += 1;
            },
        }
        k = next;
    }
    if (sp != 1) return null;
    ops_out.* += ops;
    return st[0];
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
            const g = runProgram(&g_guard, &t, ins, lens, scalars, &g_eval_flops) orelse return -1;
            if (g == 0) {
                out[i] = std.math.nan(f32);
                if (mask) |m| m[i] = 0;
                continue;
            }
        }
        out[i] = runProgram(&g_prog, &t, ins, lens, scalars, &g_eval_flops) orelse return -1;
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
            for (0..GROUP) |l| {
                var t = threadAt(g, l, n, width);
                t.acc = g_acc[l];
                t.tile = tile;
                g_tmp_ix[l] = runProgram(&g_item_idx[k], &t, ins, lens, scalars, &g_eval_flops) orelse return false;
                g_tmp_v[l] = runProgram(&g_item_val[k], &t, ins, lens, scalars, &g_eval_flops) orelse return false;
            }
            const s = g_kp3.shared_of[k];
            for (0..GROUP) |l| {
                if (toIndex(g_tmp_ix[l])) |ix| {
                    if (ix < g_kp3.sizes[s]) g_sh[s][ix] = g_tmp_v[l];
                }
            }
        },
        .reduce => {
            const s = g_kp3.shared_of[k];
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
            for (0..GROUP) |l| {
                var t = threadAt(g, l, n, width);
                t.acc = g_acc[l];
                t.tile = tile;
                g_tmp_v[l] = runProgram(&g_item_val[k], &t, ins, lens, scalars, &g_eval_flops) orelse return false;
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
        @memset(&g_acc, 0);
        for (0..g_kp3.loop_from) |k| {
            if (!runItem(k, g, n, width, 0, ins, lens, scalars)) return -1;
        }
        if (g_kp3.has_tiles) {
            const t0 = Thread{ .i = 0, .n = n };
            const cf = runProgram(&g_count, &t0, ins, lens, scalars, &g_eval_flops) orelse return -1;
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
                const gv = runProgram(&g_guard, &t, ins, lens, scalars, &g_eval_flops) orelse return -1;
                if (gv == 0) {
                    out[t.i] = std.math.nan(f32);
                    if (mask) |m| m[t.i] = 0;
                    continue;
                }
            }
            out[t.i] = runProgram(&g_prog, &t, ins, lens, scalars, &g_eval_flops) orelse return -1;
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
        \\  if (i < p.n) { v_y[i] = clamp(sqrt(abs(v_x[i])) * p.s_k - p.s_b, 0.0, 10.5) % 3 + round(v_x[i] / 2); }
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
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "if (f32(i) < f32(p.n) - 2) {") != null);
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
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "rd_a(i32(f32(i) - 1)) + v_a[i] + rd_a(i32(f32(i) + 1))") != null);
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
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "for (var k_k : i32 = i32(0); k_k < i32(4); k_k = k_k + 1) { acc0 = acc0 + (rd_a(i32(f32(i) * 4 + f32(k_k)))); }") != null);
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
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "  if (i < p.n) { v_c[i] = v_a[i] * 2; }\n}\n") != null);
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
    // the interpreter refuses more than the transpiler in exactly one place: a
    // vector-only name, which the transpiler passes to WGSL to fail there
    const vec = "in a\nin b\nout c\nbody { @c = dot(@a, @b) }";
    try std.testing.expect(stz_gpu_wgsl_elementwise(vec.ptr, @floatFromInt(vec.len), &buf, buf.len) >= 0);
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
                for (FUNC_WHITELIST) |f| {
                    if (std.mem.eql(u8, f, nm.slice())) {
                        is_func = true;
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
                expr.put(nm.slice());
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
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "return m.c_base * (1.0 + m.s_glow * f_normal.y);") != null);
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
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "v_c[i] = sh_t(i32(255 - f32(l)));") != null);
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
    try std.testing.expect(std.mem.indexOf(u8, wgsl, "for (var t_t : i32 = 0; t_t < i32(p.s_k / 16); t_t = t_t + 1) {") != null);
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
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "tanh(0.7978845608 * v_x[i]") != null);
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
