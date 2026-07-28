const std = @import("std");
const matrix = @import("matrix.zig");
const linalg = @import("linalg.zig");
const nmm = @import("neural_matmul.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;

// Shadow the real cpointer functions: store/resolve via handle table.
fn rcp(p: *anyopaque, ptr: ?*anyopaque, _: [*:0]const u8) void {
    R.retHandle(p, ptr);
}

fn gcp(p: *anyopaque, n: c_int, _: [*:0]const u8) ?*anyopaque {
    return R.getHandle(p, n);
}

const MH: [*:0]const u8 = "StzMatrixHandle";

fn getM(p: *anyopaque, n: c_int) ?*matrix.StzMatrix {
    const ptr = gcp(p, n, MH);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn getMC(p: *anyopaque, n: c_int) ?*const matrix.StzMatrix {
    const ptr = gcp(p, n, MH);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn ring_New(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_new(@intFromFloat(g(p, 1)), @intFromFloat(g(p, 2)));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_Free(p: *anyopaque) callconv(.c) void {
    const raw = R.releaseHandle(p, 1);
    if (raw) |ptr| {
        const h: ?*matrix.StzMatrix = @ptrCast(@alignCast(ptr));
        matrix.stz_matrix_free(h);
    }
}
fn ring_Rows(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(matrix.stz_matrix_rows(getMC(p, 1))));
}
fn ring_Cols(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(matrix.stz_matrix_cols(getMC(p, 1))));
}
fn ring_Set(p: *anyopaque) callconv(.c) void {
    matrix.stz_matrix_set(getM(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)), g(p, 4));
}
fn ring_Get(p: *anyopaque) callconv(.c) void {
    rn(p, matrix.stz_matrix_get(getMC(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3))));
}
fn ring_Sum(p: *anyopaque) callconv(.c) void {
    rn(p, matrix.stz_matrix_sum(getMC(p, 1)));
}
fn ring_Min(p: *anyopaque) callconv(.c) void {
    rn(p, matrix.stz_matrix_min(getMC(p, 1)));
}
fn ring_Max(p: *anyopaque) callconv(.c) void {
    rn(p, matrix.stz_matrix_max(getMC(p, 1)));
}
fn ring_Mean(p: *anyopaque) callconv(.c) void {
    rn(p, matrix.stz_matrix_mean(getMC(p, 1)));
}
fn ring_AddScalar(p: *anyopaque) callconv(.c) void {
    matrix.stz_matrix_add_scalar(getM(p, 1), g(p, 2));
}
fn ring_MultiplyScalar(p: *anyopaque) callconv(.c) void {
    matrix.stz_matrix_multiply_scalar(getM(p, 1), g(p, 2));
}
// args: handle, op(0=add,1=mul), r1, r2, c1, c2, val  (rows/cols 1-based, inclusive)
fn ring_UpdateRegion(p: *anyopaque) callconv(.c) void {
    matrix.stz_matrix_update_region(getM(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)), @intFromFloat(g(p, 4)), @intFromFloat(g(p, 5)), @intFromFloat(g(p, 6)), g(p, 7));
}
fn ring_AddMatrix(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(matrix.stz_matrix_add_matrix(getM(p, 1), getMC(p, 2))));
}
fn ring_Multiply(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_multiply(getMC(p, 1), getMC(p, 2));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_MulGgml(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(nmm.stz_neural_matmul_into(getMC(p, 1), getMC(p, 2), getM(p, 3))));
}
fn ring_Transpose(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_transpose(getMC(p, 1));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_Determinant(p: *anyopaque) callconv(.c) void {
    rn(p, matrix.stz_matrix_determinant(getMC(p, 1)));
}
fn ring_Inverse(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_inverse(getMC(p, 1));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_Power(p: *anyopaque) callconv(.c) void {
    matrix.stz_matrix_power(getM(p, 1), g(p, 2));
}
// Solve Ax = b. Both arguments are matrix handles (A square n*n, b n*1) and the
// result is a new n*1 handle, or NULL for a singular A or mismatched shapes --
// the same handle-in/handle-out shape as Inverse above.
fn ring_Solve(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_solve(getMC(p, 1), getMC(p, 2));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
// Least squares for an overdetermined system: A is an m*n handle, b is m*1, the
// result is n*1 (or NULL for rank deficiency / bad shape).
fn ring_LeastSquares(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_least_squares(getMC(p, 1), getMC(p, 2));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_Cholesky(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_cholesky(getMC(p, 1));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_EigenValues(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_eigenvalues(getMC(p, 1));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_EigenVectors(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_eigenvectors(getMC(p, 1));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_ConditionNumber(p: *anyopaque) callconv(.c) void {
    rn(p, matrix.stz_matrix_condition_number(getMC(p, 1)));
}
fn ring_Rank(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(matrix.stz_matrix_rank(getMC(p, 1))));
}
fn ring_SingularValues(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_singular_values(getMC(p, 1));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_RankGeneral(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(matrix.stz_matrix_rank_general(getMC(p, 1))));
}
fn ring_ConditionGeneral(p: *anyopaque) callconv(.c) void {
    rn(p, matrix.stz_matrix_condition_general(getMC(p, 1)));
}
fn ring_PseudoInverse(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_pseudo_inverse(getMC(p, 1));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_LowRank(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_low_rank(getMC(p, 1), @intFromFloat(g(p, 2)));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_MatrixPower(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_matrix_power(getMC(p, 1), g(p, 2));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_EigenReconstruct(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_eigen_reconstruct(getMC(p, 1), @intFromFloat(g(p, 2)));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_CholeskyInverse(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_cholesky_inverse(getMC(p, 1));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_CholeskyFactorInverse(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_cholesky_factor_inverse(getMC(p, 1));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_QrInverse(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_qr_inverse(getMC(p, 1));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_LuInverse(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_lu_inverse(getMC(p, 1));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_MinNormSolve(p: *anyopaque) callconv(.c) void {
    const ptr = matrix.stz_matrix_min_norm_solve(getMC(p, 1), getMC(p, 2));
    if (ptr) |m| rcp(p, @ptrCast(m), MH) else rcp(p, @ptrFromInt(0), MH);
}
fn ring_IsPositiveDefinite(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(matrix.stz_matrix_is_positive_definite(getMC(p, 1))));
}

fn ring_NewFromList(p: *anyopaque) callconv(.c) void {
    const nRows: usize = @intFromFloat(g(p, 1));
    const nCols: usize = @intFromFloat(g(p, 2));
    if (nRows == 0 or nCols == 0) {
        rcp(p, @ptrFromInt(0), MH);
        return;
    }
    if (R.ring_vm_api_islist(p, 3) == 0) {
        rcp(p, @ptrFromInt(0), MH);
        return;
    }
    const pOuterList = R.ring_vm_api_getlist(p, 3) orelse {
        rcp(p, @ptrFromInt(0), MH);
        return;
    };
    const m = matrix.stz_matrix_new(@intCast(nRows), @intCast(nCols)) orelse {
        rcp(p, @ptrFromInt(0), MH);
        return;
    };
    var r: usize = 0;
    while (r < nRows) : (r += 1) {
        const ri: c_uint = @intCast(r + 1);
        if (R.ring_list_islist_gc(null, pOuterList, ri) == 0) continue;
        const pRowList = R.ring_list_getlist_gc(null, pOuterList, ri) orelse continue;
        var c: usize = 0;
        while (c < nCols) : (c += 1) {
            const ci: c_uint = @intCast(c + 1);
            if (R.ring_list_isnumber_gc(null, pRowList, ci) == 0) continue;
            const pItem = R.ring_list_getitem_gc(null, pRowList, ci) orelse continue;
            const val = R.ring_item_getnumber(pItem);
            matrix.stz_matrix_set(m, @intCast(r), @intCast(c), val);
        }
    }
    rcp(p, @ptrCast(m), MH);
}

// ─── THE FULL SVD, ANY SHAPE (phase 7) ───────────────────────────────────────
//
//   StzEngineMatrixSvdFull(handle) -> [ converged, k, U (m*k), S (k), V (n*k) ]
//
// Until now only the singular VALUES reached Ring, and only for m >= n. Both are
// lifted. The wide case is NOT "transpose it and remember": the singular values of
// A and A' agree but U and V SWAP, so leaving the transpose to the caller produces
// a decomposition that multiplies back to A' rather than to A.
fn ring_SvdFull(p: *anyopaque) callconv(.c) void {
    const mat = getMC(p, 1) orelse {
        rn(p, 0);
        return;
    };
    if (mat.rows == 0 or mat.cols == 0) {
        rn(p, 0);
        return;
    }
    var d = linalg.svdAnyShape(std.heap.c_allocator, mat.data, mat.rows, mat.cols) catch {
        rn(p, 0);
        return;
    };
    defer d.deinit();

    const k = @min(mat.rows, mat.cols);
    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, if (d.converged) 1 else 0);
    R.ring_list_adddouble(out, @floatFromInt(k));
    for (0..mat.rows * k) |i| R.ring_list_adddouble(out, d.u[i]);
    for (0..k) |i| R.ring_list_adddouble(out, d.values[i]);
    for (0..mat.cols * k) |i| R.ring_list_adddouble(out, d.v[i]);
    R.ring_vm_api_retlist(p, out);
}

pub fn ringlib_init(p: *anyopaque) callconv(.c) void {
    const funcs = [_]R.Reg{
        .{ .name = "stzengine" ++ "matrixsvdfull", .func = &ring_SvdFull },
        .{ .name = "stzengine" ++ "matrixnew", .func = &ring_New },
        .{ .name = "stzengine" ++ "matrixfree", .func = &ring_Free },
        .{ .name = "stzengine" ++ "matrixrows", .func = &ring_Rows },
        .{ .name = "stzengine" ++ "matrixcols", .func = &ring_Cols },
        .{ .name = "stzengine" ++ "matrixset", .func = &ring_Set },
        .{ .name = "stzengine" ++ "matrixget", .func = &ring_Get },
        .{ .name = "stzengine" ++ "matrixsum", .func = &ring_Sum },
        .{ .name = "stzengine" ++ "matrixmin", .func = &ring_Min },
        .{ .name = "stzengine" ++ "matrixmax", .func = &ring_Max },
        .{ .name = "stzengine" ++ "matrixmean", .func = &ring_Mean },
        .{ .name = "stzengine" ++ "matrixaddscalar", .func = &ring_AddScalar },
        .{ .name = "stzengine" ++ "matrixmultiplyscalar", .func = &ring_MultiplyScalar },
        .{ .name = "stzengine" ++ "matrixupdateregion", .func = &ring_UpdateRegion },
        .{ .name = "stzengine" ++ "matrixaddmatrix", .func = &ring_AddMatrix },
        .{ .name = "stzengine" ++ "matrixmultiply", .func = &ring_Multiply },
        .{ .name = "stzengine" ++ "matrixtranspose", .func = &ring_Transpose },
        .{ .name = "stzengine" ++ "matrixmulggml", .func = &ring_MulGgml },
        .{ .name = "stzengine" ++ "matrixdeterminant", .func = &ring_Determinant },
        .{ .name = "stzengine" ++ "matrixinverse", .func = &ring_Inverse },
        .{ .name = "stzengine" ++ "matrixsolve", .func = &ring_Solve },
        .{ .name = "stzengine" ++ "matrixleastsquares", .func = &ring_LeastSquares },
        .{ .name = "stzengine" ++ "matrixcholesky", .func = &ring_Cholesky },
        .{ .name = "stzengine" ++ "matrixeigenvalues", .func = &ring_EigenValues },
        .{ .name = "stzengine" ++ "matrixeigenvectors", .func = &ring_EigenVectors },
        .{ .name = "stzengine" ++ "matrixconditionnumber", .func = &ring_ConditionNumber },
        .{ .name = "stzengine" ++ "matrixrank", .func = &ring_Rank },
        .{ .name = "stzengine" ++ "matrixsingularvalues", .func = &ring_SingularValues },
        .{ .name = "stzengine" ++ "matrixrankgeneral", .func = &ring_RankGeneral },
        .{ .name = "stzengine" ++ "matrixconditiongeneral", .func = &ring_ConditionGeneral },
        .{ .name = "stzengine" ++ "matrixpseudoinverse", .func = &ring_PseudoInverse },
        .{ .name = "stzengine" ++ "matrixlowrank", .func = &ring_LowRank },
        .{ .name = "stzengine" ++ "matrixmatrixpower", .func = &ring_MatrixPower },
        .{ .name = "stzengine" ++ "matrixcholeskyinverse", .func = &ring_CholeskyInverse },
        .{ .name = "stzengine" ++ "matrixqrinverse", .func = &ring_QrInverse },
        .{ .name = "stzengine" ++ "matrixluinverse", .func = &ring_LuInverse },
        .{ .name = "stzengine" ++ "matrixcholeskyfactorinverse", .func = &ring_CholeskyFactorInverse },
        .{ .name = "stzengine" ++ "matrixeigenreconstruct", .func = &ring_EigenReconstruct },
        .{ .name = "stzengine" ++ "matrixminnormsolve", .func = &ring_MinNormSolve },
        .{ .name = "stzengine" ++ "matrixispositivedefinite", .func = &ring_IsPositiveDefinite },
        .{ .name = "stzengine" ++ "matrixpower", .func = &ring_Power },
        .{ .name = "stzengine" ++ "matrixnewfromlist", .func = &ring_NewFromList },
    };
    R.registerAll(p, &funcs);
}
