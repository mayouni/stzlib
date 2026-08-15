// Ring bridge for stz_a11y -- the accessibility tree, handed to the
// platform (G4b).
//
// Deliberately small, and for the same reason stz_window is: this DLL
// owns exactly one thing nothing else can own portably -- a live
// connection to the operating system's assistive-technology API. It takes
// a native window handle from stz_window and a JSON tree from the GUI
// plane, and it owns neither.
//
// It is a SEPARATE DLL because AccessKit is per-OS, which is the same call
// GR5 made for windows and input, and the sound plan made for devices.
const std = @import("std");
const a11y = @import("a11y.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const allocator = std.heap.c_allocator;

fn getStr(p: *anyopaque, n: c_int) []const u8 {
    const ptr = R.ring_vm_api_getstring(p, n);
    const len = R.ring_vm_api_getstringsize(p, n);
    return ptr[0..len];
}

// Load(cPathToAccesskitDll) -> 1 / 0. The path is handed in by the Ring
// loader, which knows where the engine's DLLs were installed -- the same
// arrangement stz_gpu has with wgpu_native.dll.
fn ring_Load(p: *anyopaque) callconv(.c) void {
    rn(p, if (a11y.load(getStr(p, 1))) 1 else 0);
}

fn ring_IsAvailable(p: *anyopaque) callconv(.c) void {
    rn(p, if (a11y.isAvailable()) 1 else 0);
}

fn ring_LastError(p: *anyopaque) callconv(.c) void {
    const e = a11y.lastError();
    R.ring_vm_api_retstring2(p, e.ptr, @intCast(e.len));
}

// Attach(nNativeWindowHandle) -> id, or a negative status.
fn ring_Attach(p: *anyopaque) callconv(.c) void {
    const bits: f64 = gn(p, 1);
    if (bits < 0) {
        rn(p, @floatFromInt(a11y.BAD_ARG));
        return;
    }
    rn(p, @floatFromInt(a11y.attach(@intFromFloat(bits))));
}

// Update(nId, cTreeJson) -> status.
fn ring_Update(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(a11y.update(@intFromFloat(gn(p, 1)), getStr(p, 2))));
}

fn ring_Detach(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(a11y.detach(@intFromFloat(gn(p, 1)))));
}

fn ring_IsLive(p: *anyopaque) callconv(.c) void {
    rn(p, if (a11y.isLive(@intFromFloat(gn(p, 1)))) 1 else 0);
}

// Stats(nId) -> [ updates, activations, nodes ], or [].
//
// ACTIVATIONS is the number that matters and the reason this exists: it
// counts the times an assistive technology actually ASKED for the tree.
// `updates` only says we pushed one. A bridge that reported success on
// pushes alone would look identical with and without a screen reader
// running.
fn ring_Stats(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    var v: [3]f64 = .{ 0, 0, 0 };
    if (a11y.stats(@intFromFloat(gn(p, 1)), &v) == a11y.OK) {
        for (v) |x| R.ring_list_adddouble(out, x);
    }
    R.ring_vm_api_retlist(p, out);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginea11yload", .func = &ring_Load },
    .{ .name = "stzenginea11yisavailable", .func = &ring_IsAvailable },
    .{ .name = "stzenginea11ylasterror", .func = &ring_LastError },
    .{ .name = "stzenginea11yattach", .func = &ring_Attach },
    .{ .name = "stzenginea11yupdate", .func = &ring_Update },
    .{ .name = "stzenginea11ydetach", .func = &ring_Detach },
    .{ .name = "stzenginea11yislive", .func = &ring_IsLive },
    .{ .name = "stzenginea11ystats", .func = &ring_Stats },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
