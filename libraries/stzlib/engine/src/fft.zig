//! THE FAST FOURIER TRANSFORM.
//!
//! The last breadth item the numeric retro named. Until now the library had no
//! frequency-domain anything.
//!
//! ── WHY THERE ARE TWO ALGORITHMS HERE AND NOT ONE ──
//!
//! Radix-2 Cooley-Tukey is the FFT everyone writes: it turns an n-point DFT into
//! two n/2-point DFTs and costs O(n log n). But it only works when n is a POWER OF
//! TWO. A library that stops there has to answer "1000 samples" with either a
//! refusal or a silent zero-pad to 1024 -- and zero-padding is not the same
//! transform, it is the transform OF A DIFFERENT SIGNAL. The spectrum it returns is
//! not the spectrum of what the caller passed in.
//!
//! So arbitrary n goes through BLUESTEIN'S ALGORITHM (the chirp-z transform), which
//! rewrites the DFT as a CONVOLUTION and computes that convolution with a
//! power-of-two FFT. The trick is the identity
//!
//!     j*k = ( j^2 + k^2 - (k-j)^2 ) / 2
//!
//! so that w^(jk), with w = exp(-2*pi*i/n), splits into a factor depending on j
//! alone, one on k alone, and one on (k-j) -- and a sum over j of something
//! depending on (k-j) IS a convolution. Padded to a power of two it is O(n log n)
//! like the radix-2 case, with a larger constant.
//!
//! The result: EVERY length is O(n log n) and every length is the true DFT of the
//! samples given. Nothing is padded behind the caller's back.
//!
//! ── ONE DIRECTION IS IMPLEMENTED, NOT TWO ──
//!
//! The inverse DFT is the forward DFT with the sign of the exponent flipped and a
//! 1/n scale, and conjugation flips that sign:
//!
//!     ifft(x) = conj( fft( conj(x) ) ) / n
//!
//! So `transform` conjugates on the way in, runs the FORWARD path, and conjugates
//! and scales on the way out. Radix-2 and Bluestein each implement forward only --
//! one definition of each algorithm, and the inverse cannot drift away from it.

const std = @import("std");
const Complex = @import("complex.zig").Complex;

pub const FftError = error{OutOfMemory};

pub fn isPowerOfTwo(n: usize) bool {
    return n != 0 and (n & (n - 1)) == 0;
}

fn nextPowerOfTwo(n: usize) usize {
    var m: usize = 1;
    while (m < n) m <<= 1;
    return m;
}

/// In-place forward radix-2 Cooley-Tukey. `re.len` must be a power of two.
///
/// The twiddle factors are recomputed with @cos/@sin at every k rather than carried
/// forward by repeated complex multiplication. Recurrence is cheaper and is what most
/// textbook code does, but its error grows along each butterfly row; recomputing keeps
/// the transform accurate enough to sit beside LAPACK-grade references, which is the
/// standard this library is now held to.
fn radix2Forward(re: []f64, im: []f64) void {
    const n = re.len;
    if (n < 2) return;

    // bit-reversal permutation
    var j: usize = 0;
    var i: usize = 1;
    while (i < n) : (i += 1) {
        var bit = n >> 1;
        while (j & bit != 0) {
            j ^= bit;
            bit >>= 1;
        }
        j |= bit;
        if (i < j) {
            std.mem.swap(f64, &re[i], &re[j]);
            std.mem.swap(f64, &im[i], &im[j]);
        }
    }

    var span: usize = 2;
    while (span <= n) : (span <<= 1) {
        const half = span / 2;
        const base = -2.0 * std.math.pi / @as(f64, @floatFromInt(span));
        var start: usize = 0;
        while (start < n) : (start += span) {
            var k: usize = 0;
            while (k < half) : (k += 1) {
                const ang = base * @as(f64, @floatFromInt(k));
                const wr = @cos(ang);
                const wi = @sin(ang);
                const lo = start + k;
                const hi = lo + half;
                const xr = re[hi] * wr - im[hi] * wi;
                const xi = re[hi] * wi + im[hi] * wr;
                re[hi] = re[lo] - xr;
                im[hi] = im[lo] - xi;
                re[lo] += xr;
                im[lo] += xi;
            }
        }
    }
}

/// In-place forward DFT for ANY length, via Bluestein's chirp-z convolution.
fn bluesteinForward(alloc: std.mem.Allocator, re: []f64, im: []f64) !void {
    const n = re.len;
    if (n < 2) return;

    // the convolution must not wrap: it needs 2n-1 distinct lags
    const m = nextPowerOfTwo(2 * n - 1);

    const ar = try alloc.alloc(f64, m);
    defer alloc.free(ar);
    const ai = try alloc.alloc(f64, m);
    defer alloc.free(ai);
    const br = try alloc.alloc(f64, m);
    defer alloc.free(br);
    const bi = try alloc.alloc(f64, m);
    defer alloc.free(bi);
    @memset(ar, 0);
    @memset(ai, 0);
    @memset(br, 0);
    @memset(bi, 0);

    const nf = @as(f64, @floatFromInt(n));

    // a_j = x_j * exp(-i*pi*j^2/n)   and   b_t = exp(+i*pi*t^2/n)
    //
    // j^2 is reduced mod 2n before becoming an angle: j^2 overflows the range where
    // f64 angles stay accurate long before j does, and (j^2 mod 2n) leaves
    // exp(i*pi*j^2/n) unchanged because the period of that exponential in j^2 is 2n.
    var j: usize = 0;
    while (j < n) : (j += 1) {
        const q = (j * j) % (2 * n);
        const ang = std.math.pi * @as(f64, @floatFromInt(q)) / nf;
        const cr = @cos(ang);
        const ci = @sin(ang);
        // a = x * conj(chirp)
        ar[j] = re[j] * cr + im[j] * ci;
        ai[j] = im[j] * cr - re[j] * ci;
        // b = chirp, stored symmetrically so index (k-j) works cyclically
        br[j] = cr;
        bi[j] = ci;
        if (j != 0) {
            br[m - j] = cr;
            bi[m - j] = ci;
        }
    }

    radix2Forward(ar, ai);
    radix2Forward(br, bi);

    // pointwise product
    var t: usize = 0;
    while (t < m) : (t += 1) {
        const pr = ar[t] * br[t] - ai[t] * bi[t];
        const pi = ar[t] * bi[t] + ai[t] * br[t];
        ar[t] = pr;
        ai[t] = pi;
    }

    // inverse transform of the product: conj -> forward -> conj, scaled by 1/m
    t = 0;
    while (t < m) : (t += 1) ai[t] = -ai[t];
    radix2Forward(ar, ai);
    const invm = 1.0 / @as(f64, @floatFromInt(m));
    t = 0;
    while (t < m) : (t += 1) {
        ar[t] *= invm;
        ai[t] = -ai[t] * invm;
    }

    // X_k = conj(chirp_k) * c_k
    var k: usize = 0;
    while (k < n) : (k += 1) {
        const q = (k * k) % (2 * n);
        const ang = std.math.pi * @as(f64, @floatFromInt(q)) / nf;
        const cr = @cos(ang);
        const ci = @sin(ang);
        re[k] = ar[k] * cr + ai[k] * ci;
        im[k] = ai[k] * cr - ar[k] * ci;
    }
}

/// THE TRANSFORM. In place, any length, forward or inverse.
///
/// Forward uses exp(-2*pi*i*j*k/n) and applies no scaling; inverse uses the opposite
/// sign and divides by n. That is the same convention as NumPy's `fft`/`ifft`, so a
/// spectrum computed here can be compared with one computed there without a fudge
/// factor -- which is exactly what this module's guard does.
pub fn transform(alloc: std.mem.Allocator, re: []f64, im: []f64, inverse: bool) !void {
    const n = re.len;
    if (n != im.len) return;
    if (n < 2) return; // the DFT of a single sample is that sample

    if (inverse) {
        var i: usize = 0;
        while (i < n) : (i += 1) im[i] = -im[i];
    }

    if (isPowerOfTwo(n)) {
        radix2Forward(re, im);
    } else {
        try bluesteinForward(alloc, re, im);
    }

    if (inverse) {
        const inv = 1.0 / @as(f64, @floatFromInt(n));
        var i: usize = 0;
        while (i < n) : (i += 1) {
            re[i] *= inv;
            im[i] = -im[i] * inv;
        }
    }
}

/// LINEAR convolution of two real sequences -- the operation that makes an FFT pay
/// for itself outside signal processing, because it is exactly POLYNOMIAL
/// MULTIPLICATION: the coefficients of a*b are the convolution of the coefficients.
///
/// Schoolbook multiplication is O(n*m). This is O(N log N) with N the padded length,
/// so it overtakes the direct method once the operands are big enough -- and it is
/// the same arithmetic, so for small inputs the two agree to rounding.
///
/// `out` must have room for a.len + b.len - 1.
pub fn convolveReal(
    alloc: std.mem.Allocator,
    a: []const f64,
    b: []const f64,
    out: []f64,
) !void {
    if (a.len == 0 or b.len == 0) return;
    const need = a.len + b.len - 1;
    // padded to a power of two so the cyclic convolution the FFT computes has room
    // to hold the LINEAR one without wrapping
    const m = nextPowerOfTwo(need);

    const ar = try alloc.alloc(f64, m);
    defer alloc.free(ar);
    const ai = try alloc.alloc(f64, m);
    defer alloc.free(ai);
    const br = try alloc.alloc(f64, m);
    defer alloc.free(br);
    const bi = try alloc.alloc(f64, m);
    defer alloc.free(bi);
    @memset(ar, 0);
    @memset(ai, 0);
    @memset(br, 0);
    @memset(bi, 0);
    @memcpy(ar[0..a.len], a);
    @memcpy(br[0..b.len], b);

    radix2Forward(ar, ai);
    radix2Forward(br, bi);

    var t: usize = 0;
    while (t < m) : (t += 1) {
        const pr = ar[t] * br[t] - ai[t] * bi[t];
        const pi = ar[t] * bi[t] + ai[t] * br[t];
        ar[t] = pr;
        ai[t] = -pi; // conjugate for the inverse pass
    }
    radix2Forward(ar, ai);

    const invm = 1.0 / @as(f64, @floatFromInt(m));
    const lim = @min(need, out.len);
    t = 0;
    while (t < lim) : (t += 1) out[t] = ar[t] * invm;
}

/// ── READING A SPECTRUM: COMPLETE OPERATIONS, NOT A TRANSFORM PLUS HOST LOOPS ──
///
/// `transform` alone is half an answer. Almost nobody wants raw complex bins; they want
/// "how much of each frequency is present" or "which frequency dominates". Leaving that
/// to the host means every binding writes the same loops -- and gets the same details
/// wrong, particularly the two below.
///
/// Each of these takes a SIGNAL and returns the finished reading, so a host binds
/// arguments and reads a result.
/// |X_k| per bin -- "how much of this frequency is present". Phase-blind, which is what
/// you want when looking for a periodicity.
pub fn magnitudes(alloc: std.mem.Allocator, re: []f64, im: []f64, out: []f64) !void {
    try transform(alloc, re, im, false);
    for (0..re.len) |k| out[k] = @sqrt(re[k] * re[k] + im[k] * im[k]);
}

/// The phase angle of each bin, in radians.
pub fn phases(alloc: std.mem.Allocator, re: []f64, im: []f64, out: []f64) !void {
    try transform(alloc, re, im, false);
    for (0..re.len) |k| out[k] = std.math.atan2(im[k], re[k]);
}

/// |X_k|^2 -- energy per bin, the quantity Parseval's theorem is about.
pub fn powerSpectrum(alloc: std.mem.Allocator, re: []f64, im: []f64, out: []f64) !void {
    try transform(alloc, re, im, false);
    for (0..re.len) |k| out[k] = re[k] * re[k] + im[k] * im[k];
}

/// The bin carrying the most energy, 0-based, or 0 for a signal too short to have one.
///
/// TWO DETAILS THAT ARE EASY TO GET WRONG, which is the reason this is not left to the
/// host:
///
///   * BIN 0 IS EXCLUDED. It holds the sum -- the signal's mean, not a frequency -- and
///     for any signal that is not centred it is usually the largest bin by far, so a
///     naive argmax reports "the dominant frequency is zero" almost every time.
///   * ONLY THE FIRST HALF IS SEARCHED. A real signal has a conjugate-symmetric
///     spectrum: bin k and bin n-k carry the same magnitude. Searching the whole range
///     returns the mirror image half the time, naming the same frequency by the wrong
///     number.
pub fn dominantBin(alloc: std.mem.Allocator, re: []f64, im: []f64) !usize {
    const n = re.len;
    if (n < 2) return 0;
    try transform(alloc, re, im, false);
    const half = n / 2 + 1;
    var best: usize = 1;
    var bestv: f64 = -1;
    var k: usize = 1; // skip DC
    while (k < half) : (k += 1) {
        const m = re[k] * re[k] + im[k] * im[k];
        if (m > bestv) {
            bestv = m;
            best = k;
        }
    }
    return best;
}

/// The dominant frequency in cycles per sample-interval; multiply by a sample rate for Hz.
pub fn dominantFrequency(alloc: std.mem.Allocator, re: []f64, im: []f64) !f64 {
    const n = re.len;
    if (n < 2) return 0;
    const b = try dominantBin(alloc, re, im);
    return @as(f64, @floatFromInt(b)) / @as(f64, @floatFromInt(n));
}

test "the spectrum readings are complete answers, and they exclude DC" {
    const alloc = testing.allocator;
    const n = 16;
    var re: [n]f64 = undefined;
    var im = [_]f64{0} ** n;
    // frequency 3, ON A DELIBERATE OFFSET of 10: bin 0 will hold 160 and dwarf every
    // real frequency, which is exactly the trap dominantBin has to avoid
    for (0..n) |j| {
        re[j] = 10.0 + @cos(2.0 * std.math.pi * 3.0 * @as(f64, @floatFromInt(j)) /
            @as(f64, @floatFromInt(n)));
    }
    const keepR = re;
    const keepI = im;

    var mag = [_]f64{0} ** n;
    try magnitudes(alloc, &re, &im, &mag);
    try testing.expectApproxEqAbs(@as(f64, 160), mag[0], 1e-9); // DC really is huge
    try testing.expectApproxEqAbs(@as(f64, 8), mag[3], 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 8), mag[13], 1e-9); // the mirror

    // and the dominant bin is 3, not 0 (DC) and not 13 (the mirror)
    re = keepR;
    im = keepI;
    try testing.expectEqual(@as(usize, 3), try dominantBin(alloc, &re, &im));
    re = keepR;
    im = keepI;
    try testing.expectApproxEqAbs(3.0 / 16.0, try dominantFrequency(alloc, &re, &im), 1e-12);

    // power is magnitude squared, bin for bin
    re = keepR;
    im = keepI;
    var pw = [_]f64{0} ** n;
    try powerSpectrum(alloc, &re, &im, &pw);
    for (0..n) |k| try testing.expectApproxEqAbs(mag[k] * mag[k], pw[k], 1e-6);

    // phase of a pure cosine at its own bin is 0
    re = keepR;
    im = keepI;
    var ph = [_]f64{0} ** n;
    try phases(alloc, &re, &im, &ph);
    try testing.expectApproxEqAbs(@as(f64, 0), ph[3], 1e-9);
}

// ── tests ────────────────────────────────────────────────────────────────────

const testing = std.testing;

fn naiveDft(re: []const f64, im: []const f64, outRe: []f64, outIm: []f64, inverse: bool) void {
    const n = re.len;
    const sign: f64 = if (inverse) 2.0 else -2.0;
    for (0..n) |k| {
        var sr: f64 = 0;
        var si: f64 = 0;
        for (0..n) |j| {
            const ang = sign * std.math.pi * @as(f64, @floatFromInt(j * k)) /
                @as(f64, @floatFromInt(n));
            const c = @cos(ang);
            const s = @sin(ang);
            sr += re[j] * c - im[j] * s;
            si += re[j] * s + im[j] * c;
        }
        if (inverse) {
            const inv = 1.0 / @as(f64, @floatFromInt(n));
            outRe[k] = sr * inv;
            outIm[k] = si * inv;
        } else {
            outRe[k] = sr;
            outIm[k] = si;
        }
    }
}

test "the DFT of a delta is flat, and of a constant is a single spike" {
    const alloc = testing.allocator;
    const n = 8;
    var re = [_]f64{ 1, 0, 0, 0, 0, 0, 0, 0 };
    var im = [_]f64{0} ** n;

    // delta at 0 -> every bin equal to 1. Every frequency is present in an impulse.
    try transform(alloc, &re, &im, false);
    for (0..n) |k| {
        try testing.expectApproxEqAbs(@as(f64, 1), re[k], 1e-12);
        try testing.expectApproxEqAbs(@as(f64, 0), im[k], 1e-12);
    }

    // a constant -> all the energy in bin 0. A signal that never changes has no
    // frequency content above DC.
    var cr = [_]f64{3} ** n;
    var ci = [_]f64{0} ** n;
    try transform(alloc, &cr, &ci, false);
    try testing.expectApproxEqAbs(@as(f64, 3 * n), cr[0], 1e-11);
    for (1..n) |k| {
        try testing.expectApproxEqAbs(@as(f64, 0), cr[k], 1e-11);
        try testing.expectApproxEqAbs(@as(f64, 0), ci[k], 1e-11);
    }
}

test "a sinusoid lands in exactly two bins" {
    const alloc = testing.allocator;
    const n = 16;
    var re: [n]f64 = undefined;
    var im = [_]f64{0} ** n;
    // cos(2*pi*3*j/n) -- frequency 3, so bins 3 and n-3 each carry n/2
    for (0..n) |j| {
        re[j] = @cos(2.0 * std.math.pi * 3.0 * @as(f64, @floatFromInt(j)) /
            @as(f64, @floatFromInt(n)));
    }
    try transform(alloc, &re, &im, false);
    try testing.expectApproxEqAbs(@as(f64, n / 2), re[3], 1e-10);
    try testing.expectApproxEqAbs(@as(f64, n / 2), re[n - 3], 1e-10);
    for (0..n) |k| {
        if (k != 3 and k != n - 3) {
            const mag = @sqrt(re[k] * re[k] + im[k] * im[k]);
            try testing.expect(mag < 1e-10);
        }
    }
}

test "the round trip is the identity, at a power of two AND at a prime length" {
    const alloc = testing.allocator;

    // power of two -> radix-2 path
    {
        const n = 32;
        var re: [n]f64 = undefined;
        var im: [n]f64 = undefined;
        var keepR: [n]f64 = undefined;
        var keepI: [n]f64 = undefined;
        for (0..n) |i| {
            const x = @as(f64, @floatFromInt(i));
            re[i] = @sin(0.7 * x) + 0.3 * x;
            im[i] = @cos(0.2 * x);
            keepR[i] = re[i];
            keepI[i] = im[i];
        }
        try transform(alloc, &re, &im, false);
        try transform(alloc, &re, &im, true);
        for (0..n) |i| {
            try testing.expectApproxEqAbs(keepR[i], re[i], 1e-11);
            try testing.expectApproxEqAbs(keepI[i], im[i], 1e-11);
        }
    }

    // 17 is PRIME, so no radix decomposition exists at all -- this is the Bluestein
    // path, and it must round-trip just as exactly
    {
        const n = 17;
        var re: [n]f64 = undefined;
        var im: [n]f64 = undefined;
        var keepR: [n]f64 = undefined;
        var keepI: [n]f64 = undefined;
        for (0..n) |i| {
            const x = @as(f64, @floatFromInt(i));
            re[i] = @sin(1.1 * x) - 0.4 * x;
            im[i] = 0.5 * @cos(0.9 * x);
            keepR[i] = re[i];
            keepI[i] = im[i];
        }
        try transform(alloc, &re, &im, false);
        try transform(alloc, &re, &im, true);
        for (0..n) |i| {
            try testing.expectApproxEqAbs(keepR[i], re[i], 1e-10);
            try testing.expectApproxEqAbs(keepI[i], im[i], 1e-10);
        }
    }
}

test "BLUESTEIN AND RADIX-2 AGREE WHERE BOTH APPLY -- two algorithms, one answer" {
    const alloc = testing.allocator;
    const n = 64; // a power of two, so both paths are legal
    var radR: [n]f64 = undefined;
    var radI = [_]f64{0} ** n;
    var bluR: [n]f64 = undefined;
    var bluI = [_]f64{0} ** n;
    for (0..n) |i| {
        const x = @as(f64, @floatFromInt(i));
        radR[i] = @sin(0.31 * x) * (1.0 + 0.1 * x);
        bluR[i] = radR[i];
    }

    radix2Forward(&radR, &radI);
    try bluesteinForward(alloc, &bluR, &bluI);

    // The two algorithms share nothing but the radix-2 kernel Bluestein calls on a
    // DIFFERENT length, so agreement here is a genuine cross-check and not a
    // restatement. Bluestein does more arithmetic, hence the looser tolerance.
    for (0..n) |k| {
        try testing.expectApproxEqAbs(radR[k], bluR[k], 1e-9);
        try testing.expectApproxEqAbs(radI[k], bluI[k], 1e-9);
    }
}

test "both paths agree with the naive O(n^2) DFT" {
    const alloc = testing.allocator;
    // 12 is composite-but-not-a-power-of-two, 13 is prime: both take Bluestein
    inline for (.{ 8, 12, 13 }) |n| {
        var re: [n]f64 = undefined;
        var im: [n]f64 = undefined;
        var nr: [n]f64 = undefined;
        var ni: [n]f64 = undefined;
        var kr: [n]f64 = undefined;
        var ki: [n]f64 = undefined;
        for (0..n) |i| {
            const x = @as(f64, @floatFromInt(i));
            re[i] = 0.5 + @sin(0.8 * x);
            im[i] = @cos(0.45 * x) - 0.2;
            kr[i] = re[i];
            ki[i] = im[i];
        }
        naiveDft(&kr, &ki, &nr, &ni, false);
        try transform(alloc, &re, &im, false);
        for (0..n) |k| {
            try testing.expectApproxEqAbs(nr[k], re[k], 1e-10);
            try testing.expectApproxEqAbs(ni[k], im[k], 1e-10);
        }
    }
}

test "Parseval's theorem holds -- energy is conserved" {
    const alloc = testing.allocator;
    const n = 20; // not a power of two, so this also exercises Bluestein
    var re: [n]f64 = undefined;
    var im = [_]f64{0} ** n;
    var energy: f64 = 0;
    for (0..n) |i| {
        const x = @as(f64, @floatFromInt(i));
        re[i] = @sin(0.6 * x) + 0.25 * @cos(1.7 * x);
        energy += re[i] * re[i];
    }
    try transform(alloc, &re, &im, false);

    // sum |x_j|^2 == (1/n) sum |X_k|^2. A statement about the transform being a
    // scaled isometry, and a stringent whole-spectrum check: no single bin can be
    // wrong without breaking it.
    var spec: f64 = 0;
    for (0..n) |k| spec += re[k] * re[k] + im[k] * im[k];
    try testing.expectApproxEqAbs(energy, spec / @as(f64, @floatFromInt(n)), 1e-10);
}

test "FFT convolution equals schoolbook polynomial multiplication" {
    const alloc = testing.allocator;
    // (1 + 2x + 3x^2) * (4 + 5x) = 4 + 13x + 22x^2 + 15x^3
    const a = [_]f64{ 1, 2, 3 };
    const b = [_]f64{ 4, 5 };
    var out = [_]f64{0} ** 4;
    try convolveReal(alloc, &a, &b, &out);
    const want = [_]f64{ 4, 13, 22, 15 };
    for (want, out) |w, g| try testing.expectApproxEqAbs(w, g, 1e-10);

    // and on a longer pair, against the direct O(n*m) sum
    const na = 30;
    const nb = 25;
    var x: [na]f64 = undefined;
    var y: [nb]f64 = undefined;
    for (0..na) |i| x[i] = @sin(0.3 * @as(f64, @floatFromInt(i))) + 1.0;
    for (0..nb) |i| y[i] = @cos(0.4 * @as(f64, @floatFromInt(i))) - 0.5;

    var direct = [_]f64{0} ** (na + nb - 1);
    for (0..na) |i| {
        for (0..nb) |j| direct[i + j] += x[i] * y[j];
    }
    var viaFft = [_]f64{0} ** (na + nb - 1);
    try convolveReal(alloc, &x, &y, &viaFft);
    for (direct, viaFft) |d, f| try testing.expectApproxEqAbs(d, f, 1e-9);
}

test "the degenerate lengths do not crash" {
    const alloc = testing.allocator;
    var empty = [_]f64{};
    try transform(alloc, &empty, &empty, false);

    // a single sample is its own transform, forward or inverse
    var one = [_]f64{7};
    var oneI = [_]f64{0};
    try transform(alloc, &one, &oneI, false);
    try testing.expectApproxEqAbs(@as(f64, 7), one[0], 1e-15);
    try transform(alloc, &one, &oneI, true);
    try testing.expectApproxEqAbs(@as(f64, 7), one[0], 1e-15);

    // length 3 is the smallest Bluestein case
    var three = [_]f64{ 1, 2, 4 };
    var threeI = [_]f64{0} ** 3;
    try transform(alloc, &three, &threeI, false);
    try testing.expectApproxEqAbs(@as(f64, 7), three[0], 1e-12); // bin 0 is the sum
    try transform(alloc, &three, &threeI, true);
    try testing.expectApproxEqAbs(@as(f64, 1), three[0], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 2), three[1], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 4), three[2], 1e-12);
}
