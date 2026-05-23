pub const stats = @import("stats.zig");
pub const ring_bridge = @import("ring_bridge_stats.zig");

comptime {
    @export(&stats.stz_stats_create, .{ .name = "stz_stats_create" });
    @export(&stats.stz_stats_free, .{ .name = "stz_stats_free" });
    @export(&stats.stz_stats_count, .{ .name = "stz_stats_count" });
    @export(&stats.stz_stats_mean, .{ .name = "stz_stats_mean" });
    @export(&stats.stz_stats_sum, .{ .name = "stz_stats_sum" });
    @export(&stats.stz_stats_min, .{ .name = "stz_stats_min" });
    @export(&stats.stz_stats_max, .{ .name = "stz_stats_max" });
    @export(&stats.stz_stats_range, .{ .name = "stz_stats_range" });
    @export(&stats.stz_stats_median, .{ .name = "stz_stats_median" });
    @export(&stats.stz_stats_variance, .{ .name = "stz_stats_variance" });
    @export(&stats.stz_stats_std_dev, .{ .name = "stz_stats_std_dev" });
    @export(&stats.stz_stats_coeff_of_variation, .{ .name = "stz_stats_coeff_of_variation" });
    @export(&stats.stz_stats_percentile, .{ .name = "stz_stats_percentile" });
    @export(&stats.stz_stats_q1, .{ .name = "stz_stats_q1" });
    @export(&stats.stz_stats_q2, .{ .name = "stz_stats_q2" });
    @export(&stats.stz_stats_q3, .{ .name = "stz_stats_q3" });
    @export(&stats.stz_stats_iqr, .{ .name = "stz_stats_iqr" });
    @export(&stats.stz_stats_skewness, .{ .name = "stz_stats_skewness" });
    @export(&stats.stz_stats_kurtosis, .{ .name = "stz_stats_kurtosis" });
    @export(&stats.stz_stats_geometric_mean, .{ .name = "stz_stats_geometric_mean" });
    @export(&stats.stz_stats_harmonic_mean, .{ .name = "stz_stats_harmonic_mean" });
    @export(&stats.stz_stats_z_scores, .{ .name = "stz_stats_z_scores" });
    @export(&stats.stz_stats_outliers, .{ .name = "stz_stats_outliers" });
    @export(&stats.stz_stats_contains_outliers, .{ .name = "stz_stats_contains_outliers" });
    @export(&stats.stz_stats_mode, .{ .name = "stz_stats_mode" });
    @export(&stats.stz_stats_trimmed_mean, .{ .name = "stz_stats_trimmed_mean" });
    @export(&stats.stz_stats_weighted_mean, .{ .name = "stz_stats_weighted_mean" });
    @export(&stats.stz_stats_normalize, .{ .name = "stz_stats_normalize" });
    @export(&stats.stz_stats_standardize, .{ .name = "stz_stats_standardize" });
    @export(&stats.stz_stats_moving_average, .{ .name = "stz_stats_moving_average" });
    @export(&stats.stz_stats_correlation, .{ .name = "stz_stats_correlation" });
    @export(&stats.stz_stats_covariance, .{ .name = "stz_stats_covariance" });
    @export(&stats.stz_stats_regression, .{ .name = "stz_stats_regression" });
    @export(&stats.stz_stats_rank_correlation, .{ .name = "stz_stats_rank_correlation" });
    @export(&stats.stz_stats_deciles, .{ .name = "stz_stats_deciles" });
    @export(&stats.stz_stats_frequency, .{ .name = "stz_stats_frequency" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test { _ = stats; }
