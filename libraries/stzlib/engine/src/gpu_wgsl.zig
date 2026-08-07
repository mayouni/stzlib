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

/// Transpile a spec into WGSL. Returns the WGSL length written into `out`
/// (capacity `cap`), or -1 with the reason available via stz_gpu_wgsl_error.
/// Pure text work: needs no device, works on a GPU-less machine.
pub fn stz_gpu_wgsl_elementwise(spec: [*]const u8, spec_len: f64, out: [*]u8, cap: f64) callconv(.c) i32 {
    const text = spec[0..@intFromFloat(spec_len)];
    err_len = 0;

    var ins: [MAX_VECS]Name = undefined;
    var n_ins: usize = 0;
    var scalars: [MAX_SCALARS]Name = undefined;
    var n_scalars: usize = 0;
    var out_name: Name = .{};
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
            if (n_ins == MAX_VECS - 1)
                return fail("too many inputs (max {d})", .{MAX_VECS - 1});
            ins[n_ins] = lowered;
            n_ins += 1;
        } else if (std.mem.startsWith(u8, line, "scalar ")) {
            const nm = std.mem.trim(u8, line[7..], " \t");
            var lowered: Name = .{};
            if (!lowerInto(&lowered, nm) or !validIdent(lowered.slice()))
                return fail("bad scalar name: '{s}'", .{nm});
            if (n_scalars == MAX_SCALARS)
                return fail("too many scalars (max {d})", .{MAX_SCALARS});
            scalars[n_scalars] = lowered;
            n_scalars += 1;
        } else if (std.mem.startsWith(u8, line, "out ")) {
            const nm = std.mem.trim(u8, line[4..], " \t");
            if (have_out) return fail("only one output (ForEachElement writes one vector)", .{});
            if (!lowerInto(&out_name, nm) or !validIdent(out_name.slice()))
                return fail("bad output name: '{s}'", .{nm});
            have_out = true;
        } else if (std.mem.startsWith(u8, line, "body ")) {
            body = std.mem.trim(u8, line[5..], " \t");
        } else {
            return fail("unknown spec line: '{s}'", .{line});
        }
    }
    if (!have_out) return fail("no output declared (ReturnsVector missing)", .{});
    if (n_ins == 0) return fail("no inputs declared (TakesVector missing)", .{});
    if (body.len == 0) return fail("no body (ForEachElement missing)", .{});
    if (nameIn(ins[0..], n_ins, out_name.slice()) != null)
        return fail("'{s}' is both input and output", .{out_name.slice()});

    // tolerate the W-string's outer braces: '{ @c = ... }'
    var b = body;
    if (b.len >= 2 and b[0] == '{' and b[b.len - 1] == '}')
        b = std.mem.trim(u8, b[1 .. b.len - 1], " \t");

    // ---- the single assignment: @out = rhs
    if (b.len == 0 or b[0] != '@')
        return fail("body must be '@{s} = expression'", .{out_name.slice()});
    const eq = std.mem.indexOfScalar(u8, b, '=') orelse
        return fail("body has no '='", .{});
    const lhs = std.mem.trim(u8, b[1..eq], " \t");
    var lhs_lower: Name = .{};
    if (!lowerInto(&lhs_lower, lhs) or !std.mem.eql(u8, lhs_lower.slice(), out_name.slice()))
        return fail("body assigns '@{s}' but the output is '@{s}'", .{ lhs, out_name.slice() });
    const rhs = std.mem.trim(u8, b[eq + 1 ..], " \t");
    if (rhs.len == 0) return fail("empty expression", .{});

    // ---- transpile the rhs token by token
    var expr_buf: [4096]u8 = undefined;
    var expr = Cursor{ .buf = &expr_buf };
    var i: usize = 0;
    while (i < rhs.len) {
        const ch = rhs[i];
        if (ch == '@') {
            // vector element reference
            var j = i + 1;
            while (j < rhs.len and (std.ascii.isAlphanumeric(rhs[j]) or rhs[j] == '_')) : (j += 1) {}
            var nm: Name = .{};
            if (j == i + 1 or !lowerInto(&nm, rhs[i + 1 .. j]))
                return fail("bad @name at '{s}'", .{rhs[i..@min(i + 8, rhs.len)]});
            if (nameIn(ins[0..], n_ins, nm.slice()) == null) {
                if (std.mem.eql(u8, nm.slice(), out_name.slice()))
                    return fail("the output '@{s}' cannot be read", .{nm.slice()})
                else
                    return fail("undeclared vector '@{s}'", .{nm.slice()});
            }
            expr.put("v_");
            expr.put(nm.slice());
            expr.put("[i]");
            i = j;
        } else if (std.ascii.isAlphabetic(ch) or ch == '_') {
            // scalar or whitelisted function
            var j = i;
            while (j < rhs.len and (std.ascii.isAlphanumeric(rhs[j]) or rhs[j] == '_')) : (j += 1) {}
            var nm: Name = .{};
            if (!lowerInto(&nm, rhs[i..j]))
                return fail("name too long at '{s}'", .{rhs[i..@min(i + 8, rhs.len)]});
            if (nameIn(scalars[0..], n_scalars, nm.slice()) != null) {
                expr.put("p.s_");
                expr.put(nm.slice());
            } else {
                var is_func = false;
                for (FUNC_WHITELIST) |f| {
                    if (std.mem.eql(u8, f, nm.slice())) {
                        is_func = true;
                        break;
                    }
                }
                if (!is_func)
                    return fail("unknown name '{s}' (not a declared scalar, not a whitelisted function)", .{nm.slice()});
                // a function name must actually be CALLED
                var k = j;
                while (k < rhs.len and (rhs[k] == ' ' or rhs[k] == '\t')) : (k += 1) {}
                if (k >= rhs.len or rhs[k] != '(')
                    return fail("function '{s}' needs '('", .{nm.slice()});
                expr.put(nm.slice());
            }
            i = j;
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
            return fail("character '{c}' is not part of the elementwise language", .{ch});
        }
    }

    if (expr.overflow) return fail("expression too long", .{});

    // ---- emit the kernel straight into the caller's buffer
    var w = Cursor{ .buf = out[0..@intFromFloat(cap)] };
    const put = struct {
        fn f(l: *Cursor, s: []const u8) void {
            l.put(s);
        }
    }.f;

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
    put(&w, "@compute @workgroup_size(256)\n");
    put(&w, "fn main(@builtin(global_invocation_id) gid : vec3<u32>) {\n");
    put(&w, "  let i = gid.x + tile.xoff * 256u;\n");
    put(&w, "  if (i < p.n) { v_");
    put(&w, out_name.slice());
    put(&w, "[i] = ");
    put(&w, expr.items());
    put(&w, "; }\n}\n");

    if (w.overflow) return fail("kernel too large for the output buffer", .{});
    return @intCast(w.len);
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
