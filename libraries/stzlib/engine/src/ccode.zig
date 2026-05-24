const std = @import("std");

// ── C Code Generation Engine ───────────────────────────────────
// Emit C-compatible type names, function signatures, struct
// definitions, includes, and simple code fragments.

const MAX_OUT = 4096;

const CType = enum(u8) {
    void_t = 0,
    int_t = 1,
    float_t = 2,
    double_t = 3,
    char_t = 4,
    char_ptr = 5,
    int_ptr = 6,
    void_ptr = 7,
    int8 = 8,
    int16 = 9,
    int32 = 10,
    int64 = 11,
    uint8 = 12,
    uint16 = 13,
    uint32 = 14,
    uint64 = 15,
    bool_t = 16,
    size_t_t = 17,
};

fn type_name(t: u8) []const u8 {
    return switch (@as(CType, @enumFromInt(if (t > 17) 0 else t))) {
        .void_t => "void",
        .int_t => "int",
        .float_t => "float",
        .double_t => "double",
        .char_t => "char",
        .char_ptr => "char*",
        .int_ptr => "int*",
        .void_ptr => "void*",
        .int8 => "int8_t",
        .int16 => "int16_t",
        .int32 => "int32_t",
        .int64 => "int64_t",
        .uint8 => "uint8_t",
        .uint16 => "uint16_t",
        .uint32 => "uint32_t",
        .uint64 => "uint64_t",
        .bool_t => "bool",
        .size_t_t => "size_t",
    };
}

pub fn ccode_type_name(type_id: i32, out: [*]u8) callconv(.c) i32 {
    const t: u8 = if (type_id < 0 or type_id > 17) 0 else @intCast(type_id);
    const name = type_name(t);
    @memcpy(out[0..name.len], name);
    return @intCast(name.len);
}

pub fn ccode_sizeof(type_id: i32) callconv(.c) i32 {
    return switch (@as(CType, @enumFromInt(if (type_id < 0 or type_id > 17) 0 else @as(u8, @intCast(type_id))))) {
        .void_t => 0,
        .int_t => 4,
        .float_t => 4,
        .double_t => 8,
        .char_t => 1,
        .char_ptr, .int_ptr, .void_ptr => 8,
        .int8, .uint8, .bool_t => 1,
        .int16, .uint16 => 2,
        .int32, .uint32 => 4,
        .int64, .uint64, .size_t_t => 8,
    };
}

pub fn ccode_func_decl(ret_type: i32, name_ptr: [*]const u8, name_len: i32, param_types: [*]const i32, param_count: i32, out: [*]u8) callconv(.c) i32 {
    if (name_len <= 0 or param_count < 0) return 0;
    const nlen: usize = @intCast(name_len);
    const pcount: usize = @intCast(param_count);

    var pos: usize = 0;
    const ret = type_name(if (ret_type < 0 or ret_type > 17) 0 else @intCast(ret_type));
    if (pos + ret.len + 1 + nlen + 1 > MAX_OUT) return 0;
    @memcpy(out[pos .. pos + ret.len], ret);
    pos += ret.len;
    out[pos] = ' ';
    pos += 1;
    @memcpy(out[pos .. pos + nlen], name_ptr[0..nlen]);
    pos += nlen;
    out[pos] = '(';
    pos += 1;

    if (pcount == 0) {
        if (pos + 5 > MAX_OUT) return 0;
        @memcpy(out[pos .. pos + 4], "void");
        pos += 4;
    } else {
        for (0..pcount) |i| {
            if (i > 0) {
                if (pos + 2 > MAX_OUT) return 0;
                @memcpy(out[pos .. pos + 2], ", ");
                pos += 2;
            }
            const pt = param_types[i];
            const ptn = type_name(if (pt < 0 or pt > 17) 0 else @intCast(pt));
            if (pos + ptn.len > MAX_OUT) return 0;
            @memcpy(out[pos .. pos + ptn.len], ptn);
            pos += ptn.len;
        }
    }

    if (pos + 2 > MAX_OUT) return 0;
    out[pos] = ')';
    pos += 1;
    out[pos] = ';';
    pos += 1;
    return @intCast(pos);
}

pub fn ccode_struct_field(type_id: i32, field_name: [*]const u8, field_len: i32, out: [*]u8) callconv(.c) i32 {
    if (field_len <= 0) return 0;
    const flen: usize = @intCast(field_len);
    const tn = type_name(if (type_id < 0 or type_id > 17) 0 else @intCast(type_id));
    const total = 4 + tn.len + 1 + flen + 1;
    if (total > MAX_OUT) return 0;
    var pos: usize = 0;
    @memcpy(out[pos .. pos + 4], "    ");
    pos += 4;
    @memcpy(out[pos .. pos + tn.len], tn);
    pos += tn.len;
    out[pos] = ' ';
    pos += 1;
    @memcpy(out[pos .. pos + flen], field_name[0..flen]);
    pos += flen;
    out[pos] = ';';
    pos += 1;
    return @intCast(pos);
}

pub fn ccode_include(header: [*]const u8, header_len: i32, is_system: i32, out: [*]u8) callconv(.c) i32 {
    if (header_len <= 0) return 0;
    const hlen: usize = @intCast(header_len);
    const prefix = "#include ";
    var pos: usize = 0;
    @memcpy(out[pos .. pos + prefix.len], prefix);
    pos += prefix.len;
    if (is_system != 0) {
        out[pos] = '<';
        pos += 1;
        @memcpy(out[pos .. pos + hlen], header[0..hlen]);
        pos += hlen;
        out[pos] = '>';
        pos += 1;
    } else {
        out[pos] = '"';
        pos += 1;
        @memcpy(out[pos .. pos + hlen], header[0..hlen]);
        pos += hlen;
        out[pos] = '"';
        pos += 1;
    }
    return @intCast(pos);
}

pub fn ccode_define(name_ptr: [*]const u8, name_len: i32, val_ptr: [*]const u8, val_len: i32, out: [*]u8) callconv(.c) i32 {
    if (name_len <= 0) return 0;
    const nlen: usize = @intCast(name_len);
    const vlen: usize = if (val_len < 0) 0 else @intCast(val_len);
    const prefix = "#define ";
    var pos: usize = 0;
    if (pos + prefix.len + nlen > MAX_OUT) return 0;
    @memcpy(out[pos .. pos + prefix.len], prefix);
    pos += prefix.len;
    @memcpy(out[pos .. pos + nlen], name_ptr[0..nlen]);
    pos += nlen;
    if (vlen > 0) {
        if (pos + 1 + vlen > MAX_OUT) return 0;
        out[pos] = ' ';
        pos += 1;
        @memcpy(out[pos .. pos + vlen], val_ptr[0..vlen]);
        pos += vlen;
    }
    return @intCast(pos);
}

pub fn ccode_typedef(old_type: i32, new_name: [*]const u8, new_len: i32, out: [*]u8) callconv(.c) i32 {
    if (new_len <= 0) return 0;
    const nlen: usize = @intCast(new_len);
    const tn = type_name(if (old_type < 0 or old_type > 17) 0 else @intCast(old_type));
    const prefix = "typedef ";
    const total = prefix.len + tn.len + 1 + nlen + 1;
    if (total > MAX_OUT) return 0;
    var pos: usize = 0;
    @memcpy(out[pos .. pos + prefix.len], prefix);
    pos += prefix.len;
    @memcpy(out[pos .. pos + tn.len], tn);
    pos += tn.len;
    out[pos] = ' ';
    pos += 1;
    @memcpy(out[pos .. pos + nlen], new_name[0..nlen]);
    pos += nlen;
    out[pos] = ';';
    pos += 1;
    return @intCast(pos);
}

pub fn ccode_is_keyword(word: [*]const u8, word_len: i32) callconv(.c) i32 {
    if (word_len <= 0 or word_len > 16) return 0;
    const wlen: usize = @intCast(word_len);
    const w = word[0..wlen];
    const keywords = [_][]const u8{
        "auto",     "break",    "case",     "char",     "const",
        "continue", "default",  "do",       "double",   "else",
        "enum",     "extern",   "float",    "for",      "goto",
        "if",       "inline",   "int",      "long",     "register",
        "restrict", "return",   "short",    "signed",   "sizeof",
        "static",   "struct",   "switch",   "typedef",  "union",
        "unsigned", "void",     "volatile", "while",    "_Bool",
        "_Complex", "_Imaginary",
    };
    for (keywords) |kw| {
        if (std.mem.eql(u8, w, kw)) return 1;
    }
    return 0;
}

pub fn ccode_escape_string(input: [*]const u8, input_len: i32, out: [*]u8) callconv(.c) i32 {
    if (input_len <= 0) return 0;
    const ilen: usize = @intCast(input_len);
    var pos: usize = 0;
    for (0..ilen) |i| {
        if (pos + 2 > MAX_OUT) break;
        switch (input[i]) {
            '\\' => { out[pos] = '\\'; out[pos + 1] = '\\'; pos += 2; },
            '"' => { out[pos] = '\\'; out[pos + 1] = '"'; pos += 2; },
            '\n' => { out[pos] = '\\'; out[pos + 1] = 'n'; pos += 2; },
            '\t' => { out[pos] = '\\'; out[pos + 1] = 't'; pos += 2; },
            '\r' => { out[pos] = '\\'; out[pos + 1] = 'r'; pos += 2; },
            0 => { out[pos] = '\\'; out[pos + 1] = '0'; pos += 2; },
            else => { out[pos] = input[i]; pos += 1; },
        }
    }
    return @intCast(pos);
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_ccode_type_name(t: i32, o: [*]u8) callconv(.c) i32 { return ccode_type_name(t, o); }
pub export fn stz_ccode_sizeof(t: i32) callconv(.c) i32 { return ccode_sizeof(t); }
pub export fn stz_ccode_func_decl(r: i32, n: [*]const u8, nl: i32, p: [*]const i32, pc: i32, o: [*]u8) callconv(.c) i32 { return ccode_func_decl(r, n, nl, p, pc, o); }
pub export fn stz_ccode_struct_field(t: i32, f: [*]const u8, fl: i32, o: [*]u8) callconv(.c) i32 { return ccode_struct_field(t, f, fl, o); }
pub export fn stz_ccode_include(h: [*]const u8, hl: i32, s: i32, o: [*]u8) callconv(.c) i32 { return ccode_include(h, hl, s, o); }
pub export fn stz_ccode_define(n: [*]const u8, nl: i32, v: [*]const u8, vl: i32, o: [*]u8) callconv(.c) i32 { return ccode_define(n, nl, v, vl, o); }
pub export fn stz_ccode_typedef(o_t: i32, n: [*]const u8, nl: i32, o: [*]u8) callconv(.c) i32 { return ccode_typedef(o_t, n, nl, o); }
pub export fn stz_ccode_is_keyword(w: [*]const u8, wl: i32) callconv(.c) i32 { return ccode_is_keyword(w, wl); }
pub export fn stz_ccode_escape_string(i_p: [*]const u8, il: i32, o: [*]u8) callconv(.c) i32 { return ccode_escape_string(i_p, il, o); }

// ── Tests ────────────────────────────────────────────────────

test "ccode: type_name" {
    var buf: [64]u8 = undefined;
    const len = ccode_type_name(1, &buf);
    try std.testing.expectEqualStrings("int", buf[0..@intCast(len)]);
    const len2 = ccode_type_name(5, &buf);
    try std.testing.expectEqualStrings("char*", buf[0..@intCast(len2)]);
}

test "ccode: sizeof" {
    try std.testing.expectEqual(@as(i32, 4), ccode_sizeof(1));
    try std.testing.expectEqual(@as(i32, 8), ccode_sizeof(3));
    try std.testing.expectEqual(@as(i32, 1), ccode_sizeof(4));
}

test "ccode: func_decl" {
    var buf: [256]u8 = undefined;
    const params = [_]i32{ 1, 5 };
    const len = ccode_func_decl(0, "my_func", 7, &params, 2, &buf);
    try std.testing.expectEqualStrings("void my_func(int, char*);", buf[0..@intCast(len)]);
}

test "ccode: struct_field" {
    var buf: [128]u8 = undefined;
    const len = ccode_struct_field(1, "count", 5, &buf);
    try std.testing.expectEqualStrings("    int count;", buf[0..@intCast(len)]);
}

test "ccode: include" {
    var buf: [128]u8 = undefined;
    const len = ccode_include("stdio.h", 7, 1, &buf);
    try std.testing.expectEqualStrings("#include <stdio.h>", buf[0..@intCast(len)]);
    const len2 = ccode_include("mylib.h", 7, 0, &buf);
    try std.testing.expectEqualStrings("#include \"mylib.h\"", buf[0..@intCast(len2)]);
}

test "ccode: define" {
    var buf: [128]u8 = undefined;
    const len = ccode_define("MAX_SIZE", 8, "1024", 4, &buf);
    try std.testing.expectEqualStrings("#define MAX_SIZE 1024", buf[0..@intCast(len)]);
}

test "ccode: typedef" {
    var buf: [128]u8 = undefined;
    const len = ccode_typedef(11, "i64", 3, &buf);
    try std.testing.expectEqualStrings("typedef int64_t i64;", buf[0..@intCast(len)]);
}

test "ccode: is_keyword" {
    try std.testing.expectEqual(@as(i32, 1), ccode_is_keyword("int", 3));
    try std.testing.expectEqual(@as(i32, 1), ccode_is_keyword("return", 6));
    try std.testing.expectEqual(@as(i32, 0), ccode_is_keyword("myvar", 5));
}

test "ccode: escape_string" {
    var buf: [128]u8 = undefined;
    const len = ccode_escape_string("hello\n\"world\"", 13, &buf);
    try std.testing.expectEqualStrings("hello\\n\\\"world\\\"", buf[0..@intCast(len)]);
}
