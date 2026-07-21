// stz_wasm_entry.zig -- the Softanza differential engine, compiled to stz.wasm.
//
// This is the WEB EDGE. Not the whole engine, and NOT the Ring interpreter:
// only Softanza's DIFFERENTIAL value -- the analytical compute a browser does
// not give you for free (numeric solving, number theory, aggregation). Unicode
// and string work are left to the platform: JS is industrial-strength there, so
// shipping it to the browser is dead weight. The engine is the edge.
//
// "Compile the engine, not the interpreter": the same Zig logic modules that
// back the native DLLs (numtheory.zig, solver.zig) are re-exported here for
// wasm32, so the browser runs the REAL engine, byte-for-byte the same algorithm.
//
// ABI (matches the stz.js bridge):
//   - freestanding wasm32; JS owns the linear memory (--import-memory).
//   - scalars pass by value (i32/i64/f64).
//   - arrays/strings are marshalled through a bump heap: JS calls stz_alloc(n)
//     to get an OFFSET into the shared memory, writes the bytes there, then
//     calls the function with (offset, len). stz_reset() reclaims the whole heap.
//
// Built by `zig build wasm` -> zig-out/bin/stz.wasm.

const std = @import("std");
const numtheory = @import("numtheory.zig");
const solver = @import("solver.zig");

// -- marshalling heap: a bump allocator over a static buffer that lives in the
//    module's linear memory. Freestanding wasm has no libc malloc; this is the
//    minimal, deterministic scratch the bridge writes JS arrays/strings into.
// A small bump-scratch the bridge marshals JS arrays/strings into. Kept modest
// (wasm-ld emits it as a data segment, so it is real bytes in the module); the
// edge only marshals a few scalars/rows at a time, so 8 KiB is ample.
var heap: [1 << 13]u8 align(16) = undefined; // 8 KiB, 16-aligned so any 8-aligned
var heap_off: usize = 0; //                    sub-offset is absolutely aligned too

export fn stz_alloc(n: usize) callconv(.c) u32 {
    const base = std.mem.alignForward(usize, heap_off, 8);
    if (base + n > heap.len) return 0; // out of scratch -> null offset
    heap_off = base + n;
    return @intCast(@intFromPtr(&heap[base]));
}

export fn stz_free(ptr: u32, n: usize) callconv(.c) void {
    _ = ptr;
    _ = n; // bump heap: an individual free is a no-op; stz_reset reclaims all
}

export fn stz_reset() callconv(.c) void {
    heap_off = 0;
}

// -- number theory: exact integer math (differential -- JS Number is f64) ------

export fn stz_gcd(a: i64, b: i64) callconv(.c) i64 {
    return numtheory.gcd(a, b);
}

export fn stz_is_prime(n: i64) callconv(.c) i32 {
    return numtheory.is_prime(n);
}

export fn stz_nth_prime(n: i32) callconv(.c) i64 {
    return numtheory.nth_prime(n);
}

export fn stz_fib(n: i32) callconv(.c) i64 {
    return numtheory.fibonacci(n);
}

// -- solver: numeric root-finding / evaluation (differential -- the edge of the
//    ConstraintSolver capability the brain places on the phone) ---------------

export fn stz_solve_linear(a: f64, b: f64) callconv(.c) f64 {
    return solver.solver_linear(a, b);
}

export fn stz_quad_root1(a: f64, b: f64, c: f64) callconv(.c) f64 {
    return solver.solver_quadratic_root1(a, b, c);
}

export fn stz_quad_root2(a: f64, b: f64, c: f64) callconv(.c) f64 {
    return solver.solver_quadratic_root2(a, b, c);
}

// Evaluate a polynomial whose (degree+1) coefficients were written to `ptr`.
export fn stz_poly_eval(ptr: u32, degree: usize, x: f64) callconv(.c) f64 {
    const coeffs: [*]const f64 = @ptrFromInt(@as(usize, ptr));
    return solver.solver_eval_poly(coeffs, degree, x);
}

// -- aggregation over a JS-provided f64 array (exercises the marshalling ABI --
//    the edge of the PivotTable capability: reduce many rows to one number) ---

export fn stz_mean(ptr: u32, len: usize) callconv(.c) f64 {
    if (len == 0) return 0;
    const xs: [*]const f64 = @ptrFromInt(@as(usize, ptr));
    var sum: f64 = 0;
    var i: usize = 0;
    while (i < len) : (i += 1) sum += xs[i];
    return sum / @as(f64, @floatFromInt(len));
}

export fn stz_sum(ptr: u32, len: usize) callconv(.c) f64 {
    const xs: [*]const f64 = @ptrFromInt(@as(usize, ptr));
    var total: f64 = 0;
    var i: usize = 0;
    while (i < len) : (i += 1) total += xs[i];
    return total;
}

// A stable ABI/version probe the bridge can call to confirm it loaded stz.wasm.
export fn stz_abi_version() callconv(.c) i32 {
    return 1;
}
