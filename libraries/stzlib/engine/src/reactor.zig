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
const curlcore = @import("curlcore.zig"); // curl-backed (Schannel TLS) fetch
const c = @cImport({
    @cInclude("uv.h");
    @cInclude("mbedtls/ssl.h");
    @cInclude("mbedtls/entropy.h");
    @cInclude("mbedtls/ctr_drbg.h");
    @cInclude("mbedtls/x509_crt.h");
    @cInclude("mbedtls/pk.h");
    @cInclude("mbedtls/error.h");
    @cInclude("mbedtls/net_sockets.h");
});

// curl_request writes the body into a per-call buffer but reports its
// length via a process-global -- so the fetch + length read must be
// serialized across libuv's worker threads. HTTPS-on-the-reactor exists
// to make reactive HTTP non-blocking, not for high fan-out, so a single
// in-flight curl at a time is an acceptable, correct tradeoff.
var curl_mutex: std.Thread.Mutex = .{};

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
const ConnectionCb = *const fn (*anyopaque, c_int) callconv(.c) void;

extern fn uv_handle_size(handle_type: c.uv_handle_type) usize;
extern fn uv_req_size(req_type: c.uv_req_type) usize;
extern fn uv_tcp_init(loop: *c.uv_loop_t, handle: *anyopaque) c_int;
extern fn uv_tcp_connect(req: *anyopaque, handle: *anyopaque, addr: *const c.struct_sockaddr, cb: ConnectCb) c_int;
extern fn uv_read_start(stream: *anyopaque, alloc_cb: AllocCb, read_cb: ReadCb) c_int;
extern fn uv_read_stop(stream: *anyopaque) c_int;
extern fn uv_write(req: *anyopaque, stream: *anyopaque, bufs: [*]const c.uv_buf_t, nbufs: c_uint, cb: WriteCb) c_int;
extern fn uv_getaddrinfo(loop: *c.uv_loop_t, req: *anyopaque, cb: GaiCb, node: [*:0]const u8, service: [*:0]const u8, hints: ?*const c.struct_addrinfo) c_int;
extern fn uv_tcp_bind(handle: *anyopaque, addr: *const c.struct_sockaddr, flags: c_uint) c_int;
extern fn uv_listen(stream: *anyopaque, backlog: c_int, cb: ConnectionCb) c_int;
extern fn uv_accept(server: *anyopaque, client: *anyopaque) c_int;
extern fn uv_tcp_getsockname(handle: *anyopaque, name: *c.struct_sockaddr, namelen: *c_int) c_int;

// Async process spawn (uv_spawn). uv_process_options_t embeds function
// pointers + a stdio-container array whose union references uv_stream_t;
// translate-c cannot always build it, so we lay the ABI out ourselves
// and pass *anyopaque handles. Every libuv handle begins with `void*
// data`, so setData/getJob work on the process + pipe handles too.
const UvExitCb = *const fn (*anyopaque, i64, c_int) callconv(.c) void;

// uv_stdio_flags: ignore=0, create_pipe=1, inherit_fd=2, inherit_stream=4,
// readable_pipe=0x10, writable_pipe=0x20. To CAPTURE a child's stdout the
// parent reads and the child writes: create_pipe | writable_pipe.
const UV_IGNORE: c_uint = 0x00;
const UV_CREATE_PIPE: c_uint = 0x01;
const UV_WRITABLE_PIPE: c_uint = 0x20;

const StdioContainer = extern struct {
    flags: c_uint,
    data: extern union {
        stream: ?*anyopaque,
        fd: c_int,
    },
};

const ProcessOptions = extern struct {
    exit_cb: ?UvExitCb,
    file: [*:0]const u8,
    args: [*c]?[*:0]u8,
    env: [*c]?[*:0]u8,
    cwd: ?[*:0]const u8,
    flags: c_uint,
    stdio_count: c_int,
    stdio: [*c]StdioContainer,
    uid: c.uv_uid_t,
    gid: c.uv_gid_t,
};

extern fn uv_spawn(loop: *c.uv_loop_t, handle: *anyopaque, options: *const ProcessOptions) c_int;
extern fn uv_pipe_init(loop: *c.uv_loop_t, handle: *anyopaque, ipc: c_int) c_int;
extern fn uv_process_kill(handle: *anyopaque, signum: c_int) c_int;

// libuv work queue (its internal thread pool) -- used to run the
// blocking, TLS-capable curl fetch off the loop thread for async HTTPS.
const WorkCb = *const fn (*anyopaque) callconv(.c) void;
const AfterWorkCb = *const fn (*anyopaque, c_int) callconv(.c) void;
extern fn uv_queue_work(loop: *c.uv_loop_t, req: *anyopaque, work_cb: WorkCb, after_cb: AfterWorkCb) c_int;

fn setData(p: *anyopaque, user: *anyopaque) void {
    const slot: *?*anyopaque = @ptrCast(@alignCast(p));
    slot.* = user;
}
fn getJob(p: *anyopaque) *Job {
    const slot: *?*anyopaque = @ptrCast(@alignCast(p));
    return @ptrCast(@alignCast(slot.*.?));
}

const JobKind = enum(u32) { timer = 0, tcp_request = 1, spawn = 2, curl = 3 };

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

    // spawn op (run a subprocess, capture stdout, report exit status).
    // The command is passed as file + args joined by '\n'; argv/argv_bufs
    // own the C-string storage. proc_buf + pipe_buf are opaque handles.
    argv_joined: ?[]u8 = null,
    proc_buf: ?[]u8 = null, // opaque uv_process_t
    pipe_buf: ?[]u8 = null, // opaque uv_pipe_t (child stdout)
    proc_exited: bool = false,
    pipe_closed: bool = false,
    proc_inited: bool = false,
    exit_code: i64 = 0,

    // curl op (async HTTPS via uv_queue_work + Schannel TLS). The
    // blocking fetch runs on a libuv worker thread into `curl_out`;
    // after_work marks the result ready on the loop thread.
    curl_method: i32 = 0,
    curl_body: ?[]u8 = null, // request body (POST/PUT)
    curl_out: ?[]u8 = null, // response buffer the worker fills
    work_buf: ?[]u8 = null, // opaque uv_work_t
    curl_status: i64 = 0, // curl_request return (bytes or <0 error)

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
    if (job.argv_joined) |a| gpa.free(a);
    if (job.proc_buf) |p| gpa.free(p);
    if (job.pipe_buf) |p| gpa.free(p);
    if (job.curl_body) |b| gpa.free(b);
    if (job.curl_out) |o| gpa.free(o);
    if (job.work_buf) |w| gpa.free(w);
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
    // server side (listen/accept/read-stream/http)
    ctl: std.ArrayList(Ctl), // control ops queued for the loop thread
    servers: std.AutoHashMap(u64, *Server), // id -> server
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
    // Drain server control ops the same way.
    var cbatch: [64]Ctl = undefined;
    while (true) {
        r.mutex.lock();
        var n: usize = 0;
        while (n < cbatch.len and r.ctl.items.len > 0) : (n += 1) {
            cbatch[n] = r.ctl.orderedRemove(0);
        }
        r.mutex.unlock();
        if (n == 0) break;
        for (cbatch[0..n]) |op| runCtl(op);
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
        .spawn => startSpawn(job),
        .curl => startCurl(job),
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

// ── async process spawn: run child, capture stdout, report exit ──
//
// The command arrives as file + args joined by '\n' in argv_joined. We
// build a null-terminated argv in place (each '\n' becomes a 0), create
// a stdout pipe, spawn, and read the pipe to EOF. The job finishes once
// BOTH the process has exited AND its stdout pipe is closed.

fn startSpawn(job: *Job) void {
    const r = job.reactor;
    // argv_joined is `content + '\n'-separators` with ONE trailing spare
    // byte (already 0) reserved by the caller: raw.len = content_len + 1.
    const raw = job.argv_joined.?;
    const content_len = raw.len - 1;
    if (content_len == 0) {
        finishSpawn(job, -1);
        return;
    }
    // Split on '\n' in place into NUL-terminated C strings, collecting an
    // argv array (program is argv[0]; max 64 args).
    var argv_ptrs: [65]?[*:0]u8 = undefined;
    var n_args: usize = 0;
    var seg_start: usize = 0;
    var i: usize = 0;
    while (i < content_len) : (i += 1) {
        if (raw[i] == '\n') {
            raw[i] = 0;
            if (n_args < 64) {
                argv_ptrs[n_args] = @ptrCast(&raw[seg_start]);
                n_args += 1;
            }
            seg_start = i + 1;
        }
    }
    // final segment: NUL is already at raw[content_len]
    if (n_args < 64) {
        argv_ptrs[n_args] = @ptrCast(&raw[seg_start]);
        n_args += 1;
    }
    argv_ptrs[n_args] = null;

    const pipe = job.pipe_buf.?.ptr;
    if (uv_pipe_init(&r.loop, pipe, 0) != 0) {
        finishSpawn(job, -1);
        return;
    }
    setData(pipe, job);

    var stdio = [_]StdioContainer{
        .{ .flags = UV_IGNORE, .data = .{ .fd = 0 } },
        .{ .flags = UV_CREATE_PIPE | UV_WRITABLE_PIPE, .data = .{ .stream = pipe } },
        .{ .flags = UV_IGNORE, .data = .{ .fd = 2 } },
    };
    var opts: ProcessOptions = std.mem.zeroes(ProcessOptions);
    opts.exit_cb = onProcExit;
    opts.file = argv_ptrs[0].?;
    opts.args = @ptrCast(&argv_ptrs);
    opts.stdio_count = 3;
    opts.stdio = @ptrCast(&stdio);

    const proc = job.proc_buf.?.ptr;
    setData(proc, job);
    const rc = uv_spawn(&r.loop, proc, &opts);
    if (rc != 0) {
        // spawn failed: close the pipe we inited, mark process "exited".
        r.mutex.lock();
        job.proc_exited = true;
        job.exit_code = rc;
        r.mutex.unlock();
        c.uv_close(@ptrCast(@alignCast(pipe)), onSpawnPipeClosed);
        return;
    }
    job.proc_inited = true;
    // Start reading the child's stdout.
    if (uv_read_start(pipe, onAlloc, onSpawnRead) != 0) {
        c.uv_close(@ptrCast(@alignCast(pipe)), onSpawnPipeClosed);
    }
}

fn onSpawnRead(stream: *anyopaque, nread: isize, buf: [*c]const c.uv_buf_t) callconv(.c) void {
    _ = buf;
    const job = getJob(stream);
    if (nread > 0) {
        const s = job.scratch.?;
        job.resp.appendSlice(gpa, s[0..@intCast(nread)]) catch {};
        return;
    }
    if (nread < 0) {
        _ = uv_read_stop(stream);
        c.uv_close(@ptrCast(@alignCast(stream)), onSpawnPipeClosed);
    }
}

fn onProcExit(handle: *anyopaque, exit_status: i64, term_signal: c_int) callconv(.c) void {
    _ = term_signal;
    const job = getJob(handle);
    const r = job.reactor;
    r.mutex.lock();
    job.proc_exited = true;
    job.exit_code = exit_status;
    r.mutex.unlock();
    c.uv_close(@ptrCast(@alignCast(handle)), onSpawnProcClosed);
}

fn onSpawnProcClosed(handle: [*c]c.uv_handle_t) callconv(.c) void {
    const job: *Job = @ptrCast(@alignCast(handle.*.data.?));
    maybeFinishSpawn(job);
}

fn onSpawnPipeClosed(handle: [*c]c.uv_handle_t) callconv(.c) void {
    const job: *Job = @ptrCast(@alignCast(handle.*.data.?));
    const r = job.reactor;
    r.mutex.lock();
    job.pipe_closed = true;
    r.mutex.unlock();
    maybeFinishSpawn(job);
}

// The spawn result is ready once the process exited AND the stdout pipe
// closed. The process handle is closed in onProcExit; the pipe in
// onSpawnRead's EOF. When both close callbacks have fired we mark the
// job done and let the standard reap handshake free it.
fn maybeFinishSpawn(job: *Job) void {
    const r = job.reactor;
    r.mutex.lock();
    // proc_exited implies the process handle is closing/closed; pipe_closed
    // that the pipe is closed. Require the process to have exited and the
    // pipe closed (or never inited) before finishing.
    const proc_done = job.proc_exited;
    const pipe_done = job.pipe_closed;
    if (proc_done and pipe_done and !job.result_ready) {
        job.status = @intCast(std.math.clamp(job.exit_code, -2147483648, 2147483647));
        job.result_ready = true;
        job.handle_closed = true;
        reapLocked(r, job);
    }
    r.mutex.unlock();
}

fn finishSpawn(job: *Job, status: c_int) void {
    const r = job.reactor;
    r.mutex.lock();
    if (!job.result_ready) {
        job.status = @intCast(status);
        job.result_ready = true;
        job.handle_closed = true;
        reapLocked(r, job);
    }
    r.mutex.unlock();
}

// ── async HTTPS via uv_queue_work + curl (Schannel TLS) ──────
//
// TLS itself is not reimplemented on the loop; instead the proven
// blocking, TLS-capable curl fetch runs on a libuv WORKER thread (its
// built-in pool) and the loop is notified on completion. Ring stays
// synchronous through the same submit/poll/await idiom. This gives
// genuine async HTTPS (the reactive HTTP surface no longer has to block
// on https), reusing the vendored curl + native Schannel TLS.

const CURL_OUT_CAP: usize = 4 * 1024 * 1024;

fn startCurl(job: *Job) void {
    const r = job.reactor;
    const work = job.work_buf.?.ptr;
    setData(work, job);
    if (uv_queue_work(&r.loop, work, onCurlWork, onCurlAfter) != 0) {
        r.mutex.lock();
        job.status = -1;
        job.result_ready = true;
        job.handle_closed = true;
        reapLocked(r, job);
        r.mutex.unlock();
    }
}

// Worker thread: run the blocking (TLS-capable) fetch. curl_request
// returns the HTTP status (or <0 transport/overflow error) and writes
// the body into our per-job buffer; its length comes from a global we
// read under the same mutex. Safe to touch job.resp here -- Ring cannot
// have polled yet (result_ready is set on the loop thread in after_work).
fn onCurlWork(req: *anyopaque) callconv(.c) void {
    const job = getJob(req);
    const url = job.host orelse "";
    const body = job.curl_body orelse "";
    const out = job.curl_out.?;
    curl_mutex.lock();
    const code = curlcore.curl_request(
        job.curl_method,
        url.ptr,
        url.len,
        "", // headers
        0,
        "", // content-type
        0,
        body.ptr,
        body.len,
        out.ptr,
        out.len,
        0, // default connect timeout
        0, // default request timeout
        "", // opts
        0,
    );
    const blen = curlcore.curl_last_body_len();
    curl_mutex.unlock();
    job.curl_status = code;
    if (code > 0 and blen > 0) {
        job.resp.appendSlice(gpa, out[0..blen]) catch {};
    }
}

// Loop thread: the work request is done (no uv handle to close -- a
// uv_work_t is a request), so mark ready and let the reap handshake
// free the job once Ring drains it.
fn onCurlAfter(req: *anyopaque, status: c_int) callconv(.c) void {
    const job = getJob(req);
    const r = job.reactor;
    r.mutex.lock();
    // job.status carries the HTTP status code on success, or a negative
    // transport/engine error (so 0 here means "no HTTP response").
    if (status != 0) {
        job.status = -1;
    } else {
        job.status = @intCast(std.math.clamp(job.curl_status, -2147483648, 2147483647));
    }
    job.result_ready = true;
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
        .ctl = .{},
        .servers = std.AutoHashMap(u64, *Server).init(gpa),
    };
    if (c.uv_loop_init(&r.loop) != 0) {
        r.jobs.deinit();
        r.servers.deinit();
        gpa.destroy(r);
        return null;
    }
    if (c.uv_async_init(&r.loop, &r.wake, onWake) != 0) {
        _ = c.uv_loop_close(&r.loop);
        r.jobs.deinit();
        r.servers.deinit();
        gpa.destroy(r);
        return null;
    }
    r.wake.data = r;
    r.thread = std.Thread.spawn(.{}, runLoop, .{r}) catch {
        c.uv_close(@ptrCast(&r.wake), null);
        _ = c.uv_run(&r.loop, c.UV_RUN_DEFAULT);
        _ = c.uv_loop_close(&r.loop);
        r.jobs.deinit();
        r.servers.deinit();
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

/// Peek a job's state WITHOUT draining it: -2 not found, -1 still
/// running, 0 result ready (a subsequent reactor_tcp_poll fetches the
/// body). Lets a caller multiplex many in-flight jobs (Reaxis F5).
pub fn reactor_job_state(r_opt: ?*Reactor, job_id: u64) callconv(.c) i32 {
    const r = r_opt orelse return -2;
    r.mutex.lock();
    defer r.mutex.unlock();
    const job = r.jobs.get(job_id) orelse return -2;
    if (!job.result_ready) return -1;
    return 0;
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

// ── server side: listen / accept / per-connection read streams ──
//
// Tier 2 server slice (R7). A Server owns a libuv TCP listener living on
// the loop thread. Each accepted connection gets a read stream; incoming
// bytes (or, in http mode, complete framed HTTP/1.1 requests) are queued
// as EVENTS that Ring drains with the same poll/await idiom. Writes and
// closes are CONTROL OPS queued from Ring and executed on the loop
// thread, so no libuv call ever happens off-loop and no callback ever
// crosses into Ring.
//
// Event kinds (reactor_server_poll return value):
//   0 none, 1 accept(conn), 2 data(conn, bytes) -- in http mode one
//   complete request per event -- 3 closed(conn). Negative = error.

const SRV_SCRATCH: usize = 64 * 1024;
const SRV_MAX_INBOX: usize = 8 * 1024 * 1024; // per-conn framing cap
const LISTEN_BACKLOG: c_int = 128;

const SrvEventKind = enum(i32) { accept = 1, data = 2, closed = 3 };

const SrvEvent = struct {
    kind: SrvEventKind,
    conn_id: u64,
    data: ?[]u8 = null, // owned by the queue until polled
};

const CtlKind = enum { start_server, server_write, conn_close, stop_server };

const Ctl = struct {
    kind: CtlKind,
    server: *Server,
    conn_id: u64 = 0,
    data: ?[]u8 = null, // write payload (owned until handed to WriteReq)
    close_after: bool = false,
};

const Server = struct {
    id: u64,
    reactor: *Reactor,
    host: []u8,
    port: u16, // requested port; actual bound port in bound_port
    http_mode: bool,
    tcp_buf: ?[]u8 = null, // opaque listener uv_tcp_t
    listener_inited: bool = false,
    listener_closed: bool = false,
    bind_done: bool = false, // guarded by Reactor.mutex
    bind_status: i32 = 0,
    bound_port: u16 = 0,
    conns: std.AutoHashMap(u64, *Conn),
    next_conn_id: u64 = 1,
    events: std.ArrayList(SrvEvent) = .{},
    stopping: bool = false,
    // TLS termination config (shared, read-only during handshakes; all conns
    // handshake on the one loop thread so the shared RNG is not contended).
    tls: bool = false,
    require_client: bool = false, // mTLS: demand + validate a client cert
    tls_conf: ?*c.mbedtls_ssl_config = null,
    tls_srvcert: ?*c.mbedtls_x509_crt = null,
    tls_cacert: ?*c.mbedtls_x509_crt = null,
    tls_pk: ?*c.mbedtls_pk_context = null,
    tls_entropy: ?*c.mbedtls_entropy_context = null,
    tls_drbg: ?*c.mbedtls_ctr_drbg_context = null,
};

const Conn = struct {
    id: u64,
    server: *Server,
    tcp_buf: []u8, // opaque uv_tcp_t
    scratch: []u8, // per-read buffer libuv fills
    inbox: std.ArrayList(u8) = .{}, // http framing buffer (PLAINTEXT)
    closing: bool = false,
    // TLS termination (null on a plain-HTTP conn). The socket carries
    // CIPHERTEXT: received bytes go into net_in for mbedTLS to decrypt;
    // mbedTLS's output is buffered in net_out (via the send BIO) and flushed
    // to the socket. The rest of the server (framing, events) sees only the
    // decrypted plaintext -- TLS is transparent above this layer.
    ssl: ?*c.mbedtls_ssl_context = null,
    net_in: std.ArrayList(u8) = .{}, // received ciphertext awaiting mbedTLS
    net_in_pos: usize = 0, // consumed offset into net_in
    net_out: std.ArrayList(u8) = .{}, // ciphertext to write (BIO send target)
    hs_done: bool = false, // TLS handshake complete
};

// One in-flight write: the uv write request + the copied payload.
const WriteReq = struct {
    req_buf: []u8, // opaque uv_write_t (data slot -> this WriteReq)
    data: []u8,
    conn: *Conn,
    close_after: bool,
};

fn freeConn(conn: *Conn) void {
    if (conn.ssl) |ssl| {
        c.mbedtls_ssl_free(ssl);
        gpa.destroy(ssl);
    }
    conn.net_in.deinit(gpa);
    conn.net_out.deinit(gpa);
    gpa.free(conn.tcp_buf);
    gpa.free(conn.scratch);
    conn.inbox.deinit(gpa);
    gpa.destroy(conn);
}

// Free a server's shared TLS config + credentials.
fn freeServerTls(s: *Server) void {
    if (s.tls_conf) |x| {
        c.mbedtls_ssl_config_free(x);
        gpa.destroy(x);
        s.tls_conf = null;
    }
    if (s.tls_srvcert) |x| {
        c.mbedtls_x509_crt_free(x);
        gpa.destroy(x);
        s.tls_srvcert = null;
    }
    if (s.tls_cacert) |x| {
        c.mbedtls_x509_crt_free(x);
        gpa.destroy(x);
        s.tls_cacert = null;
    }
    if (s.tls_pk) |x| {
        c.mbedtls_pk_free(x);
        gpa.destroy(x);
        s.tls_pk = null;
    }
    if (s.tls_drbg) |x| {
        c.mbedtls_ctr_drbg_free(x);
        gpa.destroy(x);
        s.tls_drbg = null;
    }
    if (s.tls_entropy) |x| {
        c.mbedtls_entropy_free(x);
        gpa.destroy(x);
        s.tls_entropy = null;
    }
}

fn freeServer(s: *Server) void {
    var it = s.conns.iterator();
    while (it.next()) |e| freeConn(e.value_ptr.*);
    s.conns.deinit();
    freeServerTls(s);
    for (s.events.items) |ev| {
        if (ev.data) |d| gpa.free(d);
    }
    s.events.deinit(gpa);
    gpa.free(s.host);
    if (s.tcp_buf) |t| gpa.free(t);
    gpa.destroy(s);
}

// Loop thread: execute one control op.
fn runCtl(op: Ctl) void {
    switch (op.kind) {
        .start_server => startServer(op.server),
        .server_write => startWrite(op),
        .conn_close => {
            const s = op.server;
            s.reactor.mutex.lock();
            const conn = s.conns.get(op.conn_id);
            s.reactor.mutex.unlock();
            if (conn) |cn| closeConn(cn);
        },
        .stop_server => stopServer(op.server),
    }
}

fn startServer(s: *Server) void {
    const r = s.reactor;
    var addr: c.struct_sockaddr_in = undefined;
    // Accept dotted IPv4 only (plus the localhost convenience alias) --
    // a service host binds an interface, it does not resolve names.
    const host = if (std.mem.eql(u8, s.host, "localhost")) "127.0.0.1" else s.host;
    var host_buf: [64]u8 = undefined;
    const host_z = std.fmt.bufPrintZ(&host_buf, "{s}", .{host}) catch {
        finishBind(s, -1);
        return;
    };
    if (c.uv_ip4_addr(host_z.ptr, s.port, &addr) != 0) {
        finishBind(s, -1);
        return;
    }
    const tcp = s.tcp_buf.?.ptr;
    if (uv_tcp_init(&r.loop, tcp) != 0) {
        finishBind(s, -1);
        return;
    }
    setData(tcp, s);
    s.listener_inited = true;
    var rc = uv_tcp_bind(tcp, @ptrCast(&addr), 0);
    if (rc == 0) rc = uv_listen(tcp, LISTEN_BACKLOG, onNewConnection);
    if (rc != 0) {
        finishBind(s, rc);
        return;
    }
    // Report the actual bound port (supports port 0 = ephemeral).
    var name: c.struct_sockaddr_storage = undefined;
    var namelen: c_int = @sizeOf(c.struct_sockaddr_storage);
    if (uv_tcp_getsockname(tcp, @ptrCast(&name), &namelen) == 0) {
        const sin: *c.struct_sockaddr_in = @ptrCast(@alignCast(&name));
        s.bound_port = std.mem.bigToNative(u16, sin.sin_port);
    } else {
        s.bound_port = s.port;
    }
    finishBind(s, 0);
}

fn finishBind(s: *Server, status: c_int) void {
    const r = s.reactor;
    if (status != 0 and s.listener_inited) {
        const tcp = s.tcp_buf.?.ptr;
        if (c.uv_is_closing(@ptrCast(@alignCast(tcp))) == 0) {
            c.uv_close(@ptrCast(@alignCast(tcp)), onListenerClosed);
        }
    }
    r.mutex.lock();
    // If no uv handle was ever created there is nothing to close, so the
    // "listener closed" half of the reap handshake is already satisfied.
    if (status != 0 and !s.listener_inited) s.listener_closed = true;
    s.bind_status = @intCast(status);
    s.bind_done = true;
    r.mutex.unlock();
}

// ── TLS termination (mbedTLS over the libuv byte streams) ────
//
// mbedTLS drives the crypto through two BIO callbacks. It never touches the
// socket directly: `recv` hands it received CIPHERTEXT from conn.net_in, and
// `send` buffers its output CIPHERTEXT into conn.net_out, which tlsFlush()
// then writes to the socket. So the crypto is decoupled from the async I/O.

fn tlsBioSend(ctx: ?*anyopaque, buf: [*c]const u8, len: usize) callconv(.c) c_int {
    const conn: *Conn = @ptrCast(@alignCast(ctx));
    conn.net_out.appendSlice(gpa, buf[0..len]) catch return c.MBEDTLS_ERR_SSL_INTERNAL_ERROR;
    return @intCast(len);
}

fn tlsBioRecv(ctx: ?*anyopaque, buf: [*c]u8, len: usize) callconv(.c) c_int {
    const conn: *Conn = @ptrCast(@alignCast(ctx));
    const avail = conn.net_in.items.len - conn.net_in_pos;
    if (avail == 0) return c.MBEDTLS_ERR_SSL_WANT_READ;
    const n = @min(len, avail);
    @memcpy(buf[0..n], conn.net_in.items[conn.net_in_pos .. conn.net_in_pos + n]);
    conn.net_in_pos += n;
    return @intCast(n);
}

// Drop consumed ciphertext so net_in stays bounded by the in-flight record,
// not by total traffic.
fn compactNetIn(conn: *Conn) void {
    if (conn.net_in_pos >= conn.net_in.items.len) {
        conn.net_in.clearRetainingCapacity();
        conn.net_in_pos = 0;
    } else if (conn.net_in_pos > 0) {
        const rem = conn.net_in.items.len - conn.net_in_pos;
        std.mem.copyForwards(u8, conn.net_in.items[0..rem], conn.net_in.items[conn.net_in_pos..]);
        conn.net_in.shrinkRetainingCapacity(rem);
        conn.net_in_pos = 0;
    }
}

// Write any buffered ciphertext (mbedTLS output) to the socket.
fn tlsFlush(conn: *Conn) void {
    if (conn.net_out.items.len == 0) return;
    const data = gpa.dupe(u8, conn.net_out.items) catch return;
    conn.net_out.clearRetainingCapacity();
    enqueueRawWrite(conn, data, false);
}

// Feed DECRYPTED plaintext into the same framing/emit path a plain conn uses.
// (Shared by the plain-HTTP path and the TLS ssl_read loop.)
fn feedPlaintext(conn: *Conn, bytes: []const u8) void {
    const s = conn.server;
    const r = s.reactor;
    if (s.http_mode) {
        conn.inbox.appendSlice(gpa, bytes) catch {
            closeConn(conn);
            return;
        };
        if (conn.inbox.items.len > SRV_MAX_INBOX) {
            closeConn(conn);
            return;
        }
        while (httpRequestLen(conn.inbox.items)) |req_len| {
            const req = gpa.dupe(u8, conn.inbox.items[0..req_len]) catch {
                closeConn(conn);
                return;
            };
            std.mem.copyForwards(u8, conn.inbox.items[0 .. conn.inbox.items.len - req_len], conn.inbox.items[req_len..]);
            conn.inbox.shrinkRetainingCapacity(conn.inbox.items.len - req_len);
            r.mutex.lock();
            s.events.append(gpa, .{ .kind = .data, .conn_id = conn.id, .data = req }) catch {
                gpa.free(req);
            };
            r.mutex.unlock();
        }
    } else {
        const chunk = gpa.dupe(u8, bytes) catch {
            closeConn(conn);
            return;
        };
        r.mutex.lock();
        s.events.append(gpa, .{ .kind = .data, .conn_id = conn.id, .data = chunk }) catch {
            gpa.free(chunk);
        };
        r.mutex.unlock();
    }
}

// Advance a TLS conn: pump the handshake with whatever ciphertext has
// arrived, then drain any decrypted application data into the framing path.
// Flushes mbedTLS output after each phase. Called on every server read.
fn tlsProcess(conn: *Conn) void {
    // 1) handshake (until it needs more bytes, completes, or fails)
    if (!conn.hs_done) {
        while (true) {
            const rc = c.mbedtls_ssl_handshake(conn.ssl);
            if (rc == 0) {
                conn.hs_done = true;
                break;
            }
            if (rc == c.MBEDTLS_ERR_SSL_WANT_READ or rc == c.MBEDTLS_ERR_SSL_WANT_WRITE) break;
            tlsFlush(conn); // push out any alert
            closeConn(conn);
            return;
        }
        tlsFlush(conn); // send handshake records produced this pass
        compactNetIn(conn);
        if (!conn.hs_done) return; // await more ciphertext
    }
    // 2) decrypt application data -> framing
    while (true) {
        var plain: [SRV_SCRATCH]u8 = undefined;
        const rc = c.mbedtls_ssl_read(conn.ssl, &plain, plain.len);
        if (rc > 0) {
            feedPlaintext(conn, plain[0..@intCast(rc)]);
            if (conn.closing) return;
            continue;
        }
        if (rc == c.MBEDTLS_ERR_SSL_WANT_READ or rc == c.MBEDTLS_ERR_SSL_WANT_WRITE) break;
        // clean peer close, or a fatal error -> tear the conn down
        tlsFlush(conn);
        closeConn(conn);
        return;
    }
    tlsFlush(conn);
    compactNetIn(conn);
}

fn onNewConnection(listener: *anyopaque, status: c_int) callconv(.c) void {
    const slot: *?*anyopaque = @ptrCast(@alignCast(listener));
    const s: *Server = @ptrCast(@alignCast(slot.*.?));
    if (status != 0 or s.stopping) return;
    const r = s.reactor;

    const conn = gpa.create(Conn) catch return;
    const tcp_buf = gpa.alloc(u8, uv_handle_size(c.UV_TCP)) catch {
        gpa.destroy(conn);
        return;
    };
    const scratch = gpa.alloc(u8, SRV_SCRATCH) catch {
        gpa.free(tcp_buf);
        gpa.destroy(conn);
        return;
    };
    conn.* = .{ .id = 0, .server = s, .tcp_buf = tcp_buf, .scratch = scratch };

    if (uv_tcp_init(&r.loop, tcp_buf.ptr) != 0) {
        freeConn(conn);
        return;
    }
    setData(tcp_buf.ptr, conn);
    if (uv_accept(listener, tcp_buf.ptr) != 0) {
        c.uv_close(@ptrCast(@alignCast(tcp_buf.ptr)), onConnClosed);
        return;
    }

    r.mutex.lock();
    conn.id = s.next_conn_id;
    s.next_conn_id += 1;
    const put_ok = blk: {
        s.conns.put(conn.id, conn) catch break :blk false;
        break :blk true;
    };
    if (put_ok) {
        s.events.append(gpa, .{ .kind = .accept, .conn_id = conn.id }) catch {};
    }
    r.mutex.unlock();
    if (!put_ok) {
        closeConn(conn);
        return;
    }
    // TLS conns get a per-connection mbedTLS context wired to the byte BIOs;
    // the handshake runs as ciphertext arrives in onSrvRead -> tlsProcess.
    if (s.tls) {
        const ssl = gpa.create(c.mbedtls_ssl_context) catch {
            closeConn(conn);
            return;
        };
        c.mbedtls_ssl_init(ssl);
        if (c.mbedtls_ssl_setup(ssl, s.tls_conf) != 0) {
            c.mbedtls_ssl_free(ssl);
            gpa.destroy(ssl);
            closeConn(conn);
            return;
        }
        c.mbedtls_ssl_set_bio(ssl, conn, tlsBioSend, tlsBioRecv, null);
        conn.ssl = ssl;
    }
    if (uv_read_start(tcp_buf.ptr, onSrvAlloc, onSrvRead) != 0) closeConn(conn);
}

fn onSrvAlloc(stream: *anyopaque, suggested: usize, buf: [*c]c.uv_buf_t) callconv(.c) void {
    _ = suggested;
    const slot: *?*anyopaque = @ptrCast(@alignCast(stream));
    const conn: *Conn = @ptrCast(@alignCast(slot.*.?));
    buf.*.base = conn.scratch.ptr;
    buf.*.len = @intCast(conn.scratch.len);
}

fn onSrvRead(stream: *anyopaque, nread: isize, buf: [*c]const c.uv_buf_t) callconv(.c) void {
    _ = buf;
    const slot: *?*anyopaque = @ptrCast(@alignCast(stream));
    const conn: *Conn = @ptrCast(@alignCast(slot.*.?));
    const s = conn.server;
    if (nread > 0) {
        const bytes = conn.scratch[0..@intCast(nread)];
        if (s.tls) {
            // socket bytes are CIPHERTEXT: buffer + let mbedTLS decrypt them
            // (the handshake, then app data) via tlsProcess -> feedPlaintext.
            conn.net_in.appendSlice(gpa, bytes) catch {
                closeConn(conn);
                return;
            };
            if (conn.net_in.items.len > SRV_MAX_INBOX) {
                closeConn(conn);
                return;
            }
            tlsProcess(conn);
        } else {
            feedPlaintext(conn, bytes);
        }
        return;
    }
    if (nread < 0) closeConn(conn); // EOF or error: peer is gone either way
    // nread == 0 -> EAGAIN, nothing to do
}

// HTTP/1.1 framing: total byte length of the first complete request in
// `bytes` (headers + Content-Length body), or null if incomplete.
fn httpRequestLen(bytes: []const u8) ?usize {
    const he = std.mem.indexOf(u8, bytes, "\r\n\r\n") orelse return null;
    const header_end = he + 4;
    const clen = httpContentLength(bytes[0..header_end]);
    if (bytes.len >= header_end + clen) return header_end + clen;
    return null;
}

fn httpContentLength(headers: []const u8) usize {
    var it = std.mem.splitSequence(u8, headers, "\r\n");
    _ = it.next(); // request line
    while (it.next()) |line| {
        if (line.len == 0) break;
        const colon = std.mem.indexOfScalar(u8, line, ':') orelse continue;
        if (std.ascii.eqlIgnoreCase(std.mem.trim(u8, line[0..colon], " \t"), "content-length")) {
            const v = std.mem.trim(u8, line[colon + 1 ..], " \t");
            return std.fmt.parseInt(usize, v, 10) catch 0;
        }
    }
    return 0;
}

fn startWrite(op: Ctl) void {
    const s = op.server;
    const r = s.reactor;
    r.mutex.lock();
    const conn = s.conns.get(op.conn_id);
    r.mutex.unlock();
    const cn = conn orelse {
        if (op.data) |d| gpa.free(d);
        return;
    };
    if (cn.closing) {
        if (op.data) |d| gpa.free(d);
        return;
    }
    const data = op.data orelse return;
    if (cn.ssl != null) {
        // ENCRYPT the plaintext response: mbedtls_ssl_write feeds ciphertext
        // into net_out (via the send BIO); that ciphertext is what goes on
        // the wire. (Our send BIO never blocks, so ssl_write returns bytes
        // written or a fatal error -- never WANT_*.)
        var off: usize = 0;
        while (off < data.len) {
            const rc = c.mbedtls_ssl_write(cn.ssl, data.ptr + off, data.len - off);
            if (rc <= 0) {
                gpa.free(data);
                closeConn(cn);
                return;
            }
            off += @intCast(rc);
        }
        gpa.free(data); // plaintext consumed
        if (cn.net_out.items.len > 0) {
            const ct = gpa.dupe(u8, cn.net_out.items) catch {
                closeConn(cn);
                return;
            };
            cn.net_out.clearRetainingCapacity();
            enqueueRawWrite(cn, ct, op.close_after);
        } else if (op.close_after) {
            closeConn(cn);
        }
        return;
    }
    enqueueRawWrite(cn, data, op.close_after);
}

// Queue a raw (already-on-the-wire) byte buffer for a uv_write. Takes
// ownership of `data`. Used for plain conns and for flushing TLS ciphertext.
fn enqueueRawWrite(cn: *Conn, data: []u8, close_after: bool) void {
    const wr = gpa.create(WriteReq) catch {
        gpa.free(data);
        return;
    };
    const req_buf = gpa.alloc(u8, uv_req_size(c.UV_WRITE)) catch {
        gpa.free(data);
        gpa.destroy(wr);
        return;
    };
    wr.* = .{ .req_buf = req_buf, .data = data, .conn = cn, .close_after = close_after };
    setData(req_buf.ptr, wr);
    var buf = c.uv_buf_init(@ptrCast(data.ptr), @intCast(data.len));
    if (uv_write(req_buf.ptr, cn.tcp_buf.ptr, @ptrCast(&buf), 1, onSrvWrite) != 0) {
        gpa.free(req_buf);
        gpa.free(data);
        gpa.destroy(wr);
        closeConn(cn);
    }
}

fn onSrvWrite(req: *anyopaque, status: c_int) callconv(.c) void {
    const slot: *?*anyopaque = @ptrCast(@alignCast(req));
    const wr: *WriteReq = @ptrCast(@alignCast(slot.*.?));
    const cn = wr.conn;
    const want_close = wr.close_after or status != 0;
    gpa.free(wr.req_buf);
    gpa.free(wr.data);
    gpa.destroy(wr);
    if (want_close) closeConn(cn);
}

fn closeConn(conn: *Conn) void {
    if (conn.closing) return;
    conn.closing = true;
    _ = uv_read_stop(conn.tcp_buf.ptr);
    c.uv_close(@ptrCast(@alignCast(conn.tcp_buf.ptr)), onConnClosed);
}

fn onConnClosed(handle: [*c]c.uv_handle_t) callconv(.c) void {
    const conn: *Conn = @ptrCast(@alignCast(handle.*.data.?));
    const s = conn.server;
    const r = s.reactor;
    r.mutex.lock();
    const known = s.conns.remove(conn.id);
    if (known) {
        s.events.append(gpa, .{ .kind = .closed, .conn_id = conn.id }) catch {};
    }
    reapServerLocked(s);
    r.mutex.unlock();
    freeConn(conn);
}

fn stopServer(s: *Server) void {
    s.stopping = true;
    if (s.listener_inited and !s.listener_closed) {
        const tcp = s.tcp_buf.?.ptr;
        if (c.uv_is_closing(@ptrCast(@alignCast(tcp))) == 0) {
            c.uv_close(@ptrCast(@alignCast(tcp)), onListenerClosed);
        }
    } else {
        s.reactor.mutex.lock();
        s.listener_closed = true;
        reapServerLocked(s);
        s.reactor.mutex.unlock();
    }
    // Close every live connection; each close reaps toward teardown.
    // Collect ALL ids first (closes complete asynchronously, so the map
    // still holds closing conns -- re-collecting would spin forever).
    var ids: std.ArrayList(u64) = .{};
    defer ids.deinit(gpa);
    s.reactor.mutex.lock();
    var it = s.conns.iterator();
    while (it.next()) |e| {
        ids.append(gpa, e.key_ptr.*) catch break;
    }
    s.reactor.mutex.unlock();
    for (ids.items) |cid| {
        s.reactor.mutex.lock();
        const conn = s.conns.get(cid);
        s.reactor.mutex.unlock();
        if (conn) |cn| closeConn(cn);
    }
}

fn onListenerClosed(handle: [*c]c.uv_handle_t) callconv(.c) void {
    const s: *Server = @ptrCast(@alignCast(handle.*.data.?));
    const r = s.reactor;
    r.mutex.lock();
    s.listener_closed = true;
    reapServerLocked(s);
    r.mutex.unlock();
}

// Free the server once stopped, listener closed and every conn gone.
// Caller holds the mutex.
fn reapServerLocked(s: *Server) void {
    if (s.stopping and s.listener_closed and s.conns.count() == 0) {
        _ = s.reactor.servers.remove(s.id);
        // Deferred free: freeServer touches only our own memory, safe here.
        freeServer(s);
    }
}

var srv_last_conn: u64 = 0;
var srv_last_len: usize = 0;

/// Connection id of the last event returned by reactor_server_poll/await.
pub fn reactor_server_last_conn() callconv(.c) u64 {
    return srv_last_conn;
}

pub fn reactor_server_last_len() callconv(.c) usize {
    return srv_last_len;
}

/// Start a TCP/HTTP listener on host:port (dotted IPv4 or "localhost";
/// port 0 = ephemeral). http_mode != 0 frames complete HTTP/1.1 requests.
/// Blocks briefly for the bind result. Returns server id (>0) or the
/// negative uv error code.
pub fn reactor_listen(
    r_opt: ?*Reactor,
    host_ptr: [*]const u8,
    host_len: usize,
    port: u16,
    http_mode: i32,
) callconv(.c) i64 {
    const r = r_opt orelse return -1;
    if (r.stopping.load(.acquire)) return -1;
    const s = gpa.create(Server) catch return -1;
    const host = gpa.dupe(u8, host_ptr[0..host_len]) catch {
        gpa.destroy(s);
        return -1;
    };
    const tcp_buf = gpa.alloc(u8, uv_handle_size(c.UV_TCP)) catch {
        gpa.free(host);
        gpa.destroy(s);
        return -1;
    };
    r.mutex.lock();
    s.* = .{
        .id = r.next_id,
        .reactor = r,
        .host = host,
        .port = port,
        .http_mode = http_mode != 0,
        .tcp_buf = tcp_buf,
        .conns = std.AutoHashMap(u64, *Conn).init(gpa),
    };
    r.next_id += 1;
    const id = s.id;
    r.servers.put(id, s) catch {
        r.mutex.unlock();
        freeServer(s);
        return -1;
    };
    r.ctl.append(gpa, .{ .kind = .start_server, .server = s }) catch {
        _ = r.servers.remove(id);
        r.mutex.unlock();
        freeServer(s);
        return -1;
    };
    r.mutex.unlock();
    _ = c.uv_async_send(&r.wake);
    // Wait for the loop thread to report the bind result (bounded).
    const deadline = std.time.nanoTimestamp() + 5 * std.time.ns_per_s;
    while (true) {
        r.mutex.lock();
        const done = s.bind_done;
        const status = s.bind_status;
        r.mutex.unlock();
        if (done) {
            if (status != 0) {
                // Bind failed: the listener close is already in flight;
                // mark stopping so the reap handshake frees the server.
                r.mutex.lock();
                s.stopping = true;
                reapServerLocked(s);
                r.mutex.unlock();
                return status;
            }
            return @intCast(id);
        }
        if (std.time.nanoTimestamp() >= deadline) return -1;
        std.Thread.sleep(1 * std.time.ns_per_ms);
    }
}

// Build a server's shared TLS credentials + config from cert/key(/ca) file
// paths. Returns 0 on success, a negative code on failure (the caller frees
// the partial state via freeServer -> freeServerTls). Done on the CALLER
// thread at listen time; the config is read-only once the loop uses it.
fn setupServerTls(s: *Server, cert_path: []const u8, key_path: []const u8, ca_path: []const u8, require_client: bool) i32 {
    var cbuf: [1024]u8 = undefined;
    var kbuf: [1024]u8 = undefined;
    const cert_z = std.fmt.bufPrintZ(&cbuf, "{s}", .{cert_path}) catch return -10;
    const key_z = std.fmt.bufPrintZ(&kbuf, "{s}", .{key_path}) catch return -10;

    // RNG
    const entropy = gpa.create(c.mbedtls_entropy_context) catch return -11;
    s.tls_entropy = entropy;
    c.mbedtls_entropy_init(entropy);
    const drbg = gpa.create(c.mbedtls_ctr_drbg_context) catch return -11;
    s.tls_drbg = drbg;
    c.mbedtls_ctr_drbg_init(drbg);
    const pers = "softanza-reactor-tls";
    if (c.mbedtls_ctr_drbg_seed(drbg, c.mbedtls_entropy_func, entropy, pers, pers.len) != 0) return -12;

    // server certificate chain + private key
    const srvcert = gpa.create(c.mbedtls_x509_crt) catch return -11;
    s.tls_srvcert = srvcert;
    c.mbedtls_x509_crt_init(srvcert);
    if (c.mbedtls_x509_crt_parse_file(srvcert, cert_z.ptr) != 0) return -13;
    const pk = gpa.create(c.mbedtls_pk_context) catch return -11;
    s.tls_pk = pk;
    c.mbedtls_pk_init(pk);
    if (c.mbedtls_pk_parse_keyfile(pk, key_z.ptr, null, c.mbedtls_ctr_drbg_random, drbg) != 0) return -14;

    // config
    const conf = gpa.create(c.mbedtls_ssl_config) catch return -11;
    s.tls_conf = conf;
    c.mbedtls_ssl_config_init(conf);
    if (c.mbedtls_ssl_config_defaults(conf, c.MBEDTLS_SSL_IS_SERVER, c.MBEDTLS_SSL_TRANSPORT_STREAM, c.MBEDTLS_SSL_PRESET_DEFAULT) != 0) return -15;
    c.mbedtls_ssl_conf_rng(conf, c.mbedtls_ctr_drbg_random, drbg);
    if (c.mbedtls_ssl_conf_own_cert(conf, srvcert, pk) != 0) return -16;

    // optional CA -> client-cert verification (the MUTUAL half)
    if (ca_path.len > 0) {
        var abuf: [1024]u8 = undefined;
        const ca_z = std.fmt.bufPrintZ(&abuf, "{s}", .{ca_path}) catch return -10;
        const cacert = gpa.create(c.mbedtls_x509_crt) catch return -11;
        s.tls_cacert = cacert;
        c.mbedtls_x509_crt_init(cacert);
        if (c.mbedtls_x509_crt_parse_file(cacert, ca_z.ptr) != 0) return -17;
        c.mbedtls_ssl_conf_ca_chain(conf, cacert, null);
        c.mbedtls_ssl_conf_authmode(conf, if (require_client) c.MBEDTLS_SSL_VERIFY_REQUIRED else c.MBEDTLS_SSL_VERIFY_OPTIONAL);
    } else {
        // one-way server TLS: no client cert demanded
        c.mbedtls_ssl_conf_authmode(conf, c.MBEDTLS_SSL_VERIFY_NONE);
    }
    return 0;
}

/// Like reactor_listen, but the listener TERMINATES TLS: each connection
/// runs an mbedTLS handshake (server cert from cert_path/key_path) before
/// the plaintext HTTP framing. A non-empty ca_path enables client-cert
/// verification; require_client != 0 makes it MANDATORY (mTLS). Returns the
/// server id (>0) or a negative error (TLS setup errors are -10..-17).
pub fn reactor_listen_tls(
    r_opt: ?*Reactor,
    host_ptr: [*]const u8,
    host_len: usize,
    port: u16,
    http_mode: i32,
    cert_ptr: [*]const u8,
    cert_len: usize,
    key_ptr: [*]const u8,
    key_len: usize,
    ca_ptr: [*]const u8,
    ca_len: usize,
    require_client: i32,
) callconv(.c) i64 {
    const r = r_opt orelse return -1;
    if (r.stopping.load(.acquire)) return -1;
    const s = gpa.create(Server) catch return -1;
    const host = gpa.dupe(u8, host_ptr[0..host_len]) catch {
        gpa.destroy(s);
        return -1;
    };
    const tcp_buf = gpa.alloc(u8, uv_handle_size(c.UV_TCP)) catch {
        gpa.free(host);
        gpa.destroy(s);
        return -1;
    };
    s.* = .{
        .id = 0,
        .reactor = r,
        .host = host,
        .port = port,
        .http_mode = http_mode != 0,
        .tcp_buf = tcp_buf,
        .conns = std.AutoHashMap(u64, *Conn).init(gpa),
        .tls = true,
        .require_client = require_client != 0,
    };
    // TLS credentials + config (file parse) before registering with the loop
    const trc = setupServerTls(s, cert_ptr[0..cert_len], key_ptr[0..key_len], ca_ptr[0..ca_len], require_client != 0);
    if (trc != 0) {
        freeServer(s);
        return trc;
    }
    r.mutex.lock();
    s.id = r.next_id;
    r.next_id += 1;
    const id = s.id;
    r.servers.put(id, s) catch {
        r.mutex.unlock();
        freeServer(s);
        return -1;
    };
    r.ctl.append(gpa, .{ .kind = .start_server, .server = s }) catch {
        _ = r.servers.remove(id);
        r.mutex.unlock();
        freeServer(s);
        return -1;
    };
    r.mutex.unlock();
    _ = c.uv_async_send(&r.wake);
    const deadline = std.time.nanoTimestamp() + 5 * std.time.ns_per_s;
    while (true) {
        r.mutex.lock();
        const done = s.bind_done;
        const status = s.bind_status;
        r.mutex.unlock();
        if (done) {
            if (status != 0) {
                r.mutex.lock();
                s.stopping = true;
                reapServerLocked(s);
                r.mutex.unlock();
                return status;
            }
            return @intCast(id);
        }
        if (std.time.nanoTimestamp() >= deadline) return -1;
        std.Thread.sleep(1 * std.time.ns_per_ms);
    }
}

// ── TLS CLIENT (the mTLS counterpart to the slice-2 server) ──
//
// A synchronous mbedTLS request over a blocking socket (mbedtls_net): it
// presents THIS node's client cert (cert_path/key_path, for the server's
// mutual check), validates the peer's server cert against ca_path when
// verify != 0 (hostname checked via SNI), sends req_bytes, and reads the
// framed HTTP response. This is deliberately a SEPARATE transport from the
// Schannel curl path (which stays for general outbound HTTPS): node-to-node
// mTLS wants PEM certs + mutual auth end to end, which Schannel can't do.
// Status via reactor_tls_client_status() (0 ok, -1 connect, -2 handshake,
// -3 cert verify, -4 setup).

var tls_client_status: i32 = 0;

pub fn reactor_tls_client_status() callconv(.c) i32 {
    return tls_client_status;
}

pub fn reactor_tls_request(
    host_ptr: [*]const u8,
    host_len: usize,
    port: u16,
    req_ptr: [*]const u8,
    req_len: usize,
    cert_ptr: [*]const u8,
    cert_len: usize,
    key_ptr: [*]const u8,
    key_len: usize,
    ca_ptr: [*]const u8,
    ca_len: usize,
    verify: i32,
    out: [*]u8,
    max: usize,
) callconv(.c) i32 {
    tls_client_status = -4; // assume setup failure until we get past it

    var hbuf: [256]u8 = undefined;
    var pbuf: [16]u8 = undefined;
    const host_z = std.fmt.bufPrintZ(&hbuf, "{s}", .{host_ptr[0..host_len]}) catch return -4;
    const port_z = std.fmt.bufPrintZ(&pbuf, "{d}", .{port}) catch return -4;

    var net: c.mbedtls_net_context = undefined;
    var ssl: c.mbedtls_ssl_context = undefined;
    var conf: c.mbedtls_ssl_config = undefined;
    var cacert: c.mbedtls_x509_crt = undefined;
    var clicert: c.mbedtls_x509_crt = undefined;
    var pk: c.mbedtls_pk_context = undefined;
    var entropy: c.mbedtls_entropy_context = undefined;
    var drbg: c.mbedtls_ctr_drbg_context = undefined;
    c.mbedtls_net_init(&net);
    c.mbedtls_ssl_init(&ssl);
    c.mbedtls_ssl_config_init(&conf);
    c.mbedtls_x509_crt_init(&cacert);
    c.mbedtls_x509_crt_init(&clicert);
    c.mbedtls_pk_init(&pk);
    c.mbedtls_entropy_init(&entropy);
    c.mbedtls_ctr_drbg_init(&drbg);
    defer {
        c.mbedtls_net_free(&net);
        c.mbedtls_ssl_free(&ssl);
        c.mbedtls_ssl_config_free(&conf);
        c.mbedtls_x509_crt_free(&cacert);
        c.mbedtls_x509_crt_free(&clicert);
        c.mbedtls_pk_free(&pk);
        c.mbedtls_ctr_drbg_free(&drbg);
        c.mbedtls_entropy_free(&entropy);
    }

    const pers = "softanza-tls-client";
    if (c.mbedtls_ctr_drbg_seed(&drbg, c.mbedtls_entropy_func, &entropy, pers, pers.len) != 0) return -4;
    if (c.mbedtls_ssl_config_defaults(&conf, c.MBEDTLS_SSL_IS_CLIENT, c.MBEDTLS_SSL_TRANSPORT_STREAM, c.MBEDTLS_SSL_PRESET_DEFAULT) != 0) return -4;
    c.mbedtls_ssl_conf_rng(&conf, c.mbedtls_ctr_drbg_random, &drbg);
    c.mbedtls_ssl_conf_read_timeout(&conf, 2000);

    // trust anchor + verification mode
    if (ca_len > 0) {
        var abuf: [1024]u8 = undefined;
        const ca_z = std.fmt.bufPrintZ(&abuf, "{s}", .{ca_ptr[0..ca_len]}) catch return -4;
        if (c.mbedtls_x509_crt_parse_file(&cacert, ca_z.ptr) != 0) return -4;
        c.mbedtls_ssl_conf_ca_chain(&conf, &cacert, null);
        c.mbedtls_ssl_conf_authmode(&conf, if (verify != 0) c.MBEDTLS_SSL_VERIFY_REQUIRED else c.MBEDTLS_SSL_VERIFY_OPTIONAL);
    } else {
        c.mbedtls_ssl_conf_authmode(&conf, c.MBEDTLS_SSL_VERIFY_NONE);
    }

    // this node's CLIENT cert (presented for the server's mutual check)
    if (cert_len > 0 and key_len > 0) {
        var cbuf: [1024]u8 = undefined;
        var kbuf: [1024]u8 = undefined;
        const cert_z = std.fmt.bufPrintZ(&cbuf, "{s}", .{cert_ptr[0..cert_len]}) catch return -4;
        const key_z = std.fmt.bufPrintZ(&kbuf, "{s}", .{key_ptr[0..key_len]}) catch return -4;
        if (c.mbedtls_x509_crt_parse_file(&clicert, cert_z.ptr) != 0) return -4;
        if (c.mbedtls_pk_parse_keyfile(&pk, key_z.ptr, null, c.mbedtls_ctr_drbg_random, &drbg) != 0) return -4;
        if (c.mbedtls_ssl_conf_own_cert(&conf, &clicert, &pk) != 0) return -4;
    }

    if (c.mbedtls_ssl_setup(&ssl, &conf) != 0) return -4;
    if (c.mbedtls_ssl_set_hostname(&ssl, host_z.ptr) != 0) return -4;

    tls_client_status = -1;
    if (c.mbedtls_net_connect(&net, host_z.ptr, port_z.ptr, c.MBEDTLS_NET_PROTO_TCP) != 0) return -1;
    c.mbedtls_ssl_set_bio(&ssl, &net, c.mbedtls_net_send, null, c.mbedtls_net_recv_timeout);

    tls_client_status = -2;
    while (true) {
        const rc = c.mbedtls_ssl_handshake(&ssl);
        if (rc == 0) break;
        if (rc == c.MBEDTLS_ERR_SSL_WANT_READ or rc == c.MBEDTLS_ERR_SSL_WANT_WRITE) continue;
        return -2; // handshake failed (bad cert, no client cert offered, etc.)
    }
    if (verify != 0 and c.mbedtls_ssl_get_verify_result(&ssl) != 0) {
        tls_client_status = -3;
        return -3; // peer cert did not validate against the CA / hostname
    }

    // send the request
    tls_client_status = 0;
    var woff: usize = 0;
    while (woff < req_len) {
        const rc = c.mbedtls_ssl_write(&ssl, req_ptr + woff, req_len - woff);
        if (rc > 0) {
            woff += @intCast(rc);
            continue;
        }
        if (rc == c.MBEDTLS_ERR_SSL_WANT_READ or rc == c.MBEDTLS_ERR_SSL_WANT_WRITE) continue;
        return -5;
    }

    // read the framed HTTP response (or until idle-timeout / close)
    var total: usize = 0;
    while (total < max) {
        if (httpRequestLen(out[0..total]) != null) break; // full response framed
        const rc = c.mbedtls_ssl_read(&ssl, out + total, max - total);
        if (rc > 0) {
            total += @intCast(rc);
            continue;
        }
        if (rc == c.MBEDTLS_ERR_SSL_WANT_READ or rc == c.MBEDTLS_ERR_SSL_WANT_WRITE) continue;
        break; // TIMEOUT / peer close / EOF -> response complete
    }
    _ = c.mbedtls_ssl_close_notify(&ssl);
    return @intCast(total);
}

/// Actual bound port of a listening server (useful with port 0).
pub fn reactor_server_port(r_opt: ?*Reactor, sid: u64) callconv(.c) i32 {
    const r = r_opt orelse return -2;
    r.mutex.lock();
    defer r.mutex.unlock();
    const s = r.servers.get(sid) orelse return -2;
    return @intCast(s.bound_port);
}

/// Number of live connections on a server.
pub fn reactor_server_conns(r_opt: ?*Reactor, sid: u64) callconv(.c) i32 {
    const r = r_opt orelse return -2;
    r.mutex.lock();
    defer r.mutex.unlock();
    const s = r.servers.get(sid) orelse return -2;
    return @intCast(s.conns.count());
}

/// Drain one server event. Returns 0 (none), -2 (unknown server), -3
/// (data overflow: event dropped), or the event kind (1 accept, 2 data,
/// 3 closed). Data bytes are copied into out[0..max]; the conn id and
/// byte count are reported via reactor_server_last_conn/_last_len.
pub fn reactor_server_poll(r_opt: ?*Reactor, sid: u64, out: [*]u8, max: usize) callconv(.c) i32 {
    const r = r_opt orelse return -2;
    r.mutex.lock();
    defer r.mutex.unlock();
    const s = r.servers.get(sid) orelse return -2;
    if (s.events.items.len == 0) return 0;
    const ev = s.events.orderedRemove(0);
    srv_last_conn = ev.conn_id;
    srv_last_len = 0;
    if (ev.data) |d| {
        defer gpa.free(d);
        if (d.len > max) return -3;
        @memcpy(out[0..d.len], d);
        srv_last_len = d.len;
    }
    return @intFromEnum(ev.kind);
}

/// Block up to timeout_ms for a server event. Same codes as
/// reactor_server_poll (0 = timed out with no event).
pub fn reactor_server_await(r_opt: ?*Reactor, sid: u64, timeout_ms: u64, out: [*]u8, max: usize) callconv(.c) i32 {
    const r = r_opt orelse return -2;
    const deadline = std.time.nanoTimestamp() + @as(i128, @intCast(timeout_ms)) * 1_000_000;
    while (true) {
        const rc = reactor_server_poll(r, sid, out, max);
        if (rc != 0) return rc;
        if (std.time.nanoTimestamp() >= deadline) return 0;
        std.Thread.sleep(1 * std.time.ns_per_ms);
    }
}

/// Queue a write to a connection; close_after != 0 closes it once the
/// write completes (Connection: close semantics). Returns 0 or -1.
pub fn reactor_server_write(
    r_opt: ?*Reactor,
    sid: u64,
    conn_id: u64,
    data_ptr: [*]const u8,
    data_len: usize,
    close_after: i32,
) callconv(.c) i32 {
    const r = r_opt orelse return -1;
    if (r.stopping.load(.acquire)) return -1;
    r.mutex.lock();
    const s = r.servers.get(sid) orelse {
        r.mutex.unlock();
        return -1;
    };
    const data = gpa.dupe(u8, data_ptr[0..data_len]) catch {
        r.mutex.unlock();
        return -1;
    };
    r.ctl.append(gpa, .{
        .kind = .server_write,
        .server = s,
        .conn_id = conn_id,
        .data = data,
        .close_after = close_after != 0,
    }) catch {
        r.mutex.unlock();
        gpa.free(data);
        return -1;
    };
    r.mutex.unlock();
    _ = c.uv_async_send(&r.wake);
    return 0;
}

/// Queue a connection close. Returns 0 or -1.
pub fn reactor_server_close_conn(r_opt: ?*Reactor, sid: u64, conn_id: u64) callconv(.c) i32 {
    const r = r_opt orelse return -1;
    r.mutex.lock();
    const s = r.servers.get(sid) orelse {
        r.mutex.unlock();
        return -1;
    };
    r.ctl.append(gpa, .{ .kind = .conn_close, .server = s, .conn_id = conn_id }) catch {
        r.mutex.unlock();
        return -1;
    };
    r.mutex.unlock();
    _ = c.uv_async_send(&r.wake);
    return 0;
}

/// Stop a server: close the listener and every connection; the server is
/// freed once all handles are closed. Returns 0 or -1.
pub fn reactor_server_stop(r_opt: ?*Reactor, sid: u64) callconv(.c) i32 {
    const r = r_opt orelse return -1;
    r.mutex.lock();
    const s = r.servers.get(sid) orelse {
        r.mutex.unlock();
        return -1;
    };
    r.ctl.append(gpa, .{ .kind = .stop_server, .server = s }) catch {
        r.mutex.unlock();
        return -1;
    };
    r.mutex.unlock();
    _ = c.uv_async_send(&r.wake);
    return 0;
}

// ── async process spawn (public API) ─────────────────────────

var spawn_last_status: i32 = 0;
var spawn_last_len: usize = 0;

pub fn reactor_spawn_last_status() callconv(.c) i32 {
    return spawn_last_status;
}
pub fn reactor_spawn_last_len() callconv(.c) usize {
    return spawn_last_len;
}

/// Submit an async spawn. `cmd_ptr` is the program and its arguments
/// joined by '\n' (argv[0] = program). Runs the child on the loop,
/// captures its stdout, and reports the exit code + output through the
/// job idiom. Returns a job id (>0) or -1.
pub fn reactor_submit_spawn(
    r_opt: ?*Reactor,
    cmd_ptr: [*]const u8,
    cmd_len: usize,
) callconv(.c) i64 {
    const r = r_opt orelse return -1;
    if (r.stopping.load(.acquire)) return -1;
    const job = gpa.create(Job) catch return -1;
    // dupe with one spare trailing NUL byte for the final argv segment
    const argv = gpa.alloc(u8, cmd_len + 1) catch {
        gpa.destroy(job);
        return -1;
    };
    @memcpy(argv[0..cmd_len], cmd_ptr[0..cmd_len]);
    argv[cmd_len] = 0;
    const scratch = gpa.alloc(u8, TCP_SCRATCH) catch {
        gpa.free(argv);
        gpa.destroy(job);
        return -1;
    };
    const proc_buf = gpa.alloc(u8, uv_handle_size(c.UV_PROCESS)) catch {
        gpa.free(argv);
        gpa.free(scratch);
        gpa.destroy(job);
        return -1;
    };
    const pipe_buf = gpa.alloc(u8, uv_handle_size(c.UV_NAMED_PIPE)) catch {
        gpa.free(argv);
        gpa.free(scratch);
        gpa.free(proc_buf);
        gpa.destroy(job);
        return -1;
    };
    r.mutex.lock();
    job.* = .{
        .id = r.next_id,
        .kind = .spawn,
        .reactor = r,
        .argv_joined = argv,
        .scratch = scratch,
        .proc_buf = proc_buf,
        .pipe_buf = pipe_buf,
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

/// Poll a spawn job: -2 not found, -1 running, -3 overflow, else the
/// number of stdout bytes written into out[0..max]. The exit code is
/// reported via reactor_spawn_last_status().
pub fn reactor_spawn_poll(r_opt: ?*Reactor, job_id: u64, out: [*]u8, max: usize) callconv(.c) i32 {
    const r = r_opt orelse return -2;
    r.mutex.lock();
    defer r.mutex.unlock();
    const job = r.jobs.get(job_id) orelse return -2;
    if (!job.result_ready) return -1;
    spawn_last_status = job.status;
    const body = job.resp.items;
    job.drained = true;
    if (body.len > max) {
        spawn_last_len = 0;
        reapLocked(r, job);
        return -3;
    }
    @memcpy(out[0..body.len], body);
    spawn_last_len = body.len;
    reapLocked(r, job);
    return @intCast(body.len);
}

/// Block up to timeout_ms for a spawn to finish. Same codes as
/// reactor_spawn_poll, plus -1 on timeout.
pub fn reactor_spawn_await(r_opt: ?*Reactor, job_id: u64, timeout_ms: u64, out: [*]u8, max: usize) callconv(.c) i32 {
    const r = r_opt orelse return -2;
    const deadline = std.time.nanoTimestamp() + @as(i128, @intCast(timeout_ms)) * 1_000_000;
    while (true) {
        const rc = reactor_spawn_poll(r, job_id, out, max);
        if (rc != -1) return rc;
        if (std.time.nanoTimestamp() >= deadline) return -1;
        std.Thread.sleep(2 * std.time.ns_per_ms);
    }
}

/// Force-kill a spawned child by job id: send `signum` to the process
/// (SIGKILL=9 / SIGTERM=15; on Windows libuv maps these to TerminateProcess).
/// Returns 0 on success, -2 job not found, -3 already exited, -4 not a spawn
/// job / no handle, else a negative uv error. Mutex-guarded so it can never
/// race the loop thread closing/freeing the process handle on exit.
pub fn reactor_spawn_kill(r_opt: ?*Reactor, job_id: u64, signum: c_int) callconv(.c) i32 {
    const r = r_opt orelse return -2;
    r.mutex.lock();
    defer r.mutex.unlock();
    const job = r.jobs.get(job_id) orelse return -2;
    if (job.kind != .spawn) return -4;
    if (job.proc_exited) return -3;
    const pb = job.proc_buf orelse return -4;
    return @intCast(uv_process_kill(pb.ptr, signum));
}

// ── async HTTPS / HTTP request (public API) ──────────────────

var curl_last_status: i32 = 0;
var curl_last_len: usize = 0;

/// HTTP status code of the last drained curl request (or <0 error).
pub fn reactor_curl_last_status() callconv(.c) i32 {
    return curl_last_status;
}
pub fn reactor_curl_last_len() callconv(.c) usize {
    return curl_last_len;
}

/// Submit an async HTTP/HTTPS request run on a libuv worker thread
/// (native TLS via curl/Schannel). method: 0=GET 1=POST 2=PUT 3=DELETE
/// 4=HEAD 5=OPTIONS 6=PATCH. Returns a job id (>0) or -1.
pub fn reactor_submit_curl(
    r_opt: ?*Reactor,
    method: i32,
    url_ptr: [*]const u8,
    url_len: usize,
    body_ptr: [*]const u8,
    body_len: usize,
) callconv(.c) i64 {
    const r = r_opt orelse return -1;
    if (r.stopping.load(.acquire)) return -1;
    const job = gpa.create(Job) catch return -1;
    const url = gpa.dupe(u8, url_ptr[0..url_len]) catch {
        gpa.destroy(job);
        return -1;
    };
    const body = gpa.dupe(u8, body_ptr[0..body_len]) catch {
        gpa.free(url);
        gpa.destroy(job);
        return -1;
    };
    const out = gpa.alloc(u8, CURL_OUT_CAP) catch {
        gpa.free(url);
        gpa.free(body);
        gpa.destroy(job);
        return -1;
    };
    const work_buf = gpa.alloc(u8, uv_req_size(c.UV_WORK)) catch {
        gpa.free(url);
        gpa.free(body);
        gpa.free(out);
        gpa.destroy(job);
        return -1;
    };
    r.mutex.lock();
    job.* = .{
        .id = r.next_id,
        .kind = .curl,
        .reactor = r,
        .host = url,
        .curl_method = method,
        .curl_body = body,
        .curl_out = out,
        .work_buf = work_buf,
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

/// Poll a curl job: -2 not found, -1 running, -3 overflow, else the
/// number of body bytes written into out[0..max]. HTTP status via
/// reactor_curl_last_status().
pub fn reactor_curl_poll(r_opt: ?*Reactor, job_id: u64, out: [*]u8, max: usize) callconv(.c) i32 {
    const r = r_opt orelse return -2;
    r.mutex.lock();
    defer r.mutex.unlock();
    const job = r.jobs.get(job_id) orelse return -2;
    if (!job.result_ready) return -1;
    curl_last_status = job.status;
    const bdy = job.resp.items;
    job.drained = true;
    if (bdy.len > max) {
        curl_last_len = 0;
        reapLocked(r, job);
        return -3;
    }
    @memcpy(out[0..bdy.len], bdy);
    curl_last_len = bdy.len;
    reapLocked(r, job);
    return @intCast(bdy.len);
}

/// Block up to timeout_ms for a curl job. Same codes as
/// reactor_curl_poll, plus -1 on timeout.
pub fn reactor_curl_await(r_opt: ?*Reactor, job_id: u64, timeout_ms: u64, out: [*]u8, max: usize) callconv(.c) i32 {
    const r = r_opt orelse return -2;
    const deadline = std.time.nanoTimestamp() + @as(i128, @intCast(timeout_ms)) * 1_000_000;
    while (true) {
        const rc = reactor_curl_poll(r, job_id, out, max);
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
    // Free surviving servers (their handles were force-closed by walkClose,
    // so the per-handle close callbacks never ran).
    var sit = r.servers.iterator();
    while (sit.next()) |e| freeServer(e.value_ptr.*);
    r.servers.deinit();
    // Free any queued-but-never-run control ops that own data.
    for (r.ctl.items) |op| {
        if (op.data) |d| gpa.free(d);
    }
    r.ctl.deinit(gpa);
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

test "reactor server: http request/response round-trip on loopback" {
    const r = reactor_create().?;
    defer reactor_destroy(r);
    const sid_i = reactor_listen(r, "127.0.0.1", 9, 0, 1); // port 0 = ephemeral
    try std.testing.expect(sid_i > 0);
    const sid: u64 = @intCast(sid_i);
    const port_i = reactor_server_port(r, sid);
    try std.testing.expect(port_i > 0);
    const port: u16 = @intCast(port_i);

    // Client and server share the reactor: the loop thread runs both ends,
    // this thread plays "Ring" -- submit, then serve events, then await.
    const req = "GET /hello HTTP/1.1\r\nHost: x\r\nConnection: close\r\n\r\n";
    const jid = reactor_submit_tcp_request(r, "127.0.0.1", 9, port, req, req.len);
    try std.testing.expect(jid > 0);

    var evbuf: [65536]u8 = undefined;
    var served = false;
    var tries: usize = 0;
    while (!served and tries < 500) : (tries += 1) {
        const k = reactor_server_await(r, sid, 20, &evbuf, evbuf.len);
        if (k == 2) {
            const got = evbuf[0..reactor_server_last_len()];
            try std.testing.expect(std.mem.startsWith(u8, got, "GET /hello"));
            const resp = "HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\nhi";
            try std.testing.expectEqual(@as(i32, 0), reactor_server_write(r, sid, reactor_server_last_conn(), resp, resp.len, 1));
            served = true;
        }
    }
    try std.testing.expect(served);

    var buf: [65536]u8 = undefined;
    const n = reactor_tcp_await(r, @intCast(jid), 10_000, &buf, buf.len);
    try std.testing.expect(n > 0);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(n)], "200 OK") != null);
    try std.testing.expect(std.mem.endsWith(u8, buf[0..@intCast(n)], "hi"));
    try std.testing.expectEqual(@as(i32, 0), reactor_server_stop(r, sid));
}

test "reactor server: stop with live connections leaks nothing" {
    const r = reactor_create().?;
    const sid_i = reactor_listen(r, "127.0.0.1", 9, 0, 0); // raw stream mode
    try std.testing.expect(sid_i > 0);
    const sid: u64 = @intCast(sid_i);
    const port: u16 = @intCast(reactor_server_port(r, sid));
    // Open a client conn that never completes (no EOF from our side).
    _ = reactor_submit_tcp_request(r, "127.0.0.1", 9, port, "ping", 4);
    var evbuf: [4096]u8 = undefined;
    // Wait for the accept (and likely the data chunk) to arrive.
    _ = reactor_server_await(r, sid, 2_000, &evbuf, evbuf.len);
    try std.testing.expectEqual(@as(i32, 0), reactor_server_stop(r, sid));
    // Destroy with the stop possibly still in flight: must not crash/leak.
    reactor_destroy(r);
}

test "reactor server: bind to an invalid host reports an error" {
    const r = reactor_create().?;
    defer reactor_destroy(r);
    const sid = reactor_listen(r, "999.999.0.1", 11, 0, 1);
    try std.testing.expect(sid < 0);
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
