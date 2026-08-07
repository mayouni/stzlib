const random = @import("random.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_Seed(p: *anyopaque) callconv(.c) void {
    random.stz_random_seed(@intFromFloat(g(p, 1)));
}

fn ring_Int(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(random.stz_random_int(@intFromFloat(g(p, 1)), @intFromFloat(g(p, 2)))));
}

fn ring_Float(p: *anyopaque) callconv(.c) void {
    rn(p, random.stz_random_float(g(p, 1), g(p, 2)));
}

fn ring_Bool(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(random.stz_random_bool(g(p, 1))));
}

fn ring_Gauss(p: *anyopaque) callconv(.c) void {
    rn(p, random.stz_random_gauss(g(p, 1), g(p, 2)));
}

fn ring_Exp(p: *anyopaque) callconv(.c) void {
    rn(p, random.stz_random_exp(g(p, 1)));
}

// Bulk draws return a NATIVE Ring list built engine-side (newlist +
// adddouble + retlist) -- one FFI call for n draws instead of n round
// trips. The callee holds nothing that must be freed before returning, so
// this is the shape that measured FASTEST for value results; the older
// comma-separated-string bulk return above predates that measurement and
// is kept only for its existing callers.
fn retDoubles(p: *anyopaque, vals: []const f64) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (vals) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

fn ring_NGauss(p: *anyopaque) callconv(.c) void {
    const std = @import("std");
    const n: usize = @intFromFloat(g(p, 1));
    if (n == 0 or n > 10_000_000) {
        retDoubles(p, &[_]f64{});
        return;
    }
    const buf = std.heap.c_allocator.alloc(f64, n) catch {
        retDoubles(p, &[_]f64{});
        return;
    };
    defer std.heap.c_allocator.free(buf);
    _ = random.stz_random_n_gauss(n, g(p, 2), g(p, 3), buf.ptr);
    retDoubles(p, buf);
}

fn ring_NExp(p: *anyopaque) callconv(.c) void {
    const std = @import("std");
    const n: usize = @intFromFloat(g(p, 1));
    if (n == 0 or n > 10_000_000) {
        retDoubles(p, &[_]f64{});
        return;
    }
    const buf = std.heap.c_allocator.alloc(f64, n) catch {
        retDoubles(p, &[_]f64{});
        return;
    };
    defer std.heap.c_allocator.free(buf);
    const got = random.stz_random_n_exp(n, g(p, 2), buf.ptr);
    retDoubles(p, buf[0..got]);
}

fn ring_NInRange(p: *anyopaque) callconv(.c) void {
    const n: usize = @intFromFloat(g(p, 1));
    const min: i64 = @intFromFloat(g(p, 2));
    const max: i64 = @intFromFloat(g(p, 3));
    if (n == 0 or n > 10000) {
        rs2(p, "", 0);
        return;
    }
    const std = @import("std");
    const buf = std.heap.c_allocator.alloc(i64, n) catch {
        rs2(p, "", 0);
        return;
    };
    defer std.heap.c_allocator.free(buf);
    const count = random.stz_random_n_in_range(n, min, max, buf.ptr);
    var out: [80000]u8 = undefined;
    var pos: usize = 0;
    var i: usize = 0;
    while (i < count) : (i += 1) {
        if (i > 0) {
            out[pos] = ',';
            pos += 1;
        }
        const val = buf[i];
        var tmp: [20]u8 = undefined;
        const neg = val < 0;
        var abs_val: u64 = if (neg) @intCast(-val) else @intCast(val);
        var tlen: usize = 0;
        if (abs_val == 0) {
            tmp[0] = '0';
            tlen = 1;
        } else {
            while (abs_val > 0) {
                tmp[tlen] = @intCast(abs_val % 10 + '0');
                abs_val /= 10;
                tlen += 1;
            }
        }
        if (neg) {
            out[pos] = '-';
            pos += 1;
        }
        var j: usize = tlen;
        while (j > 0) {
            j -= 1;
            out[pos] = tmp[j];
            pos += 1;
        }
    }
    rs2(p, &out, @intCast(pos));
}

fn ring_NUniqueInRange(p: *anyopaque) callconv(.c) void {
    const n: usize = @intFromFloat(g(p, 1));
    const min: i64 = @intFromFloat(g(p, 2));
    const max: i64 = @intFromFloat(g(p, 3));
    if (n == 0 or n > 10000) {
        rs2(p, "", 0);
        return;
    }
    const std = @import("std");
    const buf = std.heap.c_allocator.alloc(i64, n) catch {
        rs2(p, "", 0);
        return;
    };
    defer std.heap.c_allocator.free(buf);
    const count = random.stz_random_n_unique_in_range(n, min, max, buf.ptr);
    var out: [80000]u8 = undefined;
    var pos: usize = 0;
    var i: usize = 0;
    while (i < count) : (i += 1) {
        if (i > 0) {
            out[pos] = ',';
            pos += 1;
        }
        const val = buf[i];
        var tmp: [20]u8 = undefined;
        const neg = val < 0;
        var abs_val: u64 = if (neg) @intCast(-val) else @intCast(val);
        var tlen: usize = 0;
        if (abs_val == 0) {
            tmp[0] = '0';
            tlen = 1;
        } else {
            while (abs_val > 0) {
                tmp[tlen] = @intCast(abs_val % 10 + '0');
                abs_val /= 10;
                tlen += 1;
            }
        }
        if (neg) {
            out[pos] = '-';
            pos += 1;
        }
        var j: usize = tlen;
        while (j > 0) {
            j -= 1;
            out[pos] = tmp[j];
            pos += 1;
        }
    }
    rs2(p, &out, @intCast(pos));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginerandomseed", .func = &ring_Seed },
    .{ .name = "stzenginerandomint", .func = &ring_Int },
    .{ .name = "stzenginerandomfloat", .func = &ring_Float },
    .{ .name = "stzenginerandombool", .func = &ring_Bool },
    .{ .name = "stzenginerandomgauss", .func = &ring_Gauss },
    .{ .name = "stzenginerandomexp", .func = &ring_Exp },
    .{ .name = "stzenginerandomngauss", .func = &ring_NGauss },
    .{ .name = "stzenginerandomnexp", .func = &ring_NExp },
    .{ .name = "stzenginerandomninrange", .func = &ring_NInRange },
    .{ .name = "stzenginerandomnuniqueinrange", .func = &ring_NUniqueInRange },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
