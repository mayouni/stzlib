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

// Import a group's source module ONLY when the group is on, so an off group's
// code is not in the compilation at all (a true subset, not a gated surface).
const solver = if (want_solver) @import("solver.zig") else struct {};
const numtheory = if (want_numtheory) @import("numtheory.zig") else struct {};
const pattern = if (want_pattern) @import("pattern.zig") else struct {};
const graph = if (want_graph) @import("graph.zig") else struct {};

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
    if (want_pattern) {
        @export(&pat_is_palindrome, .{ .name = "stz_is_palindrome" });
        @export(&pat_is_arith, .{ .name = "stz_is_arithmetic" });
        @export(&pat_arith_diff, .{ .name = "stz_arith_diff" });
        @export(&pat_is_geo, .{ .name = "stz_is_geometric" });
        @export(&pat_geo_ratio, .{ .name = "stz_geo_ratio" });
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
