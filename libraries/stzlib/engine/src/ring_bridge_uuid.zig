const uuid = @import("uuid.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_V4(p: *anyopaque) callconv(.c) void {
    var buf: [36]u8 = undefined;
    _ = uuid.uuid_v4(&buf);
    rs2(p, &buf, 36);
}

fn ring_V4Compact(p: *anyopaque) callconv(.c) void {
    var buf: [32]u8 = undefined;
    _ = uuid.uuid_v4_compact(&buf);
    rs2(p, &buf, 32);
}

fn ring_IsValid(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(uuid.uuid_is_valid(ptr, len)));
}

fn ring_Version(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(uuid.uuid_version(ptr, len)));
}

fn ring_Nil(p: *anyopaque) callconv(.c) void {
    var buf: [36]u8 = undefined;
    _ = uuid.uuid_nil(&buf);
    rs2(p, &buf, 36);
}

fn ring_Compare(p: *anyopaque) callconv(.c) void {
    const a: [*]const u8 = @ptrCast(gs(p, 1));
    const al: usize = @intCast(gss(p, 1));
    const b: [*]const u8 = @ptrCast(gs(p, 2));
    const bl: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(uuid.uuid_compare(a, al, b, bl)));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineuuidv4", .func = &ring_V4 },
    .{ .name = "stzengineuuidv4compact", .func = &ring_V4Compact },
    .{ .name = "stzengineuuidisvalid", .func = &ring_IsValid },
    .{ .name = "stzengineuuidversion", .func = &ring_Version },
    .{ .name = "stzengineuuidnil", .func = &ring_Nil },
    .{ .name = "stzengineuuidcompare", .func = &ring_Compare },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
