const std = @import("std");
const f = @import("file.zig");
const pdf = @import("pdf.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;

// Returns a Ring LIST of names, UTF-8 as they are on disk.
//
// Ring's own dir() mangles non-ASCII names to '?' via the ANSI code page on
// Windows, which makes two differently-named files indistinguishable. This
// path carries the bytes through untouched.
fn emitDirList(p: *anyopaque, ptr: [*c]u8, out_len: usize) void {
    const out = R.ring_vm_api_newlist(p) orelse return;

    if (ptr != null) {
        defer f.stz_file_read_free(ptr, out_len);

        const buf = ptr[0..out_len];
        var start: usize = 0;
        var i: usize = 0;
        while (i < buf.len) : (i += 1) {
            if (buf[i] == 0) {
                if (i > start) R.ring_list_addstring2(out, buf.ptr + start, @intCast(i - start));
                start = i + 1;
            }
        }
        if (buf.len > start) R.ring_list_addstring2(out, buf.ptr + start, @intCast(buf.len - start));
    }

    // An unreadable or empty directory returns an EMPTY list, not nothing --
    // callers walk a filesystem and must not have to tell those apart.
    R.ring_vm_api_retlist(p, out);
}

fn ring_DirListFiles(p: *anyopaque) callconv(.c) void {
    var out_len: usize = 0;
    const ptr = f.stz_dir_list_files(gs(p, 1), @intCast(gss(p, 1)), &out_len);
    emitDirList(p, ptr, out_len);
}

fn ring_DirListDirs(p: *anyopaque) callconv(.c) void {
    var out_len: usize = 0;
    const ptr = f.stz_dir_list_dirs(gs(p, 1), @intCast(gss(p, 1)), &out_len);
    emitDirList(p, ptr, out_len);
}

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

fn ring_FileSetReadOnly(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_file_set_readonly(gs(p, 1), @intCast(gss(p, 1)), @intFromFloat(g(p, 2)))));
}
fn ring_FileSetExecutable(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_file_set_executable(gs(p, 1), @intCast(gss(p, 1)))));
}
// StzEngineFileWritePrivate(cPath, cBytes) -> 1 written (owner-only), 0 failed
fn ring_FileWritePrivate(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_file_write_private(gs(p, 1), @intCast(gss(p, 1)), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_FileIsReadOnly(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(f.stz_file_is_readonly(gs(p, 1), @intCast(gss(p, 1)))));
}

// ---- the native PDF reader (pdf.zig) ---------------------------------------------------------------------
// One document is open at a time: StzEnginePdfOpen reads and lays it out once, and the other calls read
// that result until StzEnginePdfClose or the next open. A refusal (not a PDF, encrypted, no page) answers -1
// and StzEnginePdfError says why in a sentence.

var g_pdf: ?pdf.Result = null;
var g_pdf_err: [512]u8 = undefined;
var g_pdf_err_len: usize = 0;

fn pdfSetError(msg: []const u8) void {
    const n = @min(msg.len, g_pdf_err.len);
    @memcpy(g_pdf_err[0..n], msg[0..n]);
    g_pdf_err_len = n;
}

fn pdfClose() void {
    if (g_pdf) |*r| r.deinit();
    g_pdf = null;
}

// StzEnginePdfOpen(cPath) -> the number of pages, or -1 (StzEnginePdfError says why)
fn ring_PdfOpen(p: *anyopaque) callconv(.c) void {
    pdfClose();
    g_pdf_err_len = 0;
    const path = gs(p, 1)[0..@intCast(gss(p, 1))];
    const r = pdf.readFile(std.heap.page_allocator, path) catch |e| {
        pdfSetError(switch (e) {
            error.NotPdf => "the file is not a PDF",
            error.Encrypted => "the PDF is encrypted; it is not read",
            error.NoPages => "the PDF has no page that could be found",
            error.FileNotFound => "the file does not exist",
            error.OutOfMemory => "out of memory while reading the PDF",
            else => @errorName(e),
        });
        rn(p, -1);
        return;
    };
    g_pdf = r;
    rn(p, @floatFromInt(r.pages));
}

fn ring_PdfError(p: *anyopaque) callconv(.c) void {
    rs2(p, &g_pdf_err, @intCast(g_pdf_err_len));
}

// StzEnginePdfInfo() -> [ nPages, cVersion, bEncrypted, bTagged, nGlyphs, nBlocks ], [] when nothing is open
fn ring_PdfInfo(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    if (g_pdf) |r| {
        R.ring_list_adddouble(out, @floatFromInt(r.pages));
        R.ring_list_addstring2(out, r.version.ptr, @intCast(r.version.len));
        R.ring_list_adddouble(out, if (r.encrypted) 1 else 0);
        R.ring_list_adddouble(out, if (r.tagged) 1 else 0);
        R.ring_list_adddouble(out, @floatFromInt(r.glyphs));
        R.ring_list_adddouble(out, @floatFromInt(r.blocks.len));
    }
    R.ring_vm_api_retlist(p, out);
}

// StzEnginePdfBlocks() -> one [ nPage, cKind, nLevel, nX0, nY0, nX1, nY1, nSize, bBold, bMono, cText, aRows ]
// per block, in reading order; aRows holds a table's cells row by row ([] for any other kind)
fn ring_PdfBlocks(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    if (g_pdf) |r| {
        for (r.blocks) |b| {
            const l = R.ring_list_newlist(out) orelse continue;
            const kn = pdf.kindName(b.kind);
            R.ring_list_adddouble(l, @floatFromInt(b.page));
            R.ring_list_addstring2(l, kn.ptr, @intCast(kn.len));
            R.ring_list_adddouble(l, @floatFromInt(b.level));
            R.ring_list_adddouble(l, b.x0);
            R.ring_list_adddouble(l, b.y0);
            R.ring_list_adddouble(l, b.x1);
            R.ring_list_adddouble(l, b.y1);
            R.ring_list_adddouble(l, b.size);
            R.ring_list_adddouble(l, if (b.bold) 1 else 0);
            R.ring_list_adddouble(l, if (b.mono) 1 else 0);
            R.ring_list_addstring2(l, b.text.ptr, @intCast(b.text.len));
            const rows = R.ring_list_newlist(l) orelse continue;
            for (b.rows) |row| {
                const rl = R.ring_list_newlist(rows) orelse continue;
                for (row) |c| R.ring_list_addstring2(rl, c.ptr, @intCast(c.len));
            }
        }
    }
    R.ring_vm_api_retlist(p, out);
}

// StzEnginePdfText() -> the body text in reading order, blocks separated by a blank line, page furniture left out
fn ring_PdfText(p: *anyopaque) callconv(.c) void {
    if (g_pdf) |r| {
        rs2(p, r.text.ptr, @intCast(r.text.len));
    } else rs2(p, &g_pdf_err, 0);
}

fn ring_PdfClose(p: *anyopaque) callconv(.c) void {
    pdfClose();
    rn(p, 1);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginepdfopen", .func = &ring_PdfOpen },
    .{ .name = "stzenginepdferror", .func = &ring_PdfError },
    .{ .name = "stzenginepdfinfo", .func = &ring_PdfInfo },
    .{ .name = "stzenginepdfblocks", .func = &ring_PdfBlocks },
    .{ .name = "stzenginepdftext", .func = &ring_PdfText },
    .{ .name = "stzenginepdfclose", .func = &ring_PdfClose },
    .{ .name = "stzenginefilesetreadonly", .func = &ring_FileSetReadOnly },
    .{ .name = "stzenginefilewriteprivate", .func = &ring_FileWritePrivate },
    .{ .name = "stzenginefilesetexecutable", .func = &ring_FileSetExecutable },
    .{ .name = "stzenginefileisreadonly", .func = &ring_FileIsReadOnly },
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
    .{ .name = "stzenginedirlistfiles", .func = &ring_DirListFiles },
    .{ .name = "stzenginedirlistdirs", .func = &ring_DirListDirs },
    .{ .name = "stzenginepathextension", .func = &ring_PathExtension },
    .{ .name = "stzenginepathbasename", .func = &ring_PathBasename },
    .{ .name = "stzenginepathdirname", .func = &ring_PathDirname },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
