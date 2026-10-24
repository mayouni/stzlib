//! gpu_peak_probe.zig -- GK3's first move: the COMPUTE PEAK of each adapter,
//! measured the way gpu_verify.zig measures its copy floor.
//!
//! WHY THIS FILE EXISTS. Every kernel this plane has ever timed is recorded as
//! "Nx the CPU" or "Nx the generic tile" -- never as a fraction of what the
//! hardware can do. GK0's roofline refuses a time that beats the BUS (copy
//! bandwidth, submit floor) and has no ceiling for ARITHMETIC: a candidate
//! claiming more FLOP/s than the device owns is not refused today. The peak
//! below is that ceiling, and the plan's tables read against it from GK3 on.
//!
//! WHAT IS MEASURED. A synthetic kernel whose only work is fused multiply-add
//! on registers: each thread carries CHAINS independent accumulators through
//! `iters` rounds of fma(x, m, b) with m and b taken from the params uniform
//! (so nothing folds at compile time) and writes their sum once. One float
//! read and one written per thread; everything else is arithmetic. FLOPs
//! counted as 2 per fma, the convention every published peak uses.
//!
//! HOW IT IS MEASURED. The house's method, not a new one: Wake(400) first (a
//! power-gated laptop GPU measured asleep measures its sleep); warm on both
//! arms; A B A B against the COPY kernel as the control section, so ambient
//! drift lands on both arms; warm-min; TWO clocks where the adapter has them
//! (wall around dispatch+sync, GPU timestamps inside the pass); and the
//! SPREAD (max - min of the reps) printed beside every minimum, because a
//! peak that is "about" is not a peak. Several `iters` sizes are run so the
//! reader sees the number saturate rather than trusting one point.
//!
//! STANDALONE. Not built by the default `zig build`; nothing links it. From
//! the engine folder:
//!
//!     zig build-exe src/gpu_peak_probe.zig -I vendor/wgpu/include -lc -O ReleaseFast
//!     ./gpu_peak_probe <absolute path to wgpu_native.dll> [--reps=7] [--ramp]
//!
//! It walks every adapter the instance enumerates (the discrete card and the
//! integrated one on this machine) and prints one block per adapter. ASCII
//! only on the console, by the house rule.

const std = @import("std");
const gpu = @import("gpu.zig");
const verify = @import("gpu_verify.zig");

const print = std.debug.print;

const WG: usize = 256;
const N_THREADS: usize = 4096 * WG; // 1,048,576 threads: enough waves for any adapter here
const ROUNDS = [_]u32{ 1024, 4096, 16384 }; // fma rounds per chain; iters = rounds / unroll

/// The variants: the loop's bookkeeping (counter, compare, branch) competes
/// with the fmas for issue slots, so a denser body reads closer to the ALU.
/// The peak is the best of them, and the memo names which.
const Variant = struct { chains: usize, unroll: usize, src: []const u8 };
// the last one is PEAK_WGSL itself -- the probe and the engine must agree
const VARIANTS = [_]Variant{
    .{ .chains = 8, .unroll = 1, .src = fmaSource(8, 1) },
    .{ .chains = 8, .unroll = 4, .src = fmaSource(8, 4) },
    .{ .chains = 16, .unroll = 4, .src = fmaSource(16, 4) },
    .{ .chains = 16, .unroll = 8, .src = fmaSource(16, 8) },
    .{ .chains = 32, .unroll = 8, .src = fmaSource(32, 8) },
    .{ .chains = verify.PEAK_CHAINS, .unroll = verify.PEAK_UNROLL, .src = verify.PEAK_WGSL },
};

const Params = verify.PeakParams;
const fmaSource = verify.fmaSource; // the checker's own builder; GK3 measures with its (16, 16)

const Stat = struct {
    min: f64 = std.math.inf(f64),
    max: f64 = -std.math.inf(f64),
    n: usize = 0,
    fn add(self: *Stat, v: f64) void {
        if (v < 0) return; // -1 = no second clock
        if (v < self.min) self.min = v;
        if (v > self.max) self.max = v;
        self.n += 1;
    }
    fn spread(self: Stat) f64 {
        return if (self.n > 0) self.max - self.min else 0;
    }
};

fn adapterName(idx: i32, buf: []u8) []const u8 {
    const n = gpu.stz_gpu_adapter_name(idx, buf.ptr, @intCast(buf.len));
    return buf[0..@intCast(@max(n, 0))];
}

fn gflops(flops: f64, ms: f64) f64 {
    return if (ms > 0) flops / (ms / 1000.0) / 1e9 else 0;
}

fn gbs(bytes: f64, ms: f64) f64 {
    return if (ms > 0) bytes / (ms / 1000.0) / 1e9 else 0;
}

fn runAdapter(idx: i32, reps: usize) !void {
    var nbuf: [256]u8 = undefined;
    const name = adapterName(idx, &nbuf);
    print("\n== adapter {d}: {s}\n", .{ idx, name });
    print("   clocks: {s}\n", .{if (gpu.hasTimestamps()) "2 (wall + GPU timestamps)" else "1 (wall only; no timestamp queries on this adapter)"});

    // Wake first and SAY how long it took: the awake threshold inside
    // stz_gpu_wake (32 MB under 2 ms) is a 3050 number, and an adapter that
    // passes it at once was never asleep by that definition -- or is slower
    // than the threshold awake, which the copy figure below then shows
    var wt = try std.time.Timer.start();
    const copies = verify.stz_gpu_wake(400);
    print("   wake: {d} copies in {d:.0} ms\n", .{ copies, @as(f64, @floatFromInt(wt.read())) / 1e6 });
    // the floors the checker already measures, for the record beside the peak
    const j = verify.stz_gpu_verify_judge(1e6, 1.0);
    if (j == verify.V_ERROR) {
        print("   floors: could not be measured (status {d}); adapter skipped\n", .{j});
        return;
    }
    print("   checker floors: copy {d:.1} GB/s, smallest dispatch {d:.3} ms, PEAK {d:.1} GFLOP/s (the engine's own measurement, 5 reps)\n", .{
        verify.stz_gpu_verify_result(verify.R_FLOOR_GBS),
        verify.stz_gpu_verify_result(verify.R_SUBMIT_FLOOR_MS),
        verify.stz_gpu_verify_result(verify.R_PEAK_GFLOPS),
    });
    const two = verify.ensureTs();

    // buffers: FMA in/out (4 MB each), copy in/out (16 MB each)
    const fbytes: f64 = @floatFromInt(N_THREADS * 4);
    const fa = gpu.stz_gpu_buffer_new(fbytes);
    const fo = gpu.stz_gpu_buffer_new(fbytes);
    const cbytes: f64 = @floatFromInt(verify.COPY_N * 4);
    const ca = gpu.stz_gpu_buffer_new(cbytes);
    const co = gpu.stz_gpu_buffer_new(cbytes);
    if (fa == 0 or fo == 0 or ca == 0 or co == 0) {
        print("   no device buffers; adapter skipped\n", .{});
        return;
    }
    defer _ = gpu.stz_gpu_buffer_free(fa);
    defer _ = gpu.stz_gpu_buffer_free(fo);
    defer _ = gpu.stz_gpu_buffer_free(ca);
    defer _ = gpu.stz_gpu_buffer_free(co);
    // seeds in [0, 1): the accumulators converge toward b / (1 - m) and never
    // leave f32's comfortable range, so there is no NaN to flatten the ALU
    const seeds = try std.heap.c_allocator.alloc(f32, N_THREADS);
    defer std.heap.c_allocator.free(seeds);
    var x: u32 = 12345;
    for (seeds) |*v| {
        x = x *% 1664525 +% 1013904223;
        v.* = @as(f32, @floatFromInt(x >> 8)) / 16777216.0;
    }
    if (gpu.stz_gpu_buffer_write(fa, @ptrCast(seeds.ptr), fbytes) != gpu.OK) return;

    const kcopy = gpu.stz_gpu_kernel_compile(verify.COPY_WGSL.ptr, @floatFromInt(verify.COPY_WGSL.len));
    if (kcopy == 0) {
        print("   copy kernel refused: {s}\n", .{gpu.firstError()});
        return;
    }
    const fids = [_]i64{ fa, fo };
    const cids = [_]i64{ ca, co };
    const wx_f: f64 = @floatFromInt(N_THREADS / WG);
    const wx_c: f64 = @floatFromInt(verify.COPY_N / WG);
    var best_wall: f64 = 0;
    var best_gpu: f64 = 0;
    var best_wall_spread: f64 = 0;
    var best_gpu_spread: f64 = 0;
    var best_rounds: u32 = 0;
    var best_variant: usize = 0;
    var copy_best: f64 = 0;
    var last_chains: usize = 8;

    for (VARIANTS, 0..) |vr, vi| {
        const kfma = gpu.stz_gpu_kernel_compile(vr.src.ptr, @floatFromInt(vr.src.len));
        if (kfma == 0) {
            print("   variant {d} chains x{d} unroll refused: {s}\n", .{ vr.chains, vr.unroll, gpu.firstError() });
            continue;
        }
        last_chains = vr.chains;
        const flops_per_round: f64 = @floatFromInt(N_THREADS * vr.chains * 2);
        print("\n   variant: {d} chains, body unrolled x{d} ({d} fma per loop round)\n", .{ vr.chains, vr.unroll, vr.chains * vr.unroll });
        print("   {s:>7} | {s:>9} {s:>8} {s:>9} | {s:>9} {s:>8} {s:>9} | {s:>9} {s:>8}\n", .{ "rounds", "wall ms", "spread", "GFLOP/s", "gpu ms", "spread", "GFLOP/s", "copy GB/s", "spread" });
        print("   {s}\n", .{"-" ** 96});

        for (ROUNDS) |rounds| {
            const iters: u32 = @max(1, rounds / @as(u32, @intCast(vr.unroll)));
            const prm = Params{ .iters = iters, .n = @intCast(N_THREADS), .m = 0.999, .b = 0.001 };
            const pbytes = std.mem.asBytes(&prm);
            const flops = flops_per_round * @as(f64, @floatFromInt(iters * @as(u32, @intCast(vr.unroll))));

            // warm both arms once: the compile cache is a feature and a confound
            var g: f64 = 0;
            _ = verify.timedDispatch(kfma, pbytes, &fids, wx_f, false, &g) orelse {
                print("   fma dispatch refused: {s}\n", .{gpu.lastError()});
                return;
            };
            _ = gpu.stz_gpu_dispatch(kcopy, &cids, 2, wx_c, 1);
            _ = gpu.stz_gpu_sync();

            var fw = Stat{};
            var fg = Stat{};
            var cw = Stat{};
            var reps_gpu: [32]f64 = @splat(0);
            var r: usize = 0;
            while (r < reps) : (r += 1) {
                // A: the FMA kernel
                var gms: f64 = -1;
                const wms = verify.timedDispatch(kfma, pbytes, &fids, wx_f, two, &gms) orelse return;
                fw.add(wms);
                fg.add(gms);
                if (r < reps_gpu.len) reps_gpu[r] = if (gms >= 0) gms else wms;
                // B: the copy kernel, the control
                var t = try std.time.Timer.start();
                if (gpu.stz_gpu_dispatch(kcopy, &cids, 2, wx_c, 1) != gpu.OK) return;
                if (gpu.stz_gpu_sync() != gpu.OK) return;
                cw.add(@as(f64, @floatFromInt(t.read())) / 1e6);
            }

            const gf_wall = gflops(flops, fw.min);
            const gf_gpu = if (fg.n > 0) gflops(flops, fg.min) else 0;
            const copy_gbs = gbs(2.0 * cbytes, cw.min);
            if (fg.n > 0) {
                print("   {d:>7} | {d:>9.3} {d:>8.3} {d:>9.1} | {d:>9.3} {d:>8.3} {d:>9.1} | {d:>9.1} {d:>8.3}\n", .{ rounds, fw.min, fw.spread(), gf_wall, fg.min, fg.spread(), gf_gpu, copy_gbs, cw.spread() });
            } else {
                print("   {d:>7} | {d:>9.3} {d:>8.3} {d:>9.1} | {s:>9} {s:>8} {s:>9} | {d:>9.1} {d:>8.3}\n", .{ rounds, fw.min, fw.spread(), gf_wall, "-", "-", "-", copy_gbs, cw.spread() });
            }
            print("           reps ({s} ms):", .{if (fg.n > 0) "gpu" else "wall"});
            for (0..@min(reps, reps_gpu.len)) |k| print(" {d:.2}", .{reps_gpu[k]});
            print("\n", .{});
            if (gf_wall > best_wall) {
                best_wall = gf_wall;
                best_wall_spread = fw.spread();
                best_rounds = rounds;
                best_variant = vi;
            }
            if (gf_gpu > best_gpu) {
                best_gpu = gf_gpu;
                best_gpu_spread = fg.spread();
            }
            if (copy_gbs > copy_best) copy_best = copy_gbs;
        }
    }

    // the correctness check nobody asked for and the probe owes anyway: the
    // output converged where the recurrence says it must
    const out = try std.heap.c_allocator.alloc(f32, 8);
    defer std.heap.c_allocator.free(out);
    _ = gpu.stz_gpu_buffer_read(fo, @ptrCast(out.ptr), 32);
    print("\n   first outputs: {d:.4} {d:.4} {d:.4} (expected near {d:.3} = chains * b/(1-m), last variant)\n", .{ out[0], out[1], out[2], @as(f64, @floatFromInt(last_chains)) * 0.001 / (1.0 - 0.999) });

    const bv = VARIANTS[best_variant];
    print("   PEAK  wall clock: {d:.1} GFLOP/s (spread {d:.3} ms; {d} chains x{d} unroll, {d} rounds)\n", .{ best_wall, best_wall_spread, bv.chains, bv.unroll, best_rounds });
    if (best_gpu > 0) {
        print("   PEAK  GPU clock : {d:.1} GFLOP/s (spread {d:.3} ms)\n", .{ best_gpu, best_gpu_spread });
    } else {
        print("   PEAK  GPU clock : one clock only; the wall number is the record\n", .{});
    }
    print("   COPY  best      : {d:.1} GB/s (16 MB in + 16 MB out, warm-min)\n", .{copy_best});
    print("   2 FLOP per fma; {d} threads; reps {d}; copy = 16 MB in + 16 MB out\n", .{ N_THREADS, reps });
}

/// --ramp: how the device's clock rises under sustained work, measured, so
/// the settle rules in stz_gpu_wake and measurePeak are chosen from data.
/// 400 back-to-back copies, then 300 back-to-back dense dispatches; the
/// min of every window of 20 (copies) / 10 (dispatches) is printed.
fn rampAdapter(idx: i32) !void {
    var nbuf: [256]u8 = undefined;
    print("\n== RAMP adapter {d}: {s}\n", .{ idx, adapterName(idx, &nbuf) });
    const cbytes: f64 = @floatFromInt(verify.COPY_N * 4);
    const ca = gpu.stz_gpu_buffer_new(cbytes);
    const co = gpu.stz_gpu_buffer_new(cbytes);
    const pbytes: f64 = @floatFromInt(verify.PEAK_THREADS * 4);
    const pa = gpu.stz_gpu_buffer_new(pbytes);
    const po = gpu.stz_gpu_buffer_new(pbytes);
    if (ca == 0 or co == 0 or pa == 0 or po == 0) return;
    defer _ = gpu.stz_gpu_buffer_free(ca);
    defer _ = gpu.stz_gpu_buffer_free(co);
    defer _ = gpu.stz_gpu_buffer_free(pa);
    defer _ = gpu.stz_gpu_buffer_free(po);
    const kcopy = gpu.stz_gpu_kernel_compile(verify.COPY_WGSL.ptr, @floatFromInt(verify.COPY_WGSL.len));
    const kpeak = gpu.stz_gpu_kernel_compile(verify.PEAK_WGSL.ptr, @floatFromInt(verify.PEAK_WGSL.len));
    if (kcopy == 0 or kpeak == 0) return;
    const cids = [_]i64{ ca, co };
    const pids = [_]i64{ pa, po };
    const wx_c: f64 = @floatFromInt(verify.COPY_N / WG);
    const wx_p: f64 = @floatFromInt(verify.PEAK_THREADS / WG);
    const two = verify.ensureTs();

    print("   copies, 32 MB each, min ms per window of 20 (GB/s):\n   ", .{});
    var total = try std.time.Timer.start();
    var w: usize = 0;
    while (w < 20) : (w += 1) {
        var best: f64 = std.math.inf(f64);
        var k: usize = 0;
        while (k < 20) : (k += 1) {
            var t = try std.time.Timer.start();
            if (gpu.stz_gpu_dispatch(kcopy, &cids, 2, wx_c, 1) != gpu.OK) return;
            if (gpu.stz_gpu_sync() != gpu.OK) return;
            const ms = @as(f64, @floatFromInt(t.read())) / 1e6;
            if (ms < best) best = ms;
        }
        print(" {d:.2}({d:.0})", .{ best, gbs(2.0 * cbytes, best) });
    }
    print("\n   400 copies in {d:.0} ms\n", .{@as(f64, @floatFromInt(total.read())) / 1e6});

    const prm = Params{ .iters = verify.PEAK_ROUNDS / @as(u32, @intCast(verify.PEAK_UNROLL)), .n = @intCast(verify.PEAK_THREADS), .m = 0.999, .b = 0.001 };
    const pb = std.mem.asBytes(&prm);
    print("   dense fma dispatches (1024 rounds), min {s} ms per window of 10 (GFLOP/s):\n   ", .{if (two) "gpu" else "wall"});
    total = try std.time.Timer.start();
    w = 0;
    while (w < 30) : (w += 1) {
        var best: f64 = std.math.inf(f64);
        var k: usize = 0;
        while (k < 10) : (k += 1) {
            var gms: f64 = -1;
            const wall = verify.timedDispatch(kpeak, pb, &pids, wx_p, two, &gms) orelse return;
            const t = if (gms > 0) gms else wall;
            if (t < best) best = t;
        }
        print(" {d:.2}({d:.0})", .{ best, gflops(verify.PEAK_FLOPS, best) });
    }
    print("\n   300 dispatches in {d:.0} ms\n", .{@as(f64, @floatFromInt(total.read())) / 1e6});
}

pub fn main() !void {
    const alloc = std.heap.c_allocator;
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);
    var dll: []const u8 = "vendor/wgpu/lib/wgpu_native.dll";
    var reps: usize = 7;
    var ramp = false;
    for (args[1..]) |a| {
        if (std.mem.startsWith(u8, a, "--reps=")) {
            reps = @min(32, try std.fmt.parseInt(usize, a["--reps=".len..], 10));
        } else if (std.mem.eql(u8, a, "--ramp")) {
            ramp = true;
        } else dll = a;
    }
    const dllz = try alloc.dupeZ(u8, dll);
    defer alloc.free(dllz);

    print("gpu_peak_probe -- GK3 first move: compute peak per adapter, A B A B against the copy kernel\n", .{});
    print("wgpu runtime: {s}\n", .{dll});
    if (gpu.stz_gpu_init(dllz.ptr) == 0) {
        print("no device: {s}\n", .{gpu.lastError()});
        return;
    }
    const count = gpu.stz_gpu_adapter_count();
    print("adapters enumerated: {d}\n", .{count});

    var i: i32 = 0;
    while (i < count) : (i += 1) {
        if (gpu.stz_gpu_select_adapter(i) == 0) {
            var nb: [256]u8 = undefined;
            print("\n== adapter {d}: {s} -- no device ({s})\n", .{ i, adapterName(i, &nb), gpu.lastError() });
            continue;
        }
        if (ramp) try rampAdapter(i) else try runAdapter(i, reps);
    }
    gpu.stz_gpu_shutdown();
}
