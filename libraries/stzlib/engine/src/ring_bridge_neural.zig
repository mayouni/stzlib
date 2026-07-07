const neural = @import("neural.zig");
const embed = @import("neural_embed.zig");
const R = @import("ring_api.zig");

const rn = R.ring_vm_api_retnumber;
const gs = R.ring_vm_api_getstring;

fn ring_NeuralSmoke(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(neural.neural_ggml_smoke()));
}

fn ring_NeuralVersion(p: *anyopaque) callconv(.c) void {
    const v: [*:0]const u8 = @ptrCast(neural.neural_ggml_version());
    R.ring_vm_api_retstring(p, v);
}

// --- Model loading + inspection (GGUF) ---
fn ring_NeuralModelLoad(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.neural_model_load(gs(p, 1))));
}

fn ring_NeuralModelFree(p: *anyopaque) callconv(.c) void {
    embed.neural_model_free();
    rn(p, 1);
}

fn ring_NeuralModelLoaded(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.neural_model_loaded()));
}

fn ring_NeuralModelArch(p: *anyopaque) callconv(.c) void {
    const a: [*:0]const u8 = @ptrCast(embed.neural_model_arch());
    R.ring_vm_api_retstring(p, a);
}

fn ring_NeuralModelNEmbd(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.neural_model_n_embd()));
}

fn ring_NeuralModelNLayers(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.neural_model_n_layers()));
}

fn ring_NeuralModelNHeads(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.neural_model_n_heads()));
}

fn ring_NeuralModelNCtx(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.neural_model_n_ctx()));
}

fn ring_NeuralModelNVocab(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.neural_model_n_vocab()));
}

fn ring_NeuralModelNTensors(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.neural_model_n_tensors()));
}

fn ring_NeuralModelKvCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.neural_model_kv_count()));
}
fn ring_NeuralModelKey(p: *anyopaque) callconv(.c) void {
    const i: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 1));
    const k: [*:0]const u8 = @ptrCast(embed.neural_model_key(i));
    R.ring_vm_api_retstring(p, k);
}
fn ring_NeuralModelKeyType(p: *anyopaque) callconv(.c) void {
    const i: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 1));
    rn(p, @floatFromInt(embed.neural_model_key_type(i)));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineneuralsmoke", .func = &ring_NeuralSmoke },
    .{ .name = "stzengineneuralversion", .func = &ring_NeuralVersion },
    .{ .name = "stzengineneuralmodelload", .func = &ring_NeuralModelLoad },
    .{ .name = "stzengineneuralmodelfree", .func = &ring_NeuralModelFree },
    .{ .name = "stzengineneuralmodelloaded", .func = &ring_NeuralModelLoaded },
    .{ .name = "stzengineneuralmodelarch", .func = &ring_NeuralModelArch },
    .{ .name = "stzengineneuralmodelnembd", .func = &ring_NeuralModelNEmbd },
    .{ .name = "stzengineneuralmodelnlayers", .func = &ring_NeuralModelNLayers },
    .{ .name = "stzengineneuralmodelnheads", .func = &ring_NeuralModelNHeads },
    .{ .name = "stzengineneuralmodelnctx", .func = &ring_NeuralModelNCtx },
    .{ .name = "stzengineneuralmodelnvocab", .func = &ring_NeuralModelNVocab },
    .{ .name = "stzengineneuralmodelntensors", .func = &ring_NeuralModelNTensors },
    .{ .name = "stzengineneuralmodelkvcount", .func = &ring_NeuralModelKvCount },
    .{ .name = "stzengineneuralmodelkey", .func = &ring_NeuralModelKey },
    .{ .name = "stzengineneuralmodelkeytype", .func = &ring_NeuralModelKeyType },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
