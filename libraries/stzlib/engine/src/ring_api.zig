// Shared Ring Extension API declarations.
// Imported by each ring_bridge_*.zig -- no code duplication.

pub extern fn ring_vm_funcregister2(pRingState: *anyopaque, cName: [*:0]const u8, pFunc: *const fn (*anyopaque) callconv(.c) void) void;
pub extern fn ring_vm_api_paracount(p: *anyopaque) c_int;
pub extern fn ring_vm_api_isstring(p: *anyopaque, n: c_int) c_int;
pub extern fn ring_vm_api_isnumber(p: *anyopaque, n: c_int) c_int;
pub extern fn ring_vm_api_ispointer(p: *anyopaque, n: c_int) c_int;
pub extern fn ring_vm_api_getstring(p: *anyopaque, n: c_int) [*]const u8;
pub extern fn ring_vm_api_getstringsize(p: *anyopaque, n: c_int) c_uint;
pub extern fn ring_vm_api_getnumber(p: *anyopaque, n: c_int) f64;
pub extern fn ring_vm_api_getcpointer(p: *anyopaque, n: c_int, cType: [*:0]const u8) ?*anyopaque;
pub extern fn ring_vm_api_retnumber(p: *anyopaque, n: f64) void;
pub extern fn ring_vm_api_retstring(p: *anyopaque, s: [*:0]const u8) void;
pub extern fn ring_vm_api_retstring2(p: *anyopaque, s: [*]const u8, len: c_uint) void;
pub extern fn ring_vm_api_retcpointer(p: *anyopaque, ptr: ?*anyopaque, cType: [*:0]const u8) void;

pub const Reg = struct { name: [*:0]const u8, func: *const fn (*anyopaque) callconv(.c) void };

pub fn registerAll(state: *anyopaque, regs: []const Reg) void {
    for (regs) |reg| {
        ring_vm_funcregister2(state, reg.name, reg.func);
    }
}
