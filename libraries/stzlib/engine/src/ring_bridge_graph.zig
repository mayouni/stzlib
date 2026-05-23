const graph = @import("graph.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const gcp = R.ring_vm_api_getcpointer;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;
const rcp = R.ring_vm_api_retcpointer;

const H: [*:0]const u8 = "StzGraphHandle";

fn getH(p: *anyopaque, n: c_int) ?*const graph.StzGraph {
    const ptr = gcp(p, n, H);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn getMutH(p: *anyopaque, n: c_int) ?*graph.StzGraph {
    const ptr = gcp(p, n, H);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn ring_Create(p: *anyopaque) callconv(.c) void {
    const directed: i32 = @intFromFloat(g(p, 1));
    rcp(p, @ptrCast(graph.stz_graph_create(directed)), H);
}

fn ring_Free(p: *anyopaque) callconv(.c) void {
    const ptr = gcp(p, 1, H);
    if (ptr) |raw| {
        const c: ?*graph.StzGraph = @ptrCast(@alignCast(raw));
        graph.stz_graph_free(c);
    }
}

fn ring_AddNode(p: *anyopaque) callconv(.c) void {
    const id = gs(p, 2);
    const id_len: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(graph.stz_graph_add_node(getMutH(p, 1), id, id_len)));
}

fn ring_NodeCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(graph.stz_graph_node_count(getH(p, 1))));
}

fn ring_EdgeCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(graph.stz_graph_edge_count(getH(p, 1))));
}

fn ring_AddEdge(p: *anyopaque) callconv(.c) void {
    const from = gs(p, 2);
    const from_len: usize = @intCast(gss(p, 2));
    const to = gs(p, 3);
    const to_len: usize = @intCast(gss(p, 3));
    const weight = g(p, 4);
    rn(p, @floatFromInt(graph.stz_graph_add_edge(getMutH(p, 1), from, from_len, to, to_len, weight)));
}

fn ring_HasEdge(p: *anyopaque) callconv(.c) void {
    const from = gs(p, 2);
    const from_len: usize = @intCast(gss(p, 2));
    const to = gs(p, 3);
    const to_len: usize = @intCast(gss(p, 3));
    rn(p, @floatFromInt(graph.stz_graph_has_edge(getH(p, 1), from, from_len, to, to_len)));
}

fn ring_RemoveEdge(p: *anyopaque) callconv(.c) void {
    const from = gs(p, 2);
    const from_len: usize = @intCast(gss(p, 2));
    const to = gs(p, 3);
    const to_len: usize = @intCast(gss(p, 3));
    rn(p, @floatFromInt(graph.stz_graph_remove_edge(getMutH(p, 1), from, from_len, to, to_len)));
}

fn ring_Neighbors(p: *anyopaque) callconv(.c) void {
    const id = gs(p, 2);
    const id_len: usize = @intCast(gss(p, 2));
    var buf: [8192]u8 = undefined;
    const len = graph.stz_graph_neighbors(getH(p, 1), id, id_len, &buf, 8192);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs(p, "");
}

fn ring_NeighborCount(p: *anyopaque) callconv(.c) void {
    const id = gs(p, 2);
    const id_len: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(graph.stz_graph_neighbor_count(getH(p, 1), id, id_len)));
}

fn ring_ShortestPath(p: *anyopaque) callconv(.c) void {
    const from = gs(p, 2);
    const from_len: usize = @intCast(gss(p, 2));
    const to = gs(p, 3);
    const to_len: usize = @intCast(gss(p, 3));
    var buf: [8192]u8 = undefined;
    const len = graph.stz_graph_shortest_path(getH(p, 1), from, from_len, to, to_len, &buf, 8192);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs(p, "");
}

fn ring_PathExists(p: *anyopaque) callconv(.c) void {
    const from = gs(p, 2);
    const from_len: usize = @intCast(gss(p, 2));
    const to = gs(p, 3);
    const to_len: usize = @intCast(gss(p, 3));
    rn(p, @floatFromInt(graph.stz_graph_path_exists(getH(p, 1), from, from_len, to, to_len)));
}

fn ring_Reachable(p: *anyopaque) callconv(.c) void {
    const id = gs(p, 2);
    const id_len: usize = @intCast(gss(p, 2));
    var buf: [16384]u8 = undefined;
    const len = graph.stz_graph_reachable(getH(p, 1), id, id_len, &buf, 16384);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs(p, "");
}

fn ring_HasCycle(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(graph.stz_graph_has_cycle(getH(p, 1))));
}

fn ring_InDegree(p: *anyopaque) callconv(.c) void {
    const id = gs(p, 2);
    const id_len: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(graph.stz_graph_in_degree(getH(p, 1), id, id_len)));
}

fn ring_OutDegree(p: *anyopaque) callconv(.c) void {
    const id = gs(p, 2);
    const id_len: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(graph.stz_graph_out_degree(getH(p, 1), id, id_len)));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginegraphcreate", .func = &ring_Create },
    .{ .name = "stzenginegraphfree", .func = &ring_Free },
    .{ .name = "stzenginegraphaddnode", .func = &ring_AddNode },
    .{ .name = "stzenginegraphnodecount", .func = &ring_NodeCount },
    .{ .name = "stzenginegraphedgecount", .func = &ring_EdgeCount },
    .{ .name = "stzenginegraphaddedge", .func = &ring_AddEdge },
    .{ .name = "stzenginegraphhasedge", .func = &ring_HasEdge },
    .{ .name = "stzenginegraphremoveedge", .func = &ring_RemoveEdge },
    .{ .name = "stzenginegraphneighbors", .func = &ring_Neighbors },
    .{ .name = "stzenginegraphneighborcount", .func = &ring_NeighborCount },
    .{ .name = "stzenginegraphshortestpath", .func = &ring_ShortestPath },
    .{ .name = "stzenginegraphpathexists", .func = &ring_PathExists },
    .{ .name = "stzenginegraphreachable", .func = &ring_Reachable },
    .{ .name = "stzenginegraphhascycle", .func = &ring_HasCycle },
    .{ .name = "stzenginegraphindegree", .func = &ring_InDegree },
    .{ .name = "stzenginegraphoutdegree", .func = &ring_OutDegree },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
