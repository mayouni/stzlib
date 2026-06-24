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

// ─── Handle Table ───
// Maps integer IDs (1-based) to raw engine pointers.
// Eliminates sporadic @alignCast panics in Ring-Zig FFI by ensuring
// Ring never touches actual C pointers — only integer IDs cross the boundary.
//
// Bridge files shadow ring_vm_api_retcpointer / ring_vm_api_getcpointer
// with these wrappers so all call sites automatically use the table.

const MAX_HANDLES = 8192;
var handle_table: [MAX_HANDLES]?*anyopaque = [_]?*anyopaque{null} ** MAX_HANDLES;
var next_slot: usize = 0;

pub fn storeHandle(ptr: ?*anyopaque) f64 {
    const raw = ptr orelse return 0;
    var i: usize = 0;
    while (i < MAX_HANDLES) : (i += 1) {
        const idx = (next_slot + i) % MAX_HANDLES;
        if (handle_table[idx] == null) {
            handle_table[idx] = raw;
            next_slot = (idx + 1) % MAX_HANDLES;
            return @floatFromInt(idx + 1); // 1-based ID
        }
    }
    return 0; // table full
}

pub fn resolveHandle(id: f64) ?*anyopaque {
    const raw_id = @as(i64, @intFromFloat(id));
    if (raw_id <= 0 or raw_id > MAX_HANDLES) return null;
    const idx: usize = @intCast(raw_id - 1);
    return handle_table[idx];
}

pub fn releaseSlot(id: f64) void {
    const raw_id = @as(i64, @intFromFloat(id));
    if (raw_id <= 0 or raw_id > MAX_HANDLES) return;
    const idx: usize = @intCast(raw_id - 1);
    handle_table[idx] = null;
}

/// Wrapper: store pointer in handle table, return integer ID to Ring.
/// Use this instead of ring_vm_api_retcpointer in bridge functions.
pub fn retHandle(p: *anyopaque, ptr: ?*anyopaque) void {
    ring_vm_api_retnumber(p, storeHandle(ptr));
}

/// Wrapper: read integer ID from Ring param, resolve to pointer.
/// Use this instead of ring_vm_api_getcpointer in bridge functions.
pub fn getHandle(p: *anyopaque, n: c_int) ?*anyopaque {
    const id = ring_vm_api_getnumber(p, n);
    return resolveHandle(id);
}

/// Read handle ID from param n, resolve and release slot.
/// Returns the raw pointer for the caller to free with the appropriate typed function.
/// Caller pattern: const ptr = releaseHandle(p, 1); typedFree(ptr);
pub fn releaseHandle(p: *anyopaque, n: c_int) ?*anyopaque {
    const id = ring_vm_api_getnumber(p, n);
    const ptr = resolveHandle(id);
    releaseSlot(id);
    return ptr;
}

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

// --- Ring list WRITE side (return Ring lists from bridge functions) ---
// `ring_vm_api_newlist(p)` allocates a fresh Ring list owned by the VM
// for the duration of this call; `ring_vm_api_retlist(p, *List)` returns
// it to the caller. The add* helpers append items in place.
pub extern fn ring_vm_api_newlist(p: *anyopaque) ?*anyopaque;
pub extern fn ring_vm_api_retlist(p: *anyopaque, pList: *anyopaque) void;
pub extern fn ring_list_addint(pList: *anyopaque, x: c_int) void;
pub extern fn ring_list_adddouble(pList: *anyopaque, x: f64) void;
pub extern fn ring_list_addstring(pList: *anyopaque, cStr: [*:0]const u8) void;
pub extern fn ring_list_addstring2(pList: *anyopaque, cStr: [*]const u8, nSize: c_uint) void;
pub extern fn ring_list_newlist(pList: *anyopaque) ?*anyopaque;

// Ring struct layout — direct field access where Ring exposes data only via
// macros (no exported getter functions): list size + string bytes.
//
// The `String` and `Item` structs are stable across Ring versions, but the
// internal `List` struct was REORGANIZED in Ring 1.27 (nSize moved from offset
// 16 to offset 60). So the layout used for reading List.nSize must match the
// Ring version the engine is built against. build.zig reads RING_VERSION_MINOR
// from the chosen Ring's state.h and passes it here; rebuild against your Ring.
const ring_minor: u32 = @import("ring_build_options").ring_minor;

pub const RingString = extern struct { cStr: [*]const u8, nSize: c_uint };

// Ring 1.27+ List layout (only the fields up to nSize are needed here).
const RingList127 = extern struct {
    pFirst: ?*anyopaque,
    pLast: ?*anyopaque,
    pLastItem: ?*anyopaque,
    pItemsArray: ?*anyopaque,
    pHashTable: ?*anyopaque,
    pBlocks: ?*anyopaque,
    pHashParent: ?*anyopaque,
    nNextItem: c_uint,
    nSize: c_uint,
};
// Ring <= 1.26 List layout (nSize right after pFirst/pLast).
const RingListLegacy = extern struct { pFirst: ?*anyopaque, pLast: ?*anyopaque, nSize: c_uint };

pub const RingList = if (ring_minor >= 27) RingList127 else RingListLegacy;

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
