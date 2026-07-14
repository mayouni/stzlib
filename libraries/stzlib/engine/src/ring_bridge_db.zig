const db = @import("db.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;

fn ring_Open(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(db.stz_db_open(gs(p, 1))));
}
fn ring_Exec(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(db.stz_db_exec(@intFromFloat(gn(p, 1)), gs(p, 2))));
}
fn ring_Query(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(db.stz_db_query(@intFromFloat(gn(p, 1)), gs(p, 2))));
}
fn ring_Result(p: *anyopaque) callconv(.c) void {
    rs(p, @ptrCast(db.stz_db_result()));
}
fn ring_Error(p: *anyopaque) callconv(.c) void {
    rs(p, @ptrCast(db.stz_db_error()));
}
fn ring_Close(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(db.stz_db_close(@intFromFloat(gn(p, 1)))));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginedbopen", .func = &ring_Open },
    .{ .name = "stzenginedbexec", .func = &ring_Exec },
    .{ .name = "stzenginedbquery", .func = &ring_Query },
    .{ .name = "stzenginedbresult", .func = &ring_Result },
    .{ .name = "stzenginedberror", .func = &ring_Error },
    .{ .name = "stzenginedbclose", .func = &ring_Close },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
