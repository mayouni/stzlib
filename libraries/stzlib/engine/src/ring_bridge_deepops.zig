const R = @import("ring_api.zig");
const mod = @import("deepops.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_SetNesting(p: *anyopaque) callconv(.c) void {
    const depth: i32 = @intFromFloat(gn(p, 1));
    // For Ring bridge, accept depth and count as numbers; sizes from a simple encoding
    // Ring caller passes a string of comma-separated sizes
    const sptr = gs(p, 2);
    const slen: usize = @intCast(gl(p, 2));
    var sizes: [16]i32 = undefined;
    var count: usize = 0;
    var start: usize = 0;
    for (0..slen) |i| {
        if (sptr[i] == ',') {
            sizes[count] = parseI32(sptr[start..i]);
            count += 1;
            start = i + 1;
        }
    }
    if (start < slen) {
        sizes[count] = parseI32(sptr[start..slen]);
        count += 1;
    }
    mod.stz_deep_set_nesting(depth, &sizes, @intCast(count));
}

fn parseI32(s: []const u8) i32 {
    var val: i32 = 0;
    for (s) |c| {
        if (c >= '0' and c <= '9') {
            val = val * 10 + @as(i32, c - '0');
        }
    }
    return val;
}

fn ring_TotalElements(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_deep_total_elements()));
}

fn ring_ElementAtFlat(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(mod.stz_deep_element_at_flat(idx)));
}

fn ring_Depth(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_deep_depth()));
}

fn ring_Flatten(p: *anyopaque) callconv(.c) void {
    var out: [1024]i32 = undefined;
    const n = mod.stz_deep_flatten(&out);
    rn(p, @floatFromInt(n));
}

fn ring_Find(p: *anyopaque) callconv(.c) void {
    const value: i32 = @intFromFloat(gn(p, 1));
    var results: [256]i32 = undefined;
    const n = mod.stz_deep_find(value, &results);
    rn(p, @floatFromInt(n));
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_deep_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzenginedeepsetnesting", .func = ring_SetNesting },
    .{ .name = "stzenginedeeptotalelements", .func = ring_TotalElements },
    .{ .name = "stzenginedeepelementatflat", .func = ring_ElementAtFlat },
    .{ .name = "stzenginedeepdepth", .func = ring_Depth },
    .{ .name = "stzenginedeepflatten", .func = ring_Flatten },
    .{ .name = "stzenginedeepfind", .func = ring_Find },
    .{ .name = "stzenginedeepclear", .func = ring_Clear },
};
