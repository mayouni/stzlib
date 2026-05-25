const std = @import("std");

// ─── Resource Tracker Engine ───
// 128-slot named resources with usage tracking (acquired/released/leaked).

const MAX_RESOURCES: usize = 128;
const MAX_NAME: usize = 64;

const ResourceState = enum(u8) {
    free = 0,
    acquired = 1,
    released = 2,
};

const Resource = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    kind: [MAX_NAME]u8 = undefined,
    kind_len: usize = 0,
    state: ResourceState = .free,
    acquire_count: u32 = 0,
    release_count: u32 = 0,
    active: bool = false,
};

var resources: [MAX_RESOURCES]Resource = [_]Resource{.{}} ** MAX_RESOURCES;
var res_count: usize = 0;

fn findByName(name: [*]const u8, len: usize) ?usize {
    for (0..MAX_RESOURCES) |idx| {
        if (resources[idx].active and resources[idx].name_len == len) {
            if (std.mem.eql(u8, resources[idx].name[0..len], name[0..len])) return idx;
        }
    }
    return null;
}

// ─── C ABI ───

pub export fn stz_res_register(name: [*]const u8, name_len: usize, kind: [*]const u8, kind_len: usize) i32 {
    if (findByName(name, name_len) != null) return -2;
    for (0..MAX_RESOURCES) |idx| {
        if (!resources[idx].active) {
            const nl = @min(name_len, MAX_NAME);
            @memcpy(resources[idx].name[0..nl], name[0..nl]);
            resources[idx].name_len = nl;
            const kl = @min(kind_len, MAX_NAME);
            @memcpy(resources[idx].kind[0..kl], kind[0..kl]);
            resources[idx].kind_len = kl;
            resources[idx].state = .free;
            resources[idx].acquire_count = 0;
            resources[idx].release_count = 0;
            resources[idx].active = true;
            res_count += 1;
            return @intCast(idx);
        }
    }
    return -1;
}

pub export fn stz_res_acquire(name: [*]const u8, name_len: usize) i32 {
    const idx = findByName(name, name_len) orelse return 0;
    resources[idx].state = .acquired;
    resources[idx].acquire_count += 1;
    return 1;
}

pub export fn stz_res_release(name: [*]const u8, name_len: usize) i32 {
    const idx = findByName(name, name_len) orelse return 0;
    if (resources[idx].state != .acquired) return 0;
    resources[idx].state = .released;
    resources[idx].release_count += 1;
    return 1;
}

pub export fn stz_res_state(name: [*]const u8, name_len: usize) i32 {
    const idx = findByName(name, name_len) orelse return -1;
    return @intFromEnum(resources[idx].state);
}

pub export fn stz_res_count() i32 {
    return @intCast(res_count);
}

pub export fn stz_res_leaked_count() i32 {
    var count: i32 = 0;
    for (0..MAX_RESOURCES) |idx| {
        if (resources[idx].active and resources[idx].state == .acquired) {
            count += 1;
        }
    }
    return count;
}

pub export fn stz_res_acquire_count(name: [*]const u8, name_len: usize) i32 {
    const idx = findByName(name, name_len) orelse return 0;
    return @intCast(resources[idx].acquire_count);
}

pub export fn stz_res_unregister(name: [*]const u8, name_len: usize) i32 {
    const idx = findByName(name, name_len) orelse return 0;
    resources[idx].active = false;
    res_count -= 1;
    return 1;
}

pub export fn stz_res_clear() void {
    for (0..MAX_RESOURCES) |idx| {
        resources[idx].active = false;
    }
    res_count = 0;
}

// ─── Tests ───

test "register and acquire/release" {
    stz_res_clear();
    const idx = stz_res_register("db_conn", 7, "connection", 10);
    try std.testing.expect(idx >= 0);
    try std.testing.expectEqual(@as(i32, 0), stz_res_state("db_conn", 7));
    _ = stz_res_acquire("db_conn", 7);
    try std.testing.expectEqual(@as(i32, 1), stz_res_state("db_conn", 7));
    _ = stz_res_release("db_conn", 7);
    try std.testing.expectEqual(@as(i32, 2), stz_res_state("db_conn", 7));
    stz_res_clear();
}

test "leak detection" {
    stz_res_clear();
    _ = stz_res_register("a", 1, "file", 4);
    _ = stz_res_register("b", 1, "file", 4);
    _ = stz_res_acquire("a", 1);
    _ = stz_res_acquire("b", 1);
    _ = stz_res_release("a", 1);
    try std.testing.expectEqual(@as(i32, 1), stz_res_leaked_count());
    stz_res_clear();
}

test "acquire count" {
    stz_res_clear();
    _ = stz_res_register("r", 1, "mem", 3);
    _ = stz_res_acquire("r", 1);
    _ = stz_res_release("r", 1);
    _ = stz_res_acquire("r", 1);
    try std.testing.expectEqual(@as(i32, 2), stz_res_acquire_count("r", 1));
    stz_res_clear();
}

test "duplicate register rejected" {
    stz_res_clear();
    _ = stz_res_register("x", 1, "t", 1);
    try std.testing.expectEqual(@as(i32, -2), stz_res_register("x", 1, "t", 1));
    stz_res_clear();
}
