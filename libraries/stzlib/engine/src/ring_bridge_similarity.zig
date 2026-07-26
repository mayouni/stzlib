const R = @import("ring_api.zig");
const mod = @import("similarity.zig");
const std = @import("std");

const gn = R.ring_vm_api_getnumber;
const gl = R.ring_vm_api_getlist;
const rn = R.ring_vm_api_retnumber;
const allocator = std.heap.c_allocator;

// PHASE 4 SLICE 6. Until now this bridge exposed ONLY fixed 3-dimension variants,
// which is why similarity.zig's 1024-element cap had never fired in practice: Ring
// could not reach it. Three components is a geometry demo, not an embedding -- real
// sentence embeddings are 384, 768, 1024 or 1536 -- so the general forms below are
// what makes the module usable at all, and the cap had to go in the same slice or
// widening the door would have turned a latent silent-zero into a live one.
//
// The 3-argument forms are kept: they are a published surface, they are what the
// existing tests call, and a caller with three numbers should not have to build a
// list.

fn listToF64(p: *anyopaque, param: c_int) ?[]f64 {
    const lst = gl(p, param) orelse return null;
    const n: usize = @intCast(R.ringListSize(lst));
    if (n == 0) return null;
    const arr = allocator.alloc(f64, n) catch return null;
    for (0..n) |i| {
        const item = R.ring_list_getitem_gc(null, lst, @intCast(i + 1)) orelse {
            arr[i] = 0;
            continue;
        };
        arr[i] = R.ring_item_getnumber(item);
    }
    return arr;
}

/// Marshal both lists, apply the metric, free. The two must be the same length --
/// a mismatch answers 0 rather than reading past the shorter one.
fn pairMetric(p: *anyopaque, comptime f: fn ([*]const f64, [*]const f64, i32) callconv(.c) f64) void {
    const a = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(a);
    const b = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(b);
    if (a.len != b.len) {
        rn(p, 0);
        return;
    }
    rn(p, f(a.ptr, b.ptr, @intCast(a.len)));
}

fn ring_Cosine(p: *anyopaque) callconv(.c) void {
    pairMetric(p, mod.stz_sim_cosine);
}
fn ring_Euclidean(p: *anyopaque) callconv(.c) void {
    pairMetric(p, mod.stz_sim_euclidean);
}
fn ring_Manhattan(p: *anyopaque) callconv(.c) void {
    pairMetric(p, mod.stz_sim_manhattan);
}
fn ring_DotProduct(p: *anyopaque) callconv(.c) void {
    pairMetric(p, mod.stz_sim_dot_product);
}

/// The magnitude of a vector, which is what normalize divides by. Returning the
/// magnitude rather than a normalised copy keeps this bridge allocation-free on the
/// way out; a caller wanting the unit vector divides.
fn ring_Magnitude(p: *anyopaque) callconv(.c) void {
    const a = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(a);
    const zero = allocator.alloc(f64, a.len) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(zero);
    @memset(zero, 0);
    rn(p, mod.stz_sim_euclidean(a.ptr, zero.ptr, @intCast(a.len)));
}

// ─── The original fixed-arity forms, unchanged ───

fn ring_Cosine3(p: *anyopaque) callconv(.c) void {
    var a = [3]f64{ gn(p, 1), gn(p, 2), gn(p, 3) };
    var b = [3]f64{ gn(p, 4), gn(p, 5), gn(p, 6) };
    rn(p, mod.stz_sim_cosine(&a, &b, 3));
}

fn ring_Euclidean3(p: *anyopaque) callconv(.c) void {
    var a = [3]f64{ gn(p, 1), gn(p, 2), gn(p, 3) };
    var b = [3]f64{ gn(p, 4), gn(p, 5), gn(p, 6) };
    rn(p, mod.stz_sim_euclidean(&a, &b, 3));
}

fn ring_Manhattan3(p: *anyopaque) callconv(.c) void {
    var a = [3]f64{ gn(p, 1), gn(p, 2), gn(p, 3) };
    var b = [3]f64{ gn(p, 4), gn(p, 5), gn(p, 6) };
    rn(p, mod.stz_sim_manhattan(&a, &b, 3));
}

fn ring_DotProduct3(p: *anyopaque) callconv(.c) void {
    var a = [3]f64{ gn(p, 1), gn(p, 2), gn(p, 3) };
    var b = [3]f64{ gn(p, 4), gn(p, 5), gn(p, 6) };
    rn(p, mod.stz_sim_dot_product(&a, &b, 3));
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzenginesimcosine", .func = ring_Cosine },
    .{ .name = "stzenginesimeuclidean", .func = ring_Euclidean },
    .{ .name = "stzenginesimmanhattan", .func = ring_Manhattan },
    .{ .name = "stzenginesimdotproduct", .func = ring_DotProduct },
    .{ .name = "stzenginesimmagnitude", .func = ring_Magnitude },
    .{ .name = "stzenginesimcosine3", .func = ring_Cosine3 },
    .{ .name = "stzenginesimeuclidean3", .func = ring_Euclidean3 },
    .{ .name = "stzenginesimmanhattan3", .func = ring_Manhattan3 },
    .{ .name = "stzenginesimdotproduct3", .func = ring_DotProduct3 },
};
