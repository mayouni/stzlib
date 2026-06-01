// Softanza Engine -- Integer Sequence (IntSeq)
//
// A typed integer-sequence engine feature: a flat []i64 backing store
// allocated in one shot, fronted by a handle that any language binding
// can consume.
//
// Purpose: a generic answer to the "host language's list-append is
// slow per element" problem. Modules that need to *produce* a large
// numeric sequence (stzCounter, stzRange, statistical accumulators,
// numbric simulators, etc.) build it here in O(N) total time, then
// callers consume it through fast O(1) accessor / O(N) bulk-copy
// entries -- never paying the host language's per-item cost.
//
// Language-binding contract:
//   - the *create* entries return an opaque handle (i.e. a pointer
//     to an IntSeq struct allocated on the C allocator).
//   - the *get* / *len* / *bulk* entries take that handle.
//   - the host language is responsible for calling `free` when done.
//
// This is intentionally simpler than the more general StzList:
//   - homogeneous i64 elements (no StzValue boxing -> no per-item alloc)
//   - flat slice (no linked list, no nested values)
//   - bulk operations stay in Zig (no per-call FFI roundtrip)

const std = @import("std");
const ca = std.heap.c_allocator;

pub const IntSeq = struct {
    items: []i64,

    pub fn create(n: usize) ?*IntSeq {
        const seq = ca.create(IntSeq) catch return null;
        seq.* = .{ .items = ca.alloc(i64, n) catch {
            ca.destroy(seq);
            return null;
        } };
        return seq;
    }

    pub fn free(self: *IntSeq) void {
        ca.free(self.items);
        ca.destroy(self);
    }
};

// ─── Cycle generation ───
// Two modes, matching stzCounter's semantics. Both run in O(N) and
// touch each element exactly once with no allocation in the loop.

pub const Mode = enum(u8) {
    when_you_reach = 1,
    after_you_skip = 2,
};

pub export fn stz_intseq_create_cycle(
    start: i64,
    step_val: i64,
    cycle_param: i64,
    restart: i64,
    n_items: usize,
    mode: i32,
) ?*IntSeq {
    if (n_items == 0) return IntSeq.create(0);

    const seq = IntSeq.create(n_items) orelse return null;
    var n: i64 = start;

    if (mode == @intFromEnum(Mode.when_you_reach)) {
        var i: usize = 0;
        while (i < n_items) : (i += 1) {
            const idx_i64: i64 = @intCast(i);
            // Index-based reset: i+start equals cycle_param (Ring 1-based)
            if (cycle_param != 0 and (idx_i64 + start) == cycle_param) {
                n = restart;
            }
            seq.items[i] = n;
            n += step_val;
            if (cycle_param != 0 and n == cycle_param) {
                n = restart;
            }
        }
    } else if (mode == @intFromEnum(Mode.after_you_skip)) {
        const cycle_len: i64 = cycle_param + 1;
        var i: usize = 0;
        while (i < n_items) : (i += 1) {
            const idx_i64: i64 = @intCast(i);
            if (cycle_len > 0 and @rem(idx_i64 + start, cycle_len) == 0) {
                n = restart;
            }
            seq.items[i] = n;
            n += step_val;
            if (cycle_len > 0 and n == cycle_len) {
                n = restart;
            }
        }
    } else {
        // Mode 0 / unknown: leave items zero-initialized (already are)
        @memset(seq.items, 0);
    }

    return seq;
}

// ─── Accessors ───

pub export fn stz_intseq_len(seq: ?*const IntSeq) callconv(.c) usize {
    const s = seq orelse return 0;
    return s.items.len;
}

pub export fn stz_intseq_at(seq: ?*const IntSeq, index: usize) callconv(.c) i64 {
    const s = seq orelse return 0;
    if (index >= s.items.len) return 0;
    return s.items[index];
}

pub export fn stz_intseq_first(seq: ?*const IntSeq) callconv(.c) i64 {
    const s = seq orelse return 0;
    if (s.items.len == 0) return 0;
    return s.items[0];
}

pub export fn stz_intseq_last(seq: ?*const IntSeq) callconv(.c) i64 {
    const s = seq orelse return 0;
    if (s.items.len == 0) return 0;
    return s.items[s.items.len - 1];
}

// ─── Bulk operations (stay in Zig, no FFI per-element) ───

pub export fn stz_intseq_sum(seq: ?*const IntSeq) callconv(.c) i64 {
    const s = seq orelse return 0;
    var acc: i64 = 0;
    for (s.items) |x| acc += x;
    return acc;
}

pub export fn stz_intseq_min(seq: ?*const IntSeq) callconv(.c) i64 {
    const s = seq orelse return 0;
    if (s.items.len == 0) return 0;
    var m: i64 = s.items[0];
    for (s.items[1..]) |x| if (x < m) { m = x; };
    return m;
}

pub export fn stz_intseq_max(seq: ?*const IntSeq) callconv(.c) i64 {
    const s = seq orelse return 0;
    if (s.items.len == 0) return 0;
    var m: i64 = s.items[0];
    for (s.items[1..]) |x| if (x > m) { m = x; };
    return m;
}

pub export fn stz_intseq_count_value(seq: ?*const IntSeq, value: i64) callconv(.c) usize {
    const s = seq orelse return 0;
    var n: usize = 0;
    for (s.items) |x| if (x == value) { n += 1; };
    return n;
}

// Copy items into a caller-provided buffer; returns count copied.
pub export fn stz_intseq_copy_to_buf(seq: ?*const IntSeq, out: [*]i64, max: usize) callconv(.c) usize {
    const s = seq orelse return 0;
    const n = @min(s.items.len, max);
    @memcpy(out[0..n], s.items[0..n]);
    return n;
}

// ─── Lifecycle ───

pub export fn stz_intseq_free(seq: ?*IntSeq) callconv(.c) void {
    if (seq) |s| s.free();
}

// ─── Tests ───

test "cycle 1..3 when_you_reach=4 restart=1" {
    const seq = stz_intseq_create_cycle(1, 1, 4, 1, 10, 1) orelse unreachable;
    defer stz_intseq_free(seq);
    const expected = [_]i64{ 1, 2, 3, 1, 2, 3, 1, 2, 3, 1 };
    try std.testing.expectEqualSlices(i64, &expected, seq.items);
}

test "cycle after_you_skip=4 restart=0" {
    const seq = stz_intseq_create_cycle(1, 1, 4, 0, 8, 2) orelse unreachable;
    defer stz_intseq_free(seq);
    try std.testing.expectEqual(@as(usize, 8), seq.items.len);
    try std.testing.expectEqual(@as(i64, 0), stz_intseq_first(seq));
}

test "sum + min + max" {
    const seq = stz_intseq_create_cycle(1, 1, 4, 1, 9, 1) orelse unreachable;
    defer stz_intseq_free(seq);
    // 1,2,3,1,2,3,1,2,3  -> sum=18, min=1, max=3
    try std.testing.expectEqual(@as(i64, 18), stz_intseq_sum(seq));
    try std.testing.expectEqual(@as(i64, 1), stz_intseq_min(seq));
    try std.testing.expectEqual(@as(i64, 3), stz_intseq_max(seq));
}
