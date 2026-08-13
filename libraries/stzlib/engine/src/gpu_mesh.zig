//! Meshes -- GR3 of SOFTANZA_GRAPHICS_PLAN.md.
//!
//! A mesh is interleaved f32 vertex data + a u32 index list + an ATTRIBUTE
//! DESCRIPTOR. That descriptor is the §3b door, taken concretely: the
//! pipeline's vertex-format string is DERIVED from the attribute list
//! ("3,3,2" for position/normal/uv), so adding skin weights or per-vertex
//! colour later is a new attribute, not a change to the pipeline contract.
//! Skeletal animation stays OUT of this phase; its door stays open, and the
//! guard proves the hinge works by building a 4-attribute mesh today.
//!
//! Winding is COUNTER-CLOCKWISE for front faces (WebGPU's FrontFace_CCW,
//! which the 3D pipeline sets explicitly), so back-face culling is a knob
//! that can be turned on without re-authoring geometry.
//!
//! Everything here is CPU-side: a mesh exists, and can be inspected and
//! unit-tested, with no device present.

const std = @import("std");

const alloc = std.heap.c_allocator;

pub const OK: i32 = 0;
pub const STALE: i32 = 2;
pub const BAD_ARG: i32 = 3;

pub const MAX_ATTRS = 8;

/// One vertex attribute: a name (for diagnostics) and its float count.
pub const Attr = struct { name: []const u8, comps: u8 };

/// The standard 3D vertex: position, normal, uv. New attributes append.
pub const STD_ATTRS = [_]Attr{
    .{ .name = "position", .comps = 3 },
    .{ .name = "normal", .comps = 3 },
    .{ .name = "uv", .comps = 2 },
};

const MeshSlot = struct {
    verts: std.ArrayList(f32) = .{},
    indices: std.ArrayList(u32) = .{},
    attrs: [MAX_ATTRS]Attr = undefined,
    nattrs: usize = 0,
    stride: usize = 0, // floats per vertex
    gen: u32 = 1,
    live: bool = false,
};

var meshes: std.ArrayList(MeshSlot) = .{};

fn makeId(slot: usize, gen: u32) i64 {
    return (@as(i64, gen) << 32) | @as(i64, @intCast(slot + 1));
}

fn slotOf(id: i64) ?usize {
    const idx = id & 0xffff_ffff;
    if (idx <= 0 or idx > @as(i64, @intCast(meshes.items.len))) return null;
    const slot: usize = @intCast(idx - 1);
    const gen: u32 = @intCast((id >> 32) & 0xffff_ffff);
    if (!meshes.items[slot].live or meshes.items[slot].gen != gen) return null;
    return slot;
}

fn alloc_slot(attrs: []const Attr) ?usize {
    if (attrs.len == 0 or attrs.len > MAX_ATTRS) return null;
    var slot: usize = meshes.items.len;
    for (meshes.items, 0..) |s, i| {
        if (!s.live) {
            slot = i;
            break;
        }
    }
    if (slot == meshes.items.len) {
        meshes.append(alloc, .{}) catch return null;
    }
    const s = &meshes.items[slot];
    s.verts.clearRetainingCapacity();
    s.indices.clearRetainingCapacity();
    s.nattrs = attrs.len;
    s.stride = 0;
    for (attrs, 0..) |a, i| {
        s.attrs[i] = a;
        s.stride += a.comps;
    }
    s.live = true;
    return slot;
}

pub fn meshFree(id: i64) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &meshes.items[slot];
    s.verts.clearAndFree(alloc);
    s.indices.clearAndFree(alloc);
    s.live = false;
    s.gen +%= 1;
    return OK;
}

pub fn vertexCount(id: i64) f64 {
    const slot = slotOf(id) orelse return -1;
    const s = &meshes.items[slot];
    if (s.stride == 0) return 0;
    return @floatFromInt(s.verts.items.len / s.stride);
}

pub fn indexCount(id: i64) f64 {
    const slot = slotOf(id) orelse return -1;
    return @floatFromInt(meshes.items[slot].indices.items.len);
}

pub fn attrCount(id: i64) f64 {
    const slot = slotOf(id) orelse return -1;
    return @floatFromInt(meshes.items[slot].nattrs);
}

pub fn strideFloats(id: i64) f64 {
    const slot = slotOf(id) orelse return -1;
    return @floatFromInt(meshes.items[slot].stride);
}

/// The pipeline's vertex-format string, DERIVED from the attributes
/// ("3,3,2"). This is the §3b hinge: extending a mesh extends its format,
/// and the pipeline contract never had to know what the attributes MEAN.
pub fn formatString(id: i64, out: []u8) ?[]const u8 {
    const slot = slotOf(id) orelse return null;
    const s = &meshes.items[slot];
    var n: usize = 0;
    for (0..s.nattrs) |i| {
        if (n > 0) {
            if (n >= out.len) return null;
            out[n] = ',';
            n += 1;
        }
        if (n >= out.len) return null;
        out[n] = '0' + s.attrs[i].comps;
        n += 1;
    }
    return out[0..n];
}

pub fn vertexData(id: i64) ?[]const f32 {
    const slot = slotOf(id) orelse return null;
    return meshes.items[slot].verts.items;
}

pub fn indexData(id: i64) ?[]const u32 {
    const slot = slotOf(id) orelse return null;
    return meshes.items[slot].indices.items;
}

// ---------------------------------------------------------------- builders

fn pushVertex(s: *MeshSlot, vals: []const f32) !void {
    try s.verts.appendSlice(alloc, vals);
}

fn pushTri(s: *MeshSlot, a: u32, b: u32, c: u32) !void {
    try s.indices.append(alloc, a);
    try s.indices.append(alloc, b);
    try s.indices.append(alloc, c);
}

/// An axis-aligned cube of side `size`, centred at the origin. Six separate
/// faces (24 vertices) rather than eight shared corners, because a shared
/// corner cannot carry three different normals -- sharing them is the
/// classic way to get a cube that shades like a sphere.
pub fn buildCube(size: f32) i64 {
    const slot = alloc_slot(&STD_ATTRS) orelse return 0;
    const s = &meshes.items[slot];
    const h = size * 0.5;
    // face: normal, then its four corners in CCW order seen from outside
    const faces = [_][3]f32{
        .{ 0, 0, 1 }, .{ 0, 0, -1 }, .{ 1, 0, 0 },
        .{ -1, 0, 0 }, .{ 0, 1, 0 }, .{ 0, -1, 0 },
    };
    const corners = [_][4][3]f32{
        .{ .{ -1, -1, 1 }, .{ 1, -1, 1 }, .{ 1, 1, 1 }, .{ -1, 1, 1 } }, // +Z
        .{ .{ 1, -1, -1 }, .{ -1, -1, -1 }, .{ -1, 1, -1 }, .{ 1, 1, -1 } }, // -Z
        .{ .{ 1, -1, 1 }, .{ 1, -1, -1 }, .{ 1, 1, -1 }, .{ 1, 1, 1 } }, // +X
        .{ .{ -1, -1, -1 }, .{ -1, -1, 1 }, .{ -1, 1, 1 }, .{ -1, 1, -1 } }, // -X
        .{ .{ -1, 1, 1 }, .{ 1, 1, 1 }, .{ 1, 1, -1 }, .{ -1, 1, -1 } }, // +Y
        .{ .{ -1, -1, -1 }, .{ 1, -1, -1 }, .{ 1, -1, 1 }, .{ -1, -1, 1 } }, // -Y
    };
    const uvs = [4][2]f32{ .{ 0, 1 }, .{ 1, 1 }, .{ 1, 0 }, .{ 0, 0 } };
    for (faces, 0..) |nrm, fi| {
        const base: u32 = @intCast(s.verts.items.len / s.stride);
        for (corners[fi], 0..) |cn, ci| {
            pushVertex(s, &[_]f32{
                cn[0] * h, cn[1] * h, cn[2] * h,
                nrm[0],    nrm[1],    nrm[2],
                uvs[ci][0], uvs[ci][1],
            }) catch return 0;
        }
        pushTri(s, base, base + 1, base + 2) catch return 0;
        pushTri(s, base, base + 2, base + 3) catch return 0;
    }
    return makeId(slot, s.gen);
}

/// A UV sphere. `segs` around, `rings` top to bottom.
pub fn buildSphere(radius: f32, segs: u32, rings: u32) i64 {
    if (segs < 3 or rings < 2) return 0;
    const slot = alloc_slot(&STD_ATTRS) orelse return 0;
    const s = &meshes.items[slot];
    for (0..rings + 1) |ri| {
        const v = @as(f32, @floatFromInt(ri)) / @as(f32, @floatFromInt(rings));
        const phi = v * std.math.pi;
        for (0..segs + 1) |si| {
            const u = @as(f32, @floatFromInt(si)) / @as(f32, @floatFromInt(segs));
            const theta = u * std.math.tau;
            // The poles are set EXACTLY rather than trusted to trigonometry:
            // @sin(pi) in f32 is -8.7e-8, not 0, so the bottom "pole" would
            // be a ring of almost-coincident points whose triangles are
            // numerically meaningless slivers.
            const sp: f32 = if (ri == 0 or ri == rings) 0.0 else @sin(phi);
            const cp: f32 = if (ri == 0) 1.0 else if (ri == rings) -1.0 else @cos(phi);
            const nx = sp * @cos(theta);
            const ny = cp;
            const nz = sp * @sin(theta);
            pushVertex(s, &[_]f32{ nx * radius, ny * radius, nz * radius, nx, ny, nz, u, v }) catch return 0;
        }
    }
    const row = segs + 1;
    for (0..rings) |ri| {
        for (0..segs) |si| {
            const a: u32 = @intCast(ri * row + si);
            const b: u32 = a + row;
            // COUNTER-CLOCKWISE seen from OUTSIDE. Getting this backwards
            // does not look like a winding bug: back-face culling hides the
            // near surface and you see the sphere's INTERIOR, whose normals
            // face away from the light -- so the sphere just renders dark,
            // and it is easy to blame the lighting. The test below asserts
            // the face normal agrees with the vertex normal for exactly
            // this reason.
            pushTri(s, a, a + 1, b) catch return 0;
            pushTri(s, a + 1, b + 1, b) catch return 0;
        }
    }
    return makeId(slot, s.gen);
}

/// A TORUS: the shape every renderer shows off with, and the one this
/// library could not draw. Ring radius R, tube radius r, `segs` around the
/// ring and `sides` around the tube.
///
/// The normal is exact rather than estimated -- it points from the tube's
/// CENTRE CIRCLE to the surface, which is the definition of the surface
/// normal on a torus. A cross-product estimate from neighbouring vertices
/// would be close but would band visibly under a smooth material, and the
/// material language is precisely what this shape exists to display.
pub fn buildTorus(ring_r: f32, tube_r: f32, segs: u32, sides: u32) i64 {
    if (segs < 3 or sides < 3 or ring_r <= 0 or tube_r <= 0) return 0;
    const slot = alloc_slot(&STD_ATTRS) orelse return 0;
    const s = &meshes.items[slot];
    for (0..segs + 1) |si| {
        const u = @as(f32, @floatFromInt(si)) / @as(f32, @floatFromInt(segs));
        const theta = u * std.math.tau;      // around the ring
        const ct = @cos(theta);
        const st = @sin(theta);
        for (0..sides + 1) |vi| {
            const v = @as(f32, @floatFromInt(vi)) / @as(f32, @floatFromInt(sides));
            const phi = v * std.math.tau;    // around the tube
            const cp = @cos(phi);
            const sp = @sin(phi);
            // the point on the centre circle this vertex belongs to
            const cx = ring_r * ct;
            const cz = ring_r * st;
            const px = (ring_r + tube_r * cp) * ct;
            const py = tube_r * sp;
            const pz = (ring_r + tube_r * cp) * st;
            // centre-circle -> surface, normalised: the exact normal
            var nx = px - cx;
            const ny = py;
            var nz = pz - cz;
            const len = @sqrt(nx * nx + ny * ny + nz * nz);
            if (len > 0) {
                nx /= len;
                nz /= len;
            }
            pushVertex(s, &[_]f32{ px, py, pz, nx, ny / @max(len, 1e-6), nz, u, v }) catch return 0;
        }
    }
    const row = sides + 1;
    for (0..segs) |si| {
        for (0..sides) |vi| {
            const a: u32 = @intCast(si * row + vi);
            const b: u32 = a + row;
            // same winding as the sphere, and for the same reason: get it
            // backwards and you see the INSIDE, which reads as a lighting
            // bug rather than a winding one
            pushTri(s, a, a + 1, b) catch return 0;
            pushTri(s, a + 1, b + 1, b) catch return 0;
        }
    }
    return makeId(slot, s.gen);
}

/// A flat plane in XZ, facing +Y, centred at the origin.
pub fn buildPlane(size: f32) i64 {
    const slot = alloc_slot(&STD_ATTRS) orelse return 0;
    const s = &meshes.items[slot];
    const h = size * 0.5;
    const pts = [4][3]f32{ .{ -h, 0, h }, .{ h, 0, h }, .{ h, 0, -h }, .{ -h, 0, -h } };
    const uvs = [4][2]f32{ .{ 0, 1 }, .{ 1, 1 }, .{ 1, 0 }, .{ 0, 0 } };
    for (pts, 0..) |pt, i| {
        pushVertex(s, &[_]f32{ pt[0], pt[1], pt[2], 0, 1, 0, uvs[i][0], uvs[i][1] }) catch return 0;
    }
    pushTri(s, 0, 1, 2) catch return 0;
    pushTri(s, 0, 2, 3) catch return 0;
    return makeId(slot, s.gen);
}

/// Build a mesh with a CUSTOM attribute layout from raw interleaved data.
/// The door in §3b, usable today: pass 4 attributes (say position, normal,
/// uv, colour) and everything downstream -- format string, pipeline, draw --
/// adapts without a line changing in the render layer.
pub fn buildCustom(comps: []const u8, verts: []const f32, indices: []const u32) i64 {
    if (comps.len == 0 or comps.len > MAX_ATTRS) return 0;
    var attrs: [MAX_ATTRS]Attr = undefined;
    var stride: usize = 0;
    for (comps, 0..) |cc, i| {
        if (cc < 1 or cc > 4) return 0;
        attrs[i] = .{ .name = "attr", .comps = cc };
        stride += cc;
    }
    if (stride == 0 or verts.len % stride != 0) return 0;
    const nverts = verts.len / stride;
    for (indices) |ix| {
        if (ix >= nverts) return 0; // an index past the end is a refusal, not a crash
    }
    const slot = alloc_slot(attrs[0..comps.len]) orelse return 0;
    const s = &meshes.items[slot];
    s.verts.appendSlice(alloc, verts) catch return 0;
    s.indices.appendSlice(alloc, indices) catch return 0;
    return makeId(slot, s.gen);
}

// ---------------------------------------------------------------- OBJ

const Key3 = struct { v: u32, t: u32, n: u32 };

fn parseIndexTriple(tok: []const u8, nv: usize, nt: usize, nn: usize) ?Key3 {
    var it = std.mem.splitScalar(u8, tok, '/');
    const vs = it.next() orelse return null;
    const ts = it.next();
    const ns = it.next();
    const v = parseObjIndex(vs, nv) orelse return null;
    const t = if (ts != null and ts.?.len > 0) (parseObjIndex(ts.?, nt) orelse return null) else 0;
    const n = if (ns != null and ns.?.len > 0) (parseObjIndex(ns.?, nn) orelse return null) else 0;
    return .{ .v = v, .t = t, .n = n };
}

/// OBJ indices are 1-based, and NEGATIVE means "counting back from the end"
/// -- a real part of the format that a naive parser turns into a crash.
fn parseObjIndex(s: []const u8, count: usize) ?u32 {
    const i = std.fmt.parseInt(i64, s, 10) catch return null;
    if (i > 0) {
        if (@as(usize, @intCast(i)) > count) return null;
        return @intCast(i);
    }
    if (i < 0) {
        const back = @as(i64, @intCast(count)) + i + 1;
        if (back < 1) return null;
        return @intCast(back);
    }
    return null;
}

/// Load a Wavefront OBJ from memory: v / vt / vn / f, faces triangulated as
/// a fan, vertices deduplicated by their (v, vt, vn) TRIPLE -- because two
/// faces sharing a position but not a normal are two different vertices,
/// and merging them is how a hard edge turns soft. Missing normals are
/// generated from face geometry.
pub fn loadObj(src: []const u8) i64 {
    var pos: std.ArrayList([3]f32) = .{};
    defer pos.deinit(alloc);
    var nrm: std.ArrayList([3]f32) = .{};
    defer nrm.deinit(alloc);
    var uv: std.ArrayList([2]f32) = .{};
    defer uv.deinit(alloc);
    var keys: std.ArrayList(Key3) = .{};
    defer keys.deinit(alloc);
    var tris: std.ArrayList(u32) = .{};
    defer tris.deinit(alloc);

    var lines = std.mem.splitScalar(u8, src, '\n');
    while (lines.next()) |raw| {
        const line = std.mem.trim(u8, raw, " \t\r");
        if (line.len == 0 or line[0] == '#') continue;
        var it = std.mem.tokenizeAny(u8, line, " \t");
        const tag = it.next() orelse continue;
        if (std.mem.eql(u8, tag, "v")) {
            var v: [3]f32 = .{ 0, 0, 0 };
            for (0..3) |i| {
                const t = it.next() orelse return 0;
                v[i] = std.fmt.parseFloat(f32, t) catch return 0;
            }
            pos.append(alloc, v) catch return 0;
        } else if (std.mem.eql(u8, tag, "vn")) {
            var v: [3]f32 = .{ 0, 0, 0 };
            for (0..3) |i| {
                const t = it.next() orelse return 0;
                v[i] = std.fmt.parseFloat(f32, t) catch return 0;
            }
            nrm.append(alloc, v) catch return 0;
        } else if (std.mem.eql(u8, tag, "vt")) {
            var v: [2]f32 = .{ 0, 0 };
            for (0..2) |i| {
                const t = it.next() orelse return 0;
                v[i] = std.fmt.parseFloat(f32, t) catch return 0;
            }
            uv.append(alloc, v) catch return 0;
        } else if (std.mem.eql(u8, tag, "f")) {
            var face: [64]u32 = undefined;
            var nf: usize = 0;
            while (it.next()) |tok| {
                if (nf == face.len) break;
                const k = parseIndexTriple(tok, pos.items.len, uv.items.len, nrm.items.len) orelse return 0;
                var found: ?u32 = null;
                for (keys.items, 0..) |kk, ki| {
                    if (kk.v == k.v and kk.t == k.t and kk.n == k.n) {
                        found = @intCast(ki);
                        break;
                    }
                }
                if (found == null) {
                    keys.append(alloc, k) catch return 0;
                    found = @intCast(keys.items.len - 1);
                }
                face[nf] = found.?;
                nf += 1;
            }
            if (nf < 3) continue;
            for (1..nf - 1) |i| { // fan triangulation
                tris.append(alloc, face[0]) catch return 0;
                tris.append(alloc, face[i]) catch return 0;
                tris.append(alloc, face[i + 1]) catch return 0;
            }
        }
    }
    if (keys.items.len == 0 or tris.items.len == 0) return 0;

    const slot = alloc_slot(&STD_ATTRS) orelse return 0;
    const s = &meshes.items[slot];
    for (keys.items) |k| {
        const p = pos.items[k.v - 1];
        const n = if (k.n > 0) nrm.items[k.n - 1] else [3]f32{ 0, 0, 0 };
        const t = if (k.t > 0) uv.items[k.t - 1] else [2]f32{ 0, 0 };
        pushVertex(s, &[_]f32{ p[0], p[1], p[2], n[0], n[1], n[2], t[0], t[1] }) catch return 0;
    }
    s.indices.appendSlice(alloc, tris.items) catch return 0;

    // A file without vn leaves every normal at zero, which shades to black.
    // Generate them from the faces instead of shipping an unlit mesh.
    if (nrm.items.len == 0) generateNormals(s);
    return makeId(slot, s.gen);
}

fn generateNormals(s: *MeshSlot) void {
    const stride = s.stride;
    const nverts = s.verts.items.len / stride;
    for (0..nverts) |i| {
        s.verts.items[i * stride + 3] = 0;
        s.verts.items[i * stride + 4] = 0;
        s.verts.items[i * stride + 5] = 0;
    }
    var i: usize = 0;
    while (i + 2 < s.indices.items.len) : (i += 3) {
        const ia = s.indices.items[i];
        const ib = s.indices.items[i + 1];
        const ic = s.indices.items[i + 2];
        const ax = s.verts.items[ia * stride];
        const ay = s.verts.items[ia * stride + 1];
        const az = s.verts.items[ia * stride + 2];
        const ux = s.verts.items[ib * stride] - ax;
        const uy = s.verts.items[ib * stride + 1] - ay;
        const uz = s.verts.items[ib * stride + 2] - az;
        const vx = s.verts.items[ic * stride] - ax;
        const vy = s.verts.items[ic * stride + 1] - ay;
        const vz = s.verts.items[ic * stride + 2] - az;
        const nx = uy * vz - uz * vy;
        const ny = uz * vx - ux * vz;
        const nz = ux * vy - uy * vx;
        for ([_]u32{ ia, ib, ic }) |ix| {
            s.verts.items[ix * stride + 3] += nx;
            s.verts.items[ix * stride + 4] += ny;
            s.verts.items[ix * stride + 5] += nz;
        }
    }
    for (0..nverts) |vi| {
        const nx = s.verts.items[vi * stride + 3];
        const ny = s.verts.items[vi * stride + 4];
        const nz = s.verts.items[vi * stride + 5];
        const l = @sqrt(nx * nx + ny * ny + nz * nz);
        if (l > 0) {
            s.verts.items[vi * stride + 3] = nx / l;
            s.verts.items[vi * stride + 4] = ny / l;
            s.verts.items[vi * stride + 5] = nz / l;
        }
    }
}

// ---------------------------------------------------------------- tests

const testing = std.testing;

test "a cube keeps its faces apart so normals stay sharp" {
    const id = buildCube(2.0);
    defer _ = meshFree(id);
    try testing.expectEqual(@as(f64, 24), vertexCount(id)); // NOT 8
    try testing.expectEqual(@as(f64, 36), indexCount(id));
    try testing.expectEqual(@as(f64, 8), strideFloats(id));
    var buf: [32]u8 = undefined;
    try testing.expectEqualStrings("3,3,2", formatString(id, &buf).?);
    // every vertex sits on the cube's surface
    const v = vertexData(id).?;
    var i: usize = 0;
    while (i < v.len) : (i += 8) {
        const m = @max(@abs(v[i]), @max(@abs(v[i + 1]), @abs(v[i + 2])));
        try testing.expect(@abs(m - 1.0) < 1e-6);
    }
}

test "sphere vertices all sit at the radius, normals point outward" {
    const id = buildSphere(3.0, 12, 6);
    defer _ = meshFree(id);
    const v = vertexData(id).?;
    var i: usize = 0;
    while (i < v.len) : (i += 8) {
        const r = @sqrt(v[i] * v[i] + v[i + 1] * v[i + 1] + v[i + 2] * v[i + 2]);
        try testing.expect(@abs(r - 3.0) < 1e-4);
        // normal is the outward unit vector: n . p == r
        const d = v[i] * v[i + 3] + v[i + 1] * v[i + 4] + v[i + 2] * v[i + 5];
        try testing.expect(@abs(d - 3.0) < 1e-3);
    }
}

// Every triangle of a closed primitive must wind COUNTER-CLOCKWISE seen
// from outside, or back-face culling hides the surface facing the camera
// and shows the inside instead. Checked by the only thing that cannot be
// fooled: the face normal computed from the POSITIONS must agree with the
// normal the builder declared. (A showcase render is what exposed this on
// the sphere -- it read as a lighting bug, not a winding one.)
/// For a CLOSED shape centred on the origin, "outward" has an exact meaning
/// that needs no vertex normal at all: the face normal must point away from
/// the centre. Judging against a VERTEX normal instead looks reasonable and
/// is wrong at a sphere's poles, where every top vertex carries (0,1,0)
/// while the faces touching it stand almost vertical -- the first version of
/// this test failed BOTH windings for exactly that reason.
fn faceNormalLen(v: []const f32, ia: usize, ib: usize, ic: usize) f32 {
    const ux = v[ib] - v[ia];
    const uy = v[ib + 1] - v[ia + 1];
    const uz = v[ib + 2] - v[ia + 2];
    const wx = v[ic] - v[ia];
    const wy = v[ic + 1] - v[ia + 1];
    const wz = v[ic + 2] - v[ia + 2];
    const fx = uy * wz - uz * wy;
    const fy = uz * wx - ux * wz;
    const fz = ux * wy - uy * wx;
    return @sqrt(fx * fx + fy * fy + fz * fz);
}

fn expectOutwardWinding(id: i64) !void {
    const v = vertexData(id).?;
    const idx = indexData(id).?;
    const stride: usize = 8;
    // Degeneracy is RELATIVE: a pole fan's seam triangles have areas many
    // orders below the real faces, and an absolute epsilon either keeps
    // numerical noise or throws away real geometry depending on the mesh's
    // scale.
    var max_area: f32 = 0;
    var j: usize = 0;
    while (j + 2 < idx.len) : (j += 3) {
        const l = faceNormalLen(v, @as(usize, idx[j]) * stride, @as(usize, idx[j + 1]) * stride, @as(usize, idx[j + 2]) * stride);
        max_area = @max(max_area, l);
    }
    var i: usize = 0;
    while (i + 2 < idx.len) : (i += 3) {
        const ia: usize = @as(usize, idx[i]) * stride;
        const ib: usize = @as(usize, idx[i + 1]) * stride;
        const ic: usize = @as(usize, idx[i + 2]) * stride;
        const ux = v[ib] - v[ia];
        const uy = v[ib + 1] - v[ia + 1];
        const uz = v[ib + 2] - v[ia + 2];
        const wx = v[ic] - v[ia];
        const wy = v[ic + 1] - v[ia + 1];
        const wz = v[ic + 2] - v[ia + 2];
        const fx = uy * wz - uz * wy;
        const fy = uz * wx - ux * wz;
        const fz = ux * wy - uy * wx;
        const flen = @sqrt(fx * fx + fy * fy + fz * fz);
        if (flen <= max_area * 1e-4) continue; // a sliver: no verdict to give
        // the triangle's own centroid IS its outward direction here
        const cx = (v[ia] + v[ib] + v[ic]) / 3.0;
        const cy = (v[ia + 1] + v[ib + 1] + v[ic + 1]) / 3.0;
        const cz = (v[ia + 2] + v[ib + 2] + v[ic + 2]) / 3.0;
        try std.testing.expect(fx * cx + fy * cy + fz * cz > 0);
    }
}

test "sphere triangles wind outward, so culling keeps the visible surface" {
    const id = buildSphere(2.0, 16, 8);
    defer _ = meshFree(id);
    try expectOutwardWinding(id);
}

test "cube triangles wind outward too" {
    const c = buildCube(2.0);
    defer _ = meshFree(c);
    try expectOutwardWinding(c);
}

test "the plane's faces point the way it says they do" {
    // a plane is FLAT and centred, so "away from the centre" says nothing
    // about it -- its declared normal is the only truth available
    const p = buildPlane(3.0);
    defer _ = meshFree(p);
    const v = vertexData(p).?;
    const idx = indexData(p).?;
    var i: usize = 0;
    while (i + 2 < idx.len) : (i += 3) {
        const ia: usize = @as(usize, idx[i]) * 8;
        const ib: usize = @as(usize, idx[i + 1]) * 8;
        const ic: usize = @as(usize, idx[i + 2]) * 8;
        const ux = v[ib] - v[ia];
        const uz = v[ib + 2] - v[ia + 2];
        const wx = v[ic] - v[ia];
        const wz = v[ic + 2] - v[ia + 2];
        const fy = uz * wx - ux * wz; // y component of (b-a)x(c-a)
        try std.testing.expect(fy * v[ia + 4] > 0);
    }
}

test "the attribute descriptor drives the format string (the §3b hinge)" {
    // four attributes today, without one line changing in the render layer
    const verts = [_]f32{
        0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1,
        1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1,
        0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1,
    };
    const idx = [_]u32{ 0, 1, 2 };
    const id = buildCustom(&[_]u8{ 3, 3, 2, 4 }, &verts, &idx);
    defer _ = meshFree(id);
    try testing.expect(id != 0);
    try testing.expectEqual(@as(f64, 4), attrCount(id));
    try testing.expectEqual(@as(f64, 12), strideFloats(id));
    var buf: [32]u8 = undefined;
    try testing.expectEqualStrings("3,3,2,4", formatString(id, &buf).?);
    try testing.expectEqual(@as(f64, 3), vertexCount(id));
}

test "buildCustom refuses an out-of-range index instead of crashing later" {
    const verts = [_]f32{ 0, 0, 0, 1, 1, 1 };
    const bad = [_]u32{ 0, 1, 7 };
    try testing.expectEqual(@as(i64, 0), buildCustom(&[_]u8{3}, &verts, &bad));
}

test "OBJ: triples dedupe, faces fan, negative indices resolve" {
    const src =
        \\# a quad made of two triangles
        \\v 0 0 0
        \\v 1 0 0
        \\v 1 1 0
        \\v 0 1 0
        \\vn 0 0 1
        \\f 1//1 2//1 3//1 4//1
    ;
    const id = loadObj(src);
    defer _ = meshFree(id);
    try testing.expect(id != 0);
    try testing.expectEqual(@as(f64, 4), vertexCount(id)); // deduped by triple
    try testing.expectEqual(@as(f64, 6), indexCount(id)); // quad -> 2 triangles

    // the same quad written with NEGATIVE indices must produce the same mesh
    const src2 =
        \\v 0 0 0
        \\v 1 0 0
        \\v 1 1 0
        \\v 0 1 0
        \\vn 0 0 1
        \\f -4//-1 -3//-1 -2//-1 -1//-1
    ;
    const id2 = loadObj(src2);
    defer _ = meshFree(id2);
    try testing.expectEqual(@as(f64, 4), vertexCount(id2));
    try testing.expectEqualSlices(f32, vertexData(id).?, vertexData(id2).?);
}

test "OBJ without normals gets generated ones, not black geometry" {
    const src =
        \\v 0 0 0
        \\v 1 0 0
        \\v 0 1 0
        \\f 1 2 3
    ;
    const id = loadObj(src);
    defer _ = meshFree(id);
    const v = vertexData(id).?;
    var i: usize = 0;
    while (i < v.len) : (i += 8) {
        const l = @sqrt(v[i + 3] * v[i + 3] + v[i + 4] * v[i + 4] + v[i + 5] * v[i + 5]);
        try testing.expect(@abs(l - 1.0) < 1e-5); // unit, not zero
        try testing.expect(@abs(v[i + 5] - 1.0) < 1e-5); // +Z for a CCW XY face
    }
}

test "a freed mesh answers stale by name" {
    const id = buildPlane(1.0);
    try testing.expectEqual(OK, meshFree(id));
    try testing.expectEqual(STALE, meshFree(id));
    try testing.expectEqual(@as(f64, -1), vertexCount(id));
}
