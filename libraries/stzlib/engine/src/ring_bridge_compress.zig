const compress = @import("compressor.zig");
const zip = @import("zip_archive.zig");
const std = @import("std");
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


// ---- the ZIP container (zip_archive.zig) -----------------------------------
fn arg(p: *anyopaque, n: c_int) []const u8 {
    const ptr: [*]const u8 = @ptrCast(gs(p, n));
    const len: usize = @intCast(gss(p, n));
    return ptr[0..len];
}

fn retBytes(p: *anyopaque, b: []const u8) void {
    if (b.len == 0) rs(p, @constCast("")) else rs2(p, b.ptr, @intCast(b.len));
}

// StzEngineZipNames(cArchive) -> the entry names joined by char(10); "" with an error
fn ring_ZipNames(p: *anyopaque) callconv(.c) void {
    var out = std.ArrayList(u8){};
    defer out.deinit(std.heap.c_allocator);
    if (zip.names(arg(p, 1), &out)) retBytes(p, out.items) else rs(p, @constCast(""));
}

// StzEngineZipRead(cArchive, cEntry) -> the entry's bytes; "" with an error
fn ring_ZipRead(p: *anyopaque) callconv(.c) void {
    if (zip.readEntry(arg(p, 1), arg(p, 2))) |b| {
        defer std.heap.c_allocator.free(b);
        retBytes(p, b);
    } else rs(p, @constCast(""));
}

// StzEngineZipCrc(cArchive, cEntry) -> the stored CRC32, or -1
fn ring_ZipCrc(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(zip.entryCrc(arg(p, 1), arg(p, 2))));
}

// StzEngineZipWrite(cArchive, cNames, cSizes, cBlob, nAppend) -> 1 or 0
fn ring_ZipWrite(p: *anyopaque) callconv(.c) void {
    const append = R.ring_vm_api_getnumber(p, 5) != 0;
    rn(p, if (zip.write(arg(p, 1), arg(p, 2), arg(p, 3), arg(p, 4), append)) 1 else 0);
}

// StzEngineZipExtractAll(cArchive, cFolder) -> files written, or -1
fn ring_ZipExtractAll(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(zip.extractAll(arg(p, 1), arg(p, 2))));
}

// StzEngineZipLastError() -> the last zip error, "" when the last call succeeded
fn ring_ZipLastError(p: *anyopaque) callconv(.c) void {
    retBytes(p, zip.lastError());
}

const regs = [_]R.Reg{
    .{ .name = "stzenginezipnames", .func = ring_ZipNames },
    .{ .name = "stzenginezipread", .func = ring_ZipRead },
    .{ .name = "stzenginezipcrc", .func = ring_ZipCrc },
    .{ .name = "stzenginezipwrite", .func = ring_ZipWrite },
    .{ .name = "stzenginezipextractall", .func = ring_ZipExtractAll },
    .{ .name = "stzengineziplasterror", .func = ring_ZipLastError },
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
