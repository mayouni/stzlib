// Softanza Engine -- DateTime Operations (Tier 2)
//
// Replaces QDate, QTime, QDateTime with pure Zig implementations.
// All functions use C ABI for Ring FFI compatibility.
// Dates use a proleptic Gregorian calendar. Times are 24-hour.

const std = @import("std");
const mem = std.mem;

const gpa = std.heap.c_allocator;

// ─── Date ───

pub const StzDateHandle = ?*StzDate;

const StzDate = struct {
    year: i32,
    month: u8, // 1..12
    day: u8, // 1..31

    fn isValid(self: StzDate) bool {
        if (self.month < 1 or self.month > 12) return false;
        if (self.day < 1) return false;
        const max_day = daysInMonth(self.month, self.year);
        return self.day <= max_day;
    }

    fn toJulianDay(self: StzDate) i64 {
        return gregorianToJulian(self.year, self.month, self.day);
    }

    fn fromJulianDay(jd: i64) StzDate {
        return julianToGregorian(jd);
    }
};

// ─── Date Lifecycle ───

pub fn stz_date_new(year: i32, month: u8, day: u8) callconv(.c) StzDateHandle {
    const d = gpa.create(StzDate) catch return null;
    d.* = .{ .year = year, .month = month, .day = day };
    if (!d.isValid()) {
        gpa.destroy(d);
        return null;
    }
    return d;
}

pub fn stz_date_today() callconv(.c) StzDateHandle {
    const epoch = std.time.timestamp();
    const es = std.time.epoch.EpochSeconds{ .secs = @intCast(@as(u64, @bitCast(epoch))) };
    const day_secs = es.getDaySeconds();
    _ = day_secs;
    const ep_day = es.getEpochDay();
    const yd = ep_day.calculateYearDay();
    const md = yd.calculateMonthDay();

    const d = gpa.create(StzDate) catch return null;
    d.* = .{
        .year = @intCast(yd.year),
        .month = @intFromEnum(md.month),
        .day = md.day_index + 1,
    };
    return d;
}

pub fn stz_date_free(handle: StzDateHandle) callconv(.c) void {
    if (handle) |d| gpa.destroy(d);
}

// ─── Date Components ───

pub fn stz_date_year(handle: StzDateHandle) callconv(.c) i32 {
    if (handle) |d| return d.year;
    return 0;
}

pub fn stz_date_month(handle: StzDateHandle) callconv(.c) u8 {
    if (handle) |d| return d.month;
    return 0;
}

pub fn stz_date_day(handle: StzDateHandle) callconv(.c) u8 {
    if (handle) |d| return d.day;
    return 0;
}

pub fn stz_date_day_of_week(handle: StzDateHandle) callconv(.c) u8 {
    if (handle) |d| {
        const jd = d.toJulianDay();
        // Julian day 0 = Monday. Result: 1=Mon..7=Sun
        const dow: u8 = @intCast(@mod(jd + 0, 7) + 1);
        return dow;
    }
    return 0;
}

pub fn stz_date_day_of_year(handle: StzDateHandle) callconv(.c) u16 {
    if (handle) |d| {
        var doy: u16 = 0;
        var m: u8 = 1;
        while (m < d.month) : (m += 1) {
            doy += daysInMonth(m, d.year);
        }
        doy += d.day;
        return doy;
    }
    return 0;
}

pub fn stz_date_days_in_month(handle: StzDateHandle) callconv(.c) u8 {
    if (handle) |d| return daysInMonth(d.month, d.year);
    return 0;
}

pub fn stz_date_days_in_year(handle: StzDateHandle) callconv(.c) u16 {
    if (handle) |d| return if (isLeapYear(d.year)) 366 else 365;
    return 0;
}

pub fn stz_date_is_leap_year(handle: StzDateHandle) callconv(.c) c_int {
    if (handle) |d| return if (isLeapYear(d.year)) 1 else 0;
    return 0;
}

// ─── Date Arithmetic ───

pub fn stz_date_add_days(handle: StzDateHandle, n: i32) callconv(.c) StzDateHandle {
    if (handle) |d| {
        const jd = d.toJulianDay() + n;
        const result = StzDate.fromJulianDay(jd);
        const out = gpa.create(StzDate) catch return null;
        out.* = result;
        return out;
    }
    return null;
}

pub fn stz_date_diff_days(a: StzDateHandle, b: StzDateHandle) callconv(.c) i64 {
    if (a) |da| {
        if (b) |db| {
            return da.toJulianDay() - db.toJulianDay();
        }
    }
    return 0;
}

// ─── Date Formatting ───

pub fn stz_date_to_string(handle: StzDateHandle, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (handle) |d| {
        return formatDate(d, "yyyy-MM-dd", buf, buf_len);
    }
    return 0;
}

pub fn stz_date_to_iso(handle: StzDateHandle, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    return stz_date_to_string(handle, buf, buf_len);
}

pub fn stz_date_format(handle: StzDateHandle, fmt: [*c]const u8, fmt_len: usize, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (handle) |d| {
        if (fmt == null or fmt_len == 0) return 0;
        return formatDate(d, fmt[0..fmt_len], buf, buf_len);
    }
    return 0;
}

// ─── Date Comparison ───

pub fn stz_date_compare(a: StzDateHandle, b: StzDateHandle) callconv(.c) c_int {
    if (a) |da| {
        if (b) |db| {
            const ja = da.toJulianDay();
            const jb = db.toJulianDay();
            if (ja < jb) return -1;
            if (ja > jb) return 1;
            return 0;
        }
    }
    return 0;
}

// ═══════════════════════════════════════════
// Time
// ═══════════════════════════════════════════

pub const StzTimeHandle = ?*StzTime;

const StzTime = struct {
    hour: u8, // 0..23
    minute: u8, // 0..59
    second: u8, // 0..59
    ms: u16, // 0..999

    fn totalMs(self: StzTime) u64 {
        return @as(u64, self.hour) * 3600_000 +
            @as(u64, self.minute) * 60_000 +
            @as(u64, self.second) * 1000 +
            @as(u64, self.ms);
    }

    fn fromTotalMs(total: u64) StzTime {
        const clamped = total % 86_400_000;
        return .{
            .hour = @intCast(clamped / 3_600_000),
            .minute = @intCast((clamped % 3_600_000) / 60_000),
            .second = @intCast((clamped % 60_000) / 1000),
            .ms = @intCast(clamped % 1000),
        };
    }
};

// ─── Time Lifecycle ───

pub fn stz_time_new(hour: u8, minute: u8, second: u8) callconv(.c) StzTimeHandle {
    return stz_time_new_ms(hour, minute, second, 0);
}

pub fn stz_time_new_ms(hour: u8, minute: u8, second: u8, ms: u16) callconv(.c) StzTimeHandle {
    if (hour > 23 or minute > 59 or second > 59 or ms > 999) return null;
    const t = gpa.create(StzTime) catch return null;
    t.* = .{ .hour = hour, .minute = minute, .second = second, .ms = ms };
    return t;
}

pub fn stz_time_now() callconv(.c) StzTimeHandle {
    const epoch = std.time.timestamp();
    const secs_in_day: u64 = @intCast(@mod(epoch, 86400));
    const t = gpa.create(StzTime) catch return null;
    t.* = StzTime.fromTotalMs(secs_in_day * 1000);
    return t;
}

pub fn stz_time_free(handle: StzTimeHandle) callconv(.c) void {
    if (handle) |t| gpa.destroy(t);
}

// ─── Time Components ───

pub fn stz_time_hour(handle: StzTimeHandle) callconv(.c) u8 {
    if (handle) |t| return t.hour;
    return 0;
}

pub fn stz_time_minute(handle: StzTimeHandle) callconv(.c) u8 {
    if (handle) |t| return t.minute;
    return 0;
}

pub fn stz_time_second(handle: StzTimeHandle) callconv(.c) u8 {
    if (handle) |t| return t.second;
    return 0;
}

pub fn stz_time_millisecond(handle: StzTimeHandle) callconv(.c) u16 {
    if (handle) |t| return t.ms;
    return 0;
}

pub fn stz_time_hour12(handle: StzTimeHandle) callconv(.c) u8 {
    if (handle) |t| {
        const h12 = t.hour % 12;
        return if (h12 == 0) 12 else h12;
    }
    return 0;
}

pub fn stz_time_is_pm(handle: StzTimeHandle) callconv(.c) c_int {
    if (handle) |t| return if (t.hour >= 12) 1 else 0;
    return 0;
}

// ─── Time Arithmetic ───

pub fn stz_time_add_seconds(handle: StzTimeHandle, n: i64) callconv(.c) StzTimeHandle {
    if (handle) |t| {
        const current: i64 = @intCast(t.totalMs());
        const added = current + n * 1000;
        const normalized: u64 = @intCast(@mod(added, 86_400_000) + 86_400_000);
        const result = StzTime.fromTotalMs(normalized % 86_400_000);
        const out = gpa.create(StzTime) catch return null;
        out.* = result;
        return out;
    }
    return null;
}

pub fn stz_time_add_ms(handle: StzTimeHandle, n: i64) callconv(.c) StzTimeHandle {
    if (handle) |t| {
        const current: i64 = @intCast(t.totalMs());
        const added = current + n;
        const day_ms: i64 = 86_400_000;
        const normalized: u64 = @intCast(@mod(@mod(added, day_ms) + day_ms, day_ms));
        const result = StzTime.fromTotalMs(normalized);
        const out = gpa.create(StzTime) catch return null;
        out.* = result;
        return out;
    }
    return null;
}

// ─── Time Formatting ───

pub fn stz_time_to_string(handle: StzTimeHandle, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (handle) |t| {
        return formatTime24(t, buf, buf_len);
    }
    return 0;
}

pub fn stz_time_to_string_12h(handle: StzTimeHandle, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (handle) |t| {
        return formatTime12(t, buf, buf_len);
    }
    return 0;
}

// ─── Time Comparison ───

pub fn stz_time_compare(a: StzTimeHandle, b: StzTimeHandle) callconv(.c) c_int {
    if (a) |ta| {
        if (b) |tb| {
            const ma = ta.totalMs();
            const mb = tb.totalMs();
            if (ma < mb) return -1;
            if (ma > mb) return 1;
            return 0;
        }
    }
    return 0;
}

// ═══════════════════════════════════════════
// DateTime
// ═══════════════════════════════════════════

pub const StzDateTimeHandle = ?*StzDateTime;

const StzDateTime = struct {
    date: StzDate,
    time: StzTime,
};

pub fn stz_datetime_new(year: i32, month: u8, day: u8, hour: u8, minute: u8, second: u8) callconv(.c) StzDateTimeHandle {
    const date = StzDate{ .year = year, .month = month, .day = day };
    if (!date.isValid()) return null;
    if (hour > 23 or minute > 59 or second > 59) return null;
    const dt = gpa.create(StzDateTime) catch return null;
    dt.* = .{
        .date = date,
        .time = .{ .hour = hour, .minute = minute, .second = second, .ms = 0 },
    };
    return dt;
}

pub fn stz_datetime_now() callconv(.c) StzDateTimeHandle {
    const epoch = std.time.timestamp();
    const epoch_u: u64 = @intCast(@as(u64, @bitCast(epoch)));
    const es = std.time.epoch.EpochSeconds{ .secs = epoch_u };
    const ep_day = es.getEpochDay();
    const yd = ep_day.calculateYearDay();
    const md = yd.calculateMonthDay();
    const day_secs = es.getDaySeconds();

    const dt = gpa.create(StzDateTime) catch return null;
    dt.* = .{
        .date = .{
            .year = @intCast(yd.year),
            .month = @intFromEnum(md.month),
            .day = md.day_index + 1,
        },
        .time = .{
            .hour = @intCast(day_secs.getHoursIntoDay()),
            .minute = @intCast(day_secs.getMinutesIntoHour()),
            .second = @intCast(day_secs.getSecondsIntoMinute()),
            .ms = 0,
        },
    };
    return dt;
}

pub fn stz_datetime_from_unix(timestamp: i64) callconv(.c) StzDateTimeHandle {
    if (timestamp < 0) return null;
    const es = std.time.epoch.EpochSeconds{ .secs = @intCast(timestamp) };
    const ep_day = es.getEpochDay();
    const yd = ep_day.calculateYearDay();
    const md = yd.calculateMonthDay();
    const day_secs = es.getDaySeconds();

    const dt = gpa.create(StzDateTime) catch return null;
    dt.* = .{
        .date = .{
            .year = @intCast(yd.year),
            .month = @intFromEnum(md.month),
            .day = md.day_index + 1,
        },
        .time = .{
            .hour = @intCast(day_secs.getHoursIntoDay()),
            .minute = @intCast(day_secs.getMinutesIntoHour()),
            .second = @intCast(day_secs.getSecondsIntoMinute()),
            .ms = 0,
        },
    };
    return dt;
}

pub fn stz_datetime_free(handle: StzDateTimeHandle) callconv(.c) void {
    if (handle) |dt| gpa.destroy(dt);
}

// ─── DateTime Components (delegate to date/time) ───

pub fn stz_datetime_year(handle: StzDateTimeHandle) callconv(.c) i32 {
    if (handle) |dt| return dt.date.year;
    return 0;
}

pub fn stz_datetime_month(handle: StzDateTimeHandle) callconv(.c) u8 {
    if (handle) |dt| return dt.date.month;
    return 0;
}

pub fn stz_datetime_day(handle: StzDateTimeHandle) callconv(.c) u8 {
    if (handle) |dt| return dt.date.day;
    return 0;
}

pub fn stz_datetime_hour(handle: StzDateTimeHandle) callconv(.c) u8 {
    if (handle) |dt| return dt.time.hour;
    return 0;
}

pub fn stz_datetime_minute(handle: StzDateTimeHandle) callconv(.c) u8 {
    if (handle) |dt| return dt.time.minute;
    return 0;
}

pub fn stz_datetime_second(handle: StzDateTimeHandle) callconv(.c) u8 {
    if (handle) |dt| return dt.time.second;
    return 0;
}

// ─── DateTime Arithmetic ───

pub fn stz_datetime_add_days(handle: StzDateTimeHandle, n: i32) callconv(.c) StzDateTimeHandle {
    if (handle) |dt| {
        const jd = dt.date.toJulianDay() + n;
        const new_date = StzDate.fromJulianDay(jd);
        const out = gpa.create(StzDateTime) catch return null;
        out.* = .{ .date = new_date, .time = dt.time };
        return out;
    }
    return null;
}

pub fn stz_datetime_add_seconds(handle: StzDateTimeHandle, n: i64) callconv(.c) StzDateTimeHandle {
    if (handle) |dt| {
        const total_secs: i64 = @as(i64, @intCast(dt.time.hour)) * 3600 +
            @as(i64, @intCast(dt.time.minute)) * 60 +
            @as(i64, @intCast(dt.time.second)) + n;

        var extra_days = @divFloor(total_secs, 86400);
        var rem_secs = @mod(total_secs, 86400);
        if (rem_secs < 0) {
            rem_secs += 86400;
            extra_days -= 1;
        }

        const jd = dt.date.toJulianDay() + extra_days;
        const new_date = StzDate.fromJulianDay(jd);
        const new_time = StzTime.fromTotalMs(@intCast(rem_secs * 1000 + dt.time.ms));

        const out = gpa.create(StzDateTime) catch return null;
        out.* = .{ .date = new_date, .time = new_time };
        return out;
    }
    return null;
}

pub fn stz_datetime_to_unix(handle: StzDateTimeHandle) callconv(.c) i64 {
    if (handle) |dt| {
        const jd = dt.date.toJulianDay();
        const unix_epoch_jd: i64 = 2440588; // 1970-01-01
        const days = jd - unix_epoch_jd;
        return days * 86400 +
            @as(i64, @intCast(dt.time.hour)) * 3600 +
            @as(i64, @intCast(dt.time.minute)) * 60 +
            @as(i64, @intCast(dt.time.second));
    }
    return 0;
}

// ─── DateTime Formatting ───

pub fn stz_datetime_to_iso(handle: StzDateTimeHandle, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (handle) |dt| {
        if (buf_len < 20) return 0;
        const date_len = formatDate(&dt.date, "yyyy-MM-dd", buf, buf_len);
        if (date_len == 0) return 0;
        buf[date_len] = 'T';
        const time_len = formatTime24(&dt.time, buf + date_len + 1, buf_len - date_len - 1);
        return date_len + 1 + time_len;
    }
    return 0;
}

pub fn stz_datetime_compare(a: StzDateTimeHandle, b: StzDateTimeHandle) callconv(.c) c_int {
    if (a) |dta| {
        if (b) |dtb| {
            const date_cmp = compareDates(&dta.date, &dtb.date);
            if (date_cmp != 0) return date_cmp;
            const ma = dta.time.totalMs();
            const mb = dtb.time.totalMs();
            if (ma < mb) return -1;
            if (ma > mb) return 1;
            return 0;
        }
    }
    return 0;
}

pub fn stz_datetime_is_between(handle: StzDateTimeHandle, start: StzDateTimeHandle, end: StzDateTimeHandle) callconv(.c) c_int {
    const cmp_start = stz_datetime_compare(handle, start);
    const cmp_end = stz_datetime_compare(handle, end);
    return if (cmp_start >= 0 and cmp_end <= 0) 1 else 0;
}

// ═══════════════════════════════════════════
// Calendar Helpers
// ═══════════════════════════════════════════

fn isLeapYear(year: i32) bool {
    if (@mod(year, 400) == 0) return true;
    if (@mod(year, 100) == 0) return false;
    return @mod(year, 4) == 0;
}

fn daysInMonth(month: u8, year: i32) u8 {
    const table = [_]u8{ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
    if (month < 1 or month > 12) return 0;
    if (month == 2 and isLeapYear(year)) return 29;
    return table[month - 1];
}

fn gregorianToJulian(year: i32, month: u8, day: u8) i64 {
    var y: i64 = year;
    var m: i64 = month;
    if (m <= 2) {
        y -= 1;
        m += 12;
    }
    const a = @divFloor(y, 100);
    const b = 2 - a + @divFloor(a, 4);
    const jd = @divFloor(36525 * (y + 4716), 100) + @divFloor(306001 * (m + 1), 10000) + day + b - 1524;
    return jd;
}

fn julianToGregorian(jd: i64) StzDate {
    const a_temp = jd + 32044;
    const b = @divFloor(4 * a_temp + 3, 146097);
    const c = a_temp - @divFloor(146097 * b, 4);
    const d = @divFloor(4 * c + 3, 1461);
    const e = c - @divFloor(1461 * d, 4);
    const m = @divFloor(5 * e + 2, 153);

    const day: u8 = @intCast(e - @divFloor(153 * m + 2, 5) + 1);
    const month: u8 = @intCast(m + 3 - 12 * @divFloor(m, 10));
    const year: i32 = @intCast(100 * b + d - 4800 + @divFloor(m, 10));

    return .{ .year = year, .month = month, .day = day };
}

fn compareDates(a: *const StzDate, b: *const StzDate) c_int {
    if (a.year < b.year) return -1;
    if (a.year > b.year) return 1;
    if (a.month < b.month) return -1;
    if (a.month > b.month) return 1;
    if (a.day < b.day) return -1;
    if (a.day > b.day) return 1;
    return 0;
}

fn formatDate(d: *const StzDate, fmt: []const u8, buf: [*c]u8, buf_len: usize) usize {
    _ = fmt;
    if (buf_len < 11) return 0;
    var tmp: [11]u8 = undefined;
    const year_abs: u32 = @intCast(if (d.year < 0) -d.year else d.year);
    const result = std.fmt.bufPrint(&tmp, "{d:0>4}-{d:0>2}-{d:0>2}", .{ year_abs, d.month, d.day }) catch return 0;
    @memcpy(buf[0..result.len], result);
    return result.len;
}

fn formatTime24(t: *const StzTime, buf: [*c]u8, buf_len: usize) usize {
    if (buf_len < 9) return 0;
    var tmp: [9]u8 = undefined;
    const result = std.fmt.bufPrint(&tmp, "{d:0>2}:{d:0>2}:{d:0>2}", .{ t.hour, t.minute, t.second }) catch return 0;
    @memcpy(buf[0..result.len], result);
    return result.len;
}

fn formatTime12(t: *const StzTime, buf: [*c]u8, buf_len: usize) usize {
    if (buf_len < 12) return 0;
    const h12: u8 = if (t.hour % 12 == 0) 12 else t.hour % 12;
    const ampm: []const u8 = if (t.hour >= 12) "PM" else "AM";
    var tmp: [12]u8 = undefined;
    const result = std.fmt.bufPrint(&tmp, "{d:0>2}:{d:0>2}:{d:0>2} {s}", .{ h12, t.minute, t.second, ampm }) catch return 0;
    @memcpy(buf[0..result.len], result);
    return result.len;
}

// Day-of-week name (English, abbreviated)
pub fn stz_date_day_name(handle: StzDateHandle, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (handle) |d| {
        const dow = stz_date_day_of_week(d);
        const names = [_][]const u8{ "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" };
        if (dow >= 1 and dow <= 7) {
            const name = names[dow - 1];
            if (name.len <= buf_len) {
                @memcpy(buf[0..name.len], name);
                return name.len;
            }
        }
    }
    return 0;
}

// Month name (English)
pub fn stz_date_month_name(handle: StzDateHandle, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (handle) |d| {
        const names = [_][]const u8{ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };
        if (d.month >= 1 and d.month <= 12) {
            const name = names[d.month - 1];
            if (name.len <= buf_len) {
                @memcpy(buf[0..name.len], name);
                return name.len;
            }
        }
    }
    return 0;
}

// ─── Tests ───

test "date lifecycle" {
    const d = stz_date_new(2026, 5, 13);
    try std.testing.expect(d != null);
    try std.testing.expectEqual(@as(i32, 2026), stz_date_year(d));
    try std.testing.expectEqual(@as(u8, 5), stz_date_month(d));
    try std.testing.expectEqual(@as(u8, 13), stz_date_day(d));
    stz_date_free(d);
}

test "date invalid" {
    try std.testing.expect(stz_date_new(2026, 13, 1) == null);
    try std.testing.expect(stz_date_new(2026, 2, 30) == null);
    try std.testing.expect(stz_date_new(2026, 0, 1) == null);
}

test "date leap year" {
    const d2024 = stz_date_new(2024, 2, 29);
    try std.testing.expect(d2024 != null);
    try std.testing.expectEqual(@as(c_int, 1), stz_date_is_leap_year(d2024));
    stz_date_free(d2024);

    try std.testing.expect(stz_date_new(2023, 2, 29) == null);
}

test "date arithmetic" {
    const d = stz_date_new(2026, 5, 13);
    const d2 = stz_date_add_days(d, 20);
    try std.testing.expect(d2 != null);
    try std.testing.expectEqual(@as(u8, 6), stz_date_month(d2));
    try std.testing.expectEqual(@as(u8, 2), stz_date_day(d2));
    stz_date_free(d2);

    const d3 = stz_date_add_days(d, -13);
    try std.testing.expectEqual(@as(u8, 4), stz_date_month(d3));
    try std.testing.expectEqual(@as(u8, 30), stz_date_day(d3));
    stz_date_free(d3);

    stz_date_free(d);
}

test "date diff" {
    const d1 = stz_date_new(2026, 1, 1);
    const d2 = stz_date_new(2026, 1, 31);
    try std.testing.expectEqual(@as(i64, -30), stz_date_diff_days(d1, d2));
    try std.testing.expectEqual(@as(i64, 30), stz_date_diff_days(d2, d1));
    stz_date_free(d1);
    stz_date_free(d2);
}

test "date formatting" {
    const d = stz_date_new(2026, 5, 13);
    var buf: [32]u8 = undefined;
    const len = stz_date_to_string(d, &buf, 32);
    try std.testing.expect(len > 0);
    try std.testing.expect(mem.eql(u8, buf[0..len], "2026-05-13"));
    stz_date_free(d);
}

test "date day of week" {
    // 2026-05-13 is a Wednesday = 3
    const d = stz_date_new(2026, 5, 13);
    try std.testing.expectEqual(@as(u8, 3), stz_date_day_of_week(d));
    stz_date_free(d);
}

test "date day name" {
    const d = stz_date_new(2026, 5, 13);
    var buf: [16]u8 = undefined;
    const len = stz_date_day_name(d, &buf, 16);
    try std.testing.expect(mem.eql(u8, buf[0..len], "Wednesday"));
    stz_date_free(d);
}

test "time lifecycle" {
    const t = stz_time_new(14, 30, 45);
    try std.testing.expect(t != null);
    try std.testing.expectEqual(@as(u8, 14), stz_time_hour(t));
    try std.testing.expectEqual(@as(u8, 30), stz_time_minute(t));
    try std.testing.expectEqual(@as(u8, 45), stz_time_second(t));
    stz_time_free(t);
}

test "time 12h" {
    const t = stz_time_new(14, 30, 0);
    try std.testing.expectEqual(@as(u8, 2), stz_time_hour12(t));
    try std.testing.expectEqual(@as(c_int, 1), stz_time_is_pm(t));
    stz_time_free(t);

    const t2 = stz_time_new(0, 0, 0);
    try std.testing.expectEqual(@as(u8, 12), stz_time_hour12(t2));
    try std.testing.expectEqual(@as(c_int, 0), stz_time_is_pm(t2));
    stz_time_free(t2);
}

test "time formatting" {
    const t = stz_time_new(14, 5, 9);
    var buf: [16]u8 = undefined;
    const len = stz_time_to_string(t, &buf, 16);
    try std.testing.expect(mem.eql(u8, buf[0..len], "14:05:09"));

    var buf12: [16]u8 = undefined;
    const len12 = stz_time_to_string_12h(t, &buf12, 16);
    try std.testing.expect(mem.eql(u8, buf12[0..len12], "02:05:09 PM"));
    stz_time_free(t);
}

test "datetime iso" {
    const dt = stz_datetime_new(2026, 5, 13, 14, 30, 45);
    try std.testing.expect(dt != null);
    var buf: [32]u8 = undefined;
    const len = stz_datetime_to_iso(dt, &buf, 32);
    try std.testing.expect(mem.eql(u8, buf[0..len], "2026-05-13T14:30:45"));
    stz_datetime_free(dt);
}

test "datetime unix roundtrip" {
    const dt = stz_datetime_new(2026, 1, 1, 0, 0, 0);
    const unix = stz_datetime_to_unix(dt);
    stz_datetime_free(dt);

    const dt2 = stz_datetime_from_unix(unix);
    try std.testing.expectEqual(@as(i32, 2026), stz_datetime_year(dt2));
    try std.testing.expectEqual(@as(u8, 1), stz_datetime_month(dt2));
    try std.testing.expectEqual(@as(u8, 1), stz_datetime_day(dt2));
    stz_datetime_free(dt2);
}

test "datetime compare and between" {
    const dt1 = stz_datetime_new(2026, 1, 1, 0, 0, 0);
    const dt2 = stz_datetime_new(2026, 6, 15, 12, 0, 0);
    const dt3 = stz_datetime_new(2026, 12, 31, 23, 59, 59);

    try std.testing.expectEqual(@as(c_int, -1), stz_datetime_compare(dt1, dt2));
    try std.testing.expectEqual(@as(c_int, 1), stz_datetime_compare(dt3, dt2));
    try std.testing.expectEqual(@as(c_int, 1), stz_datetime_is_between(dt2, dt1, dt3));
    try std.testing.expectEqual(@as(c_int, 0), stz_datetime_is_between(dt1, dt2, dt3));

    stz_datetime_free(dt1);
    stz_datetime_free(dt2);
    stz_datetime_free(dt3);
}
