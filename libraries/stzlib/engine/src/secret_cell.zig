// A secret held by the engine, never by a Ring string -- COMPASS-KERN-07.
//
// Ring has no destructor and copies strings freely, so a value kept in a Ring
// string can be neither wiped nor kept out of the page file: every copy is
// somewhere the library cannot reach. A cell keeps the value in pages the
// engine owns, and answers four questions an auditor can measure:
//
//   locked    the pages are pinned in RAM (VirtualLock / mlock), so the value
//             is never written to the page file; on Windows the answer comes
//             from the OS's own page table (QueryWorkingSetEx), not a flag
//   wiped     release zeroes the pages before they go back, and counts the
//             bytes still non-zero after the wipe (and before it, so the
//             count is seen to see something)
//   compared  equality runs over the whole secret whatever the candidate, so
//             its time does not say where two values first differ
//   revealed  only on request; the revealed copy is a Ring string and is the
//             caller's to keep short
//
// A cell's id lives in the handle table, so a copy of a released secret
// raises instead of reading the next cell to land in that slot.

const std = @import("std");
const builtin = @import("builtin");

const is_windows = builtin.os.tag == .windows;
const page = std.heap.page_size_min;

pub const Cell = struct {
    pages: []align(page) u8,
    len: usize,
    locked: bool,
};

// --- the OS calls -------------------------------------------------------

const win = struct {
    const BOOL = c_int;
    extern "kernel32" fn VirtualLock(addr: *anyopaque, size: usize) callconv(.winapi) BOOL;
    extern "kernel32" fn VirtualUnlock(addr: *anyopaque, size: usize) callconv(.winapi) BOOL;
    extern "kernel32" fn GetCurrentProcess() callconv(.winapi) ?*anyopaque;
    extern "kernel32" fn K32QueryWorkingSetEx(proc: ?*anyopaque, info: *anyopaque, size: u32) callconv(.winapi) BOOL;
    extern "kernel32" fn GetProcessWorkingSetSize(proc: ?*anyopaque, min: *usize, max: *usize) callconv(.winapi) BOOL;
    extern "kernel32" fn SetProcessWorkingSetSize(proc: ?*anyopaque, min: usize, max: usize) callconv(.winapi) BOOL;

    const WsEx = extern struct {
        va: ?*anyopaque,
        attrs: usize,
    };
};

const posix = struct {
    extern "c" fn mlock(addr: *const anyopaque, len: usize) c_int;
    extern "c" fn munlock(addr: *const anyopaque, len: usize) c_int;
};

// Windows lets a process lock only what fits in its MINIMUM working set, about
// 44 one-page cells by default (measured 2026-11-05). A refused lock grows the
// minimum by the cell plus 64 pages of room, and tries once more.
fn lockPages(buf: []u8) bool {
    if (!is_windows) return posix.mlock(buf.ptr, buf.len) == 0;
    if (win.VirtualLock(buf.ptr, buf.len) != 0) return true;
    const proc = win.GetCurrentProcess();
    var lo: usize = 0;
    var hi: usize = 0;
    if (win.GetProcessWorkingSetSize(proc, &lo, &hi) == 0) return false;
    const more = buf.len + 64 * page;
    if (win.SetProcessWorkingSetSize(proc, lo + more, @max(hi, lo + more) + more) == 0) return false;
    return win.VirtualLock(buf.ptr, buf.len) != 0;
}

fn unlockPages(buf: []u8) void {
    if (is_windows) {
        _ = win.VirtualUnlock(buf.ptr, buf.len);
    } else {
        _ = posix.munlock(buf.ptr, buf.len);
    }
}

/// 1 if every page of the cell is locked, 0 if one is not, -1 when the OS gives
/// no way to ask (POSIX: the answer is then mlock's own return, kept in .locked).
pub fn osSaysLocked(c: *const Cell) i32 {
    if (!is_windows) return if (c.locked) 1 else -1;
    var off: usize = 0;
    while (off < c.pages.len) : (off += page) {
        var info = win.WsEx{ .va = @ptrCast(c.pages.ptr + off), .attrs = 0 };
        if (win.K32QueryWorkingSetEx(win.GetCurrentProcess(), &info, @sizeOf(win.WsEx)) == 0) return -1;
        // bit 0 Valid, bit 22 Locked (PSAPI_WORKING_SET_EX_BLOCK)
        if (info.attrs & 1 == 0) return 0;
        if ((info.attrs >> 22) & 1 == 0) return 0;
    }
    return 1;
}

// --- life ---------------------------------------------------------------

var live: usize = 0;
var last_before: usize = 0;
var last_after: usize = 0;

pub fn liveCount() usize {
    return live;
}

pub fn lastResidueBefore() usize {
    return last_before;
}

pub fn lastResidueAfter() usize {
    return last_after;
}

/// A cell holding a copy of bytes. The caller wipes its own copy.
pub fn hold(bytes: []const u8) ?*Cell {
    const n = @max(bytes.len, 1);
    const size = std.mem.alignForward(usize, n, page);
    const pages = std.heap.page_allocator.alignedAlloc(u8, .fromByteUnits(page), size) catch return null;
    const c = std.heap.c_allocator.create(Cell) catch {
        std.heap.page_allocator.free(pages);
        return null;
    };
    // lock BEFORE the value is written, so it is never in a pageable page
    const locked = lockPages(pages);
    @memset(pages, 0);
    @memcpy(pages[0..bytes.len], bytes);
    c.* = .{ .pages = pages, .len = bytes.len, .locked = locked };
    live += 1;
    return c;
}

/// A cell holding n random bytes written as 2n lowercase hex characters. The
/// value is made inside the cell and never exists anywhere else.
pub fn holdRandomHex(n: usize) ?*Cell {
    const c = hold(&[_]u8{}) orelse return null;
    const need = n * 2;
    if (need > c.pages.len) {
        _ = release(c);
        return null;
    }
    const hex = "0123456789abcdef";
    var i: usize = 0;
    while (i < n) : (i += 1) {
        var b: [1]u8 = undefined;
        std.crypto.random.bytes(&b);
        c.pages[i * 2] = hex[b[0] >> 4];
        c.pages[i * 2 + 1] = hex[b[0] & 15];
        std.crypto.secureZero(u8, &b);
    }
    c.len = need;
    return c;
}

fn countNonZero(buf: []const u8) usize {
    const v: [*]const volatile u8 = @ptrCast(buf.ptr);
    var k: usize = 0;
    var i: usize = 0;
    while (i < buf.len) : (i += 1) {
        if (v[i] != 0) k += 1;
    }
    return k;
}

/// Wipe the pages, count what the wipe left, unlock and free. Returns the
/// number of bytes still non-zero after the wipe -- 0 is the only right answer.
pub fn release(c: *Cell) usize {
    last_before = countNonZero(c.pages);
    std.crypto.secureZero(u8, c.pages);
    last_after = countNonZero(c.pages);
    if (c.locked) unlockPages(c.pages);
    std.heap.page_allocator.free(c.pages);
    std.heap.c_allocator.destroy(c);
    if (live > 0) live -= 1;
    return last_after;
}

pub fn value(c: *const Cell) []const u8 {
    return c.pages[0..c.len];
}

// --- comparison ---------------------------------------------------------

/// Equality whose time depends on the SECRET's length only: every byte of the
/// secret is visited whatever the candidate holds, and no branch reads a
/// byte of either side. A different length still costs a full pass.
pub fn ctEqual(secret: []const u8, candidate: []const u8) bool {
    var d: u8 = 0;
    var i: usize = 0;
    while (i < secret.len) : (i += 1) {
        // the index test reads lengths, which are not secret
        const b: u8 = if (i < candidate.len) candidate[i] else 0;
        d |= secret[i] ^ b;
    }
    const vd: *volatile u8 = &d;
    const same_len: u8 = @intFromBool(secret.len == candidate.len);
    return (vd.* == 0) and same_len == 1;
}

/// Nanoseconds for n comparisons -- the instrument the timing guard reads. The
/// plain flag measures std.mem.eql instead, the early-exit comparison the guard
/// holds up as its negative sibling.
pub fn timeCompares(secret: []const u8, candidate: []const u8, n: usize, plain: bool) u64 {
    const t0 = std.time.Instant.now() catch return 0;
    var hits: usize = 0;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const eq = if (plain) std.mem.eql(u8, secret, candidate) else ctEqual(secret, candidate);
        hits += @intFromBool(eq);
        std.mem.doNotOptimizeAway(hits);
    }
    const t1 = std.time.Instant.now() catch return 0;
    return t1.since(t0);
}

/// The median, over `rounds` paired rounds, of time(b) / time(a), each round
/// timing `per` comparisons of each candidate back to back. A preemption spoils
/// one round, not an arm, and the median drops it -- which a ratio of two long
/// totals cannot do on a machine whose load moves (one run in three failed a
/// 0.8..1.25 band that way, 2026-11-05).
pub fn medianRatio(secret: []const u8, a: []const u8, b: []const u8, rounds: usize, per: usize, plain: bool) f64 {
    var buf: [1001]f64 = undefined;
    const r = @min(@max(rounds, 1), buf.len);
    var i: usize = 0;
    while (i < r) : (i += 1) {
        // alternate which arm goes first, so neither always pays a cold cache
        const ta = if (i & 1 == 0) timeCompares(secret, a, per, plain) else 0;
        const tb = timeCompares(secret, b, per, plain);
        const ta2 = if (i & 1 == 1) timeCompares(secret, a, per, plain) else ta;
        buf[i] = @as(f64, @floatFromInt(tb)) / @as(f64, @floatFromInt(@max(ta2, 1)));
    }
    std.mem.sort(f64, buf[0..r], {}, std.sort.asc(f64));
    return buf[r / 2];
}

test "a cell holds, compares and wipes" {
    const c = hold("invented-secret").?;
    try std.testing.expect(ctEqual(value(c), "invented-secret"));
    try std.testing.expect(!ctEqual(value(c), "invented-secreT"));
    try std.testing.expect(!ctEqual(value(c), "invented-secret-longer"));
    try std.testing.expect(!ctEqual(value(c), "invented"));
    try std.testing.expectEqual(@as(usize, 0), release(c));
    try std.testing.expectEqual(@as(usize, 15), lastResidueBefore());
}

test "a random hex cell is 2n characters" {
    const c = holdRandomHex(32).?;
    try std.testing.expectEqual(@as(usize, 64), value(c).len);
    _ = release(c);
}
