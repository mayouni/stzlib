const std = @import("std");

// ─── Schema Engine ───
// 32 named schemas, each with up to 32 typed fields.

const MAX_SCHEMAS: usize = 32;
const MAX_FIELDS: usize = 32;
const MAX_NAME: usize = 64;

const FieldType = enum(u8) {
    string = 0,
    integer = 1,
    float = 2,
    boolean = 3,
    list = 4,
    object = 5,
};

const Field = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    field_type: FieldType = .string,
    required: bool = false,
    active: bool = false,
};

const Schema = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    fields: [MAX_FIELDS]Field = [_]Field{.{}} ** MAX_FIELDS,
    field_count: usize = 0,
    active: bool = false,
};

var schemas: [MAX_SCHEMAS]Schema = [_]Schema{.{}} ** MAX_SCHEMAS;
var schema_count: usize = 0;

fn findSchemaByName(name: [*]const u8, len: usize) ?usize {
    for (0..MAX_SCHEMAS) |idx| {
        if (schemas[idx].active and schemas[idx].name_len == len) {
            if (std.mem.eql(u8, schemas[idx].name[0..len], name[0..len])) return idx;
        }
    }
    return null;
}

// ─── C ABI ───

pub export fn stz_schema_create(name: [*]const u8, name_len: usize) i32 {
    for (0..MAX_SCHEMAS) |idx| {
        if (!schemas[idx].active) {
            const nl = @min(name_len, MAX_NAME);
            @memcpy(schemas[idx].name[0..nl], name[0..nl]);
            schemas[idx].name_len = nl;
            schemas[idx].field_count = 0;
            for (0..MAX_FIELDS) |fi| {
                schemas[idx].fields[fi].active = false;
            }
            schemas[idx].active = true;
            schema_count += 1;
            return @intCast(idx);
        }
    }
    return -1;
}

pub export fn stz_schema_add_field(schema_idx: i32, name: [*]const u8, name_len: usize, field_type: i32, required: i32) i32 {
    if (schema_idx < 0 or schema_idx >= @as(i32, MAX_SCHEMAS)) return -1;
    const si: usize = @intCast(schema_idx);
    if (!schemas[si].active) return -1;

    for (0..MAX_FIELDS) |fi| {
        if (!schemas[si].fields[fi].active) {
            const nl = @min(name_len, MAX_NAME);
            @memcpy(schemas[si].fields[fi].name[0..nl], name[0..nl]);
            schemas[si].fields[fi].name_len = nl;
            schemas[si].fields[fi].field_type = @enumFromInt(@as(u8, @intCast(@min(field_type, 5))));
            schemas[si].fields[fi].required = required != 0;
            schemas[si].fields[fi].active = true;
            schemas[si].field_count += 1;
            return @intCast(fi);
        }
    }
    return -1;
}

pub export fn stz_schema_field_count(schema_idx: i32) i32 {
    if (schema_idx < 0 or schema_idx >= @as(i32, MAX_SCHEMAS)) return 0;
    const si: usize = @intCast(schema_idx);
    if (!schemas[si].active) return 0;
    return @intCast(schemas[si].field_count);
}

pub export fn stz_schema_field_name(schema_idx: i32, field_idx: i32, out: [*]u8) i32 {
    if (schema_idx < 0 or schema_idx >= @as(i32, MAX_SCHEMAS)) return 0;
    if (field_idx < 0 or field_idx >= @as(i32, MAX_FIELDS)) return 0;
    const si: usize = @intCast(schema_idx);
    const fi: usize = @intCast(field_idx);
    if (!schemas[si].active or !schemas[si].fields[fi].active) return 0;
    const len = schemas[si].fields[fi].name_len;
    @memcpy(out[0..len], schemas[si].fields[fi].name[0..len]);
    return @intCast(len);
}

pub export fn stz_schema_field_type(schema_idx: i32, field_idx: i32) i32 {
    if (schema_idx < 0 or schema_idx >= @as(i32, MAX_SCHEMAS)) return -1;
    if (field_idx < 0 or field_idx >= @as(i32, MAX_FIELDS)) return -1;
    const si: usize = @intCast(schema_idx);
    const fi: usize = @intCast(field_idx);
    if (!schemas[si].active or !schemas[si].fields[fi].active) return -1;
    return @intFromEnum(schemas[si].fields[fi].field_type);
}

pub export fn stz_schema_field_required(schema_idx: i32, field_idx: i32) i32 {
    if (schema_idx < 0 or schema_idx >= @as(i32, MAX_SCHEMAS)) return 0;
    if (field_idx < 0 or field_idx >= @as(i32, MAX_FIELDS)) return 0;
    const si: usize = @intCast(schema_idx);
    const fi: usize = @intCast(field_idx);
    if (!schemas[si].active or !schemas[si].fields[fi].active) return 0;
    return if (schemas[si].fields[fi].required) @as(i32, 1) else @as(i32, 0);
}

pub export fn stz_schema_count() i32 {
    return @intCast(schema_count);
}

pub export fn stz_schema_destroy(schema_idx: i32) void {
    if (schema_idx < 0 or schema_idx >= @as(i32, MAX_SCHEMAS)) return;
    const si: usize = @intCast(schema_idx);
    if (schemas[si].active) {
        schemas[si].active = false;
        schema_count -= 1;
    }
}

pub export fn stz_schema_clear() void {
    for (0..MAX_SCHEMAS) |idx| {
        schemas[idx].active = false;
    }
    schema_count = 0;
}

// ─── Tests ───

test "create schema with fields" {
    stz_schema_clear();
    const s = stz_schema_create("user", 4);
    try std.testing.expect(s >= 0);
    _ = stz_schema_add_field(s, "name", 4, 0, 1);
    _ = stz_schema_add_field(s, "age", 3, 1, 1);
    _ = stz_schema_add_field(s, "email", 5, 0, 0);
    try std.testing.expectEqual(@as(i32, 3), stz_schema_field_count(s));
    stz_schema_clear();
}

test "field type and required" {
    stz_schema_clear();
    const s = stz_schema_create("item", 4);
    const f = stz_schema_add_field(s, "price", 5, 2, 1);
    try std.testing.expectEqual(@as(i32, 2), stz_schema_field_type(s, f));
    try std.testing.expectEqual(@as(i32, 1), stz_schema_field_required(s, f));
    stz_schema_clear();
}

test "field name retrieval" {
    stz_schema_clear();
    const s = stz_schema_create("doc", 3);
    const f = stz_schema_add_field(s, "title", 5, 0, 1);
    var buf: [64]u8 = undefined;
    const len = stz_schema_field_name(s, f, &buf);
    try std.testing.expectEqualSlices(u8, "title", buf[0..@intCast(len)]);
    stz_schema_clear();
}

test "destroy schema" {
    stz_schema_clear();
    const s = stz_schema_create("tmp", 3);
    try std.testing.expectEqual(@as(i32, 1), stz_schema_count());
    stz_schema_destroy(s);
    try std.testing.expectEqual(@as(i32, 0), stz_schema_count());
    stz_schema_clear();
}

test "multiple schemas" {
    stz_schema_clear();
    _ = stz_schema_create("users", 5);
    _ = stz_schema_create("orders", 6);
    _ = stz_schema_create("items", 5);
    try std.testing.expectEqual(@as(i32, 3), stz_schema_count());
    stz_schema_clear();
    try std.testing.expectEqual(@as(i32, 0), stz_schema_count());
}

test "multiple fields per schema" {
    stz_schema_clear();
    const s = stz_schema_create("product", 7);
    _ = stz_schema_add_field(s, "id", 2, 1, 1);
    _ = stz_schema_add_field(s, "name", 4, 0, 1);
    _ = stz_schema_add_field(s, "price", 5, 2, 1);
    _ = stz_schema_add_field(s, "desc", 4, 0, 0);
    try std.testing.expectEqual(@as(i32, 4), stz_schema_field_count(s));

    // Check non-required field
    try std.testing.expectEqual(@as(i32, 0), stz_schema_field_required(s, 3));
    // Check required field
    try std.testing.expectEqual(@as(i32, 1), stz_schema_field_required(s, 0));
    stz_schema_clear();
}
