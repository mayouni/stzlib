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

// These four all wrote into a FIXED 65536-byte stack buffer, and the engine
// functions return -1 on overflow, which the bridge turned into an empty
// string. So encoding anything past ~64 KB silently produced "" -- a real
// document vanished with no error. Sizing the buffer to the worst case for
// the operation removes the cliff.
//
// Worst-case growth per output:
//   encode / encode_attribute : 6x  ('"' -> "&quot;", 6 bytes; the longest)
//   decode / strip_tags       : 1x  (both only ever SHRINK)
// A heap allocation avoids putting a 6x-of-input array on the stack.
const gpa = std.heap.c_allocator;
const std = @import("std");

fn htmlXform(
    p: *anyopaque,
    comptime f: fn ([*]const u8, usize, [*]u8, usize) callconv(.c) i32,
    growth: usize,
) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    if (len == 0) {
        rs(p, @constCast(""));
        return;
    }
    // +8 covers the largest single entity when len is tiny; growth*len is the
    // real bound.
    const cap = len * growth + 8;
    const buf = gpa.alloc(u8, cap) catch {
        rs(p, @constCast(""));
        return;
    };
    defer gpa.free(buf);
    const out_len = f(ptr, len, buf.ptr, cap);
    if (out_len > 0) rs2(p, buf.ptr, @intCast(out_len)) else rs(p, @constCast(""));
}

fn ring_HtmlEncode(p: *anyopaque) callconv(.c) void {
    htmlXform(p, html.html_encode, 6);
}

fn ring_HtmlDecode(p: *anyopaque) callconv(.c) void {
    htmlXform(p, html.html_decode, 1);
}

fn ring_HtmlStripTags(p: *anyopaque) callconv(.c) void {
    htmlXform(p, html.html_strip_tags, 1);
}

fn ring_HtmlEncodeAttribute(p: *anyopaque) callconv(.c) void {
    htmlXform(p, html.html_encode_attribute, 6);
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

// Returns a Ring list of [ tag, occurrence ] pairs -- every class match in
// one engine pass. Replaces the O(n^2) find_by_class(1..count) loop.
fn ring_HtmlClassPairs(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const doc = getDoc(p, 1);
    const class_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const class_len: usize = @intCast(gss(p, 2));

    var out_len: usize = 0;
    const ptr = dom.html_class_pairs(doc, class_ptr, class_len, &out_len);
    if (ptr != null) {
        defer dom.html_pairs_free(ptr, out_len);
        const b = ptr[0..out_len];
        // Walk NUL-delimited fields two at a time: tag, then occurrence.
        var start: usize = 0;
        var i: usize = 0;
        var pending_tag: ?[]const u8 = null;
        while (i < b.len) : (i += 1) {
            if (b[i] == 0) {
                const field = b[start..i];
                start = i + 1;
                if (pending_tag) |tagbytes| {
                    const pair = R.ring_list_newlist(out) orelse {
                        pending_tag = null;
                        continue;
                    };
                    R.ring_list_addstring2(pair, tagbytes.ptr, @intCast(tagbytes.len));
                    const occ = std.fmt.parseInt(c_int, field, 10) catch 0;
                    R.ring_list_addint(pair, occ);
                    pending_tag = null;
                } else {
                    pending_tag = field;
                }
            }
        }
    }
    R.ring_vm_api_retlist(p, out);
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
    .{ .name = "stzenginehtmlclasspairs", .func = ring_HtmlClassPairs },
    .{ .name = "stzenginehtmlchildrencount", .func = ring_HtmlChildrenCount },
    .{ .name = "stzenginehtmlchildat", .func = ring_HtmlChildAt },
    .{ .name = "stzenginehtmlparentof", .func = ring_HtmlParentOf },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
