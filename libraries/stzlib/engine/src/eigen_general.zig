//! Eigenvalues of a GENERAL (non-symmetric) real matrix.
//!
//! PHASE 7. This lifts a refusal phase 4 slice 8 wrote down deliberately: symmetric
//! eigenvalues were built with cyclic Jacobi, and a non-symmetric matrix was REFUSED
//! rather than silently handed the eigenvalues of (A + A')/2. That was the right
//! call -- those belong to a different matrix -- and the honest way to remove the
//! refusal is to implement what it was refusing.
//!
//! WHY IT NEEDS COMPLEX NUMBERS. A real symmetric matrix has real eigenvalues; a
//! general real one does not. `[[0,-1],[1,0]]` -- a quarter turn -- has eigenvalues
//! ±i, and no amount of care produces a real answer, because a rotation genuinely
//! has no real eigendirection. Complex eigenvalues of a real matrix always arrive in
//! conjugate pairs, which is what makes the 2x2 blocks below readable.
//!
//! THE ALGORITHM, in three steps, and each is standard:
//!
//!   1. BALANCE. A diagonal similarity that evens out the row and column norms.
//!      Purely optional for correctness and significant for accuracy: without it a
//!      matrix whose entries differ by many orders of magnitude loses digits it did
//!      not have to. The transform is a similarity, so the eigenvalues are unchanged
//!      exactly -- and it uses powers of the RADIX so the scaling is exact in binary.
//!   2. HESSENBERG. Householder reflections make everything below the first
//!      subdiagonal zero. QR iteration on a full matrix costs O(n^3) per sweep; on a
//!      Hessenberg matrix it costs O(n^2), and Hessenberg form is preserved by the
//!      iteration. This is the step that makes the whole thing practical.
//!   3. FRANCIS DOUBLE-SHIFT QR. Iterate until a subdiagonal entry is negligible,
//!      then deflate. A 1x1 block on the diagonal is a real eigenvalue; a 2x2 block
//!      that will not split is a complex conjugate pair, read off directly from its
//!      trace and determinant. The DOUBLE shift is what lets a real arithmetic
//!      implementation find complex pairs at all: shifting by a complex number would
//!      require complex arithmetic throughout, but shifting by a conjugate PAIR is
//!      an equivalent real operation.
//!
//! WHAT IS NOT HERE: eigenVECTORS of a general matrix. They need either inverse
//! iteration or a back-substitution on the full Schur form, they are far more
//! delicate near a repeated eigenvalue, and nothing has asked for them. The Ring
//! side refuses them by name rather than returning the symmetric routine's answer.

const std = @import("std");
const Complex = @import("complex.zig").Complex;

const RADIX: f64 = 2.0;

/// Diagonal similarity balancing (Parlett & Reinsch). Scales rows and columns by
/// powers of the radix so their norms are comparable, without changing any
/// eigenvalue -- exactly, because a power of two is exact in binary floating point.
fn balance(a: []f64, n: usize) void {
    var done = false;
    while (!done) {
        done = true;
        var i: usize = 0;
        while (i < n) : (i += 1) {
            var r: f64 = 0; // row norm, off-diagonal
            var c: f64 = 0; // column norm, off-diagonal
            var j: usize = 0;
            while (j < n) : (j += 1) {
                if (j != i) {
                    r += @abs(a[i * n + j]);
                    c += @abs(a[j * n + i]);
                }
            }
            if (r == 0 or c == 0) continue;

            var g = r / RADIX;
            var f: f64 = 1;
            const s = c + r;
            while (c < g) {
                f *= RADIX;
                c *= RADIX * RADIX;
            }
            g = r * RADIX;
            while (c > g) {
                f /= RADIX;
                c /= RADIX * RADIX;
            }
            if ((c + r) / f < 0.95 * s) {
                done = false;
                const gi = 1 / f;
                j = 0;
                while (j < n) : (j += 1) a[i * n + j] *= gi;
                j = 0;
                while (j < n) : (j += 1) a[j * n + i] *= f;
            }
        }
    }
}

/// Reduce to upper Hessenberg by Householder-style elimination with pivoting.
fn toHessenberg(a: []f64, n: usize) void {
    if (n < 3) return;
    var m: usize = 1;
    while (m < n - 1) : (m += 1) {
        var x: f64 = 0;
        var i = m;
        // pivot on the largest subdiagonal entry in this column
        var j: usize = m;
        while (j < n) : (j += 1) {
            if (@abs(a[j * n + (m - 1)]) > @abs(x)) {
                x = a[j * n + (m - 1)];
                i = j;
            }
        }
        if (i != m) {
            // swap rows i, m and columns i, m -- a similarity, so the spectrum holds
            j = m - 1;
            while (j < n) : (j += 1) {
                const t = a[i * n + j];
                a[i * n + j] = a[m * n + j];
                a[m * n + j] = t;
            }
            j = 0;
            while (j < n) : (j += 1) {
                const t = a[j * n + i];
                a[j * n + i] = a[j * n + m];
                a[j * n + m] = t;
            }
        }
        if (x != 0) {
            i = m + 1;
            while (i < n) : (i += 1) {
                var y = a[i * n + (m - 1)];
                if (y != 0) {
                    y /= x;
                    a[i * n + (m - 1)] = y;
                    j = m;
                    while (j < n) : (j += 1) a[i * n + j] -= y * a[m * n + j];
                    j = 0;
                    while (j < n) : (j += 1) a[j * n + m] += y * a[j * n + i];
                }
            }
        }
    }
    // clear the elimination multipliers left below the subdiagonal
    var r: usize = 2;
    while (r < n) : (r += 1) {
        var c: usize = 0;
        while (c + 1 < r) : (c += 1) a[r * n + c] = 0;
    }
}

pub const EigenError = error{DidNotConverge};

/// Eigenvalues of the n x n row-major matrix `a`, which is CONSUMED (overwritten).
/// Results are written to `out` in no particular order -- QR deflation finds them
/// from the bottom up, and imposing an order would be a lie about which is "first"
/// when several share a magnitude.
///
/// Francis double-shift QR on the Hessenberg form.
pub fn eigenvalues(a: []f64, n: usize, out: []Complex) EigenError!void {
    if (n == 0) return;
    if (n == 1) {
        out[0] = Complex.real(a[0]);
        return;
    }

    balance(a, n);
    toHessenberg(a, n);

    var anorm: f64 = 0;
    {
        var i: usize = 0;
        while (i < n) : (i += 1) {
            var j = if (i >= 1) i - 1 else 0;
            while (j < n) : (j += 1) anorm += @abs(a[i * n + j]);
        }
    }

    var nn: isize = @as(isize, @intCast(n)) - 1;
    var t: f64 = 0;
    while (nn >= 0) {
        var its: usize = 0;
        var l: isize = 0;
        while (true) {
            // look for a negligible subdiagonal element to deflate on
            l = nn;
            while (l >= 1) : (l -= 1) {
                const ll: usize = @intCast(l);
                const s = @abs(a[(ll - 1) * n + (ll - 1)]) + @abs(a[ll * n + ll]);
                const sc = if (s == 0) anorm else s;
                if (@abs(a[ll * n + (ll - 1)]) + sc == sc) {
                    a[ll * n + (ll - 1)] = 0;
                    break;
                }
            }
            if (l < 0) l = 0;

            const un: usize = @intCast(nn);
            var x = a[un * n + un];
            if (l == nn) {
                // a 1x1 block: a real eigenvalue
                out[un] = Complex.real(x + t);
                nn -= 1;
                break;
            }

            const un1 = un - 1;
            var y = a[un1 * n + un1];
            var w = a[un * n + un1] * a[un1 * n + un];
            if (l == nn - 1) {
                // a 2x2 block: either two reals or a conjugate pair
                const p = 0.5 * (y - x);
                const q = p * p + w;
                const z = @sqrt(@abs(q));
                x += t;
                if (q >= 0) {
                    const zz = p + (if (p >= 0) z else -z);
                    out[un1] = Complex.real(x + zz);
                    out[un] = if (zz != 0) Complex.real(x - w / zz) else Complex.real(x + zz);
                } else {
                    out[un1] = Complex.init(x + p, -z);
                    out[un] = Complex.init(x + p, z);
                }
                nn -= 2;
                break;
            }

            if (its == 30) return EigenError.DidNotConverge;
            if (its == 10 or its == 20) {
                // EXCEPTIONAL SHIFT. The ordinary shift can cycle on matrices with
                // a symmetry the iteration cannot break; kicking it with an ad hoc
                // shift is the standard escape, and the constants are the published
                // ones rather than anything derived.
                t += x;
                var i: usize = 0;
                while (i <= un) : (i += 1) a[i * n + i] -= x;
                const s = @abs(a[un * n + un1]) + @abs(a[un1 * n + (un - 2)]);
                y = 0.75 * s;
                x = y;
                w = -0.4375 * s * s;
            }
            its += 1;

            // form the double-shift bulge
            var m: isize = nn - 2;
            var p: f64 = 0;
            var q: f64 = 0;
            var r: f64 = 0;
            while (m >= l) : (m -= 1) {
                const um: usize = @intCast(m);
                const z = a[um * n + um];
                const rr = x - z;
                const ss = y - z;
                p = (rr * ss - w) / a[(um + 1) * n + um] + a[um * n + (um + 1)];
                q = a[(um + 1) * n + (um + 1)] - z - rr - ss;
                r = a[(um + 2) * n + (um + 1)];
                const sc = @abs(p) + @abs(q) + @abs(r);
                p /= sc;
                q /= sc;
                r /= sc;
                if (m == l) break;
                const u = @abs(a[um * n + (um - 1)]) * (@abs(q) + @abs(r));
                const v = @abs(p) * (@abs(a[(um - 1) * n + (um - 1)]) +
                    @abs(z) + @abs(a[(um + 1) * n + (um + 1)]));
                if (u + v == v) break;
            }
            if (m < l) m = l;

            {
                var i: isize = m + 2;
                while (i <= nn) : (i += 1) {
                    const ui: usize = @intCast(i);
                    a[ui * n + (ui - 2)] = 0;
                    if (i != m + 2) a[ui * n + (ui - 3)] = 0;
                }
            }

            // chase the bulge down the subdiagonal
            var k: isize = m;
            while (k <= nn - 1) : (k += 1) {
                const uk: usize = @intCast(k);
                if (k != m) {
                    p = a[uk * n + (uk - 1)];
                    q = a[(uk + 1) * n + (uk - 1)];
                    r = if (k != nn - 1) a[(uk + 2) * n + (uk - 1)] else 0;
                    x = @abs(p) + @abs(q) + @abs(r);
                    if (x != 0) {
                        p /= x;
                        q /= x;
                        r /= x;
                    }
                }
                if (x == 0 and k != m) continue;
                var s = @sqrt(p * p + q * q + r * r);
                if (p < 0) s = -s;
                if (s == 0) continue;
                if (k == m) {
                    if (l != m) a[uk * n + (uk - 1)] = -a[uk * n + (uk - 1)];
                } else {
                    a[uk * n + (uk - 1)] = -s * x;
                }
                p += s;
                const px = p / s;
                const py = q / s;
                const pz = r / s;
                q /= p;
                r /= p;

                var j: usize = uk;
                while (j <= @as(usize, @intCast(nn))) : (j += 1) {
                    var pp = a[uk * n + j] + q * a[(uk + 1) * n + j];
                    if (k != nn - 1) {
                        pp += r * a[(uk + 2) * n + j];
                        a[(uk + 2) * n + j] -= pp * pz;
                    }
                    a[(uk + 1) * n + j] -= pp * py;
                    a[uk * n + j] -= pp * px;
                }
                const mmin: usize = if (nn < @as(isize, @intCast(uk + 3)))
                    @intCast(nn)
                else
                    uk + 3;
                var i: usize = @intCast(l);
                while (i <= mmin) : (i += 1) {
                    var pp = px * a[i * n + uk] + py * a[i * n + (uk + 1)];
                    if (k != nn - 1) {
                        pp += pz * a[i * n + (uk + 2)];
                        a[i * n + (uk + 2)] -= pp * r;
                    }
                    a[i * n + (uk + 1)] -= pp * q;
                    a[i * n + uk] -= pp;
                }
            }
        }
    }
}

// ─── tests ───────────────────────────────────────────────────────────────────

const testing = std.testing;

fn hasEigen(out: []const Complex, re: f64, im: f64, tol: f64) bool {
    for (out) |z| {
        if (@abs(z.re - re) < tol and @abs(z.im - im) < tol) return true;
    }
    return false;
}

test "a diagonal matrix gives back its diagonal" {
    var a = [_]f64{ 3, 0, 0, 0, -1, 0, 0, 0, 7 };
    var out: [3]Complex = undefined;
    try eigenvalues(&a, 3, &out);
    try testing.expect(hasEigen(&out, 3, 0, 1e-9));
    try testing.expect(hasEigen(&out, -1, 0, 1e-9));
    try testing.expect(hasEigen(&out, 7, 0, 1e-9));
}

test "a rotation has eigenvalues +i and -i -- the case that needs complex" {
    // a quarter turn has NO real eigendirection, which is why the symmetric
    // routine could not be stretched to cover this
    var a = [_]f64{ 0, -1, 1, 0 };
    var out: [2]Complex = undefined;
    try eigenvalues(&a, 2, &out);
    try testing.expect(hasEigen(&out, 0, 1, 1e-12));
    try testing.expect(hasEigen(&out, 0, -1, 1e-12));
}

test "a non-symmetric matrix with real eigenvalues" {
    // upper triangular: the eigenvalues are the diagonal
    var a = [_]f64{ 1, 2, 3, 0, 4, 5, 0, 0, 6 };
    var out: [3]Complex = undefined;
    try eigenvalues(&a, 3, &out);
    try testing.expect(hasEigen(&out, 1, 0, 1e-9));
    try testing.expect(hasEigen(&out, 4, 0, 1e-9));
    try testing.expect(hasEigen(&out, 6, 0, 1e-9));
}

test "a companion matrix finds polynomial roots" {
    // x^3 - 6x^2 + 11x - 6 = (x-1)(x-2)(x-3)
    var a = [_]f64{ 6, -11, 6, 1, 0, 0, 0, 1, 0 };
    var out: [3]Complex = undefined;
    try eigenvalues(&a, 3, &out);
    try testing.expect(hasEigen(&out, 1, 0, 1e-7));
    try testing.expect(hasEigen(&out, 2, 0, 1e-7));
    try testing.expect(hasEigen(&out, 3, 0, 1e-7));
}

test "trace and determinant are preserved, which is the invariant check" {
    // the sum of the eigenvalues is the trace and their product is the determinant,
    // whatever the eigenvalues turn out to be -- a check that does not need the
    // answer known in advance
    var a = [_]f64{ 4, 1, -2, 3, 0, 5, 1, -1, 2 };
    const trace = a[0] + a[4] + a[8];
    var out: [3]Complex = undefined;
    try eigenvalues(&a, 3, &out);
    var sum: f64 = 0;
    var prod = Complex.real(1);
    for (out) |z| {
        sum += z.re;
        prod = Complex.mul(prod, z);
    }
    try testing.expectApproxEqAbs(trace, sum, 1e-9);
    // det of the original: 4(0*2 - 5*(-1)) - 1(3*2 - 5*1) + (-2)(3*(-1) - 0*1)
    //                     = 4*5 - 1*1 - 2*(-3) = 20 - 1 + 6 = 25
    try testing.expectApproxEqAbs(@as(f64, 25), prod.re, 1e-8);
    try testing.expectApproxEqAbs(@as(f64, 0), prod.im, 1e-8);
}

test "complex eigenvalues arrive in conjugate pairs" {
    var a = [_]f64{ 1, -2, 3, 4, 5, -6, 7, 8, 9 };
    var out: [3]Complex = undefined;
    try eigenvalues(&a, 3, &out);
    var n_complex: usize = 0;
    var im_sum: f64 = 0;
    for (out) |z| {
        if (@abs(z.im) > 1e-9) n_complex += 1;
        im_sum += z.im;
    }
    // a real matrix cannot have an odd number of genuinely complex eigenvalues,
    // and the imaginary parts must cancel
    try testing.expect(n_complex % 2 == 0);
    try testing.expectApproxEqAbs(@as(f64, 0), im_sum, 1e-9);
}

test "a symmetric matrix still gives real eigenvalues here" {
    // the general routine must agree with the symmetric one on symmetric input
    var a = [_]f64{ 2, 1, 1, 2 };
    var out: [2]Complex = undefined;
    try eigenvalues(&a, 2, &out);
    try testing.expect(hasEigen(&out, 3, 0, 1e-12));
    try testing.expect(hasEigen(&out, 1, 0, 1e-12));
    for (out) |z| try testing.expectApproxEqAbs(@as(f64, 0), z.im, 1e-14);
}

test "badly scaled entries -- what balancing is for" {
    var a = [_]f64{ 1, 1e10, 0, 1e-10, 1, 0, 0, 0, 2 };
    var out: [3]Complex = undefined;
    try eigenvalues(&a, 3, &out);
    // eigenvalues of the 2x2 block are 1 +- 1, so 0 and 2, plus the 2
    try testing.expect(hasEigen(&out, 0, 0, 1e-6));
    try testing.expect(hasEigen(&out, 2, 0, 1e-6));
}

test "one by one, and the trivially small cases" {
    var a1 = [_]f64{5};
    var o1: [1]Complex = undefined;
    try eigenvalues(&a1, 1, &o1);
    try testing.expectEqual(@as(f64, 5), o1[0].re);

    var a2 = [_]f64{ 1, 0, 0, 2 };
    var o2: [2]Complex = undefined;
    try eigenvalues(&a2, 2, &o2);
    try testing.expect(hasEigen(&o2, 1, 0, 1e-12));
    try testing.expect(hasEigen(&o2, 2, 0, 1e-12));
}
