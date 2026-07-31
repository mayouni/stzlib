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

// ── The frame profiler (perf P10) ────────────────────────────
//
// WHERE does the time go? Cooperative FRAMES + statistical SAMPLING.
// Ring marks frames (enter/leave); the frame STACK lives here, so a
// background sampler thread can photograph the active path at a fixed
// cadence with zero Ring involvement -- flame-graph truth whose
// sampling cost is constant no matter how hot the code. Both
// accumulations run per path ("a;b;c"):
//   instrumented: calls, total_ns, self_ns (total minus children)
//   sampled:      samples (photographs that landed on this path)
// Paths are bounded (max_paths at create; overflow -> "_overflow"),
// storage is fixed slabs -- the sampler never allocates.

const PROF_NAME_MAX = 48;
const PROF_PATH_MAX = 256;
const PROF_DEPTH_MAX = 32;

var g_prof_base: ?std.time.Instant = null;

fn profNowNs() u64 {
    if (g_prof_base == null) {
        g_prof_base = std.time.Instant.now() catch return 0;
    }
    const base = g_prof_base orelse return 0;
    const t = std.time.Instant.now() catch return 0;
    return t.since(base);
}

pub const Profiler = struct {
    // the live frame stack (Ring thread pushes/pops)
    fr_names: [PROF_DEPTH_MAX][PROF_NAME_MAX]u8,
    fr_lens: [PROF_DEPTH_MAX]u8,
    fr_start: [PROF_DEPTH_MAX]u64,
    fr_child: [PROF_DEPTH_MAX]u64, // ns spent in already-closed children
    depth: usize,
    // the path accumulation (fixed slabs)
    max_paths: usize,
    paths: []u8, // max_paths * PROF_PATH_MAX
    path_lens: []u16,
    calls: []u64,
    total_ns: []u64,
    self_ns: []u64,
    samples: []u64,
    n: usize,
    overflow_slot: ?usize,
    // sampling
    sampling: std.atomic.Value(bool),
    interval_ms: u64,
    ticks: u64, // sampler wakeups (in-frame or not)
    thread: ?std.Thread,
    mutex: std.Thread.Mutex,

    fn currentPath(self: *Profiler, out: []u8) usize {
        var l: usize = 0;
        var i: usize = 0;
        while (i < self.depth) : (i += 1) {
            const nl2: usize = self.fr_lens[i];
            if (l + nl2 + 1 >= out.len) break;
            if (i > 0) {
                out[l] = ';';
                l += 1;
            }
            @memcpy(out[l..][0..nl2], self.fr_names[i][0..nl2]);
            l += nl2;
        }
        return l;
    }

    fn slotFor(self: *Profiler, path: []const u8) usize {
        var i: usize = 0;
        while (i < self.n) : (i += 1) {
            if (self.path_lens[i] == path.len and std.mem.eql(u8, self.paths[i * PROF_PATH_MAX ..][0..path.len], path)) {
                return i;
            }
        }
        if (self.n < self.max_paths) {
            const s = self.n;
            @memcpy(self.paths[s * PROF_PATH_MAX ..][0..path.len], path);
            self.path_lens[s] = @intCast(path.len);
            self.n += 1;
            return s;
        }
        // full: the overflow path absorbs (created on first need --
        // room is guaranteed because it replaces nothing)
        if (self.overflow_slot) |s| return s;
        // reuse the LAST slot as overflow: relabel it
        const s = self.max_paths - 1;
        const label = "_overflow";
        @memcpy(self.paths[s * PROF_PATH_MAX ..][0..label.len], label);
        self.path_lens[s] = @intCast(label.len);
        self.overflow_slot = s;
        return s;
    }
};

pub fn perf_prof_create(max_paths_f: f64) callconv(.c) ?*Profiler {
    if (max_paths_f < 2) return null;
    const maxp: usize = @intFromFloat(max_paths_f);
    const p = gpa.create(Profiler) catch return null;
    const paths = gpa.alloc(u8, maxp * PROF_PATH_MAX) catch {
        gpa.destroy(p);
        return null;
    };
    const path_lens = gpa.alloc(u16, maxp) catch {
        gpa.free(paths);
        gpa.destroy(p);
        return null;
    };
    const calls = gpa.alloc(u64, maxp) catch {
        gpa.free(path_lens);
        gpa.free(paths);
        gpa.destroy(p);
        return null;
    };
    const total_ns = gpa.alloc(u64, maxp) catch {
        gpa.free(calls);
        gpa.free(path_lens);
        gpa.free(paths);
        gpa.destroy(p);
        return null;
    };
    const self_ns = gpa.alloc(u64, maxp) catch {
        gpa.free(total_ns);
        gpa.free(calls);
        gpa.free(path_lens);
        gpa.free(paths);
        gpa.destroy(p);
        return null;
    };
    const samples = gpa.alloc(u64, maxp) catch {
        gpa.free(self_ns);
        gpa.free(total_ns);
        gpa.free(calls);
        gpa.free(path_lens);
        gpa.free(paths);
        gpa.destroy(p);
        return null;
    };
    for (calls) |*x| x.* = 0;
    for (total_ns) |*x| x.* = 0;
    for (self_ns) |*x| x.* = 0;
    for (samples) |*x| x.* = 0;
    p.* = .{
        .fr_names = undefined,
        .fr_lens = [_]u8{0} ** PROF_DEPTH_MAX,
        .fr_start = [_]u64{0} ** PROF_DEPTH_MAX,
        .fr_child = [_]u64{0} ** PROF_DEPTH_MAX,
        .depth = 0,
        .max_paths = maxp,
        .paths = paths,
        .path_lens = path_lens,
        .calls = calls,
        .total_ns = total_ns,
        .self_ns = self_ns,
        .samples = samples,
        .n = 0,
        .overflow_slot = null,
        .sampling = std.atomic.Value(bool).init(false),
        .interval_ms = 5,
        .ticks = 0,
        .thread = null,
        .mutex = .{},
    };
    return p;
}

pub fn perf_prof_enter(p_opt: ?*Profiler, name: [*]const u8, name_len: usize) callconv(.c) void {
    const p = p_opt orelse return;
    p.mutex.lock();
    defer p.mutex.unlock();
    if (p.depth >= PROF_DEPTH_MAX) return; // deeper frames fold into the parent
    var nl2 = name_len;
    if (nl2 > PROF_NAME_MAX) nl2 = PROF_NAME_MAX;
    @memcpy(p.fr_names[p.depth][0..nl2], name[0..nl2]);
    p.fr_lens[p.depth] = @intCast(nl2);
    p.fr_start[p.depth] = profNowNs();
    p.fr_child[p.depth] = 0;
    p.depth += 1;
}

pub fn perf_prof_leave(p_opt: ?*Profiler) callconv(.c) void {
    const p = p_opt orelse return;
    p.mutex.lock();
    defer p.mutex.unlock();
    if (p.depth == 0) return;
    var buf: [PROF_PATH_MAX]u8 = undefined;
    const pl = p.currentPath(&buf); // path INCLUDING the leaving frame
    const d = p.depth - 1;
    const elapsed = profNowNs() - p.fr_start[d];
    const self_time = elapsed -| p.fr_child[d];
    const s = p.slotFor(buf[0..pl]);
    p.calls[s] += 1;
    p.total_ns[s] += elapsed;
    p.self_ns[s] += self_time;
    p.depth = d;
    if (d > 0) p.fr_child[d - 1] += elapsed;
}

pub fn perf_prof_depth(p_opt: ?*Profiler) callconv(.c) f64 {
    const p = p_opt orelse return 0;
    p.mutex.lock();
    defer p.mutex.unlock();
    return @floatFromInt(p.depth);
}

fn samplerLoop(p: *Profiler) void {
    while (p.sampling.load(.acquire)) {
        std.Thread.sleep(p.interval_ms * std.time.ns_per_ms);
        p.mutex.lock();
        p.ticks += 1;
        if (p.depth > 0) {
            var buf: [PROF_PATH_MAX]u8 = undefined;
            const pl = p.currentPath(&buf);
            const s = p.slotFor(buf[0..pl]);
            p.samples[s] += 1;
        }
        p.mutex.unlock();
    }
}

pub fn perf_prof_sample_start(p_opt: ?*Profiler, interval_ms_f: f64) callconv(.c) i32 {
    const p = p_opt orelse return -1;
    if (p.sampling.load(.acquire)) return -2; // already sampling
    p.interval_ms = if (interval_ms_f < 1) 1 else @intFromFloat(interval_ms_f);
    p.sampling.store(true, .release);
    p.thread = std.Thread.spawn(.{}, samplerLoop, .{p}) catch {
        p.sampling.store(false, .release);
        return -3;
    };
    return 0;
}

pub fn perf_prof_sample_stop(p_opt: ?*Profiler) callconv(.c) void {
    const p = p_opt orelse return;
    if (!p.sampling.load(.acquire)) return;
    p.sampling.store(false, .release);
    if (p.thread) |t| {
        t.join();
        p.thread = null;
    }
}

pub fn perf_prof_is_sampling(p_opt: ?*Profiler) callconv(.c) f64 {
    const p = p_opt orelse return 0;
    return if (p.sampling.load(.acquire)) 1 else 0;
}

pub fn perf_prof_ticks(p_opt: ?*Profiler) callconv(.c) f64 {
    const p = p_opt orelse return 0;
    p.mutex.lock();
    defer p.mutex.unlock();
    return @floatFromInt(p.ticks);
}

pub fn perf_prof_path_count(p_opt: ?*Profiler) callconv(.c) f64 {
    const p = p_opt orelse return 0;
    p.mutex.lock();
    defer p.mutex.unlock();
    return @floatFromInt(p.n);
}

// 1-based readers over the accumulated paths.
pub fn perf_prof_path_at(p_opt: ?*Profiler, i_f: f64, out: [*]u8, max: usize) callconv(.c) i32 {
    const p = p_opt orelse return 0;
    p.mutex.lock();
    defer p.mutex.unlock();
    if (i_f < 1 or i_f > @as(f64, @floatFromInt(p.n))) return 0;
    const i = @as(usize, @intFromFloat(i_f)) - 1;
    var l: usize = p.path_lens[i];
    if (l > max) l = max;
    @memcpy(out[0..l], p.paths[i * PROF_PATH_MAX ..][0..l]);
    return @intCast(l);
}

fn profField(p_opt: ?*Profiler, i_f: f64, field: []const u64) f64 {
    const p = p_opt orelse return -1;
    if (i_f < 1 or i_f > @as(f64, @floatFromInt(p.n))) return -1;
    return @floatFromInt(field[@as(usize, @intFromFloat(i_f)) - 1]);
}

pub fn perf_prof_calls_at(p_opt: ?*Profiler, i_f: f64) callconv(.c) f64 {
    const p = p_opt orelse return -1;
    p.mutex.lock();
    defer p.mutex.unlock();
    return profField(p_opt, i_f, p.calls);
}

pub fn perf_prof_total_ns_at(p_opt: ?*Profiler, i_f: f64) callconv(.c) f64 {
    const p = p_opt orelse return -1;
    p.mutex.lock();
    defer p.mutex.unlock();
    return profField(p_opt, i_f, p.total_ns);
}

pub fn perf_prof_self_ns_at(p_opt: ?*Profiler, i_f: f64) callconv(.c) f64 {
    const p = p_opt orelse return -1;
    p.mutex.lock();
    defer p.mutex.unlock();
    return profField(p_opt, i_f, p.self_ns);
}

pub fn perf_prof_samples_at(p_opt: ?*Profiler, i_f: f64) callconv(.c) f64 {
    const p = p_opt orelse return -1;
    p.mutex.lock();
    defer p.mutex.unlock();
    return profField(p_opt, i_f, p.samples);
}

pub fn perf_prof_reset(p_opt: ?*Profiler) callconv(.c) void {
    const p = p_opt orelse return;
    p.mutex.lock();
    defer p.mutex.unlock();
    p.n = 0;
    p.depth = 0;
    p.ticks = 0;
    p.overflow_slot = null;
    for (p.calls) |*x| x.* = 0;
    for (p.total_ns) |*x| x.* = 0;
    for (p.self_ns) |*x| x.* = 0;
    for (p.samples) |*x| x.* = 0;
}

pub fn perf_prof_destroy(p_opt: ?*Profiler) callconv(.c) void {
    const p = p_opt orelse return;
    perf_prof_sample_stop(p);
    gpa.free(p.paths);
    gpa.free(p.path_lens);
    gpa.free(p.calls);
    gpa.free(p.total_ns);
    gpa.free(p.self_ns);
    gpa.free(p.samples);
    gpa.destroy(p);
}

// ── The trace scope (perf P9: log-trace correlation) ─────────
//
// One process-global slot holding the ACTIVE traceparent. The server
// bracket opens the scope before dispatch and closes it after the
// write; anything that logs meanwhile -- any stzLog, any face, any
// object -- reads the same slot and stamps its records with the
// trace id. Engine-global for the usual reason: a Ring-side
// "current trace" would be per-face state and the handler's log
// would miss it.

var g_scope_buf: [64]u8 = undefined;
var g_scope_len: usize = 0;
var g_scope_mutex: std.Thread.Mutex = .{};

pub fn perf_trace_scope_set(ptr: [*]const u8, len: usize) callconv(.c) void {
    g_scope_mutex.lock();
    defer g_scope_mutex.unlock();
    var l = len;
    if (l > g_scope_buf.len) l = g_scope_buf.len;
    @memcpy(g_scope_buf[0..l], ptr[0..l]);
    g_scope_len = l;
}

pub fn perf_trace_scope_get(out: [*]u8, max: usize) callconv(.c) i32 {
    g_scope_mutex.lock();
    defer g_scope_mutex.unlock();
    var l = g_scope_len;
    if (l > max) l = max;
    @memcpy(out[0..l], g_scope_buf[0..l]);
    return @intCast(l);
}

pub fn perf_trace_scope_clear() callconv(.c) void {
    g_scope_mutex.lock();
    defer g_scope_mutex.unlock();
    g_scope_len = 0;
}

// ── The metric family (perf P8: labels / dimensions) ─────────
//
// A family is a metric name + declared label names; each distinct
// label-value combination is a CHILD with its own series (and, for
// timers, histogram). The child REGISTRY lives engine-side for the
// same reason all perf state does: children are created dynamically
// (a route first hit after the server copied its monitor), and every
// Ring face must resolve a label set to the SAME stores -- a Ring-side
// registry would fork per copy.
//
// Cardinality is BOUNDED BY DESIGN (max_children at creation): the
// field's cardinality explosions come from unbounded label values.
// When the family is full, child lookup returns null and the Ring
// face routes records to its reserved overflow child -- data is
// never silently dropped, and the exposition shows the overflow.
//
// Keys are the label VALUES joined with '|' (values sanitized Ring-
// side); bounded at FAM_KEY_MAX bytes.

const FAM_KEY_MAX = 128;

const hist_mod = @import("histogram.zig");
const Histogram = hist_mod.Histogram;

pub const Family = struct {
    kind: u8, // 0 counter, 1 gauge, 2 timer (timer children get a histogram)
    window: usize, // per-child series capacity
    max_children: usize,
    keys: []u8, // max_children * FAM_KEY_MAX
    key_lens: []u8,
    series: []?*Series,
    hists: []?*Histogram,
    n: usize,
    mutex: std.Thread.Mutex,
};

pub fn perf_family_create(kind_f: f64, window_f: f64, max_children_f: f64) callconv(.c) ?*Family {
    if (max_children_f < 1 or window_f < 1) return null;
    const maxc: usize = @intFromFloat(max_children_f);
    const f = gpa.create(Family) catch return null;
    const keys = gpa.alloc(u8, maxc * FAM_KEY_MAX) catch {
        gpa.destroy(f);
        return null;
    };
    const key_lens = gpa.alloc(u8, maxc) catch {
        gpa.free(keys);
        gpa.destroy(f);
        return null;
    };
    const series = gpa.alloc(?*Series, maxc) catch {
        gpa.free(key_lens);
        gpa.free(keys);
        gpa.destroy(f);
        return null;
    };
    const hists = gpa.alloc(?*Histogram, maxc) catch {
        gpa.free(series);
        gpa.free(key_lens);
        gpa.free(keys);
        gpa.destroy(f);
        return null;
    };
    for (series) |*s| s.* = null;
    for (hists) |*h| h.* = null;
    f.* = .{ .kind = @intFromFloat(kind_f), .window = @intFromFloat(window_f), .max_children = maxc, .keys = keys, .key_lens = key_lens, .series = series, .hists = hists, .n = 0, .mutex = .{} };
    return f;
}

// Find the slot for a key, creating it (with its stores) when new and
// room remains. Returns the slot index, or null when full-and-new.
fn famSlot(f: *Family, key: [*]const u8, key_len: usize) ?usize {
    var kl = key_len;
    if (kl > FAM_KEY_MAX) kl = FAM_KEY_MAX;
    var i: usize = 0;
    while (i < f.n) : (i += 1) {
        if (f.key_lens[i] == kl and std.mem.eql(u8, f.keys[i * FAM_KEY_MAX ..][0..kl], key[0..kl])) {
            return i;
        }
    }
    if (f.n >= f.max_children) return null;
    const slot = f.n;
    const s = gpa.create(Series) catch return null;
    const times = gpa.alloc(f64, f.window) catch {
        gpa.destroy(s);
        return null;
    };
    const values = gpa.alloc(f64, f.window) catch {
        gpa.free(times);
        gpa.destroy(s);
        return null;
    };
    s.* = .{ .times = times, .values = values, .cap = f.window, .count = 0, .head = 0, .mutex = .{} };
    f.series[slot] = s;
    if (f.kind == 2) {
        const h = hist_mod.histogram_create() orelse {
            // keep the series; a timer child without a histogram still
            // answers window stats -- but this alloc-failure path is
            // effectively unreachable in practice
            f.hists[slot] = null;
            @memcpy(f.keys[slot * FAM_KEY_MAX ..][0..kl], key[0..kl]);
            f.key_lens[slot] = @intCast(kl);
            f.n += 1;
            return slot;
        };
        f.hists[slot] = h;
    }
    @memcpy(f.keys[slot * FAM_KEY_MAX ..][0..kl], key[0..kl]);
    f.key_lens[slot] = @intCast(kl);
    f.n += 1;
    return slot;
}

pub fn perf_family_child_series(f_opt: ?*Family, key: [*]const u8, key_len: usize) callconv(.c) ?*Series {
    const f = f_opt orelse return null;
    f.mutex.lock();
    defer f.mutex.unlock();
    const slot = famSlot(f, key, key_len) orelse return null;
    return f.series[slot];
}

pub fn perf_family_child_hist(f_opt: ?*Family, key: [*]const u8, key_len: usize) callconv(.c) ?*Histogram {
    const f = f_opt orelse return null;
    f.mutex.lock();
    defer f.mutex.unlock();
    const slot = famSlot(f, key, key_len) orelse return null;
    return f.hists[slot];
}

// 1 when the key already has a child OR room remains for it; 0 when
// the family is full and the key is new (route to the overflow child).
pub fn perf_family_can_add(f_opt: ?*Family, key: [*]const u8, key_len: usize) callconv(.c) f64 {
    const f = f_opt orelse return 0;
    f.mutex.lock();
    defer f.mutex.unlock();
    var kl = key_len;
    if (kl > FAM_KEY_MAX) kl = FAM_KEY_MAX;
    var i: usize = 0;
    while (i < f.n) : (i += 1) {
        if (f.key_lens[i] == kl and std.mem.eql(u8, f.keys[i * FAM_KEY_MAX ..][0..kl], key[0..kl])) {
            return 1;
        }
    }
    if (f.n < f.max_children) return 1;
    return 0;
}

pub fn perf_family_size(f_opt: ?*Family) callconv(.c) f64 {
    const f = f_opt orelse return 0;
    f.mutex.lock();
    defer f.mutex.unlock();
    return @floatFromInt(f.n);
}

// 1-based, in creation order.
pub fn perf_family_key_at(f_opt: ?*Family, i_f: f64, out: [*]u8, max: usize) callconv(.c) i32 {
    const f = f_opt orelse return 0;
    f.mutex.lock();
    defer f.mutex.unlock();
    if (i_f < 1 or i_f > @as(f64, @floatFromInt(f.n))) return 0;
    const i = @as(usize, @intFromFloat(i_f)) - 1;
    var l: usize = f.key_lens[i];
    if (l > max) l = max;
    @memcpy(out[0..l], f.keys[i * FAM_KEY_MAX ..][0..l]);
    return @intCast(l);
}

pub fn perf_family_destroy(f_opt: ?*Family) callconv(.c) void {
    const f = f_opt orelse return;
    var i: usize = 0;
    while (i < f.n) : (i += 1) {
        if (f.series[i]) |s| perf_series_destroy(s);
        if (f.hists[i]) |h| hist_mod.histogram_destroy(h);
    }
    gpa.free(f.keys);
    gpa.free(f.key_lens);
    gpa.free(f.series);
    gpa.free(f.hists);
    gpa.destroy(f);
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

test "family: children are keyed, created once, bounded" {
    const f = perf_family_create(2, 16, 3).?; // timer kind, 3 children max
    defer perf_family_destroy(f);
    const a = perf_family_child_series(f, "GET|/a", 6).?;
    const b = perf_family_child_series(f, "GET|/b", 6).?;
    try std.testing.expect(a != b);
    // same key resolves to the SAME child
    const a2 = perf_family_child_series(f, "GET|/a", 6).?;
    try std.testing.expect(a == a2);
    perf_series_record(a, 1, 10);
    try std.testing.expectEqual(@as(f64, 10), perf_series_last(a2));
    // timers get histograms, shared per key too
    const ha = perf_family_child_hist(f, "GET|/a", 6).?;
    const ha2 = perf_family_child_hist(f, "GET|/a", 6).?;
    try std.testing.expect(ha == ha2);
    // capacity: a third child fits, a fourth refuses
    _ = perf_family_child_series(f, "GET|/c", 6).?;
    try std.testing.expectEqual(@as(f64, 3), perf_family_size(f));
    try std.testing.expect(perf_family_child_series(f, "GET|/d", 6) == null);
    // keys read back in creation order
    var buf: [64]u8 = undefined;
    const n = perf_family_key_at(f, 2, &buf, buf.len);
    try std.testing.expectEqualStrings("GET|/b", buf[0..@intCast(n)]);
}

test "profiler: nested frames accumulate paths with self vs total" {
    const p = perf_prof_create(16).?;
    defer perf_prof_destroy(p);
    perf_prof_enter(p, "a", 1);
    std.Thread.sleep(4 * std.time.ns_per_ms);
    perf_prof_enter(p, "b", 1);
    std.Thread.sleep(6 * std.time.ns_per_ms);
    perf_prof_leave(p); // b
    perf_prof_leave(p); // a
    try std.testing.expectEqual(@as(f64, 2), perf_prof_path_count(p));
    var buf: [256]u8 = undefined;
    var n = perf_prof_path_at(p, 1, &buf, buf.len);
    try std.testing.expectEqualStrings("a;b", buf[0..@intCast(n)]);
    n = perf_prof_path_at(p, 2, &buf, buf.len);
    try std.testing.expectEqualStrings("a", buf[0..@intCast(n)]);
    // a's total covers both sleeps; a's SELF excludes b's share
    const a_total = perf_prof_total_ns_at(p, 2);
    const a_self = perf_prof_self_ns_at(p, 2);
    const b_total = perf_prof_total_ns_at(p, 1);
    try std.testing.expect(a_total >= b_total);
    try std.testing.expect(a_self <= a_total - b_total + 2_000_000.0); // ~tolerance
    try std.testing.expectEqual(@as(f64, 1), perf_prof_calls_at(p, 1));
}

test "profiler: the sampler photographs the active path" {
    const p = perf_prof_create(16).?;
    defer perf_prof_destroy(p);
    try std.testing.expectEqual(@as(i32, 0), perf_prof_sample_start(p, 1));
    perf_prof_enter(p, "hot", 3);
    std.Thread.sleep(60 * std.time.ns_per_ms);
    perf_prof_leave(p);
    perf_prof_sample_stop(p);
    try std.testing.expect(perf_prof_ticks(p) > 5);
    // the hot frame collected samples
    var buf: [256]u8 = undefined;
    const n = perf_prof_path_at(p, 1, &buf, buf.len);
    try std.testing.expectEqualStrings("hot", buf[0..@intCast(n)]);
    try std.testing.expect(perf_prof_samples_at(p, 1) > 3);
}

test "profiler: bounded paths fold into overflow" {
    const p = perf_prof_create(2).?;
    defer perf_prof_destroy(p);
    perf_prof_enter(p, "one", 3);
    perf_prof_leave(p);
    perf_prof_enter(p, "two", 3);
    perf_prof_leave(p);
    perf_prof_enter(p, "three", 5);
    perf_prof_leave(p);
    try std.testing.expectEqual(@as(f64, 2), perf_prof_path_count(p));
    var buf: [256]u8 = undefined;
    const n = perf_prof_path_at(p, 2, &buf, buf.len);
    try std.testing.expectEqualStrings("_overflow", buf[0..@intCast(n)]);
}

test "trace scope: set, read back, clear" {
    perf_trace_scope_set("00-abc-def-01", 13);
    var buf: [64]u8 = undefined;
    var n = perf_trace_scope_get(&buf, buf.len);
    try std.testing.expectEqualStrings("00-abc-def-01", buf[0..@intCast(n)]);
    perf_trace_scope_clear();
    n = perf_trace_scope_get(&buf, buf.len);
    try std.testing.expectEqual(@as(i32, 0), n);
}

test "family: counter kind has no histogram" {
    const f = perf_family_create(0, 8, 2).?;
    defer perf_family_destroy(f);
    _ = perf_family_child_series(f, "x", 1).?;
    try std.testing.expect(perf_family_child_hist(f, "x", 1) == null);
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
