pub const random = @import("random.zig");
pub const ring_bridge = @import("ring_bridge_random.zig");

comptime {
    @export(&random.stz_random_seed, .{ .name = "stz_random_seed" });
    @export(&random.stz_random_int, .{ .name = "stz_random_int" });
    @export(&random.stz_random_float, .{ .name = "stz_random_float" });
    @export(&random.stz_random_n_in_range, .{ .name = "stz_random_n_in_range" });
    @export(&random.stz_random_n_unique_in_range, .{ .name = "stz_random_n_unique_in_range" });
    @export(&random.stz_random_shuffle, .{ .name = "stz_random_shuffle" });
    @export(&random.stz_random_bool, .{ .name = "stz_random_bool" });
    @export(&random.stz_random_weighted, .{ .name = "stz_random_weighted" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test { _ = random; }
