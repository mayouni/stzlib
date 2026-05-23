pub const matrix = @import("matrix.zig");
pub const ring_bridge = @import("ring_bridge_matrix.zig");

comptime {
    @export(&matrix.stz_matrix_new, .{ .name = "stz_matrix_new" });
    @export(&matrix.stz_matrix_free, .{ .name = "stz_matrix_free" });
    @export(&matrix.stz_matrix_rows, .{ .name = "stz_matrix_rows" });
    @export(&matrix.stz_matrix_cols, .{ .name = "stz_matrix_cols" });
    @export(&matrix.stz_matrix_set, .{ .name = "stz_matrix_set" });
    @export(&matrix.stz_matrix_get, .{ .name = "stz_matrix_get" });
    @export(&matrix.stz_matrix_sum, .{ .name = "stz_matrix_sum" });
    @export(&matrix.stz_matrix_min, .{ .name = "stz_matrix_min" });
    @export(&matrix.stz_matrix_max, .{ .name = "stz_matrix_max" });
    @export(&matrix.stz_matrix_mean, .{ .name = "stz_matrix_mean" });
    @export(&matrix.stz_matrix_add_scalar, .{ .name = "stz_matrix_add_scalar" });
    @export(&matrix.stz_matrix_multiply_scalar, .{ .name = "stz_matrix_multiply_scalar" });
    @export(&matrix.stz_matrix_add_matrix, .{ .name = "stz_matrix_add_matrix" });
    @export(&matrix.stz_matrix_multiply, .{ .name = "stz_matrix_multiply" });
    @export(&matrix.stz_matrix_transpose, .{ .name = "stz_matrix_transpose" });
    @export(&matrix.stz_matrix_determinant, .{ .name = "stz_matrix_determinant" });
    @export(&matrix.stz_matrix_inverse, .{ .name = "stz_matrix_inverse" });
    @export(&matrix.stz_matrix_power, .{ .name = "stz_matrix_power" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test { _ = matrix; }
