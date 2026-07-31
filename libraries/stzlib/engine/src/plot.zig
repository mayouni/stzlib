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

/// The horizontal bar renderer's knobs. Different defaults from the vertical one --
/// a horizontal plot is one row per bar and a fixed pixel width, where a vertical one
/// is one column per bar and a fixed height.
pub const HBarOptions = extern struct {
    width: u32 = 18,
    bar_height: u32 = 1,
    max_height: u32 = 30,
    max_label_width: u32 = 12,
    inter_space: u32 = 0,
    axis_padding: u32 = 1,
    show_h_axis: u8 = 1,
    show_v_axis: u8 = 1,
    show_labels: u8 = 1,
    show_axis_labels: u8 = 1,
    show_values: u8 = 0,
    show_percent: u8 = 0,
};

const CH_HBAR: u21 = '▇';

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
    /// Like toString, but every row is RIGHT-TRIMMED of spaces.
    ///
    /// The histogram serialises this way where the bar plots pad to full width. It
    /// is a real difference in the output, not a tidy-up: a padded row and a trimmed
    /// row are different strings, and the parity check compares strings.
    fn toStringTrimmed(self: *Canvas, alloc: std.mem.Allocator) ![]u8 {
        var out = std.ArrayList(u8){};
        errdefer out.deinit(alloc);
        var r: usize = 0;
        while (r < self.h) : (r += 1) {
            var last: usize = 0;
            var c: usize = 0;
            while (c < self.w) : (c += 1) {
                if (self.cells[r * self.w + c] != ' ') last = c + 1;
            }
            c = 0;
            while (c < last) : (c += 1) {
                var b: [4]u8 = undefined;
                const n = std.unicode.utf8Encode(self.cells[r * self.w + c], &b) catch 1;
                try out.appendSlice(alloc, b[0..n]);
            }
            if (r + 1 < self.h) try out.append(alloc, '\n');
        }
        return out.toOwnedSlice(alloc);
    }

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

/// A percentage always carries ONE DECIMAL, even when it is whole: Ring's renderer
/// prints 25.0% and not 25%, because it rounds to one place and formats the rounded
/// number rather than trimming it. Values are different -- an integer value prints
/// bare -- so the two cannot share a formatter.
fn fmtPct(buf: []u8, x: f64) []const u8 {
    return std.fmt.bufPrint(buf, "{d:.1}%", .{plotRound(x, 1)}) catch "";
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
            const t = fmtNum(&numbuf, values[i], 1);
            if (t.len > w) w = t.len;
        } else if (show_pct and sum > 0) {
            const t = fmtPct(&numbuf, values[i] * 100 / sum);
            if (t.len > w) w = t.len;
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
                fmtNum(&numbuf, v, 1)
            else fmtPct(&numbuf, if (sum > 0) v * 100 / sum else 0);
            // DIRECTLY ABOVE ITS OWN BAR, not in one shared row at the top. The row
            // is still reserved in the layout -- the tallest bar's value needs it --
            // but a short bar's value follows the bar down, which is what makes the
            // number read as belonging to it.
            var vr = if (bars_end_row > bh) bars_end_row - bh else 1;
            if (vr < 1) vr = 1;
            const toff = if (ew[i] > t.len) (ew[i] - t.len) / 2 else 0;
            cv.putText(vr, col + toff, t);
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
    try testing.expect(std.mem.indexOf(u8, withp, "25.0%") != null);
    try testing.expect(std.mem.indexOf(u8, withp, "75.0%") != null);
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

/// RENDER A HORIZONTAL BAR PLOT, complete.
///
/// One row per bar, labels down the left, bars growing rightward. Note this is NOT
/// the vertical renderer transposed: the widths, the axis columns and even the bar
/// glyph differ, which is why stzHBarPlot overrode almost every drawing routine and
/// why inheriting the vertical ToString() rendered horizontal plots as vertical ones.
pub fn renderHBar(
    alloc: std.mem.Allocator,
    values: []const f64,
    labels_joined: []const u8,
    opts: HBarOptions,
) ![]u8 {
    const n = values.len;
    if (n == 0) return PlotError.BadShape;

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

    const show_v = opts.show_v_axis != 0;
    const show_h = opts.show_h_axis != 0;
    const show_lab = opts.show_labels != 0 and opts.show_axis_labels != 0;
    const show_val = opts.show_values != 0;
    const show_pct = opts.show_percent != 0 and !show_val;

    const to_show = @min(n, opts.max_height);
    const bars_h = to_show * opts.bar_height;

    var max_lab: usize = 0;
    if (show_lab) {
        for (0..to_show) |i| {
            if (i < labels.items.len) {
                const lw = @min(cpLen(labels.items[i]), opts.max_label_width);
                if (lw > max_lab) max_lab = lw;
            }
        }
    }

    // ── columns, left to right ──
    var col: usize = 1;
    var labels_col: usize = 0;
    if (show_lab and max_lab > 0) {
        labels_col = col;
        col += max_lab + opts.axis_padding;
    }
    var v_axis_col: usize = 0;
    if (show_v) {
        v_axis_col = col;
        col += 1 + opts.axis_padding;
    }
    const bars_start = col;
    const bars_end = col + opts.width - 1;
    col = bars_end + 1;

    var values_col: usize = 0;
    var numbuf: [64]u8 = undefined;
    if (show_val or show_pct) {
        values_col = col + 1;
        var max_vw: usize = 0;
        for (0..to_show) |i| {
            const t = if (show_val)
                fmtNum(&numbuf, values[i], 1)
            else fmtPct(&numbuf, if (sum > 0) values[i] * 100 / sum else 0);
            if (t.len > max_vw) max_vw = t.len;
        }
        col += max_vw + 1;
    }
    const total_w = col - 1;

    // ── rows ──
    var row: usize = 1;
    if (show_v) row = 2; // the arrow occupies row 1
    const bars_start_row = row;
    const bars_end_row = row + bars_h - 1;
    row = bars_end_row + 1;
    var h_axis_row: usize = 0;
    if (show_h) {
        h_axis_row = row;
        row += 1;
    }
    const total_h = row - 1;

    var cv = try Canvas.init(alloc, total_w, total_h);
    defer cv.deinit();

    if (show_v) {
        cv.put(1, v_axis_col, CH_VARROW);
        var r = bars_start_row;
        while (r <= bars_end_row) : (r += 1) cv.put(r, v_axis_col, CH_VAXIS);
    }
    if (show_h) {
        cv.put(h_axis_row, v_axis_col, if (show_v) CH_ORIGIN else CH_HAXIS);
        var c = v_axis_col + 1;
        while (c < total_w) : (c += 1) cv.put(h_axis_row, c, CH_HAXIS);
        cv.put(h_axis_row, total_w, CH_HARROW);
    }

    const bars_w = bars_end - bars_start + 1;
    var r = bars_start_row;
    for (0..to_show) |i| {
        const v = values[i];
        var bw: usize = 0;
        if (maxv > 0 and v > 0) {
            bw = @intFromFloat(@ceil(v / maxv * @as(f64, @floatFromInt(bars_w))));
            if (bw == 0) bw = 1;
            if (bw > bars_w) bw = bars_w;
        }
        var k: usize = 0;
        while (k < bw) : (k += 1) cv.put(r, bars_start + k, CH_HBAR);

        if (labels_col != 0 and i < labels.items.len) {
            // RIGHT-ALIGNED against the axis, not left-aligned: the labels sit in a
            // column that ends where the axis begins, so a short label is pushed
            // right to meet it. Left-aligning detaches every short label from its bar.
            var lab = labels.items[i];
            var lw = cpLen(lab);
            var tbuf: [256]u8 = undefined;
            if (lw > opts.max_label_width and opts.max_label_width > 2) {
                // too long: cut and mark the cut, the way the Ring renderer did
                const keep = opts.max_label_width - 2;
                var it2 = std.unicode.Utf8Iterator{ .bytes = lab, .i = 0 };
                var taken: usize = 0;
                var end: usize = 0;
                while (taken < keep) : (taken += 1) {
                    if (it2.nextCodepointSlice()) |sl| end += sl.len else break;
                }
                if (end + 2 <= tbuf.len) {
                    @memcpy(tbuf[0..end], lab[0..end]);
                    tbuf[end] = '.';
                    tbuf[end + 1] = '.';
                    lab = tbuf[0 .. end + 2];
                    lw = taken + 2;
                }
            }
            const off = if (max_lab > lw) max_lab - lw else 0;
            cv.putText(r, labels_col + off, lab);
        }
        if (values_col != 0) {
            const t = if (show_val)
                fmtNum(&numbuf, v, 1)
            else fmtPct(&numbuf, if (sum > 0) v * 100 / sum else 0);
            // RIGHT AFTER THE BAR ENDS, one space along -- so the number tracks the
            // bar's length instead of sitting in a column far to its right
            cv.putText(r, bars_start + bw + 1, t);
        }
        r += opts.bar_height;
    }

    return cv.toString(alloc);
}

test "a horizontal bar plot renders exactly what the Ring implementation rendered" {
    const alloc = testing.allocator;
    const vals = [_]f64{ 3, 7, 5 };
    const out = try renderHBar(alloc, &vals, "A\nB\nC", .{});
    defer alloc.free(out);

    // ground truth captured from stzHBarPlot. Note the DIFFERENT bar glyph (▇, not
    // █), labels down the left, and one row per bar -- none of which the vertical
    // renderer produces, which is exactly why inheriting its ToString() was a bug.
    const want =
        "  ▲                   " ++ "\n" ++
        "A │ ▇▇▇▇▇▇▇▇          " ++ "\n" ++
        "B │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇" ++ "\n" ++
        "C │ ▇▇▇▇▇▇▇▇▇▇▇▇▇     " ++ "\n" ++
        "  ╰──────────────────►";
    try testing.expectEqualStrings(want, out);
}

/// ── BINNING, AS AN OPERATION OF ITS OWN ──
///
/// A histogram is two separate things: deciding the bins, and drawing them. The
/// first is pure statistics and is useful with no picture anywhere near it -- a host
/// asking "how is this distributed" wants edges and counts, not ASCII art. So it is
/// exported separately rather than buried inside the renderer.
///
/// BIN COUNT BY STURGES' RULE when the caller does not choose: ceil(1 + log2(n)),
/// floored at 5. Sturges assumes roughly normal data and under-bins heavy tails, but
/// it is the rule this library has always used and a caller who knows better passes
/// a count.
///
/// The LAST BIN INCLUDES THE MAXIMUM. Without that the largest value falls outside
/// every half-open bin and silently vanishes from its own histogram.
pub fn binCountFor(n: usize, requested: usize) usize {
    if (requested > 0) return requested;
    if (n == 0) return 0;
    const lg = std.math.log2(@as(f64, @floatFromInt(n)));
    const sturges: usize = @intFromFloat(@ceil(1.0 + lg));
    return @max(@as(usize, 5), sturges);
}

/// Bin `values` into `nbins` (0 asks for Sturges). Writes nbins+1 edges and nbins
/// counts. Returns the number of bins actually used.
pub fn binValues(
    values: []const f64,
    requested: usize,
    out_edges: []f64,
    out_counts: []u32,
) !usize {
    if (values.len == 0) return 0;
    const nb = binCountFor(values.len, requested);
    if (out_edges.len < nb + 1 or out_counts.len < nb) return PlotError.BadShape;

    var lo = values[0];
    var hi = values[0];
    for (values) |v| {
        if (v < lo) lo = v;
        if (v > hi) hi = v;
    }
    const span = hi - lo;
    // a constant sample has no spread; give it a unit-wide bin rather than dividing
    // by zero and reporting NaN edges
    const wide = if (span == 0) 1.0 else span / @as(f64, @floatFromInt(nb));

    for (0..nb + 1) |i| out_edges[i] = lo + @as(f64, @floatFromInt(i)) * wide;
    out_edges[nb] = if (span == 0) lo + 1 else hi;

    @memset(out_counts[0..nb], 0);
    for (values) |v| {
        var idx: usize = 0;
        if (span > 0) {
            const f = (v - lo) / wide;
            idx = @intFromFloat(@floor(f));
            if (idx >= nb) idx = nb - 1; // the maximum belongs to the last bin
        }
        out_counts[idx] += 1;
    }
    return nb;
}

test "binning counts every value exactly once, maximum included" {
    const vals = [_]f64{ 1, 2, 2, 3, 3, 3, 4, 4, 5 };
    var edges: [32]f64 = undefined;
    var counts: [32]u32 = undefined;
    const nb = try binValues(&vals, 0, &edges, &counts);

    // Sturges on 9 samples: ceil(1 + log2(9)) = ceil(4.17) = 5, and the floor is 5
    try testing.expectEqual(@as(usize, 5), nb);
    try testing.expectApproxEqAbs(@as(f64, 1), edges[0], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 5), edges[nb], 1e-12);

    // EVERY value is in exactly one bin -- the maximum too, which a half-open rule
    // would drop
    var total: u32 = 0;
    for (counts[0..nb]) |c| total += c;
    try testing.expectEqual(@as(u32, 9), total);
    try testing.expect(counts[nb - 1] >= 1); // the 5 landed somewhere
}

test "an explicit bin count overrides Sturges, and a flat sample still bins" {
    const vals = [_]f64{ 10, 20, 30, 40 };
    var edges: [32]f64 = undefined;
    var counts: [32]u32 = undefined;
    try testing.expectEqual(@as(usize, 2), try binValues(&vals, 2, &edges, &counts));
    try testing.expectEqual(@as(u32, 2), counts[0]);
    try testing.expectEqual(@as(u32, 2), counts[1]);

    // a sample with NO SPREAD: every value identical. The width would be zero and
    // every edge the same, so it gets a unit bin instead of NaN.
    const flat = [_]f64{ 7, 7, 7 };
    const nb = try binValues(&flat, 3, &edges, &counts);
    try testing.expectEqual(@as(usize, 3), nb);
    try testing.expectApproxEqAbs(@as(f64, 7), edges[0], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 8), edges[nb], 1e-12);
    try testing.expectEqual(@as(u32, 3), counts[0]);
}

/// The histogram renderer's knobs.
pub const HistOptions = extern struct {
    bar_width: u32 = 2,
    height: u32 = 10,
    max_label_width: u32 = 12,
    bar_inter_space: u32 = 1,
    label_inter_space: u32 = 1,
    axis_padding: u32 = 1,
    v_axis_width: u32 = 1,
    show_h_axis: u8 = 1,
    show_v_axis: u8 = 1,
    show_labels: u8 = 1,
    show_frequency: u8 = 0,
    show_percent: u8 = 0,
};

/// A BIN EDGE AS TEXT: round to one decimal, then compact.
///
/// Rounding first kills the float artefact that makes an edge print as
/// 3.40000000004; compacting keeps a large edge short (2.7K). Whatever this returns
/// is what gets MEASURED for the layout and what gets DRAWN, which is the whole
/// point -- three separate formattings is what made the Ring version's labels
/// collide with each other.
pub fn binLabel(buf: []u8, x: f64) []const u8 {
    const r = plotRound(x, 1);
    const a = @abs(r);
    if (a >= 1_000_000_000) {
        const q = fmtNum(buf[0 .. buf.len - 1], plotRound(r / 1_000_000_000, 1), 1);
        buf[q.len] = 'B';
        return buf[0 .. q.len + 1];
    }
    if (a >= 1_000_000) {
        const q = fmtNum(buf[0 .. buf.len - 1], plotRound(r / 1_000_000, 1), 1);
        buf[q.len] = 'M';
        return buf[0 .. q.len + 1];
    }
    if (a >= 1000) {
        const q = fmtNum(buf[0 .. buf.len - 1], plotRound(r / 1000, 1), 1);
        buf[q.len] = 'K';
        return buf[0 .. q.len + 1];
    }
    return fmtNum(buf, r, 1);
}

/// RENDER A HISTOGRAM: bins along the bottom, frequency upward, edges beneath.
///
/// `counts` is one frequency per bin and `edges` is counts.len + 1 boundaries, the
/// shape binValues produces -- so a caller can bin once and draw, or bin and never
/// draw, or draw bins it computed itself.
///
/// ── THE HEIGHT IS MEASURED TWICE, ON PURPOSE ──
///
/// A first pass assumes the configured height and works out how tall the tallest bar
/// would be; the layout is then REBUILT around that actual height. Without the second
/// pass a histogram of small counts reserves a tall empty chart, which is why the Ring
/// version does the same thing.
///
/// ── AND A FREQUENCY OF TWO DRAWS TWO ROWS ──
///
/// When the largest count fits inside the bar area the bar height IS the count, not a
/// proportion of it. That makes the picture readable as counts -- three blocks means
/// three observations -- and only when the counts outgrow the space does it fall back
/// to scaling. Worth keeping: it is the difference between a histogram you can read
/// and one you have to measure.
pub fn renderHistogram(
    alloc: std.mem.Allocator,
    counts: []const u32,
    edges: []const f64,
    opts: HistOptions,
) ![]u8 {
    const nb = counts.len;
    if (nb == 0 or edges.len < nb + 1) return PlotError.BadShape;

    var maxv: u32 = 0;
    var total: u32 = 0;
    for (counts) |c| {
        if (c > maxv) maxv = c;
        total += c;
    }

    const show_lab = opts.show_labels != 0;
    const show_val = opts.show_frequency != 0;
    const show_pct = opts.show_percent != 0 and !show_val;

    // ── bar height for a count, given the room available ──
    const barHeightOf = struct {
        fn f(v: u32, mx: u32, area: usize) usize {
            if (v == 0) return 0;
            if (mx <= area) return v; // a frequency of two draws two rows
            const h: usize = @intFromFloat(@ceil(@as(f64, @floatFromInt(area)) *
                @as(f64, @floatFromInt(v)) / @as(f64, @floatFromInt(mx))));
            return @max(@as(usize, 1), h);
        }
    }.f;

    // ── pass one: how tall does this actually need to be? ──
    const est = if (opts.height == 0) 20 else opts.height;
    const area1 = if (show_val or show_pct) est - 1 - 2 else est - 1 - 1;
    var tallest: usize = 0;
    for (counts) |c| {
        const h = barHeightOf(c, maxv, area1);
        if (h > tallest) tallest = h;
    }
    var required = tallest + 2; // one row for values above, one for the axis
    if (show_lab) required += 2; // two label rows: bin starts, then bin ends

    const axis_row = required;
    const bars_area_h = required - 2;
    const total_rows = if (show_lab) required + 2 else required;

    // ── widths: an element is as wide as the widest thing that must sit in it ──
    var lbuf: [64]u8 = undefined;
    var rbuf: [64]u8 = undefined;
    const ew = try alloc.alloc(usize, nb);
    defer alloc.free(ew);
    for (0..nb) |i| {
        var w: usize = opts.bar_width;
        if (show_lab) {
            const l1 = binLabel(&lbuf, edges[i]);
            const l2 = binLabel(&rbuf, edges[i + 1]);
            var lw = @max(cpLen(l1), cpLen(l2));
            if (lw > opts.max_label_width) lw = opts.max_label_width;
            if (lw > w) w = lw;
        }
        if (show_val) {
            const t = fmtNum(&lbuf, @floatFromInt(counts[i]), 1);
            if (t.len > w) w = t.len;
        } else if (show_pct and total > 0) {
            const t = fmtPct(&lbuf, @as(f64, @floatFromInt(counts[i])) * 100 /
                @as(f64, @floatFromInt(total)));
            if (t.len > w) w = t.len;
        }
        ew[i] = w;
    }
    const gap = opts.bar_inter_space + opts.label_inter_space;
    var area_w: usize = 0;
    for (ew) |w| area_w += w;
    if (nb > 1) area_w += gap * (nb - 1);

    const v_axis_col: usize = 1;
    const v_axis_end = v_axis_col + opts.v_axis_width - 1;
    var bars_start = v_axis_end + 1;
    if (opts.show_v_axis != 0) bars_start += opts.axis_padding;
    const bars_end = bars_start + area_w - 1;
    const h_axis_start: usize = if (opts.show_v_axis != 0) v_axis_end + opts.axis_padding else v_axis_col;
    const h_axis_end = bars_end + opts.axis_padding;
    const total_w = h_axis_end + 1;

    var cv = try Canvas.init(alloc, total_w, total_rows);
    defer cv.deinit();

    if (opts.show_v_axis != 0) {
        cv.put(1, v_axis_col, CH_VARROW);
        var r: usize = 2;
        while (r < axis_row) : (r += 1) cv.put(r, v_axis_col, CH_VAXIS);
    }
    if (opts.show_h_axis != 0) {
        var c = h_axis_start;
        while (c <= h_axis_end) : (c += 1) cv.put(axis_row, c, CH_HAXIS);
        if (opts.show_v_axis != 0) cv.put(axis_row, v_axis_col, CH_ORIGIN);
        cv.put(axis_row, h_axis_end, CH_HARROW);
    }

    var x = bars_start;
    for (0..nb) |i| {
        const h = barHeightOf(counts[i], maxv, bars_area_h);
        const bx = x + (ew[i] - opts.bar_width) / 2;
        var j: usize = 1;
        while (j <= h) : (j += 1) {
            const rr = axis_row - j;
            if (rr < 1) break;
            var k: usize = 0;
            while (k < opts.bar_width) : (k += 1) cv.put(rr, bx + k, CH_BAR);
        }

        if (show_val or show_pct) {
            const t = if (show_val)
                fmtNum(&lbuf, @floatFromInt(counts[i]), 1)
            else
                fmtPct(&lbuf, if (total > 0) @as(f64, @floatFromInt(counts[i])) * 100 /
                    @as(f64, @floatFromInt(total)) else 0);
            const vr = if (axis_row > h + 1) axis_row - h - 1 else 1;
            const off = if (ew[i] > t.len) (ew[i] - t.len) / 2 else 0;
            cv.putText(vr, x + off, t);
        }

        if (show_lab) {
            const l1 = binLabel(&lbuf, edges[i]);
            const w1 = cpLen(l1);
            const o1 = if (ew[i] > w1) (ew[i] - w1) / 2 else 0;
            cv.putText(axis_row + 1, x + o1, l1);

            const l2 = binLabel(&rbuf, edges[i + 1]);
            const w2 = cpLen(l2);
            const o2 = if (ew[i] > w2) (ew[i] - w2) / 2 else 0;
            cv.putText(axis_row + 2, x + o2, l2);
        }

        if (i + 1 < nb) x += ew[i] + gap;
    }

    return cv.toStringTrimmed(alloc);
}

test "a histogram renders exactly what the Ring implementation rendered" {
    const alloc = testing.allocator;
    // the counts and edges stzHistogram produces for [1,2,2,3,3,3,4,4,5]
    const counts = [_]u32{ 1, 2, 3, 2, 1 };
    const edges = [_]f64{ 1, 1.8, 2.6, 3.4000000000000004, 4.2, 5 };
    const out = try renderHistogram(alloc, &counts, &edges, .{});
    defer alloc.free(out);

    // ground truth captured from stzHistogram. Note the rows are RIGHT-TRIMMED --
    // unlike the bar plots, which pad every row to the full width.
    const want =
        "▲" ++ "\n" ++
        "│" ++ "\n" ++
        "│" ++ "\n" ++
        "│           ██" ++ "\n" ++
        "│      ██   ██   ██" ++ "\n" ++
        "│ ██   ██   ██   ██   ██" ++ "\n" ++
        "╰────────────────────────►" ++ "\n" ++
        "   1   1.8  2.6  3.4  4.2" ++ "\n" ++
        "  1.8  2.6  3.4  4.2   5";
    try testing.expectEqualStrings(want, out);

    // and the float artefact never reaches a label: 3.4000000000000004 prints 3.4
    try testing.expect(std.mem.indexOf(u8, out, "3.40000") == null);
}

test "a frequency of two draws two rows, until the counts outgrow the space" {
    const alloc = testing.allocator;
    // small counts: the bar height IS the count, so the picture reads as counts
    const small = [_]u32{ 1, 3, 2 };
    const e3 = [_]f64{ 0, 1, 2, 3 };
    const a = try renderHistogram(alloc, &small, &e3, .{});
    defer alloc.free(a);
    var rows = std.mem.splitScalar(u8, a, '\n');
    var nrows: usize = 0;
    while (rows.next()) |_| nrows += 1;
    // tallest bar 3 -> required 3 + 2 + 2 = 7, plus two label rows = 9
    try testing.expectEqual(@as(usize, 9), nrows);

    // large counts: they cannot fit, so the bars scale instead -- and the chart does
    // NOT grow to a hundred rows
    const big = [_]u32{ 10, 100, 40 };
    const b = try renderHistogram(alloc, &big, &e3, .{});
    defer alloc.free(b);
    var rows2 = std.mem.splitScalar(u8, b, '\n');
    var nrows2: usize = 0;
    while (rows2.next()) |_| nrows2 += 1;
    try testing.expect(nrows2 < 20);
}

test "bin labels compact only when they need to" {
    var buf: [64]u8 = undefined;
    try testing.expectEqualStrings("1", binLabel(&buf, 1));
    try testing.expectEqualStrings("1.8", binLabel(&buf, 1.8));
    try testing.expectEqualStrings("3.4", binLabel(&buf, 3.4000000000000004));
    try testing.expectEqualStrings("5", binLabel(&buf, 5));
    try testing.expectEqualStrings("1.2K", binLabel(&buf, 1200));
    try testing.expectEqualStrings("2K", binLabel(&buf, 2000));
    try testing.expectEqualStrings("2.7K", binLabel(&buf, 2666.6666));
    try testing.expectEqualStrings("1.2M", binLabel(&buf, 1234567));
    try testing.expectEqualStrings("1B", binLabel(&buf, 1000000000));
}
