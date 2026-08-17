const std = @import("std");
const graph = @import("graph.zig");
const glayout = @import("graph_layout.zig");
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

// EVERY list-returning graph call goes through this. The engine's contract
// is snprintf's: it returns the size it NEEDED and writes nothing unless the
// whole list fits, so a result larger than the stack buffer is a signal, not
// a truncation. Before this, seven bridges silently cut their answer at
// 8 KB -- and cut the last node NAME in half, handing back an id that is not
// a node. The stack buffer still serves the common case with no allocation.
fn retLinesGrow(p: *anyopaque, stack_buf: []u8, first_len: usize, ctx: anytype) void {
    if (first_len <= stack_buf.len) {
        retLines(p, stack_buf[0..first_len]);
        return;
    }
    const big = gpa.alloc(u8, first_len) catch {
        retLines(p, "");
        return;
    };
    defer gpa.free(big);
    const got = ctx.call(big.ptr, big.len);
    retLines(p, big[0..@min(got, big.len)]);
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

fn ring_AddEdge(p: *anyopaque) callconv(.c) void {
    const from = gs(p, 2);
    const from_len: usize = @intCast(gss(p, 2));
    const to = gs(p, 3);
    const to_len: usize = @intCast(gss(p, 3));
    const weight = g(p, 4);
    rn(p, @floatFromInt(graph.stz_graph_add_edge(getMutH(p, 1), from, from_len, to, to_len, weight)));
}

fn ring_Neighbors(p: *anyopaque) callconv(.c) void {
    const id = gs(p, 2);
    const id_len: usize = @intCast(gss(p, 2));
    var buf: [8192]u8 = undefined;
    const h = getH(p, 1);
    const len = graph.stz_graph_neighbors(h, id, id_len, &buf, buf.len);
    const Ctx = struct {
        h: ?*const graph.StzGraph,
        id: [*]const u8,
        id_len: usize,
        fn call(s: @This(), b: [*]u8, n: usize) usize {
            return graph.stz_graph_neighbors(s.h, s.id, s.id_len, b, n);
        }
    };
    retLinesGrow(p, &buf, len, Ctx{ .h = h, .id = id, .id_len = id_len });
}

fn ring_ShortestPath(p: *anyopaque) callconv(.c) void {
    const from = gs(p, 2);
    const from_len: usize = @intCast(gss(p, 2));
    const to = gs(p, 3);
    const to_len: usize = @intCast(gss(p, 3));
    var buf: [8192]u8 = undefined;
    const h = getH(p, 1);
    const len = graph.stz_graph_shortest_path(h, from, from_len, to, to_len, &buf, buf.len);
    const Ctx = struct {
        h: ?*const graph.StzGraph,
        a: [*]const u8, al: usize, b2: [*]const u8, bl: usize,
        fn call(s: @This(), b: [*]u8, n: usize) usize {
            return graph.stz_graph_shortest_path(s.h, s.a, s.al, s.b2, s.bl, b, n);
        }
    };
    retLinesGrow(p, &buf, len, Ctx{ .h = h, .a = from, .al = from_len, .b2 = to, .bl = to_len });
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
    const h = getH(p, 1);
    const len = graph.stz_graph_bfs(h, id, id_len, &buf, buf.len);
    const Ctx = struct {
        h: ?*const graph.StzGraph,
        id: [*]const u8,
        id_len: usize,
        fn call(s: @This(), b: [*]u8, n: usize) usize {
            return graph.stz_graph_bfs(s.h, s.id, s.id_len, b, n);
        }
    };
    retLinesGrow(p, &buf, len, Ctx{ .h = h, .id = id, .id_len = id_len });
}

fn ring_DFS(p: *anyopaque) callconv(.c) void {
    const id = gs(p, 2);
    const id_len: usize = @intCast(gss(p, 2));
    var buf: [8192]u8 = undefined;
    const h = getH(p, 1);
    const len = graph.stz_graph_dfs(h, id, id_len, &buf, buf.len);
    const Ctx = struct {
        h: ?*const graph.StzGraph,
        id: [*]const u8,
        id_len: usize,
        fn call(s: @This(), b: [*]u8, n: usize) usize {
            return graph.stz_graph_dfs(s.h, s.id, s.id_len, b, n);
        }
    };
    retLinesGrow(p, &buf, len, Ctx{ .h = h, .id = id, .id_len = id_len });
}

fn ring_Dijkstra(p: *anyopaque) callconv(.c) void {
    const from = gs(p, 2);
    const from_len: usize = @intCast(gss(p, 2));
    const to = gs(p, 3);
    const to_len: usize = @intCast(gss(p, 3));
    var buf: [8192]u8 = undefined;
    const h = getH(p, 1);
    const len = graph.stz_graph_dijkstra(h, from, from_len, to, to_len, &buf, buf.len);
    const Ctx = struct {
        h: ?*const graph.StzGraph,
        a: [*]const u8, al: usize, b2: [*]const u8, bl: usize,
        fn call(s: @This(), b: [*]u8, n: usize) usize {
            return graph.stz_graph_dijkstra(s.h, s.a, s.al, s.b2, s.bl, b, n);
        }
    };
    retLinesGrow(p, &buf, len, Ctx{ .h = h, .a = from, .al = from_len, .b2 = to, .bl = to_len });
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
    // HONOUR THE RETURN VALUE. It was discarded, so a metric that REFUSED
    // -- impact above MAX_REACH_NODES, layering on a cycle -- came back as
    // n entries of whatever was in the freshly allocated buffer. The face's
    // careful refusal message ("refused above 20,000 nodes") was
    // unreachable: len(result) was never 0. An empty list is the refusal
    // signal every caller here already checks for.
    if (fnc(gr, vals.ptr, n) == 0) {
        R.ring_vm_api_retlist(p, outer);
        return;
    }
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

// The graph metrics a PICTURE binds to, read from the RESIDENT graph --
// no edge list marshalled, no id mapped in Ring.
fn ring_ImpactAll(p: *anyopaque) callconv(.c) void {
    retCentralityAll(p, &graph.stz_graph_impact_all);
}
// A MEASUREMENT INSTRUMENT: the same answer as ImpactAll by one BFS per
// node, so a guard can split "engine vs Ring" into the seam's share and the
// algorithm's share. Not a product path -- see graph.zig.
fn ring_ImpactAllNaive(p: *anyopaque) callconv(.c) void {
    retCentralityAll(p, &graph.stz_graph_impact_all_naive);
}

fn ring_LayersAll(p: *anyopaque) callconv(.c) void {
    retCentralityAll(p, &graph.stz_graph_layers_all);
}
fn ring_DegreeAll(p: *anyopaque) callconv(.c) void {
    retCentralityAll(p, &graph.stz_graph_degree_all);
}
fn ring_InDegreeAll(p: *anyopaque) callconv(.c) void {
    retCentralityAll(p, &graph.stz_graph_indegree_all);
}
fn ring_OutDegreeAll(p: *anyopaque) callconv(.c) void {
    retCentralityAll(p, &graph.stz_graph_outdegree_all);
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
    const h = getH(p, 1);
    const len = graph.stz_graph_astar(h, from, from_len, to, to_len, mode, &buf, buf.len);
    const Ctx = struct {
        h: ?*const graph.StzGraph,
        a: [*]const u8, al: usize, b2: [*]const u8, bl: usize, m: i32,
        fn call(s: @This(), b: [*]u8, n: usize) usize {
            return graph.stz_graph_astar(s.h, s.a, s.al, s.b2, s.bl, s.m, b, n);
        }
    };
    retLinesGrow(p, &buf, len, Ctx{ .h = h, .a = from, .al = from_len, .b2 = to, .bl = to_len, .m = mode });
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
fn ring_AStarWeighted(p: *anyopaque) callconv(.c) void {
    const from = gs(p, 2);
    const from_len: usize = @intCast(gss(p, 2));
    const to = gs(p, 3);
    const to_len: usize = @intCast(gss(p, 3));
    const mode: i32 = @intFromFloat(g(p, 4));
    var buf: [8192]u8 = undefined;
    const h = getH(p, 1);
    const len = graph.stz_graph_astar_weighted(h, from, from_len, to, to_len, mode, &buf, buf.len);
    const Ctx = struct {
        h: ?*const graph.StzGraph,
        a: [*]const u8, al: usize, b2: [*]const u8, bl: usize, m: i32,
        fn call(s: @This(), b: [*]u8, n: usize) usize {
            return graph.stz_graph_astar_weighted(s.h, s.a, s.al, s.b2, s.bl, s.m, b, n);
        }
    };
    retLinesGrow(p, &buf, len, Ctx{ .h = h, .a = from, .al = from_len, .b2 = to, .bl = to_len, .m = mode });
}

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

fn ring_SetEdgeCost(p: *anyopaque) callconv(.c) void {
    const from = gs(p, 2);
    const from_len: usize = @intCast(gss(p, 2));
    const to = gs(p, 3);
    const to_len: usize = @intCast(gss(p, 3));
    const c = g(p, 4);
    rn(p, @floatFromInt(graph.stz_graph_set_edge_cost(getMutH(p, 1), from, from_len, to, to_len, c)));
}

// Min-cost max-flow: returns a 2-element Ring list [ flow, cost ].
fn ring_MinCostMaxFlow(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const s = gs(p, 2);
    const sl: usize = @intCast(gss(p, 2));
    const t = gs(p, 3);
    const tl: usize = @intCast(gss(p, 3));
    var cost: f64 = 0;
    const flow = graph.stz_graph_min_cost_max_flow(getH(p, 1), s, sl, t, tl, &cost);
    R.ring_list_adddouble(out, flow);
    R.ring_list_adddouble(out, cost);
    R.ring_vm_api_retlist(p, out);
}

fn ring_NumberOfCommunities(p: *anyopaque) callconv(.c) void {
    const gr = getH(p, 1) orelse { rn(p, 0); return; };
    const n = graph.stz_graph_node_count(gr);
    if (n == 0) { rn(p, 0); return; }
    const labels = gpa.alloc(u32, n) catch { rn(p, 0); return; };
    defer gpa.free(labels);
    rn(p, @floatFromInt(graph.stz_graph_communities(gr, labels.ptr, n)));
}

// Communities as a Ring list of lists of node names (built Zig-side).
fn ring_Communities(p: *anyopaque) callconv(.c) void {
    const outer = R.ring_vm_api_newlist(p) orelse return;
    const gr = getH(p, 1) orelse { R.ring_vm_api_retlist(p, outer); return; };
    const n = graph.stz_graph_node_count(gr);
    if (n == 0) { R.ring_vm_api_retlist(p, outer); return; }
    const labels = gpa.alloc(u32, n) catch { R.ring_vm_api_retlist(p, outer); return; };
    defer gpa.free(labels);
    const k = graph.stz_graph_communities(gr, labels.ptr, n);
    var comp: u32 = 0;
    while (comp < k) : (comp += 1) {
        const sub = R.ring_list_newlist(outer) orelse continue;
        for (0..n) |i| {
            if (labels[i] == comp) addName(sub, gr, i);
        }
    }
    R.ring_vm_api_retlist(p, outer);
}

fn ring_MaxFlow(p: *anyopaque) callconv(.c) void {
    const s = gs(p, 2);
    const sl: usize = @intCast(gss(p, 2));
    const t = gs(p, 3);
    const tl: usize = @intCast(gss(p, 3));
    rn(p, graph.stz_graph_max_flow(getH(p, 1), s, sl, t, tl));
}

// Min cut as a ready list of [uName, vName] cut-edge pairs (Zig-side).
fn ring_MinCut(p: *anyopaque) callconv(.c) void {
    const outer = R.ring_vm_api_newlist(p) orelse return;
    const gr = getH(p, 1) orelse { R.ring_vm_api_retlist(p, outer); return; };
    const n = graph.stz_graph_node_count(gr);
    if (n == 0) { R.ring_vm_api_retlist(p, outer); return; }
    const s = gs(p, 2);
    const sl: usize = @intCast(gss(p, 2));
    const t = gs(p, 3);
    const tl: usize = @intCast(gss(p, 3));
    const eu = gpa.alloc(u32, n * n) catch { R.ring_vm_api_retlist(p, outer); return; };
    defer gpa.free(eu);
    const ev = gpa.alloc(u32, n * n) catch { R.ring_vm_api_retlist(p, outer); return; };
    defer gpa.free(ev);
    const c = graph.stz_graph_min_cut(gr, s, sl, t, tl, eu.ptr, ev.ptr, n * n);
    for (0..c) |i| {
        const sub = R.ring_list_newlist(outer) orelse continue;
        addName(sub, gr, eu[i]);
        addName(sub, gr, ev[i]);
    }
    R.ring_vm_api_retlist(p, outer);
}

fn ring_ClusteringAll(p: *anyopaque) callconv(.c) void {
    retCentralityAll(p, &graph.stz_graph_clustering);
}
fn ring_ClusteringOf(p: *anyopaque) callconv(.c) void {
    retCentralityOf(p, &graph.stz_graph_clustering);
}

fn ring_Diameter(p: *anyopaque) callconv(.c) void {
    rn(p, graph.stz_graph_diameter(getH(p, 1)));
}
fn ring_Radius(p: *anyopaque) callconv(.c) void {
    rn(p, graph.stz_graph_radius(getH(p, 1)));
}
fn ring_AveragePathLength(p: *anyopaque) callconv(.c) void {
    rn(p, graph.stz_graph_average_path_length(getH(p, 1)));
}
fn ring_EccentricitiesAll(p: *anyopaque) callconv(.c) void {
    retCentralityAll(p, &graph.stz_graph_eccentricities);
}
fn ring_EccentricityOf(p: *anyopaque) callconv(.c) void {
    retCentralityOf(p, &graph.stz_graph_eccentricities);
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

// The 16 KB stack buffer serves the common case with no allocation. When
// the reachable set does not fit, stz_graph_reachable answers the size it
// NEEDED (it does not truncate), and we ask again on the heap. Before this,
// a hub reaching 5,000 nodes came back with 2,916 of them and no signal.
fn ring_Reachable(p: *anyopaque) callconv(.c) void {
    const id = gs(p, 2);
    const id_len: usize = @intCast(gss(p, 2));
    const h = getH(p, 1);
    var buf: [16384]u8 = undefined;
    const len = graph.stz_graph_reachable(h, id, id_len, &buf, buf.len);
    if (len <= buf.len) {
        retLines(p, buf[0..len]);
        return;
    }
    const big = gpa.alloc(u8, len) catch {
        retLines(p, "");
        return;
    };
    defer gpa.free(big);
    const got = graph.stz_graph_reachable(h, id, id_len, big.ptr, big.len);
    retLines(p, big[0..@min(got, big.len)]);
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


// ---- GG1 layered layout ------------------------------------------------
//
// Lists in, lists out. The sweep and the crossing count were the whole cost
// of a 10,000-node layout in interpreted Ring; they are ordinary tight loops
// and belong here.

fn readU32List(p: *anyopaque, argn: c_int) ?[]u32 {
    const lst = R.gl(p, argn) orelse return null;
    const n: usize = @intCast(R.ringListSize(lst));
    if (n == 0) return null;
    const out = gpa.alloc(u32, n) catch return null;
    for (0..n) |i| {
        const item = R.ring_list_getitem_gc(null, lst, @intCast(i + 1)) orelse {
            out[i] = 0;
            continue;
        };
        const v = R.ring_item_getnumber(item);
        out[i] = if (v < 0) 0 else @intFromFloat(v);
    }
    return out;
}

fn readF64List(p: *anyopaque, argn: c_int) ?[]f64 {
    const lst = R.gl(p, argn) orelse return null;
    const n: usize = @intCast(R.ringListSize(lst));
    if (n == 0) return null;
    const out = gpa.alloc(f64, n) catch return null;
    for (0..n) |i| {
        const item = R.ring_list_getitem_gc(null, lst, @intCast(i + 1)) orelse {
            out[i] = 0;
            continue;
        };
        out[i] = R.ring_item_getnumber(item);
    }
    return out;
}

fn readF32List(p: *anyopaque, argn: c_int) ?[]f32 {
    const lst = R.gl(p, argn) orelse return null;
    const n: usize = @intCast(R.ringListSize(lst));
    if (n == 0) return null;
    const out = gpa.alloc(f32, n) catch return null;
    for (0..n) |i| {
        const item = R.ring_list_getitem_gc(null, lst, @intCast(i + 1)) orelse {
            out[i] = 0;
            continue;
        };
        out[i] = @floatCast(R.ring_item_getnumber(item));
    }
    return out;
}

// GraphLayoutForce(aOff, aSrc, aSeedXY, nIters, nK) -> flat [x,y,...]
fn ring_GraphLayoutForce(p: *anyopaque) callconv(.c) void {
    const off = readU32List(p, 1) orelse return;
    defer gpa.free(off);
    const src = readU32List(p, 2) orelse return;
    defer gpa.free(src);
    const seed = readF32List(p, 3) orelse return;
    defer gpa.free(seed);
    const iters: u32 = @intFromFloat(g(p, 4));
    const k: f32 = @floatCast(g(p, 5));

    _ = glayout.force(off, src, seed, iters, k);

    const out = R.ring_vm_api_newlist(p) orelse return;
    for (seed) |v| R.ring_list_adddouble(out, @floatCast(v));
    R.ring_vm_api_retlist(p, out);
}

// GraphLayoutSweep(aOff, aSrc, aLayer, aOrder, aStarts, nSweeps, aU, aV) -> aOrder
fn ring_LayoutSweep(p: *anyopaque) callconv(.c) void {
    const off = readU32List(p, 1) orelse return;
    defer gpa.free(off);
    const src = readU32List(p, 2) orelse return;
    defer gpa.free(src);
    const layer = readU32List(p, 3) orelse return;
    defer gpa.free(layer);
    const order = readU32List(p, 4) orelse return;
    defer gpa.free(order);
    const starts = readU32List(p, 5) orelse return;
    defer gpa.free(starts);
    const nsw: u32 = @intFromFloat(g(p, 6));
    const eu = readU32List(p, 7) orelse return;
    defer gpa.free(eu);
    const ev = readU32List(p, 8) orelse return;
    defer gpa.free(ev);

    _ = glayout.sweep(off, src, layer, order, starts, nsw, eu, ev);

    const out = R.ring_vm_api_newlist(p) orelse return;
    for (order) |v| R.ring_list_adddouble(out, @floatFromInt(v));
    R.ring_vm_api_retlist(p, out);
}

// GraphLayoutCoords(aInOff, aInSrc, aOutOff, aOutDst, aOrder, aStarts,
//                   nSep, nIters) -> aX (one x per node, node order)
fn ring_LayoutCoords(p: *anyopaque) callconv(.c) void {
    const in_off = readU32List(p, 1) orelse return;
    defer gpa.free(in_off);
    const in_src = readU32List(p, 2) orelse return;
    defer gpa.free(in_src);
    const out_off = readU32List(p, 3) orelse return;
    defer gpa.free(out_off);
    const out_dst = readU32List(p, 4) orelse return;
    defer gpa.free(out_dst);
    const order = readU32List(p, 5) orelse return;
    defer gpa.free(order);
    const starts = readU32List(p, 6) orelse return;
    defer gpa.free(starts);
    const sep = g(p, 7);
    const iters: u32 = @intFromFloat(g(p, 8));
    // OPTIONAL 9th: per-node extra half-width demand. Absent or the wrong
    // length means uniform separation, which is what every caller before
    // edge labels wanted and still gets.
    const extra_opt = readF64List(p, 9);
    defer if (extra_opt) |e| gpa.free(e);
    const extra: []const f64 = if (extra_opt) |e| e else &[_]f64{};

    const x = gpa.alloc(f64, order.len) catch return;
    defer gpa.free(x);
    @memset(x, 0);

    // A REFUSAL ANSWERS NOTHING, IT ANSWERS THE EVEN SPREAD. Bad arguments
    // here mean the caller built a malformed CSR, and the honest fallback is
    // the placement the face used before this function existed -- a worse
    // picture, never a blank one.
    if (glayout.coords(in_off, in_src, out_off, out_dst, order, starts, sep, iters, extra, x) != glayout.OK) {
        for (0..starts.len -| 1) |L| {
            if (starts[L + 1] > order.len or starts[L] > starts[L + 1]) break;
            var k: usize = 0;
            while (starts[L] + k < starts[L + 1]) : (k += 1) {
                if (order[starts[L] + k] < x.len)
                    x[order[starts[L] + k]] = @as(f64, @floatFromInt(k)) * sep;
            }
        }
    }

    const out = R.ring_vm_api_newlist(p) orelse return;
    for (x) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

// GraphLayoutCrossings(aU, aV, aLayer, aPos, aStarts) -> count
fn ring_LayoutCrossings(p: *anyopaque) callconv(.c) void {
    const eu = readU32List(p, 1) orelse {
        rn(p, -1);
        return;
    };
    defer gpa.free(eu);
    const ev = readU32List(p, 2) orelse {
        rn(p, -1);
        return;
    };
    defer gpa.free(ev);
    const layer = readU32List(p, 3) orelse {
        rn(p, -1);
        return;
    };
    defer gpa.free(layer);
    const pos = readU32List(p, 4) orelse {
        rn(p, -1);
        return;
    };
    defer gpa.free(pos);
    const starts = readU32List(p, 5) orelse {
        rn(p, -1);
        return;
    };
    defer gpa.free(starts);
    rn(p, glayout.crossings(eu, ev, layer, pos, starts));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginegraphlayoutcoords", .func = &ring_LayoutCoords },
    .{ .name = "stzenginegraphcreate", .func = &ring_Create },
    .{ .name = "stzenginegraphfree", .func = &ring_Free },
    .{ .name = "stzenginegraphaddnode", .func = &ring_AddNode },
    .{ .name = "stzenginegraphaddedge", .func = &ring_AddEdge },
    .{ .name = "stzenginegraphneighbors", .func = &ring_Neighbors },
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
    .{ .name = "stzenginegraphsetedgecost", .func = &ring_SetEdgeCost },
    .{ .name = "stzenginegraphmincostmaxflow", .func = &ring_MinCostMaxFlow },
    .{ .name = "stzenginegraphnumberofcommunities", .func = &ring_NumberOfCommunities },
    .{ .name = "stzenginegraphcommunities", .func = &ring_Communities },
    .{ .name = "stzenginegraphmaxflow", .func = &ring_MaxFlow },
    .{ .name = "stzenginegraphmincut", .func = &ring_MinCut },
    .{ .name = "stzenginegraphclusteringall", .func = &ring_ClusteringAll },
    .{ .name = "stzenginegraphclusteringof", .func = &ring_ClusteringOf },
    .{ .name = "stzenginegraphdiameter", .func = &ring_Diameter },
    .{ .name = "stzenginegraphradius", .func = &ring_Radius },
    .{ .name = "stzenginegraphaveragepathlength", .func = &ring_AveragePathLength },
    .{ .name = "stzenginegrapheccentricitiesall", .func = &ring_EccentricitiesAll },
    .{ .name = "stzenginegrapheccentricityof", .func = &ring_EccentricityOf },
    .{ .name = "stzenginegraphcorenumbersall", .func = &ring_CoreNumbersAll },
    .{ .name = "stzenginegraphcorenumberof", .func = &ring_CoreNumberOf },
    .{ .name = "stzenginegraphpagerankall", .func = &ring_PageRankAll },
    .{ .name = "stzenginegraphpagerankof", .func = &ring_PageRankOf },
    .{ .name = "stzenginegraphsetcoords", .func = &ring_SetCoords },
    .{ .name = "stzenginegraphastar", .func = &ring_AStar },
    .{ .name = "stzenginegraphastarweighted", .func = &ring_AStarWeighted },
    .{ .name = "stzenginegraphsetedgeweight", .func = &ring_SetEdgeWeight },
    .{ .name = "stzenginegraphastarplan", .func = &ring_AStarPlan },
    .{ .name = "stzenginegraphreachable", .func = &ring_Reachable },
    .{ .name = "stzenginegraphhascycle", .func = &ring_HasCycle },
    .{ .name = "stzenginegraphindegree", .func = &ring_InDegree },
    .{ .name = "stzenginegraphoutdegree", .func = &ring_OutDegree },
    .{ .name = "stzenginegraphtopologicalsort", .func = &ring_TopologicalSort },
    .{ .name = "stzenginegraphconnectedcomponents", .func = &ring_ConnectedComponents },
    .{ .name = "stzenginegraphimpactall", .func = &ring_ImpactAll },
    .{ .name = "stzenginegraphimpactallnaive", .func = &ring_ImpactAllNaive },
    .{ .name = "stzenginegraphlayersall", .func = &ring_LayersAll },
    .{ .name = "stzenginegraphdegreeall", .func = &ring_DegreeAll },
    .{ .name = "stzenginegraphindegreeall", .func = &ring_InDegreeAll },
    .{ .name = "stzenginegraphoutdegreeall", .func = &ring_OutDegreeAll },
    .{ .name = "stzenginegraphlayoutforce", .func = &ring_GraphLayoutForce },
    .{ .name = "stzenginegraphlayoutsweep", .func = &ring_LayoutSweep },
    .{ .name = "stzenginegraphlayoutcrossings", .func = &ring_LayoutCrossings },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
