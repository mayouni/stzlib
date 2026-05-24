const std = @import("std");

// ─── Reaxis Reactive Engine ───
// Rule-based event processing: define rules (condition pattern + action tag),
// emit events, get triggered actions. Patterns are simple substring matches.

const MAX_RULES: usize = 128;
const MAX_PATTERN: usize = 128;
const MAX_ACTION: usize = 128;

const Rule = struct {
    pattern: [MAX_PATTERN]u8 = undefined,
    pattern_len: usize = 0,
    action: [MAX_ACTION]u8 = undefined,
    action_len: usize = 0,
    active: bool = false,
};

var rules: [MAX_RULES]Rule = [_]Rule{.{}} ** MAX_RULES;
var rule_count: usize = 0;

fn substringMatch(haystack: []const u8, needle: []const u8) bool {
    if (needle.len == 0) return true;
    if (needle.len > haystack.len) return false;
    const limit = haystack.len - needle.len + 1;
    for (0..limit) |i| {
        if (std.mem.eql(u8, haystack[i..][0..needle.len], needle)) return true;
    }
    return false;
}

// ─── C ABI ───

pub export fn stz_rx_add_rule(pattern: [*]const u8, pat_len: usize, action: [*]const u8, act_len: usize) i32 {
    if (rule_count >= MAX_RULES) return -1;
    for (0..MAX_RULES) |i| {
        if (!rules[i].active) {
            const pl = @min(pat_len, MAX_PATTERN);
            const al = @min(act_len, MAX_ACTION);
            @memcpy(rules[i].pattern[0..pl], pattern[0..pl]);
            rules[i].pattern_len = pl;
            @memcpy(rules[i].action[0..al], action[0..al]);
            rules[i].action_len = al;
            rules[i].active = true;
            rule_count += 1;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn stz_rx_emit(event: [*]const u8, event_len: usize, out_actions: [*]u8) i32 {
    const ev = event[0..event_len];
    var triggered: i32 = 0;
    var offset: usize = 0;
    for (0..MAX_RULES) |i| {
        if (rules[i].active) {
            const pat = rules[i].pattern[0..rules[i].pattern_len];
            if (substringMatch(ev, pat)) {
                const alen = rules[i].action_len;
                @memcpy(out_actions[offset..][0..alen], rules[i].action[0..alen]);
                offset += alen;
                out_actions[offset] = '\n';
                offset += 1;
                triggered += 1;
            }
        }
    }
    return triggered;
}

pub export fn stz_rx_rule_count() i32 {
    return @intCast(rule_count);
}

pub export fn stz_rx_match_count(pattern: [*]const u8, pat_len: usize) i32 {
    const pat = pattern[0..pat_len];
    var count: i32 = 0;
    for (0..MAX_RULES) |i| {
        if (rules[i].active) {
            const rp = rules[i].pattern[0..rules[i].pattern_len];
            if (std.mem.eql(u8, rp, pat)) count += 1;
        }
    }
    return count;
}

pub export fn stz_rx_remove_rule(idx: i32) void {
    if (idx < 0 or idx >= @as(i32, MAX_RULES)) return;
    const i: usize = @intCast(idx);
    if (rules[i].active) {
        rules[i].active = false;
        rule_count -= 1;
    }
}

pub export fn stz_rx_clear() void {
    for (0..MAX_RULES) |i| {
        rules[i].active = false;
    }
    rule_count = 0;
}

// ─── Tests ───

test "add rule and count" {
    stz_rx_clear();
    const idx = stz_rx_add_rule("error", 5, "alert", 5);
    try std.testing.expect(idx >= 0);
    try std.testing.expectEqual(@as(i32, 1), stz_rx_rule_count());
    stz_rx_clear();
}

test "emit triggers matching rules" {
    stz_rx_clear();
    _ = stz_rx_add_rule("error", 5, "alert", 5);
    _ = stz_rx_add_rule("warn", 4, "log", 3);
    var buf: [4096]u8 = undefined;
    const n = stz_rx_emit("system error occurred", 21, &buf);
    try std.testing.expectEqual(@as(i32, 1), n);
    stz_rx_clear();
}

test "emit with no match" {
    stz_rx_clear();
    _ = stz_rx_add_rule("error", 5, "alert", 5);
    var buf: [4096]u8 = undefined;
    const n = stz_rx_emit("all good", 8, &buf);
    try std.testing.expectEqual(@as(i32, 0), n);
    stz_rx_clear();
}

test "match count" {
    stz_rx_clear();
    _ = stz_rx_add_rule("error", 5, "a1", 2);
    _ = stz_rx_add_rule("error", 5, "a2", 2);
    _ = stz_rx_add_rule("warn", 4, "a3", 2);
    try std.testing.expectEqual(@as(i32, 2), stz_rx_match_count("error", 5));
    stz_rx_clear();
}

test "remove rule" {
    stz_rx_clear();
    const idx = stz_rx_add_rule("test", 4, "action", 6);
    stz_rx_remove_rule(idx);
    try std.testing.expectEqual(@as(i32, 0), stz_rx_rule_count());
    stz_rx_clear();
}
