const R = @import("ring_api.zig");
const pattern = @import("pattern.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_is_palindrome(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const l: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(pattern.is_palindrome(s, l)));
}

fn ring_repeat_len(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const l: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(pattern.find_repeat_len(s, l)));
}

fn ring_repeat_count(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const l: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(pattern.count_repeats(s, l)));
}

fn ring_extract_repeat(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const l: usize = @intCast(gss(p, 1));
    var buf: [1024]u8 = undefined;
    const len = pattern.extract_repeat(s, l, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_has_prefix(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    const pat: [*]const u8 = @ptrCast(gs(p, 2));
    const pl: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(pattern.has_prefix_pattern(s, sl, pat, pl)));
}

fn ring_has_suffix(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    const pat: [*]const u8 = @ptrCast(gs(p, 2));
    const pl: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(pattern.has_suffix_pattern(s, sl, pat, pl)));
}

fn ring_count_occ(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    const pat: [*]const u8 = @ptrCast(gs(p, 2));
    const pl: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(pattern.count_pattern_occurrences(s, sl, pat, pl)));
}

fn ring_lcp(p: *anyopaque) callconv(.c) void {
    const a: [*]const u8 = @ptrCast(gs(p, 1));
    const al: usize = @intCast(gss(p, 1));
    const b: [*]const u8 = @ptrCast(gs(p, 2));
    const bl: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(pattern.longest_common_prefix(a, al, b, bl)));
}

fn ring_lcs(p: *anyopaque) callconv(.c) void {
    const a: [*]const u8 = @ptrCast(gs(p, 1));
    const al: usize = @intCast(gss(p, 1));
    const b: [*]const u8 = @ptrCast(gs(p, 2));
    const bl: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(pattern.longest_common_suffix(a, al, b, bl)));
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengine_pattern_is_palindrome", .func = ring_is_palindrome },
    .{ .name = "stzengine_pattern_repeat_len", .func = ring_repeat_len },
    .{ .name = "stzengine_pattern_repeat_count", .func = ring_repeat_count },
    .{ .name = "stzengine_pattern_extract_repeat", .func = ring_extract_repeat },
    .{ .name = "stzengine_pattern_has_prefix", .func = ring_has_prefix },
    .{ .name = "stzengine_pattern_has_suffix", .func = ring_has_suffix },
    .{ .name = "stzengine_pattern_count_occ", .func = ring_count_occ },
    .{ .name = "stzengine_pattern_lcp", .func = ring_lcp },
    .{ .name = "stzengine_pattern_lcs", .func = ring_lcs },
};
