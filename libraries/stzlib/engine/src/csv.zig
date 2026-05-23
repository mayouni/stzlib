const std = @import("std");
const allocator = std.heap.c_allocator;

const RowList = std.ArrayListUnmanaged([]const u8);
const RowsContainer = std.ArrayListUnmanaged(RowList);

pub const StzCSV = struct {
    rows: RowsContainer,
    separator: u8,

    pub fn init(sep: u8) !*StzCSV {
        const self = try allocator.create(StzCSV);
        self.rows = .{};
        self.separator = sep;
        return self;
    }

    pub fn deinit(self: *StzCSV) void {
        for (self.rows.items) |*row| {
            for (row.items) |cell| allocator.free(cell);
            row.deinit(allocator);
        }
        self.rows.deinit(allocator);
        allocator.destroy(self);
    }
};

fn dupeSlice(s: []const u8) ![]const u8 {
    const d = try allocator.alloc(u8, s.len);
    @memcpy(d, s);
    return d;
}

fn parseField(line: []const u8, start: usize, sep: u8) struct { field: []const u8, next: usize } {
    if (start >= line.len) return .{ .field = "", .next = line.len };

    if (line[start] == '"') {
        var i = start + 1;
        var end_quote: usize = line.len;
        while (i < line.len) {
            if (line[i] == '"') {
                if (i + 1 < line.len and line[i + 1] == '"') {
                    i += 2;
                } else {
                    end_quote = i;
                    break;
                }
            } else {
                i += 1;
            }
        }
        var unescaped = allocator.alloc(u8, end_quote - start - 1) catch return .{ .field = line[start + 1 .. end_quote], .next = end_quote + 2 };
        var wpos: usize = 0;
        var rpos = start + 1;
        while (rpos < end_quote) {
            if (line[rpos] == '"' and rpos + 1 < end_quote and line[rpos + 1] == '"') {
                unescaped[wpos] = '"';
                wpos += 1;
                rpos += 2;
            } else {
                unescaped[wpos] = line[rpos];
                wpos += 1;
                rpos += 1;
            }
        }
        const result = allocator.realloc(unescaped, wpos) catch unescaped;
        _ = result;
        var next = end_quote + 1;
        if (next < line.len and line[next] == sep) next += 1;
        return .{ .field = unescaped[0..wpos], .next = next };
    }

    var i = start;
    while (i < line.len and line[i] != sep) : (i += 1) {}
    const next = if (i < line.len) i + 1 else i;
    return .{ .field = line[start..i], .next = next };
}

// ─── C ABI ───

pub fn stz_csv_parse(ptr: [*]const u8, len: usize, sep: u8) callconv(.c) ?*StzCSV {
    if (len == 0) return null;
    const data = ptr[0..len];
    const csv = StzCSV.init(sep) catch return null;

    var line_start: usize = 0;
    while (line_start < data.len) {
        var line_end = line_start;
        while (line_end < data.len and data[line_end] != '\n' and data[line_end] != '\r') : (line_end += 1) {}

        const line = data[line_start..line_end];
        if (line.len > 0) {
            var row: RowList = .{};
            var pos: usize = 0;
            while (pos < line.len) {
                const result = parseField(line, pos, sep);
                const cell = dupeSlice(result.field) catch break;
                row.append(allocator, cell) catch {
                    allocator.free(cell);
                    break;
                };
                if (result.next <= pos) break;
                pos = result.next;
                if (pos > line.len) break;
            }
            csv.rows.append(allocator, row) catch {
                for (row.items) |cell| allocator.free(cell);
                row.deinit(allocator);
            };
        }

        line_start = line_end;
        if (line_start < data.len and data[line_start] == '\r') line_start += 1;
        if (line_start < data.len and data[line_start] == '\n') line_start += 1;
    }

    return csv;
}

pub fn stz_csv_free(csv: ?*StzCSV) callconv(.c) void {
    if (csv) |c| c.deinit();
}

pub fn stz_csv_row_count(csv: ?*const StzCSV) callconv(.c) usize {
    const c = csv orelse return 0;
    return c.rows.items.len;
}

pub fn stz_csv_col_count(csv: ?*const StzCSV, row: usize) callconv(.c) usize {
    const c = csv orelse return 0;
    if (row >= c.rows.items.len) return 0;
    return c.rows.items[row].items.len;
}

pub fn stz_csv_get_cell(csv: ?*const StzCSV, row: usize, col: usize, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const c = csv orelse return 0;
    if (row >= c.rows.items.len) return 0;
    const r = c.rows.items[row];
    if (col >= r.items.len) return 0;
    const cell = r.items[col];
    const copy_len = @min(cell.len, buf_len);
    @memcpy(buf[0..copy_len], cell[0..copy_len]);
    return copy_len;
}

pub fn stz_csv_is_valid(ptr: [*]const u8, len: usize, sep: u8) callconv(.c) i32 {
    if (len == 0) return 0;
    const csv = stz_csv_parse(ptr, len, sep) orelse return 0;
    defer stz_csv_free(csv);
    if (csv.rows.items.len < 2) return 0;
    const expected_cols = csv.rows.items[0].items.len;
    if (expected_cols == 0) return 0;
    for (csv.rows.items[1..]) |row| {
        if (row.items.len != expected_cols) return 0;
    }
    return 1;
}

pub fn stz_csv_to_string(csv: ?*const StzCSV, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const c = csv orelse return 0;
    if (buf_len == 0) return 0;
    var pos: usize = 0;
    for (c.rows.items, 0..) |row, ri| {
        if (ri > 0) {
            if (pos < buf_len) {
                buf[pos] = '\n';
                pos += 1;
            }
        }
        for (row.items, 0..) |cell, ci| {
            if (ci > 0 and pos < buf_len) {
                buf[pos] = c.separator;
                pos += 1;
            }
            const copy_len = @min(cell.len, buf_len - pos);
            if (copy_len > 0) {
                @memcpy(buf[pos .. pos + copy_len], cell[0..copy_len]);
                pos += copy_len;
            }
        }
    }
    return pos;
}

// ─── Tests ───

test "csv parse basic" {
    const data = "name;age\nAlice;30\nBob;25";
    const csv = stz_csv_parse(data.ptr, data.len, ';') orelse return error.ParseFailed;
    defer stz_csv_free(csv);
    try std.testing.expectEqual(@as(usize, 3), stz_csv_row_count(csv));
    try std.testing.expectEqual(@as(usize, 2), stz_csv_col_count(csv, 0));

    var buf: [64]u8 = undefined;
    var len = stz_csv_get_cell(csv, 0, 0, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..len], "name"));
    len = stz_csv_get_cell(csv, 1, 0, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..len], "Alice"));
    len = stz_csv_get_cell(csv, 1, 1, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..len], "30"));
    len = stz_csv_get_cell(csv, 2, 1, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..len], "25"));
}

test "csv parse comma separated" {
    const data = "a,b,c\n1,2,3";
    const csv = stz_csv_parse(data.ptr, data.len, ',') orelse return error.ParseFailed;
    defer stz_csv_free(csv);
    try std.testing.expectEqual(@as(usize, 2), stz_csv_row_count(csv));
    try std.testing.expectEqual(@as(usize, 3), stz_csv_col_count(csv, 0));
}

test "csv is_valid" {
    const valid = "a;b\n1;2\n3;4";
    try std.testing.expectEqual(@as(i32, 1), stz_csv_is_valid(valid.ptr, valid.len, ';'));

    const invalid = "a;b\n1;2;3";
    try std.testing.expectEqual(@as(i32, 0), stz_csv_is_valid(invalid.ptr, invalid.len, ';'));
}

test "csv to_string roundtrip" {
    const data = "name;age\nAlice;30\nBob;25";
    const csv = stz_csv_parse(data.ptr, data.len, ';') orelse return error.ParseFailed;
    defer stz_csv_free(csv);
    var buf: [256]u8 = undefined;
    const len = stz_csv_to_string(csv, &buf, 256);
    try std.testing.expect(std.mem.eql(u8, buf[0..len], data));
}

test "csv null handles" {
    stz_csv_free(null);
    try std.testing.expectEqual(@as(usize, 0), stz_csv_row_count(null));
    try std.testing.expectEqual(@as(usize, 0), stz_csv_col_count(null, 0));
}

test "csv crlf line endings" {
    const data = "a;b\r\n1;2\r\n3;4";
    const csv = stz_csv_parse(data.ptr, data.len, ';') orelse return error.ParseFailed;
    defer stz_csv_free(csv);
    try std.testing.expectEqual(@as(usize, 3), stz_csv_row_count(csv));
}

test "csv quoted fields" {
    const data = "name;desc\n\"Alice\";\"hello, world\"";
    const csv = stz_csv_parse(data.ptr, data.len, ';') orelse return error.ParseFailed;
    defer stz_csv_free(csv);
    var buf: [64]u8 = undefined;
    const len = stz_csv_get_cell(csv, 1, 1, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..len], "hello, world"));
}
