const matrix = @import("matrix.zig");
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

pub fn ringlib_init(p: *anyopaque) callconv(.c) void {
    const funcs = [_]R.Reg{
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
        .{ .name = "stzengine" ++ "matrixdeterminant", .func = &ring_Determinant },
        .{ .name = "stzengine" ++ "matrixinverse", .func = &ring_Inverse },
        .{ .name = "stzengine" ++ "matrixpower", .func = &ring_Power },
        .{ .name = "stzengine" ++ "matrixnewfromlist", .func = &ring_NewFromList },
    };
    R.registerAll(p, &funcs);
}
