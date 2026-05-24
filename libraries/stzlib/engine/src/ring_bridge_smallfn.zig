const smallfn = @import("smallfn.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;

fn ring_Min(p: *anyopaque) callconv(.c) void { rn(p, smallfn.smallfn_min_f64(gn(p, 1), gn(p, 2))); }
fn ring_Max(p: *anyopaque) callconv(.c) void { rn(p, smallfn.smallfn_max_f64(gn(p, 1), gn(p, 2))); }
fn ring_Abs(p: *anyopaque) callconv(.c) void { rn(p, smallfn.smallfn_abs_f64(gn(p, 1))); }
fn ring_Sign(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(smallfn.smallfn_sign(gn(p, 1)))); }
fn ring_Clamp(p: *anyopaque) callconv(.c) void { rn(p, smallfn.smallfn_clamp_f64(gn(p, 1), gn(p, 2), gn(p, 3))); }
fn ring_Lerp(p: *anyopaque) callconv(.c) void { rn(p, smallfn.smallfn_lerp(gn(p, 1), gn(p, 2), gn(p, 3))); }
fn ring_MapRange(p: *anyopaque) callconv(.c) void { rn(p, smallfn.smallfn_map_range(gn(p, 1), gn(p, 2), gn(p, 3), gn(p, 4), gn(p, 5))); }
fn ring_IsNan(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(smallfn.smallfn_is_nan(gn(p, 1)))); }
fn ring_IsInf(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(smallfn.smallfn_is_inf(gn(p, 1)))); }
fn ring_IsFinite(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(smallfn.smallfn_is_finite(gn(p, 1)))); }
fn ring_Ceil(p: *anyopaque) callconv(.c) void { rn(p, smallfn.smallfn_ceil(gn(p, 1))); }
fn ring_Floor(p: *anyopaque) callconv(.c) void { rn(p, smallfn.smallfn_floor(gn(p, 1))); }
fn ring_Round(p: *anyopaque) callconv(.c) void { rn(p, smallfn.smallfn_round(gn(p, 1))); }
fn ring_Trunc(p: *anyopaque) callconv(.c) void { rn(p, smallfn.smallfn_trunc(gn(p, 1))); }
fn ring_Fmod(p: *anyopaque) callconv(.c) void { rn(p, smallfn.smallfn_fmod(gn(p, 1), gn(p, 2))); }
fn ring_Pow(p: *anyopaque) callconv(.c) void { rn(p, smallfn.smallfn_pow(gn(p, 1), gn(p, 2))); }
fn ring_Sqrt(p: *anyopaque) callconv(.c) void { rn(p, smallfn.smallfn_sqrt(gn(p, 1))); }
fn ring_LogE(p: *anyopaque) callconv(.c) void { rn(p, smallfn.smallfn_log_e(gn(p, 1))); }
fn ring_Log10(p: *anyopaque) callconv(.c) void { rn(p, smallfn.smallfn_log10(gn(p, 1))); }

pub const regs = [_]R.Reg{
    .{ .name = "stzenginesmallmin", .func = &ring_Min },
    .{ .name = "stzenginesmallmax", .func = &ring_Max },
    .{ .name = "stzenginesmallabs", .func = &ring_Abs },
    .{ .name = "stzenginesmallsign", .func = &ring_Sign },
    .{ .name = "stzenginesmallclamp", .func = &ring_Clamp },
    .{ .name = "stzenginesmalllerp", .func = &ring_Lerp },
    .{ .name = "stzenginesmallmaprange", .func = &ring_MapRange },
    .{ .name = "stzenginesmallisnan", .func = &ring_IsNan },
    .{ .name = "stzenginesmallisinf", .func = &ring_IsInf },
    .{ .name = "stzenginesmallisfinite", .func = &ring_IsFinite },
    .{ .name = "stzenginesmallceil", .func = &ring_Ceil },
    .{ .name = "stzenginesmallfloor", .func = &ring_Floor },
    .{ .name = "stzenginesmallround", .func = &ring_Round },
    .{ .name = "stzenginesmalltrunc", .func = &ring_Trunc },
    .{ .name = "stzenginesmallfmod", .func = &ring_Fmod },
    .{ .name = "stzenginesmallpow", .func = &ring_Pow },
    .{ .name = "stzenginesmallsqrt", .func = &ring_Sqrt },
    .{ .name = "stzenginesmallloge", .func = &ring_LogE },
    .{ .name = "stzenginesmalllog10", .func = &ring_Log10 },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
