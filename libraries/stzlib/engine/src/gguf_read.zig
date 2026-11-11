// READING A MODEL FILE'S METADATA -- the one way engine code reads a GGUF value (SECURITY-MODELDATA-01b, 2026-11-08).
//
// ggml's typed getters (gguf_get_val_str, gguf_get_val_u32, gguf_get_arr_str, ...) do not answer "wrong type": they
// ASSERT, and a failed GGML_ASSERT aborts the process. A model file is outside input -- a converted release, a copy
// somebody shared -- so a key with the wrong type (an architecture written as a number, a vocabulary written as an
// array of integers) brought the whole program down at load, and gguf_get_arr_str does not check its index at all.
// Found by fuzzing the loaders through their exported entry points, 2026-11-08.
//
// Every function here checks the key's type, the array's element type and the index BEFORE calling a typed getter,
// and answers null (or the caller's default) for anything else: the caller refuses the model by status. Integers are
// range-checked into the type the caller asked for, because @intCast of an out-of-range value is a panic in a
// ReleaseSafe build -- the same crash by another road.
//
// The context is taken as anytype and passed on as an opaque pointer, because each engine module's @cImport makes
// its own distinct gguf_context type.

const std = @import("std");

pub const T_U8: c_int = 0;
pub const T_I8: c_int = 1;
pub const T_U16: c_int = 2;
pub const T_I16: c_int = 3;
pub const T_U32: c_int = 4;
pub const T_I32: c_int = 5;
pub const T_F32: c_int = 6;
pub const T_BOOL: c_int = 7;
pub const T_STR: c_int = 8;
pub const T_ARR: c_int = 9;
pub const T_U64: c_int = 10;
pub const T_I64: c_int = 11;
pub const T_F64: c_int = 12;

const Ctx = *const anyopaque;
extern fn gguf_find_key(ctx: Ctx, key: [*:0]const u8) i64;
extern fn gguf_get_n_kv(ctx: Ctx) i64;
extern fn gguf_get_kv_type(ctx: Ctx, id: i64) c_int;
extern fn gguf_get_arr_type(ctx: Ctx, id: i64) c_int;
extern fn gguf_get_arr_n(ctx: Ctx, id: i64) usize;
extern fn gguf_get_arr_data(ctx: Ctx, id: i64) ?*const anyopaque;
extern fn gguf_get_arr_str(ctx: Ctx, id: i64, i: usize) [*:0]const u8;
extern fn gguf_get_val_u8(ctx: Ctx, id: i64) u8;
extern fn gguf_get_val_i8(ctx: Ctx, id: i64) i8;
extern fn gguf_get_val_u16(ctx: Ctx, id: i64) u16;
extern fn gguf_get_val_i16(ctx: Ctx, id: i64) i16;
extern fn gguf_get_val_u32(ctx: Ctx, id: i64) u32;
extern fn gguf_get_val_i32(ctx: Ctx, id: i64) i32;
extern fn gguf_get_val_u64(ctx: Ctx, id: i64) u64;
extern fn gguf_get_val_i64(ctx: Ctx, id: i64) i64;
extern fn gguf_get_val_f32(ctx: Ctx, id: i64) f32;
extern fn gguf_get_val_f64(ctx: Ctx, id: i64) f64;
extern fn gguf_get_val_bool(ctx: Ctx, id: i64) bool;
extern fn gguf_get_val_str(ctx: Ctx, id: i64) [*:0]const u8;

inline fn op(ctx: anytype) Ctx {
    return @ptrCast(ctx);
}

/// the key's id, or -1 when it is absent
pub fn find(ctx: anytype, key: [*:0]const u8) i64 {
    return gguf_find_key(op(ctx), key);
}

fn valid(ctx: Ctx, id: i64) bool {
    return id >= 0 and id < gguf_get_n_kv(ctx);
}

/// the value's type (T_ARR for any array), or -1 for an id that is not a key
pub fn kindOf(ctx: anytype, id: i64) c_int {
    const g = op(ctx);
    if (!valid(g, id)) return -1;
    return gguf_get_kv_type(g, id);
}

/// a STRING value by id; null for any other type
pub fn strAt(ctx: anytype, id: i64) ?[*:0]const u8 {
    const g = op(ctx);
    if (!valid(g, id) or gguf_get_kv_type(g, id) != T_STR) return null;
    return gguf_get_val_str(g, id);
}

/// a STRING value by key; null when absent or of another type
pub fn str(ctx: anytype, key: [*:0]const u8) ?[*:0]const u8 {
    return strAt(ctx, find(ctx, key));
}

/// as str(), as a slice; "" when absent or of another type
pub fn strOr(ctx: anytype, key: [*:0]const u8, dflt: []const u8) []const u8 {
    const s = str(ctx, key) orelse return dflt;
    return std.mem.span(s);
}

/// any integer value by id, widened to i128 so no source value is out of range; null for a non-integer
pub fn intAt(ctx: anytype, id: i64) ?i128 {
    const g = op(ctx);
    if (!valid(g, id)) return null;
    return switch (gguf_get_kv_type(g, id)) {
        T_U8 => gguf_get_val_u8(g, id),
        T_I8 => gguf_get_val_i8(g, id),
        T_U16 => gguf_get_val_u16(g, id),
        T_I16 => gguf_get_val_i16(g, id),
        T_U32 => gguf_get_val_u32(g, id),
        T_I32 => gguf_get_val_i32(g, id),
        T_U64 => gguf_get_val_u64(g, id),
        T_I64 => gguf_get_val_i64(g, id),
        else => null,
    };
}

/// an integer value by id, as T when it fits in T; dflt for absent, non-integer or out of T's range
pub fn intAtAs(comptime T: type, ctx: anytype, id: i64, dflt: T) T {
    const v = intAt(ctx, id) orelse return dflt;
    if (v < std.math.minInt(T) or v > std.math.maxInt(T)) return dflt;
    return @intCast(v);
}

/// an integer value by key, as T when it fits in T; dflt otherwise
pub fn intAs(comptime T: type, ctx: anytype, key: [*:0]const u8, dflt: T) T {
    return intAtAs(T, ctx, find(ctx, key), dflt);
}

/// a float value by id (f32 or f64), or dflt; a NaN or an infinity is dflt too
pub fn floatAt(ctx: anytype, id: i64, dflt: f32) f32 {
    const g = op(ctx);
    if (!valid(g, id)) return dflt;
    const v: f64 = switch (gguf_get_kv_type(g, id)) {
        T_F32 => gguf_get_val_f32(g, id),
        T_F64 => gguf_get_val_f64(g, id),
        else => return dflt,
    };
    if (!std.math.isFinite(v) or @abs(v) > std.math.floatMax(f32)) return dflt;
    return @floatCast(v);
}

pub fn float(ctx: anytype, key: [*:0]const u8, dflt: f32) f32 {
    return floatAt(ctx, find(ctx, key), dflt);
}

/// a BOOL value by key, or dflt
pub fn boolOr(ctx: anytype, key: [*:0]const u8, dflt: bool) bool {
    const g = op(ctx);
    const id = gguf_find_key(g, key);
    if (!valid(g, id) or gguf_get_kv_type(g, id) != T_BOOL) return dflt;
    return gguf_get_val_bool(g, id);
}

/// the number of items of an ARRAY whose items are of type elem; null for anything else
pub fn arrN(ctx: anytype, id: i64, elem: c_int) ?usize {
    const g = op(ctx);
    if (!valid(g, id) or gguf_get_kv_type(g, id) != T_ARR) return null;
    if (gguf_get_arr_type(g, id) != elem) return null;
    return gguf_get_arr_n(g, id);
}

/// item i of an array of strings; null when id is not one or i is past its end (ggml does not check i)
pub fn arrStr(ctx: anytype, id: i64, i: usize) ?[*:0]const u8 {
    const n = arrN(ctx, id, T_STR) orelse return null;
    if (i >= n) return null;
    return gguf_get_arr_str(op(ctx), id, i);
}

/// the items of an array of T (a scalar type), as a slice of the file's own memory; null for any other shape
/// An array of booleans (one byte each in GGUF), or null when the key is not one.
pub fn arrBool(ctx: anytype, id: i64) ?[]const u8 {
    const n = arrN(ctx, id, T_BOOL) orelse return null;
    if (n == 0) return &[_]u8{};
    const p = gguf_get_arr_data(op(ctx), id) orelse return null;
    const items: [*]const u8 = @ptrCast(p);
    return items[0..n];
}

pub fn arrOf(comptime T: type, ctx: anytype, id: i64) ?[]const T {
    const elem: c_int = switch (T) {
        u8 => T_U8,
        i8 => T_I8,
        u16 => T_U16,
        i16 => T_I16,
        u32 => T_U32,
        i32 => T_I32,
        f32 => T_F32,
        u64 => T_U64,
        i64 => T_I64,
        f64 => T_F64,
        else => @compileError("gguf_read.arrOf: not a scalar type"),
    };
    const n = arrN(ctx, id, elem) orelse return null;
    if (n == 0) return &[_]T{};
    const p = gguf_get_arr_data(op(ctx), id) orelse return null;
    const items: [*]const T = @ptrCast(@alignCast(p));
    return items[0..n];
}
