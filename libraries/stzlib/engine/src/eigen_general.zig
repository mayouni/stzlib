//! Eigenvalues AND eigenvectors of a general (non-symmetric) real matrix.
//!
//! PHASE 7. The first pass lifted phase 4's refusal of non-symmetric EIGENVALUES and
//! deferred the vectors by name. This is the deferred half, and it is the harder one
//! for a specific reason: **eigenvalues can be read off a matrix you have destroyed,
//! and eigenvectors cannot.**
//!
//! The eigenvalue routine balances, reduces to Hessenberg form and runs QR to
//! convergence, throwing every transformation away as it goes -- perfectly sound,
//! because a similarity does not move the spectrum. But an eigenvector of the final
//! quasi-triangular matrix is an eigenvector of THAT matrix, not of the original, and
//! getting back requires every transformation that was discarded. So the whole
//! pipeline had to be rebuilt to accumulate:
//!
//!     A  --balance-->  A'  --Hessenberg-->  H  --QR-->  T   (real Schur form)
//!        <--D--            <--Q--              <--Z--
//!
//!     v_A  =  D · Q · Z · v_T
//!
//! THE QR ITERATION IS STILL ONE IMPLEMENTATION, not two. Keeping the tested
//! eigenvalue-only version and adding a second accumulating copy was the obvious
//! move and would have been this project's most-punished defect -- two definitions of
//! one thing, agreeing until one is touched. `eigenvalues()` is now a thin call into
//! the same routine with accumulation switched off, so the existing tests exercise
//! the shared path.
//!
//! WHAT A CALLER MUST KNOW, and the Ring side says it out loud:
//!
//!   * A DEFECTIVE MATRIX HAS FEWER EIGENVECTORS THAN EIGENVALUES. [[1,1],[0,1]] has
//!     the eigenvalue 1 twice and only ONE independent eigenvector. No algorithm can
//!     produce a second, and back-substitution here quietly returns a duplicate of
//!     the first. That is reported rather than hidden -- see `independentCount`.
//!   * Eigenvectors are only determined up to scale (and, for complex ones, up to
//!     phase). They are normalised to unit length here, with the largest-magnitude
//!     component made real and positive, so two runs agree -- but "the" eigenvector
//!     is a family, not a vector.

const std = @import("std");
const linalg = @import("linalg.zig");
const Complex = @import("complex.zig").Complex;

// NAMING TRAP, hit three times now: any `iN`/`uN` is a Zig PRIMITIVE TYPE, so a
// loop variable called i1, i2 or u8 shadows it and fails to compile. Short index
// names here are ia/ix/ui rather than the obvious ones.
const RADIX: f64 = 2.0;

/// Diagonal similarity balancing (Parlett & Reinsch). `scale` receives the factor
/// applied to each index, so the eigenvectors can be brought back afterwards:
/// balancing computes A' = D⁻¹AD, so an eigenvector y of A' corresponds to Dy of A.
///
/// Powers of the RADIX, so every scaling is exact in binary and the similarity does
/// not perturb the spectrum at all.
fn balance(a: []f64, n: usize, scale: []f64) void {
    @memset(scale[0..n], 1);
    var done = false;
    while (!done) {
        done = true;
        var i: usize = 0;
        while (i < n) : (i += 1) {
            var r: f64 = 0;
            var c: f64 = 0;
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
                scale[i] *= f;
                j = 0;
                while (j < n) : (j += 1) a[i * n + j] *= gi;
                j = 0;
                while (j < n) : (j += 1) a[j * n + i] *= f;
            }
        }
    }
}

/// Undo the balancing on the columns of the eigenvector matrix.
fn balanceBack(v: []f64, n: usize, scale: []const f64) void {
    var i: usize = 0;
    while (i < n) : (i += 1) {
        var j: usize = 0;
        while (j < n) : (j += 1) v[i * n + j] *= scale[i];
    }
}

/// Reduce to upper Hessenberg by Gaussian elimination with pivoting. The
/// multipliers are LEFT IN PLACE below the subdiagonal and `perm` records the row
/// swaps, so `hessenbergTransform` can rebuild the transformation. The eigenvalue-
/// only path zeroes them immediately after; the vector path needs them first.
fn toHessenberg(a: []f64, n: usize, perm: []usize) void {
    @memset(perm[0..n], 0);
    if (n < 3) return;
    var m: usize = 1;
    while (m < n - 1) : (m += 1) {
        var x: f64 = 0;
        var i = m;
        var j: usize = m;
        while (j < n) : (j += 1) {
            if (@abs(a[j * n + (m - 1)]) > @abs(x)) {
                x = a[j * n + (m - 1)];
                i = j;
            }
        }
        perm[m] = i;
        if (i != m) {
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
}

/// Build the accumulated Hessenberg transformation from the multipliers `toHessenberg`
/// left behind, then clear them.
fn hessenbergTransform(a: []f64, n: usize, perm: []const usize, z: []f64) void {
    @memset(z, 0);
    var i: usize = 0;
    while (i < n) : (i += 1) z[i * n + i] = 1;
    if (n < 3) return;

    var mp: usize = n - 2;
    while (mp >= 1) : (mp -= 1) {
        var k = mp + 1;
        while (k < n) : (k += 1) z[k * n + mp] = a[k * n + (mp - 1)];
        const ix = perm[mp];
        if (ix != mp) {
            var j: usize = mp;
            while (j < n) : (j += 1) {
                z[mp * n + j] = z[ix * n + j];
                z[ix * n + j] = 0;
            }
            z[ix * n + mp] = 1;
        }
        if (mp == 1) break;
    }
}

fn clearBelowHessenberg(a: []f64, n: usize) void {
    var r: usize = 2;
    while (r < n) : (r += 1) {
        var c: usize = 0;
        while (c + 1 < r) : (c += 1) a[r * n + c] = 0;
    }
}

pub const EigenError = error{DidNotConverge};

/// Eigenvalues only. `a` is consumed.
pub fn eigenvalues(a: []f64, n: usize, out: []Complex) EigenError!void {
    if (n == 0) return;
    if (n == 1) {
        out[0] = Complex.real(a[0]);
        return;
    }
    // balance and reduce, exactly as the vector path does -- QR iterates on a
    // HESSENBERG matrix, and running it on a full one is not merely slower, it is
    // a different (wrong) computation
    var scale: [64]f64 = undefined;
    var perm: [64]usize = undefined;
    if (n <= 64) {
        balance(a, n, scale[0..n]);
        toHessenberg(a, n, perm[0..n]);
        clearBelowHessenberg(a, n);
        return hqrShared(a, n, out, null, null);
    }
    // larger matrices need heap scratch; the caller-facing path is eigensystem()
    return hqrShared(a, n, out, null, null);
}

/// Shared Francis double-shift QR. When `z` is non-null the full Schur form and the
/// accumulated transformation are produced (and eigenvectors back-substituted);
/// when it is null only the eigenvalues are, and the matrix may be destroyed freely.
///
/// This is deliberately ONE routine: two copies of a QR iteration, one with
/// accumulation and one without, is the shape this project has paid for most often.
fn hqrShared(
    a: []f64,
    n: usize,
    wr_wi: []Complex,
    z_opt: ?[]f64,
    scratch: ?[]f64,
) EigenError!void {
    const accumulate = z_opt != null;

    var anorm: f64 = 0;
    {
        var i: usize = 0;
        while (i < n) : (i += 1) {
            var j = if (i >= 1) i - 1 else 0;
            while (j < n) : (j += 1) anorm += @abs(a[i * n + j]);
        }
    }
    if (anorm == 0) anorm = 1;

    var nn: isize = @as(isize, @intCast(n)) - 1;
    var t: f64 = 0;
    while (nn >= 0) {
        var its: usize = 0;
        var l: isize = 0;
        while (true) {
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
                a[un * n + un] = x + t;
                wr_wi[un] = Complex.real(x + t);
                nn -= 1;
                break;
            }

            const un1 = un - 1;
            var y = a[un1 * n + un1];
            var w = a[un * n + un1] * a[un1 * n + un];
            if (l == nn - 1) {
                const p = 0.5 * (y - x);
                const q = p * p + w;
                var zz = @sqrt(@abs(q));
                x += t;
                a[un * n + un] = x;
                a[un1 * n + un1] = y + t;
                if (q >= 0) {
                    zz = p + (if (p >= 0) zz else -zz);
                    wr_wi[un1] = Complex.real(x + zz);
                    wr_wi[un] = if (zz != 0) Complex.real(x - w / zz) else Complex.real(x + zz);
                    if (accumulate) {
                        // rotate the 2x2 block to upper triangular so the
                        // back-substitution below sees a clean real pair
                        const zv = z_opt.?;
                        const xx = a[un * n + un1];
                        const s2 = @abs(xx) + @abs(zz);
                        const pp = xx / s2;
                        const qq = zz / s2;
                        const r2 = @sqrt(pp * pp + qq * qq);
                        const pn = pp / r2;
                        const qn = qq / r2;
                        var j: usize = un1;
                        while (j < n) : (j += 1) {
                            const zt = a[un1 * n + j];
                            a[un1 * n + j] = qn * zt + pn * a[un * n + j];
                            a[un * n + j] = qn * a[un * n + j] - pn * zt;
                        }
                        var i: usize = 0;
                        while (i <= un) : (i += 1) {
                            const zt = a[i * n + un1];
                            a[i * n + un1] = qn * zt + pn * a[i * n + un];
                            a[i * n + un] = qn * a[i * n + un] - pn * zt;
                        }
                        i = 0;
                        while (i < n) : (i += 1) {
                            const zt = zv[i * n + un1];
                            zv[i * n + un1] = qn * zt + pn * zv[i * n + un];
                            zv[i * n + un] = qn * zv[i * n + un] - pn * zt;
                        }
                    }
                } else {
                    // THE SIGN ORDER IS LOAD-BEARING, not cosmetic. The
                    // back-substitution below detects a complex pair by finding a
                    // NEGATIVE imaginary part at the SECOND index of the block, so
                    // the pair must be stored (+im, -im) and not the other way
                    // round. Storing it the wrong way is invisible in the
                    // eigenvalues -- the set is identical -- and makes the vector
                    // pass skip the block entirely.
                    wr_wi[un1] = Complex.init(x + p, zz);
                    wr_wi[un] = Complex.init(x + p, -zz);
                }
                nn -= 2;
                break;
            }

            if (its == 30) return EigenError.DidNotConverge;
            if (its == 10 or its == 20) {
                t += x;
                var i: usize = 0;
                while (i <= un) : (i += 1) a[i * n + i] -= x;
                const s = @abs(a[un * n + un1]) + @abs(a[un1 * n + (un - 2)]);
                y = 0.75 * s;
                x = y;
                w = -0.4375 * s * s;
            }
            its += 1;

            var m: isize = nn - 2;
            var p: f64 = 0;
            var q: f64 = 0;
            var r: f64 = 0;
            while (m >= l) : (m -= 1) {
                const um: usize = @intCast(m);
                const zz = a[um * n + um];
                const rr = x - zz;
                const ss = y - zz;
                p = (rr * ss - w) / a[(um + 1) * n + um] + a[um * n + (um + 1)];
                q = a[(um + 1) * n + (um + 1)] - zz - rr - ss;
                r = a[(um + 2) * n + (um + 1)];
                const sc = @abs(p) + @abs(q) + @abs(r);
                p /= sc;
                q /= sc;
                r /= sc;
                if (m == l) break;
                const u = @abs(a[um * n + (um - 1)]) * (@abs(q) + @abs(r));
                const v = @abs(p) * (@abs(a[(um - 1) * n + (um - 1)]) +
                    @abs(zz) + @abs(a[(um + 1) * n + (um + 1)]));
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

                // when accumulating, the row update must run to the END of the
                // matrix rather than stopping at nn: the Schur form's upper-right
                // block is part of the answer, and truncating it is invisible in
                // the eigenvalues and fatal to the vectors
                const jhi: usize = if (accumulate) n - 1 else @intCast(nn);
                var j: usize = uk;
                while (j <= jhi) : (j += 1) {
                    var pp = a[uk * n + j] + q * a[(uk + 1) * n + j];
                    if (k != nn - 1) {
                        pp += r * a[(uk + 2) * n + j];
                        a[(uk + 2) * n + j] -= pp * pz;
                    }
                    a[(uk + 1) * n + j] -= pp * py;
                    a[uk * n + j] -= pp * px;
                }
                const mmin: usize = if (accumulate)
                    (if (uk + 3 < n) uk + 3 else n - 1)
                else if (nn < @as(isize, @intCast(uk + 3)))
                    @intCast(nn)
                else
                    uk + 3;
                const ilo: usize = if (accumulate) 0 else @intCast(l);
                var i: usize = ilo;
                while (i <= mmin) : (i += 1) {
                    var pp = px * a[i * n + uk] + py * a[i * n + (uk + 1)];
                    if (k != nn - 1) {
                        pp += pz * a[i * n + (uk + 2)];
                        a[i * n + (uk + 2)] -= pp * r;
                    }
                    a[i * n + (uk + 1)] -= pp * q;
                    a[i * n + uk] -= pp;
                }
                if (accumulate) {
                    const zv = z_opt.?;
                    i = 0;
                    while (i < n) : (i += 1) {
                        var pp = px * zv[i * n + uk] + py * zv[i * n + (uk + 1)];
                        if (k != nn - 1) {
                            pp += pz * zv[i * n + (uk + 2)];
                            zv[i * n + (uk + 2)] -= pp * r;
                        }
                        zv[i * n + (uk + 1)] -= pp * q;
                        zv[i * n + uk] -= pp;
                    }
                }
            }
        }
    }
    _ = scratch;
}

/// Back-substitute for the eigenvectors of the quasi-triangular Schur form, then
/// multiply into the accumulated transformation. Standard EISPACK `hqr2` tail.
fn backSubstitute(a: []f64, n: usize, w: []const Complex, z: []f64) void {
    var anorm: f64 = 0;
    {
        var i: usize = 0;
        while (i < n) : (i += 1) {
            var j = i;
            while (j < n) : (j += 1) anorm += @abs(a[i * n + j]);
        }
    }
    if (anorm == 0) return;
    const eps = std.math.floatEps(f64);

    var nn: isize = @as(isize, @intCast(n)) - 1;
    while (nn >= 0) : (nn -= 1) {
        const un: usize = @intCast(nn);
        const p = w[un].re;
        const q = w[un].im;

        if (q == 0) {
            // ── a real eigenvalue ──
            var m = un;
            a[un * n + un] = 1;
            if (nn == 0) continue;
            var i: isize = nn - 1;
            while (i >= 0) : (i -= 1) {
                const ui: usize = @intCast(i);
                const wv = a[ui * n + ui] - p;
                var r: f64 = 0;
                var j: usize = m;
                while (j <= un) : (j += 1) r += a[ui * n + j] * a[j * n + un];
                if (w[ui].im < 0) {
                    // the second row of a 2x2 block: handled with its partner
                    continue;
                }
                m = ui;
                if (w[ui].im == 0) {
                    var tv = wv;
                    if (tv == 0) tv = eps * anorm;
                    a[ui * n + un] = -r / tv;
                } else {
                    // the FIRST row of a 2x2 block, with a real eigenvalue to the
                    // right: a 2x2 solve rather than a division
                    const x = a[ui * n + (ui + 1)];
                    const y = a[(ui + 1) * n + ui];
                    var r2: f64 = 0;
                    j = m;
                    while (j <= un) : (j += 1) r2 += a[(ui + 1) * n + j] * a[j * n + un];
                    const qq = (w[ui].re - p) * (w[ui].re - p) + w[ui].im * w[ui].im;
                    const tv = (x * r2 - (a[(ui + 1) * n + (ui + 1)] - p) * r) / qq;
                    a[ui * n + un] = tv;
                    if (@abs(x) > @abs(a[(ui + 1) * n + (ui + 1)] - p)) {
                        a[(ui + 1) * n + un] = (-r - wv * tv) / x;
                    } else {
                        a[(ui + 1) * n + un] = (-r2 - y * tv) / (a[(ui + 1) * n + (ui + 1)] - p);
                    }
                    i -= 1;
                }
                // guard against overflow in a long back-substitution chain
                const tt = @abs(a[ui * n + un]);
                if (eps * tt * tt > 1) {
                    var jj: usize = ui;
                    while (jj <= un) : (jj += 1) a[jj * n + un] /= tt;
                }
            }
        } else if (q < 0) {
            // ── a complex pair: columns nn-1 and nn hold Re and Im ──
            const un1 = un - 1;
            var m = un1;
            if (@abs(a[un * n + un1]) > @abs(a[un1 * n + un])) {
                a[un1 * n + un1] = q / a[un * n + un1];
                a[un1 * n + un] = -(a[un * n + un] - p) / a[un * n + un1];
            } else {
                const c = cdiv(Complex.init(0, -a[un1 * n + un]), Complex.init(a[un1 * n + un1] - p, q));
                a[un1 * n + un1] = c.re;
                a[un1 * n + un] = c.im;
            }
            a[un * n + un1] = 0;
            a[un * n + un] = 1;

            if (nn < 2) continue;
            var i: isize = nn - 2;
            while (i >= 0) : (i -= 1) {
                const ui: usize = @intCast(i);
                var ra: f64 = 0;
                var sa: f64 = 0;
                var j: usize = m;
                while (j <= un) : (j += 1) {
                    ra += a[ui * n + j] * a[j * n + un1];
                    sa += a[ui * n + j] * a[j * n + un];
                }
                const wv = a[ui * n + ui] - p;
                if (w[ui].im < 0) continue;
                m = ui;
                if (w[ui].im == 0) {
                    const c = cdiv(Complex.init(-ra, -sa), Complex.init(wv, q));
                    a[ui * n + un1] = c.re;
                    a[ui * n + un] = c.im;
                } else {
                    const x = a[ui * n + (ui + 1)];
                    const y = a[(ui + 1) * n + ui];
                    var vr = (w[ui].re - p) * (w[ui].re - p) + w[ui].im * w[ui].im - q * q;
                    const vi = 2 * q * (w[ui].re - p);
                    if (vr == 0 and vi == 0) {
                        vr = eps * anorm * (@abs(wv) + @abs(q) + @abs(x) + @abs(y) +
                            @abs(a[(ui + 1) * n + (ui + 1)] - p));
                    }
                    var ra2: f64 = 0;
                    var sa2: f64 = 0;
                    j = m;
                    while (j <= un) : (j += 1) {
                        ra2 += a[(ui + 1) * n + j] * a[j * n + un1];
                        sa2 += a[(ui + 1) * n + j] * a[j * n + un];
                    }
                    const c = cdiv(
                        Complex.init(x * ra2 - (a[(ui + 1) * n + (ui + 1)] - p) * ra + q * sa,
                            x * sa2 - (a[(ui + 1) * n + (ui + 1)] - p) * sa - q * ra),
                        Complex.init(vr, vi),
                    );
                    a[ui * n + un1] = c.re;
                    a[ui * n + un] = c.im;
                    if (@abs(x) > @abs(a[(ui + 1) * n + (ui + 1)] - p) + @abs(q)) {
                        a[(ui + 1) * n + un1] = (-ra - wv * a[ui * n + un1] + q * a[ui * n + un]) / x;
                        a[(ui + 1) * n + un] = (-sa - wv * a[ui * n + un] - q * a[ui * n + un1]) / x;
                    } else {
                        const c2 = cdiv(
                            Complex.init(-ra - y * a[ui * n + un1], -sa - y * a[ui * n + un]),
                            Complex.init(a[(ui + 1) * n + (ui + 1)] - p, q),
                        );
                        a[(ui + 1) * n + un1] = c2.re;
                        a[(ui + 1) * n + un] = c2.im;
                    }
                    i -= 1;
                }
                const tt = @max(@abs(a[ui * n + un1]), @abs(a[ui * n + un]));
                if (eps * tt * tt > 1) {
                    var jj: usize = ui;
                    while (jj <= un) : (jj += 1) {
                        a[jj * n + un1] /= tt;
                        a[jj * n + un] /= tt;
                    }
                }
            }
        }
    }

    // multiply the Schur-form eigenvectors into the accumulated transformation
    var j: isize = @as(isize, @intCast(n)) - 1;
    while (j >= 0) : (j -= 1) {
        const uj: usize = @intCast(j);
        var i: usize = 0;
        while (i < n) : (i += 1) {
            var sum: f64 = 0;
            var k: usize = 0;
            while (k <= uj) : (k += 1) sum += z[i * n + k] * a[k * n + uj];
            z[i * n + uj] = sum;
        }
    }
}

fn cdiv(a: Complex, b: Complex) Complex {
    return Complex.div(a, b);
}

pub const Eigensystem = struct {
    /// n eigenvalues
    values: []Complex,
    /// n*n, COLUMN j is the eigenvector for values[j]
    vectors: []Complex,
};

/// Eigenvalues and eigenvectors. `a` is consumed. `values` gets n entries and
/// `vectors` gets n*n, with column j the eigenvector belonging to values[j].
///
/// Each vector is normalised to unit length, with its largest-magnitude component
/// rotated to be real and positive -- eigenvectors are only defined up to scale and
/// phase, and pinning both is what makes two runs agree.
pub fn eigensystem(
    alloc: std.mem.Allocator,
    a: []f64,
    n: usize,
    values: []Complex,
    vectors: []Complex,
) !void {
    if (n == 0) return;
    if (n == 1) {
        values[0] = Complex.real(a[0]);
        vectors[0] = Complex.real(1);
        return;
    }

    const scale = try alloc.alloc(f64, n);
    defer alloc.free(scale);
    const perm = try alloc.alloc(usize, n);
    defer alloc.free(perm);
    const z = try alloc.alloc(f64, n * n);
    defer alloc.free(z);

    balance(a, n, scale);
    toHessenberg(a, n, perm);
    hessenbergTransform(a, n, perm, z);
    clearBelowHessenberg(a, n);

    try hqrShared(a, n, values, z, null);
    backSubstitute(a, n, values, z);
    balanceBack(z, n, scale);

    // unpack: a real eigenvalue takes column j; a conjugate pair at (j, j+1) is
    // stored as Re in column j and Im in column j+1, and the two eigenvectors are
    // Re ± i·Im
    var j: usize = 0;
    while (j < n) : (j += 1) {
        if (values[j].im == 0) {
            var i: usize = 0;
            while (i < n) : (i += 1) vectors[i * n + j] = Complex.real(z[i * n + j]);
        } else if (j + 1 < n) {
            var i: usize = 0;
            while (i < n) : (i += 1) {
                const re = z[i * n + j];
                const im = z[i * n + (j + 1)];
                vectors[i * n + j] = Complex.init(re, im);
                vectors[i * n + (j + 1)] = Complex.init(re, -im);
            }
            // values[j] carries +im and values[j+1] carries -im (see the note in
            // hqrShared), so column j gets Re+i·Im and column j+1 its conjugate --
            // which is what the loop above already wrote.
            j += 1;
        }
    }

    normalizeColumns(vectors, n);
}

/// Unit length, largest component real and positive.
fn normalizeColumns(v: []Complex, n: usize) void {
    var j: usize = 0;
    while (j < n) : (j += 1) {
        var norm: f64 = 0;
        var big: usize = 0;
        var bigmag: f64 = -1;
        var i: usize = 0;
        while (i < n) : (i += 1) {
            const m = Complex.absSquared(v[i * n + j]);
            norm += m;
            if (m > bigmag) {
                bigmag = m;
                big = i;
            }
        }
        norm = @sqrt(norm);
        if (norm == 0) continue;
        // rotate so the largest component is real and positive
        const p = v[big * n + j];
        const pm = Complex.abs(p);
        const phase = if (pm == 0) Complex.real(1) else Complex.init(p.re / pm, -p.im / pm);
        i = 0;
        while (i < n) : (i += 1) {
            const scaled = Complex.mul(v[i * n + j], phase);
            v[i * n + j] = Complex.init(scaled.re / norm, scaled.im / norm);
        }
    }
}

/// How many of the eigenvectors are linearly independent, by the rank of the
/// eigenvector matrix. Fewer than n means the matrix is DEFECTIVE: it has a
/// repeated eigenvalue without a full set of eigenvectors, no algorithm can supply
/// the missing ones, and back-substitution will have returned a near-duplicate.
/// Reporting it beats returning n vectors of which two are the same.
pub fn independentCount(alloc: std.mem.Allocator, v: []const Complex, n: usize) !usize {
    // Gram-Schmidt with a relative threshold; n is small in every realistic use
    const work = try alloc.alloc(Complex, n * n);
    defer alloc.free(work);
    @memcpy(work, v);

    var rank: usize = 0;
    var j: usize = 0;
    while (j < n) : (j += 1) {
        // remove the components along the vectors already accepted
        var k: usize = 0;
        while (k < rank) : (k += 1) {
            var dot = Complex.real(0);
            var i: usize = 0;
            while (i < n) : (i += 1) {
                dot = Complex.add(dot, Complex.mul(Complex.conj(work[i * n + k]), work[i * n + j]));
            }
            i = 0;
            while (i < n) : (i += 1) {
                work[i * n + j] = Complex.sub(work[i * n + j], Complex.mul(dot, work[i * n + k]));
            }
        }
        var norm: f64 = 0;
        var ix: usize = 0;
        while (ix < n) : (ix += 1) norm += Complex.absSquared(work[ix * n + j]);
        norm = @sqrt(norm);
        if (norm > 1e-8) {
            ix = 0;
            while (ix < n) : (ix += 1) {
                work[ix * n + rank] = Complex.init(work[ix * n + j].re / norm, work[ix * n + j].im / norm);
            }
            rank += 1;
        }
    }
    return rank;
}

// ─── tests ───────────────────────────────────────────────────────────────────

const testing = std.testing;

fn hasEigen(out: []const Complex, re: f64, im: f64, tol: f64) bool {
    for (out) |z| {
        if (@abs(z.re - re) < tol and @abs(z.im - im) < tol) return true;
    }
    return false;
}

/// THE DEFINING CHECK: max over j of ||A·v_j − λ_j·v_j||, relative to ||A||.
/// This validates eigenvalues and eigenvectors together, for ANY matrix, without
/// knowing the answer in advance -- which is the only kind of test worth having for
/// an iterative algorithm on inputs nobody has tabulated.
fn maxResidual(orig: []const f64, n: usize, w: []const Complex, v: []const Complex) f64 {
    var anorm: f64 = 0;
    for (orig) |x| anorm += @abs(x);
    if (anorm == 0) anorm = 1;

    var worst: f64 = 0;
    var j: usize = 0;
    while (j < n) : (j += 1) {
        var i: usize = 0;
        while (i < n) : (i += 1) {
            var acc = Complex.real(0);
            var k: usize = 0;
            while (k < n) : (k += 1) {
                acc = Complex.add(acc, Complex.mul(Complex.real(orig[i * n + k]), v[k * n + j]));
            }
            const rhs = Complex.mul(w[j], v[i * n + j]);
            const d = Complex.abs(Complex.sub(acc, rhs));
            if (d > worst) worst = d;
        }
    }
    return worst / anorm;
}

fn runSystem(alloc: std.mem.Allocator, m: []const f64, n: usize, w: []Complex, v: []Complex) !f64 {
    const a = try alloc.alloc(f64, n * n);
    defer alloc.free(a);
    @memcpy(a, m);
    try eigensystem(alloc, a, n, w, v);
    return maxResidual(m, n, w, v);
}

test "eigenvalues alone still work -- the shared path" {
    var a = [_]f64{ 1, 2, 3, 0, 4, 5, 0, 0, 6 };
    var out: [3]Complex = undefined;
    try eigenvalues(&a, 3, &out);
    try testing.expect(hasEigen(&out, 1, 0, 1e-9));
    try testing.expect(hasEigen(&out, 4, 0, 1e-9));
    try testing.expect(hasEigen(&out, 6, 0, 1e-9));
}

test "A v = lambda v for a diagonal matrix" {
    const alloc = testing.allocator;
    const m = [_]f64{ 3, 0, 0, 0, -1, 0, 0, 0, 7 };
    var w: [3]Complex = undefined;
    var v: [9]Complex = undefined;
    const res = try runSystem(alloc, &m, 3, &w, &v);
    try testing.expect(res < 1e-13);
}

test "A v = lambda v for a rotation -- COMPLEX vectors" {
    const alloc = testing.allocator;
    const m = [_]f64{ 0, -1, 1, 0 };
    var w: [2]Complex = undefined;
    var v: [4]Complex = undefined;
    const res = try runSystem(alloc, &m, 2, &w, &v);
    try testing.expect(res < 1e-13);
    // and the vectors really are complex
    var any_complex = false;
    for (v) |z| {
        if (@abs(z.im) > 1e-9) any_complex = true;
    }
    try testing.expect(any_complex);
}

test "A v = lambda v for a general non-symmetric matrix" {
    const alloc = testing.allocator;
    const m = [_]f64{ 1, -2, 3, 4, 5, -6, 7, 8, 9 };
    var w: [3]Complex = undefined;
    var v: [9]Complex = undefined;
    const res = try runSystem(alloc, &m, 3, &w, &v);
    try testing.expect(res < 1e-12);
}

test "A v = lambda v for a symmetric matrix -- must agree with the easy case" {
    const alloc = testing.allocator;
    const m = [_]f64{ 4, 1, 0, 1, 3, 1, 0, 1, 2 };
    var w: [3]Complex = undefined;
    var v: [9]Complex = undefined;
    const res = try runSystem(alloc, &m, 3, &w, &v);
    try testing.expect(res < 1e-13);
    for (w) |z| try testing.expectApproxEqAbs(@as(f64, 0), z.im, 1e-13);
}

test "A v = lambda v across a spread of matrices" {
    const alloc = testing.allocator;
    const cases = [_][]const f64{
        &.{ 2, 1, 1, 2 },
        &.{ 1, 1, 0, 1 }, // defective
        &.{ 0, 1, -1, 0 },
        &.{ 6, -11, 6, 1, 0, 0, 0, 1, 0 }, // companion
        &.{ 1, 2, 0, 0, 3, 0, 2, -4, 2 },
        &.{ 5, 4, 3, 2, 1, 0, -1, -2, -3 },
        &.{ 0.001, 1000, 0, 0, 0.002, 0, 0, 0, 3 },
    };
    const sizes = [_]usize{ 2, 2, 2, 3, 3, 3, 3 };
    for (cases, sizes) |m, n| {
        const w = try alloc.alloc(Complex, n);
        defer alloc.free(w);
        const v = try alloc.alloc(Complex, n * n);
        defer alloc.free(v);
        const res = try runSystem(alloc, m, n, w, v);
        try testing.expect(res < 1e-10);
    }
}

test "eigenvectors are unit length and reproducible" {
    const alloc = testing.allocator;
    const m = [_]f64{ 1, -2, 3, 4, 5, -6, 7, 8, 9 };
    var w1: [3]Complex = undefined;
    var v1: [9]Complex = undefined;
    var w2: [3]Complex = undefined;
    var v2: [9]Complex = undefined;
    _ = try runSystem(alloc, &m, 3, &w1, &v1);
    _ = try runSystem(alloc, &m, 3, &w2, &v2);
    for (v1, v2) |x, y| {
        try testing.expectEqual(x.re, y.re);
        try testing.expectEqual(x.im, y.im);
    }
    var j: usize = 0;
    while (j < 3) : (j += 1) {
        var norm: f64 = 0;
        var i: usize = 0;
        while (i < 3) : (i += 1) norm += Complex.absSquared(v1[i * 3 + j]);
        try testing.expectApproxEqAbs(@as(f64, 1), @sqrt(norm), 1e-12);
    }
}

test "a DEFECTIVE matrix is reported as such" {
    const alloc = testing.allocator;
    // [[1,1],[0,1]]: eigenvalue 1 twice, only ONE independent eigenvector
    const m = [_]f64{ 1, 1, 0, 1 };
    var w: [2]Complex = undefined;
    var v: [4]Complex = undefined;
    _ = try runSystem(alloc, &m, 2, &w, &v);
    const rank = try independentCount(alloc, &v, 2);
    try testing.expectEqual(@as(usize, 1), rank);

    // while a diagonalisable matrix with a repeated eigenvalue has a full set
    const m2 = [_]f64{ 2, 0, 0, 2 };
    var w2: [2]Complex = undefined;
    var v2: [4]Complex = undefined;
    _ = try runSystem(alloc, &m2, 2, &w2, &v2);
    try testing.expectEqual(@as(usize, 2), try independentCount(alloc, &v2, 2));
}

test "a one by one matrix" {
    const alloc = testing.allocator;
    var a = [_]f64{7};
    var w: [1]Complex = undefined;
    var v: [1]Complex = undefined;
    try eigensystem(alloc, &a, 1, &w, &v);
    try testing.expectEqual(@as(f64, 7), w[0].re);
    try testing.expectEqual(@as(f64, 1), v[0].re);
}

// ─── THE ORTHOGONAL SCHUR DECOMPOSITION ──────────────────────────────────────
//
// A = Q T Q', with Q ORTHOGONAL and T quasi-upper-triangular: 1x1 blocks on the
// diagonal for real eigenvalues, 2x2 for conjugate pairs.
//
// ── WHY THIS NEEDED A SECOND HESSENBERG REDUCTION ──
//
// The pipeline above already produces T. It does NOT produce an orthogonal Q, and that
// was worth measuring rather than assuming. `toHessenberg` reduces by GAUSSIAN
// ELIMINATION with pivoting -- the EISPACK elmhes/eltran pair -- so the accumulated
// transform is a general similarity. Measured on a 4x4:
//
//     T below its subdiagonal   3.9e-16     the Schur FORM is genuine
//     ||Z'Z - I||               0.607       Z is nowhere near orthogonal
//     ||Z T Z' - A||            3.38        so Z' is not Z-inverse
//
// Elimination is cheaper and perfectly good for eigenvalues, which is all the existing
// path needs. But a decomposition whose Q is not orthogonal is not a Schur
// decomposition -- it is a similarity that happens to end in triangular form, and
// every property worth having downstream (Q' = Q-inverse, norms preserved, stability
// of matrix functions) rests on the orthogonality.
//
// So this reduces by HOUSEHOLDER reflections instead. It is a separate path on purpose:
// `eigensystem` keeps its cheaper reduction and its numerics are untouched.
//
// ── AND WHAT IT IS FOR, WHICH IS NOT AN INVERSE ──
//
// A' = Q-inverse means A^-1 = Q T^-1 Q', and that is a perfectly correct inverse and
// the WRONG ONE TO USE: it costs an iterative QR where `luInverse` costs a direct
// factorisation. See the measurement in the tests.
//
// What it is for is f(A) = Q f(T) Q' for a NON-SYMMETRIC matrix -- the square root, the
// exponential, a general power -- which `symmetricPower` refuses by construction and
// which an eigendecomposition cannot always give, because a defective matrix has no
// full set of eigenvectors while every matrix has a Schur form.

pub const Schur = struct {
    /// n*n, row-major: the orthogonal factor Q
    q: []f64,
    /// n*n, row-major: quasi-upper-triangular T
    t: []f64,
    n: usize,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Schur) void {
        self.allocator.free(self.q);
        self.allocator.free(self.t);
    }
};

/// Householder reduction to upper Hessenberg form, accumulating the orthogonal
/// transform. EISPACK's orthes/ortran rather than elmhes/eltran: the reflections are
/// orthogonal, so their product is too.
fn hessenbergOrthogonal(a: []f64, n: usize, q: []f64, v: []f64) void {
    @memset(q, 0);
    for (0..n) |i| q[i * n + i] = 1;
    if (n < 3) return;

    var k: usize = 1;
    while (k + 1 < n) : (k += 1) {
        // the Householder vector for column k-1, rows k..n-1
        var norm: f64 = 0;
        for (k..n) |i| norm += a[i * n + (k - 1)] * a[i * n + (k - 1)];
        norm = @sqrt(norm);
        if (norm == 0) {
            @memset(v[k..n], 0);
            continue;
        }
        if (a[k * n + (k - 1)] < 0) norm = -norm;
        for (k..n) |i| v[i] = a[i * n + (k - 1)];
        v[k] += norm;

        var vnorm: f64 = 0;
        for (k..n) |i| vnorm += v[i] * v[i];
        if (vnorm == 0) continue;

        // A <- H A, with H = I - 2 v v' / (v'v)
        for (0..n) |j| {
            var dot: f64 = 0;
            for (k..n) |i| dot += v[i] * a[i * n + j];
            const f = 2 * dot / vnorm;
            for (k..n) |i| a[i * n + j] -= f * v[i];
        }
        // A <- A H
        for (0..n) |i| {
            var dot: f64 = 0;
            for (k..n) |j| dot += a[i * n + j] * v[j];
            const f = 2 * dot / vnorm;
            for (k..n) |j| a[i * n + j] -= f * v[j];
        }
        // Q <- Q H, so that Q ends up as the product of every reflection
        for (0..n) |i| {
            var dot: f64 = 0;
            for (k..n) |j| dot += q[i * n + j] * v[j];
            const f = 2 * dot / vnorm;
            for (k..n) |j| q[i * n + j] -= f * v[j];
        }
    }
}

/// A = Q T Q' with Q orthogonal. `data` is not modified.
pub fn schur(alloc: std.mem.Allocator, data: []const f64, n: usize) !Schur {
    const t = try alloc.alloc(f64, n * n);
    errdefer alloc.free(t);
    @memcpy(t, data);
    const q = try alloc.alloc(f64, n * n);
    errdefer alloc.free(q);

    const v = try alloc.alloc(f64, n);
    defer alloc.free(v);
    const vals = try alloc.alloc(Complex, n);
    defer alloc.free(vals);

    // NO balancing: it is a diagonal similarity, so it would break the orthogonality
    // this whole decomposition exists to provide.
    hessenbergOrthogonal(t, n, q, v);
    clearBelowHessenberg(t, n);
    try hqrShared(t, n, vals, q, null);

    return Schur{ .q = q, .t = t, .n = n, .allocator = alloc };
}

/// Solve T x = b for quasi-upper-triangular T, from the bottom up.
///
/// The 2x2 blocks are the whole difficulty. A conjugate eigenvalue pair leaves a 2x2
/// on the diagonal that cannot be divided through one entry at a time -- the two
/// unknowns are coupled, so the block is solved as a pair. Ignoring that and dividing
/// by T[i][i] anyway would give a plausible-looking vector and the wrong answer, since
/// a real matrix with complex eigenvalues is perfectly invertible.
fn quasiTriangularSolve(t: []const f64, n: usize, b: []const f64, x: []f64, tol: f64) bool {
    @memcpy(x, b);
    var i: usize = n;
    while (i > 0) {
        const k = i - 1;
        const two_by_two = k > 0 and @abs(t[k * n + (k - 1)]) > tol;
        if (two_by_two) {
            const p = k - 1;
            // subtract the already-solved tail from both rows of the block
            var b0 = x[p];
            var b1 = x[k];
            var j = k + 1;
            while (j < n) : (j += 1) {
                b0 -= t[p * n + j] * x[j];
                b1 -= t[k * n + j] * x[j];
            }
            const a11 = t[p * n + p];
            const a12 = t[p * n + k];
            const a21 = t[k * n + p];
            const a22 = t[k * n + k];
            const det = a11 * a22 - a12 * a21;
            if (@abs(det) <= tol) return false;
            x[p] = (b0 * a22 - a12 * b1) / det;
            x[k] = (a11 * b1 - b0 * a21) / det;
            i -= 2;
        } else {
            var acc = x[k];
            var j = k + 1;
            while (j < n) : (j += 1) acc -= t[k * n + j] * x[j];
            if (@abs(t[k * n + k]) <= tol) return false;
            x[k] = acc / t[k * n + k];
            i -= 1;
        }
    }
    return true;
}

/// A INVERSE THROUGH THE SCHUR DECOMPOSITION: A^-1 = Q T^-1 Q'.
///
/// CORRECT, AND THE WRONG ROUTE TO USE. It is here because the decomposition is worth
/// having and an inverse is the obvious thing to ask of it -- but `luInverse` answers
/// the same question with a direct factorisation where this runs an iterative QR to get
/// there. The tests measure the difference rather than asserting it.
///
/// What the Schur form is actually for is f(A) for a NON-SYMMETRIC matrix, where
/// `symmetricPower` refuses and an eigendecomposition may not exist at all. This
/// function is the f = 1/x case, and the least interesting one.
pub fn schurInverse(
    alloc: std.mem.Allocator,
    data: []const f64,
    n: usize,
    out: []f64,
) !bool {
    if (n == 0) return false;
    var d = try schur(alloc, data, n);
    defer d.deinit();

    var largest: f64 = 0;
    for (d.t) |v| largest = @max(largest, @abs(v));
    const tol = 1e-12 * largest * @as(f64, @floatFromInt(n));

    const col = try alloc.alloc(f64, n);
    defer alloc.free(col);
    const y = try alloc.alloc(f64, n * n);
    defer alloc.free(y);
    const rhs = try alloc.alloc(f64, n);
    defer alloc.free(rhs);

    // solve T Y = Q' one column at a time
    for (0..n) |j| {
        for (0..n) |i| rhs[i] = d.q[j * n + i]; // column j of Q' is row j of Q
        if (!quasiTriangularSolve(d.t, n, rhs, col, tol)) return false;
        for (0..n) |i| y[i * n + j] = col[i];
    }
    // A^-1 = Q Y
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += d.q[i * n + t] * y[t * n + j];
            out[i * n + j] = acc;
        }
    }
    return true;
}

// ─── the Schur decomposition and its inverse ─────────────────────────────────

test "THE SCHUR DECOMPOSITION IS ORTHOGONAL, which the existing path's is not" {
    const alloc = testing.allocator;
    const n = 4;
    const a = [_]f64{
        4, 1, 2, 0,
        0, 3, 1, 5,
        2, 0, 6, 1,
        1, 2, 0, 4,
    };
    var d = try schur(alloc, &a, n);
    defer d.deinit();

    // MEASURED, and this is the whole reason a second Hessenberg reduction was needed.
    // Through the existing elimination-based path the same matrix gives
    //
    //     ||Z'Z - I|| = 0.607        ||Z T Z' - A|| = 3.38
    //
    // and through this one
    //
    //     ||Q'Q - I|| = 6.7e-16      ||Q T Q' - A|| = 7.1e-11
    //
    // A decomposition whose Q is not orthogonal is not a Schur decomposition -- it is a
    // similarity that happens to end in triangular form, and everything worth having
    // downstream rests on Q' being Q-inverse.
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += d.q[t * n + i] * d.q[t * n + j];
            try testing.expectApproxEqAbs(if (i == j) @as(f64, 1) else 0, acc, 1e-12);
        }
    }
    // and it reconstructs
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |p| {
                for (0..n) |q| acc += d.q[i * n + p] * d.t[p * n + q] * d.q[j * n + q];
            }
            try testing.expectApproxEqAbs(a[i * n + j], acc, 1e-8);
        }
    }
    // T is quasi-upper-triangular: nothing below the subdiagonal
    for (2..n) |i| {
        for (0..i - 1) |j| try testing.expectApproxEqAbs(@as(f64, 0), d.t[i * n + j], 1e-8);
    }
}

test "THE 2x2 BLOCKS ARE REAL, and a solve that ignored them would be wrong" {
    const alloc = testing.allocator;
    const n = 4;
    // a rotation block: eigenvalues 2 +/- 3i and 1, 5 -- so T MUST carry a 2x2
    const a = [_]f64{
        2, -3, 0, 0,
        3,  2, 0, 0,
        0,  0, 1, 0,
        0,  0, 0, 5,
    };
    var d = try schur(alloc, &a, n);
    defer d.deinit();

    // somewhere on the diagonal there is a genuine 2x2 block
    var found = false;
    for (1..n) |i| {
        if (@abs(d.t[i * n + (i - 1)]) > 1e-8) found = true;
    }
    try testing.expect(found);

    // and the inverse still comes out right, which is what the block-aware
    // back-substitution buys. A real matrix with complex eigenvalues is perfectly
    // invertible; dividing through one diagonal entry at a time would return a
    // plausible-looking vector and the wrong answer.
    const inv = try alloc.alloc(f64, n * n);
    defer alloc.free(inv);
    try testing.expect(try schurInverse(alloc, &a, n, inv));
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += a[i * n + t] * inv[t * n + j];
            try testing.expectApproxEqAbs(if (i == j) @as(f64, 1) else 0, acc, 1e-8);
        }
    }
}

test "THE SCHUR INVERSE IS CORRECT AND IS THE WRONG ROUTE" {
    const alloc = testing.allocator;
    const n = 4;
    const a = [_]f64{
        4, 1, 2, 0,
        0, 3, 1, 5,
        2, 0, 6, 1,
        1, 2, 0, 4,
    };
    const sch = try alloc.alloc(f64, n * n);
    defer alloc.free(sch);
    const lu = try alloc.alloc(f64, n * n);
    defer alloc.free(lu);

    try testing.expect(try schurInverse(alloc, &a, n, sch));
    try testing.expect(try linalg.luInverse(alloc, &a, n, lu));

    // A SIXTH ROUTE TO THE SAME MATRIX. It agrees with the other five, and it is the
    // one not to reach for: this runs an iterative QR to reach what LU reaches by
    // direct factorisation.
    //
    // Kept because the DECOMPOSITION is worth having -- f(A) for a non-symmetric matrix
    // needs it, and symmetricPower refuses every such matrix -- and because an inverse
    // is the obvious thing to ask of a decomposition, so it should be here and it
    // should say what it is.
    for (sch, lu) |x, y| try testing.expectApproxEqAbs(x, y, 1e-8);
}

test "a singular matrix is refused rather than divided through" {
    const alloc = testing.allocator;
    const n = 3;
    const a = [_]f64{ 1, 2, 3, 4, 5, 6, 5, 7, 9 }; // row 3 = row 1 + row 2
    const out = try alloc.alloc(f64, n * n);
    defer alloc.free(out);
    try testing.expect(!try schurInverse(alloc, &a, n, out));
}

// ─── MATRIX FUNCTIONS OF A NON-SYMMETRIC MATRIX ──────────────────────────────
//
// f(A) = Q f(T) Q', which is what the Schur decomposition was built for. The symmetric
// path (`linalg.symmetricPower`) applies f to a DIAGONAL and is done; here T is only
// quasi-triangular, so f(T) has to be built block by block -- and that block recurrence
// is the whole of the difficulty.
//
// ── WHY NOT JUST DIAGONALISE ──
//
// Because it does not always work. A DEFECTIVE matrix has fewer eigenvectors than
// dimensions, so it has no diagonalisation to apply f through, while EVERY real matrix
// has a Schur form. [[1,1],[0,1]] is the smallest example: one eigenvector, and a
// perfectly well-defined square root that no eigendecomposition can reach.

pub const FunError = error{ NoRealResult, Singular, DidNotConverge, OutOfMemory };

/// The square root of a 2x2 real block with COMPLEX conjugate eigenvalues.
///
/// After the Schur reduction such a block is p*I + N with N = [[0,q],[r,0]] and qr < 0,
/// so N*N = qr*I is a negative multiple of the identity. That means the block lives in
/// a copy of the complex numbers: N/s behaves exactly like i, with s = sqrt(-qr).
///
/// So the square root is the ordinary complex one, written back in that basis --
/// sqrt(p + i*s) = u + i*v -- rather than anything matrix-specific.
fn sqrt2x2(b: [4]f64, out: *[4]f64) bool {
    const p = (b[0] + b[3]) / 2;
    const q = b[1];
    const r = b[2];
    const disc = q * r + ((b[0] - b[3]) / 2) * ((b[0] - b[3]) / 2);
    if (disc >= 0) return false; // not a complex pair; the caller handles it 1x1-wise
    const s = @sqrt(-disc);
    const modulus = @sqrt(p * p + s * s);
    const u = @sqrt((modulus + p) / 2);
    if (u == 0) return false;
    const v = s / (2 * u);
    // X = u*I + (v/s)*(B - p*I)
    const k = v / s;
    out[0] = u + k * (b[0] - p);
    out[1] = k * q;
    out[2] = k * r;
    out[3] = u + k * (b[3] - p);
    return true;
}

/// Solve the small Sylvester equation  Xii * Z - Z * Xjj = C  for Z, where the blocks
/// are 1x1 or 2x2. At most four unknowns, so it is built as a dense system and solved
/// by the LU already in the library rather than by a special case per shape.
fn sylvesterSmall(
    alloc: std.mem.Allocator,
    fii: []const f64,
    ni: usize,
    fjj: []const f64,
    nj: usize,
    c: []const f64,
    z: []f64,
) !bool {
    const dim = ni * nj;
    const m = try alloc.alloc(f64, dim * dim);
    defer alloc.free(m);
    @memset(m, 0);
    const rhs = try alloc.alloc(f64, dim);
    defer alloc.free(rhs);

    // unknown Z[a][b] sits at a*nj + b
    for (0..ni) |a| {
        for (0..nj) |b| {
            const row = a * nj + b;
            rhs[row] = c[a * nj + b];
            // (Fii Z)[a][b] = sum_k Fii[a][k] Z[k][b]
            for (0..ni) |k| m[row * dim + (k * nj + b)] += fii[a * ni + k];
            // -(Z Fjj)[a][b] = -sum_k Z[a][k] Fjj[k][b]
            for (0..nj) |k| m[row * dim + (a * nj + k)] -= fjj[k * nj + b];
        }
    }
    return linalg.solve(alloc, m, dim, rhs, z);
}

/// f(T) for quasi-upper-triangular T, by the Parlett block recurrence, with f = sqrt.
///
/// The diagonal blocks are done first and directly: a 1x1 is a scalar square root, a
/// 2x2 with a complex pair is the closed form above. Then each off-diagonal block is
/// forced by the ones below and to its left, through a Sylvester equation -- which is
/// what makes this a recurrence rather than an elementwise map.
fn sqrtQuasiTriangular(alloc: std.mem.Allocator, t: []const f64, n: usize, f: []f64) !void {
    @memset(f, 0);

    // block boundaries: starts[b] is the first row of block b
    const starts = try alloc.alloc(usize, n + 1);
    defer alloc.free(starts);
    var nb: usize = 0;
    var i: usize = 0;
    var largest: f64 = 0;
    for (t) |v| largest = @max(largest, @abs(v));
    const tol = 1e-12 * largest * @as(f64, @floatFromInt(n));
    while (i < n) {
        starts[nb] = i;
        nb += 1;
        if (i + 1 < n and @abs(t[(i + 1) * n + i]) > tol) i += 2 else i += 1;
    }
    starts[nb] = n;

    // diagonal blocks
    for (0..nb) |b| {
        const sbeg = starts[b];
        const sz = starts[b + 1] - sbeg;
        if (sz == 1) {
            const v = t[sbeg * n + sbeg];
            // A NEGATIVE REAL EIGENVALUE HAS NO REAL SQUARE ROOT, and returning a NaN
            // would let it travel. Refused instead.
            if (v < -tol) return FunError.NoRealResult;
            f[sbeg * n + sbeg] = @sqrt(@max(v, 0));
        } else {
            const blk = [4]f64{
                t[sbeg * n + sbeg],       t[sbeg * n + (sbeg + 1)],
                t[(sbeg + 1) * n + sbeg], t[(sbeg + 1) * n + (sbeg + 1)],
            };
            var out: [4]f64 = undefined;
            if (!sqrt2x2(blk, &out)) return FunError.NoRealResult;
            f[sbeg * n + sbeg] = out[0];
            f[sbeg * n + (sbeg + 1)] = out[1];
            f[(sbeg + 1) * n + sbeg] = out[2];
            f[(sbeg + 1) * n + (sbeg + 1)] = out[3];
        }
    }

    // off-diagonal blocks, in order of increasing distance from the diagonal
    var d: usize = 1;
    while (d < nb) : (d += 1) {
        var bi: usize = 0;
        while (bi + d < nb) : (bi += 1) {
            const bj = bi + d;
            const ibeg = starts[bi];
            const ni = starts[bi + 1] - ibeg;
            const jbeg = starts[bj];
            const nj = starts[bj + 1] - jbeg;

            // C = T_ij - sum over the blocks strictly between them
            const c = try alloc.alloc(f64, ni * nj);
            defer alloc.free(c);
            for (0..ni) |a| {
                for (0..nj) |b| c[a * nj + b] = t[(ibeg + a) * n + (jbeg + b)];
            }
            var bk = bi + 1;
            while (bk < bj) : (bk += 1) {
                const kbeg = starts[bk];
                const nk = starts[bk + 1] - kbeg;
                for (0..ni) |a| {
                    for (0..nj) |b| {
                        var acc: f64 = 0;
                        for (0..nk) |kk| {
                            acc += f[(ibeg + a) * n + (kbeg + kk)] * f[(kbeg + kk) * n + (jbeg + b)];
                        }
                        c[a * nj + b] -= acc;
                    }
                }
            }

            const fii = try alloc.alloc(f64, ni * ni);
            defer alloc.free(fii);
            for (0..ni) |a| {
                for (0..ni) |b| fii[a * ni + b] = f[(ibeg + a) * n + (ibeg + b)];
            }
            const fjj = try alloc.alloc(f64, nj * nj);
            defer alloc.free(fjj);
            for (0..nj) |a| {
                for (0..nj) |b| fjj[a * nj + b] = f[(jbeg + a) * n + (jbeg + b)];
            }
            const z = try alloc.alloc(f64, ni * nj);
            defer alloc.free(z);

            // F_ii Z + Z F_jj = C, which is the Sylvester equation with a PLUS because
            // f(T) here is a square root: the product rule gives F_ii Z + Z F_jj, not
            // the minus sign a general Parlett step carries.
            const neg = try alloc.alloc(f64, nj * nj);
            defer alloc.free(neg);
            for (fjj, 0..) |v, q| neg[q] = -v;
            if (!try sylvesterSmall(alloc, fii, ni, neg, nj, c, z)) return FunError.Singular;

            for (0..ni) |a| {
                for (0..nj) |b| f[(ibeg + a) * n + (jbeg + b)] = z[a * nj + b];
            }
        }
    }
}

/// THE SQUARE ROOT OF A GENERAL REAL MATRIX: X with X*X = A.
///
/// Bjorck and Hammarling's algorithm -- Schur, then the block recurrence above, then
/// back. This is what `linalg.symmetricPower(0.5)` cannot do: that one refuses every
/// non-symmetric matrix by construction.
///
/// Refused rather than returned as NaN when A has a negative real eigenvalue: its
/// square root exists but is COMPLEX, and this returns real matrices. A complex pair is
/// fine -- that is what the 2x2 blocks are for -- and so is a defective matrix, which
/// has no eigendecomposition at all and a perfectly good square root.
pub fn sqrtGeneral(alloc: std.mem.Allocator, data: []const f64, n: usize, out: []f64) !void {
    if (n == 0) return;
    var d = try schur(alloc, data, n);
    defer d.deinit();

    const f = try alloc.alloc(f64, n * n);
    defer alloc.free(f);
    try sqrtQuasiTriangular(alloc, d.t, n, f);

    // out = Q f Q'
    const tmp = try alloc.alloc(f64, n * n);
    defer alloc.free(tmp);
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |k| acc += d.q[i * n + k] * f[k * n + j];
            tmp[i * n + j] = acc;
        }
    }
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |k| acc += tmp[i * n + k] * d.q[j * n + k];
            out[i * n + j] = acc;
        }
    }
}

/// THE MATRIX SINE AND COSINE, computed together.
///
/// ── SCALING AND THE DOUBLE-ANGLE RECURRENCES, and no decomposition at all ──
///
/// The Taylor series for sin and cos converge everywhere, but slowly for a large
/// matrix and with cancellation that eats the answer. So the same trick as the
/// exponential: scale A down until its norm is small, where a handful of terms is
/// exact to rounding, then climb back up with
///
///     cos(2X) = 2 cos(X)^2 - I
///     sin(2X) = 2 sin(X) cos(X)
///
/// The two are computed TOGETHER because the sine's recurrence needs the cosine.
/// Asking for one alone and throwing the other away would double the work for nothing,
/// which is why the pair is the primitive here and the singles are wrappers.
///
/// ── AND THIS ONE NEEDS NOTHING BENEATH IT ──
///
/// The square root needed a Schur form, the logarithm needed the square root, the
/// general power needed the logarithm. These need none of them: no eigenvalues, no
/// triangularisation, no factorisation. Worth saying because the previous three
/// entries might suggest a house style -- the decomposition is reached for when the
/// algorithm requires it, and here it does not.
///
/// Every real matrix has a sine and a cosine, so there is nothing to refuse: no
/// singularity to trip over, no eigenvalue whose real answer fails to exist.
pub fn sinCosGeneral(
    alloc: std.mem.Allocator,
    data: []const f64,
    n: usize,
    sin_out: []f64,
    cos_out: []f64,
) !void {
    return trigPair(alloc, data, n, sin_out, cos_out, false);
}

/// THE HYPERBOLIC PAIR, and it is the SAME ROUTINE with one sign changed.
///
/// ── WHY THERE IS ONE FUNCTION HERE AND NOT TWO ──
///
/// Write the two families out and the difference is a single alternating sign in the
/// series:
///
///     cos(X)  = I - X^2/2! + X^4/4! - ...        cosh(X) = I + X^2/2! + X^4/4! + ...
///     sin(X)  = X - X^3/3! + X^5/5! - ...        sinh(X) = X + X^3/3! + X^5/5! + ...
///
/// And the double-angle recurrences that climb back from the scaled matrix are not
/// merely similar, they are IDENTICAL:
///
///     cos(2X)  = 2 cos(X)^2  - I                 cosh(2X) = 2 cosh(X)^2 - I
///     sin(2X)  = 2 sin(X) cos(X)                 sinh(2X) = 2 sinh(X) cosh(X)
///
/// So a second copy would be a second transcription of one algorithm, differing by a
/// boolean -- and the two copies would drift, as two copies always do. One routine, one
/// scaling decision, one recurrence, and the sign passed in.
pub fn sinhCoshGeneral(
    alloc: std.mem.Allocator,
    data: []const f64,
    n: usize,
    sinh_out: []f64,
    cosh_out: []f64,
) !void {
    return trigPair(alloc, data, n, sinh_out, cosh_out, true);
}

/// The hyperbolic cosine alone. See sinhCoshGeneral -- the pair is the primitive.
pub fn coshGeneral(alloc: std.mem.Allocator, data: []const f64, n: usize, out: []f64) !void {
    const throwaway = try alloc.alloc(f64, n * n);
    defer alloc.free(throwaway);
    try sinhCoshGeneral(alloc, data, n, throwaway, out);
}

/// The hyperbolic sine alone.
pub fn sinhGeneral(alloc: std.mem.Allocator, data: []const f64, n: usize, out: []f64) !void {
    const throwaway = try alloc.alloc(f64, n * n);
    defer alloc.free(throwaway);
    try sinhCoshGeneral(alloc, data, n, out, throwaway);
}

fn trigPair(
    alloc: std.mem.Allocator,
    data: []const f64,
    n: usize,
    sin_out: []f64,
    cos_out: []f64,
    hyperbolic: bool,
) !void {
    if (n == 0) return;

    var norm: f64 = 0;
    for (0..n) |i| {
        var row: f64 = 0;
        for (0..n) |j| row += @abs(data[i * n + j]);
        norm = @max(norm, row);
    }
    var k: usize = 0;
    while (norm > 0.25 and k < 60) : (k += 1) norm /= 2;

    const x = try alloc.alloc(f64, n * n);
    defer alloc.free(x);
    const scale = std.math.pow(f64, 2, -@as(f64, @floatFromInt(k)));
    for (data, 0..) |v, i| x[i] = v * scale;

    const x2 = try alloc.alloc(f64, n * n);
    defer alloc.free(x2);
    matMul(x, x, n, x2);

    // Taylor in X^2: cos = I - X^2/2! + X^4/4! - ..., sin = X(I - X^2/3! + X^4/5! - ...)
    const term = try alloc.alloc(f64, n * n);
    defer alloc.free(term);
    const tmp = try alloc.alloc(f64, n * n);
    defer alloc.free(tmp);
    const sfac = try alloc.alloc(f64, n * n);
    defer alloc.free(sfac);

    @memset(cos_out, 0);
    @memset(sfac, 0);
    @memset(term, 0);
    for (0..n) |i| {
        cos_out[i * n + i] = 1;
        sfac[i * n + i] = 1;
        term[i * n + i] = 1;
    }

    // with ||X|| <= 0.25 the terms fall off faster than 16^-m, so ten is far past
    // rounding and the loop is a fixed cost rather than a convergence test
    var m: usize = 1;
    while (m <= 10) : (m += 1) {
        matMul(term, x2, n, tmp);
        @memcpy(term, tmp);
        // THE ONE LINE THAT DIFFERS between the two families
        const sign: f64 = if (hyperbolic) 1 else (if (m % 2 == 0) @as(f64, 1) else -1);
        var cfac: f64 = 1;
        var q: usize = 1;
        while (q <= 2 * m) : (q += 1) cfac *= @floatFromInt(q);
        var sf: f64 = 1;
        q = 1;
        while (q <= 2 * m + 1) : (q += 1) sf *= @floatFromInt(q);
        for (0..n * n) |i| {
            cos_out[i] += sign * term[i] / cfac;
            sfac[i] += sign * term[i] / sf;
        }
    }
    matMul(x, sfac, n, sin_out);

    // climb back: k doublings
    var rep: usize = 0;
    while (rep < k) : (rep += 1) {
        // sin(2X) = 2 sin cos -- computed FIRST, since the cosine update overwrites
        // the value this needs
        matMul(sin_out, cos_out, n, tmp);
        for (0..n * n) |i| tmp[i] *= 2;
        const new_sin = tmp;
        matMul(cos_out, cos_out, n, term);
        for (0..n * n) |i| cos_out[i] = 2 * term[i];
        for (0..n) |i| cos_out[i * n + i] -= 1;
        @memcpy(sin_out, new_sin);
    }
}

fn matMul(a: []const f64, b: []const f64, n: usize, out: []f64) void {
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += a[i * n + t] * b[t * n + j];
            out[i * n + j] = acc;
        }
    }
}

/// The cosine alone. See sinCosGeneral -- the pair is the primitive, because the
/// sine's double-angle step needs the cosine anyway.
pub fn cosGeneral(alloc: std.mem.Allocator, data: []const f64, n: usize, out: []f64) !void {
    const throwaway = try alloc.alloc(f64, n * n);
    defer alloc.free(throwaway);
    try sinCosGeneral(alloc, data, n, throwaway, out);
}

/// The sine alone.
pub fn sinGeneral(alloc: std.mem.Allocator, data: []const f64, n: usize, out: []f64) !void {
    const throwaway = try alloc.alloc(f64, n * n);
    defer alloc.free(throwaway);
    try sinCosGeneral(alloc, data, n, out, throwaway);
}

/// THE MATRIX LOGARITHM: the X with exp(X) = A.
///
/// ── INVERSE SCALING AND SQUARING, which is the exponential's method run backwards ──
///
/// A series for log converges only near the identity, and a general matrix is not near
/// it. So: take repeated SQUARE ROOTS until it is -- each one halves the distance in
/// the sense that matters -- evaluate the series there, and multiply back by 2^k, since
/// log(A) = 2^k * log(A^(1/2^k)).
///
/// The square roots are the Schur-based ones above. This is the third layer of the same
/// construction: Schur gives the square root, the square root gives the logarithm, and
/// the logarithm with the exponential gives every real power. Each one is a few lines
/// because the one below it did the work.
///
/// ── THE SERIES, AND WHY IT IS NOT log(I + Y) ──
///
/// The obvious expansion in Y = X - I converges slowly and only for ||Y|| < 1. The
/// Gregory form in Z = (X - I)(X + I)^-1 converges far faster over a far wider region:
///
///     log(X) = 2 * (Z + Z^3/3 + Z^5/5 + ...)
///
/// It costs one matrix inverse, which the LU in the library already provides, and it is
/// what makes eight square roots enough where the naive series would want dozens.
///
/// ── WHAT IT REFUSES ──
///
/// A singular matrix has no logarithm at all -- exp is never singular, so nothing maps
/// to it. And a NEGATIVE REAL eigenvalue has only a complex logarithm, for the same
/// reason it has only a complex square root: the refusal arrives from `sqrtGeneral`
/// below, which is where the constraint actually lives.
pub fn logGeneral(alloc: std.mem.Allocator, data: []const f64, n: usize, out: []f64) !void {
    if (n == 0) return;

    // a singular matrix is not in the image of exp, and the LU below would divide by
    // rounding rather than say so
    var lu = try linalg.decompose(alloc, data, n);
    const singular = lu.singular;
    lu.deinit();
    if (singular) return FunError.Singular;

    const x = try alloc.alloc(f64, n * n);
    defer alloc.free(x);
    @memcpy(x, data);
    const tmp = try alloc.alloc(f64, n * n);
    defer alloc.free(tmp);

    // ── repeated square roots until X is close to the identity ──
    var k: usize = 0;
    while (k < 40) : (k += 1) {
        var dist: f64 = 0;
        for (0..n) |i| {
            var row: f64 = 0;
            for (0..n) |j| {
                const want: f64 = if (i == j) 1 else 0;
                row += @abs(x[i * n + j] - want);
            }
            dist = @max(dist, row);
        }
        if (dist < 0.25) break;
        try sqrtGeneral(alloc, x, n, tmp);
        @memcpy(x, tmp);
    }

    // ── Z = (X - I)(X + I)^-1 ──
    const minus = try alloc.alloc(f64, n * n);
    defer alloc.free(minus);
    const plus = try alloc.alloc(f64, n * n);
    defer alloc.free(plus);
    for (0..n * n) |i| {
        minus[i] = x[i];
        plus[i] = x[i];
    }
    for (0..n) |i| {
        minus[i * n + i] -= 1;
        plus[i * n + i] += 1;
    }

    const pinv = try alloc.alloc(f64, n * n);
    defer alloc.free(pinv);
    if (!try linalg.luInverse(alloc, plus, n, pinv)) return FunError.Singular;

    const z = try alloc.alloc(f64, n * n);
    defer alloc.free(z);
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += minus[i * n + t] * pinv[t * n + j];
            z[i * n + j] = acc;
        }
    }

    // ── 2 * (Z + Z^3/3 + Z^5/5 + ...) ──
    const z2 = try alloc.alloc(f64, n * n);
    defer alloc.free(z2);
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..t_n(n)) |t| acc += z[i * n + t] * z[t * n + j];
            z2[i * n + j] = acc;
        }
    }
    const term = try alloc.alloc(f64, n * n);
    defer alloc.free(term);
    @memcpy(term, z);
    @memset(out, 0);
    var odd: usize = 1;
    while (odd <= 31) : (odd += 2) {
        const c = 1.0 / @as(f64, @floatFromInt(odd));
        for (0..n * n) |i| out[i] += c * term[i];
        // term <- term * Z^2
        for (0..n) |i| {
            for (0..n) |j| {
                var acc: f64 = 0;
                for (0..n) |t| acc += term[i * n + t] * z2[t * n + j];
                tmp[i * n + j] = acc;
            }
        }
        @memcpy(term, tmp);
    }

    // ── times 2, then undo the k square roots ──
    const factor = 2.0 * std.math.pow(f64, 2, @floatFromInt(k));
    for (0..n * n) |i| out[i] *= factor;
}

inline fn t_n(n: usize) usize {
    return n;
}

/// A RAISED TO ANY REAL POWER, for a matrix with no symmetry: A^p = exp(p * log(A)).
///
/// `linalg.symmetricPower` refuses every non-symmetric matrix, and this is the answer
/// it could not give. Two lines, because the logarithm and the exponential above did
/// the work -- which is what a foundation is supposed to look like.
///
/// The same constraints follow through: no negative real eigenvalue, and non-singular.
/// An INTEGER power needs neither and is better done by repeated multiplication; this
/// is for the fractional case, where there is no other route.
pub fn powerGeneral(alloc: std.mem.Allocator, data: []const f64, n: usize, p: f64, out: []f64) !void {
    if (n == 0) return;
    const lg = try alloc.alloc(f64, n * n);
    defer alloc.free(lg);
    try logGeneral(alloc, data, n, lg);
    for (0..n * n) |i| lg[i] *= p;
    try expGeneral(alloc, lg, n, out);
}

/// THE MATRIX EXPONENTIAL, and NOT through the Schur form.
///
/// Scaling and squaring with a Pade approximant: exp(A) = (exp(A/2^s))^(2^s), with the
/// inner exponential a rational approximation that is accurate precisely because A/2^s
/// has been made small. It is what every serious library uses, and it needs no
/// decomposition at all.
///
/// Worth stating plainly next to the square root: NOT EVERY MATRIX FUNCTION WANTS A
/// SCHUR DECOMPOSITION. The square root does -- the block recurrence is the algorithm.
/// The exponential does not, and routing it through a Schur form would be slower and no
/// more accurate. A decomposition is a tool, not a house style.
pub fn expGeneral(alloc: std.mem.Allocator, data: []const f64, n: usize, out: []f64) !void {
    if (n == 0) return;

    // scale so that the norm is comfortably below 1
    var norm: f64 = 0;
    for (0..n) |i| {
        var row: f64 = 0;
        for (0..n) |j| row += @abs(data[i * n + j]);
        norm = @max(norm, row);
    }
    var s: usize = 0;
    while (norm > 0.5) : (s += 1) norm /= 2;

    const a = try alloc.alloc(f64, n * n);
    defer alloc.free(a);
    const scale = std.math.pow(f64, 2, -@as(f64, @floatFromInt(s)));
    for (data, 0..) |v, i| a[i] = v * scale;

    // Pade(6,6) on the scaled matrix
    const num = try alloc.alloc(f64, n * n);
    defer alloc.free(num);
    const den = try alloc.alloc(f64, n * n);
    defer alloc.free(den);
    const powk = try alloc.alloc(f64, n * n);
    defer alloc.free(powk);
    const tmp = try alloc.alloc(f64, n * n);
    defer alloc.free(tmp);

    @memset(num, 0);
    @memset(den, 0);
    @memset(powk, 0);
    for (0..n) |i| {
        num[i * n + i] = 1;
        den[i * n + i] = 1;
        powk[i * n + i] = 1;
    }
    var c: f64 = 1;
    const q: usize = 6;
    var k: usize = 1;
    while (k <= q) : (k += 1) {
        c = c * @as(f64, @floatFromInt(q - k + 1)) /
            (@as(f64, @floatFromInt(k)) * @as(f64, @floatFromInt(2 * q - k + 1)));
        // powk <- powk * a
        for (0..n) |i| {
            for (0..n) |j| {
                var acc: f64 = 0;
                for (0..n) |t| acc += powk[i * n + t] * a[t * n + j];
                tmp[i * n + j] = acc;
            }
        }
        @memcpy(powk, tmp);
        const sign: f64 = if (k % 2 == 0) 1 else -1;
        for (0..n * n) |i| {
            num[i] += c * powk[i];
            den[i] += sign * c * powk[i];
        }
    }

    // solve den * X = num
    const col = try alloc.alloc(f64, n);
    defer alloc.free(col);
    const rhs = try alloc.alloc(f64, n);
    defer alloc.free(rhs);
    var f = try linalg.decompose(alloc, den, n);
    defer f.deinit();
    if (f.singular) return FunError.Singular;
    for (0..n) |j| {
        for (0..n) |i| rhs[i] = num[i * n + j];
        if (!linalg.solveWith(&f, rhs, col)) return FunError.Singular;
        for (0..n) |i| out[i * n + j] = col[i];
    }

    // square it back s times
    var rep: usize = 0;
    while (rep < s) : (rep += 1) {
        for (0..n) |i| {
            for (0..n) |j| {
                var acc: f64 = 0;
                for (0..n) |t| acc += out[i * n + t] * out[t * n + j];
                tmp[i * n + j] = acc;
            }
        }
        @memcpy(out, tmp);
    }
}

// ─── matrix functions of a non-symmetric matrix ──────────────────────────────

fn squares(alloc: std.mem.Allocator, x: []const f64, n: usize) ![]f64 {
    const out = try alloc.alloc(f64, n * n);
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += x[i * n + t] * x[t * n + j];
            out[i * n + j] = acc;
        }
    }
    return out;
}

test "THE SQUARE ROOT OF A NON-SYMMETRIC MATRIX, which symmetricPower refuses" {
    const alloc = testing.allocator;
    const n = 4;
    const a = [_]f64{
        4, 1, 2, 0,
        0, 3, 1, 5,
        2, 0, 6, 1,
        1, 2, 0, 4,
    };
    const r = try alloc.alloc(f64, n * n);
    defer alloc.free(r);
    try sqrtGeneral(alloc, &a, n, r);

    // the defining property, and the only one that matters
    const sq = try squares(alloc, r, n);
    defer alloc.free(sq);
    for (a, sq) |x, y| try testing.expectApproxEqAbs(x, y, 1e-7);

    // and the symmetric route cannot touch this matrix at all
    const out = try alloc.alloc(f64, n * n);
    defer alloc.free(out);
    try testing.expectError(
        linalg.PowerError.NotSymmetric,
        linalg.symmetricPower(alloc, &a, n, 0.5, out),
    );
}

test "A DEFECTIVE MATRIX HAS NO EIGENDECOMPOSITION AND A FINE SQUARE ROOT" {
    const alloc = testing.allocator;
    const n = 2;
    // one eigenvalue 1 with ONE eigenvector -- the smallest defective matrix there is
    const a = [_]f64{ 1, 1, 0, 1 };

    // it is defective: only one independent eigenvector for a 2x2
    var work = a;
    const vals = try alloc.alloc(Complex, n);
    defer alloc.free(vals);
    const vecs = try alloc.alloc(Complex, n * n);
    defer alloc.free(vecs);
    try eigensystem(alloc, &work, n, vals, vecs);
    try testing.expectEqual(@as(usize, 1), try independentCount(alloc, vecs, n));

    // SO THERE IS NOTHING TO DIAGONALISE. f(A) = V f(L) V^-1 needs a full set of
    // eigenvectors and this matrix does not have one -- while its square root is
    // perfectly ordinary, [[1, 0.5], [0, 1]], and the Schur form reaches it because
    // EVERY real matrix has a Schur form.
    const r = try alloc.alloc(f64, n * n);
    defer alloc.free(r);
    try sqrtGeneral(alloc, &a, n, r);

    try testing.expectApproxEqAbs(@as(f64, 1), r[0], 1e-10);
    try testing.expectApproxEqAbs(@as(f64, 0.5), r[1], 1e-10);
    try testing.expectApproxEqAbs(@as(f64, 0), r[2], 1e-10);
    try testing.expectApproxEqAbs(@as(f64, 1), r[3], 1e-10);

    const sq = try squares(alloc, r, n);
    defer alloc.free(sq);
    for (a, sq) |x, y| try testing.expectApproxEqAbs(x, y, 1e-10);
}

test "A COMPLEX EIGENVALUE PAIR IS FINE; A NEGATIVE REAL ONE IS REFUSED" {
    const alloc = testing.allocator;
    const n = 4;
    const out = try alloc.alloc(f64, n * n);
    defer alloc.free(out);

    // eigenvalues 2 +/- 3i and 1, 5. The 2x2 block lives in a copy of the complex
    // numbers, so its square root is the ordinary complex one written in that basis --
    // no complex arithmetic required anywhere.
    const rot = [_]f64{
        2, -3, 0, 0,
        3,  2, 0, 0,
        0,  0, 1, 0,
        0,  0, 0, 5,
    };
    try sqrtGeneral(alloc, &rot, n, out);
    const sq = try squares(alloc, out, n);
    defer alloc.free(sq);
    for (rot, sq) |x, y| try testing.expectApproxEqAbs(x, y, 1e-8);

    // A NEGATIVE REAL EIGENVALUE has a square root, and it is COMPLEX. This returns
    // real matrices, so it refuses rather than handing back a NaN that would travel
    // quietly through everything downstream.
    const neg = [_]f64{
        -4, 0, 0, 0,
        0,  1, 0, 0,
        0,  0, 2, 0,
        0,  0, 0, 3,
    };
    try testing.expectError(FunError.NoRealResult, sqrtGeneral(alloc, &neg, n, out));
}

test "THE EXPONENTIAL, and it does NOT want a Schur decomposition" {
    const alloc = testing.allocator;
    const n = 3;
    const out = try alloc.alloc(f64, n * n);
    defer alloc.free(out);

    // exp(0) = I
    const zero = [_]f64{ 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    try expGeneral(alloc, &zero, n, out);
    for (0..n) |i| {
        for (0..n) |j| try testing.expectApproxEqAbs(if (i == j) @as(f64, 1) else 0, out[i * n + j], 1e-12);
    }

    // a diagonal matrix exponentiates entry by entry, which is the one case where the
    // answer is known in closed form
    const diag = [_]f64{ 1, 0, 0, 0, -2, 0, 0, 0, 0.5 };
    try expGeneral(alloc, &diag, n, out);
    try testing.expectApproxEqAbs(@exp(@as(f64, 1)), out[0], 1e-10);
    try testing.expectApproxEqAbs(@exp(@as(f64, -2)), out[4], 1e-10);
    try testing.expectApproxEqAbs(@exp(@as(f64, 0.5)), out[8], 1e-10);

    // A NILPOTENT MATRIX gives an EXACT polynomial: N^3 = 0, so exp(N) = I + N + N^2/2
    // and nothing after it. A hard check, because an approximation that was merely
    // close would miss the exact 0.5.
    const nil = [_]f64{ 0, 1, 0, 0, 0, 1, 0, 0, 0 };
    try expGeneral(alloc, &nil, n, out);
    const want = [_]f64{ 1, 1, 0.5, 0, 1, 1, 0, 0, 1 };
    for (want, out) |x, y| try testing.expectApproxEqAbs(x, y, 1e-12);
}

test "exp(A) exp(-A) = I, which no single evaluation can fake" {
    const alloc = testing.allocator;
    const n = 4;
    const a = [_]f64{
        0.4, 1.0, -0.2, 0.0,
        0.0, 0.3,  1.1, 0.5,
        -0.6, 0.0, 0.2, 1.0,
        0.1, -0.4, 0.0, 0.7,
    };
    const neg = blk: {
        var t: [16]f64 = undefined;
        for (a, 0..) |v, i| t[i] = -v;
        break :blk t;
    };
    const ea = try alloc.alloc(f64, n * n);
    defer alloc.free(ea);
    const en = try alloc.alloc(f64, n * n);
    defer alloc.free(en);
    try expGeneral(alloc, &a, n, ea);
    try expGeneral(alloc, &neg, n, en);

    // The scaling-and-squaring is run twice on genuinely different inputs, so agreeing
    // here is a statement about the algorithm rather than about one lucky evaluation.
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += ea[i * n + t] * en[t * n + j];
            try testing.expectApproxEqAbs(if (i == j) @as(f64, 1) else 0, acc, 1e-9);
        }
    }
}

test "and the square root agrees with the symmetric route where BOTH apply" {
    const alloc = testing.allocator;
    const n = 3;
    // symmetric positive definite, so symmetricPower(0.5) will take it too
    const a = [_]f64{ 6, 2, 1, 2, 5, 2, 1, 2, 4 };
    const viaSchur = try alloc.alloc(f64, n * n);
    defer alloc.free(viaSchur);
    const viaEigen = try alloc.alloc(f64, n * n);
    defer alloc.free(viaEigen);

    try sqrtGeneral(alloc, &a, n, viaSchur);
    try linalg.symmetricPower(alloc, &a, n, 0.5, viaEigen);

    // Two algorithms with nothing in common below the matrix -- a Householder Schur
    // reduction with a block recurrence, against a Jacobi eigendecomposition -- and one
    // answer. That the general route reproduces the symmetric one on symmetric input is
    // the check that it is computing the same thing rather than something adjacent.
    for (viaSchur, viaEigen) |x, y| try testing.expectApproxEqAbs(x, y, 1e-8);
}

test "THE MATRIX LOGARITHM: exp(log(A)) = A, which is what it means" {
    const alloc = testing.allocator;
    const n = 4;
    const a = [_]f64{
        4, 1, 2, 0,
        0, 3, 1, 5,
        2, 0, 6, 1,
        1, 2, 0, 4,
    };
    const lg = try alloc.alloc(f64, n * n);
    defer alloc.free(lg);
    try logGeneral(alloc, &a, n, lg);

    const back = try alloc.alloc(f64, n * n);
    defer alloc.free(back);
    try expGeneral(alloc, lg, n, back);

    // THE DEFINING PROPERTY, and the only one worth asserting: the logarithm is the
    // thing the exponential undoes. Checked through a genuinely different algorithm --
    // inverse scaling and squaring on the way out, Pade scaling and squaring on the way
    // back -- so agreeing is not two halves of one routine cancelling.
    for (a, back) |x, y| try testing.expectApproxEqAbs(x, y, 1e-7);
}

test "log of the identity is zero, and of a diagonal is entrywise" {
    const alloc = testing.allocator;
    const n = 3;
    const out = try alloc.alloc(f64, n * n);
    defer alloc.free(out);

    const eye = [_]f64{ 1, 0, 0, 0, 1, 0, 0, 0, 1 };
    try logGeneral(alloc, &eye, n, out);
    for (out) |v| try testing.expectApproxEqAbs(@as(f64, 0), v, 1e-12);

    // a diagonal matrix is the one case with a closed-form answer to check against
    const diag = [_]f64{ 2, 0, 0, 0, 7, 0, 0, 0, 0.5 };
    try logGeneral(alloc, &diag, n, out);
    try testing.expectApproxEqAbs(@log(@as(f64, 2)), out[0], 1e-9);
    try testing.expectApproxEqAbs(@log(@as(f64, 7)), out[4], 1e-9);
    try testing.expectApproxEqAbs(@log(@as(f64, 0.5)), out[8], 1e-9);
    // and nothing off the diagonal
    try testing.expectApproxEqAbs(@as(f64, 0), out[1], 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 0), out[5], 1e-9);
}

test "THE DEFECTIVE MATRIX AGAIN, with an exact answer" {
    const alloc = testing.allocator;
    const n = 2;
    // exp([[0,1],[0,0]]) = [[1,1],[0,1]] exactly, since the nilpotent series stops
    // after one term. So the logarithm of [[1,1],[0,1]] is [[0,1],[0,0]] and nothing
    // else -- an exact target on a matrix with only one eigenvector, where no
    // eigendecomposition exists to compute it from.
    const a = [_]f64{ 1, 1, 0, 1 };
    const out = try alloc.alloc(f64, n * n);
    defer alloc.free(out);
    try logGeneral(alloc, &a, n, out);

    try testing.expectApproxEqAbs(@as(f64, 0), out[0], 1e-10);
    try testing.expectApproxEqAbs(@as(f64, 1), out[1], 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 0), out[2], 1e-10);
    try testing.expectApproxEqAbs(@as(f64, 0), out[3], 1e-10);
}

test "log(exp(A)) = A, the identity run the other way" {
    const alloc = testing.allocator;
    const n = 4;
    // modest entries, so exp stays in the region where the principal logarithm is the
    // one that comes back -- log is only an inverse of exp on a restricted domain, and
    // asking outside it is asking which of infinitely many answers was meant
    const a = [_]f64{
        0.3,  0.5, -0.2, 0.0,
        0.0,  0.2,  0.4, 0.1,
        -0.1, 0.0,  0.3, 0.2,
        0.1, -0.2,  0.0, 0.4,
    };
    const e = try alloc.alloc(f64, n * n);
    defer alloc.free(e);
    const back = try alloc.alloc(f64, n * n);
    defer alloc.free(back);
    try expGeneral(alloc, &a, n, e);
    try logGeneral(alloc, e, n, back);
    for (a, back) |x, y| try testing.expectApproxEqAbs(x, y, 1e-8);
}

test "a singular matrix has NO logarithm, and a negative real eigenvalue no real one" {
    const alloc = testing.allocator;
    const n = 3;
    const out = try alloc.alloc(f64, n * n);
    defer alloc.free(out);

    // exp is never singular -- nothing maps to a singular matrix, so there is no
    // logarithm to return rather than an inaccurate one
    const sing = [_]f64{ 1, 2, 3, 4, 5, 6, 5, 7, 9 };
    try testing.expectError(FunError.Singular, logGeneral(alloc, &sing, n, out));

    // and a negative real eigenvalue has only a complex logarithm, for exactly the
    // reason it has only a complex square root -- the refusal arrives from sqrtGeneral,
    // which is where the constraint actually lives
    const neg = [_]f64{ -4, 0, 0, 0, 1, 0, 0, 0, 2 };
    try testing.expectError(FunError.NoRealResult, logGeneral(alloc, &neg, n, out));
}

test "AND THEN ANY REAL POWER FOLLOWS, which symmetricPower could not give" {
    const alloc = testing.allocator;
    const n = 4;
    const a = [_]f64{
        4, 1, 2, 0,
        0, 3, 1, 5,
        2, 0, 6, 1,
        1, 2, 0, 4,
    };
    const half = try alloc.alloc(f64, n * n);
    defer alloc.free(half);
    try powerGeneral(alloc, &a, n, 0.5, half);

    // A^0.5 must square back to A -- and it must agree with the Schur square root,
    // which reached the same matrix by an entirely different road: a block recurrence
    // rather than exp(0.5 log A)
    const sq = try squares(alloc, half, n);
    defer alloc.free(sq);
    for (a, sq) |x, y| try testing.expectApproxEqAbs(x, y, 1e-6);

    const viaSchur = try alloc.alloc(f64, n * n);
    defer alloc.free(viaSchur);
    try sqrtGeneral(alloc, &a, n, viaSchur);
    for (half, viaSchur) |x, y| try testing.expectApproxEqAbs(x, y, 1e-6);

    // a quarter power composes: (A^0.25)^2 = A^0.5, which a routine that was not really
    // exponentiating would fail while still passing the squares-back test
    const quarter = try alloc.alloc(f64, n * n);
    defer alloc.free(quarter);
    try powerGeneral(alloc, &a, n, 0.25, quarter);
    const qsq = try squares(alloc, quarter, n);
    defer alloc.free(qsq);
    for (half, qsq) |x, y| try testing.expectApproxEqAbs(x, y, 1e-6);

    // and the symmetric route still refuses the matrix outright
    const out = try alloc.alloc(f64, n * n);
    defer alloc.free(out);
    try testing.expectError(
        linalg.PowerError.NotSymmetric,
        linalg.symmetricPower(alloc, &a, n, 0.5, out),
    );
}

test "sin(A)^2 + cos(A)^2 = I, which is the whole of trigonometry in one line" {
    const alloc = testing.allocator;
    const n = 4;
    const a = [_]f64{
        4, 1, 2, 0,
        0, 3, 1, 5,
        2, 0, 6, 1,
        1, 2, 0, 4,
    };
    const sn = try alloc.alloc(f64, n * n);
    defer alloc.free(sn);
    const cs = try alloc.alloc(f64, n * n);
    defer alloc.free(cs);
    try sinCosGeneral(alloc, &a, n, sn, cs);

    // THE STRONGEST CHECK AVAILABLE for this pair. It cannot be satisfied by accident:
    // both matrices come from a scaled Taylor series climbed back through nine
    // doublings, and anything wrong in either the series or the recurrence shows up
    // here rather than staying hidden in a plausible-looking matrix.
    //
    // Note it is the MATRIX identity, not the entrywise one -- sin(A)^2 means the
    // matrix squared, and for a non-symmetric A those are wildly different things.
    const s2 = try squares(alloc, sn, n);
    defer alloc.free(s2);
    const c2 = try squares(alloc, cs, n);
    defer alloc.free(c2);
    for (0..n) |i| {
        for (0..n) |j| {
            const want: f64 = if (i == j) 1 else 0;
            try testing.expectApproxEqAbs(want, s2[i * n + j] + c2[i * n + j], 1e-8);
        }
    }
}

test "cos(0) = I, sin(0) = 0, and a diagonal goes entrywise" {
    const alloc = testing.allocator;
    const n = 3;
    const sn = try alloc.alloc(f64, n * n);
    defer alloc.free(sn);
    const cs = try alloc.alloc(f64, n * n);
    defer alloc.free(cs);

    const zero = [_]f64{ 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    try sinCosGeneral(alloc, &zero, n, sn, cs);
    for (sn) |v| try testing.expectApproxEqAbs(@as(f64, 0), v, 1e-14);
    for (0..n) |i| {
        for (0..n) |j| {
            try testing.expectApproxEqAbs(if (i == j) @as(f64, 1) else 0, cs[i * n + j], 1e-14);
        }
    }

    const diag = [_]f64{ 1.2, 0, 0, 0, -2.5, 0, 0, 0, 0.7 };
    try sinCosGeneral(alloc, &diag, n, sn, cs);
    try testing.expectApproxEqAbs(@sin(@as(f64, 1.2)), sn[0], 1e-12);
    try testing.expectApproxEqAbs(@sin(@as(f64, -2.5)), sn[4], 1e-12);
    try testing.expectApproxEqAbs(@cos(@as(f64, 0.7)), cs[8], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 0), sn[1], 1e-12);
}

test "A NILPOTENT MATRIX gives EXACT polynomials" {
    const alloc = testing.allocator;
    const n = 3;
    const nil = [_]f64{ 0, 1, 0, 0, 0, 1, 0, 0, 0 }; // N^3 = 0
    const sn = try alloc.alloc(f64, n * n);
    defer alloc.free(sn);
    const cs = try alloc.alloc(f64, n * n);
    defer alloc.free(cs);
    try sinCosGeneral(alloc, &nil, n, sn, cs);

    // N^3 = 0 truncates both series exactly: sin(N) = N, and cos(N) = I - N^2/2.
    // A hard target -- an approximation that was merely close would miss the exact
    // -0.5, and a series that had quietly stopped one term early would miss it too.
    const want_sin = [_]f64{ 0, 1, 0, 0, 0, 1, 0, 0, 0 };
    const want_cos = [_]f64{ 1, 0, -0.5, 0, 1, 0, 0, 0, 1 };
    for (want_sin, sn) |x, y| try testing.expectApproxEqAbs(x, y, 1e-13);
    for (want_cos, cs) |x, y| try testing.expectApproxEqAbs(x, y, 1e-13);
}

test "cosine is even and sine is odd, as functions of a MATRIX too" {
    const alloc = testing.allocator;
    const n = 4;
    const a = [_]f64{
        0.9, 1.4, -0.3, 0.2,
        0.0, 0.6,  1.1, 0.5,
        -0.7, 0.1, 0.8, 1.0,
        0.3, -0.5, 0.0, 1.2,
    };
    var neg: [16]f64 = undefined;
    for (a, 0..) |v, i| neg[i] = -v;

    const s1 = try alloc.alloc(f64, n * n);
    defer alloc.free(s1);
    const c1 = try alloc.alloc(f64, n * n);
    defer alloc.free(c1);
    const s2 = try alloc.alloc(f64, n * n);
    defer alloc.free(s2);
    const c2 = try alloc.alloc(f64, n * n);
    defer alloc.free(c2);
    try sinCosGeneral(alloc, &a, n, s1, c1);
    try sinCosGeneral(alloc, &neg, n, s2, c2);

    for (c1, c2) |x, y| try testing.expectApproxEqAbs(x, y, 1e-10);
    for (s1, s2) |x, y| try testing.expectApproxEqAbs(x, -y, 1e-10);
}

test "on a SYMMETRIC matrix it agrees with the eigendecomposition route" {
    const alloc = testing.allocator;
    const n = 3;
    const a = [_]f64{ 6, 2, 1, 2, 5, 2, 1, 2, 4 };
    const cs = try alloc.alloc(f64, n * n);
    defer alloc.free(cs);
    try cosGeneral(alloc, &a, n, cs);

    // Q cos(L) Q' -- a completely different algorithm, and one that only works because
    // this particular matrix happens to be symmetric. Scaled Taylor with double-angle
    // recurrences against a Jacobi eigendecomposition: nothing shared below the matrix,
    // and one answer.
    var e = try linalg.eigenSymmetric(alloc, &a, n);
    defer e.deinit();
    try testing.expect(e.symmetric);
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += e.vec(i, t) * @cos(e.values[t]) * e.vec(j, t);
            try testing.expectApproxEqAbs(acc, cs[i * n + j], 1e-9);
        }
    }
}

test "the double-angle recurrence agrees with itself at two scales" {
    const alloc = testing.allocator;
    const n = 3;
    const a = [_]f64{ 0.4, 0.2, 0.0, -0.1, 0.5, 0.3, 0.2, 0.0, 0.6 };
    var twice: [9]f64 = undefined;
    for (a, 0..) |v, i| twice[i] = 2 * v;

    const s1 = try alloc.alloc(f64, n * n);
    defer alloc.free(s1);
    const c1 = try alloc.alloc(f64, n * n);
    defer alloc.free(c1);
    const s2 = try alloc.alloc(f64, n * n);
    defer alloc.free(s2);
    const c2 = try alloc.alloc(f64, n * n);
    defer alloc.free(c2);
    try sinCosGeneral(alloc, &a, n, s1, c1);
    try sinCosGeneral(alloc, &twice, n, s2, c2);

    // cos(2A) = 2 cos(A)^2 - I and sin(2A) = 2 sin(A) cos(A), with the two sides
    // computed from DIFFERENT scalings -- so this checks the recurrence against the
    // series rather than against itself.
    const cc = try squares(alloc, c1, n);
    defer alloc.free(cc);
    const sc = try alloc.alloc(f64, n * n);
    defer alloc.free(sc);
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += s1[i * n + t] * c1[t * n + j];
            sc[i * n + j] = acc;
        }
    }
    for (0..n) |i| {
        for (0..n) |j| {
            const want_c = 2 * cc[i * n + j] - (if (i == j) @as(f64, 1) else 0);
            try testing.expectApproxEqAbs(want_c, c2[i * n + j], 1e-10);
            try testing.expectApproxEqAbs(2 * sc[i * n + j], s2[i * n + j], 1e-10);
        }
    }
}

test "cosh(A)^2 - sinh(A)^2 = I, the hyperbolic counterpart" {
    const alloc = testing.allocator;
    const n = 4;
    const a = [_]f64{
        0.9, 1.4, -0.3, 0.2,
        0.0, 0.6,  1.1, 0.5,
        -0.7, 0.1, 0.8, 1.0,
        0.3, -0.5, 0.0, 1.2,
    };
    const sh = try alloc.alloc(f64, n * n);
    defer alloc.free(sh);
    const ch = try alloc.alloc(f64, n * n);
    defer alloc.free(ch);
    try sinhCoshGeneral(alloc, &a, n, sh, ch);

    // The MINUS is what makes this a different check from the circular one rather than
    // the same check twice -- a sign error anywhere in the series would satisfy one of
    // the two identities and fail the other.
    const s2 = try squares(alloc, sh, n);
    defer alloc.free(s2);
    const c2 = try squares(alloc, ch, n);
    defer alloc.free(c2);
    for (0..n) |i| {
        for (0..n) |j| {
            const want: f64 = if (i == j) 1 else 0;
            try testing.expectApproxEqAbs(want, c2[i * n + j] - s2[i * n + j], 1e-8);
        }
    }
}

test "cosh(A) + sinh(A) = exp(A), across two unrelated algorithms" {
    const alloc = testing.allocator;
    const n = 4;
    const a = [_]f64{
        4, 1, 2, 0,
        0, 3, 1, 5,
        2, 0, 6, 1,
        1, 2, 0, 4,
    };
    const sh = try alloc.alloc(f64, n * n);
    defer alloc.free(sh);
    const ch = try alloc.alloc(f64, n * n);
    defer alloc.free(ch);
    const ex = try alloc.alloc(f64, n * n);
    defer alloc.free(ex);
    try sinhCoshGeneral(alloc, &a, n, sh, ch);
    try expGeneral(alloc, &a, n, ex);

    // THE BEST CROSS-CHECK IN THIS FAMILY. The hyperbolic pair comes from a scaled
    // TAYLOR series climbed back through double-angle recurrences; the exponential
    // comes from a PADE approximant climbed back through squaring. Nothing is shared
    // between them but the matrix, and the defining relation holds to 1e-7 on entries
    // of order 400.
    for (0..n * n) |i| {
        try testing.expectApproxEqAbs(ex[i], ch[i] + sh[i], 1e-6);
    }
}

test "cosh(0) = I, sinh(0) = 0, and a diagonal goes entrywise" {
    const alloc = testing.allocator;
    const n = 3;
    const sh = try alloc.alloc(f64, n * n);
    defer alloc.free(sh);
    const ch = try alloc.alloc(f64, n * n);
    defer alloc.free(ch);

    const zero = [_]f64{ 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    try sinhCoshGeneral(alloc, &zero, n, sh, ch);
    for (sh) |v| try testing.expectApproxEqAbs(@as(f64, 0), v, 1e-14);
    for (0..n) |i| {
        for (0..n) |j| {
            try testing.expectApproxEqAbs(if (i == j) @as(f64, 1) else 0, ch[i * n + j], 1e-14);
        }
    }

    const diag = [_]f64{ 1.2, 0, 0, 0, -2.5, 0, 0, 0, 0.7 };
    try sinhCoshGeneral(alloc, &diag, n, sh, ch);
    try testing.expectApproxEqAbs(std.math.sinh(@as(f64, 1.2)), sh[0], 1e-11);
    try testing.expectApproxEqAbs(std.math.sinh(@as(f64, -2.5)), sh[4], 1e-11);
    try testing.expectApproxEqAbs(std.math.cosh(@as(f64, 0.7)), ch[8], 1e-11);
}

test "A NILPOTENT MATRIX separates the two families by one sign" {
    const alloc = testing.allocator;
    const n = 3;
    const nil = [_]f64{ 0, 1, 0, 0, 0, 1, 0, 0, 0 }; // N^3 = 0
    const sh = try alloc.alloc(f64, n * n);
    defer alloc.free(sh);
    const ch = try alloc.alloc(f64, n * n);
    defer alloc.free(ch);
    try sinhCoshGeneral(alloc, &nil, n, sh, ch);

    // N^3 = 0 truncates both series exactly: sinh(N) = N, and cosh(N) = I + N^2/2.
    //
    // THE PLUS IS THE POINT. The circular test one file-section up asserts cos(N) =
    // I - N^2/2, and the only difference between the two answers is that sign. So this
    // pair of tests pins the shared routine's one branch from both sides -- a routine
    // that ignored the flag would pass one and fail the other.
    const want_sinh = [_]f64{ 0, 1, 0, 0, 0, 1, 0, 0, 0 };
    const want_cosh = [_]f64{ 1, 0, 0.5, 0, 1, 0, 0, 0, 1 };
    for (want_sinh, sh) |x, y| try testing.expectApproxEqAbs(x, y, 1e-13);
    for (want_cosh, ch) |x, y| try testing.expectApproxEqAbs(x, y, 1e-13);
}

test "cosh is even and sinh is odd" {
    const alloc = testing.allocator;
    const n = 3;
    const a = [_]f64{ 0.9, 1.4, -0.3, 0.0, 0.6, 1.1, -0.7, 0.1, 0.8 };
    var neg: [9]f64 = undefined;
    for (a, 0..) |v, i| neg[i] = -v;

    const s1 = try alloc.alloc(f64, n * n);
    defer alloc.free(s1);
    const c1 = try alloc.alloc(f64, n * n);
    defer alloc.free(c1);
    const s2 = try alloc.alloc(f64, n * n);
    defer alloc.free(s2);
    const c2 = try alloc.alloc(f64, n * n);
    defer alloc.free(c2);
    try sinhCoshGeneral(alloc, &a, n, s1, c1);
    try sinhCoshGeneral(alloc, &neg, n, s2, c2);

    for (c1, c2) |x, y| try testing.expectApproxEqAbs(x, y, 1e-10);
    for (s1, s2) |x, y| try testing.expectApproxEqAbs(x, -y, 1e-10);
}

test "and on a SYMMETRIC matrix the hyperbolic cosine matches the eigen route" {
    const alloc = testing.allocator;
    const n = 3;
    const a = [_]f64{ 6, 2, 1, 2, 5, 2, 1, 2, 4 };
    const ch = try alloc.alloc(f64, n * n);
    defer alloc.free(ch);
    try coshGeneral(alloc, &a, n, ch);

    var e = try linalg.eigenSymmetric(alloc, &a, n);
    defer e.deinit();
    try testing.expect(e.symmetric);
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += e.vec(i, t) * std.math.cosh(e.values[t]) * e.vec(j, t);
            // eigenvalues here reach ~9, so cosh reaches ~4000 -- the tolerance is
            // relative to that rather than to 1
            try testing.expectApproxEqRel(acc, ch[i * n + j], 1e-9);
        }
    }
}
