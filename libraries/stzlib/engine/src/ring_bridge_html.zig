const html = @import("html.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rs2 = R.ring_vm_api_retstring2;
const rs = R.ring_vm_api_retstring;

fn ring_HtmlEncode(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [65536]u8 = undefined;
    const out_len = html.html_encode(ptr, len, &buf, 65536);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs(p, @constCast(""));
}

fn ring_HtmlDecode(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [65536]u8 = undefined;
    const out_len = html.html_decode(ptr, len, &buf, 65536);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs(p, @constCast(""));
}

fn ring_HtmlStripTags(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [65536]u8 = undefined;
    const out_len = html.html_strip_tags(ptr, len, &buf, 65536);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs(p, @constCast(""));
}

fn ring_HtmlEncodeAttribute(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [65536]u8 = undefined;
    const out_len = html.html_encode_attribute(ptr, len, &buf, 65536);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs(p, @constCast(""));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginehtmlencode", .func = ring_HtmlEncode },
    .{ .name = "stzenginehtmldecode", .func = ring_HtmlDecode },
    .{ .name = "stzenginehtmlstriptags", .func = ring_HtmlStripTags },
    .{ .name = "stzenginehtmlencodeattribute", .func = ring_HtmlEncodeAttribute },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
