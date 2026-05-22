// Per-domain entry point for stz_value.dll
pub const value = @import("value.zig");
pub const ring_bridge = @import("ring_bridge_value.zig");

comptime {
    @export(&value.stz_value_new_null, .{ .name = "stz_value_new_null" });
    @export(&value.stz_value_new_bool, .{ .name = "stz_value_new_bool" });
    @export(&value.stz_value_new_int, .{ .name = "stz_value_new_int" });
    @export(&value.stz_value_new_float, .{ .name = "stz_value_new_float" });
    @export(&value.stz_value_new_string, .{ .name = "stz_value_new_string" });
    @export(&value.stz_value_new_list, .{ .name = "stz_value_new_list" });
    @export(&value.stz_value_free, .{ .name = "stz_value_free" });
    @export(&value.stz_value_type, .{ .name = "stz_value_type" });
    @export(&value.stz_value_is_null, .{ .name = "stz_value_is_null" });
    @export(&value.stz_value_get_bool, .{ .name = "stz_value_get_bool" });
    @export(&value.stz_value_get_int, .{ .name = "stz_value_get_int" });
    @export(&value.stz_value_get_float, .{ .name = "stz_value_get_float" });
    @export(&value.stz_value_get_string, .{ .name = "stz_value_get_string" });
    @export(&value.stz_value_get_string_len, .{ .name = "stz_value_get_string_len" });
    @export(&value.stz_value_list_len, .{ .name = "stz_value_list_len" });
    @export(&value.stz_value_list_get, .{ .name = "stz_value_list_get" });
    @export(&value.stz_value_list_append, .{ .name = "stz_value_list_append" });
    @export(&value.stz_value_list_set, .{ .name = "stz_value_list_set" });
    @export(&value.stz_value_list_remove, .{ .name = "stz_value_list_remove" });
    @export(&value.stz_value_list_insert, .{ .name = "stz_value_list_insert" });
    @export(&value.stz_value_equals, .{ .name = "stz_value_equals" });
    @export(&value.stz_value_equals_cs, .{ .name = "stz_value_equals_cs" });
    @export(&value.stz_value_compare, .{ .name = "stz_value_compare" });
    @export(&value.stz_value_clone, .{ .name = "stz_value_clone" });
    @export(&value.stz_value_to_string, .{ .name = "stz_value_to_string" });
    @export(&value.stz_value_type_name, .{ .name = "stz_value_type_name" });
    @export(&value.stz_value_type_name_len, .{ .name = "stz_value_type_name_len" });
    @export(&value.stz_value_list_find, .{ .name = "stz_value_list_find" });
    @export(&value.stz_value_list_contains, .{ .name = "stz_value_list_contains" });
    @export(&value.stz_value_list_reverse, .{ .name = "stz_value_list_reverse" });
    @export(&value.stz_value_list_sort, .{ .name = "stz_value_list_sort" });
    @export(&value.stz_value_list_clear, .{ .name = "stz_value_list_clear" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test { _ = value; }
