// The consumer half of the engine door (SECURITY-R18b): import this in any engine
// DLL that runs a model, and call recordFact before the answer goes back to Ring.
//
//     const door = @import("seclog_door.zig");
//     _ = door.recordFact("model.call", "stzNeuralModel", arch, "", "generate: 12 tokens");
//
// It writes into the PROCESS ledger, which lives in stz_seclog -- a DLL with its own
// globals, reachable only through its exported stz_seclog_door_fact. The symbol is
// found once: in the stz_seclog already loaded in the process, or else loaded from
// the folder this DLL was loaded from, so a program that never loaded stz_seclog
// still gets its record written. Nothing here can turn the door off.
//
// POSIX is not wired yet (R14 needs a Linux machine): recordFact answers false
// there and counts the call as missed, so the gap is a number, not a silence.

const std = @import("std");
const builtin = @import("builtin");

const DoorFn = *const fn (
    [*]const u8, usize, [*]const u8, usize, [*]const u8, usize,
    [*]const u8, usize, [*]const u8, usize,
) callconv(.c) i32;

const win = struct {
    const HMODULE = ?*anyopaque;
    extern "kernel32" fn GetModuleHandleA(name: ?[*:0]const u8) callconv(.winapi) HMODULE;
    extern "kernel32" fn GetModuleHandleExA(flags: u32, addr: ?*const anyopaque, out: *HMODULE) callconv(.winapi) c_int;
    extern "kernel32" fn GetModuleFileNameA(m: HMODULE, buf: [*]u8, size: u32) callconv(.winapi) u32;
    extern "kernel32" fn LoadLibraryA(name: [*:0]const u8) callconv(.winapi) HMODULE;
    extern "kernel32" fn GetProcAddress(m: HMODULE, name: [*:0]const u8) callconv(.winapi) ?*const anyopaque;
    const FROM_ADDRESS: u32 = 0x4;
    const UNCHANGED_REFCOUNT: u32 = 0x2;
};

const ShutFn = *const fn ([*]const u8, usize, [*]const u8, usize, [*]u8, usize) callconv(.c) i32;

var door: ?DoorFn = null;
var shut_fn: ?ShutFn = null;
var looked = false;
var shut_unknown: u64 = 0;
var missed: u64 = 0;
var written: u64 = 0;

fn anchor() callconv(.c) void {}

// stz_seclog.dll beside the module that holds this code
fn loadBeside() win.HMODULE {
    var self: win.HMODULE = null;
    if (win.GetModuleHandleExA(win.FROM_ADDRESS | win.UNCHANGED_REFCOUNT, @ptrCast(&anchor), &self) == 0) return null;
    var buf: [1024]u8 = undefined;
    const n = win.GetModuleFileNameA(self, &buf, buf.len - 32);
    if (n == 0 or n >= buf.len - 32) return null;
    const path = buf[0..n];
    const cut = (std.mem.lastIndexOfAny(u8, path, "\\/") orelse return null) + 1;
    const name = "stz_seclog.dll";
    @memcpy(buf[cut .. cut + name.len], name);
    buf[cut + name.len] = 0;
    return win.LoadLibraryA(@ptrCast(&buf));
}

fn find() ?DoorFn {
    if (looked) return door;
    looked = true;
    if (builtin.os.tag != .windows) return null;
    const m = win.GetModuleHandleA("stz_seclog.dll") orelse loadBeside() orelse return null;
    if (win.GetProcAddress(m, "stz_seclog_door_shut_query")) |q| shut_fn = @ptrCast(@alignCast(q));
    const f = win.GetProcAddress(m, "stz_seclog_door_fact") orelse return null;
    door = @ptrCast(@alignCast(f));
    return door;
}

/// SECURITY-R18c: the advisory that shut the door of this kind to this name, copied
/// into out, or null when it is open. An engine entry point asks this BEFORE it acts
/// and refuses when it answers. When the list cannot be reached (no stz_seclog, POSIX
/// until R14) the answer is null and the miss is counted: shutUnknownCount() > 0
/// says the refusal could not be checked, so the gap is a number, never a silence.
pub fn isShut(kind: []const u8, name: []const u8, out: []u8) ?[]const u8 {
    _ = find();
    const q = shut_fn orelse {
        shut_unknown += 1;
        return null;
    };
    const n = q(kind.ptr, kind.len, name.ptr, name.len, out.ptr, out.len);
    if (n < 0) return null;
    return out[0..@intCast(n)];
}

/// Checks that could not reach the shut list -- 0 is the only right answer.
pub fn shutUnknownCount() u64 {
    return shut_unknown;
}

/// Write one observed fact to the process ledger, opening it if none is open.
/// True when the record was written.
pub fn recordFact(kind: []const u8, actor: []const u8, subject: []const u8, origin: []const u8, what: []const u8) bool {
    const f = find() orelse {
        missed += 1;
        return false;
    };
    if (f(kind.ptr, kind.len, actor.ptr, actor.len, subject.ptr, subject.len, origin.ptr, origin.len, what.ptr, what.len) != 1) {
        missed += 1;
        return false;
    }
    written += 1;
    return true;
}

/// Calls whose record could not be written -- 0 is the only right answer.
pub fn missedCount() u64 {
    return missed;
}

pub fn writtenCount() u64 {
    return written;
}
