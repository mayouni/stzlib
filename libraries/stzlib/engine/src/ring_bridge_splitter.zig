const R = @import("ring_api.zig");
const splitter = @import("splitter.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_by_str(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    const d: [*]const u8 = @ptrCast(gs(p, 2));
    const dl: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(splitter.split_by_str(s, sl, d, dl)));
}

fn ring_by_width(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    const w: i32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(splitter.split_by_width(s, sl, w)));
}

fn ring_by_any_char(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    const c: [*]const u8 = @ptrCast(gs(p, 2));
    const cl: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(splitter.split_by_any_char(s, sl, c, cl)));
}

fn ring_keep_delim(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    const d: [*]const u8 = @ptrCast(gs(p, 2));
    const dl: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(splitter.split_keep_delim(s, sl, d, dl)));
}

fn ring_limit(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    const d: [*]const u8 = @ptrCast(gs(p, 2));
    const dl: usize = @intCast(gss(p, 2));
    const m: i32 = @intFromFloat(gn(p, 3));
    rn(p, @floatFromInt(splitter.split_limit(s, sl, d, dl, m)));
}

fn ring_lines(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(splitter.split_lines(s, sl)));
}

fn ring_words(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(splitter.split_words(s, sl)));
}

fn ring_part_at(p: *anyopaque) callconv(.c) void {
    const i: i32 = @intFromFloat(gn(p, 1));
    var buf: [4096]u8 = undefined;
    const len = splitter.part_at(i, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_part_len(p: *anyopaque) callconv(.c) void {
    const i: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(splitter.part_len_at(i)));
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengine_splitter_by_str", .func = ring_by_str },
    .{ .name = "stzengine_splitter_by_width", .func = ring_by_width },
    .{ .name = "stzengine_splitter_by_any_char", .func = ring_by_any_char },
    .{ .name = "stzengine_splitter_keep_delim", .func = ring_keep_delim },
    .{ .name = "stzengine_splitter_limit", .func = ring_limit },
    .{ .name = "stzengine_splitter_lines", .func = ring_lines },
    .{ .name = "stzengine_splitter_words", .func = ring_words },
    .{ .name = "stzengine_splitter_part_at", .func = ring_part_at },
    .{ .name = "stzengine_splitter_part_len", .func = ring_part_len },
};
