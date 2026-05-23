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

// Ring List C API — for bulk-loading Ring lists in Zig (no per-element FFI from Ring)
pub extern fn ring_vm_api_getlist(p: *anyopaque, n: c_int) ?*anyopaque;
pub extern fn ring_vm_api_islist(p: *anyopaque, n: c_int) c_int;
pub extern fn ring_list_getitem_gc(pState: ?*anyopaque, pList: *anyopaque, nIndex: c_uint) ?*anyopaque;
pub extern fn ring_list_getlist_gc(pState: ?*anyopaque, pList: *anyopaque, nIndex: c_uint) ?*anyopaque;
pub extern fn ring_list_gettype_gc(pState: ?*anyopaque, pList: *anyopaque, nIndex: c_uint) c_uint;
pub extern fn ring_list_isnumber_gc(pState: ?*anyopaque, pList: *anyopaque, nIndex: c_uint) c_uint;
pub extern fn ring_list_islist_gc(pState: ?*anyopaque, pList: *anyopaque, nIndex: c_uint) c_uint;
pub extern fn ring_item_getnumber(pItem: *anyopaque) f64;
pub extern fn ring_string_size(pString: *anyopaque) c_uint;
pub extern fn ring_list_isstring_gc(pState: ?*anyopaque, pList: *anyopaque, nIndex: c_uint) c_uint;

// Ring struct layout — stable ABI for direct field access where macros can't be called
pub const RingString = extern struct { cStr: [*]const u8, nSize: c_uint };
pub const RingList = extern struct { pFirst: ?*anyopaque, pLast: ?*anyopaque, nSize: c_uint };

pub inline fn ringListSize(pList: *anyopaque) c_uint {
    const rl: *const RingList = @ptrCast(@alignCast(pList));
    return rl.nSize;
}

pub inline fn ringItemStringPtr(pItem: *anyopaque) ?[*]const u8 {
    const pp: *const ?*const RingString = @ptrCast(@alignCast(pItem));
    if (pp.*) |rs| return rs.cStr;
    return null;
}

pub inline fn ringItemStringSize(pItem: *anyopaque) c_uint {
    const pp: *const ?*const RingString = @ptrCast(@alignCast(pItem));
    if (pp.*) |rs| return rs.nSize;
    return 0;
}

pub inline fn ringItemListPtr(pItem: *anyopaque) ?*anyopaque {
    const pp: *const ?*anyopaque = @ptrCast(@alignCast(pItem));
    return pp.*;
}

pub const gl = ring_vm_api_getlist;
pub const il = ring_vm_api_islist;

pub const Reg = struct { name: [*:0]const u8, func: *const fn (*anyopaque) callconv(.c) void };

pub fn registerAll(state: *anyopaque, regs: []const Reg) void {
    for (regs) |reg| {
        ring_vm_funcregister2(state, reg.name, reg.func);
    }
}
