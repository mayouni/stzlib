const std = @import("std");

// ── Display Engine ──────────────────────────────────────────
// Structured output formatting: number formatting, alignment,
// column layout, tree rendering, bar charts.

const MAX_OUT = 4096;

pub fn format_number(val: f64, decimals: i32, out: [*]u8) callconv(.c) i32 {
    const d: u8 = if (decimals < 0) 0 else if (decimals > 15) 15 else @intCast(decimals);
    var buf: [64]u8 = undefined;
    const formatted = std.fmt.bufPrint(&buf, "{d:.[1]}", .{ val, d }) catch return 0;
    const len = @min(formatted.len, MAX_OUT);
    @memcpy(out[0..len], formatted[0..len]);
    return @intCast(len);
}

pub fn format_int_grouped(val: i64, sep: u8, group_size: i32, out: [*]u8) callconv(.c) i32 {
    if (group_size <= 0) return 0;
    const gs: usize = @intCast(group_size);
    var digits: [24]u8 = undefined;
    var dlen: usize = 0;
    var negative = false;
    var n: u64 = undefined;
    if (val < 0) {
        negative = true;
        n = @intCast(-val);
    } else {
        n = @intCast(val);
    }
    if (n == 0) {
        digits[0] = '0';
        dlen = 1;
    } else {
        while (n > 0) : (n /= 10) {
            digits[dlen] = @intCast('0' + n % 10);
            dlen += 1;
        }
    }
    var pos: usize = 0;
    if (negative) {
        out[pos] = '-';
        pos += 1;
    }
    var i: usize = dlen;
    while (i > 0) {
        i -= 1;
        out[pos] = digits[i];
        pos += 1;
        if (i > 0 and i % gs == 0) {
            out[pos] = sep;
            pos += 1;
        }
    }
    return @intCast(pos);
}

pub fn format_percent(val: f64, decimals: i32, out: [*]u8) callconv(.c) i32 {
    const pct = val * 100.0;
    const len = format_number(pct, decimals, out);
    if (len <= 0) return 0;
    const l: usize = @intCast(len);
    out[l] = '%';
    return len + 1;
}

pub fn format_bytes_human(bytes_val: i64, out: [*]u8) callconv(.c) i32 {
    const units = [_][]const u8{ "B", "KB", "MB", "GB", "TB", "PB" };
    var val: f64 = @floatFromInt(if (bytes_val < 0) -bytes_val else bytes_val);
    var unit_idx: usize = 0;
    while (val >= 1024.0 and unit_idx < units.len - 1) {
        val /= 1024.0;
        unit_idx += 1;
    }
    var buf: [64]u8 = undefined;
    const prec: u8 = if (unit_idx == 0) 0 else 1;
    const formatted = std.fmt.bufPrint(&buf, "{d:.[1]}", .{ val, prec }) catch return 0;
    var pos: usize = 0;
    if (bytes_val < 0) {
        out[pos] = '-';
        pos += 1;
    }
    @memcpy(out[pos .. pos + formatted.len], formatted);
    pos += formatted.len;
    out[pos] = ' ';
    pos += 1;
    const unit = units[unit_idx];
    @memcpy(out[pos .. pos + unit.len], unit);
    pos += unit.len;
    return @intCast(pos);
}

pub fn bar_chart(val: f64, max_val: f64, width: i32, fill: u8, empty: u8, out: [*]u8) callconv(.c) i32 {
    if (width <= 0 or max_val <= 0) return 0;
    const w: usize = @intCast(width);
    const ratio = if (val < 0) 0.0 else if (val > max_val) 1.0 else val / max_val;
    const filled: usize = @intFromFloat(ratio * @as(f64, @floatFromInt(w)));
    @memset(out[0..filled], fill);
    @memset(out[filled..w], empty);
    return @intCast(w);
}

pub fn progress_bar(current: i64, total: i64, width: i32, out: [*]u8) callconv(.c) i32 {
    if (width <= 2 or total <= 0) return 0;
    const w: usize = @intCast(width);
    const inner = w - 2;
    const ratio: f64 = @as(f64, @floatFromInt(if (current < 0) 0 else if (current > total) total else current)) / @as(f64, @floatFromInt(total));
    const filled: usize = @intFromFloat(ratio * @as(f64, @floatFromInt(inner)));
    out[0] = '[';
    @memset(out[1 .. 1 + filled], '#');
    @memset(out[1 + filled .. 1 + inner], '-');
    out[w - 1] = ']';
    return @intCast(w);
}

pub fn tree_prefix(depth: i32, is_last: i32, out: [*]u8) callconv(.c) i32 {
    if (depth <= 0) return 0;
    var pos: usize = 0;
    const d: usize = @intCast(depth);
    // Unicode tree connectors: │ = E2 94 82, └ = E2 94 94, ├ = E2 94 9C, ── = E2 94 80 x2
    const pipe = "\xe2\x94\x82"; // │
    const elbow = "\xe2\x94\x94"; // └
    const tee = "\xe2\x94\x9c"; // ├
    const dash = "\xe2\x94\x80"; // ─
    for (0..d - 1) |_| {
        @memcpy(out[pos .. pos + 3], pipe);
        out[pos + 3] = ' ';
        out[pos + 4] = ' ';
        out[pos + 5] = ' ';
        pos += 6;
    }
    if (is_last != 0) {
        @memcpy(out[pos .. pos + 3], elbow);
        @memcpy(out[pos + 3 .. pos + 6], dash);
        @memcpy(out[pos + 6 .. pos + 9], dash);
        out[pos + 9] = ' ';
        pos += 10;
    } else {
        @memcpy(out[pos .. pos + 3], tee);
        @memcpy(out[pos + 3 .. pos + 6], dash);
        @memcpy(out[pos + 6 .. pos + 9], dash);
        out[pos + 9] = ' ';
        pos += 10;
    }
    return @intCast(pos);
}

pub fn ruler(width: i32, major: i32, out: [*]u8) callconv(.c) i32 {
    if (width <= 0) return 0;
    const w: usize = @intCast(width);
    const m: usize = if (major <= 0) 10 else @intCast(major);
    // Ruler uses Unicode: │ for major, ┼ for mid, ─ for fill
    // Since each Unicode char is 3 bytes, output is 3*w bytes
    const tick_major = "\xe2\x94\x82"; // │
    const tick_mid = "\xe2\x94\xbc"; // ┼
    const tick_fill = "\xe2\x94\x80"; // ─
    var pos: usize = 0;
    for (0..w) |i| {
        if (i % m == 0) {
            @memcpy(out[pos .. pos + 3], tick_major);
        } else if (i % (m / 2) == 0 and m >= 4) {
            @memcpy(out[pos .. pos + 3], tick_mid);
        } else {
            @memcpy(out[pos .. pos + 3], tick_fill);
        }
        pos += 3;
    }
    return @intCast(pos);
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_display_format_number(v: f64, d: i32, o: [*]u8) callconv(.c) i32 { return format_number(v, d, o); }
pub export fn stz_display_format_int_grouped(v: i64, s: u8, g: i32, o: [*]u8) callconv(.c) i32 { return format_int_grouped(v, s, g, o); }
pub export fn stz_display_format_percent(v: f64, d: i32, o: [*]u8) callconv(.c) i32 { return format_percent(v, d, o); }
pub export fn stz_display_format_bytes(v: i64, o: [*]u8) callconv(.c) i32 { return format_bytes_human(v, o); }
pub export fn stz_display_bar_chart(v: f64, m: f64, w: i32, f: u8, e: u8, o: [*]u8) callconv(.c) i32 { return bar_chart(v, m, w, f, e, o); }
pub export fn stz_display_progress_bar(c: i64, t: i64, w: i32, o: [*]u8) callconv(.c) i32 { return progress_bar(c, t, w, o); }
pub export fn stz_display_tree_prefix(d: i32, l: i32, o: [*]u8) callconv(.c) i32 { return tree_prefix(d, l, o); }
pub export fn stz_display_ruler(w: i32, m: i32, o: [*]u8) callconv(.c) i32 { return ruler(w, m, o); }

// ── Tests ────────────────────────────────────────────────────

test "display: format_number" {
    var buf: [64]u8 = undefined;
    const len = format_number(3.14159, 2, &buf);
    try std.testing.expectEqualStrings("3.14", buf[0..@intCast(len)]);
}

test "display: format_int_grouped" {
    var buf: [64]u8 = undefined;
    const len = format_int_grouped(1234567, ',', 3, &buf);
    try std.testing.expectEqualStrings("1,234,567", buf[0..@intCast(len)]);
}

test "display: format_percent" {
    var buf: [64]u8 = undefined;
    const len = format_percent(0.856, 1, &buf);
    try std.testing.expectEqualStrings("85.6%", buf[0..@intCast(len)]);
}

test "display: format_bytes_human" {
    var buf: [64]u8 = undefined;
    const len = format_bytes_human(1536, &buf);
    try std.testing.expectEqualStrings("1.5 KB", buf[0..@intCast(len)]);
}

test "display: bar_chart" {
    var buf: [64]u8 = undefined;
    const len = bar_chart(7.0, 10.0, 10, '#', '.', &buf);
    try std.testing.expectEqualStrings("#######...", buf[0..@intCast(len)]);
}

test "display: progress_bar" {
    var buf: [64]u8 = undefined;
    const len = progress_bar(5, 10, 12, &buf);
    try std.testing.expectEqualStrings("[#####-----]", buf[0..@intCast(len)]);
}

test "display: tree_prefix" {
    var buf: [64]u8 = undefined;
    const len = tree_prefix(2, 0, &buf);
    try std.testing.expectEqualStrings("\xe2\x94\x82   \xe2\x94\x9c\xe2\x94\x80\xe2\x94\x80 ", buf[0..@intCast(len)]);
    const len2 = tree_prefix(1, 1, &buf);
    try std.testing.expectEqualStrings("\xe2\x94\x94\xe2\x94\x80\xe2\x94\x80 ", buf[0..@intCast(len2)]);
}

test "display: ruler" {
    var buf: [128]u8 = undefined;
    const len = ruler(10, 5, &buf);
    // 10 positions * 3 bytes per Unicode char = 30 bytes
    try std.testing.expectEqual(@as(i32, 30), len);
    // Position 0 = major tick │ (E2 94 82)
    try std.testing.expectEqual(@as(u8, 0xe2), buf[0]);
    try std.testing.expectEqual(@as(u8, 0x94), buf[1]);
    try std.testing.expectEqual(@as(u8, 0x82), buf[2]);
    // Position 5 = major tick │ (at byte offset 15)
    try std.testing.expectEqual(@as(u8, 0xe2), buf[15]);
    try std.testing.expectEqual(@as(u8, 0x94), buf[16]);
    try std.testing.expectEqual(@as(u8, 0x82), buf[17]);
}

// ── Edge case tests ──

test "display: format_number zero decimals" {
    var buf: [64]u8 = undefined;
    const len = format_number(42.789, 0, &buf);
    try std.testing.expectEqualStrings("43", buf[0..@intCast(len)]);
}

test "display: format_number negative decimals clamps to 0" {
    var buf: [64]u8 = undefined;
    const len = format_number(3.14, -5, &buf);
    try std.testing.expect(len > 0);
}

test "display: format_number large decimals clamps to 15" {
    var buf: [64]u8 = undefined;
    const len = format_number(1.0, 100, &buf);
    try std.testing.expect(len > 0);
}

test "display: format_int_grouped negative number" {
    var buf: [64]u8 = undefined;
    const len = format_int_grouped(-1234567, ',', 3, &buf);
    try std.testing.expectEqualStrings("-1,234,567", buf[0..@intCast(len)]);
}

test "display: format_int_grouped zero" {
    var buf: [64]u8 = undefined;
    const len = format_int_grouped(0, ',', 3, &buf);
    try std.testing.expectEqualStrings("0", buf[0..@intCast(len)]);
}

test "display: format_int_grouped invalid group_size" {
    var buf: [64]u8 = undefined;
    try std.testing.expectEqual(@as(i32, 0), format_int_grouped(1234, ',', 0, &buf));
    try std.testing.expectEqual(@as(i32, 0), format_int_grouped(1234, ',', -1, &buf));
}

test "display: format_percent zero" {
    var buf: [64]u8 = undefined;
    const len = format_percent(0.0, 1, &buf);
    try std.testing.expectEqualStrings("0.0%", buf[0..@intCast(len)]);
}

test "display: format_percent full" {
    var buf: [64]u8 = undefined;
    const len = format_percent(1.0, 0, &buf);
    try std.testing.expectEqualStrings("100%", buf[0..@intCast(len)]);
}

test "display: format_bytes_human exact boundaries" {
    var buf: [64]u8 = undefined;
    // 0 bytes
    const len0 = format_bytes_human(0, &buf);
    try std.testing.expectEqualStrings("0 B", buf[0..@intCast(len0)]);

    // 1024 bytes = 1.0 KB
    const len1 = format_bytes_human(1024, &buf);
    try std.testing.expectEqualStrings("1.0 KB", buf[0..@intCast(len1)]);

    // 1 byte
    const len2 = format_bytes_human(1, &buf);
    try std.testing.expectEqualStrings("1 B", buf[0..@intCast(len2)]);
}

test "display: format_bytes_human negative" {
    var buf: [64]u8 = undefined;
    const len = format_bytes_human(-1536, &buf);
    try std.testing.expectEqualStrings("-1.5 KB", buf[0..@intCast(len)]);
}

test "display: bar_chart edge cases" {
    var buf: [64]u8 = undefined;
    // Zero width
    try std.testing.expectEqual(@as(i32, 0), bar_chart(5.0, 10.0, 0, '#', '.', &buf));
    // Zero max
    try std.testing.expectEqual(@as(i32, 0), bar_chart(5.0, 0.0, 10, '#', '.', &buf));
    // Negative value clamps to 0
    const len = bar_chart(-5.0, 10.0, 5, '#', '.', &buf);
    try std.testing.expectEqualStrings(".....", buf[0..@intCast(len)]);
    // Value > max clamps to full
    const len2 = bar_chart(15.0, 10.0, 5, '#', '.', &buf);
    try std.testing.expectEqualStrings("#####", buf[0..@intCast(len2)]);
}

test "display: progress_bar edge cases" {
    var buf: [64]u8 = undefined;
    // Too narrow
    try std.testing.expectEqual(@as(i32, 0), progress_bar(5, 10, 1, &buf));
    try std.testing.expectEqual(@as(i32, 0), progress_bar(5, 10, 2, &buf));
    // Zero total
    try std.testing.expectEqual(@as(i32, 0), progress_bar(5, 0, 10, &buf));
    // Full progress
    const len = progress_bar(10, 10, 12, &buf);
    try std.testing.expectEqualStrings("[##########]", buf[0..@intCast(len)]);
    // Zero progress
    const len2 = progress_bar(0, 10, 12, &buf);
    try std.testing.expectEqualStrings("[----------]", buf[0..@intCast(len2)]);
}

test "display: tree_prefix depth 0 returns 0" {
    var buf: [64]u8 = undefined;
    try std.testing.expectEqual(@as(i32, 0), tree_prefix(0, 0, &buf));
}

test "display: ruler zero width returns 0" {
    var buf: [64]u8 = undefined;
    try std.testing.expectEqual(@as(i32, 0), ruler(0, 5, &buf));
}

test "display: ruler negative major defaults to 10" {
    var buf: [128]u8 = undefined;
    const len = ruler(5, -1, &buf);
    try std.testing.expectEqual(@as(i32, 15), len); // 5 * 3 bytes
}
