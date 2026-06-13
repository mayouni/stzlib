const http = @import("http.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rs2 = R.ring_vm_api_retstring2;
const rs = R.ring_vm_api_retstring;
const rn = R.ring_vm_api_retnumber;

// Default body buffer for blocking GET/POST. Generous for the
// scrape-data-from-HTML use case. Larger payloads should grow this
// or move to a streaming API in a later slice.
const BODY_CAP: usize = 4 * 1024 * 1024; // 4 MiB

var body_buf: [BODY_CAP]u8 = undefined;

fn ring_HttpGet(p: *anyopaque) callconv(.c) void {
    const url_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const url_len: usize = @intCast(gss(p, 1));
    const status = http.http_get(url_ptr, url_len, &body_buf, BODY_CAP);
    if (status > 0) {
        const n = http.http_last_body_len();
        rs2(p, &body_buf, @intCast(n));
    } else {
        rs(p, @constCast(""));
    }
}

fn ring_HttpGetStatus(p: *anyopaque) callconv(.c) void {
    const url_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const url_len: usize = @intCast(gss(p, 1));
    const status = http.http_get(url_ptr, url_len, &body_buf, BODY_CAP);
    rn(p, @floatFromInt(status));
}

fn ring_HttpPost(p: *anyopaque) callconv(.c) void {
    const url_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const url_len: usize = @intCast(gss(p, 1));
    const ct_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const ct_len: usize = @intCast(gss(p, 2));
    const body_ptr: [*]const u8 = @ptrCast(gs(p, 3));
    const body_len: usize = @intCast(gss(p, 3));
    const status = http.http_post(url_ptr, url_len, ct_ptr, ct_len, body_ptr, body_len, &body_buf, BODY_CAP);
    if (status > 0) {
        const n = http.http_last_body_len();
        rs2(p, &body_buf, @intCast(n));
    } else {
        rs(p, @constCast(""));
    }
}

fn ring_HttpLastError(p: *anyopaque) callconv(.c) void {
    var buf: [512]u8 = undefined;
    const n = http.http_last_error(&buf, 512);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, @constCast(""));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginehttpget", .func = ring_HttpGet },
    .{ .name = "stzenginehttpgetstatus", .func = ring_HttpGetStatus },
    .{ .name = "stzenginehttppost", .func = ring_HttpPost },
    .{ .name = "stzenginehttplasterror", .func = ring_HttpLastError },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
