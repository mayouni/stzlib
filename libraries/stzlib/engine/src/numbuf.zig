// Softanza Engine -- StzNumBuffer: a RESIDENT contiguous f64 buffer.
//
// THE MEASUREMENT THIS EXISTS FOR (SOFTANZA_NUMERIC_FOUNDATION.md 2.5): over
// 200 000 numbers, a Ring loop computing mean+variance took 0.04s and the engine
// took 0.04s -- NO FASTER -- because StatsCreate alone (the marshalling) was the
// entire 0.04s. Twenty means on a WARM handle cost 0.01s in total.
//
// So the crossing is the cost, and a faster kernel behind a per-call marshalling
// boundary buys almost nothing. Residency is not an optimisation of this plane;
// it is the precondition for the rest of it.
//
// What this module gives Ring is a buffer the ENGINE owns: filled in one crossing,
// operated on any number of times at engine speed with no crossing at all, and
// read back once when the answer is wanted. Every operation below either mutates
// the buffer in place or returns a scalar -- neither marshals.
//
// The element type is f64 throughout. A number that reaches here has already left
// the exact world of phase 1 (rationals, scaled decimals); this is the measured,
// bulk tier, and pretending otherwise would be the dishonest kind of convenience.
//
// C ABI: stz_numbuf_* prefix. Handles are opaque pointers.

const std = @import("std");
const allocator = std.heap.c_allocator;
const stats = @import("stats.zig");

pub const StzNumBuffer = struct {
    data: []f64,

    pub fn init(n: usize) !*StzNumBuffer {
        const self = try allocator.create(StzNumBuffer);
        self.data = allocator.alloc(f64, n) catch {
            allocator.destroy(self);
            return error.OutOfMemory;
        };
        @memset(self.data, 0);
        return self;
    }

    pub fn deinit(self: *StzNumBuffer) void {
        allocator.free(self.data);
        allocator.destroy(self);
    }
};

// ─── Lifecycle ───

pub fn stz_numbuf_new(n: usize) callconv(.c) ?*StzNumBuffer {
    return StzNumBuffer.init(n) catch null;
}

pub fn stz_numbuf_free(b: ?*StzNumBuffer) callconv(.c) void {
    const buf = b orelse return;
    buf.deinit();
}

pub fn stz_numbuf_len(b: ?*const StzNumBuffer) callconv(.c) usize {
    const buf = b orelse return 0;
    return buf.data.len;
}

pub fn stz_numbuf_clone(b: ?*const StzNumBuffer) callconv(.c) ?*StzNumBuffer {
    const src = b orelse return null;
    const out = StzNumBuffer.init(src.data.len) catch return null;
    @memcpy(out.data, src.data);
    return out;
}

// ─── Element access (1-BASED, matching Ring and the rest of Softanza) ───

pub fn stz_numbuf_get(b: ?*const StzNumBuffer, i: usize) callconv(.c) f64 {
    const buf = b orelse return 0;
    if (i == 0 or i > buf.data.len) return 0;
    return buf.data[i - 1];
}

pub fn stz_numbuf_set(b: ?*StzNumBuffer, i: usize, v: f64) callconv(.c) i32 {
    const buf = b orelse return 0;
    if (i == 0 or i > buf.data.len) return 0;
    buf.data[i - 1] = v;
    return 1;
}

// ─── Filling, without a crossing per element ───

pub fn stz_numbuf_fill(b: ?*StzNumBuffer, v: f64) callconv(.c) void {
    const buf = b orelse return;
    @memset(buf.data, v);
}

/// 1, 2, 3, ... n -- built HERE rather than marshalled from a Ring list, which is
/// the difference between one crossing and none.
pub fn stz_numbuf_range(b: ?*StzNumBuffer, start: f64, step: f64) callconv(.c) void {
    const buf = b orelse return;
    var v = start;
    for (buf.data) |*slot| {
        slot.* = v;
        v += step;
    }
}

// ─── Elementwise, IN PLACE: the whole point ───
//
// Each of these is a full pass over resident memory with no marshalling at either
// end, so a chain of them costs one crossing in total rather than one per step.

pub fn stz_numbuf_add_scalar(b: ?*StzNumBuffer, v: f64) callconv(.c) void {
    const buf = b orelse return;
    for (buf.data) |*x| x.* += v;
}

pub fn stz_numbuf_scale(b: ?*StzNumBuffer, v: f64) callconv(.c) void {
    const buf = b orelse return;
    for (buf.data) |*x| x.* *= v;
}

pub fn stz_numbuf_add(b: ?*StzNumBuffer, other: ?*const StzNumBuffer) callconv(.c) i32 {
    const buf = b orelse return 0;
    const o = other orelse return 0;
    if (buf.data.len != o.data.len) return 0;
    for (buf.data, o.data) |*x, y| x.* += y;
    return 1;
}

pub fn stz_numbuf_sub(b: ?*StzNumBuffer, other: ?*const StzNumBuffer) callconv(.c) i32 {
    const buf = b orelse return 0;
    const o = other orelse return 0;
    if (buf.data.len != o.data.len) return 0;
    for (buf.data, o.data) |*x, y| x.* -= y;
    return 1;
}

pub fn stz_numbuf_mul(b: ?*StzNumBuffer, other: ?*const StzNumBuffer) callconv(.c) i32 {
    const buf = b orelse return 0;
    const o = other orelse return 0;
    if (buf.data.len != o.data.len) return 0;
    for (buf.data, o.data) |*x, y| x.* *= y;
    return 1;
}

// ─── Reductions: a scalar out, nothing marshalled ───

/// Summed with NEUMAIER COMPENSATION -- see stats.compensatedSum, which is the
/// one place that summation is defined. This buffer had its own copy of the
/// algorithm briefly, which is how the library ended up with two answers for the
/// same 1001 numbers; the copy is gone.
pub fn stz_numbuf_sum(b: ?*const StzNumBuffer) callconv(.c) f64 {
    const buf = b orelse return 0;
    return stats.compensatedSum(buf.data);
}

pub fn stz_numbuf_mean(b: ?*const StzNumBuffer) callconv(.c) f64 {
    const buf = b orelse return 0;
    if (buf.data.len == 0) return 0;
    return stz_numbuf_sum(buf) / @as(f64, @floatFromInt(buf.data.len));
}

pub fn stz_numbuf_min(b: ?*const StzNumBuffer) callconv(.c) f64 {
    const buf = b orelse return 0;
    if (buf.data.len == 0) return 0;
    var m = buf.data[0];
    for (buf.data) |x| {
        if (x < m) m = x;
    }
    return m;
}

pub fn stz_numbuf_max(b: ?*const StzNumBuffer) callconv(.c) f64 {
    const buf = b orelse return 0;
    if (buf.data.len == 0) return 0;
    var m = buf.data[0];
    for (buf.data) |x| {
        if (x > m) m = x;
    }
    return m;
}

pub fn stz_numbuf_dot(b: ?*const StzNumBuffer, other: ?*const StzNumBuffer) callconv(.c) f64 {
    const buf = b orelse return 0;
    const o = other orelse return 0;
    if (buf.data.len != o.data.len) return 0;
    var sum: f64 = 0;
    for (buf.data, o.data) |x, y| sum += x * y;
    return sum;
}

/// Variance, WITH THE CONVENTION ASKED OF THE ONE AUTHORITY (stats.zig), not
/// decided again here -- the phase-0 repair exists precisely because two modules
/// once chose their own divisor. kind: 0 = population, 1 = sample.
pub fn stz_numbuf_variance(b: ?*const StzNumBuffer, kind: i32) callconv(.c) f64 {
    const buf = b orelse return 0;
    const k: stats.VarianceKind = if (kind == 0) .population else .sample;
    // the whole calculation is asked of stats.varianceOf -- compensated mean,
    // vectorised centered sum of squares, named divisor. This module used to
    // assemble those three pieces itself, which is how a fifth copy of the sum of
    // squares came to exist.
    return stats.varianceOf(buf.data, k);
}

pub fn stz_numbuf_stddev(b: ?*const StzNumBuffer, kind: i32) callconv(.c) f64 {
    return @sqrt(stz_numbuf_variance(b, kind));
}

// ─── Tests ───

const testing = std.testing;

test "numbuf: fill, range and element access are 1-based" {
    const b = stz_numbuf_new(5) orelse return error.AllocFailed;
    defer stz_numbuf_free(b);
    try testing.expectEqual(@as(usize, 5), stz_numbuf_len(b));

    stz_numbuf_range(b, 1, 1);
    try testing.expectEqual(@as(f64, 1), stz_numbuf_get(b, 1));
    try testing.expectEqual(@as(f64, 5), stz_numbuf_get(b, 5));
    // out of range answers 0 rather than trapping
    try testing.expectEqual(@as(f64, 0), stz_numbuf_get(b, 0));
    try testing.expectEqual(@as(f64, 0), stz_numbuf_get(b, 6));

    try testing.expectEqual(@as(i32, 1), stz_numbuf_set(b, 3, 99));
    try testing.expectEqual(@as(f64, 99), stz_numbuf_get(b, 3));
    try testing.expectEqual(@as(i32, 0), stz_numbuf_set(b, 6, 1));
}

test "numbuf: elementwise ops stay resident" {
    const b = stz_numbuf_new(4) orelse return error.AllocFailed;
    defer stz_numbuf_free(b);
    stz_numbuf_range(b, 1, 1); // 1 2 3 4

    stz_numbuf_scale(b, 2); // 2 4 6 8
    stz_numbuf_add_scalar(b, 1); // 3 5 7 9
    try testing.expectEqual(@as(f64, 3), stz_numbuf_get(b, 1));
    try testing.expectEqual(@as(f64, 9), stz_numbuf_get(b, 4));
    try testing.expectEqual(@as(f64, 24), stz_numbuf_sum(b));

    const o = stz_numbuf_new(4) orelse return error.AllocFailed;
    defer stz_numbuf_free(o);
    stz_numbuf_fill(o, 1);
    try testing.expectEqual(@as(i32, 1), stz_numbuf_add(b, o)); // 4 6 8 10
    try testing.expectEqual(@as(f64, 28), stz_numbuf_sum(b));

    // a length mismatch is refused rather than half-applied
    const short = stz_numbuf_new(2) orelse return error.AllocFailed;
    defer stz_numbuf_free(short);
    try testing.expectEqual(@as(i32, 0), stz_numbuf_add(b, short));
    try testing.expectEqual(@as(f64, 28), stz_numbuf_sum(b));
}

test "numbuf: the compensated sum survives what a naive one loses" {
    const b = stz_numbuf_new(1001) orelse return error.AllocFailed;
    defer stz_numbuf_free(b);
    // 1e16 followed by a thousand 1.0s. Every 1.0 is below the mantissa's reach
    // once the total is 1e16, so a naive running total answers exactly 1e16.
    stz_numbuf_fill(b, 1);
    _ = stz_numbuf_set(b, 1, 1e16);

    var naive: f64 = 0;
    for (b.data) |x| naive += x;
    try testing.expectEqual(@as(f64, 1e16), naive); // the loss, demonstrated

    try testing.expectEqual(@as(f64, 1e16 + 1000), stz_numbuf_sum(b));
}

test "numbuf: variance asks stats.zig for the convention" {
    const b = stz_numbuf_new(8) orelse return error.AllocFailed;
    defer stz_numbuf_free(b);
    const vals = [_]f64{ 2, 4, 4, 4, 5, 5, 7, 9 };
    for (vals, 1..) |v, i| _ = stz_numbuf_set(b, i, v);

    try testing.expectEqual(@as(f64, 4), stz_numbuf_variance(b, 0)); // population
    try testing.expectApproxEqAbs(@as(f64, 32.0 / 7.0), stz_numbuf_variance(b, 1), 1e-12);
    try testing.expectEqual(@as(f64, 2), stz_numbuf_stddev(b, 0));
}

test "numbuf: dot and the reductions" {
    const a = stz_numbuf_new(3) orelse return error.AllocFailed;
    defer stz_numbuf_free(a);
    const c = stz_numbuf_new(3) orelse return error.AllocFailed;
    defer stz_numbuf_free(c);
    stz_numbuf_range(a, 1, 1); // 1 2 3
    stz_numbuf_range(c, 4, 1); // 4 5 6

    try testing.expectEqual(@as(f64, 32), stz_numbuf_dot(a, c)); // 4+10+18
    try testing.expectEqual(@as(f64, 1), stz_numbuf_min(a));
    try testing.expectEqual(@as(f64, 3), stz_numbuf_max(a));
    try testing.expectEqual(@as(f64, 2), stz_numbuf_mean(a));
}
