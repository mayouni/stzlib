const std = @import("std");

// ── Embed (compile-time data embedding utilities) ──────────
// Engine version, build info, feature flags. Provides a
// structured way for Ring to query engine capabilities.

const ENGINE_VERSION_MAJOR: u8 = 0;
const ENGINE_VERSION_MINOR: u8 = 8;
const ENGINE_VERSION_PATCH: u8 = 0;

const MAX_FEATURES = 64;
const MAX_FEAT_NAME = 32;

const Feature = struct {
    name: [MAX_FEAT_NAME]u8 = [_]u8{0} ** MAX_FEAT_NAME,
    name_len: usize = 0,
    enabled: bool = false,
    active: bool = false,
};

var features: [MAX_FEATURES]Feature = [_]Feature{.{}} ** MAX_FEATURES;

pub fn embed_version_major() callconv(.c) u8 { return ENGINE_VERSION_MAJOR; }
pub fn embed_version_minor() callconv(.c) u8 { return ENGINE_VERSION_MINOR; }
pub fn embed_version_patch() callconv(.c) u8 { return ENGINE_VERSION_PATCH; }

pub fn embed_version_string(out: [*]u8, max: usize) callconv(.c) i32 {
    const ver = std.fmt.bufPrint(out[0..max], "{d}.{d}.{d}", .{ ENGINE_VERSION_MAJOR, ENGINE_VERSION_MINOR, ENGINE_VERSION_PATCH }) catch return -1;
    return @intCast(ver.len);
}

pub fn embed_build_os(out: [*]u8, max: usize) callconv(.c) i32 {
    const os_name = @tagName(@import("builtin").os.tag);
    if (os_name.len > max) return -1;
    @memcpy(out[0..os_name.len], os_name);
    return @intCast(os_name.len);
}

pub fn embed_build_arch(out: [*]u8, max: usize) callconv(.c) i32 {
    const arch = @tagName(@import("builtin").cpu.arch);
    if (arch.len > max) return -1;
    @memcpy(out[0..arch.len], arch);
    return @intCast(arch.len);
}

pub fn embed_register_feature(name_ptr: [*]const u8, name_len: usize, enabled: i32) callconv(.c) i32 {
    if (name_len > MAX_FEAT_NAME) return -1;
    for (0..MAX_FEATURES) |i| {
        if (features[i].active and features[i].name_len == name_len and
            std.mem.eql(u8, features[i].name[0..name_len], name_ptr[0..name_len]))
        {
            features[i].enabled = (enabled != 0);
            return @intCast(i);
        }
    }
    for (0..MAX_FEATURES) |i| {
        if (!features[i].active) {
            @memcpy(features[i].name[0..name_len], name_ptr[0..name_len]);
            features[i].name_len = name_len;
            features[i].enabled = (enabled != 0);
            features[i].active = true;
            return @intCast(i);
        }
    }
    return -2;
}

pub fn embed_has_feature(name_ptr: [*]const u8, name_len: usize) callconv(.c) i32 {
    for (0..MAX_FEATURES) |i| {
        if (features[i].active and features[i].name_len == name_len and
            std.mem.eql(u8, features[i].name[0..name_len], name_ptr[0..name_len]))
        {
            return if (features[i].enabled) 1 else 0;
        }
    }
    return -1;
}

pub fn embed_feature_count() callconv(.c) u32 {
    var count: u32 = 0;
    for (0..MAX_FEATURES) |i| {
        if (features[i].active) count += 1;
    }
    return count;
}

pub fn embed_clear_features() callconv(.c) void {
    for (0..MAX_FEATURES) |i| features[i].active = false;
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_embed_version_major() callconv(.c) u8 { return embed_version_major(); }
pub export fn stz_embed_version_minor() callconv(.c) u8 { return embed_version_minor(); }
pub export fn stz_embed_version_patch() callconv(.c) u8 { return embed_version_patch(); }
pub export fn stz_embed_version_string(o: [*]u8, m: usize) callconv(.c) i32 { return embed_version_string(o, m); }
pub export fn stz_embed_build_os(o: [*]u8, m: usize) callconv(.c) i32 { return embed_build_os(o, m); }
pub export fn stz_embed_build_arch(o: [*]u8, m: usize) callconv(.c) i32 { return embed_build_arch(o, m); }
pub export fn stz_embed_register_feature(p: [*]const u8, l: usize, e: i32) callconv(.c) i32 { return embed_register_feature(p, l, e); }
pub export fn stz_embed_has_feature(p: [*]const u8, l: usize) callconv(.c) i32 { return embed_has_feature(p, l); }
pub export fn stz_embed_feature_count() callconv(.c) u32 { return embed_feature_count(); }
pub export fn stz_embed_clear_features() callconv(.c) void { embed_clear_features(); }

// ── Tests ────────────────────────────────────────────────────

test "embed: version" {
    try std.testing.expectEqual(@as(u8, 0), embed_version_major());
    try std.testing.expectEqual(@as(u8, 8), embed_version_minor());
    var buf: [32]u8 = undefined;
    const len = embed_version_string(&buf, 32);
    try std.testing.expectEqualStrings("0.8.0", buf[0..@intCast(len)]);
}

test "embed: build info" {
    var buf: [64]u8 = undefined;
    const os_len = embed_build_os(&buf, 64);
    try std.testing.expect(os_len > 0);
    const arch_len = embed_build_arch(&buf, 64);
    try std.testing.expect(arch_len > 0);
}

test "embed: features" {
    embed_clear_features();
    _ = embed_register_feature("unicode".ptr, 7, 1);
    _ = embed_register_feature("pcre2".ptr, 5, 1);
    try std.testing.expectEqual(@as(i32, 1), embed_has_feature("unicode".ptr, 7));
    try std.testing.expectEqual(@as(u32, 2), embed_feature_count());
    _ = embed_register_feature("unicode".ptr, 7, 0);
    try std.testing.expectEqual(@as(i32, 0), embed_has_feature("unicode".ptr, 7));
}

test "embed: unknown feature" {
    embed_clear_features();
    try std.testing.expectEqual(@as(i32, -1), embed_has_feature("nope".ptr, 4));
}
