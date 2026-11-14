// THE OPERATING-SYSTEM BOUNDARY -- rung B1 of SOFTANZA_OS_BOUNDARY_STUDY.md (FOUNDRY-OSBOUNDARY-01, stzfoundry AF7)
//
// A grant describes what a node may reach; start() runs a command inside it and wait() answers how the run ended.
// On Windows the boundary is an AppContainer (files and network) plus a job object (children, memory, processor time),
// the two mechanisms the study measured working. The grant's fields:
//
//   name        the AppContainer profile; created on first use and kept (removal is rung B2)
//   read        paths the node may read and execute, granted to the container's SID
//   write       paths the node may write (full access); a path must exist when the grant is applied
//   network     0 none, 1 the internetClient capability (loopback stays closed either way: study, consequence 1)
//   children    how many processes the node may start besides itself (job active-process limit = 1 + children)
//   memory MB   the job's commit ceiling; past it an allocation fails and the job reports JOB_MEMORY_LIMIT
//   processor   seconds of processor time for the whole job; past it Windows ends the job (END_OF_JOB_TIME, ~1.6 s late)
//   out / err   files the node's standard output and error go to (NUL when empty); stdin is NUL
//
// The child inherits ONLY its three standard handles (PROC_THREAD_ATTRIBUTE_HANDLE_LIST), never another inheritable
// handle the supervisor holds. Its environment is the supervisor's. A grant is applied once per path: a folder whose
// access list already names the container with the access asked is left alone, so the 2.5 to 4 s a library tree
// costs is paid at the first start and not on each one.
//
// Other systems: every call answers 0 with the reason in error(); the Linux half is HAROBANDA-WORKER-01.

const std = @import("std");
const builtin = @import("builtin");

const is_windows = builtin.os.tag == .windows;
const alloc = std.heap.page_allocator;

pub const MAX_SLOTS = 16;
pub const MAX_PATHS = 32;
pub const MAX_MSGS = 32;

const Slot = struct {
    used: bool = false,
    name: [64]u8 = undefined,
    name_len: usize = 0,
    reads: [MAX_PATHS][]u8 = undefined,
    nreads: usize = 0,
    writes: [MAX_PATHS][]u8 = undefined,
    nwrites: usize = 0,
    network: bool = false,
    children: u32 = 0,
    memory_mb: usize = 256,
    processor_s: f64 = 0,
    out: ?[]u8 = null,
    err: ?[]u8 = null,
    // the run
    started: bool = false,
    ended: bool = false,
    process: ?*anyopaque = null,
    job: ?*anyopaque = null,
    port: ?*anyopaque = null,
    pid: u32 = 0,
    exit_code: u32 = 0,
    peak_mb: f64 = 0,
    msgs: [MAX_MSGS]u32 = undefined,
    nmsg: usize = 0,
    t0: ?std.time.Instant = null,
    wall_ms: f64 = 0,
    grant_ms: f64 = 0,
    granted: u32 = 0,
    error_text: [256]u8 = undefined,
    error_len: usize = 0,
};

var slots: [MAX_SLOTS]Slot = [_]Slot{.{}} ** MAX_SLOTS;
var last_error: [256]u8 = undefined;
var last_error_len: usize = 0;

const not_here = "the OS boundary is built on Windows only; the Linux half is HAROBANDA-WORKER-01";

fn setGlobalError(comptime f: []const u8, a: anytype) void {
    const s = std.fmt.bufPrint(&last_error, f, a) catch last_error[0..0];
    last_error_len = s.len;
}

fn setError(s: *Slot, comptime f: []const u8, a: anytype) void {
    const t = std.fmt.bufPrint(&s.error_text, f, a) catch s.error_text[0..0];
    s.error_len = t.len;
}

fn slotOf(id: i64) ?*Slot {
    if (id < 1 or id > MAX_SLOTS) {
        setGlobalError("no grant {d}", .{id});
        return null;
    }
    const s = &slots[@intCast(id - 1)];
    if (!s.used) {
        setGlobalError("no grant {d}", .{id});
        return null;
    }
    return s;
}

// an AppContainer name: 1 to 64 of letters, digits, '.', '-', '_'
pub fn validName(name: []const u8) bool {
    if (name.len == 0 or name.len > 64) return false;
    for (name) |c| {
        if (!(std.ascii.isAlphanumeric(c) or c == '.' or c == '-' or c == '_')) return false;
    }
    return true;
}

// --- the grant ------------------------------------------------------------------------------------------------------

pub fn new(name: []const u8) i64 {
    if (!validName(name)) {
        setGlobalError("a grant's name is 1 to 64 letters, digits, '.', '-' or '_'; got '{s}'", .{name[0..@min(name.len, 80)]});
        return 0;
    }
    for (&slots, 0..) |*s, i| {
        if (s.used) continue;
        s.* = .{};
        s.used = true;
        @memcpy(s.name[0..name.len], name);
        s.name_len = name.len;
        return @intCast(i + 1);
    }
    setGlobalError("all {d} grants are in use; free one first", .{MAX_SLOTS});
    return 0;
}

fn addPath(s: *Slot, list: *[MAX_PATHS][]u8, n: *usize, path: []const u8) bool {
    if (s.started) {
        setError(s, "the grant is fixed once its run has started", .{});
        return false;
    }
    if (path.len == 0 or path.len > 1000) {
        setError(s, "a path is 1 to 1000 bytes", .{});
        return false;
    }
    if (n.* >= MAX_PATHS) {
        setError(s, "a grant holds at most {d} paths of each kind", .{MAX_PATHS});
        return false;
    }
    list[n.*] = alloc.dupe(u8, path) catch return false;
    n.* += 1;
    return true;
}

pub fn addRead(id: i64, path: []const u8) bool {
    const s = slotOf(id) orelse return false;
    return addPath(s, &s.reads, &s.nreads, path);
}

pub fn addWrite(id: i64, path: []const u8) bool {
    const s = slotOf(id) orelse return false;
    return addPath(s, &s.writes, &s.nwrites, path);
}

pub fn setNetwork(id: i64, on: bool) bool {
    const s = slotOf(id) orelse return false;
    if (s.started) return false;
    s.network = on;
    return true;
}

pub fn setChildren(id: i64, n: i64) bool {
    const s = slotOf(id) orelse return false;
    if (s.started or n < 0 or n > 64) return false;
    s.children = @intCast(n);
    return true;
}

pub fn setMemory(id: i64, mb: i64) bool {
    const s = slotOf(id) orelse return false;
    if (s.started or mb < 16 or mb > 1 << 20) return false;
    s.memory_mb = @intCast(mb);
    return true;
}

pub fn setProcessor(id: i64, seconds: f64) bool {
    const s = slotOf(id) orelse return false;
    if (s.started or seconds < 0) return false;
    s.processor_s = seconds;
    return true;
}

pub fn setOutput(id: i64, out: []const u8, err: []const u8) bool {
    const s = slotOf(id) orelse return false;
    if (s.started) return false;
    s.out = if (out.len > 0) (alloc.dupe(u8, out) catch return false) else null;
    s.err = if (err.len > 0) (alloc.dupe(u8, err) catch return false) else null;
    return true;
}

pub fn free(id: i64) bool {
    const s = slotOf(id) orelse return false;
    if (is_windows) win.release(s);
    for (s.reads[0..s.nreads]) |p| alloc.free(p);
    for (s.writes[0..s.nwrites]) |p| alloc.free(p);
    if (s.out) |o| alloc.free(o);
    if (s.err) |e| alloc.free(e);
    s.* = .{};
    return true;
}

// --- the run --------------------------------------------------------------------------------------------------------

pub fn start(id: i64, cmdline: []const u8) i64 {
    const s = slotOf(id) orelse return 0;
    if (!is_windows) {
        setError(s, not_here, .{});
        return 0;
    }
    if (s.started) {
        setError(s, "a grant runs once; make a new grant for the next run", .{});
        return 0;
    }
    return win.start(s, cmdline);
}

// -> 1 the run has ended, 0 it is still running after ms milliseconds
pub fn wait(id: i64, ms: i64) i64 {
    const s = slotOf(id) orelse return 0;
    if (!is_windows or !s.started) return 0;
    if (s.ended) return 1;
    return win.wait(s, if (ms < 0) 0xFFFFFFFF else @intCast(@min(ms, 0xFFFFFFFE)));
}

// ends the whole job now; -> 1 when it was running
pub fn end(id: i64) i64 {
    const s = slotOf(id) orelse return 0;
    if (!is_windows or !s.started or s.ended) return 0;
    win.endJob(s);
    _ = win.wait(s, 5000);
    return 1;
}

pub fn pid(id: i64) i64 {
    const s = slotOf(id) orelse return 0;
    return s.pid;
}

pub fn exitCode(id: i64) f64 {
    const s = slotOf(id) orelse return -1;
    if (!s.ended) return -1;
    return @floatFromInt(s.exit_code);
}

pub fn peakMb(id: i64) f64 {
    const s = slotOf(id) orelse return 0;
    return s.peak_mb;
}

pub fn wallMs(id: i64) f64 {
    const s = slotOf(id) orelse return 0;
    return s.wall_ms;
}

pub fn grantMs(id: i64) f64 {
    const s = slotOf(id) orelse return 0;
    return s.grant_ms;
}

// how many paths start() wrote a rule on (a path already carrying the rule is not counted)
pub fn grantedCount(id: i64) i64 {
    const s = slotOf(id) orelse return 0;
    return s.granted;
}

pub fn msgName(m: u32) []const u8 {
    return switch (m) {
        1 => "END_OF_JOB_TIME",
        2 => "END_OF_PROCESS_TIME",
        3 => "ACTIVE_PROCESS_LIMIT",
        4 => "ACTIVE_PROCESS_ZERO",
        6 => "NEW_PROCESS",
        7 => "EXIT_PROCESS",
        8 => "ABNORMAL_EXIT_PROCESS",
        9 => "PROCESS_MEMORY_LIMIT",
        10 => "JOB_MEMORY_LIMIT",
        11 => "NOTIFICATION_LIMIT",
        12 => "JOB_CYCLE_TIME_LIMIT",
        13 => "SILO_TERMINATED",
        else => "UNKNOWN",
    };
}

// the job's messages in order, comma-separated: "NEW_PROCESS,JOB_MEMORY_LIMIT,EXIT_PROCESS,ACTIVE_PROCESS_ZERO"
pub fn messages(id: i64, out: []u8) []u8 {
    const s = slotOf(id) orelse return out[0..0];
    var n: usize = 0;
    for (s.msgs[0..s.nmsg], 0..) |m, i| {
        const name = msgName(m);
        const sep: usize = if (i > 0) 1 else 0;
        if (n + sep + name.len > out.len) break;
        if (sep == 1) {
            out[n] = ',';
            n += 1;
        }
        @memcpy(out[n .. n + name.len], name);
        n += name.len;
    }
    return out[0..n];
}

pub fn errorText(id: i64) []const u8 {
    if (id == 0) return last_error[0..last_error_len];
    const s = slotOf(id) orelse return last_error[0..last_error_len];
    return s.error_text[0..s.error_len];
}

// --- outside a grant: the rules a profile leaves on disk ------------------------------------------------------------

// -> 1 when the path's access list names the container (an explicit or an inherited rule), 0 when not, -1 on error
pub fn hasRule(name: []const u8, path: []const u8) i64 {
    if (!is_windows) {
        setGlobalError(not_here, .{});
        return -1;
    }
    return win.hasRule(name, path);
}

// removes every rule naming the container from the path and its tree; -> 0 or the Windows error
pub fn revoke(name: []const u8, path: []const u8) i64 {
    if (!is_windows) {
        setGlobalError(not_here, .{});
        return -1;
    }
    return win.revoke(name, path);
}

// deletes the AppContainer profile; -> 0 or the HRESULT
pub fn deleteProfile(name: []const u8) i64 {
    if (!is_windows) {
        setGlobalError(not_here, .{});
        return -1;
    }
    if (!validName(name)) return -1;
    return win.deleteProfile(name);
}

// --- Windows --------------------------------------------------------------------------------------------------------

const win = if (is_windows) struct {
    const PVOID = ?*anyopaque;
    const HANDLE = ?*anyopaque;
    const INVALID: usize = std.math.maxInt(usize);

    const SID_AND_ATTRIBUTES = extern struct { sid: PVOID, attributes: u32 };
    const SECURITY_CAPABILITIES = extern struct { container: PVOID, caps: ?[*]SID_AND_ATTRIBUTES, count: u32, reserved: u32 };
    const STARTUPINFOW = extern struct {
        cb: u32,
        reserved: ?[*:0]u16 = null,
        desktop: ?[*:0]u16 = null,
        title: ?[*:0]u16 = null,
        x: u32 = 0,
        y: u32 = 0,
        xsize: u32 = 0,
        ysize: u32 = 0,
        xchars: u32 = 0,
        ychars: u32 = 0,
        fill: u32 = 0,
        flags: u32 = 0,
        show: u16 = 0,
        reserved2n: u16 = 0,
        reserved2: PVOID = null,
        stdin: HANDLE = null,
        stdout: HANDLE = null,
        stderr: HANDLE = null,
    };
    const STARTUPINFOEXW = extern struct { si: STARTUPINFOW, attrs: PVOID };
    const PROCESS_INFORMATION = extern struct { process: HANDLE, thread: HANDLE, pid: u32, tid: u32 };
    const SECURITY_ATTRIBUTES = extern struct { len: u32, sd: PVOID, inherit: i32 };
    const TRUSTEE_W = extern struct { multiple: PVOID = null, op: i32 = 0, form: i32, ttype: i32, name: PVOID };
    const EXPLICIT_ACCESS_W = extern struct { access: u32, mode: i32, inherit: u32, trustee: TRUSTEE_W };
    const BASIC_LIMIT = extern struct {
        per_process_time: i64 = 0,
        per_job_time: i64 = 0,
        flags: u32 = 0,
        min_ws: usize = 0,
        max_ws: usize = 0,
        active: u32 = 0,
        affinity: usize = 0,
        priority: u32 = 0,
        scheduling: u32 = 0,
    };
    const EXT_LIMIT = extern struct {
        basic: BASIC_LIMIT = .{},
        io: [6]u64 = [_]u64{0} ** 6,
        process_mem: usize = 0,
        job_mem: usize = 0,
        peak_process_mem: usize = 0,
        peak_job_mem: usize = 0,
    };
    const PORT_ASSOC = extern struct { key: PVOID, port: HANDLE };
    const ACL_SIZE_INFO = extern struct { count: u32, used: u32, free: u32 };
    const ACE_HEADER = extern struct { type: u8, flags: u8, size: u16 };

    extern "kernel32" fn CreateFileW(n: [*:0]const u16, a: u32, s: u32, sa: ?*SECURITY_ATTRIBUTES, d: u32, f: u32, t: HANDLE) callconv(.winapi) usize;
    extern "kernel32" fn CloseHandle(h: HANDLE) callconv(.winapi) i32;
    extern "kernel32" fn GetLastError() callconv(.winapi) u32;
    extern "kernel32" fn GetFileAttributesW(n: [*:0]const u16) callconv(.winapi) u32;
    extern "kernel32" fn CreateProcessW(app: ?[*:0]const u16, cmd: [*:0]u16, pa: PVOID, ta: PVOID, inh: i32, flags: u32, env: PVOID, dir: ?[*:0]const u16, si: *anyopaque, pi: *PROCESS_INFORMATION) callconv(.winapi) i32;
    extern "kernel32" fn InitializeProcThreadAttributeList(l: PVOID, n: u32, f: u32, size: *usize) callconv(.winapi) i32;
    extern "kernel32" fn UpdateProcThreadAttribute(l: PVOID, f: u32, attr: usize, v: *anyopaque, size: usize, prev: PVOID, ret: PVOID) callconv(.winapi) i32;
    extern "kernel32" fn DeleteProcThreadAttributeList(l: PVOID) callconv(.winapi) void;
    extern "kernel32" fn CreateJobObjectW(sa: PVOID, name: ?[*:0]const u16) callconv(.winapi) HANDLE;
    extern "kernel32" fn SetInformationJobObject(j: HANDLE, c: u32, info: *anyopaque, n: u32) callconv(.winapi) i32;
    extern "kernel32" fn QueryInformationJobObject(j: HANDLE, c: u32, info: *anyopaque, n: u32, ret: ?*u32) callconv(.winapi) i32;
    extern "kernel32" fn AssignProcessToJobObject(j: HANDLE, p: HANDLE) callconv(.winapi) i32;
    extern "kernel32" fn TerminateJobObject(j: HANDLE, code: u32) callconv(.winapi) i32;
    extern "kernel32" fn TerminateProcess(h: HANDLE, code: u32) callconv(.winapi) i32;
    extern "kernel32" fn ResumeThread(t: HANDLE) callconv(.winapi) u32;
    extern "kernel32" fn WaitForSingleObject(h: HANDLE, ms: u32) callconv(.winapi) u32;
    extern "kernel32" fn GetExitCodeProcess(h: HANDLE, code: *u32) callconv(.winapi) i32;
    extern "kernel32" fn CreateIoCompletionPort(f: usize, p: HANDLE, key: usize, n: u32) callconv(.winapi) HANDLE;
    extern "kernel32" fn GetQueuedCompletionStatus(p: HANDLE, n: *u32, key: *usize, o: *PVOID, ms: u32) callconv(.winapi) i32;
    extern "kernel32" fn LocalFree(p: PVOID) callconv(.winapi) PVOID;
    extern "userenv" fn CreateAppContainerProfile(n: [*:0]const u16, d: [*:0]const u16, desc: [*:0]const u16, caps: PVOID, cn: u32, sid: *PVOID) callconv(.winapi) i32;
    extern "userenv" fn DeleteAppContainerProfile(n: [*:0]const u16) callconv(.winapi) i32;
    extern "userenv" fn DeriveAppContainerSidFromAppContainerName(n: [*:0]const u16, sid: *PVOID) callconv(.winapi) i32;
    extern "advapi32" fn FreeSid(s: PVOID) callconv(.winapi) PVOID;
    extern "advapi32" fn EqualSid(a: PVOID, b: PVOID) callconv(.winapi) i32;
    extern "advapi32" fn CreateWellKnownSid(t: u32, dom: PVOID, sid: *anyopaque, size: *u32) callconv(.winapi) i32;
    extern "advapi32" fn GetNamedSecurityInfoW(n: [*:0]const u16, t: u32, i: u32, o: PVOID, g: PVOID, dacl: *PVOID, sacl: PVOID, sd: *PVOID) callconv(.winapi) u32;
    extern "advapi32" fn SetNamedSecurityInfoW(n: [*:0]const u16, t: u32, i: u32, o: PVOID, g: PVOID, dacl: PVOID, sacl: PVOID) callconv(.winapi) u32;
    extern "advapi32" fn SetEntriesInAclW(n: u32, ea: *EXPLICIT_ACCESS_W, old: PVOID, new: *PVOID) callconv(.winapi) u32;
    extern "advapi32" fn GetAclInformation(acl: PVOID, info: *anyopaque, n: u32, class: u32) callconv(.winapi) i32;
    extern "advapi32" fn GetAce(acl: PVOID, i: u32, ace: *PVOID) callconv(.winapi) i32;

    const GENERIC_READ: u32 = 0x80000000;
    const GENERIC_WRITE: u32 = 0x40000000;
    const GENERIC_EXECUTE: u32 = 0x20000000;
    const GENERIC_ALL: u32 = 0x10000000;
    // what the generic rights become once written on a file object: what an existing rule is compared against
    const FILE_READ_EXECUTE: u32 = 0x1200A9;
    const FILE_ALL: u32 = 0x1F01FF;

    // a rule may keep its generic bits (an inherit-only rule does); read them as what they mean on a file
    fn mapGeneric(m: u32) u32 {
        var r = m & 0x0FFFFFFF;
        if (m & GENERIC_ALL != 0) r |= FILE_ALL;
        if (m & GENERIC_READ != 0) r |= 0x120089;
        if (m & GENERIC_EXECUTE != 0) r |= 0x1200A0;
        if (m & GENERIC_WRITE != 0) r |= 0x120116;
        return r;
    }

    fn w(s: []const u8) ?[:0]u16 {
        return std.unicode.utf8ToUtf16LeAllocZ(alloc, s) catch null;
    }

    fn containerSid(name: []const u8, create: bool) ?PVOID {
        const n = w(name) orelse return null;
        defer alloc.free(n);
        var sid: PVOID = null;
        if (create) {
            if (CreateAppContainerProfile(n, n, n, null, 0, &sid) == 0) return sid;
        }
        if (DeriveAppContainerSidFromAppContainerName(n, &sid) == 0) return sid;
        return null;
    }

    fn isDir(p: [:0]const u16) ?bool {
        const a = GetFileAttributesW(p);
        if (a == 0xFFFFFFFF) return null;
        return (a & 0x10) != 0;
    }

    // -> the access mask the path's list gives the SID (0 when it names it nowhere), or null when it cannot be read
    fn ruleMask(p: [:0]const u16, sid: PVOID) ?u32 {
        var dacl: PVOID = null;
        var sd: PVOID = null;
        if (GetNamedSecurityInfoW(p, 1, 4, null, null, &dacl, null, &sd) != 0) return null;
        defer _ = LocalFree(sd);
        if (dacl == null) return 0;
        var info: ACL_SIZE_INFO = undefined;
        if (GetAclInformation(dacl, &info, @sizeOf(ACL_SIZE_INFO), 2) == 0) return null;
        var mask: u32 = 0;
        var i: u32 = 0;
        while (i < info.count) : (i += 1) {
            var ace: PVOID = null;
            if (GetAce(dacl, i, &ace) == 0) continue;
            const hdr: *const ACE_HEADER = @ptrCast(@alignCast(ace));
            if (hdr.type != 0) continue; // ACCESS_ALLOWED_ACE only
            const base: [*]u8 = @ptrCast(ace);
            const ace_mask = std.mem.readInt(u32, base[4..8], .little);
            if (EqualSid(@ptrCast(base + 8), sid) != 0) mask |= mapGeneric(ace_mask);
        }
        return mask;
    }

    fn setRule(p: [:0]const u16, sid: PVOID, access: u32, mode: i32, dir: bool) u32 {
        var old: PVOID = null;
        var sd: PVOID = null;
        var r = GetNamedSecurityInfoW(p, 1, 4, null, null, &old, null, &sd);
        if (r != 0) return r;
        defer _ = LocalFree(sd);
        var ea = EXPLICIT_ACCESS_W{ .access = access, .mode = mode, .inherit = if (dir) 3 else 0, .trustee = .{ .form = 0, .ttype = 5, .name = sid } };
        var new_acl: PVOID = null;
        r = SetEntriesInAclW(1, &ea, old, &new_acl);
        if (r == 0) r = SetNamedSecurityInfoW(p, 1, 4, null, null, new_acl, null);
        _ = LocalFree(new_acl);
        return r;
    }

    // grants the path unless its list already gives the SID that access; -> 0 left alone, 1 written, or an error
    fn ensure(s: *Slot, path: []const u8, sid: PVOID, write: bool) ?u1 {
        const p = w(path) orelse return null;
        defer alloc.free(p);
        const dir = isDir(p) orelse {
            setError(s, "the granted path does not exist: {s}", .{path[0..@min(path.len, 200)]});
            return null;
        };
        const want: u32 = if (write) FILE_ALL else FILE_READ_EXECUTE;
        const have = ruleMask(p, sid) orelse 0;
        if (have & want == want) return 0;
        const access: u32 = if (write) GENERIC_ALL else GENERIC_READ | GENERIC_EXECUTE;
        const r = setRule(p, sid, access, 1, dir);
        if (r != 0) {
            setError(s, "granting {s} failed: Windows error {d}", .{ path[0..@min(path.len, 200)], r });
            return null;
        }
        return 1;
    }

    fn openStd(path: ?[]u8, write: bool) usize {
        var sa = SECURITY_ATTRIBUTES{ .len = @sizeOf(SECURITY_ATTRIBUTES), .sd = null, .inherit = 1 };
        const target = path orelse "NUL";
        const p = w(target) orelse return INVALID;
        defer alloc.free(p);
        if (write) return CreateFileW(p, GENERIC_WRITE, 3, &sa, 2, 0x80, null); // share read+write, create always
        return CreateFileW(p, GENERIC_READ, 3, &sa, 3, 0x80, null);
    }

    fn elapsedMs(t0: std.time.Instant) f64 {
        const now = std.time.Instant.now() catch return 0;
        return @as(f64, @floatFromInt(now.since(t0))) / 1e6;
    }

    fn start(s: *Slot, cmdline: []const u8) i64 {
        const t_grant = std.time.Instant.now() catch null;
        const sid = containerSid(s.name[0..s.name_len], true) orelse {
            setError(s, "the AppContainer profile '{s}' could not be created or found", .{s.name[0..s.name_len]});
            return 0;
        };
        defer _ = FreeSid(sid);

        for (s.reads[0..s.nreads]) |p| {
            const r = ensure(s, p, sid, false) orelse return 0;
            s.granted += r;
        }
        for (s.writes[0..s.nwrites]) |p| {
            const r = ensure(s, p, sid, true) orelse return 0;
            s.granted += r;
        }
        if (t_grant) |t| s.grant_ms = elapsedMs(t);

        // the capabilities: internetClient when the grant asks for the network
        var caps: [1]SID_AND_ATTRIBUTES = undefined;
        var capsid: [68]u8 align(8) = undefined;
        var sc = SECURITY_CAPABILITIES{ .container = sid, .caps = null, .count = 0, .reserved = 0 };
        if (s.network) {
            var n: u32 = capsid.len;
            if (CreateWellKnownSid(86, null, &capsid, &n) == 0) {
                setError(s, "the internetClient capability could not be built: Windows error {d}", .{GetLastError()});
                return 0;
            }
            caps[0] = .{ .sid = &capsid, .attributes = 4 };
            sc.caps = &caps;
            sc.count = 1;
        }

        // the three standard handles, and ONLY they are inherited
        const h_in = openStd(null, false);
        const h_out = openStd(s.out, true);
        const same = s.err != null and s.out != null and std.mem.eql(u8, s.err.?, s.out.?);
        const h_err = if (same) h_out else openStd(s.err, true);
        defer {
            _ = CloseHandle(@ptrFromInt(h_in));
            _ = CloseHandle(@ptrFromInt(h_out));
            if (!same) _ = CloseHandle(@ptrFromInt(h_err));
        }
        if (h_in == INVALID or h_out == INVALID or h_err == INVALID) {
            setError(s, "the output files could not be opened: Windows error {d}", .{GetLastError()});
            return 0;
        }
        var inherit: [3]HANDLE = .{ @ptrFromInt(h_in), @ptrFromInt(h_out), @ptrFromInt(h_err) };
        const ninherit: usize = if (same) 2 else 3;

        var size: usize = 0;
        _ = InitializeProcThreadAttributeList(null, 2, 0, &size);
        const list = alloc.alignedAlloc(u8, .@"8", size) catch return 0;
        defer alloc.free(list);
        if (InitializeProcThreadAttributeList(list.ptr, 2, 0, &size) == 0) {
            setError(s, "InitializeProcThreadAttributeList: Windows error {d}", .{GetLastError()});
            return 0;
        }
        defer DeleteProcThreadAttributeList(list.ptr);
        if (UpdateProcThreadAttribute(list.ptr, 0, 0x00020009, &sc, @sizeOf(SECURITY_CAPABILITIES), null, null) == 0 or
            UpdateProcThreadAttribute(list.ptr, 0, 0x00020002, @ptrCast(&inherit), ninherit * @sizeOf(HANDLE), null, null) == 0)
        {
            setError(s, "UpdateProcThreadAttribute: Windows error {d}", .{GetLastError()});
            return 0;
        }

        const cmd = w(cmdline) orelse return 0;
        defer alloc.free(cmd);

        // the job: kill on close, die on an unhandled exception, the active-process, memory and processor limits
        const job = CreateJobObjectW(null, null) orelse {
            setError(s, "CreateJobObject: Windows error {d}", .{GetLastError()});
            return 0;
        };
        var ext = EXT_LIMIT{};
        ext.basic.flags = 0x2000 | 0x400 | 0x8 | 0x200;
        ext.basic.active = 1 + s.children;
        ext.job_mem = s.memory_mb << 20;
        if (s.processor_s > 0) {
            ext.basic.flags |= 0x4;
            ext.basic.per_job_time = @intFromFloat(s.processor_s * 10_000_000.0);
        }
        const port = CreateIoCompletionPort(INVALID, null, 0, 1);
        var assoc = PORT_ASSOC{ .key = job, .port = port };
        if (SetInformationJobObject(job, 9, &ext, @sizeOf(EXT_LIMIT)) == 0 or port == null or
            SetInformationJobObject(job, 7, &assoc, @sizeOf(PORT_ASSOC)) == 0)
        {
            setError(s, "the job's limits could not be set: Windows error {d}", .{GetLastError()});
            _ = CloseHandle(job);
            if (port != null) _ = CloseHandle(port);
            return 0;
        }

        var si = STARTUPINFOEXW{ .si = .{ .cb = @sizeOf(STARTUPINFOEXW), .flags = 0x100, .stdin = inherit[0], .stdout = inherit[1], .stderr = if (same) inherit[1] else inherit[2] }, .attrs = list.ptr };
        var pi: PROCESS_INFORMATION = undefined;
        s.t0 = std.time.Instant.now() catch null;
        // extended startup info, suspended until it is in the job, no console window
        if (CreateProcessW(null, cmd.ptr, null, null, 1, 0x00080000 | 0x4 | 0x08000000, null, null, &si, &pi) == 0) {
            setError(s, "the process could not be started inside the boundary: Windows error {d}", .{GetLastError()});
            _ = CloseHandle(job);
            _ = CloseHandle(port);
            return 0;
        }
        if (AssignProcessToJobObject(job, pi.process) == 0) {
            setError(s, "the process could not be put in its job: Windows error {d}", .{GetLastError()});
            _ = TerminateProcess(pi.process, 1);
            _ = CloseHandle(pi.thread);
            _ = CloseHandle(pi.process);
            _ = CloseHandle(job);
            _ = CloseHandle(port);
            return 0;
        }
        _ = ResumeThread(pi.thread);
        _ = CloseHandle(pi.thread);
        s.process = pi.process;
        s.job = job;
        s.port = port;
        s.pid = pi.pid;
        s.started = true;
        return pi.pid;
    }

    fn drain(s: *Slot, ms: u32) void {
        while (true) {
            var msg: u32 = 0;
            var key: usize = 0;
            var o: PVOID = null;
            if (GetQueuedCompletionStatus(s.port, &msg, &key, &o, ms) == 0) return;
            if (s.nmsg < MAX_MSGS) {
                s.msgs[s.nmsg] = msg;
                s.nmsg += 1;
            }
            if (msg == 4) return; // ACTIVE_PROCESS_ZERO: the job is empty, nothing follows
        }
    }

    fn wait(s: *Slot, ms: u32) i64 {
        if (WaitForSingleObject(s.process, ms) != 0) {
            drain(s, 0);
            return 0;
        }
        if (s.t0) |t| s.wall_ms = elapsedMs(t);
        var code: u32 = 0;
        _ = GetExitCodeProcess(s.process, &code);
        s.exit_code = code;
        var q = EXT_LIMIT{};
        if (QueryInformationJobObject(s.job, 9, &q, @sizeOf(EXT_LIMIT), null) != 0) s.peak_mb = @as(f64, @floatFromInt(q.peak_job_mem)) / 1048576.0;
        drain(s, 200);
        s.ended = true;
        return 1;
    }

    fn endJob(s: *Slot) void {
        _ = TerminateJobObject(s.job, 0xC000013A);
    }

    fn release(s: *Slot) void {
        if (s.process != null) _ = CloseHandle(s.process);
        if (s.job != null) _ = CloseHandle(s.job); // kill on close: nothing the grant started outlives it
        if (s.port != null) _ = CloseHandle(s.port);
        s.process = null;
        s.job = null;
        s.port = null;
    }

    fn hasRule(name: []const u8, path: []const u8) i64 {
        if (!validName(name)) return -1;
        const sid = containerSid(name, false) orelse return -1;
        defer _ = FreeSid(sid);
        const p = w(path) orelse return -1;
        defer alloc.free(p);
        const m = ruleMask(p, sid) orelse return -1;
        return if (m != 0) 1 else 0;
    }

    fn revoke(name: []const u8, path: []const u8) i64 {
        if (!validName(name)) return -1;
        const sid = containerSid(name, false) orelse return -1;
        defer _ = FreeSid(sid);
        const p = w(path) orelse return -1;
        defer alloc.free(p);
        const dir = isDir(p) orelse return 2; // ERROR_FILE_NOT_FOUND
        return setRule(p, sid, 0, 4, dir); // REVOKE_ACCESS
    }

    fn deleteProfile(name: []const u8) i64 {
        const n = w(name) orelse return -1;
        defer alloc.free(n);
        return DeleteAppContainerProfile(n);
    }
} else struct {
    fn release(_: *Slot) void {}
    fn start(_: *Slot, _: []const u8) i64 {
        return 0;
    }
    fn wait(_: *Slot, _: u32) i64 {
        return 0;
    }
    fn endJob(_: *Slot) void {}
    fn hasRule(_: []const u8, _: []const u8) i64 {
        return -1;
    }
    fn revoke(_: []const u8, _: []const u8) i64 {
        return -1;
    }
    fn deleteProfile(_: []const u8) i64 {
        return -1;
    }
};

// --- tests (no process is started: the grant's checks only) --------------------------------------------------------

test "boundary: a name is letters, digits, '.', '-', '_'" {
    try std.testing.expect(validName("stz.node-1_a"));
    try std.testing.expect(!validName(""));
    try std.testing.expect(!validName("has space"));
    try std.testing.expect(!validName("a" ** 65));
}

test "boundary: a grant is built, refuses a second start once fixed, and frees" {
    const id = new("stz.unit");
    try std.testing.expect(id > 0);
    try std.testing.expect(addRead(id, "C:\\x"));
    try std.testing.expect(!addRead(id, ""));
    try std.testing.expect(setChildren(id, 0));
    try std.testing.expect(!setChildren(id, -1));
    try std.testing.expect(!setMemory(id, 1));
    try std.testing.expect(free(id));
    try std.testing.expect(!free(id));
}

test "boundary: the job messages read as names" {
    try std.testing.expectEqualStrings("JOB_MEMORY_LIMIT", msgName(10));
    try std.testing.expectEqualStrings("END_OF_JOB_TIME", msgName(1));
}
