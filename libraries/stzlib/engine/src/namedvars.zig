const std = @import("std");

// ── Named Variables Engine ─────────────────────────────────────
// Named parameter store with type tracking. Supports the
// Softanza named-params paradigm (:param = value).

const MAX_VARS = 256;
const MAX_NAME = 64;
const MAX_VAL = 256;

const VarType = enum(u8) {
    none = 0,
    int_t = 1,
    float_t = 2,
    string_t = 3,
    bool_t = 4,
};

const NamedVar = struct {
    name: [MAX_NAME]u8 = [_]u8{0} ** MAX_NAME,
    name_len: u8 = 0,
    str_val: [MAX_VAL]u8 = [_]u8{0} ** MAX_VAL,
    str_len: u16 = 0,
    num_val: f64 = 0,
    var_type: VarType = .none,
    active: bool = false,
};

var vars: [MAX_VARS]NamedVar = [_]NamedVar{.{}} ** MAX_VARS;

fn find_var(name: [*]const u8, nlen: usize) ?usize {
    for (0..MAX_VARS) |i| {
        if (vars[i].active and vars[i].name_len == nlen and
            std.mem.eql(u8, vars[i].name[0..nlen], name[0..nlen]))
            return i;
    }
    return null;
}

pub fn nv_set_int(name: [*]const u8, name_len: i32, val: i64) callconv(.c) i32 {
    if (name_len <= 0 or name_len > MAX_NAME) return -1;
    const nlen: usize = @intCast(name_len);
    const idx = find_var(name, nlen) orelse blk: {
        for (0..MAX_VARS) |i| {
            if (!vars[i].active) break :blk i;
        }
        return -2;
    };
    @memcpy(vars[idx].name[0..nlen], name[0..nlen]);
    vars[idx].name_len = @intCast(nlen);
    vars[idx].num_val = @floatFromInt(val);
    vars[idx].var_type = .int_t;
    vars[idx].active = true;
    return @intCast(idx);
}

pub fn nv_set_float(name: [*]const u8, name_len: i32, val: f64) callconv(.c) i32 {
    if (name_len <= 0 or name_len > MAX_NAME) return -1;
    const nlen: usize = @intCast(name_len);
    const idx = find_var(name, nlen) orelse blk: {
        for (0..MAX_VARS) |i| {
            if (!vars[i].active) break :blk i;
        }
        return -2;
    };
    @memcpy(vars[idx].name[0..nlen], name[0..nlen]);
    vars[idx].name_len = @intCast(nlen);
    vars[idx].num_val = val;
    vars[idx].var_type = .float_t;
    vars[idx].active = true;
    return @intCast(idx);
}

pub fn nv_set_string(name: [*]const u8, name_len: i32, val: [*]const u8, val_len: i32) callconv(.c) i32 {
    if (name_len <= 0 or name_len > MAX_NAME) return -1;
    if (val_len < 0 or val_len > MAX_VAL) return -3;
    const nlen: usize = @intCast(name_len);
    const vlen: usize = @intCast(val_len);
    const idx = find_var(name, nlen) orelse blk: {
        for (0..MAX_VARS) |i| {
            if (!vars[i].active) break :blk i;
        }
        return -2;
    };
    @memcpy(vars[idx].name[0..nlen], name[0..nlen]);
    vars[idx].name_len = @intCast(nlen);
    @memcpy(vars[idx].str_val[0..vlen], val[0..vlen]);
    vars[idx].str_len = @intCast(vlen);
    vars[idx].var_type = .string_t;
    vars[idx].active = true;
    return @intCast(idx);
}

pub fn nv_set_bool(name: [*]const u8, name_len: i32, val: i32) callconv(.c) i32 {
    if (name_len <= 0 or name_len > MAX_NAME) return -1;
    const nlen: usize = @intCast(name_len);
    const idx = find_var(name, nlen) orelse blk: {
        for (0..MAX_VARS) |i| {
            if (!vars[i].active) break :blk i;
        }
        return -2;
    };
    @memcpy(vars[idx].name[0..nlen], name[0..nlen]);
    vars[idx].name_len = @intCast(nlen);
    vars[idx].num_val = if (val != 0) 1 else 0;
    vars[idx].var_type = .bool_t;
    vars[idx].active = true;
    return @intCast(idx);
}

pub fn nv_get_type(name: [*]const u8, name_len: i32) callconv(.c) i32 {
    if (name_len <= 0) return 0;
    const idx = find_var(name, @intCast(name_len)) orelse return 0;
    return @intFromEnum(vars[idx].var_type);
}

pub fn nv_get_int(name: [*]const u8, name_len: i32) callconv(.c) i64 {
    if (name_len <= 0) return 0;
    const idx = find_var(name, @intCast(name_len)) orelse return 0;
    return @intFromFloat(vars[idx].num_val);
}

pub fn nv_get_float(name: [*]const u8, name_len: i32) callconv(.c) f64 {
    if (name_len <= 0) return 0;
    const idx = find_var(name, @intCast(name_len)) orelse return 0;
    return vars[idx].num_val;
}

pub fn nv_get_string(name: [*]const u8, name_len: i32, out: [*]u8) callconv(.c) i32 {
    if (name_len <= 0) return 0;
    const idx = find_var(name, @intCast(name_len)) orelse return 0;
    const slen = vars[idx].str_len;
    @memcpy(out[0..slen], vars[idx].str_val[0..slen]);
    return @intCast(slen);
}

pub fn nv_has(name: [*]const u8, name_len: i32) callconv(.c) i32 {
    if (name_len <= 0) return 0;
    return if (find_var(name, @intCast(name_len)) != null) 1 else 0;
}

pub fn nv_remove(name: [*]const u8, name_len: i32) callconv(.c) i32 {
    if (name_len <= 0) return -1;
    const idx = find_var(name, @intCast(name_len)) orelse return -2;
    vars[idx].active = false;
    return 0;
}

pub fn nv_count() callconv(.c) i32 {
    var c: i32 = 0;
    for (0..MAX_VARS) |i| {
        if (vars[i].active) c += 1;
    }
    return c;
}

pub fn nv_clear() callconv(.c) void {
    for (0..MAX_VARS) |i| {
        vars[i] = .{};
    }
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_nv_set_int(n: [*]const u8, nl: i32, v: i64) callconv(.c) i32 { return nv_set_int(n, nl, v); }
pub export fn stz_nv_set_float(n: [*]const u8, nl: i32, v: f64) callconv(.c) i32 { return nv_set_float(n, nl, v); }
pub export fn stz_nv_set_string(n: [*]const u8, nl: i32, v: [*]const u8, vl: i32) callconv(.c) i32 { return nv_set_string(n, nl, v, vl); }
pub export fn stz_nv_set_bool(n: [*]const u8, nl: i32, v: i32) callconv(.c) i32 { return nv_set_bool(n, nl, v); }
pub export fn stz_nv_get_type(n: [*]const u8, nl: i32) callconv(.c) i32 { return nv_get_type(n, nl); }
pub export fn stz_nv_get_int(n: [*]const u8, nl: i32) callconv(.c) i64 { return nv_get_int(n, nl); }
pub export fn stz_nv_get_float(n: [*]const u8, nl: i32) callconv(.c) f64 { return nv_get_float(n, nl); }
pub export fn stz_nv_get_string(n: [*]const u8, nl: i32, o: [*]u8) callconv(.c) i32 { return nv_get_string(n, nl, o); }
pub export fn stz_nv_has(n: [*]const u8, nl: i32) callconv(.c) i32 { return nv_has(n, nl); }
pub export fn stz_nv_remove(n: [*]const u8, nl: i32) callconv(.c) i32 { return nv_remove(n, nl); }
pub export fn stz_nv_count() callconv(.c) i32 { return nv_count(); }
pub export fn stz_nv_clear() callconv(.c) void { nv_clear(); }

// ── Tests ────────────────────────────────────────────────────

test "namedvars: set and get int" {
    nv_clear();
    _ = nv_set_int("count", 5, 42);
    try std.testing.expectEqual(@as(i64, 42), nv_get_int("count", 5));
    try std.testing.expectEqual(@as(i32, 1), nv_get_type("count", 5));
}

test "namedvars: set and get string" {
    nv_clear();
    _ = nv_set_string("name", 4, "Alice", 5);
    var buf: [256]u8 = undefined;
    const len = nv_get_string("name", 4, &buf);
    try std.testing.expectEqualStrings("Alice", buf[0..@intCast(len)]);
}

test "namedvars: set and get float" {
    nv_clear();
    _ = nv_set_float("ratio", 5, 3.14);
    try std.testing.expectApproxEqAbs(@as(f64, 3.14), nv_get_float("ratio", 5), 0.001);
}

test "namedvars: has and remove" {
    nv_clear();
    _ = nv_set_int("x", 1, 10);
    try std.testing.expectEqual(@as(i32, 1), nv_has("x", 1));
    _ = nv_remove("x", 1);
    try std.testing.expectEqual(@as(i32, 0), nv_has("x", 1));
}

test "namedvars: count and clear" {
    nv_clear();
    _ = nv_set_int("a", 1, 1);
    _ = nv_set_int("b", 1, 2);
    try std.testing.expectEqual(@as(i32, 2), nv_count());
    nv_clear();
    try std.testing.expectEqual(@as(i32, 0), nv_count());
}

test "namedvars: overwrite" {
    nv_clear();
    _ = nv_set_int("x", 1, 10);
    _ = nv_set_int("x", 1, 20);
    try std.testing.expectEqual(@as(i64, 20), nv_get_int("x", 1));
    try std.testing.expectEqual(@as(i32, 1), nv_count());
}
