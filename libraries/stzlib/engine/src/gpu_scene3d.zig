//! The 3D scene -- GR3 of SOFTANZA_GRAPHICS_PLAN.md.
//!
//! A camera, a directional light, and a list of INSTANCES: each one a mesh,
//! a material colour, and a transform. Rendered by ONE forward-lit pipeline
//! (directional + ambient) into a depth-tested pass, with all instances of
//! the same mesh drawn in a SINGLE instanced call.
//!
//! Two §3b doors are load-bearing here, and both are guarded rather than
//! merely intended:
//!
//!   - **Transform state is SEPARATE from render state.** An instance's
//!     transform lives in its own array and its own GPU buffer. Moving
//!     something re-uploads 128 bytes of matrices; it does not touch the
//!     mesh, its vertex buffer, its material or its pipeline. That is what
//!     lets a physics or animation step drive a scene without knowing what
//!     rendering is, and `geometry_uploads` exists so a guard can PROVE the
//!     geometry stayed put.
//!   - **The vertex format is derived from the mesh's attributes**, so a
//!     mesh carrying extra attributes gets its own pipeline variant with no
//!     change to this file's contract.
//!
//! Scope, per the plan and kept honestly: NO shadows, NO PBR, NO skeletal
//! animation. Each is a later, workload-justified increment -- the G6 law
//! applied to our own roadmap.
//!
//! Binding contract for the 3D pipeline (group 0):
//!   @binding(0) storage read Frame     { viewProj, lightDir, lightColor, ambient }
//!   @binding(1) storage read Instances { array<Instance{ model, normalMat, color }> }
//! Both are ordinary lifecycle buffers -- storage rather than uniform so
//! the buffer usage that shipped in G1 already covers them.

const std = @import("std");
const gpu = @import("gpu.zig");
const render = @import("gpu_render.zig");
const mesh = @import("gpu_mesh.zig");
const gm = @import("gpu_math.zig");

const alloc = std.heap.c_allocator;

pub const OK: i32 = 0;
pub const STALE: i32 = 2;
pub const BAD_ARG: i32 = 3;

// ---------------------------------------------------------------- WGSL

const WGSL_FORWARD =
    \\struct Frame {
    \\  viewProj: mat4x4<f32>,
    \\  lightDir: vec4<f32>,
    \\  lightColor: vec4<f32>,
    \\  ambient: vec4<f32>,
    \\}
    \\struct Instance {
    \\  model: mat4x4<f32>,
    \\  normalMat: mat4x4<f32>,
    \\  color: vec4<f32>,
    \\}
    \\@group(0) @binding(0) var<storage, read> frame: Frame;
    \\@group(0) @binding(1) var<storage, read> instances: array<Instance>;
    \\
    \\struct VSOut {
    \\  @builtin(position) pos: vec4<f32>,
    \\  @location(0) normal: vec3<f32>,
    \\  @location(1) color: vec4<f32>,
    \\}
    \\
    \\@vertex
    \\fn vmain(@location(0) position: vec3<f32>,
    \\         @location(1) normal: vec3<f32>,
    \\         @location(2) uv: vec2<f32>,
    \\         @builtin(instance_index) ii: u32) -> VSOut {
    \\  let inst = instances[ii];
    \\  var o: VSOut;
    \\  o.pos = frame.viewProj * inst.model * vec4<f32>(position, 1.0);
    \\  o.normal = normalize((inst.normalMat * vec4<f32>(normal, 0.0)).xyz);
    \\  o.color = inst.color;
    \\  return o;
    \\}
    \\
    \\@fragment
    \\fn fmain(in: VSOut) -> @location(0) vec4<f32> {
    \\  let n = normalize(in.normal);
    \\  let lambert = max(dot(n, -normalize(frame.lightDir.xyz)), 0.0);
    \\  let lit = frame.ambient.rgb + frame.lightColor.rgb * lambert;
    \\  return vec4<f32>(in.color.rgb * lit, in.color.a);
    \\}
;

// The same shading for a mesh carrying an EXTRA attribute (position,
// normal, uv, colour). Proof that the vertex-format hinge reaches all the
// way to a working pipeline: only the attribute list and this entry point
// differ -- the frame/instance contract is untouched.
const WGSL_FORWARD_VCOLOR =
    \\struct Frame {
    \\  viewProj: mat4x4<f32>,
    \\  lightDir: vec4<f32>,
    \\  lightColor: vec4<f32>,
    \\  ambient: vec4<f32>,
    \\}
    \\struct Instance {
    \\  model: mat4x4<f32>,
    \\  normalMat: mat4x4<f32>,
    \\  color: vec4<f32>,
    \\}
    \\@group(0) @binding(0) var<storage, read> frame: Frame;
    \\@group(0) @binding(1) var<storage, read> instances: array<Instance>;
    \\
    \\struct VSOut {
    \\  @builtin(position) pos: vec4<f32>,
    \\  @location(0) normal: vec3<f32>,
    \\  @location(1) color: vec4<f32>,
    \\}
    \\
    \\@vertex
    \\fn vmain(@location(0) position: vec3<f32>,
    \\         @location(1) normal: vec3<f32>,
    \\         @location(2) uv: vec2<f32>,
    \\         @location(3) vcolor: vec4<f32>,
    \\         @builtin(instance_index) ii: u32) -> VSOut {
    \\  let inst = instances[ii];
    \\  var o: VSOut;
    \\  o.pos = frame.viewProj * inst.model * vec4<f32>(position, 1.0);
    \\  o.normal = normalize((inst.normalMat * vec4<f32>(normal, 0.0)).xyz);
    \\  o.color = inst.color * vcolor;
    \\  return o;
    \\}
    \\
    \\@fragment
    \\fn fmain(in: VSOut) -> @location(0) vec4<f32> {
    \\  let n = normalize(in.normal);
    \\  let lambert = max(dot(n, -normalize(frame.lightDir.xyz)), 0.0);
    \\  let lit = frame.ambient.rgb + frame.lightColor.rgb * lambert;
    \\  return vec4<f32>(in.color.rgb * lit, in.color.a);
    \\}
;

const FRAME_FLOATS = 16 + 4 + 4 + 4; // viewProj, lightDir, lightColor, ambient
pub const MAX_MAT_FLOATS = 6 * 4 + 14; // the transpiler's colour and scalar limits
const INSTANCE_FLOATS = 16 + 16 + 4; // model, normalMat, color

// ---------------------------------------------------------------- state

const Instance = struct {
    mesh_id: i64,
    transform: gm.Transform, // LOCAL transform, relative to the parent
    color: [4]f32, // RENDER STATE -- written by materials
    // GG3: -1 means "no parent, local IS world". A child's drawn position
    // is parent_world * local, which is what makes an arm a chain rather
    // than four independent objects that must be moved in lockstep by hand.
    parent: i32 = -1,
};

/// Per-mesh GPU residency: uploaded once, reused every frame (the retained
/// discipline the whole plane runs on).
const MeshRes = struct {
    mesh_id: i64,
    vbuf: i64 = 0,
    ibuf: i64 = 0,
    nindices: u32 = 0,
    // one pipeline per TARGET FORMAT (0 = RGBA8 offscreen, 1 = BGRA8
    // swapchain). Same shader, same mesh, same everything else -- a colour
    // target of the wrong format is a validation error, so the format is
    // part of what a pipeline IS.
    pipe: [2]i64 = @splat(0),
    uploaded: bool = false,
};

const Scene3d = struct {
    w: u32 = 0,
    h: u32 = 0,
    clear: [4]f32 = .{ 0, 0, 0, 1 },
    camera: gm.Camera = .{},
    light_dir: gm.Vec3 = .{ .x = -0.4, .y = -1, .z = -0.5 },
    light_color: [3]f32 = .{ 1, 1, 1 },
    ambient: [3]f32 = .{ 0.15, 0.15, 0.18 },
    instances: std.ArrayList(Instance) = .{},
    world: std.ArrayList(gm.Mat4) = .{}, // GG3: resolved each frame
    hierarchy_depth: u32 = 0, // witness: 0 = flat, >0 = a real chain
    cycles_refused: u32 = 0, // a parent loop is COUNTED, never hung on
    res: std.ArrayList(MeshRes) = .{},
    // GPU objects
    target: i64 = 0,
    depth: i64 = 0,
    // GR5 presentation: a swapchain frame to draw into instead of `target`.
    // Set for the duration of one draw, never stored across frames -- a
    // swapchain texture is only valid between acquire and present.
    ext_target: i64 = 0,
    ext_tfmt: i32 = 0,
    frame_buf: i64 = 0,
    inst_buf: i64 = 0,
    gpu_driven: bool = false, // transforms come from a compute kernel, not from CPU state
    // GR4b: a scene-level MATERIAL -- a transpiled WGSL shader plus the
    // values its declared colours and scalars take. Scene-level rather
    // than per-instance on purpose: per-instance materials would have to
    // split the draw grouping (mesh AND material), which is a different
    // phase, not a bigger version of this one.
    mat_wgsl: [8192]u8 = undefined,
    mat_wgsl_len: usize = 0,
    mat_params: [MAX_MAT_FLOATS]f32 = @splat(0),
    mat_param_count: usize = 0,
    mat_buf: i64 = 0,
    // witnesses
    geometry_uploads: u64 = 0, // increments ONLY when mesh data is uploaded
    transform_uploads: u64 = 0, // increments every frame (cheap, by design)
    last_draw_calls: u32 = 0,
    gen: u32 = 1,
    live: bool = false,
};

var scenes: std.ArrayList(Scene3d) = .{};
var hooked = false;

fn ensureHooked() void {
    if (!hooked) {
        gpu.registerDeviceCloseHook(&forgetDeviceObjects);
        hooked = true;
    }
}

fn makeId(slot: usize, gen: u32) i64 {
    return (@as(i64, gen) << 32) | @as(i64, @intCast(slot + 1));
}

fn slotOf(id: i64) ?usize {
    const idx = id & 0xffff_ffff;
    if (idx <= 0 or idx > @as(i64, @intCast(scenes.items.len))) return null;
    const slot: usize = @intCast(idx - 1);
    const gen: u32 = @intCast((id >> 32) & 0xffff_ffff);
    if (!scenes.items[slot].live or scenes.items[slot].gen != gen) return null;
    return slot;
}

pub fn forgetDeviceObjects() void {
    for (scenes.items) |*s| {
        if (!s.live) continue;
        s.target = 0;
        s.depth = 0;
        s.ext_target = 0;
        s.frame_buf = 0;
        s.inst_buf = 0;
        for (s.res.items) |*r| {
            r.vbuf = 0;
            r.ibuf = 0;
            r.pipe = @splat(0);
            r.uploaded = false;
        }
    }
}

pub fn sceneNew(w: f64, h: f64) i64 {
    ensureHooked();
    if (w < 1 or h < 1 or w > 16384 or h > 16384) return 0;
    var slot: usize = scenes.items.len;
    for (scenes.items, 0..) |s, i| {
        if (!s.live) {
            slot = i;
            break;
        }
    }
    if (slot == scenes.items.len) scenes.append(alloc, .{}) catch return 0;
    const s = &scenes.items[slot];
    s.w = @intFromFloat(w);
    s.h = @intFromFloat(h);
    s.instances.clearRetainingCapacity();
    s.res.clearRetainingCapacity();
    s.camera = .{};
    s.clear = .{ 0.05, 0.06, 0.08, 1 };
    s.light_dir = .{ .x = -0.4, .y = -1, .z = -0.5 };
    s.light_color = .{ 1, 1, 1 };
    s.ambient = .{ 0.15, 0.15, 0.18 };
    s.geometry_uploads = 0;
    s.transform_uploads = 0;
    s.last_draw_calls = 0;
    s.live = true;
    return makeId(slot, s.gen);
}

pub fn sceneFree(id: i64) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &scenes.items[slot];
    for (s.res.items) |r| {
        if (r.vbuf != 0) _ = gpu.stz_gpu_buffer_free(r.vbuf);
        if (r.ibuf != 0) _ = gpu.stz_gpu_buffer_free(r.ibuf);
    }
    s.instances.clearAndFree(alloc);
    s.res.clearAndFree(alloc);
    if (s.frame_buf != 0) _ = gpu.stz_gpu_buffer_free(s.frame_buf);
    if (s.inst_buf != 0) _ = gpu.stz_gpu_buffer_free(s.inst_buf);
    if (s.target != 0) _ = gpu.stz_gpu_texture_free(s.target);
    if (s.depth != 0) _ = gpu.stz_gpu_texture_free(s.depth);
    s.frame_buf = 0;
    s.inst_buf = 0;
    s.target = 0;
    s.depth = 0;
    s.live = false;
    s.gen +%= 1;
    return OK;
}

pub fn setClear(id: i64, r: f32, g: f32, b: f32, a: f32) i32 {
    const slot = slotOf(id) orelse return STALE;
    scenes.items[slot].clear = .{ r, g, b, a };
    return OK;
}

pub fn setCamera(id: i64, eye: gm.Vec3, target: gm.Vec3, fovy_deg: f32, near: f32, far: f32) i32 {
    const slot = slotOf(id) orelse return STALE;
    if (near <= 0 or far <= near or fovy_deg <= 0 or fovy_deg >= 180) return BAD_ARG;
    const s = &scenes.items[slot];
    s.camera.eye = eye;
    s.camera.target = target;
    s.camera.fovy_rad = fovy_deg * std.math.pi / 180.0;
    s.camera.near = near;
    s.camera.far = far;
    return OK;
}

pub fn setLight(id: i64, dir: gm.Vec3, r: f32, g: f32, b: f32, ar: f32, ag: f32, ab: f32) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &scenes.items[slot];
    s.light_dir = dir;
    s.light_color = .{ r, g, b };
    s.ambient = .{ ar, ag, ab };
    return OK;
}

/// Add an instance. Returns its 1-based index (0 = refusal) -- transforms
/// are addressed by index afterwards, which is what keeps a simulation's
/// write path free of handles and render state.
pub fn addInstance(id: i64, mesh_id: i64, tr: gm.Transform, color: [4]f32) f64 {
    const slot = slotOf(id) orelse return 0;
    if (mesh.vertexCount(mesh_id) <= 0) return 0;
    const s = &scenes.items[slot];
    s.instances.append(alloc, .{ .mesh_id = mesh_id, .transform = tr, .color = color }) catch return 0;
    return @floatFromInt(s.instances.items.len);
}

/// Write ONE instance's transform. The §3b door in one function: this
/// touches transform state and nothing else -- no mesh, no material, no
/// pipeline, no geometry re-upload.
pub fn setTransform(id: i64, index: usize, tr: gm.Transform) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &scenes.items[slot];
    if (index == 0 or index > s.instances.items.len) return BAD_ARG;
    s.instances.items[index - 1].transform = tr;
    return OK;
}

pub fn getTransform(id: i64, index: usize) ?gm.Transform {
    const slot = slotOf(id) orelse return null;
    const s = &scenes.items[slot];
    if (index == 0 or index > s.instances.items.len) return null;
    return s.instances.items[index - 1].transform;
}

pub fn setInstanceColor(id: i64, index: usize, color: [4]f32) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &scenes.items[slot];
    if (index == 0 or index > s.instances.items.len) return BAD_ARG;
    s.instances.items[index - 1].color = color;
    return OK;
}

pub fn instanceCount(id: i64) f64 {
    const slot = slotOf(id) orelse return -1;
    return @floatFromInt(scenes.items[slot].instances.items.len);
}

/// GR4 (closing the challenge pass's gap 1): hand out the instance
/// buffer's handle so a COMPUTE kernel can write transforms directly --
/// the zero-copy trick that already works for particles, now reachable
/// for meshes. 0 until the scene has rendered once (the buffer is sized
/// from the instance list).
/// GR4b: give the scene a transpiled material. `params` are the declared
/// colours (4 floats each, in declaration order) followed by the declared
/// scalars. Passing an empty shader clears it back to the built-in
/// forward-lit pipeline.
pub fn setMaterial(id: i64, wgsl: []const u8, params: []const f32) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &scenes.items[slot];
    if (wgsl.len > s.mat_wgsl.len) return BAD_ARG;
    if (params.len > MAX_MAT_FLOATS) return BAD_ARG;
    @memcpy(s.mat_wgsl[0..wgsl.len], wgsl);
    s.mat_wgsl_len = wgsl.len;
    @memcpy(s.mat_params[0..params.len], params);
    s.mat_param_count = params.len;
    // the pipeline is chosen per mesh at residency time, so drop what was
    // resident: the next render rebuilds against the new shader
    for (s.res.items) |*r| r.uploaded = false;
    return OK;
}

pub fn hasMaterial(id: i64) i32 {
    const slot = slotOf(id) orelse return -1;
    return if (scenes.items[slot].mat_wgsl_len > 0) 1 else 0;
}

pub fn instanceBuffer(id: i64) i64 {
    const slot = slotOf(id) orelse return 0;
    return scenes.items[slot].inst_buf;
}

/// Per-instance stride in FLOATS, so a kernel can address the array the
/// same way the shader does (model 16, normalMat 16, color 4).
pub fn instanceStrideFloats() f64 {
    return @floatFromInt(INSTANCE_FLOATS);
}

/// When GPU-driven, the scene STOPS rewriting the instance buffer from
/// its CPU transforms -- whatever a compute kernel left there is what
/// gets drawn. Without this the next frame would overwrite the kernel's
/// work, so the accessor above would be a trap rather than a door.
pub fn setGpuDriven(id: i64, on: bool) i32 {
    const slot = slotOf(id) orelse return STALE;
    scenes.items[slot].gpu_driven = on;
    return OK;
}

pub fn isGpuDriven(id: i64) i32 {
    const slot = slotOf(id) orelse return -1;
    return if (scenes.items[slot].gpu_driven) 1 else 0;
}

/// [instances, meshes resident, draw calls last render, geometry uploads,
///  transform uploads]
pub fn stats(id: i64) ?[5]f64 {
    const slot = slotOf(id) orelse return null;
    const s = &scenes.items[slot];
    return .{
        @floatFromInt(s.instances.items.len),
        @floatFromInt(s.res.items.len),
        @floatFromInt(s.last_draw_calls),
        @floatFromInt(s.geometry_uploads),
        @floatFromInt(s.transform_uploads),
    };
}

// ---------------------------------------------------------------- render

/// Create-or-reuse a device buffer of at least `bytes`. It GROWS ONLY: a
/// request smaller than the current buffer keeps it, so the allocation
/// tracks the high-water mark rather than the latest frame.
///
/// That is why there is no capacity field here (a dead `inst_capacity` sat
/// on the scene for two phases before anyone noticed it was never read).
/// Two facts make one impossible to use: this function already refuses to
/// shrink, and a scene's instance count cannot fall at all -- instances are
/// only ever ADDED through the public surface, and the sole
/// `clearRetainingCapacity` runs at scene creation. So there is no
/// oscillation for a capacity check to absorb. If instance REMOVAL is ever
/// added, revisit this comment before revisiting the buffer.
fn ensureBuffer(cur: i64, bytes: usize) i64 {
    var id = cur;
    if (id != 0) {
        const sz = gpu.stz_gpu_buffer_size(id);
        if (sz < 0) {
            id = 0;
        } else if (@as(usize, @intFromFloat(sz)) < bytes) {
            _ = gpu.stz_gpu_buffer_free(id);
            id = 0;
        }
    }
    if (id == 0) id = gpu.stz_gpu_buffer_new(@floatFromInt(bytes));
    return id;
}

/// Upload a mesh ONCE and keep it; returns its INDEX in s.res (not a
/// pointer -- appending to that list can move it, and a dangling *MeshRes
/// is the kind of bug that only shows up once a scene has two meshes).
/// The pipeline is chosen by the mesh's own attribute layout, which is how
/// an extended vertex format reaches the GPU without this function ever
/// learning what the new attribute means.
fn residencyFor(s: *Scene3d, mesh_id: i64, tfmt: i32) ?usize {
    const ti: usize = if (tfmt == render.TFMT_BGRA8) 1 else 0;
    for (s.res.items, 0..) |r, i| {
        if (r.mesh_id != mesh_id or !r.uploaded) continue;
        if (r.pipe[ti] != 0) return i;
        // Resident geometry, new target format: compile the ONE missing
        // pipeline and keep the mesh where it is. Re-uploading it here
        // would make the geometry-upload witness lie the first time a
        // scene is shown in a window after being saved to a file.
        var fb: [32]u8 = undefined;
        const f2 = mesh.formatString(mesh_id, &fb) orelse return null;
        const w2: []const u8 = if (s.mat_wgsl_len > 0)
            s.mat_wgsl[0..s.mat_wgsl_len]
        else if (mesh.attrCount(mesh_id) >= 4) WGSL_FORWARD_VCOLOR else WGSL_FORWARD;
        const p2 = render.stz_gpu_render_pipeline_fmt(w2.ptr, @floatFromInt(w2.len), f2.ptr, @floatFromInt(f2.len), 0, 1, 1, @floatFromInt(tfmt));
        if (p2 == 0) return null;
        s.res.items[i].pipe[ti] = p2;
        return i;
    }
    const verts = mesh.vertexData(mesh_id) orelse return null;
    const idx = mesh.indexData(mesh_id) orelse return null;
    if (verts.len == 0 or idx.len == 0) return null;

    var fmt_buf: [32]u8 = undefined;
    const fmt = mesh.formatString(mesh_id, &fmt_buf) orelse return null;
    // a scene material replaces the built-in shading for every mesh
    const wgsl: []const u8 = if (s.mat_wgsl_len > 0)
        s.mat_wgsl[0..s.mat_wgsl_len]
    else if (mesh.attrCount(mesh_id) >= 4) WGSL_FORWARD_VCOLOR else WGSL_FORWARD;
    const pipe = render.stz_gpu_render_pipeline_fmt(wgsl.ptr, @floatFromInt(wgsl.len), fmt.ptr, @floatFromInt(fmt.len), 0, 1, 1, @floatFromInt(tfmt));
    if (pipe == 0) return null;

    var ri: ?usize = null;
    for (s.res.items, 0..) |r, i| {
        if (r.mesh_id == mesh_id) ri = i;
    }
    if (ri == null) {
        s.res.append(alloc, .{ .mesh_id = mesh_id }) catch return null;
        ri = s.res.items.len - 1;
    }
    const r = &s.res.items[ri.?];
    const vbytes = verts.len * 4;
    const ibytes = idx.len * 4;
    r.vbuf = ensureBuffer(r.vbuf, vbytes);
    r.ibuf = ensureBuffer(r.ibuf, ibytes);
    if (r.vbuf == 0 or r.ibuf == 0) return null;
    if (gpu.stz_gpu_buffer_write(r.vbuf, @ptrCast(verts.ptr), @floatFromInt(vbytes)) != gpu.OK) return null;
    if (gpu.stz_gpu_buffer_write(r.ibuf, @ptrCast(idx.ptr), @floatFromInt(ibytes)) != gpu.OK) return null;
    r.nindices = @intCast(idx.len);
    r.pipe[ti] = pipe;
    r.uploaded = true;
    s.geometry_uploads += 1;
    return ri.?;
}

/// Resolve every instance's WORLD transform from its local one and its
/// parent's world. GG0's propagation primitive with matrices instead of
/// bitsets: repeat passes until nothing new resolves.
///
/// Order-independent on purpose -- a caller may add a child before its
/// parent, and demanding otherwise would be a rule nobody remembers. The
/// pass count is the hierarchy DEPTH, reported so a guard can prove a
/// chain is a chain.
///
/// A parent CYCLE cannot resolve. Rather than loop forever, the unresolved
/// instances fall back to their local transform and the refusal is counted
/// -- the house rule: a refusal that names itself, never a hang.
fn resolveWorld(s: *Scene3d) !void {
    const n = s.instances.items.len;
    try s.world.resize(alloc, n);
    const level = try alloc.alloc(i32, n); // -1 = not resolved yet
    defer alloc.free(level);
    @memset(level, -1);

    // An explicit stack, walking each instance's parent chain and memoising
    // on the way back down. O(n) TOTAL regardless of the order things were
    // added in.
    //
    // The first version swept the whole list repeatedly until nothing new
    // resolved. That is O(n) when parents happen to be added before their
    // children and O(n*depth) when they are not -- measured at 4000 deep,
    // 0.15 ms the friendly way and 20 ms the other, which is a whole frame
    // budget lost to the order a caller wrote their code in. A resolver
    // whose cost depends on that is a trap, not an optimisation.
    var stack = try alloc.alloc(usize, n);
    defer alloc.free(stack);

    for (0..n) |start| {
        if (level[start] >= 0) continue;
        var top: usize = 0;
        var cur = start;

        // climb to an ancestor that is already resolved (or is a root)
        while (true) {
            const p = s.instances.items[cur].parent;
            if (p < 0) {
                s.world.items[cur] = s.instances.items[cur].transform.toMat4();
                level[cur] = 0;
                break;
            }
            const pi: usize = @intCast(p);
            if (pi >= n or pi == cur) {
                s.world.items[cur] = s.instances.items[cur].transform.toMat4();
                level[cur] = 0;
                s.cycles_refused += 1;
                break;
            }
            if (level[pi] >= 0) {
                // Parent already known -- but cur still has to be COMPOSED,
                // so it must go on the stack. Breaking here without pushing
                // left every such instance unresolved, and the whole point
                // of the class (a child follows its parent) stopped working.
                stack[top] = cur;
                top += 1;
                break;
            }
            // CYCLE: this instance is already on the path we are climbing
            if (level[cur] == -2) {
                s.world.items[cur] = s.instances.items[cur].transform.toMat4();
                level[cur] = 0;
                s.cycles_refused += 1;
                break;
            }
            level[cur] = -2; // mark "on the current path"
            stack[top] = cur;
            top += 1;
            cur = pi;
        }

        // walk back down, composing parent_world * local
        while (top > 0) {
            top -= 1;
            const i = stack[top];
            const p = s.instances.items[i].parent;
            const pi: usize = @intCast(@max(0, p));
            if (p >= 0 and pi < n and level[pi] >= 0) {
                s.world.items[i] = s.world.items[pi].mul(s.instances.items[i].transform.toMat4());
                level[i] = level[pi] + 1;
            } else {
                s.world.items[i] = s.instances.items[i].transform.toMat4();
                level[i] = 0;
            }
        }
    }

    var maxlvl: i32 = 0;
    for (level) |L| {
        if (L > maxlvl) maxlvl = L;
    }
    s.hierarchy_depth = @intCast(@max(0, maxlvl));
}

pub fn setParent(id: i64, index: i32, parent: i32) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &scenes.items[slot];
    const i: usize = @intCast(@max(0, index - 1));
    if (index < 1 or i >= s.instances.items.len) return BAD_ARG;
    if (parent != -1) {
        const p: usize = @intCast(@max(0, parent - 1));
        if (parent < 1 or p >= s.instances.items.len) return BAD_ARG;
        if (p == i) return BAD_ARG; // its own parent is never meaningful
        s.instances.items[i].parent = @intCast(p);
    } else {
        s.instances.items[i].parent = -1;
    }
    return OK;
}

pub fn hierarchyDepth(id: i64) f64 {
    const slot = slotOf(id) orelse return -1;
    const s = &scenes.items[slot];
    // RESOLVE first. This used to return whatever the previous render had
    // left behind, so a chain that had never been drawn reported depth 0 --
    // a witness that answered about the past.
    resolveWorld(s) catch return -1;
    return @floatFromInt(s.hierarchy_depth);
}

pub fn cyclesRefused(id: i64) f64 {
    const slot = slotOf(id) orelse return -1;
    return @floatFromInt(scenes.items[slot].cycles_refused);
}

/// The resolved world position of one instance -- what a caller needs to
/// ASSERT that a child actually followed its parent.
pub fn worldPosition(id: i64, index: i32, out: *[3]f32) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &scenes.items[slot];
    const i: usize = @intCast(@max(0, index - 1));
    if (index < 1 or i >= s.instances.items.len) return BAD_ARG;
    resolveWorld(s) catch return BAD_ARG;
    const m = s.world.items[i].m;
    out[0] = m[12];
    out[1] = m[13];
    out[2] = m[14];
    return OK;
}

fn renderToTarget(s: *Scene3d) !bool {
    if (gpu.stz_gpu_is_available() == 0) {
        gpu.countFallback();
        return false;
    }
    if (s.instances.items.len == 0) return false;

    const tfmt: i32 = if (s.ext_target != 0) s.ext_tfmt else render.TFMT_RGBA8;
    if (s.ext_target == 0) {
        // Same as the 2D tier: a target that no longer matches the scene's
        // size is as unusable as a stale one. The depth buffer below was
        // already handled; the COLOUR target was not, so a resized 3D scene
        // read back through the wrong dimensions.
        if (s.target != 0 and (gpu.stz_gpu_texture_width(s.target) != @as(f64, @floatFromInt(s.w)) or
            gpu.stz_gpu_texture_height(s.target) != @as(f64, @floatFromInt(s.h))))
        {
            _ = gpu.stz_gpu_texture_free(s.target);
            s.target = 0;
        }
        if (s.target == 0) {
            s.target = gpu.stz_gpu_texture_new(@floatFromInt(s.w), @floatFromInt(s.h), @floatFromInt(gpu.TEX_TARGET));
            if (s.target == 0) return false;
        }
    }
    const draw_target = if (s.ext_target != 0) s.ext_target else s.target;
    const ti: usize = if (tfmt == render.TFMT_BGRA8) 1 else 0;
    // The depth buffer must MATCH the colour target's size, so a resized
    // window drops the old one rather than rendering with a mismatched
    // attachment (a validation error, and a black window if it were not).
    if (s.depth != 0 and (gpu.stz_gpu_texture_width(s.depth) != @as(f64, @floatFromInt(s.w)) or
        gpu.stz_gpu_texture_height(s.depth) != @as(f64, @floatFromInt(s.h))))
    {
        _ = gpu.stz_gpu_texture_free(s.depth);
        s.depth = 0;
    }
    if (s.depth == 0) {
        s.depth = gpu.stz_gpu_texture_new(@floatFromInt(s.w), @floatFromInt(s.h), @floatFromInt(gpu.TEX_DEPTH));
        if (s.depth == 0) return false;
    }

    // frame constants
    const aspect = @as(f32, @floatFromInt(s.w)) / @as(f32, @floatFromInt(s.h));
    const vp = s.camera.viewProjection(aspect);
    var frame: [FRAME_FLOATS]f32 = @splat(0);
    @memcpy(frame[0..16], &vp.m);
    const ld = s.light_dir.normalize();
    frame[16] = ld.x;
    frame[17] = ld.y;
    frame[18] = ld.z;
    frame[19] = 0;
    frame[20] = s.light_color[0];
    frame[21] = s.light_color[1];
    frame[22] = s.light_color[2];
    frame[23] = 1;
    frame[24] = s.ambient[0];
    frame[25] = s.ambient[1];
    frame[26] = s.ambient[2];
    frame[27] = 1;
    s.frame_buf = ensureBuffer(s.frame_buf, FRAME_FLOATS * 4);
    if (s.frame_buf == 0) return false;
    if (gpu.stz_gpu_buffer_write(s.frame_buf, @ptrCast(&frame), FRAME_FLOATS * 4) != gpu.OK) return false;

    // Instances are ordered by mesh so each mesh draws in ONE instanced
    // call; the per-instance data is the ONLY thing rebuilt per frame.
    var order: std.ArrayList(usize) = .{};
    defer order.deinit(alloc);
    var groups: std.ArrayList(struct { res_index: usize, first: u32, count: u32 }) = .{};
    defer groups.deinit(alloc);

    var seen: std.ArrayList(i64) = .{};
    defer seen.deinit(alloc);
    for (s.instances.items) |inst| {
        var known = false;
        for (seen.items) |m| {
            if (m == inst.mesh_id) known = true;
        }
        if (!known) try seen.append(alloc, inst.mesh_id);
    }
    for (seen.items) |mid| {
        const ri = residencyFor(s, mid, tfmt) orelse continue;
        const first: u32 = @intCast(order.items.len);
        for (s.instances.items, 0..) |inst, i| {
            if (inst.mesh_id == mid) try order.append(alloc, i);
        }
        const count: u32 = @as(u32, @intCast(order.items.len)) - first;
        if (count > 0) try groups.append(alloc, .{ .res_index = ri, .first = first, .count = count });
    }
    if (order.items.len == 0) return false;

    const idata = try alloc.alloc(f32, order.items.len * INSTANCE_FLOATS);
    defer alloc.free(idata);
    try resolveWorld(s);
    for (order.items, 0..) |src_i, dst_i| {
        const inst = s.instances.items[src_i];
        const model = s.world.items[src_i];
        const nrm = gm.Mat4.normalMatrix(model);
        const base = dst_i * INSTANCE_FLOATS;
        @memcpy(idata[base .. base + 16], &model.m);
        @memcpy(idata[base + 16 .. base + 32], &nrm.m);
        idata[base + 32] = inst.color[0];
        idata[base + 33] = inst.color[1];
        idata[base + 34] = inst.color[2];
        idata[base + 35] = inst.color[3];
    }
    const ibytes = idata.len * 4;
    const had_buffer = s.inst_buf != 0;
    s.inst_buf = ensureBuffer(s.inst_buf, ibytes);
    if (s.inst_buf == 0) return false;
    // A GPU-driven scene keeps whatever a compute kernel wrote. The FIRST
    // render still seeds the buffer from CPU state (a kernel needs
    // something to read, and the buffer only exists from here), and a
    // buffer that had to be recreated is seeded again -- otherwise the
    // scene would draw uninitialized VRAM.
    if (!s.gpu_driven or !had_buffer) {
        if (gpu.stz_gpu_buffer_write(s.inst_buf, @ptrCast(idata.ptr), @floatFromInt(ibytes)) != gpu.OK) return false;
        s.transform_uploads += 1;
    }

    // a material's declared values ride a third storage buffer at @2 --
    // the binding the transpiler emits, and the only addition a material
    // makes to the 3D contract
    var nbufs: i32 = 2;
    if (s.mat_wgsl_len > 0) {
        // WGSL rounds a struct's SIZE up to its largest member alignment,
        // and a material's colours are vec4s -- so a buffer sized to the
        // raw float count is too small and the bind group is rejected at
        // submit, far from here. Round to 16.
        const raw = @max(4, s.mat_param_count * 4);
        const mbytes = (raw + 15) / 16 * 16;
        s.mat_buf = ensureBuffer(s.mat_buf, mbytes);
        if (s.mat_buf == 0) return false;
        if (gpu.stz_gpu_buffer_write(s.mat_buf, @ptrCast(&s.mat_params), @floatFromInt(mbytes)) != gpu.OK) return false;
        nbufs = 3;
    }

    if (render.stz_gpu_render_begin3d(draw_target, s.depth, s.clear[0], s.clear[1], s.clear[2], s.clear[3]) != gpu.OK) return false;
    var draws: u32 = 0;
    const bufs = [_]i64{ s.frame_buf, s.inst_buf, s.mat_buf };
    for (groups.items) |g| {
        // Instances of one mesh are CONTIGUOUS in the buffer (it was built
        // in group order), so each mesh is ONE instanced draw. firstInstance
        // shifts @builtin(instance_index) onto this group's slice -- which
        // is what makes "one draw per mesh, whatever the scene" true rather
        // than aspirational.
        const r = s.res.items[g.res_index];
        if (render.stz_gpu_render_draw_bound(
            r.pipe[ti],
            r.vbuf,
            r.ibuf,
            @floatFromInt(r.nindices),
            @floatFromInt(g.count),
            @floatFromInt(g.first),
            &bufs,
            nbufs,
        ) == gpu.OK) draws += 1;
    }
    if (render.stz_gpu_render_end() != gpu.OK) return false;
    s.last_draw_calls = draws;
    return true;
}

/// GR5: draw this 3D scene straight into a swapchain frame -- no readback,
/// no encode. This is the call an animation loop makes 60 times a second,
/// and it is the same renderer that produces the PNG.
pub fn sceneDrawToTarget(id: i64, target_id: i64, tfmt: i32, w: u32, h: u32) bool {
    const slot = slotOf(id) orelse return false;
    const s = &scenes.items[slot];
    if (w != 0 and h != 0 and (w != s.w or h != s.h)) {
        s.w = w;
        s.h = h; // the camera's aspect ratio is derived from these each frame
    }
    s.ext_target = target_id;
    s.ext_tfmt = tfmt;
    defer {
        s.ext_target = 0;
        s.ext_tfmt = 0;
    }
    return renderToTarget(s) catch false;
}

pub fn sceneToPixels(id: i64) !?[]u8 {
    const slot = slotOf(id) orelse return null;
    const s = &scenes.items[slot];
    if (!try renderToTarget(s)) return null;
    const npix = @as(usize, s.w) * s.h * 4;
    const out = try alloc.alloc(u8, npix);
    errdefer alloc.free(out);
    if (render.stz_gpu_target_read(s.target, out.ptr, @floatFromInt(npix)) != gpu.OK) {
        alloc.free(out);
        return null;
    }
    return out;
}

pub fn sceneToPng(id: i64, level: i32) !?[]u8 {
    const px = try sceneToPixels(id) orelse return null;
    defer alloc.free(px);
    const slot = slotOf(id) orelse return null;
    const s = &scenes.items[slot];
    return try render.pngEncode(s.w, s.h, px, level);
}
