const stream = @import("stream.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_StreamOpen(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(stream.stream_open(@intFromFloat(gn(p, 1)))));
}

fn ring_StreamClose(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(stream.stream_close(@intFromFloat(gn(p, 1)))));
}

fn ring_StreamWrite(p: *anyopaque) callconv(.c) void {
    const id: u32 = @intFromFloat(gn(p, 1));
    const ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const len: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(stream.stream_write(id, ptr, len)));
}

fn ring_StreamRead(p: *anyopaque) callconv(.c) void {
    const id: u32 = @intFromFloat(gn(p, 1));
    const max: usize = @intFromFloat(gn(p, 2));
    var buf: [65536]u8 = undefined;
    const n = stream.stream_read(id, &buf, @min(max, 65536));
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs2(p, &buf, 0);
}

fn ring_StreamAvailable(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(stream.stream_available(@intFromFloat(gn(p, 1)))));
}

fn ring_StreamReset(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(stream.stream_reset(@intFromFloat(gn(p, 1)))));
}

fn ring_StreamSeek(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(stream.stream_seek(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_StreamSize(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(stream.stream_size(@intFromFloat(gn(p, 1)))));
}

fn ring_StreamIsOpen(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(stream.stream_is_open(@intFromFloat(gn(p, 1)))));
}

fn ring_StreamPeek(p: *anyopaque) callconv(.c) void {
    const id: u32 = @intFromFloat(gn(p, 1));
    const max: usize = @intFromFloat(gn(p, 2));
    var buf: [65536]u8 = undefined;
    const n = stream.stream_peek(id, &buf, @min(max, 65536));
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs2(p, &buf, 0);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginestreamopen", .func = &ring_StreamOpen },
    .{ .name = "stzenginestreamclose", .func = &ring_StreamClose },
    .{ .name = "stzenginestreamwrite", .func = &ring_StreamWrite },
    .{ .name = "stzenginestreamread", .func = &ring_StreamRead },
    .{ .name = "stzenginestreamavailable", .func = &ring_StreamAvailable },
    .{ .name = "stzenginestreamreset", .func = &ring_StreamReset },
    .{ .name = "stzenginestreamseek", .func = &ring_StreamSeek },
    .{ .name = "stzenginestreamsize", .func = &ring_StreamSize },
    .{ .name = "stzenginestreamisopen", .func = &ring_StreamIsOpen },
    .{ .name = "stzenginestreampeek", .func = &ring_StreamPeek },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
