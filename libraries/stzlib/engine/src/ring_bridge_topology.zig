const mod = @import("topology.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;

fn ring_AddNode(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_topo_add_node(name, name_len)));
}

fn ring_AddEdge(p: *anyopaque) callconv(.c) void {
    const name_a: [*]const u8 = @ptrCast(gs(p, 1));
    const a_len: usize = @intCast(gl(p, 1));
    const name_b: [*]const u8 = @ptrCast(gs(p, 2));
    const b_len: usize = @intCast(gl(p, 2));
    rn(p, @floatFromInt(mod.stz_topo_add_edge(name_a, a_len, name_b, b_len)));
}

fn ring_AreNeighbors(p: *anyopaque) callconv(.c) void {
    const name_a: [*]const u8 = @ptrCast(gs(p, 1));
    const a_len: usize = @intCast(gl(p, 1));
    const name_b: [*]const u8 = @ptrCast(gs(p, 2));
    const b_len: usize = @intCast(gl(p, 2));
    rn(p, @floatFromInt(mod.stz_topo_are_neighbors(name_a, a_len, name_b, b_len)));
}

fn ring_NeighborCount(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_topo_neighbor_count(name, name_len)));
}

fn ring_NodeCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_topo_node_count()));
}

fn ring_Connected(p: *anyopaque) callconv(.c) void {
    const name_a: [*]const u8 = @ptrCast(gs(p, 1));
    const a_len: usize = @intCast(gl(p, 1));
    const name_b: [*]const u8 = @ptrCast(gs(p, 2));
    const b_len: usize = @intCast(gl(p, 2));
    rn(p, @floatFromInt(mod.stz_topo_connected(name_a, a_len, name_b, b_len)));
}

fn ring_RemoveNode(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    mod.stz_topo_remove_node(name, name_len);
    rn(p, 1);
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_topo_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = @constCast("stzenginetopoaddnode"), .func = ring_AddNode },
    .{ .name = @constCast("stzenginetopoaddedge"), .func = ring_AddEdge },
    .{ .name = @constCast("stzenginetopoareneighbors"), .func = ring_AreNeighbors },
    .{ .name = @constCast("stzenginetoponeighborcount"), .func = ring_NeighborCount },
    .{ .name = @constCast("stzenginetoponodecount"), .func = ring_NodeCount },
    .{ .name = @constCast("stzenginetopoconnected"), .func = ring_Connected },
    .{ .name = @constCast("stzenginetoporemovenode"), .func = ring_RemoveNode },
    .{ .name = @constCast("stzenginetopoclear"), .func = ring_Clear },
};
