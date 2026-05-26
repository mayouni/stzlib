const std = @import("std");

// ── Adverb Engine ──────────────────────────────────────────────
// Modifiers that transform operations: caseless, reversed,
// unique, sorted, bounded, etc. The Softanza suffix system
// (CS, XT, Q, Z, ZZ, W, IB) implemented as composable flags.

const MAX_ADVERBS = 64;
const MAX_NAME = 32;

const Adverb = struct {
    name: [MAX_NAME]u8 = [_]u8{0} ** MAX_NAME,
    name_len: u8 = 0,
    flag_bits: u32 = 0,
    active: bool = false,
};

pub const Flags = struct {
    pub const CASELESS: u32 = 1;
    pub const REVERSED: u32 = 2;
    pub const UNIQUE: u32 = 4;
    pub const SORTED: u32 = 8;
    pub const BOUNDED: u32 = 16;
    pub const FLUENT: u32 = 32;
    pub const EXTENDED: u32 = 64;
    pub const INDEX_BASED: u32 = 128;
    pub const DEEP: u32 = 256;
    pub const WIDENED: u32 = 512;
};

var adverbs: [MAX_ADVERBS]Adverb = [_]Adverb{.{}} ** MAX_ADVERBS;

fn find_adverb(name: [*]const u8, nlen: usize) ?usize {
    for (0..MAX_ADVERBS) |i| {
        if (adverbs[i].active and adverbs[i].name_len == nlen and
            std.mem.eql(u8, adverbs[i].name[0..nlen], name[0..nlen]))
            return i;
    }
    return null;
}

pub fn adv_define(name: [*]const u8, name_len: i32, flags: u32) callconv(.c) i32 {
    if (name_len <= 0 or name_len > MAX_NAME) return -1;
    const nlen: usize = @intCast(name_len);
    const idx = find_adverb(name, nlen) orelse blk: {
        for (0..MAX_ADVERBS) |i| {
            if (!adverbs[i].active) break :blk i;
        }
        return -2;
    };
    @memcpy(adverbs[idx].name[0..nlen], name[0..nlen]);
    adverbs[idx].name_len = @intCast(nlen);
    adverbs[idx].flag_bits = flags;
    adverbs[idx].active = true;
    return @intCast(idx);
}

pub fn adv_flags(name: [*]const u8, name_len: i32) callconv(.c) u32 {
    if (name_len <= 0) return 0;
    const idx = find_adverb(name, @intCast(name_len)) orelse return 0;
    return adverbs[idx].flag_bits;
}

pub fn adv_has_flag(name: [*]const u8, name_len: i32, flag: u32) callconv(.c) i32 {
    const flags = adv_flags(name, name_len);
    return if (flags & flag != 0) 1 else 0;
}

pub fn adv_compose(a_name: [*]const u8, a_len: i32, b_name: [*]const u8, b_len: i32) callconv(.c) u32 {
    const fa = adv_flags(a_name, a_len);
    const fb = adv_flags(b_name, b_len);
    return fa | fb;
}

pub fn adv_count() callconv(.c) i32 {
    var c: i32 = 0;
    for (0..MAX_ADVERBS) |i| {
        if (adverbs[i].active) c += 1;
    }
    return c;
}

pub fn adv_clear() callconv(.c) void {
    for (0..MAX_ADVERBS) |i| {
        adverbs[i] = .{};
    }
}

pub fn adv_init_defaults() callconv(.c) void {
    adv_clear();
    _ = adv_define("CS", 2, Flags.CASELESS);
    _ = adv_define("XT", 2, Flags.EXTENDED);
    _ = adv_define("Q", 1, Flags.FLUENT);
    _ = adv_define("IB", 2, Flags.INDEX_BASED);
    _ = adv_define("Z", 1, Flags.REVERSED);
    _ = adv_define("ZZ", 2, Flags.REVERSED | Flags.DEEP);
    _ = adv_define("W", 1, Flags.WIDENED);
    _ = adv_define("U", 1, Flags.UNIQUE);
    _ = adv_define("S", 1, Flags.SORTED);
    _ = adv_define("B", 1, Flags.BOUNDED);
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_adv_define(n: [*]const u8, nl: i32, f: u32) callconv(.c) i32 { return adv_define(n, nl, f); }
pub export fn stz_adv_flags(n: [*]const u8, nl: i32) callconv(.c) u32 { return adv_flags(n, nl); }
pub export fn stz_adv_has_flag(n: [*]const u8, nl: i32, f: u32) callconv(.c) i32 { return adv_has_flag(n, nl, f); }
pub export fn stz_adv_compose(a: [*]const u8, al: i32, b: [*]const u8, bl: i32) callconv(.c) u32 { return adv_compose(a, al, b, bl); }
pub export fn stz_adv_count() callconv(.c) i32 { return adv_count(); }
pub export fn stz_adv_clear() callconv(.c) void { adv_clear(); }
pub export fn stz_adv_init_defaults() callconv(.c) void { adv_init_defaults(); }

// ── Tests ────────────────────────────────────────────────────

test "adverb: define and query flags" {
    adv_clear();
    _ = adv_define("CS", 2, Flags.CASELESS);
    try std.testing.expectEqual(Flags.CASELESS, adv_flags("CS", 2));
    try std.testing.expectEqual(@as(i32, 1), adv_has_flag("CS", 2, Flags.CASELESS));
    try std.testing.expectEqual(@as(i32, 0), adv_has_flag("CS", 2, Flags.REVERSED));
}

test "adverb: compose" {
    adv_clear();
    _ = adv_define("CS", 2, Flags.CASELESS);
    _ = adv_define("Z", 1, Flags.REVERSED);
    const combined = adv_compose("CS", 2, "Z", 1);
    try std.testing.expectEqual(Flags.CASELESS | Flags.REVERSED, combined);
}

test "adverb: defaults" {
    adv_init_defaults();
    try std.testing.expectEqual(@as(i32, 10), adv_count());
    try std.testing.expectEqual(@as(i32, 1), adv_has_flag("Q", 1, Flags.FLUENT));
    try std.testing.expectEqual(@as(i32, 1), adv_has_flag("ZZ", 2, Flags.DEEP));
    try std.testing.expectEqual(@as(i32, 1), adv_has_flag("ZZ", 2, Flags.REVERSED));
}

test "adverb: overwrite" {
    adv_clear();
    _ = adv_define("X", 1, Flags.CASELESS);
    _ = adv_define("X", 1, Flags.REVERSED);
    try std.testing.expectEqual(Flags.REVERSED, adv_flags("X", 1));
    try std.testing.expectEqual(@as(i32, 1), adv_count());
}

test "adverb: invalid name length" {
    adv_clear();
    try std.testing.expectEqual(@as(i32, -1), adv_define("x", 0, Flags.CASELESS));
    try std.testing.expectEqual(@as(i32, -1), adv_define("x", -1, Flags.CASELESS));
}

test "adverb: unknown adverb returns 0 flags" {
    adv_clear();
    try std.testing.expectEqual(@as(u32, 0), adv_flags("UNKNOWN", 7));
    try std.testing.expectEqual(@as(i32, 0), adv_has_flag("UNKNOWN", 7, Flags.CASELESS));
}

test "adverb: compose unknown adverbs returns 0" {
    adv_clear();
    try std.testing.expectEqual(@as(u32, 0), adv_compose("A", 1, "B", 1));
}

test "adverb: multi-flag composition" {
    adv_clear();
    _ = adv_define("CSXT", 4, Flags.CASELESS | Flags.EXTENDED);
    try std.testing.expectEqual(@as(i32, 1), adv_has_flag("CSXT", 4, Flags.CASELESS));
    try std.testing.expectEqual(@as(i32, 1), adv_has_flag("CSXT", 4, Flags.EXTENDED));
    try std.testing.expectEqual(@as(i32, 0), adv_has_flag("CSXT", 4, Flags.FLUENT));
}

test "adverb: clear then redefine" {
    adv_clear();
    _ = adv_define("A", 1, Flags.CASELESS);
    adv_clear();
    try std.testing.expectEqual(@as(i32, 0), adv_count());
    try std.testing.expectEqual(@as(u32, 0), adv_flags("A", 1));
    _ = adv_define("A", 1, Flags.REVERSED);
    try std.testing.expectEqual(Flags.REVERSED, adv_flags("A", 1));
}

test "adverb: all softanza suffixes covered" {
    adv_init_defaults();
    // Verify all documented suffixes
    try std.testing.expect(adv_flags("CS", 2) != 0);
    try std.testing.expect(adv_flags("XT", 2) != 0);
    try std.testing.expect(adv_flags("Q", 1) != 0);
    try std.testing.expect(adv_flags("IB", 2) != 0);
    try std.testing.expect(adv_flags("Z", 1) != 0);
    try std.testing.expect(adv_flags("ZZ", 2) != 0);
    try std.testing.expect(adv_flags("W", 1) != 0);
    try std.testing.expect(adv_flags("U", 1) != 0);
    try std.testing.expect(adv_flags("S", 1) != 0);
    try std.testing.expect(adv_flags("B", 1) != 0);
}
