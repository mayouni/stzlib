// Softanza Engine -- stz_yielder: Yielder (map/filter/reduce)
//
// The Yielder metaphor: apply a transformation to each item and yield
// results into a new collection. Works on StzList handles with built-in
// transform, filter, and reduce operations.
//
// C ABI: stz_yielder_* prefix. All handles are opaque pointers.

const std = @import("std");
const allocator = std.heap.c_allocator;
const value_mod = @import("value.zig");
const StzValue = value_mod.StzValue;
const ValueType = value_mod.ValueType;
const list_mod = @import("list.zig");
const StzList = list_mod.StzList;

// ─── Transform Operations ───

pub const TransformOp = enum(u8) {
    type_name = 0, // yields "null"/"bool"/"int"/"float"/"string"/"list"
    abs = 1, // numeric absolute value
    negate = 2, // numeric negation
    double_val = 3, // multiply by 2
    square = 4, // x * x
    to_string = 5, // convert to string representation
    to_int = 6, // convert to integer
    to_float = 7, // convert to float
    str_len = 8, // string byte length (0 for non-strings)
    str_upper = 9, // uppercase (passthrough for non-strings)
    str_lower = 10, // lowercase (passthrough for non-strings)
    str_trim = 11, // trim whitespace (passthrough for non-strings)
    str_reverse = 12, // reverse string (passthrough for non-strings)
    increment = 13, // add 1 to numbers
    decrement = 14, // subtract 1 from numbers
    is_even = 15, // yields bool: true if even int
    sign = 16, // yields -1, 0, or 1
};

// ─── Filter Operations ───

pub const FilterOp = enum(u8) {
    is_string = 0,
    is_number = 1, // int or float
    is_int = 2,
    is_float = 3,
    is_bool = 4,
    is_null = 5,
    is_list = 6,
    is_positive = 7, // > 0
    is_negative = 8, // < 0
    is_zero = 9, // == 0
    is_nonzero = 10, // != 0
    is_empty = 11, // empty string or null
    is_notempty = 12, // non-empty string, or any non-null/non-string
    is_even = 13, // even integer
    is_odd = 14, // odd integer
    is_true = 15, // bool true, or nonzero number
    is_false = 16, // bool false, zero, or null
};

// ─── Reduce Operations ───

pub const ReduceOp = enum(u8) {
    sum = 0, // sum all numeric values
    product = 1, // product of all numeric values
    min_val = 2, // minimum numeric value
    max_val = 3, // maximum numeric value
    count = 4, // count of items
    count_strings = 5, // count of string items
    count_numbers = 6, // count of numeric items
    concat = 7, // concatenate all as strings
    any_true = 8, // logical OR
    all_true = 9, // logical AND
};

// ─── Transform Implementation ───

fn applyTransform(item: *const StzValue, op: TransformOp) !*StzValue {
    const result = try allocator.create(StzValue);
    errdefer allocator.destroy(result);

    switch (op) {
        .type_name => {
            const name: []const u8 = switch (item.tag) {
                .null_val => "null",
                .bool_val => "bool",
                .int_val => "int",
                .float_val => "float",
                .string_val => "string",
                .list_val => "list",
            };
            const buf = try allocator.alloc(u8, name.len);
            @memcpy(buf, name);
            result.* = .{ .tag = .string_val, .data = .{ .string_val = .{
                .ptr = buf.ptr,
                .len = buf.len,
                .owned = true,
            } } };
        },
        .abs => {
            switch (item.tag) {
                .int_val => result.* = .{ .tag = .int_val, .data = .{ .int_val = @as(i64, @intCast(if (item.data.int_val < 0) -item.data.int_val else item.data.int_val)) } },
                .float_val => result.* = .{ .tag = .float_val, .data = .{ .float_val = @abs(item.data.float_val) } },
                else => {
                    const cloned = try item.clone();
                    allocator.destroy(result);
                    return cloned;
                },
            }
        },
        .negate => {
            switch (item.tag) {
                .int_val => result.* = .{ .tag = .int_val, .data = .{ .int_val = -item.data.int_val } },
                .float_val => result.* = .{ .tag = .float_val, .data = .{ .float_val = -item.data.float_val } },
                else => {
                    const cloned = try item.clone();
                    allocator.destroy(result);
                    return cloned;
                },
            }
        },
        .double_val => {
            switch (item.tag) {
                .int_val => result.* = .{ .tag = .int_val, .data = .{ .int_val = item.data.int_val * 2 } },
                .float_val => result.* = .{ .tag = .float_val, .data = .{ .float_val = item.data.float_val * 2.0 } },
                else => {
                    const cloned = try item.clone();
                    allocator.destroy(result);
                    return cloned;
                },
            }
        },
        .square => {
            switch (item.tag) {
                .int_val => result.* = .{ .tag = .int_val, .data = .{ .int_val = item.data.int_val * item.data.int_val } },
                .float_val => result.* = .{ .tag = .float_val, .data = .{ .float_val = item.data.float_val * item.data.float_val } },
                else => {
                    const cloned = try item.clone();
                    allocator.destroy(result);
                    return cloned;
                },
            }
        },
        .to_string => {
            var buf: [64]u8 = undefined;
            const s: []const u8 = switch (item.tag) {
                .null_val => "null",
                .bool_val => if (item.data.bool_val) "true" else "false",
                .int_val => blk: {
                    const written = std.fmt.bufPrint(&buf, "{d}", .{item.data.int_val}) catch "?";
                    break :blk written;
                },
                .float_val => blk: {
                    const written = std.fmt.bufPrint(&buf, "{d}", .{item.data.float_val}) catch "?";
                    break :blk written;
                },
                .string_val => {
                    const cloned = try item.clone();
                    allocator.destroy(result);
                    return cloned;
                },
                .list_val => "[list]",
            };
            const owned = try allocator.alloc(u8, s.len);
            @memcpy(owned, s);
            result.* = .{ .tag = .string_val, .data = .{ .string_val = .{
                .ptr = owned.ptr,
                .len = owned.len,
                .owned = true,
            } } };
        },
        .to_int => {
            switch (item.tag) {
                .int_val => result.* = .{ .tag = .int_val, .data = .{ .int_val = item.data.int_val } },
                .float_val => result.* = .{ .tag = .int_val, .data = .{ .int_val = @intFromFloat(item.data.float_val) } },
                .bool_val => result.* = .{ .tag = .int_val, .data = .{ .int_val = if (item.data.bool_val) 1 else 0 } },
                else => result.* = .{ .tag = .int_val, .data = .{ .int_val = 0 } },
            }
        },
        .to_float => {
            switch (item.tag) {
                .float_val => result.* = .{ .tag = .float_val, .data = .{ .float_val = item.data.float_val } },
                .int_val => result.* = .{ .tag = .float_val, .data = .{ .float_val = @floatFromInt(item.data.int_val) } },
                .bool_val => result.* = .{ .tag = .float_val, .data = .{ .float_val = if (item.data.bool_val) 1.0 else 0.0 } },
                else => result.* = .{ .tag = .float_val, .data = .{ .float_val = 0.0 } },
            }
        },
        .str_len => {
            switch (item.tag) {
                .string_val => result.* = .{ .tag = .int_val, .data = .{ .int_val = @intCast(item.data.string_val.len) } },
                else => result.* = .{ .tag = .int_val, .data = .{ .int_val = 0 } },
            }
        },
        .str_upper, .str_lower, .str_trim, .str_reverse => {
            if (item.tag != .string_val) {
                const cloned = try item.clone();
                allocator.destroy(result);
                return cloned;
            }
            const src = item.data.string_val.ptr[0..item.data.string_val.len];
            const transformed = switch (op) {
                .str_upper => blk: {
                    const buf = try allocator.alloc(u8, src.len);
                    for (src, 0..) |c, i| buf[i] = std.ascii.toUpper(c);
                    break :blk buf;
                },
                .str_lower => blk: {
                    const buf = try allocator.alloc(u8, src.len);
                    for (src, 0..) |c, i| buf[i] = std.ascii.toLower(c);
                    break :blk buf;
                },
                .str_trim => blk: {
                    const trimmed = std.mem.trim(u8, src, &std.ascii.whitespace);
                    const buf = try allocator.alloc(u8, trimmed.len);
                    @memcpy(buf, trimmed);
                    break :blk buf;
                },
                .str_reverse => blk: {
                    const buf = try allocator.alloc(u8, src.len);
                    for (src, 0..) |c, i| buf[src.len - 1 - i] = c;
                    break :blk buf;
                },
                else => unreachable,
            };
            result.* = .{ .tag = .string_val, .data = .{ .string_val = .{
                .ptr = transformed.ptr,
                .len = transformed.len,
                .owned = true,
            } } };
        },
        .increment => {
            switch (item.tag) {
                .int_val => result.* = .{ .tag = .int_val, .data = .{ .int_val = item.data.int_val + 1 } },
                .float_val => result.* = .{ .tag = .float_val, .data = .{ .float_val = item.data.float_val + 1.0 } },
                else => {
                    const cloned = try item.clone();
                    allocator.destroy(result);
                    return cloned;
                },
            }
        },
        .decrement => {
            switch (item.tag) {
                .int_val => result.* = .{ .tag = .int_val, .data = .{ .int_val = item.data.int_val - 1 } },
                .float_val => result.* = .{ .tag = .float_val, .data = .{ .float_val = item.data.float_val - 1.0 } },
                else => {
                    const cloned = try item.clone();
                    allocator.destroy(result);
                    return cloned;
                },
            }
        },
        .is_even => {
            switch (item.tag) {
                .int_val => result.* = .{ .tag = .bool_val, .data = .{ .bool_val = @rem(item.data.int_val, 2) == 0 } },
                else => result.* = .{ .tag = .bool_val, .data = .{ .bool_val = false } },
            }
        },
        .sign => {
            switch (item.tag) {
                .int_val => result.* = .{ .tag = .int_val, .data = .{ .int_val = if (item.data.int_val > 0) @as(i64, 1) else if (item.data.int_val < 0) @as(i64, -1) else 0 } },
                .float_val => result.* = .{ .tag = .int_val, .data = .{ .int_val = if (item.data.float_val > 0) @as(i64, 1) else if (item.data.float_val < 0) @as(i64, -1) else 0 } },
                else => result.* = .{ .tag = .int_val, .data = .{ .int_val = 0 } },
            }
        },
    }
    return result;
}

// ─── Filter Implementation ───

fn applyFilter(item: *const StzValue, op: FilterOp) bool {
    return switch (op) {
        .is_string => item.tag == .string_val,
        .is_number => item.tag == .int_val or item.tag == .float_val,
        .is_int => item.tag == .int_val,
        .is_float => item.tag == .float_val,
        .is_bool => item.tag == .bool_val,
        .is_null => item.tag == .null_val,
        .is_list => item.tag == .list_val,
        .is_positive => switch (item.tag) {
            .int_val => item.data.int_val > 0,
            .float_val => item.data.float_val > 0,
            else => false,
        },
        .is_negative => switch (item.tag) {
            .int_val => item.data.int_val < 0,
            .float_val => item.data.float_val < 0,
            else => false,
        },
        .is_zero => switch (item.tag) {
            .int_val => item.data.int_val == 0,
            .float_val => item.data.float_val == 0.0,
            else => false,
        },
        .is_nonzero => switch (item.tag) {
            .int_val => item.data.int_val != 0,
            .float_val => item.data.float_val != 0.0,
            .bool_val => item.data.bool_val,
            else => true,
        },
        .is_empty => switch (item.tag) {
            .string_val => item.data.string_val.len == 0,
            .null_val => true,
            .list_val => item.data.list_val.len == 0,
            else => false,
        },
        .is_notempty => switch (item.tag) {
            .string_val => item.data.string_val.len > 0,
            .null_val => false,
            .list_val => item.data.list_val.len > 0,
            else => true,
        },
        .is_even => switch (item.tag) {
            .int_val => @rem(item.data.int_val, 2) == 0,
            else => false,
        },
        .is_odd => switch (item.tag) {
            .int_val => @rem(item.data.int_val, 2) != 0,
            else => false,
        },
        .is_true => switch (item.tag) {
            .bool_val => item.data.bool_val,
            .int_val => item.data.int_val != 0,
            .float_val => item.data.float_val != 0.0,
            else => false,
        },
        .is_false => switch (item.tag) {
            .bool_val => !item.data.bool_val,
            .int_val => item.data.int_val == 0,
            .float_val => item.data.float_val == 0.0,
            .null_val => true,
            else => false,
        },
    };
}

// ─── Numeric helper ───

fn toFloat(item: *const StzValue) ?f64 {
    return switch (item.tag) {
        .int_val => @floatFromInt(item.data.int_val),
        .float_val => item.data.float_val,
        .bool_val => if (item.data.bool_val) @as(f64, 1.0) else 0.0,
        else => null,
    };
}

// ─── C ABI Functions ───

/// Map: apply transform to each item, return new list
pub export fn stz_yielder_map(list_handle: *anyopaque, op: u8) ?*anyopaque {
    const list: *StzList = @ptrCast(@alignCast(list_handle));
    const transform: TransformOp = @enumFromInt(op);

    const result = StzList.init() catch return null;

    for (list.items.items) |item| {
        const transformed = applyTransform(item, transform) catch {
            result.deinit();
            return null;
        };
        result.items.append(allocator, transformed) catch {
            transformed.deinit();
            allocator.destroy(transformed);
            result.deinit();
            return null;
        };
    }

    return @ptrCast(result);
}

/// Filter: keep items matching predicate, return new list
pub export fn stz_yielder_filter(list_handle: *anyopaque, op: u8) ?*anyopaque {
    const list: *StzList = @ptrCast(@alignCast(list_handle));
    const predicate: FilterOp = @enumFromInt(op);

    const result = StzList.init() catch return null;

    for (list.items.items) |item| {
        if (applyFilter(item, predicate)) {
            result.appendClone(item) catch {
                result.deinit();
                return null;
            };
        }
    }

    return @ptrCast(result);
}

/// Reduce: fold all items with a reduce operation, return single value
/// Returns a float for numeric reductions, int for counts.
pub export fn stz_yielder_reduce(list_handle: *anyopaque, op: u8) f64 {
    const list: *StzList = @ptrCast(@alignCast(list_handle));
    const reduce_op: ReduceOp = @enumFromInt(op);

    const items = list.items.items;
    if (items.len == 0) return 0;

    switch (reduce_op) {
        .sum => {
            var acc: f64 = 0;
            for (items) |item| {
                if (toFloat(item)) |v| acc += v;
            }
            return acc;
        },
        .product => {
            var acc: f64 = 1;
            for (items) |item| {
                if (toFloat(item)) |v| acc *= v;
            }
            return acc;
        },
        .min_val => {
            var min: f64 = std.math.inf(f64);
            for (items) |item| {
                if (toFloat(item)) |v| {
                    if (v < min) min = v;
                }
            }
            return if (min == std.math.inf(f64)) 0 else min;
        },
        .max_val => {
            var max: f64 = -std.math.inf(f64);
            for (items) |item| {
                if (toFloat(item)) |v| {
                    if (v > max) max = v;
                }
            }
            return if (max == -std.math.inf(f64)) 0 else max;
        },
        .count => return @floatFromInt(items.len),
        .count_strings => {
            var n: usize = 0;
            for (items) |item| {
                if (item.tag == .string_val) n += 1;
            }
            return @floatFromInt(n);
        },
        .count_numbers => {
            var n: usize = 0;
            for (items) |item| {
                if (item.tag == .int_val or item.tag == .float_val) n += 1;
            }
            return @floatFromInt(n);
        },
        .concat => return 0, // concat returns string via separate function
        .any_true => {
            for (items) |item| {
                if (applyFilter(item, .is_true)) return 1;
            }
            return 0;
        },
        .all_true => {
            for (items) |item| {
                if (!applyFilter(item, .is_true)) return 0;
            }
            return 1;
        },
    }
}

/// Reduce to string: concatenate all items as strings
/// Returns a new StzValue string handle.
pub export fn stz_yielder_reduce_concat(list_handle: *anyopaque, sep: [*]const u8, sep_len: u32) ?*anyopaque {
    const list: *StzList = @ptrCast(@alignCast(list_handle));
    const separator = sep[0..sep_len];
    const items = list.items.items;

    // Calculate total length
    var total_len: usize = 0;
    var buf: [64]u8 = undefined;
    var parts = std.ArrayList([]const u8){};

    defer {
        for (parts.items) |p| allocator.free(p);
        parts.deinit(allocator);
    }

    for (items, 0..) |item, i| {
        const s: []const u8 = switch (item.tag) {
            .string_val => item.data.string_val.ptr[0..item.data.string_val.len],
            .int_val => std.fmt.bufPrint(&buf, "{d}", .{item.data.int_val}) catch "?",
            .float_val => std.fmt.bufPrint(&buf, "{d}", .{item.data.float_val}) catch "?",
            .bool_val => if (item.data.bool_val) "true" else "false",
            .null_val => "null",
            .list_val => "[list]",
        };
        const copy = allocator.alloc(u8, s.len) catch return null;
        @memcpy(copy, s);
        parts.append(allocator, copy) catch {
            allocator.free(copy);
            return null;
        };
        total_len += s.len;
        if (i < items.len - 1) total_len += separator.len;
    }

    // Build result
    const result_buf = allocator.alloc(u8, total_len) catch return null;
    var pos: usize = 0;
    for (parts.items, 0..) |p, i| {
        @memcpy(result_buf[pos .. pos + p.len], p);
        pos += p.len;
        if (i < parts.items.len - 1) {
            @memcpy(result_buf[pos .. pos + separator.len], separator);
            pos += separator.len;
        }
    }

    const result = allocator.create(StzValue) catch {
        allocator.free(result_buf);
        return null;
    };
    result.* = .{ .tag = .string_val, .data = .{ .string_val = .{
        .ptr = result_buf.ptr,
        .len = result_buf.len,
        .owned = true,
    } } };
    return @ptrCast(result);
}

/// Filter + Map: filter first, then transform matching items
pub export fn stz_yielder_filter_map(list_handle: *anyopaque, filter_op: u8, transform_op: u8) ?*anyopaque {
    const list: *StzList = @ptrCast(@alignCast(list_handle));
    const predicate: FilterOp = @enumFromInt(filter_op);
    const transform: TransformOp = @enumFromInt(transform_op);

    const result = StzList.init() catch return null;

    for (list.items.items) |item| {
        if (applyFilter(item, predicate)) {
            const transformed = applyTransform(item, transform) catch {
                result.deinit();
                return null;
            };
            result.items.append(allocator, transformed) catch {
                transformed.deinit();
                allocator.destroy(transformed);
                result.deinit();
                return null;
            };
        }
    }

    return @ptrCast(result);
}

/// Map with index: transform provides 1-based index as additional context
/// The transform operates on the item; the index is available separately.
pub export fn stz_yielder_map_indexed(list_handle: *anyopaque, op: u8) ?*anyopaque {
    // Same as map but each result is a 2-element list [index, transformed_value]
    const list: *StzList = @ptrCast(@alignCast(list_handle));
    const transform: TransformOp = @enumFromInt(op);

    const result = StzList.init() catch return null;

    for (list.items.items, 0..) |item, i| {
        // Create index value (1-based)
        const idx_val = allocator.create(StzValue) catch {
            result.deinit();
            return null;
        };
        idx_val.* = .{ .tag = .int_val, .data = .{ .int_val = @intCast(i + 1) } };

        const transformed = applyTransform(item, transform) catch {
            allocator.destroy(idx_val);
            result.deinit();
            return null;
        };

        // Create pair list [index, value]
        const pair_items = allocator.alloc(*StzValue, 2) catch {
            transformed.deinit();
            allocator.destroy(transformed);
            allocator.destroy(idx_val);
            result.deinit();
            return null;
        };
        pair_items[0] = idx_val;
        pair_items[1] = transformed;

        const pair = allocator.create(StzValue) catch {
            allocator.free(pair_items);
            transformed.deinit();
            allocator.destroy(transformed);
            allocator.destroy(idx_val);
            result.deinit();
            return null;
        };
        pair.* = .{ .tag = .list_val, .data = .{ .list_val = .{
            .items = pair_items.ptr,
            .len = 2,
            .cap = 2,
        } } };

        result.items.append(allocator, pair) catch {
            pair.deinit();
            allocator.destroy(pair);
            result.deinit();
            return null;
        };
    }

    return @ptrCast(result);
}

/// Count items matching a filter predicate
pub export fn stz_yielder_count_where(list_handle: *anyopaque, op: u8) u32 {
    const list: *StzList = @ptrCast(@alignCast(list_handle));
    const predicate: FilterOp = @enumFromInt(op);

    var n: u32 = 0;
    for (list.items.items) |item| {
        if (applyFilter(item, predicate)) n += 1;
    }
    return n;
}

/// Free a list handle returned by yielder functions
pub export fn stz_yielder_free(handle: *anyopaque) void {
    const list: *StzList = @ptrCast(@alignCast(handle));
    list.deinit();
}

// ─── Tests ───

test "map: type_name" {
    const list = try StzList.init();
    defer list.deinit();

    const v1 = try allocator.create(StzValue);
    v1.* = .{ .tag = .int_val, .data = .{ .int_val = 42 } };
    try list.items.append(allocator, v1);

    const v2 = try allocator.create(StzValue);
    const s = try allocator.alloc(u8, 5);
    @memcpy(s, "hello");
    v2.* = .{ .tag = .string_val, .data = .{ .string_val = .{ .ptr = s.ptr, .len = 5, .owned = true } } };
    try list.items.append(allocator, v2);

    const result_ptr = stz_yielder_map(@ptrCast(list), @intFromEnum(TransformOp.type_name));
    try std.testing.expect(result_ptr != null);
    const result: *StzList = @ptrCast(@alignCast(result_ptr.?));
    defer result.deinit();

    try std.testing.expectEqual(@as(usize, 2), result.len());
    const r0 = result.get(0).?;
    try std.testing.expectEqual(ValueType.string_val, r0.tag);
    try std.testing.expectEqualStrings("int", r0.data.string_val.ptr[0..r0.data.string_val.len]);
    const r1 = result.get(1).?;
    try std.testing.expectEqualStrings("string", r1.data.string_val.ptr[0..r1.data.string_val.len]);
}

test "map: square" {
    const list = try StzList.init();
    defer list.deinit();

    const v1 = try allocator.create(StzValue);
    v1.* = .{ .tag = .int_val, .data = .{ .int_val = 5 } };
    try list.items.append(allocator, v1);

    const v2 = try allocator.create(StzValue);
    v2.* = .{ .tag = .int_val, .data = .{ .int_val = -3 } };
    try list.items.append(allocator, v2);

    const result_ptr = stz_yielder_map(@ptrCast(list), @intFromEnum(TransformOp.square));
    try std.testing.expect(result_ptr != null);
    const result: *StzList = @ptrCast(@alignCast(result_ptr.?));
    defer result.deinit();

    try std.testing.expectEqual(@as(i64, 25), result.get(0).?.data.int_val);
    try std.testing.expectEqual(@as(i64, 9), result.get(1).?.data.int_val);
}

test "filter: is_positive" {
    const list = try StzList.init();
    defer list.deinit();

    const values = [_]i64{ -2, 0, 3, -1, 5 };
    for (values) |v| {
        const sv = try allocator.create(StzValue);
        sv.* = .{ .tag = .int_val, .data = .{ .int_val = v } };
        try list.items.append(allocator, sv);
    }

    const result_ptr = stz_yielder_filter(@ptrCast(list), @intFromEnum(FilterOp.is_positive));
    try std.testing.expect(result_ptr != null);
    const result: *StzList = @ptrCast(@alignCast(result_ptr.?));
    defer result.deinit();

    try std.testing.expectEqual(@as(usize, 2), result.len());
    try std.testing.expectEqual(@as(i64, 3), result.get(0).?.data.int_val);
    try std.testing.expectEqual(@as(i64, 5), result.get(1).?.data.int_val);
}

test "reduce: sum" {
    const list = try StzList.init();
    defer list.deinit();

    const values = [_]i64{ 1, 2, 3, 4, 5 };
    for (values) |v| {
        const sv = try allocator.create(StzValue);
        sv.* = .{ .tag = .int_val, .data = .{ .int_val = v } };
        try list.items.append(allocator, sv);
    }

    const result = stz_yielder_reduce(@ptrCast(list), @intFromEnum(ReduceOp.sum));
    try std.testing.expectEqual(@as(f64, 15.0), result);
}

test "reduce: product" {
    const list = try StzList.init();
    defer list.deinit();

    const values = [_]i64{ 2, 3, 4 };
    for (values) |v| {
        const sv = try allocator.create(StzValue);
        sv.* = .{ .tag = .int_val, .data = .{ .int_val = v } };
        try list.items.append(allocator, sv);
    }

    const result = stz_yielder_reduce(@ptrCast(list), @intFromEnum(ReduceOp.product));
    try std.testing.expectEqual(@as(f64, 24.0), result);
}

test "reduce: min and max" {
    const list = try StzList.init();
    defer list.deinit();

    const values = [_]i64{ 7, 2, 9, 1, 5 };
    for (values) |v| {
        const sv = try allocator.create(StzValue);
        sv.* = .{ .tag = .int_val, .data = .{ .int_val = v } };
        try list.items.append(allocator, sv);
    }

    try std.testing.expectEqual(@as(f64, 1.0), stz_yielder_reduce(@ptrCast(list), @intFromEnum(ReduceOp.min_val)));
    try std.testing.expectEqual(@as(f64, 9.0), stz_yielder_reduce(@ptrCast(list), @intFromEnum(ReduceOp.max_val)));
}

test "filter_map: positive numbers doubled" {
    const list = try StzList.init();
    defer list.deinit();

    const values = [_]i64{ -2, 3, 0, 5 };
    for (values) |v| {
        const sv = try allocator.create(StzValue);
        sv.* = .{ .tag = .int_val, .data = .{ .int_val = v } };
        try list.items.append(allocator, sv);
    }

    const result_ptr = stz_yielder_filter_map(
        @ptrCast(list),
        @intFromEnum(FilterOp.is_positive),
        @intFromEnum(TransformOp.double_val),
    );
    try std.testing.expect(result_ptr != null);
    const result: *StzList = @ptrCast(@alignCast(result_ptr.?));
    defer result.deinit();

    try std.testing.expectEqual(@as(usize, 2), result.len());
    try std.testing.expectEqual(@as(i64, 6), result.get(0).?.data.int_val);
    try std.testing.expectEqual(@as(i64, 10), result.get(1).?.data.int_val);
}

test "count_where" {
    const list = try StzList.init();
    defer list.deinit();

    const values = [_]i64{ 2, 4, 7, 8, 11 };
    for (values) |v| {
        const sv = try allocator.create(StzValue);
        sv.* = .{ .tag = .int_val, .data = .{ .int_val = v } };
        try list.items.append(allocator, sv);
    }

    try std.testing.expectEqual(@as(u32, 3), stz_yielder_count_where(@ptrCast(list), @intFromEnum(FilterOp.is_even)));
    try std.testing.expectEqual(@as(u32, 2), stz_yielder_count_where(@ptrCast(list), @intFromEnum(FilterOp.is_odd)));
}

test "reduce_concat" {
    const list = try StzList.init();
    defer list.deinit();

    const words = [_][]const u8{ "hello", "world" };
    for (words) |w| {
        const sv = try allocator.create(StzValue);
        const buf = try allocator.alloc(u8, w.len);
        @memcpy(buf, w);
        sv.* = .{ .tag = .string_val, .data = .{ .string_val = .{ .ptr = buf.ptr, .len = buf.len, .owned = true } } };
        try list.items.append(allocator, sv);
    }

    const sep = ", ";
    const result_ptr = stz_yielder_reduce_concat(@ptrCast(list), sep.ptr, @intCast(sep.len));
    try std.testing.expect(result_ptr != null);
    const result: *StzValue = @ptrCast(@alignCast(result_ptr.?));
    defer {
        result.deinit();
        allocator.destroy(result);
    }

    try std.testing.expectEqual(ValueType.string_val, result.tag);
    try std.testing.expectEqualStrings("hello, world", result.data.string_val.ptr[0..result.data.string_val.len]);
}

test "map: str_upper and str_lower" {
    const list = try StzList.init();
    defer list.deinit();

    const sv = try allocator.create(StzValue);
    const src = try allocator.alloc(u8, 5);
    @memcpy(src, "Hello");
    sv.* = .{ .tag = .string_val, .data = .{ .string_val = .{ .ptr = src.ptr, .len = 5, .owned = true } } };
    try list.items.append(allocator, sv);

    const upper_ptr = stz_yielder_map(@ptrCast(list), @intFromEnum(TransformOp.str_upper));
    try std.testing.expect(upper_ptr != null);
    const upper: *StzList = @ptrCast(@alignCast(upper_ptr.?));
    defer upper.deinit();
    try std.testing.expectEqualStrings("HELLO", upper.get(0).?.data.string_val.ptr[0..upper.get(0).?.data.string_val.len]);

    const lower_ptr = stz_yielder_map(@ptrCast(list), @intFromEnum(TransformOp.str_lower));
    try std.testing.expect(lower_ptr != null);
    const lower: *StzList = @ptrCast(@alignCast(lower_ptr.?));
    defer lower.deinit();
    try std.testing.expectEqualStrings("hello", lower.get(0).?.data.string_val.ptr[0..lower.get(0).?.data.string_val.len]);
}

test "map: negate and abs" {
    const list = try StzList.init();
    defer list.deinit();

    const sv = try allocator.create(StzValue);
    sv.* = .{ .tag = .int_val, .data = .{ .int_val = -7 } };
    try list.items.append(allocator, sv);

    const neg_ptr = stz_yielder_map(@ptrCast(list), @intFromEnum(TransformOp.negate));
    try std.testing.expect(neg_ptr != null);
    const neg: *StzList = @ptrCast(@alignCast(neg_ptr.?));
    defer neg.deinit();
    try std.testing.expectEqual(@as(i64, 7), neg.get(0).?.data.int_val);

    const abs_ptr = stz_yielder_map(@ptrCast(list), @intFromEnum(TransformOp.abs));
    try std.testing.expect(abs_ptr != null);
    const abs_list: *StzList = @ptrCast(@alignCast(abs_ptr.?));
    defer abs_list.deinit();
    try std.testing.expectEqual(@as(i64, 7), abs_list.get(0).?.data.int_val);
}

test "filter: mixed types" {
    const list = try StzList.init();
    defer list.deinit();

    // Add int
    const v1 = try allocator.create(StzValue);
    v1.* = .{ .tag = .int_val, .data = .{ .int_val = 42 } };
    try list.items.append(allocator, v1);

    // Add string
    const v2 = try allocator.create(StzValue);
    const s = try allocator.alloc(u8, 3);
    @memcpy(s, "abc");
    v2.* = .{ .tag = .string_val, .data = .{ .string_val = .{ .ptr = s.ptr, .len = 3, .owned = true } } };
    try list.items.append(allocator, v2);

    // Add float
    const v3 = try allocator.create(StzValue);
    v3.* = .{ .tag = .float_val, .data = .{ .float_val = 3.14 } };
    try list.items.append(allocator, v3);

    // Filter for numbers
    const nums_ptr = stz_yielder_filter(@ptrCast(list), @intFromEnum(FilterOp.is_number));
    try std.testing.expect(nums_ptr != null);
    const nums: *StzList = @ptrCast(@alignCast(nums_ptr.?));
    defer nums.deinit();
    try std.testing.expectEqual(@as(usize, 2), nums.len());

    // Filter for strings
    const strs_ptr = stz_yielder_filter(@ptrCast(list), @intFromEnum(FilterOp.is_string));
    try std.testing.expect(strs_ptr != null);
    const strs: *StzList = @ptrCast(@alignCast(strs_ptr.?));
    defer strs.deinit();
    try std.testing.expectEqual(@as(usize, 1), strs.len());
}

test "empty list operations" {
    const list = try StzList.init();
    defer list.deinit();

    // Map on empty list
    const map_ptr = stz_yielder_map(@ptrCast(list), @intFromEnum(TransformOp.square));
    try std.testing.expect(map_ptr != null);
    const map_result: *StzList = @ptrCast(@alignCast(map_ptr.?));
    defer map_result.deinit();
    try std.testing.expectEqual(@as(usize, 0), map_result.len());

    // Filter on empty list
    const filter_ptr = stz_yielder_filter(@ptrCast(list), @intFromEnum(FilterOp.is_string));
    try std.testing.expect(filter_ptr != null);
    const filter_result: *StzList = @ptrCast(@alignCast(filter_ptr.?));
    defer filter_result.deinit();
    try std.testing.expectEqual(@as(usize, 0), filter_result.len());

    // Reduce on empty list
    try std.testing.expectEqual(@as(f64, 0.0), stz_yielder_reduce(@ptrCast(list), @intFromEnum(ReduceOp.sum)));
}
