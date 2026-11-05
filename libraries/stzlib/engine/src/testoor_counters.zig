//! Testoor core -- node counters (roadmap P3.4, TESTOOR_PROTOCOL_2.md section 3).
//!
//! The NUMERATOR of graph coverage: how many times a tour reached each node of its program. A
//! program (or a trace hook acting for it) calls `hit` as it reaches a node, and at the end the
//! counters are written as `[testoor node ID N]` lines, which the verdict reads into the tour's
//! nodes record. Counting is the cheap half of coverage; naming the nodes (the graph) is the other.
//!
//! Built for the HOT PATH. A node is registered ONCE, which answers a SLOT (1, 2, 3 ...), and a hit
//! by slot is an array increment: no string, no hash, no allocation. A hit by id is one hash lookup
//! more. MEASURED on 2026-11-06 (rnxc, Ring++): an empty Ring function call costs 0.05 us, an engine
//! call taking and returning numbers 0.15 us; the Ring trace hook the first design considered costs
//! 11.5 us an event on Ring 1.27 and does not exist on Ring++ at all.
//!
//! Counters are in the engine, never in a Ring object: Ring copies an object it stores and a copy
//! would fork the counts (CLAUDE.md, the engine-wrapper copy law). Nothing here imports Ring.
//!
//!   * an id is non-empty and holds no byte of 32 or below (no space, no control byte): the graph
//!     record's rule for an id, so a report line always reads back
//!   * a count saturates at 10^15 - 1, the longest count `[testoor node ID N]` carries
//!   * `reset` zeroes every count and KEEPS the slots, so a slot a tour cached stays valid
//!   * a slot that was never registered is ignored by `hit`; it cannot count somewhere else

const std = @import("std");
const Allocator = std.mem.Allocator;
const T = @import("testoor_text.zig");

pub const max_hits: u64 = 999_999_999_999_999;

/// does `id` read back from a `[testoor node ID N]` line?
pub fn validId(id: []const u8) bool {
    if (id.len == 0) return false;
    for (id) |c| if (c <= 32) return false;
    return true;
}

pub const Counters = struct {
    /// owned copies of the ids, in the order they were registered; slot k is ids[k - 1]
    ids: std.ArrayList([]const u8) = .empty,
    hits: std.ArrayList(u64) = .empty,
    index: std.StringHashMapUnmanaged(u32) = .empty,

    /// the slot of `id`, registering it on first sight; 0 when the id cannot be a node line's
    pub fn slot(c: *Counters, gpa: Allocator, id: []const u8) !u32 {
        if (c.index.get(id)) |k| return k + 1;
        if (!validId(id)) return 0;
        const copy = try gpa.dupe(u8, id);
        errdefer gpa.free(copy);
        const k: u32 = @intCast(c.ids.items.len);
        try c.ids.append(gpa, copy);
        errdefer _ = c.ids.pop();
        try c.hits.append(gpa, 0);
        errdefer _ = c.hits.pop();
        try c.index.put(gpa, copy, k);
        return k + 1;
    }

    /// `n` hits on a slot; answers the count after, or 0 for a slot that was never registered
    pub fn hit(c: *Counters, s: u32, n: u64) u64 {
        if (s == 0 or s > c.hits.items.len) return 0;
        const p = &c.hits.items[s - 1];
        p.* = @min(max_hits, p.* +| n);
        return p.*;
    }

    /// a hit by id: one hash lookup more than a hit by slot; 0 for an id that cannot be a node's
    pub fn hitId(c: *Counters, gpa: Allocator, id: []const u8, n: u64) !u64 {
        const s = try c.slot(gpa, id);
        return c.hit(s, n);
    }

    pub fn count(c: *const Counters, id: []const u8) u64 {
        const k = c.index.get(id) orelse return 0;
        return c.hits.items[k];
    }

    pub fn registered(c: *const Counters) usize {
        return c.ids.items.len;
    }

    /// every count to zero; the slots stay
    pub fn reset(c: *Counters) void {
        @memset(c.hits.items, 0);
    }

    /// the ids reached at least once, as `[testoor node ID N]` lines in the order they were registered,
    /// one to a line and no line feed after the last; nothing when no node was reached
    pub fn report(c: *const Counters, b: *T.Buf) !void {
        var first = true;
        for (c.ids.items, c.hits.items) |id, n| {
            if (n == 0) continue;
            if (!first) try b.c('\n');
            first = false;
            try b.s("[testoor node ");
            try b.s(id);
            try b.c(' ');
            try b.int(@intCast(n));
            try b.c(']');
        }
    }

    pub fn deinit(c: *Counters, gpa: Allocator) void {
        for (c.ids.items) |id| gpa.free(id);
        c.ids.deinit(gpa);
        c.hits.deinit(gpa);
        c.index.deinit(gpa);
    }
};

// ── tests ────────────────────────────────────────────────────

const testing = std.testing;
const G = @import("testoor_graph.zig");

test "a node is registered once, and its slot never changes" {
    var c: Counters = .{};
    defer c.deinit(testing.allocator);
    const a = testing.allocator;
    try testing.expectEqual(@as(u32, 1), try c.slot(a, "stzTax.Total"));
    try testing.expectEqual(@as(u32, 2), try c.slot(a, "stzTax.Rate"));
    try testing.expectEqual(@as(u32, 1), try c.slot(a, "stzTax.Total"));
    try testing.expectEqual(@as(usize, 2), c.registered());
}

test "an id that could not be read back is refused, and a refused id counts nowhere" {
    var c: Counters = .{};
    defer c.deinit(testing.allocator);
    const a = testing.allocator;
    try testing.expectEqual(@as(u32, 0), try c.slot(a, ""));
    try testing.expectEqual(@as(u32, 0), try c.slot(a, "has space"));
    try testing.expectEqual(@as(u32, 0), try c.slot(a, "tab\there"));
    try testing.expectEqual(@as(u32, 0), try c.slot(a, "new\nline"));
    try testing.expectEqual(@as(u64, 0), try c.hitId(a, "has space", 5));
    try testing.expectEqual(@as(usize, 0), c.registered());
    // non-ASCII bytes are fine: only 32 and below are refused
    try testing.expect(validId("é.Total"));
}

test "hits add, by slot and by id, and a slot never registered is ignored" {
    var c: Counters = .{};
    defer c.deinit(testing.allocator);
    const a = testing.allocator;
    const s = try c.slot(a, "a.B");
    try testing.expectEqual(@as(u64, 1), c.hit(s, 1));
    try testing.expectEqual(@as(u64, 4), c.hit(s, 3));
    try testing.expectEqual(@as(u64, 5), try c.hitId(a, "a.B", 1));
    try testing.expectEqual(@as(u64, 5), c.count("a.B"));
    try testing.expectEqual(@as(u64, 0), c.hit(0, 1));
    try testing.expectEqual(@as(u64, 0), c.hit(99, 1));
    try testing.expectEqual(@as(u64, 0), c.count("never"));
    // an id met first by a hit is registered by it
    try testing.expectEqual(@as(u64, 1), try c.hitId(a, "c.D", 1));
    try testing.expectEqual(@as(usize, 2), c.registered());
}

test "a count saturates at the longest count a node line can carry" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    var c: Counters = .{};
    defer c.deinit(testing.allocator);
    const s = try c.slot(testing.allocator, "x");
    try testing.expectEqual(max_hits, c.hit(s, std.math.maxInt(u64)));
    try testing.expectEqual(max_hits, c.hit(s, 1));
    var b = T.Buf.init(arena.allocator());
    try c.report(&b);
    try testing.expectEqualStrings("[testoor node x 999999999999999]", try b.done());
}

test "reset zeroes the counts and keeps the slots" {
    var c: Counters = .{};
    defer c.deinit(testing.allocator);
    const a = testing.allocator;
    const s = try c.slot(a, "k.L");
    _ = c.hit(s, 7);
    c.reset();
    try testing.expectEqual(@as(u64, 0), c.count("k.L"));
    try testing.expectEqual(s, try c.slot(a, "k.L"));
    try testing.expectEqual(@as(u64, 1), c.hit(s, 1)); // the cached slot still counts
}

test "the report is the node lines the verdict reads, in registration order, and only for nodes reached" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var c: Counters = .{};
    defer c.deinit(testing.allocator);
    const g = testing.allocator;
    const first = try c.slot(g, "stzTax.Total");
    const never = try c.slot(g, "stzTax.Never");
    const third = try c.slot(g, "stzMoney.Add");
    _ = never;
    _ = c.hit(third, 2);
    _ = c.hit(first, 3);
    var b = T.Buf.init(a);
    try c.report(&b);
    const text = try b.done();
    try testing.expectEqualStrings("[testoor node stzTax.Total 3]\n[testoor node stzMoney.Add 2]", text);
    // every line reads back to the id and the count that were written
    var lines = std.mem.splitScalar(u8, text, '\n');
    const want = [_]struct { id: []const u8, n: i64 }{ .{ .id = "stzTax.Total", .n = 3 }, .{ .id = "stzMoney.Add", .n = 2 } };
    var k: usize = 0;
    while (lines.next()) |ln| : (k += 1) {
        const h = G.parseNodeLine(ln).?;
        try testing.expectEqualStrings(want[k].id, h.id);
        try testing.expectEqual(want[k].n, h.hits);
    }
    try testing.expectEqual(@as(usize, 2), k);
    // and nothing reached is nothing written
    c.reset();
    var e = T.Buf.init(a);
    try c.report(&e);
    try testing.expectEqualStrings("", try e.done());
}

test "THE COST: a hit by slot and a hit by id, raw, with no Ring in the way" {
    var c: Counters = .{};
    defer c.deinit(testing.allocator);
    const a = testing.allocator;
    const s = try c.slot(a, "stzTax.Total");
    _ = try c.slot(a, "stzTax.Rate");
    _ = try c.slot(a, "stzMoney.Add");
    const slot_n: u64 = 20_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < slot_n) : (i += 1) _ = c.hit(s, 1);
    const slot_ns = timer.read();
    const id_n: u64 = 2_000_000;
    timer.reset();
    i = 0;
    while (i < id_n) : (i += 1) _ = try c.hitId(a, "stzMoney.Add", 1);
    const id_ns = timer.read();
    std.debug.print("  counters: a hit by slot {d} ns, by id {d} ns (raw; the Ring trace hook is 11500 ns)\n", .{
        slot_ns / slot_n,
        id_ns / id_n,
    });
    try testing.expectEqual(slot_n, c.count("stzTax.Total"));
    // far inside the hook's 11.5 us: a generous bound, so machine load cannot make it flaky
    try testing.expect(slot_ns / slot_n < 1000);
    try testing.expect(id_ns / id_n < 2000);
}
