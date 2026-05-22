// Per-domain entry point for stz_table.dll
pub const table = @import("table.zig");
pub const pivot = @import("pivot.zig");
pub const ring_bridge = @import("ring_bridge_table.zig");

comptime {
    @export(&table.stz_table_new, .{ .name = "stz_table_new" });
    @export(&table.stz_table_free, .{ .name = "stz_table_free" });
    @export(&table.stz_table_num_cols, .{ .name = "stz_table_num_cols" });
    @export(&table.stz_table_num_rows, .{ .name = "stz_table_num_rows" });
    @export(&table.stz_table_add_col, .{ .name = "stz_table_add_col" });
    @export(&table.stz_table_remove_col, .{ .name = "stz_table_remove_col" });
    @export(&table.stz_table_find_col, .{ .name = "stz_table_find_col" });
    @export(&table.stz_table_col_name, .{ .name = "stz_table_col_name" });
    @export(&table.stz_table_col_name_len, .{ .name = "stz_table_col_name_len" });
    @export(&table.stz_table_rename_col, .{ .name = "stz_table_rename_col" });
    @export(&table.stz_table_add_row, .{ .name = "stz_table_add_row" });
    @export(&table.stz_table_remove_row, .{ .name = "stz_table_remove_row" });
    @export(&table.stz_table_set_cell_int, .{ .name = "stz_table_set_cell_int" });
    @export(&table.stz_table_set_cell_float, .{ .name = "stz_table_set_cell_float" });
    @export(&table.stz_table_set_cell_string, .{ .name = "stz_table_set_cell_string" });
    @export(&table.stz_table_get_cell_int, .{ .name = "stz_table_get_cell_int" });
    @export(&table.stz_table_get_cell_float, .{ .name = "stz_table_get_cell_float" });
    @export(&table.stz_table_get_cell_string, .{ .name = "stz_table_get_cell_string" });
    @export(&table.stz_table_get_cell_string_len, .{ .name = "stz_table_get_cell_string_len" });
    @export(&table.stz_table_get_cell_type, .{ .name = "stz_table_get_cell_type" });
    @export(&table.stz_table_sort_on, .{ .name = "stz_table_sort_on" });
    @export(&table.stz_table_swap_rows, .{ .name = "stz_table_swap_rows" });
    @export(&table.stz_table_reverse_rows, .{ .name = "stz_table_reverse_rows" });
    @export(&table.stz_table_sum_col, .{ .name = "stz_table_sum_col" });
    @export(&table.stz_table_sum_col_range, .{ .name = "stz_table_sum_col_range" });
    @export(&table.stz_table_avg_col, .{ .name = "stz_table_avg_col" });
    @export(&table.stz_table_min_col, .{ .name = "stz_table_min_col" });
    @export(&table.stz_table_max_col, .{ .name = "stz_table_max_col" });
    @export(&table.stz_table_product_col, .{ .name = "stz_table_product_col" });
    @export(&table.stz_table_count_non_null, .{ .name = "stz_table_count_non_null" });
    @export(&table.stz_table_count_in_col, .{ .name = "stz_table_count_in_col" });
    @export(&table.stz_table_contains_in_col, .{ .name = "stz_table_contains_in_col" });
    @export(&table.stz_table_fill_int, .{ .name = "stz_table_fill_int" });
    @export(&table.stz_table_fill_float, .{ .name = "stz_table_fill_float" });
    @export(&table.stz_table_clone, .{ .name = "stz_table_clone" });
    @export(&table.stz_table_sub_table, .{ .name = "stz_table_sub_table" });
    @export(&table.stz_table_group_by, .{ .name = "stz_table_group_by" });
    @export(&table.stz_table_filter_rows, .{ .name = "stz_table_filter_rows" });
    @export(&table.stz_table_find_cell_cs, .{ .name = "stz_table_find_cell_cs" });
    @export(&table.stz_table_find_in_col_cs, .{ .name = "stz_table_find_in_col_cs" });

    // ─── Pivot operations ───
    @export(&pivot.stz_pivot_multi_group_by, .{ .name = "stz_pivot_multi_group_by" });
    @export(&pivot.stz_pivot_cross_tab, .{ .name = "stz_pivot_cross_tab" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test {
    _ = table;
    _ = pivot;
}
