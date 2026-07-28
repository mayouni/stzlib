pub const matrix = @import("matrix.zig");
pub const linalg = @import("linalg.zig");
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
    @export(&matrix.stz_matrix_solve, .{ .name = "stz_matrix_solve" });
    @export(&matrix.stz_matrix_least_squares, .{ .name = "stz_matrix_least_squares" });
    @export(&matrix.stz_matrix_eigenvalues, .{ .name = "stz_matrix_eigenvalues" });
    @export(&matrix.stz_matrix_eigenvectors, .{ .name = "stz_matrix_eigenvectors" });
    @export(&matrix.stz_matrix_condition_number, .{ .name = "stz_matrix_condition_number" });
    @export(&matrix.stz_matrix_rank, .{ .name = "stz_matrix_rank" });
    @export(&matrix.stz_matrix_singular_values, .{ .name = "stz_matrix_singular_values" });
    @export(&matrix.stz_matrix_rank_general, .{ .name = "stz_matrix_rank_general" });
    @export(&matrix.stz_matrix_condition_general, .{ .name = "stz_matrix_condition_general" });
    @export(&matrix.stz_matrix_pseudo_inverse, .{ .name = "stz_matrix_pseudo_inverse" });
    @export(&matrix.stz_matrix_low_rank, .{ .name = "stz_matrix_low_rank" });
    @export(&matrix.stz_matrix_matrix_power, .{ .name = "stz_matrix_matrix_power" });
    @export(&matrix.stz_matrix_cholesky_inverse, .{ .name = "stz_matrix_cholesky_inverse" });
    @export(&matrix.stz_matrix_qr_inverse, .{ .name = "stz_matrix_qr_inverse" });
    @export(&matrix.stz_matrix_lu_inverse, .{ .name = "stz_matrix_lu_inverse" });
    @export(&matrix.stz_matrix_schur_q, .{ .name = "stz_matrix_schur_q" });
    @export(&matrix.stz_matrix_sqrt_general, .{ .name = "stz_matrix_sqrt_general" });
    @export(&matrix.stz_matrix_exp, .{ .name = "stz_matrix_exp" });
    @export(&matrix.stz_matrix_log, .{ .name = "stz_matrix_log" });
    @export(&matrix.stz_matrix_power_general, .{ .name = "stz_matrix_power_general" });
    @export(&matrix.stz_matrix_schur_t, .{ .name = "stz_matrix_schur_t" });
    @export(&matrix.stz_matrix_schur_inverse, .{ .name = "stz_matrix_schur_inverse" });
    @export(&matrix.stz_matrix_cholesky_factor_inverse, .{ .name = "stz_matrix_cholesky_factor_inverse" });
    @export(&matrix.stz_matrix_eigen_reconstruct, .{ .name = "stz_matrix_eigen_reconstruct" });
    @export(&matrix.stz_matrix_min_norm_solve, .{ .name = "stz_matrix_min_norm_solve" });
    @export(&matrix.stz_matrix_cholesky, .{ .name = "stz_matrix_cholesky" });
    @export(&matrix.stz_matrix_is_positive_definite, .{ .name = "stz_matrix_is_positive_definite" });
    @export(&matrix.stz_matrix_inverse, .{ .name = "stz_matrix_inverse" });
    @export(&matrix.stz_matrix_power, .{ .name = "stz_matrix_power" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test {
    _ = matrix;
    _ = linalg;
}
