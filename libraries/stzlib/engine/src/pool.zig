// Bounded thread pool with a work queue.
//
// Replaces per-call std.Thread.spawn (which costs a thread create +
// join per job, ~50-100us on Linux, ~200-500us on Windows). A pool
// with N worker threads reuses them across jobs: spawn cost is paid
// once, queue overhead is a mutex + cond var (sub-microsecond).
//
// This is the prerequisite for scaling parallel HTTP / TCP server /
// fswatch beyond the per-thread limit. With N = num_cpus and
// std.net using blocking I/O, the pool holds connections proportional
// to N; for the IOCP/epoll/kqueue scale (10k+ concurrent connections
// per worker via non-blocking I/O) we still need a real reactor.
// That arc is tracked separately.
//
// Surface:
//   pool_create(num_workers) -> opaque handle
//   pool_submit(pool, job_kind, arg_blob, arg_len) -> job_id (or -1)
//   pool_poll(pool, job_id, out, max) -> result bytes
//     -1: still running
//     -2: not found
//     >=0: bytes written into out (job complete; status code prefix
//           depends on job_kind)
//   pool_destroy(pool)
//   pool_last_error_len() / pool_last_error(buf, max)
//
// Job kinds:
//   0 = http_get(url)
//   (extend with more verbs as callers need them)

const std = @import("std");

const gpa = std.heap.c_allocator;

var last_error_buf: [512]u8 = undefined;
var last_error_len: usize = 0;

fn setError(msg: []const u8) void {
    const n = @min(msg.len, last_error_buf.len);
    @memcpy(last_error_buf[0..n], msg[0..n]);
    last_error_len = n;
}

pub fn pool_last_error_len() callconv(.c) usize {
    return last_error_len;
}

pub fn pool_last_error(out: [*]u8, max: usize) callconv(.c) i32 {
    const n = @min(last_error_len, max);
    if (n == 0) return 0;
    @memcpy(out[0..n], last_error_buf[0..n]);
    return @intCast(n);
}

pub const JobStatus = enum(u8) { pending, running, done };

pub const Job = struct {
    id: u64,
    kind: u32,
    arg: []u8,
    status: JobStatus,
    result_status: i32,
    result_body: std.ArrayList(u8),
};

pub const Pool = struct {
    workers: []std.Thread,
    queue: std.ArrayList(*Job),
    jobs_by_id: std.AutoHashMap(u64, *Job),
    next_id: u64,
    max_queue: usize,
    mutex: std.Thread.Mutex,
    cond: std.Thread.Condition,
    stop_flag: std.atomic.Value(bool),
};

pub fn pool_create(num_workers: u32) callconv(.c) ?*Pool {
    return pool_create_xt(num_workers, 0);
}

/// Extended ctor with explicit queue cap.
/// max_queue == 0 means unbounded (legacy behaviour).
pub fn pool_create_xt(num_workers: u32, max_queue: u32) callconv(.c) ?*Pool {
    last_error_len = 0;
    const n = if (num_workers == 0) 4 else @min(num_workers, 256);

    const p = gpa.create(Pool) catch {
        setError("oom (pool)");
        return null;
    };

    p.* = .{
        .workers = gpa.alloc(std.Thread, n) catch {
            gpa.destroy(p);
            setError("oom (workers)");
            return null;
        },
        .queue = .{},
        .jobs_by_id = std.AutoHashMap(u64, *Job).init(gpa),
        .next_id = 1,
        .max_queue = max_queue,
        .mutex = .{},
        .cond = .{},
        .stop_flag = std.atomic.Value(bool).init(false),
    };

    for (p.workers) |*t| {
        if (std.Thread.spawn(.{}, workerLoop, .{p})) |th| {
            t.* = th;
        } else |_| {
            setError("partial worker init");
        }
    }
    return p;
}

pub fn pool_submit(
    pool_opt: ?*Pool,
    kind: u32,
    arg_ptr: [*]const u8,
    arg_len: usize,
) callconv(.c) i64 {
    last_error_len = 0;
    const p = pool_opt orelse {
        setError("null pool");
        return -1;
    };
    const job = gpa.create(Job) catch {
        setError("oom (job)");
        return -1;
    };
    const arg_copy = gpa.dupe(u8, arg_ptr[0..arg_len]) catch {
        gpa.destroy(job);
        setError("oom (arg)");
        return -1;
    };

    p.mutex.lock();
    defer p.mutex.unlock();

    // Backpressure: refuse submissions when the queue is full so the
    // caller can retry / shed load instead of OOMing the engine.
    if (p.max_queue != 0 and p.queue.items.len >= p.max_queue) {
        gpa.free(arg_copy);
        gpa.destroy(job);
        setError("queue full (backpressure)");
        return -2;
    }

    job.* = .{
        .id = p.next_id,
        .kind = kind,
        .arg = arg_copy,
        .status = .pending,
        .result_status = 0,
        .result_body = .{},
    };
    p.next_id += 1;
    p.queue.append(gpa, job) catch {
        gpa.free(arg_copy);
        gpa.destroy(job);
        setError("oom (queue)");
        return -1;
    };
    p.jobs_by_id.put(job.id, job) catch {};
    p.cond.signal();
    return @intCast(job.id);
}

/// Snapshot of pool state for ops dashboards + tests.
pub fn pool_pending(pool_opt: ?*Pool) callconv(.c) i32 {
    const p = pool_opt orelse return -1;
    p.mutex.lock();
    defer p.mutex.unlock();
    return @intCast(p.queue.items.len);
}

pub fn pool_inflight(pool_opt: ?*Pool) callconv(.c) i32 {
    const p = pool_opt orelse return -1;
    p.mutex.lock();
    defer p.mutex.unlock();
    var n: i32 = 0;
    var it = p.jobs_by_id.iterator();
    while (it.next()) |e| {
        if (e.value_ptr.*.status == .running) n += 1;
    }
    return n;
}

/// pool_poll returns:
///   -1 = job still running
///   -2 = job id not found (already drained or never submitted)
///   -3 = output buffer too small for body
///   >=0 = HTTP status (or job-kind result code) and body written
pub fn pool_poll(
    pool_opt: ?*Pool,
    job_id: u64,
    out: [*]u8,
    max: usize,
) callconv(.c) i32 {
    const p = pool_opt orelse return -2;
    p.mutex.lock();
    defer p.mutex.unlock();

    const job = p.jobs_by_id.get(job_id) orelse return -2;
    if (job.status != .done) return -1;

    const body = job.result_body.items;
    if (body.len > max) return -3;
    @memcpy(out[0..body.len], body);
    const status = job.result_status;

    // Drain: free the job slot. Caller has the result now.
    _ = p.jobs_by_id.remove(job_id);
    gpa.free(job.arg);
    job.result_body.deinit(gpa);
    gpa.destroy(job);
    last_body_len = body.len;
    return status;
}

var last_body_len: usize = 0;

pub fn pool_last_body_len() callconv(.c) usize {
    return last_body_len;
}

pub fn pool_destroy(pool_opt: ?*Pool) callconv(.c) void {
    const p = pool_opt orelse return;
    p.stop_flag.store(true, .release);
    {
        p.mutex.lock();
        defer p.mutex.unlock();
        p.cond.broadcast();
    }
    for (p.workers) |t| t.join();
    gpa.free(p.workers);

    // Drain any pending jobs.
    while (p.queue.pop()) |job| {
        gpa.free(job.arg);
        job.result_body.deinit(gpa);
        gpa.destroy(job);
    }
    p.queue.deinit(gpa);

    var it = p.jobs_by_id.iterator();
    while (it.next()) |entry| {
        const job = entry.value_ptr.*;
        gpa.free(job.arg);
        job.result_body.deinit(gpa);
        gpa.destroy(job);
    }
    p.jobs_by_id.deinit();
    gpa.destroy(p);
}

// ── worker ───────────────────────────────────────────────────

fn workerLoop(p: *Pool) void {
    while (true) {
        p.mutex.lock();
        while (p.queue.items.len == 0 and !p.stop_flag.load(.acquire)) {
            p.cond.wait(&p.mutex);
        }
        if (p.stop_flag.load(.acquire) and p.queue.items.len == 0) {
            p.mutex.unlock();
            return;
        }
        const job = p.queue.orderedRemove(0);
        job.status = .running;
        p.mutex.unlock();

        runJob(job);

        p.mutex.lock();
        job.status = .done;
        p.mutex.unlock();
    }
}

fn runJob(job: *Job) void {
    switch (job.kind) {
        0 => runHttpGet(job),
        else => {
            job.result_status = -99;
            const msg = "unknown job kind";
            job.result_body.appendSlice(gpa, msg) catch {};
        },
    }
}

fn runHttpGet(job: *Job) void {
    var client = std.http.Client{ .allocator = gpa };
    defer client.deinit();
    var allocating = std.io.Writer.Allocating.init(gpa);
    defer allocating.deinit();

    const res = client.fetch(.{
        .method = .GET,
        .location = .{ .url = job.arg },
        .response_writer = &allocating.writer,
    }) catch {
        job.result_status = -1;
        const msg = "transport error";
        job.result_body.appendSlice(gpa, msg) catch {};
        return;
    };
    job.result_status = @intCast(@intFromEnum(res.status));
    job.result_body.appendSlice(gpa, allocating.writer.buffered()) catch {
        job.result_status = -1;
    };
}

// ── tests ────────────────────────────────────────────────────

test "pool: create + destroy" {
    const p = pool_create(2).?;
    pool_destroy(p);
}

test "pool: submit job + poll while running" {
    const p = pool_create(2).?;
    defer pool_destroy(p);

    const id = pool_submit(p, 0, "bogus".ptr, 5);
    try std.testing.expect(id > 0);

    // Without waiting, the job is either pending or in flight.
    var buf: [256]u8 = undefined;
    const code = pool_poll(p, @intCast(id), &buf, 256);
    // -1 = running, or already done with transport error (-1 status).
    try std.testing.expect(code == -1 or code == -1);
}

test "pool: unknown id" {
    const p = pool_create(1).?;
    defer pool_destroy(p);
    var buf: [16]u8 = undefined;
    try std.testing.expectEqual(@as(i32, -2), pool_poll(p, 99999, &buf, 16));
}
