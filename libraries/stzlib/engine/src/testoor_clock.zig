//! Testoor core -- the clock that runs backwards, and the weather (roadmap P3.2).
//!
//! A tour's side of the replay bargain: it PRINTS ITS SEED, and the same seed walks the same
//! path. This module owns what decides that path -- the seed, the stepped clock that moves only
//! when the tour moves it, and the weather a tour declares and the tick each one falls due at.
//! It owns TIMING and STATE. It does not own a weather's payload (the child's name, a spec the
//! tour wrote): that is the caller's, by ordinal, so no JSON round trip stands between a tick
//! and the supervisor it kills a child of. Printing the `[testoor ...]` lines is the caller's too.
//!
//! Nothing here imports Ring. `zig test` runs it with no virtual machine.
//!
//! THE ONE DEVIATION FROM THE RING REFERENCE (base/testoor/stzClock.ring). A weather declared
//! without a tick had its tick drawn from Ring's own generator: `1 + random(5)`. That generator
//! is the C runtime's `rand()`, so the same seed picked another tick on Windows, on Linux and on
//! Ring++, and a tick that depended on how many other draws the tour had already taken. Here the
//! tick is `1 + splitmix64(seed, n) % 6`, n counting the picks made since the seed was set: the
//! same on every machine, and unmoved by the tour's other draws. Seeding restarts the count, as
//! reseeding restarted the reference's generator. The values are pinned by a test below -- a
//! change to the generator changes every replay anyone recorded.

const std = @import("std");
const Allocator = std.mem.Allocator;
const T = @import("testoor_text.zig");

pub const Mode = enum {
    live,
    frozen,
    stepped,

    pub fn name(m: Mode) []const u8 {
        return @tagName(m);
    }

    pub fn fromName(s: []const u8) ?Mode {
        inline for (@typeInfo(Mode).@"enum".fields) |f| {
            if (std.mem.eql(u8, s, f.name)) return @field(Mode, f.name);
        }
        return null;
    }
};

pub const Kind = enum { child_killed, skew };

/// a declared fault. `tick` 0 is "at once": the fault was applied when it was declared and the
/// entry stays planned forever, since the clock's tick never reads 0 after a tick -- the
/// reference does the same and a tour may read it back with WeatherPlan.
pub const Weather = struct {
    kind: Kind,
    tick: f64,
    fired: bool = false,
    /// a restarted stepped clock keeps no weather that already fell due: such an entry is
    /// dropped, not removed, so every ordinal the caller holds stays where it was
    dropped: bool = false,
};

pub const Refusal = error{ NotStepped, UnknownMode };

pub const World = struct {
    /// -1: nobody has set a seed in this world
    seed: f64 = -1,
    mode: Mode = .live,
    ms: f64 = 0,
    step: f64 = 0,
    tick: f64 = 0,
    /// ticks picked since the seed was set
    picks: u64 = 0,
    weather: std.ArrayList(Weather) = .empty,

    pub fn reset(w: *World) void {
        w.seed = -1;
        w.mode = .live;
        w.ms = 0;
        w.step = 0;
        w.tick = 0;
        w.picks = 0;
        w.weather.clearRetainingCapacity();
    }

    pub fn deinit(w: *World, a: Allocator) void {
        w.weather.deinit(a);
    }

    // --- seed -------------------------------------------------------------------------

    /// the seed a runner-less run draws from the clock: 1 to 90000, from the milliseconds the
    /// caller read. The runner draws its own the same way (stzTraveller), so one place says how
    pub fn draw(entropy_ms: f64) f64 {
        const e = if (std.math.isFinite(entropy_ms)) @floor(@abs(entropy_ms)) else 0;
        return 1 + @mod(e, 90000);
    }

    /// the seed is set, and every pick starts over
    pub fn seedSet(w: *World, n: f64) f64 {
        w.seed = n;
        w.picks = 0;
        return n;
    }

    /// Seed(:run): the seed the runner passed (`--testoor-seed`, as text; "" when absent), or a
    /// draw from the clock. A seed that is not a number, or is negative, is no seed.
    pub fn seedRun(w: *World, arg: []const u8, entropy_ms: f64) f64 {
        var n: f64 = -1;
        if (arg.len != 0) {
            if (T.parseNumber(arg)) |v| {
                if (std.math.isFinite(v)) n = v;
            }
        }
        if (n < 0) n = draw(entropy_ms);
        return w.seedSet(n);
    }

    // --- clock ------------------------------------------------------------------------

    pub fn clockTo(w: *World, m: Mode, start: f64, step: f64) void {
        w.mode = m;
        if (m != .stepped) return;
        w.ms = start;
        w.step = step;
        w.tick = 0;
        for (w.weather.items) |*e| {
            if (e.fired) e.dropped = true;
        }
    }

    /// the logical milliseconds, or null when the clock is not the stepped one
    pub fn now(w: *const World) ?f64 {
        return if (w.mode == .stepped) w.ms else null;
    }

    pub fn advance(w: *World, ms: f64) Refusal!f64 {
        if (w.mode != .stepped) return error.NotStepped;
        w.ms += ms;
        return w.ms;
    }

    /// ONE step, and the weather that falls due at it, each once: the ordinals (0-based) are
    /// written to `out`, in the order they were declared
    pub fn tickOnce(w: *World, a: Allocator, out: *std.ArrayList(usize)) !void {
        if (w.mode != .stepped) return error.NotStepped;
        w.tick += 1;
        w.ms += w.step;
        for (w.weather.items, 0..) |*e, i| {
            if (e.dropped or e.fired) continue;
            if (e.tick == w.tick) {
                e.fired = true;
                try out.append(a, i);
            }
        }
    }

    // --- weather ----------------------------------------------------------------------

    pub const Declared = struct { ordinal: usize, tick: f64 };

    /// the tick the seeded generator picks next: 1 to 6
    fn pick(w: *World) f64 {
        const n = w.picks;
        w.picks += 1;
        return 1 + @as(f64, @floatFromInt(mix(w.seed, n) % 6));
    }

    /// :child_killed at a tick the tour named (`tick`), or at one the seed picks (null)
    pub fn declareKill(w: *World, a: Allocator, tick: ?f64) !Declared {
        const t = tick orelse w.pick();
        try w.weather.append(a, .{ .kind = .child_killed, .tick = t });
        return .{ .ordinal = w.weather.items.len - 1, .tick = t };
    }

    /// :skew: the stepped clock jumps at once. Nothing is declared on a clock the tour does not drive.
    pub fn declareSkew(w: *World, a: Allocator, ms: f64) !Declared {
        if (w.mode != .stepped) return error.NotStepped;
        w.ms += ms;
        try w.weather.append(a, .{ .kind = .skew, .tick = 0 });
        return .{ .ordinal = w.weather.items.len - 1, .tick = 0 };
    }
};

/// splitmix64 finaliser over the seed's bits and the pick's number: a tick is a function of the
/// two and of nothing else, on any machine
fn mix(seed: f64, n: u64) u64 {
    var x: u64 = @bitCast(seed);
    x +%= (n +% 1) *% 0x9E3779B97F4A7C15;
    x = (x ^ (x >> 30)) *% 0xBF58476D1CE4E5B9;
    x = (x ^ (x >> 27)) *% 0x94D049BB133111EB;
    return x ^ (x >> 31);
}

// --- the text surface the Ring bridge calls ---------------------------------------------
//
// One call: an operation name, a text and two numbers, and an answer that is a string.
// Numbers cross as the shortest decimal that reads back to the same f64. A refusal answers
// "!" and a code. Ordinals and counts are 1-based, as Ring counts. A list answers one item
// a line, so Ring's str2list reads it and an empty list is "".
//
//   reset                                  -> 1
//   seedset      a = seed                  -> the seed
//   seedrun      text = the runner's seed, a = clock ms
//                                          -> the seed adopted or drawn
//   draw         a = clock ms              -> a seed, and the world is not touched
//   seed                                   -> the seed, -1 when none
//   clockto      text = mode, a = start, b = step
//                                          -> the mode; !mode for one that is not known
//   mode                                   -> live, frozen or stepped
//   now                                    -> the stepped ms; "" on any other clock
//   advance      a = ms                    -> the ms; !stepped
//   ticks                                  -> the ticks taken
//   tick                                   -> the ordinals fallen due, "" for none; !stepped
//   declarekill  a = tick                  -> ordinal, tick
//   declarepick                            -> ordinal, tick (the seed picks it)
//   declareskew  a = ms                    -> ordinal, tick (0); !stepped
//   planned                                -> ordinal, tick, ordinal, tick ... of what has not fallen due
//   declared                               -> the ordinals of what the world still holds

pub const CallError = error{ UnknownOp, OutOfMemory };

fn num(a: Allocator, v: f64) ![]u8 {
    return std.fmt.allocPrint(a, "{d}", .{v});
}

fn lines2(a: Allocator, x: usize, t: f64) ![]u8 {
    return std.fmt.allocPrint(a, "{d}\n{d}", .{ x + 1, t });
}

/// `gpa` grows the world's weather list and must outlive the call; `a` holds the answer and the
/// call's own scratch and may be an arena that dies with the call.
pub fn call(w: *World, gpa: Allocator, a: Allocator, op: []const u8, text: []const u8, na: f64, nb: f64) CallError![]u8 {
    const eq = std.mem.eql;
    if (eq(u8, op, "reset")) {
        w.reset();
        return a.dupe(u8, "1");
    }
    if (eq(u8, op, "seedset")) return num(a, w.seedSet(na));
    if (eq(u8, op, "seedrun")) return num(a, w.seedRun(text, na));
    if (eq(u8, op, "draw")) return num(a, World.draw(na));
    if (eq(u8, op, "seed")) return num(a, w.seed);
    if (eq(u8, op, "clockto")) {
        const m = Mode.fromName(text) orelse return a.dupe(u8, "!mode");
        w.clockTo(m, na, nb);
        return a.dupe(u8, m.name());
    }
    if (eq(u8, op, "mode")) return a.dupe(u8, w.mode.name());
    if (eq(u8, op, "now")) return if (w.now()) |v| num(a, v) else a.dupe(u8, "");
    if (eq(u8, op, "advance")) {
        const v = w.advance(na) catch return a.dupe(u8, "!stepped");
        return num(a, v);
    }
    if (eq(u8, op, "ticks")) return num(a, w.tick);
    if (eq(u8, op, "tick")) {
        var due: std.ArrayList(usize) = .empty;
        w.tickOnce(a, &due) catch |e| switch (e) {
            error.NotStepped => return a.dupe(u8, "!stepped"),
            error.OutOfMemory => return error.OutOfMemory,
        };
        var b: std.ArrayList(u8) = .empty;
        for (due.items, 0..) |o, i| {
            if (i > 0) try b.append(a, '\n');
            try b.appendSlice(a, try std.fmt.allocPrint(a, "{d}", .{o + 1}));
        }
        return b.toOwnedSlice(a);
    }
    if (eq(u8, op, "declarekill") or eq(u8, op, "declarepick")) {
        const d = try w.declareKill(gpa, if (eq(u8, op, "declarekill")) na else null);
        return lines2(a, d.ordinal, d.tick);
    }
    if (eq(u8, op, "declareskew")) {
        const d = w.declareSkew(gpa, na) catch |e| switch (e) {
            error.NotStepped => return a.dupe(u8, "!stepped"),
            error.OutOfMemory => return error.OutOfMemory,
        };
        return lines2(a, d.ordinal, d.tick);
    }
    if (eq(u8, op, "planned")) {
        var b: std.ArrayList(u8) = .empty;
        var first = true;
        for (w.weather.items, 0..) |e, i| {
            if (e.dropped or e.fired) continue;
            if (!first) try b.append(a, '\n');
            first = false;
            try b.appendSlice(a, try std.fmt.allocPrint(a, "{d}\n{d}", .{ i + 1, e.tick }));
        }
        return b.toOwnedSlice(a);
    }
    if (eq(u8, op, "declared")) {
        var b: std.ArrayList(u8) = .empty;
        var first = true;
        for (w.weather.items, 0..) |e, i| {
            if (e.dropped) continue;
            if (!first) try b.append(a, '\n');
            first = false;
            try b.appendSlice(a, try std.fmt.allocPrint(a, "{d}", .{i + 1}));
        }
        return b.toOwnedSlice(a);
    }
    return error.UnknownOp;
}

// --- tests -------------------------------------------------------------------------------

const testing = std.testing;

fn tickList(w: *World, a: Allocator) ![]usize {
    var due: std.ArrayList(usize) = .empty;
    try w.tickOnce(a, &due);
    return due.items;
}

test "the stepped clock moves only when it is moved, and replays identically" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var runs: [2][4]f64 = undefined;
    for (&runs) |*run| {
        var w: World = .{};
        defer w.deinit(a);
        w.clockTo(.stepped, 1000, 250);
        run[0] = w.now().?;
        _ = try tickList(&w, a);
        run[1] = w.now().?;
        _ = try w.advance(750);
        run[2] = w.now().?;
        _ = try tickList(&w, a);
        run[3] = w.now().?;
        try testing.expectEqual(@as(f64, 2), w.tick);
    }
    try testing.expectEqualSlices(f64, &.{ 1000, 1250, 2000, 2250 }, &runs[0]);
    try testing.expectEqualSlices(f64, &runs[0], &runs[1]);
}

test "a clock that is not stepped refuses to tick, to advance, and to be skewed" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var w: World = .{};
    try testing.expectError(error.NotStepped, tickList(&w, a));
    try testing.expectError(error.NotStepped, w.advance(5));
    try testing.expectError(error.NotStepped, w.declareSkew(a, 5));
    try testing.expect(w.now() == null);
    w.clockTo(.frozen, 0, 0);
    try testing.expectError(error.NotStepped, tickList(&w, a));
    try testing.expect(w.now() == null);
    w.clockTo(.live, 0, 0);
    try testing.expectEqual(Mode.live, w.mode);
}

test "weather falls due once, at its tick, and the guard's table of ticks holds" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var w: World = .{};
    w.clockTo(.stepped, 0, 100);
    const d = try w.declareKill(a, 3);
    try testing.expectEqual(@as(usize, 0), d.ordinal);
    try testing.expectEqual(@as(f64, 3), d.tick);
    try testing.expectEqual(@as(usize, 0), (try tickList(&w, a)).len);
    try testing.expectEqual(@as(usize, 0), (try tickList(&w, a)).len);
    const at3 = try tickList(&w, a);
    try testing.expectEqual(@as(usize, 1), at3.len);
    try testing.expectEqual(@as(usize, 0), at3[0]);
    try testing.expectEqual(@as(usize, 0), (try tickList(&w, a)).len);
}

test "two weathers due at one tick fall due together, in the order declared" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var w: World = .{};
    w.clockTo(.stepped, 0, 1);
    _ = try w.declareKill(a, 2);
    _ = try w.declareKill(a, 1);
    _ = try w.declareKill(a, 2);
    const t1 = try tickList(&w, a);
    try testing.expectEqualSlices(usize, &.{1}, t1);
    const t2 = try tickList(&w, a);
    try testing.expectEqualSlices(usize, &.{ 0, 2 }, t2);
}

test "a skew moves the clock at once and stays planned at tick 0, as the reference does" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var w: World = .{};
    w.clockTo(.stepped, 100, 10);
    const d = try w.declareSkew(a, 500);
    try testing.expectEqual(@as(f64, 600), w.now().?);
    try testing.expectEqual(@as(f64, 0), d.tick);
    for (0..5) |_| try testing.expectEqual(@as(usize, 0), (try tickList(&w, a)).len);
    try testing.expectEqual(@as(f64, 650), w.now().?);
    const r = try call(&w, a, a, "planned", "", 0, 0);
    try testing.expectEqualStrings("1\n0", r);
}

test "restarting the stepped clock drops what already fell due and keeps the rest" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var w: World = .{};
    w.clockTo(.stepped, 0, 1);
    _ = try w.declareKill(a, 1);
    _ = try w.declareKill(a, 5);
    _ = try tickList(&w, a); // the first falls due
    try testing.expectEqualStrings("1\n2", try call(&w, a, a, "declared", "", 0, 0));
    w.clockTo(.stepped, 10, 2);
    try testing.expectEqualStrings("2", try call(&w, a, a, "declared", "", 0, 0));
    try testing.expectEqualStrings("2\n5", try call(&w, a, a, "planned", "", 0, 0));
    // the survivor keeps its ordinal, so the caller's payload for it is still at 2
    for (0..4) |_| _ = try tickList(&w, a);
    const at5 = try tickList(&w, a);
    try testing.expectEqualSlices(usize, &.{1}, at5);
}

test "a seed names the draw: the same seed picks the same tick, anywhere" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var w: World = .{};
    _ = w.seedSet(42);
    const first = (try w.declareKill(a, null)).tick;
    w.reset();
    _ = w.seedSet(42);
    try testing.expectEqual(first, (try w.declareKill(a, null)).tick);
    // seeding again restarts the count, as reseeding restarted the reference's generator
    _ = try w.declareKill(a, null); // a second pick under the same seed
    _ = w.seedSet(42);
    try testing.expectEqual(first, (try w.declareKill(a, null)).tick);
    // PINNED: these are what every machine must pick. A change here changes every recorded replay.
    const pinned = [_]struct { seed: f64, ticks: [4]f64 }{
        // computed by a second implementation of the same formula (Python), not by this one
        .{ .seed = 42, .ticks = .{ 2, 3, 4, 2 } },
        .{ .seed = 43, .ticks = .{ 5, 5, 4, 5 } },
        .{ .seed = 7, .ticks = .{ 3, 3, 2, 1 } },
    };
    for (pinned) |p| {
        _ = w.seedSet(p.seed);
        var got: [4]f64 = undefined;
        for (&got) |*g| g.* = (try w.declareKill(a, null)).tick;
        try testing.expectEqualSlices(f64, &p.ticks, &got);
    }
}

test "every pick is one to six, all six occur, and no value is starved" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var w: World = .{};
    var seen = [_]usize{0} ** 7;
    var s: f64 = 1;
    while (s <= 1200) : (s += 1) {
        _ = w.seedSet(s);
        const t = (try w.declareKill(a, null)).tick;
        try testing.expect(t >= 1 and t <= 6);
        seen[@intFromFloat(t)] += 1;
    }
    for (seen[1..]) |c| try testing.expect(c > 120); // an even spread is 200 each
    try testing.expectEqual(@as(usize, 0), seen[0]);
}

test "a pick does not depend on the weather declared with a tick of its own" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var w: World = .{};
    _ = w.seedSet(9);
    const alone = (try w.declareKill(a, null)).tick;
    w.reset();
    _ = w.seedSet(9);
    _ = try w.declareKill(a, 4);
    _ = try w.declareKill(a, 2);
    try testing.expectEqual(alone, (try w.declareKill(a, null)).tick);
}

test "Seed(:run) adopts the runner's seed, or draws one from the clock" {
    var w: World = .{};
    try testing.expectEqual(@as(f64, 42), w.seedRun("42", 123456.7));
    try testing.expectEqual(@as(f64, 42), w.seed);
    try testing.expectEqual(@as(f64, 0), w.seedRun("0", 5)); // 0 is a seed
    // absent, not a number, or negative: a draw, 1 + ms mod 90000
    try testing.expectEqual(@as(f64, 33457), w.seedRun("", 123456.7));
    try testing.expectEqual(@as(f64, 33457), w.seedRun("abc", 123456.7));
    try testing.expectEqual(@as(f64, 33457), w.seedRun("-3", 123456.7));
    try testing.expectEqual(@as(f64, 1), World.draw(90000));
    try testing.expectEqual(@as(f64, 90000), World.draw(89999));
    try testing.expectEqual(@as(f64, 1), World.draw(std.math.nan(f64)));
    // the draw alone leaves a world as it was
    const v: World = .{};
    _ = World.draw(77);
    try testing.expectEqual(@as(f64, -1), v.seed);
    try testing.expectEqual(@as(u64, 0), v.picks);
}

test "the text surface answers what the Ring glue reads" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var w: World = .{};
    try testing.expectEqualStrings("live", try call(&w, a, a, "mode", "", 0, 0));
    try testing.expectEqualStrings("", try call(&w, a, a, "now", "", 0, 0));
    try testing.expectEqualStrings("!stepped", try call(&w, a, a, "tick", "", 0, 0));
    try testing.expectEqualStrings("!stepped", try call(&w, a, a, "advance", "", 5, 0));
    try testing.expectEqualStrings("!stepped", try call(&w, a, a, "declareskew", "", 5, 0));
    try testing.expectEqualStrings("!mode", try call(&w, a, a, "clockto", "sideways", 0, 0));
    try testing.expectEqualStrings("-1", try call(&w, a, a, "seed", "", 0, 0));
    try testing.expectEqualStrings("stepped", try call(&w, a, a, "clockto", "stepped", 1000, 250));
    try testing.expectEqualStrings("1000", try call(&w, a, a, "now", "", 0, 0));
    try testing.expectEqualStrings("1000.5", try call(&w, a, a, "advance", "", 0.5, 0)); // a fraction crosses exactly
    try testing.expectEqualStrings("1\n3", try call(&w, a, a, "declarekill", "", 3, 0));
    try testing.expectEqualStrings("42", try call(&w, a, a, "seedset", "", 42, 0));
    try testing.expectEqualStrings("2\n2", try call(&w, a, a, "declarepick", "", 0, 0)); // seed 42, first pick: 2
    try testing.expectEqualStrings("3\n0", try call(&w, a, a, "declareskew", "", 5, 0));
    try testing.expectEqualStrings("1\n3\n2\n2\n3\n0", try call(&w, a, a, "planned", "", 0, 0));
    try testing.expectEqualStrings("1\n2\n3", try call(&w, a, a, "declared", "", 0, 0));
    try testing.expectEqualStrings("", try call(&w, a, a, "tick", "", 0, 0)); // tick 1
    try testing.expectEqualStrings("2", try call(&w, a, a, "tick", "", 0, 0)); // tick 2: the picked one
    try testing.expectEqualStrings("2", try call(&w, a, a, "ticks", "", 0, 0));
    try testing.expectEqualStrings("1", try call(&w, a, a, "reset", "", 0, 0));
    try testing.expectEqualStrings("-1", try call(&w, a, a, "seed", "", 0, 0));
    try testing.expectEqualStrings("", try call(&w, a, a, "declared", "", 0, 0));
}

test "an unknown operation is an error, not a silent answer" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var w: World = .{};
    try testing.expectError(error.UnknownOp, call(&w, a, a, "nonsense", "", 0, 0));
}
