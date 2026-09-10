// GS6c's experiment (2026-09-10): is the device route's lower purity the
// SYNCHRONOUS update (Jacobi) or something else? The CPU's own loop run three
// ways on the same graph, same seed -- sequential (as shipped), Jacobi, and
// Jacobi with the attraction halved per endpoint -- 5-NN blob purity after
// 200 epochs, four blobs in 8 dims:
//
//     n        sequential   jacobi   jacobi, attraction halved
//     1,000      0.997      0.979      1.000
//     4,000      0.982      0.951      0.972
//
// The device's gather kernel (umap_gpu.zig) is the third column. Kept as the
// evidence for that choice; the GS6 spike's precedent for a tool in src/.
//
//   zig build-exe -j2 src/gs6c_probe.zig -OReleaseSafe -I vendor/wgpu/include -lc --name gs6c_probe
const std = @import("std");
const umap = @import("umap.zig");

fn blobs(a: std.mem.Allocator, n: usize, d: usize) ![]f64 {
    const x = try a.alloc(f64, n * d);
    for (0..n) |i| {
        const b: f64 = @floatFromInt(i % 4);
        for (0..d) |k| {
            const kk: f64 = @floatFromInt(k + 1);
            const par: f64 = @floatFromInt(@as(usize, @intFromFloat(kk + b)) % 2);
            x[i * d + k] = b * 4 * par + @sin(@as(f64, @floatFromInt(i + 1)) * 0.731 + kk * 1.37) * 0.5;
        }
    }
    return x;
}

fn clip(v: f64) f64 {
    if (v > 4) return 4;
    if (v < -4) return -4;
    return v;
}

const Rng = struct {
    state: u64,
    fn next(self: *Rng) u64 {
        self.state ^= self.state << 13;
        self.state ^= self.state >> 7;
        self.state ^= self.state << 17;
        return self.state;
    }
    fn uniform(self: *Rng) f64 {
        return @as(f64, @floatFromInt(self.next() >> 11)) / 9007199254740992.0;
    }
    fn below(self: *Rng, n: usize) usize {
        return @intCast(self.next() % @as(u64, @intCast(n)));
    }
};

fn purity(y: []const f64, n: usize) f64 {
    var hits: usize = 0;
    var i: usize = 0;
    var q: usize = 0;
    while (i < n) : (i += 5) {
        q += 1;
        var bd: [5]f64 = .{ 1e300, 1e300, 1e300, 1e300, 1e300 };
        var bb: [5]usize = .{ 0, 0, 0, 0, 0 };
        for (0..n) |j| {
            if (j == i) continue;
            const dx = y[i * 2] - y[j * 2];
            const dy = y[i * 2 + 1] - y[j * 2 + 1];
            const d = dx * dx + dy * dy;
            if (d < bd[4]) {
                var pos: usize = 4;
                while (pos > 0 and bd[pos - 1] > d) : (pos -= 1) {
                    bd[pos] = bd[pos - 1];
                    bb[pos] = bb[pos - 1];
                }
                bd[pos] = d;
                bb[pos] = j % 4;
            }
        }
        for (bb) |b| {
            if (b == i % 4) hits += 1;
        }
    }
    return @as(f64, @floatFromInt(hits)) / @as(f64, @floatFromInt(q * 5));
}

fn runLoop(a: std.mem.Allocator, g: *const umap.Graph, n: usize, mode: u8, epochs: usize, seed: u64) ![]f64 {
    const dims = 2;
    const y = try a.alloc(f64, n * dims);
    var rng = Rng{ .state = seed };
    for (y) |*v| v.* = (rng.uniform() * 20) - 10;
    const edges = g.edges.items;
    const eps = try a.alloc(f64, edges.len);
    defer a.free(eps);
    const ns = try a.alloc(f64, edges.len);
    defer a.free(ns);
    for (edges, 0..) |e, i| {
        eps[i] = g.wmax / e.w;
        ns[i] = eps[i];
    }
    const acc = try a.alloc(f64, n * dims);
    defer a.free(acc);
    const A = g.a;
    const B = g.b;
    for (0..epochs) |epoch| {
        const alpha = 1.0 - @as(f64, @floatFromInt(epoch)) / @as(f64, @floatFromInt(epochs));
        @memset(acc, 0);
        const half: f64 = if (mode == 2) 0.5 else 1.0;
        for (edges, 0..) |e, ei| {
            if (ns[ei] > @as(f64, @floatFromInt(epoch + 1))) continue;
            ns[ei] += eps[ei];
            const ii: usize = e.i;
            const jj: usize = e.j;
            const yi = y[ii * dims ..][0..dims];
            const yj = y[jj * dims ..][0..dims];
            var d2 = umap.sqDist(yi, yj);
            if (d2 > 0) {
                const gc = (-2.0 * A * B * std.math.pow(f64, d2, B - 1.0)) / (A * std.math.pow(f64, d2, B) + 1.0);
                for (0..dims) |t| {
                    const gg = clip(gc * (yi[t] - yj[t]));
                    if (mode == 0) {
                        y[ii * dims + t] += gg * alpha;
                        y[jj * dims + t] -= gg * alpha;
                    } else {
                        acc[ii * dims + t] += gg * alpha * half;
                        acc[jj * dims + t] -= gg * alpha * half;
                    }
                }
            }
            var s: usize = 0;
            while (s < 5) : (s += 1) {
                const kk = rng.below(n);
                if (kk == ii or kk == jj) continue;
                const yk = y[kk * dims ..][0..dims];
                d2 = umap.sqDist(yi, yk);
                var gc: f64 = 4.0;
                if (d2 > 0) gc = (2.0 * B) / ((0.001 + d2) * (A * std.math.pow(f64, d2, B) + 1.0));
                for (0..dims) |t| {
                    const gg = clip(gc * (yi[t] - yk[t])) * alpha;
                    if (mode == 0) y[ii * dims + t] += gg else acc[ii * dims + t] += gg;
                }
            }
        }
        if (mode != 0) {
            for (y, acc) |*v, d| v.* += d;
        }
    }
    return y;
}

pub fn main() !void {
    const a = std.heap.c_allocator;
    const sizes = [_]usize{ 1000, 4000 };
    for (sizes) |n| {
        const x = try blobs(a, n, 8);
        var g = try umap.buildGraph(a, x, n, 8, null, .{});
        defer g.deinit();
        const names = [_][]const u8{ "sequential", "jacobi", "jacobi-half-attract" };
        for (0..3) |mode| {
            const y = try runLoop(a, &g, n, @intCast(mode), 200, 7);
            std.debug.print("n={d} {s}: purity {d:.4}{c}", .{ n, names[mode], purity(y, n), @as(u8, 10) });
            a.free(y);
        }
    }
}
