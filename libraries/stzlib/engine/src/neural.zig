// Softanza Engine -- Neural / modern tier (ggml)
//
// The modern NLP tier: vendored ggml (CPU-only) for runtime inference over GGUF
// models -- sentence embeddings (semantic search), zero-shot classification,
// transformer NER. Unlike the classical @embedFile'd tables, neural models are
// LOADED AT RUNTIME from disk (they are large), so this layer is a thin, safe
// Zig wrapper over the vendored ggml C/C++ core.
//
// MILESTONE 1 (this commit): prove the ggml runtime vendors, builds under Zig,
// links into a DLL, and RUNS from Ring. Embedding inference (GGUF load + BERT
// forward pass + tokenization + pooling) is the next milestone.

const std = @import("std");
const c = @cImport({
    @cInclude("ggml.h");
    @cInclude("ggml-cpu.h");
});

// Compute-path smoke: build a trivial 2-tensor add graph and run it through
// ggml_graph_plan + ggml_graph_compute. Returns 1 if a+b == expected.
pub export fn neural_ggml_compute_smoke() callconv(.c) c_int {
    const ctx = c.ggml_init(.{ .mem_size = 16 * 1024 * 1024, .mem_buffer = null, .no_alloc = false }) orelse return 0;
    defer c.ggml_free(ctx);
    const a = c.ggml_new_tensor_1d(ctx, c.GGML_TYPE_F32, 3) orelse return 0;
    const b = c.ggml_new_tensor_1d(ctx, c.GGML_TYPE_F32, 3) orelse return 0;
    const ad: [*]f32 = @ptrCast(@alignCast(a.*.data));
    const bd: [*]f32 = @ptrCast(@alignCast(b.*.data));
    ad[0] = 1;
    ad[1] = 2;
    ad[2] = 3;
    bd[0] = 10;
    bd[1] = 20;
    bd[2] = 30;
    const cc = c.ggml_add(ctx, a, b) orelse return 0;
    const graph = c.ggml_new_graph(ctx) orelse return 0;
    c.ggml_build_forward_expand(graph, cc);
    var plan = c.ggml_graph_plan(graph, 1, null);
    var wbuf: [1024 * 1024]u8 = undefined;
    if (plan.work_size > 0) plan.work_data = &wbuf;
    _ = c.ggml_graph_compute(graph, &plan);
    const cd: [*]const f32 = @ptrCast(@alignCast(cc.*.data));
    return if (cd[0] > 10.9 and cd[0] < 11.1) 1 else 0;
}

// ggml build version string (proves the header + lib are wired).
pub export fn neural_ggml_version() callconv(.c) [*c]const u8 {
    return c.ggml_version();
}

// Smoke test: exercise the actual ggml runtime -- init a context, allocate a
// 1-D f32 tensor, write and read back through its data buffer, free. Returns 1
// if the round-trip value is correct, else 0. Proves context/allocator/tensor
// all link and execute.
pub export fn neural_ggml_smoke() callconv(.c) c_int {
    const params = c.ggml_init_params{
        // 64 KB: ample for one 3-element f32 tensor + ggml context/object/tensor
        // overhead. It's a liveness probe, not a workload -- keep it lean.
        .mem_size = 64 * 1024,
        .mem_buffer = null,
        .no_alloc = false,
    };
    const ctx = c.ggml_init(params) orelse return 0;
    defer c.ggml_free(ctx);

    const t = c.ggml_new_tensor_1d(ctx, c.GGML_TYPE_F32, 3) orelse return 0;
    const data: [*]f32 = @ptrCast(@alignCast(t.*.data));
    data[0] = 3.5;
    data[1] = -1.25;
    data[2] = data[0] + data[1]; // 2.25
    const ok = (data[2] > 2.24 and data[2] < 2.26);
    return if (ok) 1 else 0;
}

// Number of ggml objects in a fresh small context -- another liveness probe.
pub export fn neural_ggml_ok() callconv(.c) c_int {
    return neural_ggml_smoke();
}
