// Ring bridge for stz_gpu -- the GPU lifecycle layer (G1).
// Numbers cross as f64; buffer/kernel ids are integer-valued doubles (exact
// to 2^53, far beyond any handle count). Lists of numbers marshal to f32
// staging engine-side -- ONE crossing per upload, per the residency law.
const std = @import("std");
const gpu = @import("gpu.zig");
const ops = @import("gpu_ops.zig");
const wgsl = @import("gpu_wgsl.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const allocator = std.heap.c_allocator;

fn getStr(p: *anyopaque, n: c_int) []const u8 {
    const ptr = R.ring_vm_api_getstring(p, n);
    const len = R.ring_vm_api_getstringsize(p, n);
    return ptr[0..len];
}

fn ring_Init(p: *anyopaque) callconv(.c) void {
    const path = getStr(p, 1);
    const z = allocator.dupeZ(u8, path) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(z);
    rn(p, @floatFromInt(gpu.stz_gpu_init(z)));
}

fn ring_Shutdown(p: *anyopaque) callconv(.c) void {
    gpu.stz_gpu_shutdown();
    rn(p, 1);
}

fn ring_IsAvailable(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gpu.stz_gpu_is_available()));
}

fn ring_AdapterCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gpu.stz_gpu_adapter_count()));
}

fn ring_AdapterName(p: *anyopaque) callconv(.c) void {
    var buf: [256]u8 = undefined;
    const n = gpu.stz_gpu_adapter_name(@intFromFloat(gn(p, 1)), &buf, buf.len);
    R.ring_vm_api_retstring2(p, &buf, @intCast(n));
}

fn ring_SelectAdapter(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gpu.stz_gpu_select_adapter(@intFromFloat(gn(p, 1)))));
}

fn ring_SelectedAdapter(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gpu.stz_gpu_selected_adapter()));
}

fn ring_SetVramBudget(p: *anyopaque) callconv(.c) void {
    gpu.stz_gpu_set_vram_budget(gn(p, 1));
}

fn ring_VramBudget(p: *anyopaque) callconv(.c) void {
    rn(p, gpu.stz_gpu_vram_budget());
}

fn ring_VramInUse(p: *anyopaque) callconv(.c) void {
    rn(p, gpu.stz_gpu_vram_in_use());
}

fn ring_SetTileLimit(p: *anyopaque) callconv(.c) void {
    gpu.stz_gpu_set_tile_limit(gn(p, 1));
}

fn ring_TileLimit(p: *anyopaque) callconv(.c) void {
    rn(p, gpu.stz_gpu_tile_limit());
}

fn ring_Counter(p: *anyopaque) callconv(.c) void {
    rn(p, gpu.stz_gpu_counter(@intFromFloat(gn(p, 1))));
}

fn ring_CountersReset(p: *anyopaque) callconv(.c) void {
    gpu.stz_gpu_counters_reset();
    rn(p, 1);
}

fn ring_LastError(p: *anyopaque) callconv(.c) void {
    const e = gpu.lastError();
    R.ring_vm_api_retstring2(p, e.ptr, @intCast(e.len));
}

// ---------------- buffers

fn ring_BufferNew(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gpu.stz_gpu_buffer_new(gn(p, 1))));
}

fn ring_BufferFree(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gpu.stz_gpu_buffer_free(@intFromFloat(gn(p, 1)))));
}

fn ring_BufferSize(p: *anyopaque) callconv(.c) void {
    rn(p, gpu.stz_gpu_buffer_size(@intFromFloat(gn(p, 1))));
}

// UploadList(id, aNumbers) -> status. Ring f64 -> f32 staging -> device.
fn ring_BufferUploadList(p: *anyopaque) callconv(.c) void {
    const id: i64 = @intFromFloat(gn(p, 1));
    const lst = R.gl(p, 2) orelse {
        rn(p, gpu.BAD_ARG);
        return;
    };
    const n: usize = @intCast(R.ringListSize(lst));
    if (n == 0) {
        rn(p, gpu.BAD_ARG);
        return;
    }
    const staging = allocator.alloc(f32, n) catch {
        rn(p, gpu.BAD_ARG);
        return;
    };
    defer allocator.free(staging);
    for (0..n) |i| {
        const item = R.ring_list_getitem_gc(null, lst, @intCast(i + 1)) orelse {
            staging[i] = 0;
            continue;
        };
        staging[i] = @floatCast(R.ring_item_getnumber(item));
    }
    rn(p, @floatFromInt(gpu.stz_gpu_buffer_write(id, @ptrCast(staging.ptr), @floatFromInt(n * 4))));
}

// DownloadList(id, nCount) -> Ring list of nCount numbers ([] on failure).
fn ring_BufferDownloadList(p: *anyopaque) callconv(.c) void {
    const id: i64 = @intFromFloat(gn(p, 1));
    const n: usize = @intFromFloat(gn(p, 2));
    const out = R.ring_vm_api_newlist(p) orelse return;
    if (n == 0) {
        R.ring_vm_api_retlist(p, out);
        return;
    }
    const staging = allocator.alloc(f32, n) catch {
        R.ring_vm_api_retlist(p, out);
        return;
    };
    defer allocator.free(staging);
    const status = gpu.stz_gpu_buffer_read(id, @ptrCast(staging.ptr), @floatFromInt(n * 4));
    if (status == gpu.OK) {
        for (staging) |v| R.ring_list_adddouble(out, @floatCast(v));
    }
    R.ring_vm_api_retlist(p, out);
}

// ---------------- kernels

fn ring_KernelCompile(p: *anyopaque) callconv(.c) void {
    const text = getStr(p, 1);
    rn(p, @floatFromInt(gpu.stz_gpu_kernel_compile(text.ptr, @floatFromInt(text.len))));
}

// Dispatch(nKernel, aBufferIds, wx, wy) -> status
fn ring_Dispatch(p: *anyopaque) callconv(.c) void {
    const kernel: i64 = @intFromFloat(gn(p, 1));
    const lst = R.gl(p, 2) orelse {
        rn(p, gpu.BAD_ARG);
        return;
    };
    const n: usize = @intCast(R.ringListSize(lst));
    if (n == 0 or n > 8) {
        rn(p, gpu.BAD_ARG);
        return;
    }
    var ids: [8]i64 = undefined;
    for (0..n) |i| {
        const item = R.ring_list_getitem_gc(null, lst, @intCast(i + 1)) orelse {
            rn(p, gpu.BAD_ARG);
            return;
        };
        ids[i] = @intFromFloat(R.ring_item_getnumber(item));
    }
    rn(p, @floatFromInt(gpu.stz_gpu_dispatch(kernel, &ids, @intCast(n), gn(p, 3), gn(p, 4))));
}

fn ring_BatchBegin(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gpu.stz_gpu_batch_begin()));
}

fn ring_BatchEnd(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gpu.stz_gpu_batch_end()));
}

fn ring_BatchActive(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gpu.stz_gpu_batch_active()));
}

fn ring_Sync(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gpu.stz_gpu_sync()));
}

// ---------------- calibration

fn ring_CalibSet(p: *anyopaque) callconv(.c) void {
    const name = getStr(p, 1);
    gpu.stz_gpu_calib_set(name.ptr, @floatFromInt(name.len), gn(p, 2));
    rn(p, 1);
}

fn ring_CalibGet(p: *anyopaque) callconv(.c) void {
    const name = getStr(p, 1);
    rn(p, gpu.stz_gpu_calib_get(name.ptr, @floatFromInt(name.len)));
}

fn ring_ShouldDispatch(p: *anyopaque) callconv(.c) void {
    const name = getStr(p, 1);
    rn(p, @floatFromInt(gpu.stz_gpu_should_dispatch(name.ptr, @floatFromInt(name.len), gn(p, 2))));
}

// ---------------- G2 op library

fn ring_OpMatmul(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ops.stz_gpu_op_matmul(
        @intFromFloat(gn(p, 1)),
        @intFromFloat(gn(p, 2)),
        @intFromFloat(gn(p, 3)),
        gn(p, 4),
        gn(p, 5),
        gn(p, 6),
    )));
}

fn ring_OpPairDist(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ops.stz_gpu_op_pairdist(
        @intFromFloat(gn(p, 1)),
        @intFromFloat(gn(p, 2)),
        @intFromFloat(gn(p, 3)),
        gn(p, 4),
        gn(p, 5),
        gn(p, 6),
    )));
}

fn ring_OpAxpby(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ops.stz_gpu_op_axpby(
        gn(p, 1),
        @intFromFloat(gn(p, 2)),
        gn(p, 3),
        @intFromFloat(gn(p, 4)),
        @intFromFloat(gn(p, 5)),
        gn(p, 6),
    )));
}

fn ring_OpMul(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ops.stz_gpu_op_mul(
        @intFromFloat(gn(p, 1)),
        @intFromFloat(gn(p, 2)),
        @intFromFloat(gn(p, 3)),
        gn(p, 4),
    )));
}

fn ring_OpScaleInPlace(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ops.stz_gpu_op_scale_inplace(
        @intFromFloat(gn(p, 1)),
        gn(p, 2),
        gn(p, 3),
    )));
}

fn ring_OpSoftmax(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ops.stz_gpu_op_softmax(
        @intFromFloat(gn(p, 1)),
        @intFromFloat(gn(p, 2)),
        gn(p, 3),
    )));
}

// Reductions return [status, value] -- the status is part of the answer,
// not a side channel.
fn ring_OpSum(p: *anyopaque) callconv(.c) void {
    var val: f64 = 0;
    const st = ops.stz_gpu_op_sum(@intFromFloat(gn(p, 1)), gn(p, 2), &val);
    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, @floatFromInt(st));
    R.ring_list_adddouble(out, val);
    R.ring_vm_api_retlist(p, out);
}

fn ring_OpDot(p: *anyopaque) callconv(.c) void {
    var val: f64 = 0;
    const st = ops.stz_gpu_op_dot(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)), gn(p, 3), &val);
    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, @floatFromInt(st));
    R.ring_list_adddouble(out, val);
    R.ring_vm_api_retlist(p, out);
}

// ---------------- G4 declarative surface

// WgslElementwise(cSpec) -> generated WGSL text, or "" (reason via WgslError).
// Pure text work, needs no device -- ToWGSL() works on GPU-less machines.
fn ring_WgslElementwise(p: *anyopaque) callconv(.c) void {
    const spec = getStr(p, 1);
    var buf: [8192]u8 = undefined;
    const n = wgsl.stz_gpu_wgsl_elementwise(spec.ptr, @floatFromInt(spec.len), &buf, buf.len);
    if (n < 0) {
        R.ring_vm_api_retstring2(p, &buf, 0);
        return;
    }
    R.ring_vm_api_retstring2(p, &buf, @intCast(n));
}

fn ring_WgslError(p: *anyopaque) callconv(.c) void {
    var buf: [256]u8 = undefined;
    const n = wgsl.stz_gpu_wgsl_error(&buf, buf.len);
    R.ring_vm_api_retstring2(p, &buf, @intCast(n));
}

// DispatchParams(hKernel, nElems, aScalars, aBufIds, wx) -> status.
// Packs the params uniform the generated kernels expect: u32 n, u32 pad,
// then the declared scalars as f32 IN DECLARATION ORDER.
fn ring_DispatchParams(p: *anyopaque) callconv(.c) void {
    const kernel: i64 = @intFromFloat(gn(p, 1));
    const nelems: u32 = @intFromFloat(gn(p, 2));
    var blob: [64]u8 = @splat(0);
    std.mem.writeInt(u32, blob[0..4], nelems, .little);
    var blen: usize = 8;
    if (R.gl(p, 3)) |lst| {
        const ns: usize = @intCast(R.ringListSize(lst));
        if (ns > 14) {
            rn(p, gpu.BAD_ARG);
            return;
        }
        for (0..ns) |i| {
            const item = R.ring_list_getitem_gc(null, lst, @intCast(i + 1)) orelse continue;
            const v: f32 = @floatCast(R.ring_item_getnumber(item));
            std.mem.writeInt(u32, blob[8 + i * 4 ..][0..4], @bitCast(v), .little);
        }
        blen = 8 + ns * 4;
    }
    const bl = R.gl(p, 4) orelse {
        rn(p, gpu.BAD_ARG);
        return;
    };
    const nb: usize = @intCast(R.ringListSize(bl));
    if (nb == 0 or nb > 8) {
        rn(p, gpu.BAD_ARG);
        return;
    }
    var ids: [8]i64 = undefined;
    for (0..nb) |i| {
        const item = R.ring_list_getitem_gc(null, bl, @intCast(i + 1)) orelse {
            rn(p, gpu.BAD_ARG);
            return;
        };
        ids[i] = @intFromFloat(R.ring_item_getnumber(item));
    }
    rn(p, @floatFromInt(gpu.stz_gpu_dispatch_params(kernel, &blob, @floatFromInt(blen), &ids, @intCast(nb), gn(p, 5), 1)));
}

// TopK(hDistances, n, k) -> [status, idx0, dist0, idx1, dist1, ...]
// (indices 0-based -- the engine's truth; faces translate to 1-based).
fn ring_OpTopK(p: *anyopaque) callconv(.c) void {
    const n = gn(p, 2);
    const k: usize = @intFromFloat(gn(p, 3));
    const out = R.ring_vm_api_newlist(p) orelse return;
    if (k == 0 or k > 65536) {
        R.ring_list_adddouble(out, gpu.BAD_ARG);
        R.ring_vm_api_retlist(p, out);
        return;
    }
    const idx = allocator.alloc(f64, k) catch {
        R.ring_list_adddouble(out, gpu.BAD_ARG);
        R.ring_vm_api_retlist(p, out);
        return;
    };
    defer allocator.free(idx);
    const dist = allocator.alloc(f64, k) catch {
        R.ring_list_adddouble(out, gpu.BAD_ARG);
        R.ring_vm_api_retlist(p, out);
        return;
    };
    defer allocator.free(dist);
    var count: i32 = 0;
    const st = ops.stz_gpu_op_topk(@intFromFloat(gn(p, 1)), n, @floatFromInt(k), idx.ptr, dist.ptr, &count);
    R.ring_list_adddouble(out, @floatFromInt(st));
    if (st == gpu.OK) {
        for (0..@intCast(count)) |i| {
            R.ring_list_adddouble(out, idx[i]);
            R.ring_list_adddouble(out, dist[i]);
        }
    }
    R.ring_vm_api_retlist(p, out);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginegpuinit", .func = &ring_Init },
    .{ .name = "stzenginegpushutdown", .func = &ring_Shutdown },
    .{ .name = "stzenginegpuisavailable", .func = &ring_IsAvailable },
    .{ .name = "stzenginegpuadaptercount", .func = &ring_AdapterCount },
    .{ .name = "stzenginegpuadaptername", .func = &ring_AdapterName },
    .{ .name = "stzenginegpuselectadapter", .func = &ring_SelectAdapter },
    .{ .name = "stzenginegpuselectedadapter", .func = &ring_SelectedAdapter },
    .{ .name = "stzenginegpusetvrambudget", .func = &ring_SetVramBudget },
    .{ .name = "stzenginegpuvrambudget", .func = &ring_VramBudget },
    .{ .name = "stzenginegpuvraminuse", .func = &ring_VramInUse },
    .{ .name = "stzenginegpusettilelimit", .func = &ring_SetTileLimit },
    .{ .name = "stzenginegputilelimit", .func = &ring_TileLimit },
    .{ .name = "stzenginegpucounter", .func = &ring_Counter },
    .{ .name = "stzenginegpucountersreset", .func = &ring_CountersReset },
    .{ .name = "stzenginegpulasterror", .func = &ring_LastError },
    .{ .name = "stzenginegpubuffernew", .func = &ring_BufferNew },
    .{ .name = "stzenginegpubufferfree", .func = &ring_BufferFree },
    .{ .name = "stzenginegpubuffersize", .func = &ring_BufferSize },
    .{ .name = "stzenginegpubufferuploadlist", .func = &ring_BufferUploadList },
    .{ .name = "stzenginegpubufferdownloadlist", .func = &ring_BufferDownloadList },
    .{ .name = "stzenginegpukernelcompile", .func = &ring_KernelCompile },
    .{ .name = "stzenginegpudispatch", .func = &ring_Dispatch },
    .{ .name = "stzenginegpusync", .func = &ring_Sync },
    .{ .name = "stzenginegpubatchbegin", .func = &ring_BatchBegin },
    .{ .name = "stzenginegpubatchend", .func = &ring_BatchEnd },
    .{ .name = "stzenginegpubatchactive", .func = &ring_BatchActive },
    .{ .name = "stzenginegpucalibset", .func = &ring_CalibSet },
    .{ .name = "stzenginegpucalibget", .func = &ring_CalibGet },
    .{ .name = "stzenginegpushoulddispatch", .func = &ring_ShouldDispatch },
    .{ .name = "stzenginegpuopmatmul", .func = &ring_OpMatmul },
    .{ .name = "stzenginegpuoppairdist", .func = &ring_OpPairDist },
    .{ .name = "stzenginegpuopaxpby", .func = &ring_OpAxpby },
    .{ .name = "stzenginegpuopmul", .func = &ring_OpMul },
    .{ .name = "stzenginegpuopscaleinplace", .func = &ring_OpScaleInPlace },
    .{ .name = "stzenginegpuopsoftmax", .func = &ring_OpSoftmax },
    .{ .name = "stzenginegpuopsum", .func = &ring_OpSum },
    .{ .name = "stzenginegpuopdot", .func = &ring_OpDot },
    .{ .name = "stzenginegpuoptopk", .func = &ring_OpTopK },
    .{ .name = "stzenginegpuwgslelementwise", .func = &ring_WgslElementwise },
    .{ .name = "stzenginegpuwgslerror", .func = &ring_WgslError },
    .{ .name = "stzenginegpudispatchparams", .func = &ring_DispatchParams },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
