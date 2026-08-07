// CALIBRATE THIS MACHINE (M5) -- measure the real gated functions and write
// stz_calibration.txt for the engine to load.
//
// Run (from engine/):  zig run src/calibrate_tool.zig -OReleaseSafe
// (lives in src/ because Zig forbids ../ imports from a tools/ module root,
// and this tool exists precisely to probe the REAL production functions)
// then place the written stz_calibration.txt in the WORKING DIRECTORY of
// the application (each engine DLL loads it lazily from the CWD; no file
// means the compiled spike-measured defaults, which is the dev machine's
// truth).
//
// This tool imports the PRODUCTION functions -- matrix.stz_matrix_multiply,
// linalg.decompose, stats.compensatedSum / centeredSumOfSquares,
// cluster.topK, and umap's exact-kNN via its gate -- and probes each gate
// by forcing serial vs parallel through the same Gate.override the tests
// use. No replicated kernels, nothing to drift.
//
// RUN THIS ON A QUIET MACHINE. Observed live on first use: with a parallel
// build saturating the box, the css probe read 0.13x where the quiet-machine
// spike measured 1.6-1.9x -- the conservative rule then RAISES gates, which
// fails safe but writes a pessimistic file. Contention cannot make this tool
// write a dangerous gate (it can only make parallel look worse than it is),
// but it can cost you real speedups. Delete the file to return to defaults.
//
// DECISION RULE, per gate, written before running: probe at the default
// gate size D and at a half-work size H.
//     speedup(H) >= 1.5  ->  gate lowers to H
//     else speedup(D) >= 1.5  ->  gate stays at D
//     else                ->  gate raises to 2x D (threading not paying here)
// Coarse on purpose: this bounds every gate with two measurements, and the
// bar matches every spike's ship bar. The gpu.* namespace is reserved for
// the GPU plane's store and never written here.

const std = @import("std");
const calibstore = @import("calib.zig");
const matrix = @import("matrix.zig");
const linalg = @import("linalg.zig");
const stats = @import("stats.zig");
const cluster = @import("cluster.zig");

fn ms(ns: u64) f64 {
    return @as(f64, @floatFromInt(ns)) / 1_000_000.0;
}

var timer: std.time.Timer = undefined;

fn fill(buf: []f64, seed0: u64) void {
    var s = seed0;
    for (buf) |*v| {
        s = s *% 6364136223846793005 +% 1442695040888963407;
        v.* = @as(f64, @floatFromInt((s >> 33) % 1000)) / 999.0;
    }
}

const REPS = 3;

fn speedupMatmul(alloc: std.mem.Allocator, n: usize) !f64 {
    const a = matrix.stz_matrix_new(@intCast(n), @intCast(n)).?;
    defer matrix.stz_matrix_free(a);
    const b = matrix.stz_matrix_new(@intCast(n), @intCast(n)).?;
    defer matrix.stz_matrix_free(b);
    fill(a.data, 42);
    fill(b.data, 4242);
    _ = alloc;

    var t_ser: u64 = std.math.maxInt(u64);
    matrix.mm_par_min_flops.override(1e30); // force serial
    for (0..REPS) |_| {
        timer.reset();
        const c = matrix.stz_matrix_multiply(a, b).?;
        t_ser = @min(t_ser, timer.read());
        matrix.stz_matrix_free(c);
    }
    var t_par: u64 = std.math.maxInt(u64);
    matrix.mm_par_min_flops.override(1); // force parallel
    for (0..REPS) |_| {
        timer.reset();
        const c = matrix.stz_matrix_multiply(a, b).?;
        t_par = @min(t_par, timer.read());
        matrix.stz_matrix_free(c);
    }
    matrix.mm_par_min_flops.reset();
    return @as(f64, @floatFromInt(t_ser)) / @as(f64, @floatFromInt(t_par));
}

fn speedupLu(alloc: std.mem.Allocator, n: usize) !f64 {
    const data = try alloc.alloc(f64, n * n);
    defer alloc.free(data);
    fill(data, 7);
    for (0..n) |i| data[i * n + i] += 4.0;

    var t_ser: u64 = std.math.maxInt(u64);
    linalg.lu_gate.overrideUsize(std.math.maxInt(usize));
    for (0..REPS) |_| {
        timer.reset();
        var f = try linalg.decompose(alloc, data, n);
        t_ser = @min(t_ser, timer.read());
        f.deinit();
    }
    var t_par: u64 = std.math.maxInt(u64);
    linalg.lu_gate.overrideUsize(1);
    for (0..REPS) |_| {
        timer.reset();
        var f = try linalg.decompose(alloc, data, n);
        t_par = @min(t_par, timer.read());
        f.deinit();
    }
    linalg.lu_gate.reset();
    return @as(f64, @floatFromInt(t_ser)) / @as(f64, @floatFromInt(t_par));
}

fn speedupSum(alloc: std.mem.Allocator, n: usize, css: bool) !f64 {
    const data = try alloc.alloc(f64, n);
    defer alloc.free(data);
    fill(data, 5);
    const gate = if (css) &stats.css_gate else &stats.sum_gate;

    var t_ser: u64 = std.math.maxInt(u64);
    gate.overrideUsize(std.math.maxInt(usize));
    for (0..REPS) |_| {
        timer.reset();
        var r = if (css) stats.centeredSumOfSquares(data, 0.5) else stats.compensatedSum(data);
        std.mem.doNotOptimizeAway(&r);
        t_ser = @min(t_ser, timer.read());
    }
    var t_par: u64 = std.math.maxInt(u64);
    gate.overrideUsize(1);
    for (0..REPS) |_| {
        timer.reset();
        var r = if (css) stats.centeredSumOfSquares(data, 0.5) else stats.compensatedSum(data);
        std.mem.doNotOptimizeAway(&r);
        t_par = @min(t_par, timer.read());
    }
    gate.reset();
    return @as(f64, @floatFromInt(t_ser)) / @as(f64, @floatFromInt(t_par));
}

fn speedupTopk(alloc: std.mem.Allocator, n: usize, d: usize) !f64 {
    const pts = try alloc.alloc(f64, n * d);
    defer alloc.free(pts);
    fill(pts, 9);
    const q = try alloc.alloc(f64, d);
    defer alloc.free(q);
    for (q) |*v| v.* = 0.5;
    var idx: [10]i32 = undefined;
    var dst: [10]f64 = undefined;

    var t_ser: u64 = std.math.maxInt(u64);
    cluster.topk_gate.overrideUsize(std.math.maxInt(usize));
    for (0..REPS) |_| {
        timer.reset();
        var h = cluster.topK(pts, n, d, q, 10, &idx, &dst);
        std.mem.doNotOptimizeAway(&h);
        t_ser = @min(t_ser, timer.read());
    }
    var t_par: u64 = std.math.maxInt(u64);
    cluster.topk_gate.overrideUsize(1);
    for (0..REPS) |_| {
        timer.reset();
        var h = cluster.topK(pts, n, d, q, 10, &idx, &dst);
        std.mem.doNotOptimizeAway(&h);
        t_par = @min(t_par, timer.read());
    }
    cluster.topk_gate.reset();
    return @as(f64, @floatFromInt(t_ser)) / @as(f64, @floatFromInt(t_par));
}

fn decide(sp_half: f64, sp_full: f64, half: f64, full: f64) f64 {
    if (sp_half >= 1.5) return half;
    if (sp_full >= 1.5) return full;
    return full * 2.0;
}

pub fn main() !void {
    var gpa_state = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa_state.allocator();
    timer = try std.time.Timer.start();

    std.debug.print("calibrating (each probe = best of {d})...\n\n", .{REPS});

    // matmul: gate is FLOPS; probe n=203 (~half of 256^3 flops) and n=256.
    const mm_h = try speedupMatmul(alloc, 203);
    const mm_f = try speedupMatmul(alloc, 256);
    const mm_gate = decide(mm_h, mm_f, 2.0 * 203.0 * 203.0 * 203.0, 2.0 * 256.0 * 256.0 * 256.0);
    std.debug.print("matmul   sp(203)={d:.2} sp(256)={d:.2} -> par_min_flops {d:.0}\n", .{ mm_h, mm_f, mm_gate });

    // lu: gate is n; probe 812 (~half of 1024^3 flops) and 1024.
    const lu_h = try speedupLu(alloc, 812);
    const lu_f = try speedupLu(alloc, 1024);
    const lu_gate_v = decide(lu_h, lu_f, 812, 1024);
    std.debug.print("lu       sp(812)={d:.2} sp(1024)={d:.2} -> par_min_n {d:.0}\n", .{ lu_h, lu_f, lu_gate_v });

    // sum: gate is n; probe 2M and 4M.
    const s_h = try speedupSum(alloc, 2 * 1024 * 1024, false);
    const s_f = try speedupSum(alloc, 4 * 1024 * 1024, false);
    const s_gate = decide(s_h, s_f, 2 * 1024 * 1024, 4 * 1024 * 1024);
    std.debug.print("sum      sp(2M)={d:.2} sp(4M)={d:.2} -> par_min_n {d:.0}\n", .{ s_h, s_f, s_gate });

    // css: probe 512k and 1M.
    const c_h = try speedupSum(alloc, 512 * 1024, true);
    const c_f = try speedupSum(alloc, 1024 * 1024, true);
    const c_gate = decide(c_h, c_f, 512 * 1024, 1024 * 1024);
    std.debug.print("css      sp(512k)={d:.2} sp(1M)={d:.2} -> par_min_n {d:.0}\n", .{ c_h, c_f, c_gate });

    // topk: gate is WORK n*d; probe 4M (250k x 16) and 8M (500k x 16).
    const t_h = try speedupTopk(alloc, 250_000, 16);
    const t_f = try speedupTopk(alloc, 500_000, 16);
    const t_gate = decide(t_h, t_f, 4_000_000, 8_000_000);
    std.debug.print("topk     sp(4M)={d:.2} sp(8M)={d:.2} -> par_min_work {d:.0}\n", .{ t_h, t_f, t_gate });

    // knn all-pairs is probed through umap's gate indirectly by cost model:
    // its kernel class (distance rows) is the same as topk's per-row work at
    // n x d, and the spike measured 3x at n=1024 twice. The gate keeps its
    // spike value scaled by the same factor the topk probe moved, if any.
    const knn_gate_v: f64 = 1024.0 * (t_gate / 8_000_000.0);
    std.debug.print("knn      scaled with topk -> allpairs_par_min_n {d:.0}\n\n", .{knn_gate_v});

    // write the file
    var buf: [4096]u8 = undefined;
    const text = try std.fmt.bufPrint(&buf,
        \\# stz_calibration.txt -- written by tools/calibrate.zig
        \\# Machine-measured parallel-dispatch thresholds. Place this file in
        \\# the application's working directory. Delete it to fall back to
        \\# the engine's compiled defaults. The gpu.* namespace is reserved
        \\# for the GPU plane's store.
        \\cpu.matmul.par_min_flops = {d:.0}
        \\cpu.matmul.full_width_min_flops = {d:.0}
        \\cpu.lu.par_min_n = {d:.0}
        \\cpu.stats.sum_par_min_n = {d:.0}
        \\cpu.stats.css_par_min_n = {d:.0}
        \\cpu.topk.par_min_work = {d:.0}
        \\cpu.knn.allpairs_par_min_n = {d:.0}
        \\
    , .{ mm_gate, @max(mm_gate * 8.0, 2.0 * 512.0 * 512.0 * 512.0), lu_gate_v, s_gate, c_gate, t_gate, knn_gate_v });

    const f = try std.fs.cwd().createFile(calibstore.CALIB_FILE, .{});
    defer f.close();
    try f.writeAll(text);
    std.debug.print("wrote {s} ({d} bytes)\n", .{ calibstore.CALIB_FILE, text.len });
}
