//! SOUND ANALYSIS -- spectrum, spectrogram, onsets, tempo, loudness.
//! SN5 of SOFTANZA_SOUND_PLAN.md.
//!
//! ── NOT NEW CAPABILITY: EXISTING CAPABILITY POINTED AT A NEW DOMAIN ──
//!
//! FACT 2 of the plan said the signal half was already strong, and this file is
//! where that gets cashed. Every transform below rides `fft.zig` -- the same
//! radix-2/Bluestein pair the numeric tier has had all along, held to a
//! LAPACK-grade reference by its own guards. Nothing here reimplements a DFT.
//!
//! ── THE OUTPUT IS A DATA MODEL, NEVER A PICTURE ──
//!
//! A spectrogram is a GRID OF NUMBERS. Drawing it is the graphics plane's job,
//! and keeping that boundary is what makes the analysis testable at all: a
//! guard can assert that a 1 kHz sine puts its energy in the 1 kHz bin, which
//! is a statement about numbers. "The picture looks right" is not a statement
//! about anything.
//!
//! So everything here returns a GRID -- rows x cols of f64, gen-keyed like
//! every other handle in this engine. A spectrum is one row. A spectrogram is
//! many. Onset times are one row. One shape, one lifetime discipline, one
//! table.
//!
//! ── LOUDNESS IS A STANDARD, NOT AN OPINION ──
//!
//! `loudness()` implements ITU-R BS.1770-4 (LUFS): K-weighting, 400 ms blocks
//! at 75% overlap, absolute gate at -70 LUFS then a relative gate 10 LU below
//! the ungated mean. It is specified precisely enough that a guard can check it
//! against arithmetic rather than against a previous run -- which is the whole
//! reason to implement the standard instead of inventing a loudness number.

const std = @import("std");
const fft = @import("fft.zig");
const snd = @import("sound.zig");

const alloc = std.heap.c_allocator;

pub const OK: i32 = 0;
pub const STALE: i32 = 2;
pub const BAD_ARG: i32 = 3;
pub const UNSUPPORTED: i32 = 6;

// ---------------------------------------------------------------- counters

pub const CTR_GRIDS_LIVE = 0; // sound.analysis.grids.live
pub const CTR_TRANSFORMS = 1; // sound.analysis.transforms -- FFTs performed
pub const CTR_REFUSALS = 2; // sound.analysis.refusals
pub const CTR_COUNT = 3;

var counters: [CTR_COUNT]f64 = @splat(0);

pub fn counter(i: usize) f64 {
    if (i >= CTR_COUNT) return 0;
    return counters[i];
}

pub fn countersReset() void {
    counters = @splat(0);
    var live: f64 = 0;
    for (grids.items) |g| {
        if (g.live) live += 1;
    }
    counters[CTR_GRIDS_LIVE] = live;
}

var last_error_buf: [512]u8 = @splat(0);
var last_error_len: usize = 0;

fn setErr(msg: []const u8) void {
    const n = @min(msg.len, last_error_buf.len);
    @memcpy(last_error_buf[0..n], msg[0..n]);
    last_error_len = n;
}

pub fn lastError() []const u8 {
    return last_error_buf[0..last_error_len];
}

fn refuse(msg: []const u8) void {
    counters[CTR_REFUSALS] += 1;
    setErr(msg);
}

// ---------------------------------------------------------------- the grid
//
// One result shape for every analysis. A spectrum is 1 x bins; a spectrogram
// is frames x bins; onset times are 1 x n. `x_step` and `y_step` carry what a
// row and a column MEAN (seconds per row, hertz per column), so a caller can
// label an axis without recomputing what the analysis already knew.

const Grid = struct {
    data: []f64 = &.{},
    rows: usize = 0,
    cols: usize = 0,
    x_step: f64 = 0, // seconds per row (spectrogram hop), or 0
    y_step: f64 = 0, // hertz per column (bin width), or 0
    gen: u32 = 1,
    live: bool = false,
};

var grids: std.ArrayList(Grid) = .{};

fn makeId(slot: usize, gen: u32) i64 {
    return (@as(i64, gen) << 32) | @as(i64, @intCast(slot + 1));
}

fn slotOf(id: i64) ?usize {
    const idx = id & 0xffff_ffff;
    if (idx <= 0 or idx > @as(i64, @intCast(grids.items.len))) return null;
    const s: usize = @intCast(idx - 1);
    const gen: u32 = @intCast((id >> 32) & 0xffff_ffff);
    if (!grids.items[s].live or grids.items[s].gen != gen) return null;
    return s;
}

fn adoptGrid(data: []f64, rows: usize, cols: usize, x_step: f64, y_step: f64) i64 {
    for (grids.items, 0..) |*g, i| {
        if (!g.live) {
            g.* = .{ .data = data, .rows = rows, .cols = cols, .x_step = x_step, .y_step = y_step, .gen = g.gen, .live = true };
            counters[CTR_GRIDS_LIVE] += 1;
            return makeId(i, g.gen);
        }
    }
    grids.append(alloc, .{ .data = data, .rows = rows, .cols = cols, .x_step = x_step, .y_step = y_step, .gen = 1, .live = true }) catch {
        alloc.free(data);
        setErr("out of memory growing the grid table");
        return 0;
    };
    counters[CTR_GRIDS_LIVE] += 1;
    return makeId(grids.items.len - 1, 1);
}

pub fn gridRows(id: i64) f64 {
    const s = slotOf(id) orelse return -1;
    return @floatFromInt(grids.items[s].rows);
}

pub fn gridCols(id: i64) f64 {
    const s = slotOf(id) orelse return -1;
    return @floatFromInt(grids.items[s].cols);
}

pub fn gridXStep(id: i64) f64 {
    const s = slotOf(id) orelse return -1;
    return grids.items[s].x_step;
}

pub fn gridYStep(id: i64) f64 {
    const s = slotOf(id) orelse return -1;
    return grids.items[s].y_step;
}

/// 0-based, like every engine surface. The Ring face translates.
pub fn gridAt(id: i64, row: usize, col: usize) f64 {
    const s = slotOf(id) orelse return 0;
    const g = grids.items[s];
    if (row >= g.rows or col >= g.cols) return 0;
    return g.data[row * g.cols + col];
}

/// The largest value anywhere -- what a drawing needs to scale by, computed
/// here so a caller does not walk the whole grid across the FFI to find it.
pub fn gridMax(id: i64) f64 {
    const s = slotOf(id) orelse return 0;
    var mx: f64 = 0;
    for (grids.items[s].data) |v| mx = @max(mx, v);
    return mx;
}

/// The column holding the largest value in a row -- "which frequency won".
pub fn gridArgMaxInRow(id: i64, row: usize) f64 {
    const s = slotOf(id) orelse return -1;
    const g = grids.items[s];
    if (row >= g.rows) return -1;
    var best: usize = 0;
    var bv: f64 = -1;
    for (0..g.cols) |c| {
        const v = g.data[row * g.cols + c];
        if (v > bv) {
            bv = v;
            best = c;
        }
    }
    return @floatFromInt(best);
}

pub fn gridFree(id: i64) i32 {
    const s = slotOf(id) orelse return STALE;
    alloc.free(grids.items[s].data);
    grids.items[s].data = &.{};
    grids.items[s].live = false;
    grids.items[s].gen +%= 1;
    if (grids.items[s].gen == 0) grids.items[s].gen = 1;
    counters[CTR_GRIDS_LIVE] -= 1;
    return OK;
}

// ---------------------------------------------------------------- windows

/// Hann. A rectangular window smears a pure tone across every bin (spectral
/// leakage), which would make "the 1 kHz sine is in the 1 kHz bin" false for
/// reasons that have nothing to do with the signal.
fn hann(n: usize, i: usize) f64 {
    if (n <= 1) return 1;
    const x = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(n - 1));
    return 0.5 - 0.5 * @cos(2.0 * std.math.pi * x);
}

fn nextPow2(n: usize) usize {
    var m: usize = 1;
    while (m < n) m <<= 1;
    return m;
}

// ---------------------------------------------------------------- spectrum

/// The magnitude spectrum of one window, starting at `start` frames in.
/// Returns a 1 x (fft_size/2 + 1) grid; y_step is the bin width in hertz.
///
/// Only the first half is kept: a real signal's spectrum is conjugate
/// symmetric, so bins above Nyquist are the same numbers mirrored, and
/// returning them invites a caller to find a "second peak" that is not there.
pub fn spectrum(buffer_id: i64, channel: u32, start: usize, fft_size: usize) i64 {
    const frames: usize = @intFromFloat(@max(0, snd.frameCount(buffer_id)));
    const rate = snd.sampleRate(buffer_id);
    if (frames == 0 or rate <= 0) {
        refuse("spectrum: that buffer is empty or stale");
        return 0;
    }
    const n = nextPow2(fft_size);
    if (n < 8 or n > 1 << 20) {
        refuse("spectrum: fft size must be 8..1048576");
        return 0;
    }
    const re = alloc.alloc(f64, n) catch return 0;
    defer alloc.free(re);
    const im = alloc.alloc(f64, n) catch return 0;
    defer alloc.free(im);
    @memset(im, 0);
    for (0..n) |i| {
        const f = start + i;
        const v: f64 = if (f < frames) snd.getSample(buffer_id, f, channel) else 0;
        re[i] = v * hann(n, i);
    }
    const bins = n / 2 + 1;
    const out = alloc.alloc(f64, bins) catch return 0;
    const mag = alloc.alloc(f64, n) catch {
        alloc.free(out);
        return 0;
    };
    defer alloc.free(mag);
    fft.magnitudes(alloc, re, im, mag) catch {
        alloc.free(out);
        refuse("spectrum: the transform failed");
        return 0;
    };
    counters[CTR_TRANSFORMS] += 1;
    // scale so a full-scale sine reads ~1.0 rather than ~n/4: the window
    // halves the energy and the FFT multiplies by n, and a caller should not
    // have to know either
    const scale = 2.0 / (@as(f64, @floatFromInt(n)) * 0.5);
    for (0..bins) |i| out[i] = mag[i] * scale;
    return adoptGrid(out, 1, bins, 0, rate / @as(f64, @floatFromInt(n)));
}

/// The strongest frequency in the whole buffer, in hertz.
pub fn dominantFrequency(buffer_id: i64, channel: u32, fft_size: usize) f64 {
    const gid = spectrum(buffer_id, channel, 0, fft_size);
    if (gid == 0) return -1;
    defer _ = gridFree(gid);
    const bin = gridArgMaxInRow(gid, 0);
    if (bin < 0) return -1;
    return bin * gridYStep(gid);
}

// ---------------------------------------------------------------- spectrogram

const SpecJob = struct {
    buffer_id: i64,
    channel: u32,
    frames: usize,
    n: usize,
    hop: usize,
    bins: usize,
    out: []f64,
    row_from: usize,
    row_to: usize,
};

fn spectrogramRows(job: SpecJob) void {
    const re = alloc.alloc(f64, job.n) catch return;
    defer alloc.free(re);
    const im = alloc.alloc(f64, job.n) catch return;
    defer alloc.free(im);
    const mag = alloc.alloc(f64, job.n) catch return;
    defer alloc.free(mag);
    const scale = 2.0 / (@as(f64, @floatFromInt(job.n)) * 0.5);

    var row = job.row_from;
    while (row < job.row_to) : (row += 1) {
        const start = row * job.hop;
        @memset(im, 0);
        for (0..job.n) |i| {
            const f = start + i;
            const v: f64 = if (f < job.frames) snd.getSample(job.buffer_id, f, job.channel) else 0;
            re[i] = v * hann(job.n, i);
        }
        fft.magnitudes(alloc, re, im, mag) catch return;
        for (0..job.bins) |b| job.out[row * job.bins + b] = mag[b] * scale;
    }
}

/// A spectrogram: one row per window, one column per frequency bin.
///
/// MULTICORE, because the plan said so and because it is the one analysis
/// that is embarrassingly parallel -- every row is an independent FFT over a
/// different slice of the same immutable buffer. Rows are split across
/// threads; with one thread it is the same code path, so the guard can compare
/// the two and assert they agree exactly.
pub fn spectrogram(buffer_id: i64, channel: u32, fft_size: usize, hop: usize, threads: u32) i64 {
    const frames: usize = @intFromFloat(@max(0, snd.frameCount(buffer_id)));
    const rate = snd.sampleRate(buffer_id);
    if (frames == 0 or rate <= 0) {
        refuse("spectrogram: that buffer is empty or stale");
        return 0;
    }
    const n = nextPow2(fft_size);
    const h = if (hop == 0) n / 4 else hop;
    if (n < 8 or n > 1 << 18 or h == 0) {
        refuse("spectrogram: fft size 8..262144 and hop > 0");
        return 0;
    }
    if (frames <= n) {
        refuse("spectrogram: the sound is shorter than one window");
        return 0;
    }
    const rows = (frames - n) / h + 1;
    const bins = n / 2 + 1;
    const out = alloc.alloc(f64, rows * bins) catch {
        setErr("out of memory allocating the spectrogram");
        return 0;
    };

    var nthreads: usize = @max(1, threads);
    if (nthreads > 32) nthreads = 32;
    if (rows < nthreads * 2) nthreads = 1;

    if (nthreads == 1) {
        spectrogramRows(.{
            .buffer_id = buffer_id, .channel = channel, .frames = frames,
            .n = n, .hop = h, .bins = bins, .out = out,
            .row_from = 0, .row_to = rows,
        });
    } else {
        var handles: [32]std.Thread = undefined;
        var spawned: usize = 0;
        const per = rows / nthreads;
        var t: usize = 0;
        while (t < nthreads) : (t += 1) {
            const from = t * per;
            const to = if (t + 1 == nthreads) rows else (t + 1) * per;
            const job = SpecJob{
                .buffer_id = buffer_id, .channel = channel, .frames = frames,
                .n = n, .hop = h, .bins = bins, .out = out,
                .row_from = from, .row_to = to,
            };
            handles[t] = std.Thread.spawn(.{}, spectrogramRows, .{job}) catch {
                // could not spawn: do this slice here rather than lose it
                spectrogramRows(job);
                continue;
            };
            spawned += 1;
        }
        for (handles[0..spawned]) |th| th.join();
    }
    counters[CTR_TRANSFORMS] += @floatFromInt(rows);
    return adoptGrid(out, rows, bins, @as(f64, @floatFromInt(h)) / rate, rate / @as(f64, @floatFromInt(n)));
}

// ---------------------------------------------------------------- onsets

/// Where notes START, in seconds. Returns a 1 x n grid of times.
///
/// The method is SPECTRAL FLUX: how much the spectrum GREW between one window
/// and the next, summed over bins. Only growth counts -- a note ending is not
/// a note starting, and counting the fall as well would double every event.
/// A peak is kept when it is above a local moving average by `sensitivity`
/// and is the largest in its neighbourhood, so one attack yields one onset
/// rather than a cluster.
pub fn onsets(buffer_id: i64, channel: u32, fft_size: usize, hop: usize, sensitivity: f64) i64 {
    const sg = spectrogram(buffer_id, channel, fft_size, hop, 4);
    if (sg == 0) return 0;
    defer _ = gridFree(sg);
    const s = slotOf(sg).?;
    const g = grids.items[s];
    if (g.rows < 3) {
        refuse("onsets: too short to find anything");
        return 0;
    }

    const flux = alloc.alloc(f64, g.rows) catch return 0;
    defer alloc.free(flux);
    flux[0] = 0;
    var mag_total: f64 = 0;
    for (1..g.rows) |r| {
        var sum: f64 = 0;
        var tot: f64 = 0;
        for (0..g.cols) |c| {
            const cur = g.data[r * g.cols + c];
            const d = cur - g.data[(r - 1) * g.cols + c];
            if (d > 0) sum += d;
            tot += cur;
        }
        flux[r] = sum;
        mag_total += tot;
    }

    // AN ABSOLUTE FLOOR, not only a relative one.
    //
    // The first version compared flux against a moving average of ITSELF and
    // nothing else. On a steady tone the flux is numerical noise -- tiny, but
    // tiny numbers still have peaks above their own tiny mean -- so it found
    // "onsets" everywhere and reported a 440 Hz sine as 1125 BPM.
    //
    // A note starting changes the spectrum by an amount comparable to the
    // spectrum itself. So a peak must also be a real fraction of the average
    // spectral magnitude, which a steady tone's noise never is.
    const mean_mag = mag_total / @as(f64, @floatFromInt(g.rows - 1));
    const floor_abs = mean_mag * 0.02;

    // a moving average as the floor: a fixed threshold works on one recording
    // and no other, because it encodes that recording's loudness
    const W = 8;
    var times: std.ArrayList(f64) = .{};
    defer times.deinit(alloc);
    var last_row: usize = 0;
    var found_any = false;
    for (1..g.rows - 1) |r| {
        const lo = if (r > W) r - W else 0;
        const hi = @min(g.rows, r + W);
        var mean: f64 = 0;
        for (lo..hi) |k| mean += flux[k];
        mean /= @floatFromInt(hi - lo);
        if (flux[r] <= floor_abs) continue; // nothing actually changed here
        if (flux[r] <= mean * (1.0 + sensitivity)) continue;
        if (flux[r] < flux[r - 1] or flux[r] < flux[r + 1]) continue; // local peak only
        // one attack, one onset: ignore anything within 50 ms of the last
        if (found_any and (@as(f64, @floatFromInt(r - last_row)) * g.x_step) < 0.05) continue;
        times.append(alloc, @as(f64, @floatFromInt(r)) * g.x_step) catch break;
        last_row = r;
        found_any = true;
    }

    const out = alloc.alloc(f64, @max(1, times.items.len)) catch return 0;
    for (times.items, 0..) |t, i| out[i] = t;
    return adoptGrid(out, 1, times.items.len, 0, 0);
}

/// Beats per minute, from the gaps between onsets.
///
/// The MEDIAN gap, not the mean: one missed onset doubles a gap, and a mean
/// would carry that error into the answer while a median shrugs it off.
/// Returns -1 when there are too few onsets to say anything, which is a
/// better answer than a confident number derived from two events.
pub fn tempo(buffer_id: i64, channel: u32) f64 {
    const oid = onsets(buffer_id, channel, 2048, 512, 0.35);
    if (oid == 0) return -1;
    defer _ = gridFree(oid);
    const n: usize = @intFromFloat(@max(0, gridCols(oid)));
    if (n < 3) {
        refuse("tempo: fewer than three onsets -- not enough to time anything");
        return -1;
    }
    const gaps = alloc.alloc(f64, n - 1) catch return -1;
    defer alloc.free(gaps);
    for (0..n - 1) |i| gaps[i] = gridAt(oid, 0, i + 1) - gridAt(oid, 0, i);
    std.mem.sort(f64, gaps, {}, std.sort.asc(f64));
    const med = gaps[gaps.len / 2];
    if (med <= 0.0001) return -1;
    return 60.0 / med;
}

// ---------------------------------------------------------------- loudness
//
// ITU-R BS.1770-4. The coefficients below are the standard's own, specified
// at 48 kHz -- which is why `loudness` REFUSES another rate rather than
// applying them anyway and returning a number that looks plausible. The Ring
// face resamples a copy; the engine will not guess.

const PRE_B = [3]f64{ 1.53512485958697, -2.69169618940638, 1.19839281085285 };
const PRE_A = [3]f64{ 1.0, -1.69065929318241, 0.73248077421585 };
const RLB_B = [3]f64{ 1.0, -2.0, 1.0 };
const RLB_A = [3]f64{ 1.0, -1.99004745483398, 0.99007225036621 };

fn biquadInPlace(x: []f64, b: [3]f64, a: [3]f64) void {
    var x1: f64 = 0;
    var x2: f64 = 0;
    var y1: f64 = 0;
    var y2: f64 = 0;
    for (x) |*v| {
        const in = v.*;
        const out = b[0] * in + b[1] * x1 + b[2] * x2 - a[1] * y1 - a[2] * y2;
        x2 = x1;
        x1 = in;
        y2 = y1;
        y1 = out;
        v.* = out;
    }
}

/// Integrated loudness in LUFS. -1000 means "silence" (the standard's answer
/// is minus infinity; a sentinel is what crosses an FFI).
pub fn loudness(buffer_id: i64) f64 {
    const frames: usize = @intFromFloat(@max(0, snd.frameCount(buffer_id)));
    const chans: u32 = @intFromFloat(@max(0, snd.channelCount(buffer_id)));
    const rate = snd.sampleRate(buffer_id);
    if (frames == 0 or chans == 0) {
        refuse("loudness: that buffer is empty or stale");
        return -1000;
    }
    if (@abs(rate - 48000) > 0.5) {
        refuse("loudness: BS.1770 K-weighting is specified at 48 kHz -- resample first");
        return -1000;
    }
    const block = 4800 * 4; // 400 ms
    const step = 4800; // 100 ms -> 75% overlap
    if (frames < block) {
        refuse("loudness: shorter than one 400 ms block");
        return -1000;
    }

    // K-weight each channel once, then measure blocks over the filtered signal
    var z_sum = alloc.alloc(f64, ((frames - block) / step) + 1) catch return -1000;
    defer alloc.free(z_sum);
    @memset(z_sum, 0);

    const buf = alloc.alloc(f64, frames) catch return -1000;
    defer alloc.free(buf);

    var ch: u32 = 0;
    while (ch < chans) : (ch += 1) {
        for (0..frames) |i| buf[i] = snd.getSample(buffer_id, i, ch);
        biquadInPlace(buf, PRE_B, PRE_A);
        biquadInPlace(buf, RLB_B, RLB_A);
        // channel weights: L/R/C are 1.0; surrounds would be 1.41, and this
        // plane does not claim surround, so anything past stereo weighs 1.0
        const gw: f64 = 1.0;
        var bi: usize = 0;
        while (bi < z_sum.len) : (bi += 1) {
            const from = bi * step;
            var acc: f64 = 0;
            for (buf[from..][0..block]) |v| acc += v * v;
            z_sum[bi] += gw * (acc / @as(f64, @floatFromInt(block)));
        }
    }

    // absolute gate at -70 LUFS
    var kept: std.ArrayList(f64) = .{};
    defer kept.deinit(alloc);
    for (z_sum) |z| {
        if (z <= 0) continue;
        const l = -0.691 + 10.0 * std.math.log10(z);
        if (l > -70.0) kept.append(alloc, z) catch {};
    }
    if (kept.items.len == 0) return -1000;

    // relative gate: 10 LU below the mean of what survived the absolute gate
    var mean: f64 = 0;
    for (kept.items) |z| mean += z;
    mean /= @floatFromInt(kept.items.len);
    const rel = -0.691 + 10.0 * std.math.log10(mean) - 10.0;

    var final_sum: f64 = 0;
    var final_n: usize = 0;
    for (kept.items) |z| {
        const l = -0.691 + 10.0 * std.math.log10(z);
        if (l > rel) {
            final_sum += z;
            final_n += 1;
        }
    }
    if (final_n == 0) return -1000;
    return -0.691 + 10.0 * std.math.log10(final_sum / @as(f64, @floatFromInt(final_n)));
}

// ---------------------------------------------------------------- tests

const testing = std.testing;

fn makeTone(hz: f64, secs: f64, amp: f64, rate: u32) i64 {
    const n: usize = @intFromFloat(secs * @as(f64, @floatFromInt(rate)));
    const id = snd.newSilent(n, 1, rate);
    for (0..n) |i| {
        const t = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(rate));
        _ = snd.setSample(id, i, 0, amp * @sin(2.0 * std.math.pi * hz * t));
    }
    return id;
}

test "a 1 kHz sine puts its energy in the 1 kHz bin, and nowhere else" {
    const id = makeTone(1000, 0.5, 0.8, 48000);
    defer _ = snd.free(id);
    const g = spectrum(id, 0, 0, 4096);
    defer _ = gridFree(g);
    try testing.expect(g != 0);
    try testing.expectEqual(@as(f64, 1), gridRows(g));
    try testing.expectEqual(@as(f64, 2049), gridCols(g));

    const bin = gridArgMaxInRow(g, 0);
    const hz = bin * gridYStep(g);
    try testing.expectApproxEqAbs(@as(f64, 1000), hz, gridYStep(g) * 1.5);

    // NEGATIVE SIBLING: a bin far from the tone is essentially empty, so the
    // peak means something rather than everything being large
    const far = gridAt(g, 0, @intFromFloat(bin + 200));
    try testing.expect(far < gridMax(g) * 0.01);
}

test "the amplitude is recovered exactly -- on a bin, and low off one" {
    // SCALLOPING, and it is not a defect. 1000 Hz at 48 kHz with a 4096-point
    // window lands on bin 85.33, BETWEEN two bins, so neither holds all of the
    // tone and the tallest reads about 93% of the true amplitude. This test
    // asserts both halves of that: on a bin centre the amplitude comes back
    // essentially exact, and off one it is measurably (and predictably) low.
    //
    // The first version of this test asserted 0.8 for the off-bin case and
    // failed at 0.744 -- the arithmetic predicts 0.7443, so the code was right
    // and the expectation was naive.
    const bin_hz = 48000.0 / 4096.0; // 11.7188 Hz
    const on_bin = bin_hz * 85.0; // 996.09 Hz -- exactly bin 85

    const a = makeTone(on_bin, 0.5, 0.8, 48000);
    defer _ = snd.free(a);
    const ga = spectrum(a, 0, 0, 4096);
    defer _ = gridFree(ga);
    try testing.expectApproxEqAbs(@as(f64, 0.8), gridMax(ga), 0.01);

    const b = makeTone(1000, 0.5, 0.8, 48000); // bin 85.33
    defer _ = snd.free(b);
    const gb = spectrum(b, 0, 0, 4096);
    defer _ = gridFree(gb);
    try testing.expect(gridMax(gb) < gridMax(ga)); // off-bin always reads lower
    try testing.expectApproxEqAbs(@as(f64, 0.744), gridMax(gb), 0.01);
}

test "dominantFrequency names the pitch" {
    const id = makeTone(440, 0.3, 0.5, 48000);
    defer _ = snd.free(id);
    const hz = dominantFrequency(id, 0, 8192);
    try testing.expectApproxEqAbs(@as(f64, 440), hz, 8);
}

test "the spectrogram is the same whether one thread computes it or four" {
    // Multicore has to be provably invisible: same numbers, sooner.
    const id = makeTone(700, 1.0, 0.6, 48000);
    defer _ = snd.free(id);
    const a = spectrogram(id, 0, 1024, 256, 1);
    defer _ = gridFree(a);
    const b = spectrogram(id, 0, 1024, 256, 4);
    defer _ = gridFree(b);
    try testing.expect(a != 0 and b != 0);
    try testing.expectEqual(gridRows(a), gridRows(b));
    try testing.expectEqual(gridCols(a), gridCols(b));

    const rows: usize = @intFromFloat(gridRows(a));
    const cols: usize = @intFromFloat(gridCols(a));
    var worst: f64 = 0;
    for (0..rows) |r| {
        for (0..cols) |c| worst = @max(worst, @abs(gridAt(a, r, c) - gridAt(b, r, c)));
    }
    try testing.expectEqual(@as(f64, 0), worst); // EXACTLY, not approximately
}

test "the spectrogram knows what its axes mean" {
    const id = makeTone(300, 0.5, 0.5, 48000);
    defer _ = snd.free(id);
    const g = spectrogram(id, 0, 1024, 512, 2);
    defer _ = gridFree(g);
    try testing.expectApproxEqAbs(512.0 / 48000.0, gridXStep(g), 1e-9); // seconds per row
    try testing.expectApproxEqAbs(48000.0 / 1024.0, gridYStep(g), 1e-9); // hertz per column
    // and every row agrees about the pitch, because the tone never changes
    const rows: usize = @intFromFloat(gridRows(g));
    for (2..rows - 2) |r| {
        const hz = gridArgMaxInRow(g, r) * gridYStep(g);
        try testing.expectApproxEqAbs(@as(f64, 300), hz, 60);
    }
}

test "onsets find four clicks, and the tempo follows from them" {
    const rate: u32 = 48000;
    const n: usize = rate * 2;
    const id = snd.newSilent(n, 1, rate);
    defer _ = snd.free(id);
    // a click every 0.5 s -> 120 BPM, with a short decay so each is an EVENT
    var k: usize = 0;
    while (k < 4) : (k += 1) {
        const at = k * rate / 2;
        for (0..2000) |i| {
            const env = 1.0 - @as(f64, @floatFromInt(i)) / 2000.0;
            const t = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(rate));
            _ = snd.setSample(id, at + i, 0, 0.9 * env * @sin(2.0 * std.math.pi * 1200.0 * t));
        }
    }
    const o = onsets(id, 0, 1024, 256, 0.5);
    defer _ = gridFree(o);
    const found: usize = @intFromFloat(@max(0, gridCols(o)));
    try testing.expect(found >= 3 and found <= 6); // 4 clicks, allow the edges

    const bpm = tempo(id, 0);
    try testing.expectApproxEqAbs(@as(f64, 120), bpm, 12);
}

test "a steady tone has NO onsets -- the false positive that reported 1125 BPM" {
    // The onset detector originally compared flux against a moving average of
    // itself and nothing else. On a steady tone the flux is numerical noise,
    // and noise still has peaks above its own mean, so a 440 Hz sine came back
    // as 1125 BPM. Caught by the Ring guard; locked down here.
    const id = makeTone(440, 2.0, 0.5, 48000);
    defer _ = snd.free(id);
    const o = onsets(id, 0, 2048, 512, 0.35);
    defer _ = gridFree(o);
    const n: usize = @intFromFloat(@max(0, gridCols(o)));
    try testing.expect(n <= 1); // the very first window may register; nothing after
    try testing.expectEqual(@as(f64, -1), tempo(id, 0));
}

test "loudness follows the standard: +6 LU when the amplitude doubles" {
    const quiet = makeTone(1000, 1.0, 0.1, 48000);
    defer _ = snd.free(quiet);
    const loud = makeTone(1000, 1.0, 0.2, 48000);
    defer _ = snd.free(loud);
    const lq = loudness(quiet);
    const ll = loudness(loud);
    try testing.expect(lq > -1000 and ll > -1000);
    // doubling amplitude is +6.02 dB, and LUFS is a dB scale
    try testing.expectApproxEqAbs(@as(f64, 6.02), ll - lq, 0.1);

    // AND THE ABSOLUTE VALUE, predicted from an INDEPENDENT measurement of
    // the same truth (the perf plane's law 5) rather than from a constant
    // copied out of a previous run.
    //
    // The first attempt asserted LUFS = -0.691 + 10log10(A^2/2), on the
    // assumption that K-weighting is flat at 1 kHz. It is not: the standard's
    // shelf is already climbing there, worth about +0.7 dB, and the test
    // failed by exactly that. So rather than hard-code 0.7, run a 1 kHz sine
    // through the very same two biquads, measure the power gain, and predict
    // the answer from it. If the filters ever change, this moves with them.
    const n = 48000;
    const probe = alloc.alloc(f64, n) catch unreachable;
    defer alloc.free(probe);
    for (0..n) |i| {
        const t = @as(f64, @floatFromInt(i)) / 48000.0;
        probe[i] = 0.1 * @sin(2.0 * std.math.pi * 1000.0 * t);
    }
    biquadInPlace(probe, PRE_B, PRE_A);
    biquadInPlace(probe, RLB_B, RLB_A);
    var z: f64 = 0;
    for (probe[4800..]) |v| z += v * v; // skip the filters' start-up
    z /= @floatFromInt(n - 4800);
    const want = -0.691 + 10.0 * std.math.log10(z);
    try testing.expectApproxEqAbs(want, lq, 0.15);

    // and for the record: K-weighting is NOT flat at 1 kHz, which is the
    // whole reason the naive prediction was wrong
    const unweighted = -0.691 + 10.0 * std.math.log10(0.1 * 0.1 / 2.0);
    try testing.expect(@abs(want - unweighted) > 0.3);
}

test "loudness REFUSES a rate its coefficients were not written for" {
    const id = makeTone(1000, 1.0, 0.5, 44100);
    defer _ = snd.free(id);
    countersReset();
    const before = counter(CTR_REFUSALS);
    try testing.expectEqual(@as(f64, -1000), loudness(id));
    try testing.expect(counter(CTR_REFUSALS) > before);
    try testing.expect(lastError().len > 0);
}

test "silence is not a loudness, and says so instead of returning a number" {
    const id = snd.newSilent(48000 * 2, 1, 48000);
    defer _ = snd.free(id);
    try testing.expectEqual(@as(f64, -1000), loudness(id));
}

test "a freed grid is STALE, not readable" {
    const id = makeTone(500, 0.2, 0.5, 48000);
    defer _ = snd.free(id);
    const g = spectrum(id, 0, 0, 1024);
    try testing.expect(g != 0);
    try testing.expectEqual(OK, gridFree(g));
    try testing.expectEqual(STALE, gridFree(g));
    try testing.expectEqual(@as(f64, -1), gridRows(g));
    try testing.expectEqual(@as(f64, 0), gridAt(g, 0, 0));
}
