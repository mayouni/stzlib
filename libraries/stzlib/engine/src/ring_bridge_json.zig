const std = @import("std");
const j = @import("json.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;

// Shadow the real cpointer functions: store/resolve via handle table.
fn rcp(p: *anyopaque, ptr: ?*anyopaque, _: [*:0]const u8) void {
    R.retHandle(p, ptr);
}

fn gcp(p: *anyopaque, n: c_int, _: [*:0]const u8) ?*anyopaque {
    return R.getHandle(p, n);
}

const H: [*:0]const u8 = "StzJsonHandle";

fn getH(p: *anyopaque, n: c_int) j.StzJsonHandle {
    const ptr = gcp(p, n, H);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn ring_Parse(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(j.stz_json_parse(gs(p, 1), @intCast(gss(p, 1)))), H);
}
fn ring_Free(p: *anyopaque) callconv(.c) void {
    const raw = R.releaseHandle(p, 1);
    if (raw) |ptr| {
        const h: j.StzJsonHandle = @ptrCast(@alignCast(ptr));
        j.stz_json_free(h);
    }
}
fn ring_IsValid(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(j.stz_json_is_valid(getH(p, 1)))); }
fn ring_IsArray(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(j.stz_json_is_array(getH(p, 1)))); }
fn ring_Size(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(j.stz_json_size(getH(p, 1)))); }
fn ring_HasKey(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(j.stz_json_has_key(getH(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_GetString(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = j.stz_json_get_string(getH(p, 1), gs(p, 2), @intCast(gss(p, 2)), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_GetInt(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(j.stz_json_get_int(getH(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_GetBool(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(j.stz_json_get_bool(getH(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_ArrayAtString(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = j.stz_json_array_at_string(getH(p, 1), @intFromFloat(g(p, 2)), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_ArrayAtInt(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(j.stz_json_array_at_int(getH(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_ToString(p: *anyopaque) callconv(.c) void {
    var out_len: usize = 0;
    const ptr = j.stz_json_to_string(getH(p, 1), &out_len);
    if (ptr != null and out_len > 0) {
        rs2(p, ptr, @intCast(out_len));
        j.stz_json_string_free(ptr, out_len);
    } else rs(p, "");
}
fn ring_ToStringPretty(p: *anyopaque) callconv(.c) void {
    var out_len: usize = 0;
    const ptr = j.stz_json_to_string_pretty(getH(p, 1), &out_len);
    if (ptr != null and out_len > 0) {
        rs2(p, ptr, @intCast(out_len));
        j.stz_json_string_free(ptr, out_len);
    } else rs(p, "");
}
fn ring_Keys(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = j.stz_json_keys(getH(p, 1), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_Error(p: *anyopaque) callconv(.c) void {
    var buf: [256]u8 = undefined;
    const n = j.stz_json_error(getH(p, 1), &buf, 256);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}

pub // JsonEscapeNonAscii(cJson) -> the same JSON with every non-ASCII
// character written as \uXXXX. Ring's own JsonToList loses its place on a
// raw multibyte character and answers a well-formed WRONG list; this is
// what a caller runs the text through first. The reason, with the
// measurement, is on the engine function.
fn ring_EscapeNonAscii(p: *anyopaque) callconv(.c) void {
    const n: usize = @intCast(gss(p, 1));
    if (n == 0) {
        rs(p, "");
        return;
    }
    const src = gs(p, 1);
    var out_len: usize = 0;
    const out = j.stz_json_escape_nonascii(src, n, &out_len);
    if (out == null) {
        rs(p, "");
        return;
    }
    defer j.stz_json_escape_free(out, out_len);
    rs2(p, out, @intCast(out_len));
}

// ---------------------------------------------------------------- to Ring
//
// JsonParse(cText) -> the whole document as Ring lists, in ONE crossing:
// an object as a list of [ key, value ] pairs (which is what Ring's hash
// syntax a[:key] reads), an array as a plain list, a string as a string, a
// number as a number, true/false as 1/0 and null as "".
//
// WHY THIS EXISTS. Ring's own JsonToList is wrong on real documents in two
// ways, both measured on the same 108 KB file:
//
//   IT LOSES ITS PLACE on a raw multibyte character. The world atlas has
//   exactly two non-ASCII bytes in 107,760 -- the circumflex in one
//   country's name -- and with them JsonToList answered NINE top-level
//   arcs where the file holds 595, having picked up a value from inside a
//   nested object. One ASCII substitution, nothing else changed, and it
//   answered 595.
//
//   AND IT DOES NOT READ \uXXXX AT ALL. Given "t\u00f4u" it answers
//   `tu00f4u`: the backslash is dropped and the digits kept. So escaping
//   the document -- the first repair -- fixed the structure and left every
//   accented name mangled, which is how "Cote d'Ivoire" stopped matching
//   itself.
//
// Both are silent: a well-formed list, wrong. std.json is already linked
// into this module, so the honest answer was always to parse here and hand
// over the finished tree.
fn emitJsonValue(list: *anyopaque, v: std.json.Value) void {
    switch (v) {
        .null => R.ring_list_addstring2(list, "", 0),
        .bool => |b| R.ring_list_adddouble(list, if (b) 1 else 0),
        .integer => |i| R.ring_list_adddouble(list, @floatFromInt(i)),
        .float => |f| R.ring_list_adddouble(list, f),
        .number_string => |sv| R.ring_list_addstring2(list, sv.ptr, @intCast(sv.len)),
        .string => |sv| R.ring_list_addstring2(list, sv.ptr, @intCast(sv.len)),
        .array => |arr| {
            const sub = R.ring_list_newlist(list) orelse return;
            for (arr.items) |item| emitJsonValue(sub, item);
        },
        .object => |obj| {
            const sub = R.ring_list_newlist(list) orelse return;
            var it = obj.iterator();
            while (it.next()) |kv| {
                // one PAIR per key: Ring reads [ [k, v], ... ] as a hash
                const pair = R.ring_list_newlist(sub) orelse continue;
                R.ring_list_addstring2(pair, kv.key_ptr.*.ptr, @intCast(kv.key_ptr.*.len));
                emitJsonValue(pair, kv.value_ptr.*);
            }
        },
    }
}

fn ring_JsonParseToList(p: *anyopaque) callconv(.c) void {
    const n: usize = @intCast(gss(p, 1));
    const out = R.ring_vm_api_newlist(p) orelse return;
    if (n == 0) {
        R.ring_vm_api_retlist(p, out);
        return;
    }
    const src = gs(p, 1);
    const parsed = std.json.parseFromSlice(std.json.Value, std.heap.c_allocator, src[0..n], .{}) catch {
        R.ring_vm_api_retlist(p, out);
        return;
    };
    defer parsed.deinit();
    // THE DOCUMENT'S OWN TOP LEVEL IS THE ANSWER, not a wrapper round it:
    // an object comes back as the list of pairs Ring reads with a[:key],
    // an array as the list itself. That is exactly JsonToList's shape, so
    // this is a drop-in for it and no caller has to be rewritten twice.
    switch (parsed.value) {
        .object => |obj| {
            var it = obj.iterator();
            while (it.next()) |kv| {
                const pair = R.ring_list_newlist(out) orelse continue;
                R.ring_list_addstring2(pair, kv.key_ptr.*.ptr, @intCast(kv.key_ptr.*.len));
                emitJsonValue(pair, kv.value_ptr.*);
            }
        },
        .array => |arr| {
            for (arr.items) |item| emitJsonValue(out, item);
        },
        else => emitJsonValue(out, parsed.value),
    }
    R.ring_vm_api_retlist(p, out);
}

const regs = [_]R.Reg{
    .{ .name = "stzenginejsonparse", .func = &ring_Parse },
    .{ .name = "stzenginejsonescapenonascii", .func = &ring_EscapeNonAscii },
    .{ .name = "stzenginejsonparsetolist", .func = &ring_JsonParseToList },
    .{ .name = "stzenginejsonfree", .func = &ring_Free },
    .{ .name = "stzenginejsonisvalid", .func = &ring_IsValid },
    .{ .name = "stzenginejsonisarray", .func = &ring_IsArray },
    .{ .name = "stzenginejsonsize", .func = &ring_Size },
    .{ .name = "stzenginejsonhaskey", .func = &ring_HasKey },
    .{ .name = "stzenginejsongetstring", .func = &ring_GetString },
    .{ .name = "stzenginejsongetint", .func = &ring_GetInt },
    .{ .name = "stzenginejsongetbool", .func = &ring_GetBool },
    .{ .name = "stzenginejsonarrayatstring", .func = &ring_ArrayAtString },
    .{ .name = "stzenginejsonarrayatint", .func = &ring_ArrayAtInt },
    .{ .name = "stzenginejsontostring", .func = &ring_ToString },
    .{ .name = "stzenginejsontostringpretty", .func = &ring_ToStringPretty },
    .{ .name = "stzenginejsonkeys", .func = &ring_Keys },
    .{ .name = "stzenginejsonerror", .func = &ring_Error },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
