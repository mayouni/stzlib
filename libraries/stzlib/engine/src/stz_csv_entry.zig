pub const csv = @import("csv.zig");
pub const ring_bridge = @import("ring_bridge_csv.zig");

comptime {
    @export(&csv.stz_csv_parse, .{ .name = "stz_csv_parse" });
    @export(&csv.stz_csv_free, .{ .name = "stz_csv_free" });
    @export(&csv.stz_csv_row_count, .{ .name = "stz_csv_row_count" });
    @export(&csv.stz_csv_col_count, .{ .name = "stz_csv_col_count" });
    @export(&csv.stz_csv_get_cell, .{ .name = "stz_csv_get_cell" });
    @export(&csv.stz_csv_is_valid, .{ .name = "stz_csv_is_valid" });
    @export(&csv.stz_csv_to_string, .{ .name = "stz_csv_to_string" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test { _ = csv; }
