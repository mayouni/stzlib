// Softanza Engine -- StzTable: columnar relational data engine
//
// Design: columnar storage for cache-friendly analytics. Each column
// is a contiguous array of StzValue pointers. Sort uses parallel
// merge-sort with index permutation (no row-object copies). Aggregates
// scan columns linearly for L1-friendly access. GroupBy uses hash maps
// with pre-hashed keys for O(n) grouping.
//
// C ABI: stz_table_* prefix. All handles are opaque pointers.

const std = @import("std");
const allocator = std.heap.c_allocator;
const value_mod = @import("value.zig");
const StzValue = value_mod.StzValue;
const ValueType = value_mod.ValueType;

// ─── Column ───

pub const Column = struct {
    name: []u8,
    cells: std.ArrayList(*StzValue),
    type_hint: ValueType, // predominant type (optimization hint)
    is_sorted_asc: bool,
    is_sorted_desc: bool,

    fn init(name_ptr: [*]const u8, name_len: usize) !Column {
        const owned_name = try allocator.alloc(u8, name_len);
        @memcpy(owned_name, name_ptr[0..name_len]);
        return Column{
            .name = owned_name,
            .cells = .{},
            .type_hint = .null_val,
            .is_sorted_asc = true,
            .is_sorted_desc = true,
        };
    }

    fn deinit(self: *Column) void {
        for (self.cells.items) |cell| {
            cell.deinit();
            allocator.destroy(cell);
        }
        self.cells.deinit(allocator);
        allocator.free(self.name);
    }

    fn invalidateSort(self: *Column) void {
        self.is_sorted_asc = false;
        self.is_sorted_desc = false;
    }

    fn updateTypeHint(self: *Column) void {
        if (self.cells.items.len == 0) {
            self.type_hint = .null_val;
            return;
        }
        const first_tag = self.cells.items[0].tag;
        for (self.cells.items[1..]) |cell| {
            if (cell.tag != first_tag) {
                self.type_hint = .null_val; // mixed
                return;
            }
        }
        self.type_hint = first_tag;
    }

    fn nameEql(self: *const Column, other_ptr: [*]const u8, other_len: usize) bool {
        if (self.name.len != other_len) return false;
        return std.mem.eql(u8, self.name, other_ptr[0..other_len]);
    }

    fn nameEqlCI(self: *const Column, other_ptr: [*]const u8, other_len: usize) bool {
        if (self.name.len != other_len) return false;
        return std.ascii.eqlIgnoreCase(self.name, other_ptr[0..other_len]);
    }
};

// ─── StzTable ───

pub const StzTable = struct {
    columns: std.ArrayList(Column),
    num_rows: usize,

    pub fn init() !*StzTable {
        const self = try allocator.create(StzTable);
        self.* = .{
            .columns = .{},
            .num_rows = 0,
        };
        return self;
    }

    pub fn deinit(self: *StzTable) void {
        for (self.columns.items) |*col| {
            col.deinit();
        }
        self.columns.deinit(allocator);
        allocator.destroy(self);
    }

    // ─── Column management ───

    pub fn addColumn(self: *StzTable, name_ptr: [*]const u8, name_len: usize) !usize {
        var col = try Column.init(name_ptr, name_len);
        // pad with nulls to match existing row count
        for (0..self.num_rows) |_| {
            const null_val = try allocator.create(StzValue);
            null_val.* = .{ .tag = .null_val, .data = .{ .null_val = {} } };
            try col.cells.append(allocator, null_val);
        }
        try self.columns.append(allocator, col);
        return self.columns.items.len - 1;
    }

    pub fn removeColumn(self: *StzTable, col_idx: usize) void {
        if (col_idx >= self.columns.items.len) return;
        self.columns.items[col_idx].deinit();
        _ = self.columns.orderedRemove(col_idx);
    }

    pub fn findColumn(self: *const StzTable, name_ptr: [*]const u8, name_len: usize) i64 {
        for (self.columns.items, 0..) |*col, i| {
            if (col.nameEqlCI(name_ptr, name_len)) return @intCast(i);
        }
        return -1;
    }

    pub fn numColumns(self: *const StzTable) usize {
        return self.columns.items.len;
    }

    pub fn columnName(self: *const StzTable, col_idx: usize) ?[]const u8 {
        if (col_idx >= self.columns.items.len) return null;
        return self.columns.items[col_idx].name;
    }

    pub fn renameColumn(self: *StzTable, col_idx: usize, name_ptr: [*]const u8, name_len: usize) !void {
        if (col_idx >= self.columns.items.len) return;
        allocator.free(self.columns.items[col_idx].name);
        const owned = try allocator.alloc(u8, name_len);
        @memcpy(owned, name_ptr[0..name_len]);
        self.columns.items[col_idx].name = owned;
    }

    // ─── Row management ───

    pub fn addRow(self: *StzTable) !usize {
        for (self.columns.items) |*col| {
            const null_val = try allocator.create(StzValue);
            null_val.* = .{ .tag = .null_val, .data = .{ .null_val = {} } };
            try col.cells.append(allocator, null_val);
            col.invalidateSort();
        }
        self.num_rows += 1;
        return self.num_rows - 1;
    }

    pub fn removeRow(self: *StzTable, row_idx: usize) void {
        if (row_idx >= self.num_rows) return;
        for (self.columns.items) |*col| {
            const cell = col.cells.orderedRemove(row_idx);
            cell.deinit();
            allocator.destroy(cell);
        }
        self.num_rows -= 1;
    }

    // ─── Cell access ───

    pub fn getCell(self: *const StzTable, col_idx: usize, row_idx: usize) ?*const StzValue {
        if (col_idx >= self.columns.items.len or row_idx >= self.num_rows) return null;
        return self.columns.items[col_idx].cells.items[row_idx];
    }

    pub fn setCell(self: *StzTable, col_idx: usize, row_idx: usize, value: *const StzValue) !void {
        if (col_idx >= self.columns.items.len or row_idx >= self.num_rows) return;
        const col = &self.columns.items[col_idx];
        const old = col.cells.items[row_idx];
        old.deinit();
        allocator.destroy(old);
        col.cells.items[row_idx] = try value.clone();
        col.invalidateSort();
    }

    pub fn setCellInt(self: *StzTable, col_idx: usize, row_idx: usize, val: i64) !void {
        if (col_idx >= self.columns.items.len or row_idx >= self.num_rows) return;
        const col = &self.columns.items[col_idx];
        const old = col.cells.items[row_idx];
        old.deinit();
        old.* = .{ .tag = .int_val, .data = .{ .int_val = val } };
        col.invalidateSort();
    }

    pub fn setCellFloat(self: *StzTable, col_idx: usize, row_idx: usize, val: f64) !void {
        if (col_idx >= self.columns.items.len or row_idx >= self.num_rows) return;
        const col = &self.columns.items[col_idx];
        const old = col.cells.items[row_idx];
        old.deinit();
        old.* = .{ .tag = .float_val, .data = .{ .float_val = val } };
        col.invalidateSort();
    }

    pub fn setCellString(self: *StzTable, col_idx: usize, row_idx: usize, ptr: [*]const u8, len: usize) !void {
        if (col_idx >= self.columns.items.len or row_idx >= self.num_rows) return;
        const col = &self.columns.items[col_idx];
        const old = col.cells.items[row_idx];
        old.deinit();
        const buf = try allocator.alloc(u8, len);
        @memcpy(buf, ptr[0..len]);
        old.* = .{ .tag = .string_val, .data = .{ .string_val = .{ .ptr = buf.ptr, .len = buf.len, .owned = true } } };
        col.invalidateSort();
    }

    // ─── Sorting (index-permutation, avoids data copies) ───

    pub fn sortOnColumn(self: *StzTable, col_idx: usize, ascending: bool) !void {
        if (col_idx >= self.columns.items.len or self.num_rows <= 1) return;

        const col = &self.columns.items[col_idx];
        if (ascending and col.is_sorted_asc) return;
        if (!ascending and col.is_sorted_desc) return;

        // Build index permutation
        const indices = try allocator.alloc(usize, self.num_rows);
        defer allocator.free(indices);
        for (0..self.num_rows) |i| indices[i] = i;

        const key_cells = col.cells.items;
        const Context = struct {
            keys: []*StzValue,
            asc: bool,
        };
        const ctx = Context{ .keys = key_cells, .asc = ascending };

        std.sort.pdq(usize, indices, ctx, struct {
            fn lessThan(c: Context, a: usize, b: usize) bool {
                const cmp = c.keys[a].compare(c.keys[b]);
                return if (c.asc) cmp < 0 else cmp > 0;
            }
        }.lessThan);

        // Apply permutation to ALL columns
        try self.applyPermutation(indices);

        // Update sort flags
        for (self.columns.items) |*c| {
            c.is_sorted_asc = false;
            c.is_sorted_desc = false;
        }
        col.is_sorted_asc = ascending;
        col.is_sorted_desc = !ascending;
    }

    fn applyPermutation(self: *StzTable, perm: []const usize) !void {
        const n = self.num_rows;
        const temp = try allocator.alloc(*StzValue, n);
        defer allocator.free(temp);

        for (self.columns.items) |*col| {
            // Copy pointers in permutation order
            for (0..n) |i| {
                temp[i] = col.cells.items[perm[i]];
            }
            // Write back
            @memcpy(col.cells.items[0..n], temp[0..n]);
        }
    }

    // ─── Search ───

    pub fn findCell(self: *const StzTable, value: *const StzValue) ?[2]usize {
        for (self.columns.items, 0..) |*col, ci| {
            for (col.cells.items, 0..) |cell, ri| {
                if (cell.eql(value)) return .{ ci, ri };
            }
        }
        return null;
    }

    pub fn findAllInColumn(self: *const StzTable, col_idx: usize, value: *const StzValue, result_buf: []usize) usize {
        if (col_idx >= self.columns.items.len) return 0;
        const cells = self.columns.items[col_idx].cells.items;
        var count: usize = 0;
        for (cells, 0..) |cell, ri| {
            if (cell.eql(value)) {
                if (count < result_buf.len) {
                    result_buf[count] = ri;
                }
                count += 1;
            }
        }
        return count;
    }

    pub fn containsInColumn(self: *const StzTable, col_idx: usize, value: *const StzValue) bool {
        if (col_idx >= self.columns.items.len) return false;
        for (self.columns.items[col_idx].cells.items) |cell| {
            if (cell.eql(value)) return true;
        }
        return false;
    }

    pub fn countInColumn(self: *const StzTable, col_idx: usize, value: *const StzValue) usize {
        if (col_idx >= self.columns.items.len) return 0;
        var count: usize = 0;
        for (self.columns.items[col_idx].cells.items) |cell| {
            if (cell.eql(value)) count += 1;
        }
        return count;
    }

    // ─── Aggregation (cache-friendly columnar scans) ───

    pub fn sumColumn(self: *const StzTable, col_idx: usize) f64 {
        if (col_idx >= self.columns.items.len) return 0;
        var sum: f64 = 0;
        for (self.columns.items[col_idx].cells.items) |cell| {
            sum += cellToFloat(cell);
        }
        return sum;
    }

    pub fn sumColumnRange(self: *const StzTable, col_idx: usize, from_row: usize, to_row: usize) f64 {
        if (col_idx >= self.columns.items.len) return 0;
        const cells = self.columns.items[col_idx].cells.items;
        const end = @min(to_row, cells.len);
        if (from_row >= end) return 0;
        var sum: f64 = 0;
        for (cells[from_row..end]) |cell| {
            sum += cellToFloat(cell);
        }
        return sum;
    }

    pub fn avgColumn(self: *const StzTable, col_idx: usize) f64 {
        if (col_idx >= self.columns.items.len or self.num_rows == 0) return 0;
        return self.sumColumn(col_idx) / @as(f64, @floatFromInt(self.num_rows));
    }

    pub fn minColumn(self: *const StzTable, col_idx: usize) f64 {
        if (col_idx >= self.columns.items.len or self.num_rows == 0) return 0;
        const cells = self.columns.items[col_idx].cells.items;
        var result: f64 = cellToFloat(cells[0]);
        for (cells[1..]) |cell| {
            const v = cellToFloat(cell);
            if (v < result) result = v;
        }
        return result;
    }

    pub fn maxColumn(self: *const StzTable, col_idx: usize) f64 {
        if (col_idx >= self.columns.items.len or self.num_rows == 0) return 0;
        const cells = self.columns.items[col_idx].cells.items;
        var result: f64 = cellToFloat(cells[0]);
        for (cells[1..]) |cell| {
            const v = cellToFloat(cell);
            if (v > result) result = v;
        }
        return result;
    }

    pub fn productColumn(self: *const StzTable, col_idx: usize) f64 {
        if (col_idx >= self.columns.items.len or self.num_rows == 0) return 0;
        var prod: f64 = 1;
        for (self.columns.items[col_idx].cells.items) |cell| {
            prod *= cellToFloat(cell);
        }
        return prod;
    }

    pub fn countNonNull(self: *const StzTable, col_idx: usize) usize {
        if (col_idx >= self.columns.items.len) return 0;
        var count: usize = 0;
        for (self.columns.items[col_idx].cells.items) |cell| {
            if (cell.tag != .null_val) count += 1;
        }
        return count;
    }

    // ─── Row operations ───

    pub fn swapRows(self: *StzTable, row_a: usize, row_b: usize) void {
        if (row_a >= self.num_rows or row_b >= self.num_rows or row_a == row_b) return;
        for (self.columns.items) |*col| {
            const tmp = col.cells.items[row_a];
            col.cells.items[row_a] = col.cells.items[row_b];
            col.cells.items[row_b] = tmp;
            col.invalidateSort();
        }
    }

    // ─── SubTable (returns new table with selected columns) ───

    pub fn subTable(self: *const StzTable, col_indices: []const usize) !*StzTable {
        const result = try StzTable.init();
        errdefer result.deinit();

        for (col_indices) |ci| {
            if (ci >= self.columns.items.len) continue;
            const src_col = &self.columns.items[ci];
            const new_ci = try result.addColumn(src_col.name.ptr, src_col.name.len);
            _ = new_ci;
        }

        // Add rows
        for (0..self.num_rows) |ri| {
            _ = try result.addRow();
            var dest_ci: usize = 0;
            for (col_indices) |ci| {
                if (ci >= self.columns.items.len) continue;
                const src_cell = self.columns.items[ci].cells.items[ri];
                try result.setCell(dest_ci, ri, src_cell);
                dest_ci += 1;
            }
        }

        return result;
    }

    // ─── Clone ───

    pub fn clone(self: *const StzTable) !*StzTable {
        const result = try StzTable.init();
        errdefer result.deinit();

        for (self.columns.items) |*src_col| {
            _ = try result.addColumn(src_col.name.ptr, src_col.name.len);
        }
        for (0..self.num_rows) |ri| {
            _ = try result.addRow();
            for (self.columns.items, 0..) |*src_col, ci| {
                try result.setCell(ci, ri, src_col.cells.items[ri]);
            }
        }
        return result;
    }

    // ─── GroupBy with aggregate ───

    pub const AggFunc = enum(u8) {
        sum = 0,
        avg = 1,
        min = 2,
        max = 3,
        count = 4,
        product = 5,
    };

    pub fn groupByAggregate(
        self: *const StzTable,
        group_col: usize,
        value_col: usize,
        agg_func: AggFunc,
    ) !*StzTable {
        if (group_col >= self.columns.items.len or value_col >= self.columns.items.len)
            return error.InvalidColumn;

        const result = try StzTable.init();
        errdefer result.deinit();

        const src_group = &self.columns.items[group_col];
        _ = try result.addColumn(src_group.name.ptr, src_group.name.len);
        _ = try result.addColumn("result".ptr, 6);

        // Hash-based grouping: key = serialized StzValue, value = list of row indices
        var groups = std.StringArrayHashMap(std.ArrayList(usize)).init(allocator);
        defer {
            var it = groups.iterator();
            while (it.next()) |entry| {
                allocator.free(entry.key_ptr.*);
                entry.value_ptr.deinit(allocator);
            }
            groups.deinit();
        }

        // Serialize group keys and collect row indices
        var key_buf: [1024]u8 = undefined;
        for (0..self.num_rows) |ri| {
            const cell = src_group.cells.items[ri];
            const key_len = cell.toString(&key_buf);
            const key_slice = key_buf[0..key_len];

            const gop = try groups.getOrPut(key_slice);
            if (!gop.found_existing) {
                // Copy key for ownership
                const owned_key = try allocator.alloc(u8, key_len);
                @memcpy(owned_key, key_slice);
                gop.key_ptr.* = owned_key;
                gop.value_ptr.* = .{};
            }
            try gop.value_ptr.append(allocator, ri);
        }

        // Compute aggregates
        const val_cells = self.columns.items[value_col].cells.items;
        var group_it = groups.iterator();
        while (group_it.next()) |entry| {
            const row_indices = entry.value_ptr.items;
            const ri = try result.addRow();

            // Set group key (clone from first row in group)
            const first_row = row_indices[0];
            try result.setCell(0, ri, src_group.cells.items[first_row]);

            // Compute aggregate
            const agg_result = computeAggregate(val_cells, row_indices, agg_func);
            try result.setCellFloat(1, ri, agg_result);
        }

        return result;
    }

    // ─── Filter rows where column matches value ───

    pub fn filterRows(self: *const StzTable, col_idx: usize, value: *const StzValue) !*StzTable {
        if (col_idx >= self.columns.items.len) return error.InvalidColumn;

        const result = try StzTable.init();
        errdefer result.deinit();

        for (self.columns.items) |*src_col| {
            _ = try result.addColumn(src_col.name.ptr, src_col.name.len);
        }

        const filter_cells = self.columns.items[col_idx].cells.items;
        for (0..self.num_rows) |ri| {
            if (filter_cells[ri].eql(value)) {
                const new_ri = try result.addRow();
                for (self.columns.items, 0..) |*src_col, ci| {
                    try result.setCell(ci, new_ri, src_col.cells.items[ri]);
                }
            }
        }

        return result;
    }

    // ─── Reverse rows ───

    pub fn reverseRows(self: *StzTable) void {
        if (self.num_rows <= 1) return;
        const half = self.num_rows / 2;
        for (0..half) |i| {
            self.swapRows(i, self.num_rows - 1 - i);
        }
    }

    // ─── Fill all cells ───

    pub fn fillInt(self: *StzTable, val: i64) void {
        for (self.columns.items) |*col| {
            for (col.cells.items) |cell| {
                cell.deinit();
                cell.* = .{ .tag = .int_val, .data = .{ .int_val = val } };
            }
            col.invalidateSort();
        }
    }

    pub fn fillFloat(self: *StzTable, val: f64) void {
        for (self.columns.items) |*col| {
            for (col.cells.items) |cell| {
                cell.deinit();
                cell.* = .{ .tag = .float_val, .data = .{ .float_val = val } };
            }
            col.invalidateSort();
        }
    }
};

// ─── Helpers ───

fn cellToFloat(cell: *const StzValue) f64 {
    return switch (cell.tag) {
        .int_val => @floatFromInt(cell.data.int_val),
        .float_val => cell.data.float_val,
        .bool_val => if (cell.data.bool_val) @as(f64, 1) else @as(f64, 0),
        else => 0,
    };
}

fn computeAggregate(cells: []*StzValue, indices: []const usize, func: StzTable.AggFunc) f64 {
    if (indices.len == 0) return 0;

    return switch (func) {
        .sum => blk: {
            var s: f64 = 0;
            for (indices) |i| s += cellToFloat(cells[i]);
            break :blk s;
        },
        .avg => blk: {
            var s: f64 = 0;
            for (indices) |i| s += cellToFloat(cells[i]);
            break :blk s / @as(f64, @floatFromInt(indices.len));
        },
        .min => blk: {
            var m: f64 = cellToFloat(cells[indices[0]]);
            for (indices[1..]) |i| {
                const v = cellToFloat(cells[i]);
                if (v < m) m = v;
            }
            break :blk m;
        },
        .max => blk: {
            var m: f64 = cellToFloat(cells[indices[0]]);
            for (indices[1..]) |i| {
                const v = cellToFloat(cells[i]);
                if (v > m) m = v;
            }
            break :blk m;
        },
        .count => @floatFromInt(indices.len),
        .product => blk: {
            var p: f64 = 1;
            for (indices) |i| p *= cellToFloat(cells[i]);
            break :blk p;
        },
    };
}

// ─── C ABI ───

pub fn stz_table_new() callconv(.c) ?*StzTable {
    return StzTable.init() catch null;
}

pub fn stz_table_free(t: ?*StzTable) callconv(.c) void {
    if (t) |tbl| tbl.deinit();
}

pub fn stz_table_num_cols(t: ?*const StzTable) callconv(.c) i64 {
    const tbl = t orelse return 0;
    return @intCast(tbl.numColumns());
}

pub fn stz_table_num_rows(t: ?*const StzTable) callconv(.c) i64 {
    const tbl = t orelse return 0;
    return @intCast(tbl.num_rows);
}

pub fn stz_table_add_col(t: ?*StzTable, name: [*]const u8, name_len: usize) callconv(.c) i64 {
    const tbl = t orelse return -1;
    const idx = tbl.addColumn(name, name_len) catch return -1;
    return @intCast(idx);
}

pub fn stz_table_remove_col(t: ?*StzTable, col_idx: i64) callconv(.c) void {
    const tbl = t orelse return;
    if (col_idx < 0) return;
    tbl.removeColumn(@intCast(col_idx));
}

pub fn stz_table_find_col(t: ?*const StzTable, name: [*]const u8, name_len: usize) callconv(.c) i64 {
    const tbl = t orelse return -1;
    return tbl.findColumn(name, name_len);
}

pub fn stz_table_col_name(t: ?*const StzTable, col_idx: i64) callconv(.c) ?[*]const u8 {
    const tbl = t orelse return null;
    if (col_idx < 0) return null;
    const name = tbl.columnName(@intCast(col_idx)) orelse return null;
    return name.ptr;
}

pub fn stz_table_col_name_len(t: ?*const StzTable, col_idx: i64) callconv(.c) usize {
    const tbl = t orelse return 0;
    if (col_idx < 0) return 0;
    const name = tbl.columnName(@intCast(col_idx)) orelse return 0;
    return name.len;
}

pub fn stz_table_rename_col(t: ?*StzTable, col_idx: i64, name: [*]const u8, name_len: usize) callconv(.c) void {
    const tbl = t orelse return;
    if (col_idx < 0) return;
    tbl.renameColumn(@intCast(col_idx), name, name_len) catch {};
}

pub fn stz_table_add_row(t: ?*StzTable) callconv(.c) i64 {
    const tbl = t orelse return -1;
    const idx = tbl.addRow() catch return -1;
    return @intCast(idx);
}

pub fn stz_table_remove_row(t: ?*StzTable, row_idx: i64) callconv(.c) void {
    const tbl = t orelse return;
    if (row_idx < 0) return;
    tbl.removeRow(@intCast(row_idx));
}

pub fn stz_table_set_cell_int(t: ?*StzTable, col: i64, row: i64, val: i64) callconv(.c) void {
    const tbl = t orelse return;
    if (col < 0 or row < 0) return;
    tbl.setCellInt(@intCast(col), @intCast(row), val) catch {};
}

pub fn stz_table_set_cell_float(t: ?*StzTable, col: i64, row: i64, val: f64) callconv(.c) void {
    const tbl = t orelse return;
    if (col < 0 or row < 0) return;
    tbl.setCellFloat(@intCast(col), @intCast(row), val) catch {};
}

pub fn stz_table_set_cell_string(t: ?*StzTable, col: i64, row: i64, ptr: [*]const u8, len: usize) callconv(.c) void {
    const tbl = t orelse return;
    if (col < 0 or row < 0) return;
    tbl.setCellString(@intCast(col), @intCast(row), ptr, len) catch {};
}

pub fn stz_table_get_cell_int(t: ?*const StzTable, col: i64, row: i64) callconv(.c) i64 {
    const tbl = t orelse return 0;
    if (col < 0 or row < 0) return 0;
    const cell = tbl.getCell(@intCast(col), @intCast(row)) orelse return 0;
    return switch (cell.tag) {
        .int_val => cell.data.int_val,
        .float_val => @intFromFloat(cell.data.float_val),
        .bool_val => if (cell.data.bool_val) @as(i64, 1) else 0,
        else => 0,
    };
}

pub fn stz_table_get_cell_float(t: ?*const StzTable, col: i64, row: i64) callconv(.c) f64 {
    const tbl = t orelse return 0;
    if (col < 0 or row < 0) return 0;
    const cell = tbl.getCell(@intCast(col), @intCast(row)) orelse return 0;
    return cellToFloat(cell);
}

pub fn stz_table_get_cell_string(t: ?*const StzTable, col: i64, row: i64) callconv(.c) ?[*]const u8 {
    const tbl = t orelse return null;
    if (col < 0 or row < 0) return null;
    const cell = tbl.getCell(@intCast(col), @intCast(row)) orelse return null;
    if (cell.tag != .string_val) return null;
    return cell.data.string_val.ptr;
}

pub fn stz_table_get_cell_string_len(t: ?*const StzTable, col: i64, row: i64) callconv(.c) usize {
    const tbl = t orelse return 0;
    if (col < 0 or row < 0) return 0;
    const cell = tbl.getCell(@intCast(col), @intCast(row)) orelse return 0;
    if (cell.tag != .string_val) return 0;
    return cell.data.string_val.len;
}

pub fn stz_table_get_cell_type(t: ?*const StzTable, col: i64, row: i64) callconv(.c) i32 {
    const tbl = t orelse return -1;
    if (col < 0 or row < 0) return -1;
    const cell = tbl.getCell(@intCast(col), @intCast(row)) orelse return -1;
    return @intFromEnum(cell.tag);
}

pub fn stz_table_sort_on(t: ?*StzTable, col: i64, ascending: i32) callconv(.c) void {
    const tbl = t orelse return;
    if (col < 0) return;
    tbl.sortOnColumn(@intCast(col), ascending != 0) catch {};
}

pub fn stz_table_swap_rows(t: ?*StzTable, a: i64, b: i64) callconv(.c) void {
    const tbl = t orelse return;
    if (a < 0 or b < 0) return;
    tbl.swapRows(@intCast(a), @intCast(b));
}

pub fn stz_table_reverse_rows(t: ?*StzTable) callconv(.c) void {
    const tbl = t orelse return;
    tbl.reverseRows();
}

pub fn stz_table_sum_col(t: ?*const StzTable, col: i64) callconv(.c) f64 {
    const tbl = t orelse return 0;
    if (col < 0) return 0;
    return tbl.sumColumn(@intCast(col));
}

pub fn stz_table_sum_col_range(t: ?*const StzTable, col: i64, from: i64, to: i64) callconv(.c) f64 {
    const tbl = t orelse return 0;
    if (col < 0 or from < 0 or to < 0) return 0;
    return tbl.sumColumnRange(@intCast(col), @intCast(from), @intCast(to));
}

pub fn stz_table_avg_col(t: ?*const StzTable, col: i64) callconv(.c) f64 {
    const tbl = t orelse return 0;
    if (col < 0) return 0;
    return tbl.avgColumn(@intCast(col));
}

pub fn stz_table_min_col(t: ?*const StzTable, col: i64) callconv(.c) f64 {
    const tbl = t orelse return 0;
    if (col < 0) return 0;
    return tbl.minColumn(@intCast(col));
}

pub fn stz_table_max_col(t: ?*const StzTable, col: i64) callconv(.c) f64 {
    const tbl = t orelse return 0;
    if (col < 0) return 0;
    return tbl.maxColumn(@intCast(col));
}

pub fn stz_table_product_col(t: ?*const StzTable, col: i64) callconv(.c) f64 {
    const tbl = t orelse return 0;
    if (col < 0) return 0;
    return tbl.productColumn(@intCast(col));
}

pub fn stz_table_count_non_null(t: ?*const StzTable, col: i64) callconv(.c) i64 {
    const tbl = t orelse return 0;
    if (col < 0) return 0;
    return @intCast(tbl.countNonNull(@intCast(col)));
}

pub fn stz_table_count_in_col(t: ?*const StzTable, col: i64, val: ?*const StzValue) callconv(.c) i64 {
    const tbl = t orelse return 0;
    const v = val orelse return 0;
    if (col < 0) return 0;
    return @intCast(tbl.countInColumn(@intCast(col), v));
}

pub fn stz_table_contains_in_col(t: ?*const StzTable, col: i64, val: ?*const StzValue) callconv(.c) i32 {
    const tbl = t orelse return 0;
    const v = val orelse return 0;
    if (col < 0) return 0;
    return if (tbl.containsInColumn(@intCast(col), v)) @as(i32, 1) else 0;
}

pub fn stz_table_fill_int(t: ?*StzTable, val: i64) callconv(.c) void {
    const tbl = t orelse return;
    tbl.fillInt(val);
}

pub fn stz_table_fill_float(t: ?*StzTable, val: f64) callconv(.c) void {
    const tbl = t orelse return;
    tbl.fillFloat(val);
}

pub fn stz_table_clone(t: ?*const StzTable) callconv(.c) ?*StzTable {
    const tbl = t orelse return null;
    return tbl.clone() catch null;
}

pub fn stz_table_sub_table(t: ?*const StzTable, col_indices: [*]const i64, num_cols: usize) callconv(.c) ?*StzTable {
    const tbl = t orelse return null;
    const usize_indices = allocator.alloc(usize, num_cols) catch return null;
    defer allocator.free(usize_indices);
    for (0..num_cols) |i| {
        if (col_indices[i] < 0) return null;
        usize_indices[i] = @intCast(col_indices[i]);
    }
    return tbl.subTable(usize_indices) catch null;
}

pub fn stz_table_group_by(t: ?*const StzTable, group_col: i64, value_col: i64, agg_func: i32) callconv(.c) ?*StzTable {
    const tbl = t orelse return null;
    if (group_col < 0 or value_col < 0 or agg_func < 0 or agg_func > 5) return null;
    return tbl.groupByAggregate(
        @intCast(group_col),
        @intCast(value_col),
        @enumFromInt(@as(u8, @intCast(agg_func))),
    ) catch null;
}

pub fn stz_table_filter_rows(t: ?*const StzTable, col: i64, val: ?*const StzValue) callconv(.c) ?*StzTable {
    const tbl = t orelse return null;
    const v = val orelse return null;
    if (col < 0) return null;
    return tbl.filterRows(@intCast(col), v) catch null;
}

// ─── Tests ───

test "table create and basic ops" {
    const t = StzTable.init() catch unreachable;
    defer t.deinit();

    _ = try t.addColumn("name", 4);
    _ = try t.addColumn("age", 3);
    _ = try t.addColumn("city", 4);

    try std.testing.expectEqual(@as(usize, 3), t.numColumns());
    try std.testing.expectEqual(@as(usize, 0), t.num_rows);

    // Add rows
    _ = try t.addRow();
    _ = try t.addRow();
    _ = try t.addRow();

    try std.testing.expectEqual(@as(usize, 3), t.num_rows);

    // Set cells
    try t.setCellString(0, 0, "Ali", 3);
    try t.setCellInt(1, 0, 35);
    try t.setCellString(2, 0, "Tunis", 5);

    try t.setCellString(0, 1, "Dania", 5);
    try t.setCellInt(1, 1, 28);
    try t.setCellString(2, 1, "Cairo", 5);

    try t.setCellString(0, 2, "Han", 3);
    try t.setCellInt(1, 2, 42);
    try t.setCellString(2, 2, "Beijing", 7);

    // Get cell
    try std.testing.expectEqual(@as(i64, 35), stz_table_get_cell_int(t, 1, 0));
    try std.testing.expectEqual(@as(i64, 42), stz_table_get_cell_int(t, 1, 2));

    // Find column
    try std.testing.expectEqual(@as(i64, 1), t.findColumn("age", 3));
    try std.testing.expectEqual(@as(i64, -1), t.findColumn("xyz", 3));

    // Column name
    const name = t.columnName(0).?;
    try std.testing.expect(std.mem.eql(u8, name, "name"));
}

test "table sort" {
    const t = StzTable.init() catch unreachable;
    defer t.deinit();

    _ = try t.addColumn("name", 4);
    _ = try t.addColumn("score", 5);

    _ = try t.addRow();
    try t.setCellString(0, 0, "Charlie", 7);
    try t.setCellInt(1, 0, 85);

    _ = try t.addRow();
    try t.setCellString(0, 1, "Alice", 5);
    try t.setCellInt(1, 1, 92);

    _ = try t.addRow();
    try t.setCellString(0, 2, "Bob", 3);
    try t.setCellInt(1, 2, 78);

    // Sort ascending on name
    try t.sortOnColumn(0, true);

    try std.testing.expectEqual(@as(i64, 92), stz_table_get_cell_int(t, 1, 0)); // Alice
    try std.testing.expectEqual(@as(i64, 78), stz_table_get_cell_int(t, 1, 1)); // Bob
    try std.testing.expectEqual(@as(i64, 85), stz_table_get_cell_int(t, 1, 2)); // Charlie

    // Sort descending on score
    try t.sortOnColumn(1, false);
    try std.testing.expectEqual(@as(i64, 92), stz_table_get_cell_int(t, 1, 0));
    try std.testing.expectEqual(@as(i64, 85), stz_table_get_cell_int(t, 1, 1));
    try std.testing.expectEqual(@as(i64, 78), stz_table_get_cell_int(t, 1, 2));
}

test "table aggregation" {
    const t = StzTable.init() catch unreachable;
    defer t.deinit();

    _ = try t.addColumn("product", 7);
    _ = try t.addColumn("qty", 3);
    _ = try t.addColumn("price", 5);

    _ = try t.addRow();
    try t.setCellString(0, 0, "Apple", 5);
    try t.setCellInt(1, 0, 10);
    try t.setCellFloat(2, 0, 2.5);

    _ = try t.addRow();
    try t.setCellString(0, 1, "Banana", 6);
    try t.setCellInt(1, 1, 5);
    try t.setCellFloat(2, 1, 1.2);

    _ = try t.addRow();
    try t.setCellString(0, 2, "Cherry", 6);
    try t.setCellInt(1, 2, 20);
    try t.setCellFloat(2, 2, 3.0);

    try std.testing.expectEqual(@as(f64, 35), t.sumColumn(1));
    try std.testing.expectApproxEqAbs(@as(f64, 6.7), t.sumColumn(2), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 11.667), t.avgColumn(1), 0.01);
    try std.testing.expectEqual(@as(f64, 5), t.minColumn(1));
    try std.testing.expectEqual(@as(f64, 20), t.maxColumn(1));
    try std.testing.expectEqual(@as(f64, 1000), t.productColumn(1)); // 10*5*20
}

test "table swap and reverse" {
    const t = StzTable.init() catch unreachable;
    defer t.deinit();

    _ = try t.addColumn("x", 1);
    for (0..3) |_| _ = try t.addRow();
    try t.setCellInt(0, 0, 1);
    try t.setCellInt(0, 1, 2);
    try t.setCellInt(0, 2, 3);

    t.swapRows(0, 2);
    try std.testing.expectEqual(@as(i64, 3), stz_table_get_cell_int(t, 0, 0));
    try std.testing.expectEqual(@as(i64, 1), stz_table_get_cell_int(t, 0, 2));

    t.reverseRows();
    try std.testing.expectEqual(@as(i64, 1), stz_table_get_cell_int(t, 0, 0));
    try std.testing.expectEqual(@as(i64, 3), stz_table_get_cell_int(t, 0, 2));
}

test "table clone and subtable" {
    const t = StzTable.init() catch unreachable;
    defer t.deinit();

    _ = try t.addColumn("a", 1);
    _ = try t.addColumn("b", 1);
    _ = try t.addColumn("c", 1);

    _ = try t.addRow();
    try t.setCellInt(0, 0, 1);
    try t.setCellInt(1, 0, 2);
    try t.setCellInt(2, 0, 3);

    _ = try t.addRow();
    try t.setCellInt(0, 1, 4);
    try t.setCellInt(1, 1, 5);
    try t.setCellInt(2, 1, 6);

    // Clone
    const c = try t.clone();
    defer c.deinit();
    try std.testing.expectEqual(@as(usize, 3), c.numColumns());
    try std.testing.expectEqual(@as(usize, 2), c.num_rows);
    try std.testing.expectEqual(@as(i64, 5), stz_table_get_cell_int(c, 1, 1));

    // SubTable
    const indices = [_]usize{ 0, 2 };
    const sub = try t.subTable(&indices);
    defer sub.deinit();
    try std.testing.expectEqual(@as(usize, 2), sub.numColumns());
    try std.testing.expectEqual(@as(i64, 3), stz_table_get_cell_int(sub, 1, 0));
    try std.testing.expectEqual(@as(i64, 6), stz_table_get_cell_int(sub, 1, 1));
}

test "table group by" {
    const t = StzTable.init() catch unreachable;
    defer t.deinit();

    _ = try t.addColumn("dept", 4);
    _ = try t.addColumn("salary", 6);

    _ = try t.addRow();
    try t.setCellString(0, 0, "IT", 2);
    try t.setCellInt(1, 0, 50000);

    _ = try t.addRow();
    try t.setCellString(0, 1, "HR", 2);
    try t.setCellInt(1, 1, 45000);

    _ = try t.addRow();
    try t.setCellString(0, 2, "IT", 2);
    try t.setCellInt(1, 2, 55000);

    _ = try t.addRow();
    try t.setCellString(0, 3, "HR", 2);
    try t.setCellInt(1, 3, 48000);

    const grouped = try t.groupByAggregate(0, 1, .sum);
    defer grouped.deinit();

    try std.testing.expectEqual(@as(usize, 2), grouped.numColumns());
    try std.testing.expectEqual(@as(usize, 2), grouped.num_rows);

    // Total salaries: IT=105000, HR=93000 (order may vary)
    const sum1 = stz_table_get_cell_float(grouped, 1, 0);
    const sum2 = stz_table_get_cell_float(grouped, 1, 1);
    const total = sum1 + sum2;
    try std.testing.expectApproxEqAbs(@as(f64, 198000), total, 0.01);
}

test "table fill" {
    const t = StzTable.init() catch unreachable;
    defer t.deinit();

    _ = try t.addColumn("a", 1);
    _ = try t.addColumn("b", 1);
    _ = try t.addRow();
    _ = try t.addRow();

    t.fillInt(42);
    try std.testing.expectEqual(@as(i64, 42), stz_table_get_cell_int(t, 0, 0));
    try std.testing.expectEqual(@as(i64, 42), stz_table_get_cell_int(t, 1, 1));
}

test "table remove row and column" {
    const t = StzTable.init() catch unreachable;
    defer t.deinit();

    _ = try t.addColumn("x", 1);
    _ = try t.addColumn("y", 1);
    for (0..3) |_| _ = try t.addRow();
    try t.setCellInt(0, 0, 10);
    try t.setCellInt(0, 1, 20);
    try t.setCellInt(0, 2, 30);

    t.removeRow(1);
    try std.testing.expectEqual(@as(usize, 2), t.num_rows);
    try std.testing.expectEqual(@as(i64, 30), stz_table_get_cell_int(t, 0, 1));

    t.removeColumn(0);
    try std.testing.expectEqual(@as(usize, 1), t.numColumns());
}
