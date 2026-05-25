const std = @import("std");

// ─── Topology Engine ───
// Adjacency-based topology: 64 nodes, neighbor tracking, connectivity queries.

const MAX_NODES: usize = 64;
const MAX_NEIGHBORS: usize = 16;
const MAX_NAME: usize = 64;

const Node = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    neighbors: [MAX_NEIGHBORS]usize = undefined,
    neighbor_count: usize = 0,
    active: bool = false,
};

var nodes: [MAX_NODES]Node = [_]Node{.{}} ** MAX_NODES;
var node_count: usize = 0;

fn findByName(name: [*]const u8, len: usize) ?usize {
    for (0..MAX_NODES) |idx| {
        if (nodes[idx].active and nodes[idx].name_len == len) {
            if (std.mem.eql(u8, nodes[idx].name[0..len], name[0..len])) return idx;
        }
    }
    return null;
}

// ─── C ABI ───

pub export fn stz_topo_add_node(name: [*]const u8, name_len: usize) i32 {
    if (findByName(name, name_len) != null) return -2;
    for (0..MAX_NODES) |idx| {
        if (!nodes[idx].active) {
            const nl = @min(name_len, MAX_NAME);
            @memcpy(nodes[idx].name[0..nl], name[0..nl]);
            nodes[idx].name_len = nl;
            nodes[idx].neighbor_count = 0;
            nodes[idx].active = true;
            node_count += 1;
            return @intCast(idx);
        }
    }
    return -1;
}

pub export fn stz_topo_add_edge(name_a: [*]const u8, a_len: usize, name_b: [*]const u8, b_len: usize) i32 {
    const ia = findByName(name_a, a_len) orelse return 0;
    const ib = findByName(name_b, b_len) orelse return 0;
    if (nodes[ia].neighbor_count >= MAX_NEIGHBORS or nodes[ib].neighbor_count >= MAX_NEIGHBORS) return 0;
    for (0..nodes[ia].neighbor_count) |k| {
        if (nodes[ia].neighbors[k] == ib) return 1;
    }
    nodes[ia].neighbors[nodes[ia].neighbor_count] = ib;
    nodes[ia].neighbor_count += 1;
    nodes[ib].neighbors[nodes[ib].neighbor_count] = ia;
    nodes[ib].neighbor_count += 1;
    return 1;
}

pub export fn stz_topo_are_neighbors(name_a: [*]const u8, a_len: usize, name_b: [*]const u8, b_len: usize) i32 {
    const ia = findByName(name_a, a_len) orelse return 0;
    const ib = findByName(name_b, b_len) orelse return 0;
    for (0..nodes[ia].neighbor_count) |k| {
        if (nodes[ia].neighbors[k] == ib) return 1;
    }
    return 0;
}

pub export fn stz_topo_neighbor_count(name: [*]const u8, name_len: usize) i32 {
    const idx = findByName(name, name_len) orelse return 0;
    return @intCast(nodes[idx].neighbor_count);
}

pub export fn stz_topo_node_count() i32 {
    return @intCast(node_count);
}

pub export fn stz_topo_connected(name_a: [*]const u8, a_len: usize, name_b: [*]const u8, b_len: usize) i32 {
    const ia = findByName(name_a, a_len) orelse return 0;
    const ib = findByName(name_b, b_len) orelse return 0;
    var visited: [MAX_NODES]bool = [_]bool{false} ** MAX_NODES;
    var queue: [MAX_NODES]usize = undefined;
    var head: usize = 0;
    var tail: usize = 0;
    queue[tail] = ia;
    tail += 1;
    visited[ia] = true;
    while (head < tail) {
        const cur = queue[head];
        head += 1;
        if (cur == ib) return 1;
        for (0..nodes[cur].neighbor_count) |k| {
            const nb = nodes[cur].neighbors[k];
            if (!visited[nb]) {
                visited[nb] = true;
                queue[tail] = nb;
                tail += 1;
            }
        }
    }
    return 0;
}

pub export fn stz_topo_remove_node(name: [*]const u8, name_len: usize) void {
    const idx = findByName(name, name_len) orelse return;
    for (0..MAX_NODES) |other| {
        if (nodes[other].active and other != idx) {
            var write: usize = 0;
            for (0..nodes[other].neighbor_count) |k| {
                if (nodes[other].neighbors[k] != idx) {
                    nodes[other].neighbors[write] = nodes[other].neighbors[k];
                    write += 1;
                }
            }
            nodes[other].neighbor_count = write;
        }
    }
    nodes[idx].active = false;
    node_count -= 1;
}

pub export fn stz_topo_clear() void {
    for (0..MAX_NODES) |idx| nodes[idx].active = false;
    node_count = 0;
}

// ─── Tests ───

test "add nodes and edges" {
    stz_topo_clear();
    _ = stz_topo_add_node("A", 1);
    _ = stz_topo_add_node("B", 1);
    _ = stz_topo_add_edge("A", 1, "B", 1);
    try std.testing.expectEqual(@as(i32, 1), stz_topo_are_neighbors("A", 1, "B", 1));
    try std.testing.expectEqual(@as(i32, 1), stz_topo_neighbor_count("A", 1));
    stz_topo_clear();
}

test "connectivity via BFS" {
    stz_topo_clear();
    _ = stz_topo_add_node("A", 1);
    _ = stz_topo_add_node("B", 1);
    _ = stz_topo_add_node("C", 1);
    _ = stz_topo_add_node("D", 1);
    _ = stz_topo_add_edge("A", 1, "B", 1);
    _ = stz_topo_add_edge("B", 1, "C", 1);
    try std.testing.expectEqual(@as(i32, 1), stz_topo_connected("A", 1, "C", 1));
    try std.testing.expectEqual(@as(i32, 0), stz_topo_connected("A", 1, "D", 1));
    stz_topo_clear();
}

test "remove node cleans edges" {
    stz_topo_clear();
    _ = stz_topo_add_node("X", 1);
    _ = stz_topo_add_node("Y", 1);
    _ = stz_topo_add_edge("X", 1, "Y", 1);
    stz_topo_remove_node("X", 1);
    try std.testing.expectEqual(@as(i32, 0), stz_topo_neighbor_count("Y", 1));
    try std.testing.expectEqual(@as(i32, 1), stz_topo_node_count());
    stz_topo_clear();
}

test "duplicate node rejected" {
    stz_topo_clear();
    _ = stz_topo_add_node("N", 1);
    try std.testing.expectEqual(@as(i32, -2), stz_topo_add_node("N", 1));
    stz_topo_clear();
}
