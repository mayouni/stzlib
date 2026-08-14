//! THE PRE-RENDERED RING BUFFER -- the seam between the graph and the device.
//! SN3 of SOFTANZA_SOUND_PLAN.md.
//!
//! ── WHY THIS FILE EXISTS AT ALL ──
//!
//! FACT 4: the audio callback is DEADLINE-bound. It fires on a thread the OS
//! owns, every few milliseconds, and missing it produces an audible click that
//! no amount of average throughput repairs. So the callback must not render the
//! graph -- it must CONSUME something already rendered. This is that something.
//!
//! ── AND WHY IT IS ITS OWN FILE ──
//!
//! The producer lives in stz_sound.dll (portable) and the consumer in
//! stz_audiodev.dll (per-OS). The ring therefore straddles a DLL boundary, and
//! a struct whose layout the two sides disagree about would corrupt audio in a
//! way that looks like a hardware fault.
//!
//! The fix is structural: ONE source file, compiled into BOTH DLLs. The layouts
//! cannot drift because there is only one declaration. What crosses the
//! boundary is a POINTER to a plain `extern struct` -- never an engine handle,
//! which keeps the house law intact for the same reason stz_window handing out
//! an HWND does: an address is not a handle.
//!
//! `magic` and `version` are checked on every consumer entry, so a stale
//! pointer from a previous stream is REFUSED rather than played as noise.
//!
//! ── THE DISCIPLINE ──
//!
//! Single producer, single consumer, lock-free. The producer owns write_pos and
//! only ever reads read_pos; the consumer owns read_pos and only ever reads
//! write_pos. No CAS is needed for that, only correct acquire/release ordering:
//! the release on the producer's write_pos publishes the SAMPLES written before
//! it, and the consumer's acquire load is what makes those samples visible.
//! Getting that pairing wrong is not a crash -- it is intermittent garbage on
//! one machine and silence on another.
//!
//! A BOUNDED RECORD COUNTS WHAT IT DROPS (lesson 3). When the consumer finds
//! less than it needs, it fills the remainder with SILENCE -- never with stale
//! samples, which would be an audible repeat -- and bumps `underruns` by the
//! number of frames it could not supply. That counter is the plane's first
//! instrument and the thing SN3's guards are built around.

const std = @import("std");

pub const MAGIC: u32 = 0x53_4E_52_47; // "SNRG"
pub const VERSION: u32 = 2; // 2 added `rate` -- see the field's note

/// extern struct: a fixed, C-compatible layout, because two DLLs read it.
/// Field order is deliberate -- the producer's and consumer's hot fields are
/// separated by padding so they do not share a cache line and force the two
/// threads to fight over it (false sharing turns a lock-free ring into a slow
/// one, silently).
pub const Ring = extern struct {
    magic: u32,
    version: u32,
    channels: u32,
    capacity: u32, // frames; ALWAYS a power of two so wrapping is a mask

    // THE RING CARRIES ITS OWN SAMPLE RATE, and it must.
    //
    // The device tier used to open with sampleRate = 0 -- "let the device
    // pick" -- on the comment "the graph must already match it". Nothing
    // enforced that, and nothing could: the consumer had no way to ask. A
    // graph at 22050 fed a device running at 44100 played every sample twice
    // as fast. Earcons render at 48000 and happened to match, so this stayed
    // invisible until a SPOKEN phrase arrived at 22050 and came out at double
    // speed -- audible as gibberish, and not visible in any counter, because
    // no frames were lost. The rate travels WITH the buffer now, and the
    // device is opened for it.
    rate: u32,

    // ---- producer's line
    write_pos: u64 align(64), // monotonic frame counter, never wraps
    frames_written: u64,
    producer_pad: [48]u8 = @splat(0),

    // ---- consumer's line
    read_pos: u64 align(64), // monotonic frame counter, never wraps
    frames_read: u64,
    underruns: u64, // FRAMES the consumer could not supply
    underrun_events: u64, // how many separate callbacks went short
    consumer_pad: [32]u8 = @splat(0),

    // ---- shared, written once at setup
    running: u32,
    data: [*]f32, // interleaved, capacity * channels

    /// Frames the consumer can take right now.
    pub fn readable(self: *const Ring) u64 {
        const w = @atomicLoad(u64, &self.write_pos, .acquire);
        const r = @atomicLoad(u64, &self.read_pos, .monotonic);
        return w - r;
    }

    /// Frames the producer may write right now.
    pub fn writable(self: *const Ring) u64 {
        const w = @atomicLoad(u64, &self.write_pos, .monotonic);
        const r = @atomicLoad(u64, &self.read_pos, .acquire);
        return @as(u64, self.capacity) - (w - r);
    }

    pub fn valid(self: *const Ring) bool {
        return self.magic == MAGIC and self.version == VERSION and self.capacity > 0;
    }

    /// PRODUCER ONLY. Copy `frames` of PLANAR source into the ring, interleaving
    /// on the way in -- the graph renders planar (SN0 measured that faster) and
    /// the device wants interleaved, so the one transposition happens here,
    /// on the producer's thread, where there is no deadline.
    ///
    /// Returns frames actually written (0 if full). Never blocks.
    pub fn pushPlanar(self: *Ring, planes: []const []const f32, frames: usize) usize {
        const room = self.writable();
        const n = @min(frames, @as(usize, @intCast(room)));
        if (n == 0) return 0;
        const cap: usize = self.capacity;
        const mask = cap - 1;
        const nch: usize = self.channels;
        const w = @atomicLoad(u64, &self.write_pos, .monotonic);
        var i: usize = 0;
        while (i < n) : (i += 1) {
            const slot = @as(usize, @intCast((w + i) & mask));
            var ch: usize = 0;
            while (ch < nch) : (ch += 1) {
                self.data[slot * nch + ch] = if (ch < planes.len) planes[ch][i] else 0;
            }
        }
        self.frames_written += n;
        // RELEASE: everything written above becomes visible to the consumer
        // before it can observe the new write_pos. This one ordering is the
        // whole correctness argument of the ring.
        @atomicStore(u64, &self.write_pos, w + n, .release);
        return n;
    }

    /// CONSUMER ONLY -- this runs INSIDE the audio callback. No allocation, no
    /// lock, no Ring/VM call: a bounded copy and two atomics.
    ///
    /// Short reads are filled with SILENCE and COUNTED. Silence rather than
    /// stale samples because a repeated buffer is an audible artefact that
    /// sounds like content, whereas a gap sounds like the fault it is.
    pub fn popInterleaved(self: *Ring, out: [*]f32, frames: usize) usize {
        if (!self.valid()) {
            @memset(out[0 .. frames * self.channels], 0);
            return 0;
        }
        const avail = self.readable();
        const n = @min(frames, @as(usize, @intCast(avail)));
        const cap: usize = self.capacity;
        const mask = cap - 1;
        const nch: usize = self.channels;
        const r = @atomicLoad(u64, &self.read_pos, .monotonic);

        var i: usize = 0;
        while (i < n) : (i += 1) {
            const slot = @as(usize, @intCast((r + i) & mask));
            var ch: usize = 0;
            while (ch < nch) : (ch += 1) out[i * nch + ch] = self.data[slot * nch + ch];
        }
        if (n < frames) {
            @memset(out[n * nch .. frames * nch], 0);
            self.underruns += frames - n;
            self.underrun_events += 1;
        }
        self.frames_read += n;
        @atomicStore(u64, &self.read_pos, r + n, .release);
        return n;
    }

    /// PRODUCER, from a CAPTURE callback. The mirror of popInterleaved: the
    /// device hands us interleaved frames it just recorded, and we copy them in.
    ///
    /// Capture runs the ring the other way round -- the audio callback is the
    /// PRODUCER and the Ring thread the consumer -- which is exactly why this is
    /// written as a single-producer/single-consumer ring rather than as a
    /// playback buffer. One structure, both directions.
    ///
    /// OVERRUN is the capture-side twin of underrun: if the reader has not kept
    /// up, incoming frames have nowhere to go. They are DROPPED and COUNTED,
    /// never written over unread audio -- losing the newest is recoverable,
    /// losing the middle of a recording silently is not.
    pub fn pushInterleaved(self: *Ring, src: [*]const f32, frames: usize) usize {
        if (!self.valid()) return 0;
        const room = self.writable();
        const n = @min(frames, @as(usize, @intCast(room)));
        const cap: usize = self.capacity;
        const mask = cap - 1;
        const nch: usize = self.channels;
        const w = @atomicLoad(u64, &self.write_pos, .monotonic);
        var i: usize = 0;
        while (i < n) : (i += 1) {
            const slot = @as(usize, @intCast((w + i) & mask));
            var ch: usize = 0;
            while (ch < nch) : (ch += 1) self.data[slot * nch + ch] = src[i * nch + ch];
        }
        if (n < frames) {
            self.underruns += frames - n; // frames the ring could not accept
            self.underrun_events += 1;
        }
        self.frames_written += n;
        @atomicStore(u64, &self.write_pos, w + n, .release);
        return n;
    }
};

/// Capacity must be a power of two: the wrap is then a mask rather than a
/// modulo, which matters because `pushPlanar` does it per frame per channel.
pub fn roundUpPow2(n: usize) usize {
    var m: usize = 1;
    while (m < n) m <<= 1;
    return m;
}

// ---------------------------------------------------------------- tests

const testing = std.testing;

fn makeTestRing(alloc: std.mem.Allocator, cap: usize, ch: u32) !*Ring {
    const r = try alloc.create(Ring);
    r.* = .{
        .magic = MAGIC,
        .version = VERSION,
        .channels = ch,
        .capacity = @intCast(cap),
        .rate = 48000,
        .write_pos = 0,
        .frames_written = 0,
        .read_pos = 0,
        .frames_read = 0,
        .underruns = 0,
        .underrun_events = 0,
        .running = 1,
        .data = (try alloc.alloc(f32, cap * ch)).ptr,
    };
    return r;
}

test "the ring round-trips samples exactly, and interleaves on the way in" {
    const alloc = testing.allocator;
    const r = try makeTestRing(alloc, 8, 2);
    defer {
        alloc.free(r.data[0 .. 8 * 2]);
        alloc.destroy(r);
    }

    const l = [_]f32{ 1, 2, 3, 4 };
    const rr = [_]f32{ -1, -2, -3, -4 };
    const planes = [_][]const f32{ &l, &rr };
    try testing.expectEqual(@as(usize, 4), r.pushPlanar(&planes, 4));
    try testing.expectEqual(@as(u64, 4), r.readable());

    var out: [8]f32 = @splat(0);
    try testing.expectEqual(@as(usize, 4), r.popInterleaved(&out, 4));
    const want = [_]f32{ 1, -1, 2, -2, 3, -3, 4, -4 };
    for (want, out) |w, g| try testing.expectEqual(w, g);
    try testing.expectEqual(@as(u64, 0), r.underruns);
}

test "an empty ring yields SILENCE and COUNTS the frames it could not supply" {
    const alloc = testing.allocator;
    const r = try makeTestRing(alloc, 8, 2);
    defer {
        alloc.free(r.data[0 .. 8 * 2]);
        alloc.destroy(r);
    }

    // only 2 frames available, 4 asked for
    const l = [_]f32{ 9, 9 };
    const planes = [_][]const f32{ &l, &l };
    _ = r.pushPlanar(&planes, 2);

    var out: [8]f32 = @splat(7); // poison, so silence is provably WRITTEN
    try testing.expectEqual(@as(usize, 2), r.popInterleaved(&out, 4));
    try testing.expectEqual(@as(f32, 9), out[0]);
    try testing.expectEqual(@as(f32, 9), out[3]);
    // the shortfall is silence, NOT the previous contents and NOT a repeat
    for (4..8) |i| try testing.expectEqual(@as(f32, 0), out[i]);
    // and it is COUNTED, in frames and in events
    try testing.expectEqual(@as(u64, 2), r.underruns);
    try testing.expectEqual(@as(u64, 1), r.underrun_events);

    // NEGATIVE SIBLING: a full read must NOT bump the counter, or "underruns
    // moved" would prove nothing
    _ = r.pushPlanar(&planes, 2);
    _ = r.popInterleaved(&out, 2);
    try testing.expectEqual(@as(u64, 2), r.underruns);
    try testing.expectEqual(@as(u64, 1), r.underrun_events);
}

test "the ring wraps without losing or duplicating a single frame" {
    const alloc = testing.allocator;
    const cap = 8;
    const r = try makeTestRing(alloc, cap, 1);
    defer {
        alloc.free(r.data[0..cap]);
        alloc.destroy(r);
    }

    // push and pop 3 at a time through many wraps, checking the sequence is
    // exactly the naturals -- an off-by-one in the mask shows up as a repeat
    var next_write: f32 = 0;
    var expect: f32 = 0;
    var out: [3]f32 = @splat(0);
    var round: usize = 0;
    while (round < 50) : (round += 1) {
        var src: [3]f32 = undefined;
        for (&src) |*v| {
            v.* = next_write;
            next_write += 1;
        }
        const planes = [_][]const f32{&src};
        try testing.expectEqual(@as(usize, 3), r.pushPlanar(&planes, 3));
        try testing.expectEqual(@as(usize, 3), r.popInterleaved(&out, 3));
        for (out) |g| {
            try testing.expectEqual(expect, g);
            expect += 1;
        }
    }
    try testing.expectEqual(@as(u64, 0), r.underruns);
    try testing.expectEqual(@as(u64, 150), r.frames_read);
}

test "a full ring refuses the write rather than overwriting unread audio" {
    const alloc = testing.allocator;
    const cap = 4;
    const r = try makeTestRing(alloc, cap, 1);
    defer {
        alloc.free(r.data[0..cap]);
        alloc.destroy(r);
    }
    const src = [_]f32{ 1, 2, 3, 4, 5, 6 };
    const planes = [_][]const f32{&src};
    // asks for 6, capacity is 4 -> exactly 4 written, none lost
    try testing.expectEqual(@as(usize, 4), r.pushPlanar(&planes, 6));
    try testing.expectEqual(@as(u64, 0), r.writable());
    try testing.expectEqual(@as(usize, 0), r.pushPlanar(&planes, 1));
    // and what IS in there is the first four, unclobbered
    var out: [4]f32 = @splat(0);
    _ = r.popInterleaved(&out, 4);
    for ([_]f32{ 1, 2, 3, 4 }, out) |w, g| try testing.expectEqual(w, g);
}

test "a stale or foreign pointer is REFUSED, and yields silence not noise" {
    const alloc = testing.allocator;
    const r = try makeTestRing(alloc, 8, 2);
    defer {
        alloc.free(r.data[0 .. 8 * 2]);
        alloc.destroy(r);
    }
    r.magic = 0xDEADBEEF; // what a freed-and-reused block looks like
    try testing.expect(!r.valid());
    var out: [8]f32 = @splat(7);
    try testing.expectEqual(@as(usize, 0), r.popInterleaved(&out, 4));
    for (out) |v| try testing.expectEqual(@as(f32, 0), v);
}

test "producer and consumer on REAL threads lose nothing" {
    // The single-threaded tests above cannot catch a missing release/acquire
    // pairing. This one runs the two sides concurrently on a ring small enough
    // that they genuinely contend, and asserts the consumer sees the exact
    // sequence the producer wrote.
    const alloc = testing.allocator;
    const cap = 64;
    const r = try makeTestRing(alloc, cap, 1);
    defer {
        alloc.free(r.data[0..cap]);
        alloc.destroy(r);
    }
    const TOTAL: usize = 200_000;

    const Producer = struct {
        fn run(ring: *Ring, total: usize) void {
            var v: f32 = 0;
            var written: usize = 0;
            var chunk: [16]f32 = undefined;
            while (written < total) {
                const n = @min(chunk.len, total - written);
                for (chunk[0..n]) |*x| {
                    x.* = v;
                    v += 1;
                }
                const planes = [_][]const f32{chunk[0..n]};
                var done: usize = 0;
                while (done < n) {
                    const got = ring.pushPlanar(&[_][]const f32{planes[0][done..n]}, n - done);
                    if (got == 0) std.Thread.yield() catch {};
                    done += got;
                }
                written += n;
            }
        }
    };

    var th = try std.Thread.spawn(.{}, Producer.run, .{ r, TOTAL });
    var expect: f32 = 0;
    var read: usize = 0;
    var out: [16]f32 = undefined;
    var mismatches: usize = 0;
    while (read < TOTAL) {
        const want = @min(out.len, TOTAL - read);
        const got = r.popInterleaved(&out, want);
        for (out[0..got]) |g| {
            if (g != expect) mismatches += 1;
            expect += 1;
        }
        read += got;
        if (got == 0) std.Thread.yield() catch {};
    }
    th.join();
    // every frame, in order, exactly once
    try testing.expectEqual(@as(usize, 0), mismatches);
    try testing.expectEqual(@as(u64, TOTAL), r.frames_read);
}


test "capture direction: the callback pushes, the reader pops, nothing is lost" {
    const alloc = testing.allocator;
    const r = try makeTestRing(alloc, 8, 2);
    defer {
        alloc.free(r.data[0 .. 8 * 2]);
        alloc.destroy(r);
    }
    const recorded = [_]f32{ 1, -1, 2, -2, 3, -3 }; // 3 interleaved stereo frames
    try testing.expectEqual(@as(usize, 3), r.pushInterleaved(&recorded, 3));
    var out: [6]f32 = @splat(0);
    try testing.expectEqual(@as(usize, 3), r.popInterleaved(&out, 3));
    for (recorded, out) |w, g| try testing.expectEqual(w, g);

    // OVERRUN: a reader that stops reading loses the NEWEST frames, counted
    const big = [_]f32{9} ** 40;
    const took = r.pushInterleaved(&big, 20);
    try testing.expect(took < 20);
    try testing.expect(r.underruns > 0);
}
