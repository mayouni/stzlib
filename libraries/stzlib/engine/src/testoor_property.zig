//! Testoor core -- THE PROPERTY RECORD, step V2 (TESTOOR_PROTOCOL_3.md section 4).
//!
//! A tour checks a property over a domain in ONE walk and prints one line:
//!
//!   [testoor property {"id":"SQUARE-UNDER-50","nodes":["stzMath.Square"],"domain":"n int 0..100","seed":7,
//!                      "tried":3,"of":101,"exhaustive":false,"held":false,"counterexample":{"n":8},"shrinks":5}]
//!
//! This file reads that line (a line that is not a JSON object with `id`, `held` and `tried` is ignored), writes the
//! record back in the core's key order, and answers the three operations a face asks of the core: the inputs of a
//! domain, the shrink candidates of a failing input, and the canonical line of a record.

const std = @import("std");
const T = @import("testoor_text.zig");
const J = @import("testoor_json.zig");
const D = @import("testoor_domain.zig");

const Allocator = std.mem.Allocator;
const Buf = T.Buf;

pub const Record = struct {
    id: []const u8,
    nodes: ?[]const []const u8 = null,
    domain: ?[]const u8 = null,
    seed: ?f64 = null,
    tried: i64,
    of: ?i64 = null,
    exhaustive: bool = false,
    held: bool,
    counterexample: ?J.Value = null,
    shrinks: ?i64 = null,
};

const prefix = "[testoor property ";

fn hasSpace(s: []const u8) bool {
    for (s) |ch| if (ch <= 32) return true;
    return false;
}

fn isWhole(v: J.Value) bool {
    return switch (v) {
        .num => |n| std.math.isFinite(n) and n == @floor(n) and @abs(n) < 9.0e15,
        else => false,
    };
}

/// a record from a JSON object, or null when it lacks what a record needs
pub fn fromValue(a: Allocator, v: J.Value) !?Record {
    switch (v) {
        .obj => {},
        else => return null,
    }
    const id = v.get("id") orelse return null;
    const held = v.get("held") orelse return null;
    const tried = v.get("tried") orelse return null;
    switch (id) {
        .str => {},
        else => return null,
    }
    if (id.str_().len == 0 or hasSpace(id.str_())) return null;
    switch (held) {
        .bool => {},
        else => return null,
    }
    if (!isWhole(tried) or tried.int_() < 0) return null;
    var r = Record{ .id = id.str_(), .tried = tried.int_(), .held = held.truthy() };
    if (v.get("nodes")) |nv| {
        var ns: std.ArrayList([]const u8) = .empty;
        for (nv.items()) |n| switch (n) {
            .str => |s| try ns.append(a, s),
            else => {},
        };
        r.nodes = ns.items;
    }
    if (v.get("domain")) |x| switch (x) {
        .str => |s| r.domain = s,
        else => {},
    };
    if (v.get("seed")) |x| switch (x) {
        .num => |n| r.seed = n,
        else => {},
    };
    if (v.get("of")) |x| if (isWhole(x) and x.int_() >= 0) {
        r.of = x.int_();
    };
    if (v.get("exhaustive")) |x| r.exhaustive = x.truthy();
    if (!r.held) {
        r.counterexample = v.get("counterexample");
        if (v.get("shrinks")) |x| if (isWhole(x) and x.int_() >= 0) {
            r.shrinks = x.int_();
        };
    }
    return r;
}

/// `[testoor property {...}]`, trimmed; null when it is not one, or is malformed (it then stays ordinary output)
pub fn parseLine(a: Allocator, t: []const u8) !?Record {
    if (!T.startsWith(t, prefix) or t.len < prefix.len + 2 or t[t.len - 1] != ']') return null;
    const body = T.trimSp(t[prefix.len .. t.len - 1]);
    if (body.len == 0 or body[0] != '{') return null;
    const v = J.parse(a, body) catch return null;
    return fromValue(a, v);
}

/// a cheap test a reader can make without parsing: the line has a property's shape
pub fn looksLikeLine(t: []const u8) bool {
    return T.startsWith(t, prefix ++ "{") and t.len > prefix.len + 2 and t[t.len - 1] == ']' and t[t.len - 2] == '}';
}

/// a JSON value written back: objects in their order, text with the five escapes, numbers as the core prints them
pub fn writeValue(b: *Buf, v: J.Value) error{OutOfMemory}!void {
    switch (v) {
        .null => try b.s("null"),
        .bool => |x| try b.s(if (x) "true" else "false"),
        .num => |n| try b.num(n),
        .str => |s| try b.js(s),
        .arr => |xs| {
            try b.c('[');
            for (xs, 0..) |x, i| {
                if (i > 0) try b.c(',');
                try writeValue(b, x);
            }
            try b.c(']');
        },
        .obj => |ps| {
            try b.c('{');
            for (ps, 0..) |p, i| {
                if (i > 0) try b.c(',');
                try b.js(p.key);
                try b.c(':');
                try writeValue(b, p.val);
            }
            try b.c('}');
        },
    }
}

/// the record, keys in the order of TESTOOR_PROTOCOL_3.md 4.4, each only when it has something to say
pub fn writeRecord(b: *Buf, r: Record) !void {
    try b.s("{\"id\":");
    try b.js(r.id);
    if (r.nodes) |ns| {
        try b.s(",\"nodes\":[");
        for (ns, 0..) |n, i| {
            if (i > 0) try b.c(',');
            try b.js(n);
        }
        try b.c(']');
    }
    if (r.domain) |d| {
        try b.s(",\"domain\":");
        try b.js(d);
    }
    if (r.seed) |s| {
        try b.s(",\"seed\":");
        try b.num(s);
    }
    try b.s(",\"tried\":");
    try b.int(r.tried);
    if (r.of) |o| {
        try b.s(",\"of\":");
        try b.int(o);
    }
    try b.s(",\"exhaustive\":");
    try b.s(if (r.exhaustive) "true" else "false");
    try b.s(",\"held\":");
    try b.s(if (r.held) "true" else "false");
    if (!r.held) {
        if (r.counterexample) |c| {
            try b.s(",\"counterexample\":");
            try writeValue(b, c);
        }
        if (r.shrinks) |s| {
            try b.s(",\"shrinks\":");
            try b.int(s);
        }
    }
    try b.c('}');
}

/// the line under a tour's prose for a property that did not hold
pub fn writeCounterexample(b: *Buf, r: Record) !void {
    try b.s("    counterexample  ");
    try b.s(r.id);
    try b.s("  ");
    if (r.counterexample) |c| try writeValue(b, c) else try b.s("(none given)");
    try b.s("  (");
    if (r.seed) |s| {
        try b.s("seed ");
        try b.num(s);
    } else try b.s("no seed");
    const n = r.shrinks orelse 0;
    try b.s(", ");
    try b.int(n);
    try b.s(if (n == 1) " shrink)" else " shrinks)");
}

// ── the three operations a face asks ─────────────────────────

pub const OpError = error{ BadRequest, BadDomain, OutOfMemory };

fn writeInputs(b: *Buf, d: D.Domain, ins: []const D.Input, key: []const u8, comma: bool) !void {
    if (comma) try b.c(',');
    try b.c('"');
    try b.s(key);
    try b.s("\":[");
    for (ins, 0..) |in, i| {
        if (i > 0) try b.c(',');
        try D.writeInput(b, d, in);
    }
    try b.s("],\"texts\":[");
    for (ins, 0..) |in, i| {
        if (i > 0) try b.c(',');
        var t = Buf.init(b.a);
        try D.writeInput(&t, d, in);
        try b.js(try t.done());
    }
    try b.c(']');
}

/// {"op":"inputs","domain":..,"seed":..,"tries":..} -> {"exhaustive":..,"of":..,"inputs":[..],"texts":[..]}
/// {"op":"shrink","domain":..,"input":{..}}          -> {"candidates":[..],"texts":[..]}
/// {"op":"line","record":{..}}                       -> the line a tour prints
pub fn op(a: Allocator, req: J.Value) OpError![]u8 {
    const name = (req.get("op") orelse return OpError.BadRequest).str_();
    var b = Buf.init(a);
    if (std.mem.eql(u8, name, "line")) {
        const r = (fromValue(a, req.get("record") orelse return OpError.BadRequest) catch return OpError.OutOfMemory) orelse
            return OpError.BadRequest;
        b.s(prefix) catch return OpError.OutOfMemory;
        writeRecord(&b, r) catch return OpError.OutOfMemory;
        b.c(']') catch return OpError.OutOfMemory;
        return b.done() catch OpError.OutOfMemory;
    }
    const dv = req.get("domain") orelse return OpError.BadRequest;
    const d = D.parse(a, dv.str_()) catch |e| return if (e == error.OutOfMemory) OpError.OutOfMemory else OpError.BadDomain;
    if (std.mem.eql(u8, name, "inputs")) {
        const seed = if (req.get("seed")) |s| s.num_() else 0;
        const tries_v = req.get("tries") orelse return OpError.BadRequest;
        if (!isWhole(tries_v) or tries_v.int_() < 1 or tries_v.int_() > 1_000_000) return OpError.BadRequest;
        const r = D.inputs(a, d, seed, @intCast(tries_v.int_())) catch |e| return if (e == error.OutOfMemory) OpError.OutOfMemory else OpError.BadDomain;
        b.s("{\"exhaustive\":") catch return OpError.OutOfMemory;
        b.s(if (r.exhaustive) "true" else "false") catch return OpError.OutOfMemory;
        if (r.of) |o| {
            b.s(",\"of\":") catch return OpError.OutOfMemory;
            b.int(@intCast(o)) catch return OpError.OutOfMemory;
        }
        writeInputs(&b, d, r.inputs, "inputs", true) catch return OpError.OutOfMemory;
        b.c('}') catch return OpError.OutOfMemory;
        return b.done() catch OpError.OutOfMemory;
    }
    if (std.mem.eql(u8, name, "shrink")) {
        const in = D.readInput(a, d, req.get("input") orelse return OpError.BadRequest) catch |e|
            return if (e == error.OutOfMemory) OpError.OutOfMemory else OpError.BadDomain;
        const cs = D.shrink(a, d, in) catch |e| return if (e == error.OutOfMemory) OpError.OutOfMemory else OpError.BadDomain;
        b.c('{') catch return OpError.OutOfMemory;
        writeInputs(&b, d, cs, "candidates", false) catch return OpError.OutOfMemory;
        b.c('}') catch return OpError.OutOfMemory;
        return b.done() catch OpError.OutOfMemory;
    }
    return OpError.BadRequest;
}

// ── tests ────────────────────────────────────────────────────

const testing = std.testing;

test "a line is read, malformed ones are ignored, and the record is written back in order" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const r = (try parseLine(a, "[testoor property {\"held\":false,\"tried\":3,\"id\":\"SQ\",\"counterexample\":{\"n\":8},\"shrinks\":5,\"seed\":7}]")).?;
    var b = Buf.init(a);
    try writeRecord(&b, r);
    try testing.expectEqualStrings("{\"id\":\"SQ\",\"seed\":7,\"tried\":3,\"exhaustive\":false,\"held\":false,\"counterexample\":{\"n\":8},\"shrinks\":5}", try b.done());
    try testing.expect((try parseLine(a, "[testoor property not json]")) == null);
    try testing.expect((try parseLine(a, "[testoor property {\"id\":\"X\",\"tried\":3}]")) == null); // no held
    try testing.expect((try parseLine(a, "[testoor property {\"id\":\"a b\",\"tried\":1,\"held\":true}]")) == null); // a space
    try testing.expect((try parseLine(a, "[testoor property {\"id\":\"X\",\"tried\":1.5,\"held\":true}]")) == null);
    // a counterexample on a property that held is dropped
    const h = (try parseLine(a, "[testoor property {\"id\":\"H\",\"tried\":2,\"held\":true,\"counterexample\":{\"n\":1}}]")).?;
    var hb = Buf.init(a);
    try writeRecord(&hb, h);
    try testing.expectEqualStrings("{\"id\":\"H\",\"tried\":2,\"exhaustive\":false,\"held\":true}", try hb.done());
}

test "the operations: inputs, shrink, line" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const ins = try op(a, try J.parse(a, "{\"op\":\"inputs\",\"domain\":\"a one x|y\",\"seed\":1,\"tries\":5}"));
    try testing.expectEqualStrings("{\"exhaustive\":true,\"of\":2,\"inputs\":[{\"a\":\"x\"},{\"a\":\"y\"}],\"texts\":[\"{\\\"a\\\":\\\"x\\\"}\",\"{\\\"a\\\":\\\"y\\\"}\"]}", ins);
    const sh = try op(a, try J.parse(a, "{\"op\":\"shrink\",\"domain\":\"n int 0..4\",\"input\":{\"n\":4}}"));
    try testing.expectEqualStrings("{\"candidates\":[{\"n\":0},{\"n\":2},{\"n\":3}],\"texts\":[\"{\\\"n\\\":0}\",\"{\\\"n\\\":2}\",\"{\\\"n\\\":3}\"]}", sh);
    const ln = try op(a, try J.parse(a, "{\"op\":\"line\",\"record\":{\"held\":true,\"id\":\"P\",\"tried\":2,\"of\":2,\"exhaustive\":true,\"domain\":\"a one x|y\"}}"));
    try testing.expectEqualStrings("[testoor property {\"id\":\"P\",\"domain\":\"a one x|y\",\"tried\":2,\"of\":2,\"exhaustive\":true,\"held\":true}]", ln);
    try testing.expectError(OpError.BadDomain, op(a, try J.parse(a, "{\"op\":\"inputs\",\"domain\":\"n int 9..1\",\"tries\":3}")));
    try testing.expectError(OpError.BadDomain, op(a, try J.parse(a, "{\"op\":\"shrink\",\"domain\":\"n int 0..4\",\"input\":{\"n\":9}}")));
    try testing.expectError(OpError.BadRequest, op(a, try J.parse(a, "{\"op\":\"guess\",\"domain\":\"n int 0..4\"}")));
}
