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
    x: f64 = std.math.nan(f64), // optional coordinate for the A* heuristic
    y: f64 = std.math.nan(f64),
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
            .x = std.math.nan(f64),
            .y = std.math.nan(f64),
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

// ─── Strongly connected components (Kosaraju, directed) ───

// Fills labels[i] with the SCC id (0-based) of node i; returns the number
// of strongly connected components. Two nodes share an id iff each is
// reachable from the other.
pub fn stz_graph_strongly_connected_components(g: ?*const StzGraph, labels: [*]u32, labels_len: usize) callconv(.c) u32 {
    const gr = g orelse return 0;
    const n = gr.nodes.items.len;
    if (n == 0 or labels_len < n) return 0;

    const visited = allocator.alloc(bool, n) catch return 0;
    defer allocator.free(visited);
    @memset(visited, false);

    // 1. iterative post-order (finish order) over the forward graph
    const order = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(order);
    var oc: usize = 0;
    const st_node = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(st_node);
    const st_ci = allocator.alloc(usize, n) catch return 0;
    defer allocator.free(st_ci);
    for (0..n) |s| {
        if (visited[s]) continue;
        var sp: usize = 0;
        st_node[sp] = @intCast(s);
        st_ci[sp] = 0;
        sp += 1;
        visited[s] = true;
        while (sp > 0) {
            const u = st_node[sp - 1];
            const edges = gr.nodes.items[u].edges.items;
            if (st_ci[sp - 1] < edges.len) {
                const e = edges[st_ci[sp - 1]];
                st_ci[sp - 1] += 1;
                if (!visited[e.to]) {
                    visited[e.to] = true;
                    st_node[sp] = e.to;
                    st_ci[sp] = 0;
                    sp += 1;
                }
            } else {
                order[oc] = u;
                oc += 1;
                sp -= 1;
            }
        }
    }

    // 2. reverse adjacency (CSR): count, prefix, fill
    const rstart = allocator.alloc(usize, n + 1) catch return 0;
    defer allocator.free(rstart);
    @memset(rstart, 0);
    var total: usize = 0;
    for (gr.nodes.items) |node| {
        for (node.edges.items) |e| {
            rstart[e.to + 1] += 1;
            total += 1;
        }
    }
    for (0..n) |i| rstart[i + 1] += rstart[i];
    const radj = allocator.alloc(u32, total) catch return 0;
    defer allocator.free(radj);
    const fillpos = allocator.alloc(usize, n) catch return 0;
    defer allocator.free(fillpos);
    for (0..n) |i| fillpos[i] = rstart[i];
    for (gr.nodes.items, 0..) |node, u| {
        for (node.edges.items) |e| {
            radj[fillpos[e.to]] = @intCast(u);
            fillpos[e.to] += 1;
        }
    }

    // 3. assign components in reverse finish order, DFS on the transpose
    @memset(labels[0..n], std.math.maxInt(u32));
    var comp: u32 = 0;
    const stack = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(stack);
    var i = oc;
    while (i > 0) {
        i -= 1;
        const root = order[i];
        if (labels[root] != std.math.maxInt(u32)) continue;
        var sp: usize = 0;
        stack[sp] = root;
        sp += 1;
        labels[root] = comp;
        while (sp > 0) {
            sp -= 1;
            const u = stack[sp];
            var k = rstart[u];
            while (k < rstart[u + 1]) : (k += 1) {
                const v = radj[k];
                if (labels[v] == std.math.maxInt(u32)) {
                    labels[v] = comp;
                    stack[sp] = v;
                    sp += 1;
                }
            }
        }
        comp += 1;
    }
    return comp;
}

// ─── Minimum spanning tree weight (Kruskal, edges treated as undirected) ───

const KEdge = struct { u: u32, v: u32, w: f64 };

fn ufFind(parent: []u32, x: u32) u32 {
    var r = x;
    while (parent[r] != r) r = parent[r];
    var cur = x;
    while (parent[cur] != r) {
        const nxt = parent[cur];
        parent[cur] = r;
        cur = nxt;
    }
    return r;
}

// Total weight of a minimum spanning tree over the undirected version of the
// graph. Returns -1.0 if the graph is empty or not connected (no spanning
// tree). Uses the edge weights set via add_edge.
pub fn stz_graph_mst_weight(g: ?*const StzGraph) callconv(.c) f64 {
    const gr = g orelse return -1.0;
    const n = gr.nodes.items.len;
    if (n == 0) return -1.0;
    if (n == 1) return 0.0;

    // collect undirected edges once (u < v)
    var edges = std.ArrayListUnmanaged(KEdge){};
    defer edges.deinit(allocator);
    for (gr.nodes.items, 0..) |node, u| {
        for (node.edges.items) |e| {
            const uu: u32 = @intCast(u);
            if (uu < e.to) {
                edges.append(allocator, .{ .u = uu, .v = e.to, .w = e.weight }) catch return -1.0;
            } else if (e.to < uu and !gr.directed) {
                // undirected graphs store both directions; the u<v guard
                // already captured this edge from the other endpoint
            } else if (gr.directed and e.to < uu) {
                // directed edge v->u with no u->v: still include undirected
                edges.append(allocator, .{ .u = e.to, .v = uu, .w = e.weight }) catch return -1.0;
            }
        }
    }
    std.mem.sort(KEdge, edges.items, {}, struct {
        fn lt(_: void, a: KEdge, b: KEdge) bool {
            return a.w < b.w;
        }
    }.lt);

    const parent = allocator.alloc(u32, n) catch return -1.0;
    defer allocator.free(parent);
    for (0..n) |i| parent[i] = @intCast(i);

    var total: f64 = 0.0;
    var used: usize = 0;
    for (edges.items) |e| {
        const ru = ufFind(parent, e.u);
        const rv = ufFind(parent, e.v);
        if (ru != rv) {
            parent[ru] = rv;
            total += e.w;
            used += 1;
            if (used == n - 1) break;
        }
    }
    if (used != n - 1) return -1.0; // not connected
    return total;
}

// Fills the chosen MST edges into parallel arrays (node indices + weight);
// returns the edge count (n-1 if connected, else a partial forest). Same
// Kruskal selection as stz_graph_mst_weight.
pub fn stz_graph_mst_edges(g: ?*const StzGraph, out_u: [*]u32, out_v: [*]u32, out_w: [*]f64, cap: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const n = gr.nodes.items.len;
    if (n < 2) return 0;
    var edges = std.ArrayListUnmanaged(KEdge){};
    defer edges.deinit(allocator);
    for (gr.nodes.items, 0..) |node, u| {
        for (node.edges.items) |e| {
            const uu: u32 = @intCast(u);
            if (uu < e.to) {
                edges.append(allocator, .{ .u = uu, .v = e.to, .w = e.weight }) catch return 0;
            } else if (gr.directed and e.to < uu) {
                edges.append(allocator, .{ .u = e.to, .v = uu, .w = e.weight }) catch return 0;
            }
        }
    }
    std.mem.sort(KEdge, edges.items, {}, struct {
        fn lt(_: void, a: KEdge, b: KEdge) bool {
            return a.w < b.w;
        }
    }.lt);
    const parent = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(parent);
    for (0..n) |i| parent[i] = @intCast(i);
    var used: usize = 0;
    for (edges.items) |e| {
        const ru = ufFind(parent, e.u);
        const rv = ufFind(parent, e.v);
        if (ru != rv) {
            parent[ru] = rv;
            if (used < cap) {
                out_u[used] = e.u;
                out_v[used] = e.v;
                out_w[used] = e.w;
            }
            used += 1;
            if (used == n - 1) break;
        }
    }
    return used;
}

// ─── Undirected adjacency (CSR), deduped — for articulation pts / bridges / k-core ───

const Undirected = struct {
    start: []usize, // length n+1
    adj: []u32, // length 2*m
    fn deinit(self: *Undirected) void {
        allocator.free(self.start);
        allocator.free(self.adj);
    }
};

// Builds a deduped undirected adjacency: each distinct unordered pair {u,v}
// appears once in adj[u] and once in adj[v], regardless of whether the graph
// stored it directed or both-ways. Caller must deinit().
fn buildUndirected(gr: *const StzGraph) ?Undirected {
    const n = gr.nodes.items.len;
    // unique unordered pairs via a seen-set keyed by min*n+max
    var seen = std.AutoHashMapUnmanaged(u64, void){};
    defer seen.deinit(allocator);
    var pu = std.ArrayListUnmanaged(u32){};
    defer pu.deinit(allocator);
    var pv = std.ArrayListUnmanaged(u32){};
    defer pv.deinit(allocator);
    for (gr.nodes.items, 0..) |node, u| {
        for (node.edges.items) |e| {
            const a: u64 = @min(@as(u64, @intCast(u)), @as(u64, e.to));
            const b: u64 = @max(@as(u64, @intCast(u)), @as(u64, e.to));
            if (a == b) continue;
            const key = a * @as(u64, n) + b;
            if (seen.contains(key)) continue;
            seen.put(allocator, key, {}) catch return null;
            pu.append(allocator, @intCast(a)) catch return null;
            pv.append(allocator, @intCast(b)) catch return null;
        }
    }
    const start = allocator.alloc(usize, n + 1) catch return null;
    @memset(start, 0);
    for (pu.items, pv.items) |x, y| {
        start[x + 1] += 1;
        start[y + 1] += 1;
    }
    for (0..n) |i| start[i + 1] += start[i];
    const adj = allocator.alloc(u32, pu.items.len * 2) catch {
        allocator.free(start);
        return null;
    };
    const fillpos = allocator.alloc(usize, n) catch {
        allocator.free(start);
        allocator.free(adj);
        return null;
    };
    defer allocator.free(fillpos);
    for (0..n) |i| fillpos[i] = start[i];
    for (pu.items, pv.items) |x, y| {
        adj[fillpos[x]] = y;
        fillpos[x] += 1;
        adj[fillpos[y]] = x;
        fillpos[y] += 1;
    }
    return Undirected{ .start = start, .adj = adj };
}

// ─── Articulation points & bridges (Tarjan low-link, undirected) ───

const APCtx = struct {
    u: Undirected,
    disc: []u32,
    low: []u32,
    timer: u32,
    is_ap: []bool,
    // bridge output
    br_u: ?[*]u32,
    br_v: ?[*]u32,
    br_cap: usize,
    br_count: usize,
};

fn apDfs(ctx: *APCtx, node: u32, parent: i64) void {
    ctx.timer += 1;
    ctx.disc[node] = ctx.timer;
    ctx.low[node] = ctx.timer;
    var children: u32 = 0;
    var k = ctx.u.start[node];
    while (k < ctx.u.start[node + 1]) : (k += 1) {
        const v = ctx.u.adj[k];
        if (ctx.disc[v] == 0) {
            children += 1;
            apDfs(ctx, v, @intCast(node));
            if (ctx.low[v] < ctx.low[node]) ctx.low[node] = ctx.low[v];
            // articulation (non-root)
            if (parent != -1 and ctx.low[v] >= ctx.disc[node]) ctx.is_ap[node] = true;
            // bridge
            if (ctx.low[v] > ctx.disc[node]) {
                if (ctx.br_u) |bu| {
                    if (ctx.br_count < ctx.br_cap) {
                        bu[ctx.br_count] = node;
                        ctx.br_v.?[ctx.br_count] = v;
                    }
                }
                ctx.br_count += 1;
            }
        } else if (v != parent) {
            if (ctx.disc[v] < ctx.low[node]) ctx.low[node] = ctx.disc[v];
        }
    }
    if (parent == -1 and children > 1) ctx.is_ap[node] = true;
}

// Fills out[] with the node indices that are articulation points; returns count.
pub fn stz_graph_articulation_points(g: ?*const StzGraph, out: [*]u32, cap: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const n = gr.nodes.items.len;
    if (n == 0) return 0;
    var u = buildUndirected(gr) orelse return 0;
    defer u.deinit();
    const disc = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(disc);
    const low = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(low);
    const is_ap = allocator.alloc(bool, n) catch return 0;
    defer allocator.free(is_ap);
    @memset(disc, 0);
    @memset(is_ap, false);
    var ctx = APCtx{ .u = u, .disc = disc, .low = low, .timer = 0, .is_ap = is_ap, .br_u = null, .br_v = null, .br_cap = 0, .br_count = 0 };
    for (0..n) |s| {
        if (disc[s] == 0) apDfs(&ctx, @intCast(s), -1);
    }
    var count: usize = 0;
    for (0..n) |i| {
        if (is_ap[i]) {
            if (count < cap) out[count] = @intCast(i);
            count += 1;
        }
    }
    return count;
}

// Fills out_u/out_v with the bridge edges (node indices); returns count.
pub fn stz_graph_bridges(g: ?*const StzGraph, out_u: [*]u32, out_v: [*]u32, cap: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const n = gr.nodes.items.len;
    if (n == 0) return 0;
    var u = buildUndirected(gr) orelse return 0;
    defer u.deinit();
    const disc = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(disc);
    const low = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(low);
    const is_ap = allocator.alloc(bool, n) catch return 0;
    defer allocator.free(is_ap);
    @memset(disc, 0);
    @memset(is_ap, false);
    var ctx = APCtx{ .u = u, .disc = disc, .low = low, .timer = 0, .is_ap = is_ap, .br_u = out_u, .br_v = out_v, .br_cap = cap, .br_count = 0 };
    for (0..n) |s| {
        if (disc[s] == 0) apDfs(&ctx, @intCast(s), -1);
    }
    return ctx.br_count;
}

// ─── Centrality ───

// Closeness per node: reachable / sum(distances) over out-edge BFS (matches
// the historical stzGraph semantics). Fills out[]; returns n.
pub fn stz_graph_closeness(g: ?*const StzGraph, out: [*]f64, cap: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const n = gr.nodes.items.len;
    if (n == 0 or cap < n) return 0;
    const dist = allocator.alloc(i64, n) catch return 0;
    defer allocator.free(dist);
    const queue = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(queue);
    for (0..n) |s| {
        @memset(dist, -1);
        dist[s] = 0;
        var qh: usize = 0;
        var qt: usize = 0;
        queue[qt] = @intCast(s);
        qt += 1;
        var total: i64 = 0;
        var reachable: i64 = 0;
        while (qh < qt) {
            const w = queue[qh];
            qh += 1;
            for (gr.nodes.items[w].edges.items) |e| {
                if (dist[e.to] < 0) {
                    dist[e.to] = dist[w] + 1;
                    total += dist[e.to];
                    reachable += 1;
                    queue[qt] = e.to;
                    qt += 1;
                }
            }
        }
        out[s] = if (total > 0) @as(f64, @floatFromInt(reachable)) / @as(f64, @floatFromInt(total)) else 0.0;
    }
    return n;
}

// Betweenness centrality (Brandes, unweighted). Unnormalised; for undirected
// graphs the per-source accumulation is halved. Fills out[]; returns n.
pub fn stz_graph_betweenness(g: ?*const StzGraph, out: [*]f64, cap: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const n = gr.nodes.items.len;
    if (n == 0 or cap < n) return 0;
    for (0..n) |i| out[i] = 0.0;

    const sigma = allocator.alloc(f64, n) catch return 0;
    defer allocator.free(sigma);
    const dist = allocator.alloc(i64, n) catch return 0;
    defer allocator.free(dist);
    const delta = allocator.alloc(f64, n) catch return 0;
    defer allocator.free(delta);
    const order = allocator.alloc(u32, n) catch return 0; // BFS finish stack
    defer allocator.free(order);
    const queue = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(queue);
    const preds = allocator.alloc(std.ArrayListUnmanaged(u32), n) catch return 0;
    for (0..n) |i| preds[i] = .{};
    defer {
        for (0..n) |i| preds[i].deinit(allocator);
        allocator.free(preds);
    }

    for (0..n) |s| {
        for (0..n) |i| {
            sigma[i] = 0;
            dist[i] = -1;
            delta[i] = 0;
            preds[i].clearRetainingCapacity();
        }
        sigma[s] = 1;
        dist[s] = 0;
        var qh: usize = 0;
        var qt: usize = 0;
        var oc: usize = 0;
        queue[qt] = @intCast(s);
        qt += 1;
        while (qh < qt) {
            const w = queue[qh];
            qh += 1;
            order[oc] = w;
            oc += 1;
            for (gr.nodes.items[w].edges.items) |e| {
                if (dist[e.to] < 0) {
                    dist[e.to] = dist[w] + 1;
                    queue[qt] = e.to;
                    qt += 1;
                }
                if (dist[e.to] == dist[w] + 1) {
                    sigma[e.to] += sigma[w];
                    preds[e.to].append(allocator, w) catch return 0;
                }
            }
        }
        var i = oc;
        while (i > 0) {
            i -= 1;
            const w = order[i];
            for (preds[w].items) |pv| {
                delta[pv] += (sigma[pv] / sigma[w]) * (1.0 + delta[w]);
            }
            if (w != s) out[w] += delta[w];
        }
    }
    if (!gr.directed) {
        for (0..n) |i| out[i] /= 2.0;
    }
    return n;
}

// ─── Distance metrics (all-pairs BFS over out-edges) ───

const EccStats = struct { sum: f64, count: f64 };

// Fill ecc[v] = eccentricity of v (max BFS hop-distance to any node reachable
// from v; 0 if v reaches nothing) and accumulate sum/count over all reachable
// ordered pairs. Returns null on allocation failure.
fn eccAndStats(gr: *const StzGraph, ecc: []f64) ?EccStats {
    const n = gr.nodes.items.len;
    const dist = allocator.alloc(i64, n) catch return null;
    defer allocator.free(dist);
    const queue = allocator.alloc(u32, n) catch return null;
    defer allocator.free(queue);
    var sum: f64 = 0;
    var count: f64 = 0;
    for (0..n) |s| {
        @memset(dist, -1);
        dist[s] = 0;
        var qh: usize = 0;
        var qt: usize = 0;
        queue[qt] = @intCast(s);
        qt += 1;
        var maxd: i64 = 0;
        while (qh < qt) {
            const w = queue[qh];
            qh += 1;
            for (gr.nodes.items[w].edges.items) |e| {
                if (dist[e.to] < 0) {
                    dist[e.to] = dist[w] + 1;
                    if (dist[e.to] > maxd) maxd = dist[e.to];
                    sum += @floatFromInt(dist[e.to]);
                    count += 1;
                    queue[qt] = e.to;
                    qt += 1;
                }
            }
        }
        ecc[s] = @floatFromInt(maxd);
    }
    return EccStats{ .sum = sum, .count = count };
}

// Eccentricity per node. Fills out[]; returns n.
pub fn stz_graph_eccentricities(g: ?*const StzGraph, out: [*]f64, cap: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const n = gr.nodes.items.len;
    if (n == 0 or cap < n) return 0;
    _ = eccAndStats(gr, out[0..n]) orelse return 0;
    return n;
}

// Diameter = max eccentricity (longest shortest path over reachable pairs).
pub fn stz_graph_diameter(g: ?*const StzGraph) callconv(.c) f64 {
    const gr = g orelse return 0;
    const n = gr.nodes.items.len;
    if (n == 0) return 0;
    const ecc = allocator.alloc(f64, n) catch return 0;
    defer allocator.free(ecc);
    _ = eccAndStats(gr, ecc) orelse return 0;
    var mx: f64 = 0;
    for (ecc) |e| {
        if (e > mx) mx = e;
    }
    return mx;
}

// Radius = min eccentricity over nodes that reach something (ecc > 0); 0 if
// none do.
pub fn stz_graph_radius(g: ?*const StzGraph) callconv(.c) f64 {
    const gr = g orelse return 0;
    const n = gr.nodes.items.len;
    if (n == 0) return 0;
    const ecc = allocator.alloc(f64, n) catch return 0;
    defer allocator.free(ecc);
    _ = eccAndStats(gr, ecc) orelse return 0;
    var mn: f64 = -1;
    for (ecc) |e| {
        if (e > 0 and (mn < 0 or e < mn)) mn = e;
    }
    return if (mn < 0) 0 else mn;
}

// Average shortest-path length over all reachable ordered pairs; 0 if none.
pub fn stz_graph_average_path_length(g: ?*const StzGraph) callconv(.c) f64 {
    const gr = g orelse return 0;
    const n = gr.nodes.items.len;
    if (n == 0) return 0;
    const ecc = allocator.alloc(f64, n) catch return 0;
    defer allocator.free(ecc);
    const st = eccAndStats(gr, ecc) orelse return 0;
    if (st.count == 0) return 0;
    return st.sum / st.count;
}

// ─── k-core & PageRank ───

// Core number of every node (Batagelj-Zaversnik, O(V+E)) over the undirected
// view: out[v] = largest k such that v survives in the k-core. Fills out[];
// returns n.
pub fn stz_graph_core_numbers(g: ?*const StzGraph, out: [*]f64, cap: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const n = gr.nodes.items.len;
    if (n == 0 or cap < n) return 0;
    var u = buildUndirected(gr) orelse return 0;
    defer u.deinit();

    const deg = allocator.alloc(usize, n) catch return 0;
    defer allocator.free(deg);
    var md: usize = 0;
    for (0..n) |i| {
        deg[i] = u.start[i + 1] - u.start[i];
        if (deg[i] > md) md = deg[i];
    }
    const bin = allocator.alloc(usize, md + 1) catch return 0;
    defer allocator.free(bin);
    @memset(bin, 0);
    for (0..n) |i| bin[deg[i]] += 1;
    var acc: usize = 0;
    for (0..md + 1) |d| {
        const tmp = bin[d];
        bin[d] = acc;
        acc += tmp;
    }
    const vert = allocator.alloc(u32, n) catch return 0;
    defer allocator.free(vert);
    const pos = allocator.alloc(usize, n) catch return 0;
    defer allocator.free(pos);
    for (0..n) |i| {
        pos[i] = bin[deg[i]];
        vert[pos[i]] = @intCast(i);
        bin[deg[i]] += 1;
    }
    // restore bin to bucket starts
    var d = md;
    while (d >= 1) : (d -= 1) bin[d] = bin[d - 1];
    bin[0] = 0;
    // peel
    for (0..n) |ii| {
        const v = vert[ii];
        const s = u.start[v];
        const e = u.start[v + 1];
        for (s..e) |k| {
            const w = u.adj[k];
            if (deg[w] > deg[v]) {
                const dw = deg[w];
                const pw = pos[w];
                const pf = bin[dw];
                const fv = vert[pf];
                if (w != fv) {
                    pos[w] = pf;
                    vert[pw] = fv;
                    pos[fv] = pw;
                    vert[pf] = w;
                }
                bin[dw] += 1;
                deg[w] -= 1;
            }
        }
    }
    for (0..n) |i| out[i] = @floatFromInt(deg[i]);
    return n;
}

// PageRank via power iteration over directed out-edges. damping<=0 -> 0.85,
// iters<=0 -> 100. Dangling nodes redistribute their mass uniformly. Fills
// out[]; returns n.
pub fn stz_graph_pagerank(g: ?*const StzGraph, out: [*]f64, cap: usize, damping: f64, iters: i32) callconv(.c) usize {
    const gr = g orelse return 0;
    const n = gr.nodes.items.len;
    if (n == 0 or cap < n) return 0;
    const dmp: f64 = if (damping > 0 and damping < 1) damping else 0.85;
    const rounds: usize = if (iters > 0) @intCast(iters) else 100;
    const nf: f64 = @floatFromInt(n);

    const tmp = allocator.alloc(f64, n) catch return 0;
    defer allocator.free(tmp);
    const outdeg = allocator.alloc(f64, n) catch return 0;
    defer allocator.free(outdeg);
    for (0..n) |i| {
        out[i] = 1.0 / nf;
        outdeg[i] = @floatFromInt(gr.nodes.items[i].edges.items.len);
    }
    var r: usize = 0;
    while (r < rounds) : (r += 1) {
        var dangling: f64 = 0;
        for (0..n) |i| {
            tmp[i] = (1.0 - dmp) / nf;
            if (outdeg[i] == 0) dangling += out[i];
        }
        const dshare = dmp * dangling / nf;
        for (0..n) |i| tmp[i] += dshare;
        for (0..n) |uu| {
            if (outdeg[uu] == 0) continue;
            const share = dmp * out[uu] / outdeg[uu];
            for (gr.nodes.items[uu].edges.items) |edge| tmp[edge.to] += share;
        }
        for (0..n) |i| out[i] = tmp[i];
    }
    return n;
}

// Signature-compatible wrapper (default damping/iters) so the bridge can reuse
// the generic per-node centrality plumbing.
pub fn stz_graph_pagerank_default(g: ?*const StzGraph, out: [*]f64, cap: usize) callconv(.c) usize {
    return stz_graph_pagerank(g, out, cap, 0.85, 100);
}

// ─── A* (coordinate heuristic) ───

// Attach (x,y) coordinates to a node for the A* heuristic. Returns 1 on
// success, 0 if the node is unknown.
pub fn stz_graph_set_coords(g: ?*StzGraph, id_ptr: [*]const u8, id_len: usize, x: f64, y: f64) callconv(.c) i32 {
    const gr = g orelse return 0;
    const idx = gr.findNode(id_ptr[0..id_len]) orelse return 0;
    gr.nodes.items[idx].x = x;
    gr.nodes.items[idx].y = y;
    return 1;
}

// Heuristic between two nodes given a mode: 1=Euclidean, 2=Manhattan,
// anything else (or missing coords) => 0 (admissible; A* degrades to Dijkstra).
fn heuristic(gr: *const StzGraph, a: NodeId, b: NodeId, mode: i32) f64 {
    const na = gr.nodes.items[a];
    const nb = gr.nodes.items[b];
    if (std.math.isNan(na.x) or std.math.isNan(na.y) or std.math.isNan(nb.x) or std.math.isNan(nb.y)) return 0;
    const dx = na.x - nb.x;
    const dy = na.y - nb.y;
    return switch (mode) {
        1 => @sqrt(dx * dx + dy * dy),
        2 => @abs(dx) + @abs(dy),
        else => 0,
    };
}

// A* shortest path using edge weights + a coordinate heuristic (mode as in
// `heuristic`). Writes the node-name path '\n'-joined into buf; returns its
// byte length (0 if no path / unknown endpoints).
pub fn stz_graph_astar(g: ?*const StzGraph, from_ptr: [*]const u8, from_len: usize, to_ptr: [*]const u8, to_len: usize, mode: i32, buf: [*]u8, cap: usize) callconv(.c) usize {
    const gr = g orelse return 0;
    const n = gr.nodes.items.len;
    if (n == 0) return 0;
    const src = gr.findNode(from_ptr[0..from_len]) orelse return 0;
    const dst = gr.findNode(to_ptr[0..to_len]) orelse return 0;

    const gscore = allocator.alloc(f64, n) catch return 0;
    defer allocator.free(gscore);
    const fscore = allocator.alloc(f64, n) catch return 0;
    defer allocator.free(fscore);
    const came = allocator.alloc(i64, n) catch return 0;
    defer allocator.free(came);
    const open = allocator.alloc(bool, n) catch return 0;
    defer allocator.free(open);
    const closed = allocator.alloc(bool, n) catch return 0;
    defer allocator.free(closed);
    const inf = std.math.inf(f64);
    for (0..n) |i| {
        gscore[i] = inf;
        fscore[i] = inf;
        came[i] = -1;
        open[i] = false;
        closed[i] = false;
    }
    gscore[src] = 0;
    fscore[src] = heuristic(gr, src, dst, mode);
    open[src] = true;

    while (true) {
        // pick the open node with the lowest fscore (linear scan)
        var cur: i64 = -1;
        var best: f64 = inf;
        for (0..n) |i| {
            if (open[i] and fscore[i] < best) {
                best = fscore[i];
                cur = @intCast(i);
            }
        }
        if (cur < 0) return 0; // open set empty -> no path
        const c: NodeId = @intCast(cur);
        if (c == dst) break;
        open[c] = false;
        closed[c] = true;
        for (gr.nodes.items[c].edges.items) |e| {
            if (closed[e.to]) continue;
            const w = if (e.weight > 0) e.weight else 1.0;
            const tentative = gscore[c] + w;
            if (tentative < gscore[e.to]) {
                came[e.to] = @intCast(c);
                gscore[e.to] = tentative;
                fscore[e.to] = tentative + heuristic(gr, e.to, dst, mode);
                open[e.to] = true;
            }
        }
    }

    // reconstruct dst..src then emit forward
    var path = std.ArrayListUnmanaged(NodeId){};
    defer path.deinit(allocator);
    var w: i64 = @intCast(dst);
    while (w >= 0) : (w = came[@intCast(w)]) {
        path.append(allocator, @intCast(w)) catch return 0;
    }
    var pos: usize = 0;
    var k: usize = path.items.len;
    while (k > 0) {
        k -= 1;
        const id = gr.nodes.items[path.items[k]];
        if (pos != 0) {
            if (pos >= cap) break;
            buf[pos] = '\n';
            pos += 1;
        }
        const remaining = cap - pos;
        const take = @min(id.id_len, remaining);
        @memcpy(buf[pos .. pos + take], id.id_ptr[0..take]);
        pos += take;
    }
    return pos;
}

// Override the weight of the directed edge from->to (used by the planner to
// push per-optimisation transition costs before an engine A* search).
// Returns 1 on success, 0 if the edge/endpoints are unknown.
pub fn stz_graph_set_edge_weight(g: ?*StzGraph, from_ptr: [*]const u8, from_len: usize, to_ptr: [*]const u8, to_len: usize, w: f64) callconv(.c) i32 {
    const gr = g orelse return 0;
    const f = gr.findNode(from_ptr[0..from_len]) orelse return 0;
    const t = gr.findNode(to_ptr[0..to_len]) orelse return 0;
    for (gr.nodes.items[f].edges.items) |*e| {
        if (e.to == t) {
            e.weight = w;
            return 1;
        }
    }
    return 0;
}

// A* that also records the explored (closed) order -- used by stzGraphPlanner
// so its explainability metrics (nodes_explored / efficiency) stay honest
// while the search itself runs in the engine. Writes the path into path_buf
// ('\n'-joined, returned length) and the explored order into exp_buf
// ('\n'-joined, length via exp_len_ptr).
pub fn stz_graph_astar_full(g: ?*const StzGraph, from_ptr: [*]const u8, from_len: usize, to_ptr: [*]const u8, to_len: usize, mode: i32, path_buf: [*]u8, path_cap: usize, exp_buf: [*]u8, exp_cap: usize, exp_len_ptr: *usize) callconv(.c) usize {
    exp_len_ptr.* = 0;
    const gr = g orelse return 0;
    const n = gr.nodes.items.len;
    if (n == 0) return 0;
    const src = gr.findNode(from_ptr[0..from_len]) orelse return 0;
    const dst = gr.findNode(to_ptr[0..to_len]) orelse return 0;

    const gscore = allocator.alloc(f64, n) catch return 0;
    defer allocator.free(gscore);
    const fscore = allocator.alloc(f64, n) catch return 0;
    defer allocator.free(fscore);
    const came = allocator.alloc(i64, n) catch return 0;
    defer allocator.free(came);
    const open = allocator.alloc(bool, n) catch return 0;
    defer allocator.free(open);
    const closed = allocator.alloc(bool, n) catch return 0;
    defer allocator.free(closed);
    var explored = std.ArrayListUnmanaged(NodeId){};
    defer explored.deinit(allocator);
    const inf = std.math.inf(f64);
    for (0..n) |i| {
        gscore[i] = inf;
        fscore[i] = inf;
        came[i] = -1;
        open[i] = false;
        closed[i] = false;
    }
    gscore[src] = 0;
    fscore[src] = heuristic(gr, src, dst, mode);
    open[src] = true;

    var found = false;
    while (true) {
        var cur: i64 = -1;
        var best: f64 = inf;
        for (0..n) |i| {
            if (open[i] and fscore[i] < best) {
                best = fscore[i];
                cur = @intCast(i);
            }
        }
        if (cur < 0) break;
        const c: NodeId = @intCast(cur);
        open[c] = false;
        closed[c] = true;
        explored.append(allocator, c) catch return 0;
        if (c == dst) {
            found = true;
            break;
        }
        for (gr.nodes.items[c].edges.items) |e| {
            if (closed[e.to]) continue;
            const w = if (e.weight > 0) e.weight else 1.0;
            const tentative = gscore[c] + w;
            if (tentative < gscore[e.to]) {
                came[e.to] = @intCast(c);
                gscore[e.to] = tentative;
                fscore[e.to] = tentative + heuristic(gr, e.to, dst, mode);
                open[e.to] = true;
            }
        }
    }

    // emit explored order
    var epos: usize = 0;
    for (explored.items) |nid| {
        const id = gr.nodes.items[nid];
        if (epos != 0) {
            if (epos >= exp_cap) break;
            exp_buf[epos] = '\n';
            epos += 1;
        }
        const take = @min(id.id_len, exp_cap - epos);
        @memcpy(exp_buf[epos .. epos + take], id.id_ptr[0..take]);
        epos += take;
    }
    exp_len_ptr.* = epos;

    if (!found) return 0;

    // reconstruct path dst..src then emit forward
    var path = std.ArrayListUnmanaged(NodeId){};
    defer path.deinit(allocator);
    var w: i64 = @intCast(dst);
    while (w >= 0) : (w = came[@intCast(w)]) {
        path.append(allocator, @intCast(w)) catch return 0;
    }
    var pos: usize = 0;
    var k: usize = path.items.len;
    while (k > 0) {
        k -= 1;
        const id = gr.nodes.items[path.items[k]];
        if (pos != 0) {
            if (pos >= path_cap) break;
            path_buf[pos] = '\n';
            pos += 1;
        }
        const take = @min(id.id_len, path_cap - pos);
        @memcpy(path_buf[pos .. pos + take], id.id_ptr[0..take]);
        pos += take;
    }
    return pos;
}

// ─── Tests ───

test "graph A* full (path + explored order)" {
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 5.0);
    _ = stz_graph_add_edge(g, "B", 1, "D", 1, 5.0);
    _ = stz_graph_add_edge(g, "A", 1, "C", 1, 1.0);
    _ = stz_graph_add_edge(g, "C", 1, "D", 1, 20.0);
    // override C->D weight to prove set_edge_weight works
    try std.testing.expectEqual(@as(i32, 1), stz_graph_set_edge_weight(g, "C", 1, "D", 1, 99.0));
    var pbuf: [64]u8 = undefined;
    var ebuf: [64]u8 = undefined;
    var elen: usize = 0;
    const plen = stz_graph_astar_full(g, "A", 1, "D", 1, 0, &pbuf, 64, &ebuf, 64, &elen);
    try std.testing.expectEqualStrings("A\nB\nD", pbuf[0..plen]);
    try std.testing.expect(elen > 0); // explored some nodes
}

test "graph A* with euclidean heuristic" {
    // grid-ish: S->A->G (cheap) and S->B->G (expensive); coords steer it
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "S", 1, "A", 1, 1.0);
    _ = stz_graph_add_edge(g, "A", 1, "G", 1, 1.0);
    _ = stz_graph_add_edge(g, "S", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "B", 1, "G", 1, 5.0);
    _ = stz_graph_set_coords(g, "S", 1, 0, 0);
    _ = stz_graph_set_coords(g, "A", 1, 1, 0);
    _ = stz_graph_set_coords(g, "B", 1, 0, 1);
    _ = stz_graph_set_coords(g, "G", 1, 2, 0);
    var buf: [64]u8 = undefined;
    const len = stz_graph_astar(g, "S", 1, "G", 1, 1, &buf, 64);
    try std.testing.expectEqualStrings("S\nA\nG", buf[0..len]);
}

test "graph k-core core numbers" {
    // triangle A-B-C (each core 2) plus a pendant D off A (core 1)
    const g = stz_graph_create(0) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "B", 1, "C", 1, 1.0);
    _ = stz_graph_add_edge(g, "C", 1, "A", 1, 1.0);
    _ = stz_graph_add_edge(g, "A", 1, "D", 1, 1.0);
    var core: [4]f64 = undefined;
    _ = stz_graph_core_numbers(g, &core, 4);
    try std.testing.expectEqual(@as(f64, 2.0), core[0]); // A
    try std.testing.expectEqual(@as(f64, 2.0), core[1]); // B
    try std.testing.expectEqual(@as(f64, 2.0), core[2]); // C
    try std.testing.expectEqual(@as(f64, 1.0), core[3]); // D
}

test "graph pagerank sums to one" {
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "B", 1, "C", 1, 1.0);
    _ = stz_graph_add_edge(g, "C", 1, "A", 1, 1.0);
    var pr: [3]f64 = undefined;
    _ = stz_graph_pagerank(g, &pr, 3, 0.85, 100);
    // symmetric cycle => all equal ~1/3
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 3.0), pr[0], 1e-6);
    var sum: f64 = 0;
    for (pr) |x| sum += x;
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), sum, 1e-6);
}

test "graph distance metrics (diameter / radius / avg path)" {
    // directed path A->B->C->D->E
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "B", 1, "C", 1, 1.0);
    _ = stz_graph_add_edge(g, "C", 1, "D", 1, 1.0);
    _ = stz_graph_add_edge(g, "D", 1, "E", 1, 1.0);
    // A reaches E at distance 4 -> diameter 4; A's ecc 4, B's 3, ...
    try std.testing.expectEqual(@as(f64, 4.0), stz_graph_diameter(g));
    // smallest non-zero ecc is D (reaches only E, ecc 1)
    try std.testing.expectEqual(@as(f64, 1.0), stz_graph_radius(g));
    var ecc: [5]f64 = undefined;
    _ = stz_graph_eccentricities(g, &ecc, 5);
    try std.testing.expectEqual(@as(f64, 4.0), ecc[0]); // A
    try std.testing.expectEqual(@as(f64, 0.0), ecc[4]); // E reaches nothing
}

test "graph centrality (closeness + betweenness)" {
    // directed path A->B->C->D->E
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "B", 1, "C", 1, 1.0);
    _ = stz_graph_add_edge(g, "C", 1, "D", 1, 1.0);
    _ = stz_graph_add_edge(g, "D", 1, "E", 1, 1.0);
    var bc: [5]f64 = undefined;
    _ = stz_graph_betweenness(g, &bc, 5);
    // path betweenness: A=0,B=3,C=4,D=3,E=0
    try std.testing.expectEqual(@as(f64, 0.0), bc[0]);
    try std.testing.expectEqual(@as(f64, 3.0), bc[1]);
    try std.testing.expectEqual(@as(f64, 4.0), bc[2]);
    try std.testing.expectEqual(@as(f64, 3.0), bc[3]);
    var cc: [5]f64 = undefined;
    _ = stz_graph_closeness(g, &cc, 5);
    // A reaches B,C,D,E at 1,2,3,4 => 4/10 = 0.4
    try std.testing.expectApproxEqAbs(@as(f64, 0.4), cc[0], 1e-9);
}

test "graph mst edges" {
    const g = stz_graph_create(0) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "B", 1, "C", 1, 2.0);
    _ = stz_graph_add_edge(g, "C", 1, "D", 1, 3.0);
    _ = stz_graph_add_edge(g, "D", 1, "A", 1, 4.0);
    _ = stz_graph_add_edge(g, "A", 1, "C", 1, 5.0);
    var ou: [8]u32 = undefined;
    var ov: [8]u32 = undefined;
    var ow: [8]f64 = undefined;
    const m = stz_graph_mst_edges(g, &ou, &ov, &ow, 8);
    try std.testing.expectEqual(@as(usize, 3), m);
    var sum: f64 = 0;
    for (0..m) |i| sum += ow[i];
    try std.testing.expectEqual(@as(f64, 6.0), sum);
}

test "graph articulation points and bridges" {
    // A-B-C with B central, plus C-D-E triangle: B and C are articulation pts;
    // A-B and B-C are bridges (D-E-C triangle has none).
    const g = stz_graph_create(0) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "B", 1, "C", 1, 1.0);
    _ = stz_graph_add_edge(g, "C", 1, "D", 1, 1.0);
    _ = stz_graph_add_edge(g, "D", 1, "E", 1, 1.0);
    _ = stz_graph_add_edge(g, "E", 1, "C", 1, 1.0);
    var ap: [8]u32 = undefined;
    const nap = stz_graph_articulation_points(g, &ap, 8);
    try std.testing.expectEqual(@as(usize, 2), nap); // B and C
    var bu: [8]u32 = undefined;
    var bv: [8]u32 = undefined;
    const nbr = stz_graph_bridges(g, &bu, &bv, 8);
    try std.testing.expectEqual(@as(usize, 2), nbr); // A-B and B-C
}

test "graph strongly connected components" {
    const g = stz_graph_create(1) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    // SCC1 {A,B,C} cycle ; D separate ; C->D bridge
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "B", 1, "C", 1, 1.0);
    _ = stz_graph_add_edge(g, "C", 1, "A", 1, 1.0);
    _ = stz_graph_add_edge(g, "C", 1, "D", 1, 1.0);
    var labels: [4]u32 = undefined;
    const nc = stz_graph_strongly_connected_components(g, &labels, 4);
    try std.testing.expectEqual(@as(u32, 2), nc);
    // A,B,C share a label; D differs
    try std.testing.expect(labels[0] == labels[1] and labels[1] == labels[2]);
    try std.testing.expect(labels[3] != labels[0]);
}

test "graph mst weight" {
    const g = stz_graph_create(0) orelse return error.CreateFailed;
    defer stz_graph_free(g);
    // square with a diagonal: A-B 1, B-C 2, C-D 3, D-A 4, A-C 5
    _ = stz_graph_add_edge(g, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_edge(g, "B", 1, "C", 1, 2.0);
    _ = stz_graph_add_edge(g, "C", 1, "D", 1, 3.0);
    _ = stz_graph_add_edge(g, "D", 1, "A", 1, 4.0);
    _ = stz_graph_add_edge(g, "A", 1, "C", 1, 5.0);
    // MST = A-B(1)+B-C(2)+C-D(3) = 6
    try std.testing.expectEqual(@as(f64, 6.0), stz_graph_mst_weight(g));

    const g2 = stz_graph_create(0) orelse return error.CreateFailed;
    defer stz_graph_free(g2);
    _ = stz_graph_add_edge(g2, "A", 1, "B", 1, 1.0);
    _ = stz_graph_add_node(g2, "X", 1); // disconnected
    try std.testing.expectEqual(@as(f64, -1.0), stz_graph_mst_weight(g2));
}

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
