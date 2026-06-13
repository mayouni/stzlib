const tcp = @import("tcp.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const gn = R.ring_vm_api_getnumber;
const rs2 = R.ring_vm_api_retstring2;
const rs = R.ring_vm_api_retstring;
const rn = R.ring_vm_api_retnumber;

// Custom pointer kinds so Ring round-trips client/server handles.
const TCP_CLIENT: [*:0]const u8 = "TcpClient";
const TCP_SERVER: [*:0]const u8 = "TcpServer";

fn getClient(p: *anyopaque, n: c_int) ?*tcp.TcpClient {
    const raw = R.ring_vm_api_getcpointer(p, n, TCP_CLIENT) orelse return null;
    const addr = @intFromPtr(raw);
    if (addr == 0) return null;
    return @ptrFromInt(addr);
}

fn getServer(p: *anyopaque, n: c_int) ?*tcp.TcpServer {
    const raw = R.ring_vm_api_getcpointer(p, n, TCP_SERVER) orelse return null;
    const addr = @intFromPtr(raw);
    if (addr == 0) return null;
    return @ptrFromInt(addr);
}

// Receive buffer used by tcp_recv. Sized for typical responses; the
// caller passes a max byte count that is clamped to this cap.
const RECV_CAP: usize = 64 * 1024;
var recv_buf: [RECV_CAP]u8 = undefined;

fn ring_TcpConnect(p: *anyopaque) callconv(.c) void {
    const host_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const host_len: usize = @intCast(gss(p, 1));
    const port: u16 = @intFromFloat(gn(p, 2));
    const h = tcp.tcp_connect(host_ptr, host_len, port);
    if (h) |c| {
        R.ring_vm_api_retcpointer(p, @ptrCast(c), TCP_CLIENT);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), TCP_CLIENT);
    }
}

fn ring_TcpSend(p: *anyopaque) callconv(.c) void {
    const c = getClient(p, 1);
    const data_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const data_len: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(tcp.tcp_send(c, data_ptr, data_len)));
}

fn ring_TcpRecv(p: *anyopaque) callconv(.c) void {
    const c = getClient(p, 1);
    const max_req: usize = @intFromFloat(gn(p, 2));
    const cap = @min(max_req, RECV_CAP);
    const n = tcp.tcp_recv(c, &recv_buf, cap);
    if (n > 0) rs2(p, &recv_buf, @intCast(n)) else rs(p, @constCast(""));
}

fn ring_TcpClose(p: *anyopaque) callconv(.c) void {
    const c = getClient(p, 1);
    tcp.tcp_close(c);
}

fn ring_TcpListen(p: *anyopaque) callconv(.c) void {
    const host_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const host_len: usize = @intCast(gss(p, 1));
    const port: u16 = @intFromFloat(gn(p, 2));
    const h = tcp.tcp_listen(host_ptr, host_len, port);
    if (h) |s| {
        R.ring_vm_api_retcpointer(p, @ptrCast(s), TCP_SERVER);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), TCP_SERVER);
    }
}

fn ring_TcpAccept(p: *anyopaque) callconv(.c) void {
    const s = getServer(p, 1);
    const c = tcp.tcp_accept(s);
    if (c) |client| {
        R.ring_vm_api_retcpointer(p, @ptrCast(client), TCP_CLIENT);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), TCP_CLIENT);
    }
}

fn ring_TcpServerClose(p: *anyopaque) callconv(.c) void {
    const s = getServer(p, 1);
    tcp.tcp_server_close(s);
}

fn ring_TcpLastError(p: *anyopaque) callconv(.c) void {
    var buf: [512]u8 = undefined;
    const n = tcp.tcp_last_error(&buf, 512);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, @constCast(""));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginetcpconnect", .func = ring_TcpConnect },
    .{ .name = "stzenginetcpsend", .func = ring_TcpSend },
    .{ .name = "stzenginetcprecv", .func = ring_TcpRecv },
    .{ .name = "stzenginetcpclose", .func = ring_TcpClose },
    .{ .name = "stzenginetcplisten", .func = ring_TcpListen },
    .{ .name = "stzenginetcpaccept", .func = ring_TcpAccept },
    .{ .name = "stzenginetcpserverclose", .func = ring_TcpServerClose },
    .{ .name = "stzenginetcplasterror", .func = ring_TcpLastError },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
