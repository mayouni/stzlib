//! PLOTS -- rendered here, not laid out here and drawn somewhere else.
//!
//! ── THE OUTPUT IS THE FINISHED PICTURE ──
//!
//! It is tempting to have the engine compute "layout" -- bin edges, axis ticks,
//! scale factors -- and leave the drawing to each host. That is the same half-an-
//! operation mistake as returning neighbours and letting the host vote: a Python or
//! C face would receive a pile of numbers and still have to write a renderer, so the
//! library would have a plotting feature only in Ring.
//!
//! So these functions return THE TEXT, ready to print. A host calls one function and
//! displays what comes back.
//!
//! ── A CANVAS OF CODEPOINTS, NOT BYTES ──
//!
//! The glyphs are box-drawing and block characters -- ▲ │ ╰ ─ ► █ -- and every one of
//! them is multibyte in UTF-8. A byte grid would need three bytes per cell and every
//! column arithmetic would be wrong. The canvas therefore holds CODEPOINTS, one per
//! cell, and is encoded to UTF-8 once at the end, so "column 3" means the third
//! character on screen no matter what is in it.

const std = @import("std");

pub const PlotError = error{ OutOfMemory, BadShape };

/// Every knob the bar renderer has. The defaults are the ones stzBarPlot has always
/// carried, so a host that sets nothing gets the picture it used to get.
pub const BarOptions = extern struct {
    height: u32 = 7,
    bar_width: u32 = 2,
    inter_space: u32 = 1,
    v_axis_width: u32 = 1,
    axis_padding: u32 = 1,
    max_label_width: u32 = 12,
    show_h_axis: u8 = 1,
    show_v_axis: u8 = 1,
    show_labels: u8 = 1,
    show_axis_labels: u8 = 1,
    show_values: u8 = 0,
    show_percent: u8 = 0,
    show_average: u8 = 0,
};

const CH_BAR: u21 = '█';
const CH_VAXIS: u21 = '│';
const CH_HAXIS: u21 = '─';
const CH_VARROW: u21 = '▲';
const CH_HARROW: u21 = '►';
const CH_ORIGIN: u21 = '╰';
const CH_AVERAGE: u21 = '-';
const SPACE: u21 = ' ';

const Canvas = struct {
    alloc: std.mem.Allocator,
    cells: []u21,
    w: usize,
    h: usize,

    fn init(alloc: std.mem.Allocator, w: usize, h: usize) !Canvas {
        const cells = try alloc.alloc(u21, w * h);
        @memset(cells, SPACE);
        return .{ .alloc = alloc, .cells = cells, .w = w, .h = h };
    }

    fn deinit(self: *Canvas) void {
        self.alloc.free(self.cells);
    }

    /// 1-based row and column, silently ignoring anything off the canvas -- the
    /// callers below compute positions from user-supplied widths, and a plot should
    /// come out clipped rather than crash.
    fn put(self: *Canvas, row: usize, col: usize, c: u21) void {
        if (row == 0 or col == 0 or row > self.h or col > self.w) return;
        self.cells[(row - 1) * self.w + (col - 1)] = c;
    }

    fn putText(self: *Canvas, row: usize, col: usize, text: []const u8) void {
        var it = std.unicode.Utf8Iterator{ .bytes = text, .i = 0 };
        var c = col;
        while (it.nextCodepoint()) |cp| : (c += 1) self.put(row, c, cp);
    }

    /// UTF-8, rows joined by newline, NO trailing newline -- the Ring renderer ends
    /// the last line without one and callers print it as-is.
    fn toString(self: *Canvas, alloc: std.mem.Allocator) ![]u8 {
        var out = std.ArrayList(u8){};
        errdefer out.deinit(alloc);
        var buf: [4]u8 = undefined;
        for (0..self.h) |r| {
            if (r > 0) try out.append(alloc, '\n');
            for (0..self.w) |c| {
                const n = std.unicode.utf8Encode(self.cells[r * self.w + c], &buf) catch 1;
                try out.appendSlice(alloc, buf[0..n]);
            }
        }
        return out.toOwnedSlice(alloc);
    }
};

fn cpLen(s: []const u8) usize {
    return std.unicode.utf8CountCodepoints(s) catch s.len;
}

/// Round half-away-from-zero to `places`, matching the Ring helper the plots use.
fn plotRound(x: f64, places: u32) f64 {
    const m = std.math.pow(f64, 10, @floatFromInt(places));
    return @round(x * m) / m;
}

/// Format a number the way Ring prints it: an integer with no decimal point,
/// otherwise up to `places` decimals with trailing zeros trimmed.
fn fmtNum(buf: []u8, x: f64, places: u32) []const u8 {
    const r = plotRound(x, places);
    if (r == @trunc(r) and @abs(r) < 1e15) {
        return std.fmt.bufPrint(buf, "{d}", .{@as(i64, @intFromFloat(r))}) catch "";
    }
    return std.fmt.bufPrint(buf, "{d}", .{r}) catch "";
}

/// RENDER A VERTICAL BAR PLOT, complete.
///
/// `labels` is the label list joined by '\n'; an empty slice means no labels. The
/// caller owns the returned bytes.
pub fn renderBar(
    alloc: std.mem.Allocator,
    values: []const f64,
    labels_joined: []const u8,
    opts: BarOptions,
) ![]u8 {
    const n = values.len;
    if (n == 0) return PlotError.BadShape;

    // split the labels once
    var labels = std.ArrayList([]const u8){};
    defer labels.deinit(alloc);
    if (labels_joined.len > 0) {
        var it = std.mem.splitScalar(u8, labels_joined, '\n');
        while (it.next()) |piece| try labels.append(alloc, piece);
    }

    var sum: f64 = 0;
    var maxv: f64 = 0;
    for (values) |v| {
        sum += v;
        if (v > maxv) maxv = v;
    }
    const avg = sum / @as(f64, @floatFromInt(n));

    const show_v = opts.show_v_axis != 0;
    const show_h = opts.show_h_axis != 0;
    const show_lab = opts.show_labels != 0 and opts.show_axis_labels != 0;
    const show_val = opts.show_values != 0;
    const show_pct = opts.show_percent != 0 and !show_val;

    // ── element widths: a column is as wide as the widest of bar, label, value ──
    const ew = try alloc.alloc(usize, n);
    defer alloc.free(ew);
    var numbuf: [64]u8 = undefined;
    for (0..n) |i| {
        var w: usize = opts.bar_width;
        if (show_lab and i < labels.items.len) {
            const lw = @min(cpLen(labels.items[i]), opts.max_label_width);
            if (lw > w) w = lw;
        }
        if (show_val) {
            const t = fmtNum(&numbuf, values[i], 6);
            if (t.len > w) w = t.len;
        } else if (show_pct and sum > 0) {
            const p = values[i] * 100 / sum;
            const t = fmtNum(&numbuf, p, 1);
            if (t.len + 1 > w) w = t.len + 1; // the '%'
        }
        ew[i] = w;
    }

    var bars_w: usize = 0;
    for (ew) |w| bars_w += w;
    bars_w += (n - 1) * opts.inter_space;

    var total_w = bars_w + 2 + if (show_v) opts.v_axis_width + opts.axis_padding else 0;
    if (opts.show_average != 0) {
        const t = fmtNum(&numbuf, avg, 1);
        total_w += 2 + t.len;
    }

    // ── rows, allocated only for the parts that are shown ──
    var row: usize = 1;
    if (show_v) row = 2; // the arrow occupies row 1
    var values_row: usize = 0;
    if (show_val or show_pct) {
        values_row = row;
        row += 1;
    }
    const bars_end_row = row + opts.height - 1;
    row = bars_end_row + 1;
    var h_axis_row: usize = 0;
    if (show_h) {
        h_axis_row = row;
        row += 1;
    }
    var labels_row: usize = 0;
    if (show_lab) {
        labels_row = row;
        row += 1;
    }
    const total_h = row - 1;

    const bars_start_col: usize = if (show_v) opts.v_axis_width + opts.axis_padding + 1 else 1;
    const v_axis_start: usize = if (show_v) 2 else 1;

    var cv = try Canvas.init(alloc, total_w, total_h);
    defer cv.deinit();

    // ── the axes ──
    if (show_v) {
        cv.put(1, 1, CH_VARROW);
        var r = v_axis_start;
        while (r <= bars_end_row) : (r += 1) cv.put(r, 1, CH_VAXIS);
    }
    if (show_h) {
        cv.put(h_axis_row, 1, if (show_v) CH_ORIGIN else CH_HAXIS);
        var c: usize = 2;
        while (c < total_w) : (c += 1) cv.put(h_axis_row, c, CH_HAXIS);
        cv.put(h_axis_row, total_w, CH_HARROW);
    }

    // ── the bars, and the value and label that belong to each ──
    var col = bars_start_col;
    for (0..n) |i| {
        const v = values[i];
        var bh: usize = 0;
        if (maxv > 0 and v > 0) {
            // CEIL, not round. A bar shows the value's SHARE of the tallest, and
            // rounding down a share hides part of it: at height 7 a value of 100
            // against 300 is 2.33 rows, and drawing 2 understates it. Ring rounded
            // up and so does this -- the difference is visible in most plots, which
            // is exactly how the port's first version was caught.
            bh = @intFromFloat(@ceil(v / maxv * @as(f64, @floatFromInt(opts.height))));
            if (bh == 0) bh = 1; // a positive value is never invisible
            if (bh > opts.height) bh = opts.height;
        }
        // the bar is as wide as the BAR width, centred in the element
        const bw = @min(opts.bar_width, ew[i]);
        const off = (ew[i] - bw) / 2;
        var r = bars_end_row;
        var done: usize = 0;
        while (done < bh) : (done += 1) {
            var c: usize = 0;
            while (c < bw) : (c += 1) cv.put(r, col + off + c, CH_BAR);
            if (r == 0) break;
            r -= 1;
        }

        if (values_row != 0) {
            const t = if (show_val)
                fmtNum(&numbuf, v, 6)
            else blk: {
                const p = if (sum > 0) v * 100 / sum else 0;
                const s = fmtNum(numbuf[0 .. numbuf.len - 1], p, 1);
                numbuf[s.len] = '%';
                break :blk numbuf[0 .. s.len + 1];
            };
            const toff = if (ew[i] > t.len) (ew[i] - t.len) / 2 else 0;
            cv.putText(values_row, col + toff, t);
        }

        if (labels_row != 0 and i < labels.items.len) {
            const lab = labels.items[i];
            const lw = @min(cpLen(lab), opts.max_label_width);
            const loff = if (ew[i] > lw) (ew[i] - lw) / 2 else 0;
            cv.putText(labels_row, col + loff, lab);
        }

        col += ew[i] + opts.inter_space;
    }

    // ── the average line ──
    if (opts.show_average != 0 and maxv > 0) {
        var ah: usize = @intFromFloat(@ceil(avg / maxv * @as(f64, @floatFromInt(opts.height))));
        if (ah == 0) ah = 1;
        if (ah > opts.height) ah = opts.height;
        const ar = bars_end_row - (ah - 1);
        var c = bars_start_col;
        while (c < bars_start_col + bars_w) : (c += 1) {
            if (cv.cells[(ar - 1) * cv.w + (c - 1)] == SPACE) cv.put(ar, c, CH_AVERAGE);
        }
        const t = fmtNum(&numbuf, avg, 1);
        cv.putText(ar, bars_start_col + bars_w + 1, t);
    }

    return cv.toString(alloc);
}

// ── tests ────────────────────────────────────────────────────────────────────

const testing = std.testing;

test "a bar plot renders exactly what the Ring implementation rendered" {
    const alloc = testing.allocator;
    const vals = [_]f64{ 3, 7, 5 };
    const out = try renderBar(alloc, &vals, "A\nB\nC", .{});
    defer alloc.free(out);

    // THE GROUND TRUTH, captured from stzBarPlot before the renderer moved. Every
    // glyph and every trailing space, because a plot IS its exact characters.
    const want =
        "▲           \n" ++
        "│    ██     \n" ++
        "│    ██     \n" ++
        "│    ██ ██  \n" ++
        "│    ██ ██  \n" ++
        "│ ██ ██ ██  \n" ++
        "│ ██ ██ ██  \n" ++
        "│ ██ ██ ██  \n" ++
        "╰──────────►\n" ++
        "  A  B  C   ";
    try testing.expectEqualStrings(want, out);
}

test "a bar is CEILED to its share, never rounded down" {
    const alloc = testing.allocator;
    // 100 against a max of 300 at height 7 is 2.33 rows. Rounding gives 2 and
    // understates the bar; the Ring renderer ceiled, and so must this.
    const vals = [_]f64{ 100, 300 };
    const out = try renderBar(alloc, &vals, "X\nY", .{});
    defer alloc.free(out);
    const want =
        "▲        \n" ++
        "│    ██  \n" ++
        "│    ██  \n" ++
        "│    ██  \n" ++
        "│    ██  \n" ++
        "│ ██ ██  \n" ++
        "│ ██ ██  \n" ++
        "│ ██ ██  \n" ++
        "╰───────►\n" ++
        "  X  Y   ";
    try testing.expectEqualStrings(want, out);
}

test "the canvas counts CODEPOINTS, not bytes" {
    const alloc = testing.allocator;
    const vals = [_]f64{ 1, 1 };
    const out = try renderBar(alloc, &vals, "aa\nbb", .{ .height = 1 });
    defer alloc.free(out);

    // every row must be the same number of CHARACTERS even though the box glyphs are
    // three bytes each -- a byte-indexed canvas gets this wrong and the columns drift
    var it = std.mem.splitScalar(u8, out, '\n');
    var first: ?usize = null;
    while (it.next()) |line| {
        const len = try std.unicode.utf8CountCodepoints(line);
        if (first) |f| try testing.expectEqual(f, len) else first = len;
    }
    try testing.expect(first != null);
}

test "hiding a part removes its row or column rather than blanking it" {
    const alloc = testing.allocator;
    const vals = [_]f64{ 2, 4 };

    const full = try renderBar(alloc, &vals, "a\nb", .{ .height = 3 });
    defer alloc.free(full);
    const noaxis = try renderBar(alloc, &vals, "a\nb", .{
        .height = 3,
        .show_v_axis = 0,
        .show_h_axis = 0,
        .show_labels = 0,
    });
    defer alloc.free(noaxis);

    // the stripped plot is strictly smaller in both directions
    try testing.expect(noaxis.len < full.len);
    var it = std.mem.splitScalar(u8, noaxis, '\n');
    var rows: usize = 0;
    while (it.next()) |_| rows += 1;
    try testing.expectEqual(@as(usize, 3), rows); // bars only
}

test "values and percentages widen the column that needs it" {
    const alloc = testing.allocator;
    const vals = [_]f64{ 100, 300 };
    const withv = try renderBar(alloc, &vals, "a\nb", .{ .height = 2, .show_values = 1 });
    defer alloc.free(withv);

    // "100" is three characters, wider than the two-character bar, so the column
    // grows to fit it -- otherwise the number would overwrite its neighbour
    try testing.expect(std.mem.indexOf(u8, withv, "100") != null);
    try testing.expect(std.mem.indexOf(u8, withv, "300") != null);

    const withp = try renderBar(alloc, &vals, "a\nb", .{ .height = 2, .show_percent = 1 });
    defer alloc.free(withp);
    try testing.expect(std.mem.indexOf(u8, withp, "25%") != null);
    try testing.expect(std.mem.indexOf(u8, withp, "75%") != null);
}

test "a positive value is never rendered as nothing" {
    const alloc = testing.allocator;
    // 1 against a max of 1000 rounds to zero rows; it must still show one block, or
    // the plot would claim the value is absent
    const vals = [_]f64{ 1, 1000 };
    const out = try renderBar(alloc, &vals, "a\nb", .{ .height = 5 });
    defer alloc.free(out);
    var count: usize = 0;
    var i: usize = 0;
    while (std.mem.indexOfPos(u8, out, i, "█")) |p| : (i = p + 1) count += 1;
    // the tall bar is 5 rows x 2 cells, the short one at least 1 row x 2 cells
    try testing.expect(count >= 12);
}
