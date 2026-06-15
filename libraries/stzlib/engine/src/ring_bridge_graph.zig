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

// Build & return a Ring list from a '\n'-joined buffer. The split happens
// here (Zig side) so the Ring caller receives a ready list -- no Ring-side
// looping/splitting.
fn retLines(p: *anyopaque, buf: []const u8) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    if (buf.len > 0) {
        var it = std.mem.splitScalar(u8, buf, '\n');
        while (it.next()) |seg| {
            R.ring_list_addstring2(out, seg.ptr, @intCast(seg.len));
        }
    }
    R.ring_vm_api_retlist(p, out);
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
    retLines(p, buf[0..len]);
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
    retLines(p, buf[0..len]);
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
    retLines(p, buf[0..len]);
}

fn ring_DFS(p: *anyopaque) callconv(.c) void {
    const id = gs(p, 2);
    const id_len: usize = @intCast(gss(p, 2));
    var buf: [8192]u8 = undefined;
    const len = graph.stz_graph_dfs(getH(p, 1), id, id_len, &buf, 8192);
    retLines(p, buf[0..len]);
}

fn ring_Dijkstra(p: *anyopaque) callconv(.c) void {
    const from = gs(p, 2);
    const from_len: usize = @intCast(gss(p, 2));
    const to = gs(p, 3);
    const to_len: usize = @intCast(gss(p, 3));
    var buf: [8192]u8 = undefined;
    const len = graph.stz_graph_dijkstra(getH(p, 1), from, from_len, to, to_len, &buf, 8192);
    retLines(p, buf[0..len]);
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

fn ring_NumberOfSCC(p: *anyopaque) callconv(.c) void {
    const gr = getH(p, 1) orelse { rn(p, 0); return; };
    const n = graph.stz_graph_node_count(gr);
    if (n == 0) { rn(p, 0); return; }
    const labels = gpa.alloc(u32, n) catch { rn(p, 0); return; };
    defer gpa.free(labels);
    rn(p, @floatFromInt(graph.stz_graph_strongly_connected_components(gr, labels.ptr, n)));
}

// Grouped SCCs: one line per component (newline-separated), node names
// within a component comma-separated.
// Returns the SCCs as a Ring list of lists of node names -- built entirely
// here (Zig side), so the Ring caller gets a ready nested list.
fn ring_StronglyConnectedComponents(p: *anyopaque) callconv(.c) void {
    const outer = R.ring_vm_api_newlist(p) orelse return;
    const gr = getH(p, 1) orelse { R.ring_vm_api_retlist(p, outer); return; };
    const n = graph.stz_graph_node_count(gr);
    if (n == 0) { R.ring_vm_api_retlist(p, outer); return; }
    const labels = gpa.alloc(u32, n) catch { R.ring_vm_api_retlist(p, outer); return; };
    defer gpa.free(labels);
    const nc = graph.stz_graph_strongly_connected_components(gr, labels.ptr, n);
    var name_buf: [256]u8 = undefined;
    var comp: u32 = 0;
    while (comp < nc) : (comp += 1) {
        const sub = R.ring_list_newlist(outer) orelse continue;
        for (0..n) |i| {
            if (labels[i] != comp) continue;
            const nlen = graph.stz_graph_node_name(gr, i, &name_buf, 256);
            R.ring_list_addstring2(sub, &name_buf, @intCast(nlen));
        }
    }
    R.ring_vm_api_retlist(p, outer);
}

fn ring_MSTWeight(p: *anyopaque) callconv(.c) void {
    rn(p, graph.stz_graph_mst_weight(getH(p, 1)));
}

fn addName(sub: *anyopaque, gr: *const graph.StzGraph, idx: usize) void {
    var nb: [256]u8 = undefined;
    const nlen = graph.stz_graph_node_name(gr, idx, &nb, 256);
    R.ring_list_addstring2(sub, &nb, @intCast(nlen));
}

// MST edges as a list of [fromName, toName, weight] triples (built Zig-side).
fn ring_MSTEdges(p: *anyopaque) callconv(.c) void {
    const outer = R.ring_vm_api_newlist(p) orelse return;
    const gr = getH(p, 1) orelse { R.ring_vm_api_retlist(p, outer); return; };
    const n = graph.stz_graph_node_count(gr);
    if (n < 2) { R.ring_vm_api_retlist(p, outer); return; }
    const ou = gpa.alloc(u32, n) catch { R.ring_vm_api_retlist(p, outer); return; };
    defer gpa.free(ou);
    const ov = gpa.alloc(u32, n) catch { R.ring_vm_api_retlist(p, outer); return; };
    defer gpa.free(ov);
    const ow = gpa.alloc(f64, n) catch { R.ring_vm_api_retlist(p, outer); return; };
    defer gpa.free(ow);
    const m = graph.stz_graph_mst_edges(gr, ou.ptr, ov.ptr, ow.ptr, n);
    for (0..m) |i| {
        const sub = R.ring_list_newlist(outer) orelse continue;
        addName(sub, gr, ou[i]);
        addName(sub, gr, ov[i]);
        R.ring_list_adddouble(sub, ow[i]);
    }
    R.ring_vm_api_retlist(p, outer);
}

// Articulation points as a flat list of node names.
fn ring_ArticulationPoints(p: *anyopaque) callconv(.c) void {
    const outer = R.ring_vm_api_newlist(p) orelse return;
    const gr = getH(p, 1) orelse { R.ring_vm_api_retlist(p, outer); return; };
    const n = graph.stz_graph_node_count(gr);
    if (n == 0) { R.ring_vm_api_retlist(p, outer); return; }
    const out = gpa.alloc(u32, n) catch { R.ring_vm_api_retlist(p, outer); return; };
    defer gpa.free(out);
    const c = graph.stz_graph_articulation_points(gr, out.ptr, n);
    for (0..c) |i| addName(outer, gr, out[i]);
    R.ring_vm_api_retlist(p, outer);
}

// Bridge edges as a list of [uName, vName] pairs.
fn ring_Bridges(p: *anyopaque) callconv(.c) void {
    const outer = R.ring_vm_api_newlist(p) orelse return;
    const gr = getH(p, 1) orelse { R.ring_vm_api_retlist(p, outer); return; };
    const n = graph.stz_graph_node_count(gr);
    if (n == 0) { R.ring_vm_api_retlist(p, outer); return; }
    // up to n-1 bridges in a tree; cap at n to be safe
    const bu = gpa.alloc(u32, n) catch { R.ring_vm_api_retlist(p, outer); return; };
    defer gpa.free(bu);
    const bv = gpa.alloc(u32, n) catch { R.ring_vm_api_retlist(p, outer); return; };
    defer gpa.free(bv);
    const c = graph.stz_graph_bridges(gr, bu.ptr, bv.ptr, n);
    var i: usize = 0;
    while (i < c and i < n) : (i += 1) {
        const sub = R.ring_list_newlist(outer) orelse continue;
        addName(sub, gr, bu[i]);
        addName(sub, gr, bv[i]);
    }
    R.ring_vm_api_retlist(p, outer);
}

// Compute a per-node centrality vector with `fnc`, then build a Ring list of
// [nodeName, value] pairs (Zig-side -- no Ring looping).
fn retCentralityAll(p: *anyopaque, fnc: *const fn (?*const graph.StzGraph, [*]f64, usize) callconv(.c) usize) void {
    const outer = R.ring_vm_api_newlist(p) orelse return;
    const gr = getH(p, 1) orelse { R.ring_vm_api_retlist(p, outer); return; };
    const n = graph.stz_graph_node_count(gr);
    if (n == 0) { R.ring_vm_api_retlist(p, outer); return; }
    const vals = gpa.alloc(f64, n) catch { R.ring_vm_api_retlist(p, outer); return; };
    defer gpa.free(vals);
    _ = fnc(gr, vals.ptr, n);
    for (0..n) |i| {
        const sub = R.ring_list_newlist(outer) orelse continue;
        addName(sub, gr, i);
        R.ring_list_adddouble(sub, vals[i]);
    }
    R.ring_vm_api_retlist(p, outer);
}

// Compute the centrality vector with `fnc`, return the value for the node
// whose (already-normalised) name matches arg 2; 0 if not found.
fn retCentralityOf(p: *anyopaque, fnc: *const fn (?*const graph.StzGraph, [*]f64, usize) callconv(.c) usize) void {
    const gr = getH(p, 1) orelse { rn(p, 0); return; };
    const n = graph.stz_graph_node_count(gr);
    if (n == 0) { rn(p, 0); return; }
    const query = gs(p, 2);
    const qlen: usize = @intCast(gss(p, 2));
    const qslice = query[0..qlen];
    const vals = gpa.alloc(f64, n) catch { rn(p, 0); return; };
    defer gpa.free(vals);
    _ = fnc(gr, vals.ptr, n);
    var nb: [256]u8 = undefined;
    for (0..n) |i| {
        const nlen = graph.stz_graph_node_name(gr, i, &nb, 256);
        if (std.mem.eql(u8, nb[0..nlen], qslice)) { rn(p, vals[i]); return; }
    }
    rn(p, 0);
}

fn ring_ClosenessAll(p: *anyopaque) callconv(.c) void {
    retCentralityAll(p, &graph.stz_graph_closeness);
}
fn ring_ClosenessOf(p: *anyopaque) callconv(.c) void {
    retCentralityOf(p, &graph.stz_graph_closeness);
}
fn ring_BetweennessAll(p: *anyopaque) callconv(.c) void {
    retCentralityAll(p, &graph.stz_graph_betweenness);
}
fn ring_BetweennessOf(p: *anyopaque) callconv(.c) void {
    retCentralityOf(p, &graph.stz_graph_betweenness);
}

fn ring_SetCoords(p: *anyopaque) callconv(.c) void {
    const id = gs(p, 2);
    const id_len: usize = @intCast(gss(p, 2));
    const x = g(p, 3);
    const y = g(p, 4);
    rn(p, @floatFromInt(graph.stz_graph_set_coords(getMutH(p, 1), id, id_len, x, y)));
}

fn ring_AStar(p: *anyopaque) callconv(.c) void {
    const from = gs(p, 2);
    const from_len: usize = @intCast(gss(p, 2));
    const to = gs(p, 3);
    const to_len: usize = @intCast(gss(p, 3));
    const mode: i32 = @intFromFloat(g(p, 4));
    var buf: [8192]u8 = undefined;
    const len = graph.stz_graph_astar(getH(p, 1), from, from_len, to, to_len, mode, &buf, 8192);
    retLines(p, buf[0..len]);
}

fn ring_SetEdgeWeight(p: *anyopaque) callconv(.c) void {
    const from = gs(p, 2);
    const from_len: usize = @intCast(gss(p, 2));
    const to = gs(p, 3);
    const to_len: usize = @intCast(gss(p, 3));
    const w = g(p, 4);
    rn(p, @floatFromInt(graph.stz_graph_set_edge_weight(getMutH(p, 1), from, from_len, to, to_len, w)));
}

// Split a '\n'-joined buffer into an existing Ring sublist (Zig-side).
fn addSplit(lst: *anyopaque, buf: []const u8) void {
    if (buf.len == 0) return;
    var it = std.mem.splitScalar(u8, buf, '\n');
    while (it.next()) |seg| {
        R.ring_list_addstring2(lst, seg.ptr, @intCast(seg.len));
    }
}

// A* for the planner: returns [ routeList, exploredList ] -- one engine search
// builds both ready Ring lists. mode is arg 4 (0 = Dijkstra/UCS, optimal for
// any non-negative cost).
fn ring_AStarPlan(p: *anyopaque) callconv(.c) void {
    const outer = R.ring_vm_api_newlist(p) orelse return;
    const from = gs(p, 2);
    const from_len: usize = @intCast(gss(p, 2));
    const to = gs(p, 3);
    const to_len: usize = @intCast(gss(p, 3));
    const mode: i32 = @intFromFloat(g(p, 4));
    var pbuf: [8192]u8 = undefined;
    var ebuf: [16384]u8 = undefined;
    var elen: usize = 0;
    const plen = graph.stz_graph_astar_full(getH(p, 1), from, from_len, to, to_len, mode, &pbuf, 8192, &ebuf, 16384, &elen);
    const routeSub = R.ring_list_newlist(outer) orelse { R.ring_vm_api_retlist(p, outer); return; };
    addSplit(routeSub, pbuf[0..plen]);
    const expSub = R.ring_list_newlist(outer) orelse { R.ring_vm_api_retlist(p, outer); return; };
    addSplit(expSub, ebuf[0..elen]);
    R.ring_vm_api_retlist(p, outer);
}

fn ring_CoreNumbersAll(p: *anyopaque) callconv(.c) void {
    retCentralityAll(p, &graph.stz_graph_core_numbers);
}
fn ring_CoreNumberOf(p: *anyopaque) callconv(.c) void {
    retCentralityOf(p, &graph.stz_graph_core_numbers);
}
fn ring_PageRankAll(p: *anyopaque) callconv(.c) void {
    retCentralityAll(p, &graph.stz_graph_pagerank_default);
}
fn ring_PageRankOf(p: *anyopaque) callconv(.c) void {
    retCentralityOf(p, &graph.stz_graph_pagerank_default);
}

fn ring_Reachable(p: *anyopaque) callconv(.c) void {
    const id = gs(p, 2);
    const id_len: usize = @intCast(gss(p, 2));
    var buf: [16384]u8 = undefined;
    const len = graph.stz_graph_reachable(getH(p, 1), id, id_len, &buf, 16384);
    retLines(p, buf[0..len]);
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
    const out = R.ring_vm_api_newlist(p) orelse return;
    const gr = getH(p, 1) orelse { R.ring_vm_api_retlist(p, out); return; };
    const n = graph.stz_graph_node_count(gr);
    if (n == 0) { R.ring_vm_api_retlist(p, out); return; }
    const result = gpa.alloc(u32, n) catch { R.ring_vm_api_retlist(p, out); return; };
    defer gpa.free(result);
    const count = graph.stz_graph_topological_sort(gr, result.ptr, n);
    var name_buf: [256]u8 = undefined;
    for (0..count) |i| {
        const nlen = graph.stz_graph_node_name(gr, result[i], &name_buf, 256);
        R.ring_list_addstring2(out, &name_buf, @intCast(nlen));
    }
    R.ring_vm_api_retlist(p, out);
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
    .{ .name = "stzenginegraphnumberofscc", .func = &ring_NumberOfSCC },
    .{ .name = "stzenginegraphstronglyconnectedcomponents", .func = &ring_StronglyConnectedComponents },
    .{ .name = "stzenginegraphmstweight", .func = &ring_MSTWeight },
    .{ .name = "stzenginegraphmstedges", .func = &ring_MSTEdges },
    .{ .name = "stzenginegrapharticulationpoints", .func = &ring_ArticulationPoints },
    .{ .name = "stzenginegraphbridges", .func = &ring_Bridges },
    .{ .name = "stzenginegraphclosenessall", .func = &ring_ClosenessAll },
    .{ .name = "stzenginegraphclosenessof", .func = &ring_ClosenessOf },
    .{ .name = "stzenginegraphbetweennessall", .func = &ring_BetweennessAll },
    .{ .name = "stzenginegraphbetweennessof", .func = &ring_BetweennessOf },
    .{ .name = "stzenginegraphcorenumbersall", .func = &ring_CoreNumbersAll },
    .{ .name = "stzenginegraphcorenumberof", .func = &ring_CoreNumberOf },
    .{ .name = "stzenginegraphpagerankall", .func = &ring_PageRankAll },
    .{ .name = "stzenginegraphpagerankof", .func = &ring_PageRankOf },
    .{ .name = "stzenginegraphsetcoords", .func = &ring_SetCoords },
    .{ .name = "stzenginegraphastar", .func = &ring_AStar },
    .{ .name = "stzenginegraphsetedgeweight", .func = &ring_SetEdgeWeight },
    .{ .name = "stzenginegraphastarplan", .func = &ring_AStarPlan },
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
