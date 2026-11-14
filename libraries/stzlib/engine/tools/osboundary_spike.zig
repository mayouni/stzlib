// OSBOUNDARY spike -- what Windows enforces on a process started inside an AppContainer and a job object
// (RADAR-OPENSHELL-OSBOUNDARY-01, FOUNDRY-OSBOUNDARY-01; study: base/security/SOFTANZA_OS_BOUNDARY_STUDY.md).
//
// One file, two roles. Run with no argument it is the PARENT: it builds a work folder under %TEMP%\stz_osb, creates an
// AppContainer profile, grants the container read on a copy of itself and full access on one folder, opens a job
// object with the limits a Foundry node would carry, and starts a copy of itself in CHILD mode inside both. The child
// tries each reach -- reads, writes, network, a child process, memory -- and prints one line per check. The parent
// times every step, reads the job's notifications, and deletes the profile at the end.
//
//   zig build-exe osboundary_spike.zig -O ReleaseSafe -luserenv -ladvapi32 -lws2_32
//   osboundary_spike.exe                 the three runs: no network, internetClient, a processor-time ceiling
//   osboundary_spike.exe haro <haro.exe> <script.haro> <engine dir> <library dir> [job memory MB, 1024]
//                                        a haro.exe run inside the boundary: what it needs granted, what it costs
//
// Nothing here changes a permission outside %TEMP%\stz_osb except where the haro mode is told to grant a folder; the
// write-DAC check on a folder under D:\GitHub only OPENS it for WRITE_DAC and closes it.

const std = @import("std");

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
const SOCKADDR_IN = extern struct { family: u16, port: u16, addr: u32, zero: [8]u8 = [_]u8{0} ** 8 };

extern "kernel32" fn CreateFileW(n: [*:0]const u16, a: u32, s: u32, sa: ?*SECURITY_ATTRIBUTES, d: u32, f: u32, t: HANDLE) callconv(.winapi) usize;
extern "kernel32" fn ReadFile(h: usize, b: [*]u8, n: u32, got: *u32, o: PVOID) callconv(.winapi) i32;
extern "kernel32" fn WriteFile(h: usize, b: [*]const u8, n: u32, put: *u32, o: PVOID) callconv(.winapi) i32;
extern "kernel32" fn CloseHandle(h: HANDLE) callconv(.winapi) i32;
extern "kernel32" fn GetLastError() callconv(.winapi) u32;
extern "kernel32" fn GetStdHandle(n: u32) callconv(.winapi) usize;
extern "kernel32" fn CreateProcessW(app: ?[*:0]const u16, cmd: [*:0]u16, pa: PVOID, ta: PVOID, inh: i32, flags: u32, env: PVOID, dir: ?[*:0]const u16, si: *anyopaque, pi: *PROCESS_INFORMATION) callconv(.winapi) i32;
extern "kernel32" fn InitializeProcThreadAttributeList(l: PVOID, n: u32, f: u32, size: *usize) callconv(.winapi) i32;
extern "kernel32" fn UpdateProcThreadAttribute(l: PVOID, f: u32, attr: usize, v: *anyopaque, size: usize, prev: PVOID, ret: PVOID) callconv(.winapi) i32;
extern "kernel32" fn DeleteProcThreadAttributeList(l: PVOID) callconv(.winapi) void;
extern "kernel32" fn CreateJobObjectW(sa: PVOID, name: ?[*:0]const u16) callconv(.winapi) HANDLE;
extern "kernel32" fn SetInformationJobObject(j: HANDLE, c: u32, info: *anyopaque, n: u32) callconv(.winapi) i32;
extern "kernel32" fn QueryInformationJobObject(j: HANDLE, c: u32, info: *anyopaque, n: u32, ret: ?*u32) callconv(.winapi) i32;
extern "kernel32" fn AssignProcessToJobObject(j: HANDLE, p: HANDLE) callconv(.winapi) i32;
extern "kernel32" fn ResumeThread(t: HANDLE) callconv(.winapi) u32;
extern "kernel32" fn WaitForSingleObject(h: HANDLE, ms: u32) callconv(.winapi) u32;
extern "kernel32" fn GetExitCodeProcess(h: HANDLE, code: *u32) callconv(.winapi) i32;
extern "kernel32" fn TerminateProcess(h: HANDLE, code: u32) callconv(.winapi) i32;
extern "kernel32" fn CreateIoCompletionPort(f: usize, p: HANDLE, key: usize, n: u32) callconv(.winapi) HANDLE;
extern "kernel32" fn GetQueuedCompletionStatus(p: HANDLE, n: *u32, key: *usize, o: *PVOID, ms: u32) callconv(.winapi) i32;
extern "kernel32" fn VirtualAlloc(a: PVOID, n: usize, t: u32, p: u32) callconv(.winapi) PVOID;
extern "kernel32" fn VirtualFree(a: PVOID, n: usize, t: u32) callconv(.winapi) i32;
extern "kernel32" fn LocalFree(p: PVOID) callconv(.winapi) PVOID;
extern "userenv" fn CreateAppContainerProfile(n: [*:0]const u16, d: [*:0]const u16, desc: [*:0]const u16, caps: PVOID, cn: u32, sid: *PVOID) callconv(.winapi) i32;
extern "userenv" fn DeleteAppContainerProfile(n: [*:0]const u16) callconv(.winapi) i32;
extern "userenv" fn DeriveAppContainerSidFromAppContainerName(n: [*:0]const u16, sid: *PVOID) callconv(.winapi) i32;
extern "advapi32" fn FreeSid(s: PVOID) callconv(.winapi) PVOID;
extern "advapi32" fn CreateWellKnownSid(t: u32, dom: PVOID, sid: *anyopaque, size: *u32) callconv(.winapi) i32;
extern "advapi32" fn GetNamedSecurityInfoW(n: [*:0]const u16, t: u32, i: u32, o: PVOID, g: PVOID, dacl: *PVOID, sacl: PVOID, sd: *PVOID) callconv(.winapi) u32;
extern "advapi32" fn SetNamedSecurityInfoW(n: [*:0]const u16, t: u32, i: u32, o: PVOID, g: PVOID, dacl: PVOID, sacl: PVOID) callconv(.winapi) u32;
extern "advapi32" fn SetEntriesInAclW(n: u32, ea: *EXPLICIT_ACCESS_W, old: PVOID, new: *PVOID) callconv(.winapi) u32;
extern "ws2_32" fn WSAStartup(v: u16, d: *[408]u8) callconv(.winapi) i32;
extern "ws2_32" fn WSAGetLastError() callconv(.winapi) i32;
extern "ws2_32" fn socket(af: i32, t: i32, p: i32) callconv(.winapi) usize;
extern "ws2_32" fn connect(s: usize, a: *const SOCKADDR_IN, n: i32) callconv(.winapi) i32;
extern "ws2_32" fn bind(s: usize, a: *const SOCKADDR_IN, n: i32) callconv(.winapi) i32;
extern "ws2_32" fn listen(s: usize, n: i32) callconv(.winapi) i32;
extern "ws2_32" fn getsockname(s: usize, a: *SOCKADDR_IN, n: *i32) callconv(.winapi) i32;
extern "ws2_32" fn closesocket(s: usize) callconv(.winapi) i32;

const GENERIC_READ: u32 = 0x80000000;
const GENERIC_WRITE: u32 = 0x40000000;
const GENERIC_EXECUTE: u32 = 0x20000000;
const GENERIC_ALL: u32 = 0x10000000;
const WRITE_DAC: u32 = 0x00040000;

const alloc = std.heap.page_allocator;

fn w(s: []const u8) [:0]u16 {
    return std.unicode.utf8ToUtf16LeAllocZ(alloc, s) catch unreachable;
}

fn say(comptime f: []const u8, a: anytype) void {
    const s = std.fmt.allocPrint(alloc, f ++ "\n", a) catch return;
    var put: u32 = 0;
    _ = WriteFile(GetStdHandle(@bitCast(@as(i32, -11))), s.ptr, @intCast(s.len), &put, null);
}

fn ms(t: *std.time.Timer) f64 {
    return @as(f64, @floatFromInt(t.lap())) / 1e6;
}

// --- the child: one line per reach -------------------------------------------------------------------------------------

fn tryRead(path: []const u8) u32 {
    const h = CreateFileW(w(path), GENERIC_READ, 7, null, 3, 0x80, null);
    if (h == INVALID) return GetLastError();
    var b: [16]u8 = undefined;
    var got: u32 = 0;
    const ok = ReadFile(h, &b, b.len, &got, null);
    const e = if (ok == 0) GetLastError() else 0;
    _ = CloseHandle(@ptrFromInt(h));
    return e;
}

fn tryWrite(path: []const u8) u32 {
    const h = CreateFileW(w(path), GENERIC_WRITE, 0, null, 2, 0x80, null);
    if (h == INVALID) return GetLastError();
    var put: u32 = 0;
    const ok = WriteFile(h, "x", 1, &put, null);
    const e = if (ok == 0) GetLastError() else 0;
    _ = CloseHandle(@ptrFromInt(h));
    return e;
}

fn tryConnect(a: u8, b: u8, c: u8, d: u8, port: u16) i32 {
    const s = socket(2, 1, 6);
    if (s == INVALID) return WSAGetLastError();
    const addr = SOCKADDR_IN{ .family = 2, .port = std.mem.nativeToBig(u16, port), .addr = @bitCast([4]u8{ a, b, c, d }) };
    const r = connect(s, &addr, @sizeOf(SOCKADDR_IN));
    const e = if (r != 0) WSAGetLastError() else 0;
    _ = closesocket(s);
    return e;
}

fn trySpawn() u32 {
    var si = STARTUPINFOW{ .cb = @sizeOf(STARTUPINFOW) };
    var pi: PROCESS_INFORMATION = undefined;
    const cmd = w("C:\\Windows\\System32\\cmd.exe /c exit 0");
    if (CreateProcessW(null, cmd.ptr, null, null, 0, 0x08000000, null, null, &si, &pi) == 0) return GetLastError();
    _ = WaitForSingleObject(pi.process, 5000);
    _ = CloseHandle(pi.process);
    _ = CloseHandle(pi.thread);
    return 0;
}

fn tryAlloc(mb: usize) u32 {
    const p = VirtualAlloc(null, mb << 20, 0x3000, 4) orelse return GetLastError();
    const bytes: [*]u8 = @ptrCast(p);
    var i: usize = 0;
    while (i < (mb << 20)) : (i += 4096) bytes[i] = 1;
    _ = VirtualFree(p, 0, 0x8000);
    return 0;
}

fn line(tag: []const u8, what: []const u8, err: i64) void {
    if (err == 0) say("{s} reached   {s}", .{ tag, what }) else say("{s} refused   {s}  (error {d})", .{ tag, what, err });
}

fn child(args: []const []const u8) void {
    // args: child <grant dir> <outside dir> <loopback port> <repo file> <profile file>
    const grant = args[2];
    const outside = args[3];
    const port = std.fmt.parseInt(u16, args[4], 10) catch 0;
    var wsa: [408]u8 = undefined;
    _ = WSAStartup(0x0202, &wsa);
    line("R1", "read a file in the granted folder", tryRead(std.fmt.allocPrint(alloc, "{s}\\in.txt", .{grant}) catch unreachable));
    line("R2", "read a stand-in key the user owns, outside the grant", tryRead(std.fmt.allocPrint(alloc, "{s}\\key.txt", .{outside}) catch unreachable));
    line("R3", "read a file of the repository under D:\\GitHub", tryRead(args[5]));
    line("R4", "read a file of the user's profile", tryRead(args[6]));
    line("R5", "read C:\\Windows\\System32\\drivers\\etc\\hosts", tryRead("C:\\Windows\\System32\\drivers\\etc\\hosts"));
    line("W1", "write in the granted folder", tryWrite(std.fmt.allocPrint(alloc, "{s}\\out.txt", .{grant}) catch unreachable));
    line("W2", "write beside the stand-in key", tryWrite(std.fmt.allocPrint(alloc, "{s}\\planted.txt", .{outside}) catch unreachable));
    line("W3", "write in the user's TEMP", tryWrite(std.fmt.allocPrint(alloc, "{s}\\..\\planted.txt", .{outside}) catch unreachable));
    line("N1", "TCP connect to the parent on 127.0.0.1", tryConnect(127, 0, 0, 1, port));
    line("N2", "TCP connect to 1.1.1.1:80", tryConnect(1, 1, 1, 1, 80));
    line("C1", "start cmd.exe", trySpawn());
    line("M1", "commit and touch 64 MB", tryAlloc(64));
    line("M2", "commit and touch 512 MB", tryAlloc(512));
}

fn spin() void {
    var x: u64 = 0;
    while (true) x +%= 1;
}

// --- the parent: profile, grants, job, spawn ----------------------------------------------------------------------------

fn grantPath(path: []const u8, sid: PVOID, access: u32) u32 {
    var old: PVOID = null;
    var sd: PVOID = null;
    const p = w(path);
    var r = GetNamedSecurityInfoW(p, 1, 4, null, null, &old, null, &sd);
    if (r != 0) return r;
    var ea = EXPLICIT_ACCESS_W{ .access = access, .mode = 1, .inherit = 3, .trustee = .{ .form = 0, .ttype = 5, .name = sid } };
    var new: PVOID = null;
    r = SetEntriesInAclW(1, &ea, old, &new);
    if (r == 0) r = SetNamedSecurityInfoW(p, 1, 4, null, null, new, null);
    _ = LocalFree(new);
    _ = LocalFree(sd);
    return r;
}

// removes every access rule naming the container from a folder and, through inheritance, its tree
fn revokePath(path: []const u8, sid: PVOID) u32 {
    var old: PVOID = null;
    var sd: PVOID = null;
    const p = w(path);
    var r = GetNamedSecurityInfoW(p, 1, 4, null, null, &old, null, &sd);
    if (r != 0) return r;
    var ea = EXPLICIT_ACCESS_W{ .access = 0, .mode = 4, .inherit = 3, .trustee = .{ .form = 0, .ttype = 5, .name = sid } };
    var new: PVOID = null;
    r = SetEntriesInAclW(1, &ea, old, &new);
    if (r == 0) r = SetNamedSecurityInfoW(p, 1, 4, null, null, new, null);
    _ = LocalFree(new);
    _ = LocalFree(sd);
    return r;
}

fn holdsWriteDac(path: []const u8) u32 {
    const h = CreateFileW(w(path), WRITE_DAC, 7, null, 3, 0x02000000, null);
    if (h == INVALID) return GetLastError();
    _ = CloseHandle(@ptrFromInt(h));
    return 0;
}

const Limits = struct { active: u32 = 1, job_mem_mb: usize = 256, job_time_ms: i64 = 0 };

const Run = struct { exit: u32, wall_ms: f64, spawn_ms: f64, msgs: [8]u32, nmsg: usize, peak_mb: f64 };

fn runInside(sid: PVOID, internet: bool, cmdline: []const u8, log_path: []const u8, lim: Limits) Run {
    var t = std.time.Timer.start() catch unreachable;
    var caps: [1]SID_AND_ATTRIBUTES = undefined;
    var capsid: [68]u8 align(8) = undefined;
    var sc = SECURITY_CAPABILITIES{ .container = sid, .caps = null, .count = 0, .reserved = 0 };
    if (internet) {
        var n: u32 = capsid.len;
        _ = CreateWellKnownSid(86, null, &capsid, &n); // WinCapabilityInternetClientSid
        caps[0] = .{ .sid = &capsid, .attributes = 4 }; // SE_GROUP_ENABLED
        sc.caps = &caps;
        sc.count = 1;
    }
    var size: usize = 0;
    _ = InitializeProcThreadAttributeList(null, 1, 0, &size);
    const list = alloc.alignedAlloc(u8, .@"8", size) catch unreachable;
    _ = InitializeProcThreadAttributeList(list.ptr, 1, 0, &size);
    _ = UpdateProcThreadAttribute(list.ptr, 0, 0x00020009, &sc, @sizeOf(SECURITY_CAPABILITIES), null, null);

    var sa = SECURITY_ATTRIBUTES{ .len = @sizeOf(SECURITY_ATTRIBUTES), .sd = null, .inherit = 1 };
    const log = CreateFileW(w(log_path), GENERIC_WRITE, 3, &sa, 2, 0x80, null);
    var si = STARTUPINFOEXW{ .si = .{ .cb = @sizeOf(STARTUPINFOEXW), .flags = 0x100, .stdout = @ptrFromInt(log), .stderr = @ptrFromInt(log) }, .attrs = list.ptr };

    const job = CreateJobObjectW(null, null);
    var ext = EXT_LIMIT{};
    ext.basic.flags = 0x2000 | 0x400 | 0x8 | 0x200; // kill on close, die on unhandled exception, active processes, job memory
    ext.basic.active = lim.active;
    ext.job_mem = lim.job_mem_mb << 20;
    if (lim.job_time_ms > 0) {
        ext.basic.flags |= 0x4;
        ext.basic.per_job_time = lim.job_time_ms * 10_000;
    }
    _ = SetInformationJobObject(job, 9, &ext, @sizeOf(EXT_LIMIT));
    const port = CreateIoCompletionPort(INVALID, null, 0, 1);
    var assoc = PORT_ASSOC{ .key = job, .port = port };
    _ = SetInformationJobObject(job, 7, &assoc, @sizeOf(PORT_ASSOC));

    var pi: PROCESS_INFORMATION = undefined;
    const cmd = w(cmdline);
    const ok = CreateProcessW(null, cmd.ptr, null, null, 1, 0x00080000 | 0x4 | 0x08000000, null, null, &si, &pi);
    if (ok == 0) {
        say("  CreateProcessW failed: error {d}", .{GetLastError()});
        return .{ .exit = 0xFFFFFFFF, .wall_ms = 0, .spawn_ms = 0, .msgs = undefined, .nmsg = 0, .peak_mb = 0 };
    }
    _ = AssignProcessToJobObject(job, pi.process);
    _ = ResumeThread(pi.thread);
    const spawn_ms = ms(&t);
    _ = WaitForSingleObject(pi.process, 600_000);
    const wall_ms = ms(&t);
    var code: u32 = 0;
    _ = GetExitCodeProcess(pi.process, &code);
    var run = Run{ .exit = code, .wall_ms = wall_ms, .spawn_ms = spawn_ms, .msgs = undefined, .nmsg = 0, .peak_mb = 0 };
    var q = EXT_LIMIT{};
    if (QueryInformationJobObject(job, 9, &q, @sizeOf(EXT_LIMIT), null) != 0) run.peak_mb = @as(f64, @floatFromInt(q.peak_job_mem)) / 1048576.0;
    while (run.nmsg < run.msgs.len) {
        var msg: u32 = 0;
        var key: usize = 0;
        var o: PVOID = null;
        if (GetQueuedCompletionStatus(port, &msg, &key, &o, 50) == 0) break;
        run.msgs[run.nmsg] = msg;
        run.nmsg += 1;
    }
    _ = CloseHandle(pi.thread);
    _ = CloseHandle(pi.process);
    _ = CloseHandle(@ptrFromInt(log));
    _ = CloseHandle(job);
    _ = CloseHandle(port);
    DeleteProcThreadAttributeList(list.ptr);
    return run;
}

fn msgName(m: u32) []const u8 {
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
        else => "?",
    };
}

fn report(name: []const u8, r: Run, log_path: []const u8) void {
    say("", .{});
    say("== {s}: spawn {d:.1} ms, exit after {d:.1} ms, exit code 0x{X}, peak job memory {d:.1} MB", .{ name, r.spawn_ms, r.wall_ms, r.exit, r.peak_mb });
    var i: usize = 0;
    while (i < r.nmsg) : (i += 1) say("   job message: {s}", .{msgName(r.msgs[i])});
    const body = std.fs.cwd().readFileAlloc(alloc, log_path, 1 << 20) catch "";
    say("{s}", .{body});
}

fn makeContainer(name: []const u8, t: *std.time.Timer) PVOID {
    const n = w(name);
    _ = DeleteAppContainerProfile(n);
    var sid: PVOID = null;
    const hr = CreateAppContainerProfile(n, n, w("Softanza OSBOUNDARY spike"), null, 0, &sid);
    if (hr != 0) {
        if (DeriveAppContainerSidFromAppContainerName(n, &sid) != 0) {
            say("profile: CreateAppContainerProfile 0x{X}", .{@as(u32, @bitCast(hr))});
            std.process.exit(2);
        }
    }
    say("profile {s}: created in {d:.1} ms", .{ name, ms(t) });
    return sid;
}

pub fn main() !void {
    const args = try std.process.argsAlloc(alloc);
    if (args.len >= 2 and std.mem.eql(u8, args[1], "child")) return child(args);
    if (args.len >= 2 and std.mem.eql(u8, args[1], "spin")) return spin();

    const temp = try std.process.getEnvVarOwned(alloc, "TEMP");
    const base = try std.fmt.allocPrint(alloc, "{s}\\stz_osb", .{temp});
    const bin = try std.fmt.allocPrint(alloc, "{s}\\bin", .{base});
    const grant = try std.fmt.allocPrint(alloc, "{s}\\grant", .{base});
    const outside = try std.fmt.allocPrint(alloc, "{s}\\outside", .{base});
    const logs = try std.fmt.allocPrint(alloc, "{s}\\logs", .{base});
    for ([_][]const u8{ bin, grant, outside, logs }) |d| try std.fs.cwd().makePath(d);
    try std.fs.cwd().writeFile(.{ .sub_path = try std.fmt.allocPrint(alloc, "{s}\\in.txt", .{grant}), .data = "granted" });
    try std.fs.cwd().writeFile(.{ .sub_path = try std.fmt.allocPrint(alloc, "{s}\\key.txt", .{outside}), .data = "stand-in key" });
    const self = try std.fs.selfExePathAlloc(alloc);
    const probe = try std.fmt.allocPrint(alloc, "{s}\\probe.exe", .{bin});
    try std.fs.copyFileAbsolute(self, probe, .{});

    var t = try std.time.Timer.start();
    const sid = makeContainer("stz.osb.spike", &t);
    defer _ = DeleteAppContainerProfile(w("stz.osb.spike"));
    say("grant read+execute on bin: error {d}, {d:.1} ms", .{ grantPath(bin, sid, GENERIC_READ | GENERIC_EXECUTE), ms(&t) });
    say("grant full on grant:       error {d}, {d:.1} ms", .{ grantPath(grant, sid, GENERIC_ALL), ms(&t) });

    if (args.len >= 6 and std.mem.eql(u8, args[1], "haro")) return haroMode(sid, args, logs, &t);

    // the labelling limit stzfoundry found: may this user write an access rule under D:\GitHub?
    say("WRITE_DAC on D:\\GitHub\\_wts\\libraries\\stzlib: error {d}", .{holdsWriteDac("D:\\GitHub\\_wts\\libraries\\stzlib")});
    say("WRITE_DAC on C:\\haro-engine: error {d}", .{holdsWriteDac("C:\\haro-engine")});
    say("WRITE_DAC on {s}: error {d}", .{ base, holdsWriteDac(base) });

    var wsa: [408]u8 = undefined;
    _ = WSAStartup(0x0202, &wsa);
    const ls = socket(2, 1, 6);
    var la = SOCKADDR_IN{ .family = 2, .port = 0, .addr = @bitCast([4]u8{ 127, 0, 0, 1 }) };
    _ = bind(ls, &la, @sizeOf(SOCKADDR_IN));
    _ = listen(ls, 4);
    var ln: i32 = @sizeOf(SOCKADDR_IN);
    _ = getsockname(ls, &la, &ln);
    const lport = std.mem.bigToNative(u16, la.port);

    const user = try std.process.getEnvVarOwned(alloc, "USERPROFILE");
    const prof = try std.fmt.allocPrint(alloc, "{s}\\.gitconfig", .{user});
    const repo = "D:\\GitHub\\_wts\\libraries\\stzlib\\engine\\tools\\osboundary_spike.zig";
    const cmd = try std.fmt.allocPrint(alloc, "\"{s}\" child \"{s}\" \"{s}\" {d} \"{s}\" \"{s}\"", .{ probe, grant, outside, lport, repo, prof });

    const l1 = try std.fmt.allocPrint(alloc, "{s}\\run1.txt", .{logs});
    report("run 1: AppContainer, no capability, job (1 process, 256 MB)", runInside(sid, false, cmd, l1, .{}), l1);
    const l2 = try std.fmt.allocPrint(alloc, "{s}\\run2.txt", .{logs});
    report("run 2: AppContainer + internetClient, same job", runInside(sid, true, cmd, l2, .{}), l2);
    const l3 = try std.fmt.allocPrint(alloc, "{s}\\run3.txt", .{logs});
    const spincmd = try std.fmt.allocPrint(alloc, "\"{s}\" spin", .{probe});
    report("run 3: a spinning child under a 500 ms processor-time ceiling", runInside(sid, false, spincmd, l3, .{ .job_time_ms = 500 }), l3);
    _ = closesocket(ls);
}

// haro <haro.exe> <script> <engine dir> <library dir>: grant the container read on each, run the script inside, report
fn haroMode(sid: PVOID, args: []const []const u8, logs: []const u8, t: *std.time.Timer) void {
    const haro = args[2];
    const script = args[3];
    const engine = args[4];
    const lib = args[5];
    const haro_dir = std.fs.path.dirname(haro) orelse ".";
    const script_dir = std.fs.path.dirname(script) orelse ".";
    for ([_][]const u8{ haro_dir, engine, lib, script_dir }) |d| {
        say("grant read+execute on {s}: error {d}, {d:.1} ms", .{ d, grantPath(d, sid, GENERIC_READ | GENERIC_EXECUTE), ms(t) });
    }
    const l = std.fmt.allocPrint(alloc, "{s}\\haro.txt", .{logs}) catch unreachable;
    const cmd = std.fmt.allocPrint(alloc, "\"{s}\" \"{s}\"", .{ haro, script }) catch unreachable;
    _ = ms(t);
    const mb: usize = if (args.len >= 7) std.fmt.parseInt(usize, args[6], 10) catch 1024 else 1024;
    const title = std.fmt.allocPrint(alloc, "haro.exe inside the AppContainer and the job (1 process, {d} MB)", .{mb}) catch unreachable;
    report(title, runInside(sid, false, cmd, l, .{ .job_mem_mb = mb }), l);
    _ = ms(t);
    for ([_][]const u8{ haro_dir, engine, lib, script_dir }) |d| {
        say("revoke on {s}: error {d}, {d:.1} ms", .{ d, revokePath(d, sid), ms(t) });
    }
}
