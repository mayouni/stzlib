const neural = @import("neural.zig");
const embed = @import("neural_embed.zig");
const R = @import("ring_api.zig");

const rn = R.ring_vm_api_retnumber;
const gs = R.ring_vm_api_getstring;

fn ring_NeuralSmoke(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(neural.neural_ggml_smoke()));
}
fn ring_NeuralComputeSmoke(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(neural.neural_ggml_compute_smoke()));
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

fn ring_NeuralModelTensorName(p: *anyopaque) callconv(.c) void {
    const i: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 1));
    const n: [*:0]const u8 = @ptrCast(embed.neural_model_tensor_name(i));
    R.ring_vm_api_retstring(p, n);
}

fn ring_NeuralTokenize(p: *anyopaque) callconv(.c) void {
    const ptr = gs(p, 1);
    const len: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    rn(p, @floatFromInt(embed.neural_tokenize(ptr, len)));
}
fn ring_NeuralTokenAt(p: *anyopaque) callconv(.c) void {
    const i: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 1));
    rn(p, @floatFromInt(embed.neural_token_at(i)));
}

fn ring_NeuralEmbed(p: *anyopaque) callconv(.c) void {
    const ptr = gs(p, 1);
    const len: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    rn(p, @floatFromInt(embed.neural_embed_text(ptr, len)));
}
fn ring_NeuralEmbedAt(p: *anyopaque) callconv(.c) void {
    const i: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 1));
    rn(p, embed.neural_embed_at(i));
}

fn ring_NeuralEmbedTokens(p: *anyopaque) callconv(.c) void {
    const ptr = gs(p, 1);
    const len: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    rn(p, @floatFromInt(embed.neural_embed_tokens(ptr, len)));
}
fn ring_NeuralTokenDim(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.neural_token_dim()));
}
fn ring_NeuralTokenValue(p: *anyopaque) callconv(.c) void {
    const t: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 1));
    const d: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 2));
    rn(p, embed.neural_token_value(t, d));
}

fn ring_NeuralVocabToken(p: *anyopaque) callconv(.c) void {
    const i: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 1));
    const t: [*:0]const u8 = @ptrCast(embed.neural_vocab_token(i));
    R.ring_vm_api_retstring(p, t);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineneuralvocabtoken", .func = &ring_NeuralVocabToken },
    .{ .name = "stzengineneuralmodeltensorname", .func = &ring_NeuralModelTensorName },
    .{ .name = "stzengineneuraltokenize", .func = &ring_NeuralTokenize },
    .{ .name = "stzengineneuraltokenat", .func = &ring_NeuralTokenAt },
    .{ .name = "stzengineneuralembed", .func = &ring_NeuralEmbed },
    .{ .name = "stzengineneuralembedat", .func = &ring_NeuralEmbedAt },
    .{ .name = "stzengineneuralembedtokens", .func = &ring_NeuralEmbedTokens },
    .{ .name = "stzengineneuraltokendim", .func = &ring_NeuralTokenDim },
    .{ .name = "stzengineneuraltokenvalue", .func = &ring_NeuralTokenValue },
    .{ .name = "stzengineneuralsmoke", .func = &ring_NeuralSmoke },
    .{ .name = "stzengineneuralcomputesmoke", .func = &ring_NeuralComputeSmoke },
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
