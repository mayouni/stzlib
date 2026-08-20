// stz_wasm_entry.zig -- the Softanza differential engine, compiled to stz.wasm.
//
// This is the WEB EDGE. Not the whole engine, and NOT the Ring interpreter:
// only Softanza's DIFFERENTIAL value -- the analytical compute a browser does
// not give you for free. And not even all of THAT: only the SUBSET the plan
// asks for. The build option `wasm-groups` (set by the brain from each part's
// [stz.wasm]-placed capabilities) selects which engine groups are compiled in,
// so a part that only solves ships only the solver -- no number theory, no
// aggregation. Emit ONLY the plan's per-part engine subset.
//
// Groups (capability -> group, in stzBuilder._StzWasmGroupFor):
//   solver       <- ConstraintSolver   (solver.zig: root-finding / evaluation)
//   aggregation  <- PivotTable          (reduce a marshalled array to one number)
//   numtheory    <- BigNumber           (numtheory.zig: exact integer math)
//
// ABI: freestanding wasm32; JS owns the linear memory (--import-memory). Scalars
// by value; arrays via the marshalling heap (stz_alloc -> offset, JS writes, call
// with (offset, len); stz_reset reclaims). Built by `zig build wasm`.

const std = @import("std");
const cfg = @import("wasm_groups");

// comptime: is an engine group requested for this build?
fn wants(comptime g: []const u8) bool {
    return comptime (std.mem.indexOf(u8, cfg.groups, g) != null);
}
const want_solver = wants("solver");
const want_agg = wants("aggregation");
const want_numtheory = wants("numtheory");
const want_pattern = wants("pattern");
const want_graph = wants("graph");
const want_gpu = wants("gpu");
// SN6's fourth sink. The browser gets the sound GRAPH, not the sample table:
// see soundwasm.zig for why a source node cannot exist here and why that is
// right rather than a shortfall.
const want_sound = wants("sound");

// Import a group's source module ONLY when the group is on, so an off group's
// code is not in the compilation at all (a true subset, not a gated surface).
const solver = if (want_solver) @import("solver.zig") else struct {};
const numtheory = if (want_numtheory) @import("numtheory.zig") else struct {};
const pattern = if (want_pattern) @import("pattern.zig") else struct {};
const graph = if (want_graph) @import("graph.zig") else struct {};
const gpu_wgsl = if (want_gpu) @import("gpu_wgsl.zig") else struct {};
const sw = if (want_sound) @import("soundwasm.zig") else struct {};
const sdsp = if (want_sound) @import("sounddsp.zig") else struct {};

// -- marshalling heap (always present): a bump allocator over a static buffer in
//    linear memory. 16-aligned so marshalled f64 views are aligned; kept small
//    because wasm-ld emits it as real bytes (the edge marshals only a few rows).
var heap: [1 << 13]u8 align(16) = undefined; // 8 KiB
var heap_off: usize = 0;

export fn stz_alloc(n: usize) callconv(.c) u32 {
    const base = std.mem.alignForward(usize, heap_off, 8);
    if (base + n > heap.len) return 0;
    heap_off = base + n;
    return @intCast(@intFromPtr(&heap[base]));
}

export fn stz_free(ptr: u32, n: usize) callconv(.c) void {
    _ = ptr;
    _ = n;
}

export fn stz_reset() callconv(.c) void {
    heap_off = 0;
}

// A version/ABI probe the bridge calls to confirm it loaded a stz.wasm.
export fn stz_abi_version() callconv(.c) i32 {
    return 1;
}

// -- solver group (wrappers; analyzed + exported only when want_solver) --------
fn solve_linear(a: f64, b: f64) callconv(.c) f64 {
    return solver.solver_linear(a, b);
}
fn quad_root1(a: f64, b: f64, c: f64) callconv(.c) f64 {
    return solver.solver_quadratic_root1(a, b, c);
}
fn quad_root2(a: f64, b: f64, c: f64) callconv(.c) f64 {
    return solver.solver_quadratic_root2(a, b, c);
}
fn poly_eval(ptr: u32, degree: usize, x: f64) callconv(.c) f64 {
    const coeffs: [*]const f64 = @ptrFromInt(@as(usize, ptr));
    return solver.solver_eval_poly(coeffs, degree, x);
}

// -- aggregation group (self-contained; reduce a marshalled f64 array) ---------
fn agg_mean(ptr: u32, len: usize) callconv(.c) f64 {
    if (len == 0) return 0;
    const xs: [*]const f64 = @ptrFromInt(@as(usize, ptr));
    var sum: f64 = 0;
    var i: usize = 0;
    while (i < len) : (i += 1) sum += xs[i];
    return sum / @as(f64, @floatFromInt(len));
}
fn agg_sum(ptr: u32, len: usize) callconv(.c) f64 {
    const xs: [*]const f64 = @ptrFromInt(@as(usize, ptr));
    var total: f64 = 0;
    var i: usize = 0;
    while (i < len) : (i += 1) total += xs[i];
    return total;
}

// -- numtheory group (wrappers; exported only when want_numtheory) -------------
fn nt_gcd(a: i64, b: i64) callconv(.c) i64 {
    return numtheory.gcd(a, b);
}
fn nt_is_prime(n: i64) callconv(.c) i32 {
    return numtheory.is_prime(n);
}
fn nt_nth_prime(n: i32) callconv(.c) i64 {
    return numtheory.nth_prime(n);
}
fn nt_fib(n: i32) callconv(.c) i64 {
    return numtheory.fibonacci(n);
}

// -- pattern group (sequence / string pattern detection; self-contained) -------
fn pat_is_palindrome(ptr: u32, len: usize) callconv(.c) i32 {
    const s: [*]const u8 = @ptrFromInt(@as(usize, ptr));
    return pattern.is_palindrome(s, len);
}
fn pat_is_arith(ptr: u32, len: usize) callconv(.c) i32 {
    const v: [*]const f64 = @ptrFromInt(@as(usize, ptr));
    return pattern.is_arithmetic_seq(v, len);
}
fn pat_arith_diff(ptr: u32, len: usize) callconv(.c) f64 {
    const v: [*]const f64 = @ptrFromInt(@as(usize, ptr));
    return pattern.arithmetic_diff(v, len);
}
fn pat_is_geo(ptr: u32, len: usize) callconv(.c) i32 {
    const v: [*]const f64 = @ptrFromInt(@as(usize, ptr));
    return pattern.is_geometric_seq(v, len);
}
fn pat_geo_ratio(ptr: u32, len: usize) callconv(.c) f64 {
    const v: [*]const f64 = @ptrFromInt(@as(usize, ptr));
    return pattern.geometric_ratio(v, len);
}

// -- gpu group (the W->WGSL transpiler -- G5 edge convergence) -----------------
// The SAME zero-allocation transpiler that stz_gpu.dll carries: a spec string
// in linear memory becomes the SAME WGSL text the native engine emits, and
// the page feeds it to navigator.gpu. Kernel authoring converges; execution
// is the browser's WebGPU (the same API family wgpu-native implements).
fn wgsl_elementwise(spec_ptr: u32, spec_len: usize, out_ptr: u32, out_cap: usize) callconv(.c) i32 {
    const spec: [*]const u8 = @ptrFromInt(@as(usize, spec_ptr));
    const out: [*]u8 = @ptrFromInt(@as(usize, out_ptr));
    return gpu_wgsl.stz_gpu_wgsl_elementwise(spec, @floatFromInt(spec_len), out, @floatFromInt(out_cap));
}
fn wgsl_error(out_ptr: u32, out_cap: usize) callconv(.c) i32 {
    const out: [*]u8 = @ptrFromInt(@as(usize, out_ptr));
    return gpu_wgsl.stz_gpu_wgsl_error(out, @floatFromInt(out_cap));
}


// ── the sound group: build a graph, then fill a block on demand ─────────────
//
// The shape is the AudioWorklet's: snd_render() fills one quantum and JS reads
// it out of linear memory at snd_block_ptr(), interleaved f32. No ring, no
// device thread, no callback -- the worklet IS the clock.

// SS5: THE EARCON VOCABULARY IN THE BROWSER.
//
// Not a graph. A motif is a short run of pure arithmetic, so the browser pulls
// it out, copies it into an AudioBuffer and plays it -- simpler than a worklet
// and lower latency, because there is no ring and no quantum to wait for.
//
// IT CARRIES NO BUFFER OF ITS OWN. The first cut declared a 32768-frame static
// to render into and added 128 KB to every download, for a cue lasting 180 ms;
// `undefined` did not keep it out of the module. So the motif is rendered
// STATELESSLY, in chunks, through stz_snd_block_ptr() -- the buffer the
// worklet already uses -- and the module grows by nothing. SN6 paid this same
// tuition when per-node delay lines made a 26 MB wasm: in this tier a static
// array IS download size.
fn snd_earcon_chunk(value: u32, rate: u32, from: u32) callconv(.c) u32 {
    return sw.earconChunk(value, rate, from);
}

fn snd_earcon_frames(value: u32, rate: u32) callconv(.c) u32 {
    return @intCast(sdsp.motifFrames(value, rate));
}

fn snd_earcon_count() callconv(.c) u32 {
    return sdsp.EARCON_COUNT;
}

fn snd_reset(r: u32, ch: u32, blk: u32) callconv(.c) i32 {
    return sw.reset(r, ch, blk);
}
fn snd_add_osc(waveform: u32, hz: f64, amp: f64) callconv(.c) i32 {
    return sw.addOsc(waveform, hz, amp);
}
fn snd_add_gain(input: i32, gain: f64) callconv(.c) i32 {
    return sw.addGain(input, gain);
}
fn snd_add_mix() callconv(.c) i32 {
    return sw.addMix();
}
fn snd_mix_add(mix: i32, input: i32) callconv(.c) i32 {
    return sw.mixAdd(mix, input);
}
fn snd_add_pan(input: i32, pan: f64) callconv(.c) i32 {
    return sw.addPan(input, pan);
}
fn snd_add_filter(input: i32, kind: u32, freq: f64, q: f64) callconv(.c) i32 {
    return sw.addFilter(input, kind, freq, q);
}
fn snd_add_delay(input: i32, seconds: f64, feedback: f64, wet: f64) callconv(.c) i32 {
    return sw.addDelay(input, seconds, feedback, wet);
}
fn snd_add_envelope(input: i32, a: f64, d: f64, sus: f64, r: f64, gate: f64) callconv(.c) i32 {
    return sw.addEnvelope(input, a, d, sus, r, gate);
}
fn snd_set_output(node: i32) callconv(.c) i32 {
    return sw.setOutput(node);
}
fn snd_prepare() callconv(.c) i32 {
    return sw.prepare();
}
fn snd_trigger(node: i32) callconv(.c) i32 {
    return sw.triggerNode(node);
}
fn snd_render() callconv(.c) u32 {
    return sw.renderBlock();
}
fn snd_block_ptr() callconv(.c) u32 {
    return sw.blockPtr();
}
fn snd_node_count() callconv(.c) u32 {
    return sw.nodeCount();
}
fn snd_refusals() callconv(.c) u32 {
    return sw.refusals();
}
fn snd_blocks_rendered() callconv(.c) u32 {
    return sw.blocksRendered();
}
fn snd_sample_at(frame: u32, ch: u32) callconv(.c) f64 {
    return sw.sampleAt(frame, ch);
}

// Export exactly the requested groups. Unlisted wrappers are never referenced,
// so they are never analyzed and their (possibly absent) module deps never
// checked -- the binary carries only the plan's subset.
comptime {
    if (want_solver) {
        @export(&solve_linear, .{ .name = "stz_solve_linear" });
        @export(&quad_root1, .{ .name = "stz_quad_root1" });
        @export(&quad_root2, .{ .name = "stz_quad_root2" });
        @export(&poly_eval, .{ .name = "stz_poly_eval" });
    }
    if (want_agg) {
        @export(&agg_mean, .{ .name = "stz_mean" });
        @export(&agg_sum, .{ .name = "stz_sum" });
    }
    if (want_numtheory) {
        @export(&nt_gcd, .{ .name = "stz_gcd" });
        @export(&nt_is_prime, .{ .name = "stz_is_prime" });
        @export(&nt_nth_prime, .{ .name = "stz_nth_prime" });
        @export(&nt_fib, .{ .name = "stz_fib" });
    }
    if (want_sound) {
        @export(&snd_reset, .{ .name = "stz_snd_reset" });
        @export(&snd_add_osc, .{ .name = "stz_snd_add_osc" });
        @export(&snd_add_gain, .{ .name = "stz_snd_add_gain" });
        @export(&snd_add_mix, .{ .name = "stz_snd_add_mix" });
        @export(&snd_mix_add, .{ .name = "stz_snd_mix_add" });
        @export(&snd_add_pan, .{ .name = "stz_snd_add_pan" });
        @export(&snd_add_filter, .{ .name = "stz_snd_add_filter" });
        @export(&snd_add_delay, .{ .name = "stz_snd_add_delay" });
        @export(&snd_add_envelope, .{ .name = "stz_snd_add_envelope" });
        @export(&snd_set_output, .{ .name = "stz_snd_set_output" });
        @export(&snd_prepare, .{ .name = "stz_snd_prepare" });
        @export(&snd_trigger, .{ .name = "stz_snd_trigger" });
        @export(&snd_render, .{ .name = "stz_snd_render" });
        @export(&snd_block_ptr, .{ .name = "stz_snd_block_ptr" });
        @export(&snd_node_count, .{ .name = "stz_snd_node_count" });
        @export(&snd_refusals, .{ .name = "stz_snd_refusals" });
        @export(&snd_blocks_rendered, .{ .name = "stz_snd_blocks_rendered" });
        @export(&snd_sample_at, .{ .name = "stz_snd_sample_at" });
        @export(&snd_earcon_chunk, .{ .name = "stz_snd_earcon_chunk" });
        @export(&snd_earcon_frames, .{ .name = "stz_snd_earcon_frames" });
        @export(&snd_earcon_count, .{ .name = "stz_snd_earcon_count" });
    }
    if (want_pattern) {
        @export(&pat_is_palindrome, .{ .name = "stz_is_palindrome" });
        @export(&pat_is_arith, .{ .name = "stz_is_arithmetic" });
        @export(&pat_arith_diff, .{ .name = "stz_arith_diff" });
        @export(&pat_is_geo, .{ .name = "stz_is_geometric" });
        @export(&pat_geo_ratio, .{ .name = "stz_geo_ratio" });
    }
    if (want_gpu) {
        @export(&wgsl_elementwise, .{ .name = "stz_gpu_wgsl_elementwise" });
        @export(&wgsl_error, .{ .name = "stz_gpu_wgsl_error" });
    }
    if (want_graph) {
        // graph.zig's functions are already callconv(.c) with a pointer/handle
        // ABI (?*StzGraph = an i32 handle in wasm, [*]const u8 = an offset), so
        // JS can drive them directly -- export the real ones under their names.
        @export(&graph.stz_graph_create, .{ .name = "stz_graph_create" });
        @export(&graph.stz_graph_free, .{ .name = "stz_graph_free" });
        @export(&graph.stz_graph_add_node, .{ .name = "stz_graph_add_node" });
        @export(&graph.stz_graph_add_edge, .{ .name = "stz_graph_add_edge" });
        @export(&graph.stz_graph_node_count, .{ .name = "stz_graph_node_count" });
        @export(&graph.stz_graph_edge_count, .{ .name = "stz_graph_edge_count" });
        @export(&graph.stz_graph_path_exists, .{ .name = "stz_graph_path_exists" });
        @export(&graph.stz_graph_has_cycle, .{ .name = "stz_graph_has_cycle" });
        @export(&graph.stz_graph_connected_components, .{ .name = "stz_graph_connected_components" });
    }
}
