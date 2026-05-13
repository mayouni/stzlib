// Per-domain entry point for stz_file.dll
// Bundles file + dir + path operations (Tier 2) into one shared library.

pub const file = @import("file.zig");

comptime {
    @export(&file.stz_file_exists, .{ .name = "stz_file_exists" });
    @export(&file.stz_file_size, .{ .name = "stz_file_size" });
    @export(&file.stz_file_read, .{ .name = "stz_file_read" });
    @export(&file.stz_file_read_free, .{ .name = "stz_file_read_free" });
    @export(&file.stz_file_write, .{ .name = "stz_file_write" });
    @export(&file.stz_file_append, .{ .name = "stz_file_append" });
    @export(&file.stz_file_delete, .{ .name = "stz_file_delete" });
    @export(&file.stz_file_copy, .{ .name = "stz_file_copy" });
    @export(&file.stz_dir_exists, .{ .name = "stz_dir_exists" });
    @export(&file.stz_dir_create, .{ .name = "stz_dir_create" });
    @export(&file.stz_dir_create_path, .{ .name = "stz_dir_create_path" });
    @export(&file.stz_dir_delete, .{ .name = "stz_dir_delete" });
    @export(&file.stz_dir_count_files, .{ .name = "stz_dir_count_files" });
    @export(&file.stz_dir_count_dirs, .{ .name = "stz_dir_count_dirs" });
    @export(&file.stz_path_extension, .{ .name = "stz_path_extension" });
    @export(&file.stz_path_basename, .{ .name = "stz_path_basename" });
    @export(&file.stz_path_dirname, .{ .name = "stz_path_dirname" });
}

test {
    _ = file;
}
