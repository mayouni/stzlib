//! soundinstr.zig -- MU1 of SOFTANZA_MUSIC_PLAN.md: the instruments, as arithmetic.
//!
//! ── WHY A SEPARATE SEAM FILE ────────────────────────────────────────────────
//!
//! Like sounddsp.zig this imports `std` and NOTHING ELSE: no allocator, no handle
//! table, no device. Every render writes into a slice the caller owns. That is
//! what lets the native DLL and the browser's wasm compile the SAME instruments
//! -- one author of what an oud sounds like, never two that happen to agree
//! (SS5's lesson, paid for once and not again).
//!
//! ── FIVE ENGINES, AND WHY THESE FIVE ────────────────────────────────────────
//!
//!   PLUCK     Karplus-Strong with an ALLPASS fractional delay. MU0 measured the
//!             integer-period line at up to 8 cents off at A4; the allpass carries
//!             the fraction the integer line could not.
//!   BOW       a string waveguide excited by stick-slip friction (the imzad).
//!   WIND      ONE bore, FOUR mouths: single reed (mezwed), double reed (zokra),
//!             lip (kakaki), air jet (flute, sarewa). Niger corrected the plan's
//!             shape before this was written: four excitations, not four engines.
//!   FM        two operators; bells, keys, brass, bars.
//!   MEMBRANE  a modal circular membrane struck at centre or rim, with an optional
//!             snare buzz (bendir) and a pitch that may move while it sounds
//!             (kalangu -- Gap 1 applied to a drum).
//!
//! The waveguides follow Perry Cook's STK models (Clarinet, Saxofony, Brass,
//! Flute, Bowed) -- published, studied for thirty years, and the right thing to
//! borrow rather than reinvent.
//!
//! ── THE INSTRUMENTS TUNE THEMSELVES, BY LISTENING ──────────────────────────
//!
//! A waveguide's pitch is NOT its delay length: the loop filter, the reed's
//! nonlinearity and the interpolation each add their own delay, and STK's fudge
//! constants ("- 3.0", "- 2.0") are the record of a thirty-year argument with
//! that fact. So every pitched waveguide here does what a musician does: it plays
//! a probe note, MEASURES the pitch it actually made, and corrects. Offline, it
//! costs two short extra renders and removes the argument. The raw error and the
//! correction applied are both reported, so a guard can say how far off the
//! model was before it listened to itself.

const std = @import("std");

const PI: f64 = std.math.pi;

// ── engines, mouths, pitch classes ──────────────────────────────────────────

pub const ENGINE_PLUCK: u32 = 0;
pub const ENGINE_BOW: u32 = 1;
pub const ENGINE_WIND: u32 = 2;
pub const ENGINE_FM: u32 = 3;
pub const ENGINE_MEMBRANE: u32 = 4;

pub const MOUTH_SINGLE_REED: u32 = 0;
pub const MOUTH_DOUBLE_REED: u32 = 1;
pub const MOUTH_LIP: u32 = 2;
pub const MOUTH_JET: u32 = 3;

pub const PITCH_HARMONIC: u32 = 0; // held to 2 cents: the plan's bar
pub const PITCH_INHARMONIC: u32 = 1; // a pitch the ear infers from modes or a bar
pub const PITCH_NONE: u32 = 2; // hats, snares, frame-drum buzz

pub const Spec = struct {
    name: []const u8,
    /// The name this instrument ships under if the author's ear says the real
    /// name is a lie -- MU1's kill criterion, written into the table so the
    /// fallback is decided BEFORE anyone listens, not negotiated after.
    honest: []const u8,
    engine: u32,
    pitch: u32 = PITCH_HARMONIC,
    tail: f64 = 0.25, // seconds rendered after the hold
    lo: f64 = 40,
    hi: f64 = 2000,
    // pluck
    decay: f64 = 0.996, // loss per pass round the loop
    bright: f64 = 1.0, // 1 = a white-noise pluck; lower = finger or plectrum
    hammer: bool = false,
    body: f64 = 0, // a body or gourd resonance in Hz; 0 = none
    // wind and bow
    mouth: u32 = 0,
    noise: f64 = 0.2,
    vibrato: f64 = 0.0,
    pair_cents: f64 = 0, // a second, detuned voice: the mezwed's twin chanters
    // fm
    ratio: f64 = 1,
    index: f64 = 1,
    index_decay: f64 = 0,
    amp_decay: f64 = 0,
    attack: f64 = 0.002,
    sustained: bool = false,
    tine: f64 = 0,
    // membrane
    kind: u32 = 0, // 0 hand drum, 1 frame drum with snares, 2 drum kit
    tau: f64 = 0.3,
};

/// THE TWENTY, in the plan's order. The first twelve are the plan's general
/// set; then the four Tunisian; then the four Nigerien, each chosen to prove an
/// excitation rather than lengthen the list.
pub const SPECS = [_]Spec{
    .{ .name = "piano", .honest = "hammeredstring", .engine = ENGINE_PLUCK, .hammer = true, .decay = 0.998, .bright = 0.55, .tail = 0.4, .lo = 55, .hi = 2000 },
    .{ .name = "guitar", .honest = "pluckedstring", .engine = ENGINE_PLUCK, .decay = 0.996, .bright = 0.8, .body = 110, .lo = 80, .hi = 1200 },
    .{ .name = "harp", .honest = "ringingstring", .engine = ENGINE_PLUCK, .decay = 0.999, .bright = 0.6, .tail = 0.8, .lo = 55, .hi = 2000 },
    .{ .name = "bell", .honest = "fmbell", .engine = ENGINE_FM, .pitch = PITCH_INHARMONIC, .ratio = 1.4, .index = 6, .index_decay = 1.5, .amp_decay = 0.9, .tail = 2.5, .lo = 100, .hi = 2000 },
    .{ .name = "epiano", .honest = "fmkeys", .engine = ENGINE_FM, .ratio = 1.0, .index = 1.8, .index_decay = 5, .amp_decay = 1.2, .tine = 0.12, .tail = 0.6, .lo = 40, .hi = 2000 },
    .{ .name = "brass", .honest = "fmbrass", .engine = ENGINE_FM, .ratio = 1.0, .index = 3.5, .attack = 0.06, .sustained = true, .tail = 0.2, .lo = 60, .hi = 1000 },
    .{ .name = "flute", .honest = "jetpipe", .engine = ENGINE_WIND, .mouth = MOUTH_JET, .noise = 0.15, .vibrato = 0.05, .tail = 0.15, .lo = 250, .hi = 2000 },
    .{ .name = "oud", .honest = "darkpluck", .engine = ENGINE_PLUCK, .decay = 0.994, .bright = 0.45, .body = 150, .lo = 70, .hi = 700 },
    .{ .name = "koto", .honest = "brightpluck", .engine = ENGINE_PLUCK, .decay = 0.997, .bright = 0.95, .lo = 100, .hi = 1200 },
    .{ .name = "kora", .honest = "gourdpluck", .engine = ENGINE_PLUCK, .decay = 0.998, .bright = 0.7, .body = 200, .tail = 0.6, .lo = 80, .hi = 1000 },
    .{ .name = "metallophone", .honest = "fmbar", .engine = ENGINE_FM, .pitch = PITCH_INHARMONIC, .ratio = 2.76, .index = 1.2, .index_decay = 3, .amp_decay = 1.1, .tail = 1.5, .lo = 150, .hi = 1500 },
    .{ .name = "drumkit", .honest = "synthkit", .engine = ENGINE_MEMBRANE, .pitch = PITCH_NONE, .kind = 2, .tail = 0, .lo = 40, .hi = 400 },
    .{ .name = "mezwed", .honest = "twinreedpipe", .engine = ENGINE_WIND, .mouth = MOUTH_SINGLE_REED, .noise = 0.08, .vibrato = 0, .pair_cents = 12, .tail = 0.15, .lo = 200, .hi = 900 },
    .{ .name = "zokra", .honest = "shawm", .engine = ENGINE_WIND, .mouth = MOUTH_DOUBLE_REED, .noise = 0.1, .vibrato = 0, .tail = 0.15, .lo = 200, .hi = 1200 },
    .{ .name = "darbouka", .honest = "gobletdrum", .engine = ENGINE_MEMBRANE, .pitch = PITCH_INHARMONIC, .kind = 0, .tau = 0.3, .tail = 0, .lo = 80, .hi = 400 },
    .{ .name = "bendir", .honest = "snaredframe", .engine = ENGINE_MEMBRANE, .pitch = PITCH_NONE, .kind = 1, .tau = 0.45, .tail = 0, .lo = 50, .hi = 250 },
    .{ .name = "kakaki", .honest = "liptrumpet", .engine = ENGINE_WIND, .mouth = MOUTH_LIP, .noise = 0, .tail = 0.15, .lo = 60, .hi = 400 },
    .{ .name = "sarewa", .honest = "breathyflute", .engine = ENGINE_WIND, .mouth = MOUTH_JET, .noise = 0.35, .vibrato = 0.02, .tail = 0.15, .lo = 250, .hi = 1500 },
    .{ .name = "imzad", .honest = "bowedstring", .engine = ENGINE_BOW, .vibrato = 0.004, .tail = 0.25, .lo = 150, .hi = 1000 },
    .{ .name = "kalangu", .honest = "talkingdrum", .engine = ENGINE_MEMBRANE, .pitch = PITCH_INHARMONIC, .kind = 0, .tau = 0.5, .tail = 0, .lo = 70, .hi = 400 },
};

pub fn count() u32 {
    return SPECS.len;
}

/// Case-insensitive lookup; -1 when there is no such instrument.
pub fn indexOf(name: []const u8) i32 {
    for (SPECS, 0..) |s, i| {
        if (std.ascii.eqlIgnoreCase(s.name, name)) return @intCast(i);
    }
    return -1;
}

// ── refusal reasons, readable after a render returns 0 ─────────────────────

pub const R_OK: u32 = 0;
pub const R_UNKNOWN: u32 = 1;
pub const R_RANGE: u32 = 2;
pub const R_GLIDE: u32 = 3;
pub const R_ARGS: u32 = 4;
pub const R_VARIANT: u32 = 5;
pub const R_BUFFER: u32 = 6;
pub const R_SILENT: u32 = 7;

pub var last_reason: u32 = R_OK;
/// How far the UNTUNED model was from the pitch asked for, in cents.
pub var last_raw_cents: f64 = 0;
/// The correction the self-tuning applied, in cents. 0 for engines tuned by
/// construction (FM, membrane), which never needed to listen to themselves.
pub var last_tuning_cents: f64 = 0;

pub fn reasonText(r: u32) []const u8 {
    return switch (r) {
        R_UNKNOWN => "no instrument with that index",
        R_RANGE => "that pitch is outside this instrument's range",
        R_GLIDE => "this instrument cannot glide: a pluck and an FM voice hold one pitch",
        R_ARGS => "hold must be 0..60 s and velocity 0..1",
        R_VARIANT => "that stroke is not one this instrument has",
        R_BUFFER => "the buffer is smaller than the note",
        R_SILENT => "the model did not sound -- a waveguide that fails to oscillate is refused, not returned as silence",
        else => "",
    };
}

// ── sizes ───────────────────────────────────────────────────────────────────

pub fn noteFrames(inst: u32, rate: u32, hold: f64) usize {
    if (inst >= SPECS.len or !(hold > 0)) return 0;
    return @intFromFloat((hold + SPECS[inst].tail) * @as(f64, @floatFromInt(rate)));
}

/// The scratch a self-tuning render needs for its probe notes: 1.2 s, because
/// an instrument that WANDERS -- vibrato, or a breathy jet whose pitch moves
/// +-8 cents about its centre for the whole note -- has its centre in no short
/// span. 0.6 s was the first cut; the sarewa could not be centred in it.
pub fn scratchFrames(rate: u32) usize {
    return @intFromFloat(1.2 * @as(f64, @floatFromInt(rate)));
}

/// Does this instrument's pitch move on purpose? Then it is measured as an
/// average of many readings, never as one.
pub fn wanders(s: Spec) bool {
    return s.vibrato > 0.001 or s.noise >= 0.3;
}

pub const READ_FROM_S: f64 = 0.25;
pub const READ_COUNT: usize = 16;
pub const READ_STEP: usize = 2400; // 50 ms at 48 kHz: sixteen span 0.25 .. 1.0 s

// ── the finer pitch instrument ──────────────────────────────────────────────
//
// MU0 owed this. An integer-lag autocorrelation at 218 frames is 7.9 cents wide,
// so it could not see the error it sat beside. This is McLeod's NORMALISED
// square difference (robust to a decaying note, which a plain autocorrelation is
// not), searched only between 0.8 and 1.25 of the expected period -- so an octave
// error is impossible by construction -- and the peak is refined by a parabola
// through its neighbours, which resolves a fraction of a sample.
//
// A peak landing ON the window's edge means the true period is outside it, and
// that is reported as a failed measurement (0) rather than as the edge value.
//
// AND THE OCTAVE, which the first cut claimed was "impossible by construction"
// and was not. A 440 Hz sine asked about near 220 Hz repeats perfectly every
// 220 Hz period -- two of its own -- so the search found a flawless peak and
// reported 220. A negative test caught it. It mattered beyond the tool: a
// self-tuning instrument that jumped an octave UP would have measured itself as
// correct and reported success. So the peak is checked at half and a third of its
// lag; if the signal repeats there as well, the true period is shorter and the
// measurement is refused.

pub const MEASURE_WINDOW: usize = 4096;
const MAX_LAGS: usize = 4096;

pub fn measureHz(x: []const f32, rate: u32, from: usize, hz_guess: f64) f64 {
    if (!(hz_guess > 0)) return 0;
    const ratef: f64 = @floatFromInt(rate);
    const period = ratef / hz_guess;
    const lo: usize = @intFromFloat(@floor(period * 0.8));
    const hi: usize = @intFromFloat(@ceil(period * 1.25));
    if (lo < 2 or hi - lo + 1 > MAX_LAGS) return 0;
    if (from + MEASURE_WINDOW + hi + 2 > x.len) return 0;
    var nsdf: [MAX_LAGS]f64 = undefined;
    var l: usize = lo;
    while (l <= hi) : (l += 1) {
        var acf: f64 = 0;
        var m: f64 = 0;
        var i: usize = from;
        while (i < from + MEASURE_WINDOW) : (i += 1) {
            const a: f64 = x[i];
            const b: f64 = x[i + l];
            acf += a * b;
            m += a * a + b * b;
        }
        nsdf[l - lo] = if (m > 0) 2.0 * acf / m else 0;
    }
    var best: usize = 0;
    var k: usize = 1;
    while (k <= hi - lo) : (k += 1) {
        if (nsdf[k] > nsdf[best]) best = k;
    }
    if (best == 0 or best == hi - lo) return 0; // on the edge: not a measurement
    if (nsdf[best] < 0.3) return 0; // no periodicity worth the name
    const lag = lo + best;
    for ([_]usize{ 2, 3 }) |div| {
        const sub = lag / div;
        if (sub < 2) continue;
        var acf: f64 = 0;
        var m: f64 = 0;
        var i: usize = from;
        while (i < from + MEASURE_WINDOW) : (i += 1) {
            const xa: f64 = x[i];
            const xb: f64 = x[i + sub];
            acf += xa * xb;
            m += xa * xa + xb * xb;
        }
        const ns = if (m > 0) 2.0 * acf / m else 0;
        if (ns > 0.9 * nsdf[best]) return 0; // it repeats sooner: not this pitch
    }
    const a = nsdf[best - 1];
    const b = nsdf[best];
    const c = nsdf[best + 1];
    const den = a - 2.0 * b + c;
    const delta = if (den != 0) 0.5 * (a - c) / den else 0;
    return ratef / (@as(f64, @floatFromInt(lo + best)) + delta);
}

/// The FIRST reading, before anything is known: lags from half to twice the
/// expected period, and McLeod's rule -- the first peak within 0.9 of the
/// highest, not the highest -- which is what keeps a wide search off the octave
/// below. Needed because a raw waveguide can start further off than the narrow
/// search's +-25%: the untuned kakaki sounds at 0.79x its target at 72 Hz and
/// 1.14x at 320, so the narrow search found nothing at the bottom of its range.
pub fn measureHzWide(x: []const f32, rate: u32, from: usize, hz_guess: f64) f64 {
    if (!(hz_guess > 0)) return 0;
    const ratef: f64 = @floatFromInt(rate);
    const period = ratef / hz_guess;
    const lo: usize = @intFromFloat(@floor(period * 0.5));
    const hi: usize = @intFromFloat(@ceil(period * 2.0));
    if (lo < 2 or hi - lo + 1 > MAX_LAGS) return 0;
    if (from + MEASURE_WINDOW + hi + 2 > x.len) return 0;
    var nsdf: [MAX_LAGS]f64 = undefined;
    var l: usize = lo;
    while (l <= hi) : (l += 1) {
        var acf: f64 = 0;
        var m: f64 = 0;
        var i: usize = from;
        while (i < from + MEASURE_WINDOW) : (i += 1) {
            const a: f64 = x[i];
            const b: f64 = x[i + l];
            acf += a * b;
            m += a * a + b * b;
        }
        nsdf[l - lo] = if (m > 0) 2.0 * acf / m else 0;
    }
    const n = hi - lo + 1;
    var top: f64 = 0;
    for (nsdf[0..n]) |v| top = @max(top, v);
    if (top < 0.3) return 0;
    var k: usize = 1;
    while (k + 1 < n) : (k += 1) {
        if (nsdf[k] >= nsdf[k - 1] and nsdf[k] >= nsdf[k + 1] and nsdf[k] >= 0.9 * top) break;
    }
    if (k + 1 >= n) return 0;
    const a = nsdf[k - 1];
    const b = nsdf[k];
    const c = nsdf[k + 1];
    const den = a - 2.0 * b + c;
    const delta = if (den != 0) 0.5 * (a - c) / den else 0;
    return ratef / (@as(f64, @floatFromInt(lo + k)) + delta);
}

/// The tuner's reading: wide on the first pass, narrow and octave-guarded after;
/// and for a note with vibrato, the AVERAGE of eight readings across a cycle,
/// because a pitch that moves on purpose has its centre in no single window.
pub fn readPitch(x: []const f32, rate: u32, from: usize, hz: f64, averaged: bool, wide: bool) f64 {
    if (!averaged) return if (wide) measureHzWide(x, rate, from, hz) else measureHz(x, rate, from, hz);
    var acc: f64 = 0;
    var got: f64 = 0;
    for (0..READ_COUNT) |k| {
        const at = from + k * READ_STEP;
        const v = if (wide) measureHzWide(x, rate, at, hz) else measureHz(x, rate, at, hz);
        if (v > 0) {
            acc += std.math.log2(v / hz);
            got += 1;
        }
    }
    if (got < READ_COUNT * 3 / 4) return 0; // mostly unreadable: not a measurement
    return hz * std.math.pow(f64, 2.0, acc / got);
}

// ── the spectral instrument, for sounds that are not harmonic ──────────────
//
// A period estimator is the WRONG instrument for a drum. A membrane's modes are
// at Bessel-zero ratios -- 1, 1.594, 2.136 -- not at multiples, and inharmonic
// partials pull a period estimate off the fundamental: the kalangu read 18.7
// cents sharp by it while its fundamental mode was exact by construction. This
// evaluates the spectrum directly, at a fine grid of frequencies within +-span of
// the guess, under a Hann window, and refines the peak with a parabola through
// the LOG magnitudes (the right shape for a Hann main lobe). It answers "where is
// the mode", which is a question about the arithmetic; what the ear calls the
// drum's pitch is a separate question, and it is the listener's.

pub fn peakHz(x: []const f32, rate: u32, from: usize, window: usize, hz_guess: f64, span: f64) f64 {
    if (!(hz_guess > 0) or window < 256 or from + window > x.len) return 0;
    const ratef: f64 = @floatFromInt(rate);
    const steps: usize = 240;
    var mag: [241]f64 = undefined;
    var k: usize = 0;
    while (k <= steps) : (k += 1) {
        const f = hz_guess * (1.0 - span + 2.0 * span * @as(f64, @floatFromInt(k)) / @as(f64, @floatFromInt(steps)));
        const w = 2.0 * PI * f / ratef;
        var re: f64 = 0;
        var im: f64 = 0;
        var cr: f64 = 1;
        var ci: f64 = 0;
        const rr = @cos(w);
        const ri = -@sin(w);
        var i: usize = 0;
        while (i < window) : (i += 1) {
            const hann = 0.5 - 0.5 * @cos(2.0 * PI * @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(window - 1)));
            const v: f64 = hann * @as(f64, x[from + i]);
            re += v * cr;
            im += v * ci;
            const nr = cr * rr - ci * ri;
            ci = cr * ri + ci * rr;
            cr = nr;
        }
        mag[k] = @log(@sqrt(re * re + im * im) + 1e-30);
    }
    var best: usize = 0;
    k = 1;
    while (k <= steps) : (k += 1) {
        if (mag[k] > mag[best]) best = k;
    }
    if (best == 0 or best == steps) return 0; // the peak is outside the span
    const a = mag[best - 1];
    const b = mag[best];
    const c = mag[best + 1];
    const den = a - 2.0 * b + c;
    const delta = if (den != 0) 0.5 * (a - c) / den else 0;
    const kk = @as(f64, @floatFromInt(best)) + delta;
    return hz_guess * (1.0 - span + 2.0 * span * kk / @as(f64, @floatFromInt(steps)));
}

// ── shared parts ────────────────────────────────────────────────────────────

const Lcg = struct {
    s: u32 = 0x2545F491,
    fn next(self: *Lcg) f32 {
        self.s = self.s *% 1664525 +% 1013904223;
        return (@as(f32, @floatFromInt(self.s >> 8)) / 8388608.0) - 1.0;
    }
};

const MAXD: usize = 4096; // a power of two: the wrap is a mask

/// A delay line with a fractional, linearly interpolated read. `tick` writes
/// the input and returns the sample `d` samples behind it; `last` is the
/// previous return value -- STK's DelayL, which the models below are written
/// against.
const Delay = struct {
    buf: [MAXD]f32 = @splat(0),
    w: usize = 0,
    last: f32 = 0,
    fn tick(self: *Delay, in: f64, d: f64) f32 {
        self.buf[self.w] = @floatCast(in);
        const dd = @max(1.0, @min(d, @as(f64, @floatFromInt(MAXD - 2))));
        const di: usize = @intFromFloat(@floor(dd));
        const fr: f32 = @floatCast(dd - @floor(dd));
        const a = self.buf[(self.w + MAXD - di) & (MAXD - 1)];
        const b = self.buf[(self.w + MAXD - di - 1) & (MAXD - 1)];
        const o = a + (b - a) * fr;
        self.w = (self.w + 1) & (MAXD - 1);
        self.last = o;
        return o;
    }
};

/// A glide in LOG frequency, so equal times cover equal musical intervals.
fn hzAt(hz0: f64, hz1: f64, t: f64, hold: f64) f64 {
    if (hz1 == hz0 or !(hold > 0)) return hz0;
    const u = @min(1.0, @max(0.0, t / hold));
    return hz0 * @exp(u * @log(hz1 / hz0));
}

/// A two-pole body or gourd resonance, mixed back into the signal.
fn bodyResonance(out: []f32, fhz: f64, rate: u32, mix: f64) void {
    const w = 2.0 * PI * fhz / @as(f64, @floatFromInt(rate));
    const r = 0.985;
    const a1 = -2.0 * r * @cos(w);
    const a2 = r * r;
    const b0 = (1.0 - r * r) * 0.5;
    var y1: f64 = 0;
    var y2: f64 = 0;
    for (out) |*o| {
        const x: f64 = o.*;
        const y = b0 * x - a1 * y1 - a2 * y2;
        y2 = y1;
        y1 = y;
        o.* = @floatCast(x + mix * y);
    }
}

// ── PLUCK: Karplus-Strong with an allpass fractional delay ──────────────────
//
// The loop is N whole samples, plus half a sample for the two-point average
// (MU0's finding), plus d for a first-order allpass, chosen so N + 0.5 + d is
// the period exactly with d in [0.5, 1.5) -- the allpass's best-behaved range.

fn rawPluck(s: Spec, hz: f64, hold_f: usize, vel: f64, rate: u32, out: []f32) bool {
    const ratef: f64 = @floatFromInt(rate);
    const P = ratef / hz;
    const nf = @floor(P - 1.0);
    if (nf < 2 or nf >= @as(f64, @floatFromInt(MAXD))) return false;
    const N: usize = @intFromFloat(nf);
    const d = P - 0.5 - nf;
    const C: f64 = (1.0 - d) / (1.0 + d);

    var line: [MAXD]f32 = undefined;
    var rng = Lcg{};
    var lp: f32 = 0;
    const br: f32 = @floatCast(std.math.clamp(s.bright * (0.6 + 0.4 * vel), 0.05, 1.0));
    var i: usize = 0;
    while (i < N) : (i += 1) {
        var x = rng.next();
        if (s.hammer) {
            // a felt hammer: a smooth bump struck at a seventh of the string
            const pos = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(N));
            const w = 0.12;
            const cpos = 1.0 / 7.0;
            var bump: f64 = 0;
            if (@abs(pos - cpos) < w) bump = 0.5 * (1.0 + @cos(PI * (pos - cpos) / w));
            x = @floatCast(bump * 1.6 + 0.15 * @as(f64, x));
        }
        lp += br * (x - lp);
        line[i] = lp;
    }
    // remove the excitation's mean, or the string rings about an offset
    var mean: f32 = 0;
    i = 0;
    while (i < N) : (i += 1) mean += line[i];
    mean /= @floatFromInt(N);
    i = 0;
    while (i < N) : (i += 1) line[i] -= mean;

    var p: usize = 0;
    var prev: f32 = 0;
    var apx: f64 = 0;
    var apy: f64 = 0;
    const dh: f32 = @floatCast(s.decay);
    for (out, 0..) |*o, f| {
        const cur = line[p];
        const avg = 0.5 * (cur + prev);
        prev = cur;
        // after the hold the string is DAMPED -- a finger or palm on it --
        // rather than cut, which would be a click
        const dmp: f32 = if (f < hold_f) dh else 0.93;
        const x: f64 = dmp * avg;
        const y = C * x + apx - C * apy;
        apx = x;
        apy = y;
        line[p] = @floatCast(y);
        p += 1;
        if (p == N) p = 0;
        o.* = cur;
    }
    if (s.body > 0) bodyResonance(out, s.body, rate, 0.6);
    return true;
}

// ── BOW: STK's Bowed, a string excited by stick-slip friction ───────────────

/// STK's default bow pressure (slope 3) plays an OCTAVE UP from about 600 Hz:
/// measured 1205 Hz asked 600, 1611 asked 800 -- the string breaking to its
/// second harmonic, which is real bowed-string physics and which the octave
/// guard caught and refused. Scanned slope {1,2,3,4} x bow position
/// {0.06,0.127,0.2} x {400,600,800} Hz: slope 2 (bow pressure 0.75 in STK's
/// terms) holds the fundamental at all three with STK's own bow position.
const BOW_SLOPE: f64 = 2.0;

fn bowTable(v: f64) f64 {
    const s = (v + 0.001) * BOW_SLOPE;
    const o = 1.0 / std.math.pow(f64, @abs(s) + 0.75, 4.0);
    return std.math.clamp(o, 0.01, 0.98);
}

fn rawBow(s: Spec, hz0: f64, hz1: f64, hold: f64, vel: f64, rate: u32, out: []f32) bool {
    const ratef: f64 = @floatFromInt(rate);
    const hold_f: usize = @intFromFloat(hold * ratef);
    var neck = Delay{};
    var bridge = Delay{};
    const beta = 0.127236;
    const sp = 0.75 - 0.2 * 22050.0 / ratef;
    var sfy: f64 = 0;
    const maxv = 0.03 + 0.2 * vel;
    const atk = vel * 0.001;
    const rel = 1.0 / (0.01 * ratef);
    var env: f64 = 0;
    for (out, 0..) |*o, f| {
        const t = @as(f64, @floatFromInt(f)) / ratef;
        var hz = hzAt(hz0, hz1, t, hold);
        if (s.vibrato > 0) hz *= 1.0 + s.vibrato * @sin(2.0 * PI * 5.5 * t);
        var base = ratef / hz - 4.0;
        if (base < 0.3) base = 0.3;
        if (f < hold_f) env = @min(1.0, env + atk) else env = @max(0.0, env - rel);
        const bowv = maxv * env;
        sfy = 0.95 * (1.0 - sp) * @as(f64, bridge.last) + sp * sfy;
        const br = -sfy;
        const nr: f64 = -@as(f64, neck.last);
        const sv = br + nr;
        const dv = bowv - sv;
        const nv = dv * bowTable(dv);
        _ = neck.tick(br + nv, base * (1.0 - beta));
        _ = bridge.tick(nr + nv, base * beta);
        o.* = bridge.last;
    }
    return true;
}

// ── WIND: one bore, four mouths ─────────────────────────────────────────────

fn reedTable(pd: f64, offset: f64, slope: f64) f64 {
    return std.math.clamp(offset + slope * pd, -1.0, 1.0);
}

fn jetTable(x: f64) f64 {
    return std.math.clamp(x * (x * x - 1.0), -1.0, 1.0);
}

/// A single reed on a cylinder (STK Clarinet): odd harmonics dominate, because a
/// cylinder closed at the reed end supports only odd ones. Adds into `out`.
fn addSingleReed(s: Spec, hz0: f64, hz1: f64, detune: f64, hold: f64, vel: f64, rate: u32, out: []f32) void {
    const ratef: f64 = @floatFromInt(rate);
    const hold_f: usize = @intFromFloat(hold * ratef);
    var dl = Delay{};
    var fx1: f64 = 0;
    var rng = Lcg{ .s = @as(u32, @intFromFloat(@mod(detune * 1000.0, 65536.0))) +% 7 };
    const target = 0.55 + 0.3 * vel;
    const up = vel * 0.005;
    const down = vel * 0.01;
    var env: f64 = 0;
    for (out, 0..) |*o, f| {
        const t = @as(f64, @floatFromInt(f)) / ratef;
        const hz = hzAt(hz0, hz1, t, hold) * detune;
        if (f < hold_f) env = @min(target, env + up) else env = @max(0.0, env - down);
        var breath = env;
        breath += breath * s.noise * @as(f64, rng.next());
        breath += breath * s.vibrato * @sin(2.0 * PI * 5.735 * t);
        const x: f64 = dl.last;
        const filt = 0.5 * x + 0.5 * fx1;
        fx1 = x;
        const pd = -0.95 * filt - breath;
        const d = ratef / hz * 0.5 - 0.5 - 1.0;
        o.* += dl.tick(breath + pd * reedTable(pd, 0.7, -0.3), d);
    }
}

/// A double reed on a cone (STK Saxofony): the cone supports ALL harmonics,
/// which is the audible difference between a zokra and a mezwed.
fn rawDoubleReed(s: Spec, hz0: f64, hz1: f64, hold: f64, vel: f64, rate: u32, out: []f32) void {
    const ratef: f64 = @floatFromInt(rate);
    const hold_f: usize = @intFromFloat(hold * ratef);
    var d0 = Delay{};
    var d1 = Delay{};
    var fx1: f64 = 0;
    var rng = Lcg{};
    const target = 0.55 + 0.3 * vel;
    const up = vel * 0.005;
    const down = vel * 0.01;
    var env: f64 = 0;
    const pos = 0.2;
    for (out, 0..) |*o, f| {
        const t = @as(f64, @floatFromInt(f)) / ratef;
        const hz = hzAt(hz0, hz1, t, hold);
        if (f < hold_f) env = @min(target, env + up) else env = @max(0.0, env - down);
        var breath = env;
        breath += breath * s.noise * @as(f64, rng.next());
        breath += breath * s.vibrato * @sin(2.0 * PI * 5.735 * t);
        const dtot = ratef / hz - 0.5 - 1.0;
        const x: f64 = d0.last;
        const filt = 0.5 * x + 0.5 * fx1;
        fx1 = x;
        const temp = -0.95 * filt;
        const outv = temp - @as(f64, d1.last);
        const pd = breath - outv;
        _ = d1.tick(temp, pos * dtot);
        _ = d0.tick(breath - pd * reedTable(pd, 0.7, 0.3) - temp, (1.0 - pos) * dtot);
        o.* = @floatCast(outv);
    }
}

/// Lips as the reed, after STK's Brass: a resonant lip filter tuned to the note,
/// and a tube two periods long so the lips drive its second mode.
///
/// TWO CHANGES FROM STK, BOTH MEASURED. Written as STK has it, the lip filter
/// passed a steady pressure at ~40x gain: the lips snapped fully open, the loop
/// reached a fixed point, and the model went SILENT after 100 ms -- exact zero,
/// not a decay. Made a band-pass (zeros at DC and Nyquist) it could never START:
/// the area is lip^2, and a square has zero small-signal gain at zero. So the lips
/// now have a REST OPENING they oscillate about -- which is what real lips have --
/// and the band-pass moves them. Rest 0.7, input gain 16: scanned over rest
/// {0.3,0.5,0.7} x gain {2,4,8,16} x {100,200,300} Hz, and the one point where
/// every test pitch sustained.
const LIP_REST: f64 = 0.7;
const LIP_GAIN: f64 = 16.0;

fn rawLip(s: Spec, hz0: f64, hz1: f64, hold: f64, vel: f64, rate: u32, out: []f32, tube_c: f64) void {
    _ = s;
    const ratef: f64 = @floatFromInt(rate);
    const hold_f: usize = @intFromFloat(hold * ratef);
    var dl = Delay{};
    var x1: f64 = 0;
    var x2: f64 = 0;
    var y1: f64 = 0;
    var y2: f64 = 0;
    var dcx: f64 = 0;
    var dcy: f64 = 0;
    const atk = vel * 0.001;
    const rel = 1.0 / (0.01 * ratef);
    var env: f64 = 0;
    const r = 0.997;
    for (out, 0..) |*o, f| {
        const t = @as(f64, @floatFromInt(f)) / ratef;
        const hz = hzAt(hz0, hz1, t, hold);
        if (f < hold_f) env = @min(1.0, env + atk) else env = @max(0.0, env - rel);
        const breath = vel * env;
        const mouth = 0.3 * breath;
        const bore = 0.85 * @as(f64, dl.last);
        // the lip resonance, re-tuned every sample so a glide moves the lips too.
        // THE LIPS STAY AT THE ASKED PITCH; only the TUBE carries the tuner's
        // correction. Tuning both together made the kakaki CRACK -- the tuner
        // converged on its probe and the note then sounded a fourth up (99 Hz
        // asked 72), the lips having chosen another tube mode. The lips choose
        // the mode, so they must not be the thing the tuner moves.
        const w = 2.0 * PI * (hz / tube_c) / ratef;
        const a1 = -2.0 * r * @cos(w);
        const a2 = r * r;
        const xin = LIP_GAIN * (mouth - bore);
        const b0 = 0.5 - 0.5 * a2;
        const lip = b0 * xin - b0 * x2 - a1 * y1 - a2 * y2;
        x2 = x1;
        x1 = xin;
        y2 = y1;
        y1 = lip;
        const opening = LIP_REST + lip;
        var dp = opening * opening;
        if (dp > 1.0) dp = 1.0;
        const o1 = dp * mouth + (1.0 - dp) * bore;
        const dc = o1 - dcx + 0.99 * dcy;
        dcx = o1;
        dcy = dc;
        _ = dl.tick(dc, ratef / hz * 2.0 + 3.0);
        o.* = dl.last;
    }
}

/// An air jet across an edge (STK Flute): no reed at all -- the jet's delay and
/// its cubic deflection are the whole nonlinearity.
fn rawJet(s: Spec, hz0: f64, hz1: f64, hold: f64, vel: f64, rate: u32, out: []f32) void {
    const ratef: f64 = @floatFromInt(rate);
    const hold_f: usize = @intFromFloat(hold * ratef);
    var bore = Delay{};
    var jet = Delay{};
    var rng = Lcg{};
    const p = 0.7 - 0.1 * 22050.0 / ratef;
    var fy: f64 = 0;
    var dcx: f64 = 0;
    var dcy: f64 = 0;
    const maxp = (1.1 + 0.2 * vel) / 0.8;
    const atk = vel * 0.02;
    const rel = 1.0 / (0.01 * ratef);
    var env: f64 = 0;
    for (out, 0..) |*o, f| {
        const t = @as(f64, @floatFromInt(f)) / ratef;
        const hz = hzAt(hz0, hz1, t, hold);
        const feff = hz * 0.66666;
        const w = 2.0 * PI * feff / ratef;
        const pdel = std.math.atan2(p * @sin(w), 1.0 - p * @cos(w)) / w;
        const bd = ratef / feff - pdel - 1.0;
        if (f < hold_f) env = @min(0.8, env + atk) else env = @max(0.0, env - rel);
        var breath = maxp * env;
        breath += breath * (s.noise * @as(f64, rng.next()) + s.vibrato * @sin(2.0 * PI * 5.925 * t));
        fy = (1.0 - p) * @as(f64, bore.last) + p * fy;
        var temp = -fy;
        const dc = temp - dcx + 0.99 * dcy;
        dcx = temp;
        dcy = dc;
        temp = dc;
        var pd = breath - 0.5 * temp;
        pd = jet.tick(pd, bd * 0.32);
        pd = jetTable(pd) + 0.5 * temp;
        o.* = @floatCast(0.3 * @as(f64, bore.tick(pd, bd)));
    }
}

fn rawWind(s: Spec, hz0: f64, hz1: f64, hold: f64, vel: f64, rate: u32, out: []f32, tube_c: f64) void {
    switch (s.mouth) {
        MOUTH_SINGLE_REED => {
            @memset(out, 0);
            addSingleReed(s, hz0, hz1, 1.0, hold, vel, rate, out);
            if (s.pair_cents != 0) {
                addSingleReed(s, hz0, hz1, std.math.pow(f64, 2.0, s.pair_cents / 1200.0), hold, vel, rate, out);
            }
        },
        MOUTH_DOUBLE_REED => rawDoubleReed(s, hz0, hz1, hold, vel, rate, out),
        MOUTH_LIP => rawLip(s, hz0, hz1, hold, vel, rate, out, tube_c),
        else => rawJet(s, hz0, hz1, hold, vel, rate, out),
    }
}

// ── FM: two operators ───────────────────────────────────────────────────────

fn rawFm(s: Spec, hz: f64, hold: f64, rate: u32, out: []f32) void {
    const ratef: f64 = @floatFromInt(rate);
    const hold_f: usize = @intFromFloat(hold * ratef);
    var pc: f64 = 0;
    var pm: f64 = 0;
    var pt: f64 = 0;
    for (out, 0..) |*o, f| {
        const t = @as(f64, @floatFromInt(f)) / ratef;
        var env: f64 = 0;
        if (s.sustained) {
            if (t < s.attack) {
                env = t / s.attack;
            } else if (f < hold_f) {
                env = 1.0;
            } else {
                env = @max(0.0, 1.0 - @as(f64, @floatFromInt(f - hold_f)) / (0.15 * ratef));
            }
        } else {
            env = if (t < s.attack) t / s.attack else @exp(-s.amp_decay * (t - s.attack));
        }
        const idx = if (s.sustained) s.index * env else s.index * @exp(-s.index_decay * t);
        var y = env * @sin(2.0 * PI * pc + idx * @sin(2.0 * PI * pm));
        if (s.tine > 0) {
            const te = @exp(-30.0 * t);
            y += s.tine * te * @sin(2.0 * PI * pc + 0.8 * te * @sin(2.0 * PI * pt));
        }
        pc += hz / ratef;
        pm += hz * s.ratio / ratef;
        pt += hz * 14.0 / ratef;
        pc -= @floor(pc);
        pm -= @floor(pm);
        pt -= @floor(pt);
        o.* = @floatCast(y);
    }
}

// ── MEMBRANE: a circular membrane, struck ───────────────────────────────────
//
// The mode ratios are the zeros of the Bessel functions -- the (m,n) modes of an
// ideal circular membrane, which is why a drum is NOT harmonic. Where it is
// struck decides which modes speak: the centre excites the symmetric modes (dum),
// the rim the ones with nodal diameters (tak), the weaker rim fewer still (ka).

const MODE_R = [8]f64{ 1.0, 1.594, 2.136, 2.296, 2.653, 2.918, 3.156, 3.501 };
const W_DUM = [8]f64{ 1.0, 0.25, 0.1, 0.35, 0.05, 0.1, 0.03, 0.05 };
const W_TAK = [8]f64{ 0.15, 0.7, 0.8, 0.3, 0.7, 0.5, 0.5, 0.4 };
const W_KA = [8]f64{ 0.1, 0.4, 0.5, 0.2, 0.45, 0.35, 0.3, 0.25 };

fn rawMembrane(s: Spec, hz0: f64, hz1: f64, hold: f64, variant: u32, rate: u32, out: []f32) void {
    const ratef: f64 = @floatFromInt(rate);
    if (s.kind == 2) return rawKit(hz0, variant, rate, out);
    const wts = switch (variant) {
        1 => W_TAK,
        2 => W_KA,
        else => W_DUM,
    };
    const tau0 = s.tau * (switch (variant) {
        1 => @as(f64, 0.35),
        2 => @as(f64, 0.25),
        else => @as(f64, 1.0),
    });
    const vamp: f64 = if (variant == 2) 0.6 else 1.0;
    const click: f64 = if (variant == 0) 0.1 else 0.3;
    var amp: [8]f64 = undefined;
    var mult: [8]f64 = undefined;
    var ph: [8]f64 = @splat(0);
    for (0..8) |k| {
        amp[k] = wts[k];
        const tk = tau0 / std.math.pow(f64, MODE_R[k], 0.8);
        mult[k] = @exp(-1.0 / (tk * ratef));
    }
    var rng = Lcg{};
    var n1: f64 = 0;
    // the bendir's snares: noise, gated by how hard the head is moving, through
    // a resonance near 2.5 kHz
    const bw = 2.0 * PI * 2500.0 / ratef;
    const br = 0.95;
    const ba1 = -2.0 * br * @cos(bw);
    const ba2 = br * br;
    var by1: f64 = 0;
    var by2: f64 = 0;
    const env_mult = @exp(-1.0 / (tau0 * ratef));
    var env0: f64 = 1.0;
    for (out, 0..) |*o, f| {
        const t = @as(f64, @floatFromInt(f)) / ratef;
        const f0 = hzAt(hz0, hz1, t, hold);
        var y: f64 = 0;
        for (0..8) |k| {
            y += amp[k] * @sin(2.0 * PI * ph[k]);
            amp[k] *= mult[k];
            ph[k] += f0 * MODE_R[k] / ratef;
            ph[k] -= @floor(ph[k]);
        }
        const nz: f64 = rng.next();
        if (t < 0.004) {
            y += click * (nz - n1) * (1.0 - t / 0.004);
        }
        if (s.kind == 1 and t > 0.003) {
            const bx = nz * env0 * 0.35;
            const by = (1.0 - br) * bx - ba1 * by1 - ba2 * by2;
            by2 = by1;
            by1 = by;
            y += by * 6.0;
        }
        n1 = nz;
        env0 *= env_mult;
        o.* = @floatCast(y * vamp);
    }
}

/// A synthesised kit: kick (a membrane whose pitch drops as it is struck),
/// snare (a rim-struck membrane plus wires), hi-hat (noise, highpassed twice).
fn rawKit(hz: f64, variant: u32, rate: u32, out: []f32) void {
    const ratef: f64 = @floatFromInt(rate);
    var rng = Lcg{};
    var ph0: f64 = 0;
    var ph1: f64 = 0;
    var n1: f64 = 0;
    var h1: f64 = 0;
    var hp1: f64 = 0;
    for (out, 0..) |*o, f| {
        const t = @as(f64, @floatFromInt(f)) / ratef;
        const nz: f64 = rng.next();
        var y: f64 = 0;
        switch (variant) {
            0 => {
                const fk = hz * (1.0 + 1.5 * @exp(-t / 0.03));
                y = @sin(2.0 * PI * ph0) * @exp(-t / 0.25) + 0.2 * @sin(2.0 * PI * ph1) * @exp(-t / 0.12);
                ph0 += fk / ratef;
                ph1 += fk * MODE_R[1] / ratef;
                if (t < 0.003) y += 0.4 * (nz - n1);
            },
            1 => {
                for (0..8) |k| {
                    _ = k;
                }
                y = 0.6 * (@sin(2.0 * PI * ph0) * 0.3 + @sin(2.0 * PI * ph1) * 0.6) * @exp(-t / 0.12);
                ph0 += hz / ratef;
                ph1 += hz * MODE_R[2] / ratef;
                y += 0.8 * (nz - n1) * @exp(-t / 0.15);
            },
            else => {
                const hp = nz - n1;
                const hp2 = hp - hp1;
                hp1 = hp;
                y = hp2 * @exp(-t / 0.05) * 0.5;
            },
        }
        ph0 -= @floor(ph0);
        ph1 -= @floor(ph1);
        n1 = nz;
        h1 = y;
        o.* = @floatCast(y);
    }
}

// ── dispatch, finishing, and the self-tuning render ─────────────────────────

fn raw(s: Spec, hz0: f64, hz1: f64, hold: f64, vel: f64, variant: u32, rate: u32, out: []f32, tube_c: f64) bool {
    const hold_f: usize = @intFromFloat(hold * @as(f64, @floatFromInt(rate)));
    switch (s.engine) {
        ENGINE_PLUCK => return rawPluck(s, hz0, hold_f, vel, rate, out),
        ENGINE_BOW => return rawBow(s, hz0, hz1, hold, vel, rate, out),
        ENGINE_WIND => {
            rawWind(s, hz0, hz1, hold, vel, rate, out, tube_c);
            return true;
        },
        ENGINE_FM => {
            rawFm(s, hz0, hold, rate, out);
            return true;
        },
        else => {
            rawMembrane(s, hz0, hz1, hold, variant, rate, out);
            return true;
        },
    }
}

/// DC out, silence and NaN refused, the last 5 ms faded so the end is not a
/// click, then peak-normalised to 0.7 x velocity. A NOTE is normalised; the mix
/// in which notes meet is a later phase's, and loudness between instruments is
/// not claimed here.
fn finish(out: []f32, vel: f64, rate: u32) bool {
    var x1: f32 = 0;
    var y1: f32 = 0;
    for (out) |*o| {
        const x = o.*;
        const y = x - x1 + 0.999 * y1;
        x1 = x;
        y1 = y;
        o.* = y;
    }
    var peak: f32 = 0;
    for (out) |o| {
        if (!std.math.isFinite(o)) return false;
        peak = @max(peak, @abs(o));
    }
    if (peak < 1e-5) return false;
    const fade = @min(out.len, rate * 5 / 1000);
    var i: usize = 0;
    while (i < fade) : (i += 1) {
        const k = out.len - fade + i;
        out[k] *= @as(f32, @floatFromInt(fade - i)) / @as(f32, @floatFromInt(fade));
    }
    const g: f32 = @floatCast(0.7 * vel / @as(f64, peak));
    for (out) |*o| o.* *= g;
    return true;
}

pub fn renderNote(inst: u32, hz: f64, hz_end: f64, hold: f64, vel: f64, variant: u32, rate: u32, out: []f32, scratch: []f32) usize {
    last_reason = R_OK;
    last_raw_cents = 0;
    last_tuning_cents = 0;
    if (inst >= SPECS.len) {
        last_reason = R_UNKNOWN;
        return 0;
    }
    const s = SPECS[inst];
    if (!(hold > 0 and hold <= 60) or !(vel > 0 and vel <= 1) or rate < 8000) {
        last_reason = R_ARGS;
        return 0;
    }
    const end = if (hz_end > 0) hz_end else hz;
    if (!(hz >= s.lo and hz <= s.hi and end >= s.lo and end <= s.hi)) {
        last_reason = R_RANGE;
        return 0;
    }
    if (end != hz and (s.engine == ENGINE_PLUCK or s.engine == ENGINE_FM)) {
        last_reason = R_GLIDE;
        return 0;
    }
    if ((s.engine == ENGINE_MEMBRANE and variant > 2) or (s.engine != ENGINE_MEMBRANE and variant != 0)) {
        last_reason = R_VARIANT;
        return 0;
    }
    const need = noteFrames(inst, rate, hold);
    if (need == 0 or out.len < need) {
        last_reason = R_BUFFER;
        return 0;
    }

    var c: f64 = 1.0;
    const listens = s.engine == ENGINE_PLUCK or s.engine == ENGINE_BOW or s.engine == ENGINE_WIND;
    if (listens) {
        const pf = scratchFrames(rate);
        if (scratch.len < pf) {
            last_reason = R_BUFFER;
            return 0;
        }
        const probe = scratch[0..pf];
        const from: usize = @intFromFloat(READ_FROM_S * @as(f64, @floatFromInt(rate)));
        // THE PROBE IS PLAYED AS THE NOTE WILL BE -- vibrato and all -- and read
        // as an average across a vibrato cycle. The first cut tuned a
        // vibrato-FREE probe on the theory that the centre is what matters; a
        // jet's pitch rides on its breath, so the flute tuned still and then
        // played 2.9 cents flat with its breath vibrato on. Tune what is played.
        const averaged = wanders(s);
        // ONLY A PROBED CORRECTION IS EVER USED. The first cut applied its last
        // correction without hearing it -- computed, never probed -- and that is
        // the step at which the kakaki cracked. Every pass now probes the value
        // it is judging, and the note is rendered with the best one HEARD.
        //
        // AND IT STEPS BY WHAT IT MEASURED, NOT BY WHAT IT ASSUMED. The first
        // tuner corrected in proportion -- 10% more tube for a note 10% flat --
        // which is true of a string and false of a lip: with the lips held at the
        // asked pitch, stretching the tube moves the note only PART of the way,
        // so each pass under-corrected and the kakaki ran out of passes 8.5 cents
        // off at 320 Hz. From the second pass on, the step is a secant: how far
        // the pitch actually moved per cent of correction, last time.
        var best_c: f64 = 1.0;
        var best_err: f64 = std.math.inf(f64);
        var lc: f64 = 0; // the correction, in cents
        var prev_lc: f64 = 0;
        var prev_err: f64 = 0;
        var have_prev = false;
        var it: usize = 0;
        while (it < 8) : (it += 1) {
            c = std.math.pow(f64, 2.0, lc / 1200.0);
            @memset(probe, 0);
            // held to 1.15 s so every reading lands in the HOLD: sixteen readings
            // from 0.25 s end near 1.09 s, and a 1.0 s probe put its last ones in
            // the release -- a different sound from the note being tuned
            if (!raw(s, hz * c, hz * c, 1.15, vel, 0, rate, probe, c)) break;
            const m = readPitch(probe, rate, from, hz, averaged, it == 0);
            if (m <= 0) break;
            const err = 1200.0 * std.math.log2(m / hz);
            if (it == 0) last_raw_cents = err;
            if (@abs(err) < @abs(best_err)) {
                best_err = err;
                best_c = c;
            }
            if (@abs(err) < 0.05) break;
            var next = lc - err;
            if (have_prev and err != prev_err and lc != prev_lc) {
                const slope = (err - prev_err) / (lc - prev_lc);
                if (slope > 0.05 and slope < 20) next = lc - err / slope;
            }
            next = std.math.clamp(next, lc - 400.0, lc + 400.0);
            prev_lc = lc;
            prev_err = err;
            have_prev = true;
            lc = next;
        }
        c = best_c;
        last_tuning_cents = 1200.0 * std.math.log2(c);
    }

    const o = out[0..need];
    @memset(o, 0);
    if (!raw(s, hz * c, end * c, hold, vel, variant, rate, o, c) or !finish(o, vel, rate)) {
        last_reason = R_SILENT;
        return 0;
    }
    return need;
}

// ── tests ───────────────────────────────────────────────────────────────────

const testing = std.testing;

test "the pitch instrument reads a pure sine to a hundredth of a cent" {
    var buf: [16384]f32 = undefined;
    const hz = 293.6648;
    for (&buf, 0..) |*b, i| b.* = @floatCast(0.5 * @sin(2.0 * PI * hz * @as(f64, @floatFromInt(i)) / 48000.0));
    const m = measureHz(&buf, 48000, 1000, hz);
    try testing.expect(@abs(1200.0 * std.math.log2(m / hz)) < 0.01);
}

test "and a DECAYING sine, which is what a plucked string is" {
    var buf: [16384]f32 = undefined;
    const hz = 220.0;
    for (&buf, 0..) |*b, i| {
        const t = @as(f64, @floatFromInt(i)) / 48000.0;
        b.* = @floatCast(0.8 * @exp(-t * 3.0) * @sin(2.0 * PI * hz * t));
    }
    const m = measureHz(&buf, 48000, 1000, hz);
    try testing.expect(@abs(1200.0 * std.math.log2(m / hz)) < 0.05);
}

test "the pitch instrument REFUSES rather than report an edge" {
    var buf: [16384]f32 = @splat(0);
    try testing.expectEqual(@as(f64, 0), measureHz(&buf, 48000, 1000, 220)); // silence
    for (&buf, 0..) |*b, i| b.* = @floatCast(@sin(2.0 * PI * 440.0 * @as(f64, @floatFromInt(i)) / 48000.0));
    try testing.expectEqual(@as(f64, 0), measureHz(&buf, 48000, 1000, 220)); // an octave away
}

test "DIAGNOSTIC: every instrument renders, and its pitch is where it was asked" {
    const al = testing.allocator;
    const out = try al.alloc(f32, 48000 * 4);
    defer al.free(out);
    const scr = try al.alloc(f32, scratchFrames(48000));
    defer al.free(scr);
    std.debug.print("\n  {s:<14} {s:>8} {s:>9} {s:>9} {s:>7}\n", .{ "instrument", "hz", "raw c", "tuned c", "peak" });
    for (SPECS, 0..) |s, i| {
        const hz: f64 = switch (s.engine) {
            ENGINE_MEMBRANE => if (s.kind == 2) 55 else 150,
            else => @max(s.lo * 1.5, @min(330.0, s.hi * 0.5)),
        };
        const n = renderNote(@intCast(i), hz, hz, 1.2, 0.8, 0, 48000, out, scr);
        var peak: f32 = 0;
        for (out[0..n]) |x| peak = @max(peak, @abs(x));
        var m: f64 = 0;
        if (n > 0 and s.pitch != PITCH_NONE) {
            if (s.pitch == PITCH_INHARMONIC) {
                m = peakHz(out[0..n], 48000, 480, 16384, hz, 0.06);
            } else {
                m = readPitch(out[0..n], 48000, 12000, hz, wanders(s), false);
            }
        }
        const tc = if (m > 0) 1200.0 * std.math.log2(m / hz) else 999;
        std.debug.print("  {s:<14} {d:>8.2} {d:>9.2} {d:>9.3} {d:>7.3}  {s}\n", .{ s.name, hz, last_raw_cents, tc, peak, if (n == 0) reasonText(last_reason) else "" });
    }
}

test "every pitched instrument, low, middle and high, is within 2 cents" {
    const al = testing.allocator;
    const out = try al.alloc(f32, 48000 * 4);
    defer al.free(out);
    const scr = try al.alloc(f32, scratchFrames(48000));
    defer al.free(scr);
    std.debug.print("\n  {s:<13} {s:>24}   {s:>26}\n", .{ "instrument", "hz lo / mid / hi", "cents lo / mid / hi" });
    var bad: usize = 0;
    for (SPECS, 0..) |s, i| {
        if (s.pitch == PITCH_NONE) continue;
        const lo = s.lo * 1.2;
        const hi = s.hi * 0.8;
        const hzs = [3]f64{ lo, @sqrt(lo * hi), hi };
        var cs: [3]f64 = undefined;
        for (hzs, 0..) |hz, j| {
            const n = renderNote(@intCast(i), hz, hz, 1.2, 0.8, 0, 48000, out, scr);
            var m: f64 = 0;
            if (n > 0) {
                if (s.pitch == PITCH_INHARMONIC) {
                    m = peakHz(out[0..n], 48000, 480, 16384, hz, 0.06);
                } else {
                    m = readPitch(out[0..n], 48000, 12000, hz, wanders(s), false);
                }
            }
            cs[j] = if (m > 0) 1200.0 * std.math.log2(m / hz) else 999;
            if (n == 0) cs[j] = -999;
        }
        std.debug.print("  {s:<13} {d:>7.1} {d:>7.1} {d:>7.1}   {d:>8.3} {d:>8.3} {d:>8.3}\n", .{ s.name, hzs[0], hzs[1], hzs[2], cs[0], cs[1], cs[2] });
        for (cs) |c| {
            if (!(@abs(c) <= 2.0)) bad += 1;
        }
    }
    try testing.expectEqual(@as(usize, 0), bad);
}
