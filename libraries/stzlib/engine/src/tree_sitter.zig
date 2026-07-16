// Softanza engine -- tree-sitter polyglot parsing (prototype: Python).
//
// Vendored tree-sitter runtime + tree-sitter-python grammar (both C,
// compiled by Zig, no external runtime). parsePython() walks the concrete
// syntax tree and emits the SAME line protocol the old spawn-Python driver
// did -- CLASS|/METHOD|/FUNC|/IMPORT|/CALL| -- so the Ring stzPyCodeGraph
// ingests it unchanged, now with ZERO Python dependency.
//
// Adding a second language later is: vendor its grammar + a walk() that
// maps its node types to the same protocol. The runtime + emit buffer are
// language-agnostic.

const std = @import("std");

// ── tree-sitter C ABI (opaque handles; TSNode/TSPoint are by-value) ──
const TSPoint = extern struct { row: u32, column: u32 };
const TSNode = extern struct {
    context: [4]u32,
    id: ?*const anyopaque,
    tree: ?*const anyopaque,
};

extern fn ts_parser_new() ?*anyopaque;
extern fn ts_parser_delete(?*anyopaque) void;
extern fn ts_parser_set_language(?*anyopaque, ?*const anyopaque) bool;
extern fn ts_parser_parse_string(?*anyopaque, ?*const anyopaque, [*]const u8, u32) ?*anyopaque;
extern fn ts_tree_delete(?*anyopaque) void;
extern fn ts_tree_root_node(?*const anyopaque) TSNode;
extern fn ts_node_type(TSNode) [*:0]const u8;
extern fn ts_node_child_count(TSNode) u32;
extern fn ts_node_child(TSNode, u32) TSNode;
extern fn ts_node_named_child_count(TSNode) u32;
extern fn ts_node_named_child(TSNode, u32) TSNode;
extern fn ts_node_child_by_field_name(TSNode, [*]const u8, u32) TSNode;
extern fn ts_node_start_byte(TSNode) u32;
extern fn ts_node_end_byte(TSNode) u32;
extern fn ts_node_start_point(TSNode) TSPoint;
extern fn ts_node_is_null(TSNode) bool;

// the grammar's language function (linked from vendor/tree-sitter/python)
extern fn tree_sitter_python() ?*const anyopaque;

// ── emit buffer (persists between calls; single-threaded Ring use) ──
pub var g_buf: [1 << 20]u8 = undefined;
pub var g_len: usize = 0;

fn put(s: []const u8) void {
    const room = g_buf.len - 1 - g_len; // keep 1 byte for a trailing NUL
    const n = @min(s.len, room);
    if (n == 0) return;
    @memcpy(g_buf[g_len .. g_len + n], s[0..n]);
    g_len += n;
}

fn putNum(v: u32) void {
    var tmp: [16]u8 = undefined;
    const s = std.fmt.bufPrint(&tmp, "{d}", .{v}) catch return;
    put(s);
}

fn streq(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

fn ntype(n: TSNode) []const u8 {
    return std.mem.span(ts_node_type(n));
}

fn field(n: TSNode, name: []const u8) TSNode {
    return ts_node_child_by_field_name(n, name.ptr, @intCast(name.len));
}

fn text(n: TSNode, src: []const u8) []const u8 {
    const a = ts_node_start_byte(n);
    const b = ts_node_end_byte(n);
    if (a > src.len or b > src.len or a > b) return "";
    return src[a..b];
}

fn line(n: TSNode) u32 {
    return ts_node_start_point(n).row + 1;
}

// ── the walk: CST -> line protocol ──
// cur_class = the enclosing class name (a method's owner), null at module
// level; cur_fn = the enclosing function (a call's caller); in_fn = we are
// inside a function body (so nested defs are locals, not methods/funcs).
fn walk(n: TSNode, src: []const u8, cur_class: ?[]const u8, cur_fn: ?[]const u8, in_fn: bool) void {
    const t = ntype(n);

    if (streq(t, "class_definition")) {
        const nm = text(field(n, "name"), src);
        put("CLASS|");
        put(nm);
        put("|");
        emitBases(n, src);
        put("|");
        putNum(line(n));
        put("\n");
        // recurse the class body with this class as owner, not inside a fn
        var i: u32 = 0;
        const c = ts_node_child_count(n);
        while (i < c) : (i += 1) walk(ts_node_child(n, i), src, nm, cur_fn, false);
        return;
    }

    if (streq(t, "function_definition")) {
        const nm = text(field(n, "name"), src);
        if (cur_class != null and !in_fn) {
            put("METHOD|");
            put(cur_class.?);
            put("|");
            put(nm);
            put("|");
            putNum(line(n));
            put("\n");
        } else if (!in_fn) {
            put("FUNC|");
            put(nm);
            put("|");
            putNum(line(n));
            put("\n");
        }
        // the body is inside a function: clear class owner, set caller = nm
        var i: u32 = 0;
        const c = ts_node_child_count(n);
        while (i < c) : (i += 1) walk(ts_node_child(n, i), src, null, nm, true);
        return;
    }

    if (streq(t, "import_statement")) {
        emitImportNames(n, src);
        return;
    }
    if (streq(t, "import_from_statement")) {
        const m = field(n, "module_name");
        if (!ts_node_is_null(m)) {
            put("IMPORT|");
            put(text(m, src));
            put("\n");
        }
        return;
    }

    if (streq(t, "call")) {
        emitCall(n, src, cur_fn);
        // fall through to recurse arguments (nested calls)
    }

    var i: u32 = 0;
    const c = ts_node_child_count(n);
    while (i < c) : (i += 1) walk(ts_node_child(n, i), src, cur_class, cur_fn, in_fn);
}

fn emitBases(class_node: TSNode, src: []const u8) void {
    const sup = field(class_node, "superclasses");
    if (ts_node_is_null(sup)) return;
    var i: u32 = 0;
    const n = ts_node_named_child_count(sup);
    var first = true;
    while (i < n) : (i += 1) {
        const b = ts_node_named_child(sup, i);
        const bt = ntype(b);
        if (streq(bt, "keyword_argument")) continue; // metaclass=..., skip
        if (!first) put(",");
        put(text(b, src));
        first = false;
    }
}

fn emitImportNames(imp: TSNode, src: []const u8) void {
    var i: u32 = 0;
    const n = ts_node_named_child_count(imp);
    while (i < n) : (i += 1) {
        const c = ts_node_named_child(imp, i);
        const ct = ntype(c);
        if (streq(ct, "dotted_name") or streq(ct, "identifier")) {
            put("IMPORT|");
            put(text(c, src));
            put("\n");
        } else if (streq(ct, "aliased_import")) {
            const nm = field(c, "name");
            if (!ts_node_is_null(nm)) {
                put("IMPORT|");
                put(text(nm, src));
                put("\n");
            }
        }
    }
}

fn emitCall(call_node: TSNode, src: []const u8, cur_fn: ?[]const u8) void {
    const f = field(call_node, "function");
    if (ts_node_is_null(f)) return;
    const ft = ntype(f);
    var callee: []const u8 = "";
    if (streq(ft, "identifier")) {
        callee = text(f, src);
    } else if (streq(ft, "attribute")) {
        const a = field(f, "attribute"); // the trailing name of a.b.c
        if (ts_node_is_null(a)) return;
        callee = text(a, src);
    } else {
        return;
    }
    if (callee.len == 0) return;
    put("CALL|");
    if (cur_fn) |cf| put(cf);
    put("|");
    put(callee);
    put("\n");
}

// Parse Python source and fill g_buf with the line protocol. Returns on the
// globals (g_buf/g_len); the bridge hands them back to Ring.
pub fn parsePython(src_ptr: [*]const u8, src_len: usize) void {
    g_len = 0;
    const src = src_ptr[0..src_len];
    const parser = ts_parser_new();
    if (parser == null) return;
    defer ts_parser_delete(parser);
    if (!ts_parser_set_language(parser, tree_sitter_python())) return;
    const tree = ts_parser_parse_string(parser, null, src_ptr, @intCast(src_len));
    if (tree == null) return;
    defer ts_tree_delete(tree);
    const root = ts_tree_root_node(tree);
    walk(root, src, null, null, false);
    g_buf[g_len] = 0;
}
