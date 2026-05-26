// Softanza Engine -- StzPivotTable: cross-tabulation analytics engine
//
// Design: builds on StzTable's columnar storage. Pivot computes a
// cross-tabulation matrix: unique row-key combos x unique col-key combos
// → aggregate(value_column). Uses hash maps for O(n) grouping.
// Returns result as a new StzTable.
//
// C ABI: stz_pivot_* prefix. All handles are opaque pointers.

const std = @import("std");
const allocator = std.heap.c_allocator;
const table_mod = @import("table.zig");
const StzTable = table_mod.StzTable;
const value_mod = @import("value.zig");
const StzValue = value_mod.StzValue;

// ─── Aggregate functions ───

pub const AggFunc = enum(u8) {
    sum = 0,
    count = 1,
    avg = 2,
    min = 3,
    max = 4,
    product = 5,
    stdev = 6,
    variance = 7,
    median = 8,
};

fn computeAgg(values: []const f64, func: AggFunc) f64 {
    if (values.len == 0) return 0;

    return switch (func) {
        .sum => blk: {
            var s: f64 = 0;
            for (values) |v| s += v;
            break :blk s;
        },
        .count => @floatFromInt(values.len),
        .avg => blk: {
            var s: f64 = 0;
            for (values) |v| s += v;
            break :blk s / @as(f64, @floatFromInt(values.len));
        },
        .min => blk: {
            var m: f64 = values[0];
            for (values[1..]) |v| {
                if (v < m) m = v;
            }
            break :blk m;
        },
        .max => blk: {
            var m: f64 = values[0];
            for (values[1..]) |v| {
                if (v > m) m = v;
            }
            break :blk m;
        },
        .product => blk: {
            var p: f64 = 1;
            for (values) |v| p *= v;
            break :blk p;
        },
        .stdev => blk: {
            if (values.len < 2) break :blk 0;
            var s: f64 = 0;
            for (values) |v| s += v;
            const mean = s / @as(f64, @floatFromInt(values.len));
            var ss: f64 = 0;
            for (values) |v| {
                const d = v - mean;
                ss += d * d;
            }
            break :blk @sqrt(ss / @as(f64, @floatFromInt(values.len - 1)));
        },
        .variance => blk: {
            if (values.len < 2) break :blk 0;
            var s: f64 = 0;
            for (values) |v| s += v;
            const mean = s / @as(f64, @floatFromInt(values.len));
            var ss: f64 = 0;
            for (values) |v| {
                const d = v - mean;
                ss += d * d;
            }
            break :blk ss / @as(f64, @floatFromInt(values.len - 1));
        },
        .median => blk: {
            const sorted = allocator.alloc(f64, values.len) catch break :blk 0;
            defer allocator.free(sorted);
            @memcpy(sorted, values);
            std.sort.pdq(f64, sorted, {}, std.sort.asc(f64));
            const mid = values.len / 2;
            if (values.len % 2 == 0) {
                break :blk (sorted[mid - 1] + sorted[mid]) / 2.0;
            } else {
                break :blk sorted[mid];
            }
        },
    };
}

fn cellToFloat(cell: *const StzValue) f64 {
    return switch (cell.tag) {
        .int_val => @floatFromInt(cell.data.int_val),
        .float_val => cell.data.float_val,
        .bool_val => if (cell.data.bool_val) @as(f64, 1) else @as(f64, 0),
        else => 0,
    };
}

// ─── Key serialization ───

fn serializeKey(cells: []const *const StzValue, buf: []u8) usize {
    var pos: usize = 0;
    for (cells, 0..) |cell, i| {
        if (i > 0 and pos < buf.len) {
            buf[pos] = 0x1F; // unit separator
            pos += 1;
        }
        const written = cell.toString(buf[pos..]);
        pos += written;
    }
    return pos;
}

// ─── Multi-column GroupBy ───

pub fn multiGroupBy(
    src: *const StzTable,
    group_cols: []const usize,
    value_col: usize,
    agg_func: AggFunc,
) !*StzTable {
    if (group_cols.len == 0 or value_col >= src.numColumns()) return error.InvalidColumn;
    for (group_cols) |gc| {
        if (gc >= src.numColumns()) return error.InvalidColumn;
    }

    const result = try StzTable.init();
    errdefer result.deinit();

    // Add group columns to result
    for (group_cols) |gc| {
        const name = src.columnName(gc) orelse "?";
        _ = try result.addColumn(name.ptr, name.len);
    }
    _ = try result.addColumn("result", 6);

    // Hash-based grouping
    var groups = std.StringArrayHashMap(std.ArrayList(usize)).init(allocator);
    defer {
        var it = groups.iterator();
        while (it.next()) |entry| {
            allocator.free(entry.key_ptr.*);
            entry.value_ptr.deinit(allocator);
        }
        groups.deinit();
    }

    var key_buf: [4096]u8 = undefined;
    const key_cells = try allocator.alloc(*const StzValue, group_cols.len);
    defer allocator.free(key_cells);

    for (0..src.num_rows) |ri| {
        for (group_cols, 0..) |gc, ki| {
            key_cells[ki] = src.getCell(gc, ri) orelse continue;
        }
        const key_len = serializeKey(key_cells, &key_buf);
        const key_slice = key_buf[0..key_len];

        const gop = try groups.getOrPut(key_slice);
        if (!gop.found_existing) {
            const owned_key = try allocator.alloc(u8, key_len);
            @memcpy(owned_key, key_slice);
            gop.key_ptr.* = owned_key;
            gop.value_ptr.* = .{};
        }
        try gop.value_ptr.append(allocator, ri);
    }

    // Build result rows
    const val_col_cells = src.columns.items[value_col].cells.items;
    var group_it = groups.iterator();
    while (group_it.next()) |entry| {
        const row_indices = entry.value_ptr.items;
        const ri = try result.addRow();

        // Set group key values from first row in group
        const first_row = row_indices[0];
        for (group_cols, 0..) |gc, ki| {
            const cell = src.getCell(gc, first_row) orelse continue;
            try result.setCell(ki, ri, cell);
        }

        // Compute aggregate
        const vals = try allocator.alloc(f64, row_indices.len);
        defer allocator.free(vals);
        for (row_indices, 0..) |idx, vi| {
            vals[vi] = cellToFloat(val_col_cells[idx]);
        }
        const agg_result = computeAgg(vals, agg_func);
        try result.setCellFloat(group_cols.len, ri, agg_result);
    }

    return result;
}

// ─── Cross-tabulation (pivot) ───

pub fn crossTab(
    src: *const StzTable,
    row_cols: []const usize,
    col_col: usize,
    value_col: usize,
    agg_func: AggFunc,
    include_row_total: bool,
    include_col_total: bool,
) !*StzTable {
    if (row_cols.len == 0 or col_col >= src.numColumns() or value_col >= src.numColumns())
        return error.InvalidColumn;
    for (row_cols) |rc| {
        if (rc >= src.numColumns()) return error.InvalidColumn;
    }

    // Step 1: Collect unique column values
    var col_uniques = std.StringArrayHashMap(void).init(allocator);
    defer col_uniques.deinit();
    {
        const col_cells = src.columns.items[col_col].cells.items;
        var buf: [1024]u8 = undefined;
        for (0..src.num_rows) |ri| {
            const len = col_cells[ri].toString(&buf);
            const key = buf[0..len];
            if (!col_uniques.contains(key)) {
                const owned = try allocator.alloc(u8, len);
                @memcpy(owned, key);
                try col_uniques.put(owned, {});
            }
        }
    }
    const unique_col_keys = col_uniques.keys();

    // Step 2: Collect unique row-key combos
    var row_uniques = std.StringArrayHashMap(void).init(allocator);
    defer row_uniques.deinit();
    const row_key_cells = try allocator.alloc(*const StzValue, row_cols.len);
    defer allocator.free(row_key_cells);
    {
        var buf: [4096]u8 = undefined;
        for (0..src.num_rows) |ri| {
            for (row_cols, 0..) |rc, ki| {
                row_key_cells[ki] = src.getCell(rc, ri) orelse continue;
            }
            const len = serializeKey(row_key_cells, &buf);
            const key = buf[0..len];
            if (!row_uniques.contains(key)) {
                const owned = try allocator.alloc(u8, len);
                @memcpy(owned, key);
                try row_uniques.put(owned, {});
            }
        }
    }
    const unique_row_keys = row_uniques.keys();

    // Step 3: Build accumulator: (row_key, col_key) → list of f64
    const CellKey = struct { row_idx: usize, col_idx: usize };
    var accum = std.AutoArrayHashMap(CellKey, std.ArrayList(f64)).init(allocator);
    defer {
        var it = accum.iterator();
        while (it.next()) |entry| {
            entry.value_ptr.deinit(allocator);
        }
        accum.deinit();
    }

    {
        var row_buf: [4096]u8 = undefined;
        var col_buf: [1024]u8 = undefined;
        const col_cells = src.columns.items[col_col].cells.items;
        const val_cells = src.columns.items[value_col].cells.items;

        for (0..src.num_rows) |ri| {
            for (row_cols, 0..) |rc, ki| {
                row_key_cells[ki] = src.getCell(rc, ri) orelse continue;
            }
            const rk_len = serializeKey(row_key_cells, &row_buf);
            const ck_len = col_cells[ri].toString(&col_buf);

            // Find indices
            const row_idx = findKeyIndex(unique_row_keys, row_buf[0..rk_len]) orelse continue;
            const col_idx = findKeyIndex(unique_col_keys, col_buf[0..ck_len]) orelse continue;

            const cell_key = CellKey{ .row_idx = row_idx, .col_idx = col_idx };
            const gop = try accum.getOrPut(cell_key);
            if (!gop.found_existing) {
                gop.value_ptr.* = .{};
            }
            try gop.value_ptr.append(allocator, cellToFloat(val_cells[ri]));
        }
    }

    // Step 4: Build result table
    const num_data_cols = unique_col_keys.len;
    const total_cols = row_cols.len + num_data_cols + @as(usize, if (include_row_total) 1 else 0);
    _ = total_cols;

    const result = try StzTable.init();
    errdefer result.deinit();

    // Add row label columns
    for (row_cols) |rc| {
        const name = src.columnName(rc) orelse "?";
        _ = try result.addColumn(name.ptr, name.len);
    }

    // Add data columns (named by unique col values)
    for (unique_col_keys) |ck| {
        _ = try result.addColumn(ck.ptr, ck.len);
    }

    // Add total column
    if (include_row_total) {
        _ = try result.addColumn("TOTAL", 5);
    }

    // Add data rows
    for (unique_row_keys, 0..) |rk, ri| {
        const dest_ri = try result.addRow();

        // Parse row key back to set row label cells
        // Find first source row matching this row key
        var row_buf: [4096]u8 = undefined;
        for (0..src.num_rows) |src_ri| {
            for (row_cols, 0..) |rc, ki| {
                row_key_cells[ki] = src.getCell(rc, src_ri) orelse continue;
            }
            const len = serializeKey(row_key_cells, &row_buf);
            if (std.mem.eql(u8, row_buf[0..len], rk)) {
                // Set row label cells
                for (row_cols, 0..) |rc, ki| {
                    const cell = src.getCell(rc, src_ri) orelse continue;
                    try result.setCell(ki, dest_ri, cell);
                }
                break;
            }
        }

        // Set aggregated values
        var row_total: f64 = 0;
        for (0..num_data_cols) |ci| {
            const cell_key = CellKey{ .row_idx = ri, .col_idx = ci };
            if (accum.getPtr(cell_key)) |vals| {
                const agg = computeAgg(vals.items, agg_func);
                try result.setCellFloat(row_cols.len + ci, dest_ri, agg);
                row_total += agg;
            } else {
                try result.setCellFloat(row_cols.len + ci, dest_ri, 0);
            }
        }

        if (include_row_total) {
            try result.setCellFloat(row_cols.len + num_data_cols, dest_ri, row_total);
        }
    }

    // Add total row
    if (include_col_total) {
        const total_ri = try result.addRow();

        // Set "TOTAL" label in first row column
        try result.setCellString(0, total_ri, "TOTAL", 5);

        // Calculate column totals
        for (0..num_data_cols) |ci| {
            var col_total: f64 = 0;
            for (0..unique_row_keys.len) |ri| {
                const cell_key = CellKey{ .row_idx = ri, .col_idx = ci };
                if (accum.getPtr(cell_key)) |vals| {
                    col_total += computeAgg(vals.items, agg_func);
                }
            }
            try result.setCellFloat(row_cols.len + ci, total_ri, col_total);
        }

        // Grand total
        if (include_row_total) {
            var grand: f64 = 0;
            for (0..num_data_cols) |ci| {
                for (0..unique_row_keys.len) |ri| {
                    const cell_key = CellKey{ .row_idx = ri, .col_idx = ci };
                    if (accum.getPtr(cell_key)) |vals| {
                        grand += computeAgg(vals.items, agg_func);
                    }
                }
            }
            try result.setCellFloat(row_cols.len + num_data_cols, total_ri, grand);
        }
    }

    return result;
}

fn findKeyIndex(keys: []const []const u8, needle: []const u8) ?usize {
    for (keys, 0..) |k, i| {
        if (std.mem.eql(u8, k, needle)) return i;
    }
    return null;
}

// ─── C ABI ───

pub fn stz_pivot_multi_group_by(
    t: ?*const StzTable,
    group_cols: [*]const i64,
    num_group_cols: usize,
    value_col: i64,
    agg_func: i32,
) callconv(.c) ?*StzTable {
    const tbl = t orelse return null;
    if (num_group_cols == 0 or value_col < 0) return null;

    const cols = allocator.alloc(usize, num_group_cols) catch return null;
    defer allocator.free(cols);
    for (0..num_group_cols) |i| {
        if (group_cols[i] < 0) return null;
        cols[i] = @intCast(group_cols[i]);
    }

    const func: AggFunc = @enumFromInt(@as(u8, @intCast(@min(agg_func, 8))));
    return multiGroupBy(tbl, cols, @intCast(value_col), func) catch null;
}

pub fn stz_pivot_cross_tab(
    t: ?*const StzTable,
    row_cols: [*]const i64,
    num_row_cols: usize,
    col_col: i64,
    value_col: i64,
    agg_func: i32,
    include_row_total: i32,
    include_col_total: i32,
) callconv(.c) ?*StzTable {
    const tbl = t orelse return null;
    if (num_row_cols == 0 or col_col < 0 or value_col < 0) return null;

    const cols = allocator.alloc(usize, num_row_cols) catch return null;
    defer allocator.free(cols);
    for (0..num_row_cols) |i| {
        if (row_cols[i] < 0) return null;
        cols[i] = @intCast(row_cols[i]);
    }

    const func: AggFunc = @enumFromInt(@as(u8, @intCast(@min(agg_func, 8))));
    return crossTab(
        tbl,
        cols,
        @intCast(col_col),
        @intCast(value_col),
        func,
        include_row_total != 0,
        include_col_total != 0,
    ) catch null;
}

// ─── Tests ───

test "pivot multi group by" {
    const t = try StzTable.init();
    defer t.deinit();

    _ = try t.addColumn("dept", 4);
    _ = try t.addColumn("role", 4);
    _ = try t.addColumn("salary", 6);

    inline for (.{
        .{ "IT", "Dev", 50000 },
        .{ "IT", "Dev", 55000 },
        .{ "IT", "QA", 45000 },
        .{ "HR", "Mgr", 60000 },
        .{ "HR", "Mgr", 62000 },
    }) |row| {
        const ri = try t.addRow();
        try t.setCellString(0, ri, row[0], row[0].len);
        try t.setCellString(1, ri, row[1], row[1].len);
        try t.setCellInt(2, ri, row[2]);
    }

    const cols = [_]usize{ 0, 1 };
    const grouped = try multiGroupBy(t, &cols, 2, .sum);
    defer grouped.deinit();

    try std.testing.expectEqual(@as(usize, 3), grouped.numColumns()); // dept, role, result
    try std.testing.expectEqual(@as(usize, 3), grouped.num_rows); // IT/Dev, IT/QA, HR/Mgr
}

test "pivot cross tab" {
    const t = try StzTable.init();
    defer t.deinit();

    _ = try t.addColumn("region", 6);
    _ = try t.addColumn("product", 7);
    _ = try t.addColumn("sales", 5);

    inline for (.{
        .{ "North", "A", 100 },
        .{ "North", "B", 200 },
        .{ "South", "A", 150 },
        .{ "South", "B", 250 },
        .{ "North", "A", 120 },
    }) |row| {
        const ri = try t.addRow();
        try t.setCellString(0, ri, row[0], row[0].len);
        try t.setCellString(1, ri, row[1], row[1].len);
        try t.setCellInt(2, ri, row[2]);
    }

    const row_cols = [_]usize{0};
    const result = try crossTab(t, &row_cols, 1, 2, .sum, true, true);
    defer result.deinit();

    // Columns: region, A, B, TOTAL
    try std.testing.expectEqual(@as(usize, 4), result.numColumns());
    // Rows: North, South, TOTAL
    try std.testing.expectEqual(@as(usize, 3), result.num_rows);
}

test "pivot aggregation functions" {
    const vals = [_]f64{ 10, 20, 30, 40, 50 };
    try std.testing.expectEqual(@as(f64, 150), computeAgg(&vals, .sum));
    try std.testing.expectEqual(@as(f64, 5), computeAgg(&vals, .count));
    try std.testing.expectEqual(@as(f64, 30), computeAgg(&vals, .avg));
    try std.testing.expectEqual(@as(f64, 10), computeAgg(&vals, .min));
    try std.testing.expectEqual(@as(f64, 50), computeAgg(&vals, .max));
    try std.testing.expectEqual(@as(f64, 12000000), computeAgg(&vals, .product));
    try std.testing.expectEqual(@as(f64, 30), computeAgg(&vals, .median));

    const variance = computeAgg(&vals, .variance);
    try std.testing.expectApproxEqAbs(@as(f64, 250), variance, 0.01);

    const stdev = computeAgg(&vals, .stdev);
    try std.testing.expectApproxEqAbs(@as(f64, 15.811), stdev, 0.01);
}

test "pivot median even count" {
    const vals = [_]f64{ 10, 20, 30, 40 };
    try std.testing.expectEqual(@as(f64, 25), computeAgg(&vals, .median));
}

test "pivot aggregation: empty values" {
    const vals = [_]f64{};
    try std.testing.expectEqual(@as(f64, 0), computeAgg(&vals, .sum));
    try std.testing.expectEqual(@as(f64, 0), computeAgg(&vals, .count));
    try std.testing.expectEqual(@as(f64, 0), computeAgg(&vals, .avg));
    try std.testing.expectEqual(@as(f64, 0), computeAgg(&vals, .product));
}

test "pivot aggregation: single value" {
    const vals = [_]f64{42};
    try std.testing.expectEqual(@as(f64, 42), computeAgg(&vals, .sum));
    try std.testing.expectEqual(@as(f64, 1), computeAgg(&vals, .count));
    try std.testing.expectEqual(@as(f64, 42), computeAgg(&vals, .avg));
    try std.testing.expectEqual(@as(f64, 42), computeAgg(&vals, .min));
    try std.testing.expectEqual(@as(f64, 42), computeAgg(&vals, .max));
    try std.testing.expectEqual(@as(f64, 42), computeAgg(&vals, .product));
    try std.testing.expectEqual(@as(f64, 42), computeAgg(&vals, .median));
    // stdev/variance of single value = 0
    try std.testing.expectEqual(@as(f64, 0), computeAgg(&vals, .stdev));
    try std.testing.expectEqual(@as(f64, 0), computeAgg(&vals, .variance));
}

test "pivot aggregation: negative values" {
    const vals = [_]f64{ -10, -20, -30 };
    try std.testing.expectEqual(@as(f64, -60), computeAgg(&vals, .sum));
    try std.testing.expectEqual(@as(f64, -20), computeAgg(&vals, .avg));
    try std.testing.expectEqual(@as(f64, -30), computeAgg(&vals, .min));
    try std.testing.expectEqual(@as(f64, -10), computeAgg(&vals, .max));
    try std.testing.expectEqual(@as(f64, -20), computeAgg(&vals, .median));
}

test "pivot aggregation: product of zeros" {
    const vals = [_]f64{ 0, 5, 10 };
    try std.testing.expectEqual(@as(f64, 0), computeAgg(&vals, .product));
}

test "pivot cross tab: without totals" {
    const t = try StzTable.init();
    defer t.deinit();

    _ = try t.addColumn("region", 6);
    _ = try t.addColumn("product", 7);
    _ = try t.addColumn("sales", 5);

    inline for (.{
        .{ "North", "A", 100 },
        .{ "South", "B", 200 },
    }) |row| {
        const ri = try t.addRow();
        try t.setCellString(0, ri, row[0], row[0].len);
        try t.setCellString(1, ri, row[1], row[1].len);
        try t.setCellInt(2, ri, row[2]);
    }

    const row_cols = [_]usize{0};
    const result = try crossTab(t, &row_cols, 1, 2, .sum, false, false);
    defer result.deinit();

    // Columns: region, A, B (no TOTAL)
    try std.testing.expectEqual(@as(usize, 3), result.numColumns());
    // Rows: North, South (no TOTAL)
    try std.testing.expectEqual(@as(usize, 2), result.num_rows);
}

test "pivot cross tab: with avg aggregation" {
    const t = try StzTable.init();
    defer t.deinit();

    _ = try t.addColumn("dept", 4);
    _ = try t.addColumn("quarter", 7);
    _ = try t.addColumn("revenue", 7);

    inline for (.{
        .{ "IT", "Q1", 100 },
        .{ "IT", "Q1", 200 },
        .{ "IT", "Q2", 300 },
        .{ "HR", "Q1", 150 },
    }) |row| {
        const ri = try t.addRow();
        try t.setCellString(0, ri, row[0], row[0].len);
        try t.setCellString(1, ri, row[1], row[1].len);
        try t.setCellInt(2, ri, row[2]);
    }

    const row_cols = [_]usize{0};
    const result = try crossTab(t, &row_cols, 1, 2, .avg, false, false);
    defer result.deinit();

    try std.testing.expectEqual(@as(usize, 3), result.numColumns()); // dept, Q1, Q2
    try std.testing.expectEqual(@as(usize, 2), result.num_rows); // IT, HR
}

test "pivot multi group by: single column group" {
    const t = try StzTable.init();
    defer t.deinit();

    _ = try t.addColumn("category", 8);
    _ = try t.addColumn("amount", 6);

    inline for (.{
        .{ "A", 10 },
        .{ "B", 20 },
        .{ "A", 30 },
        .{ "B", 40 },
        .{ "A", 50 },
    }) |row| {
        const ri = try t.addRow();
        try t.setCellString(0, ri, row[0], row[0].len);
        try t.setCellInt(1, ri, row[1]);
    }

    const cols = [_]usize{0};
    const grouped = try multiGroupBy(t, &cols, 1, .sum);
    defer grouped.deinit();

    try std.testing.expectEqual(@as(usize, 2), grouped.numColumns()); // category, result
    try std.testing.expectEqual(@as(usize, 2), grouped.num_rows); // A, B
}

test "pivot C ABI: null table returns null" {
    const cols = [_]i64{0};
    try std.testing.expect(stz_pivot_multi_group_by(null, &cols, 1, 0, 0) == null);
    try std.testing.expect(stz_pivot_cross_tab(null, &cols, 1, 1, 2, 0, 0, 0) == null);
}

test "pivot C ABI: negative column returns null" {
    const t = try StzTable.init();
    defer t.deinit();
    _ = try t.addColumn("x", 1);

    const cols = [_]i64{0};
    try std.testing.expect(stz_pivot_multi_group_by(t, &cols, 1, -1, 0) == null);
    try std.testing.expect(stz_pivot_cross_tab(t, &cols, 1, -1, 0, 0, 0, 0) == null);
}
