//! f32 graphics math -- GR3 of SOFTANZA_GRAPHICS_PLAN.md.
//!
//! Vectors, 4x4 matrices, quaternions and cameras, in f32, DELIBERATELY
//! apart from the f64 solver tier (linalg/matrix). That separation is a
//! decision, not an oversight: the oracle tier's bit-stability is
//! contractual -- we refused to re-associate additions in cholesky() -- and
//! graphics wants speed and WGSL-shaped f32 layouts. Nothing here may be
//! reached for by the numeric tier, and nothing here imports it.
//!
//! Layout contract: **column-major**, matching WGSL's `mat4x4<f32>` exactly,
//! so a Mat4 is memcpy'd into a storage buffer and used as-is. Element
//! (row r, column c) lives at m[c*4 + r]. Vectors are columns; the product
//! is `M * v`, as in the shaders.
//!
//! Depth convention: **WebGPU's**, clip z in [0, 1] (not OpenGL's [-1, 1]),
//! right-handed eye space looking down -Z. `perspective` maps -near to 0 and
//! -far to 1; the unit tests assert exactly that rather than trusting the
//! formula's provenance.

const std = @import("std");

pub const Vec3 = struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,

    pub fn new(x: f32, y: f32, z: f32) Vec3 {
        return .{ .x = x, .y = y, .z = z };
    }

    pub fn add(a: Vec3, b: Vec3) Vec3 {
        return .{ .x = a.x + b.x, .y = a.y + b.y, .z = a.z + b.z };
    }

    pub fn sub(a: Vec3, b: Vec3) Vec3 {
        return .{ .x = a.x - b.x, .y = a.y - b.y, .z = a.z - b.z };
    }

    pub fn scale(a: Vec3, s: f32) Vec3 {
        return .{ .x = a.x * s, .y = a.y * s, .z = a.z * s };
    }

    pub fn dot(a: Vec3, b: Vec3) f32 {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }

    pub fn cross(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.y * b.z - a.z * b.y,
            .y = a.z * b.x - a.x * b.z,
            .z = a.x * b.y - a.y * b.x,
        };
    }

    pub fn length(a: Vec3) f32 {
        return @sqrt(a.dot(a));
    }

    pub fn normalize(a: Vec3) Vec3 {
        const l = a.length();
        if (l == 0) return a;
        return a.scale(1.0 / l);
    }
};

/// Column-major 4x4. m[c*4 + r] is (row r, column c) -- the WGSL layout.
pub const Mat4 = struct {
    m: [16]f32,

    pub fn identity() Mat4 {
        var r = Mat4{ .m = @splat(0) };
        r.m[0] = 1;
        r.m[5] = 1;
        r.m[10] = 1;
        r.m[15] = 1;
        return r;
    }

    pub fn at(self: Mat4, row: usize, col: usize) f32 {
        return self.m[col * 4 + row];
    }

    pub fn translation(t: Vec3) Mat4 {
        var r = identity();
        r.m[12] = t.x;
        r.m[13] = t.y;
        r.m[14] = t.z;
        return r;
    }

    pub fn scaling(s: Vec3) Mat4 {
        var r = Mat4{ .m = @splat(0) };
        r.m[0] = s.x;
        r.m[5] = s.y;
        r.m[10] = s.z;
        r.m[15] = 1;
        return r;
    }

    /// C = A * B (apply B first, then A -- the usual reading).
    pub fn mul(a: Mat4, b: Mat4) Mat4 {
        var r = Mat4{ .m = @splat(0) };
        for (0..4) |col| {
            for (0..4) |row| {
                var sum: f32 = 0;
                for (0..4) |k| sum += a.m[k * 4 + row] * b.m[col * 4 + k];
                r.m[col * 4 + row] = sum;
            }
        }
        return r;
    }

    /// Transform a POINT (w = 1), perspective divide NOT applied.
    pub fn mulPoint(a: Mat4, v: Vec3) Vec3 {
        return .{
            .x = a.m[0] * v.x + a.m[4] * v.y + a.m[8] * v.z + a.m[12],
            .y = a.m[1] * v.x + a.m[5] * v.y + a.m[9] * v.z + a.m[13],
            .z = a.m[2] * v.x + a.m[6] * v.y + a.m[10] * v.z + a.m[14],
        };
    }

    /// Transform a POINT and return the full homogeneous 4-vector -- the
    /// only honest way to inspect a projection (w carries the divide).
    pub fn mulPoint4(a: Mat4, v: Vec3) [4]f32 {
        return .{
            a.m[0] * v.x + a.m[4] * v.y + a.m[8] * v.z + a.m[12],
            a.m[1] * v.x + a.m[5] * v.y + a.m[9] * v.z + a.m[13],
            a.m[2] * v.x + a.m[6] * v.y + a.m[10] * v.z + a.m[14],
            a.m[3] * v.x + a.m[7] * v.y + a.m[11] * v.z + a.m[15],
        };
    }

    /// Transform a DIRECTION (w = 0): translation must not apply.
    pub fn mulDir(a: Mat4, v: Vec3) Vec3 {
        return .{
            .x = a.m[0] * v.x + a.m[4] * v.y + a.m[8] * v.z,
            .y = a.m[1] * v.x + a.m[5] * v.y + a.m[9] * v.z,
            .z = a.m[2] * v.x + a.m[6] * v.y + a.m[10] * v.z,
        };
    }

    pub fn transpose(a: Mat4) Mat4 {
        var r = Mat4{ .m = @splat(0) };
        for (0..4) |col| {
            for (0..4) |row| r.m[row * 4 + col] = a.m[col * 4 + row];
        }
        return r;
    }

    /// Right-handed view matrix. Eye maps to the origin; the camera looks
    /// down -Z in the space it produces.
    pub fn lookAt(eye: Vec3, target: Vec3, up: Vec3) Mat4 {
        const zaxis = eye.sub(target).normalize(); // backward
        const xaxis = up.cross(zaxis).normalize(); // right
        const yaxis = zaxis.cross(xaxis); // true up
        var r = Mat4{ .m = @splat(0) };
        r.m[0] = xaxis.x;
        r.m[4] = xaxis.y;
        r.m[8] = xaxis.z;
        r.m[1] = yaxis.x;
        r.m[5] = yaxis.y;
        r.m[9] = yaxis.z;
        r.m[2] = zaxis.x;
        r.m[6] = zaxis.y;
        r.m[10] = zaxis.z;
        r.m[12] = -xaxis.dot(eye);
        r.m[13] = -yaxis.dot(eye);
        r.m[14] = -zaxis.dot(eye);
        r.m[15] = 1;
        return r;
    }

    /// Right-handed perspective with WebGPU's [0, 1] clip depth.
    pub fn perspective(fovy_rad: f32, aspect: f32, near: f32, far: f32) Mat4 {
        const f = 1.0 / @tan(fovy_rad * 0.5);
        var r = Mat4{ .m = @splat(0) };
        r.m[0] = f / aspect;
        r.m[5] = f;
        r.m[10] = far / (near - far);
        r.m[11] = -1;
        r.m[14] = (far * near) / (near - far);
        return r;
    }

    /// Right-handed orthographic with WebGPU's [0, 1] clip depth.
    pub fn ortho(l: f32, rgt: f32, bot: f32, top: f32, near: f32, far: f32) Mat4 {
        var r = identity();
        r.m[0] = 2.0 / (rgt - l);
        r.m[5] = 2.0 / (top - bot);
        r.m[10] = 1.0 / (near - far);
        r.m[12] = -(rgt + l) / (rgt - l);
        r.m[13] = -(top + bot) / (top - bot);
        r.m[14] = near / (near - far);
        return r;
    }

    /// The NORMAL matrix: inverse transpose of the upper-left 3x3, so
    /// normals survive NON-UNIFORM scale. (Under rigid motion this equals
    /// the model matrix, which is exactly why passing the model matrix
    /// "works" right up until someone scales one axis.) Returns identity
    /// rotation when the 3x3 is singular -- a degenerate transform gets a
    /// defined answer instead of NaNs across the frame.
    pub fn normalMatrix(a: Mat4) Mat4 {
        const a00 = a.m[0];
        const a01 = a.m[4];
        const a02 = a.m[8];
        const a10 = a.m[1];
        const a11 = a.m[5];
        const a12 = a.m[9];
        const a20 = a.m[2];
        const a21 = a.m[6];
        const a22 = a.m[10];

        const c00 = a11 * a22 - a12 * a21;
        const c01 = a12 * a20 - a10 * a22;
        const c02 = a10 * a21 - a11 * a20;
        const det = a00 * c00 + a01 * c01 + a02 * c02;
        if (@abs(det) < 1e-20) return identity();
        const inv_det = 1.0 / det;

        // inverse = adj/det ; we want (inverse)^T, so write cofactors
        // straight into the transposed slots
        var r = Mat4{ .m = @splat(0) };
        r.m[0] = c00 * inv_det;
        r.m[4] = c01 * inv_det;
        r.m[8] = c02 * inv_det;
        r.m[1] = (a02 * a21 - a01 * a22) * inv_det;
        r.m[5] = (a00 * a22 - a02 * a20) * inv_det;
        r.m[9] = (a01 * a20 - a00 * a21) * inv_det;
        r.m[2] = (a01 * a12 - a02 * a11) * inv_det;
        r.m[6] = (a02 * a10 - a00 * a12) * inv_det;
        r.m[10] = (a00 * a11 - a01 * a10) * inv_det;
        r.m[15] = 1;
        return r;
    }
};

/// Unit quaternion rotation. Cheaper to compose and interpolate than a
/// matrix, and it cannot shear -- which is why transform state stores one
/// (the §3b door: a simulation writes rotations without touching meshes).
pub const Quat = struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,
    w: f32 = 1,

    pub fn identity() Quat {
        return .{};
    }

    pub fn fromAxisAngle(axis: Vec3, angle_rad: f32) Quat {
        const n = axis.normalize();
        const h = angle_rad * 0.5;
        const s = @sin(h);
        return .{ .x = n.x * s, .y = n.y * s, .z = n.z * s, .w = @cos(h) };
    }

    /// a * b = "apply b, then a", matching matrix composition order.
    pub fn mul(a: Quat, b: Quat) Quat {
        return .{
            .x = a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
            .y = a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
            .z = a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
            .w = a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z,
        };
    }

    pub fn normalize(q: Quat) Quat {
        const l = @sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w);
        if (l == 0) return identity();
        return .{ .x = q.x / l, .y = q.y / l, .z = q.z / l, .w = q.w / l };
    }

    pub fn toMat4(q0: Quat) Mat4 {
        const q = q0.normalize();
        const xx = q.x * q.x;
        const yy = q.y * q.y;
        const zz = q.z * q.z;
        const xy = q.x * q.y;
        const xz = q.x * q.z;
        const yz = q.y * q.z;
        const wx = q.w * q.x;
        const wy = q.w * q.y;
        const wz = q.w * q.z;
        var r = Mat4.identity();
        r.m[0] = 1 - 2 * (yy + zz);
        r.m[1] = 2 * (xy + wz);
        r.m[2] = 2 * (xz - wy);
        r.m[4] = 2 * (xy - wz);
        r.m[5] = 1 - 2 * (xx + zz);
        r.m[6] = 2 * (yz + wx);
        r.m[8] = 2 * (xz + wy);
        r.m[9] = 2 * (yz - wx);
        r.m[10] = 1 - 2 * (xx + yy);
        return r;
    }
};

/// Position + rotation + scale, kept as DATA. This is the §3b door: a
/// physics or animation step writes these and nothing else; meshes,
/// materials and pipelines never hear about it. `toMat4` is the only place
/// the two worlds meet.
pub const Transform = struct {
    position: Vec3 = .{},
    rotation: Quat = .{},
    scale: Vec3 = .{ .x = 1, .y = 1, .z = 1 },

    pub fn toMat4(self: Transform) Mat4 {
        const s = Mat4.scaling(self.scale);
        const r = self.rotation.toMat4();
        const t = Mat4.translation(self.position);
        return t.mul(r.mul(s)); // scale, then rotate, then translate
    }
};

pub const Camera = struct {
    eye: Vec3 = .{ .x = 0, .y = 0, .z = 5 },
    target: Vec3 = .{},
    up: Vec3 = .{ .x = 0, .y = 1, .z = 0 },
    fovy_rad: f32 = std.math.pi / 4.0,
    near: f32 = 0.1,
    far: f32 = 100.0,

    pub fn view(self: Camera) Mat4 {
        return Mat4.lookAt(self.eye, self.target, self.up);
    }

    pub fn projection(self: Camera, aspect: f32) Mat4 {
        return Mat4.perspective(self.fovy_rad, aspect, self.near, self.far);
    }

    pub fn viewProjection(self: Camera, aspect: f32) Mat4 {
        return self.projection(aspect).mul(self.view());
    }
};

// ---------------------------------------------------------------- tests
// The math is asserted here, ANALYTICALLY, rather than through rendered
// pixels: a picture can look right with a subtly wrong matrix, and these
// identities cannot.

const testing = std.testing;

fn expectNear(a: f32, b: f32, tol: f32) !void {
    try testing.expect(@abs(a - b) <= tol);
}

test "identity is the multiplicative identity" {
    const t = Mat4.translation(Vec3.new(3, -4, 5)).mul(Quat.fromAxisAngle(Vec3.new(1, 2, 3), 0.7).toMat4());
    const r = t.mul(Mat4.identity());
    for (t.m, r.m) |x, y| try expectNear(x, y, 1e-6);
}

test "lookAt sends the eye to the origin and the target down -Z" {
    const eye = Vec3.new(4, 3, 10);
    const target = Vec3.new(-1, 2, 0);
    const v = Mat4.lookAt(eye, target, Vec3.new(0, 1, 0));
    const o = v.mulPoint(eye);
    try expectNear(o.x, 0, 1e-4);
    try expectNear(o.y, 0, 1e-4);
    try expectNear(o.z, 0, 1e-4);
    const t = v.mulPoint(target);
    try expectNear(t.x, 0, 1e-4);
    try expectNear(t.y, 0, 1e-4);
    try testing.expect(t.z < 0); // in front of the camera
    try expectNear(t.z, -target.sub(eye).length(), 1e-3); // distance preserved
}

test "perspective maps near to 0 and far to 1 (WebGPU depth, not OpenGL)" {
    const near: f32 = 0.5;
    const far: f32 = 40.0;
    const p = Mat4.perspective(std.math.pi / 3.0, 16.0 / 9.0, near, far);
    const at_near = p.mulPoint4(Vec3.new(0, 0, -near));
    try expectNear(at_near[2] / at_near[3], 0, 1e-5);
    const at_far = p.mulPoint4(Vec3.new(0, 0, -far));
    try expectNear(at_far[2] / at_far[3], 1, 1e-5);
    // and the divide is a real perspective one: w = -z_eye
    try expectNear(at_far[3], far, 1e-3);
}

test "quaternion composition equals matrix composition" {
    const a = Quat.fromAxisAngle(Vec3.new(0, 1, 0), 0.9);
    const b = Quat.fromAxisAngle(Vec3.new(1, 0.3, 0.2), -0.4);
    const by_quat = a.mul(b).toMat4();
    const by_mat = a.toMat4().mul(b.toMat4());
    for (by_quat.m, by_mat.m) |x, y| try expectNear(x, y, 1e-5);
}

test "a rotation matrix is orthonormal and preserves length" {
    const q = Quat.fromAxisAngle(Vec3.new(0.3, -0.7, 0.5), 1.9);
    const m = q.toMat4();
    const v = Vec3.new(2, -3, 6);
    try expectNear(m.mulDir(v).length(), v.length(), 1e-4);
    const x = m.mulDir(Vec3.new(1, 0, 0));
    const y = m.mulDir(Vec3.new(0, 1, 0));
    try expectNear(x.dot(y), 0, 1e-5);
}

test "direction transform ignores translation, point transform does not" {
    const m = Mat4.translation(Vec3.new(10, 20, 30));
    const d = m.mulDir(Vec3.new(1, 0, 0));
    try expectNear(d.x, 1, 1e-6);
    try expectNear(d.y, 0, 1e-6);
    const p = m.mulPoint(Vec3.new(1, 0, 0));
    try expectNear(p.x, 11, 1e-6);
    try expectNear(p.y, 20, 1e-6);
}

test "the normal matrix keeps normals perpendicular under NON-UNIFORM scale" {
    // the case where using the model matrix for normals silently fails
    const model = Mat4.scaling(Vec3.new(4, 1, 1));
    const nrm = Mat4.normalMatrix(model);
    // a 45-degree surface: tangent (1,1,0), normal (1,-1,0)
    const tangent = Vec3.new(1, 1, 0);
    const normal = Vec3.new(1, -1, 0);
    const t2 = model.mulDir(tangent); // tangents ride the MODEL matrix
    const n2 = nrm.mulDir(normal).normalize();
    try expectNear(n2.dot(t2.normalize()), 0, 1e-5);
    // and the naive choice really is wrong -- the negative sibling
    const naive = model.mulDir(normal).normalize();
    try testing.expect(@abs(naive.dot(t2.normalize())) > 0.4);
}

test "Transform composes scale, then rotation, then translation" {
    var tr = Transform{};
    tr.position = Vec3.new(5, 0, 0);
    tr.scale = Vec3.new(2, 2, 2);
    tr.rotation = Quat.fromAxisAngle(Vec3.new(0, 0, 1), std.math.pi / 2.0);
    const p = tr.toMat4().mulPoint(Vec3.new(1, 0, 0));
    // scaled to (2,0,0), rotated 90deg about Z to (0,2,0), moved to (5,2,0)
    try expectNear(p.x, 5, 1e-4);
    try expectNear(p.y, 2, 1e-4);
    try expectNear(p.z, 0, 1e-4);
}

test "the camera's viewProjection is projection * view, in that order" {
    const cam = Camera{ .eye = Vec3.new(0, 0, 6), .target = Vec3{}, .fovy_rad = 1.0, .near = 0.1, .far = 50 };
    const vp = cam.viewProjection(1.5);
    const manual = cam.projection(1.5).mul(cam.view());
    for (vp.m, manual.m) |x, y| try expectNear(x, y, 1e-6);
    // the origin sits at the centre of the screen
    const c = vp.mulPoint4(Vec3{});
    try expectNear(c[0] / c[3], 0, 1e-5);
    try expectNear(c[1] / c[3], 0, 1e-5);
}
