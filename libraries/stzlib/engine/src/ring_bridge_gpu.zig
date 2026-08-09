// Ring bridge for stz_gpu -- the GPU lifecycle layer (G1).
// Numbers cross as f64; buffer/kernel ids are integer-valued doubles (exact
// to 2^53, far beyond any handle count). Lists of numbers marshal to f32
// staging engine-side -- ONE crossing per upload, per the residency law.
const std = @import("std");
const gpu = @import("gpu.zig");
const ops = @import("gpu_ops.zig");
const wgsl = @import("gpu_wgsl.zig");
const render = @import("gpu_render.zig");
// named gtext: these directories sit on C include paths, and a bare `text`
// local already exists in older bridge fns
const gtext = @import("gpu_text.zig");
const scene = @import("gpu_scene.zig");
const atlas = @import("gpu_atlas.zig");
const gmesh = @import("gpu_mesh.zig");
const s3d = @import("gpu_scene3d.zig");
const gm = @import("gpu_math.zig");
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

// UploadListU32(id, aNumbers) -> status. For INDEX data (GR1): Ring numbers
// staged as little-endian u32, not f32.
fn ring_BufferUploadListU32(p: *anyopaque) callconv(.c) void {
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
    const staging = allocator.alloc(u32, n) catch {
        rn(p, gpu.BAD_ARG);
        return;
    };
    defer allocator.free(staging);
    for (0..n) |i| {
        const item = R.ring_list_getitem_gc(null, lst, @intCast(i + 1)) orelse {
            staging[i] = 0;
            continue;
        };
        staging[i] = @intFromFloat(R.ring_item_getnumber(item));
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

// ---------------- GR1 render lifecycle

fn ring_TextureNew(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gpu.stz_gpu_texture_new(gn(p, 1), gn(p, 2), gn(p, 3))));
}

fn ring_TextureFree(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gpu.stz_gpu_texture_free(@intFromFloat(gn(p, 1)))));
}

fn ring_TextureWidth(p: *anyopaque) callconv(.c) void {
    rn(p, gpu.stz_gpu_texture_width(@intFromFloat(gn(p, 1))));
}

fn ring_TextureHeight(p: *anyopaque) callconv(.c) void {
    rn(p, gpu.stz_gpu_texture_height(@intFromFloat(gn(p, 1))));
}

// TextureWrite(id, cRgbaBytes) -> status. The string IS the pixel payload
// (binary-safe, counted); its length must be exactly w*h*4.
fn ring_TextureWrite(p: *anyopaque) callconv(.c) void {
    const id: i64 = @intFromFloat(gn(p, 1));
    const bytes = getStr(p, 2);
    rn(p, @floatFromInt(gpu.stz_gpu_texture_write(id, bytes.ptr, @floatFromInt(bytes.len))));
}

// RenderPipeline(cWgsl, cFmt, bBlend) -> pipeline id (cached) or 0
fn ring_RenderPipeline(p: *anyopaque) callconv(.c) void {
    const text = getStr(p, 1);
    const fmt = getStr(p, 2);
    rn(p, @floatFromInt(render.stz_gpu_render_pipeline(text.ptr, @floatFromInt(text.len), fmt.ptr, @floatFromInt(fmt.len), gn(p, 3))));
}

fn ring_RenderBegin(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(render.stz_gpu_render_begin(@intFromFloat(gn(p, 1)), gn(p, 2), gn(p, 3), gn(p, 4), gn(p, 5))));
}

fn ring_RenderDraw(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(render.stz_gpu_render_draw(
        @intFromFloat(gn(p, 1)),
        @intFromFloat(gn(p, 2)),
        gn(p, 3),
        gn(p, 4),
        @intFromFloat(gn(p, 5)),
    )));
}

fn ring_RenderDrawIndexed(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(render.stz_gpu_render_draw_indexed(
        @intFromFloat(gn(p, 1)),
        @intFromFloat(gn(p, 2)),
        @intFromFloat(gn(p, 3)),
        gn(p, 4),
        @intFromFloat(gn(p, 5)),
    )));
}

fn ring_RenderEnd(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(render.stz_gpu_render_end()));
}

fn ring_RenderActive(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(render.stz_gpu_render_active()));
}

// TargetRead(hTarget) -> tight RGBA8 bytes as a binary string ("" on refusal)
fn ring_TargetRead(p: *anyopaque) callconv(.c) void {
    const id: i64 = @intFromFloat(gn(p, 1));
    const w = gpu.stz_gpu_texture_width(id);
    const h = gpu.stz_gpu_texture_height(id);
    if (w < 1 or h < 1) {
        R.ring_vm_api_retstring2(p, "", 0);
        return;
    }
    const n: usize = @intFromFloat(w * h * 4);
    const buf = allocator.alloc(u8, n) catch {
        R.ring_vm_api_retstring2(p, "", 0);
        return;
    };
    defer allocator.free(buf);
    const st = render.stz_gpu_target_read(id, buf.ptr, @floatFromInt(n));
    if (st != gpu.OK) {
        R.ring_vm_api_retstring2(p, "", 0);
        return;
    }
    R.ring_vm_api_retstring2(p, buf.ptr, @intCast(n));
}

// PngEncode(nW, nH, cRgbaBytes, nLevel) -> PNG bytes ("" on refusal).
// Level 1 is the measured default; pass 0 to take it.
fn ring_PngEncode(p: *anyopaque) callconv(.c) void {
    const w: u32 = @intFromFloat(gn(p, 1));
    const h: u32 = @intFromFloat(gn(p, 2));
    const rgba = getStr(p, 3);
    const level: i32 = @intFromFloat(gn(p, 4));
    const png = render.pngEncode(w, h, rgba, level) catch {
        R.ring_vm_api_retstring2(p, "", 0);
        return;
    };
    defer allocator.free(png);
    R.ring_vm_api_retstring2(p, png.ptr, @intCast(png.len));
}

// ImageDecode(cBytes) -> [nW, nH, cRgbaBytes] or [] on failure (stb_image:
// PNG/JPG/BMP/GIF/TGA/PSD, always RGBA8 out)
fn ring_ImageDecode(p: *anyopaque) callconv(.c) void {
    const bytes = getStr(p, 1);
    const out = R.ring_vm_api_newlist(p) orelse return;
    if (render.imageDecode(bytes)) |img| {
        defer allocator.free(img.rgba);
        R.ring_list_adddouble(out, @floatFromInt(img.w));
        R.ring_list_adddouble(out, @floatFromInt(img.h));
        R.ring_list_addstring2(out, img.rgba.ptr, @intCast(img.rgba.len));
    }
    R.ring_vm_api_retlist(p, out);
}

// ---------------- GR2 text pipeline (CPU-side: works with NO device)

// FontLoad(cFontBytes) -> gen-keyed id (0 = refusal)
fn ring_FontLoad(p: *anyopaque) callconv(.c) void {
    const bytes = getStr(p, 1);
    rn(p, @floatFromInt(gtext.fontLoad(bytes)));
}

fn ring_FontFree(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gtext.fontFree(@intFromFloat(gn(p, 1)))));
}

fn ring_FontGlyphCount(p: *anyopaque) callconv(.c) void {
    rn(p, gtext.fontGlyphCount(@intFromFloat(gn(p, 1))));
}

// TextLayout(hFont, cUtf8, nSizePx) ->
//   [nWidth, nRunCount, [ [gid, x, y, byteCluster], ... ]]  or [] on refusal.
// Glyphs come in VISUAL left-to-right order (bidi already applied); gids
// are GLYPH ids (post-shaping), never codepoints.
fn ring_TextLayout(p: *anyopaque) callconv(.c) void {
    const font: i64 = @intFromFloat(gn(p, 1));
    const utf8 = getStr(p, 2);
    const out = R.ring_vm_api_newlist(p) orelse return;
    const layout = gtext.textLayout(font, utf8, gn(p, 3)) catch {
        R.ring_vm_api_retlist(p, out);
        return;
    };
    defer layout.deinit();
    R.ring_list_adddouble(out, layout.width);
    R.ring_list_adddouble(out, @floatFromInt(layout.run_count));
    const gl = R.ring_list_newlist(out) orelse {
        R.ring_vm_api_retlist(p, out);
        return;
    };
    for (layout.glyphs) |g| {
        const item = R.ring_list_newlist(gl) orelse continue;
        R.ring_list_adddouble(item, @floatFromInt(g.gid));
        R.ring_list_adddouble(item, g.x);
        R.ring_list_adddouble(item, g.y);
        R.ring_list_adddouble(item, @floatFromInt(g.cluster));
    }
    R.ring_vm_api_retlist(p, out);
}

// GlyphBitmap(hFont, nGlyphId, nSizePx) -> [w, h, xoff, yoff, cGrayBytes]
// or [] on refusal. Whitespace glyphs answer [0,0,0,0,""] -- ink-free, valid.
fn ring_GlyphBitmap(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const bm = gtext.glyphBitmap(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)), gn(p, 3)) catch {
        R.ring_vm_api_retlist(p, out);
        return;
    };
    defer bm.deinit();
    R.ring_list_adddouble(out, @floatFromInt(bm.w));
    R.ring_list_adddouble(out, @floatFromInt(bm.h));
    R.ring_list_adddouble(out, @floatFromInt(bm.xoff));
    R.ring_list_adddouble(out, @floatFromInt(bm.yoff));
    R.ring_list_addstring2(out, bm.gray.ptr, @intCast(bm.gray.len));
    R.ring_vm_api_retlist(p, out);
}

// ---------------- GR2b display list (one model, two renderers)
//
// Colors cross as PACKED 0xRRGGBBAA doubles: a 32-bit value is exact in
// f64 (2^53 headroom), and one argument beats four. Point lists cross FLAT
// ([x0,y0,x1,y1,...]) -- one shape of list to get wrong instead of two.

fn packedColor(p: *anyopaque, n: c_int) u32 {
    const v = gn(p, n);
    if (v < 0 or v > 4294967295.0) return 0;
    return @intFromFloat(v);
}

fn flatPoints(p: *anyopaque, n: c_int) ?[]f64 {
    const lst = R.gl(p, n) orelse return null;
    const cnt: usize = @intCast(R.ringListSize(lst));
    if (cnt == 0) return null;
    const out = allocator.alloc(f64, cnt) catch return null;
    for (0..cnt) |i| {
        const item = R.ring_list_getitem_gc(null, lst, @intCast(i + 1)) orelse {
            out[i] = 0;
            continue;
        };
        out[i] = R.ring_item_getnumber(item);
    }
    return out;
}

fn ring_SceneNew(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(scene.sceneNew(gn(p, 1), gn(p, 2))));
}

fn ring_SceneFree(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(scene.sceneFree(@intFromFloat(gn(p, 1)))));
}

fn ring_SceneClear(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(scene.sceneClear(@intFromFloat(gn(p, 1)), packedColor(p, 2))));
}

fn ring_SceneRect(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(scene.sceneRect(@intFromFloat(gn(p, 1)), gn(p, 2), gn(p, 3), gn(p, 4), gn(p, 5), packedColor(p, 6))));
}

fn ring_SceneRectGradient(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(scene.sceneRectGradient(
        @intFromFloat(gn(p, 1)),
        gn(p, 2),
        gn(p, 3),
        gn(p, 4),
        gn(p, 5),
        packedColor(p, 6),
        packedColor(p, 7),
        gn(p, 8) != 0,
    )));
}

fn ring_SceneCircle(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(scene.sceneCircle(@intFromFloat(gn(p, 1)), gn(p, 2), gn(p, 3), gn(p, 4), packedColor(p, 5))));
}

fn ring_SceneLine(p: *anyopaque) callconv(.c) void {
    const pts = [_]f64{ gn(p, 2), gn(p, 3), gn(p, 4), gn(p, 5) };
    rn(p, @floatFromInt(scene.sceneStroke(@intFromFloat(gn(p, 1)), &pts, gn(p, 6), packedColor(p, 7))));
}

fn ring_ScenePolyline(p: *anyopaque) callconv(.c) void {
    const pts = flatPoints(p, 2) orelse {
        rn(p, scene.BAD_ARG);
        return;
    };
    defer allocator.free(pts);
    rn(p, @floatFromInt(scene.sceneStroke(@intFromFloat(gn(p, 1)), pts, gn(p, 3), packedColor(p, 4))));
}

fn ring_ScenePolygon(p: *anyopaque) callconv(.c) void {
    const pts = flatPoints(p, 2) orelse {
        rn(p, scene.BAD_ARG);
        return;
    };
    defer allocator.free(pts);
    rn(p, @floatFromInt(scene.scenePolygon(@intFromFloat(gn(p, 1)), pts, packedColor(p, 3))));
}

fn ring_SceneText(p: *anyopaque) callconv(.c) void {
    const str = getStr(p, 3);
    rn(p, @floatFromInt(scene.sceneText(
        @intFromFloat(gn(p, 1)),
        @intFromFloat(gn(p, 2)),
        str,
        gn(p, 4),
        gn(p, 5),
        gn(p, 6),
        packedColor(p, 7),
    )));
}

fn ring_SceneCommandCount(p: *anyopaque) callconv(.c) void {
    rn(p, scene.sceneCommandCount(@intFromFloat(gn(p, 1))));
}

// SceneStats(id) -> [commands, shapeVerts, textVerts, drawSegments, builds]
fn ring_SceneStats(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    if (scene.sceneStats(@intFromFloat(gn(p, 1)))) |st| {
        for (st) |v| R.ring_list_adddouble(out, v);
    }
    R.ring_vm_api_retlist(p, out);
}

// SceneToSvg(id) -> SVG text ("" on a stale handle). NEVER needs a device.
fn ring_SceneToSvg(p: *anyopaque) callconv(.c) void {
    const svg = scene.sceneToSvg(@intFromFloat(gn(p, 1))) catch {
        R.ring_vm_api_retstring2(p, "", 0);
        return;
    };
    if (svg) |s| {
        defer allocator.free(s);
        R.ring_vm_api_retstring2(p, s.ptr, @intCast(s.len));
    } else {
        R.ring_vm_api_retstring2(p, "", 0);
    }
}

// SceneToPng(id, nLevel) -> PNG bytes ("" when there is no device -- and
// that refusal is COUNTED, so a face can fall to the SVG tier knowing why)
fn ring_SceneToPng(p: *anyopaque) callconv(.c) void {
    const png = scene.sceneToPng(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2))) catch {
        R.ring_vm_api_retstring2(p, "", 0);
        return;
    };
    if (png) |b| {
        defer allocator.free(b);
        R.ring_vm_api_retstring2(p, b.ptr, @intCast(b.len));
    } else {
        R.ring_vm_api_retstring2(p, "", 0);
    }
}

// SceneToPixels(id) -> raw RGBA8 of the GPU tier (the parity witness:
// the same bytes the PNG encodes, before compression can be blamed)
fn ring_SceneToPixels(p: *anyopaque) callconv(.c) void {
    const px = scene.sceneToPixels(@intFromFloat(gn(p, 1))) catch {
        R.ring_vm_api_retstring2(p, "", 0);
        return;
    };
    if (px) |b| {
        defer allocator.free(b);
        R.ring_vm_api_retstring2(p, b.ptr, @intCast(b.len));
    } else {
        R.ring_vm_api_retstring2(p, "", 0);
    }
}

// AtlasStats() -> [w, h, entries, uploads]
fn ring_AtlasStats(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (atlas.stats()) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

fn ring_AtlasReset(p: *anyopaque) callconv(.c) void {
    atlas.reset();
    rn(p, 1);
}

// CircleSegments(nRadius) -> the tessellation count the error bound picks
// (exposed so a guard can check the sagitta claim arithmetically)
fn ring_CircleSegments(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(scene.circleSegments(gn(p, 1))));
}

// ---------------- GR3 meshes and the 3D scene

fn ring_MeshCube(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gmesh.buildCube(@floatCast(gn(p, 1)))));
}

fn ring_MeshSphere(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gmesh.buildSphere(@floatCast(gn(p, 1)), @intFromFloat(gn(p, 2)), @intFromFloat(gn(p, 3)))));
}

fn ring_MeshPlane(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gmesh.buildPlane(@floatCast(gn(p, 1)))));
}

fn ring_MeshFromObj(p: *anyopaque) callconv(.c) void {
    const src = getStr(p, 1);
    rn(p, @floatFromInt(gmesh.loadObj(src)));
}

// MeshCustom(aComps, aVerts, aIndices) -> id. The §3b hinge from Ring:
// any attribute layout, and everything downstream adapts.
fn ring_MeshCustom(p: *anyopaque) callconv(.c) void {
    const comps_l = R.gl(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const nc: usize = @intCast(R.ringListSize(comps_l));
    if (nc == 0 or nc > gmesh.MAX_ATTRS) {
        rn(p, 0);
        return;
    }
    var comps: [gmesh.MAX_ATTRS]u8 = undefined;
    for (0..nc) |i| {
        const item = R.ring_list_getitem_gc(null, comps_l, @intCast(i + 1)) orelse {
            rn(p, 0);
            return;
        };
        comps[i] = @intFromFloat(R.ring_item_getnumber(item));
    }
    const verts = flatPoints(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(verts);
    const idxs = flatPoints(p, 3) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(idxs);
    const vf = allocator.alloc(f32, verts.len) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(vf);
    for (verts, 0..) |v, i| vf[i] = @floatCast(v);
    const iu = allocator.alloc(u32, idxs.len) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(iu);
    for (idxs, 0..) |v, i| iu[i] = @intFromFloat(v);
    rn(p, @floatFromInt(gmesh.buildCustom(comps[0..nc], vf, iu)));
}

fn ring_MeshFree(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gmesh.meshFree(@intFromFloat(gn(p, 1)))));
}

// MeshStats(id) -> [vertices, indices, attributes, strideFloats, cFormat]
fn ring_MeshStats(p: *anyopaque) callconv(.c) void {
    const id: i64 = @intFromFloat(gn(p, 1));
    const out = R.ring_vm_api_newlist(p) orelse return;
    const nv = gmesh.vertexCount(id);
    if (nv < 0) {
        R.ring_vm_api_retlist(p, out);
        return;
    }
    R.ring_list_adddouble(out, nv);
    R.ring_list_adddouble(out, gmesh.indexCount(id));
    R.ring_list_adddouble(out, gmesh.attrCount(id));
    R.ring_list_adddouble(out, gmesh.strideFloats(id));
    var fbuf: [32]u8 = undefined;
    if (gmesh.formatString(id, &fbuf)) |f| {
        R.ring_list_addstring2(out, f.ptr, @intCast(f.len));
    }
    R.ring_vm_api_retlist(p, out);
}

fn vec3At(p: *anyopaque, n: c_int) gm.Vec3 {
    return .{ .x = @floatCast(gn(p, n)), .y = @floatCast(gn(p, n + 1)), .z = @floatCast(gn(p, n + 2)) };
}

fn ring_Scene3dNew(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(s3d.sceneNew(gn(p, 1), gn(p, 2))));
}

fn ring_Scene3dFree(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(s3d.sceneFree(@intFromFloat(gn(p, 1)))));
}

fn ring_Scene3dClear(p: *anyopaque) callconv(.c) void {
    const col = packedColor(p, 2);
    rn(p, @floatFromInt(s3d.setClear(
        @intFromFloat(gn(p, 1)),
        @as(f32, @floatFromInt((col >> 24) & 0xff)) / 255.0,
        @as(f32, @floatFromInt((col >> 16) & 0xff)) / 255.0,
        @as(f32, @floatFromInt((col >> 8) & 0xff)) / 255.0,
        @as(f32, @floatFromInt(col & 0xff)) / 255.0,
    )));
}

// Scene3dCamera(id, ex,ey,ez, tx,ty,tz, fovDeg, near, far)
fn ring_Scene3dCamera(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(s3d.setCamera(
        @intFromFloat(gn(p, 1)),
        vec3At(p, 2),
        vec3At(p, 5),
        @floatCast(gn(p, 8)),
        @floatCast(gn(p, 9)),
        @floatCast(gn(p, 10)),
    )));
}

// Scene3dLight(id, dx,dy,dz, nRGB, nAmbientRGB)
fn ring_Scene3dLight(p: *anyopaque) callconv(.c) void {
    const lc = packedColor(p, 5);
    const am = packedColor(p, 6);
    rn(p, @floatFromInt(s3d.setLight(
        @intFromFloat(gn(p, 1)),
        vec3At(p, 2),
        @as(f32, @floatFromInt((lc >> 24) & 0xff)) / 255.0,
        @as(f32, @floatFromInt((lc >> 16) & 0xff)) / 255.0,
        @as(f32, @floatFromInt((lc >> 8) & 0xff)) / 255.0,
        @as(f32, @floatFromInt((am >> 24) & 0xff)) / 255.0,
        @as(f32, @floatFromInt((am >> 16) & 0xff)) / 255.0,
        @as(f32, @floatFromInt((am >> 8) & 0xff)) / 255.0,
    )));
}

fn transformFrom(p: *anyopaque, base: c_int) gm.Transform {
    var tr = gm.Transform{};
    tr.position = vec3At(p, base);
    const axis = vec3At(p, base + 3);
    const angle: f32 = @floatCast(gn(p, base + 6));
    if (axis.length() > 0 and angle != 0) {
        tr.rotation = gm.Quat.fromAxisAngle(axis, angle * std.math.pi / 180.0);
    }
    const sx: f32 = @floatCast(gn(p, base + 7));
    const sy: f32 = @floatCast(gn(p, base + 8));
    const sz: f32 = @floatCast(gn(p, base + 9));
    tr.scale = .{ .x = if (sx == 0) 1 else sx, .y = if (sy == 0) 1 else sy, .z = if (sz == 0) 1 else sz };
    return tr;
}

// Scene3dAdd(id, hMesh, px,py,pz, ax,ay,az, angleDeg, sx,sy,sz, nRGBA) -> index
fn ring_Scene3dAdd(p: *anyopaque) callconv(.c) void {
    const col = packedColor(p, 13);
    rn(p, s3d.addInstance(
        @intFromFloat(gn(p, 1)),
        @intFromFloat(gn(p, 2)),
        transformFrom(p, 3),
        .{
            @as(f32, @floatFromInt((col >> 24) & 0xff)) / 255.0,
            @as(f32, @floatFromInt((col >> 16) & 0xff)) / 255.0,
            @as(f32, @floatFromInt((col >> 8) & 0xff)) / 255.0,
            @as(f32, @floatFromInt(col & 0xff)) / 255.0,
        },
    ));
}

// Scene3dSetTransform(id, nIndex, px,py,pz, ax,ay,az, angleDeg, sx,sy,sz)
// The §3b door from Ring: writes transform state, nothing else.
fn ring_Scene3dSetTransform(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(s3d.setTransform(
        @intFromFloat(gn(p, 1)),
        @intFromFloat(gn(p, 2)),
        transformFrom(p, 3),
    )));
}

fn ring_Scene3dSetColor(p: *anyopaque) callconv(.c) void {
    const col = packedColor(p, 3);
    rn(p, @floatFromInt(s3d.setInstanceColor(
        @intFromFloat(gn(p, 1)),
        @intFromFloat(gn(p, 2)),
        .{
            @as(f32, @floatFromInt((col >> 24) & 0xff)) / 255.0,
            @as(f32, @floatFromInt((col >> 16) & 0xff)) / 255.0,
            @as(f32, @floatFromInt((col >> 8) & 0xff)) / 255.0,
            @as(f32, @floatFromInt(col & 0xff)) / 255.0,
        },
    )));
}

// Scene3dStats(id) -> [instances, meshesResident, drawCalls, geometryUploads,
//                      transformUploads]
fn ring_Scene3dStats(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    if (s3d.stats(@intFromFloat(gn(p, 1)))) |st| {
        for (st) |v| R.ring_list_adddouble(out, v);
    }
    R.ring_vm_api_retlist(p, out);
}

// ---------------- GR4: the f32 math, reachable from Ring
// (the challenge pass's gap 4 -- a caller wanting its own camera had to
// re-derive lookAt/perspective by hand). Matrices cross as flat lists of
// 16 numbers in COLUMN-MAJOR order, the same layout the shaders read.

fn matFrom(p: *anyopaque, n: c_int) ?gm.Mat4 {
    const lst = R.gl(p, n) orelse return null;
    if (R.ringListSize(lst) != 16) return null;
    var m = gm.Mat4{ .m = @splat(0) };
    for (0..16) |i| {
        const item = R.ring_list_getitem_gc(null, lst, @intCast(i + 1)) orelse return null;
        m.m[i] = @floatCast(R.ring_item_getnumber(item));
    }
    return m;
}

fn retMat(p: *anyopaque, m: gm.Mat4) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (m.m) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

fn ring_Mat4LookAt(p: *anyopaque) callconv(.c) void {
    retMat(p, gm.Mat4.lookAt(vec3At(p, 1), vec3At(p, 4), vec3At(p, 7)));
}

fn ring_Mat4Perspective(p: *anyopaque) callconv(.c) void {
    const fov: f32 = @floatCast(gn(p, 1) * std.math.pi / 180.0);
    retMat(p, gm.Mat4.perspective(fov, @floatCast(gn(p, 2)), @floatCast(gn(p, 3)), @floatCast(gn(p, 4))));
}

fn ring_Mat4Mul(p: *anyopaque) callconv(.c) void {
    const a = matFrom(p, 1) orelse return;
    const b = matFrom(p, 2) orelse return;
    retMat(p, a.mul(b));
}

// Mat4Project(aM, x, y, z, nW, nH) -> [screenX, screenY, depth, bVisible]
// The perspective divide made explicit -- w <= 0 means behind the camera,
// which is a real answer, not a NaN.
fn ring_Mat4Project(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const m = matFrom(p, 1) orelse {
        R.ring_vm_api_retlist(p, out);
        return;
    };
    const v = gm.Vec3{ .x = @floatCast(gn(p, 2)), .y = @floatCast(gn(p, 3)), .z = @floatCast(gn(p, 4)) };
    const w: f64 = gn(p, 5);
    const h: f64 = gn(p, 6);
    const c4 = m.mulPoint4(v);
    if (c4[3] <= 0) {
        R.ring_list_adddouble(out, 0);
        R.ring_list_adddouble(out, 0);
        R.ring_list_adddouble(out, 0);
        R.ring_list_adddouble(out, 0); // not visible
        R.ring_vm_api_retlist(p, out);
        return;
    }
    const nx = c4[0] / c4[3];
    const ny = c4[1] / c4[3];
    const nz = c4[2] / c4[3];
    R.ring_list_adddouble(out, (nx * 0.5 + 0.5) * w);
    R.ring_list_adddouble(out, (1.0 - (ny * 0.5 + 0.5)) * h);
    R.ring_list_adddouble(out, nz);
    R.ring_list_adddouble(out, 1);
    R.ring_vm_api_retlist(p, out);
}

fn ring_Scene3dInstanceBuffer(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(s3d.instanceBuffer(@intFromFloat(gn(p, 1)))));
}

fn ring_Scene3dInstanceStride(p: *anyopaque) callconv(.c) void {
    rn(p, s3d.instanceStrideFloats());
}

fn ring_Scene3dSetGpuDriven(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(s3d.setGpuDriven(@intFromFloat(gn(p, 1)), gn(p, 2) != 0)));
}

fn ring_Scene3dIsGpuDriven(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(s3d.isGpuDriven(@intFromFloat(gn(p, 1)))));
}

fn ring_Scene3dToPixels(p: *anyopaque) callconv(.c) void {
    const px = s3d.sceneToPixels(@intFromFloat(gn(p, 1))) catch {
        R.ring_vm_api_retstring2(p, "", 0);
        return;
    };
    if (px) |b| {
        defer allocator.free(b);
        R.ring_vm_api_retstring2(p, b.ptr, @intCast(b.len));
    } else {
        R.ring_vm_api_retstring2(p, "", 0);
    }
}

fn ring_Scene3dToPng(p: *anyopaque) callconv(.c) void {
    const png = s3d.sceneToPng(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2))) catch {
        R.ring_vm_api_retstring2(p, "", 0);
        return;
    };
    if (png) |b| {
        defer allocator.free(b);
        R.ring_vm_api_retstring2(p, b.ptr, @intCast(b.len));
    } else {
        R.ring_vm_api_retstring2(p, "", 0);
    }
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
    .{ .name = "stzenginegpubufferuploadlistu32", .func = &ring_BufferUploadListU32 },
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
    // GR1 render lifecycle
    .{ .name = "stzenginegputexturenew", .func = &ring_TextureNew },
    .{ .name = "stzenginegputexturefree", .func = &ring_TextureFree },
    .{ .name = "stzenginegputexturewidth", .func = &ring_TextureWidth },
    .{ .name = "stzenginegputextureheight", .func = &ring_TextureHeight },
    .{ .name = "stzenginegputexturewrite", .func = &ring_TextureWrite },
    .{ .name = "stzenginegpurenderpipeline", .func = &ring_RenderPipeline },
    .{ .name = "stzenginegpurenderbegin", .func = &ring_RenderBegin },
    .{ .name = "stzenginegpurenderdraw", .func = &ring_RenderDraw },
    .{ .name = "stzenginegpurenderdrawindexed", .func = &ring_RenderDrawIndexed },
    .{ .name = "stzenginegpurenderend", .func = &ring_RenderEnd },
    .{ .name = "stzenginegpurenderactive", .func = &ring_RenderActive },
    .{ .name = "stzenginegputargetread", .func = &ring_TargetRead },
    .{ .name = "stzenginegpupngencode", .func = &ring_PngEncode },
    .{ .name = "stzenginegpuimagedecode", .func = &ring_ImageDecode },
    // GR2 text pipeline
    .{ .name = "stzenginegpufontload", .func = &ring_FontLoad },
    .{ .name = "stzenginegpufontfree", .func = &ring_FontFree },
    .{ .name = "stzenginegpufontglyphcount", .func = &ring_FontGlyphCount },
    .{ .name = "stzenginegputextlayout", .func = &ring_TextLayout },
    .{ .name = "stzenginegpuglyphbitmap", .func = &ring_GlyphBitmap },
    // GR2b display list
    .{ .name = "stzenginegpuscenenew", .func = &ring_SceneNew },
    .{ .name = "stzenginegpuscenefree", .func = &ring_SceneFree },
    .{ .name = "stzenginegpusceneclear", .func = &ring_SceneClear },
    .{ .name = "stzenginegpuscenerect", .func = &ring_SceneRect },
    .{ .name = "stzenginegpuscenerectgradient", .func = &ring_SceneRectGradient },
    .{ .name = "stzenginegpuscenecircle", .func = &ring_SceneCircle },
    .{ .name = "stzenginegpusceneline", .func = &ring_SceneLine },
    .{ .name = "stzenginegpuscenepolyline", .func = &ring_ScenePolyline },
    .{ .name = "stzenginegpuscenepolygon", .func = &ring_ScenePolygon },
    .{ .name = "stzenginegpuscenetext", .func = &ring_SceneText },
    .{ .name = "stzenginegpuscenecommandcount", .func = &ring_SceneCommandCount },
    .{ .name = "stzenginegpuscenestats", .func = &ring_SceneStats },
    .{ .name = "stzenginegpuscenetosvg", .func = &ring_SceneToSvg },
    .{ .name = "stzenginegpuscenetopng", .func = &ring_SceneToPng },
    .{ .name = "stzenginegpuscenetopixels", .func = &ring_SceneToPixels },
    .{ .name = "stzenginegpuatlasstats", .func = &ring_AtlasStats },
    .{ .name = "stzenginegpuatlasreset", .func = &ring_AtlasReset },
    .{ .name = "stzenginegpucirclesegments", .func = &ring_CircleSegments },
    // GR3 meshes + 3D scene
    .{ .name = "stzenginegpumeshcube", .func = &ring_MeshCube },
    .{ .name = "stzenginegpumeshsphere", .func = &ring_MeshSphere },
    .{ .name = "stzenginegpumeshplane", .func = &ring_MeshPlane },
    .{ .name = "stzenginegpumeshfromobj", .func = &ring_MeshFromObj },
    .{ .name = "stzenginegpumeshcustom", .func = &ring_MeshCustom },
    .{ .name = "stzenginegpumeshfree", .func = &ring_MeshFree },
    .{ .name = "stzenginegpumeshstats", .func = &ring_MeshStats },
    .{ .name = "stzenginegpuscene3dnew", .func = &ring_Scene3dNew },
    .{ .name = "stzenginegpuscene3dfree", .func = &ring_Scene3dFree },
    .{ .name = "stzenginegpuscene3dclear", .func = &ring_Scene3dClear },
    .{ .name = "stzenginegpuscene3dcamera", .func = &ring_Scene3dCamera },
    .{ .name = "stzenginegpuscene3dlight", .func = &ring_Scene3dLight },
    .{ .name = "stzenginegpuscene3dadd", .func = &ring_Scene3dAdd },
    .{ .name = "stzenginegpuscene3dsettransform", .func = &ring_Scene3dSetTransform },
    .{ .name = "stzenginegpuscene3dsetcolor", .func = &ring_Scene3dSetColor },
    .{ .name = "stzenginegpuscene3dstats", .func = &ring_Scene3dStats },
    .{ .name = "stzenginegpuscene3dtopixels", .func = &ring_Scene3dToPixels },
    .{ .name = "stzenginegpuscene3dtopng", .func = &ring_Scene3dToPng },
    // GR4: math reachable from Ring + the GPU-driven instance door
    .{ .name = "stzenginegpumat4lookat", .func = &ring_Mat4LookAt },
    .{ .name = "stzenginegpumat4perspective", .func = &ring_Mat4Perspective },
    .{ .name = "stzenginegpumat4mul", .func = &ring_Mat4Mul },
    .{ .name = "stzenginegpumat4project", .func = &ring_Mat4Project },
    .{ .name = "stzenginegpuscene3dinstancebuffer", .func = &ring_Scene3dInstanceBuffer },
    .{ .name = "stzenginegpuscene3dinstancestride", .func = &ring_Scene3dInstanceStride },
    .{ .name = "stzenginegpuscene3dsetgpudriven", .func = &ring_Scene3dSetGpuDriven },
    .{ .name = "stzenginegpuscene3disgpudriven", .func = &ring_Scene3dIsGpuDriven },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
