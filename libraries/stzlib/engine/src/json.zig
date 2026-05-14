// Softanza Engine -- JSON Operations (Tier 3)
//
// Replaces Qt QJsonDocument/QJsonObject/QJsonArray with Zig std.json.
// All functions use C ABI for Ring FFI compatibility.
// JSON is parsed to an internal tree; queries extract values.

const std = @import("std");
const mem = std.mem;
const gpa = std.heap.c_allocator;

// ─── JSON Handle ───

pub const StzJsonHandle = ?*Json;

const Json = struct {
    source: []const u8,
    tree: ?std.json.Parsed(std.json.Value),
    is_array: bool,
    last_error: [256]u8,
    error_len: usize,
};

pub fn stz_json_parse(data: [*c]const u8, data_len: usize) callconv(.c) ?*Json {
    if (data == null or data_len == 0) return null;
    const src = gpa.dupe(u8, data[0..data_len]) catch return null;
    const j = gpa.create(Json) catch { gpa.free(src); return null; };
    j.* = .{ .source = src, .tree = null, .is_array = false, .last_error = undefined, .error_len = 0 };

    j.tree = std.json.parseFromSlice(std.json.Value, gpa, src, .{}) catch |err| {
        setError(j, @errorName(err));
        return j;
    };

    if (j.tree) |t| {
        j.is_array = t.value == .array;
    }
    return j;
}

pub fn stz_json_free(h: ?*Json) callconv(.c) void {
    if (h) |j| {
        if (j.tree) |*t| t.deinit();
        gpa.free(j.source);
        gpa.destroy(j);
    }
}

pub fn stz_json_is_valid(h: ?*Json) callconv(.c) c_int {
    const j = h orelse return 0;
    return if (j.tree != null) 1 else 0;
}

pub fn stz_json_is_array(h: ?*Json) callconv(.c) c_int {
    const j = h orelse return 0;
    return if (j.is_array) 1 else 0;
}

pub fn stz_json_size(h: ?*Json) callconv(.c) c_int {
    const j = h orelse return 0;
    const t = j.tree orelse return 0;
    return switch (t.value) {
        .object => |o| @intCast(o.count()),
        .array => |a| @intCast(a.items.len),
        else => 0,
    };
}

pub fn stz_json_has_key(h: ?*Json, key: [*c]const u8, key_len: usize) callconv(.c) c_int {
    const j = h orelse return 0;
    const t = j.tree orelse return 0;
    if (t.value != .object) return 0;
    if (key == null or key_len == 0) return 0;
    return if (t.value.object.get(key[0..key_len]) != null) 1 else 0;
}

pub fn stz_json_get_string(h: ?*Json, key: [*c]const u8, key_len: usize, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const j = h orelse return 0;
    const t = j.tree orelse return 0;
    if (t.value != .object) return 0;
    if (key == null or key_len == 0) return 0;
    const val = t.value.object.get(key[0..key_len]) orelse return 0;
    if (val != .string) return 0;
    const s = val.string;
    if (s.len > buf_len) return 0;
    @memcpy(buf[0..s.len], s);
    return s.len;
}

pub fn stz_json_get_int(h: ?*Json, key: [*c]const u8, key_len: usize) callconv(.c) i64 {
    const j = h orelse return 0;
    const t = j.tree orelse return 0;
    if (t.value != .object) return 0;
    if (key == null or key_len == 0) return 0;
    const val = t.value.object.get(key[0..key_len]) orelse return 0;
    return switch (val) {
        .integer => val.integer,
        .float => @intFromFloat(val.float),
        else => 0,
    };
}

pub fn stz_json_get_bool(h: ?*Json, key: [*c]const u8, key_len: usize) callconv(.c) c_int {
    const j = h orelse return -1;
    const t = j.tree orelse return -1;
    if (t.value != .object) return -1;
    if (key == null or key_len == 0) return -1;
    const val = t.value.object.get(key[0..key_len]) orelse return -1;
    if (val != .bool) return -1;
    return if (val.bool) 1 else 0;
}

pub fn stz_json_array_at_string(h: ?*Json, idx: c_int, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const j = h orelse return 0;
    const t = j.tree orelse return 0;
    if (t.value != .array) return 0;
    const i: usize = @intCast(idx);
    if (i >= t.value.array.items.len) return 0;
    const val = t.value.array.items[i];
    if (val != .string) return 0;
    const s = val.string;
    if (s.len > buf_len) return 0;
    @memcpy(buf[0..s.len], s);
    return s.len;
}

pub fn stz_json_array_at_int(h: ?*Json, idx: c_int) callconv(.c) i64 {
    const j = h orelse return 0;
    const t = j.tree orelse return 0;
    if (t.value != .array) return 0;
    const i: usize = @intCast(idx);
    if (i >= t.value.array.items.len) return 0;
    const val = t.value.array.items[i];
    return switch (val) {
        .integer => val.integer,
        .float => @intFromFloat(val.float),
        else => 0,
    };
}

// ─── Serialization ───

pub fn stz_json_to_string(h: ?*Json, out_len: *usize) callconv(.c) [*c]u8 {
    out_len.* = 0;
    const j = h orelse return null;
    const t = j.tree orelse return null;
    const result = std.json.Stringify.valueAlloc(gpa, t.value, .{}) catch return null;
    out_len.* = result.len;
    return @constCast(result.ptr);
}

pub fn stz_json_to_string_pretty(h: ?*Json, out_len: *usize) callconv(.c) [*c]u8 {
    out_len.* = 0;
    const j = h orelse return null;
    const t = j.tree orelse return null;
    const result = std.json.Stringify.valueAlloc(gpa, t.value, .{ .whitespace = .indent_4 }) catch return null;
    out_len.* = result.len;
    return @constCast(result.ptr);
}

pub fn stz_json_string_free(ptr: [*c]u8, len: usize) callconv(.c) void {
    if (ptr != null and len > 0) gpa.free(ptr[0..len]);
}

pub fn stz_json_keys(h: ?*Json, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const j = h orelse return 0;
    const t = j.tree orelse return 0;
    if (t.value != .object) return 0;
    var out: usize = 0;
    var it = t.value.object.iterator();
    var first = true;
    while (it.next()) |entry| {
        if (!first) {
            if (out >= buf_len) return 0;
            buf[out] = '\n';
            out += 1;
        }
        if (out + entry.key_ptr.*.len > buf_len) return 0;
        @memcpy(buf[out .. out + entry.key_ptr.*.len], entry.key_ptr.*);
        out += entry.key_ptr.*.len;
        first = false;
    }
    return out;
}

pub fn stz_json_error(h: ?*Json, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const j = h orelse return 0;
    if (j.error_len == 0) return 0;
    const len = @min(j.error_len, buf_len);
    @memcpy(buf[0..len], j.last_error[0..len]);
    return len;
}

fn setError(j: *Json, msg: []const u8) void {
    const len = @min(msg.len, 256);
    @memcpy(j.last_error[0..len], msg[0..len]);
    j.error_len = len;
}

// ─── Tests ───

test "parse object" {
    const j = stz_json_parse("{\"name\":\"Zin\",\"version\":1}", 26) orelse return error.NullJson;
    defer stz_json_free(j);
    try std.testing.expectEqual(@as(c_int, 1), stz_json_is_valid(j));
    try std.testing.expectEqual(@as(c_int, 0), stz_json_is_array(j));
    try std.testing.expectEqual(@as(c_int, 2), stz_json_size(j));
    try std.testing.expectEqual(@as(c_int, 1), stz_json_has_key(j, "name", 4));

    var buf: [64]u8 = undefined;
    const len = stz_json_get_string(j, "name", 4, &buf, 64);
    try std.testing.expect(mem.eql(u8, buf[0..len], "Zin"));
    try std.testing.expectEqual(@as(i64, 1), stz_json_get_int(j, "version", 7));
}

test "parse array" {
    const j = stz_json_parse("[10,20,30]", 10) orelse return error.NullJson;
    defer stz_json_free(j);
    try std.testing.expectEqual(@as(c_int, 1), stz_json_is_array(j));
    try std.testing.expectEqual(@as(c_int, 3), stz_json_size(j));
    try std.testing.expectEqual(@as(i64, 20), stz_json_array_at_int(j, 1));
}

test "invalid json" {
    const j = stz_json_parse("{bad}", 5) orelse return error.NullJson;
    defer stz_json_free(j);
    try std.testing.expectEqual(@as(c_int, 0), stz_json_is_valid(j));
}
