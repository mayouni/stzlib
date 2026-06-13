const pool = @import("pool.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const gn = R.ring_vm_api_getnumber;
const rs2 = R.ring_vm_api_retstring2;
const rs = R.ring_vm_api_retstring;
const rn = R.ring_vm_api_retnumber;

const POOL_HANDLE: [*:0]const u8 = "StzPool";

fn getPool(p: *anyopaque, n: c_int) ?*pool.Pool {
    const raw = R.ring_vm_api_getcpointer(p, n, POOL_HANDLE) orelse return null;
    const addr = @intFromPtr(raw);
    if (addr == 0) return null;
    return @ptrFromInt(addr);
}

const POLL_CAP: usize = 4 * 1024 * 1024;
var poll_buf: [POLL_CAP]u8 = undefined;
var last_pool_status: i32 = 0;

fn ring_PoolCreate(p: *anyopaque) callconv(.c) void {
    const n: u32 = @intFromFloat(gn(p, 1));
    const handle = pool.pool_create(n);
    if (handle) |h| {
        R.ring_vm_api_retcpointer(p, @ptrCast(h), POOL_HANDLE);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), POOL_HANDLE);
    }
}

fn ring_PoolCreateXT(p: *anyopaque) callconv(.c) void {
    const n: u32 = @intFromFloat(gn(p, 1));
    const max_queue: u32 = @intFromFloat(gn(p, 2));
    const handle = pool.pool_create_xt(n, max_queue);
    if (handle) |h| {
        R.ring_vm_api_retcpointer(p, @ptrCast(h), POOL_HANDLE);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), POOL_HANDLE);
    }
}

fn ring_PoolPending(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(pool.pool_pending(getPool(p, 1))));
}

fn ring_PoolInflight(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(pool.pool_inflight(getPool(p, 1))));
}

fn ring_PoolSubmit(p: *anyopaque) callconv(.c) void {
    const pp = getPool(p, 1);
    const kind: u32 = @intFromFloat(gn(p, 2));
    const arg_ptr: [*]const u8 = @ptrCast(gs(p, 3));
    const arg_len: usize = @intCast(gss(p, 3));
    const id = pool.pool_submit(pp, kind, arg_ptr, arg_len);
    rn(p, @floatFromInt(id));
}

fn ring_PoolPoll(p: *anyopaque) callconv(.c) void {
    const pp = getPool(p, 1);
    const id: u64 = @intFromFloat(gn(p, 2));
    const code = pool.pool_poll(pp, id, &poll_buf, POLL_CAP);
    last_pool_status = code;
    if (code >= 0) {
        rs2(p, &poll_buf, @intCast(pool.pool_last_body_len()));
    } else {
        rs(p, @constCast(""));
    }
}

fn ring_PoolPollWithDeadline(p: *anyopaque) callconv(.c) void {
    const pp = getPool(p, 1);
    const id: u64 = @intFromFloat(gn(p, 2));
    const deadline_ms: u64 = @intFromFloat(gn(p, 3));
    const code = pool.pool_poll_with_deadline(pp, id, deadline_ms, &poll_buf, POLL_CAP);
    last_pool_status = code;
    if (code >= 0) {
        rs2(p, &poll_buf, @intCast(pool.pool_last_body_len()));
    } else {
        rs(p, @constCast(""));
    }
}

fn ring_PoolLastStatus(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(last_pool_status));
}

fn ring_PoolDestroy(p: *anyopaque) callconv(.c) void {
    const pp = getPool(p, 1);
    pool.pool_destroy(pp);
}

fn ring_PoolLastError(p: *anyopaque) callconv(.c) void {
    var buf: [512]u8 = undefined;
    const n = pool.pool_last_error(&buf, 512);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, @constCast(""));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginepoolcreate", .func = ring_PoolCreate },
    .{ .name = "stzenginepoolcreatext", .func = ring_PoolCreateXT },
    .{ .name = "stzenginepoolsubmit", .func = ring_PoolSubmit },
    .{ .name = "stzenginepoolpoll", .func = ring_PoolPoll },
    .{ .name = "stzenginepoolpollwithdeadline", .func = ring_PoolPollWithDeadline },
    .{ .name = "stzenginepoollaststatus", .func = ring_PoolLastStatus },
    .{ .name = "stzenginepooldestroy", .func = ring_PoolDestroy },
    .{ .name = "stzenginepoollasterror", .func = ring_PoolLastError },
    .{ .name = "stzenginepoolpending", .func = ring_PoolPending },
    .{ .name = "stzenginepoolinflight", .func = ring_PoolInflight },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
