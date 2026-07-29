// The engine senses -- performance system P1 (SOFTANZA_PERF_SYSTEM.md).
//
// Until this module, the engine could tell TIME (time.zig, watch.zig,
// process.zig) but could not observe MEMORY or CPU: no process RSS, no
// system memory, no CPU time. The perf plan's issues 2-5 (degradation,
// slow leaks, crash-sized leaks, CPU spikes) were unobservable. This
// module adds the missing senses, plus the metric SERIES -- a
// fixed-capacity (time, value) ring buffer that lives engine-side so
// recording is O(1), bounded, and copy-proof (Ring copies values on
// assignment; a handle survives copying).
//
// Senses (all f64; bytes for memory, nanoseconds for CPU; -1 = the
// platform refused / not implemented here):
//   stz_perf_mem_rss()        -> current working set / resident set
//   stz_perf_mem_peak()       -> peak working set / max resident set
//   stz_perf_sys_mem_total()  -> physical memory, total
//   stz_perf_sys_mem_free()   -> physical memory, available
//   stz_perf_cpu_ns()         -> process CPU time (user + kernel)
//
// CPU time is the honest spike detector: it advances only when this
// process COMPUTES. A sleeping process accumulates wall time but no
// CPU time; utilization over a window is
//   delta(cpu_ns) / (delta(mono_ns) * cores).
//
// Series (mutex-protected; oldest samples overwritten past capacity):
//   perf_series_create(cap)          -> handle (null on failure)
//   perf_series_record(s, t_ms, v)   -> O(1)
//   perf_series_count(s)             -> samples EVER recorded
//   perf_series_size(s)              -> samples RETAINED (<= cap)
//   perf_series_time_at/value_at(s, i)  -> 1-based, oldest first
//   perf_series_last/min/max/mean(s)    -> over the retained window
//   perf_series_slope_per_ms(s)      -> least-squares dv/dt (leak trend)
//   perf_series_percentile(s, p)     -> exact nearest-rank, retained window
//   perf_series_reset(s) / perf_series_destroy(s)

const std = @import("std");
const builtin = @import("builtin");

const gpa = std.heap.c_allocator;

// ── Windows API (senses) ─────────────────────────────────────

const PROCESS_MEMORY_COUNTERS = extern struct {
    cb: u32,
    PageFaultCount: u32,
    PeakWorkingSetSize: usize,
    WorkingSetSize: usize,
    QuotaPeakPagedPoolUsage: usize,
    QuotaPagedPoolUsage: usize,
    QuotaPeakNonPagedPoolUsage: usize,
    QuotaNonPagedPoolUsage: usize,
    PagefileUsage: usize,
    PeakPagefileUsage: usize,
};

const MEMORYSTATUSEX = extern struct {
    dwLength: u32,
    dwMemoryLoad: u32,
    ullTotalPhys: u64,
    ullAvailPhys: u64,
    ullTotalPageFile: u64,
    ullAvailPageFile: u64,
    ullTotalVirtual: u64,
    ullAvailVirtual: u64,
    ullAvailExtendedVirtual: u64,
};

const FILETIME = extern struct { lo: u32, hi: u32 };

// K32* exports live in kernel32 since Windows 7 -- no psapi link needed.
extern "kernel32" fn GetCurrentProcess() callconv(.winapi) *anyopaque;
extern "kernel32" fn K32GetProcessMemoryInfo(h: *anyopaque, c: *PROCESS_MEMORY_COUNTERS, cb: u32) callconv(.winapi) i32;
extern "kernel32" fn GlobalMemoryStatusEx(b: *MEMORYSTATUSEX) callconv(.winapi) i32;
extern "kernel32" fn GetProcessTimes(h: *anyopaque, creation: *FILETIME, exit: *FILETIME, kernel: *FILETIME, user: *FILETIME) callconv(.winapi) i32;

fn winMemCounters() ?PROCESS_MEMORY_COUNTERS {
    var c: PROCESS_MEMORY_COUNTERS = undefined;
    c.cb = @sizeOf(PROCESS_MEMORY_COUNTERS);
    if (K32GetProcessMemoryInfo(GetCurrentProcess(), &c, c.cb) == 0) return null;
    return c;
}

// ── Linux helpers (best-effort; the dev box is Windows) ──────

// /proc/self/statm field 2 = resident pages. Page size is 4096 on all
// mainstream Linux targets we build for (x86_64, aarch64).
const LINUX_PAGE_SIZE: f64 = 4096;

fn linuxStatmRssBytes() f64 {
    const f = std.fs.openFileAbsolute("/proc/self/statm", .{}) catch return -1;
    defer f.close();
    var buf: [128]u8 = undefined;
    const n = f.read(&buf) catch return -1;
    var it = std.mem.tokenizeScalar(u8, buf[0..n], ' ');
    _ = it.next() orelse return -1; // total program size
    const rss_pages = it.next() orelse return -1;
    const pages = std.fmt.parseInt(u64, rss_pages, 10) catch return -1;
    return @as(f64, @floatFromInt(pages)) * LINUX_PAGE_SIZE;
}

fn linuxMeminfoKb(key: []const u8) f64 {
    const f = std.fs.openFileAbsolute("/proc/meminfo", .{}) catch return -1;
    defer f.close();
    var buf: [4096]u8 = undefined;
    const n = f.read(&buf) catch return -1;
    var lines = std.mem.tokenizeScalar(u8, buf[0..n], '\n');
    while (lines.next()) |line| {
        if (std.mem.startsWith(u8, line, key)) {
            var it = std.mem.tokenizeScalar(u8, line[key.len..], ' ');
            _ = it.next(); // ":"-attached or standalone colon token
            var tok = it.next() orelse return -1;
            if (tok.len > 0 and tok[0] == ':') tok = tok[1..];
            if (tok.len == 0) tok = it.next() orelse return -1;
            const kb = std.fmt.parseInt(u64, tok, 10) catch return -1;
            return @as(f64, @floatFromInt(kb)) * 1024;
        }
    }
    return -1;
}

// ── The senses ───────────────────────────────────────────────

pub fn stz_perf_mem_rss() callconv(.c) f64 {
    if (builtin.os.tag == .windows) {
        const c = winMemCounters() orelse return -1;
        return @floatFromInt(c.WorkingSetSize);
    } else if (builtin.os.tag == .linux) {
        return linuxStatmRssBytes();
    }
    return -1;
}

pub fn stz_perf_mem_peak() callconv(.c) f64 {
    if (builtin.os.tag == .windows) {
        const c = winMemCounters() orelse return -1;
        return @floatFromInt(c.PeakWorkingSetSize);
    } else if (builtin.os.tag == .linux) {
        var ru: std.os.linux.rusage = undefined;
        if (std.os.linux.getrusage(0, &ru) != 0) return -1;
        return @as(f64, @floatFromInt(ru.maxrss)) * 1024; // maxrss is KB on Linux
    }
    return -1;
}

pub fn stz_perf_sys_mem_total() callconv(.c) f64 {
    if (builtin.os.tag == .windows) {
        var m: MEMORYSTATUSEX = undefined;
        m.dwLength = @sizeOf(MEMORYSTATUSEX);
        if (GlobalMemoryStatusEx(&m) == 0) return -1;
        return @floatFromInt(m.ullTotalPhys);
    } else if (builtin.os.tag == .linux) {
        return linuxMeminfoKb("MemTotal");
    }
    return -1;
}

pub fn stz_perf_sys_mem_free() callconv(.c) f64 {
    if (builtin.os.tag == .windows) {
        var m: MEMORYSTATUSEX = undefined;
        m.dwLength = @sizeOf(MEMORYSTATUSEX);
        if (GlobalMemoryStatusEx(&m) == 0) return -1;
        return @floatFromInt(m.ullAvailPhys);
    } else if (builtin.os.tag == .linux) {
        return linuxMeminfoKb("MemAvailable");
    }
    return -1;
}

fn filetimeToNs(ft: FILETIME) f64 {
    // FILETIME counts 100-ns intervals.
    const ticks: u64 = (@as(u64, ft.hi) << 32) | @as(u64, ft.lo);
    return @as(f64, @floatFromInt(ticks)) * 100.0;
}

pub fn stz_perf_cpu_ns() callconv(.c) f64 {
    if (builtin.os.tag == .windows) {
        var c: FILETIME = undefined;
        var e: FILETIME = undefined;
        var k: FILETIME = undefined;
        var u: FILETIME = undefined;
        if (GetProcessTimes(GetCurrentProcess(), &c, &e, &k, &u) == 0) return -1;
        return filetimeToNs(k) + filetimeToNs(u);
    } else if (builtin.os.tag == .linux) {
        var ts: std.os.linux.timespec = undefined;
        if (std.os.linux.clock_gettime(.PROCESS_CPUTIME_ID, &ts) != 0) return -1;
        return @as(f64, @floatFromInt(ts.sec)) * 1_000_000_000.0 + @as(f64, @floatFromInt(ts.nsec));
    }
    return -1;
}

// ── The metric series ────────────────────────────────────────

pub const Series = struct {
    times: []f64, // ms timestamps (caller's clock -- monotonic by convention)
    values: []f64,
    cap: usize,
    count: u64, // ever recorded
    head: usize, // next write slot
    mutex: std.Thread.Mutex,

    fn size(self: *const Series) usize {
        if (self.count < self.cap) return @intCast(self.count);
        return self.cap;
    }

    // Physical index of logical position i (0-based, oldest first).
    fn phys(self: *const Series, i: usize) usize {
        if (self.count < self.cap) return i;
        return (self.head + i) % self.cap;
    }
};

pub fn perf_series_create(cap_f: f64) callconv(.c) ?*Series {
    if (cap_f < 1) return null;
    const cap: usize = @intFromFloat(cap_f);
    const s = gpa.create(Series) catch return null;
    const times = gpa.alloc(f64, cap) catch {
        gpa.destroy(s);
        return null;
    };
    const values = gpa.alloc(f64, cap) catch {
        gpa.free(times);
        gpa.destroy(s);
        return null;
    };
    s.* = .{ .times = times, .values = values, .cap = cap, .count = 0, .head = 0, .mutex = .{} };
    return s;
}

pub fn perf_series_record(s_opt: ?*Series, t_ms: f64, v: f64) callconv(.c) void {
    const s = s_opt orelse return;
    s.mutex.lock();
    defer s.mutex.unlock();
    s.times[s.head] = t_ms;
    s.values[s.head] = v;
    s.head = (s.head + 1) % s.cap;
    s.count += 1;
}

pub fn perf_series_count(s_opt: ?*Series) callconv(.c) f64 {
    const s = s_opt orelse return 0;
    s.mutex.lock();
    defer s.mutex.unlock();
    return @floatFromInt(s.count);
}

pub fn perf_series_size(s_opt: ?*Series) callconv(.c) f64 {
    const s = s_opt orelse return 0;
    s.mutex.lock();
    defer s.mutex.unlock();
    return @floatFromInt(s.size());
}

pub fn perf_series_time_at(s_opt: ?*Series, i_f: f64) callconv(.c) f64 {
    const s = s_opt orelse return -1;
    s.mutex.lock();
    defer s.mutex.unlock();
    const n = s.size();
    if (i_f < 1 or i_f > @as(f64, @floatFromInt(n))) return -1;
    const i: usize = @intFromFloat(i_f);
    return s.times[s.phys(i - 1)];
}

pub fn perf_series_value_at(s_opt: ?*Series, i_f: f64) callconv(.c) f64 {
    const s = s_opt orelse return -1;
    s.mutex.lock();
    defer s.mutex.unlock();
    const n = s.size();
    if (i_f < 1 or i_f > @as(f64, @floatFromInt(n))) return -1;
    const i: usize = @intFromFloat(i_f);
    return s.values[s.phys(i - 1)];
}

pub fn perf_series_last(s_opt: ?*Series) callconv(.c) f64 {
    const s = s_opt orelse return 0;
    s.mutex.lock();
    defer s.mutex.unlock();
    const n = s.size();
    if (n == 0) return 0;
    return s.values[s.phys(n - 1)];
}

pub fn perf_series_min(s_opt: ?*Series) callconv(.c) f64 {
    const s = s_opt orelse return 0;
    s.mutex.lock();
    defer s.mutex.unlock();
    const n = s.size();
    if (n == 0) return 0;
    var m = s.values[s.phys(0)];
    var i: usize = 1;
    while (i < n) : (i += 1) {
        const v = s.values[s.phys(i)];
        if (v < m) m = v;
    }
    return m;
}

pub fn perf_series_max(s_opt: ?*Series) callconv(.c) f64 {
    const s = s_opt orelse return 0;
    s.mutex.lock();
    defer s.mutex.unlock();
    const n = s.size();
    if (n == 0) return 0;
    var m = s.values[s.phys(0)];
    var i: usize = 1;
    while (i < n) : (i += 1) {
        const v = s.values[s.phys(i)];
        if (v > m) m = v;
    }
    return m;
}

pub fn perf_series_mean(s_opt: ?*Series) callconv(.c) f64 {
    const s = s_opt orelse return 0;
    s.mutex.lock();
    defer s.mutex.unlock();
    const n = s.size();
    if (n == 0) return 0;
    // Kahan-compensated, same discipline as stats.zig.
    var sum: f64 = 0;
    var comp: f64 = 0;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const y = s.values[s.phys(i)] - comp;
        const t = sum + y;
        comp = (t - sum) - y;
        sum = t;
    }
    return sum / @as(f64, @floatFromInt(n));
}

// Least-squares slope of value over time, per MILLISECOND of the
// series' own clock. This is the leak/trend detector: a stable gauge
// slopes ~0, a leaking one slopes positive. 0 when underdetermined
// (fewer than 2 points, or all timestamps equal).
pub fn perf_series_slope_per_ms(s_opt: ?*Series) callconv(.c) f64 {
    const s = s_opt orelse return 0;
    s.mutex.lock();
    defer s.mutex.unlock();
    const n = s.size();
    if (n < 2) return 0;
    const nf: f64 = @floatFromInt(n);
    var st: f64 = 0;
    var sv: f64 = 0;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        st += s.times[s.phys(i)];
        sv += s.values[s.phys(i)];
    }
    const mt = st / nf;
    const mv = sv / nf;
    var num: f64 = 0;
    var den: f64 = 0;
    i = 0;
    while (i < n) : (i += 1) {
        const dt = s.times[s.phys(i)] - mt;
        num += dt * (s.values[s.phys(i)] - mv);
        den += dt * dt;
    }
    if (den == 0) return 0;
    return num / den;
}

// Exact nearest-rank percentile over the retained window (copy + sort;
// queries are rare, recording is the hot path).
pub fn perf_series_percentile(s_opt: ?*Series, p: f64) callconv(.c) f64 {
    const s = s_opt orelse return 0;
    s.mutex.lock();
    defer s.mutex.unlock();
    const n = s.size();
    if (n == 0) return 0;
    const tmp = gpa.alloc(f64, n) catch return 0;
    defer gpa.free(tmp);
    var i: usize = 0;
    while (i < n) : (i += 1) tmp[i] = s.values[s.phys(i)];
    std.mem.sort(f64, tmp, {}, std.sort.asc(f64));
    var pp = p;
    if (pp < 0) pp = 0;
    if (pp > 100) pp = 100;
    const rank_f = @as(f64, @floatFromInt(n)) * pp / 100.0;
    var rank: usize = @intFromFloat(@ceil(rank_f));
    if (rank < 1) rank = 1;
    if (rank > n) rank = n;
    return tmp[rank - 1];
}

pub fn perf_series_reset(s_opt: ?*Series) callconv(.c) void {
    const s = s_opt orelse return;
    s.mutex.lock();
    defer s.mutex.unlock();
    s.count = 0;
    s.head = 0;
}

pub fn perf_series_destroy(s_opt: ?*Series) callconv(.c) void {
    const s = s_opt orelse return;
    gpa.free(s.times);
    gpa.free(s.values);
    gpa.destroy(s);
}

// ── The trace ring (perf P7) ─────────────────────────────────
//
// A bounded ring of request traces -- [traceId, path, status, durMs,
// wallMs] -- living engine-side for the same reason the series does:
// O(1) record, fixed memory, and one truth shared by every Ring copy
// (the server face records, the sentinel face reads -- the black box
// can carry the trace ids of the requests that tripped an alert).
// Strings are bounded fixed slots (ids are 32-hex W3C, paths clipped),
// oldest overwritten past capacity.

const TRACE_ID_MAX = 64;
const TRACE_PATH_MAX = 96;

pub const TraceRing = struct {
    ids: []u8, // cap * TRACE_ID_MAX, zero-padded
    id_lens: []u8,
    paths: []u8, // cap * TRACE_PATH_MAX
    path_lens: []u8,
    status: []f64,
    dur: []f64,
    wall: []f64,
    cap: usize,
    count: u64,
    head: usize,
    mutex: std.Thread.Mutex,

    fn size(self: *const TraceRing) usize {
        if (self.count < self.cap) return @intCast(self.count);
        return self.cap;
    }

    fn phys(self: *const TraceRing, i: usize) usize {
        if (self.count < self.cap) return i;
        return (self.head + i) % self.cap;
    }
};

pub fn perf_trace_create(cap_f: f64) callconv(.c) ?*TraceRing {
    if (cap_f < 1) return null;
    const cap: usize = @intFromFloat(cap_f);
    const t = gpa.create(TraceRing) catch return null;
    const ids = gpa.alloc(u8, cap * TRACE_ID_MAX) catch {
        gpa.destroy(t);
        return null;
    };
    const id_lens = gpa.alloc(u8, cap) catch {
        gpa.free(ids);
        gpa.destroy(t);
        return null;
    };
    const paths = gpa.alloc(u8, cap * TRACE_PATH_MAX) catch {
        gpa.free(id_lens);
        gpa.free(ids);
        gpa.destroy(t);
        return null;
    };
    const path_lens = gpa.alloc(u8, cap) catch {
        gpa.free(paths);
        gpa.free(id_lens);
        gpa.free(ids);
        gpa.destroy(t);
        return null;
    };
    const status = gpa.alloc(f64, cap) catch {
        gpa.free(path_lens);
        gpa.free(paths);
        gpa.free(id_lens);
        gpa.free(ids);
        gpa.destroy(t);
        return null;
    };
    const dur = gpa.alloc(f64, cap) catch {
        gpa.free(status);
        gpa.free(path_lens);
        gpa.free(paths);
        gpa.free(id_lens);
        gpa.free(ids);
        gpa.destroy(t);
        return null;
    };
    const wall = gpa.alloc(f64, cap) catch {
        gpa.free(dur);
        gpa.free(status);
        gpa.free(path_lens);
        gpa.free(paths);
        gpa.free(id_lens);
        gpa.free(ids);
        gpa.destroy(t);
        return null;
    };
    t.* = .{ .ids = ids, .id_lens = id_lens, .paths = paths, .path_lens = path_lens, .status = status, .dur = dur, .wall = wall, .cap = cap, .count = 0, .head = 0, .mutex = .{} };
    return t;
}

pub fn perf_trace_record(t_opt: ?*TraceRing, id: [*]const u8, id_len: usize, path: [*]const u8, path_len: usize, status: f64, dur_ms: f64, wall_ms: f64) callconv(.c) void {
    const t = t_opt orelse return;
    t.mutex.lock();
    defer t.mutex.unlock();
    const h = t.head;
    var il = id_len;
    if (il > TRACE_ID_MAX) il = TRACE_ID_MAX;
    @memcpy(t.ids[h * TRACE_ID_MAX ..][0..il], id[0..il]);
    t.id_lens[h] = @intCast(il);
    var pl = path_len;
    if (pl > TRACE_PATH_MAX) pl = TRACE_PATH_MAX;
    @memcpy(t.paths[h * TRACE_PATH_MAX ..][0..pl], path[0..pl]);
    t.path_lens[h] = @intCast(pl);
    t.status[h] = status;
    t.dur[h] = dur_ms;
    t.wall[h] = wall_ms;
    t.head = (t.head + 1) % t.cap;
    t.count += 1;
}

pub fn perf_trace_count(t_opt: ?*TraceRing) callconv(.c) f64 {
    const t = t_opt orelse return 0;
    t.mutex.lock();
    defer t.mutex.unlock();
    return @floatFromInt(t.count);
}

pub fn perf_trace_size(t_opt: ?*TraceRing) callconv(.c) f64 {
    const t = t_opt orelse return 0;
    t.mutex.lock();
    defer t.mutex.unlock();
    return @floatFromInt(t.size());
}

// 1-based, oldest first over the retained window. Returns the copied
// length (0 = out of range).
pub fn perf_trace_id_at(t_opt: ?*TraceRing, i_f: f64, out: [*]u8, max: usize) callconv(.c) i32 {
    const t = t_opt orelse return 0;
    t.mutex.lock();
    defer t.mutex.unlock();
    const n = t.size();
    if (i_f < 1 or i_f > @as(f64, @floatFromInt(n))) return 0;
    const p = t.phys(@as(usize, @intFromFloat(i_f)) - 1);
    var l: usize = t.id_lens[p];
    if (l > max) l = max;
    @memcpy(out[0..l], t.ids[p * TRACE_ID_MAX ..][0..l]);
    return @intCast(l);
}

pub fn perf_trace_path_at(t_opt: ?*TraceRing, i_f: f64, out: [*]u8, max: usize) callconv(.c) i32 {
    const t = t_opt orelse return 0;
    t.mutex.lock();
    defer t.mutex.unlock();
    const n = t.size();
    if (i_f < 1 or i_f > @as(f64, @floatFromInt(n))) return 0;
    const p = t.phys(@as(usize, @intFromFloat(i_f)) - 1);
    var l: usize = t.path_lens[p];
    if (l > max) l = max;
    @memcpy(out[0..l], t.paths[p * TRACE_PATH_MAX ..][0..l]);
    return @intCast(l);
}

fn traceFieldAt(t_opt: ?*TraceRing, i_f: f64, field: []const f64, t: *TraceRing) f64 {
    _ = t_opt;
    const n = t.size();
    if (i_f < 1 or i_f > @as(f64, @floatFromInt(n))) return -1;
    return field[t.phys(@as(usize, @intFromFloat(i_f)) - 1)];
}

pub fn perf_trace_status_at(t_opt: ?*TraceRing, i_f: f64) callconv(.c) f64 {
    const t = t_opt orelse return -1;
    t.mutex.lock();
    defer t.mutex.unlock();
    return traceFieldAt(t_opt, i_f, t.status, t);
}

pub fn perf_trace_dur_at(t_opt: ?*TraceRing, i_f: f64) callconv(.c) f64 {
    const t = t_opt orelse return -1;
    t.mutex.lock();
    defer t.mutex.unlock();
    return traceFieldAt(t_opt, i_f, t.dur, t);
}

pub fn perf_trace_wall_at(t_opt: ?*TraceRing, i_f: f64) callconv(.c) f64 {
    const t = t_opt orelse return -1;
    t.mutex.lock();
    defer t.mutex.unlock();
    return traceFieldAt(t_opt, i_f, t.wall, t);
}

pub fn perf_trace_reset(t_opt: ?*TraceRing) callconv(.c) void {
    const t = t_opt orelse return;
    t.mutex.lock();
    defer t.mutex.unlock();
    t.count = 0;
    t.head = 0;
}

pub fn perf_trace_destroy(t_opt: ?*TraceRing) callconv(.c) void {
    const t = t_opt orelse return;
    gpa.free(t.ids);
    gpa.free(t.id_lens);
    gpa.free(t.paths);
    gpa.free(t.path_lens);
    gpa.free(t.status);
    gpa.free(t.dur);
    gpa.free(t.wall);
    gpa.destroy(t);
}

// ── tests ────────────────────────────────────────────────────

test "perf: rss and peak are sane and ordered" {
    const rss = stz_perf_mem_rss();
    const peak = stz_perf_mem_peak();
    try std.testing.expect(rss > 1024 * 1024); // any real process exceeds 1MB
    try std.testing.expect(peak >= rss);
}

test "perf: system memory is sane" {
    const total = stz_perf_sys_mem_total();
    const free = stz_perf_sys_mem_free();
    try std.testing.expect(total > 1024 * 1024 * 1024); // > 1GB
    try std.testing.expect(free > 0);
    try std.testing.expect(free < total);
}

test "perf: cpu time advances with work, in ns" {
    const a = stz_perf_cpu_ns();
    try std.testing.expect(a >= 0);
    var x: f64 = 1.0001;
    var i: u32 = 0;
    while (i < 5_000_000) : (i += 1) x = x * 1.0000001 + 0.000001;
    std.mem.doNotOptimizeAway(&x);
    const b = stz_perf_cpu_ns();
    try std.testing.expect(b >= a);
}

test "series: record/read below capacity" {
    const s = perf_series_create(8).?;
    defer perf_series_destroy(s);
    perf_series_record(s, 1, 10);
    perf_series_record(s, 2, 30);
    perf_series_record(s, 3, 20);
    try std.testing.expectEqual(@as(f64, 3), perf_series_count(s));
    try std.testing.expectEqual(@as(f64, 3), perf_series_size(s));
    try std.testing.expectEqual(@as(f64, 20), perf_series_last(s));
    try std.testing.expectEqual(@as(f64, 10), perf_series_min(s));
    try std.testing.expectEqual(@as(f64, 30), perf_series_max(s));
    try std.testing.expectEqual(@as(f64, 20), perf_series_mean(s));
    try std.testing.expectEqual(@as(f64, 10), perf_series_value_at(s, 1));
    try std.testing.expectEqual(@as(f64, 3), perf_series_time_at(s, 3));
}

test "series: ring overwrites oldest past capacity" {
    const s = perf_series_create(3).?;
    defer perf_series_destroy(s);
    var i: f64 = 1;
    while (i <= 5) : (i += 1) perf_series_record(s, i, i * 100);
    try std.testing.expectEqual(@as(f64, 5), perf_series_count(s));
    try std.testing.expectEqual(@as(f64, 3), perf_series_size(s));
    // Retained window is samples 3, 4, 5 -- oldest first.
    try std.testing.expectEqual(@as(f64, 300), perf_series_value_at(s, 1));
    try std.testing.expectEqual(@as(f64, 500), perf_series_value_at(s, 3));
    try std.testing.expectEqual(@as(f64, 300), perf_series_min(s));
    try std.testing.expectEqual(@as(f64, 500), perf_series_last(s));
}

test "series: slope finds the trend" {
    const s = perf_series_create(16).?;
    defer perf_series_destroy(s);
    // v = 2*t + 5 exactly -> slope 2 per ms.
    var t: f64 = 0;
    while (t <= 10) : (t += 1) perf_series_record(s, t, 2 * t + 5);
    try std.testing.expectApproxEqAbs(@as(f64, 2), perf_series_slope_per_ms(s), 1e-9);
    // A flat series slopes 0.
    const flat = perf_series_create(8).?;
    defer perf_series_destroy(flat);
    perf_series_record(flat, 1, 7);
    perf_series_record(flat, 2, 7);
    perf_series_record(flat, 3, 7);
    try std.testing.expectApproxEqAbs(@as(f64, 0), perf_series_slope_per_ms(flat), 1e-12);
}

test "series: exact percentile, nearest rank" {
    const s = perf_series_create(100).?;
    defer perf_series_destroy(s);
    var i: f64 = 1;
    while (i <= 100) : (i += 1) perf_series_record(s, i, i);
    try std.testing.expectEqual(@as(f64, 50), perf_series_percentile(s, 50));
    try std.testing.expectEqual(@as(f64, 95), perf_series_percentile(s, 95));
    try std.testing.expectEqual(@as(f64, 100), perf_series_percentile(s, 100));
    try std.testing.expectEqual(@as(f64, 1), perf_series_percentile(s, 0));
}

test "trace ring: record, read back, overwrite oldest" {
    const t = perf_trace_create(3).?;
    defer perf_trace_destroy(t);
    perf_trace_record(t, "aaa", 3, "/one", 4, 200, 1.5, 1000);
    perf_trace_record(t, "bbbb", 4, "/two", 4, 404, 2.5, 2000);
    try std.testing.expectEqual(@as(f64, 2), perf_trace_count(t));
    var buf: [64]u8 = undefined;
    var n = perf_trace_id_at(t, 1, &buf, buf.len);
    try std.testing.expectEqualStrings("aaa", buf[0..@intCast(n)]);
    n = perf_trace_path_at(t, 2, &buf, buf.len);
    try std.testing.expectEqualStrings("/two", buf[0..@intCast(n)]);
    try std.testing.expectEqual(@as(f64, 404), perf_trace_status_at(t, 2));
    try std.testing.expectEqual(@as(f64, 1.5), perf_trace_dur_at(t, 1));
    // overwrite: 2 more pushes evict "aaa"
    perf_trace_record(t, "cccc", 4, "/three", 6, 200, 3.5, 3000);
    perf_trace_record(t, "dddd", 4, "/four", 5, 500, 4.5, 4000);
    try std.testing.expectEqual(@as(f64, 4), perf_trace_count(t));
    try std.testing.expectEqual(@as(f64, 3), perf_trace_size(t));
    n = perf_trace_id_at(t, 1, &buf, buf.len);
    try std.testing.expectEqualStrings("bbbb", buf[0..@intCast(n)]);
    try std.testing.expectEqual(@as(f64, 500), perf_trace_status_at(t, 3));
}

test "series: reset empties, capacity survives" {
    const s = perf_series_create(4).?;
    defer perf_series_destroy(s);
    perf_series_record(s, 1, 1);
    perf_series_reset(s);
    try std.testing.expectEqual(@as(f64, 0), perf_series_count(s));
    try std.testing.expectEqual(@as(f64, 0), perf_series_last(s));
    perf_series_record(s, 2, 9);
    try std.testing.expectEqual(@as(f64, 9), perf_series_last(s));
}
