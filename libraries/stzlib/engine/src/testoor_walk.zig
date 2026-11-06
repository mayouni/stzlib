//! Testoor core -- THE WALK: one child process, run to its end or its deadline (roadmap P3.5).
//! A port of the loop in `stzTraveller._WalkOnce` (base/testoor/stzTraveller.ring), without a Ring
//! virtual machine: spawn by argv in the tour's own folder, read what it prints and stamp each
//! complete line with the millisecond it ARRIVED, hold it to a deadline and kill it when it hangs,
//! read its error stream, and answer its exit code. The judge reads the answer.
//!
//! EVENT-DRIVEN, NOT POLLED. One thread blocks on the child's output, one on its error stream, and
//! the walking thread waits on the stream's end with the deadline as the timeout. Nothing spins.
//! (MEASURED 2026-11-06, TESTOOR-POLL-07: the Ring loop's `WaitFor(10)` is a real timed wait too, and
//! cost about 0.2 CPU seconds in all for a child idle for 2, 10 or 20 seconds; so this is not a fix
//! for CPU. It buys the same arrival accuracy with no Ring VM to carry, and a deadline that holds.)
//!
//! What the Ring loop did, kept: a line is stamped with the time of the read that completed it (every
//! line a read completes shares a stamp); every carriage return is removed from a line; a last line
//! with no line feed is kept, stamped at the stream's end; a hung child's error stream is dropped;
//! a killed child answers exit -3; a child that could not be started answers exit -1.
//!
//! Three differences, deliberate: the deadline is the whole walk's, so a child that ends its output
//! and then lingers is held to what is LEFT of it where the Ring loop gave it a fresh full timeout;
//! a child that streams output without pause is still killed at the deadline (the Ring loop only
//! looked at the clock when nothing had arrived); and on a system that is not Windows the wait for
//! the exit AFTER the stream ended is not time-limited yet (the stream's end is).
//!
//! Imports no Ring. Arrival times are whole milliseconds from a monotonic clock, as seconds.

const std = @import("std");
const builtin = @import("builtin");
const Allocator = std.mem.Allocator;
const V = @import("testoor_verdict.zig");

pub const Env = struct { key: []const u8, value: []const u8 };

/// Readers still blocked when a walk ended: a descendant of the child that escaped the job holds a pipe
/// open. A program that exits with a reader blocked in a synchronous read can hang in ExitProcess, so
/// the command line checks this and ends itself hard (testoor_main.zig).
pub var leaked_readers: std.atomic.Value(u32) = std.atomic.Value(u32).init(0);

/// A Windows JOB OBJECT holds the child and everything it starts, so the deadline kills the whole tree.
/// Killing only the child leaves a grandchild holding the output pipe open, and the readers never end
/// (measured 2026-11-06: a `cmd /c ping` tour killed at 1.5 s kept the runner alive for 29 s). std has
/// no job-object API, so the few calls are declared here.
const job = if (builtin.os.tag == .windows) struct {
    const w = std.os.windows;
    const BasicLimit = extern struct {
        per_process_user_time_limit: i64,
        per_job_user_time_limit: i64,
        limit_flags: w.DWORD,
        minimum_working_set_size: usize,
        maximum_working_set_size: usize,
        active_process_limit: w.DWORD,
        affinity: usize,
        priority_class: w.DWORD,
        scheduling_class: w.DWORD,
    };
    const IoCounters = extern struct { a: u64, b: u64, c: u64, d: u64, e: u64, f: u64 };
    const ExtendedLimit = extern struct {
        basic: BasicLimit,
        io: IoCounters,
        process_memory_limit: usize,
        job_memory_limit: usize,
        peak_process_memory_used: usize,
        peak_job_memory_used: usize,
    };
    const kill_on_close: w.DWORD = 0x2000;
    const extended_limit_class: c_int = 9;
    extern "kernel32" fn CreateJobObjectW(attrs: ?*anyopaque, name: ?[*:0]const u16) callconv(.winapi) ?w.HANDLE;
    extern "kernel32" fn SetInformationJobObject(h: w.HANDLE, class: c_int, info: *anyopaque, len: w.DWORD) callconv(.winapi) w.BOOL;
    extern "kernel32" fn AssignProcessToJobObject(h: w.HANDLE, process: w.HANDLE) callconv(.winapi) w.BOOL;
    extern "kernel32" fn TerminateJobObject(h: w.HANDLE, code: c_uint) callconv(.winapi) w.BOOL;

    /// a job that kills everything in it when it closes, with the child already inside; null when
    /// the system will not (the child is then killed alone, as before)
    fn adopt(process: w.HANDLE) ?w.HANDLE {
        const h = CreateJobObjectW(null, null) orelse return null;
        var info = std.mem.zeroes(ExtendedLimit);
        info.basic.limit_flags = kill_on_close;
        if (SetInformationJobObject(h, extended_limit_class, &info, @sizeOf(ExtendedLimit)) == 0 or AssignProcessToJobObject(h, process) == 0) {
            w.CloseHandle(h);
            return null;
        }
        return h;
    }

    fn killTree(h: w.HANDLE) void {
        _ = TerminateJobObject(h, 1);
    }
} else struct {};

pub const Spec = struct {
    argv: []const []const u8,
    /// the tour's own folder: the runtime resolves `load` against the working directory
    cwd: ?[]const u8 = null,
    /// added to this process's environment for the child
    env: []const Env = &.{},
    timeout_ms: f64 = 120000,
};

pub const Walked = struct {
    lines: []V.Line,
    stderr: []const u8,
    /// the child's exit code; -3 when it was killed at the deadline, -1 when it could not be started
    exit: i64,
    hung: bool,
    wall_ms: f64,
};

const Pipe = struct {
    file: std.fs.File,
    start: std.time.Instant,
    done: std.Thread.ResetEvent = .{},
    mutex: std.Thread.Mutex = .{},
    lines: std.ArrayList(V.Line) = .empty,
    raw: std.ArrayList(u8) = .empty,
};

fn sinceSec(start: std.time.Instant) f64 {
    const now = std.time.Instant.now() catch return 0;
    return @floor(@as(f64, @floatFromInt(now.since(start))) / 1.0e6) / 1000.0;
}

fn addLine(p: *Pipe, gpa: Allocator, raw: []const u8, at: f64) void {
    var n: usize = 0;
    for (raw) |c| if (c != '\r') {
        n += 1;
    };
    const txt = gpa.alloc(u8, n) catch return;
    var k: usize = 0;
    for (raw) |c| if (c != '\r') {
        txt[k] = c;
        k += 1;
    };
    p.mutex.lock();
    defer p.mutex.unlock();
    p.lines.append(gpa, .{ .text = txt, .at = at }) catch gpa.free(txt);
}

/// the output stream: lines, each stamped with the time of the read that completed it
fn readLines(p: *Pipe) void {
    defer p.done.set();
    const gpa = std.heap.smp_allocator;
    var buf: [64 * 1024]u8 = undefined;
    var pend: std.ArrayList(u8) = .empty;
    defer pend.deinit(gpa);
    while (true) {
        const n = p.file.read(&buf) catch break;
        if (n == 0) break;
        const at = sinceSec(p.start);
        pend.appendSlice(gpa, buf[0..n]) catch break;
        var from: usize = 0;
        while (std.mem.indexOfScalarPos(u8, pend.items, from, '\n')) |nl| {
            addLine(p, gpa, pend.items[from..nl], at);
            from = nl + 1;
        }
        if (from > 0) {
            const rest = pend.items.len - from;
            std.mem.copyForwards(u8, pend.items[0..rest], pend.items[from..]);
            pend.shrinkRetainingCapacity(rest);
        }
    }
    if (pend.items.len > 0) addLine(p, gpa, pend.items, sinceSec(p.start));
}

/// the error stream: every byte
fn readRaw(p: *Pipe) void {
    defer p.done.set();
    const gpa = std.heap.smp_allocator;
    var buf: [16 * 1024]u8 = undefined;
    while (true) {
        const n = p.file.read(&buf) catch break;
        if (n == 0) break;
        p.mutex.lock();
        p.raw.appendSlice(gpa, buf[0..n]) catch {
            p.mutex.unlock();
            break;
        };
        p.mutex.unlock();
    }
}

/// a reader that has ended is joined; one still blocked (a grandchild holds the pipe open) is let go
/// and its state is left to the process's end, never freed under it
fn finish(t: std.Thread, p: *Pipe) bool {
    p.done.timedWait(500 * std.time.ns_per_ms) catch {
        t.detach();
        return false;
    };
    t.join();
    return true;
}

fn remainingNs(start: std.time.Instant, timeout_ns: u64) u64 {
    const now = std.time.Instant.now() catch return 0;
    const used = now.since(start);
    return if (used >= timeout_ns) 0 else timeout_ns - used;
}

/// the exit code of a child whose output has ended, within `ms`; null when it is still running
fn waitExit(child: *std.process.Child, ms: u32) ?i64 {
    if (builtin.os.tag == .windows) {
        const w = std.os.windows;
        w.WaitForSingleObject(child.id, ms) catch |e| {
            if (e == error.WaitTimeOut) return null;
            return -1;
        };
        var code: w.DWORD = 0;
        if (w.kernel32.GetExitCodeProcess(child.id, &code) == 0) return -1;
        return @intCast(code);
    }
    const term = child.wait() catch return -1;
    return switch (term) {
        .Exited => |c| c,
        else => -1,
    };
}

pub fn walk(a: Allocator, spec: Spec) !Walked {
    const gpa = std.heap.smp_allocator;
    var env_map: std.process.EnvMap = undefined;
    var have_env = false;
    defer if (have_env) env_map.deinit();
    if (spec.env.len > 0) {
        env_map = try std.process.getEnvMap(a);
        have_env = true;
        for (spec.env) |e| try env_map.put(e.key, e.value);
    }
    var child = std.process.Child.init(spec.argv, a);
    child.cwd = spec.cwd;
    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;
    if (have_env) child.env_map = &env_map;

    const start = try std.time.Instant.now();
    child.spawn() catch |e| {
        return .{
            .lines = &.{},
            .stderr = try std.fmt.allocPrint(a, "could not start {s}: {s}", .{ if (spec.argv.len > 0) spec.argv[0] else "(no program)", @errorName(e) }),
            .exit = -1,
            .hung = false,
            .wall_ms = 0,
        };
    };

    const tree: ?std.os.windows.HANDLE = if (builtin.os.tag == .windows) job.adopt(child.id) else null;
    defer if (builtin.os.tag == .windows) {
        if (tree) |h| std.os.windows.CloseHandle(h);
    };

    const out = try gpa.create(Pipe);
    out.* = .{ .file = child.stdout.?, .start = start };
    const err = try gpa.create(Pipe);
    err.* = .{ .file = child.stderr.?, .start = start };
    const t_out = std.Thread.spawn(.{}, readLines, .{out}) catch |e| {
        _ = child.kill() catch {};
        return e;
    };
    const t_err = std.Thread.spawn(.{}, readRaw, .{err}) catch |e| {
        _ = child.kill() catch {};
        return e;
    };

    const timeout_ns: u64 = if (spec.timeout_ms < 1) 1_000_000 else @intFromFloat(@min(spec.timeout_ms, 1.0e9) * 1.0e6);
    var hung = false;
    var exit: i64 = -2;
    out.done.timedWait(remainingNs(start, timeout_ns)) catch {
        hung = true;
    };
    if (!hung) {
        const left_ms: u32 = @intCast(@min(remainingNs(start, timeout_ns) / std.time.ns_per_ms + 1, std.math.maxInt(u32) - 1));
        if (waitExit(&child, left_ms)) |code| {
            exit = code;
        } else {
            hung = true;
        }
    }
    if (hung) {
        exit = -3;
        if (builtin.os.tag == .windows) {
            if (tree) |h| job.killTree(h);
        }
        _ = child.kill() catch {};
    } else {
        // the child has gone; its error stream follows it
        err.done.timedWait(1000 * std.time.ns_per_ms) catch {};
        if (builtin.os.tag == .windows) _ = child.wait() catch {};
    }

    const out_joined = finish(t_out, out);
    const err_joined = finish(t_err, err);
    if (!out_joined) _ = leaked_readers.fetchAdd(1, .acq_rel);
    if (!err_joined) _ = leaked_readers.fetchAdd(1, .acq_rel);
    const wall_ms = @floor(@as(f64, @floatFromInt((try std.time.Instant.now()).since(start))) / 1.0e6);

    // the answer, copied out of the threads' state into the caller's allocator
    var lines: std.ArrayList(V.Line) = .empty;
    {
        out.mutex.lock();
        defer out.mutex.unlock();
        for (out.lines.items) |l| try lines.append(a, .{ .text = try a.dupe(u8, l.text), .at = l.at });
    }
    var stderr_text: []const u8 = "";
    if (!hung) {
        err.mutex.lock();
        defer err.mutex.unlock();
        stderr_text = try a.dupe(u8, err.raw.items);
    }
    if (out_joined) {
        for (out.lines.items) |l| gpa.free(l.text);
        out.lines.deinit(gpa);
        gpa.destroy(out);
    }
    if (err_joined) {
        err.raw.deinit(gpa);
        gpa.destroy(err);
    }
    return .{ .lines = lines.items, .stderr = stderr_text, .exit = exit, .hung = hung, .wall_ms = wall_ms };
}

// ── tests ────────────────────────────────────────────────────

const testing = std.testing;

fn argvFor(a: Allocator, cmd: []const u8) ![]const []const u8 {
    const v = try a.alloc([]const u8, 3);
    if (builtin.os.tag == .windows) {
        v[0] = "cmd.exe";
        v[1] = "/c";
    } else {
        v[0] = "sh";
        v[1] = "-c";
    }
    v[2] = cmd;
    return v;
}

test "a child's lines are kept in order, without their carriage returns, and the exit is its own" {
    if (builtin.os.tag != .windows and builtin.os.tag != .linux) return error.SkipZigTest;
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const w = try walk(a, .{ .argv = try argvFor(a, "echo one&& echo two"), .timeout_ms = 20000 });
    try testing.expect(!w.hung);
    try testing.expectEqual(@as(i64, 0), w.exit);
    try testing.expectEqual(@as(usize, 2), w.lines.len);
    try testing.expectEqualStrings("one", w.lines[0].text);
    try testing.expectEqualStrings("two", w.lines[1].text);
}

test "an exit code is answered whole, and an error stream is read" {
    if (builtin.os.tag != .windows and builtin.os.tag != .linux) return error.SkipZigTest;
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const w = try walk(a, .{ .argv = try argvFor(a, "echo oops 1>&2& exit 7"), .timeout_ms = 20000 });
    try testing.expectEqual(@as(i64, 7), w.exit);
    try testing.expectEqual(@as(usize, 0), w.lines.len);
    try testing.expect(std.mem.indexOf(u8, w.stderr, "oops") != null);
}

test "a line is stamped with the time it ARRIVED, not the time the child ended" {
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    // `ping -n 3` waits about two seconds between its two probes
    const w = try walk(a, .{ .argv = try argvFor(a, "echo first&& ping -n 3 127.0.0.1 >nul&& echo second"), .timeout_ms = 30000 });
    try testing.expectEqual(@as(i64, 0), w.exit);
    try testing.expectEqual(@as(usize, 2), w.lines.len);
    try testing.expect(w.lines[0].at < 1.0);
    try testing.expect(w.lines[1].at - w.lines[0].at >= 1.0);
    try testing.expect(w.wall_ms >= 1000);
}

test "a hung child is killed at the deadline, answers -3, and its error stream is dropped" {
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const w = try walk(a, .{ .argv = try argvFor(a, "echo alive&& ping -n 30 127.0.0.1 >nul"), .timeout_ms = 1500 });
    try testing.expect(w.hung);
    try testing.expectEqual(@as(i64, -3), w.exit);
    try testing.expect(w.wall_ms < 6000);
    try testing.expectEqualStrings("", w.stderr);
    try testing.expect(w.lines.len >= 1);
    try testing.expectEqualStrings("alive", w.lines[0].text);
    // the grandchild (`ping`) died with its parent: no reader was left blocked on its pipe
    try testing.expectEqual(@as(u32, 0), leaked_readers.load(.acquire));
}

test "a child that cannot be started answers -1 and says why" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const argv = [_][]const u8{"this-program-does-not-exist-testoor"};
    const w = try walk(a, .{ .argv = &argv });
    try testing.expectEqual(@as(i64, -1), w.exit);
    try testing.expect(!w.hung);
    try testing.expect(std.mem.indexOf(u8, w.stderr, "could not start") != null);
}

test "the environment is the parent's plus what the spec adds" {
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const env = [_]Env{.{ .key = "TESTOOR_WALK_PROBE", .value = "hello-from-the-spec" }};
    const w = try walk(a, .{ .argv = try argvFor(a, "echo %TESTOOR_WALK_PROBE%"), .env = &env, .timeout_ms = 20000 });
    try testing.expectEqual(@as(usize, 1), w.lines.len);
    try testing.expectEqualStrings("hello-from-the-spec", w.lines[0].text);
}
