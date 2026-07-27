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
