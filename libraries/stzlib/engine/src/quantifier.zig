const std = @import("std");

// ── Quantifier Engine ──────────────────────────────────────────
// Named quantifiers with configurable thresholds. Beyond
// "all/any/none": supports "most", "few", "half", "majority",
// and user-defined quantifiers.

const MAX_QUANTIFIERS = 64;
const MAX_NAME = 64;

const Quantifier = struct {
    name: [MAX_NAME]u8 = [_]u8{0} ** MAX_NAME,
    name_len: u8 = 0,
    min_pct: f64 = 0,
    max_pct: f64 = 100,
    active: bool = false,
};

var quantifiers: [MAX_QUANTIFIERS]Quantifier = [_]Quantifier{.{}} ** MAX_QUANTIFIERS;

fn find_q(name: [*]const u8, nlen: usize) ?usize {
    for (0..MAX_QUANTIFIERS) |i| {
        if (quantifiers[i].active and quantifiers[i].name_len == nlen and
            std.mem.eql(u8, quantifiers[i].name[0..nlen], name[0..nlen]))
            return i;
    }
    return null;
}

pub fn q_define(name: [*]const u8, name_len: i32, min_pct: f64, max_pct: f64) callconv(.c) i32 {
    if (name_len <= 0 or name_len > MAX_NAME) return -1;
    const nlen: usize = @intCast(name_len);
    const idx = find_q(name, nlen) orelse blk: {
        for (0..MAX_QUANTIFIERS) |i| {
            if (!quantifiers[i].active) break :blk i;
        }
        return -2;
    };
    @memcpy(quantifiers[idx].name[0..nlen], name[0..nlen]);
    quantifiers[idx].name_len = @intCast(nlen);
    quantifiers[idx].min_pct = min_pct;
    quantifiers[idx].max_pct = max_pct;
    quantifiers[idx].active = true;
    return @intCast(idx);
}

pub fn q_check(name: [*]const u8, name_len: i32, matched: i64, total: i64) callconv(.c) i32 {
    if (name_len <= 0 or total <= 0) return 0;
    const idx = find_q(name, @intCast(name_len)) orelse return -1;
    const pct = (@as(f64, @floatFromInt(matched)) / @as(f64, @floatFromInt(total))) * 100.0;
    return if (pct >= quantifiers[idx].min_pct and pct <= quantifiers[idx].max_pct) 1 else 0;
}

pub fn q_classify(matched: i64, total: i64, out: [*]u8) callconv(.c) i32 {
    if (total <= 0) return 0;
    const pct = (@as(f64, @floatFromInt(matched)) / @as(f64, @floatFromInt(total))) * 100.0;
    for (0..MAX_QUANTIFIERS) |i| {
        if (quantifiers[i].active and pct >= quantifiers[i].min_pct and pct <= quantifiers[i].max_pct) {
            const nlen = quantifiers[i].name_len;
            @memcpy(out[0..nlen], quantifiers[i].name[0..nlen]);
            return @intCast(nlen);
        }
    }
    return 0;
}

pub fn q_count() callconv(.c) i32 {
    var c: i32 = 0;
    for (0..MAX_QUANTIFIERS) |i| {
        if (quantifiers[i].active) c += 1;
    }
    return c;
}

pub fn q_name_at(idx: i32, out: [*]u8) callconv(.c) i32 {
    if (idx < 0 or idx >= MAX_QUANTIFIERS) return 0;
    const i: usize = @intCast(idx);
    if (!quantifiers[i].active) return 0;
    const nlen = quantifiers[i].name_len;
    @memcpy(out[0..nlen], quantifiers[i].name[0..nlen]);
    return @intCast(nlen);
}

pub fn q_clear() callconv(.c) void {
    for (0..MAX_QUANTIFIERS) |i| {
        quantifiers[i] = .{};
    }
}

pub fn q_init_defaults() callconv(.c) void {
    q_clear();
    _ = q_define("none", 4, 0, 0);
    _ = q_define("few", 3, 0.01, 25);
    _ = q_define("some", 4, 25.01, 49.99);
    _ = q_define("half", 4, 50, 50);
    _ = q_define("most", 4, 50.01, 89.99);
    _ = q_define("nearly_all", 10, 90, 99.99);
    _ = q_define("all", 3, 100, 100);
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_q_define(n: [*]const u8, nl: i32, mn: f64, mx: f64) callconv(.c) i32 { return q_define(n, nl, mn, mx); }
pub export fn stz_q_check(n: [*]const u8, nl: i32, m: i64, t: i64) callconv(.c) i32 { return q_check(n, nl, m, t); }
pub export fn stz_q_classify(m: i64, t: i64, o: [*]u8) callconv(.c) i32 { return q_classify(m, t, o); }
pub export fn stz_q_count() callconv(.c) i32 { return q_count(); }
pub export fn stz_q_name_at(i: i32, o: [*]u8) callconv(.c) i32 { return q_name_at(i, o); }
pub export fn stz_q_clear() callconv(.c) void { q_clear(); }
pub export fn stz_q_init_defaults() callconv(.c) void { q_init_defaults(); }

// ── Tests ────────────────────────────────────────────────────

test "quantifier: define and check" {
    q_clear();
    _ = q_define("all", 3, 100, 100);
    try std.testing.expectEqual(@as(i32, 1), q_check("all", 3, 10, 10));
    try std.testing.expectEqual(@as(i32, 0), q_check("all", 3, 9, 10));
}

test "quantifier: defaults" {
    q_init_defaults();
    try std.testing.expectEqual(@as(i32, 7), q_count());
    try std.testing.expectEqual(@as(i32, 1), q_check("none", 4, 0, 10));
    try std.testing.expectEqual(@as(i32, 1), q_check("all", 3, 10, 10));
    try std.testing.expectEqual(@as(i32, 1), q_check("half", 4, 5, 10));
}

test "quantifier: classify" {
    q_init_defaults();
    var buf: [64]u8 = undefined;
    const len = q_classify(10, 10, &buf);
    try std.testing.expectEqualStrings("all", buf[0..@intCast(len)]);
    const len2 = q_classify(0, 10, &buf);
    try std.testing.expectEqualStrings("none", buf[0..@intCast(len2)]);
}

test "quantifier: name_at" {
    q_clear();
    _ = q_define("majority", 8, 51, 100);
    var buf: [64]u8 = undefined;
    const len = q_name_at(0, &buf);
    try std.testing.expectEqualStrings("majority", buf[0..@intCast(len)]);
}
