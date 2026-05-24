const compress = @import("compressor.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;
const rs = R.ring_vm_api_retstring;

fn ring_Crc32(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(compress.compress_crc32(ptr, len)));
}

fn ring_Adler32(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(compress.compress_adler32(ptr, len)));
}

fn ring_RleEncode(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [65536]u8 = undefined;
    const out_len = compress.compress_rle_encode(ptr, len, &buf, 65536);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs(p, @constCast(""));
}

fn ring_RleDecode(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [262144]u8 = undefined;
    const out_len = compress.compress_rle_decode(ptr, len, &buf, 262144);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs(p, @constCast(""));
}

fn ring_SimpleCompress(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [65536]u8 = undefined;
    const out_len = compress.compress_simple(ptr, len, &buf, 65536);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs(p, @constCast(""));
}

fn ring_SimpleDecompress(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [262144]u8 = undefined;
    const out_len = compress.compress_simple_decompress(ptr, len, &buf, 262144);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs(p, @constCast(""));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginecompresscrc32", .func = ring_Crc32 },
    .{ .name = "stzenginecompressadler32", .func = ring_Adler32 },
    .{ .name = "stzenginecompressrleencode", .func = ring_RleEncode },
    .{ .name = "stzenginecompressrledecode", .func = ring_RleDecode },
    .{ .name = "stzenginecompresssimple", .func = ring_SimpleCompress },
    .{ .name = "stzenginecompresssimpledecompress", .func = ring_SimpleDecompress },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
