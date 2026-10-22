const std = @import("std");
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
/// Raise a trappable Ring error from a bridge function (RING_API_ERROR):
/// the `p` a bridge receives IS the VM pointer.
pub extern fn ring_vm_error(pVM: *anyopaque, cStr: [*:0]const u8) void;

// ─── Handle Table ───
// Maps integer IDs (1-based) to raw engine pointers.
// Eliminates sporadic @alignCast panics in Ring-Zig FFI by ensuring
// Ring never touches actual C pointers — only integer IDs cross the boundary.
//
// Bridge files shadow ring_vm_api_retcpointer / ring_vm_api_getcpointer
// with these wrappers so all call sites automatically use the table.

// THE TABLE GROWS. It used to be a fixed 8192 slots, and `storeHandle` returned 0
// when they ran out -- which is where a whole class of baffling failures came from.
//
// Ring has NO DESTRUCTORS, so a Ring object that goes out of scope never calls the
// Free that would reach `releaseSlot`. Every wrapper object built to ask a question
// and then dropped -- the wrap-to-validate pattern this codebase has on record --
// consumed a slot permanently. The cliff was real and reachable in ordinary code:
//
//     new stzChar("1")       failed at call 4097   (2 handles each)
//     new stzNumber("1")     failed at call 1639
//     StringToNumber("1")    failed at call 1366
//
// and the failure did not say "out of handles". `storeHandle` returned 0, the Ring
// side read that as a null pointer, and the error surfaced far away as
// "Can not create char object!" -- from a validation branch that had simply run out
// of room to build the objects it validates with. Diagnosing it took a bisection of
// stzNumber's constructor.
//
// GROWING RATHER THAN EVICTING, deliberately. A fixed table can only make room by
// evicting a live entry, and nothing here knows whether an id is still held on the
// Ring side -- an evicted-then-reused slot would hand one object's pointer to
// another, which is far worse than an honest failure. Growth cannot do that: an id
// stays valid for the life of the process. The cost is 8 bytes per leaked handle,
// so a million leaked wrappers is 8MB -- visible in RSS, diagnosable, and survivable,
// where the cliff was none of those.
//
// This is not a licence to leak. `releaseSlot` still exists and the Free paths still
// call it; removing pointless wrapper objects is still the right fix at each call
// site (three were removed from stzNumber's constructor in the same change). What
// this removes is the CLIFF -- the point where correct code starts failing for
// reasons it cannot see.

// A SLOT IS REUSED, AND AN ID MUST NOT FOLLOW IT (threat-model R16). Releasing
// a slot empties it, and the next storeHandle may fill it with another object.
// A Ring COPY of the first object still holds the old id, and before generations
// that id resolved to whatever lives in the slot now -- another object, no error:
// the use-after-free class behind PHP2Shell, in its quiet form. So every slot
// carries a GENERATION, the id carries it too, and a release bumps it:
//
//     id = generation * 2^32 + (slot + 1)       exact in an f64 up to 2^53
//
// A stale id resolves to null, and a stale RELEASE is ignored, so a copy can
// neither read nor free a slot that now belongs to someone else. A fresh slot
// starts at generation 0, so its id is exactly the old 1-based number.
const INITIAL_HANDLES = 8192;
const GEN_MASK: u32 = 0xFFFFF; // 20 bits: (2^20 * 2^32) < 2^53
var handle_table: []?*anyopaque = &[_]?*anyopaque{};
var handle_backing: [INITIAL_HANDLES]?*anyopaque = [_]?*anyopaque{null} ** INITIAL_HANDLES;
var gen_table: []u32 = &[_]u32{};
var gen_backing: [INITIAL_HANDLES]u32 = [_]u32{0} ** INITIAL_HANDLES;
var handle_grown: bool = false;
var next_slot: usize = 0;

fn tableInit() void {
    if (handle_table.len == 0) {
        handle_table = handle_backing[0..];
        gen_table = gen_backing[0..];
    }
}

fn makeId(idx: usize, gen: u32) f64 {
    const v: u64 = (@as(u64, gen) << 32) | @as(u64, @intCast(idx + 1));
    return @floatFromInt(v);
}

// The slot an id names, when the id is well formed and its generation is the
// slot's current one; null otherwise.
fn slotOf(id: f64) ?usize {
    if (!(id >= 1) or id > 9007199254740991) return null;
    const v: u64 = @intFromFloat(id);
    const low: u64 = v & 0xFFFFFFFF;
    const gen: u32 = @intCast(v >> 32);
    if (low == 0 or low > handle_table.len) return null;
    const idx: usize = @intCast(low - 1);
    if (gen_table[idx] != gen) return null;
    return idx;
}

/// Double the table, copying what is there. Returns false if the allocator refuses,
/// in which case storeHandle falls back to its old behaviour of reporting failure.
fn grow() bool {
    const alloc = std.heap.c_allocator;
    const new_len = handle_table.len * 2;
    const bigger = alloc.alloc(?*anyopaque, new_len) catch return false;
    const gens = alloc.alloc(u32, new_len) catch {
        alloc.free(bigger);
        return false;
    };
    @memcpy(bigger[0..handle_table.len], handle_table);
    @memset(bigger[handle_table.len..], null);
    @memcpy(gens[0..gen_table.len], gen_table);
    @memset(gens[gen_table.len..], 0);
    if (handle_grown) {
        alloc.free(handle_table);
        alloc.free(gen_table);
    }
    handle_table = bigger;
    gen_table = gens;
    handle_grown = true;
    return true;
}

pub fn storeHandle(ptr: ?*anyopaque) f64 {
    const raw = ptr orelse return 0;
    tableInit();

    var attempts: usize = 0;
    while (attempts < 2) : (attempts += 1) {
        const n = handle_table.len;
        var i: usize = 0;
        while (i < n) : (i += 1) {
            const idx = (next_slot + i) % n;
            if (handle_table[idx] == null) {
                handle_table[idx] = raw;
                next_slot = (idx + 1) % n;
                return makeId(idx, gen_table[idx]);
            }
        }
        // full: grow once, then look again
        if (!grow()) return 0;
    }
    return 0;
}

pub fn resolveHandle(id: f64) ?*anyopaque {
    tableInit();
    const idx = slotOf(id) orelse return null;
    return handle_table[idx];
}

// Empty the slot and move it to its next generation, so every copy of this id
// goes stale at once. A stale or unknown id releases nothing.
pub fn releaseSlot(id: f64) void {
    tableInit();
    const idx = slotOf(id) orelse return;
    if (handle_table[idx] == null) return;
    handle_table[idx] = null;
    gen_table[idx] = (gen_table[idx] + 1) & GEN_MASK;
}

/// Like getHandle, for an object whose stale use must be an ERROR rather than a
/// silent null: a nonzero id that no longer resolves raises in Ring.
pub fn getHandleOrRaise(p: *anyopaque, n: c_int, comptime what: []const u8) ?*anyopaque {
    const id = ring_vm_api_getnumber(p, n);
    if (id == 0) return null;
    const ptr = resolveHandle(id);
    if (ptr == null) ring_vm_error(p, "This " ++ what ++ " was destroyed: a copy of it holds a handle that is no longer valid.");
    return ptr;
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
