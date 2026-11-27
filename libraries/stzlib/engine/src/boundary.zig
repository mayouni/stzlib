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
// handle the supervisor holds. Its environment is the supervisor's whole environment, UNLESS the grant keeps a list
// (keepEnv, threat model R20): then the node gets SystemRoot, TEMP, TMP and LOCALAPPDATA (the last three rewritten by
// Windows to the container's own folder) and the kept names the supervisor holds, and nothing else,
// so a credential held in the supervisor's environment stays out of the node. A grant is applied once per path: a folder whose
// access list already names the container with the access asked is left alone, so the 2.5 to 4 s a library tree
// costs is paid at the first start and not on each one.
//
// A SHARED CAPABILITY (rung B4). A trustee written "cap:<name>" is the capability SID Windows derives from <name>
// (DeriveCapabilitySidsFromName). grantPath, hasRule, revoke and rulesLeft take it where they take a profile, and a
// grant carries it with addCapability: one rule on a shared tree for "cap:stz.library" serves every node whose token
// holds that capability, so a node's own profile is granted only its own folders.
//
// Other systems: every call answers 0 with the reason in error(); the Linux half is HAROBANDA-WORKER-01.

const std = @import("std");
const builtin = @import("builtin");

const is_windows = builtin.os.tag == .windows;
const alloc = std.heap.page_allocator;

pub const MAX_SLOTS = 16;
pub const MAX_PATHS = 32;
pub const MAX_MSGS = 32;
pub const MAX_CAPS = 4;
pub const MAX_KEEPS = 32;

const Slot = struct {
    used: bool = false,
    name: [64]u8 = undefined,
    name_len: usize = 0,
    reads: [MAX_PATHS][]u8 = undefined,
    nreads: usize = 0,
    writes: [MAX_PATHS][]u8 = undefined,
    nwrites: usize = 0,
    network: bool = false,
    caps: [MAX_CAPS][64]u8 = undefined,
    cap_lens: [MAX_CAPS]usize = undefined,
    ncaps: usize = 0,
    env_on: bool = false,
    keeps: [MAX_KEEPS][]u8 = undefined,
    nkeeps: usize = 0,
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
// a trustee is a profile name, or "cap:" and a capability name of the same alphabet
pub fn validTrustee(name: []const u8) bool {
    if (std.mem.startsWith(u8, name, "cap:")) return validName(name[4..]);
    return validName(name);
}

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

// adds a capability to the node's token (rung B4); -> false past MAX_CAPS or for a bad name
pub fn addCapability(id: i64, name: []const u8) bool {
    const s = slotOf(id) orelse return false;
    if (s.started) return false;
    if (!validName(name)) {
        setError(s, "a capability's name is 1 to 64 letters, digits, '.', '-' or '_'", .{});
        return false;
    }
    if (s.ncaps >= MAX_CAPS) {
        setError(s, "a grant carries at most {d} capabilities", .{MAX_CAPS});
        return false;
    }
    @memcpy(s.caps[s.ncaps][0..name.len], name);
    s.cap_lens[s.ncaps] = name.len;
    s.ncaps += 1;
    return true;
}

pub fn setNetwork(id: i64, on: bool) bool {
    const s = slotOf(id) orelse return false;
    if (s.started) return false;
    s.network = on;
    return true;
}

// R20: the node's environment becomes SystemRoot, TEMP, TMP, LOCALAPPDATA and the names kept. The first call switches the filter on; a name ""
// switches it on and keeps nothing more. A name is 1 to 128 of letters, digits, '_', '.', '-', '(' and ')'.
pub fn keepEnv(id: i64, name: []const u8) bool {
    const s = slotOf(id) orelse return false;
    if (s.started) {
        setError(s, "the grant is fixed once its run has started", .{});
        return false;
    }
    s.env_on = true;
    if (name.len == 0) return true;
    if (name.len > 128) {
        setError(s, "a variable's name is 1 to 128 bytes", .{});
        return false;
    }
    for (name) |c| {
        if (!(std.ascii.isAlphanumeric(c) or c == '_' or c == '.' or c == '-' or c == '(' or c == ')')) {
            setError(s, "a variable's name is letters, digits, '_', '.', '-', '(' or ')'", .{});
            return false;
        }
    }
    if (s.nkeeps >= MAX_KEEPS) {
        setError(s, "a grant keeps at most {d} variables", .{MAX_KEEPS});
        return false;
    }
    s.keeps[s.nkeeps] = alloc.dupe(u8, name) catch return false;
    s.nkeeps += 1;
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
    for (s.keeps[0..s.nkeeps]) |k| alloc.free(k);
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
    if (!validTrustee(name)) return -1;
    if (!is_windows) {
        setGlobalError(not_here, .{});
        return -1;
    }
    return win.hasRule(name, path);
}

// removes every rule naming the container from the path and its tree; -> 0 or the Windows error
pub fn revoke(name: []const u8, path: []const u8) i64 {
    if (!validTrustee(name)) return -1;
    if (!is_windows) {
        setGlobalError(not_here, .{});
        return -1;
    }
    return win.revoke(name, path);
}

// --- install and removal (rung B2) ----------------------------------------------------------------------------------

// creates the AppContainer profile; -> 1 created, 0 it already existed, -1 refused (error(0) says why)
pub fn ensureProfile(name: []const u8) i64 {
    if (!is_windows) {
        setGlobalError(not_here, .{});
        return -1;
    }
    if (!validName(name)) {
        setGlobalError("a profile's name is 1 to 64 letters, digits, '.', '-' or '_'", .{});
        return -1;
    }
    return win.ensureProfile(name);
}

// grants one path to the container without starting anything: the shared trees an install grants once.
// -> 1 the rule was written, 0 the path already gave that access, -1 refused (error(0) says why)
pub fn grantPath(name: []const u8, path: []const u8, write: bool) i64 {
    if (!is_windows) {
        setGlobalError(not_here, .{});
        return -1;
    }
    if (!validTrustee(name)) {
        setGlobalError("a trustee is a profile name, or cap: and a capability name, of 1 to 64 letters, digits, '.', '-' or '_'", .{});
        return -1;
    }
    return win.grantPath(name, path, write);
}

var walked: i64 = 0;

// walks the path's tree and counts the entries whose access list still names the container, examining at most
// max entries (0: all). -> the count, or -1 when the path cannot be read. walkedCount() says how many were examined.
pub fn rulesLeft(name: []const u8, path: []const u8, max: i64) i64 {
    walked = 0;
    if (!is_windows) {
        setGlobalError(not_here, .{});
        return -1;
    }
    if (!validTrustee(name)) return -1;
    return win.rulesLeft(name, path, max);
}

pub fn walkedCount() i64 {
    return walked;
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
    extern "kernel32" fn GetEnvironmentVariableW(n: [*:0]const u16, buf: ?[*]u16, size: u32) callconv(.winapi) u32;
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
    extern "advapi32" fn GetLengthSid(sid: PVOID) callconv(.winapi) u32;
    extern "advapi32" fn CopySid(n: u32, dst: PVOID, src: PVOID) callconv(.winapi) i32;
    extern "kernel32" fn GetModuleHandleW(n: [*:0]const u16) callconv(.winapi) ?*anyopaque;
    extern "kernel32" fn LoadLibraryW(n: [*:0]const u16) callconv(.winapi) ?*anyopaque;
    extern "kernel32" fn GetProcAddress(m: ?*anyopaque, n: [*:0]const u8) callconv(.winapi) ?*anyopaque;

    // kernelbase's DeriveCapabilitySidsFromName, found at run time (no import library carries it)
    const DeriveCapFn = *const fn (name: [*:0]const u16, groups: *?[*]PVOID, ngroups: *u32, caps: *?[*]PVOID, ncaps: *u32) callconv(.winapi) i32;
    var derive_cap: ?DeriveCapFn = null;

    fn deriveCapFn() ?DeriveCapFn {
        if (derive_cap) |f| return f;
        const kb = std.unicode.utf8ToUtf16LeStringLiteral("kernelbase.dll");
        const m = GetModuleHandleW(kb) orelse LoadLibraryW(kb) orelse return null;
        const f = GetProcAddress(m, "DeriveCapabilitySidsFromName") orelse return null;
        derive_cap = @ptrCast(f);
        return derive_cap;
    }

    // the capability SID of a name, copied into memory this module owns
    fn capabilitySid(name: []const u8) ?[]u8 {
        const f = deriveCapFn() orelse {
            setGlobalError("DeriveCapabilitySidsFromName is not on this Windows", .{});
            return null;
        };
        const n = w(name) orelse return null;
        defer alloc.free(n);
        var groups: ?[*]PVOID = null;
        var ngroups: u32 = 0;
        var caps: ?[*]PVOID = null;
        var ncaps: u32 = 0;
        if (f(n, &groups, &ngroups, &caps, &ncaps) == 0 or ncaps == 0) {
            setGlobalError("the capability '{s}' could not be derived: Windows error {d}", .{ name, GetLastError() });
            return null;
        }
        defer {
            var k: u32 = 0;
            while (k < ngroups) : (k += 1) _ = LocalFree(groups.?[k]);
            k = 0;
            while (k < ncaps) : (k += 1) _ = LocalFree(caps.?[k]);
            _ = LocalFree(@ptrCast(groups));
            _ = LocalFree(@ptrCast(caps));
        }
        return ownCopy(caps.?[0]);
    }

    fn ownCopy(sid: PVOID) ?[]u8 {
        const len = GetLengthSid(sid);
        const buf = alloc.alignedAlloc(u8, .@"8", len) catch return null;
        if (CopySid(len, buf.ptr, sid) == 0) {
            alloc.free(buf);
            return null;
        }
        return buf;
    }

    // a trustee's SID, owned: a profile's container SID, or "cap:<name>"'s capability SID
    fn trusteeSid(name: []const u8, create: bool) ?[]u8 {
        if (std.mem.startsWith(u8, name, "cap:")) return capabilitySid(name[4..]);
        const sid = containerSid(name, create) orelse return null;
        defer _ = FreeSid(sid);
        return ownCopy(sid);
    }

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

    const ENV_CAP: usize = 32768;

    // Always in a kept block: SystemRoot, and the three Windows itself rewrites to the container's own folder when it
    // starts an AppContainer process -- without them CreateProcessW fails with 203 (measured 2026-11-27), and their
    // supervisor values never reach the node.
    const ENV_ALWAYS = [_][]const u8{ "SystemRoot", "TEMP", "TMP", "LOCALAPPDATA" };

    fn isAlways(name: []const u8) bool {
        for (ENV_ALWAYS) |a| if (std.ascii.eqlIgnoreCase(name, a)) return true;
        return false;
    }

    // R20: the node's environment block when the grant keeps a list -- ENV_ALWAYS, then each kept name the supervisor
    // holds, as NAME=VALUE, each ended by 0 and the block by one more 0. A name the supervisor does not hold is left
    // out. The buffer is ENV_CAP units; the caller frees it.
    fn envBlock(s: *Slot) ?[]u16 {
        const buf = alloc.alloc(u16, ENV_CAP) catch return null;
        var n: usize = 0;
        var i: usize = 0;
        const na = ENV_ALWAYS.len;
        while (i < na + s.nkeeps) : (i += 1) {
            const name: []const u8 = if (i < na) ENV_ALWAYS[i] else s.keeps[i - na];
            if (i >= na and isAlways(name)) continue;
            const wn = w(name) orelse continue;
            defer alloc.free(wn);
            const need = GetEnvironmentVariableW(wn.ptr, null, 0);
            if (need <= 1) continue;
            if (n + wn.len + 1 + need + 2 >= ENV_CAP) break;
            @memcpy(buf[n .. n + wn.len], wn);
            buf[n + wn.len] = '=';
            const at = n + wn.len + 1;
            const got = GetEnvironmentVariableW(wn.ptr, buf[at..].ptr, need);
            if (got == 0 or got >= need) continue;
            n = at + got;
            buf[n] = 0;
            n += 1;
        }
        buf[n] = 0;
        if (n == 0) buf[1] = 0;
        return buf;
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

        // the capabilities: internetClient when the grant asks for the network, and the named ones (rung B4)
        var caps: [1 + MAX_CAPS]SID_AND_ATTRIBUTES = undefined;
        var capsid: [68]u8 align(8) = undefined;
        var owned: [MAX_CAPS]?[]u8 = [_]?[]u8{null} ** MAX_CAPS;
        defer for (owned) |o| {
            if (o) |b| alloc.free(b);
        };
        var ncap: u32 = 0;
        var sc = SECURITY_CAPABILITIES{ .container = sid, .caps = null, .count = 0, .reserved = 0 };
        if (s.network) {
            var n: u32 = capsid.len;
            if (CreateWellKnownSid(86, null, &capsid, &n) == 0) {
                setError(s, "the internetClient capability could not be built: Windows error {d}", .{GetLastError()});
                return 0;
            }
            caps[ncap] = .{ .sid = &capsid, .attributes = 4 };
            ncap += 1;
        }
        for (0..s.ncaps) |k| {
            const b = capabilitySid(s.caps[k][0..s.cap_lens[k]]) orelse {
                setError(s, "{s}", .{last_error[0..last_error_len]});
                return 0;
            };
            owned[k] = b;
            caps[ncap] = .{ .sid = b.ptr, .attributes = 4 };
            ncap += 1;
        }
        if (ncap > 0) {
            sc.caps = &caps;
            sc.count = ncap;
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

        // R20: a grant that keeps a list gets its own environment block (CREATE_UNICODE_ENVIRONMENT)
        const env_buf: ?[]u16 = if (s.env_on) (envBlock(s) orelse {
            setError(s, "the node's environment could not be built", .{});
            _ = CloseHandle(job);
            _ = CloseHandle(port);
            return 0;
        }) else null;
        defer if (env_buf) |b| alloc.free(b);
        const env_ptr: PVOID = if (env_buf) |b| @ptrCast(b.ptr) else null;
        const env_flag: u32 = if (env_buf != null) 0x400 else 0;

        var si = STARTUPINFOEXW{ .si = .{ .cb = @sizeOf(STARTUPINFOEXW), .flags = 0x100, .stdin = inherit[0], .stdout = inherit[1], .stderr = if (same) inherit[1] else inherit[2] }, .attrs = list.ptr };
        var pi: PROCESS_INFORMATION = undefined;
        s.t0 = std.time.Instant.now() catch null;
        // extended startup info, suspended until it is in the job, no console window
        if (CreateProcessW(null, cmd.ptr, null, null, 1, 0x00080000 | 0x4 | 0x08000000 | env_flag, env_ptr, null, &si, &pi) == 0) {
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
        const own = trusteeSid(name, false) orelse return -1;
        defer alloc.free(own);
        const sid: PVOID = own.ptr;
        const p = w(path) orelse return -1;
        defer alloc.free(p);
        const m = ruleMask(p, sid) orelse return -1;
        return if (m != 0) 1 else 0;
    }

    fn revoke(name: []const u8, path: []const u8) i64 {
        const own = trusteeSid(name, false) orelse return -1;
        defer alloc.free(own);
        const sid: PVOID = own.ptr;
        const p = w(path) orelse return -1;
        defer alloc.free(p);
        const dir = isDir(p) orelse return 2; // ERROR_FILE_NOT_FOUND
        return setRule(p, sid, 0, 4, dir); // REVOKE_ACCESS
    }

    fn ensureProfile(name: []const u8) i64 {
        const n = w(name) orelse return -1;
        defer alloc.free(n);
        var sid: PVOID = null;
        const hr = CreateAppContainerProfile(n, n, n, null, 0, &sid);
        if (hr == 0) {
            _ = FreeSid(sid);
            return 1;
        }
        if (@as(u32, @bitCast(hr)) == 0x800700B7) return 0; // HRESULT_FROM_WIN32(ERROR_ALREADY_EXISTS)
        setGlobalError("CreateAppContainerProfile refused '{s}': HRESULT 0x{X}", .{ name, @as(u32, @bitCast(hr)) });
        return -1;
    }

    fn grantPath(name: []const u8, path: []const u8, write: bool) i64 {
        const own = trusteeSid(name, true) orelse {
            if (!std.mem.startsWith(u8, name, "cap:")) setGlobalError("the profile '{s}' could not be created or found", .{name});
            return -1;
        };
        defer alloc.free(own);
        const sid: PVOID = own.ptr;
        var tmp: Slot = .{};
        const r = ensure(&tmp, path, sid, write) orelse {
            setGlobalError("{s}", .{tmp.error_text[0..tmp.error_len]});
            return -1;
        };
        return r;
    }

    fn rulesLeft(name: []const u8, path: []const u8, max: i64) i64 {
        const own = trusteeSid(name, false) orelse return -1;
        defer alloc.free(own);
        const sid: PVOID = own.ptr;
        const root = w(path) orelse return -1;
        defer alloc.free(root);
        var left: i64 = 0;
        const top = ruleMask(root, sid) orelse {
            setGlobalError("the access list of {s} cannot be read", .{path[0..@min(path.len, 200)]});
            return -1;
        };
        walked = 1;
        if (top != 0) left += 1;
        if (!(isDir(root) orelse false)) return left;
        var d = std.fs.openDirAbsolute(path, .{ .iterate = true }) catch {
            setGlobalError("the folder {s} cannot be walked", .{path[0..@min(path.len, 200)]});
            return -1;
        };
        defer d.close();
        var it = d.walk(alloc) catch return -1;
        defer it.deinit();
        while (it.next() catch null) |e| {
            if (max > 0 and walked >= max) break;
            const full = std.fmt.allocPrint(alloc, "{s}\\{s}", .{ path, e.path }) catch continue;
            defer alloc.free(full);
            const p = w(full) orelse continue;
            defer alloc.free(p);
            walked += 1;
            if ((ruleMask(p, sid) orelse 0) != 0) left += 1;
        }
        return left;
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
    fn ensureProfile(_: []const u8) i64 {
        return -1;
    }
    fn grantPath(_: []const u8, _: []const u8, _: bool) i64 {
        return -1;
    }
    fn rulesLeft(_: []const u8, _: []const u8, _: i64) i64 {
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

test "boundary: a trustee is a profile or cap: and a name" {
    try std.testing.expect(validTrustee("stz.node-1"));
    try std.testing.expect(validTrustee("cap:stz.library"));
    try std.testing.expect(!validTrustee("cap:"));
    try std.testing.expect(!validTrustee("cap:has space"));
    try std.testing.expect(!validName("cap:stz.library"));
}

test "boundary: the job messages read as names" {
    try std.testing.expectEqualStrings("JOB_MEMORY_LIMIT", msgName(10));
    try std.testing.expectEqualStrings("END_OF_JOB_TIME", msgName(1));
}
