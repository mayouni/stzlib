const std = @import("std");
const table = @import("table.zig");
const pivot = @import("pivot.zig");
const value = @import("value.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;

// Shadow the real cpointer functions: store/resolve via handle table.
fn rcp(p: *anyopaque, ptr: ?*anyopaque, _: [*:0]const u8) void {
    R.retHandle(p, ptr);
}

fn gcp(p: *anyopaque, n: c_int, _: [*:0]const u8) ?*anyopaque {
    return R.getHandle(p, n);
}

const HT: [*:0]const u8 = "StzTableHandle";
const HV: [*:0]const u8 = "StzValueHandle";

fn getT(p: *anyopaque, n: c_int) ?*table.StzTable {
    const ptr = gcp(p, n, HT);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn getTC(p: *anyopaque, n: c_int) ?*const table.StzTable {
    const ptr = gcp(p, n, HT);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn getV(p: *anyopaque, n: c_int) ?*const value.StzValue {
    const ptr = gcp(p, n, HV);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

// Lifecycle
fn ring_New(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(table.stz_table_new()), HT);
}
fn ring_Free(p: *anyopaque) callconv(.c) void {
    const raw = R.releaseHandle(p, 1);
    if (raw) |ptr| {
        const h: ?*table.StzTable = @ptrCast(@alignCast(ptr));
        table.stz_table_free(h);
    }
}

// Structure
fn ring_NumCols(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(table.stz_table_num_cols(getTC(p, 1))));
}
fn ring_NumRows(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(table.stz_table_num_rows(getTC(p, 1))));
}
fn ring_AddCol(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(table.stz_table_add_col(getT(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_RemoveCol(p: *anyopaque) callconv(.c) void {
    table.stz_table_remove_col(getT(p, 1), @intFromFloat(g(p, 2)));
}
fn ring_FindCol(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(table.stz_table_find_col(getTC(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_ColName(p: *anyopaque) callconv(.c) void {
    const ptr = table.stz_table_col_name(getTC(p, 1), @intFromFloat(g(p, 2)));
    const len = table.stz_table_col_name_len(getTC(p, 1), @intFromFloat(g(p, 2)));
    if (ptr) |p2| rs2(p, p2, @intCast(len)) else rs(p, "");
}
fn ring_RenameCol(p: *anyopaque) callconv(.c) void {
    table.stz_table_rename_col(getT(p, 1), @intFromFloat(g(p, 2)), gs(p, 3), @intCast(gss(p, 3)));
}

// Rows
fn ring_AddRow(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(table.stz_table_add_row(getT(p, 1))));
}
fn ring_RemoveRow(p: *anyopaque) callconv(.c) void {
    table.stz_table_remove_row(getT(p, 1), @intFromFloat(g(p, 2)));
}

// Cell access
fn ring_SetCellInt(p: *anyopaque) callconv(.c) void {
    table.stz_table_set_cell_int(getT(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)), @intFromFloat(g(p, 4)));
}
fn ring_SetCellFloat(p: *anyopaque) callconv(.c) void {
    table.stz_table_set_cell_float(getT(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)), g(p, 4));
}
fn ring_SetCellString(p: *anyopaque) callconv(.c) void {
    table.stz_table_set_cell_string(getT(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)), gs(p, 4), @intCast(gss(p, 4)));
}
fn ring_GetCellInt(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(table.stz_table_get_cell_int(getTC(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)))));
}
fn ring_GetCellFloat(p: *anyopaque) callconv(.c) void {
    rn(p, table.stz_table_get_cell_float(getTC(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3))));
}
fn ring_GetCellString(p: *anyopaque) callconv(.c) void {
    const col: i64 = @intFromFloat(g(p, 2));
    const row: i64 = @intFromFloat(g(p, 3));
    const ptr = table.stz_table_get_cell_string(getTC(p, 1), col, row);
    const len = table.stz_table_get_cell_string_len(getTC(p, 1), col, row);
    if (ptr) |p2| rs2(p, p2, @intCast(len)) else rs(p, "");
}
fn ring_GetCellType(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(table.stz_table_get_cell_type(getTC(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)))));
}

// Sort / order
fn ring_SortOn(p: *anyopaque) callconv(.c) void {
    table.stz_table_sort_on(getT(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)));
}
fn ring_SwapRows(p: *anyopaque) callconv(.c) void {
    table.stz_table_swap_rows(getT(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)));
}
fn ring_ReverseRows(p: *anyopaque) callconv(.c) void {
    table.stz_table_reverse_rows(getT(p, 1));
}

// Aggregation
fn ring_SumCol(p: *anyopaque) callconv(.c) void {
    rn(p, table.stz_table_sum_col(getTC(p, 1), @intFromFloat(g(p, 2))));
}
fn ring_SumColRange(p: *anyopaque) callconv(.c) void {
    rn(p, table.stz_table_sum_col_range(getTC(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)), @intFromFloat(g(p, 4))));
}
fn ring_AvgCol(p: *anyopaque) callconv(.c) void {
    rn(p, table.stz_table_avg_col(getTC(p, 1), @intFromFloat(g(p, 2))));
}
fn ring_MinCol(p: *anyopaque) callconv(.c) void {
    rn(p, table.stz_table_min_col(getTC(p, 1), @intFromFloat(g(p, 2))));
}
fn ring_MaxCol(p: *anyopaque) callconv(.c) void {
    rn(p, table.stz_table_max_col(getTC(p, 1), @intFromFloat(g(p, 2))));
}
fn ring_ProductCol(p: *anyopaque) callconv(.c) void {
    rn(p, table.stz_table_product_col(getTC(p, 1), @intFromFloat(g(p, 2))));
}
fn ring_CountNonNull(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(table.stz_table_count_non_null(getTC(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_CountInCol(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(table.stz_table_count_in_col(getTC(p, 1), @intFromFloat(g(p, 2)), getV(p, 3))));
}
fn ring_ContainsInCol(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(table.stz_table_contains_in_col(getTC(p, 1), @intFromFloat(g(p, 2)), getV(p, 3))));
}

// Fill
fn ring_FillInt(p: *anyopaque) callconv(.c) void {
    table.stz_table_fill_int(getT(p, 1), @intFromFloat(g(p, 2)));
}
fn ring_FillFloat(p: *anyopaque) callconv(.c) void {
    table.stz_table_fill_float(getT(p, 1), g(p, 2));
}

// Clone / sub / group / filter
fn ring_Clone(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(table.stz_table_clone(getTC(p, 1))), HT);
}
fn ring_GroupBy(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(table.stz_table_group_by(getTC(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)), @intFromFloat(g(p, 4)))), HT);
}
fn ring_FilterRows(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(table.stz_table_filter_rows(getTC(p, 1), @intFromFloat(g(p, 2)), getV(p, 3))), HT);
}

// Find cell: returns comma-separated "col,row;col,row;..." (1-based) positions
fn ring_FindCellStringCS(p: *anyopaque) callconv(.c) void {
    const t = getTC(p, 1) orelse {
        rs(p, "");
        return;
    };
    const needle_ptr = gs(p, 2);
    const needle_len: usize = @intCast(gss(p, 2));
    const cs: i32 = @intFromFloat(g(p, 3));
    const needle_val = value.stz_value_new_string(needle_ptr, needle_len) orelse {
        rs(p, "");
        return;
    };
    defer value.stz_value_free(needle_val);
    var positions: [32768]i64 = undefined;
    const count = table.stz_table_find_cell_cs(t, needle_val, cs, &positions, 16384);
    if (count == 0) {
        rs(p, "");
        return;
    }
    var buf: [32768 * 12]u8 = undefined;
    var pos: usize = 0;
    for (0..count) |ci| {
        const col_1 = positions[ci * 2] + 1;
        const row_1 = positions[ci * 2 + 1] + 1;
        const slice = std.fmt.bufPrint(buf[pos..], "{d},{d}", .{ col_1, row_1 }) catch break;
        pos += slice.len;
        if (ci + 1 < count) {
            buf[pos] = ';';
            pos += 1;
        }
    }
    if (pos > 0) rs2(p, &buf, @intCast(pos)) else rs(p, "");
}

// Find in column: returns comma-separated 1-based row positions
fn ring_FindInColStringCS(p: *anyopaque) callconv(.c) void {
    const t = getTC(p, 1) orelse {
        rs(p, "");
        return;
    };
    const col: i64 = @intFromFloat(g(p, 2));
    const needle_ptr = gs(p, 3);
    const needle_len: usize = @intCast(gss(p, 3));
    const cs: i32 = @intFromFloat(g(p, 4));
    const needle_val = value.stz_value_new_string(needle_ptr, needle_len) orelse {
        rs(p, "");
        return;
    };
    defer value.stz_value_free(needle_val);
    var positions: [65536]i64 = undefined;
    const count = table.stz_table_find_in_col_cs(t, col, needle_val, cs, &positions, 65536);
    if (count == 0) {
        rs(p, "");
        return;
    }
    var buf: [65536 * 12]u8 = undefined;
    var pos: usize = 0;
    for (0..count) |ci| {
        const row_1 = positions[ci] + 1;
        const slice = std.fmt.bufPrint(buf[pos..], "{d}", .{row_1}) catch break;
        pos += slice.len;
        if (ci + 1 < count) {
            buf[pos] = ',';
            pos += 1;
        }
    }
    if (pos > 0) rs2(p, &buf, @intCast(pos)) else rs(p, "");
}

// Pivot: multi group by (table, col1, col2, value_col, agg_func)
// Supports up to 4 group columns via overloaded ring functions
fn ring_PivotGroupBy1(p: *anyopaque) callconv(.c) void {
    const cols = [_]i64{@intFromFloat(g(p, 2))};
    rcp(p, @ptrCast(pivot.stz_pivot_multi_group_by(getTC(p, 1), &cols, 1, @intFromFloat(g(p, 3)), @intFromFloat(g(p, 4)))), HT);
}
fn ring_PivotGroupBy2(p: *anyopaque) callconv(.c) void {
    const cols = [_]i64{ @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)) };
    rcp(p, @ptrCast(pivot.stz_pivot_multi_group_by(getTC(p, 1), &cols, 2, @intFromFloat(g(p, 4)), @intFromFloat(g(p, 5)))), HT);
}
fn ring_PivotGroupBy3(p: *anyopaque) callconv(.c) void {
    const cols = [_]i64{ @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)), @intFromFloat(g(p, 4)) };
    rcp(p, @ptrCast(pivot.stz_pivot_multi_group_by(getTC(p, 1), &cols, 3, @intFromFloat(g(p, 5)), @intFromFloat(g(p, 6)))), HT);
}

// Pivot: cross tab (table, row_col, col_col, value_col, agg_func, inc_row_total, inc_col_total)
fn ring_PivotCrossTab1(p: *anyopaque) callconv(.c) void {
    const rows = [_]i64{@intFromFloat(g(p, 2))};
    rcp(p, @ptrCast(pivot.stz_pivot_cross_tab(
        getTC(p, 1), &rows, 1,
        @intFromFloat(g(p, 3)), @intFromFloat(g(p, 4)),
        @intFromFloat(g(p, 5)), @intFromFloat(g(p, 6)), @intFromFloat(g(p, 7)),
    )), HT);
}
fn ring_PivotCrossTab2(p: *anyopaque) callconv(.c) void {
    const rows = [_]i64{ @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)) };
    rcp(p, @ptrCast(pivot.stz_pivot_cross_tab(
        getTC(p, 1), &rows, 2,
        @intFromFloat(g(p, 4)), @intFromFloat(g(p, 5)),
        @intFromFloat(g(p, 6)), @intFromFloat(g(p, 7)), @intFromFloat(g(p, 8)),
    )), HT);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginetablenew",           .func = &ring_New },
    .{ .name = "stzenginetablefree",          .func = &ring_Free },
    .{ .name = "stzenginetablenumcols",       .func = &ring_NumCols },
    .{ .name = "stzenginetablenumrows",       .func = &ring_NumRows },
    .{ .name = "stzenginetableaddcol",        .func = &ring_AddCol },
    .{ .name = "stzenginetableremovecol",     .func = &ring_RemoveCol },
    .{ .name = "stzenginetablefindcol",       .func = &ring_FindCol },
    .{ .name = "stzenginetablecolname",       .func = &ring_ColName },
    .{ .name = "stzenginetablerenamecol",     .func = &ring_RenameCol },
    .{ .name = "stzenginetableaddrow",        .func = &ring_AddRow },
    .{ .name = "stzenginetableremoverow",     .func = &ring_RemoveRow },
    .{ .name = "stzenginetablesetcellint",    .func = &ring_SetCellInt },
    .{ .name = "stzenginetablesetcellfloat",  .func = &ring_SetCellFloat },
    .{ .name = "stzenginetablesetcellstring", .func = &ring_SetCellString },
    .{ .name = "stzenginetablegetcellint",    .func = &ring_GetCellInt },
    .{ .name = "stzenginetablegetcellfloat",  .func = &ring_GetCellFloat },
    .{ .name = "stzenginetablegetcellstring", .func = &ring_GetCellString },
    .{ .name = "stzenginetablegetcelltype",   .func = &ring_GetCellType },
    .{ .name = "stzenginetablesorton",        .func = &ring_SortOn },
    .{ .name = "stzenginetableswaprows",      .func = &ring_SwapRows },
    .{ .name = "stzenginetablereverserows",   .func = &ring_ReverseRows },
    .{ .name = "stzenginetablesumcol",        .func = &ring_SumCol },
    .{ .name = "stzenginetablesumcolrange",   .func = &ring_SumColRange },
    .{ .name = "stzenginetableavgcol",        .func = &ring_AvgCol },
    .{ .name = "stzenginetablemincol",        .func = &ring_MinCol },
    .{ .name = "stzenginetablemaxcol",        .func = &ring_MaxCol },
    .{ .name = "stzenginetableproductcol",    .func = &ring_ProductCol },
    .{ .name = "stzenginetablecountnonnull",  .func = &ring_CountNonNull },
    .{ .name = "stzenginetablecountincol",    .func = &ring_CountInCol },
    .{ .name = "stzenginetablecontainsincol", .func = &ring_ContainsInCol },
    .{ .name = "stzenginetablefillint",       .func = &ring_FillInt },
    .{ .name = "stzenginetablefillfloat",     .func = &ring_FillFloat },
    .{ .name = "stzenginetableclone",         .func = &ring_Clone },
    .{ .name = "stzenginetablegroupby",       .func = &ring_GroupBy },
    .{ .name = "stzenginetablefilterrows",    .func = &ring_FilterRows },
    .{ .name = "stzenginetablefindcellstringcs", .func = &ring_FindCellStringCS },
    .{ .name = "stzenginetablefindincolstringcs", .func = &ring_FindInColStringCS },
    // Pivot
    .{ .name = "stzenginepivotgroupby1",     .func = &ring_PivotGroupBy1 },
    .{ .name = "stzenginepivotgroupby2",     .func = &ring_PivotGroupBy2 },
    .{ .name = "stzenginepivotgroupby3",     .func = &ring_PivotGroupBy3 },
    .{ .name = "stzenginepivotcrosstab1",    .func = &ring_PivotCrossTab1 },
    .{ .name = "stzenginepivotcrosstab2",    .func = &ring_PivotCrossTab2 },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
