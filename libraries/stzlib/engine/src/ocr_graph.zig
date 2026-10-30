//! OCR GRAPHS ON GGML -- a PP-OCR network (detector, recogniser, angle classifier) converted by
//! tools/onnx_to_gguf.py into a GGUF file that carries its weights and a PROGRAM: one line per op over
//! a small op set that maps one-to-one onto ggml. This module loads such a file, builds the ggml graph
//! for a given input shape (the detector's input size varies with the page, the recogniser's with the
//! line), computes it on the CPU backend through the graph allocator (intermediate buffers are reused),
//! and hands the output tensor back.
//!
//! The program grammar (written by the converter, read here):
//!
//!     out=op(in1,in2;key=v1,v2;...;r=<rank of out in ONNX terms>)
//!
//! Tensors are ggml's: ne[0] is the contiguous dim, so an ONNX [N,C,H,W] is ne = [W,H,C,N] in the same
//! memory, and every ONNX axis j of a rank-r tensor is ggml dim r-1-j. The converter already wrote the
//! kernels in the layout ggml's conv ops read, and the `linear` weights transposed for ggml_mul_mat.
//!
//! The first proof of this module is PARITY against onnxruntime on fixed inputs (ocrParity below, driven
//! by base/test/ocr/ocr_model_parity_narrated.ring), before any OCR text is read through it.

const std = @import("std");
pub const c = @cImport({
    @cInclude("ggml.h");
    @cInclude("ggml-cpu.h");
    @cInclude("ggml-alloc.h");
    @cInclude("ggml-backend.h");
    @cInclude("gguf.h");
});

const gpa = std.heap.c_allocator;

const MAX_NODES: usize = 16384;

// STZ_OCR_TRACE=1 in the environment prints each op as the graph is built and each phase of the run (stderr)
fn tracing() bool {
    return std.process.hasNonEmptyEnvVarConstant("STZ_OCR_TRACE");
}

// STZ_OCR_PROFILE=1 computes the graph ONE NODE AT A TIME and prints, per ggml op, its count and its time
// (stderr), then the slowest nodes with their shapes. The sum is a little above a normal run (each node
// starts and joins the thread pool), so read the SHARES, not the total.
fn profiling() bool {
    return std.process.hasNonEmptyEnvVarConstant("STZ_OCR_PROFILE");
}

// ggml's struct ggml_cgraph (ggml-impl.h), which ggml.h keeps opaque: a one-node view of the graph is built
// the way ggml_graph_view builds it
const HashSet = extern struct { size: usize, used: ?*anyopaque, keys: ?*anyopaque };
const CGraph = extern struct {
    size: c_int,
    n_nodes: c_int,
    n_leafs: c_int,
    nodes: [*]*c.ggml_tensor,
    grads: ?*anyopaque,
    grad_accs: ?*anyopaque,
    leafs: ?*anyopaque,
    use_counts: ?*i32,
    visited_hash_set: HashSet,
    order: c_int,
    uid: u64,
};

// how many of a float tensor's values are subnormal (a value so small the CPU computes with it in microcode)
fn subnormals(t: *c.ggml_tensor) usize {
    if (t.type != c.GGML_TYPE_F32 or t.data == null or !c.ggml_is_contiguous(t)) return 0;
    const n: usize = @intCast(c.ggml_nelements(t));
    const d: [*]const u32 = @ptrCast(@alignCast(t.data));
    var k: usize = 0;
    for (0..n) |i| {
        // subnormal, or so small (below 2^-100) that a product with a weight lands in the subnormal range
        const e = (d[i] >> 23) & 0xff;
        if (e < 27 and (d[i] & 0x7fffffff) != 0) k += 1;
    }
    return k;
}

// the process's page-fault count (Windows; 0 elsewhere), so a node's cold-memory cost can be named
const PMC = extern struct {
    cb: u32,
    PageFaultCount: u32,
    PeakWorkingSetSize: usize,
    WorkingSetSize: usize,
    QuotaPeakPagedPoolUsage: usize,
    QuotaPagedPoolUsage: usize,
    QuotaPeakNonPagedPoolUsage: usize,
    QuotaNonPagedPoolUsage: usize,
    PagefileUsage: usize,
    PeakPagefileUsage: usize,
};
extern "kernel32" fn K32GetProcessMemoryInfo(h: ?*anyopaque, pmc: *PMC, cb: u32) callconv(.winapi) c_int;
extern "kernel32" fn GetCurrentProcess() callconv(.winapi) ?*anyopaque;
extern "kernel32" fn GetProcessWorkingSetSizeEx(h: ?*anyopaque, mn: *usize, mx: *usize, flags: *u32) callconv(.winapi) c_int;
extern "kernel32" fn IsProcessInJob(h: ?*anyopaque, job: ?*anyopaque, result: *c_int) callconv(.winapi) c_int;
fn printMemory(tag: []const u8) void {
    if (@import("builtin").os.tag != .windows) return;
    var m: PMC = undefined;
    m.cb = @sizeOf(PMC);
    _ = K32GetProcessMemoryInfo(GetCurrentProcess(), &m, @sizeOf(PMC));
    var mn: usize = 0;
    var mx: usize = 0;
    var fl: u32 = 0;
    _ = GetProcessWorkingSetSizeEx(GetCurrentProcess(), &mn, &mx, &fl);
    var injob: c_int = 0;
    _ = IsProcessInJob(GetCurrentProcess(), null, &injob);
    std.debug.print("[ocr memory] {s}: working set {d} MB (peak {d} MB), private {d} MB, faults {d}; ws limits {d}..{d} MB flags {d}; in a job {d}" ++ "\n", .{ tag, m.WorkingSetSize >> 20, m.PeakWorkingSetSize >> 20, m.PagefileUsage >> 20, m.PageFaultCount, mn >> 20, mx >> 20, fl, injob });
}

fn pageFaults() u64 {
    if (@import("builtin").os.tag != .windows) return 0;
    var m: PMC = undefined;
    m.cb = @sizeOf(PMC);
    if (K32GetProcessMemoryInfo(GetCurrentProcess(), &m, @sizeOf(PMC)) == 0) return 0;
    return m.PageFaultCount;
}

fn profileCompute(graph: *c.ggml_cgraph, plan: *c.ggml_cplan) c.ggml_status {
    const g: *CGraph = @ptrCast(@alignCast(graph));
    const n: usize = @intCast(g.n_nodes);
    const Acc = struct { name: []const u8, n: usize, ns: u64 };
    var accs: [96]Acc = undefined;
    var n_acc: usize = 0;
    const Slow = struct { i: usize, ns: u64 };
    var slow: [12]Slow = [_]Slow{.{ .i = 0, .ns = 0 }} ** 12;
    var total: u64 = 0;
    for (0..n) |i| {
        var v = g.*;
        v.size = 0;
        v.n_nodes = 1;
        v.n_leafs = 0;
        v.nodes = g.nodes + i;
        v.grads = null;
        v.grad_accs = null;
        v.leafs = null;
        v.uid = 0;
        const f0 = pageFaults();
        const t0 = std.time.nanoTimestamp();
        const st = c.ggml_graph_compute(@ptrCast(&v), plan);
        const dt: u64 = @intCast(std.time.nanoTimestamp() - t0);
        const df = pageFaults() - f0;
        if (dt > 100_000_000 or df > 1000) std.debug.print("[ocr profile] node {d} {s}: {d:.1} ms, {d} page faults" ++ "\n", .{ i, std.mem.span(c.ggml_op_desc(g.nodes[i])), @as(f64, @floatFromInt(dt)) / 1e6, df });
        if (st != c.GGML_STATUS_SUCCESS) return st;
        total += dt;
        const node = g.nodes[i];
        const name = std.mem.span(c.ggml_op_desc(node));
        if (node.op == c.GGML_OP_MUL_MAT and std.process.hasNonEmptyEnvVarConstant("STZ_OCR_PROFILE_MM")) {
            const x: *c.ggml_tensor = node.src[0];
            const y: *c.ggml_tensor = node.src[1];
            const flop = 2.0 * @as(f64, @floatFromInt(x.ne[0])) * @as(f64, @floatFromInt(x.ne[1])) * @as(f64, @floatFromInt(y.ne[1] * y.ne[2] * y.ne[3]));
            std.debug.print("[ocr mm] node {d} K={d} M={d} N={d} {d:.2} ms {d:.2} GFLOP/s cont0={} cont1={}\n", .{ i, x.ne[0], x.ne[1], y.ne[1] * y.ne[2] * y.ne[3], @as(f64, @floatFromInt(dt)) / 1e6, flop / @as(f64, @floatFromInt(dt)), c.ggml_is_contiguous(x), c.ggml_is_contiguous(y) });
        }
        var k: usize = 0;
        while (k < n_acc and !std.mem.eql(u8, accs[k].name, name)) : (k += 1) {}
        if (k == n_acc and n_acc < accs.len) {
            accs[k] = .{ .name = name, .n = 0, .ns = 0 };
            n_acc += 1;
        }
        if (k < n_acc) {
            accs[k].n += 1;
            accs[k].ns += dt;
        }
        var m: usize = 0;
        for (slow, 0..) |s, j| {
            if (s.ns < slow[m].ns) m = j;
        }
        if (dt > slow[m].ns) slow[m] = .{ .i = i, .ns = dt };
    }
    std.sort.insertion(Acc, accs[0..n_acc], {}, struct {
        fn gt(_: void, a: Acc, b: Acc) bool {
            return a.ns > b.ns;
        }
    }.gt);
    std.debug.print("[ocr profile] {d} nodes, {d:.1} ms\n", .{ n, @as(f64, @floatFromInt(total)) / 1e6 });
    for (accs[0..n_acc]) |a| {
        std.debug.print("[ocr profile] {s:<18} x{d:<4} {d:>9.1} ms  {d:>5.1}%\n", .{ a.name, a.n, @as(f64, @floatFromInt(a.ns)) / 1e6, @as(f64, @floatFromInt(a.ns)) * 100.0 / @as(f64, @floatFromInt(total)) });
    }
    // the slowest node again: warm (same plan), then on one thread -- separates a cold-memory cost from the kernel's
    {
        var m: usize = 0;
        for (slow, 0..) |sl, j| {
            if (sl.ns > slow[m].ns) m = j;
        }
        var v = g.*;
        v.size = 0;
        v.n_nodes = 1;
        v.n_leafs = 0;
        v.nodes = g.nodes + slow[m].i;
        v.grads = null;
        v.grad_accs = null;
        v.leafs = null;
        v.uid = 0;
        const t0 = std.time.nanoTimestamp();
        _ = c.ggml_graph_compute(@ptrCast(&v), plan);
        const t1 = std.time.nanoTimestamp();
        var p1 = plan.*;
        p1.n_threads = 1;
        _ = c.ggml_graph_compute(@ptrCast(&v), &p1);
        const t2 = std.time.nanoTimestamp();
        std.debug.print("[ocr profile] node {d} again: {d:.1} ms on {d} threads, {d:.1} ms on 1\n", .{ slow[m].i, @as(f64, @floatFromInt(t1 - t0)) / 1e6, plan.n_threads, @as(f64, @floatFromInt(t2 - t1)) / 1e6 });
    }
    std.sort.insertion(Slow, &slow, {}, struct {
        fn gt(_: void, a: Slow, b: Slow) bool {
            return a.ns > b.ns;
        }
    }.gt);
    for (slow) |s| {
        if (s.ns == 0) continue;
        const t = g.nodes[s.i];
        const s0: ?*c.ggml_tensor = t.src[0];
        const s1: ?*c.ggml_tensor = t.src[1];
        std.debug.print("[ocr profile]   node {d} {s} {d:.1} ms  out [{d},{d},{d},{d}]", .{ s.i, std.mem.span(c.ggml_op_desc(t)), @as(f64, @floatFromInt(s.ns)) / 1e6, t.ne[0], t.ne[1], t.ne[2], t.ne[3] });
        if (s0) |x| std.debug.print("  src0 [{d},{d},{d},{d}] {s} tiny {d}", .{ x.ne[0], x.ne[1], x.ne[2], x.ne[3], c.ggml_type_name(x.type), subnormals(x) });
        if (s1) |x| std.debug.print("  src1 [{d},{d},{d},{d}] {s}", .{ x.ne[0], x.ne[1], x.ne[2], x.ne[3], c.ggml_type_name(x.type) });
        std.debug.print("\n", .{});
    }
    return c.GGML_STATUS_SUCCESS;
}

pub const Model = struct {
    arena: std.heap.ArenaAllocator,
    gguf: *c.gguf_context,
    wctx: *c.ggml_context,
    kind: []const u8,
    output: []const u8,
    output_rank: u32,
    lines: [][]const u8,

    pub fn free(m: *Model) void {
        c.ggml_free(m.wctx);
        c.gguf_free(m.gguf);
        m.arena.deinit();
        gpa.destroy(m);
    }
};

var last_error: [256]u8 = undefined;
var last_error_len: usize = 0;

pub fn clearError() void {
    last_error_len = 0;
}

pub fn setError(comptime fmt: []const u8, args: anytype) void {
    const s = std.fmt.bufPrint(&last_error, fmt, args) catch &last_error;
    last_error_len = s.len;
}

pub fn lastError() []const u8 {
    return last_error[0..last_error_len];
}

fn kvStr(g: *c.gguf_context, key: [*:0]const u8, a: std.mem.Allocator) ![]const u8 {
    const id = c.gguf_find_key(g, key);
    if (id < 0) return error.MissingKey;
    const p = c.gguf_get_val_str(g, id);
    return try a.dupe(u8, std.mem.span(p));
}

pub fn load(path: []const u8) !*Model {
    const m = try gpa.create(Model);
    errdefer gpa.destroy(m);
    m.arena = std.heap.ArenaAllocator.init(gpa);
    errdefer m.arena.deinit();
    const a = m.arena.allocator();
    const zpath = try a.dupeZ(u8, path);
    var wctx: ?*c.ggml_context = null;
    const params = c.gguf_init_params{ .no_alloc = false, .ctx = &wctx };
    const g = c.gguf_init_from_file(zpath.ptr, params) orelse {
        setError("the file could not be read as GGUF: {s}", .{path});
        return error.NotGguf;
    };
    errdefer c.gguf_free(g);
    m.gguf = g;
    m.wctx = wctx orelse return error.NoWeights;
    const arch = try kvStr(g, "general.architecture", a);
    if (!std.mem.eql(u8, arch, "stz-ocr-graph")) {
        setError("the GGUF is a {s}, not an stz-ocr-graph", .{arch});
        return error.WrongArchitecture;
    }
    m.kind = try kvStr(g, "stz.ocr.kind", a);
    m.output = try kvStr(g, "stz.ocr.output", a);
    const rid = c.gguf_find_key(g, "stz.ocr.output_rank");
    m.output_rank = if (rid >= 0) c.gguf_get_val_u32(g, rid) else 4;
    const pid = c.gguf_find_key(g, "stz.ocr.program");
    if (pid < 0) return error.NoProgram;
    const n: usize = @intCast(c.gguf_get_arr_n(g, pid));
    m.lines = try a.alloc([]const u8, n);
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const p = c.gguf_get_arr_str(g, pid, i);
        m.lines[i] = try a.dupe(u8, std.mem.span(p));
    }
    return m;
}

// ------------------------------------------------------------------------------------------------ the builder

const Builder = struct {
    m: *Model,
    ctx: *c.ggml_context,
    tensors: std.StringHashMap(*c.ggml_tensor),
    ranks: std.StringHashMap(u8),

    fn get(b: *Builder, name: []const u8) !*c.ggml_tensor {
        if (b.tensors.get(name)) |t| return t;
        if (name.len > 0 and name[0] == 'c') {
            const z = try gpa.dupeZ(u8, name);
            defer gpa.free(z);
            if (c.ggml_get_tensor(b.m.wctx, z.ptr)) |t| {
                try b.tensors.put(name, t);
                return t;
            }
        }
        setError("program reads {s} before it is produced", .{name});
        return error.UnknownTensor;
    }

    fn rankOf(b: *Builder, name: []const u8) u8 {
        return b.ranks.get(name) orelse 4;
    }
};

const Line = struct {
    out: []const u8,
    op: []const u8,
    inputs: [8][]const u8,
    n_in: usize,
    keys: [8][]const u8,
    vals: [8][]const u8,
    n_kv: usize,

    fn val(l: *const Line, key: []const u8) ?[]const u8 {
        var i: usize = 0;
        while (i < l.n_kv) : (i += 1) if (std.mem.eql(u8, l.keys[i], key)) return l.vals[i];
        return null;
    }
    fn int(l: *const Line, key: []const u8, idx: usize) !i64 {
        const v = l.val(key) orelse return error.MissingAttr;
        var it = std.mem.splitScalar(u8, v, ',');
        var i: usize = 0;
        while (it.next()) |s| : (i += 1) if (i == idx) return try std.fmt.parseInt(i64, s, 10);
        return error.MissingAttr;
    }
    fn flt(l: *const Line, key: []const u8) !f32 {
        const v = l.val(key) orelse return error.MissingAttr;
        return try std.fmt.parseFloat(f32, v);
    }
};

fn parse(s: []const u8) !Line {
    var l: Line = undefined;
    l.n_in = 0;
    l.n_kv = 0;
    const eq = std.mem.indexOfScalar(u8, s, '=') orelse return error.BadLine;
    l.out = s[0..eq];
    const op_end = std.mem.indexOfScalarPos(u8, s, eq + 1, '(') orelse return error.BadLine;
    l.op = s[eq + 1 .. op_end];
    if (s[s.len - 1] != ')') return error.BadLine;
    const body = s[op_end + 1 .. s.len - 1];
    var parts = std.mem.splitScalar(u8, body, ';');
    const ins = parts.next() orelse return error.BadLine;
    var it = std.mem.splitScalar(u8, ins, ',');
    while (it.next()) |x| {
        if (x.len == 0) continue;
        if (l.n_in >= l.inputs.len) return error.BadLine;
        l.inputs[l.n_in] = x;
        l.n_in += 1;
    }
    while (parts.next()) |kv| {
        const e = std.mem.indexOfScalar(u8, kv, '=') orelse return error.BadLine;
        if (l.n_kv >= l.keys.len) return error.BadLine;
        l.keys[l.n_kv] = kv[0..e];
        l.vals[l.n_kv] = kv[e + 1 ..];
        l.n_kv += 1;
    }
    return l;
}

fn is(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

fn contig(ctx: *c.ggml_context, t: *c.ggml_tensor) *c.ggml_tensor {
    if (c.ggml_is_contiguous(t)) return t;
    return c.ggml_cont(ctx, t);
}

// the dims of a reshape spec, ONNX order, resolved against the tensors already built
// The ONNX shape a reshape asks for, in ggml order. ggml has four dimensions; an ONNX rank-5 tensor is accepted
// when its OUTERMOST axis is 1 (PP-OCRv5 mobile wraps an identity scale in Unsqueeze(0) ... Squeeze(0)): that axis
// is kept in the rank bookkeeping and dropped from the memory, where it changes nothing.
fn reshapeDims(b: *Builder, l: *const Line, x: *c.ggml_tensor, out: *[4]i64) !usize {
    const spec = l.val("d") orelse return error.MissingAttr;
    var dims: [5]i64 = .{ 1, 1, 1, 1, 1 };
    var n: usize = 0;
    var it = std.mem.splitScalar(u8, spec, ',');
    while (it.next()) |item| : (n += 1) {
        if (n >= 5) return error.BadReshape;
        if (item.len > 0 and item[0] == '@') {
            const colon = std.mem.indexOfScalar(u8, item, ':') orelse return error.BadReshape;
            const tname = item[1..colon];
            const j: usize = try std.fmt.parseInt(usize, item[colon + 1 ..], 10);
            const t = try b.get(tname);
            const r: usize = b.rankOf(tname);
            if (j >= r) return error.BadReshape;
            // the hidden outer axis of a rank-5 tensor is 1
            dims[n] = if (r - 1 - j >= 4) 1 else t.ne[r - 1 - j];
        } else {
            dims[n] = try std.fmt.parseInt(i64, item, 10);
        }
    }
    // ggml order, -1 inferred
    var total: i64 = 1;
    var infer: ?usize = null;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        if (dims[i] == -1) {
            if (infer != null) return error.BadReshape;
            infer = i;
        } else total *= dims[i];
    }
    if (infer) |k| dims[k] = @divExact(c.ggml_nelements(x), total);
    var first: usize = 0;
    if (n == 5) {
        if (dims[0] != 1) {
            setError("a rank-5 reshape whose outer axis is {d}, not 1: ggml has four dimensions", .{dims[0]});
            return error.BadReshape;
        }
        first = 1;
    }
    i = 0;
    while (i < 4) : (i += 1) out[i] = 1;
    i = 0;
    while (i < n - first) : (i += 1) out[i] = dims[n - 1 - i];
    return n;
}

const IM2COL_DIRECT: i64 = 64 << 20;

fn useDirect(im2col_bytes: i64) bool {
    var buf: [16]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    if (std.process.getEnvVarOwned(fba.allocator(), "STZ_OCR_CONV")) |v| {
        if (std.mem.eql(u8, v, "direct")) return true;
        if (std.mem.eql(u8, v, "im2col")) return false;
    } else |_| {}
    return im2col_bytes > IM2COL_DIRECT;
}

fn build(b: *Builder, s: []const u8) !void {
    const ctx = b.ctx;
    const l = try parse(s);
    const op = l.op;
    var r: *c.ggml_tensor = undefined;
    const x = if (l.n_in > 0) try b.get(l.inputs[0]) else return error.BadLine;
    if (is(op, "conv")) {
        const w = try b.get(l.inputs[1]);
        const s0: c_int = @intCast(try l.int("s", 0));
        const s1: c_int = @intCast(try l.int("s", 1));
        const p0: c_int = @intCast(try l.int("p", 0));
        const p1: c_int = @intCast(try l.int("p", 1));
        const dw = try l.int("dw", 0);
        // (the im2col depthwise path wants an F16 kernel; the direct one reads F32 and a contiguous WHCN input)
        // A full convolution is im2col then one matrix product, and the im2col is MATERIALISED: OW x OH x K
        // floats. On a page that is hundreds of megabytes for one layer (the detector's head: 474 MB), and on
        // this machine reading it back cost 380,000 page faults and 4 s where a warm read is 48 ms. The direct
        // form runs the same im2col in tiles inside a 16 MB work buffer; it is used above IM2COL_DIRECT bytes.
        // STZ_OCR_CONV=im2col or =direct forces one form everywhere (for measuring).
        if (dw == 1) {
            r = c.ggml_conv_2d_dw_direct(ctx, w, contig(ctx, x), s0, s1, p0, p1, 1, 1);
        } else {
            const ow = @divTrunc(x.ne[0] + 2 * p0 - w.ne[0], s0) + 1;
            const oh = @divTrunc(x.ne[1] + 2 * p1 - w.ne[1], s1) + 1;
            const bytes = ow * oh * w.ne[0] * w.ne[1] * w.ne[2] * 4;
            r = if (useDirect(bytes)) c.ggml_conv_2d_direct(ctx, w, x, s0, s1, p0, p1, 1, 1) else c.ggml_conv_2d(ctx, w, x, s0, s1, p0, p1, 1, 1);
        }
    } else if (is(op, "convt")) {
        const w = try b.get(l.inputs[1]);
        r = c.ggml_conv_transpose_2d_p0(ctx, w, x, @intCast(try l.int("s", 0)));
    } else if (is(op, "pad")) {
        r = c.ggml_pad(ctx, x, @intCast(try l.int("r", 0)), @intCast(try l.int("b", 0)), 0, 0);
    } else if (is(op, "pool")) {
        const kind = l.val("kind") orelse return error.MissingAttr;
        const pop: c.ggml_op_pool = if (is(kind, "max")) c.GGML_OP_POOL_MAX else c.GGML_OP_POOL_AVG;
        r = c.ggml_pool_2d(ctx, x, pop, @intCast(try l.int("k", 0)), @intCast(try l.int("k", 1)), @intCast(try l.int("s", 0)), @intCast(try l.int("s", 1)), 0, 0);
    } else if (is(op, "gap")) {
        r = c.ggml_pool_2d(ctx, x, c.GGML_OP_POOL_AVG, @intCast(x.ne[0]), @intCast(x.ne[1]), @intCast(x.ne[0]), @intCast(x.ne[1]), 0, 0);
    } else if (is(op, "up")) {
        const f = try l.int("f", 0);
        r = c.ggml_interpolate(ctx, x, x.ne[0] * f, x.ne[1] * f, x.ne[2], x.ne[3], c.GGML_SCALE_MODE_NEAREST);
    } else if (is(op, "concat")) {
        const d: c_int = @intCast(try l.int("d", 0));
        r = x;
        var i: usize = 1;
        while (i < l.n_in) : (i += 1) r = c.ggml_concat(ctx, r, try b.get(l.inputs[i]), d);
    } else if (is(op, "add")) {
        r = c.ggml_add(ctx, x, try b.get(l.inputs[1]));
    } else if (is(op, "sub")) {
        r = c.ggml_sub(ctx, x, try b.get(l.inputs[1]));
    } else if (is(op, "mul")) {
        r = c.ggml_mul(ctx, x, try b.get(l.inputs[1]));
    } else if (is(op, "div")) {
        r = c.ggml_div(ctx, x, try b.get(l.inputs[1]));
    } else if (is(op, "sb")) {
        r = c.ggml_scale_bias(ctx, x, try l.flt("s"), try l.flt("b"));
    } else if (is(op, "clamp")) {
        r = c.ggml_clamp(ctx, x, try l.flt("lo"), try l.flt("hi"));
    } else if (is(op, "relu")) {
        r = c.ggml_relu(ctx, x);
    } else if (is(op, "sigmoid")) {
        r = c.ggml_sigmoid(ctx, x);
    } else if (is(op, "hswish")) {
        // ONNX HardSwish = x * max(0, min(1, x/6 + 1/2)); ggml_hardswish is the same function (the PP-OCRv5 mobile backbone)
        r = c.ggml_hardswish(ctx, contig(ctx, x));
    } else if (is(op, "gelu")) {
        r = c.ggml_gelu_erf(ctx, x);
    } else if (is(op, "sqr")) {
        r = c.ggml_sqr(ctx, x);
    } else if (is(op, "sqrt")) {
        r = c.ggml_sqrt(ctx, x);
    } else if (is(op, "mean")) {
        r = c.ggml_mean(ctx, contig(ctx, x));
    } else if (is(op, "softmax")) {
        r = c.ggml_soft_max(ctx, contig(ctx, x));
    } else if (is(op, "linear")) {
        r = c.ggml_mul_mat(ctx, try b.get(l.inputs[1]), contig(ctx, x));
    } else if (is(op, "matmul")) {
        const y = try b.get(l.inputs[1]);
        r = c.ggml_mul_mat(ctx, c.ggml_cont(ctx, c.ggml_transpose(ctx, y)), contig(ctx, x));
    } else if (is(op, "permute")) {
        const rank: usize = b.rankOf(l.inputs[0]);
        var ax: [4]c_int = .{ 0, 1, 2, 3 };
        var i: usize = 0;
        while (i < rank) : (i += 1) {
            const p: usize = @intCast(try l.int("p", i));
            ax[rank - 1 - p] = @intCast(rank - 1 - i);
        }
        r = c.ggml_cont(ctx, c.ggml_permute(ctx, x, ax[0], ax[1], ax[2], ax[3]));
    } else if (is(op, "reshape")) {
        var ne: [4]i64 = undefined;
        _ = try reshapeDims(b, &l, x, &ne);
        r = c.ggml_reshape_4d(ctx, contig(ctx, x), ne[0], ne[1], ne[2], ne[3]);
    } else if (is(op, "heads")) {
        // x is ONNX [1, N, 3*h*d]: head i of q (0), k (1) or v (2) as ONNX [1, h, N, d]
        const h = try l.int("h", 0);
        const d = try l.int("d", 0);
        const which = try l.int("i", 0);
        const xc = contig(ctx, x);
        if (xc.ne[2] != 1 or xc.ne[0] != 3 * h * d) {
            setError("heads: the input is not [1, N, 3*{d}*{d}]", .{ h, d });
            return error.BadHeads;
        }
        const n = xc.ne[1];
        const t: *c.ggml_tensor = c.ggml_reshape_4d(ctx, xc, d, h, 3, n) orelse return error.OutOfMemory;
        const v = c.ggml_view_3d(ctx, t, d, h, n, t.nb[1], t.nb[3], @as(usize, @intCast(which)) * t.nb[2]);
        r = c.ggml_cont(ctx, c.ggml_permute(ctx, v, 0, 2, 1, 3));
    } else {
        setError("op {s} is not one the runner knows", .{op});
        return error.UnknownOp;
    }
    try b.tensors.put(l.out, r);
    const rk = try l.int("r", 0);
    try b.ranks.put(l.out, @intCast(rk));
}

// ------------------------------------------------------------------------------------------------ running

pub const Output = struct {
    data: []f32, // owned by gpa; the caller frees
    ne: [4]i64, // ggml order
    rank: u32,
    ms: f64,
};

/// Runs the model on one input tensor given in ONNX order [N, C, H, W] (data NCHW, row-major).
pub fn run(m: *Model, input: []const f32, dims: [4]i64, n_threads: c_int) !Output {
    const t0 = std.time.nanoTimestamp();
    const ne_in: [4]i64 = .{ dims[3], dims[2], dims[1], dims[0] };
    var total: i64 = 1;
    for (ne_in) |v| total *= v;
    if (@as(usize, @intCast(total)) != input.len) return error.InputSizeMismatch;

    const meta_size = c.ggml_tensor_overhead() * MAX_NODES + c.ggml_graph_overhead_custom(MAX_NODES, false) + (1 << 20);
    const mctx = c.ggml_init(.{ .mem_size = meta_size, .mem_buffer = null, .no_alloc = true }) orelse return error.OutOfMemory;
    defer c.ggml_free(mctx);
    const dctx = c.ggml_init(.{ .mem_size = input.len * 4 + c.ggml_tensor_overhead() * 4 + 4096, .mem_buffer = null, .no_alloc = false }) orelse return error.OutOfMemory;
    defer c.ggml_free(dctx);

    const xin: *c.ggml_tensor = c.ggml_new_tensor_4d(dctx, c.GGML_TYPE_F32, ne_in[0], ne_in[1], ne_in[2], ne_in[3]) orelse return error.OutOfMemory;
    const xdata: [*]f32 = @ptrCast(@alignCast(xin.data));
    @memcpy(xdata[0..input.len], input);

    var b = Builder{ .m = m, .ctx = mctx, .tensors = std.StringHashMap(*c.ggml_tensor).init(gpa), .ranks = std.StringHashMap(u8).init(gpa) };
    defer b.tensors.deinit();
    defer b.ranks.deinit();
    try b.tensors.put("x", xin);
    try b.ranks.put("x", 4);
    const tr = tracing();
    for (m.lines, 0..) |line, li| {
        if (tr) std.debug.print("[ocr] {d}: {s}\n", .{ li, line });
        build(&b, line) catch |e| {
            if (last_error_len == 0) setError("line failed ({s}): {s}", .{ @errorName(e), line });
            return e;
        };
    }
    if (tr) std.debug.print("[ocr] built {d} lines\n", .{m.lines.len});
    const out_t = b.tensors.get(m.output) orelse {
        setError("the output {s} was not produced", .{m.output});
        return error.NoOutput;
    };
    const out: *c.ggml_tensor = c.ggml_cont(mctx, out_t) orelse return error.OutOfMemory;

    const graph = c.ggml_new_graph_custom(mctx, MAX_NODES, false) orelse return error.OutOfMemory;
    c.ggml_build_forward_expand(graph, out);

    if (tr) std.debug.print("[ocr] graph: {d} nodes\n", .{c.ggml_graph_n_nodes(graph)});
    const galloc = c.ggml_gallocr_new(c.ggml_backend_cpu_buffer_type()) orelse return error.OutOfMemory;
    defer c.ggml_gallocr_free(galloc);
    if (!c.ggml_gallocr_alloc_graph(galloc, graph)) {
        setError("the graph's buffers could not be allocated", .{});
        return error.OutOfMemory;
    }
    if (tr) std.debug.print("[ocr] allocated\n", .{});
    if (profiling()) {
        std.debug.print("[ocr memory] graph buffer {d} MB" ++ "\n", .{c.ggml_gallocr_get_buffer_size(galloc, 0) >> 20});
        printMemory("before compute");
    }
    // (the plan + compute pair, as the rest of the tier computes: the backend object's C++ registry is not
    // something this DLL's static constructors set up)
    var plan = c.ggml_graph_plan(graph, n_threads, null);
    var wbuf: ?[]u8 = null;
    defer if (wbuf) |w| gpa.free(w);
    if (plan.work_size > 0) {
        wbuf = try gpa.alloc(u8, plan.work_size);
        plan.work_data = wbuf.?.ptr;
    }
    if (tr) std.debug.print("[ocr] computing on {d} threads, work {d} bytes\n", .{ n_threads, plan.work_size });
    const st = if (profiling()) profileCompute(graph, &plan) else c.ggml_graph_compute(graph, &plan);
    if (tr) std.debug.print("[ocr] computed, status {d}\n", .{st});
    if (st != c.GGML_STATUS_SUCCESS) {
        setError("the graph did not compute (status {d})", .{st});
        return error.ComputeFailed;
    }
    const n_out: usize = @intCast(c.ggml_nelements(out));
    const data = try gpa.alloc(f32, n_out);
    const src: [*]const f32 = @ptrCast(@alignCast(out.data));
    @memcpy(data, src[0..n_out]);
    const t1 = std.time.nanoTimestamp();
    return .{ .data = data, .ne = .{ out.ne[0], out.ne[1], out.ne[2], out.ne[3] }, .rank = m.output_rank, .ms = @as(f64, @floatFromInt(t1 - t0)) / 1e6 };
}

// ------------------------------------------------------------------------------------------------ parity files

// "STZT" u32 rank, 4 x i64 dims (ONNX order, 1 where unused), then f32 data
const Tensor = struct { data: []f32, dims: [4]i64, rank: u32 };

fn readTensor(path: []const u8) !Tensor {
    const f = try std.fs.cwd().openFile(path, .{});
    defer f.close();
    const bytes = try f.readToEndAlloc(gpa, 1 << 31);
    defer gpa.free(bytes);
    if (bytes.len < 40 or !std.mem.eql(u8, bytes[0..4], "STZT")) return error.NotTensorFile;
    const rank = std.mem.readInt(u32, bytes[4..8], .little);
    var dims: [4]i64 = undefined;
    var i: usize = 0;
    while (i < 4) : (i += 1) dims[i] = std.mem.readInt(i64, bytes[8 + i * 8 ..][0..8], .little);
    const n = (bytes.len - 40) / 4;
    const data = try gpa.alloc(f32, n);
    const src = bytes[40..];
    i = 0;
    while (i < n) : (i += 1) data[i] = @bitCast(std.mem.readInt(u32, src[i * 4 ..][0..4], .little));
    return .{ .data = data, .dims = dims, .rank = rank };
}

fn writeTensor(path: []const u8, o: Output) !void {
    const f = try std.fs.cwd().createFile(path, .{});
    defer f.close();
    var hdr: [40]u8 = undefined;
    @memcpy(hdr[0..4], "STZT");
    std.mem.writeInt(u32, hdr[4..8], o.rank, .little);
    // ONNX order: the ggml ne reversed over the rank
    var i: usize = 0;
    while (i < 4) : (i += 1) {
        const v: i64 = if (i < o.rank) o.ne[@as(usize, @intCast(o.rank)) - 1 - i] else 1;
        std.mem.writeInt(i64, hdr[8 + i * 8 ..][0..8], v, .little);
    }
    try f.writeAll(&hdr);
    try f.writeAll(std.mem.sliceAsBytes(o.data));
}

pub const Parity = struct { n: usize, max_abs: f64, mean_abs: f64, cosine: f64, ms: f64, argmax_agree: f64 };

/// Runs the model on a saved input and compares the output with a saved expected tensor (onnxruntime's).
/// `out_path` may be empty; when given, the engine's output is written there in the same file shape.
pub fn parity(model_path: []const u8, in_path: []const u8, exp_path: []const u8, out_path: []const u8, n_threads: c_int) !Parity {
    last_error_len = 0;
    const m = try load(model_path);
    defer m.free();
    const tin = try readTensor(in_path);
    defer gpa.free(tin.data);
    const texp = try readTensor(exp_path);
    defer gpa.free(texp.data);
    const o = try run(m, tin.data, tin.dims, n_threads);
    defer gpa.free(o.data);
    if (out_path.len > 0) try writeTensor(out_path, o);
    if (o.data.len != texp.data.len) {
        setError("the output has {d} values, the expected {d}", .{ o.data.len, texp.data.len });
        return error.ShapeMismatch;
    }
    var max_abs: f64 = 0;
    var sum_abs: f64 = 0;
    var dot: f64 = 0;
    var na: f64 = 0;
    var nb: f64 = 0;
    for (o.data, texp.data) |a, e| {
        const d = @abs(@as(f64, a) - @as(f64, e));
        if (d > max_abs) max_abs = d;
        sum_abs += d;
        dot += @as(f64, a) * @as(f64, e);
        na += @as(f64, a) * @as(f64, a);
        nb += @as(f64, e) * @as(f64, e);
    }
    const n = o.data.len;
    // for a classifier/recogniser output (rows of probabilities over ne0), the share of rows whose argmax agrees
    var agree: f64 = 1;
    const row: usize = @intCast(o.ne[0]);
    if (row > 1 and n % row == 0 and n / row >= 1) {
        const rows = n / row;
        var ok: usize = 0;
        var ri: usize = 0;
        while (ri < rows) : (ri += 1) {
            var ia: usize = 0;
            var ie: usize = 0;
            var j: usize = 1;
            while (j < row) : (j += 1) {
                if (o.data[ri * row + j] > o.data[ri * row + ia]) ia = j;
                if (texp.data[ri * row + j] > texp.data[ri * row + ie]) ie = j;
            }
            if (ia == ie) ok += 1;
        }
        agree = @as(f64, @floatFromInt(ok)) / @as(f64, @floatFromInt(rows));
    }
    const cosine = if (na > 0 and nb > 0) dot / (@sqrt(na) * @sqrt(nb)) else 0;
    return .{ .n = n, .max_abs = max_abs, .mean_abs = sum_abs / @as(f64, @floatFromInt(n)), .cosine = cosine, .ms = o.ms, .argmax_agree = agree };
}

pub const Info = struct { ops: usize, consts: usize, params: usize, kind: []const u8 };

pub fn info(model_path: []const u8) !Info {
    last_error_len = 0;
    const m = try load(model_path);
    defer m.free();
    var params: usize = 0;
    var t = c.ggml_get_first_tensor(m.wctx);
    var nconst: usize = 0;
    while (t) |tt| : (t = c.ggml_get_next_tensor(m.wctx, tt)) {
        // (gguf keeps the whole data blob as one more tensor; the constants are the c<N> ones)
        const tp: *c.ggml_tensor = tt;
        if (tp.name[0] != 'c') continue;
        params += @intCast(c.ggml_nelements(tt));
        nconst += 1;
    }
    return .{ .ops = m.lines.len, .consts = nconst, .params = params, .kind = m.kind };
}
