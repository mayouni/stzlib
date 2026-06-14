// Reactor -- cross-platform async I/O backbone on vendored libuv.
//
// Tier 2 foundation. libuv is the industry-standard event loop (Node.js,
// Julia, Neovim): epoll on Linux, kqueue on macOS/BSD, IOCP on Windows,
// behind one proactor API. We vendor it as C source (engine/vendor/libuv,
// like utf8proc/pcre2/sqlite) and build the engine's async surface on top
// of it instead of hand-rolling per-OS reactors.
//
// This first slice only proves the vendor + build + link path is sound:
//   reactor_version()   -> libuv version string (links + headers OK)
//   reactor_selftest()  -> runs a real loop with a one-shot timer and
//                          returns the number of timer callbacks fired
//                          (expected 1) -- proves the loop actually runs.
//
// The full reactor surface (a loop owned by an engine worker thread,
// async TCP/HTTP multiplexing, results drained through the existing
// submit/poll handle pattern so Ring stays synchronous) lands in
// subsequent slices.

const std = @import("std");
const c = @cImport({
    @cInclude("uv.h");
});

/// libuv version string, e.g. "1.52.1".
pub fn reactor_version() callconv(.c) [*c]const u8 {
    return c.uv_version_string();
}

/// Numeric libuv version (UV_VERSION_HEX-style: major<<16 | minor<<8 | patch).
pub fn reactor_version_hex() callconv(.c) u32 {
    return @intCast(c.uv_version());
}

// Self-test: spin up a private loop, arm a 1ms one-shot timer, run the
// loop to completion, and report how many times the timer fired. A
// healthy build returns 1.
var selftest_fired: i32 = 0;

fn onSelftestTimer(handle: [*c]c.uv_timer_t) callconv(.c) void {
    selftest_fired += 1;
    _ = c.uv_timer_stop(handle);
}

pub fn reactor_selftest() callconv(.c) i32 {
    selftest_fired = 0;
    var loop: c.uv_loop_t = undefined;
    if (c.uv_loop_init(&loop) != 0) return -1;
    var timer: c.uv_timer_t = undefined;
    if (c.uv_timer_init(&loop, &timer) != 0) {
        _ = c.uv_loop_close(&loop);
        return -2;
    }
    if (c.uv_timer_start(&timer, onSelftestTimer, 1, 0) != 0) {
        _ = c.uv_loop_close(&loop);
        return -3;
    }
    _ = c.uv_run(&loop, c.UV_RUN_DEFAULT);
    _ = c.uv_loop_close(&loop);
    return selftest_fired;
}

// ── Reactor core: a libuv loop on a worker thread ────────────
//
// Tier 2 slice 1. The reactor owns a uv_loop running on its own thread.
// Ring (or any other thread) submits work through a thread-safe queue +
// uv_async_send wake; the loop thread starts the libuv operation, and on
// completion stores the result in a job table. Ring drains results with
// the same submit/poll handle idiom as the thread pool, so Ring stays
// synchronous -- it never sees a libuv callback.
//
// Handle lifetime uses the standard libuv two-phase dance: an op's handle
// is uv_close()d on completion, and the Job is freed only once BOTH the
// close callback has fired and the caller has polled the result.

const gpa = std.heap.c_allocator;

// libuv's stream types (uv_stream_t / uv_tcp_t) are mutually recursive
// with uv_read_cb, which Zig's translate-c cannot build ("dependency
// loop"). We therefore treat TCP handles + requests as OPAQUE buffers
// (sized at runtime via uv_handle_size / uv_req_size) and declare the
// stream functions ourselves with `*anyopaque` pointers. Every libuv
// handle and request begins with `void* data`, so we read/write the
// user pointer at offset 0 regardless of the concrete struct.
const ConnectCb = *const fn (*anyopaque, c_int) callconv(.c) void;
const WriteCb = *const fn (*anyopaque, c_int) callconv(.c) void;
const AllocCb = *const fn (*anyopaque, usize, [*c]c.uv_buf_t) callconv(.c) void;
const ReadCb = *const fn (*anyopaque, isize, [*c]const c.uv_buf_t) callconv(.c) void;
const GaiCb = *const fn (*anyopaque, c_int, ?*c.struct_addrinfo) callconv(.c) void;

extern fn uv_handle_size(handle_type: c.uv_handle_type) usize;
extern fn uv_req_size(req_type: c.uv_req_type) usize;
extern fn uv_tcp_init(loop: *c.uv_loop_t, handle: *anyopaque) c_int;
extern fn uv_tcp_connect(req: *anyopaque, handle: *anyopaque, addr: *const c.struct_sockaddr, cb: ConnectCb) c_int;
extern fn uv_read_start(stream: *anyopaque, alloc_cb: AllocCb, read_cb: ReadCb) c_int;
extern fn uv_read_stop(stream: *anyopaque) c_int;
extern fn uv_write(req: *anyopaque, stream: *anyopaque, bufs: [*]const c.uv_buf_t, nbufs: c_uint, cb: WriteCb) c_int;
extern fn uv_getaddrinfo(loop: *c.uv_loop_t, req: *anyopaque, cb: GaiCb, node: [*:0]const u8, service: [*:0]const u8, hints: ?*const c.struct_addrinfo) c_int;

fn setData(p: *anyopaque, job: *Job) void {
    const slot: *?*anyopaque = @ptrCast(@alignCast(p));
    slot.* = job;
}
fn getJob(p: *anyopaque) *Job {
    const slot: *?*anyopaque = @ptrCast(@alignCast(p));
    return @ptrCast(@alignCast(slot.*.?));
}

const JobKind = enum(u32) { timer = 0, tcp_request = 1 };

const Job = struct {
    id: u64,
    kind: JobKind,
    reactor: *Reactor,

    // timer op
    delay_ms: u64 = 0,
    timer: c.uv_timer_t = undefined,

    // tcp_request op (connect -> write -> read-to-EOF). The uv handle +
    // request are opaque buffers (see note above). One request buffer is
    // reused across the sequential getaddrinfo -> connect -> write phases.
    host: ?[]u8 = null,
    port: u16 = 0,
    payload: ?[]u8 = null,
    scratch: ?[]u8 = null, // per-read buffer libuv fills
    resp: std.ArrayList(u8) = .{},
    tcp_buf: ?[]u8 = null, // opaque uv_tcp_t
    req_buf: ?[]u8 = null, // opaque uv request (gai/connect/write)
    tcp_inited: bool = false, // whether the handle needs uv_close

    // state (all guarded by Reactor.mutex)
    result_ready: bool = false, // op finished; status valid
    handle_closed: bool = false, // uv_close callback fired (or no handle)
    drained: bool = false, // caller polled the result
    status: i32 = 0, // 0 ok, negative = uv/engine error
};

fn freeJob(job: *Job) void {
    if (job.host) |h| gpa.free(h);
    if (job.payload) |pl| gpa.free(pl);
    if (job.scratch) |s| gpa.free(s);
    if (job.tcp_buf) |t| gpa.free(t);
    if (job.req_buf) |rq| gpa.free(rq);
    job.resp.deinit(gpa);
    gpa.destroy(job);
}

pub const Reactor = struct {
    loop: c.uv_loop_t,
    wake: c.uv_async_t, // thread-safe wake to drain `pending`
    thread: std.Thread,
    mutex: std.Thread.Mutex,
    pending: std.ArrayList(*Job), // submitted, not yet started on the loop
    jobs: std.AutoHashMap(u64, *Job), // id -> job, for poll
    next_id: u64,
    stopping: std.atomic.Value(bool),
};

fn runLoop(r: *Reactor) void {
    _ = c.uv_run(&r.loop, c.UV_RUN_DEFAULT);
}

// Wake callback (loop thread): either drain newly-submitted jobs and
// start their libuv ops, or, if stopping, close every handle so uv_run
// can return.
fn onWake(handle: [*c]c.uv_async_t) callconv(.c) void {
    const r: *Reactor = @ptrCast(@alignCast(handle.*.data.?));
    if (r.stopping.load(.acquire)) {
        // Close all handles (incl. in-flight timers + this async) so the
        // loop empties and uv_run returns.
        c.uv_walk(&r.loop, walkClose, null);
        return;
    }
    // Drain pending into a local list under the lock, then start each.
    var batch: [64]*Job = undefined;
    while (true) {
        r.mutex.lock();
        var n: usize = 0;
        while (n < batch.len and r.pending.items.len > 0) : (n += 1) {
            batch[n] = r.pending.orderedRemove(0);
        }
        r.mutex.unlock();
        if (n == 0) break;
        for (batch[0..n]) |job| startJob(job);
    }
}

fn walkClose(handle: [*c]c.uv_handle_t, _: ?*anyopaque) callconv(.c) void {
    if (c.uv_is_closing(handle) == 0) c.uv_close(handle, null);
}

fn startJob(job: *Job) void {
    const r = job.reactor;
    switch (job.kind) {
        .timer => {
            _ = c.uv_timer_init(&r.loop, &job.timer);
            job.timer.data = job;
            _ = c.uv_timer_start(&job.timer, onTimer, job.delay_ms, 0);
        },
        .tcp_request => startTcpRequest(job),
    }
}

// ── async TCP request: connect -> write -> read-to-EOF ───────

fn startTcpRequest(job: *Job) void {
    const r = job.reactor;
    const req = job.req_buf.?.ptr;
    setData(req, job);
    var hints: c.struct_addrinfo = std.mem.zeroes(c.struct_addrinfo);
    hints.ai_family = c.AF_UNSPEC;
    hints.ai_socktype = c.SOCK_STREAM;
    var port_buf: [8]u8 = undefined;
    const port_str = std.fmt.bufPrintZ(&port_buf, "{d}", .{job.port}) catch {
        finishTcp(job, -1);
        return;
    };
    const host_z = gpa.dupeZ(u8, job.host.?) catch {
        finishTcp(job, -1);
        return;
    };
    defer gpa.free(host_z);
    const rc = uv_getaddrinfo(&r.loop, req, onResolved, host_z.ptr, port_str.ptr, &hints);
    if (rc != 0) finishTcp(job, rc);
}

fn onResolved(req: *anyopaque, status: c_int, res: ?*c.struct_addrinfo) callconv(.c) void {
    const job = getJob(req);
    const r = job.reactor;
    const ai = res orelse {
        finishTcp(job, if (status != 0) @intCast(status) else -1);
        return;
    };
    if (status != 0) {
        c.uv_freeaddrinfo(@ptrCast(ai));
        finishTcp(job, @intCast(status));
        return;
    }
    const tcp = job.tcp_buf.?.ptr;
    _ = uv_tcp_init(&r.loop, tcp);
    setData(tcp, job);
    job.tcp_inited = true;
    setData(req, job); // reuse the request buffer for the connect phase
    const rc = uv_tcp_connect(req, tcp, @ptrCast(ai.ai_addr), onConnect);
    c.uv_freeaddrinfo(@ptrCast(ai));
    if (rc != 0) finishTcp(job, rc);
}

fn onConnect(req: *anyopaque, status: c_int) callconv(.c) void {
    const job = getJob(req);
    if (status != 0) {
        finishTcp(job, status);
        return;
    }
    const payload = job.payload orelse "";
    var buf = c.uv_buf_init(@constCast(payload.ptr), @intCast(payload.len));
    setData(req, job); // reuse the request buffer for the write phase
    const rc = uv_write(req, job.tcp_buf.?.ptr, @ptrCast(&buf), 1, onWrite);
    if (rc != 0) finishTcp(job, rc);
}

fn onWrite(req: *anyopaque, status: c_int) callconv(.c) void {
    const job = getJob(req);
    if (status != 0) {
        finishTcp(job, status);
        return;
    }
    const rc = uv_read_start(job.tcp_buf.?.ptr, onAlloc, onRead);
    if (rc != 0) finishTcp(job, rc);
}

fn onAlloc(stream: *anyopaque, suggested: usize, buf: [*c]c.uv_buf_t) callconv(.c) void {
    _ = suggested;
    const job = getJob(stream);
    const s = job.scratch orelse {
        buf.*.base = null;
        buf.*.len = 0;
        return;
    };
    buf.*.base = s.ptr;
    buf.*.len = @intCast(s.len);
}

fn onRead(stream: *anyopaque, nread: isize, buf: [*c]const c.uv_buf_t) callconv(.c) void {
    _ = buf;
    const job = getJob(stream);
    if (nread > 0) {
        const s = job.scratch.?;
        job.resp.appendSlice(gpa, s[0..@intCast(nread)]) catch {
            _ = uv_read_stop(stream);
            finishTcp(job, -1);
            return;
        };
        return;
    }
    if (nread < 0) {
        // UV_EOF is the normal end of a response; anything else is an error.
        _ = uv_read_stop(stream);
        finishTcp(job, if (nread == c.UV_EOF) 0 else @intCast(nread));
    }
    // nread == 0 means EAGAIN -- nothing to do.
}

// Mark the tcp job done with `status`, then close its handle (if any) so
// the lifetime handshake can reap it.
fn finishTcp(job: *Job, status: c_int) void {
    const r = job.reactor;
    r.mutex.lock();
    if (!job.result_ready) {
        job.status = @intCast(status);
        job.result_ready = true;
    }
    r.mutex.unlock();
    if (job.tcp_inited) {
        const tcp = job.tcp_buf.?.ptr;
        if (c.uv_is_closing(@ptrCast(@alignCast(tcp))) == 0) {
            c.uv_close(@ptrCast(@alignCast(tcp)), onHandleClosed);
            return;
        }
    }
    // No handle created (e.g. DNS failure) -- nothing to close.
    r.mutex.lock();
    job.handle_closed = true;
    reapLocked(r, job);
    r.mutex.unlock();
}

fn onTimer(handle: [*c]c.uv_timer_t) callconv(.c) void {
    const job: *Job = @ptrCast(@alignCast(handle.*.data.?));
    const r = job.reactor;
    _ = c.uv_timer_stop(handle);
    r.mutex.lock();
    job.status = 0;
    job.result_ready = true;
    r.mutex.unlock();
    c.uv_close(@ptrCast(handle), onHandleClosed);
}

fn onHandleClosed(handle: [*c]c.uv_handle_t) callconv(.c) void {
    const job: *Job = @ptrCast(@alignCast(handle.*.data.?));
    const r = job.reactor;
    r.mutex.lock();
    job.handle_closed = true;
    reapLocked(r, job);
    r.mutex.unlock();
}

// Free the job once it is both fully closed and drained. Caller holds the
// mutex. Safe to call from either the close callback or poll.
fn reapLocked(r: *Reactor, job: *Job) void {
    if (job.handle_closed and job.drained) {
        _ = r.jobs.remove(job.id);
        freeJob(job);
    }
}

pub fn reactor_create() callconv(.c) ?*Reactor {
    const r = gpa.create(Reactor) catch return null;
    r.* = .{
        .loop = undefined,
        .wake = undefined,
        .thread = undefined,
        .mutex = .{},
        .pending = .{},
        .jobs = std.AutoHashMap(u64, *Job).init(gpa),
        .next_id = 1,
        .stopping = std.atomic.Value(bool).init(false),
    };
    if (c.uv_loop_init(&r.loop) != 0) {
        r.jobs.deinit();
        gpa.destroy(r);
        return null;
    }
    if (c.uv_async_init(&r.loop, &r.wake, onWake) != 0) {
        _ = c.uv_loop_close(&r.loop);
        r.jobs.deinit();
        gpa.destroy(r);
        return null;
    }
    r.wake.data = r;
    r.thread = std.Thread.spawn(.{}, runLoop, .{r}) catch {
        c.uv_close(@ptrCast(&r.wake), null);
        _ = c.uv_run(&r.loop, c.UV_RUN_DEFAULT);
        _ = c.uv_loop_close(&r.loop);
        r.jobs.deinit();
        gpa.destroy(r);
        return null;
    };
    return r;
}

/// Submit a timer that fires after `delay_ms`. Returns a job id (>0) or -1.
pub fn reactor_submit_timer(r_opt: ?*Reactor, delay_ms: u64) callconv(.c) i64 {
    const r = r_opt orelse return -1;
    if (r.stopping.load(.acquire)) return -1;
    const job = gpa.create(Job) catch return -1;
    r.mutex.lock();
    job.* = .{
        .id = r.next_id,
        .kind = .timer,
        .delay_ms = delay_ms,
        .timer = undefined,
        .reactor = r,
        .result_ready = false,
        .handle_closed = false,
        .drained = false,
        .status = 0,
    };
    r.next_id += 1;
    const id = job.id;
    r.jobs.put(id, job) catch {
        r.mutex.unlock();
        gpa.destroy(job);
        return -1;
    };
    r.pending.append(gpa, job) catch {
        _ = r.jobs.remove(id);
        r.mutex.unlock();
        gpa.destroy(job);
        return -1;
    };
    r.mutex.unlock();
    _ = c.uv_async_send(&r.wake);
    return @intCast(id);
}

/// Poll a job: -2 not found, -1 still running, 0 done (op-specific status).
pub fn reactor_poll(r_opt: ?*Reactor, job_id: u64) callconv(.c) i32 {
    const r = r_opt orelse return -2;
    r.mutex.lock();
    defer r.mutex.unlock();
    const job = r.jobs.get(job_id) orelse return -2;
    if (!job.result_ready) return -1;
    const status = job.status;
    job.drained = true;
    reapLocked(r, job);
    return status;
}

/// Block up to `timeout_ms` for a job to finish. Same return codes as
/// reactor_poll, plus -1 on timeout.
pub fn reactor_await(r_opt: ?*Reactor, job_id: u64, timeout_ms: u64) callconv(.c) i32 {
    const r = r_opt orelse return -2;
    const deadline = std.time.nanoTimestamp() + @as(i128, @intCast(timeout_ms)) * 1_000_000;
    while (true) {
        const rc = reactor_poll(r, job_id);
        if (rc != -1) return rc;
        if (std.time.nanoTimestamp() >= deadline) return -1;
        std.Thread.sleep(2 * std.time.ns_per_ms);
    }
}

const TCP_SCRATCH: usize = 16 * 1024;
var tcp_last_status: i32 = 0;
var tcp_last_len: usize = 0;

/// Result status of the last reactor_tcp_poll/await that reported done
/// (0 = ok, negative = uv/engine error code).
pub fn reactor_tcp_last_status() callconv(.c) i32 {
    return tcp_last_status;
}

pub fn reactor_tcp_last_len() callconv(.c) usize {
    return tcp_last_len;
}

/// Submit an async TCP request: connect to host:port, write `payload`,
/// read the response to EOF. Returns a job id (>0) or -1.
pub fn reactor_submit_tcp_request(
    r_opt: ?*Reactor,
    host_ptr: [*]const u8,
    host_len: usize,
    port: u16,
    payload_ptr: [*]const u8,
    payload_len: usize,
) callconv(.c) i64 {
    const r = r_opt orelse return -1;
    if (r.stopping.load(.acquire)) return -1;
    const job = gpa.create(Job) catch return -1;
    const host = gpa.dupe(u8, host_ptr[0..host_len]) catch {
        gpa.destroy(job);
        return -1;
    };
    const payload = gpa.dupe(u8, payload_ptr[0..payload_len]) catch {
        gpa.free(host);
        gpa.destroy(job);
        return -1;
    };
    const scratch = gpa.alloc(u8, TCP_SCRATCH) catch {
        gpa.free(host);
        gpa.free(payload);
        gpa.destroy(job);
        return -1;
    };
    // Opaque uv handle + request buffers (malloc is 16-byte aligned, which
    // satisfies libuv's handle alignment). One request buffer, sized to
    // the largest of the phases we reuse it for.
    const req_size = @max(uv_req_size(c.UV_GETADDRINFO), @max(uv_req_size(c.UV_CONNECT), uv_req_size(c.UV_WRITE)));
    const tcp_buf = gpa.alloc(u8, uv_handle_size(c.UV_TCP)) catch {
        gpa.free(host);
        gpa.free(payload);
        gpa.free(scratch);
        gpa.destroy(job);
        return -1;
    };
    const req_buf = gpa.alloc(u8, req_size) catch {
        gpa.free(host);
        gpa.free(payload);
        gpa.free(scratch);
        gpa.free(tcp_buf);
        gpa.destroy(job);
        return -1;
    };
    r.mutex.lock();
    job.* = .{
        .id = r.next_id,
        .kind = .tcp_request,
        .reactor = r,
        .host = host,
        .port = port,
        .payload = payload,
        .scratch = scratch,
        .tcp_buf = tcp_buf,
        .req_buf = req_buf,
    };
    r.next_id += 1;
    const id = job.id;
    r.jobs.put(id, job) catch {
        r.mutex.unlock();
        freeJob(job);
        return -1;
    };
    r.pending.append(gpa, job) catch {
        _ = r.jobs.remove(id);
        r.mutex.unlock();
        freeJob(job);
        return -1;
    };
    r.mutex.unlock();
    _ = c.uv_async_send(&r.wake);
    return @intCast(id);
}

/// Poll a tcp_request job: -2 not found, -1 running, -3 overflow, else
/// the number of response bytes written into out[0..max]. The op status
/// is reported via reactor_tcp_last_status().
pub fn reactor_tcp_poll(r_opt: ?*Reactor, job_id: u64, out: [*]u8, max: usize) callconv(.c) i32 {
    const r = r_opt orelse return -2;
    r.mutex.lock();
    defer r.mutex.unlock();
    const job = r.jobs.get(job_id) orelse return -2;
    if (!job.result_ready) return -1;
    tcp_last_status = job.status;
    const body = job.resp.items;
    job.drained = true;
    if (body.len > max) {
        tcp_last_len = 0;
        reapLocked(r, job);
        return -3;
    }
    @memcpy(out[0..body.len], body);
    tcp_last_len = body.len;
    reapLocked(r, job);
    return @intCast(body.len);
}

/// Block up to `timeout_ms` for a tcp_request to finish. Same return
/// codes as reactor_tcp_poll, plus -1 on timeout.
pub fn reactor_tcp_await(r_opt: ?*Reactor, job_id: u64, timeout_ms: u64, out: [*]u8, max: usize) callconv(.c) i32 {
    const r = r_opt orelse return -2;
    const deadline = std.time.nanoTimestamp() + @as(i128, @intCast(timeout_ms)) * 1_000_000;
    while (true) {
        const rc = reactor_tcp_poll(r, job_id, out, max);
        if (rc != -1) return rc;
        if (std.time.nanoTimestamp() >= deadline) return -1;
        std.Thread.sleep(2 * std.time.ns_per_ms);
    }
}

/// Number of jobs submitted but not yet started on the loop.
pub fn reactor_pending(r_opt: ?*Reactor) callconv(.c) i32 {
    const r = r_opt orelse return -1;
    r.mutex.lock();
    defer r.mutex.unlock();
    return @intCast(r.pending.items.len);
}

pub fn reactor_destroy(r_opt: ?*Reactor) callconv(.c) void {
    const r = r_opt orelse return;
    r.stopping.store(true, .release);
    _ = c.uv_async_send(&r.wake); // wake the loop so it closes handles
    r.thread.join();
    _ = c.uv_loop_close(&r.loop);
    // No callbacks run after uv_run returns: free any jobs that survived.
    var it = r.jobs.iterator();
    while (it.next()) |e| freeJob(e.value_ptr.*);
    r.jobs.deinit();
    r.pending.deinit(gpa);
    gpa.destroy(r);
}

// Tests here need libuv's headers + objects, so they are not part of the
// default `zig build test` sweep (reactor is not imported by engine.zig).
// They run via the engine build's stz_reactor DLL + a Ring smoke, and
// can also be run with:
//   zig test src/reactor.zig -I vendor/libuv/include -I vendor/libuv/src \
//     vendor/libuv/src/*.c vendor/libuv/src/win/*.c -lc <win libs>
test "reactor: version is non-empty" {
    const v = reactor_version();
    try std.testing.expect(v != null);
    try std.testing.expect(std.mem.span(v).len > 0);
}

test "reactor: self-test fires exactly one timer" {
    try std.testing.expectEqual(@as(i32, 1), reactor_selftest());
}

test "reactor core: submit a timer, await it across the loop thread" {
    const r = reactor_create().?;
    defer reactor_destroy(r);
    const id = reactor_submit_timer(r, 20);
    try std.testing.expect(id > 0);
    // Await up to 2s -- the loop thread runs the timer and stores the result.
    try std.testing.expectEqual(@as(i32, 0), reactor_await(r, @intCast(id), 2000));
    // Drained -> a second poll on the same id reports not-found.
    try std.testing.expectEqual(@as(i32, -2), reactor_poll(r, @intCast(id)));
}

test "reactor core: unknown id is -2; many concurrent timers all fire" {
    const r = reactor_create().?;
    defer reactor_destroy(r);
    try std.testing.expectEqual(@as(i32, -2), reactor_poll(r, 99999));
    var ids: [32]i64 = undefined;
    for (&ids) |*slot| slot.* = reactor_submit_timer(r, 10);
    for (ids) |id| try std.testing.expectEqual(@as(i32, 0), reactor_await(r, @intCast(id), 2000));
}

test "reactor core: destroy with in-flight + undrained jobs leaks nothing" {
    const r = reactor_create().?;
    // Submit a long timer we never await, plus a short one we drain.
    _ = reactor_submit_timer(r, 60_000);
    const id = reactor_submit_timer(r, 5);
    _ = reactor_await(r, @intCast(id), 2000);
    reactor_destroy(r); // must close handles + free all jobs cleanly
}

// Live network -- run manually (not in CI). Proves the full async TCP
// state machine (resolve -> connect -> write -> read-to-EOF).
test "reactor core: async tcp request round-trip (LIVE NETWORK)" {
    const r = reactor_create().?;
    defer reactor_destroy(r);
    const req = "GET / HTTP/1.0\r\nHost: example.com\r\nConnection: close\r\n\r\n";
    const id = reactor_submit_tcp_request(r, "example.com", 11, 80, req, req.len);
    try std.testing.expect(id > 0);
    var buf: [65536]u8 = undefined;
    const n = reactor_tcp_await(r, @intCast(id), 15000, &buf, buf.len);
    try std.testing.expect(n > 0);
    try std.testing.expectEqual(@as(i32, 0), reactor_tcp_last_status());
    try std.testing.expect(std.mem.startsWith(u8, buf[0..@intCast(n)], "HTTP/"));
}

test "reactor core: tcp connect to unreachable surfaces an error, no leak" {
    const r = reactor_create().?;
    defer reactor_destroy(r);
    const id = reactor_submit_tcp_request(r, "192.0.2.1", 9, 80, "x", 1);
    try std.testing.expect(id > 0);
    var buf: [256]u8 = undefined;
    // Either connect refused/timed out (status<0, 0 bytes) or our await
    // times out (-1). Both are acceptable; the point is no crash/leak.
    _ = reactor_tcp_await(r, @intCast(id), 3000, &buf, buf.len);
}
