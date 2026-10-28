//! gpu_fuzz.zig -- GT0: THE RANDOM-KERNEL FUZZ (SOFTANZA_GPU_PLAN.md, NEXT;
//! the reader's account is base/gpu/SOFTANZA_GPU_KERNELS.md).
//!
//! One description has two readers: the transpiler writes WGSL from it and the
//! interpreter runs it on the CPU. They share a parser and nothing else -- the
//! rewriter that writes WGSL and the compiler that builds the interpreter's
//! program are separate code. Every hand-written guard checks them on kernels a
//! person thought of. This generates kernels nobody thought of, from the
//! grammar, runs each on the device and through the interpreter, and counts.
//!
//! What it counts, per run (stz_gpu_fuzz_result):
//!   - a description BOTH readers refuse: the generator's defect, not the grammar's
//!   - a description ONE reader admits and the other refuses: an admission split
//!   - WGSL the device refuses to compile: a transpiler defect
//!   - a store past the output region, or into an element the guard left
//!     unwritten: a structural defect
//!   - a value outside the band: a disagreement
//!
//! THE EXACTNESS DISCIPLINE, which is what makes a disagreement mean something.
//! Every input, scalar and literal is a multiple of 1/8 of small magnitude, so
//! + - * on them, and floor, round, fract, sign, step, min, max, clamp, abs,
//! mix with a dyadic weight, and % or / by a power of two, round NOWHERE: the
//! f32 result is the exact one on any device, fused multiply-add or not. A
//! description built only from those is EXACT and must agree bit for bit. The
//! inexact operations (sin, exp, log, pow, a general division ...) are applied
//! only to exact arguments and never feed a discontinuous function, a guard or
//! an index -- a last-ulp difference in sin must not become a different branch.
//! An inexact description agrees within rel * max(1, |ref|).
//!
//! Stage indices are permutations of the thread index, so no two threads write
//! one slot: a race is a defect of the description, which the interpreter
//! cannot mirror (that is GZ0's sanitizer, not this).
//!
//! Deterministic: case `index` of run `seed` is the same description on every
//! machine (stz_gpu_fuzz_case), so a disagreement is reproduced by two numbers.
//! Compiled kernels stay cached for the process (gpu.zig has no release), so a
//! run's size is bounded by memory; the guard keeps runs to a few hundred.

const std = @import("std");
const gpu = @import("gpu.zig");
const wgsl = @import("gpu_wgsl.zig");

pub const K_MAP: u8 = 0; // an elementwise expression
pub const K_GUARD: u8 = 1; // ... under a custom guard
pub const K_NEIGH: u8 = 2; // ... reading neighbours, inputs longer than n
pub const K_SUM: u8 = 3; // ... with a bounded sum
pub const K_GROUP: u8 = 4; // shared arrays, stages, reductions
pub const K_TILES: u8 = 5; // tiles, accumulate, width
pub const K_INT: u8 = 6; // GL0: ints -- declared, wrapping, divided by zero, converted
pub const K_VEC: u8 = 7; // GL0: vectors -- built, swizzled, spread, combined, reduced
pub const K_VIO: u8 = 8; // GL0: typed buffers -- vector inputs and outputs, N floats per element
pub const K_ATOM: u8 = 9; // GL0: atomics -- many threads adding, maxing or mining into SIZE counters
pub const KINDS: usize = 10;
/// The mask bit of kind k. Bits 6 to 8 are the controls, so the int kind
/// takes bit 9: a mask written before GL0 (63) asks for the six it always meant.
pub fn kindBit(k: usize) u32 {
    return if (k < 6) @as(u32, 1) << @intCast(k) else @as(u32, 1) << @intCast(k + 3);
}
fn genSlot(k: usize) usize {
    return if (k < 6) R_GEN_KIND + k else if (k == K_INT) R_GEN_INT else if (k == K_VEC) R_GEN_VEC else if (k == K_VIO) R_GEN_VIO else R_GEN_ATOM;
}
fn badSlot(k: usize) usize {
    return if (k < 6) R_BAD_KIND + k else if (k == K_INT) R_BAD_INT else if (k == K_VEC) R_BAD_VEC else if (k == K_VIO) R_BAD_VIO else R_BAD_ATOM;
}
/// mask bit 6: MUTATE -- the run's own control. Each kernel's WGSL gets its
/// first ' + ' in the stored expression turned into ' - ' (a kernel with none
/// is skipped); a fuzz that judges those agreeing proves nothing about the
/// ones it judged agreeing without the mutation.
pub const MUTATE: u32 = 1 << 6;
/// mask bit 7: RACE -- GZ0's control. Every shared-memory kernel's first stage
/// writes through an index two or more threads share, so each is a race the
/// sanitizer must name: one it misses is the sanitizer's defect (its kill line).
pub const RACE: u32 = 1 << 7;
var g_inject_race: bool = false;
/// mask bit 8: SWAP -- GL0's control for when(). Each kernel's WGSL gets the
/// two values of the first select in its stored expression exchanged, the
/// mistake WGSL's false-first order invites (a kernel with none is skipped).
/// Counted in the MUTATE slots; a swap the run judges agreeing is a kernel
/// whose condition never varied over its elements, or whose two values were
/// equal wherever it did.
pub const SWAP: u32 = 1 << 8;

const SPEC_CAP = 4096;
const WGSL_CAP = 65536;
const MARGIN: usize = 256;
const MAX_IN = 3;
const MAX_SC = 4;

// ---------------------------------------------------------------- result slots
pub const R_GENERATED = 0;
pub const R_REFUSED_BOTH = 1; // the generator's defect
pub const R_ADMISSION_SPLIT = 2; // one reader admits, the other refuses
pub const R_COMPILE_FAILED = 3; // the device refused the WGSL
pub const R_RAN = 4;
pub const R_AGREED = 5;
pub const R_DISAGREED = 6; // a value outside the band
pub const R_WRITE_OUTSIDE = 7; // past the region, or where the guard said not to
pub const R_NONFINITE = 8; // cases whose reference held a non-finite value (skipped elements)
pub const R_EXACT = 9;
pub const R_INEXACT = 10;
pub const R_WORST_RATIO = 11; // the largest |d| / allowed over inexact agreeing cases
pub const R_FIRST_BAD = 12; // index of the first defective case, -1 none
pub const R_FIRST_BAD_ELEM = 13;
pub const R_WALL_MS = 14;
pub const R_DEVICE_ERRORS = 15; // a dispatch or a read that failed
pub const R_ELEMENTS = 16; // elements compared in all
pub const R_EXACT_DISAGREED = 17;
pub const R_MUTATED = 18; // MUTATE runs: kernels whose WGSL was given one wrong operator
pub const R_CAUGHT = 19; // ... and of those, the ones the run judged defective
pub const R_UNWRITTEN = 36; // elements a guard left unwritten, checked to stay so
pub const R_SAN_RACE = 37; // GZ0: cases the sanitizer found a race in (the generator writes none: must be 0)
pub const R_SAN_QUIET = 38; // GZ0: cases with a dropped write, a read past an array or of an unwritten slot
pub const R_WHEN = 26; // GL0: cases whose description holds a when()
pub const R_GEN_KIND = 20; // + kind: cases generated of that kind
pub const R_BAD_KIND = 30; // + kind: defective cases of that kind
pub const R_GEN_INT = 40; // GL0: int cases generated
pub const R_BAD_INT = 41; // ... and defective
pub const R_GEN_VEC = 42; // GL0: vector cases generated
pub const R_BAD_VEC = 43; // ... and defective
pub const R_GEN_VIO = 44; // GL0: typed-buffer cases generated
pub const R_BAD_VIO = 45; // ... and defective
pub const R_GEN_ATOM = 46; // GL0: atomic cases generated
pub const R_BAD_ATOM = 47; // ... and defective
pub const R_SLOTS = 48;

var result: [R_SLOTS]f64 = @splat(0);
var first_buf: [SPEC_CAP + 256]u8 = undefined;
var first_len: usize = 0;
var log_buf: [32768]u8 = undefined;
var log_len: usize = 0;
var g_written: usize = 0; // elements the last case's guard let through

/// Every defective case of the last run, one line each: index, kind, defect,
/// element, and the two values where there are two (truncated at 32 KB).
pub fn stz_gpu_fuzz_log(out: [*]u8, cap: f64) callconv(.c) i32 {
    const n = @min(log_len, @as(usize, @intFromFloat(cap)));
    @memcpy(out[0..n], log_buf[0..n]);
    return @intCast(n);
}

fn logLine(comptime fmt: []const u8, args: anytype) void {
    const out = std.fmt.bufPrint(log_buf[log_len..], fmt, args) catch return;
    log_len += out.len;
}

pub fn stz_gpu_fuzz_result(idx: i32) callconv(.c) f64 {
    if (idx < 0 or idx >= R_SLOTS) return 0;
    return result[@intCast(idx)];
}

/// The first defective case: a line naming its index, kind and defect, then its description.
pub fn stz_gpu_fuzz_first(out: [*]u8, cap: f64) callconv(.c) i32 {
    const n = @min(first_len, @as(usize, @intFromFloat(cap)));
    @memcpy(out[0..n], first_buf[0..n]);
    return @intCast(n);
}

// ---------------------------------------------------------------- the case
const W = struct {
    buf: []u8,
    len: usize = 0,
    over: bool = false,

    fn s(self: *W, t: []const u8) void {
        if (self.over or self.len + t.len > self.buf.len) {
            self.over = true;
            return;
        }
        @memcpy(self.buf[self.len..][0..t.len], t);
        self.len += t.len;
    }

    fn f(self: *W, comptime fmt: []const u8, args: anytype) void {
        if (self.over) return;
        const out = std.fmt.bufPrint(self.buf[self.len..], fmt, args) catch {
            self.over = true;
            return;
        };
        self.len += out.len;
    }
};

pub const Case = struct {
    spec: [SPEC_CAP]u8 = undefined,
    len: usize = 0,
    kind: u8 = 0,
    exact: bool = true,
    n: usize = 0,
    n_ins: usize = 0,
    in_len: [MAX_IN]usize = @splat(0),
    n_sc: usize = 0,
    sc: [MAX_SC]f32 = @splat(0),
    sc_name: [MAX_SC][]const u8 = @splat(""),
    in_int: [MAX_IN]bool = @splat(false), // GL0: an int input gets whole numbers
    in_w: [MAX_IN]u8 = @splat(1), // GL0: floats per element of each input
    out_w: u8 = 1,
    data_seed: u64 = 0,

    pub fn text(self: *const Case) []const u8 {
        return self.spec[0..self.len];
    }
};

const IN_NAMES = [_][]const u8{ "a", "b", "x" };
const SC_NAMES = [_][]const u8{ "s", "alpha", "beta", "q" };
const LITS = [_][]const u8{ "0.5", "0.25", "1", "2", "3", "0.125", "1.5", "4", "0" };

const Ctx = struct {
    elem: bool = true, // a bare @a reads this thread's element
    group: bool = false, // @l @g @lx @ly
    rowcol: bool = false, // @row @col
    acc: bool = false,
    neigh: bool = false, // @a[index] reads
    sumvar: ?[]const u8 = null,
    shared: []const []const u8 = &.{}, // shared arrays this line may read
    sh_size: usize = 256,
};

const Gen = struct {
    r: std.Random,
    w: *W,
    c: *Case,
    muls: u8 = 0,
    sums: u8 = 0, // GL0: sums written in this case (an expression holds at most 4)

    fn pick(self: *Gen, n: usize) usize {
        return self.r.uintLessThan(usize, n);
    }
    fn chance(self: *Gen, pct: u8) bool {
        return self.r.uintLessThan(u8, 100) < pct;
    }
    fn int(self: *Gen, lo: usize, hi: usize) usize {
        return self.r.intRangeAtMost(usize, lo, hi);
    }

    fn atom(self: *Gen, cx: Ctx) void {
        var guard: usize = 0;
        while (guard < 64) : (guard += 1) {
            switch (self.pick(11)) {
                0, 1 => if (cx.elem and self.c.n_ins > 0) {
                    const k = self.pick(self.c.n_ins);
                    if (self.c.in_w[k] == 1) {
                        self.w.s("@");
                        self.w.s(IN_NAMES[k]);
                        return;
                    }
                },
                2 => if (self.c.n_sc > 0) {
                    self.w.s(self.c.sc_name[self.pick(self.c.n_sc)]);
                    return;
                },
                3 => {
                    self.w.s(LITS[self.pick(LITS.len)]);
                    return;
                },
                4 => {
                    const P = [_][]const u8{ "(@i % 16)", "(@i % 4)", "(n % 8)" };
                    self.w.s(P[self.pick(P.len)]);
                    return;
                },
                5 => if (cx.group) {
                    const G = [_][]const u8{ "(@l % 8)", "(@lx % 4)", "(@ly % 4)", "(@g % 4)" };
                    self.w.s(G[self.pick(G.len)]);
                    return;
                },
                6 => if (cx.acc) {
                    self.w.s("@acc");
                    return;
                },
                7 => if (cx.sumvar) |v| {
                    self.w.f("({s} % 4)", .{v});
                    return;
                },
                8 => if (cx.shared.len > 0) {
                    const sn = cx.shared[self.pick(cx.shared.len)];
                    const SI = [_][]const u8{ "0", "@l", "255 - @l", "(@l * 3) % 256", "(@g % 4)", "@lx", "@ly * 16 + @lx", "@l + 1" };
                    self.w.f("@{s}[{s}]", .{ sn, SI[self.pick(SI.len)] });
                    return;
                },
                9 => if (cx.neigh and self.c.n_ins > 0) {
                    self.neighbour();
                    return;
                },
                10 => if (cx.rowcol) {
                    self.w.s(if (self.chance(50)) "(@row % 8)" else "(@col % 8)");
                    return;
                },
                else => {},
            }
        }
        self.w.s("1");
    }

    /// A body in a group kind reads a shared array at least once.
    fn atomShared(self: *Gen, cx: Ctx) void {
        const sn = cx.shared[self.pick(cx.shared.len)];
        const SI = [_][]const u8{ "0", "@l", "255 - @l", "(@l * 3) % 256", "(@g % 4)", "@lx", "@ly * 16 + @lx" };
        self.w.f("@{s}[{s}]", .{ sn, SI[self.pick(SI.len)] });
    }

    fn neighbour(self: *Gen) void {
        const nm = IN_NAMES[self.pick(self.c.n_ins)];
        const k = self.int(1, 5);
        switch (self.pick(8)) {
            0 => self.w.f("@{s}[@i + {d}]", .{ nm, k }),
            1 => self.w.f("@{s}[@i - {d}]", .{ nm, k }),
            2 => self.w.f("@{s}[n - 1 - @i]", .{nm}),
            3 => self.w.f("@{s}[@i * 2]", .{nm}),
            4 => self.w.f("@{s}[@i * 2 + 1]", .{nm}),
            5 => self.w.f("@{s}[floor(@{s} * 4) + @i]", .{ nm, IN_NAMES[self.pick(self.c.n_ins)] }),
            6 => self.w.f("@{s}[(@i + {d}) % 7]", .{ nm, k }),
            else => self.w.f("@{s}[@i]", .{nm}),
        }
    }

    /// An exact expression: rounds nowhere on any device.
    fn exact(self: *Gen, depth: u8, cx: Ctx) void {
        if (depth == 0 or self.chance(25)) return self.atom(cx);
        const d = depth - 1;
        switch (self.pick(19)) {
            0 => self.bin(" + ", d, cx),
            1 => self.bin(" - ", d, cx),
            2 => if (self.muls < 2) {
                self.muls += 1;
                self.bin(" * ", d, cx);
            } else self.bin(" + ", d, cx),
            3 => self.call1("abs", d, cx),
            4 => self.call2("min", d, cx),
            5 => self.call2("max", d, cx),
            6 => {
                self.w.s("clamp(");
                self.exact(d, cx);
                self.w.s(", -1, 2)");
            },
            7 => self.call1("floor", d, cx),
            8 => self.call1("ceil", d, cx),
            9 => self.call1("round", d, cx),
            10 => self.call1("fract", d, cx),
            11 => self.call1("sign", d, cx),
            12 => self.call2("step", d, cx),
            13 => {
                const M = [_][]const u8{ " % 2)", " % 0.5)", " / 2)", " / 4)", " % 4)" };
                self.w.s("(");
                self.exact(d, cx);
                self.w.s(M[self.pick(M.len)]);
            },
            14 => {
                self.w.s("mix(");
                self.exact(d, cx);
                self.w.s(", ");
                self.exact(d, cx);
                self.w.s(if (self.chance(50)) ", 0.25)" else ", 0.5)");
            },
            15 => {
                self.w.s("(-");
                self.exact(d, cx);
                self.w.s(")");
            },
            16 => {
                self.w.s("(");
                self.exact(d, cx);
                self.w.s(" - -0.5)");
            },
            17 => {
                // GL0: an exact condition picks one of two exact values
                self.w.s("when(");
                self.cond(d, cx);
                self.w.s(", ");
                self.exact(d, cx);
                self.w.s(", ");
                self.exact(d, cx);
                self.w.s(")");
            },
            else => self.atom(cx),
        }
    }

    fn bin(self: *Gen, op: []const u8, d: u8, cx: Ctx) void {
        self.w.s("(");
        self.exact(d, cx);
        self.w.s(op);
        self.exact(d, cx);
        self.w.s(")");
    }
    fn call1(self: *Gen, name: []const u8, d: u8, cx: Ctx) void {
        self.w.s(name);
        self.w.s("(");
        self.exact(d, cx);
        self.w.s(")");
    }
    fn call2(self: *Gen, name: []const u8, d: u8, cx: Ctx) void {
        self.w.s(name);
        self.w.s("(");
        self.exact(d, cx);
        self.w.s(", ");
        self.exact(d, cx);
        self.w.s(")");
    }

    /// One inexact operation over exact arguments.
    fn inexact(self: *Gen, cx: Ctx) void {
        self.c.exact = false;
        const F = [_][2][]const u8{
            .{ "sin(clamp(", ", -3, 3))" },     .{ "cos(clamp(", ", -3, 3))" },
            .{ "tan(clamp(", ", -1.2, 1.2))" }, .{ "tanh(", ")" },
            .{ "exp(clamp(", ", -4, 4))" },     .{ "log(abs(", ") + 0.5)" },
            .{ "sqrt(abs(", "))" },             .{ "inversesqrt(abs(", ") + 0.5)" },
            .{ "asin(clamp(", ", -0.9, 0.9))" }, .{ "acos(clamp(", ", -0.9, 0.9))" },
            .{ "length(", ")" },                .{ "smoothstep(-1, 1, ", ")" },
        };
        switch (self.pick(F.len + 3)) {
            F.len => {
                self.w.s("pow(abs(");
                self.exact(2, cx);
                self.w.s(") + 0.5, clamp(");
                self.exact(1, cx);
                self.w.s(", -2, 2))");
            },
            F.len + 1 => {
                self.w.s("atan2(");
                self.exact(2, cx);
                self.w.s(", abs(");
                self.exact(1, cx);
                self.w.s(") + 0.5)");
            },
            F.len + 2 => {
                self.w.s("(");
                self.exact(2, cx);
                self.w.s(" / (abs(");
                self.exact(1, cx);
                self.w.s(") + 0.5))");
            },
            else => |k| {
                self.w.s(F[k][0]);
                self.exact(2, cx);
                self.w.s(F[k][1]);
            },
        }
    }

    /// A value: exact, or exact arithmetic around one or two inexact operations.
    fn value(self: *Gen, cx: Ctx, inexact_pct: u8) void {
        self.muls = 0;
        if (!self.chance(inexact_pct)) return self.exact(3, cx);
        switch (self.pick(6)) {
            5 => {
                self.w.s("when(");
                self.cond(1, cx);
                self.w.s(", ");
                self.inexact(cx);
                self.w.s(", ");
                self.exact(2, cx);
                self.w.s(")");
            },
            0 => self.inexact(cx),
            1 => {
                self.w.s("(");
                self.exact(2, cx);
                self.w.s(" + ");
                self.inexact(cx);
                self.w.s(")");
            },
            2 => {
                self.w.s("(");
                self.exact(1, cx);
                self.w.s(" * ");
                self.inexact(cx);
                self.w.s(")");
            },
            3 => {
                self.w.s("(");
                self.inexact(cx);
                self.w.s(" - ");
                self.inexact(cx);
                self.w.s(")");
            },
            else => {
                self.w.s("mix(");
                self.exact(2, cx);
                self.w.s(", ");
                self.inexact(cx);
                self.w.s(", 0.5)");
            },
        }
    }

    /// GL0: a when's condition, from exact values only, so a last-ulp
    /// difference can never choose the other value. Leaves the product
    /// budget alone: the condition sits inside an expression.
    fn cond(self: *Gen, d: u8, cx: Ctx) void {
        const OPS = [_][]const u8{ " < ", " <= ", " > ", " >= ", " == ", " != " };
        switch (self.pick(6)) {
            0 => {
                self.w.s("(");
                self.exact(0, cx);
                self.w.s(OPS[self.pick(OPS.len)]);
                self.exact(0, cx);
                self.w.s(if (self.chance(50)) ") and (" else ") or (");
                self.exact(0, cx);
                self.w.s(OPS[self.pick(OPS.len)]);
                self.exact(0, cx);
                self.w.s(")");
            },
            else => {
                self.exact(d, cx);
                self.w.s(OPS[self.pick(OPS.len)]);
                self.exact(0, cx);
            },
        }
    }

    fn compare(self: *Gen, cx: Ctx) void {
        const OPS = [_][]const u8{ " < ", " <= ", " > ", " >= ", " == ", " != " };
        self.muls = 0;
        self.exact(2, cx);
        self.w.s(OPS[self.pick(OPS.len)]);
        self.exact(1, cx);
    }

    // ---- GL0: an int expression. Exact by nature: an i32 op rounds nowhere
    // and wraps the same on every device, so every int case agrees bit for bit.
    fn iatom(self: *Gen) void {
        var tries: usize = 0;
        while (tries < 32) : (tries += 1) {
            switch (self.pick(9)) {
                0, 1 => if (self.intIn()) |nm| {
                    self.w.f("@{s}", .{nm});
                    return;
                },
                2 => if (self.intIn()) |nm| {
                    const k = self.int(1, 4);
                    switch (self.pick(3)) {
                        0 => self.w.f("@{s}[@i + {d}]", .{ nm, k }),
                        1 => self.w.f("@{s}[@i - {d}]", .{ nm, k }),
                        else => self.w.f("@{s}[(@i * 3) % 7]", .{nm}),
                    }
                    return;
                },
                3 => if (self.c.n_sc > 0) {
                    self.w.s(self.c.sc_name[self.pick(self.c.n_sc)]);
                    return;
                },
                4, 5 => {
                    const L = [_][]const u8{ "0", "1", "2", "3", "7", "13", "100", "1000", "65536", "2147483647", "1103515245", "1664525" };
                    self.w.s(L[self.pick(L.len)]);
                    return;
                },
                6 => {
                    const P = [_][]const u8{ "(@i % 9)", "(@i - 100)", "n", "(n - @i)" };
                    self.w.s(P[self.pick(P.len)]);
                    return;
                },
                7 => if (self.floatIn()) |nm| {
                    // a float read as an int: toward zero
                    switch (self.pick(3)) {
                        0 => self.w.f("int(@{s} * 4)", .{nm}),
                        1 => self.w.f("int(@{s})", .{nm}),
                        else => self.w.f("int(floor(@{s} * 8) / 2)", .{nm}),
                    }
                    return;
                },
                else => if (self.intIn()) |nm| {
                    if (self.sums < 3) {
                        self.sums += 1;
                        self.w.f("sum(k, 0, 3, @{s}[@i + k])", .{nm});
                        return;
                    }
                },
            }
        }
        self.w.s("1");
    }
    fn intIn(self: *Gen) ?[]const u8 {
        var have: [MAX_IN]usize = undefined;
        var nh: usize = 0;
        for (0..self.c.n_ins) |k| {
            if (self.c.in_int[k]) {
                have[nh] = k;
                nh += 1;
            }
        }
        return if (nh == 0) null else IN_NAMES[have[self.pick(nh)]];
    }
    fn floatIn(self: *Gen) ?[]const u8 {
        for (0..self.c.n_ins) |k| {
            if (!self.c.in_int[k]) return IN_NAMES[k];
        }
        return null;
    }
    fn iexpr(self: *Gen, depth: u8) void {
        if (depth == 0 or self.chance(20)) return self.iatom();
        const d = depth - 1;
        switch (self.pick(14)) {
            0, 1 => self.ibin(" + ", d),
            2 => self.ibin(" - ", d),
            3, 4 => self.ibin(" * ", d), // wraps: mirrored, not avoided
            5 => self.ibin(" / ", d), // by zero too: WGSL's answer is the dividend
            6, 7 => self.ibin(" % ", d), // a negative dividend: the device's own '%' is wrong here
            8 => {
                self.w.s(if (self.chance(50)) "min(" else "max(");
                self.iexpr(d);
                self.w.s(", ");
                self.iexpr(d);
                self.w.s(")");
            },
            9 => {
                self.w.s(if (self.chance(50)) "abs(" else "sign(");
                self.iexpr(d);
                self.w.s(")");
            },
            10 => {
                self.w.s("clamp(");
                self.iexpr(d);
                self.w.s(", -50, 50)");
            },
            11 => {
                const OPS = [_][]const u8{ " < ", " <= ", " > ", " >= ", " == ", " != " };
                self.w.s("when(");
                self.iexpr(d);
                self.w.s(OPS[self.pick(OPS.len)]);
                self.iatom();
                self.w.s(", ");
                self.iexpr(d);
                self.w.s(", ");
                self.iexpr(d);
                self.w.s(")");
            },
            12 => {
                self.w.s("(-");
                self.iexpr(d);
                self.w.s(")");
            },
            else => self.iatom(),
        }
    }
    fn ibin(self: *Gen, op: []const u8, d: u8) void {
        self.w.s("(");
        self.iexpr(d);
        self.w.s(op);
        self.iexpr(d);
        self.w.s(")");
    }

    // ---- GL0: a vector of width n. Exact as the scalar forms are: its
    // components are exact values, and +, -, the products under the budget,
    // dot, cross, reflect, floor, min, max, a dyadic mix and when round nowhere.
    fn vexpr(self: *Gen, n: u8, depth: u8, cx: Ctx) void {
        if (depth == 0 or self.chance(20)) return self.vatom(n, cx);
        const d = depth - 1;
        switch (self.pick(13)) {
            0, 1 => self.vbin(" + ", n, d, cx),
            2 => self.vbin(" - ", n, d, cx),
            3 => if (self.muls < 2) {
                self.muls += 1;
                self.w.s("(");
                self.vexpr(n, d, cx);
                self.w.s(" * ");
                self.exact(0, cx);
                self.w.s(")");
            } else self.vbin(" + ", n, d, cx),
            4 => {
                self.w.s("(-");
                self.vexpr(n, d, cx);
                self.w.s(")");
            },
            5 => {
                const F = [_][]const u8{ "abs(", "floor(", "ceil(", "fract(", "sign(" };
                self.w.s(F[self.pick(F.len)]);
                self.vexpr(n, d, cx);
                self.w.s(")");
            },
            6 => {
                self.w.s(if (self.chance(50)) "min(" else "max(");
                self.vexpr(n, d, cx);
                self.w.s(", ");
                self.vexpr(n, d, cx);
                self.w.s(")");
            },
            7 => {
                self.w.s("mix(");
                self.vexpr(n, d, cx);
                self.w.s(", ");
                self.vexpr(n, d, cx);
                self.w.s(if (self.chance(50)) ", 0.5)" else ", 0.25)");
            },
            8 => {
                self.w.s("when(");
                self.cond(0, cx);
                self.w.s(", ");
                self.vexpr(n, d, cx);
                self.w.s(", ");
                self.vexpr(n, d, cx);
                self.w.s(")");
            },
            9 => if (n == 3 and self.muls == 0) {
                self.muls = 2;
                self.w.s("cross(");
                self.vatom(3, cx);
                self.w.s(", ");
                self.vatom(3, cx);
                self.w.s(")");
            } else self.vbin(" - ", n, d, cx),
            10 => if (self.muls == 0) {
                self.muls = 2;
                self.w.s("reflect(");
                self.vatom(n, cx);
                self.w.s(", ");
                self.vatom(n, cx);
                self.w.s(")");
            } else self.vbin(" + ", n, d, cx),
            11 => {
                self.w.s("step(");
                self.vexpr(n, d, cx);
                self.w.s(", ");
                self.vexpr(n, d, cx);
                self.w.s(")");
            },
            else => self.vatom(n, cx),
        }
    }
    fn vbin(self: *Gen, op: []const u8, n: u8, d: u8, cx: Ctx) void {
        self.w.s("(");
        self.vexpr(n, d, cx);
        self.w.s(op);
        if (self.chance(25)) self.exact(0, cx) else self.vexpr(n, d, cx); // a number spread across it
        self.w.s(")");
    }
    fn vatom(self: *Gen, n: u8, cx: Ctx) void {
        // only a case with a vector input draws here, so the vector kind's
        // cases stay the ones it always generated
        var vin = false;
        for (0..self.c.n_ins) |k| vin = vin or self.c.in_w[k] > 1;
        if (vin and self.chance(40)) {
            for (0..self.c.n_ins) |k| {
                const wk = self.c.in_w[k];
                if (wk == n) {
                    switch (self.pick(3)) {
                        0 => self.w.f("@{s}", .{IN_NAMES[k]}),
                        1 => self.w.f("@{s}[@i + {d}]", .{ IN_NAMES[k], self.int(1, 3) }),
                        else => self.w.f("@{s}[@i - 1]", .{IN_NAMES[k]}),
                    }
                    return;
                }
                if (wk > n) {
                    const SW = [_][]const u8{ "", "", ".yx", ".zxy" };
                    self.w.f("@{s}{s}", .{ IN_NAMES[k], SW[n] });
                    return;
                }
            }
        }
        // a vec4 has no wider vector to swizzle from: it takes the other forms
        switch (if (n == 4) ([_]usize{ 0, 2, 3 })[self.pick(3)] else self.pick(4)) {
            0 => {
                self.w.f("vec{d}(", .{n});
                self.exact(0, cx);
                self.w.s(")");
            },
            1 => if (n < 4) {
                // a swizzle of a wider vector
                const SW = [_][]const u8{ "", "", ".zx", ".yzx" };
                self.w.s("vec4(");
                for (0..4) |k| {
                    if (k > 0) self.w.s(", ");
                    self.exact(0, cx);
                }
                self.w.f("){s}", .{SW[n]});
            } else self.vatom(n, cx),
            2 => if (n >= 3) {
                // a vector and a number make a wider one
                self.w.f("vec{d}(", .{n});
                self.vatom(n - 1, cx);
                self.w.s(", ");
                self.exact(0, cx);
                self.w.s(")");
            } else self.vatom(2, cx),
            else => {
                self.w.f("vec{d}(", .{n});
                for (0..n) |k| {
                    if (k > 0) self.w.s(", ");
                    self.exact(1, cx);
                }
                self.w.s(")");
            },
        }
    }
    /// A number from a vector: a component, or a dot (exact under the
    /// budget); now and then a length or a distance, which round.
    fn vreduce(self: *Gen, cx: Ctx) void {
        const n: u8 = @intCast(self.int(2, 4));
        switch (self.pick(6)) {
            0, 1 => {
                self.w.s("(");
                self.vexpr(n, 2, cx);
                self.w.s(if (n == 2) ").y" else if (n == 3) ").z" else ").w");
            },
            2 => {
                self.w.s("(");
                self.vexpr(n, 2, cx);
                self.w.s(").x");
            },
            3 => if (self.muls == 0) {
                self.muls = 2;
                self.w.s("dot(");
                self.vexpr(n, 1, cx);
                self.w.s(", ");
                self.vexpr(n, 1, cx);
                self.w.s(")");
            } else self.vreduce(cx),
            4 => {
                self.c.exact = false;
                self.w.s("length(");
                self.vexpr(n, 2, cx);
                self.w.s(")");
            },
            else => {
                self.c.exact = false;
                self.w.s("distance(");
                self.vexpr(n, 1, cx);
                self.w.s(", ");
                self.vexpr(n, 1, cx);
                self.w.s(")");
            },
        }
    }

    fn declare(self: *Gen, n_ins: usize, n_sc: usize) void {
        self.c.n_ins = n_ins;
        self.c.n_sc = n_sc;
        for (0..n_ins) |k| self.w.f("in {s}\n", .{IN_NAMES[k]});
        for (0..n_sc) |k| {
            self.w.f("scalar {s}\n", .{SC_NAMES[k]});
            self.c.sc[k] = dyadic(self.r);
            self.c.sc_name[k] = SC_NAMES[k];
        }
        self.w.s("out res\n");
    }

    fn pickN(self: *Gen) usize {
        const N = [_]usize{ 1, 7, 255, 256, 257, 1000, 1023, 2048 };
        return if (self.chance(40)) self.int(1, 3000) else N[self.pick(N.len)];
    }
};

fn dyadic(r: std.Random) f32 {
    const k: i32 = r.intRangeAtMost(i32, -16, 16);
    return @as(f32, @floatFromInt(k)) / 8.0;
}

fn caseSeed(seed: u64, index: u64) u64 {
    return (seed *% 0x9E3779B97F4A7C15) +% (index *% 0xBF58476D1CE4E5B9) +% 1;
}

/// Generate case `index` of run `seed`, of the kind given (or, with kind < 0,
/// the round-robin kind over `mask`).
pub fn generate(seed: u64, index: u64, kind: u8, c: *Case) void {
    var prng = std.Random.DefaultPrng.init(caseSeed(seed, index));
    const r = prng.random();
    c.* = .{};
    c.kind = kind;
    c.data_seed = r.int(u64);
    var w = W{ .buf = &c.spec };
    var g = Gen{ .r = r, .w = &w, .c = c };
    switch (kind) {
        K_MAP, K_GUARD, K_NEIGH => {
            g.declare(g.int(1, MAX_IN), g.int(0, MAX_SC));
            c.n = g.pickN();
            for (0..c.n_ins) |k| c.in_len[k] = c.n;
            const cx = Ctx{ .neigh = kind == K_NEIGH };
            if (kind == K_NEIGH) {
                for (0..c.n_ins) |k| c.in_len[k] = switch (g.pick(3)) {
                    0 => c.n,
                    1 => c.n + g.int(1, 300),
                    else => 2 * c.n + 2,
                };
            }
            if (kind == K_GUARD) {
                w.s("guard { ");
                switch (g.pick(5)) {
                    4 => {
                        // and and or side by side need parentheses (WGSL's
                        // rule, refused by both readers since GT0 found it)
                        w.s("(@i < n and ");
                        g.compare(cx);
                        w.s(") or (@i < n and ");
                        g.compare(cx);
                        w.s(")");
                    },
                    0 => {
                        w.s("@i < n and ");
                        g.compare(cx);
                    },
                    1 => {
                        g.compare(cx);
                        w.s(" and @i < n");
                    },
                    2 => {
                        w.s("@i < n and (");
                        g.compare(cx);
                        w.s(" or ");
                        g.compare(cx);
                        w.s(")");
                    },
                    else => {
                        w.s("@i >= 3 and @i < n and ");
                        g.compare(cx);
                    },
                }
                w.s(" }\n");
            }
            w.s("body { @res = ");
            if (kind == K_NEIGH) {
                g.muls = 0;
                w.s("(");
                g.neighbour();
                w.s(" + ");
                g.value(cx, 25);
                w.s(")");
            } else g.value(cx, 35);
            w.s(" }\n");
        },
        K_SUM => {
            const n_ins = g.int(1, 2);
            const use_scalar = g.chance(40);
            g.declare(n_ins, if (use_scalar) 0 else g.int(0, 2));
            const m = g.int(1, 6);
            if (use_scalar) {
                // the bound as a scalar named m, holding an integer
                w.s("scalar m\n");
                c.n_sc = 1;
                c.sc[0] = @floatFromInt(m);
                c.sc_name[0] = "m";
            }
            c.n = g.pickN();
            for (0..c.n_ins) |k| c.in_len[k] = c.n * m + g.int(0, 8);
            const from: usize = if (g.chance(25)) 1 else 0;
            const bound: []const u8 = if (use_scalar) "m" else switch (m) {
                1 => "1",
                2 => "2",
                3 => "3",
                4 => "4",
                5 => "5",
                else => "6",
            };
            const nm = IN_NAMES[g.pick(c.n_ins)];
            const inner = Ctx{ .sumvar = "j", .elem = true };
            w.f("body {{ @res = sum(j, {d}, {s}, @{s}[@i * {s} + j] * ", .{ from, bound, nm, bound });
            g.muls = 1;
            g.exact(2, inner);
            w.s(")");
            if (g.chance(50)) {
                w.s(" + ");
                g.value(.{}, 30);
            }
            w.s(" }\n");
        },
        K_GROUP => {
            g.declare(g.int(1, 2), g.int(0, 2));
            c.n = if (g.chance(50)) 256 * g.int(1, 8) else g.pickN();
            for (0..c.n_ins) |k| c.in_len[k] = c.n;
            const sizes = [_]usize{ 256, 256, 128, 64 };
            const size = sizes[g.pick(sizes.len)];
            const two = g.chance(40);
            w.f("shared sa {d}\n", .{size});
            if (two) w.s("shared sb 256\n");
            const PERM = [_][]const u8{ "@l", "255 - @l", "(@l + 37) % 256", "@lx * 16 + @ly", "@ly * 16 + @lx" };
            const SHARED_SLOT = [_][]const u8{ "(@l % 64)", "floor(@l / 2)", "@lx * 16", "(@l % 128)" };
            const gcx = Ctx{ .group = true };
            if (g_inject_race) {
                w.f("stage {{ @sa[{s}] = ", .{SHARED_SLOT[g.pick(SHARED_SLOT.len)]});
            } else w.f("stage {{ @sa[{s}] = ", .{PERM[g.pick(PERM.len)]});
            g.value(gcx, 25);
            w.s(" }\n");
            if (two) {
                w.f("stage {{ @sb[{s}] = ", .{PERM[g.pick(PERM.len)]});
                g.value(.{ .group = true, .shared = &.{"sa"} }, 20);
                w.s(" }\n");
            }
            if (g.chance(50)) {
                const RO = [_][]const u8{ "sum", "max", "min" };
                w.f("reduce {s} {s}\n", .{ if (two and g.chance(50)) "sb" else "sa", RO[g.pick(RO.len)] });
            }
            const readable: []const []const u8 = if (two) &.{ "sa", "sb" } else &.{"sa"};
            w.s("body { @res = ");
            const bcx = Ctx{ .group = true, .shared = readable };
            g.muls = 0;
            w.s("(");
            g.atomShared(bcx);
            w.s(" + ");
            g.value(bcx, 20);
            w.s(") }\n");
        },
        K_TILES => {
            if (g.chance(70)) {
                // the 2-D tiled product, with a random combination per term
                const rr = g.int(1, 3);
                const cc = g.int(1, 3);
                const tt = g.int(1, 3);
                c.n_ins = 2;
                w.s("in a\nin b\nscalar k\nscalar w\n");
                c.n_sc = 2;
                c.sc[0] = @floatFromInt(16 * tt);
                c.sc[1] = @floatFromInt(16 * cc);
                c.sc_name[0] = "k";
                c.sc_name[1] = "w";
                const with_alpha = g.chance(40);
                if (with_alpha) {
                    w.s("scalar alpha\n");
                    c.n_sc = 3;
                    c.sc[2] = dyadic(r);
                    c.sc_name[2] = "alpha";
                }
                w.s("out res\nwidth w\nshared ta 256\nshared tb 256\ntiles t { k / 16 }\n");
                c.n = 16 * rr * 16 * cc;
                c.in_len[0] = 16 * rr * 16 * tt;
                c.in_len[1] = 16 * tt * 16 * cc;
                const SA = [_][]const u8{ "@a[@row * k + t * 16 + @lx]", "(@a[@row * k + t * 16 + @lx] * 2)", "abs(@a[@row * k + t * 16 + @lx])" };
                const SB = [_][]const u8{ "@b[(t * 16 + @ly) * w + @col]", "(@b[(t * 16 + @ly) * w + @col] - 0.5)", "floor(@b[(t * 16 + @ly) * w + @col])" };
                w.f("stage {{ @ta[@ly * 16 + @lx] = {s} }}\n", .{SA[g.pick(SA.len)]});
                w.f("stage {{ @tb[@ly * 16 + @lx] = {s} }}\n", .{SB[g.pick(SB.len)]});
                const T = [_][]const u8{ "X * Y", "max(X, Y)", "X + Y", "abs(X - Y)", "X * Y * 0.5" };
                const term = T[g.pick(T.len)];
                w.s("accumulate { @acc = @acc + sum(j, 0, 16, ");
                for (term) |ch| switch (ch) {
                    'X' => w.s("@ta[@ly * 16 + j]"),
                    'Y' => w.s("@tb[j * 16 + @lx]"),
                    else => w.s(&[_]u8{ch}),
                };
                w.s(") }\n");
                const B = [_][]const u8{ "@acc", "@acc - (@col % 8) * 0.5", "@acc + (@row % 8)" };
                if (with_alpha and g.chance(50)) {
                    w.s("body { @res = @acc * alpha }\n");
                } else if (g.chance(25)) {
                    c.exact = false;
                    w.s("body { @res = tanh(@acc * 0.125) }\n");
                } else w.f("body {{ @res = {s} }}\n", .{B[g.pick(B.len)]});
            } else {
                // the 1-D loop: each pass stages a slice of a longer input
                g.declare(1, g.int(0, 1));
                const passes = g.int(1, 4);
                c.n = if (g.chance(50)) 256 * g.int(1, 4) else g.pickN();
                c.in_len[0] = passes * c.n;
                w.s("shared sa 256\n");
                w.f("tiles t {{ {d} }}\n", .{passes});
                w.s("stage { @sa[@l] = @a[t * n + @i] }\n");
                const ACC = [_][]const u8{ "@acc + @sa[255 - @l]", "max(@acc, @sa[@l])", "@acc + @sa[(@l + 1) % 256] * 0.5", "@acc * 0.5 + @sa[@l]" };
                w.f("accumulate {{ @acc = {s} }}\n", .{ACC[g.pick(ACC.len)]});
                w.s("body { @res = @acc }\n");
            }
        },
        K_ATOM => {
            // GL0 (atomics): '@res[index] op value' -- an index outside the
            // counters is dropped, and add, max and min agree in any order
            c.n_ins = g.int(1, 2);
            var any = false;
            for (0..c.n_ins) |k| {
                c.in_int[k] = g.chance(60);
                if (c.in_int[k]) any = true;
            }
            if (!any) c.in_int[0] = true;
            for (0..c.n_ins) |k| w.f("in {s}{s}\n", .{ IN_NAMES[k], if (c.in_int[k]) " int" else "" });
            c.n_sc = g.int(0, 1);
            for (0..c.n_sc) |k| {
                w.f("scalar {s} int\n", .{SC_NAMES[k]});
                c.sc[k] = @floatFromInt(r.intRangeAtMost(i32, -20, 20));
                c.sc_name[k] = SC_NAMES[k];
            }
            c.n = g.pickN();
            for (0..c.n_ins) |k| c.in_len[k] = c.n;
            const size = g.int(1, 64);
            w.f("out res atomic {d}\n", .{size});
            if (g.chance(20)) {
                w.s("guard { @i < n and ");
                g.iexpr(1);
                w.s(" != ");
                g.iatom();
                w.s(" }\n");
            }
            w.s("body { @res[");
            switch (g.pick(3)) {
                0 => w.f("@i % {d}", .{size}),
                1 => {
                    w.s("(");
                    g.iexpr(2);
                    w.f(") % {d}", .{size}); // may be negative: dropped
                },
                else => g.iexpr(2), // anywhere, mostly outside: dropped
            }
            w.s(switch (g.pick(3)) {
                0 => "] += ",
                1 => "] max= ",
                else => "] min= ",
            });
            if (g.chance(30)) w.s("1") else g.iexpr(2);
            w.s(" }\n");
        },
        K_VIO => {
            // a, a number; b and maybe x, vectors; the output a vector or a number
            c.n_ins = g.int(2, MAX_IN);
            c.in_w[0] = 1;
            for (1..c.n_ins) |k| c.in_w[k] = @intCast(g.int(2, 4));
            c.n = g.pickN();
            for (0..c.n_ins) |k| {
                w.f("in {s}{s}\n", .{ IN_NAMES[k], switch (c.in_w[k]) {
                    2 => " vec2",
                    3 => " vec3",
                    4 => " vec4",
                    else => "",
                } });
                // a neighbour read may reach past n: some inputs are longer
                const extra: usize = if (g.chance(30)) g.int(1, 20) else 0;
                c.in_len[k] = (c.n + extra) * c.in_w[k];
            }
            c.out_w = if (g.chance(30)) 1 else @intCast(g.int(2, 4));
            w.s(switch (c.out_w) {
                2 => "out res vec2\n",
                3 => "out res vec3\n",
                4 => "out res vec4\n",
                else => "out res\n",
            });
            const cx = Ctx{};
            g.muls = 0;
            if (g.chance(15)) {
                w.s("guard { @i < n and (");
                g.cond(0, cx);
                w.s(") }\n");
            }
            w.s("body { @res = ");
            if (c.out_w == 1) g.vreduce(cx) else g.vexpr(c.out_w, 3, cx);
            w.s(" }\n");
        },
        K_VEC => {
            g.declare(g.int(1, MAX_IN), g.int(0, MAX_SC));
            c.n = g.pickN();
            for (0..c.n_ins) |k| c.in_len[k] = c.n;
            const cx = Ctx{};
            w.s("body { @res = ");
            g.muls = 0;
            g.vreduce(cx);
            if (g.chance(40)) {
                w.s(" + ");
                g.exact(1, cx);
            }
            w.s(" }\n");
        },
        K_INT => {
            const ni = g.int(1, MAX_IN);
            c.n_ins = ni;
            var any = false;
            for (0..ni) |k| {
                c.in_int[k] = g.chance(70);
                if (c.in_int[k]) any = true;
            }
            if (!any) c.in_int[0] = true;
            for (0..ni) |k| w.f("in {s}{s}\n", .{ IN_NAMES[k], if (c.in_int[k]) " int" else "" });
            c.n_sc = g.int(0, 2);
            for (0..c.n_sc) |k| {
                w.f("scalar {s} int\n", .{SC_NAMES[k]});
                c.sc[k] = @floatFromInt(r.intRangeAtMost(i32, -20, 20));
                c.sc_name[k] = SC_NAMES[k];
            }
            c.n = g.pickN();
            for (0..ni) |k| c.in_len[k] = if (g.chance(30)) c.n + g.int(1, 50) else c.n;
            const float_out = g.chance(20);
            w.s(if (float_out) "out res\n" else "out res int\n");
            if (g.chance(20)) {
                w.s("guard { @i < n and ");
                g.iexpr(1);
                w.s(" != ");
                g.iatom();
                w.s(" }\n");
            }
            w.s("body { @res = ");
            if (float_out) {
                // an int crossing back: f32(i) rounds to nearest, the same everywhere
                w.s("float(");
                g.iexpr(3);
                w.s(") * 0.5");
            } else g.iexpr(3);
            w.s(" }\n");
        },
        else => {},
    }
    c.len = if (w.over) 0 else w.len;
}


// ---------------------------------------------------------------- the data
fn fillInputs(c: *const Case, host: *[MAX_IN][]f32) void {
    var prng = std.Random.DefaultPrng.init(c.data_seed);
    const r = prng.random();
    for (0..c.n_ins) |k| {
        for (host[k]) |*v| v.* = if (!c.in_int[k]) dyadic(r) else switch (r.uintLessThan(u8, 10)) {
            0 => @floatFromInt(r.intRangeAtMost(i32, -(1 << 20), 1 << 20)),
            1 => dyadic(r), // read through int(): toward zero
            else => @floatFromInt(r.intRangeAtMost(i32, -300, 300)),
        };
    }
}

// ---------------------------------------------------------------- the run
fn record(index: u64, c: *const Case, what: []const u8, elem: i64) void {
    if (result[R_FIRST_BAD] >= 0) return;
    result[R_FIRST_BAD] = @floatFromInt(index);
    result[R_FIRST_BAD_ELEM] = @floatFromInt(elem);
    const head = std.fmt.bufPrint(&first_buf, "case {d}, kind {d}, n {d}, {s}{s}\n", .{ index, c.kind, c.n, what, if (c.exact) " (exact)" else " (inexact)" }) catch {
        first_len = 0;
        return;
    };
    const t = c.text();
    const room = @min(t.len, first_buf.len - head.len);
    @memcpy(first_buf[head.len..][0..room], t[0..room]);
    first_len = head.len + room;
}

fn bad(index: u64, c: *const Case, slot: usize, what: []const u8, elem: i64) void {
    badv(index, c, slot, what, elem, std.math.nan(f64), std.math.nan(f64));
}

fn badv(index: u64, c: *const Case, slot: usize, what: []const u8, elem: i64, ref: f64, dev: f64) void {
    result[slot] += 1;
    result[badSlot(c.kind)] += 1;
    record(index, c, what, elem);
    if (ref == ref or dev == dev) {
        logLine("case {d}, kind {d}: {s} at element {d}: interpreter {d}, device {d}\n", .{ index, c.kind, what, elem, ref, dev });
    } else if (slot == R_COMPILE_FAILED) {
        const e = gpu.firstError();
        const cut = std.mem.indexOfScalar(u8, e, '\n') orelse e.len;
        logLine("case {d}, kind {d}: {s}: {s}\n", .{ index, c.kind, what, e[0..@min(cut, 200)] });
    } else {
        logLine("case {d}, kind {d}: {s}\n", .{ index, c.kind, what });
    }
}

const Outcome = enum { agreed, disagreed, outside, device };

/// Run one admitted case on the device and through the interpreter.
fn runCase(index: u64, c: *const Case, kernel: i64, rel: f64) void {
    const alloc = std.heap.c_allocator;
    var host: [MAX_IN][]f32 = undefined;
    var got: usize = 0;
    defer for (0..got) |k| alloc.free(host[k]);
    for (0..c.n_ins) |k| {
        host[k] = alloc.alloc(f32, c.in_len[k]) catch return;
        got += 1;
    }
    fillInputs(c, &host);

    // the interpreter
    // GL0 (typed buffers): w floats per element of the output, one mask byte per element
    const ow0: usize = @intFromFloat(wgsl.stz_gpu_spec_out_width());
    // GL0 (atomics): SIZE counters, one float each once read, every one compared
    const atomic = wgsl.stz_gpu_spec_out_atomic() == 1;
    const asz: usize = @intFromFloat(wgsl.stz_gpu_spec_out_size());
    const ow: usize = if (atomic) 1 else ow0;
    const ne: usize = if (atomic) asz else c.n; // the region's elements
    const ref = alloc.alloc(f32, @max(ne * ow, c.n * ow0)) catch return;
    defer alloc.free(ref);
    const mask = alloc.alloc(u8, c.n) catch return;
    defer alloc.free(mask);
    var ptrs: [MAX_IN][*]const f32 = undefined;
    var lens: [MAX_IN]f64 = undefined;
    for (0..c.n_ins) |k| {
        ptrs[k] = host[k].ptr;
        lens[k] = @floatFromInt(c.in_len[k]);
    }
    var scal: [wgsl.MAX_SCALARS]f32 = @splat(0);
    for (0..c.n_sc) |k| scal[k] = c.sc[k];
    // GZ0: the reference runs under the sanitizer (it changes no value: a Zig test holds that)
    const kinds = wgsl.stz_gpu_spec_sanitize(&ptrs, @intCast(c.n_ins), &lens, &scal, @intCast(c.n_sc), @floatFromInt(c.n), ref.ptr, mask.ptr);
    if (kinds < 0) {
        bad(index, c, R_ADMISSION_SPLIT, "the interpreter compiled it and then refused to run it", -1);
        return;
    }
    if (wgsl.stz_gpu_sanitize_count(wgsl.SAN_RACE) > 0) {
        result[R_SAN_RACE] += 1;
        if (!g_inject_race) logLine("case {d}, kind {d}: the sanitizer found a race the generator cannot write\n", .{ index, c.kind });
    } else {
        if (g_inject_race and c.kind == K_GROUP) logLine("case {d}, kind {d}: an injected race the sanitizer MISSED\n", .{ index, c.kind });
        if (kinds > 0) result[R_SAN_QUIET] += 1;
    }

    // the device
    var ids: [MAX_IN + 1]i64 = @splat(0);
    defer for (ids) |id| {
        if (id > 0) _ = gpu.stz_gpu_buffer_free(id);
    };
    for (0..c.n_ins) |k| {
        ids[k] = gpu.stz_gpu_buffer_new(@floatFromInt(c.in_len[k] * 4));
        if (ids[k] <= 0 or gpu.stz_gpu_buffer_write(ids[k], @ptrCast(host[k].ptr), @floatFromInt(c.in_len[k] * 4)) != gpu.OK) {
            bad(index, c, R_DEVICE_ERRORS, "no device buffer", -1);
            return;
        }
    }
    const total = ne * ow + MARGIN;
    const cand = alloc.alloc(f32, total) catch return;
    defer alloc.free(cand);
    @memset(cand, std.math.nan(f32));
    // the counters at their identity, written as bits (min='s identity is NaN-shaped as a float)
    const cbits: [*]u32 = @ptrCast(cand.ptr);
    if (atomic) @memset(cbits[0..asz], @as(u32, @bitCast(@as(i32, @intFromFloat(wgsl.stz_gpu_spec_out_identity())))));
    const out_id = gpu.stz_gpu_buffer_new(@floatFromInt(total * 4));
    ids[c.n_ins] = out_id;
    if (out_id <= 0 or gpu.stz_gpu_buffer_write(out_id, @ptrCast(cand.ptr), @floatFromInt(total * 4)) != gpu.OK) {
        bad(index, c, R_DEVICE_ERRORS, "no device buffer for the output", -1);
        return;
    }
    var params: [64]u8 = @splat(0);
    std.mem.writeInt(u32, params[0..4], @intCast(c.n), .little);
    for (0..c.n_sc) |k| std.mem.writeInt(u32, params[8 + k * 4 ..][0..4], @bitCast(c.sc[k]), .little);
    const plen: usize = 8 + c.n_sc * 4;
    const wx: f64 = @floatFromInt((c.n + 255) / 256);
    if (gpu.stz_gpu_dispatch_params(kernel, &params, @floatFromInt(plen), &ids, @intCast(c.n_ins + 1), wx, 1) != gpu.OK or
        gpu.stz_gpu_sync() != gpu.OK or
        gpu.stz_gpu_buffer_read(out_id, @ptrCast(cand.ptr), @floatFromInt(total * 4)) != gpu.OK)
    {
        bad(index, c, R_DEVICE_ERRORS, "the dispatch or the read failed", -1);
        return;
    }
    result[R_RAN] += 1;
    if (c.exact) result[R_EXACT] += 1 else result[R_INEXACT] += 1;

    // the margin: anything that is not NaN was written past the region
    if (atomic) {
        for (0..asz) |k| cand[k] = @floatFromInt(@as(i32, @bitCast(cbits[k])));
    }
    for (cand[ne * ow .. total], 0..) |x, k| {
        if (x == x) {
            bad(index, c, R_WRITE_OUTSIDE, "stored past the output region", @intCast(ne + k / ow));
            return;
        }
    }
    var worst: f64 = 0;
    var nonfinite = false;
    g_written = 0;
    for (ref[0 .. ne * ow], cand[0 .. ne * ow], 0..) |x, y, kf| {
        const i = kf / ow;
        const m: u8 = if (atomic) 1 else mask[i];
        const first = kf % ow == 0;
        if (first) result[R_ELEMENTS] += 1;
        if (m == 0) {
            if (first) result[R_UNWRITTEN] += 1;
            if (y == y) {
                bad(index, c, R_WRITE_OUTSIDE, "stored where the guard left the element unwritten", @intCast(i));
                return;
            }
            continue;
        }
        if (first) g_written += 1;
        if (!std.math.isFinite(x)) {
            nonfinite = true;
            continue;
        }
        const d: f64 = @abs(@as(f64, x) - @as(f64, y));
        if (c.exact) {
            if (!(d == 0)) {
                result[R_EXACT_DISAGREED] += 1;
                badv(index, c, R_DISAGREED, "an exact description gave a different value", @intCast(i), x, y);
                return;
            }
        } else {
            const allowed = rel * @max(1.0, @abs(@as(f64, x)));
            if (!(d <= allowed)) {
                badv(index, c, R_DISAGREED, "a value outside the band", @intCast(i), x, y);
                return;
            }
            if (d / allowed > worst) worst = d / allowed;
        }
    }
    if (nonfinite) result[R_NONFINITE] += 1;
    if (worst > result[R_WORST_RATIO]) result[R_WORST_RATIO] = worst;
    result[R_AGREED] += 1;
}

/// The control's one wrong operator: the first ' + ' after the output's
/// store, in place. False when the stored expression has none.
fn storeAt(w: []const u8) ?usize {
    return std.mem.indexOf(u8, w, "v_res[i] = ") orelse std.mem.indexOf(u8, w, "let o_ = ") orelse std.mem.indexOf(u8, w, "{ let k_ = ");
}

fn mutateWgsl(w: []u8) bool {
    // GL0 (atomics): an atomic store's one wrong operator is its operation --
    // add, max and min rotated, in place (the three names are one length)
    if (std.mem.indexOf(u8, w, "atomic")) |_| {
        for ([_][2][]const u8{ .{ "atomicAdd(", "atomicMax(" }, .{ "atomicMax(", "atomicMin(" }, .{ "atomicMin(", "atomicAdd(" } }) |pair| {
            if (std.mem.indexOf(u8, w, pair[0])) |at| {
                @memcpy(w[at .. at + pair[1].len], pair[1]);
                return true;
            }
        }
    }
    const store = storeAt(w) orelse return false;
    const end = std.mem.indexOfScalarPos(u8, w, store, ';') orelse return false;
    const plus = std.mem.indexOf(u8, w[store..end], " + ") orelse return false;
    w[store + plus + 1] = '-';
    return true;
}

/// SWAP's one wrong operator: the first select in the stored expression
/// gets its two values exchanged, in place (the rewriter writes
/// select((f), (t), (c)), so the two spans are bracketed). False with none.
fn swapSelect(w: []u8) bool {
    const store = storeAt(w) orelse return false;
    const end = std.mem.indexOfScalarPos(u8, w, store, ';') orelse return false;
    const at = std.mem.indexOf(u8, w[store..end], "select(") orelse return false;
    const a0 = store + at + 7;
    const m0 = closeOf(w, a0) orelse return false;
    if (m0 + 3 >= w.len or w[m0 + 1] != ',' or w[m0 + 2] != ' ') return false;
    const a1 = m0 + 3;
    const m1 = closeOf(w, a1) orelse return false;
    var tmp: [WGSL_CAP]u8 = undefined;
    const f_len = m0 + 1 - a0;
    const t_len = m1 + 1 - a1;
    @memcpy(tmp[0..t_len], w[a1 .. m1 + 1]);
    @memcpy(tmp[t_len .. t_len + 2], ", ");
    @memcpy(tmp[t_len + 2 .. t_len + 2 + f_len], w[a0 .. m0 + 1]);
    @memcpy(w[a0 .. m1 + 1], tmp[0 .. m1 + 1 - a0]);
    return true;
}

fn closeOf(w: []const u8, open: usize) ?usize {
    if (open >= w.len or w[open] != '(') return null;
    var depth: usize = 0;
    var j = open;
    while (j < w.len) : (j += 1) {
        if (w[j] == '(') depth += 1;
        if (w[j] == ')') {
            depth -= 1;
            if (depth == 0) return j;
        }
    }
    return null;
}

/// Generate `count` cases of the kinds in `mask` (bit k = kind k), round
/// robin, from `seed`; judge each on the device (when one is available) and
/// through the interpreter. `rel` is the inexact band. Returns gpu.OK, or
/// gpu.FALLBACK when no device exists: the admission checks still ran.
pub fn stz_gpu_fuzz_run(seedf: f64, countf: f64, maskf: f64, rel: f64) callconv(.c) i32 {
    result = @splat(0);
    result[R_FIRST_BAD] = -1;
    result[R_FIRST_BAD_ELEM] = -1;
    first_len = 0;
    log_len = 0;
    const seed: u64 = @intFromFloat(seedf);
    const count: u64 = @intFromFloat(countf);
    const mask: u32 = @intFromFloat(maskf);
    const swap = mask & SWAP != 0;
    const mutate = mask & MUTATE != 0 or swap;
    g_inject_race = mask & RACE != 0;
    defer g_inject_race = false;
    var kinds: [KINDS]u8 = undefined;
    var nk: usize = 0;
    for (0..KINDS) |k| {
        if (mask & kindBit(k) != 0) {
            kinds[nk] = @intCast(k);
            nk += 1;
        }
    }
    if (nk == 0 or count == 0) return gpu.BAD_ARG;
    const device = gpu.isAvail();
    var timer = std.time.Timer.start() catch null;
    var c: Case = .{};
    var out: [WGSL_CAP]u8 = undefined;
    var i: u64 = 0;
    while (i < count) : (i += 1) {
        generate(seed, i, kinds[@intCast(i % nk)], &c);
        result[R_GENERATED] += 1;
        result[genSlot(c.kind)] += 1;
        if (std.mem.indexOf(u8, c.text(), "when(") != null) result[R_WHEN] += 1;
        if (c.len == 0) {
            bad(i, &c, R_REFUSED_BOTH, "the generator overflowed its buffer", -1);
            continue;
        }
        const t = c.text();
        const a_wgsl = wgsl.stz_gpu_wgsl_elementwise(t.ptr, @floatFromInt(t.len), &out, @floatFromInt(out.len));
        const a_int = wgsl.stz_gpu_spec_compile(t.ptr, @floatFromInt(t.len));
        if (a_wgsl < 0 and a_int < 0) {
            bad(i, &c, R_REFUSED_BOTH, "both readers refused it (a generator defect)", -1);
            continue;
        }
        if ((a_wgsl < 0) != (a_int < 0)) {
            bad(i, &c, R_ADMISSION_SPLIT, if (a_wgsl < 0) "the transpiler refused what the interpreter admitted" else "the interpreter refused what the transpiler admitted", -1);
            continue;
        }
        if (!device) continue;
        const wl: usize = @intCast(a_wgsl);
        if (mutate) {
            if (!(if (swap) swapSelect(out[0..wl]) else mutateWgsl(out[0..wl]))) continue;
            result[R_MUTATED] += 1;
        }
        const before = result[R_DISAGREED] + result[R_WRITE_OUTSIDE];
        const kernel = gpu.stz_gpu_kernel_compile(&out, @floatFromInt(wl));
        if (kernel <= 0) {
            bad(i, &c, R_COMPILE_FAILED, "the device refused the WGSL", -1);
            // GL0: the compiler's own first words, which name the line
            const fe = gpu.firstError();
            logLine("  {s}\n", .{fe[0..@min(fe.len, 400)]});
            continue;
        }
        // the interpreter's program is the last one compiled: recompile it,
        // since nothing else ran between, but keep the order explicit
        _ = wgsl.stz_gpu_spec_compile(t.ptr, @floatFromInt(t.len));
        runCase(i, &c, kernel, rel);
        if (mutate) {
            if (result[R_DISAGREED] + result[R_WRITE_OUTSIDE] > before) {
                result[R_CAUGHT] += 1;
            } else logLine("case {d}, kind {d}: the mutant escaped (n {d}, {d} elements written)\n", .{ i, c.kind, c.n, g_written });
        }
    }
    if (timer) |*tm| result[R_WALL_MS] = @as(f64, @floatFromInt(tm.read())) / 1e6;
    return if (device) gpu.OK else gpu.FALLBACK;
}

/// The description of case `index` of run `seed` (round robin over `mask`), so
/// a reported case can be read, and run again, from two numbers.
pub fn stz_gpu_fuzz_case(seedf: f64, indexf: f64, maskf: f64, out: [*]u8, cap: f64) callconv(.c) i32 {
    const mask: u32 = @intFromFloat(maskf);
    var kinds: [KINDS]u8 = undefined;
    var nk: usize = 0;
    for (0..KINDS) |k| {
        if (mask & kindBit(k) != 0) {
            kinds[nk] = @intCast(k);
            nk += 1;
        }
    }
    if (nk == 0) return -1;
    const index: u64 = @intFromFloat(indexf);
    var c: Case = .{};
    generate(@intFromFloat(seedf), index, kinds[@intCast(index % nk)], &c);
    const n = @min(c.len, @as(usize, @intFromFloat(cap)));
    @memcpy(out[0..n], c.spec[0..n]);
    return @intCast(n);
}

// ---------------------------------------------------------------- tests (no device)
test "the fuzz: every generated description is admitted by both readers, and the interpreter runs it" {
    var c: Case = .{};
    var out: [WGSL_CAP]u8 = undefined;
    var refused: usize = 0;
    var split: usize = 0;
    var ran: usize = 0;
    const alloc = std.testing.allocator;
    for (0..KINDS) |kind| {
        for (0..60) |i| {
            generate(20261028, i, @intCast(kind), &c);
            try std.testing.expect(c.len > 0);
            const t = c.text();
            const a = wgsl.stz_gpu_wgsl_elementwise(t.ptr, @floatFromInt(t.len), &out, @floatFromInt(out.len));
            const b = wgsl.stz_gpu_spec_compile(t.ptr, @floatFromInt(t.len));
            if (a < 0 and b < 0) {
                refused += 1;
                var e: [256]u8 = undefined;
                const el = wgsl.stz_gpu_wgsl_error(&e, e.len);
                std.debug.print("REFUSED kind {d} case {d}: {s}\n{s}\n", .{ kind, i, e[0..@intCast(el)], t });
                continue;
            }
            if ((a < 0) != (b < 0)) {
                split += 1;
                var e2: [256]u8 = undefined;
                const el2 = wgsl.stz_gpu_wgsl_error(&e2, e2.len);
                std.debug.print("SPLIT kind {d} case {d} (wgsl {d}, interp {d}): {s}\n{s}\n", .{ kind, i, a, b, e2[0..@intCast(el2)], t });
                continue;
            }
            // the interpreter runs it to the end
            var host: [MAX_IN][]f32 = undefined;
            for (0..c.n_ins) |k| host[k] = try alloc.alloc(f32, c.in_len[k]);
            defer for (0..c.n_ins) |k| alloc.free(host[k]);
            fillInputs(&c, &host);
            var ptrs: [MAX_IN][*]const f32 = undefined;
            var lens: [MAX_IN]f64 = undefined;
            for (0..c.n_ins) |k| {
                ptrs[k] = host[k].ptr;
                lens[k] = @floatFromInt(c.in_len[k]);
            }
            var scal: [wgsl.MAX_SCALARS]f32 = @splat(0);
            for (0..c.n_sc) |k| scal[k] = c.sc[k];
            const ref = try alloc.alloc(f32, @max(c.n * c.out_w, 64));
            defer alloc.free(ref);
            try std.testing.expectEqual(@as(i32, 0), wgsl.stz_gpu_spec_eval(&ptrs, @intCast(c.n_ins), &lens, &scal, @intCast(c.n_sc), @floatFromInt(c.n), ref.ptr));
            ran += 1;
        }
    }
    try std.testing.expectEqual(@as(usize, 0), refused);
    try std.testing.expectEqual(@as(usize, 0), split);
    try std.testing.expectEqual(@as(usize, KINDS * 60), ran);
}

test "the fuzz is deterministic: one seed and index give one description" {
    var a: Case = .{};
    var b: Case = .{};
    for (0..KINDS) |kind| {
        generate(7, 42, @intCast(kind), &a);
        generate(7, 42, @intCast(kind), &b);
        try std.testing.expectEqualStrings(a.text(), b.text());
    }
}
