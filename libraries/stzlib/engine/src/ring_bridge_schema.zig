const mod = @import("schema.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_Create(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_schema_create(name, name_len)));
}

fn ring_AddField(p: *anyopaque) callconv(.c) void {
    const schema_idx: i32 = @intFromFloat(gn(p, 1));
    const name: [*]const u8 = @ptrCast(gs(p, 2));
    const name_len: usize = @intCast(gl(p, 2));
    const field_type: i32 = @intFromFloat(gn(p, 3));
    const required: i32 = @intFromFloat(gn(p, 4));
    rn(p, @floatFromInt(mod.stz_schema_add_field(schema_idx, name, name_len, field_type, required)));
}

fn ring_FieldCount(p: *anyopaque) callconv(.c) void {
    const schema_idx: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(mod.stz_schema_field_count(schema_idx)));
}

fn ring_FieldName(p: *anyopaque) callconv(.c) void {
    const schema_idx: i32 = @intFromFloat(gn(p, 1));
    const field_idx: i32 = @intFromFloat(gn(p, 2));
    var buf: [64]u8 = undefined;
    const len = mod.stz_schema_field_name(schema_idx, field_idx, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_FieldType(p: *anyopaque) callconv(.c) void {
    const schema_idx: i32 = @intFromFloat(gn(p, 1));
    const field_idx: i32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(mod.stz_schema_field_type(schema_idx, field_idx)));
}

fn ring_FieldRequired(p: *anyopaque) callconv(.c) void {
    const schema_idx: i32 = @intFromFloat(gn(p, 1));
    const field_idx: i32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(mod.stz_schema_field_required(schema_idx, field_idx)));
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_schema_count()));
}

fn ring_Destroy(p: *anyopaque) callconv(.c) void {
    const schema_idx: i32 = @intFromFloat(gn(p, 1));
    mod.stz_schema_destroy(schema_idx);
    rn(p, 1);
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_schema_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = @constCast("stzengineschemacreate"), .func = ring_Create },
    .{ .name = @constCast("stzengineschemaaddfield"), .func = ring_AddField },
    .{ .name = @constCast("stzengineschemafieldcount"), .func = ring_FieldCount },
    .{ .name = @constCast("stzengineschemafieldname"), .func = ring_FieldName },
    .{ .name = @constCast("stzengineschemafieldtype"), .func = ring_FieldType },
    .{ .name = @constCast("stzengineschemafieldrequired"), .func = ring_FieldRequired },
    .{ .name = @constCast("stzengineschemacount"), .func = ring_Count },
    .{ .name = @constCast("stzengineschemadestroy"), .func = ring_Destroy },
    .{ .name = @constCast("stzengineschemaclear"), .func = ring_Clear },
};
