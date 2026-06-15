const std = @import("std");
const graph = @import("graph.zig");
const R = @import("ring_api.zig");

const gpa = std.heap.c_allocator;

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
    const raw = R.releaseHandle(p, 1);
    if (raw) |ptr| {
        const c: ?*graph.StzGraph = @ptrCast(@alignCast(ptr));
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

fn ring_BFS(p: *anyopaque) callconv(.c) void {
    const id = gs(p, 2);
    const id_len: usize = @intCast(gss(p, 2));
    var buf: [8192]u8 = undefined;
    const len = graph.stz_graph_bfs(getH(p, 1), id, id_len, &buf, 8192);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs(p, "");
}

fn ring_DFS(p: *anyopaque) callconv(.c) void {
    const id = gs(p, 2);
    const id_len: usize = @intCast(gss(p, 2));
    var buf: [8192]u8 = undefined;
    const len = graph.stz_graph_dfs(getH(p, 1), id, id_len, &buf, 8192);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs(p, "");
}

fn ring_Dijkstra(p: *anyopaque) callconv(.c) void {
    const from = gs(p, 2);
    const from_len: usize = @intCast(gss(p, 2));
    const to = gs(p, 3);
    const to_len: usize = @intCast(gss(p, 3));
    var buf: [8192]u8 = undefined;
    const len = graph.stz_graph_dijkstra(getH(p, 1), from, from_len, to, to_len, &buf, 8192);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs(p, "");
}

fn ring_DijkstraDistance(p: *anyopaque) callconv(.c) void {
    const from = gs(p, 2);
    const from_len: usize = @intCast(gss(p, 2));
    const to = gs(p, 3);
    const to_len: usize = @intCast(gss(p, 3));
    rn(p, graph.stz_graph_dijkstra_distance(getH(p, 1), from, from_len, to, to_len));
}

fn ring_IsBipartite(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(graph.stz_graph_is_bipartite(getH(p, 1))));
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

fn ring_TopologicalSort(p: *anyopaque) callconv(.c) void {
    const gr = getH(p, 1) orelse { rs(p, ""); return; };
    const n = graph.stz_graph_node_count(gr);
    if (n <= 0) { rs(p, ""); return; }
    const nu: usize = @intCast(n);
    const result = gpa.alloc(u32, nu) catch { rs(p, ""); return; };
    defer gpa.free(result);
    const count = graph.stz_graph_topological_sort(gr, result.ptr, nu);
    if (count == 0) { rs(p, ""); return; }
    var buf: [16384]u8 = undefined;
    var out: usize = 0;
    var name_buf: [256]u8 = undefined;
    for (0..count) |i| {
        if (i > 0) {
            if (out >= buf.len) { rs(p, ""); return; }
            buf[out] = '\n';
            out += 1;
        }
        const nlen = graph.stz_graph_node_name(gr, result[i], &name_buf, 256);
        if (out + nlen > buf.len) { rs(p, ""); return; }
        @memcpy(buf[out..][0..nlen], name_buf[0..nlen]);
        out += nlen;
    }
    if (out > 0) rs2(p, &buf, @intCast(out)) else rs(p, "");
}

fn ring_ConnectedComponents(p: *anyopaque) callconv(.c) void {
    const gr = getH(p, 1) orelse { rn(p, 0); return; };
    const n = graph.stz_graph_node_count(gr);
    if (n <= 0) { rn(p, 0); return; }
    const nu: usize = @intCast(n);
    const labels = gpa.alloc(u32, nu) catch { rn(p, 0); return; };
    defer gpa.free(labels);
    const nc = graph.stz_graph_connected_components(gr, labels.ptr, nu);
    rn(p, @floatFromInt(nc));
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
    .{ .name = "stzenginegraphbfs", .func = &ring_BFS },
    .{ .name = "stzenginegraphdfs", .func = &ring_DFS },
    .{ .name = "stzenginegraphdijkstra", .func = &ring_Dijkstra },
    .{ .name = "stzenginegraphdijkstradistance", .func = &ring_DijkstraDistance },
    .{ .name = "stzenginegraphisbipartite", .func = &ring_IsBipartite },
    .{ .name = "stzenginegraphreachable", .func = &ring_Reachable },
    .{ .name = "stzenginegraphhascycle", .func = &ring_HasCycle },
    .{ .name = "stzenginegraphindegree", .func = &ring_InDegree },
    .{ .name = "stzenginegraphoutdegree", .func = &ring_OutDegree },
    .{ .name = "stzenginegraphtopologicalsort", .func = &ring_TopologicalSort },
    .{ .name = "stzenginegraphconnectedcomponents", .func = &ring_ConnectedComponents },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
