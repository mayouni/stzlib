const f = @import("file.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;

fn ring_FileExists(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_file_exists(gs(p, 1), @intCast(gss(p, 1)))));
}
fn ring_FileSize(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_file_size(gs(p, 1), @intCast(gss(p, 1)))));
}
fn ring_FileMTime(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_file_mtime(gs(p, 1), @intCast(gss(p, 1)))));
}
fn ring_FileRead(p: *anyopaque) callconv(.c) void {
    var out_len: usize = 0;
    const ptr = f.stz_file_read(gs(p, 1), @intCast(gss(p, 1)), &out_len);
    if (ptr != null and out_len > 0) {
        rs2(p, ptr, @intCast(out_len));
        f.stz_file_read_free(ptr, out_len);
    } else rs(p, "");
}
fn ring_FileWrite(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_file_write(gs(p, 1), @intCast(gss(p, 1)), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_FileAppend(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_file_append(gs(p, 1), @intCast(gss(p, 1)), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_FileDelete(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_file_delete(gs(p, 1), @intCast(gss(p, 1)))));
}
fn ring_FileCopy(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_file_copy(gs(p, 1), @intCast(gss(p, 1)), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_DirExists(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_dir_exists(gs(p, 1), @intCast(gss(p, 1)))));
}
fn ring_DirCreate(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_dir_create(gs(p, 1), @intCast(gss(p, 1)))));
}
fn ring_DirCreatePath(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_dir_create_path(gs(p, 1), @intCast(gss(p, 1)))));
}
fn ring_DirDelete(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_dir_delete(gs(p, 1), @intCast(gss(p, 1)))));
}
fn ring_DirCountFiles(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_dir_count_files(gs(p, 1), @intCast(gss(p, 1)))));
}
fn ring_DirCountDirs(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_dir_count_dirs(gs(p, 1), @intCast(gss(p, 1)))));
}
fn ring_PathExtension(p: *anyopaque) callconv(.c) void {
    var buf: [256]u8 = undefined;
    const n = f.stz_path_extension(gs(p, 1), @intCast(gss(p, 1)), &buf, 256);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_PathBasename(p: *anyopaque) callconv(.c) void {
    var buf: [1024]u8 = undefined;
    const n = f.stz_path_basename(gs(p, 1), @intCast(gss(p, 1)), &buf, 1024);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_PathDirname(p: *anyopaque) callconv(.c) void {
    var buf: [1024]u8 = undefined;
    const n = f.stz_path_dirname(gs(p, 1), @intCast(gss(p, 1)), &buf, 1024);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginefileexists", .func = &ring_FileExists },
    .{ .name = "stzenginefilesize", .func = &ring_FileSize },
    .{ .name = "stzenginefilemtime", .func = &ring_FileMTime },
    .{ .name = "stzenginefileread", .func = &ring_FileRead },
    .{ .name = "stzenginefilewrite", .func = &ring_FileWrite },
    .{ .name = "stzenginefileappend", .func = &ring_FileAppend },
    .{ .name = "stzenginefiledelete", .func = &ring_FileDelete },
    .{ .name = "stzenginefilecopy", .func = &ring_FileCopy },
    .{ .name = "stzenginedirexists", .func = &ring_DirExists },
    .{ .name = "stzenginedircreate", .func = &ring_DirCreate },
    .{ .name = "stzenginedircreatepath", .func = &ring_DirCreatePath },
    .{ .name = "stzenginedirdelete", .func = &ring_DirDelete },
    .{ .name = "stzenginedircountfiles", .func = &ring_DirCountFiles },
    .{ .name = "stzenginedircountdirs", .func = &ring_DirCountDirs },
    .{ .name = "stzenginepathextension", .func = &ring_PathExtension },
    .{ .name = "stzenginepathbasename", .func = &ring_PathBasename },
    .{ .name = "stzenginepathdirname", .func = &ring_PathDirname },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
