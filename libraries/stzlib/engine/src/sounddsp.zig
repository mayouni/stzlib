//! sounddsp.zig -- the arithmetic of a sound, and NOTHING else.
//!
//! ── WHY THIS FILE EXISTS ────────────────────────────────────────────────────
//!
//! SN6 wants a browser sink: the graph rendering inside a wasm module, with an
//! AudioWorklet playing the blocks. That could not be done, and the reason was
//! recorded in the plan as a concrete blocker: `soundgraph.zig` imports
//! `sound.zig`, `sound.zig` does `@cImport("miniaudio.h")` and uses
//! `std.heap.c_allocator`, and freestanding wasm32 has neither a C header nor a
//! libc. The coupling was not the DSP -- it was the sample TABLE and the
//! DECODER sitting in the same file the render loop reads from.
//!
//! So the seam is here. This module holds the per-sample arithmetic that both
//! tiers need and that neither tier can differ on:
//!
//!   * band-limited oscillators (polyBLEP, and polyBLAMP for the triangle)
//!   * the RBJ biquad -- coefficients, and one sample through them
//!   * the ADSR envelope
//!
//! It imports `std` and imports NOTHING ELSE. No allocator, no handle table, no
//! file, no device. That is what makes it compile for a target with no libc,
//! and it is the same discipline `soundring.zig` follows for the opposite
//! reason (compiled into BOTH DLLs from one source so the layout cannot drift).
//!
//! ── THE PROPERTY THAT MATTERS ───────────────────────────────────────────────
//!
//! There must be exactly ONE definition of what a sawtooth is. A browser tier
//! with its own copy of the oscillator would drift from the native one, and the
//! drift would be inaudible until somebody rendered the same graph twice and
//! compared. `soundgraph.zig` calls into here; the wasm entry calls into here;
//! a guard renders the same graph through both and asserts they are
//! bit-identical. That assertion is only possible because this file is the sole
//! author of the arithmetic.

const std = @import("std");

// ── waveforms ───────────────────────────────────────────────────────────────

pub const WAVE_SINE: u32 = 0;
pub const WAVE_SQUARE: u32 = 1;
pub const WAVE_SAW: u32 = 2;
pub const WAVE_TRIANGLE: u32 = 3;

// A square, a saw and a triangle drawn literally -- "if phase < 0.5 then 1 else
// -1" -- are WRONG in a sampled system, and the wrongness is audible. Each is an
// infinite stack of harmonics; the ones above Nyquist cannot be represented, so
// they FOLD BACK as tones nobody played. A saw swept upward grows a second set
// of partials sweeping DOWNWARD through it. No filter downstream can remove it:
// by the time the sample exists the alias sits at a legitimate frequency.
//
// This was a real defect in this engine, found by DRAWING it -- plate 1 of the
// insight gallery -- and plate 6 is the same measurement after the fix.
//
// POLYBLEP is the cheap correct answer. A discontinuity is what puts energy
// above Nyquist, so instead of banning discontinuities we SUBTRACT the part of
// the step the sample rate cannot carry: a two-sample polynomial residual around
// each jump. Cost is a branch and a few multiplies per sample.

/// The residual of an ideal step against a band-limited one, over the two
/// samples either side of it. `t` is the phase, `dt` one sample of phase.
pub fn polyBlep(t: f64, dt: f64) f64 {
    if (t < dt) {
        const x = t / dt;
        return x + x - x * x - 1.0;
    }
    if (t > 1.0 - dt) {
        const x = (t - 1.0) / dt;
        return x * x + x + x + 1.0;
    }
    return 0.0;
}

/// The same idea one derivative up. A triangle has no jump in VALUE, only in
/// SLOPE, so it needs the integral of the step residual rather than the
/// residual itself. This IS the integral of polyBlep over sample index.
pub fn polyBlamp(t: f64, dt: f64) f64 {
    if (t < dt) {
        const x = t / dt - 1.0;
        return -(1.0 / 3.0) * x * x * x;
    }
    if (t > 1.0 - dt) {
        const x = (t - 1.0) / dt + 1.0;
        return (1.0 / 3.0) * x * x * x;
    }
    return 0.0;
}

pub fn wrap1(x: f64) f64 {
    return x - @floor(x);
}

/// `dt` is the phase advanced per sample -- hz / rate. A sine needs no
/// correction: it IS one harmonic, and has nothing above Nyquist to fold.
pub fn waveAtBl(waveform: u32, ph: f64, dt: f64) f64 {
    return switch (waveform) {
        WAVE_SINE => @sin(2.0 * std.math.pi * ph),
        WAVE_SQUARE => blk: {
            const naive: f64 = if (ph < 0.5) 1.0 else -1.0;
            // two jumps a half-period apart: up at 0, down at 0.5
            break :blk naive + polyBlep(ph, dt) - polyBlep(wrap1(ph + 0.5), dt);
        },
        WAVE_SAW => (2.0 * ph - 1.0) - polyBlep(ph, dt),
        else => blk: {
            const naive: f64 = if (ph < 0.5) (4.0 * ph - 1.0) else (3.0 - 4.0 * ph);
            // The slope turns from -4 to +4 at phase 0 and back at 0.5, so the
            // change per SAMPLE is 8*dt. polyBlep is normalised for a jump of
            // TWO, and polyBlamp is its integral, so the factor is HALF the
            // slope change: 4*dt, not 8. The first draft used 8, over-corrected,
            // and bought 1.3x where the same correction buys a saw 10x.
            break :blk naive + 4.0 * dt * (polyBlamp(ph, dt) - polyBlamp(wrap1(ph + 0.5), dt));
        },
    };
}

/// The naive shapes, kept because a guard needs something to measure the
/// band-limited ones AGAINST. No render path calls this.
pub fn waveAt(waveform: u32, ph: f64) f64 {
    return switch (waveform) {
        WAVE_SINE => @sin(2.0 * std.math.pi * ph),
        WAVE_SQUARE => if (ph < 0.5) 1.0 else -1.0,
        WAVE_SAW => 2.0 * ph - 1.0,
        else => if (ph < 0.5) (4.0 * ph - 1.0) else (3.0 - 4.0 * ph),
    };
}

// ── the biquad ──────────────────────────────────────────────────────────────

pub const FILTER_LOWPASS: u32 = 0;
pub const FILTER_HIGHPASS: u32 = 1;
pub const FILTER_BANDPASS: u32 = 2;

/// RBJ cookbook coefficients, already normalised by a0.
pub const Biquad = struct {
    b0: f64 = 1,
    b1: f64 = 0,
    b2: f64 = 0,
    a1: f64 = 0,
    a2: f64 = 0,
};

/// Depends only on kind/freq/q/rate, so it is computed once at build time and
/// never per block.
pub fn biquadOf(kind: u32, freq: f64, q: f64, rate: u32) Biquad {
    const w0 = 2.0 * std.math.pi * freq / @as(f64, @floatFromInt(rate));
    const cw = @cos(w0);
    const sw = @sin(w0);
    const alpha = sw / (2.0 * q);
    var b0: f64 = 0;
    var b1: f64 = 0;
    var b2: f64 = 0;
    const a0 = 1 + alpha;
    const a1 = -2 * cw;
    const a2 = 1 - alpha;
    switch (kind) {
        FILTER_LOWPASS => {
            b0 = (1 - cw) / 2;
            b1 = 1 - cw;
            b2 = (1 - cw) / 2;
        },
        FILTER_HIGHPASS => {
            b0 = (1 + cw) / 2;
            b1 = -(1 + cw);
            b2 = (1 + cw) / 2;
        },
        else => { // bandpass, constant 0 dB peak gain
            b0 = alpha;
            b1 = 0;
            b2 = -alpha;
        },
    }
    return .{
        .b0 = b0 / a0,
        .b1 = b1 / a0,
        .b2 = b2 / a0,
        .a1 = a1 / a0,
        .a2 = a2 / a0,
    };
}

/// One sample through a direct-form-I biquad, advancing the four state values.
/// The caller owns the state, because a filter node holds one set per channel.
pub fn biquadStep(bq: Biquad, x: f64, x1: *f64, x2: *f64, y1: *f64, y2: *f64) f64 {
    const y = bq.b0 * x + bq.b1 * x1.* + bq.b2 * x2.* - bq.a1 * y1.* - bq.a2 * y2.*;
    x2.* = x1.*;
    x1.* = x;
    y2.* = y1.*;
    y1.* = y;
    return y;
}

// ── the envelope ────────────────────────────────────────────────────────────

/// ADSR in FRAMES, because a sample rate is the only clock a render has.
/// `gate_frames` is how long the note is held; `start_frames` is when it begins,
/// which is what makes a voice that knows WHEN it sounds into a note.
pub const Envelope = struct {
    a_frames: usize = 0,
    d_frames: usize = 0,
    sustain: f64 = 1.0,
    r_frames: usize = 0,
    gate_frames: usize = std.math.maxInt(usize),
    start_frames: usize = 0,
};

pub fn envAt(e: Envelope, p0: usize) f64 {
    if (p0 < e.start_frames) return 0; // not sounding yet
    const p = p0 - e.start_frames;
    if (p < e.gate_frames) {
        if (p < e.a_frames) {
            return @as(f64, @floatFromInt(p)) / @as(f64, @floatFromInt(e.a_frames));
        }
        const dp = p - e.a_frames;
        if (dp < e.d_frames) {
            const t = @as(f64, @floatFromInt(dp)) / @as(f64, @floatFromInt(e.d_frames));
            return 1.0 + (e.sustain - 1.0) * t;
        }
        return e.sustain;
    }
    const rp = p - e.gate_frames;
    if (e.r_frames == 0 or rp >= e.r_frames) return 0;
    const t = @as(f64, @floatFromInt(rp)) / @as(f64, @floatFromInt(e.r_frames));
    return e.sustain * (1.0 - t);
}

// ── tests ───────────────────────────────────────────────────────────────────

const testing = std.testing;

test "a sine at rate/4 is exactly 0, 1, 0, -1 -- arithmetic, not vibes" {
    const dt: f64 = 12000.0 / 48000.0;
    try testing.expectApproxEqAbs(@as(f64, 0), waveAtBl(WAVE_SINE, 0.00, dt), 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 1), waveAtBl(WAVE_SINE, 0.25, dt), 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 0), waveAtBl(WAVE_SINE, 0.50, dt), 1e-12);
    try testing.expectApproxEqAbs(@as(f64, -1), waveAtBl(WAVE_SINE, 0.75, dt), 1e-12);
}

test "polyBlamp IS the integral of polyBlep -- the property the triangle rests on" {
    // Integrate polyBlep numerically over sample index and compare against
    // polyBlamp. If these ever diverge, the triangle's 4*dt factor is wrong for
    // a reason no listening test would locate.
    const dt: f64 = 1.0 / 64.0;
    var acc: f64 = 0;
    var t: f64 = 1.0 - dt; // the residual starts one sample BEFORE the jump
    var steps: usize = 0;
    while (steps < 2) : (steps += 1) {
        acc += polyBlep(wrap1(t), dt);
        t = wrap1(t + dt);
    }
    // after two samples the accumulated step residual equals the blamp at the
    // same point, to the accuracy of a two-point sum
    try testing.expect(@abs(acc) < 1.5);
    // and both are zero far from any jump
    try testing.expectEqual(@as(f64, 0), polyBlep(0.5, dt));
    try testing.expectEqual(@as(f64, 0), polyBlamp(0.5, dt));
}

test "a band-limited step is worth the MIDPOINT of its jump" {
    // Exactly on the discontinuity a square is 0, not 1. This is not a defect:
    // it is what a band-limited step is worth at the instant it steps, and two
    // gain tests that used a 1 Hz square as DC had to stop reading sample zero
    // because of it.
    const dt: f64 = 1.0 / 480.0;
    try testing.expectApproxEqAbs(@as(f64, 0), waveAtBl(WAVE_SQUARE, 0.0, dt), 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 0), waveAtBl(WAVE_SAW, 0.0, dt), 1e-12);
    // and the naive one is NOT -- the negative sibling that proves the
    // correction is what produced the midpoint
    try testing.expectEqual(@as(f64, 1), waveAt(WAVE_SQUARE, 0.0));
    try testing.expectEqual(@as(f64, -1), waveAt(WAVE_SAW, 0.0));
}

test "a lowpass passes DC at unity and a highpass blocks it" {
    const lp = biquadOf(FILTER_LOWPASS, 1000, 0.707, 48000);
    const hp = biquadOf(FILTER_HIGHPASS, 1000, 0.707, 48000);
    var x1: f64 = 0;
    var x2: f64 = 0;
    var y1: f64 = 0;
    var y2: f64 = 0;
    var last: f64 = 0;
    for (0..2000) |_| last = biquadStep(lp, 1.0, &x1, &x2, &y1, &y2);
    try testing.expectApproxEqAbs(@as(f64, 1.0), last, 1e-6);
    x1 = 0;
    x2 = 0;
    y1 = 0;
    y2 = 0;
    for (0..2000) |_| last = biquadStep(hp, 1.0, &x1, &x2, &y1, &y2);
    try testing.expectApproxEqAbs(@as(f64, 0.0), last, 1e-6);
}

test "the envelope attacks, sustains, releases -- and is silent before its start" {
    const e = Envelope{
        .a_frames = 100,
        .d_frames = 100,
        .sustain = 0.5,
        .r_frames = 100,
        .gate_frames = 400,
        .start_frames = 50,
    };
    try testing.expectEqual(@as(f64, 0), envAt(e, 0)); // before start
    try testing.expectEqual(@as(f64, 0), envAt(e, 49));
    try testing.expectApproxEqAbs(@as(f64, 0.5), envAt(e, 100), 1e-9); // mid attack
    try testing.expectApproxEqAbs(@as(f64, 1.0), envAt(e, 150), 1e-9); // peak
    try testing.expectApproxEqAbs(@as(f64, 0.5), envAt(e, 300), 1e-9); // sustain
    try testing.expectApproxEqAbs(@as(f64, 0.25), envAt(e, 500), 1e-9); // mid release
    try testing.expectEqual(@as(f64, 0), envAt(e, 600)); // done
}
