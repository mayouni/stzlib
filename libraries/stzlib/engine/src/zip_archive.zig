// zip_archive -- the ZIP container, read and written by the engine (stz_compress).
//
// Softanza's zip archives went through Ring's zip extension (ziplib.ring and the
// zip_* natives). Haro carries no part of Ring (CHARTER D50), so the container is
// here: a reader of the central directory, and a writer of local headers, data and
// a central directory. Entries are DEFLATE (method 8) through the vendored zlib
// when that is smaller, else STORED (method 0) -- the two methods every reader knows.
//
// SCOPE: classic ZIP only. No ZIP64 (an archive or entry over 4 GiB is refused),
// no encryption, no multi-disk. Names are taken as given (UTF-8, flag bit 11 set);
// the Ring face checks them for ".." and absolute paths before extracting.
//
// DECOMPRESSION BOMBS: an entry is inflated into a buffer of its DECLARED size, and
// inflating past it is refused; the CRC32 is checked after.
//
// The Ring boundary carries text only: names joined by "\n", several entries as
// one blob with their sizes as "n1,n2,...". The last error is kept for the caller.

const std = @import("std");
const c = @cImport({
    @cInclude("zlib.h");
});

const gpa = std.heap.c_allocator;
const MAX_ARCHIVE: usize = 1 << 31; // 2 GiB, below ZIP64

var last_error_buf: [512]u8 = undefined;
var last_error_len: usize = 0;

pub fn lastError() []const u8 {
    return last_error_buf[0..last_error_len];
}

fn setError(comptime fmt: []const u8, args: anytype) void {
    const s = std.fmt.bufPrint(&last_error_buf, fmt, args) catch {
        last_error_len = 0;
        return;
    };
    last_error_len = s.len;
}

fn clearError() void {
    last_error_len = 0;
}

pub const Entry = struct {
    name: []const u8, // slice of the archive bytes
    method: u16,
    flags: u16,
    crc: u32,
    csize: u32,
    usize_: u32,
    mtime: u16,
    mdate: u16,
    local_offset: u32,
};

fn rd16(b: []const u8, o: usize) u16 {
    return std.mem.readInt(u16, b[o..][0..2], .little);
}
fn rd32(b: []const u8, o: usize) u32 {
    return std.mem.readInt(u32, b[o..][0..4], .little);
}

/// Reads the central directory of `data` into `out`. The names point into `data`.
pub fn parse(data: []const u8, out: *std.ArrayList(Entry)) bool {
    if (data.len < 22) {
        setError("not a zip archive (too short)", .{});
        return false;
    }
    // the end-of-central-directory record: scan back over a comment of up to 64 KiB
    var eocd: ?usize = null;
    var i: usize = data.len - 22;
    const stop: usize = if (data.len > 22 + 65535) data.len - 22 - 65535 else 0;
    while (true) {
        if (rd32(data, i) == 0x06054b50) {
            eocd = i;
            break;
        }
        if (i == stop) break;
        i -= 1;
    }
    const e = eocd orelse {
        setError("not a zip archive (no end of central directory)", .{});
        return false;
    };
    const count = rd16(data, e + 10);
    const cd_size = rd32(data, e + 12);
    const cd_off = rd32(data, e + 16);
    if (count == 0xffff or cd_off == 0xffffffff) {
        setError("ZIP64 archives are not read", .{});
        return false;
    }
    if (@as(usize, cd_off) + @as(usize, cd_size) > e) {
        setError("the central directory lies outside the archive", .{});
        return false;
    }
    var p: usize = cd_off;
    var n: usize = 0;
    while (n < count) : (n += 1) {
        if (p + 46 > e or rd32(data, p) != 0x02014b50) {
            setError("a central directory record is damaged", .{});
            return false;
        }
        const name_len = rd16(data, p + 28);
        const extra_len = rd16(data, p + 30);
        const comment_len = rd16(data, p + 32);
        if (p + 46 + name_len > e) {
            setError("a name runs past the central directory", .{});
            return false;
        }
        out.append(gpa, .{
            .name = data[p + 46 .. p + 46 + name_len],
            .flags = rd16(data, p + 8),
            .method = rd16(data, p + 10),
            .mtime = rd16(data, p + 12),
            .mdate = rd16(data, p + 14),
            .crc = rd32(data, p + 16),
            .csize = rd32(data, p + 20),
            .usize_ = rd32(data, p + 24),
            .local_offset = rd32(data, p + 42),
        }) catch {
            setError("out of memory", .{});
            return false;
        };
        p += 46 + @as(usize, name_len) + extra_len + comment_len;
    }
    return true;
}

/// The bytes of an entry's compressed data inside `data`.
fn rawData(data: []const u8, en: Entry) ?[]const u8 {
    const lo: usize = en.local_offset;
    if (lo + 30 > data.len or rd32(data, lo) != 0x04034b50) {
        setError("the local header of '{s}' is damaged", .{en.name});
        return null;
    }
    const start = lo + 30 + @as(usize, rd16(data, lo + 26)) + rd16(data, lo + 28);
    if (start + @as(usize, en.csize) > data.len) {
        setError("the data of '{s}' runs past the archive", .{en.name});
        return null;
    }
    return data[start .. start + en.csize];
}

/// The uncompressed bytes of an entry, CRC-checked. Caller frees.
pub fn entryBytes(data: []const u8, en: Entry) ?[]u8 {
    if (en.flags & 1 != 0) {
        setError("'{s}' is encrypted", .{en.name});
        return null;
    }
    const raw = rawData(data, en) orelse return null;
    const out = gpa.alloc(u8, en.usize_) catch {
        setError("out of memory", .{});
        return null;
    };
    if (en.method == 0) {
        if (raw.len != en.usize_) {
            gpa.free(out);
            setError("the stored size of '{s}' disagrees", .{en.name});
            return null;
        }
        @memcpy(out, raw);
    } else if (en.method == 8) {
        var z = std.mem.zeroes(c.z_stream);
        if (c.inflateInit2_(&z, -15, c.zlibVersion(), @sizeOf(c.z_stream)) != c.Z_OK) {
            gpa.free(out);
            setError("inflate could not start", .{});
            return null;
        }
        defer _ = c.inflateEnd(&z);
        z.next_in = @constCast(raw.ptr);
        z.avail_in = @intCast(raw.len);
        var one: [1]u8 = undefined;
        z.next_out = if (out.len > 0) out.ptr else &one;
        z.avail_out = @intCast(out.len);
        const rc = c.inflate(&z, c.Z_FINISH);
        if (rc != c.Z_STREAM_END or z.total_out != out.len) {
            gpa.free(out);
            setError("'{s}' does not inflate to its declared size", .{en.name});
            return null;
        }
    } else {
        gpa.free(out);
        setError("'{s}' uses compression method {d}, which is not read", .{ en.name, en.method });
        return null;
    }
    const crc: u32 = @intCast(c.crc32(0, out.ptr, @intCast(out.len)));
    if (crc != en.crc) {
        gpa.free(out);
        setError("the CRC of '{s}' does not match", .{en.name});
        return null;
    }
    return out;
}

pub fn readFile(path: []const u8) ?[]u8 {
    return std.fs.cwd().readFileAlloc(gpa, path, MAX_ARCHIVE) catch {
        setError("cannot read the archive: {s}", .{path});
        return null;
    };
}

fn findEntry(entries: []const Entry, name: []const u8) ?Entry {
    for (entries) |en| {
        if (std.mem.eql(u8, en.name, name)) return en;
    }
    return null;
}

/// One entry to write: its name, and either new bytes or the raw record of an
/// entry carried over from the old archive (copied without recompressing).
const Pending = struct {
    name: []const u8,
    method: u16,
    crc: u32,
    csize: u32,
    usize_: u32,
    mtime: u16,
    mdate: u16,
    payload: []const u8, // compressed (or stored) bytes
    owned: bool,
};

fn dosNow() [2]u16 {
    const secs: u64 = @intCast(@max(std.time.timestamp(), 315532800));
    const es = std.time.epoch.EpochSeconds{ .secs = secs };
    const day = es.getEpochDay();
    const yd = day.calculateYearDay();
    const md = yd.calculateMonthDay();
    const ds = es.getDaySeconds();
    const year: u16 = @intCast(@max(@as(i32, yd.year) - 1980, 0));
    const date: u16 = (year << 9) | (@as(u16, md.month.numeric()) << 5) | (@as(u16, md.day_index) + 1);
    const time: u16 = (@as(u16, ds.getHoursIntoDay()) << 11) | (@as(u16, ds.getMinutesIntoHour()) << 5) | (@as(u16, ds.getSecondsIntoMinute()) / 2);
    return .{ time, date };
}

fn deflateBytes(src: []const u8) ?[]u8 {
    var z = std.mem.zeroes(c.z_stream);
    if (c.deflateInit2_(&z, c.Z_DEFAULT_COMPRESSION, c.Z_DEFLATED, -15, 8, c.Z_DEFAULT_STRATEGY, c.zlibVersion(), @sizeOf(c.z_stream)) != c.Z_OK) return null;
    defer _ = c.deflateEnd(&z);
    const bound: usize = c.deflateBound(&z, @intCast(src.len));
    const out = gpa.alloc(u8, bound + 16) catch return null;
    var one: [1]u8 = undefined;
    z.next_in = if (src.len > 0) @constCast(src.ptr) else &one;
    z.avail_in = @intCast(src.len);
    z.next_out = out.ptr;
    z.avail_out = @intCast(out.len);
    if (c.deflate(&z, c.Z_FINISH) != c.Z_STREAM_END) {
        gpa.free(out);
        return null;
    }
    return gpa.realloc(out, z.total_out) catch out[0..z.total_out];
}

fn pendingFromBytes(name: []const u8, bytes: []const u8, when: [2]u16) ?Pending {
    if (bytes.len > 0xfffffffe) {
        setError("'{s}' is over 4 GiB (ZIP64 is not written)", .{name});
        return null;
    }
    const crc: u32 = @intCast(c.crc32(0, bytes.ptr, @intCast(bytes.len)));
    if (deflateBytes(bytes)) |d| {
        if (d.len < bytes.len) {
            return .{ .name = name, .method = 8, .crc = crc, .csize = @intCast(d.len), .usize_ = @intCast(bytes.len), .mtime = when[0], .mdate = when[1], .payload = d, .owned = true };
        }
        gpa.free(d);
    }
    return .{ .name = name, .method = 0, .crc = crc, .csize = @intCast(bytes.len), .usize_ = @intCast(bytes.len), .mtime = when[0], .mdate = when[1], .payload = bytes, .owned = false };
}

fn put16(list: *std.ArrayList(u8), v: u16) !void {
    var b: [2]u8 = undefined;
    std.mem.writeInt(u16, &b, v, .little);
    try list.appendSlice(gpa, &b);
}
fn put32(list: *std.ArrayList(u8), v: u32) !void {
    var b: [4]u8 = undefined;
    std.mem.writeInt(u32, &b, v, .little);
    try list.appendSlice(gpa, &b);
}

fn serialize(items: []const Pending, out: *std.ArrayList(u8)) !void {
    var offsets = std.ArrayList(u32){};
    defer offsets.deinit(gpa);
    for (items) |it| {
        if (out.items.len > 0xfffffff0) return error.TooBig;
        try offsets.append(gpa, @intCast(out.items.len));
        try put32(out, 0x04034b50);
        try put16(out, 20); // version needed: 2.0
        try put16(out, 0x0800); // UTF-8 names
        try put16(out, it.method);
        try put16(out, it.mtime);
        try put16(out, it.mdate);
        try put32(out, it.crc);
        try put32(out, it.csize);
        try put32(out, it.usize_);
        try put16(out, @intCast(it.name.len));
        try put16(out, 0);
        try out.appendSlice(gpa, it.name);
        try out.appendSlice(gpa, it.payload);
    }
    const cd_start: u32 = @intCast(out.items.len);
    for (items, 0..) |it, k| {
        try put32(out, 0x02014b50);
        try put16(out, 20); // made by: 2.0
        try put16(out, 20);
        try put16(out, 0x0800);
        try put16(out, it.method);
        try put16(out, it.mtime);
        try put16(out, it.mdate);
        try put32(out, it.crc);
        try put32(out, it.csize);
        try put32(out, it.usize_);
        try put16(out, @intCast(it.name.len));
        try put16(out, 0); // extra
        try put16(out, 0); // comment
        try put16(out, 0); // disk
        try put16(out, 0); // internal attributes
        try put32(out, 0); // external attributes
        try put32(out, offsets.items[k]);
        try out.appendSlice(gpa, it.name);
    }
    const cd_size: u32 = @as(u32, @intCast(out.items.len)) - cd_start;
    try put32(out, 0x06054b50);
    try put16(out, 0);
    try put16(out, 0);
    try put16(out, @intCast(items.len));
    try put16(out, @intCast(items.len));
    try put32(out, cd_size);
    try put32(out, cd_start);
    try put16(out, 0);
}

/// Writes `path` from new entries (names "\n"-joined, sizes ","-joined, one blob).
/// With `append`, the entries already in `path` are kept first, and a new entry
/// replaces an old one of the same name.
pub fn write(path: []const u8, names_joined: []const u8, sizes_joined: []const u8, blob: []const u8, append: bool) bool {
    clearError();
    var items = std.ArrayList(Pending){};
    defer {
        for (items.items) |it| if (it.owned) gpa.free(it.payload);
        items.deinit(gpa);
    }

    // the new entries
    var new_names = std.ArrayList([]const u8){};
    defer new_names.deinit(gpa);
    var new_bytes = std.ArrayList([]const u8){};
    defer new_bytes.deinit(gpa);
    if (names_joined.len > 0) {
        var it_n = std.mem.splitScalar(u8, names_joined, '\n');
        var it_s = std.mem.splitScalar(u8, sizes_joined, ',');
        var at: usize = 0;
        while (it_n.next()) |nm| {
            const sz_txt = it_s.next() orelse {
                setError("fewer sizes than names", .{});
                return false;
            };
            const sz = std.fmt.parseInt(usize, std.mem.trim(u8, sz_txt, " "), 10) catch {
                setError("a size is not a number: {s}", .{sz_txt});
                return false;
            };
            if (nm.len == 0 or nm.len > 0xffff) {
                setError("an entry name is empty or too long", .{});
                return false;
            }
            if (at + sz > blob.len) {
                setError("the sizes run past the data", .{});
                return false;
            }
            new_names.append(gpa, nm) catch return false;
            new_bytes.append(gpa, blob[at .. at + sz]) catch return false;
            at += sz;
        }
        if (at != blob.len) {
            setError("the sizes do not add up to the data", .{});
            return false;
        }
    }

    // the old entries, carried over raw
    var old_data: ?[]u8 = null;
    defer if (old_data) |d| gpa.free(d);
    if (append) {
        if (std.fs.cwd().access(path, .{})) |_| {
            old_data = readFile(path) orelse return false;
            var old = std.ArrayList(Entry){};
            defer old.deinit(gpa);
            if (!parse(old_data.?, &old)) return false;
            for (old.items) |en| {
                var replaced = false;
                for (new_names.items) |nm| {
                    if (std.mem.eql(u8, nm, en.name)) replaced = true;
                }
                if (replaced) continue;
                const raw = rawData(old_data.?, en) orelse return false;
                items.append(gpa, .{ .name = en.name, .method = en.method, .crc = en.crc, .csize = en.csize, .usize_ = en.usize_, .mtime = en.mtime, .mdate = en.mdate, .payload = raw, .owned = false }) catch return false;
            }
        } else |_| {}
    }

    const when = dosNow();
    for (new_names.items, 0..) |nm, k| {
        const pend = pendingFromBytes(nm, new_bytes.items[k], when) orelse return false;
        items.append(gpa, pend) catch return false;
    }

    var out = std.ArrayList(u8){};
    defer out.deinit(gpa);
    serialize(items.items, &out) catch {
        setError("the archive is too large (ZIP64 is not written)", .{});
        return false;
    };

    // write beside, then rename: a failed write leaves the old archive whole
    var tmp_buf: [std.fs.max_path_bytes]u8 = undefined;
    const tmp = std.fmt.bufPrint(&tmp_buf, "{s}.part", .{path}) catch {
        setError("the path is too long", .{});
        return false;
    };
    const f = std.fs.cwd().createFile(tmp, .{ .truncate = true }) catch {
        setError("cannot write the archive: {s}", .{path});
        return false;
    };
    f.writeAll(out.items) catch {
        f.close();
        std.fs.cwd().deleteFile(tmp) catch {};
        setError("cannot write the archive: {s}", .{path});
        return false;
    };
    f.close();
    std.fs.cwd().rename(tmp, path) catch {
        std.fs.cwd().deleteFile(tmp) catch {};
        setError("cannot replace the archive: {s}", .{path});
        return false;
    };
    return true;
}

/// Writes every entry of `path` under `dir`; a name ending in "/" is a folder.
/// Returns the number of files written, or -1.
pub fn extractAll(path: []const u8, dir: []const u8) i64 {
    clearError();
    const data = readFile(path) orelse return -1;
    defer gpa.free(data);
    var entries = std.ArrayList(Entry){};
    defer entries.deinit(gpa);
    if (!parse(data, &entries)) return -1;
    std.fs.cwd().makePath(dir) catch {
        setError("cannot make the folder: {s}", .{dir});
        return -1;
    };
    var target = std.fs.cwd().openDir(dir, .{}) catch {
        setError("cannot open the folder: {s}", .{dir});
        return -1;
    };
    defer target.close();
    var written: i64 = 0;
    for (entries.items) |en| {
        if (en.name.len > 0 and en.name[en.name.len - 1] == '/') {
            target.makePath(en.name[0 .. en.name.len - 1]) catch {
                setError("cannot make the folder of '{s}'", .{en.name});
                return -1;
            };
            continue;
        }
        const bytes = entryBytes(data, en) orelse return -1;
        defer gpa.free(bytes);
        if (std.fs.path.dirname(en.name)) |d| {
            target.makePath(d) catch {
                setError("cannot make the folder of '{s}'", .{en.name});
                return -1;
            };
        }
        const f = target.createFile(en.name, .{ .truncate = true }) catch {
            setError("cannot write '{s}'", .{en.name});
            return -1;
        };
        defer f.close();
        f.writeAll(bytes) catch {
            setError("cannot write '{s}'", .{en.name});
            return -1;
        };
        written += 1;
    }
    return written;
}

/// The names of `path`'s entries, "\n"-joined, into `out`. False on error.
pub fn names(path: []const u8, out: *std.ArrayList(u8)) bool {
    clearError();
    const data = readFile(path) orelse return false;
    defer gpa.free(data);
    var entries = std.ArrayList(Entry){};
    defer entries.deinit(gpa);
    if (!parse(data, &entries)) return false;
    for (entries.items, 0..) |en, k| {
        if (k > 0) out.append(gpa, '\n') catch return false;
        out.appendSlice(gpa, en.name) catch return false;
    }
    return true;
}

/// The bytes of the entry `name` of `path`. Caller frees. Null on error.
pub fn readEntry(path: []const u8, name: []const u8) ?[]u8 {
    clearError();
    const data = readFile(path) orelse return null;
    defer gpa.free(data);
    var entries = std.ArrayList(Entry){};
    defer entries.deinit(gpa);
    if (!parse(data, &entries)) return null;
    const en = findEntry(entries.items, name) orelse {
        setError("no entry named '{s}'", .{name});
        return null;
    };
    return entryBytes(data, en);
}

/// The CRC32 stored for `name`, or -1.
pub fn entryCrc(path: []const u8, name: []const u8) i64 {
    clearError();
    const data = readFile(path) orelse return -1;
    defer gpa.free(data);
    var entries = std.ArrayList(Entry){};
    defer entries.deinit(gpa);
    if (!parse(data, &entries)) return -1;
    const en = findEntry(entries.items, name) orelse {
        setError("no entry named '{s}'", .{name});
        return -1;
    };
    return en.crc;
}

test "write then read back, stored and deflated, append replaces" {
    const p = "zip_archive_test.zip";
    defer std.fs.cwd().deleteFile(p) catch {};
    const a = "hello";
    const b = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
    try std.testing.expect(write(p, "a.txt\nsub/b.txt", "5,65", a ++ b, false));
    var nm = std.ArrayList(u8){};
    defer nm.deinit(gpa);
    try std.testing.expect(names(p, &nm));
    try std.testing.expectEqualStrings("a.txt\nsub/b.txt", nm.items);
    const got = readEntry(p, "sub/b.txt").?;
    defer gpa.free(got);
    try std.testing.expectEqualStrings(b, got);
    try std.testing.expectEqual(@as(i64, 0x3610a686), entryCrc(p, "a.txt"));
    try std.testing.expect(write(p, "a.txt\nc.txt", "2,0", "hi", true));
    var nm2 = std.ArrayList(u8){};
    defer nm2.deinit(gpa);
    try std.testing.expect(names(p, &nm2));
    try std.testing.expectEqualStrings("sub/b.txt\na.txt\nc.txt", nm2.items);
    const a2 = readEntry(p, "a.txt").?;
    defer gpa.free(a2);
    try std.testing.expectEqualStrings("hi", a2);
}
