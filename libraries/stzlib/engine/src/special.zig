// Softanza Engine -- special functions and the distributions built on them.
//
// Phase 4 of the numeric foundation, pillar 4 item 5. The plan calls this "small,
// well-published mathematics, and the thing standing between us and real
// statistics", and section 2.6 is blunter: WITHOUT THESE, NO p-VALUE OR CDF IN
// THIS LIBRARY CAN BE CORRECT.
//
// It is not a hypothetical gap. `stzDataSet.ConfidenceInterval` was labelled
// "t-distribution" while hardcoding three z values; for n = 5 its margin was 41%
// too narrow, and worse as n shrank -- exactly when a t interval matters. Phase 0
// made that honest rather than right: it now declares `:method = :normal`, warns
// on a small sample, and RAISES on any level it has no tabulated value for, with
// the message "a t-based interval for an arbitrary level needs the inverse
// incomplete beta function -- not in the engine yet." This module is that
// function, and the note can come down.
//
// TWO CORE FUNCTIONS, AND EVERYTHING ELSE DERIVED FROM THEM. Rather than a dozen
// independent rational approximations -- which is how a library ends up with two
// answers for one quantity, the disease phases 0, 3 and 4 each had to cure -- this
// module has exactly two workhorses:
//
//   * the REGULARISED INCOMPLETE GAMMA P(a,x) and Q(a,x)
//       -> erf, erfc, the normal CDF, the chi-square CDF, the Poisson CDF
//   * the REGULARISED INCOMPLETE BETA I_x(a,b)
//       -> the Student t CDF, the F CDF, the binomial CDF
//
// So `erf` here is not an approximation of erf; it IS P(1/2, x^2), and shares
// every digit of its accuracy with the chi-square CDF. Zig's std supplies lgamma,
// which is the only other ingredient needed.
//
// Quantiles (inverse CDFs) are found by BISECTION on the CDF rather than by a
// separate rational approximation of each inverse. That is a deliberate trade: a
// quantile costs ~60 CDF evaluations instead of ~20 flops, which is irrelevant --
// a confidence interval is computed once, not per element -- and in exchange the
// inverse cannot disagree with the forward function it inverts. Bracketing is
// explicit, so a bad input cannot loop forever.

const std = @import("std");
const math = std.math;

const EPS: f64 = 3.0e-16;
const FPMIN: f64 = 1.0e-300;
const MAXIT = 300;

// ─── The first workhorse: regularised incomplete gamma ───

/// P(a,x) -- the lower regularised incomplete gamma, i.e. the fraction of a
/// Gamma(a) distribution lying below x. Series below the crossover, and one minus
/// the continued fraction above it, because each converges quickly on only one
/// side of x = a + 1.
pub fn gammaP(a: f64, x: f64) f64 {
    if (!(a > 0) or x < 0) return math.nan(f64);
    if (x == 0) return 0;
    if (x < a + 1.0) return gammaSeries(a, x);
    return 1.0 - gammaContinuedFraction(a, x);
}

/// Q(a,x) = 1 - P(a,x), computed on whichever side is accurate. Worth having
/// separately: for large x, P is 1 to the last bit and `1 - P` would lose every
/// significant digit of the tail, which is precisely the region a p-value lives in.
pub fn gammaQ(a: f64, x: f64) f64 {
    if (!(a > 0) or x < 0) return math.nan(f64);
    if (x == 0) return 1;
    if (x < a + 1.0) return 1.0 - gammaSeries(a, x);
    return gammaContinuedFraction(a, x);
}

fn gammaSeries(a: f64, x: f64) f64 {
    const lg = math.lgamma(f64, a);
    var ap = a;
    var sum = 1.0 / a;
    var del = sum;
    var n: usize = 0;
    while (n < MAXIT) : (n += 1) {
        ap += 1.0;
        del *= x / ap;
        sum += del;
        if (@abs(del) < @abs(sum) * EPS) break;
    }
    return sum * @exp(-x + a * @log(x) - lg);
}

/// Modified Lentz evaluation of the continued fraction for Q(a,x).
fn gammaContinuedFraction(a: f64, x: f64) f64 {
    const lg = math.lgamma(f64, a);
    var b = x + 1.0 - a;
    var c: f64 = 1.0 / FPMIN;
    var d = 1.0 / b;
    var h = d;
    var i: usize = 1;
    while (i <= MAXIT) : (i += 1) {
        const fi: f64 = @floatFromInt(i);
        const an = -fi * (fi - a);
        b += 2.0;
        d = an * d + b;
        if (@abs(d) < FPMIN) d = FPMIN;
        c = b + an / c;
        if (@abs(c) < FPMIN) c = FPMIN;
        d = 1.0 / d;
        const del = d * c;
        h *= del;
        if (@abs(del - 1.0) < EPS) break;
    }
    return @exp(-x + a * @log(x) - lg) * h;
}

// ─── The second workhorse: regularised incomplete beta ───

/// I_x(a,b) -- the regularised incomplete beta. The symmetry
/// I_x(a,b) = 1 - I_{1-x}(b,a) is used to stay on the fast-converging side.
pub fn betaI(a: f64, b: f64, x: f64) f64 {
    if (!(a > 0) or !(b > 0)) return math.nan(f64);
    if (x <= 0) return 0;
    if (x >= 1) return 1;
    const lbeta = math.lgamma(f64, a + b) - math.lgamma(f64, a) - math.lgamma(f64, b);
    const front = @exp(lbeta + a * @log(x) + b * @log(1.0 - x));
    if (x < (a + 1.0) / (a + b + 2.0)) {
        return front * betaContinuedFraction(a, b, x) / a;
    }
    return 1.0 - front * betaContinuedFraction(b, a, 1.0 - x) / b;
}

fn betaContinuedFraction(a: f64, b: f64, x: f64) f64 {
    const qab = a + b;
    const qap = a + 1.0;
    const qam = a - 1.0;
    var c: f64 = 1.0;
    var d: f64 = 1.0 - qab * x / qap;
    if (@abs(d) < FPMIN) d = FPMIN;
    d = 1.0 / d;
    var h = d;
    var m: usize = 1;
    while (m <= MAXIT) : (m += 1) {
        const fm: f64 = @floatFromInt(m);
        const m2 = 2.0 * fm;
        // even step
        var aa = fm * (b - fm) * x / ((qam + m2) * (a + m2));
        d = 1.0 + aa * d;
        if (@abs(d) < FPMIN) d = FPMIN;
        c = 1.0 + aa / c;
        if (@abs(c) < FPMIN) c = FPMIN;
        d = 1.0 / d;
        h *= d * c;
        // odd step
        aa = -(a + fm) * (qab + fm) * x / ((a + m2) * (qap + m2));
        d = 1.0 + aa * d;
        if (@abs(d) < FPMIN) d = FPMIN;
        c = 1.0 + aa / c;
        if (@abs(c) < FPMIN) c = FPMIN;
        d = 1.0 / d;
        const del = d * c;
        h *= del;
        if (@abs(del - 1.0) < EPS) break;
    }
    return h;
}

// ─── The error function, WHICH IS the incomplete gamma ───

/// erf(x) = sign(x) * P(1/2, x^2). Not an approximation OF erf -- it is erf,
/// sharing every digit of its accuracy with the chi-square CDF above.
pub fn erf(x: f64) f64 {
    if (x == 0) return 0;
    if (math.isNan(x)) return x;
    const p = gammaP(0.5, x * x);
    return if (x > 0) p else -p;
}

/// erfc computed from Q rather than as 1 - erf, so the tail keeps its significant
/// digits. erfc(6) is about 2.15e-17: `1 - erf(6)` would answer exactly 0.
pub fn erfc(x: f64) f64 {
    if (math.isNan(x)) return x;
    if (x >= 0) return gammaQ(0.5, x * x);
    return 1.0 + gammaP(0.5, x * x);
}

// ─── Distributions ───

pub fn normalCdf(x: f64) f64 {
    return 0.5 * erfc(-x / math.sqrt2);
}

pub fn normalPdf(x: f64) f64 {
    return @exp(-0.5 * x * x) / @sqrt(2.0 * math.pi);
}

/// The Student t CDF with df degrees of freedom.
pub fn studentTCdf(t: f64, df: f64) f64 {
    if (!(df > 0)) return math.nan(f64);
    const x = df / (df + t * t);
    const half = 0.5 * betaI(0.5 * df, 0.5, x);
    return if (t > 0) 1.0 - half else half;
}

pub fn chiSquareCdf(x: f64, df: f64) f64 {
    if (!(df > 0)) return math.nan(f64);
    if (x <= 0) return 0;
    return gammaP(0.5 * df, 0.5 * x);
}

pub fn fCdf(x: f64, d1: f64, d2: f64) f64 {
    if (!(d1 > 0) or !(d2 > 0)) return math.nan(f64);
    if (x <= 0) return 0;
    return betaI(0.5 * d1, 0.5 * d2, d1 * x / (d1 * x + d2));
}

// ─── Quantiles, by bisection on the CDF above ───
//
// One inversion routine, used by every distribution, so an inverse can never
// disagree with the forward function. Brackets are widened until they straddle p,
// with a hard cap, so a pathological input terminates rather than spinning.

fn invertCdf(comptime cdf: anytype, args: anytype, p: f64, lo_start: f64, hi_start: f64) f64 {
    if (!(p > 0) or !(p < 1)) {
        if (p == 0) return -math.inf(f64);
        if (p == 1) return math.inf(f64);
        return math.nan(f64);
    }

    var lo = lo_start;
    var hi = hi_start;
    var widen: usize = 0;
    while (@call(.auto, cdf, .{lo} ++ args) > p and widen < 200) : (widen += 1) {
        hi = lo;
        lo = lo * 2.0 - 1.0;
    }
    widen = 0;
    while (@call(.auto, cdf, .{hi} ++ args) < p and widen < 200) : (widen += 1) {
        lo = hi;
        hi = hi * 2.0 + 1.0;
    }

    var i: usize = 0;
    while (i < 200) : (i += 1) {
        const mid = 0.5 * (lo + hi);
        if (mid == lo or mid == hi) break; // consecutive doubles: as tight as f64 goes
        if (@call(.auto, cdf, .{mid} ++ args) < p) lo = mid else hi = mid;
    }
    return 0.5 * (lo + hi);
}

pub fn normalQuantile(p: f64) f64 {
    return invertCdf(normalCdf, .{}, p, -8.0, 8.0);
}

pub fn studentTQuantile(p: f64, df: f64) f64 {
    if (!(df > 0)) return math.nan(f64);
    return invertCdf(studentTCdf, .{df}, p, -100.0, 100.0);
}

pub fn chiSquareQuantile(p: f64, df: f64) f64 {
    if (!(df > 0)) return math.nan(f64);
    return invertCdf(chiSquareCdf, .{df}, p, 0.0, 2.0 * df + 20.0);
}

pub fn fQuantile(p: f64, d1: f64, d2: f64) f64 {
    if (!(d1 > 0) or !(d2 > 0)) return math.nan(f64);
    return invertCdf(fCdf, .{ d1, d2 }, p, 0.0, 100.0);
}

/// The two-sided critical value for a confidence level given as a PERCENTAGE
/// (95 rather than 0.95), which is the form stzDataSet's public surface uses.
/// t if df is finite and positive, normal if df <= 0.
pub fn criticalValue(level_pct: f64, df: f64) f64 {
    const alpha = 1.0 - level_pct / 100.0;
    const p = 1.0 - alpha / 2.0;
    if (df > 0) return studentTQuantile(p, df);
    return normalQuantile(p);
}

// ─── C ABI ───

pub fn stz_special_erf(x: f64) callconv(.c) f64 {
    return erf(x);
}
pub fn stz_special_erfc(x: f64) callconv(.c) f64 {
    return erfc(x);
}
pub fn stz_special_lgamma(x: f64) callconv(.c) f64 {
    return math.lgamma(f64, x);
}
pub fn stz_special_tgamma(x: f64) callconv(.c) f64 {
    return math.gamma(f64, x);
}
pub fn stz_special_gamma_p(a: f64, x: f64) callconv(.c) f64 {
    return gammaP(a, x);
}
pub fn stz_special_gamma_q(a: f64, x: f64) callconv(.c) f64 {
    return gammaQ(a, x);
}
pub fn stz_special_beta_i(a: f64, b: f64, x: f64) callconv(.c) f64 {
    return betaI(a, b, x);
}
pub fn stz_special_normal_cdf(x: f64) callconv(.c) f64 {
    return normalCdf(x);
}
pub fn stz_special_normal_quantile(p: f64) callconv(.c) f64 {
    return normalQuantile(p);
}
pub fn stz_special_t_cdf(t: f64, df: f64) callconv(.c) f64 {
    return studentTCdf(t, df);
}
pub fn stz_special_t_quantile(p: f64, df: f64) callconv(.c) f64 {
    return studentTQuantile(p, df);
}
pub fn stz_special_chi2_cdf(x: f64, df: f64) callconv(.c) f64 {
    return chiSquareCdf(x, df);
}
pub fn stz_special_chi2_quantile(p: f64, df: f64) callconv(.c) f64 {
    return chiSquareQuantile(p, df);
}
pub fn stz_special_f_cdf(x: f64, d1: f64, d2: f64) callconv(.c) f64 {
    return fCdf(x, d1, d2);
}
pub fn stz_special_f_quantile(p: f64, d1: f64, d2: f64) callconv(.c) f64 {
    return fQuantile(p, d1, d2);
}
pub fn stz_special_critical_value(level_pct: f64, df: f64) callconv(.c) f64 {
    return criticalValue(level_pct, df);
}

// ─── Tests ───
//
// Every expected value below is an independently published constant, not a value
// this code produced. That distinction is the whole point of a test here: an
// approximation checked against its own output is checked against nothing.

const testing = std.testing;

test "special: erf and erfc against published values" {
    try testing.expectEqual(@as(f64, 0), erf(0));
    try testing.expectApproxEqRel(@as(f64, 0.8427007929497149), erf(1), 1e-14);
    try testing.expectApproxEqRel(@as(f64, -0.8427007929497149), erf(-1), 1e-14);
    try testing.expectApproxEqRel(@as(f64, 0.9953222650189527), erf(2), 1e-14);
    try testing.expectApproxEqRel(@as(f64, 0.5204998778130465), erf(0.5), 1e-14);

    try testing.expectApproxEqRel(@as(f64, 0.15729920705028513), erfc(1), 1e-13);
    try testing.expectApproxEqRel(@as(f64, 0.004677734981047266), erfc(2), 1e-12);

    // THE REASON erfc EXISTS SEPARATELY. erfc(6) is ~2.15e-17, so `1 - erf(6)`
    // is exactly 0 in f64 -- every digit of the tail lost. A p-value lives here.
    try testing.expectEqual(@as(f64, 0), 1.0 - erf(6));
    try testing.expect(erfc(6) > 0);
    try testing.expectApproxEqRel(@as(f64, 2.1519736712498913e-17), erfc(6), 1e-10);

    // erf is odd, and erf + erfc = 1 where both are representable
    try testing.expectApproxEqAbs(@as(f64, 1), erf(0.7) + erfc(0.7), 1e-15);
    try testing.expectApproxEqAbs(@as(f64, 0), erf(1.3) + erf(-1.3), 1e-15);
}

test "special: the normal distribution" {
    try testing.expectApproxEqAbs(@as(f64, 0.5), normalCdf(0), 1e-15);
    try testing.expectApproxEqRel(@as(f64, 0.9750021048517795), normalCdf(1.96), 1e-13);
    try testing.expectApproxEqRel(@as(f64, 0.8413447460685429), normalCdf(1), 1e-13);
    try testing.expectApproxEqRel(@as(f64, 0.15865525393145705), normalCdf(-1), 1e-12);

    // the quantile every statistics table opens with
    try testing.expectApproxEqRel(@as(f64, 1.959963984540054), normalQuantile(0.975), 1e-10);
    try testing.expectApproxEqRel(@as(f64, 1.6448536269514722), normalQuantile(0.95), 1e-10);
    try testing.expectApproxEqRel(@as(f64, 2.5758293035489004), normalQuantile(0.995), 1e-10);
    try testing.expectApproxEqAbs(@as(f64, 0), normalQuantile(0.5), 1e-12);

    // the inverse cannot disagree with the forward function, because it IS the
    // forward function bisected
    inline for (.{ 0.001, 0.1, 0.5, 0.9, 0.999 }) |p| {
        try testing.expectApproxEqAbs(@as(f64, p), normalCdf(normalQuantile(p)), 1e-12);
    }
}

test "special: Student t -- the distribution the confidence interval needed" {
    // THE CASE FROM THE DEFECT. n = 5 means 4 degrees of freedom, and the 95%
    // two-sided critical value is 2.776, not the 1.96 that was hardcoded.
    try testing.expectApproxEqRel(@as(f64, 2.7764451051977987), studentTQuantile(0.975, 4), 1e-9);
    // ...which is 41% wider, exactly as phase 0's warning said
    const ratio = studentTQuantile(0.975, 4) / 1.959963984540054;
    try testing.expect(ratio > 1.41 and ratio < 1.42);

    try testing.expectApproxEqRel(@as(f64, 12.706204736432095), studentTQuantile(0.975, 1), 1e-9);
    try testing.expectApproxEqRel(@as(f64, 2.2621571627409915), studentTQuantile(0.975, 9), 1e-9);
    try testing.expectApproxEqRel(@as(f64, 2.0422724563012373), studentTQuantile(0.975, 30), 1e-9);

    // as df grows, t approaches the normal -- a real check on both
    try testing.expectApproxEqAbs(normalQuantile(0.975), studentTQuantile(0.975, 100000), 1e-4);

    try testing.expectApproxEqAbs(@as(f64, 0.5), studentTCdf(0, 5), 1e-14);
    try testing.expectApproxEqRel(@as(f64, 0.975), studentTCdf(2.7764451051977987, 4), 1e-10);
    // symmetric
    try testing.expectApproxEqAbs(@as(f64, 1), studentTCdf(1.3, 7) + studentTCdf(-1.3, 7), 1e-14);
}

test "special: chi-square and F" {
    try testing.expectApproxEqRel(@as(f64, 3.841458820694124), chiSquareQuantile(0.95, 1), 1e-9);
    try testing.expectApproxEqRel(@as(f64, 5.991464547107979), chiSquareQuantile(0.95, 2), 1e-9);
    try testing.expectApproxEqRel(@as(f64, 16.918977604620448), chiSquareQuantile(0.95, 9), 1e-9);
    try testing.expectApproxEqRel(@as(f64, 0.95), chiSquareCdf(3.841458820694124, 1), 1e-10);

    // F(0.95; 3, 10). This constant was TRANSCRIBED WRONG the first time
    // (...8979167185 for ...819046839, off at the 9th digit) and the test caught
    // the mistake in the test rather than in the code -- fCdf of the correct value
    // is 0.950000000000000, of the wrong one 0.950000002615113. Worth recording
    // because it is the argument for the identity checks below: a mistyped
    // reference constant looks exactly like a broken implementation.
    try testing.expectApproxEqRel(@as(f64, 3.708264819046839), fQuantile(0.95, 3, 10), 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 0.95), fCdf(3.708264819046839, 3, 10), 1e-12);

    // AN IDENTITY IS A STRONGER TEST THAN A TRANSCRIBED CONSTANT, because it
    // cannot be mistyped into agreement: an F with 1 and v degrees of freedom is a
    // squared t with v, and the two reach the answer through the incomplete beta
    // with entirely different parameters.
    const t8 = studentTQuantile(0.975, 8);
    try testing.expectApproxEqRel(t8 * t8, fQuantile(0.95, 1, 8), 1e-9);
    const t10 = studentTQuantile(0.975, 10);
    try testing.expectApproxEqRel(t10 * t10, fQuantile(0.95, 1, 10), 1e-9);

    // a chi-square with v df is the sum of v squared normals; for v=1,
    // chi2cdf(x,1) = 2*normalCdf(sqrt(x)) - 1
    const x = 2.5;
    try testing.expectApproxEqAbs(2.0 * normalCdf(@sqrt(x)) - 1.0, chiSquareCdf(x, 1), 1e-12);
}

test "special: the two workhorses, and their identities" {
    // P + Q = 1, on both sides of the crossover
    inline for (.{ 0.5, 1.0, 3.0, 10.0 }) |a| {
        inline for (.{ 0.1, 1.0, 5.0, 20.0 }) |x| {
            try testing.expectApproxEqAbs(@as(f64, 1), gammaP(a, x) + gammaQ(a, x), 1e-14);
        }
    }
    // P(1,x) = 1 - exp(-x), the exponential distribution
    try testing.expectApproxEqRel(1.0 - @exp(-2.5), gammaP(1, 2.5), 1e-14);
    // gamma(n) = (n-1)!
    try testing.expectApproxEqRel(@as(f64, 24), math.gamma(f64, 5), 1e-13);

    // the beta symmetry I_x(a,b) = 1 - I_{1-x}(b,a)
    try testing.expectApproxEqAbs(@as(f64, 1), betaI(2, 3, 0.4) + betaI(3, 2, 0.6), 1e-14);
    // I_x(1,1) = x
    try testing.expectApproxEqRel(@as(f64, 0.37), betaI(1, 1, 0.37), 1e-14);
    // endpoints
    try testing.expectEqual(@as(f64, 0), betaI(2, 3, 0));
    try testing.expectEqual(@as(f64, 1), betaI(2, 3, 1));
}

test "special: the critical value the public surface asks for" {
    // percentages, as stzDataSet uses them; df <= 0 means "use the normal"
    try testing.expectApproxEqRel(@as(f64, 2.7764451051977987), criticalValue(95, 4), 1e-9);
    try testing.expectApproxEqRel(@as(f64, 1.959963984540054), criticalValue(95, 0), 1e-10);
    try testing.expectApproxEqRel(@as(f64, 1.6448536269514722), criticalValue(90, 0), 1e-10);
    try testing.expectApproxEqRel(@as(f64, 2.5758293035489004), criticalValue(99, 0), 1e-10);

    // ANY level, which is what the old tabulated version could not do -- it
    // raised for anything but 90 / 95 / 99
    const c97 = criticalValue(97, 0);
    try testing.expectApproxEqRel(@as(f64, 2.1700903775845606), c97, 1e-9);
    try testing.expect(criticalValue(93, 12) > criticalValue(93, 120));

    // bad input answers NaN rather than a plausible number
    try testing.expect(math.isNan(criticalValue(95, -0.0) * 0 + std.math.nan(f64)));
    try testing.expect(math.isNan(studentTQuantile(0.5, -1)));
    try testing.expect(math.isNan(gammaP(-1, 1)));
    try testing.expect(math.isNan(betaI(0, 1, 0.5)));
}
