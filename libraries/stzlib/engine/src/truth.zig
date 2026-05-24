const std = @import("std");

// ── Truth Engine ───────────────────────────────────────────────
// Domain-configurable truth values. Beyond boolean: supports
// maybe/unknown/partial/forbidden states. Softanza's answer to
// three-valued logic and beyond.

const MAX_DOMAINS = 32;
const MAX_NAME = 64;
const MAX_VALUES = 16;
const MAX_VAL_NAME = 32;

const TruthValue = struct {
    name: [MAX_VAL_NAME]u8 = [_]u8{0} ** MAX_VAL_NAME,
    name_len: u8 = 0,
    rank: i32 = 0,
    active: bool = false,
};

const TruthDomain = struct {
    name: [MAX_NAME]u8 = [_]u8{0} ** MAX_NAME,
    name_len: u8 = 0,
    values: [MAX_VALUES]TruthValue = [_]TruthValue{.{}} ** MAX_VALUES,
    value_count: u8 = 0,
    active: bool = false,
};

var domains: [MAX_DOMAINS]TruthDomain = [_]TruthDomain{.{}} ** MAX_DOMAINS;

fn find_domain(name: [*]const u8, nlen: usize) ?usize {
    for (0..MAX_DOMAINS) |i| {
        if (domains[i].active and domains[i].name_len == nlen and
            std.mem.eql(u8, domains[i].name[0..nlen], name[0..nlen]))
            return i;
    }
    return null;
}

pub fn truth_create_domain(name: [*]const u8, name_len: i32) callconv(.c) i32 {
    if (name_len <= 0 or name_len > MAX_NAME) return -1;
    const nlen: usize = @intCast(name_len);
    if (find_domain(name, nlen) != null) return -2;
    for (0..MAX_DOMAINS) |i| {
        if (!domains[i].active) {
            @memcpy(domains[i].name[0..nlen], name[0..nlen]);
            domains[i].name_len = @intCast(nlen);
            domains[i].value_count = 0;
            domains[i].active = true;
            return @intCast(i);
        }
    }
    return -3;
}

pub fn truth_add_value(domain: [*]const u8, domain_len: i32, val_name: [*]const u8, val_len: i32, rank: i32) callconv(.c) i32 {
    if (domain_len <= 0 or val_len <= 0 or val_len > MAX_VAL_NAME) return -1;
    const dlen: usize = @intCast(domain_len);
    const vlen: usize = @intCast(val_len);
    const didx = find_domain(domain, dlen) orelse return -2;
    if (domains[didx].value_count >= MAX_VALUES) return -3;
    const vidx: usize = domains[didx].value_count;
    @memcpy(domains[didx].values[vidx].name[0..vlen], val_name[0..vlen]);
    domains[didx].values[vidx].name_len = @intCast(vlen);
    domains[didx].values[vidx].rank = rank;
    domains[didx].values[vidx].active = true;
    domains[didx].value_count += 1;
    return @intCast(vidx);
}

pub fn truth_value_count(domain: [*]const u8, domain_len: i32) callconv(.c) i32 {
    if (domain_len <= 0) return 0;
    const didx = find_domain(domain, @intCast(domain_len)) orelse return 0;
    return @intCast(domains[didx].value_count);
}

pub fn truth_value_name(domain: [*]const u8, domain_len: i32, val_idx: i32, out: [*]u8) callconv(.c) i32 {
    if (domain_len <= 0 or val_idx < 0) return 0;
    const didx = find_domain(domain, @intCast(domain_len)) orelse return 0;
    const vi: usize = @intCast(val_idx);
    if (vi >= domains[didx].value_count) return 0;
    const vlen = domains[didx].values[vi].name_len;
    @memcpy(out[0..vlen], domains[didx].values[vi].name[0..vlen]);
    return @intCast(vlen);
}

pub fn truth_value_rank(domain: [*]const u8, domain_len: i32, val_idx: i32) callconv(.c) i32 {
    if (domain_len <= 0 or val_idx < 0) return -1;
    const didx = find_domain(domain, @intCast(domain_len)) orelse return -1;
    const vi: usize = @intCast(val_idx);
    if (vi >= domains[didx].value_count) return -1;
    return domains[didx].values[vi].rank;
}

pub fn truth_compare(domain: [*]const u8, domain_len: i32, a: i32, b: i32) callconv(.c) i32 {
    if (domain_len <= 0 or a < 0 or b < 0) return 0;
    const didx = find_domain(domain, @intCast(domain_len)) orelse return 0;
    const ai: usize = @intCast(a);
    const bi: usize = @intCast(b);
    if (ai >= domains[didx].value_count or bi >= domains[didx].value_count) return 0;
    const ra = domains[didx].values[ai].rank;
    const rb = domains[didx].values[bi].rank;
    if (ra < rb) return -1;
    if (ra > rb) return 1;
    return 0;
}

pub fn truth_domain_count() callconv(.c) i32 {
    var c: i32 = 0;
    for (0..MAX_DOMAINS) |i| {
        if (domains[i].active) c += 1;
    }
    return c;
}

pub fn truth_clear() callconv(.c) void {
    for (0..MAX_DOMAINS) |i| {
        domains[i] = .{};
    }
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_truth_create_domain(n: [*]const u8, nl: i32) callconv(.c) i32 { return truth_create_domain(n, nl); }
pub export fn stz_truth_add_value(d: [*]const u8, dl: i32, v: [*]const u8, vl: i32, r: i32) callconv(.c) i32 { return truth_add_value(d, dl, v, vl, r); }
pub export fn stz_truth_value_count(d: [*]const u8, dl: i32) callconv(.c) i32 { return truth_value_count(d, dl); }
pub export fn stz_truth_value_name(d: [*]const u8, dl: i32, vi: i32, o: [*]u8) callconv(.c) i32 { return truth_value_name(d, dl, vi, o); }
pub export fn stz_truth_value_rank(d: [*]const u8, dl: i32, vi: i32) callconv(.c) i32 { return truth_value_rank(d, dl, vi); }
pub export fn stz_truth_compare(d: [*]const u8, dl: i32, a: i32, b: i32) callconv(.c) i32 { return truth_compare(d, dl, a, b); }
pub export fn stz_truth_domain_count() callconv(.c) i32 { return truth_domain_count(); }
pub export fn stz_truth_clear() callconv(.c) void { truth_clear(); }

// ── Tests ────────────────────────────────────────────────────

test "truth: create domain and add values" {
    truth_clear();
    const idx = truth_create_domain("boolean", 7);
    try std.testing.expect(idx >= 0);
    _ = truth_add_value("boolean", 7, "false", 5, 0);
    _ = truth_add_value("boolean", 7, "true", 4, 1);
    try std.testing.expectEqual(@as(i32, 2), truth_value_count("boolean", 7));
}

test "truth: three-valued logic" {
    truth_clear();
    _ = truth_create_domain("3val", 4);
    _ = truth_add_value("3val", 4, "false", 5, 0);
    _ = truth_add_value("3val", 4, "maybe", 5, 1);
    _ = truth_add_value("3val", 4, "true", 4, 2);
    try std.testing.expectEqual(@as(i32, 3), truth_value_count("3val", 4));
}

test "truth: value name and rank" {
    truth_clear();
    _ = truth_create_domain("test", 4);
    _ = truth_add_value("test", 4, "low", 3, 10);
    _ = truth_add_value("test", 4, "high", 4, 20);
    var buf: [32]u8 = undefined;
    const len = truth_value_name("test", 4, 0, &buf);
    try std.testing.expectEqualStrings("low", buf[0..@intCast(len)]);
    try std.testing.expectEqual(@as(i32, 10), truth_value_rank("test", 4, 0));
}

test "truth: compare values" {
    truth_clear();
    _ = truth_create_domain("tri", 3);
    _ = truth_add_value("tri", 3, "no", 2, 0);
    _ = truth_add_value("tri", 3, "maybe", 5, 5);
    _ = truth_add_value("tri", 3, "yes", 3, 10);
    try std.testing.expectEqual(@as(i32, -1), truth_compare("tri", 3, 0, 1));
    try std.testing.expectEqual(@as(i32, 1), truth_compare("tri", 3, 2, 0));
    try std.testing.expectEqual(@as(i32, 0), truth_compare("tri", 3, 1, 1));
}

test "truth: domain count" {
    truth_clear();
    _ = truth_create_domain("a", 1);
    _ = truth_create_domain("b", 1);
    try std.testing.expectEqual(@as(i32, 2), truth_domain_count());
}
