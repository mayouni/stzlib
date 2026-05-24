const codec = @import("codec.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_Base64Encode(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [65536]u8 = undefined;
    const out_len = codec.codec_base64_encode(ptr, len, &buf, 65536);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs2(p, &buf, 0);
}

fn ring_Base64Decode(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [65536]u8 = undefined;
    const out_len = codec.codec_base64_decode(ptr, len, &buf, 65536);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs2(p, &buf, 0);
}

fn ring_HexEncode(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [65536]u8 = undefined;
    const out_len = codec.codec_hex_encode(ptr, len, &buf, 65536);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs2(p, &buf, 0);
}

fn ring_HexDecode(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [65536]u8 = undefined;
    const out_len = codec.codec_hex_decode(ptr, len, &buf, 65536);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs2(p, &buf, 0);
}

fn ring_UrlEncode(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [65536]u8 = undefined;
    const out_len = codec.codec_url_encode(ptr, len, &buf, 65536);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs2(p, &buf, 0);
}

fn ring_UrlDecode(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [65536]u8 = undefined;
    const out_len = codec.codec_url_decode(ptr, len, &buf, 65536);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs2(p, &buf, 0);
}

fn ring_Rot13(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [65536]u8 = undefined;
    const out_len = codec.codec_rot13(ptr, len, &buf, 65536);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs2(p, &buf, 0);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginecodecbase64encode", .func = &ring_Base64Encode },
    .{ .name = "stzenginecodecbase64decode", .func = &ring_Base64Decode },
    .{ .name = "stzenginecodechexencode", .func = &ring_HexEncode },
    .{ .name = "stzenginecodechexdecode", .func = &ring_HexDecode },
    .{ .name = "stzenginecodecurlencode", .func = &ring_UrlEncode },
    .{ .name = "stzenginecodecurldecode", .func = &ring_UrlDecode },
    .{ .name = "stzenginecodecrot13", .func = &ring_Rot13 },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
