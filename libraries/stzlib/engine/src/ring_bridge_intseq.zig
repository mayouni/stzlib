// Ring bridge for the IntSeq engine feature.
// Exposes the language-agnostic API at intseq.zig to Ring callers.

const mod = @import("intseq.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;

const HANDLE_TAG: [*:0]const u8 = "StzIntSeqHandle";

fn rh(p: *anyopaque, ptr: ?*anyopaque) void {
    R.retHandle(p, ptr);
}

fn gh(p: *anyopaque, n: i32) ?*anyopaque {
    return R.getHandle(p, n);
}

// Create: StzEngineIntSeqCreateCycle(start, step, cycle_param, restart, n, mode) -> handle
fn ring_CreateCycle(p: *anyopaque) callconv(.c) void {
    const start: i64 = @intFromFloat(gn(p, 1));
    const step_val: i64 = @intFromFloat(gn(p, 2));
    const cycle_param: i64 = @intFromFloat(gn(p, 3));
    const restart: i64 = @intFromFloat(gn(p, 4));
    const n_items_f: f64 = gn(p, 5);
    const mode: i32 = @intFromFloat(gn(p, 6));
    const n_items: usize = if (n_items_f < 1) 0 else @intFromFloat(n_items_f);
    const seq = mod.stz_intseq_create_cycle(start, step_val, cycle_param, restart, n_items, mode);
    rh(p, @ptrCast(seq));
}

fn ring_Len(p: *anyopaque) callconv(.c) void {
    const h = gh(p, 1) orelse {
        rn(p, 0);
        return;
    };
    rn(p, @floatFromInt(mod.stz_intseq_len(@ptrCast(@alignCast(h)))));
}

fn ring_At(p: *anyopaque) callconv(.c) void {
    const h = gh(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const idx: usize = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(mod.stz_intseq_at(@ptrCast(@alignCast(h)), idx)));
}

fn ring_First(p: *anyopaque) callconv(.c) void {
    const h = gh(p, 1) orelse {
        rn(p, 0);
        return;
    };
    rn(p, @floatFromInt(mod.stz_intseq_first(@ptrCast(@alignCast(h)))));
}

fn ring_Last(p: *anyopaque) callconv(.c) void {
    const h = gh(p, 1) orelse {
        rn(p, 0);
        return;
    };
    rn(p, @floatFromInt(mod.stz_intseq_last(@ptrCast(@alignCast(h)))));
}

fn ring_Sum(p: *anyopaque) callconv(.c) void {
    const h = gh(p, 1) orelse {
        rn(p, 0);
        return;
    };
    rn(p, @floatFromInt(mod.stz_intseq_sum(@ptrCast(@alignCast(h)))));
}

fn ring_Min(p: *anyopaque) callconv(.c) void {
    const h = gh(p, 1) orelse {
        rn(p, 0);
        return;
    };
    rn(p, @floatFromInt(mod.stz_intseq_min(@ptrCast(@alignCast(h)))));
}

fn ring_Max(p: *anyopaque) callconv(.c) void {
    const h = gh(p, 1) orelse {
        rn(p, 0);
        return;
    };
    rn(p, @floatFromInt(mod.stz_intseq_max(@ptrCast(@alignCast(h)))));
}

fn ring_CountValue(p: *anyopaque) callconv(.c) void {
    const h = gh(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const v: i64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(mod.stz_intseq_count_value(@ptrCast(@alignCast(h)), v)));
}

// ToRingList: marshal the contents into a Ring list. This is the
// OPT-IN slow path -- ring_list_adddouble is O(N) per call so this
// is O(N^2), but it's only called when the host language genuinely
// needs a host-native list. Engine-fast queries (Sum, At, etc.)
// avoid this entirely.
fn ring_ToRingList(p: *anyopaque) callconv(.c) void {
    const h = gh(p, 1) orelse {
        const empty = R.ring_vm_api_newlist(p) orelse return;
        R.ring_vm_api_retlist(p, empty);
        return;
    };
    const seq: *const mod.IntSeq = @ptrCast(@alignCast(h));
    const pOut = R.ring_vm_api_newlist(p) orelse return;
    for (seq.items) |x| {
        R.ring_list_adddouble(pOut, @floatFromInt(x));
    }
    R.ring_vm_api_retlist(p, pOut);
}

fn ring_Free(p: *anyopaque) callconv(.c) void {
    if (gh(p, 1)) |h| {
        mod.stz_intseq_free(@ptrCast(@alignCast(h)));
    }
    rn(p, 1);
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = @constCast("stzengineintseqcreatecycle"), .func = ring_CreateCycle },
    .{ .name = @constCast("stzengineintseqlen"), .func = ring_Len },
    .{ .name = @constCast("stzengineintseqat"), .func = ring_At },
    .{ .name = @constCast("stzengineintseqfirst"), .func = ring_First },
    .{ .name = @constCast("stzengineintseqlast"), .func = ring_Last },
    .{ .name = @constCast("stzengineintseqsum"), .func = ring_Sum },
    .{ .name = @constCast("stzengineintseqmin"), .func = ring_Min },
    .{ .name = @constCast("stzengineintseqmax"), .func = ring_Max },
    .{ .name = @constCast("stzengineintseqcountvalue"), .func = ring_CountValue },
    .{ .name = @constCast("stzengineintseqtoringlist"), .func = ring_ToRingList },
    .{ .name = @constCast("stzengineintseqfree"), .func = ring_Free },
};
