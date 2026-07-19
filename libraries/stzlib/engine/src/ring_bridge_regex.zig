const rx = @import("regex.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;

// Shadow the real cpointer functions: store/resolve via handle table.
fn rcp(p: *anyopaque, ptr: ?*anyopaque, _: [*:0]const u8) void {
    R.retHandle(p, ptr);
}

fn gcp(p: *anyopaque, n: c_int, _: [*:0]const u8) ?*anyopaque {
    return R.getHandle(p, n);
}

const H: [*:0]const u8 = "StzRegexHandle";

fn getH(p: *anyopaque, n: c_int) rx.StzRegexHandle {
    const ptr = gcp(p, n, H);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn ring_New(p: *anyopaque) callconv(.c) void {
    const pat = gs(p, 1);
    const pat_len: usize = @intCast(gss(p, 1));
    const flags: u32 = @intFromFloat(g(p, 2));
    rcp(p, @ptrCast(rx.stz_regex_new(pat, pat_len, flags)), H);
}
fn ring_Free(p: *anyopaque) callconv(.c) void {
    const raw = R.releaseHandle(p, 1);
    if (raw) |ptr| {
        const h: rx.StzRegexHandle = @ptrCast(@alignCast(ptr));
        rx.stz_regex_free(h);
    }
}
fn ring_Match(p: *anyopaque) callconv(.c) void {
    const h = getH(p, 1);
    const inp = gs(p, 2);
    const inp_len: usize = @intCast(gss(p, 2));
    const raw: usize = @intFromFloat(g(p, 3));
    const start: usize = if (raw > 0) raw - 1 else 0;
    rn(p, @floatFromInt(rx.stz_regex_match(h, inp, inp_len, start)));
}
fn ring_MatchAll(p: *anyopaque) callconv(.c) void {
    const h = getH(p, 1);
    const inp = gs(p, 2);
    const inp_len: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(rx.stz_regex_match_all(h, inp, inp_len)));
}
fn ring_HasMatch(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(rx.stz_regex_has_match(getH(p, 1))));
}
fn ring_CaptureCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(rx.stz_regex_capture_count(getH(p, 1))));
}
fn ring_CaptureStart(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(rx.stz_regex_capture_start(getH(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_CaptureEnd(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(rx.stz_regex_capture_end(getH(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_CaptureText(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = rx.stz_regex_capture_text(getH(p, 1), @intFromFloat(g(p, 2)), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_Replace(p: *anyopaque) callconv(.c) void {
    const h = getH(p, 1);
    const inp = gs(p, 2);
    const inp_len: usize = @intCast(gss(p, 2));
    const repl = gs(p, 3);
    const repl_len: usize = @intCast(gss(p, 3));
    var out_len: usize = 0;
    const ptr = rx.stz_regex_replace(h, inp, inp_len, repl, repl_len, &out_len);
    if (ptr != null and out_len > 0) {
        rs2(p, ptr, @intCast(out_len));
        rx.stz_regex_replace_free(ptr, out_len);
    } else rs(p, "");
}
fn ring_SetLimits(p: *anyopaque) callconv(.c) void {
    rx.stz_regex_set_limits(getH(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)), @intFromFloat(g(p, 4)));
}
fn ring_CaptureByName(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const name = gs(p, 2);
    const name_len: usize = @intCast(gss(p, 2));
    const n = rx.stz_regex_capture_by_name(getH(p, 1), name, name_len, &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_NamedGroupCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(rx.stz_regex_named_group_count(getH(p, 1))));
}
fn ring_NamedGroupName(p: *anyopaque) callconv(.c) void {
    var buf: [256]u8 = undefined;
    const idx: c_int = @intFromFloat(g(p, 2));
    const n = rx.stz_regex_named_group_name(getH(p, 1), idx, &buf, 256);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
// Takes the 1-based Ring position and converts it ONCE.
//
// Worth stating because the older ring_Match does not: its caller in
// stzRegex ALSO subtracts 1, so a position travelled through two
// decrements and landed one character to the left. Matches() then
// over-advanced by exactly one to compensate, and the two errors
// cancelled -- which is why enumeration looked correct. This entry point
// converts once and the Ring side hands over the position untouched.
fn ring_MatchTyped(p: *anyopaque) callconv(.c) void {
    const h = getH(p, 1);
    const inp = gs(p, 2);
    const inp_len: usize = @intCast(gss(p, 2));
    const raw: usize = @intFromFloat(g(p, 3));
    const start: usize = if (raw > 1) raw - 1 else 0;
    const mt: u32 = @intFromFloat(g(p, 4));
    rn(p, @floatFromInt(rx.stz_regex_match_typed(h, inp, inp_len, start, mt)));
}
fn ring_PartialMatch(p: *anyopaque) callconv(.c) void {
    const h = getH(p, 1);
    const inp = gs(p, 2);
    const inp_len: usize = @intCast(gss(p, 2));
    const raw: usize = @intFromFloat(g(p, 3));
    const start: usize = if (raw > 0) raw - 1 else 0;
    rn(p, @floatFromInt(rx.stz_regex_partial_match(h, inp, inp_len, start)));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineregexnew", .func = &ring_New },
    .{ .name = "stzengineregexfree", .func = &ring_Free },
    .{ .name = "stzengineregexmatch", .func = &ring_Match },
    .{ .name = "stzengineregexmatchall", .func = &ring_MatchAll },
    .{ .name = "stzengineregexhasmatch", .func = &ring_HasMatch },
    .{ .name = "stzengineregexcapturecount", .func = &ring_CaptureCount },
    .{ .name = "stzengineregexcapturestart", .func = &ring_CaptureStart },
    .{ .name = "stzengineregexcaptureend", .func = &ring_CaptureEnd },
    .{ .name = "stzengineregexcapturetext", .func = &ring_CaptureText },
    .{ .name = "stzengineregexreplace", .func = &ring_Replace },
    .{ .name = "stzengineregexsetlimits", .func = &ring_SetLimits },
    .{ .name = "stzengineregexcapturebyname", .func = &ring_CaptureByName },
    .{ .name = "stzengineregexnamedgroupcount", .func = &ring_NamedGroupCount },
    .{ .name = "stzengineregexnamedgroupname", .func = &ring_NamedGroupName },
    .{ .name = "stzengineregexpartialmatch", .func = &ring_PartialMatch },
    .{ .name = "stzengineregexmatchtyped", .func = &ring_MatchTyped },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
