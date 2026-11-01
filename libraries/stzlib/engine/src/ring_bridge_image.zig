// ring_bridge_image.zig -- the Ring face of image.zig (stz_image.dll, IM0).
//
// Every image and every grid is a gen-keyed handle (a number). Coordinates,
// rows, columns and channels are 1-BASED here and 0-based in the engine;
// channel 0 means "the BT.601 gray of the pixel". A refused call answers 0
// and StzEngineImageLastError() says why.

const std = @import("std");
const img = @import("image.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const alloc = std.heap.c_allocator;

fn getStr(p: *anyopaque, n: c_int) []const u8 {
    const ptr = R.ring_vm_api_getstring(p, n);
    const len = R.ring_vm_api_getstringsize(p, n);
    return ptr[0..len];
}

fn id(p: *anyopaque, n: c_int) i64 {
    return @intFromFloat(gn(p, n));
}

fn u(p: *anyopaque, n: c_int) u32 {
    const v = gn(p, n);
    if (!(v >= 0) or v > 4_000_000_000) return 0;
    return @intFromFloat(v);
}

fn retF(p: *anyopaque, v: i64) void {
    rn(p, @floatFromInt(v));
}

fn retBytes(p: *anyopaque, b: []const u8) void {
    R.ring_vm_api_retstring2(p, b.ptr, @intCast(b.len));
}

fn ring_LastError(p: *anyopaque) callconv(.c) void {
    retBytes(p, img.lastError());
}

fn ring_New(p: *anyopaque) callconv(.c) void {
    const c = u(p, 3);
    retF(p, img.new(u(p, 1), u(p, 2), if (c > 255) 0 else @intCast(c), @intCast(@min(u(p, 4), 255))));
}

fn ring_FromRaw(p: *anyopaque) callconv(.c) void {
    const c = u(p, 3);
    retF(p, img.fromRaw(u(p, 1), u(p, 2), if (c > 255) 0 else @intCast(c), getStr(p, 4)));
}

fn ring_Free(p: *anyopaque) callconv(.c) void {
    retF(p, img.free(id(p, 1)));
}

fn ring_Take(p: *anyopaque) callconv(.c) void {
    retF(p, img.take(id(p, 1), id(p, 2)));
}

fn ring_Live(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(img.liveImages()));
}

fn ring_Decode(p: *anyopaque) callconv(.c) void {
    retF(p, img.decode(getStr(p, 1)));
}

fn ring_Load(p: *anyopaque) callconv(.c) void {
    retF(p, img.load(getStr(p, 1)));
}

fn ring_ToPng(p: *anyopaque) callconv(.c) void {
    const b = img.encodePng(id(p, 1)) orelse {
        retBytes(p, "");
        return;
    };
    defer alloc.free(b);
    retBytes(p, b);
}

fn ring_SavePng(p: *anyopaque) callconv(.c) void {
    retF(p, img.savePng(id(p, 1), getStr(p, 2)));
}

fn ring_SaveBmp(p: *anyopaque) callconv(.c) void {
    retF(p, img.saveBmp(id(p, 1), getStr(p, 2)));
}

fn ring_Width(p: *anyopaque) callconv(.c) void {
    const im = img.get(id(p, 1)) orelse return rn(p, 0);
    rn(p, @floatFromInt(im.w));
}

fn ring_Height(p: *anyopaque) callconv(.c) void {
    const im = img.get(id(p, 1)) orelse return rn(p, 0);
    rn(p, @floatFromInt(im.h));
}

fn ring_Channels(p: *anyopaque) callconv(.c) void {
    const im = img.get(id(p, 1)) orelse return rn(p, 0);
    rn(p, @floatFromInt(im.c));
}

// (image, x, y, channel) -> 0..255; -1 when out of range
fn ring_At(p: *anyopaque) callconv(.c) void {
    const im = img.get(id(p, 1)) orelse return rn(p, -1);
    const x = u(p, 2);
    const y = u(p, 3);
    const k = u(p, 4);
    if (x < 1 or y < 1 or k < 1 or x > im.w or y > im.h or k > im.c) return rn(p, -1);
    rn(p, @floatFromInt(im.px[((y - 1) * @as(usize, im.w) + (x - 1)) * im.c + (k - 1)]));
}

fn ring_Raw(p: *anyopaque) callconv(.c) void {
    const im = img.get(id(p, 1)) orelse return retBytes(p, "");
    retBytes(p, im.px);
}

fn ring_Convert(p: *anyopaque) callconv(.c) void {
    const c = u(p, 2);
    retF(p, img.convert(id(p, 1), if (c > 255) 0 else @intCast(c)));
}

fn ring_Invert(p: *anyopaque) callconv(.c) void {
    retF(p, img.invert(id(p, 1)));
}

fn ring_Crop(p: *anyopaque) callconv(.c) void {
    const x = u(p, 2);
    const y = u(p, 3);
    if (x < 1 or y < 1) {
        retF(p, 0);
        return;
    }
    retF(p, img.crop(id(p, 1), x - 1, y - 1, u(p, 4), u(p, 5)));
}

fn ring_Flip(p: *anyopaque) callconv(.c) void {
    retF(p, img.flip(id(p, 1), gn(p, 2) != 0));
}

fn ring_Rotate(p: *anyopaque) callconv(.c) void {
    retF(p, img.rotate(id(p, 1), id(p, 2)));
}

fn ring_Resize(p: *anyopaque) callconv(.c) void {
    const m = u(p, 4);
    const mode: img.Resample = switch (m) {
        0 => .nearest,
        2 => .area,
        else => .bilinear,
    };
    retF(p, img.resize(id(p, 1), u(p, 2), u(p, 3), mode));
}

fn ring_Blur(p: *anyopaque) callconv(.c) void {
    retF(p, img.blur(id(p, 1), gn(p, 2)));
}

fn ring_Otsu(p: *anyopaque) callconv(.c) void {
    retF(p, img.otsu(id(p, 1)));
}

fn ring_Threshold(p: *anyopaque) callconv(.c) void {
    retF(p, img.threshold(id(p, 1), id(p, 2)));
}

// channel 0 = gray
fn ring_Histogram(p: *anyopaque) callconv(.c) void {
    retF(p, img.histogram(id(p, 1), id(p, 2) - 1));
}

fn ring_ToGrid(p: *anyopaque) callconv(.c) void {
    retF(p, img.toGrid(id(p, 1), id(p, 2) - 1));
}

fn ring_FromGrid(p: *anyopaque) callconv(.c) void {
    retF(p, img.fromGrid(id(p, 1)));
}

fn ring_GridRows(p: *anyopaque) callconv(.c) void {
    const g = img.getGrid(id(p, 1)) orelse return rn(p, 0);
    rn(p, @floatFromInt(g.rows));
}

fn ring_GridCols(p: *anyopaque) callconv(.c) void {
    const g = img.getGrid(id(p, 1)) orelse return rn(p, 0);
    rn(p, @floatFromInt(g.cols));
}

fn ring_GridAt(p: *anyopaque) callconv(.c) void {
    const g = img.getGrid(id(p, 1)) orelse return rn(p, 0);
    const r = u(p, 2);
    const c = u(p, 3);
    if (r < 1 or c < 1 or r > g.rows or c > g.cols) return rn(p, 0);
    rn(p, g.data[(r - 1) * g.cols + (c - 1)]);
}

fn ring_GridMax(p: *anyopaque) callconv(.c) void {
    const g = img.getGrid(id(p, 1)) orelse return rn(p, 0);
    var m: f64 = -std.math.inf(f64);
    for (g.data) |v| m = @max(m, v);
    rn(p, m);
}

fn ring_GridMin(p: *anyopaque) callconv(.c) void {
    const g = img.getGrid(id(p, 1)) orelse return rn(p, 0);
    var m: f64 = std.math.inf(f64);
    for (g.data) |v| m = @min(m, v);
    rn(p, m);
}

fn ring_GridSum(p: *anyopaque) callconv(.c) void {
    const g = img.getGrid(id(p, 1)) orelse return rn(p, 0);
    var s: f64 = 0;
    for (g.data) |v| s += v;
    rn(p, s);
}

fn ring_GridFree(p: *anyopaque) callconv(.c) void {
    retF(p, img.freeGrid(id(p, 1)));
}

fn ring_GridLive(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(img.liveGrids()));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineimagelasterror", .func = &ring_LastError },
    .{ .name = "stzengineimagenew", .func = &ring_New },
    .{ .name = "stzengineimagefromraw", .func = &ring_FromRaw },
    .{ .name = "stzengineimagefree", .func = &ring_Free },
    .{ .name = "stzengineimagetake", .func = &ring_Take },
    .{ .name = "stzengineimagelive", .func = &ring_Live },
    .{ .name = "stzengineimagedecode", .func = &ring_Decode },
    .{ .name = "stzengineimageload", .func = &ring_Load },
    .{ .name = "stzengineimagetopng", .func = &ring_ToPng },
    .{ .name = "stzengineimagesavepng", .func = &ring_SavePng },
    .{ .name = "stzengineimagesavebmp", .func = &ring_SaveBmp },
    .{ .name = "stzengineimagewidth", .func = &ring_Width },
    .{ .name = "stzengineimageheight", .func = &ring_Height },
    .{ .name = "stzengineimagechannels", .func = &ring_Channels },
    .{ .name = "stzengineimageat", .func = &ring_At },
    .{ .name = "stzengineimageraw", .func = &ring_Raw },
    .{ .name = "stzengineimageconvert", .func = &ring_Convert },
    .{ .name = "stzengineimageinvert", .func = &ring_Invert },
    .{ .name = "stzengineimagecrop", .func = &ring_Crop },
    .{ .name = "stzengineimageflip", .func = &ring_Flip },
    .{ .name = "stzengineimagerotate", .func = &ring_Rotate },
    .{ .name = "stzengineimageresize", .func = &ring_Resize },
    .{ .name = "stzengineimageblur", .func = &ring_Blur },
    .{ .name = "stzengineimageotsu", .func = &ring_Otsu },
    .{ .name = "stzengineimagethreshold", .func = &ring_Threshold },
    .{ .name = "stzengineimagehistogram", .func = &ring_Histogram },
    .{ .name = "stzengineimagetogrid", .func = &ring_ToGrid },
    .{ .name = "stzengineimagefromgrid", .func = &ring_FromGrid },
    .{ .name = "stzengineimagegridrows", .func = &ring_GridRows },
    .{ .name = "stzengineimagegridcols", .func = &ring_GridCols },
    .{ .name = "stzengineimagegridat", .func = &ring_GridAt },
    .{ .name = "stzengineimagegridmax", .func = &ring_GridMax },
    .{ .name = "stzengineimagegridmin", .func = &ring_GridMin },
    .{ .name = "stzengineimagegridsum", .func = &ring_GridSum },
    .{ .name = "stzengineimagegridfree", .func = &ring_GridFree },
    .{ .name = "stzengineimagegridlive", .func = &ring_GridLive },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
