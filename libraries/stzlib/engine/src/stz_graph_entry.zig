pub const graph = @import("graph.zig");
pub const ring_bridge = @import("ring_bridge_graph.zig");

comptime {
    @export(&graph.stz_graph_create, .{ .name = "stz_graph_create" });
    @export(&graph.stz_graph_free, .{ .name = "stz_graph_free" });
    @export(&graph.stz_graph_add_node, .{ .name = "stz_graph_add_node" });
    @export(&graph.stz_graph_node_count, .{ .name = "stz_graph_node_count" });
    @export(&graph.stz_graph_edge_count, .{ .name = "stz_graph_edge_count" });
    @export(&graph.stz_graph_add_edge, .{ .name = "stz_graph_add_edge" });
    @export(&graph.stz_graph_has_edge, .{ .name = "stz_graph_has_edge" });
    @export(&graph.stz_graph_remove_edge, .{ .name = "stz_graph_remove_edge" });
    @export(&graph.stz_graph_neighbors, .{ .name = "stz_graph_neighbors" });
    @export(&graph.stz_graph_neighbor_count, .{ .name = "stz_graph_neighbor_count" });
    @export(&graph.stz_graph_node_name, .{ .name = "stz_graph_node_name" });
    @export(&graph.stz_graph_shortest_path, .{ .name = "stz_graph_shortest_path" });
    @export(&graph.stz_graph_path_exists, .{ .name = "stz_graph_path_exists" });
    @export(&graph.stz_graph_reachable, .{ .name = "stz_graph_reachable" });
    @export(&graph.stz_graph_connected_components, .{ .name = "stz_graph_connected_components" });
    @export(&graph.stz_graph_topological_sort, .{ .name = "stz_graph_topological_sort" });
    @export(&graph.stz_graph_has_cycle, .{ .name = "stz_graph_has_cycle" });
    @export(&graph.stz_graph_in_degree, .{ .name = "stz_graph_in_degree" });
    @export(&graph.stz_graph_out_degree, .{ .name = "stz_graph_out_degree" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test { _ = graph; }
