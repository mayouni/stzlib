const std = @import("std");

// ── Reactive Engine ────────────────────────────────────────────
// Observable streams with typed channels, subscriptions, and
// event dispatch. Foundation for Reaxis paradigm engine.

const MAX_CHANNELS = 64;
const MAX_SUBS_PER_CHANNEL = 16;
const MAX_NAME = 64;
const MAX_EVENT_DATA = 256;

const Subscription = struct {
    active: bool = false,
    channel_idx: u8 = 0,
    id: u32 = 0,
};

const Channel = struct {
    name: [MAX_NAME]u8 = [_]u8{0} ** MAX_NAME,
    name_len: u8 = 0,
    active: bool = false,
    sub_count: u16 = 0,
    event_count: u64 = 0,
    // A channel's identity across its whole life in this process. Handed out
    // by next_generation, which NEVER resets -- not on destroy, not on
    // clear_all -- so no two channels in one run ever share one, and a
    // consumer that stored a generation can tell "the channel I was watching"
    // from "a new channel wearing its name".
    generation: u64 = 0,
    last_event: [MAX_EVENT_DATA]u8 = [_]u8{0} ** MAX_EVENT_DATA,
    last_event_len: u16 = 0,
};

var channels: [MAX_CHANNELS]Channel = [_]Channel{.{}} ** MAX_CHANNELS;

// Monotonic for the life of the process. event_count restarts at zero whenever
// a channel is remade, which is invisible to a consumer that only asks whether
// the count grew -- it sees a SMALLER number, concludes there is no new work,
// and goes deaf. This is the value that makes the reset detectable.
var next_generation: u64 = 1;
var next_sub_id: u32 = 1;
var subs: [MAX_CHANNELS * MAX_SUBS_PER_CHANNEL]Subscription = [_]Subscription{.{}} ** (MAX_CHANNELS * MAX_SUBS_PER_CHANNEL);

fn find_channel(name: [*]const u8, name_len: usize) ?usize {
    for (0..MAX_CHANNELS) |i| {
        if (channels[i].active and channels[i].name_len == name_len and
            std.mem.eql(u8, channels[i].name[0..name_len], name[0..name_len]))
            return i;
    }
    return null;
}

pub fn reactive_create_channel(name: [*]const u8, name_len: i32) callconv(.c) i32 {
    if (name_len <= 0 or name_len > MAX_NAME) return -1;
    const nlen: usize = @intCast(name_len);
    if (find_channel(name, nlen) != null) return -2;
    for (0..MAX_CHANNELS) |i| {
        if (!channels[i].active) {
            @memcpy(channels[i].name[0..nlen], name[0..nlen]);
            channels[i].name_len = @intCast(nlen);
            channels[i].active = true;
            channels[i].sub_count = 0;
            channels[i].event_count = 0;
            channels[i].last_event_len = 0;
            channels[i].generation = next_generation;
            next_generation += 1;
            return @intCast(i);
        }
    }
    return -3;
}

pub fn reactive_subscribe(name: [*]const u8, name_len: i32) callconv(.c) i32 {
    if (name_len <= 0) return -1;
    const nlen: usize = @intCast(name_len);
    const ch_idx = find_channel(name, nlen) orelse return -2;
    if (channels[ch_idx].sub_count >= MAX_SUBS_PER_CHANNEL) return -3;
    for (0..subs.len) |i| {
        if (!subs[i].active) {
            subs[i] = .{
                .active = true,
                .channel_idx = @intCast(ch_idx),
                .id = next_sub_id,
            };
            next_sub_id += 1;
            channels[ch_idx].sub_count += 1;
            return @intCast(subs[i].id);
        }
    }
    return -4;
}

pub fn reactive_unsubscribe(sub_id: i32) callconv(.c) i32 {
    if (sub_id <= 0) return -1;
    const sid: u32 = @intCast(sub_id);
    for (0..subs.len) |i| {
        if (subs[i].active and subs[i].id == sid) {
            const ch = subs[i].channel_idx;
            subs[i].active = false;
            if (channels[ch].sub_count > 0) channels[ch].sub_count -= 1;
            return 0;
        }
    }
    return -2;
}

pub fn reactive_emit(name: [*]const u8, name_len: i32, data: [*]const u8, data_len: i32) callconv(.c) i32 {
    if (name_len <= 0) return -1;
    const nlen: usize = @intCast(name_len);
    const ch_idx = find_channel(name, nlen) orelse return -2;
    const dlen: usize = if (data_len <= 0) 0 else @min(@as(usize, @intCast(data_len)), MAX_EVENT_DATA);
    channels[ch_idx].event_count += 1;
    if (dlen > 0) {
        @memcpy(channels[ch_idx].last_event[0..dlen], data[0..dlen]);
    }
    channels[ch_idx].last_event_len = @intCast(dlen);
    return @intCast(channels[ch_idx].sub_count);
}

pub fn reactive_channel_count() callconv(.c) i32 {
    var count: i32 = 0;
    for (0..MAX_CHANNELS) |i| {
        if (channels[i].active) count += 1;
    }
    return count;
}

pub fn reactive_event_count(name: [*]const u8, name_len: i32) callconv(.c) i64 {
    if (name_len <= 0) return -1;
    const nlen: usize = @intCast(name_len);
    const ch_idx = find_channel(name, nlen) orelse return -2;
    return @intCast(channels[ch_idx].event_count);
}

pub fn reactive_sub_count(name: [*]const u8, name_len: i32) callconv(.c) i32 {
    if (name_len <= 0) return -1;
    const nlen: usize = @intCast(name_len);
    const ch_idx = find_channel(name, nlen) orelse return -2;
    return @intCast(channels[ch_idx].sub_count);
}

pub fn reactive_last_event(name: [*]const u8, name_len: i32, out: [*]u8) callconv(.c) i32 {
    if (name_len <= 0) return -1;
    const nlen: usize = @intCast(name_len);
    const ch_idx = find_channel(name, nlen) orelse return -2;
    const elen: usize = channels[ch_idx].last_event_len;
    if (elen == 0) return 0;
    @memcpy(out[0..elen], channels[ch_idx].last_event[0..elen]);
    return @intCast(elen);
}

pub fn reactive_destroy_channel(name: [*]const u8, name_len: i32) callconv(.c) i32 {
    if (name_len <= 0) return -1;
    const nlen: usize = @intCast(name_len);
    const ch_idx = find_channel(name, nlen) orelse return -2;
    for (0..subs.len) |i| {
        if (subs[i].active and subs[i].channel_idx == @as(u8, @intCast(ch_idx))) {
            subs[i].active = false;
        }
    }
    channels[ch_idx].active = false;
    channels[ch_idx].name_len = 0;
    channels[ch_idx].sub_count = 0;
    return 0;
}

pub fn reactive_clear_all() callconv(.c) void {
    for (0..MAX_CHANNELS) |i| {
        channels[i] = .{};
    }
    for (0..subs.len) |i| {
        subs[i] = .{};
    }
    next_sub_id = 1;
    // next_generation is deliberately NOT reset. Its whole job is to stay
    // unique across everything this process does, so that a channel remade
    // after a clear is never mistaken for the one that was cleared.
}

// The generation of the channel currently holding this name, or -2 when no
// channel does.
pub fn reactive_channel_generation(name: [*]const u8, name_len: i32) callconv(.c) i64 {
    if (name_len <= 0) return -1;
    const nlen: usize = @intCast(name_len);
    const ch_idx = find_channel(name, nlen) orelse return -2;
    return @intCast(channels[ch_idx].generation);
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_reactive_create_channel(n: [*]const u8, nl: i32) callconv(.c) i32 { return reactive_create_channel(n, nl); }
pub export fn stz_reactive_subscribe(n: [*]const u8, nl: i32) callconv(.c) i32 { return reactive_subscribe(n, nl); }
pub export fn stz_reactive_unsubscribe(id: i32) callconv(.c) i32 { return reactive_unsubscribe(id); }
pub export fn stz_reactive_emit(n: [*]const u8, nl: i32, d: [*]const u8, dl: i32) callconv(.c) i32 { return reactive_emit(n, nl, d, dl); }
pub export fn stz_reactive_channel_count() callconv(.c) i32 { return reactive_channel_count(); }
pub export fn stz_reactive_event_count(n: [*]const u8, nl: i32) callconv(.c) i64 { return reactive_event_count(n, nl); }
pub export fn stz_reactive_sub_count(n: [*]const u8, nl: i32) callconv(.c) i32 { return reactive_sub_count(n, nl); }
pub export fn stz_reactive_last_event(n: [*]const u8, nl: i32, o: [*]u8) callconv(.c) i32 { return reactive_last_event(n, nl, o); }
pub export fn stz_reactive_destroy_channel(n: [*]const u8, nl: i32) callconv(.c) i32 { return reactive_destroy_channel(n, nl); }
pub export fn stz_reactive_clear_all() callconv(.c) void { reactive_clear_all(); }
pub export fn stz_reactive_channel_generation(n: [*]const u8, nl: i32) callconv(.c) i64 { return reactive_channel_generation(n, nl); }

// ── Tests ────────────────────────────────────────────────────

test "reactive: create and destroy channel" {
    reactive_clear_all();
    const idx = reactive_create_channel("clicks", 6);
    try std.testing.expect(idx >= 0);
    try std.testing.expectEqual(@as(i32, 1), reactive_channel_count());
    try std.testing.expectEqual(@as(i32, 0), reactive_destroy_channel("clicks", 6));
    try std.testing.expectEqual(@as(i32, 0), reactive_channel_count());
}

test "reactive: subscribe and unsubscribe" {
    reactive_clear_all();
    _ = reactive_create_channel("data", 4);
    const sub1 = reactive_subscribe("data", 4);
    try std.testing.expect(sub1 > 0);
    const sub2 = reactive_subscribe("data", 4);
    try std.testing.expect(sub2 > sub1);
    try std.testing.expectEqual(@as(i32, 2), reactive_sub_count("data", 4));
    try std.testing.expectEqual(@as(i32, 0), reactive_unsubscribe(sub1));
    try std.testing.expectEqual(@as(i32, 1), reactive_sub_count("data", 4));
}

test "reactive: emit and event count" {
    reactive_clear_all();
    _ = reactive_create_channel("events", 6);
    _ = reactive_subscribe("events", 6);
    const delivered = reactive_emit("events", 6, "hello", 5);
    try std.testing.expectEqual(@as(i32, 1), delivered);
    try std.testing.expectEqual(@as(i64, 1), reactive_event_count("events", 6));
    _ = reactive_emit("events", 6, "world", 5);
    try std.testing.expectEqual(@as(i64, 2), reactive_event_count("events", 6));
}

test "reactive: last event" {
    reactive_clear_all();
    _ = reactive_create_channel("log", 3);
    _ = reactive_emit("log", 3, "first", 5);
    _ = reactive_emit("log", 3, "second", 6);
    var buf: [256]u8 = undefined;
    const len = reactive_last_event("log", 3, &buf);
    try std.testing.expectEqualStrings("second", buf[0..@intCast(len)]);
}

test "reactive: duplicate channel rejected" {
    reactive_clear_all();
    _ = reactive_create_channel("dup", 3);
    try std.testing.expectEqual(@as(i32, -2), reactive_create_channel("dup", 3));
}

test "reactive: subscribe to nonexistent channel" {
    reactive_clear_all();
    try std.testing.expectEqual(@as(i32, -2), reactive_subscribe("nope", 4));
}

test "reactive: a remade channel gets a NEW generation" {
    reactive_clear_all();
    _ = reactive_create_channel("orders", 6);
    const g1 = reactive_channel_generation("orders", 6);
    try std.testing.expect(g1 > 0);

    // Traffic does not change identity.
    _ = reactive_emit("orders", 6, "x", 1);
    try std.testing.expectEqual(g1, reactive_channel_generation("orders", 6));

    // Destroy + remake under the same name is a DIFFERENT channel, even
    // though the name and the (restarted) count look the same.
    _ = reactive_destroy_channel("orders", 6);
    _ = reactive_create_channel("orders", 6);
    const g2 = reactive_channel_generation("orders", 6);
    try std.testing.expect(g2 > g1);
    try std.testing.expectEqual(@as(i64, 0), reactive_event_count("orders", 6));
}

test "reactive: clear_all does not rewind the generation" {
    // The whole point. clear_all resets every channel, and if it reset the
    // counter too, a channel remade afterwards could be handed a generation
    // some earlier channel already had -- and a consumer comparing them would
    // conclude nothing had changed.
    reactive_clear_all();
    _ = reactive_create_channel("a", 1);
    const g1 = reactive_channel_generation("a", 1);

    reactive_clear_all();
    _ = reactive_create_channel("a", 1);
    const g2 = reactive_channel_generation("a", 1);

    try std.testing.expect(g2 > g1);
}

test "reactive: generation of a channel nobody declared" {
    reactive_clear_all();
    try std.testing.expectEqual(@as(i64, -2), reactive_channel_generation("ghost", 5));
}
