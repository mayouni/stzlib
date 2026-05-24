const cache = @import("cache.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_CachePut(p: *anyopaque) callconv(.c) void {
    const kp: [*]const u8 = @ptrCast(gs(p, 1));
    const kl: usize = @intCast(gss(p, 1));
    const vp: [*]const u8 = @ptrCast(gs(p, 2));
    const vl: usize = @intCast(gss(p, 2));
    const ttl: u64 = @intFromFloat(gn(p, 3));
    rn(p, @floatFromInt(cache.cache_put(kp, kl, vp, vl, ttl)));
}

fn ring_CacheGet(p: *anyopaque) callconv(.c) void {
    const kp: [*]const u8 = @ptrCast(gs(p, 1));
    const kl: usize = @intCast(gss(p, 1));
    var buf: [4096]u8 = undefined;
    const len = cache.cache_get(kp, kl, &buf, 4096);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_CacheHas(p: *anyopaque) callconv(.c) void {
    const kp: [*]const u8 = @ptrCast(gs(p, 1));
    const kl: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(cache.cache_has(kp, kl)));
}

fn ring_CacheRemove(p: *anyopaque) callconv(.c) void {
    const kp: [*]const u8 = @ptrCast(gs(p, 1));
    const kl: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(cache.cache_remove(kp, kl)));
}

fn ring_CacheClear(p: *anyopaque) callconv(.c) void {
    _ = p;
    cache.cache_clear();
}

fn ring_CacheSize(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(cache.cache_size()));
}

fn ring_CacheHitCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(cache.cache_hit_count()));
}

fn ring_CacheMissCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(cache.cache_miss_count()));
}

fn ring_CacheHitRate(p: *anyopaque) callconv(.c) void {
    rn(p, cache.cache_hit_rate());
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginecacheput", .func = &ring_CachePut },
    .{ .name = "stzenginecacheget", .func = &ring_CacheGet },
    .{ .name = "stzenginecachehas", .func = &ring_CacheHas },
    .{ .name = "stzenginecacheremove", .func = &ring_CacheRemove },
    .{ .name = "stzenginecacheclear", .func = &ring_CacheClear },
    .{ .name = "stzenginecachesize", .func = &ring_CacheSize },
    .{ .name = "stzenginecachehitcount", .func = &ring_CacheHitCount },
    .{ .name = "stzenginecachemisscount", .func = &ring_CacheMissCount },
    .{ .name = "stzenginecachehitrate", .func = &ring_CacheHitRate },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
