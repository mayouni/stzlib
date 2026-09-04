//! Reverse-mode automatic differentiation over a scalar expression.
//!
//! PHASE 6 SLICE 1. This is the piece the numeric plan calls "the multiplier": with
//! gradients of an arbitrary expression, L-BFGS is a few hundred lines and a caller
//! can hand the library an objective it has never seen.
//!
//! WHY NOT `expr.zig`, WHICH ALREADY COMPILES EXPRESSIONS. Two definitions of one
//! thing is this project's most repeated defect, so reusing it was the first thing
//! checked -- and it is the wrong tool, not merely an awkward one. `expr.zig` is a
//! PREDICATE DSL for filtering lists: its variable is "the current item"
//! (`load_item`, `load_index`, `load_accum`), and its function set is
//! `is_vowel`, `is_arabic`, `startswith`, `replace`. It has no `exp`, no `log`, no
//! `sin`, no `pow` -- none of the functions an objective is written with -- and no
//! named variables at all. Bending it into a numeric language would have meant
//! adding all of that, plus a variable model, plus a rule for refusing the
//! non-differentiable four fifths of it. The INFIX SYNTAX IS DELIBERATELY THE SAME
//! (same operators, same precedence, same call form), so nobody is learning a second
//! language; what differs is the domain, and the domain is the whole point.
//!
//! HOW REVERSE MODE WORKS, in one paragraph, because the code is short enough that
//! the idea is the hard part. The expression compiles to a flat list of nodes in
//! evaluation order, each naming its operands by index -- a tape. A forward pass
//! fills `val[i]` for every node. Then a reverse pass walks the SAME list backwards
//! carrying an adjoint `adj[i]` = d(result)/d(node i), seeded with adj[last] = 1, and
//! each node pushes its adjoint onto its operands by the chain rule. One forward and
//! one backward pass yield the derivative with respect to EVERY variable at once --
//! which is why it beats finite differences, where n variables cost n+1 evaluations
//! and every one of them is approximate.

const std = @import("std");
const ascii = @import("ascii.zig");

// 256, raised from 64 on 2026-09-04 for the mathematical-diagram domain
// (DN7). A constraint layout spends three unknowns per circle and two per
// label, so 64 was a cliff at about twelve labelled sets -- Penrose's own
// seven-set example already uses 21. The bridge's name buffer is a stack
// array of this size (256 slices, 4 KB), which is why it is not larger.
pub const MAX_VARS = 256;

pub const OpCode = enum(u8) {
    constant,
    variable,
    add,
    sub,
    mul,
    div,
    neg,
    pow,
    exp,
    log,
    sqrt,
    sin,
    cos,
    tan,
    tanh,
    abs,
    min,
    max,
};

pub const Node = struct {
    op: OpCode,
    /// constant: the value. variable: unused.
    k: f64 = 0,
    /// variable: which one. otherwise: operand node indices (b unused for unary).
    a: u32 = 0,
    b: u32 = 0,
};

pub const Program = struct {
    nodes: std.ArrayList(Node),
    n_vars: usize,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Program) void {
        self.nodes.deinit(self.allocator);
        self.allocator.destroy(self);
    }
};

pub const ParseError = error{
    UnexpectedCharacter,
    UnexpectedEnd,
    UnknownName,
    UnknownFunction,
    BadArity,
    MissingParen,
    TooManyVars,
    OutOfMemory,
    Empty,
};

// ─── parser ──────────────────────────────────────────────────────────────────

const Parser = struct {
    src: []const u8,
    pos: usize,
    names: []const []const u8,
    prog: *Program,
    alloc: std.mem.Allocator,

    fn skipSpace(self: *Parser) void {
        while (self.pos < self.src.len and (self.src[self.pos] == ' ' or
            self.src[self.pos] == '\t' or self.src[self.pos] == '\n' or
            self.src[self.pos] == '\r')) self.pos += 1;
    }

    fn peek(self: *Parser) ?u8 {
        self.skipSpace();
        if (self.pos >= self.src.len) return null;
        return self.src[self.pos];
    }

    fn emit(self: *Parser, n: Node) ParseError!u32 {
        try self.prog.nodes.append(self.alloc, n);
        return @intCast(self.prog.nodes.items.len - 1);
    }

    /// expression := term (('+' | '-') term)*
    fn parseExpr(self: *Parser) ParseError!u32 {
        var lhs = try self.parseTerm();
        while (self.peek()) |c| {
            if (c != '+' and c != '-') break;
            self.pos += 1;
            const rhs = try self.parseTerm();
            lhs = try self.emit(.{ .op = if (c == '+') .add else .sub, .a = lhs, .b = rhs });
        }
        return lhs;
    }

    /// term := unary (('*' | '/') unary)*
    fn parseTerm(self: *Parser) ParseError!u32 {
        var lhs = try self.parseUnary();
        while (self.peek()) |c| {
            if (c != '*' and c != '/') break;
            self.pos += 1;
            const rhs = try self.parseUnary();
            lhs = try self.emit(.{ .op = if (c == '*') .mul else .div, .a = lhs, .b = rhs });
        }
        return lhs;
    }

    /// unary := '-' unary | power
    fn parseUnary(self: *Parser) ParseError!u32 {
        if (self.peek()) |c| {
            if (c == '-') {
                self.pos += 1;
                const inner = try self.parseUnary();
                return try self.emit(.{ .op = .neg, .a = inner });
            }
            if (c == '+') {
                self.pos += 1;
                return try self.parseUnary();
            }
        }
        return try self.parsePower();
    }

    /// power := primary ('^' unary)?   -- right associative, and the exponent may
    /// be negative, so `x^-2` parses
    fn parsePower(self: *Parser) ParseError!u32 {
        const base = try self.parsePrimary();
        if (self.peek()) |c| {
            if (c == '^') {
                self.pos += 1;
                const e = try self.parseUnary();
                return try self.emit(.{ .op = .pow, .a = base, .b = e });
            }
        }
        return base;
    }

    fn parsePrimary(self: *Parser) ParseError!u32 {
        const c = self.peek() orelse return ParseError.UnexpectedEnd;
        if (c == '(') {
            self.pos += 1;
            const inner = try self.parseExpr();
            const close = self.peek() orelse return ParseError.MissingParen;
            if (close != ')') return ParseError.MissingParen;
            self.pos += 1;
            return inner;
        }
        if (c >= '0' and c <= '9' or c == '.') return try self.parseNumber();
        if (isIdentStart(c)) return try self.parseNameOrCall();
        return ParseError.UnexpectedCharacter;
    }

    fn parseNumber(self: *Parser) ParseError!u32 {
        const start = self.pos;
        while (self.pos < self.src.len) {
            const ch = self.src[self.pos];
            if ((ch >= '0' and ch <= '9') or ch == '.') {
                self.pos += 1;
            } else if (ch == 'e' or ch == 'E') {
                // exponent, optionally signed
                if (self.pos + 1 < self.src.len) {
                    const nx = self.src[self.pos + 1];
                    if ((nx >= '0' and nx <= '9') or nx == '+' or nx == '-') {
                        self.pos += 2;
                        continue;
                    }
                }
                break;
            } else break;
        }
        const v = std.fmt.parseFloat(f64, self.src[start..self.pos]) catch
            return ParseError.UnexpectedCharacter;
        return try self.emit(.{ .op = .constant, .k = v });
    }

    fn parseNameOrCall(self: *Parser) ParseError!u32 {
        const start = self.pos;
        while (self.pos < self.src.len and isIdentPart(self.src[self.pos])) self.pos += 1;
        const name = self.src[start..self.pos];

        if (self.peek()) |c| {
            if (c == '(') {
                self.pos += 1;
                const a = try self.parseExpr();
                var b: ?u32 = null;
                if (self.peek()) |c2| {
                    if (c2 == ',') {
                        self.pos += 1;
                        b = try self.parseExpr();
                    }
                }
                const close = self.peek() orelse return ParseError.MissingParen;
                if (close != ')') return ParseError.MissingParen;
                self.pos += 1;
                return try self.emitCall(name, a, b);
            }
        }

        // a bare name: a variable, or one of the two constants
        if (eqIgnoreCase(name, "pi")) return try self.emit(.{ .op = .constant, .k = std.math.pi });
        if (eqIgnoreCase(name, "e")) return try self.emit(.{ .op = .constant, .k = std.math.e });
        for (self.names, 0..) |n, i| {
            if (eqIgnoreCase(name, n)) {
                return try self.emit(.{ .op = .variable, .a = @intCast(i) });
            }
        }
        return ParseError.UnknownName;
    }

    fn emitCall(self: *Parser, name: []const u8, a: u32, b: ?u32) ParseError!u32 {
        const unary = [_]struct { n: []const u8, o: OpCode }{
            .{ .n = "exp", .o = .exp },
            .{ .n = "log", .o = .log },
            .{ .n = "ln", .o = .log },
            .{ .n = "sqrt", .o = .sqrt },
            .{ .n = "sin", .o = .sin },
            .{ .n = "cos", .o = .cos },
            .{ .n = "tan", .o = .tan },
            .{ .n = "tanh", .o = .tanh },
            .{ .n = "abs", .o = .abs },
        };
        for (unary) |u| {
            if (eqIgnoreCase(name, u.n)) {
                if (b != null) return ParseError.BadArity;
                return try self.emit(.{ .op = u.o, .a = a });
            }
        }
        if (eqIgnoreCase(name, "min") or eqIgnoreCase(name, "max")) {
            const rhs = b orelse return ParseError.BadArity;
            return try self.emit(.{
                .op = if (eqIgnoreCase(name, "min")) .min else .max,
                .a = a,
                .b = rhs,
            });
        }
        if (eqIgnoreCase(name, "pow")) {
            const rhs = b orelse return ParseError.BadArity;
            return try self.emit(.{ .op = .pow, .a = a, .b = rhs });
        }
        return ParseError.UnknownFunction;
    }
};

fn isIdentStart(c: u8) bool {
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or c == '_';
}
fn isIdentPart(c: u8) bool {
    return isIdentStart(c) or (c >= '0' and c <= '9');
}
fn eqIgnoreCase(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) return false;
    for (a, b) |x, y| {
        const lx = ascii.lower(x);
        const ly = ascii.lower(y);
        if (lx != ly) return false;
    }
    return true;
}

/// Compile `src` against the given variable names. Names are matched
/// case-insensitively, as Ring itself is.
pub fn compile(
    alloc: std.mem.Allocator,
    src: []const u8,
    names: []const []const u8,
) ParseError!*Program {
    if (names.len > MAX_VARS) return ParseError.TooManyVars;
    const prog = try alloc.create(Program);
    errdefer alloc.destroy(prog);
    prog.* = .{
        .nodes = try std.ArrayList(Node).initCapacity(alloc, 16),
        .n_vars = names.len,
        .allocator = alloc,
    };
    errdefer prog.nodes.deinit(alloc);

    var p = Parser{ .src = src, .pos = 0, .names = names, .prog = prog, .alloc = alloc };
    _ = try p.parseExpr();
    p.skipSpace();
    if (p.pos != src.len) return ParseError.UnexpectedCharacter;
    if (prog.nodes.items.len == 0) return ParseError.Empty;
    return prog;
}

// ─── forward + reverse ───────────────────────────────────────────────────────

/// Value and gradient at `x`. `val` and `adj` are scratch of nodes.len each;
/// `grad` receives n_vars entries. Returns the value.
///
/// One forward pass and one backward pass -- the gradient with respect to every
/// variable comes out of the SAME backward pass, which is the property that makes
/// reverse mode worth the tape.
pub fn valueAndGradient(
    prog: *const Program,
    x: []const f64,
    val: []f64,
    adj: []f64,
    grad: []f64,
) f64 {
    const nodes = prog.nodes.items;

    // forward
    for (nodes, 0..) |nd, i| {
        val[i] = switch (nd.op) {
            .constant => nd.k,
            .variable => x[nd.a],
            .add => val[nd.a] + val[nd.b],
            .sub => val[nd.a] - val[nd.b],
            .mul => val[nd.a] * val[nd.b],
            .div => val[nd.a] / val[nd.b],
            .neg => -val[nd.a],
            .pow => std.math.pow(f64, val[nd.a], val[nd.b]),
            .exp => @exp(val[nd.a]),
            .log => @log(val[nd.a]),
            .sqrt => @sqrt(val[nd.a]),
            .sin => @sin(val[nd.a]),
            .cos => @cos(val[nd.a]),
            .tan => @tan(val[nd.a]),
            .tanh => std.math.tanh(val[nd.a]),
            .abs => @abs(val[nd.a]),
            .min => @min(val[nd.a], val[nd.b]),
            .max => @max(val[nd.a], val[nd.b]),
        };
    }

    // reverse
    @memset(adj[0..nodes.len], 0);
    @memset(grad[0..prog.n_vars], 0);
    adj[nodes.len - 1] = 1;

    var i: usize = nodes.len;
    while (i > 0) {
        i -= 1;
        const g = adj[i];
        if (g == 0) continue;
        const nd = nodes[i];
        switch (nd.op) {
            .constant => {},
            .variable => grad[nd.a] += g,
            .add => {
                adj[nd.a] += g;
                adj[nd.b] += g;
            },
            .sub => {
                adj[nd.a] += g;
                adj[nd.b] -= g;
            },
            .mul => {
                adj[nd.a] += g * val[nd.b];
                adj[nd.b] += g * val[nd.a];
            },
            .div => {
                adj[nd.a] += g / val[nd.b];
                adj[nd.b] -= g * val[nd.a] / (val[nd.b] * val[nd.b]);
            },
            .neg => adj[nd.a] -= g,
            .pow => {
                const a = val[nd.a];
                const b = val[nd.b];
                adj[nd.a] += g * b * std.math.pow(f64, a, b - 1);
                // d/db of a^b is a^b * ln(a), which only exists for a > 0. For a
                // constant exponent -- the overwhelmingly common case -- this
                // adjoint is discarded anyway, so a NaN here would be a NaN
                // manufactured out of nothing.
                if (a > 0) adj[nd.b] += g * val[i] * @log(a);
            },
            .exp => adj[nd.a] += g * val[i],
            .log => adj[nd.a] += g / val[nd.a],
            .sqrt => adj[nd.a] += g / (2 * val[i]),
            .sin => adj[nd.a] += g * @cos(val[nd.a]),
            .cos => adj[nd.a] -= g * @sin(val[nd.a]),
            .tan => {
                const c = @cos(val[nd.a]);
                adj[nd.a] += g / (c * c);
            },
            .tanh => adj[nd.a] += g * (1 - val[i] * val[i]),
            .abs => adj[nd.a] += if (val[nd.a] >= 0) g else -g,
            // AT A TIE THE GRADIENT GOES LEFT. min/max are not differentiable
            // where the arguments are equal; something must be chosen, and
            // choosing the first argument is at least reproducible.
            .min => {
                if (val[nd.a] <= val[nd.b]) adj[nd.a] += g else adj[nd.b] += g;
            },
            .max => {
                if (val[nd.a] >= val[nd.b]) adj[nd.a] += g else adj[nd.b] += g;
            },
        }
    }
    return val[nodes.len - 1];
}

/// Value only -- no tape walk. Used by line searches, which evaluate far more
/// often than they differentiate.
pub fn value(prog: *const Program, x: []const f64, val: []f64) f64 {
    const nodes = prog.nodes.items;
    for (nodes, 0..) |nd, i| {
        val[i] = switch (nd.op) {
            .constant => nd.k,
            .variable => x[nd.a],
            .add => val[nd.a] + val[nd.b],
            .sub => val[nd.a] - val[nd.b],
            .mul => val[nd.a] * val[nd.b],
            .div => val[nd.a] / val[nd.b],
            .neg => -val[nd.a],
            .pow => std.math.pow(f64, val[nd.a], val[nd.b]),
            .exp => @exp(val[nd.a]),
            .log => @log(val[nd.a]),
            .sqrt => @sqrt(val[nd.a]),
            .sin => @sin(val[nd.a]),
            .cos => @cos(val[nd.a]),
            .tan => @tan(val[nd.a]),
            .tanh => std.math.tanh(val[nd.a]),
            .abs => @abs(val[nd.a]),
            .min => @min(val[nd.a], val[nd.b]),
            .max => @max(val[nd.a], val[nd.b]),
        };
    }
    return val[nodes.len - 1];
}

// ─── tests ───────────────────────────────────────────────────────────────────

const testing = std.testing;

fn gradOf(src: []const u8, names: []const []const u8, x: []const f64, out: []f64) !f64 {
    const alloc = testing.allocator;
    const prog = try compile(alloc, src, names);
    defer prog.deinit();
    const val = try alloc.alloc(f64, prog.nodes.items.len);
    defer alloc.free(val);
    const adj = try alloc.alloc(f64, prog.nodes.items.len);
    defer alloc.free(adj);
    return valueAndGradient(prog, x, val, adj, out);
}

test "a polynomial, differentiated exactly" {
    var g: [2]f64 = undefined;
    // f = x^2 + 3xy ; df/dx = 2x + 3y ; df/dy = 3x
    const v = try gradOf("x^2 + 3*x*y", &.{ "x", "y" }, &.{ 2, 3 }, &g);
    try testing.expectApproxEqAbs(@as(f64, 22), v, 1e-12); // 4 + 18
    try testing.expectApproxEqAbs(@as(f64, 13), g[0], 1e-12); // 4 + 9
    try testing.expectApproxEqAbs(@as(f64, 6), g[1], 1e-12);
}

test "every gradient comes from ONE backward pass" {
    // ten variables, one pass -- the property that makes reverse mode worth a tape
    var g: [10]f64 = undefined;
    const names = [_][]const u8{ "a", "b", "c", "d", "e1", "f", "g1", "h", "i", "j" };
    const xs = [_]f64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const v = try gradOf("a+2*b+3*c+4*d+5*e1+6*f+7*g1+8*h+9*i+10*j", &names, &xs, &g);
    try testing.expectApproxEqAbs(@as(f64, 385), v, 1e-9);
    for (0..10) |k| try testing.expectApproxEqAbs(@as(f64, @floatFromInt(k + 1)), g[k], 1e-12);
}

test "transcendentals" {
    var g: [1]f64 = undefined;
    _ = try gradOf("exp(x)", &.{"x"}, &.{1.0}, &g);
    try testing.expectApproxEqAbs(std.math.e, g[0], 1e-12);
    _ = try gradOf("log(x)", &.{"x"}, &.{4.0}, &g);
    try testing.expectApproxEqAbs(@as(f64, 0.25), g[0], 1e-12);
    _ = try gradOf("sqrt(x)", &.{"x"}, &.{9.0}, &g);
    try testing.expectApproxEqAbs(@as(f64, 1.0 / 6.0), g[0], 1e-12);
    _ = try gradOf("sin(x)", &.{"x"}, &.{0.0}, &g);
    try testing.expectApproxEqAbs(@as(f64, 1), g[0], 1e-12);
    _ = try gradOf("tanh(x)", &.{"x"}, &.{0.0}, &g);
    try testing.expectApproxEqAbs(@as(f64, 1), g[0], 1e-12);
}

test "against finite differences, on something awkward" {
    const alloc = testing.allocator;
    const src = "exp(-(x*x + y*y)) * sin(3*x) / (1 + abs(y))";
    const names = [_][]const u8{ "x", "y" };
    const prog = try compile(alloc, src, &names);
    defer prog.deinit();
    const val = try alloc.alloc(f64, prog.nodes.items.len);
    defer alloc.free(val);
    const adj = try alloc.alloc(f64, prog.nodes.items.len);
    defer alloc.free(adj);

    var g: [2]f64 = undefined;
    var x = [_]f64{ 0.37, -0.62 };
    _ = valueAndGradient(prog, &x, val, adj, &g);

    const h = 1e-6;
    for (0..2) |k| {
        var xp = x;
        var xm = x;
        xp[k] += h;
        xm[k] -= h;
        const num = (value(prog, &xp, val) - value(prog, &xm, val)) / (2 * h);
        try testing.expectApproxEqAbs(num, g[k], 1e-6);
    }
}

test "a shared subexpression is differentiated once, and correctly" {
    // x appears four times; the adjoints must ACCUMULATE, not overwrite
    var g: [1]f64 = undefined;
    // f = x*x + x*x = 2x^2 ; f' = 4x
    const v = try gradOf("x*x + x*x", &.{"x"}, &.{3.0}, &g);
    try testing.expectApproxEqAbs(@as(f64, 18), v, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 12), g[0], 1e-12);
}

test "precedence and associativity match the infix reading" {
    var g: [1]f64 = undefined;
    var v = try gradOf("2 + 3 * x", &.{"x"}, &.{4.0}, &g);
    try testing.expectApproxEqAbs(@as(f64, 14), v, 1e-12);
    // ^ binds tighter than unary minus on the left, and is right-associative
    v = try gradOf("2 ^ 3 ^ 2", &.{"x"}, &.{0.0}, &g);
    try testing.expectApproxEqAbs(@as(f64, 512), v, 1e-9); // 2^(3^2), not (2^3)^2
    v = try gradOf("-x ^ 2", &.{"x"}, &.{3.0}, &g);
    try testing.expectApproxEqAbs(@as(f64, -9), v, 1e-12); // -(x^2)
}

test "pi and e are known, and are not variables" {
    var g: [1]f64 = undefined;
    const v = try gradOf("sin(pi/2) + x*0", &.{"x"}, &.{5.0}, &g);
    try testing.expectApproxEqAbs(@as(f64, 1), v, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 0), g[0], 1e-12);
}

test "an unknown name is refused rather than guessed" {
    const alloc = testing.allocator;
    try testing.expectError(ParseError.UnknownName, compile(alloc, "x + zzz", &.{"x"}));
    try testing.expectError(ParseError.UnknownFunction, compile(alloc, "wobble(x)", &.{"x"}));
    try testing.expectError(ParseError.MissingParen, compile(alloc, "(x + 1", &.{"x"}));
    // a dangling operator runs out of input rather than meeting a bad character
    try testing.expectError(ParseError.UnexpectedEnd, compile(alloc, "x + ", &.{"x"}));
    try testing.expectError(ParseError.UnexpectedCharacter, compile(alloc, "x $ 2", &.{"x"}));
}

test "min and max send the gradient to the argument that won" {
    var g: [2]f64 = undefined;
    _ = try gradOf("min(x, y)", &.{ "x", "y" }, &.{ 1.0, 5.0 }, &g);
    try testing.expectApproxEqAbs(@as(f64, 1), g[0], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 0), g[1], 1e-12);
    _ = try gradOf("max(x, y)", &.{ "x", "y" }, &.{ 1.0, 5.0 }, &g);
    try testing.expectApproxEqAbs(@as(f64, 0), g[0], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 1), g[1], 1e-12);
    // at a tie it goes LEFT, deliberately
    _ = try gradOf("max(x, y)", &.{ "x", "y" }, &.{ 2.0, 2.0 }, &g);
    try testing.expectApproxEqAbs(@as(f64, 1), g[0], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 0), g[1], 1e-12);
}
