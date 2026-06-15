const std = @import("std");
const allocator = std.heap.c_allocator;

const NodeId = u32;
const EdgeList = std.ArrayListUnmanaged(Edge);
const NodeList = std.ArrayListUnmanaged(Node);

const Edge = struct {
    to: NodeId,
    weight: f64,
};

const Node = struct {
    id_ptr: [*]const u8,
    id_len: usize,
    edges: EdgeList,
};

pub const StzGraph = struct {
    nodes: NodeList,
    directed: bool,

    pub fn init(directed: bool) !*StzGraph {
        const self = try allocator.create(StzGraph);
        self.nodes = .{};
        self.directed = directed;
        return self;
    }

    pub fn deinit(self: *StzGraph) void {
        for (self.nodes.items) |*n| {
            allocator.free(n.id_ptr[0..n.id_len]);
            n.edges.deinit(allocator);
        }
        self.nodes.deinit(allocator);
        allocator.destroy(self);
    }

    fn findNode(self: *const StzGraph, id: []const u8) ?NodeId {
        for (self.nodes.items, 0..) |n, i| {
            if (n.id_len == id.len and std.mem.eql(u8, n.id_ptr[0..n.id_len], id))
                return @intCast(i);
        }
        return null;
    }

    fn addNodeInternal(self: *StzGraph, id: []const u8) !NodeId {
        if (self.findNode(id)) |existing| return existing;
        const dup = try allocator.alloc(u8, id.len);
        @memcpy(dup, id);
        try self.nodes.append(allocator, .{
            .id_ptr = dup.ptr,
            .id_len = id.len,
            .edges = .{},
        });
        return @intCast(self.nodes.items.len - 1);
    }

    fn hasEdge(self: *const StzGraph, from: NodeId, to: NodeId) bool {
        if (from >= self.nodes.items.len) return false;
        for (self.nodes.items[from].edges.items) |e| {
            if (e.to == to) return true;
        }
        return false;
    }
};

// ─── C ABI ───

pub fn stz_graph_create(directed: i32) callconv(.c) ?*StzGraph {
    return StzGraph.init(directed != 0) catch null;
}

pub fn stz_graph_free(g: ?*StzGraph) callconv(.c) void {
    if (g) |gr| gr.deinit();
}

pub fn stz_graph_add_node(g: ?*StzGraph, id_ptr: [*]const u8, id_len: usize) callconv(.c) i32 {
    const gr = g orelse return -1;
    const idx = gr.addNodeInternal(id_ptr[0..id_len]) catch return -1;
    return @intCast(idx);
}

pub fn stz_graph_node_count(g: ?*const StzGraph) callconv(.c) usize {
    const gr = g orelse return 0;
    return gr.nodes.items.len;
}

pub fn stz_graph_edge_count(g: ?*const StzGraph) callconv(.c) usize {
    const gr = g orelse return 0;
    var count: usize = 0;
    for (gr.nodes.items) |n| count += n.edges.items.len;
    if (!gr.directed) count /= 2;
    return count;
}

pub fn stz_graph_add_edge(g: ?*StzGraph, from_ptr: [*]const u8, from_len: usize, to_ptr: [*]const u8, to_len: usize, weight: f64) callconv(.c) i32 {
    const gr = g orelse return 0;
    const from_id = gr.addNodeInternal(from_ptr[0..from_len]) catch return 0;
    const to_id = gr.addNodeInternal(to_ptr[0..to_len]) catch return 0;
    if (gr.hasEdge(from_id, to_id)) return 1;
    gr.nodes.items[from_id].edges.append(allocator, .{ .to = to_id, .weight = weight }) catch return 0;
    if (!gr.directed) {
        gr.nodes.items[to_id].edges.append(allocator, .{ .to = from_id, .weight = weight }) catch return 0;
    }
    return 1;
}

pub fn stz_graph_has_edge(g: ?*const StzGraph, from_ptr: [*]const u8, from_len: usize, to_ptr: [*]const u8, to_len: usize) callconv(.c) i32 {
    const gr = g orelse return 0;
    const from_id = gr.findNode(from_ptr[0..from_len]) orelse return 0;
    const to_id = gr.findNode(to_ptr[0..to_len]) orelse return 0;
    return if (gr.hasEdge(from_id, to_id)) @as(i32, 1) else @as(i32, 0);
}

pub fn stz_graph_remove_edge(g: ?*StzGraph, from_ptr: [*]const u8, from_len: usize, to_ptr: [*]const u8, to_len: usize) callconv(.c) i32 {
    const gr = g orelse return 0;
    const from_id = gr.findNode(from_ptr[0..from_len]) orelse return 0;
    const to_id = gr.findNode(to_ptr[0..to_len]) orelse return 0;
    removeEdgeFromList(&gr.nodes.items[from_id].edges, to_id);
    if (!gr.directed) removeEdgeFromList(&gr.nodes.items[to_id].edges, from_id);
    return 1;
}

fn removeEdgeFromList(edges: *EdgeList, target: NodeId) void {
    var i: usize = 0;
    while (i < edges.items.len) {
        if (edges.items[i].to == target) {
            _ = edges.swapRemove(i);
        } else {
            i += 1;
        }
    }
}

pub fn stz_graph_neighbors(g: ?*const StzGraph, id_ptr: [*]const u8, id_len: usize, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const nid = gr.findNode(id_ptr[0..id_len]) orelse return 0;
    var pos: usize = 0;
    for (gr.nodes.items[nid].edges.items, 0..) |e, ei| {
        if (ei > 0 and pos < buf_len) {
            buf[pos] = '\n';
            pos += 1;
        }
        const name = gr.nodes.items[e.to].id_ptr[0..gr.nodes.items[e.to].id_len];
        const copy_len = @min(name.len, buf_len - pos);
        if (copy_len > 0) {
            @memcpy(buf[pos .. pos + copy_len], name[0..copy_len]);
            pos += copy_len;
        }
    }
    return pos;
}

pub fn stz_graph_neighbor_count(g: ?*const StzGraph, id_ptr: [*]const u8, id_len: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const nid = gr.findNode(id_ptr[0..id_len]) orelse return 0;
    return gr.nodes.items[nid].edges.items.len;
}

pub fn stz_graph_node_name(g: ?*const StzGraph, idx: usize, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    if (idx >= gr.nodes.items.len) return 0;
    const n = gr.nodes.items[idx];
    const copy_len = @min(n.id_len, buf_len);
    @memcpy(buf[0..copy_len], n.id_ptr[0..copy_len]);
    return copy_len;
}

// ─── BFS shortest path ───

pub fn stz_graph_shortest_path(g: ?*const StzGraph, from_ptr: [*]const u8, from_len: usize, to_ptr: [*]const u8, to_len: usize, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const from_id = gr.findNode(from_ptr[0..from_len]) orelse return 0;
    const to_id = gr.findNode(to_ptr[0..to_len]) orelse return 0;
    if (from_id == to_id) {
        const name = gr.nodes.items[from_id].id_ptr[0..gr.nodes.items[from_id].id_len];
        const cl = @min(name.len, buf_len);
        @memcpy(buf[0..cl], name[0..cl]);
        return cl;
    }
    const n = gr.nodes.items.len;
    const prev = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(prev);
    const visited = allocator.alloc(bool, n) catch return 0;
    defer allocator.free(visited);
    @memset(prev, std.math.maxInt(u32));
    @memset(visited, false);

    const queue = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(queue);
    var qhead: usize = 0;
    var qtail: usize = 0;
    queue[qtail] = from_id;
    qtail += 1;
    visited[from_id] = true;

    var found = false;
    while (qhead < qtail) {
        const cur = queue[qhead];
        qhead += 1;
        for (gr.nodes.items[cur].edges.items) |e| {
            if (!visited[e.to]) {
                visited[e.to] = true;
                prev[e.to] = cur;
                if (e.to == to_id) {
                    found = true;
                    break;
                }
                if (qtail < n) {
                    queue[qtail] = e.to;
                    qtail += 1;
                }
            }
        }
        if (found) break;
    }
    if (!found) return 0;

    // Reconstruct path
    var path_buf = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(path_buf);
    var plen: usize = 0;
    var cur: u32 = to_id;
    while (cur != std.math.maxInt(u32)) {
        path_buf[plen] = cur;
        plen += 1;
        if (cur == from_id) break;
        cur = prev[cur];
    }

    // Write reversed path as comma-separated node names
    var pos: usize = 0;
    var i = plen;
    while (i > 0) {
        i -= 1;
        if (pos > 0 and pos < buf_len) {
            buf[pos] = '\n';
            pos += 1;
        }
        const node = gr.nodes.items[path_buf[i]];
        const copy_len = @min(node.id_len, buf_len - pos);
        if (copy_len > 0) {
            @memcpy(buf[pos .. pos + copy_len], node.id_ptr[0..copy_len]);
            pos += copy_len;
        }
    }
    return pos;
}

pub fn stz_graph_path_exists(g: ?*const StzGraph, from_ptr: [*]const u8, from_len: usize, to_ptr: [*]const u8, to_len: usize) callconv(.c) i32 {
    const gr = g orelse return 0;
    const from_id = gr.findNode(from_ptr[0..from_len]) orelse return 0;
    const to_id = gr.findNode(to_ptr[0..to_len]) orelse return 0;
    if (from_id == to_id) return 1;
    return if (bfsReach(gr, from_id, to_id)) @as(i32, 1) else @as(i32, 0);
}

fn bfsReach(gr: *const StzGraph, from: NodeId, to: NodeId) bool {
    const n = gr.nodes.items.len;
    const visited = allocator.alloc(bool, n) catch return false;
    defer allocator.free(visited);
    @memset(visited, false);
    const queue = allocator.alloc(u32, n) catch return false;
    defer allocator.free(queue);
    var qh: usize = 0;
    var qt: usize = 0;
    queue[qt] = from;
    qt += 1;
    visited[from] = true;
    while (qh < qt) {
        const cur = queue[qh];
        qh += 1;
        for (gr.nodes.items[cur].edges.items) |e| {
            if (e.to == to) return true;
            if (!visited[e.to]) {
                visited[e.to] = true;
                if (qt < n) {
                    queue[qt] = e.to;
                    qt += 1;
                }
            }
        }
    }
    return false;
}

// ─── Reachable nodes from a given node ───

pub fn stz_graph_reachable(g: ?*const StzGraph, id_ptr: [*]const u8, id_len: usize, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const start = gr.findNode(id_ptr[0..id_len]) orelse return 0;
    const n = gr.nodes.items.len;
    const visited = allocator.alloc(bool, n) catch return 0;
    defer allocator.free(visited);
    @memset(visited, false);
    const stack = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(stack);
    var sp: usize = 0;
    stack[sp] = start;
    sp += 1;
    visited[start] = true;
    while (sp > 0) {
        sp -= 1;
        const cur = stack[sp];
        for (gr.nodes.items[cur].edges.items) |e| {
            if (!visited[e.to]) {
                visited[e.to] = true;
                stack[sp] = e.to;
                sp += 1;
            }
        }
    }
    var pos: usize = 0;
    for (0..n) |i| {
        if (visited[i] and i != start) {
            if (pos > 0 and pos < buf_len) {
                buf[pos] = '\n';
                pos += 1;
            }
            const node = gr.nodes.items[i];
            const cl = @min(node.id_len, buf_len - pos);
            if (cl > 0) {
                @memcpy(buf[pos .. pos + cl], node.id_ptr[0..cl]);
                pos += cl;
            }
        }
    }
    return pos;
}

// ─── Connected components (undirected) ───

pub fn stz_graph_connected_components(g: ?*const StzGraph, labels: [*]u32, labels_len: usize) callconv(.c) u32 {
    const gr = g orelse return 0;
    const n = gr.nodes.items.len;
    if (n == 0 or labels_len < n) return 0;
    @memset(labels[0..n], std.math.maxInt(u32));
    var component: u32 = 0;
    const stack = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(stack);
    for (0..n) |i| {
        if (labels[i] != std.math.maxInt(u32)) continue;
        var sp: usize = 0;
        stack[sp] = @intCast(i);
        sp += 1;
        labels[i] = component;
        while (sp > 0) {
            sp -= 1;
            const cur = stack[sp];
            for (gr.nodes.items[cur].edges.items) |e| {
                if (labels[e.to] == std.math.maxInt(u32)) {
                    labels[e.to] = component;
                    stack[sp] = e.to;
                    sp += 1;
                }
            }
        }
        component += 1;
    }
    return component;
}

// ─── Topological sort (directed, returns 0 if cycle detected) ───

pub fn stz_graph_topological_sort(g: ?*const StzGraph, result: [*]u32, result_len: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    if (!gr.directed) return 0;
    const n = gr.nodes.items.len;
    if (n == 0 or result_len < n) return 0;

    const in_degree = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(in_degree);
    @memset(in_degree, 0);
    for (gr.nodes.items) |node| {
        for (node.edges.items) |e| in_degree[e.to] += 1;
    }

    const queue = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(queue);
    var qh: usize = 0;
    var qt: usize = 0;
    for (0..n) |i| {
        if (in_degree[i] == 0) {
            queue[qt] = @intCast(i);
            qt += 1;
        }
    }

    var count: usize = 0;
    while (qh < qt) {
        const cur = queue[qh];
        qh += 1;
        result[count] = cur;
        count += 1;
        for (gr.nodes.items[cur].edges.items) |e| {
            in_degree[e.to] -= 1;
            if (in_degree[e.to] == 0) {
                queue[qt] = e.to;
                qt += 1;
            }
        }
    }

    return if (count == n) count else 0;
}

// ─── Cycle detection (directed) ───

pub fn stz_graph_has_cycle(g: ?*const StzGraph) callconv(.c) i32 {
    const gr = g orelse return 0;
    if (!gr.directed) return 0;
    const n = gr.nodes.items.len;
    if (n == 0) return 0;

    const WHITE: u8 = 0;
    const GRAY: u8 = 1;
    const BLACK: u8 = 2;

    const color = allocator.alloc(u8, n) catch return 0;
    defer allocator.free(color);
    @memset(color, WHITE);

    const stack_node = allocator.alloc(u32, n * 2) catch return 0;
    defer allocator.free(stack_node);
    const stack_ei = allocator.alloc(usize, n * 2) catch return 0;
    defer allocator.free(stack_ei);

    for (0..n) |start| {
        if (color[start] != WHITE) continue;
        var sp: usize = 0;
        stack_node[sp] = @intCast(start);
        stack_ei[sp] = 0;
        sp += 1;
        color[start] = GRAY;

        while (sp > 0) {
            const cur = stack_node[sp - 1];
            const ei = stack_ei[sp - 1];
            const edges = gr.nodes.items[cur].edges.items;
            if (ei < edges.len) {
                stack_ei[sp - 1] = ei + 1;
                const next = edges[ei].to;
                if (color[next] == GRAY) return 1;
                if (color[next] == WHITE) {
                    color[next] = GRAY;
                    stack_node[sp] = next;
                    stack_ei[sp] = 0;
                    sp += 1;
                }
            } else {
                color[cur] = BLACK;
                sp -= 1;
            }
        }
    }
    return 0;
}

// ─── In/Out degree ───

pub fn stz_graph_out_degree(g: ?*const StzGraph, id_ptr: [*]const u8, id_len: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const nid = gr.findNode(id_ptr[0..id_len]) orelse return 0;
    return gr.nodes.items[nid].edges.items.len;
}

pub fn stz_graph_in_degree(g: ?*const StzGraph, id_ptr: [*]const u8, id_len: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const nid = gr.findNode(id_ptr[0..id_len]) orelse return 0;
    var count: usize = 0;
    for (gr.nodes.items) |node| {
        for (node.edges.items) |e| {
            if (e.to == nid) count += 1;
        }
    }
    return count;
}

// ─── BFS / DFS traversal order ───

// Writes node ids[0..count] as a newline-separated name list into buf.
fn writeNames(gr: *const StzGraph, ids: []const u32, count: usize, buf: [*]u8, buf_len: usize) usize {
    var pos: usize = 0;
    var i: usize = 0;
    while (i < count) : (i += 1) {
        if (i > 0 and pos < buf_len) {
            buf[pos] = '\n';
            pos += 1;
        }
        const node = gr.nodes.items[ids[i]];
        const cl = @min(node.id_len, buf_len - pos);
        if (cl > 0) {
            @memcpy(buf[pos .. pos + cl], node.id_ptr[0..cl]);
            pos += cl;
        }
    }
    return pos;
}

// Breadth-first visit order starting at the given node (newline-separated).
pub fn stz_graph_bfs(g: ?*const StzGraph, id_ptr: [*]const u8, id_len: usize, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const start = gr.findNode(id_ptr[0..id_len]) orelse return 0;
    const n = gr.nodes.items.len;
    const visited = allocator.alloc(bool, n) catch return 0;
    defer allocator.free(visited);
    @memset(visited, false);
    const order = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(order);
    const queue = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(queue);
    var qh: usize = 0;
    var qt: usize = 0;
    var oc: usize = 0;
    queue[qt] = start;
    qt += 1;
    visited[start] = true;
    while (qh < qt) {
        const cur = queue[qh];
        qh += 1;
        order[oc] = cur;
        oc += 1;
        for (gr.nodes.items[cur].edges.items) |e| {
            if (!visited[e.to]) {
                visited[e.to] = true;
                if (qt < n) {
                    queue[qt] = e.to;
                    qt += 1;
                }
            }
        }
    }
    return writeNames(gr, order, oc, buf, buf_len);
}

// Depth-first visit order starting at the given node (newline-separated).
pub fn stz_graph_dfs(g: ?*const StzGraph, id_ptr: [*]const u8, id_len: usize, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const start = gr.findNode(id_ptr[0..id_len]) orelse return 0;
    const n = gr.nodes.items.len;
    const visited = allocator.alloc(bool, n) catch return 0;
    defer allocator.free(visited);
    @memset(visited, false);
    const order = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(order);
    const stack = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(stack);
    var sp: usize = 0;
    var oc: usize = 0;
    stack[sp] = start;
    sp += 1;
    while (sp > 0) {
        sp -= 1;
        const cur = stack[sp];
        if (visited[cur]) continue;
        visited[cur] = true;
        order[oc] = cur;
        oc += 1;
        // push neighbours in reverse so the first edge is explored first
        const edges = gr.nodes.items[cur].edges.items;
        var k: usize = edges.len;
        while (k > 0) {
            k -= 1;
            if (!visited[edges[k].to] and sp < n) {
                stack[sp] = edges[k].to;
                sp += 1;
            }
        }
    }
    return writeNames(gr, order, oc, buf, buf_len);
}

// ─── Weighted shortest path (Dijkstra, non-negative weights) ───

fn dijkstra(gr: *const StzGraph, from: NodeId, dist: []f64, prev: []u32) void {
    const n = gr.nodes.items.len;
    const visited = allocator.alloc(bool, n) catch return;
    defer allocator.free(visited);
    @memset(visited, false);
    @memset(prev, std.math.maxInt(u32));
    for (dist) |*d| d.* = std.math.inf(f64);
    dist[from] = 0;
    var done: usize = 0;
    while (done < n) : (done += 1) {
        var u: ?usize = null;
        var best: f64 = std.math.inf(f64);
        for (0..n) |i| {
            if (!visited[i] and dist[i] < best) {
                best = dist[i];
                u = i;
            }
        }
        const cur = u orelse break;
        visited[cur] = true;
        for (gr.nodes.items[cur].edges.items) |e| {
            const nd = dist[cur] + e.weight;
            if (nd < dist[e.to]) {
                dist[e.to] = nd;
                prev[e.to] = @intCast(cur);
            }
        }
    }
}

// Minimum-weight path from->to as newline-separated node names ("" if none).
pub fn stz_graph_dijkstra(g: ?*const StzGraph, from_ptr: [*]const u8, from_len: usize, to_ptr: [*]const u8, to_len: usize, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const from_id = gr.findNode(from_ptr[0..from_len]) orelse return 0;
    const to_id = gr.findNode(to_ptr[0..to_len]) orelse return 0;
    const n = gr.nodes.items.len;
    const dist = allocator.alloc(f64, n) catch return 0;
    defer allocator.free(dist);
    const prev = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(prev);
    dijkstra(gr, from_id, dist, prev);
    if (from_id != to_id and prev[to_id] == std.math.maxInt(u32)) return 0;
    const path = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(path);
    var plen: usize = 0;
    var cur: u32 = to_id;
    while (true) {
        path[plen] = cur;
        plen += 1;
        if (cur == from_id) break;
        cur = prev[cur];
        if (plen >= n) break;
    }
    // reverse into order array
    const order = allocator.alloc(u32, plen) catch return 0;
    defer allocator.free(order);
    var i: usize = 0;
    while (i < plen) : (i += 1) order[i] = path[plen - 1 - i];
    return writeNames(gr, order, plen, buf, buf_len);
}

// Total minimum weight from->to (-1.0 if unreachable, 0.0 if from==to).
pub fn stz_graph_dijkstra_distance(g: ?*const StzGraph, from_ptr: [*]const u8, from_len: usize, to_ptr: [*]const u8, to_len: usize) callconv(.c) f64 {
    const gr = g orelse return -1.0;
    const from_id = gr.findNode(from_ptr[0..from_len]) orelse return -1.0;
    const to_id = gr.findNode(to_ptr[0..to_len]) orelse return -1.0;
    const n = gr.nodes.items.len;
    const dist = allocator.alloc(f64, n) catch return -1.0;
    defer allocator.free(dist);
    const prev = allocator.alloc(u32, n) catch return -1.0;
    defer allocator.free(prev);
    dijkstra(gr, from_id, dist, prev);
    if (std.math.isInf(dist[to_id])) return -1.0;
    return dist[to_id];
}

// 2-colourability: 1 if the graph is bipartite, 0 otherwise. Treats edges
// as undirected for colouring purposes.
pub fn stz_graph_is_bipartite(g: ?*const StzGraph) callconv(.c) i32 {
    const gr = g orelse return 0;
    const n = gr.nodes.items.len;
    if (n == 0) return 1;
    const color = allocator.alloc(i8, n) catch return 0;
    defer allocator.free(color);
    @memset(color, -1);
    const queue = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(queue);
    // incoming adjacency (so colouring respects undirected reachability even
    // in a directed graph)
    for (0..n) |s| {
        if (color[s] != -1) continue;
        color[s] = 0;
        var qh: usize = 0;
        var qt: usize = 0;
        queue[qt] = @intCast(s);
        qt += 1;
        while (qh < qt) {
            const cur = queue[qh];
            qh += 1;
            // out-edges
            for (gr.nodes.items[cur].edges.items) |e| {
                if (color[e.to] == -1) {
                    color[e.to] = 1 - color[cur];
                    if (qt < n) {
                        queue[qt] = e.to;
                        qt += 1;
                    }
                } else if (color[e.to] == color[cur]) {
                    return 0;
                }
            }
            // in-edges (undirected colouring)
            for (gr.nodes.items, 0..) |node, ni| {
                for (node.edges.items) |e| {
                    if (e.to == cur) {
                        const v: u32 = @intCast(ni);
                        if (color[v] == -1) {
                            color[v] = 1 - color[cur];
                            if (qt < n) {
                                queue[qt] = v;
                                qt += 1;
                            }
                        } else if (color[v] == color[cur]) {
                            return 0;
                        }
                    }
                }
            }
        }
    }
    return 1;
}

// ─── Tests ───

test "graph bfs/dfs order" {
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "A", 1, "C", 1, 1.0);
    _ = stz_graph_add_edge(g, "B", 1, "D", 1, 1.0);
    var buf: [64]u8 = undefined;
    const bl = stz_graph_bfs(g, "A", 1, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..bl], "A\nB\nC\nD"));
    const dl = stz_graph_dfs(g, "A", 1, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..dl], "A\nB\nD\nC"));
}

test "graph dijkstra weighted" {
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    // A-B-D = 5+5 = 10 ; A-C-D = 1+20 = 21 -> Dijkstra picks A,B,D
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 5.0);
    _ = stz_graph_add_edge(g, "B", 1, "D", 1, 5.0);
    _ = stz_graph_add_edge(g, "A", 1, "C", 1, 1.0);
    _ = stz_graph_add_edge(g, "C", 1, "D", 1, 20.0);
    var buf: [64]u8 = undefined;
    const len = stz_graph_dijkstra(g, "A", 1, "D", 1, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..len], "A\nB\nD"));
    try std.testing.expectEqual(@as(f64, 10.0), stz_graph_dijkstra_distance(g, "A", 1, "D", 1));
    try std.testing.expectEqual(@as(f64, -1.0), stz_graph_dijkstra_distance(g, "D", 1, "A", 1));
}

test "graph is bipartite" {
    const g1 = stz_graph_create(0) orelse return error.CreateFailed;
    defer stz_graph_free(g1);
    _ = stz_graph_add_edge(g1, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g1, "B", 1, "C", 1, 1.0);
    try std.testing.expectEqual(@as(i32, 1), stz_graph_is_bipartite(g1)); // path = bipartite

    const g2 = stz_graph_create(0) orelse return error.CreateFailed;
    defer stz_graph_free(g2);
    _ = stz_graph_add_edge(g2, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g2, "B", 1, "C", 1, 1.0);
    _ = stz_graph_add_edge(g2, "C", 1, "A", 1, 1.0);
    try std.testing.expectEqual(@as(i32, 0), stz_graph_is_bipartite(g2)); // triangle = odd cycle
}

test "graph create and basic ops" {
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);

    _ = stz_graph_add_node(g, "A", 1);
    _ = stz_graph_add_node(g, "B", 1);
    _ = stz_graph_add_node(g, "C", 1);
    try std.testing.expectEqual(@as(usize, 3), stz_graph_node_count(g));

    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "B", 1, "C", 1, 1.0);
    try std.testing.expectEqual(@as(usize, 2), stz_graph_edge_count(g));
    try std.testing.expectEqual(@as(i32, 1), stz_graph_has_edge(g, "A", 1, "B", 1));
    try std.testing.expectEqual(@as(i32, 0), stz_graph_has_edge(g, "C", 1, "A", 1));
}

test "graph neighbors" {
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "A", 1, "C", 1, 1.0);
    try std.testing.expectEqual(@as(usize, 2), stz_graph_neighbor_count(g, "A", 1));
    var buf: [64]u8 = undefined;
    const len = stz_graph_neighbors(g, "A", 1, &buf, 64);
    try std.testing.expect(len > 0);
}

test "graph shortest path" {
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "B", 1, "C", 1, 1.0);
    _ = stz_graph_add_edge(g, "A", 1, "D", 1, 1.0);
    _ = stz_graph_add_edge(g, "D", 1, "C", 1, 1.0);
    var buf: [64]u8 = undefined;
    const len = stz_graph_shortest_path(g, "A", 1, "C", 1, &buf, 64);
    try std.testing.expect(len > 0);
    const path = buf[0..len];
    try std.testing.expect(std.mem.eql(u8, path, "A\nB\nC") or std.mem.eql(u8, path, "A\nD\nC"));
}

test "graph path exists" {
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "B", 1, "C", 1, 1.0);
    _ = stz_graph_add_node(g, "D", 1);
    try std.testing.expectEqual(@as(i32, 1), stz_graph_path_exists(g, "A", 1, "C", 1));
    try std.testing.expectEqual(@as(i32, 0), stz_graph_path_exists(g, "A", 1, "D", 1));
}

test "graph reachable" {
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "B", 1, "C", 1, 1.0);
    var buf: [64]u8 = undefined;
    const len = stz_graph_reachable(g, "A", 1, &buf, 64);
    try std.testing.expect(len > 0);
}

test "graph connected components" {
    const g = stz_graph_create(0) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_node(g, "C", 1);
    var labels: [3]u32 = undefined;
    const nc = stz_graph_connected_components(g, &labels, 3);
    try std.testing.expectEqual(@as(u32, 2), nc);
}

test "graph topological sort" {
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "B", 1, "C", 1, 1.0);
    _ = stz_graph_add_edge(g, "A", 1, "C", 1, 1.0);
    var result: [3]u32 = undefined;
    const n = stz_graph_topological_sort(g, &result, 3);
    try std.testing.expectEqual(@as(usize, 3), n);
    try std.testing.expectEqual(@as(u32, 0), result[0]);
}

test "graph cycle detection" {
    const g1 = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g1);
    _ = stz_graph_add_edge(g1, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g1, "B", 1, "C", 1, 1.0);
    try std.testing.expectEqual(@as(i32, 0), stz_graph_has_cycle(g1));

    const g2 = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g2);
    _ = stz_graph_add_edge(g2, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g2, "B", 1, "C", 1, 1.0);
    _ = stz_graph_add_edge(g2, "C", 1, "A", 1, 1.0);
    try std.testing.expectEqual(@as(i32, 1), stz_graph_has_cycle(g2));
}

test "graph in/out degree" {
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "A", 1, "C", 1, 1.0);
    _ = stz_graph_add_edge(g, "B", 1, "C", 1, 1.0);
    try std.testing.expectEqual(@as(usize, 2), stz_graph_out_degree(g, "A", 1));
    try std.testing.expectEqual(@as(usize, 0), stz_graph_in_degree(g, "A", 1));
    try std.testing.expectEqual(@as(usize, 2), stz_graph_in_degree(g, "C", 1));
}

test "graph remove edge" {
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    try std.testing.expectEqual(@as(i32, 1), stz_graph_has_edge(g, "A", 1, "B", 1));
    _ = stz_graph_remove_edge(g, "A", 1, "B", 1);
    try std.testing.expectEqual(@as(i32, 0), stz_graph_has_edge(g, "A", 1, "B", 1));
}

test "graph undirected" {
    const g = stz_graph_create(0) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    try std.testing.expectEqual(@as(i32, 1), stz_graph_has_edge(g, "A", 1, "B", 1));
    try std.testing.expectEqual(@as(i32, 1), stz_graph_has_edge(g, "B", 1, "A", 1));
    try std.testing.expectEqual(@as(usize, 1), stz_graph_edge_count(g));
}

test "graph null handles" {
    stz_graph_free(null);
    try std.testing.expectEqual(@as(usize, 0), stz_graph_node_count(null));
    try std.testing.expectEqual(@as(usize, 0), stz_graph_edge_count(null));
    try std.testing.expectEqual(@as(i32, 0), stz_graph_has_cycle(null));
}

test "graph node name" {
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_node(g, "Alice", 5);
    var buf: [64]u8 = undefined;
    const len = stz_graph_node_name(g, 0, &buf, 64);
    try std.testing.expectEqual(@as(usize, 5), len);
    try std.testing.expect(std.mem.eql(u8, buf[0..len], "Alice"));
}
