// Softanza Engine -- StzValue: tagged union for heterogeneous values
//
// Every Softanza collection item is an StzValue. This eliminates the
// Ring-side "stringify everything" pattern and enables typed operations
// (sort numbers numerically, compare strings with casefold, etc.)
//
// C ABI: stz_value_* prefix. All handles are opaque pointers.

const std = @import("std");
const allocator = std.heap.c_allocator;

// ─── Value Type Tags ───

pub const ValueType = enum(u8) {
    null_val = 0,
    bool_val = 1,
    int_val = 2,
    float_val = 3,
    string_val = 4,
    list_val = 5,
};

// ─── Core Value Struct ───

pub const StzValue = struct {
    tag: ValueType,
    data: Data,

    const Data = union {
        null_val: void,
        bool_val: bool,
        int_val: i64,
        float_val: f64,
        string_val: StringData,
        list_val: ListData,
    };

    const StringData = struct {
        ptr: [*]const u8,
        len: usize,
        owned: bool,
    };

    const ListData = struct {
        items: [*]*StzValue,
        len: usize,
        cap: usize,
    };

    pub fn deinit(self: *StzValue) void {
        switch (self.tag) {
            .string_val => {
                if (self.data.string_val.owned and self.data.string_val.len > 0) {
                    allocator.free(self.data.string_val.ptr[0..self.data.string_val.len]);
                }
            },
            .list_val => {
                const list = self.data.list_val;
                for (0..list.len) |i| {
                    list.items[i].deinit();
                    allocator.destroy(list.items[i]);
                }
                if (list.cap > 0) {
                    allocator.free(list.items[0..list.cap]);
                }
            },
            else => {},
        }
    }

    pub fn clone(self: *const StzValue) !*StzValue {
        const v = try allocator.create(StzValue);
        v.tag = self.tag;
        switch (self.tag) {
            .null_val => v.data = .{ .null_val = {} },
            .bool_val => v.data = .{ .bool_val = self.data.bool_val },
            .int_val => v.data = .{ .int_val = self.data.int_val },
            .float_val => v.data = .{ .float_val = self.data.float_val },
            .string_val => {
                const src = self.data.string_val;
                if (src.len == 0) {
                    v.data = .{ .string_val = .{ .ptr = undefined, .len = 0, .owned = false } };
                } else {
                    const buf = try allocator.alloc(u8, src.len);
                    @memcpy(buf, src.ptr[0..src.len]);
                    v.data = .{ .string_val = .{ .ptr = buf.ptr, .len = buf.len, .owned = true } };
                }
            },
            .list_val => {
                const src = self.data.list_val;
                if (src.len == 0) {
                    v.data = .{ .list_val = .{ .items = undefined, .len = 0, .cap = 0 } };
                } else {
                    const items = try allocator.alloc(*StzValue, src.len);
                    for (0..src.len) |i| {
                        items[i] = try src.items[i].clone();
                    }
                    v.data = .{ .list_val = .{ .items = items.ptr, .len = src.len, .cap = src.len } };
                }
            },
        }
        return v;
    }

    pub fn eql(a: *const StzValue, b: *const StzValue) bool {
        if (a.tag != b.tag) return false;
        return switch (a.tag) {
            .null_val => true,
            .bool_val => a.data.bool_val == b.data.bool_val,
            .int_val => a.data.int_val == b.data.int_val,
            .float_val => a.data.float_val == b.data.float_val,
            .string_val => {
                const sa = a.data.string_val;
                const sb = b.data.string_val;
                if (sa.len != sb.len) return false;
                if (sa.len == 0) return true;
                return std.mem.eql(u8, sa.ptr[0..sa.len], sb.ptr[0..sb.len]);
            },
            .list_val => {
                const la = a.data.list_val;
                const lb = b.data.list_val;
                if (la.len != lb.len) return false;
                for (0..la.len) |i| {
                    if (!la.items[i].eql(lb.items[i])) return false;
                }
                return true;
            },
        };
    }

    pub fn compare(a: *const StzValue, b: *const StzValue) i32 {
        if (a.tag != b.tag) {
            return @as(i32, @intCast(@intFromEnum(a.tag))) - @as(i32, @intCast(@intFromEnum(b.tag)));
        }
        return switch (a.tag) {
            .null_val => 0,
            .bool_val => blk: {
                const ai: i32 = if (a.data.bool_val) 1 else 0;
                const bi: i32 = if (b.data.bool_val) 1 else 0;
                break :blk ai - bi;
            },
            .int_val => blk: {
                if (a.data.int_val < b.data.int_val) break :blk @as(i32, -1);
                if (a.data.int_val > b.data.int_val) break :blk @as(i32, 1);
                break :blk @as(i32, 0);
            },
            .float_val => blk: {
                if (a.data.float_val < b.data.float_val) break :blk @as(i32, -1);
                if (a.data.float_val > b.data.float_val) break :blk @as(i32, 1);
                break :blk @as(i32, 0);
            },
            .string_val => blk: {
                const sa = a.data.string_val;
                const sb = b.data.string_val;
                const min_len = @min(sa.len, sb.len);
                if (min_len > 0) {
                    const ord = std.mem.order(u8, sa.ptr[0..min_len], sb.ptr[0..min_len]);
                    if (ord != .eq) break :blk if (ord == .lt) @as(i32, -1) else @as(i32, 1);
                }
                if (sa.len < sb.len) break :blk @as(i32, -1);
                if (sa.len > sb.len) break :blk @as(i32, 1);
                break :blk @as(i32, 0);
            },
            .list_val => blk: {
                const la = a.data.list_val;
                const lb = b.data.list_val;
                const min_len = @min(la.len, lb.len);
                for (0..min_len) |i| {
                    const c = la.items[i].compare(lb.items[i]);
                    if (c != 0) break :blk c;
                }
                if (la.len < lb.len) break :blk @as(i32, -1);
                if (la.len > lb.len) break :blk @as(i32, 1);
                break :blk @as(i32, 0);
            },
        };
    }

    // Format value as string representation
    pub fn toString(self: *const StzValue, buf: []u8) usize {
        var stream = std.io.fixedBufferStream(buf);
        const writer = stream.writer();
        self.writeToStream(writer) catch return 0;
        return stream.pos;
    }

    fn writeToStream(self: *const StzValue, writer: anytype) !void {
        switch (self.tag) {
            .null_val => try writer.writeAll("NULL"),
            .bool_val => try writer.writeAll(if (self.data.bool_val) "TRUE" else "FALSE"),
            .int_val => try std.fmt.format(writer, "{d}", .{self.data.int_val}),
            .float_val => try std.fmt.format(writer, "{d}", .{self.data.float_val}),
            .string_val => {
                const s = self.data.string_val;
                if (s.len > 0) {
                    try writer.writeAll(s.ptr[0..s.len]);
                }
            },
            .list_val => {
                const list = self.data.list_val;
                try writer.writeByte('[');
                for (0..list.len) |i| {
                    if (i > 0) try writer.writeAll(", ");
                    if (list.items[i].tag == .string_val) {
                        try writer.writeByte('"');
                        try list.items[i].writeToStream(writer);
                        try writer.writeByte('"');
                    } else {
                        try list.items[i].writeToStream(writer);
                    }
                }
                try writer.writeByte(']');
            },
        }
    }
};

// ─── C ABI: Constructors ───

pub fn stz_value_new_null() callconv(.c) ?*StzValue {
    const v = allocator.create(StzValue) catch return null;
    v.* = .{ .tag = .null_val, .data = .{ .null_val = {} } };
    return v;
}

pub fn stz_value_new_bool(b: i32) callconv(.c) ?*StzValue {
    const v = allocator.create(StzValue) catch return null;
    v.* = .{ .tag = .bool_val, .data = .{ .bool_val = b != 0 } };
    return v;
}

pub fn stz_value_new_int(n: i64) callconv(.c) ?*StzValue {
    const v = allocator.create(StzValue) catch return null;
    v.* = .{ .tag = .int_val, .data = .{ .int_val = n } };
    return v;
}

pub fn stz_value_new_float(f: f64) callconv(.c) ?*StzValue {
    const v = allocator.create(StzValue) catch return null;
    v.* = .{ .tag = .float_val, .data = .{ .float_val = f } };
    return v;
}

pub fn stz_value_new_string(ptr: [*]const u8, len: usize) callconv(.c) ?*StzValue {
    const v = allocator.create(StzValue) catch return null;
    if (len == 0) {
        v.* = .{ .tag = .string_val, .data = .{ .string_val = .{ .ptr = undefined, .len = 0, .owned = false } } };
        return v;
    }
    const buf = allocator.alloc(u8, len) catch {
        allocator.destroy(v);
        return null;
    };
    @memcpy(buf, ptr[0..len]);
    v.* = .{ .tag = .string_val, .data = .{ .string_val = .{ .ptr = buf.ptr, .len = buf.len, .owned = true } } };
    return v;
}

pub fn stz_value_new_list() callconv(.c) ?*StzValue {
    const v = allocator.create(StzValue) catch return null;
    v.* = .{ .tag = .list_val, .data = .{ .list_val = .{ .items = undefined, .len = 0, .cap = 0 } } };
    return v;
}

// ─── C ABI: Destructor ───

pub fn stz_value_free(v: ?*StzValue) callconv(.c) void {
    const val = v orelse return;
    val.deinit();
    allocator.destroy(val);
}

// ─── C ABI: Type Query ───

pub fn stz_value_type(v: ?*const StzValue) callconv(.c) i32 {
    const val = v orelse return -1;
    return @intCast(@intFromEnum(val.tag));
}

pub fn stz_value_is_null(v: ?*const StzValue) callconv(.c) i32 {
    const val = v orelse return 1;
    return if (val.tag == .null_val) 1 else 0;
}

// ─── C ABI: Getters ───

pub fn stz_value_get_bool(v: ?*const StzValue) callconv(.c) i32 {
    const val = v orelse return 0;
    if (val.tag != .bool_val) return 0;
    return if (val.data.bool_val) 1 else 0;
}

pub fn stz_value_get_int(v: ?*const StzValue) callconv(.c) i64 {
    const val = v orelse return 0;
    return switch (val.tag) {
        .int_val => val.data.int_val,
        .float_val => @intFromFloat(val.data.float_val),
        .bool_val => if (val.data.bool_val) @as(i64, 1) else 0,
        else => 0,
    };
}

pub fn stz_value_get_float(v: ?*const StzValue) callconv(.c) f64 {
    const val = v orelse return 0.0;
    return switch (val.tag) {
        .float_val => val.data.float_val,
        .int_val => @floatFromInt(val.data.int_val),
        else => 0.0,
    };
}

pub fn stz_value_get_string(v: ?*const StzValue) callconv(.c) [*]const u8 {
    const val = v orelse return "";
    if (val.tag != .string_val) return "";
    if (val.data.string_val.len == 0) return "";
    return val.data.string_val.ptr;
}

pub fn stz_value_get_string_len(v: ?*const StzValue) callconv(.c) usize {
    const val = v orelse return 0;
    if (val.tag != .string_val) return 0;
    return val.data.string_val.len;
}

// ─── C ABI: List Operations ───

pub fn stz_value_list_len(v: ?*const StzValue) callconv(.c) usize {
    const val = v orelse return 0;
    if (val.tag != .list_val) return 0;
    return val.data.list_val.len;
}

pub fn stz_value_list_get(v: ?*const StzValue, index: usize) callconv(.c) ?*const StzValue {
    const val = v orelse return null;
    if (val.tag != .list_val) return null;
    if (index >= val.data.list_val.len) return null;
    return val.data.list_val.items[index];
}

pub fn stz_value_list_append(v: ?*StzValue, item: ?*const StzValue) callconv(.c) i32 {
    const val = v orelse return -1;
    const src = item orelse return -1;
    if (val.tag != .list_val) return -1;

    var list = &val.data.list_val;
    if (list.len >= list.cap) {
        const new_cap = if (list.cap == 0) 8 else list.cap * 2;
        if (list.cap == 0) {
            const new_items = allocator.alloc(*StzValue, new_cap) catch return -1;
            list.items = new_items.ptr;
            list.cap = new_cap;
        } else {
            const old_slice = list.items[0..list.cap];
            const new_items = allocator.realloc(old_slice, new_cap) catch return -1;
            list.items = new_items.ptr;
            list.cap = new_cap;
        }
    }

    const cloned = src.clone() catch return -1;
    list.items[list.len] = cloned;
    list.len += 1;
    return 0;
}

pub fn stz_value_list_set(v: ?*StzValue, index: usize, item: ?*const StzValue) callconv(.c) i32 {
    const val = v orelse return -1;
    const src = item orelse return -1;
    if (val.tag != .list_val) return -1;
    if (index >= val.data.list_val.len) return -1;

    const cloned = src.clone() catch return -1;
    val.data.list_val.items[index].deinit();
    allocator.destroy(val.data.list_val.items[index]);
    val.data.list_val.items[index] = cloned;
    return 0;
}

pub fn stz_value_list_remove(v: ?*StzValue, index: usize) callconv(.c) i32 {
    const val = v orelse return -1;
    if (val.tag != .list_val) return -1;
    var list = &val.data.list_val;
    if (index >= list.len) return -1;

    list.items[index].deinit();
    allocator.destroy(list.items[index]);

    // Shift remaining items
    if (index + 1 < list.len) {
        const dest = list.items[index .. list.len - 1];
        const src = list.items[index + 1 .. list.len];
        @memcpy(dest, src);
    }
    list.len -= 1;
    return 0;
}

pub fn stz_value_list_insert(v: ?*StzValue, index: usize, item: ?*const StzValue) callconv(.c) i32 {
    const val = v orelse return -1;
    const src = item orelse return -1;
    if (val.tag != .list_val) return -1;
    var list = &val.data.list_val;
    if (index > list.len) return -1;

    // Grow if needed
    if (list.len >= list.cap) {
        const new_cap = if (list.cap == 0) 8 else list.cap * 2;
        if (list.cap == 0) {
            const new_items = allocator.alloc(*StzValue, new_cap) catch return -1;
            list.items = new_items.ptr;
            list.cap = new_cap;
        } else {
            const old_slice = list.items[0..list.cap];
            const new_items = allocator.realloc(old_slice, new_cap) catch return -1;
            list.items = new_items.ptr;
            list.cap = new_cap;
        }
    }

    const cloned = src.clone() catch return -1;

    // Shift items right
    if (index < list.len) {
        var i = list.len;
        while (i > index) : (i -= 1) {
            list.items[i] = list.items[i - 1];
        }
    }
    list.items[index] = cloned;
    list.len += 1;
    return 0;
}

// ─── C ABI: Comparison ───

pub fn stz_value_equals(a: ?*const StzValue, b: ?*const StzValue) callconv(.c) i32 {
    const va = a orelse return if (b == null) 1 else 0;
    const vb = b orelse return 0;
    return if (va.eql(vb)) 1 else 0;
}

pub fn stz_value_compare(a: ?*const StzValue, b: ?*const StzValue) callconv(.c) i32 {
    const va = a orelse {
        if (b == null) return 0;
        return -1;
    };
    const vb = b orelse return 1;
    return va.compare(vb);
}

// ─── C ABI: Clone ───

pub fn stz_value_clone(v: ?*const StzValue) callconv(.c) ?*StzValue {
    const val = v orelse return null;
    return val.clone() catch null;
}

// ─── C ABI: String Representation ───

pub fn stz_value_to_string(v: ?*const StzValue, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const val = v orelse return 0;
    if (buf_len == 0) return 0;
    return val.toString(buf[0..buf_len]);
}

pub fn stz_value_type_name(v: ?*const StzValue) callconv(.c) [*]const u8 {
    const val = v orelse return "unknown";
    return switch (val.tag) {
        .null_val => "null",
        .bool_val => "bool",
        .int_val => "int",
        .float_val => "float",
        .string_val => "string",
        .list_val => "list",
    };
}

pub fn stz_value_type_name_len(v: ?*const StzValue) callconv(.c) usize {
    const val = v orelse return 7; // "unknown"
    return switch (val.tag) {
        .null_val => 4,
        .bool_val => 4,
        .int_val => 3,
        .float_val => 5,
        .string_val => 6,
        .list_val => 4,
    };
}

// ─── C ABI: List Search ───

pub fn stz_value_list_find(v: ?*const StzValue, item: ?*const StzValue) callconv(.c) i64 {
    const val = v orelse return -1;
    const needle = item orelse return -1;
    if (val.tag != .list_val) return -1;
    const list = val.data.list_val;
    for (0..list.len) |i| {
        if (list.items[i].eql(needle)) return @intCast(i);
    }
    return -1;
}

pub fn stz_value_list_contains(v: ?*const StzValue, item: ?*const StzValue) callconv(.c) i32 {
    return if (stz_value_list_find(v, item) >= 0) 1 else 0;
}

// ─── C ABI: List Bulk Operations ───

pub fn stz_value_list_reverse(v: ?*StzValue) callconv(.c) i32 {
    const val = v orelse return -1;
    if (val.tag != .list_val) return -1;
    var list = &val.data.list_val;
    if (list.len <= 1) return 0;

    var lo: usize = 0;
    var hi: usize = list.len - 1;
    while (lo < hi) {
        const tmp = list.items[lo];
        list.items[lo] = list.items[hi];
        list.items[hi] = tmp;
        lo += 1;
        hi -= 1;
    }
    return 0;
}

pub fn stz_value_list_sort(v: ?*StzValue) callconv(.c) i32 {
    const val = v orelse return -1;
    if (val.tag != .list_val) return -1;
    var list = &val.data.list_val;
    if (list.len <= 1) return 0;

    const items_slice = list.items[0..list.len];
    std.mem.sort(*StzValue, items_slice, {}, struct {
        fn lessThan(_: void, a: *StzValue, b: *StzValue) bool {
            return a.compare(b) < 0;
        }
    }.lessThan);
    return 0;
}

pub fn stz_value_list_clear(v: ?*StzValue) callconv(.c) i32 {
    const val = v orelse return -1;
    if (val.tag != .list_val) return -1;
    var list = &val.data.list_val;

    for (0..list.len) |i| {
        list.items[i].deinit();
        allocator.destroy(list.items[i]);
    }
    list.len = 0;
    return 0;
}

// ─── Tests ───

test "value null" {
    const v = stz_value_new_null() orelse return error.AllocFailed;
    defer stz_value_free(v);
    try std.testing.expectEqual(@as(i32, 0), stz_value_type(v));
    try std.testing.expectEqual(@as(i32, 1), stz_value_is_null(v));
}

test "value bool" {
    const t = stz_value_new_bool(1) orelse return error.AllocFailed;
    defer stz_value_free(t);
    const f = stz_value_new_bool(0) orelse return error.AllocFailed;
    defer stz_value_free(f);
    try std.testing.expectEqual(@as(i32, 1), stz_value_get_bool(t));
    try std.testing.expectEqual(@as(i32, 0), stz_value_get_bool(f));
    try std.testing.expectEqual(@as(i32, 0), stz_value_equals(t, f));
}

test "value int" {
    const v = stz_value_new_int(42) orelse return error.AllocFailed;
    defer stz_value_free(v);
    try std.testing.expectEqual(@as(i64, 42), stz_value_get_int(v));
    try std.testing.expectEqual(@as(i32, 2), stz_value_type(v));
}

test "value float" {
    const v = stz_value_new_float(3.14) orelse return error.AllocFailed;
    defer stz_value_free(v);
    try std.testing.expectApproxEqAbs(@as(f64, 3.14), stz_value_get_float(v), 0.001);
}

test "value string" {
    const text = "Hello, World!";
    const v = stz_value_new_string(text.ptr, text.len) orelse return error.AllocFailed;
    defer stz_value_free(v);
    try std.testing.expectEqual(@as(usize, 13), stz_value_get_string_len(v));
    const got = stz_value_get_string(v);
    try std.testing.expect(std.mem.eql(u8, got[0..13], "Hello, World!"));
}

test "value string unicode" {
    const text = "Ni\xc3\xa9ger";
    const v = stz_value_new_string(text.ptr, text.len) orelse return error.AllocFailed;
    defer stz_value_free(v);
    try std.testing.expectEqual(@as(usize, 7), stz_value_get_string_len(v));
}

test "value int-float cross-get" {
    const vi = stz_value_new_int(7) orelse return error.AllocFailed;
    defer stz_value_free(vi);
    try std.testing.expectApproxEqAbs(@as(f64, 7.0), stz_value_get_float(vi), 0.001);

    const vf = stz_value_new_float(9.0) orelse return error.AllocFailed;
    defer stz_value_free(vf);
    try std.testing.expectEqual(@as(i64, 9), stz_value_get_int(vf));
}

test "value equals same type" {
    const a = stz_value_new_int(10) orelse return error.AllocFailed;
    defer stz_value_free(a);
    const b = stz_value_new_int(10) orelse return error.AllocFailed;
    defer stz_value_free(b);
    const c = stz_value_new_int(20) orelse return error.AllocFailed;
    defer stz_value_free(c);
    try std.testing.expectEqual(@as(i32, 1), stz_value_equals(a, b));
    try std.testing.expectEqual(@as(i32, 0), stz_value_equals(a, c));
}

test "value equals cross type" {
    const a = stz_value_new_int(5) orelse return error.AllocFailed;
    defer stz_value_free(a);
    const b = stz_value_new_float(5.0) orelse return error.AllocFailed;
    defer stz_value_free(b);
    try std.testing.expectEqual(@as(i32, 0), stz_value_equals(a, b));
}

test "value compare int" {
    const a = stz_value_new_int(3) orelse return error.AllocFailed;
    defer stz_value_free(a);
    const b = stz_value_new_int(7) orelse return error.AllocFailed;
    defer stz_value_free(b);
    try std.testing.expect(stz_value_compare(a, b) < 0);
    try std.testing.expect(stz_value_compare(b, a) > 0);
    try std.testing.expectEqual(@as(i32, 0), stz_value_compare(a, a));
}

test "value compare string" {
    const s1 = "apple";
    const s2 = "banana";
    const a = stz_value_new_string(s1.ptr, s1.len) orelse return error.AllocFailed;
    defer stz_value_free(a);
    const b = stz_value_new_string(s2.ptr, s2.len) orelse return error.AllocFailed;
    defer stz_value_free(b);
    try std.testing.expect(stz_value_compare(a, b) < 0);
    try std.testing.expect(stz_value_compare(b, a) > 0);
}

test "value clone" {
    const orig = stz_value_new_string("test", 4) orelse return error.AllocFailed;
    defer stz_value_free(orig);
    const copy = stz_value_clone(orig) orelse return error.AllocFailed;
    defer stz_value_free(copy);
    try std.testing.expectEqual(@as(i32, 1), stz_value_equals(orig, copy));
    try std.testing.expectEqual(@as(usize, 4), stz_value_get_string_len(copy));
}

test "value list basic" {
    const list = stz_value_new_list() orelse return error.AllocFailed;
    defer stz_value_free(list);

    const v1 = stz_value_new_int(10) orelse return error.AllocFailed;
    defer stz_value_free(v1);
    const v2 = stz_value_new_string("hello", 5) orelse return error.AllocFailed;
    defer stz_value_free(v2);

    try std.testing.expectEqual(@as(i32, 0), stz_value_list_append(list, v1));
    try std.testing.expectEqual(@as(i32, 0), stz_value_list_append(list, v2));
    try std.testing.expectEqual(@as(usize, 2), stz_value_list_len(list));

    const got1 = stz_value_list_get(list, 0) orelse return error.NotFound;
    try std.testing.expectEqual(@as(i64, 10), stz_value_get_int(got1));

    const got2 = stz_value_list_get(list, 1) orelse return error.NotFound;
    try std.testing.expectEqual(@as(usize, 5), stz_value_get_string_len(got2));
}

test "value list insert and remove" {
    const list = stz_value_new_list() orelse return error.AllocFailed;
    defer stz_value_free(list);

    const v1 = stz_value_new_int(1) orelse return error.AllocFailed;
    defer stz_value_free(v1);
    const v2 = stz_value_new_int(3) orelse return error.AllocFailed;
    defer stz_value_free(v2);
    const v3 = stz_value_new_int(2) orelse return error.AllocFailed;
    defer stz_value_free(v3);

    _ = stz_value_list_append(list, v1);
    _ = stz_value_list_append(list, v2);
    // Insert 2 between 1 and 3
    try std.testing.expectEqual(@as(i32, 0), stz_value_list_insert(list, 1, v3));
    try std.testing.expectEqual(@as(usize, 3), stz_value_list_len(list));
    const mid = stz_value_list_get(list, 1) orelse return error.NotFound;
    try std.testing.expectEqual(@as(i64, 2), stz_value_get_int(mid));

    // Remove middle
    try std.testing.expectEqual(@as(i32, 0), stz_value_list_remove(list, 1));
    try std.testing.expectEqual(@as(usize, 2), stz_value_list_len(list));
    const after_remove = stz_value_list_get(list, 1) orelse return error.NotFound;
    try std.testing.expectEqual(@as(i64, 3), stz_value_get_int(after_remove));
}

test "value list find and contains" {
    const list = stz_value_new_list() orelse return error.AllocFailed;
    defer stz_value_free(list);

    const v1 = stz_value_new_string("alpha", 5) orelse return error.AllocFailed;
    defer stz_value_free(v1);
    const v2 = stz_value_new_string("beta", 4) orelse return error.AllocFailed;
    defer stz_value_free(v2);
    const v3 = stz_value_new_string("gamma", 5) orelse return error.AllocFailed;
    defer stz_value_free(v3);

    _ = stz_value_list_append(list, v1);
    _ = stz_value_list_append(list, v2);

    try std.testing.expectEqual(@as(i64, 0), stz_value_list_find(list, v1));
    try std.testing.expectEqual(@as(i64, 1), stz_value_list_find(list, v2));
    try std.testing.expectEqual(@as(i64, -1), stz_value_list_find(list, v3));
    try std.testing.expectEqual(@as(i32, 1), stz_value_list_contains(list, v2));
    try std.testing.expectEqual(@as(i32, 0), stz_value_list_contains(list, v3));
}

test "value list sort" {
    const list = stz_value_new_list() orelse return error.AllocFailed;
    defer stz_value_free(list);

    const vals = [_]i64{ 5, 3, 8, 1, 4 };
    for (vals) |n| {
        const v = stz_value_new_int(n) orelse return error.AllocFailed;
        defer stz_value_free(v);
        _ = stz_value_list_append(list, v);
    }

    try std.testing.expectEqual(@as(i32, 0), stz_value_list_sort(list));

    const expected = [_]i64{ 1, 3, 4, 5, 8 };
    for (expected, 0..) |exp, i| {
        const item = stz_value_list_get(list, i) orelse return error.NotFound;
        try std.testing.expectEqual(exp, stz_value_get_int(item));
    }
}

test "value list reverse" {
    const list = stz_value_new_list() orelse return error.AllocFailed;
    defer stz_value_free(list);

    for (1..4) |n| {
        const v = stz_value_new_int(@intCast(n)) orelse return error.AllocFailed;
        defer stz_value_free(v);
        _ = stz_value_list_append(list, v);
    }

    try std.testing.expectEqual(@as(i32, 0), stz_value_list_reverse(list));

    const item0 = stz_value_list_get(list, 0) orelse return error.NotFound;
    try std.testing.expectEqual(@as(i64, 3), stz_value_get_int(item0));
    const item2 = stz_value_list_get(list, 2) orelse return error.NotFound;
    try std.testing.expectEqual(@as(i64, 1), stz_value_get_int(item2));
}

test "value list clone deep" {
    const list = stz_value_new_list() orelse return error.AllocFailed;
    defer stz_value_free(list);

    const v1 = stz_value_new_int(42) orelse return error.AllocFailed;
    defer stz_value_free(v1);
    _ = stz_value_list_append(list, v1);

    const copy = stz_value_clone(list) orelse return error.AllocFailed;
    defer stz_value_free(copy);

    try std.testing.expectEqual(@as(i32, 1), stz_value_equals(list, copy));
    try std.testing.expectEqual(@as(usize, 1), stz_value_list_len(copy));

    // Modify original, copy should be unaffected
    _ = stz_value_list_clear(list);
    try std.testing.expectEqual(@as(usize, 0), stz_value_list_len(list));
    try std.testing.expectEqual(@as(usize, 1), stz_value_list_len(copy));
}

test "value to_string" {
    var buf: [256]u8 = undefined;

    const vi = stz_value_new_int(42) orelse return error.AllocFailed;
    defer stz_value_free(vi);
    const len_i = stz_value_to_string(vi, &buf, 256);
    try std.testing.expect(std.mem.eql(u8, buf[0..len_i], "42"));

    const vs = stz_value_new_string("hello", 5) orelse return error.AllocFailed;
    defer stz_value_free(vs);
    const len_s = stz_value_to_string(vs, &buf, 256);
    try std.testing.expect(std.mem.eql(u8, buf[0..len_s], "hello"));

    const vn = stz_value_new_null() orelse return error.AllocFailed;
    defer stz_value_free(vn);
    const len_n = stz_value_to_string(vn, &buf, 256);
    try std.testing.expect(std.mem.eql(u8, buf[0..len_n], "NULL"));
}

test "value type_name" {
    const vi = stz_value_new_int(0) orelse return error.AllocFailed;
    defer stz_value_free(vi);
    const name = stz_value_type_name(vi);
    const name_len = stz_value_type_name_len(vi);
    try std.testing.expect(std.mem.eql(u8, name[0..name_len], "int"));
}

test "value null handles" {
    try std.testing.expectEqual(@as(i32, -1), stz_value_type(null));
    try std.testing.expectEqual(@as(i32, 1), stz_value_is_null(null));
    try std.testing.expectEqual(@as(i64, 0), stz_value_get_int(null));
    try std.testing.expectEqual(@as(f64, 0.0), stz_value_get_float(null));
    try std.testing.expectEqual(@as(usize, 0), stz_value_get_string_len(null));
    try std.testing.expectEqual(@as(usize, 0), stz_value_list_len(null));
    stz_value_free(null); // should not crash
}

test "value list set" {
    const list = stz_value_new_list() orelse return error.AllocFailed;
    defer stz_value_free(list);

    const v1 = stz_value_new_int(10) orelse return error.AllocFailed;
    defer stz_value_free(v1);
    _ = stz_value_list_append(list, v1);

    const v2 = stz_value_new_int(99) orelse return error.AllocFailed;
    defer stz_value_free(v2);
    try std.testing.expectEqual(@as(i32, 0), stz_value_list_set(list, 0, v2));

    const got = stz_value_list_get(list, 0) orelse return error.NotFound;
    try std.testing.expectEqual(@as(i64, 99), stz_value_get_int(got));
}

test "value list nested" {
    const outer = stz_value_new_list() orelse return error.AllocFailed;
    defer stz_value_free(outer);

    const inner = stz_value_new_list() orelse return error.AllocFailed;
    defer stz_value_free(inner);
    const v = stz_value_new_int(7) orelse return error.AllocFailed;
    defer stz_value_free(v);
    _ = stz_value_list_append(inner, v);

    _ = stz_value_list_append(outer, inner);
    try std.testing.expectEqual(@as(usize, 1), stz_value_list_len(outer));

    const got_inner = stz_value_list_get(outer, 0) orelse return error.NotFound;
    try std.testing.expectEqual(@as(i32, 5), stz_value_type(got_inner));
    try std.testing.expectEqual(@as(usize, 1), stz_value_list_len(got_inner));
}

test "value empty string" {
    const v = stz_value_new_string("", 0) orelse return error.AllocFailed;
    defer stz_value_free(v);
    try std.testing.expectEqual(@as(usize, 0), stz_value_get_string_len(v));
    try std.testing.expectEqual(@as(i32, 4), stz_value_type(v));
}

test "value list heterogeneous sort" {
    const list = stz_value_new_list() orelse return error.AllocFailed;
    defer stz_value_free(list);

    // Mix types: string, int, null, bool
    const vs = stz_value_new_string("z", 1) orelse return error.AllocFailed;
    defer stz_value_free(vs);
    const vi = stz_value_new_int(5) orelse return error.AllocFailed;
    defer stz_value_free(vi);
    const vn = stz_value_new_null() orelse return error.AllocFailed;
    defer stz_value_free(vn);
    const vb = stz_value_new_bool(1) orelse return error.AllocFailed;
    defer stz_value_free(vb);

    _ = stz_value_list_append(list, vs);
    _ = stz_value_list_append(list, vi);
    _ = stz_value_list_append(list, vn);
    _ = stz_value_list_append(list, vb);

    _ = stz_value_list_sort(list);

    // Order: null(0) < bool(1) < int(2) < string(4)
    const t0 = stz_value_list_get(list, 0) orelse return error.NotFound;
    try std.testing.expectEqual(@as(i32, 0), stz_value_type(t0));
    const t1 = stz_value_list_get(list, 1) orelse return error.NotFound;
    try std.testing.expectEqual(@as(i32, 1), stz_value_type(t1));
    const t2 = stz_value_list_get(list, 2) orelse return error.NotFound;
    try std.testing.expectEqual(@as(i32, 2), stz_value_type(t2));
    const t3 = stz_value_list_get(list, 3) orelse return error.NotFound;
    try std.testing.expectEqual(@as(i32, 4), stz_value_type(t3));
}
