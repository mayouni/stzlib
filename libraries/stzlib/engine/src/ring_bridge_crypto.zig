const crypto = @import("crypto.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_Sha256(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [64]u8 = undefined;
    const n = crypto.crypto_sha256(ptr, len, &buf);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs2(p, &buf, 0);
}

fn ring_Md5(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [32]u8 = undefined;
    const n = crypto.crypto_md5(ptr, len, &buf);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs2(p, &buf, 0);
}

fn ring_Crc32(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(crypto.crypto_crc32(ptr, len)));
}

fn ring_Fnv32(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(crypto.crypto_fnv32(ptr, len)));
}

fn ring_Fnv64(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(crypto.crypto_fnv64(ptr, len)));
}

fn ring_ConstEqual(p: *anyopaque) callconv(.c) void {
    const a: [*]const u8 = @ptrCast(gs(p, 1));
    const al: usize = @intCast(gss(p, 1));
    const b: [*]const u8 = @ptrCast(gs(p, 2));
    const bl: usize = @intCast(gss(p, 2));
    if (al != bl) {
        rn(p, 0);
        return;
    }
    rn(p, @floatFromInt(crypto.crypto_equal(a, b, al)));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginecryptosha256", .func = &ring_Sha256 },
    .{ .name = "stzenginecryptomd5", .func = &ring_Md5 },
    .{ .name = "stzenginecryptocrc32", .func = &ring_Crc32 },
    .{ .name = "stzenginecryptofnv32", .func = &ring_Fnv32 },
    .{ .name = "stzenginecryptofnv64", .func = &ring_Fnv64 },
    .{ .name = "stzenginecryptoconstequal", .func = &ring_ConstEqual },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
