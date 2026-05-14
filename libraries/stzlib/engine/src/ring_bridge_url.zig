const url = @import("url.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const gcp = R.ring_vm_api_getcpointer;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;
const rcp = R.ring_vm_api_retcpointer;

const H: [*:0]const u8 = "StzUrlHandle";

fn getH(p: *anyopaque, n: c_int) url.StzUrlHandle {
    const ptr = gcp(p, n, H);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn bufField(p: *anyopaque, comptime field: enum { scheme, host, path, query, fragment, user, password, reconstruct }) void {
    var buf: [4096]u8 = undefined;
    const h = getH(p, 1);
    const n = switch (field) {
        .scheme => url.stz_url_scheme(h, &buf, 4096),
        .host => url.stz_url_host(h, &buf, 4096),
        .path => url.stz_url_path(h, &buf, 4096),
        .query => url.stz_url_query(h, &buf, 4096),
        .fragment => url.stz_url_fragment(h, &buf, 4096),
        .user => url.stz_url_user(h, &buf, 4096),
        .password => url.stz_url_password(h, &buf, 4096),
        .reconstruct => url.stz_url_reconstruct(h, &buf, 4096),
    };
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}

fn ring_Parse(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(url.stz_url_parse(gs(p, 1), @intCast(gss(p, 1)))), H);
}
fn ring_Free(p: *anyopaque) callconv(.c) void { url.stz_url_free(getH(p, 1)); }
fn ring_IsValid(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(url.stz_url_is_valid(getH(p, 1)))); }
fn ring_Scheme(p: *anyopaque) callconv(.c) void { bufField(p, .scheme); }
fn ring_Host(p: *anyopaque) callconv(.c) void { bufField(p, .host); }
fn ring_Port(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(url.stz_url_port(getH(p, 1)))); }
fn ring_Path(p: *anyopaque) callconv(.c) void { bufField(p, .path); }
fn ring_Query(p: *anyopaque) callconv(.c) void { bufField(p, .query); }
fn ring_Fragment(p: *anyopaque) callconv(.c) void { bufField(p, .fragment); }
fn ring_User(p: *anyopaque) callconv(.c) void { bufField(p, .user); }
fn ring_Password(p: *anyopaque) callconv(.c) void { bufField(p, .password); }
fn ring_Reconstruct(p: *anyopaque) callconv(.c) void { bufField(p, .reconstruct); }

pub const regs = [_]R.Reg{
    .{ .name = "stzengineurlparse", .func = &ring_Parse },
    .{ .name = "stzengineurlfree", .func = &ring_Free },
    .{ .name = "stzengineurlisvalid", .func = &ring_IsValid },
    .{ .name = "stzengineurlscheme", .func = &ring_Scheme },
    .{ .name = "stzengineurlhost", .func = &ring_Host },
    .{ .name = "stzengineurlport", .func = &ring_Port },
    .{ .name = "stzengineurlpath", .func = &ring_Path },
    .{ .name = "stzengineurlquery", .func = &ring_Query },
    .{ .name = "stzengineurlfragment", .func = &ring_Fragment },
    .{ .name = "stzengineurluser", .func = &ring_User },
    .{ .name = "stzengineurlpassword", .func = &ring_Password },
    .{ .name = "stzengineurlreconstruct", .func = &ring_Reconstruct },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
