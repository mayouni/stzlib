// Per-domain entry point for stz_json.dll
pub const json = @import("json.zig");

comptime {
    @export(&json.stz_json_parse, .{ .name = "stz_json_parse" });
    @export(&json.stz_json_free, .{ .name = "stz_json_free" });
    @export(&json.stz_json_is_valid, .{ .name = "stz_json_is_valid" });
    @export(&json.stz_json_is_array, .{ .name = "stz_json_is_array" });
    @export(&json.stz_json_size, .{ .name = "stz_json_size" });
    @export(&json.stz_json_has_key, .{ .name = "stz_json_has_key" });
    @export(&json.stz_json_get_string, .{ .name = "stz_json_get_string" });
    @export(&json.stz_json_get_int, .{ .name = "stz_json_get_int" });
    @export(&json.stz_json_get_bool, .{ .name = "stz_json_get_bool" });
    @export(&json.stz_json_array_at_string, .{ .name = "stz_json_array_at_string" });
    @export(&json.stz_json_array_at_int, .{ .name = "stz_json_array_at_int" });
    @export(&json.stz_json_to_string, .{ .name = "stz_json_to_string" });
    @export(&json.stz_json_to_string_pretty, .{ .name = "stz_json_to_string_pretty" });
    @export(&json.stz_json_string_free, .{ .name = "stz_json_string_free" });
    @export(&json.stz_json_keys, .{ .name = "stz_json_keys" });
    @export(&json.stz_json_error, .{ .name = "stz_json_error" });
}

test { _ = json; }
