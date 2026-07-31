const seclog = @import("seclog.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;

const LOG_HANDLE: [*:0]const u8 = "StzSecLog";

var str_buf: [512]u8 = undefined;

fn getLog(p: *anyopaque, n: c_int) ?*seclog.SecLog {
    const raw = R.ring_vm_api_getcpointer(p, n, LOG_HANDLE) orelse return null;
    const addr = @intFromPtr(raw);
    if (addr == 0) return null;
    return @ptrFromInt(addr);
}

fn ring_SecLogCreate(p: *anyopaque) callconv(.c) void {
    const handle = seclog.seclog_create(gn(p, 1));
    if (handle) |s| {
        R.ring_vm_api_retcpointer(p, @ptrCast(s), LOG_HANDLE);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), LOG_HANDLE);
    }
}

fn ring_SecLogAppend(p: *anyopaque) callconv(.c) void {
    const c: [*]const u8 = @ptrCast(gs(p, 2));
    const cl: usize = @intCast(gss(p, 2));
    seclog.seclog_append(getLog(p, 1), c, cl, gn(p, 3), gn(p, 4));
    rn(p, 0);
}

fn ring_SecLogCount(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_count(getLog(p, 1)));
}

fn ring_SecLogCapacity(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_capacity(getLog(p, 1)));
}

fn ring_SecLogSize(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_size(getLog(p, 1)));
}

fn ring_SecLogCanonicalAt(p: *anyopaque) callconv(.c) void {
    const n = seclog.seclog_canonical_at(getLog(p, 1), gn(p, 2), &str_buf, str_buf.len);
    if (n > 0) rs2(p, &str_buf, @intCast(n)) else rs(p, @constCast(""));
}

fn ring_SecLogDigestAt(p: *anyopaque) callconv(.c) void {
    const n = seclog.seclog_digest_at(getLog(p, 1), gn(p, 2), &str_buf, str_buf.len);
    if (n > 0) rs2(p, &str_buf, @intCast(n)) else rs(p, @constCast(""));
}

fn ring_SecLogHeadDigest(p: *anyopaque) callconv(.c) void {
    const n = seclog.seclog_head_digest(getLog(p, 1), &str_buf, str_buf.len);
    if (n > 0) rs2(p, &str_buf, @intCast(n)) else rs(p, @constCast(""));
}

fn ring_SecLogWallAt(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_wall_at(getLog(p, 1), gn(p, 2)));
}

fn ring_SecLogSeverityAt(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_severity_at(getLog(p, 1), gn(p, 2)));
}

fn ring_SecLogVerify(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_verify(getLog(p, 1)));
}

fn ring_SecLogReset(p: *anyopaque) callconv(.c) void {
    seclog.seclog_reset(getLog(p, 1));
    rn(p, 0);
}

fn ring_SecLogDestroy(p: *anyopaque) callconv(.c) void {
    seclog.seclog_destroy(getLog(p, 1));
    rn(p, 0);
}

fn ring_SecLogSetCurrent(p: *anyopaque) callconv(.c) void {
    seclog.seclog_set_current(getLog(p, 1));
    rn(p, 0);
}

fn ring_SecLogClearCurrent(p: *anyopaque) callconv(.c) void {
    seclog.seclog_clear_current();
    rn(p, 0);
}

fn ring_SecLogHasCurrent(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_has_current());
}

fn ring_SecLogCurrent(p: *anyopaque) callconv(.c) void {
    const s = seclog.seclog_current();
    if (s) |sp| {
        R.ring_vm_api_retcpointer(p, @ptrCast(sp), LOG_HANDLE);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), LOG_HANDLE);
    }
}

fn ring_SecLogCurrentAppend(p: *anyopaque) callconv(.c) void {
    const c: [*]const u8 = @ptrCast(gs(p, 1));
    const cl: usize = @intCast(gss(p, 1));
    seclog.seclog_current_append(c, cl, gn(p, 2), gn(p, 3));
    rn(p, 0);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineseclogsetcurrent", .func = &ring_SecLogSetCurrent },
    .{ .name = "stzengineseclogclearcurrent", .func = &ring_SecLogClearCurrent },
    .{ .name = "stzenginesecloghascurrent", .func = &ring_SecLogHasCurrent },
    .{ .name = "stzengineseclogcurrent", .func = &ring_SecLogCurrent },
    .{ .name = "stzengineseclogcurrentappend", .func = &ring_SecLogCurrentAppend },
    .{ .name = "stzengineseclogcreate", .func = &ring_SecLogCreate },
    .{ .name = "stzengineseclogappend", .func = &ring_SecLogAppend },
    .{ .name = "stzengineseclogcount", .func = &ring_SecLogCount },
    .{ .name = "stzengineseclogsize", .func = &ring_SecLogSize },
    .{ .name = "stzengineseclogcapacity", .func = &ring_SecLogCapacity },
    .{ .name = "stzengineseclogcanonicalat", .func = &ring_SecLogCanonicalAt },
    .{ .name = "stzengineseclogdigestat", .func = &ring_SecLogDigestAt },
    .{ .name = "stzengineseclogheaddigest", .func = &ring_SecLogHeadDigest },
    .{ .name = "stzengineseclogwallat", .func = &ring_SecLogWallAt },
    .{ .name = "stzengineseclogseverityat", .func = &ring_SecLogSeverityAt },
    .{ .name = "stzengineseclogverify", .func = &ring_SecLogVerify },
    .{ .name = "stzengineseclogreset", .func = &ring_SecLogReset },
    .{ .name = "stzengineseclogdestroy", .func = &ring_SecLogDestroy },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
