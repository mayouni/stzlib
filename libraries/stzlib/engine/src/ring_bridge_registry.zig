const registry = @import("registry.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_RegistrySet(p: *anyopaque) callconv(.c) void {
    const kp: [*]const u8 = @ptrCast(gs(p, 1));
    const kl: usize = @intCast(gss(p, 1));
    const vp: [*]const u8 = @ptrCast(gs(p, 2));
    const vl: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(registry.registry_set(kp, kl, vp, vl)));
}

fn ring_RegistryGet(p: *anyopaque) callconv(.c) void {
    const kp: [*]const u8 = @ptrCast(gs(p, 1));
    const kl: usize = @intCast(gss(p, 1));
    var buf: [512]u8 = undefined;
    const len = registry.registry_get(kp, kl, &buf, 512);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_RegistryHas(p: *anyopaque) callconv(.c) void {
    const kp: [*]const u8 = @ptrCast(gs(p, 1));
    const kl: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(registry.registry_has(kp, kl)));
}

fn ring_RegistryRemove(p: *anyopaque) callconv(.c) void {
    const kp: [*]const u8 = @ptrCast(gs(p, 1));
    const kl: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(registry.registry_remove(kp, kl)));
}

fn ring_RegistryClear(p: *anyopaque) callconv(.c) void {
    _ = p;
    registry.registry_clear();
}

fn ring_RegistryCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(registry.registry_count()));
}

fn ring_RegistryKeyAt(p: *anyopaque) callconv(.c) void {
    const idx: u32 = @intFromFloat(gn(p, 1));
    var buf: [128]u8 = undefined;
    const len = registry.registry_key_at(idx, &buf, 128);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineregistryset", .func = &ring_RegistrySet },
    .{ .name = "stzengineregistryget", .func = &ring_RegistryGet },
    .{ .name = "stzengineregistryhas", .func = &ring_RegistryHas },
    .{ .name = "stzengineregistryremove", .func = &ring_RegistryRemove },
    .{ .name = "stzengineregistryclear", .func = &ring_RegistryClear },
    .{ .name = "stzengineregistrycount", .func = &ring_RegistryCount },
    .{ .name = "stzengineregistrykeyat", .func = &ring_RegistryKeyAt },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
