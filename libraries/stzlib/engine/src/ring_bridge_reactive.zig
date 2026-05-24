const R = @import("ring_api.zig");
const reactive = @import("reactive.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_create_channel(p: *anyopaque) callconv(.c) void {
    const n = gs(p, 1);
    const nl: i32 = @intCast(gl(p, 1));
    rn(p, @floatFromInt(reactive.reactive_create_channel(n, nl)));
}

fn ring_subscribe(p: *anyopaque) callconv(.c) void {
    const n = gs(p, 1);
    const nl: i32 = @intCast(gl(p, 1));
    rn(p, @floatFromInt(reactive.reactive_subscribe(n, nl)));
}

fn ring_unsubscribe(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(reactive.reactive_unsubscribe(@intFromFloat(gn(p, 1)))));
}

fn ring_emit(p: *anyopaque) callconv(.c) void {
    const n = gs(p, 1);
    const nl: i32 = @intCast(gl(p, 1));
    const d = gs(p, 2);
    const dl: i32 = @intCast(gl(p, 2));
    rn(p, @floatFromInt(reactive.reactive_emit(n, nl, d, dl)));
}

fn ring_channel_count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(reactive.reactive_channel_count()));
}

fn ring_event_count(p: *anyopaque) callconv(.c) void {
    const n = gs(p, 1);
    const nl: i32 = @intCast(gl(p, 1));
    rn(p, @floatFromInt(reactive.reactive_event_count(n, nl)));
}

fn ring_sub_count(p: *anyopaque) callconv(.c) void {
    const n = gs(p, 1);
    const nl: i32 = @intCast(gl(p, 1));
    rn(p, @floatFromInt(reactive.reactive_sub_count(n, nl)));
}

fn ring_last_event(p: *anyopaque) callconv(.c) void {
    const n = gs(p, 1);
    const nl: i32 = @intCast(gl(p, 1));
    var buf: [256]u8 = undefined;
    const len = reactive.reactive_last_event(n, nl, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_destroy_channel(p: *anyopaque) callconv(.c) void {
    const n = gs(p, 1);
    const nl: i32 = @intCast(gl(p, 1));
    rn(p, @floatFromInt(reactive.reactive_destroy_channel(n, nl)));
}

fn ring_clear_all(p: *anyopaque) callconv(.c) void {
    _ = p;
    reactive.reactive_clear_all();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengine_reactive_create_channel", .func = ring_create_channel },
    .{ .name = "stzengine_reactive_subscribe", .func = ring_subscribe },
    .{ .name = "stzengine_reactive_unsubscribe", .func = ring_unsubscribe },
    .{ .name = "stzengine_reactive_emit", .func = ring_emit },
    .{ .name = "stzengine_reactive_channel_count", .func = ring_channel_count },
    .{ .name = "stzengine_reactive_event_count", .func = ring_event_count },
    .{ .name = "stzengine_reactive_sub_count", .func = ring_sub_count },
    .{ .name = "stzengine_reactive_last_event", .func = ring_last_event },
    .{ .name = "stzengine_reactive_destroy_channel", .func = ring_destroy_channel },
    .{ .name = "stzengine_reactive_clear_all", .func = ring_clear_all },
};
