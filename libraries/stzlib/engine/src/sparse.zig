//! Compressed Sparse Row matrices.
//!
//! WHY CSR AND NOT COO OR CSC. Every operation here walks the matrix a
//! ROW at a time -- y = A*x takes one row per output element, C = A*B
//! takes one row of A per row of C -- and CSR is the layout that makes a
//! row a contiguous run. COO would need a sort or a scatter per pass;
//! CSC would make the row loop a search.
//!
//! WHY THIS LIVES IN THE MATRIX DLL. The engine's handle table is
//! STATIC STATE COMPILED INTO EACH DOMAIN DLL, so a handle minted in one
//! cannot be resolved in another. Sparse operations consume and produce
//! dense StzMatrix handles, so they must be registered in the same
//! library those handles come from. A separate stz_sparse.dll would
//! compile, link, and then silently resolve the wrong pointer.
//!
//! THE ONE SEMANTIC DECISION: what counts as zero. Dropping a stored
//! value is not a representation choice, it is an arithmetic one --
//! 0 * inf is NaN, so a matrix holding non-finite values is NOT
//! interchangeable with its sparse form. fromDense takes the threshold
//! as a PARAMETER and defaults to exact zero, so the caller decides
//! whether "small" means "absent" rather than inheriting a library's
//! opinion.

const std = @import("std");
const matrix = @import("matrix.zig");

pub const StzSparse = struct {
    /// The stored (nonzero) values, row by row.
    values: []f64,
    /// Column index of each stored value, ascending within a row.
    col_idx: []usize,
    /// row_ptr[i] .. row_ptr[i+1] is row i's slice of values/col_idx.
    /// Length is rows+1, which is what makes the last row terminate
    /// without a special case.
    row_ptr: []usize,
    rows: usize,
    cols: usize,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *StzSparse) void {
        self.allocator.free(self.values);
        self.allocator.free(self.col_idx);
        self.allocator.free(self.row_ptr);
        self.allocator.destroy(self);
    }

    pub fn nnz(self: *const StzSparse) usize {
        return self.values.len;
    }

    /// Stored fraction. 1.0 means nothing was dropped; the point of the
    /// type is for this to be small.
    pub fn density(self: *const StzSparse) f64 {
        const total = self.rows * self.cols;
        if (total == 0) return 0;
        return @as(f64, @floatFromInt(self.values.len)) / @as(f64, @floatFromInt(total));
    }
};

/// Build CSR from a dense matrix, dropping every |v| <= tol.
///
/// Two passes on purpose: count first, then fill. A single pass with a
/// growing ArrayList would reallocate through the whole matrix, and the
/// count is cheap next to the copy.
pub fn fromDense(alloc: std.mem.Allocator, m: *const matrix.StzMatrix, tol: f64) !*StzSparse {
    var count: usize = 0;
    for (m.data) |v| {
        if (@abs(v) > tol) count += 1;
    }

    const sp = try alloc.create(StzSparse);
    errdefer alloc.destroy(sp);
    sp.* = .{
        .values = try alloc.alloc(f64, count),
        .col_idx = try alloc.alloc(usize, count),
        .row_ptr = try alloc.alloc(usize, m.rows + 1),
        .rows = m.rows,
        .cols = m.cols,
        .allocator = alloc,
    };

    var at: usize = 0;
    for (0..m.rows) |i| {
        sp.row_ptr[i] = at;
        const base = i * m.cols;
        for (0..m.cols) |j| {
            const v = m.data[base + j];
            if (@abs(v) > tol) {
                sp.values[at] = v;
                sp.col_idx[at] = j;
                at += 1;
            }
        }
    }
    sp.row_ptr[m.rows] = at;
    return sp;
}

/// Rebuild the dense form. Round-tripping at tol=0 returns the original
/// bit for bit, which is what the guard uses to prove the layout stores
/// what it claims.
pub fn toDense(alloc: std.mem.Allocator, sp: *const StzSparse) !*matrix.StzMatrix {
    const out = try matrix.StzMatrix.init(alloc, sp.rows, sp.cols);
    for (0..sp.rows) |i| {
        const base = i * sp.cols;
        var k = sp.row_ptr[i];
        while (k < sp.row_ptr[i + 1]) : (k += 1) {
            out.data[base + sp.col_idx[k]] = sp.values[k];
        }
    }
    return out;
}

/// y = A*x, A sparse m*n, x dense n, y dense m.
///
/// The kernel graph work actually wants: one PageRank or power-method
/// step is exactly this, and the cost is O(nnz) rather than O(n^2).
pub fn spmv(sp: *const StzSparse, x: []const f64, y: []f64) void {
    for (0..sp.rows) |i| {
        var acc: f64 = 0;
        var k = sp.row_ptr[i];
        while (k < sp.row_ptr[i + 1]) : (k += 1) {
            acc += sp.values[k] * x[sp.col_idx[k]];
        }
        y[i] = acc;
    }
}

/// C = A*B with A sparse (m*k) and B dense (k*n), C dense (m*n).
///
/// Row-of-A outer, so the inner loop walks a ROW of B and a ROW of C
/// contiguously -- the same access pattern that took the dense kernel
/// from 0.90 to 12.03 GFLOP/s, and vectorised the same way.
///
/// ARITHMETIC vs THE DENSE PRODUCT: identical for finite inputs. Each
/// output element sums its terms in ascending k either way; sparse only
/// omits terms whose factor is exactly zero, and adding 0 to a finite
/// accumulator changes nothing. It is NOT identical when B holds inf or
/// NaN, because 0 * inf is NaN -- an omitted term would have poisoned
/// the row. That asymmetry is inherent to sparsity, not a shortcut
/// taken here, and it is why the dense kernel refuses the same skip.
const VEC_WIDTH = 4;
const Vec = @Vector(VEC_WIDTH, f64);

pub fn spmm(alloc: std.mem.Allocator, sp: *const StzSparse, b: *const matrix.StzMatrix) !?*matrix.StzMatrix {
    if (sp.cols != b.rows) return null;
    const n = b.cols;
    const out = try matrix.StzMatrix.init(alloc, sp.rows, n);

    for (0..sp.rows) |i| {
        const c_row = out.data[i * n .. i * n + n];
        var k = sp.row_ptr[i];
        while (k < sp.row_ptr[i + 1]) : (k += 1) {
            const a = sp.values[k];
            const b_row = b.data[sp.col_idx[k] * n .. sp.col_idx[k] * n + n];
            const splat: Vec = @splat(a);
            var j: usize = 0;
            while (j + VEC_WIDTH <= n) : (j += VEC_WIDTH) {
                const bvec: Vec = b_row[j..][0..VEC_WIDTH].*;
                const cvec: Vec = c_row[j..][0..VEC_WIDTH].*;
                c_row[j..][0..VEC_WIDTH].* = cvec + splat * bvec;
            }
            while (j < n) : (j += 1) c_row[j] += a * b_row[j];
        }
    }
    return out;
}

test "csr round-trips and multiplies like the dense form" {
    const alloc = std.testing.allocator;
    const m = try matrix.StzMatrix.init(alloc, 3, 3);
    defer m.deinit();
    // a deliberately sparse matrix: 4 of 9 stored
    m.setAt(0, 0, 2.0);
    m.setAt(0, 2, -1.0);
    m.setAt(1, 1, 5.0);
    m.setAt(2, 0, 3.0);

    const sp = try fromDense(alloc, m, 0.0);
    defer sp.deinit();
    try std.testing.expectEqual(@as(usize, 4), sp.nnz());

    const back = try toDense(alloc, sp);
    defer back.deinit();
    for (m.data, back.data) |a, b| try std.testing.expectEqual(a, b);

    // spmv against a hand-computed answer
    var x = [_]f64{ 1.0, 2.0, 3.0 };
    var y = [_]f64{ 0.0, 0.0, 0.0 };
    spmv(sp, &x, &y);
    try std.testing.expectEqual(@as(f64, -1.0), y[0]); // 2*1 + (-1)*3
    try std.testing.expectEqual(@as(f64, 10.0), y[1]); // 5*2
    try std.testing.expectEqual(@as(f64, 3.0), y[2]); // 3*1

    // spmm must agree with the dense kernel BIT FOR BIT on finite data
    const dense_prod = matrix.stz_matrix_multiply(m, m).?;
    defer dense_prod.deinit();
    const sparse_prod = (try spmm(alloc, sp, m)).?;
    defer sparse_prod.deinit();
    for (dense_prod.data, sparse_prod.data) |a, b| try std.testing.expectEqual(a, b);
}
