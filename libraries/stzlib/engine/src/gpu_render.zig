//! stz_gpu render lifecycle -- GR1 of SOFTANZA_GRAPHICS_PLAN.md.
//!
//! The GR0 spike proved the vendored render surface composes with the G1
//! lifecycle (new slot kinds, no new binding model, compute->render in one
//! submit). This module is that proof made product:
//!
//!   - RENDER PIPELINE CACHE keyed by (WGSL text, vertex format, blend) --
//!     the same 1-compile-N-hits mechanism as compute kernels; GR0 measured
//!     7-13 ms cold per render pipeline, so the cache is measurement-backed.
//!   - A RENDER PASS MACHINE mirroring the batched-pass shape: Begin(target,
//!     clear) opens ONE encoder+pass, draws encode into it, End() submits
//!     ONCE. Submission is asynchronous like dispatch; a readback (or Sync)
//!     establishes completion -- queue ordering carries the rest.
//!   - TARGET READBACK handling WebGPU's 256-byte row alignment (padded
//!     staging engine-side, de-padded before anyone sees the bytes).
//!   - The PNG ENCODER over the vendored zlib (chunks + CRC, born in the GR0
//!     spike). Level 1 is the measured default -- GR0: z1 = 27.5 ms vs z6 =
//!     55 ms at 1080p with identical pixels; z6 stays an opt-in knob.
//!   - IMAGE DECODE via vendored stb_image (memory-only): PNG/JPG/BMP/... ->
//!     RGBA8 for textures, and the encoder's round-trip witness in the guard.
//!
//! Resources (textures, targets) live in gpu.zig's tables -- same gen-keyed
//! ids, same VRAM budget, same FIFO eviction, same counted fallback. This
//! file holds only the pass machinery and the codecs.
//!
//! WGSL contract for render pipelines (documented in engine/stz_gpu.ring):
//!   entry points `vmain` (vertex) and `fmain` (fragment); vertex buffer 0
//!   carries float32 attributes per the declared format (e.g. "2,4" = vec2
//!   position + vec4 color at locations 0,1). A TEXTURED pipeline binds
//!   @group(0) @binding(0) texture_2d<f32> + @binding(1) sampler, and its
//!   draws must pass a sampled-texture id; an untextured pipeline must not.

const std = @import("std");
const gpu = @import("gpu.zig");
const c = gpu.c;

const z = @cImport({
    @cInclude("zlib.h");
});
const stbi = @cImport({
    @cDefine("STBI_NO_STDIO", "1");
    @cInclude("stb_image.h");
});

const alloc = std.heap.c_allocator;

fn sv(s: []const u8) c.WGPUStringView {
    return .{ .data = s.ptr, .length = s.len };
}

// ---------------------------------------------------------------- registration

var registered = false;
var frame_hooked = false;

fn ensureFrameHook() void {
    if (!frame_hooked) {
        gpu.registerFrameEndHook(&releasePassBindGroups);
        frame_hooked = true;
    }
}

fn ensureRegistered() void {
    if (!registered) {
        gpu.registerDeviceCloseHook(&onDeviceClose);
        registered = true;
    }
}

/// Device is going away (shutdown, adapter switch, loss): abort any open
/// pass, drop every device-scoped object this module holds.
fn onDeviceClose() void {
    if (g_pass_open) {
        // nothing was submitted; release the encoding and owe nothing
        g_pass_open = false;
        g_pass_target = 0;
        if (g_pass) |p| gpu.wfns().wgpuRenderPassEncoderRelease(p);
        if (g_pass_enc) |e| gpu.wfns().wgpuCommandEncoderRelease(e);
        g_pass = null;
        g_pass_enc = null;
        releasePassBindGroups();
    }
    for (rpipes.items) |*rp| {
        if (rp.layout) |l| gpu.wfns().wgpuBindGroupLayoutRelease(l);
        if (rp.pipeline) |p| gpu.wfns().wgpuRenderPipelineRelease(p);
        rp.pipeline = null;
        rp.layout = null;
    }
    rpipes.clearRetainingCapacity();
    if (g_sampler_nearest) |s| gpu.wfns().wgpuSamplerRelease(s);
    if (g_sampler_linear) |s| gpu.wfns().wgpuSamplerRelease(s);
    g_sampler_nearest = null;
    g_sampler_linear = null;
}

// ---------------------------------------------------------------- samplers

var g_sampler_nearest: c.WGPUSampler = null;
var g_sampler_linear: c.WGPUSampler = null;

fn samplerFor(kind: i32) c.WGPUSampler {
    // a TARGET read by a later pass is being resampled, so linear
    if (kind == gpu.TEX_LINEAR or kind == gpu.TEX_TARGET or kind == gpu.TEX_SRGB) {
        if (g_sampler_linear == null) {
            var d = std.mem.zeroes(c.WGPUSamplerDescriptor);
            d.label = sv("stz_linear");
            d.magFilter = c.WGPUFilterMode_Linear;
            d.minFilter = c.WGPUFilterMode_Linear;
            d.lodMaxClamp = 32.0;
            d.maxAnisotropy = 1;
            g_sampler_linear = gpu.wfns().wgpuDeviceCreateSampler(gpu.deviceHandle(), &d);
        }
        return g_sampler_linear;
    }
    if (g_sampler_nearest == null) {
        var d = std.mem.zeroes(c.WGPUSamplerDescriptor);
        d.label = sv("stz_nearest");
        d.lodMaxClamp = 32.0;
        d.maxAnisotropy = 1;
        g_sampler_nearest = gpu.wfns().wgpuDeviceCreateSampler(gpu.deviceHandle(), &d);
    }
    return g_sampler_nearest;
}

// ---------------------------------------------------------------- pipeline cache

const RenderPipeSlot = struct {
    pipeline: c.WGPURenderPipeline = null,
    layout: c.WGPUBindGroupLayout = null, // group(0), for textured pipelines
    hash: u64 = 0,
};

var rpipes: std.ArrayList(RenderPipeSlot) = .{};

const MAX_ATTRS = 8;

/// fmt: comma-separated float32 component counts per attribute, in location
/// order -- "2,4" = vec2 @location(0) + vec4 @location(1). Returns attribute
/// count, fills attrs/stride. 0 = malformed.
fn parseVertexFormat(fmt: []const u8, attrs: *[MAX_ATTRS]c.WGPUVertexAttribute, stride: *u64) usize {
    var n: usize = 0;
    var offset: u64 = 0;
    var it = std.mem.tokenizeScalar(u8, fmt, ',');
    while (it.next()) |tok| {
        if (n == MAX_ATTRS) return 0;
        if (tok.len != 1 or tok[0] < '1' or tok[0] > '4') return 0;
        const comps: u32 = tok[0] - '0';
        var a = std.mem.zeroes(c.WGPUVertexAttribute);
        a.format = switch (comps) {
            1 => c.WGPUVertexFormat_Float32,
            2 => c.WGPUVertexFormat_Float32x2,
            3 => c.WGPUVertexFormat_Float32x3,
            else => c.WGPUVertexFormat_Float32x4,
        };
        a.offset = offset;
        a.shaderLocation = @intCast(n);
        attrs[n] = a;
        offset += comps * 4;
        n += 1;
    }
    if (n == 0) return 0;
    stride.* = offset;
    return n;
}

/// Compile (or fetch from cache) a 2D render pipeline. blend: 0 = opaque,
/// 1 = standard alpha (src-alpha over). Returns a 1-based cache id, 0 on
/// refusal (unavailable device, malformed format, WGSL that fails
/// validation -- the error is counted and readable via LastError).
pub fn stz_gpu_render_pipeline(text: [*]const u8, len: f64, fmt: [*]const u8, fmt_len: f64, blend: f64) callconv(.c) i64 {
    return pipelineInternal(text, len, fmt, fmt_len, blend, false, false, TFMT_RGBA8);
}

/// GR5: the TARGET's pixel format. Every offscreen target this engine makes
/// is RGBA8, but a swapchain names its own format and BGRA8 is what most
/// Windows surfaces answer -- a pipeline compiled for the wrong one is a
/// validation error, not a wrong color. So the format joins the cache key,
/// and a scene drawn to a window and to a file uses two pipelines from one
/// shader rather than one pipeline that is wrong somewhere.
pub const TFMT_RGBA8: i32 = 0;
pub const TFMT_BGRA8: i32 = 1;

fn targetFormatOf(t: i32) c.WGPUTextureFormat {
    return if (t == TFMT_BGRA8) c.WGPUTextureFormat_BGRA8Unorm else c.WGPUTextureFormat_RGBA8Unorm;
}

pub fn stz_gpu_render_pipeline_fmt(text: [*]const u8, len: f64, fmt: [*]const u8, fmt_len: f64, blend: f64, depth: f64, cull: f64, tfmt: f64) callconv(.c) i64 {
    return pipelineInternal(text, len, fmt, fmt_len, blend, depth != 0, cull != 0, @intFromFloat(tfmt));
}

/// GR3: the same cache, with DEPTH TESTING and optional back-face culling.
/// A separate entry point rather than a widened one -- the 2D surface that
/// shipped keeps its exact signature and its guards keep passing.
pub fn stz_gpu_render_pipeline3d(text: [*]const u8, len: f64, fmt: [*]const u8, fmt_len: f64, blend: f64, cull: f64) callconv(.c) i64 {
    return pipelineInternal(text, len, fmt, fmt_len, blend, true, cull != 0, TFMT_RGBA8);
}

fn pipelineInternal(text: [*]const u8, len: f64, fmt: [*]const u8, fmt_len: f64, blend: f64, depth: bool, cull: bool, tfmt: i32) i64 {
    ensureRegistered();
    if (!gpu.isAvail()) {
        gpu.countFallback();
        return 0;
    }
    const n: usize = @intFromFloat(len);
    const fl: usize = @intFromFloat(fmt_len);
    const wgsl = text[0..n];
    const fmt_s = fmt[0..fl];
    const bl: i32 = @intFromFloat(blend);
    if (bl < 0 or bl > 1) return 0;

    var hasher = std.hash.Wyhash.init(0);
    hasher.update(wgsl);
    hasher.update("|");
    hasher.update(fmt_s);
    hasher.update(if (bl == 1) "|b1" else "|b0");
    hasher.update(if (depth) "|d1" else "|d0");
    hasher.update(if (cull) "|c1" else "|c0");
    hasher.update(if (tfmt == TFMT_BGRA8) "|t1" else "|t0");
    const h = hasher.final();
    for (rpipes.items, 0..) |rp, i| {
        if (rp.hash == h and rp.pipeline != null) {
            gpu.bumpCounter(gpu.CTR_RPIPE_HITS, 1);
            return @intCast(i + 1);
        }
    }

    var attrs: [MAX_ATTRS]c.WGPUVertexAttribute = undefined;
    var stride: u64 = 0;
    const nattrs = parseVertexFormat(fmt_s, &attrs, &stride);
    if (nattrs == 0) return 0;

    const errs_before = gpu.stz_gpu_counter(gpu.CTR_GPU_ERRORS);
    const f = gpu.wfns();

    var src = std.mem.zeroes(c.WGPUShaderSourceWGSL);
    src.chain.sType = c.WGPUSType_ShaderSourceWGSL;
    src.code = sv(wgsl);
    var mdesc = std.mem.zeroes(c.WGPUShaderModuleDescriptor);
    mdesc.nextInChain = @ptrCast(&src.chain);
    mdesc.label = sv("stz_rpipe");
    const module = f.wgpuDeviceCreateShaderModule(gpu.deviceHandle(), &mdesc);
    if (module == null) return 0;
    defer f.wgpuShaderModuleRelease(module);

    var vbl = std.mem.zeroes(c.WGPUVertexBufferLayout);
    vbl.stepMode = c.WGPUVertexStepMode_Vertex;
    vbl.arrayStride = stride;
    vbl.attributeCount = nattrs;
    vbl.attributes = &attrs;

    // GR0's zeroed-struct sentinels, set explicitly: writeMask, multisample
    var blend_state = std.mem.zeroes(c.WGPUBlendState);
    blend_state.color = .{ .operation = c.WGPUBlendOperation_Add, .srcFactor = c.WGPUBlendFactor_SrcAlpha, .dstFactor = c.WGPUBlendFactor_OneMinusSrcAlpha };
    blend_state.alpha = .{ .operation = c.WGPUBlendOperation_Add, .srcFactor = c.WGPUBlendFactor_One, .dstFactor = c.WGPUBlendFactor_OneMinusSrcAlpha };
    var target = std.mem.zeroes(c.WGPUColorTargetState);
    target.format = targetFormatOf(tfmt);
    target.blend = if (bl == 1) &blend_state else null;
    target.writeMask = c.WGPUColorWriteMask_All;

    var frag = std.mem.zeroes(c.WGPUFragmentState);
    frag.module = module;
    frag.entryPoint = sv("fmain");
    frag.targetCount = 1;
    frag.targets = &target;

    // GR3 depth state. The sentinel trap here is real and silent:
    // WGPUOptionalBool_False == 0, so a ZEROED struct disables depth
    // writes -- the depth buffer would exist, be cleared, and never be
    // written. depthWriteEnabled is set explicitly for that reason.
    var ds = std.mem.zeroes(c.WGPUDepthStencilState);
    ds.format = c.WGPUTextureFormat_Depth32Float;
    ds.depthWriteEnabled = c.WGPUOptionalBool_True;
    ds.depthCompare = c.WGPUCompareFunction_Less;
    ds.stencilFront.compare = c.WGPUCompareFunction_Always;
    ds.stencilBack.compare = c.WGPUCompareFunction_Always;
    ds.stencilReadMask = 0xFFFFFFFF;
    ds.stencilWriteMask = 0xFFFFFFFF;

    var desc = std.mem.zeroes(c.WGPURenderPipelineDescriptor);
    desc.label = sv("stz_rpipe");
    desc.vertex.module = module;
    desc.vertex.entryPoint = sv("vmain");
    desc.vertex.bufferCount = 1;
    desc.vertex.buffers = &vbl;
    desc.primitive.topology = c.WGPUPrimitiveTopology_TriangleList;
    desc.primitive.cullMode = if (cull) c.WGPUCullMode_Back else c.WGPUCullMode_None;
    desc.primitive.frontFace = c.WGPUFrontFace_CCW;
    // ONE COUNT, EVERYWHERE. A pipeline must agree with the pass it is
    // drawn in, and every pass is multisampled now, so this is not a knob
    // -- it is the same constant the attachments use.
    desc.multisample.count = gpu.MSAA_SAMPLES;
    desc.multisample.mask = 0xFFFFFFFF;
    desc.fragment = &frag;
    if (depth) desc.depthStencil = &ds;
    const pipeline = f.wgpuDeviceCreateRenderPipeline(gpu.deviceHandle(), &desc);
    if (pipeline == null) return 0;
    // Malformed WGSL surfaces as an uncaptured validation error on a non-null
    // object (the kernel-compile lesson). Flush and refuse to cache it.
    f.wgpuInstanceProcessEvents(gpu.instanceHandle());
    _ = f.wgpuDevicePoll(gpu.deviceHandle(), 0, null);
    if (gpu.stz_gpu_counter(gpu.CTR_GPU_ERRORS) > errs_before) {
        f.wgpuRenderPipelineRelease(pipeline);
        return 0;
    }
    const layout = f.wgpuRenderPipelineGetBindGroupLayout(pipeline, 0);

    rpipes.append(alloc, .{ .pipeline = pipeline, .layout = layout, .hash = h }) catch {
        if (layout) |l| f.wgpuBindGroupLayoutRelease(l);
        f.wgpuRenderPipelineRelease(pipeline);
        return 0;
    };
    gpu.bumpCounter(gpu.CTR_RPIPE_COMPILE, 1);
    return @intCast(rpipes.items.len);
}

// ---------------------------------------------------------------- pass machine

// THE BIND-GROUP POOL GROWS. It was a fixed [256] array, and a pass that
// wanted a 257th bind group had its draw REFUSED -- returning BAD_ARG
// before the vertex buffer was even set, so the geometry was tessellated,
// uploaded, and never drawn. Nothing counted it.
//
// Only a TEXTURED draw takes a slot, so in practice the ceiling was "256
// text or image segments in one pass". A panel drawn repeatedly into one
// canvas crosses that in a few seconds of a frame loop, and what the
// viewer sees is the boxes rendering perfectly while every label
// disappears -- which is exactly how it was found: by a person looking at
// a window and asking why the labels had gone.
//
// The house has been here before (the handle-table cliff): the answer is
// that the table GROWS. `g_pass_bg_refused` stays, because a growth that
// FAILS must still be a number rather than a silence.
var g_pass_open = false;
var g_pass_enc: c.WGPUCommandEncoder = null;
var g_pass: c.WGPURenderPassEncoder = null;
var g_pass_bgs: std.ArrayListUnmanaged(c.WGPUBindGroup) = .{};
var g_pass_nbg: usize = 0;
var g_pass_bg_refused: u64 = 0;
var g_pass_bg_peak: usize = 0;

/// [ bind groups in flight, peak ever, refusals ] -- so a caller can see a
/// pass approaching pathology instead of discovering it in a screenshot.
pub fn passBindGroupStats() [3]f64 {
    return .{
        @floatFromInt(g_pass_nbg),
        @floatFromInt(g_pass_bg_peak),
        @floatFromInt(g_pass_bg_refused),
    };
}

/// Take the next slot, growing the pool. Answers false only when the
/// allocator itself refuses, and counts that.
fn pushPassBindGroup(bg: c.WGPUBindGroup) bool {
    g_pass_bgs.append(alloc, bg) catch {
        g_pass_bg_refused += 1;
        return false;
    };
    g_pass_nbg = g_pass_bgs.items.len;
    if (g_pass_nbg > g_pass_bg_peak) g_pass_bg_peak = g_pass_nbg;
    return true;
}
// The target this pass is drawing INTO. Sampling it while writing it is a
// genuine read-write hazard; sampling a DIFFERENT target is exactly what a
// multi-pass effect does, and refusing both was over-broad.
var g_pass_target: i64 = 0;

fn releasePassBindGroups() void {
    for (g_pass_bgs.items) |bg| {
        if (bg) |b| gpu.wfns().wgpuBindGroupRelease(b);
    }
    g_pass_bgs.clearRetainingCapacity();
    g_pass_nbg = 0;
}

/// Open a render pass on `target` (a TEX_TARGET texture), cleared to the
/// given color (0..1 components). One pass at a time; draws follow; End()
/// submits once.
pub fn stz_gpu_render_begin(target_id: i64, r: f64, g: f64, b: f64, a: f64) callconv(.c) i32 {
    return beginInternal(target_id, 0, r, g, b, a, true);
}

/// A pass that PRESERVES what the target already holds (LoadOp.Load rather
/// than Clear). This is what an OVERLAY needs: a HUD drawn after a 3D scene
/// must sit on top of it, and a clearing pass would wipe the frame it is
/// meant to annotate.
///
/// It is the frame-graph idea at the window's own scale -- one acquired
/// frame carrying more than one pass.
pub fn stz_gpu_render_begin_over(target_id: i64) callconv(.c) i32 {
    return beginInternal(target_id, 0, 0, 0, 0, 0, false);
}

/// GR3: the same pass with a DEPTH buffer attached (cleared to 1.0 = far).
/// depth_id must be a TEX_DEPTH texture of the target's size.
pub fn stz_gpu_render_begin3d(target_id: i64, depth_id: i64, r: f64, g: f64, b: f64, a: f64) callconv(.c) i32 {
    return beginInternal(target_id, depth_id, r, g, b, a, true);
}

fn beginInternal(target_id: i64, depth_id: i64, r: f64, g: f64, b: f64, a: f64, clear: bool) i32 {
    ensureRegistered();
    ensureFrameHook();
    if (!gpu.isAvail()) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    if (g_pass_open) return gpu.BAD_ARG;
    const t = gpu.rawTexture(target_id) orelse return gpu.STALE;
    if (t.kind != gpu.TEX_TARGET) return gpu.BAD_ARG;
    g_pass_target = target_id;
    var depth_view: c.WGPUTextureView = null;
    if (depth_id != 0) {
        const d = gpu.rawTexture(depth_id) orelse return gpu.STALE;
        if (d.kind != gpu.TEX_DEPTH) return gpu.BAD_ARG;
        if (d.w != t.w or d.h != t.h) return gpu.BAD_ARG; // must match the target
        depth_view = d.view;
    }
    const f = gpu.wfns();

    // Borrow the frame's encoder when a frame is open; otherwise own one.
    g_pass_enc = if (gpu.frameOpen())
        gpu.frameEncoder()
    else
        f.wgpuDeviceCreateCommandEncoder(gpu.deviceHandle(), null);
    if (g_pass_enc == null) return gpu.GPU_ERROR;
    var att = std.mem.zeroes(c.WGPURenderPassColorAttachment);
    // DRAW INTO THE MULTISAMPLE BUFFER, RESOLVE INTO THE REAL ONE. The
    // target keeps its identity -- callers read back, sample and save
    // `t.view` exactly as before and never learn that a second texture
    // exists. If the companion cannot be made, the pass falls back to
    // drawing directly: a jagged picture beats no picture.
    if (gpu.msaaViewFor(target_id)) |msv| {
        att.view = msv;
        att.resolveTarget = t.view;
    } else {
        att.view = t.view;
    }
    att.depthSlice = std.math.maxInt(u32); // WGPU_DEPTH_SLICE_UNDEFINED
    att.loadOp = if (clear) c.WGPULoadOp_Clear else c.WGPULoadOp_Load;
    att.storeOp = c.WGPUStoreOp_Store;
    att.clearValue = .{ .r = r, .g = g, .b = b, .a = a };
    var rp = std.mem.zeroes(c.WGPURenderPassDescriptor);
    rp.colorAttachmentCount = 1;
    rp.colorAttachments = &att;
    var dsa = std.mem.zeroes(c.WGPURenderPassDepthStencilAttachment);
    if (depth_view != null) {
        dsa.view = depth_view;
        dsa.depthLoadOp = c.WGPULoadOp_Clear;
        dsa.depthStoreOp = c.WGPUStoreOp_Store;
        dsa.depthClearValue = 1.0; // the far plane: everything is nearer
        // Depth32Float carries no stencil aspect; leaving stencil ops
        // Undefined is correct, and setting them would be an error.
        rp.depthStencilAttachment = &dsa;
    }
    g_pass = f.wgpuCommandEncoderBeginRenderPass(g_pass_enc, &rp);
    if (g_pass == null) {
        f.wgpuCommandEncoderRelease(g_pass_enc);
        g_pass_enc = null;
        return gpu.GPU_ERROR;
    }
    g_pass_nbg = 0;
    g_pass_open = true;
    return gpu.OK;
}

/// GR3: an INSTANCED indexed draw whose group(0) bindings come from
/// ordinary lifecycle buffers (bindings 0..n-1, in the given order).
///
/// This is what the 3D layer needs and the 2D layer never did: a frame
/// uniform and a per-instance transform array, both readable by the vertex
/// stage. They are STORAGE buffers rather than uniforms so that the
/// lifecycle's existing buffer usage covers them -- no change to what a
/// buffer IS, only to what a draw may bind. The 2D entry points are
/// untouched.
/// `first_instance` shifts @builtin(instance_index) so a group of instances
/// living partway into a shared array draws exactly its own slice -- without
/// it, every group after the first would redraw the earlier instances with
/// the wrong geometry.
pub fn stz_gpu_render_draw_bound(pipe: i64, vbuf: i64, ibuf: i64, nindices: f64, ninstances: f64, first_instance: f64, buf_ids: [*]const i64, nbufs: i32) callconv(.c) i32 {
    return stz_gpu_render_draw_bound_tex(pipe, vbuf, ibuf, nindices, ninstances, first_instance, buf_ids, nbufs, buf_ids, 0);
}

/// The same instanced draw, plus TEXTURES.
///
/// A material that declares textures gets two group(0) bindings apiece --
/// the texture at 3+2k and its sampler at 4+2k, in declaration order --
/// which is exactly what the transpiler emits. The layout is a shared
/// convention, written down on both sides, because a bind-group mismatch
/// does not report here: it reports at SUBMIT as a wgpu PANIC, which is not
/// catchable and names nothing.
pub fn stz_gpu_render_draw_bound_tex(pipe: i64, vbuf: i64, ibuf: i64, nindices: f64, ninstances: f64, first_instance: f64, buf_ids: [*]const i64, nbufs: i32, tex_ids: [*]const i64, ntex: i32) callconv(.c) i32 {
    if (!gpu.isAvail()) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    if (!g_pass_open) return gpu.BAD_ARG;
    if (nindices < 1 or ninstances < 1 or first_instance < 0) return gpu.BAD_ARG;
    if (nbufs < 1 or nbufs > 6) return gpu.BAD_ARG;
    if (ntex < 0 or ntex > 4) return gpu.BAD_ARG;
    if (pipe <= 0 or pipe > rpipes.items.len) return gpu.BAD_ARG;
    const rp = rpipes.items[@intCast(pipe - 1)];
    const vb = gpu.rawBuffer(vbuf) orelse return gpu.STALE;
    const ib = gpu.rawBuffer(ibuf) orelse return gpu.STALE;
    const f = gpu.wfns();

    var entries: [14]c.WGPUBindGroupEntry = undefined;
    const nb: usize = @intCast(nbufs);
    for (0..nb) |i| {
        const b = gpu.rawBuffer(buf_ids[i]) orelse return gpu.STALE;
        entries[i] = std.mem.zeroes(c.WGPUBindGroupEntry);
        entries[i].binding = @intCast(i);
        entries[i].buffer = b;
        entries[i].size = gpu.rawBufferSize(buf_ids[i]);
    }
    var n_entries = nb;
    for (0..@intCast(ntex)) |t| {
        const tx = gpu.rawTexture(tex_ids[t]) orelse return gpu.STALE;
        // A pass cannot sample the target it is writing. Same check the 2D
        // path makes, for the same reason -- and narrowed the same way, to
        // the one target being written rather than every target.
        if (tex_ids[t] == g_pass_target) return gpu.BAD_ARG;
        entries[n_entries] = std.mem.zeroes(c.WGPUBindGroupEntry);
        entries[n_entries].binding = @intCast(3 + 2 * t);
        entries[n_entries].textureView = tx.view;
        entries[n_entries + 1] = std.mem.zeroes(c.WGPUBindGroupEntry);
        entries[n_entries + 1].binding = @intCast(4 + 2 * t);
        entries[n_entries + 1].sampler = samplerFor(tx.kind);
        n_entries += 2;
    }
    var bgd = std.mem.zeroes(c.WGPUBindGroupDescriptor);
    bgd.layout = rp.layout;
    bgd.entryCount = n_entries;
    bgd.entries = &entries;
    const bg = f.wgpuDeviceCreateBindGroup(gpu.deviceHandle(), &bgd);
    if (bg == null) return gpu.GPU_ERROR;

    f.wgpuRenderPassEncoderSetPipeline(g_pass, rp.pipeline);
    f.wgpuRenderPassEncoderSetBindGroup(g_pass, 0, bg, 0, null);
    f.wgpuRenderPassEncoderSetVertexBuffer(g_pass, 0, vb, 0, gpu.rawBufferSize(vbuf));
    f.wgpuRenderPassEncoderSetIndexBuffer(g_pass, ib, c.WGPUIndexFormat_Uint32, 0, gpu.rawBufferSize(ibuf));
    f.wgpuRenderPassEncoderDrawIndexed(g_pass, @intFromFloat(nindices), @intFromFloat(ninstances), 0, 0, @intFromFloat(first_instance));
    if (!pushPassBindGroup(bg)) {
        f.wgpuBindGroupRelease(bg);
        return gpu.GPU_ERROR;
    }
    gpu.bumpCounter(gpu.CTR_DRAW_COUNT, 1);
    return gpu.OK;
}

fn bindDrawState(pipe: i64, vbuf: i64, tex_id: i64) i32 {
    if (pipe <= 0 or pipe > rpipes.items.len) return gpu.BAD_ARG;
    const rp = rpipes.items[@intCast(pipe - 1)];
    const vb = gpu.rawBuffer(vbuf) orelse return gpu.STALE;
    const f = gpu.wfns();

    f.wgpuRenderPassEncoderSetPipeline(g_pass, rp.pipeline);
    if (tex_id != 0) {
        const t = gpu.rawTexture(tex_id) orelse return gpu.STALE;
        // Refuse ONLY the target being written right now. The old check
        // refused every target, which made a second pass reading the
        // first's output impossible -- the gap the challenge pass found and
        // GG4 could not be built over.
        if (tex_id == g_pass_target) return gpu.BAD_ARG;
        var entries = [2]c.WGPUBindGroupEntry{ std.mem.zeroes(c.WGPUBindGroupEntry), std.mem.zeroes(c.WGPUBindGroupEntry) };
        entries[0].binding = 0;
        entries[0].textureView = t.view;
        entries[1].binding = 1;
        entries[1].sampler = samplerFor(t.kind);
        var bgd = std.mem.zeroes(c.WGPUBindGroupDescriptor);
        bgd.layout = rp.layout;
        bgd.entryCount = 2;
        bgd.entries = &entries;
        const bg = f.wgpuDeviceCreateBindGroup(gpu.deviceHandle(), &bgd);
        if (bg == null) return gpu.GPU_ERROR;
        f.wgpuRenderPassEncoderSetBindGroup(g_pass, 0, bg, 0, null);
        // released after End() submits
        if (!pushPassBindGroup(bg)) {
            f.wgpuBindGroupRelease(bg);
            return gpu.GPU_ERROR;
        }
    }
    f.wgpuRenderPassEncoderSetVertexBuffer(g_pass, 0, vb, 0, gpu.rawBufferSize(vbuf));
    return gpu.OK;
}

/// Draw `nverts` vertices from `vbuf` starting at `first`, with `pipe`.
/// tex_id: a sampled texture for textured pipelines, 0 for untextured ones.
pub fn stz_gpu_render_draw(pipe: i64, vbuf: i64, first: f64, nverts: f64, tex_id: i64) callconv(.c) i32 {
    if (!gpu.isAvail()) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    if (!g_pass_open) return gpu.BAD_ARG;
    if (nverts < 1) return gpu.BAD_ARG;
    const st = bindDrawState(pipe, vbuf, tex_id);
    if (st != gpu.OK) return st;
    gpu.wfns().wgpuRenderPassEncoderDraw(g_pass, @intFromFloat(nverts), 1, @intFromFloat(first), 0);
    gpu.bumpCounter(gpu.CTR_DRAW_COUNT, 1);
    return gpu.OK;
}

/// Indexed draw: `ibuf` holds uint32 indices; `nindices` of them are drawn.
pub fn stz_gpu_render_draw_indexed(pipe: i64, vbuf: i64, ibuf: i64, nindices: f64, tex_id: i64) callconv(.c) i32 {
    if (!gpu.isAvail()) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    if (!g_pass_open) return gpu.BAD_ARG;
    if (nindices < 1) return gpu.BAD_ARG;
    const ib = gpu.rawBuffer(ibuf) orelse return gpu.STALE;
    const st = bindDrawState(pipe, vbuf, tex_id);
    if (st != gpu.OK) return st;
    const f = gpu.wfns();
    f.wgpuRenderPassEncoderSetIndexBuffer(g_pass, ib, c.WGPUIndexFormat_Uint32, 0, gpu.rawBufferSize(ibuf));
    f.wgpuRenderPassEncoderDrawIndexed(g_pass, @intFromFloat(nindices), 1, 0, 0, 0);
    gpu.bumpCounter(gpu.CTR_DRAW_COUNT, 1);
    return gpu.OK;
}

/// End the pass and submit ONCE. Asynchronous like dispatch: a readback or
/// Sync() establishes completion.
pub fn stz_gpu_render_end() callconv(.c) i32 {
    if (!g_pass_open) return gpu.BAD_ARG;
    g_pass_open = false;
    g_pass_target = 0;
    const f = gpu.wfns();
    f.wgpuRenderPassEncoderEnd(g_pass);
    f.wgpuRenderPassEncoderRelease(g_pass);
    g_pass = null;
    // Inside a FRAME the encoder is not ours to finish: FrameEnd owns the
    // one submit. The bind groups must also stay alive -- an encoder that
    // has not been submitted still references them, and releasing here is
    // a use-after-free waiting for the next frame.
    if (gpu.frameOpen()) {
        g_pass_enc = null; // borrowed, never owned
        return gpu.OK;
    }
    const cmd = f.wgpuCommandEncoderFinish(g_pass_enc, null);
    f.wgpuCommandEncoderRelease(g_pass_enc);
    g_pass_enc = null;
    f.wgpuQueueSubmit(gpu.queueHandle(), 1, &cmd);
    f.wgpuCommandBufferRelease(cmd);
    gpu.bumpCounter(gpu.CTR_SUBMIT_COUNT, 1);
    releasePassBindGroups();
    return gpu.OK;
}

pub fn stz_gpu_render_active() callconv(.c) i32 {
    return if (g_pass_open) 1 else 0;
}

// ---------------------------------------------------------------- readback

/// Read a render target's pixels as tight RGBA8 rows (w*h*4 bytes into out).
/// Handles the 256-byte bytesPerRow alignment with a padded staging buffer,
/// de-padded here so no caller ever sees the padding.
pub fn stz_gpu_target_read(target_id: i64, out: [*]u8, cap: f64) callconv(.c) i32 {
    ensureRegistered();
    if (!gpu.isAvail()) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    if (g_pass_open) return gpu.BAD_ARG; // end the pass first
    const t = gpu.rawTexture(target_id) orelse return gpu.STALE;
    if (t.kind != gpu.TEX_TARGET) return gpu.BAD_ARG;
    const row_bytes: usize = @as(usize, t.w) * 4;
    const tight = row_bytes * t.h;
    if (@as(usize, @intFromFloat(cap)) < tight) return gpu.BAD_ARG;
    const bpr = std.mem.alignForward(usize, row_bytes, 256);
    const f = gpu.wfns();

    var sdesc = std.mem.zeroes(c.WGPUBufferDescriptor);
    sdesc.label = sv("stz_rb");
    sdesc.usage = c.WGPUBufferUsage_MapRead | c.WGPUBufferUsage_CopyDst;
    sdesc.size = bpr * t.h;
    const staging = f.wgpuDeviceCreateBuffer(gpu.deviceHandle(), &sdesc);
    if (staging == null) return gpu.GPU_ERROR;
    defer f.wgpuBufferRelease(staging);

    const enc = f.wgpuDeviceCreateCommandEncoder(gpu.deviceHandle(), null);
    var src = std.mem.zeroes(c.WGPUTexelCopyTextureInfo);
    src.texture = t.tex;
    var dst = std.mem.zeroes(c.WGPUTexelCopyBufferInfo);
    dst.layout.bytesPerRow = @intCast(bpr);
    dst.layout.rowsPerImage = t.h;
    dst.buffer = staging;
    const ext = c.WGPUExtent3D{ .width = t.w, .height = t.h, .depthOrArrayLayers = 1 };
    f.wgpuCommandEncoderCopyTextureToBuffer(enc, &src, &dst, &ext);
    const cmd = f.wgpuCommandEncoderFinish(enc, null);
    f.wgpuCommandEncoderRelease(enc);
    f.wgpuQueueSubmit(gpu.queueHandle(), 1, &cmd);
    f.wgpuCommandBufferRelease(cmd);
    gpu.bumpCounter(gpu.CTR_SUBMIT_COUNT, 1);

    gpu.setMapFlags(false, false);
    const cbinfo = gpu.mapCallback();
    _ = f.wgpuBufferMapAsync(staging, c.WGPUMapMode_Read, 0, bpr * t.h, cbinfo);
    while (!gpu.mapDone()) {
        _ = f.wgpuDevicePoll(gpu.deviceHandle(), 1, null);
        f.wgpuInstanceProcessEvents(gpu.instanceHandle());
    }
    if (!gpu.mapOk()) return gpu.GPU_ERROR;
    const p = f.wgpuBufferGetConstMappedRange(staging, 0, bpr * t.h);
    if (p == null) return gpu.GPU_ERROR;
    const bytes: [*]const u8 = @ptrCast(p.?);
    for (0..t.h) |y| {
        @memcpy(out[y * row_bytes ..][0..row_bytes], bytes[y * bpr ..][0..row_bytes]);
    }
    f.wgpuBufferUnmap(staging);
    gpu.bumpCounter(gpu.CTR_TRANSFER_BYTES, @floatFromInt(tight));
    return gpu.OK;
}

// ---------------------------------------------------------------- PNG encoder
// Pure Zig over the vendored zlib -- the GR0 spike's encoder, engine-resident.
// Filter 0 rows, one IDAT. Level 1 is the measured default (GR0: identical
// pixels, half the time of level 6); callers may pass 1..9.

fn be32(buf: []u8, v: u32) void {
    buf[0] = @intCast((v >> 24) & 0xff);
    buf[1] = @intCast((v >> 16) & 0xff);
    buf[2] = @intCast((v >> 8) & 0xff);
    buf[3] = @intCast(v & 0xff);
}

fn pngChunk(out: []u8, pos: usize, typ: *const [4]u8, data: []const u8) usize {
    be32(out[pos..][0..4], @intCast(data.len));
    @memcpy(out[pos + 4 ..][0..4], typ);
    @memcpy(out[pos + 8 ..][0..data.len], data);
    var crc: z.uLong = z.crc32(0, null, 0);
    crc = z.crc32(crc, out[pos + 4 ..].ptr, @intCast(4 + data.len));
    be32(out[pos + 8 + data.len ..][0..4], @intCast(crc));
    return pos + 12 + data.len;
}

// WHAT A RENDERER OWES THE FILE IT WRITES.
//
// Central re-encoded a 594 KB diagram to 103 KB and handed over the method.
// Its picture was large because something upstream had been through a lossy
// step and left 16,414 distinct colours in a drawing that has about twelve:
// PNG compresses RUNS, and noise destroys runs. Its remedy was to quantise.
//
// THIS PLANE'S ANSWER IS DIFFERENT, AND THE DIFFERENCE IS THE POINT. There is
// no lossy upstream here. This encoder is handed the exact pixels the renderer
// drew, so quantising would INVENT loss where none exists -- it would be this
// library damaging its own output to fix somebody else's problem. What a
// renderer owes its file is exactness, and then not spending bytes on defaults
// it is in a position to know are wrong.
//
// Two things it was in a position to know and did not use:
//
//   1. THE FILTER. Every row was written with filter None. PNG's whole
//      compression story is that a row is usually cheaper as a DIFFERENCE
//      from its neighbours, and the standard remedy is per-row selection by
//      minimum sum of absolute differences (PNG spec 12.8). Lossless, always
//      applicable, and it costs one extra pass over the rows.
//
//   2. THE COLOUR TYPE. Colour type 6 -- 8-bit RGBA -- regardless of what was
//      drawn. A canvas that drew line art KNOWS its colours; it never has to
//      infer a palette the way an external optimiser does. Where the image
//      genuinely holds 256 distinct RGBA values or fewer, indexed colour is
//      EXACT: every pixel keeps its own colour, and the file carries one byte
//      per pixel instead of four. Where it holds more, this says so and stays
//      RGBA rather than quantising.
//
// Both are lossless, so rule 3 of Central's method -- decode your own output
// back and diff it -- becomes an assertion rather than a distribution: the
// guard demands byte-for-byte equality with the input, and would catch a
// filter or palette bug that still opens in a viewer.

/// What the encoder saw and what it decided. Returned beside the bytes so a
/// caller who wants to know can, and a guard can assert on it.
pub const PngStat = struct {
    colors: u32, // distinct RGBA values, or 257 meaning "more than 256"
    color_type: u8, // 3 indexed, 6 RGBA
    bytes: u32,
    /// how many rows chose each filter, 0..4 -- the profile that says whether
    /// adaptive filtering earned its pass
    filters: [5]u32,
};

var last_stat: PngStat = .{ .colors = 0, .color_type = 6, .bytes = 0, .filters = .{ 0, 0, 0, 0, 0 } };

pub fn pngLastStat() PngStat {
    return last_stat;
}

/// One filtered byte. Split out so the cost pass and the write pass compute
/// the SAME value from one definition -- two copies of Paeth is exactly the
/// kind of duplication that diverges silently.
inline fn filterByte(ft: u8, cur: u8, a: u8, b: u8, ul: u8) u8 {
    return switch (ft) {
        0 => cur,
        1 => cur -% a,
        2 => cur -% b,
        3 => cur -% @as(u8, @intCast((@as(u16, a) + @as(u16, b)) / 2)),
        else => blk: {
            const p: i16 = @as(i16, a) + @as(i16, b) - @as(i16, ul);
            const pa = @abs(p - @as(i16, a));
            const pb = @abs(p - @as(i16, b));
            const pc = @abs(p - @as(i16, ul));
            const pr: u8 = if (pa <= pb and pa <= pc) a else if (pb <= pc) b else ul;
            break :blk cur -% pr;
        },
    };
}

/// Sum of absolute signed differences -- PNG's own filter heuristic -- WITHOUT
/// materialising the candidate row. The first version wrote each candidate to
/// a scratch buffer and then summed it, which is two passes per filter and
/// eleven passes per row; this is six, and it took a 1100x760 encode from
/// 48.1 ms to the number in the guard.
fn filterCostOf(ft: u8, src: []const u8, prev: []const u8, bpp: usize) u64 {
    var s: u64 = 0;
    for (src, 0..) |cur, i| {
        const a: u8 = if (i >= bpp) src[i - bpp] else 0;
        const b: u8 = prev[i];
        const ul: u8 = if (i >= bpp) prev[i - bpp] else 0;
        const v: i16 = @as(i8, @bitCast(filterByte(ft, cur, a, b, ul)));
        s += @intCast(if (v < 0) -@as(i16, v) else v);
    }
    return s;
}

/// Write `src` filtered by `ft` into `dst`, given the previous raw row.
fn applyFilter(ft: u8, src: []const u8, prev: []const u8, bpp: usize, dst: []u8) void {
    for (src, 0..) |cur, i| {
        const a: u8 = if (i >= bpp) src[i - bpp] else 0;
        const b: u8 = prev[i];
        const ul: u8 = if (i >= bpp) prev[i - bpp] else 0; // `c` is the module's zlib alias
        dst[i] = filterByte(ft, cur, a, b, ul);
    }
}

/// Filter every row of `src` (h rows of row_bytes) into `raw`, choosing per
/// row. `raw` holds h*(row_bytes+1) bytes: filter byte then filtered row.
fn filterRows(src: []const u8, h: u32, row_bytes: usize, bpp: usize, raw: []u8, counts: *[5]u32) !void {
    const zero = try alloc.alloc(u8, row_bytes);
    defer alloc.free(zero);
    @memset(zero, 0);
    for (0..h) |y| {
        const cur = src[y * row_bytes ..][0..row_bytes];
        const prev = if (y == 0) zero else src[(y - 1) * row_bytes ..][0..row_bytes];
        // ONE FILTER FOR RGBA, FIVE TRIALS FOR INDEXED, and the split is
        // measured rather than tasteful. On this plane's own diagram --
        // 1100x760, past 256 colours -- trying all five bought 11.5% of the
        // bytes for FOUR TIMES the encode: 35,155 -> 31,111 bytes, 4.7 ->
        // 18.9 ms. That is a bad trade on a path that also serves embedded
        // images. At four bytes a pixel with many colours the deflate stream
        // is already near its floor, so the trials mostly re-discover the
        // same answer over 3.3 MB, five times.
        //
        // On the indexed path the same trials bought 29,189 -> 7,607 bytes
        // for 4.6 -> 6.7 ms, because one byte per pixel over flat art is
        // exactly what row differencing is for.
        //
        // So: indexed rows choose; RGBA rows take Paeth, which is the
        // standard choice for continuous-tone data and costs one pass.
        var best_ft: u8 = 4;
        if (bpp == 1) {
            var best_cost: u64 = std.math.maxInt(u64);
            var ft: u8 = 0;
            while (ft < 5) : (ft += 1) {
                const cost = filterCostOf(ft, cur, prev, bpp);
                if (cost < best_cost) {
                    best_cost = cost;
                    best_ft = ft;
                }
            }
        }
        raw[y * (row_bytes + 1)] = best_ft;
        applyFilter(best_ft, cur, prev, bpp, raw[y * (row_bytes + 1) + 1 ..][0..row_bytes]);
        counts[best_ft] += 1;
    }
}

/// RGBA8 tight rows -> PNG bytes (caller owns the slice; alloc = c_allocator).
pub fn pngEncode(w: u32, h: u32, rgba: []const u8, level: i32) ![]u8 {
    if (w == 0 or h == 0) return error.BadArg;
    const row_bytes: usize = @as(usize, w) * 4;
    if (rgba.len != row_bytes * h) return error.BadArg;
    const lvl = if (level < 1 or level > 9) 1 else level; // z1: the GR0 default

    var counts = [5]u32{ 0, 0, 0, 0, 0 };

    // COUNT THE COLOURS FIRST, and stop at 257. A drawing knows its palette;
    // an optimiser has to infer one. The early exit is what keeps this cheap
    // on a photograph, where the answer is decided in the first few rows.
    var pal: [256]u32 = undefined;
    var npal: usize = 0;
    var over = false;
    var px: usize = 0;
    while (px < rgba.len) : (px += 4) {
        const key = (@as(u32, rgba[px]) << 24) | (@as(u32, rgba[px + 1]) << 16) |
            (@as(u32, rgba[px + 2]) << 8) | @as(u32, rgba[px + 3]);
        var seen = false;
        for (pal[0..npal]) |q| {
            if (q == key) {
                seen = true;
                break;
            }
        }
        if (seen) continue;
        if (npal == 256) {
            over = true;
            break;
        }
        pal[npal] = key;
        npal += 1;
    }

    var ihdr: [13]u8 = undefined;
    be32(ihdr[0..4], w);
    be32(ihdr[4..8], h);
    ihdr[8] = 8; // bit depth
    ihdr[10] = 0;
    ihdr[11] = 0;
    ihdr[12] = 0;

    var plte_buf: [768]u8 = undefined;
    var trns_buf: [256]u8 = undefined;
    var plte_len: usize = 0;
    var trns_len: usize = 0;

    var raw: []u8 = undefined;
    var raw_len: usize = 0;

    if (!over) {
        // INDEXED, and exactly so -- every pixel keeps its own colour.
        ihdr[9] = 3;
        const idx_row: usize = w;
        const flat = try alloc.alloc(u8, idx_row * h);
        defer alloc.free(flat);
        px = 0;
        var i: usize = 0;
        while (px < rgba.len) : (px += 4) {
            const key = (@as(u32, rgba[px]) << 24) | (@as(u32, rgba[px + 1]) << 16) |
                (@as(u32, rgba[px + 2]) << 8) | @as(u32, rgba[px + 3]);
            var k: usize = 0;
            while (k < npal) : (k += 1) {
                if (pal[k] == key) break;
            }
            flat[i] = @intCast(k);
            i += 1;
        }
        var k: usize = 0;
        var any_alpha = false;
        while (k < npal) : (k += 1) {
            plte_buf[k * 3] = @intCast((pal[k] >> 24) & 0xff);
            plte_buf[k * 3 + 1] = @intCast((pal[k] >> 16) & 0xff);
            plte_buf[k * 3 + 2] = @intCast((pal[k] >> 8) & 0xff);
            trns_buf[k] = @intCast(pal[k] & 0xff);
            if (trns_buf[k] != 255) any_alpha = true;
        }
        plte_len = npal * 3;
        trns_len = if (any_alpha) npal else 0;

        raw_len = (idx_row + 1) * h;
        raw = try alloc.alloc(u8, raw_len);
        try filterRows(flat, h, idx_row, 1, raw, &counts);
    } else {
        ihdr[9] = 6; // RGBA
        raw_len = (row_bytes + 1) * h;
        raw = try alloc.alloc(u8, raw_len);
        try filterRows(rgba, h, row_bytes, 4, raw, &counts);
    }
    defer alloc.free(raw);

    var clen: z.uLongf = z.compressBound(@intCast(raw_len));
    const comp = try alloc.alloc(u8, @intCast(clen));
    defer alloc.free(comp);
    if (z.compress2(comp.ptr, &clen, raw.ptr, @intCast(raw_len), lvl) != z.Z_OK)
        return error.DeflateFailed;

    var total: usize = 8 + (12 + 13) + (12 + @as(usize, @intCast(clen))) + 12;
    if (plte_len > 0) total += 12 + plte_len;
    if (trns_len > 0) total += 12 + trns_len;

    const out = try alloc.alloc(u8, total);
    @memcpy(out[0..8], &[8]u8{ 0x89, 'P', 'N', 'G', '\r', '\n', 0x1a, '\n' });
    var pos: usize = 8;
    pos = pngChunk(out, pos, "IHDR", &ihdr);
    if (plte_len > 0) pos = pngChunk(out, pos, "PLTE", plte_buf[0..plte_len]);
    if (trns_len > 0) pos = pngChunk(out, pos, "tRNS", trns_buf[0..trns_len]);
    pos = pngChunk(out, pos, "IDAT", comp[0..@intCast(clen)]);
    pos = pngChunk(out, pos, "IEND", &.{});
    std.debug.assert(pos == total);

    last_stat = .{
        .colors = if (over) 257 else @intCast(npal),
        .color_type = ihdr[9],
        .bytes = @intCast(total),
        .filters = counts,
    };
    return out;
}

// ---------------------------------------------------------------- image grid
// Lay equal-sized RGBA tiles out in a grid: the CONTACT SHEET that turns N
// renders into one picture. Engine-side because it is a pure byte blit over
// megabytes -- nine 420x420 tiles is 6.3 MB of memcpy, which a Ring loop would
// do one substr at a time.
//
// `tiles` is the tiles CONCATENATED, tightest packing, row-major RGBA8. A
// short buffer is a refusal, not a partial sheet: a caller who miscounted
// should hear about it rather than get a torn image.

pub fn imageGrid(
    tiles: []const u8,
    tw: u32,
    th: u32,
    count: u32,
    cols: u32,
    gutter: u32,
    bg: [4]u8,
) !DecodedImage {
    if (tw == 0 or th == 0 or count == 0 or cols == 0) return error.BadArg;
    const tile_bytes: usize = @as(usize, tw) * @as(usize, th) * 4;
    if (tiles.len < tile_bytes * count) return error.BadArg;

    const rows: u32 = (count + cols - 1) / cols;
    const out_w: u32 = cols * tw + (cols + 1) * gutter;
    const out_h: u32 = rows * th + (rows + 1) * gutter;
    const out_row: usize = @as(usize, out_w) * 4;
    const out = try alloc.alloc(u8, out_row * out_h);
    errdefer alloc.free(out);

    // paint the whole sheet with the background, THEN blit -- so gutters and
    // any empty cell in the last row are the background, not uninitialised
    // memory (which reads as plausible noise and looks like a render bug).
    var i: usize = 0;
    while (i < out.len) : (i += 4) @memcpy(out[i..][0..4], &bg);

    var k: u32 = 0;
    while (k < count) : (k += 1) {
        const cx: u32 = k % cols;
        const cy: u32 = k / cols;
        const x0: usize = @as(usize, gutter + cx * (tw + gutter));
        const y0: usize = @as(usize, gutter + cy * (th + gutter));
        const src = tiles[tile_bytes * k ..][0..tile_bytes];
        const src_row: usize = @as(usize, tw) * 4;
        for (0..th) |y| {
            const d = (y0 + y) * out_row + x0 * 4;
            @memcpy(out[d..][0..src_row], src[y * src_row ..][0..src_row]);
        }
    }
    return .{ .w = out_w, .h = out_h, .rgba = out };
}

// ---------------------------------------------------------------- image decode
// stb_image, memory-only. Always RGBA8 out (req_comp = 4).

pub const DecodedImage = struct { w: u32, h: u32, rgba: []u8 };

pub fn imageDecode(bytes: []const u8) ?DecodedImage {
    var w: c_int = 0;
    var h: c_int = 0;
    var comp: c_int = 0;
    const p = stbi.stbi_load_from_memory(bytes.ptr, @intCast(bytes.len), &w, &h, &comp, 4) orelse return null;
    defer stbi.stbi_image_free(p);
    if (w <= 0 or h <= 0) return null;
    const n = @as(usize, @intCast(w)) * @as(usize, @intCast(h)) * 4;
    const out = alloc.alloc(u8, n) catch return null;
    @memcpy(out, @as([*]const u8, @ptrCast(p))[0..n]);
    return .{ .w = @intCast(w), .h = @intCast(h), .rgba = out };
}

test {
    // encode -> decode round-trip on a tiny deterministic image
    var px: [4 * 4 * 4]u8 = undefined;
    for (&px, 0..) |*v, i| v.* = @intCast((i * 37) % 251);
    const png = try pngEncode(4, 4, &px, 1);
    defer alloc.free(png);
    try std.testing.expect(png.len > 8);
    try std.testing.expectEqualSlices(u8, &[8]u8{ 0x89, 'P', 'N', 'G', '\r', '\n', 0x1a, '\n' }, png[0..8]);
    const dec = imageDecode(png) orelse return error.DecodeFailed;
    defer alloc.free(dec.rgba);
    try std.testing.expectEqual(@as(u32, 4), dec.w);
    try std.testing.expectEqual(@as(u32, 4), dec.h);
    try std.testing.expectEqualSlices(u8, &px, dec.rgba);
}
