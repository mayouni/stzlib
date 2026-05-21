// Per-domain entry point for stz_list.dll
pub const list = @import("list.zig");
pub const ring_bridge = @import("ring_bridge_list.zig");

comptime {
    @export(&list.stz_list_new, .{ .name = "stz_list_new" });
    @export(&list.stz_list_free, .{ .name = "stz_list_free" });
    @export(&list.stz_list_len, .{ .name = "stz_list_len" });
    @export(&list.stz_list_append_int, .{ .name = "stz_list_append_int" });
    @export(&list.stz_list_append_float, .{ .name = "stz_list_append_float" });
    @export(&list.stz_list_append_string, .{ .name = "stz_list_append_string" });
    @export(&list.stz_list_append_value, .{ .name = "stz_list_append_value" });
    @export(&list.stz_list_insert, .{ .name = "stz_list_insert" });
    @export(&list.stz_list_remove, .{ .name = "stz_list_remove" });
    @export(&list.stz_list_get, .{ .name = "stz_list_get" });
    @export(&list.stz_list_get_int, .{ .name = "stz_list_get_int" });
    @export(&list.stz_list_get_float, .{ .name = "stz_list_get_float" });
    @export(&list.stz_list_get_string, .{ .name = "stz_list_get_string" });
    @export(&list.stz_list_find_cs, .{ .name = "stz_list_find_cs" });
    @export(&list.stz_list_find_string_cs, .{ .name = "stz_list_find_string_cs" });
    @export(&list.stz_list_contains_cs, .{ .name = "stz_list_contains_cs" });
    @export(&list.stz_list_find_all_cs, .{ .name = "stz_list_find_all_cs" });
    @export(&list.stz_list_count_cs, .{ .name = "stz_list_count_cs" });
    @export(&list.stz_list_sort_cs, .{ .name = "stz_list_sort_cs" });
    @export(&list.stz_list_sort, .{ .name = "stz_list_sort" });
    @export(&list.stz_list_sort_descending_cs, .{ .name = "stz_list_sort_descending_cs" });
    @export(&list.stz_list_sort_descending, .{ .name = "stz_list_sort_descending" });
    @export(&list.stz_list_reverse, .{ .name = "stz_list_reverse" });
    @export(&list.stz_list_unique_cs, .{ .name = "stz_list_unique_cs" });
    @export(&list.stz_list_remove_duplicates_cs, .{ .name = "stz_list_remove_duplicates_cs" });
    @export(&list.stz_list_clone, .{ .name = "stz_list_clone" });
    @export(&list.stz_list_slice, .{ .name = "stz_list_slice" });
    @export(&list.stz_list_clear, .{ .name = "stz_list_clear" });
    @export(&list.stz_list_from_null_delimited, .{ .name = "stz_list_from_null_delimited" });
    @export(&list.stz_list_to_null_delimited, .{ .name = "stz_list_to_null_delimited" });
    @export(&list.stz_list_set, .{ .name = "stz_list_set" });
    @export(&list.stz_list_flatten, .{ .name = "stz_list_flatten" });
    @export(&list.stz_list_item_type, .{ .name = "stz_list_item_type" });
    @export(&list.stz_list_is_all_strings, .{ .name = "stz_list_is_all_strings" });
    @export(&list.stz_list_is_all_numbers, .{ .name = "stz_list_is_all_numbers" });
    @export(&list.stz_list_equals_cs, .{ .name = "stz_list_equals_cs" });
    @export(&list.stz_list_map_expr, .{ .name = "stz_list_map_expr" });
    @export(&list.stz_list_filter_expr, .{ .name = "stz_list_filter_expr" });
    @export(&list.stz_list_reduce_expr, .{ .name = "stz_list_reduce_expr" });
    @export(&list.stz_list_find_w, .{ .name = "stz_list_find_w" });
    @export(&list.stz_list_find_all_w, .{ .name = "stz_list_find_all_w" });
    @export(&list.stz_list_count_w, .{ .name = "stz_list_count_w" });
    @export(&list.stz_list_sort_by_expr, .{ .name = "stz_list_sort_by_expr" });
    @export(&list.stz_list_classify_cs, .{ .name = "stz_list_classify_cs" });
    @export(&list.stz_list_frequencies_cs, .{ .name = "stz_list_frequencies_cs" });
    @export(&list.stz_list_intersection_cs, .{ .name = "stz_list_intersection_cs" });
    @export(&list.stz_list_union_cs, .{ .name = "stz_list_union_cs" });
    @export(&list.stz_list_difference_cs, .{ .name = "stz_list_difference_cs" });
    @export(&list.stz_list_is_subset_cs, .{ .name = "stz_list_is_subset_cs" });
    @export(&list.stz_list_find_duplicates_cs, .{ .name = "stz_list_find_duplicates_cs" });
    @export(&list.stz_list_find_non_duplicated_cs, .{ .name = "stz_list_find_non_duplicated_cs" });
    @export(&list.stz_list_all_unique_cs, .{ .name = "stz_list_all_unique_cs" });
    @export(&list.stz_list_get_sublist, .{ .name = "stz_list_get_sublist" });
    @export(&list.stz_list_zip, .{ .name = "stz_list_zip" });
    @export(&list.stz_list_interleave, .{ .name = "stz_list_interleave" });
    @export(&list.stz_list_partition, .{ .name = "stz_list_partition" });
    @export(&list.stz_list_rotate_left, .{ .name = "stz_list_rotate_left" });
    @export(&list.stz_list_rotate_right, .{ .name = "stz_list_rotate_right" });
    @export(&list.stz_list_chunked, .{ .name = "stz_list_chunked" });
    @export(&list.stz_list_paired, .{ .name = "stz_list_paired" });
    @export(&list.stz_list_deep_flatten, .{ .name = "stz_list_deep_flatten" });
    @export(&list.stz_list_flatten_to_depth, .{ .name = "stz_list_flatten_to_depth" });
    @export(&list.stz_list_sort_on, .{ .name = "stz_list_sort_on" });
    @export(&list.stz_string_find_chars_w, .{ .name = "stz_string_find_chars_w" });
    @export(&list.stz_string_map_chars, .{ .name = "stz_string_map_chars" });
    @export(&list.stz_string_count_chars_w, .{ .name = "stz_string_count_chars_w" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test { _ = list; }
