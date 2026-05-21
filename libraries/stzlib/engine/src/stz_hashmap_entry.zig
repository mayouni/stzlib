// Per-domain entry point for stz_hashmap.dll
pub const hashmap = @import("hashmap.zig");
pub const ring_bridge = @import("ring_bridge_hashmap.zig");

comptime {
    @export(&hashmap.stz_hashmap_new, .{ .name = "stz_hashmap_new" });
    @export(&hashmap.stz_hashmap_free, .{ .name = "stz_hashmap_free" });
    @export(&hashmap.stz_hashmap_len, .{ .name = "stz_hashmap_len" });
    @export(&hashmap.stz_hashmap_put, .{ .name = "stz_hashmap_put" });
    @export(&hashmap.stz_hashmap_put_int, .{ .name = "stz_hashmap_put_int" });
    @export(&hashmap.stz_hashmap_put_float, .{ .name = "stz_hashmap_put_float" });
    @export(&hashmap.stz_hashmap_put_string, .{ .name = "stz_hashmap_put_string" });
    @export(&hashmap.stz_hashmap_get, .{ .name = "stz_hashmap_get" });
    @export(&hashmap.stz_hashmap_get_cs, .{ .name = "stz_hashmap_get_cs" });
    @export(&hashmap.stz_hashmap_get_int, .{ .name = "stz_hashmap_get_int" });
    @export(&hashmap.stz_hashmap_get_float, .{ .name = "stz_hashmap_get_float" });
    @export(&hashmap.stz_hashmap_get_string, .{ .name = "stz_hashmap_get_string" });
    @export(&hashmap.stz_hashmap_has_key, .{ .name = "stz_hashmap_has_key" });
    @export(&hashmap.stz_hashmap_has_key_cs, .{ .name = "stz_hashmap_has_key_cs" });
    @export(&hashmap.stz_hashmap_remove, .{ .name = "stz_hashmap_remove" });
    @export(&hashmap.stz_hashmap_key_at, .{ .name = "stz_hashmap_key_at" });
    @export(&hashmap.stz_hashmap_key_len_at, .{ .name = "stz_hashmap_key_len_at" });
    @export(&hashmap.stz_hashmap_value_at, .{ .name = "stz_hashmap_value_at" });
    @export(&hashmap.stz_hashmap_clear, .{ .name = "stz_hashmap_clear" });
    @export(&hashmap.stz_hashmap_clone, .{ .name = "stz_hashmap_clone" });
    @export(&hashmap.stz_hashmap_keys, .{ .name = "stz_hashmap_keys" });
    @export(&hashmap.stz_hashmap_merge, .{ .name = "stz_hashmap_merge" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test { _ = hashmap; }
