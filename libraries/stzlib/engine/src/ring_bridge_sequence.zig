const mod = @import("sequence.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;

fn ring_Create(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    const start: i64 = @intFromFloat(gn(p, 2));
    const step_val: i64 = @intFromFloat(gn(p, 3));
    const mode: i32 = @intFromFloat(gn(p, 4));
    rn(p, @floatFromInt(mod.stz_seq_create(name, name_len, start, step_val, mode)));
}

fn ring_SetBounds(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    const min_v: i64 = @intFromFloat(gn(p, 2));
    const max_v: i64 = @intFromFloat(gn(p, 3));
    rn(p, @floatFromInt(mod.stz_seq_set_bounds(name, name_len, min_v, max_v)));
}

fn ring_Next(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_seq_next(name, name_len)));
}

fn ring_Current(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_seq_current(name, name_len)));
}

fn ring_Iteration(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_seq_iteration(name, name_len)));
}

fn ring_Reset(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    mod.stz_seq_reset(name, name_len);
    rn(p, 1);
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_seq_count()));
}

fn ring_Destroy(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    mod.stz_seq_destroy(name, name_len);
    rn(p, 1);
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_seq_clear();
}

// ─── Counter fill: build a Ring list of N cycled values in ONE C call ───
//
// Two cycle modes are supported, matching stzCounter's two modes:
//
//   mode = 1  -> "WhenYouReach" semantics. Generate values starting at
//                `start`, incrementing by `step`. When the running
//                value would equal `cycle_param`, OR when the loop
//                index i equals `cycle_param`, reset the value to
//                `restart`. (cycle_param == 0 means linear, no reset.)
//
//   mode = 2  -> "AfterYouSkip" semantics. The cycle length is
//                `cycle_param + 1`. After that many items, reset to
//                `restart`. Index-based: at every multiple of cycle
//                length, reset.
//
// Args (Ring side): start, step, cycle_param, restart, n_items, mode
// Returns:          Ring list of n_items numbers.
//
// This delegates the hot loop to C so the O(N^2) class-method-loop
// penalty in Ring 1.26 is bypassed entirely.

fn ring_CounterFill(p: *anyopaque) callconv(.c) void {
    const start: i64 = @intFromFloat(gn(p, 1));
    const step_val: i64 = @intFromFloat(gn(p, 2));
    const cycle_param: i64 = @intFromFloat(gn(p, 3));
    const restart: i64 = @intFromFloat(gn(p, 4));
    const n_items_f: f64 = gn(p, 5);
    const mode: i32 = @intFromFloat(gn(p, 6));

    const pOut = R.ring_vm_api_newlist(p) orelse return;

    if (n_items_f < 1) {
        R.ring_vm_api_retlist(p, pOut);
        return;
    }
    const n_items: u64 = @intFromFloat(n_items_f);

    var n: i64 = start;
    var i: u64 = 0;

    if (mode == 1) {
        // WhenYouReach: reset when loop index OR running value hits cycle_param.
        // cycle_param == 0 means no cycle (linear count).
        while (i < n_items) : (i += 1) {
            const idx_i64: i64 = @intCast(i);
            // Index-based reset: i+1 == cycle_param (Ring 1-based)
            if (cycle_param != 0 and (idx_i64 + start) == cycle_param) {
                n = restart;
            }
            R.ring_list_adddouble(pOut, @floatFromInt(n));
            n += step_val;
            if (cycle_param != 0 and n == cycle_param) {
                n = restart;
            }
        }
    } else if (mode == 2) {
        // AfterYouSkip: cycle length is cycle_param + 1.
        const cycle_len: i64 = cycle_param + 1;
        while (i < n_items) : (i += 1) {
            const idx_i64: i64 = @intCast(i);
            if (cycle_len > 0 and @rem(idx_i64 + start, cycle_len) == 0) {
                n = restart;
            }
            R.ring_list_adddouble(pOut, @floatFromInt(n));
            n += step_val;
            if (cycle_len > 0 and n == cycle_len) {
                n = restart;
            }
        }
    }
    // mode 0 or unknown: empty list

    R.ring_vm_api_retlist(p, pOut);
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = @constCast("stzengineseqcreate"), .func = ring_Create },
    .{ .name = @constCast("stzengineseqsetbounds"), .func = ring_SetBounds },
    .{ .name = @constCast("stzengineseqnext"), .func = ring_Next },
    .{ .name = @constCast("stzengineseqcurrent"), .func = ring_Current },
    .{ .name = @constCast("stzengineseqiteration"), .func = ring_Iteration },
    .{ .name = @constCast("stzengineseqreset"), .func = ring_Reset },
    .{ .name = @constCast("stzengineseqcount"), .func = ring_Count },
    .{ .name = @constCast("stzengineseqdestroy"), .func = ring_Destroy },
    .{ .name = @constCast("stzengineseqclear"), .func = ring_Clear },
    .{ .name = @constCast("stzenginecounterfill"), .func = ring_CounterFill },
};
