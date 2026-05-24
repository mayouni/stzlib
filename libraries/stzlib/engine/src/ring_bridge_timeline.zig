const R = @import("ring_api.zig");
const mod = @import("timeline.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_AddEvent(p: *anyopaque) callconv(.c) void {
    const label = gs(p, 1);
    const label_len: usize = @intCast(gl(p, 1));
    const timestamp: i64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(mod.stz_tl_add_event(label, label_len, timestamp)));
}

fn ring_EventCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_tl_event_count()));
}

fn ring_EventLabel(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    var buf: [128]u8 = undefined;
    const len = mod.stz_tl_event_label(idx, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_EventTime(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(mod.stz_tl_event_time(idx)));
}

fn ring_EventsBetween(p: *anyopaque) callconv(.c) void {
    const t1: i64 = @intFromFloat(gn(p, 1));
    const t2: i64 = @intFromFloat(gn(p, 2));
    var out: [256]i32 = undefined;
    const n = mod.stz_tl_events_between(t1, t2, &out);
    rn(p, @floatFromInt(n));
}

fn ring_EventsSorted(p: *anyopaque) callconv(.c) void {
    var out: [256]i32 = undefined;
    const n = mod.stz_tl_events_sorted(&out);
    rn(p, @floatFromInt(n));
}

fn ring_Duration(p: *anyopaque) callconv(.c) void {
    const idx1: i32 = @intFromFloat(gn(p, 1));
    const idx2: i32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(mod.stz_tl_duration(idx1, idx2)));
}

fn ring_Remove(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    mod.stz_tl_remove(idx);
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_tl_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzenginetimelineaddevent", .func = ring_AddEvent },
    .{ .name = "stzenginetimelineeventcount", .func = ring_EventCount },
    .{ .name = "stzenginetimelineeventlabel", .func = ring_EventLabel },
    .{ .name = "stzenginetimelineeventtime", .func = ring_EventTime },
    .{ .name = "stzenginetimelineeventsbetween", .func = ring_EventsBetween },
    .{ .name = "stzenginetimelineeventssorted", .func = ring_EventsSorted },
    .{ .name = "stzenginetimelineduration", .func = ring_Duration },
    .{ .name = "stzenginetimelineremove", .func = ring_Remove },
    .{ .name = "stzenginetimelineclear", .func = ring_Clear },
};
