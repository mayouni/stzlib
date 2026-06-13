const html = @import("html.zig");
const dom = @import("html_dom.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const gn = R.ring_vm_api_getnumber;
const gcp = R.ring_vm_api_getcpointer;
const rs2 = R.ring_vm_api_retstring2;
const rs = R.ring_vm_api_retstring;
const rn = R.ring_vm_api_retnumber;
const rcp = R.ring_vm_api_retcpointer;

// Custom pointer kind so Ring round-trips HtmlDoc handles cleanly.
const HTML_DOC: [*:0]const u8 = "HtmlDoc";

fn getDoc(p: *anyopaque, n: c_int) ?*dom.Doc {
    const raw = R.ring_vm_api_getcpointer(p, n, HTML_DOC) orelse return null;
    const addr = @intFromPtr(raw);
    if (addr == 0) return null;
    return @ptrFromInt(addr);
}

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

// ── DOM bridge ───────────────────────────────────────────────

fn ring_HtmlParse(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    const doc = dom.html_parse(ptr, len);
    if (doc) |d| {
        R.ring_vm_api_retcpointer(p, @ptrCast(d), HTML_DOC);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), HTML_DOC);
    }
}

fn ring_HtmlFree(p: *anyopaque) callconv(.c) void {
    const doc = getDoc(p, 1);
    dom.html_free(doc);
}

fn ring_HtmlCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(dom.html_count(getDoc(p, 1))));
}

fn ring_HtmlCountByTag(p: *anyopaque) callconv(.c) void {
    const doc = getDoc(p, 1);
    const tag_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const tag_len: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(dom.html_count_by_tag(doc, tag_ptr, tag_len)));
}

fn ring_HtmlTextOfTag(p: *anyopaque) callconv(.c) void {
    const doc = getDoc(p, 1);
    const tag_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const tag_len: usize = @intCast(gss(p, 2));
    const n: i32 = @intFromFloat(gn(p, 3));
    var buf: [65536]u8 = undefined;
    const out_len = dom.html_text_of_tag(doc, tag_ptr, tag_len, n, &buf, 65536);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs(p, @constCast(""));
}

fn ring_HtmlAttrOfTag(p: *anyopaque) callconv(.c) void {
    const doc = getDoc(p, 1);
    const tag_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const tag_len: usize = @intCast(gss(p, 2));
    const n: i32 = @intFromFloat(gn(p, 3));
    const attr_ptr: [*]const u8 = @ptrCast(gs(p, 4));
    const attr_len: usize = @intCast(gss(p, 4));
    var buf: [4096]u8 = undefined;
    const out_len = dom.html_attr_of_tag(doc, tag_ptr, tag_len, n, attr_ptr, attr_len, &buf, 4096);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs(p, @constCast(""));
}

fn ring_HtmlAllText(p: *anyopaque) callconv(.c) void {
    const doc = getDoc(p, 1);
    var buf: [65536]u8 = undefined;
    const out_len = dom.html_all_text(doc, &buf, 65536);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs(p, @constCast(""));
}

fn ring_HtmlTagOf(p: *anyopaque) callconv(.c) void {
    const doc = getDoc(p, 1);
    const n: i32 = @intFromFloat(gn(p, 2));
    var buf: [256]u8 = undefined;
    const out_len = dom.html_tag_of(doc, n, &buf, 256);
    if (out_len > 0) rs2(p, &buf, @intCast(out_len)) else rs(p, @constCast(""));
}

fn ring_HtmlFindById(p: *anyopaque) callconv(.c) void {
    const doc = getDoc(p, 1);
    const id_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const id_len: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(dom.html_find_by_id(doc, id_ptr, id_len)));
}

fn ring_HtmlCountByClass(p: *anyopaque) callconv(.c) void {
    const doc = getDoc(p, 1);
    const class_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const class_len: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(dom.html_count_by_class(doc, class_ptr, class_len)));
}

fn ring_HtmlFindByClass(p: *anyopaque) callconv(.c) void {
    const doc = getDoc(p, 1);
    const class_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const class_len: usize = @intCast(gss(p, 2));
    const n: i32 = @intFromFloat(gn(p, 3));
    rn(p, @floatFromInt(dom.html_find_by_class(doc, class_ptr, class_len, n)));
}

fn ring_HtmlChildrenCount(p: *anyopaque) callconv(.c) void {
    const doc = getDoc(p, 1);
    const n: i32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(dom.html_children_count(doc, n)));
}

fn ring_HtmlChildAt(p: *anyopaque) callconv(.c) void {
    const doc = getDoc(p, 1);
    const n: i32 = @intFromFloat(gn(p, 2));
    const k: i32 = @intFromFloat(gn(p, 3));
    rn(p, @floatFromInt(dom.html_child_at(doc, n, k)));
}

fn ring_HtmlParentOf(p: *anyopaque) callconv(.c) void {
    const doc = getDoc(p, 1);
    const n: i32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(dom.html_parent_of(doc, n)));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginehtmlencode", .func = ring_HtmlEncode },
    .{ .name = "stzenginehtmldecode", .func = ring_HtmlDecode },
    .{ .name = "stzenginehtmlstriptags", .func = ring_HtmlStripTags },
    .{ .name = "stzenginehtmlencodeattribute", .func = ring_HtmlEncodeAttribute },
    // DOM (new -- M-DEP2 slice 1)
    .{ .name = "stzenginehtmlparse", .func = ring_HtmlParse },
    .{ .name = "stzenginehtmlfree", .func = ring_HtmlFree },
    .{ .name = "stzenginehtmlcount", .func = ring_HtmlCount },
    .{ .name = "stzenginehtmlcountbytag", .func = ring_HtmlCountByTag },
    .{ .name = "stzenginehtmltextoftag", .func = ring_HtmlTextOfTag },
    .{ .name = "stzenginehtmlattroftag", .func = ring_HtmlAttrOfTag },
    .{ .name = "stzenginehtmlalltext", .func = ring_HtmlAllText },
    .{ .name = "stzenginehtmltagof", .func = ring_HtmlTagOf },
    // slice 2 -- id / class lookup + tree walking
    .{ .name = "stzenginehtmlfindbyid", .func = ring_HtmlFindById },
    .{ .name = "stzenginehtmlcountbyclass", .func = ring_HtmlCountByClass },
    .{ .name = "stzenginehtmlfindbyclass", .func = ring_HtmlFindByClass },
    .{ .name = "stzenginehtmlchildrencount", .func = ring_HtmlChildrenCount },
    .{ .name = "stzenginehtmlchildat", .func = ring_HtmlChildAt },
    .{ .name = "stzenginehtmlparentof", .func = ring_HtmlParentOf },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
