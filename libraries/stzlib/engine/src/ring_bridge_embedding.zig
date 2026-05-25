const mod = @import("embedding.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_Store3(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    var vec: [3]f64 = .{ gn(p, 2), gn(p, 3), gn(p, 4) };
    rn(p, @floatFromInt(mod.stz_emb_store(name, name_len, &vec, 3)));
}

fn ring_Dim(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_emb_dim(name, name_len)));
}

fn ring_Cosine(p: *anyopaque) callconv(.c) void {
    const name_a: [*]const u8 = @ptrCast(gs(p, 1));
    const a_len: usize = @intCast(gl(p, 1));
    const name_b: [*]const u8 = @ptrCast(gs(p, 2));
    const b_len: usize = @intCast(gl(p, 2));
    rn(p, mod.stz_emb_cosine(name_a, a_len, name_b, b_len));
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_emb_count()));
}

fn ring_Has(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_emb_has(name, name_len)));
}

fn ring_Remove(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_emb_remove(name, name_len)));
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_emb_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = @constCast("stzengineembstore3"), .func = ring_Store3 },
    .{ .name = @constCast("stzengineembdim"), .func = ring_Dim },
    .{ .name = @constCast("stzengineembcosine"), .func = ring_Cosine },
    .{ .name = @constCast("stzengineembcount"), .func = ring_Count },
    .{ .name = @constCast("stzengineembhas"), .func = ring_Has },
    .{ .name = @constCast("stzengineembremove"), .func = ring_Remove },
    .{ .name = @constCast("stzengineembclear"), .func = ring_Clear },
};
