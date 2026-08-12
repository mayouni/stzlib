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
                // vecN is spelled vecN<f32> in WGSL. The material language
                // keeps the friendly name and the transpiler adds the type.
                // Emitting the bare name produced WGSL that failed to
                // compile -- and the broken pipeline then PANICKED the
                // process at submit rather than being refused.
                if (std.mem.eql(u8, nm.slice(), "vec2") or
                    std.mem.eql(u8, nm.slice(), "vec3") or
                    std.mem.eql(u8, nm.slice(), "vec4"))
                {
                    expr.put(nm.slice());
                    expr.put("<f32>");
                    i = j;
                    continue;
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
