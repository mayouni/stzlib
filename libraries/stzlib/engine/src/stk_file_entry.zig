// Core entry point for stk_file.dll
// Minimal file operations: exists, read, write, delete, dir_exists.
// Base (stz_file.dll) is a strict superset of this.

pub const file = @import("file.zig");

comptime {
    @export(&file.stz_file_exists, .{ .name = "stz_file_exists" });
    @export(&file.stz_file_read, .{ .name = "stz_file_read" });
    @export(&file.stz_file_read_free, .{ .name = "stz_file_read_free" });
    @export(&file.stz_file_write, .{ .name = "stz_file_write" });
    @export(&file.stz_file_delete, .{ .name = "stz_file_delete" });
    @export(&file.stz_dir_exists, .{ .name = "stz_dir_exists" });
}

test {
    _ = file;
}
