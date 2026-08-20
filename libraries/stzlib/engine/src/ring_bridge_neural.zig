const std = @import("std");
const neural = @import("neural.zig");
const embed = @import("neural_embed.zig");
const gen = @import("neural_gen.zig");
const gex = @import("gguf_export.zig");
const ngpu = @import("neural_gpu.zig");
const nbb = @import("neural_backbone.zig");
const gbnf = @import("schema_gbnf.zig");
const gmach = @import("gbnf_machine.zig");
const R = @import("ring_api.zig");

const rn = R.ring_vm_api_retnumber;
const gs = R.ring_vm_api_getstring;

// --- GGUF export (R4 step 8: write the format we read) ---
fn ring_GgufBegin(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gex.stz_gguf_export_begin(gs(p, 1), gs(p, 2))));
}
fn ring_GgufAddTensor(p: *anyopaque) callconv(.c) void {
    const nRows: i32 = @intFromFloat(R.ring_vm_api_getnumber(p, 2));
    const nCols: i32 = @intFromFloat(R.ring_vm_api_getnumber(p, 3));
    if (R.ring_vm_api_islist(p, 4) == 0) {
        rn(p, 0);
        return;
    }
    const pList = R.ring_vm_api_getlist(p, 4) orelse {
        rn(p, 0);
        return;
    };
    const want: usize = @intCast(nRows * nCols);
    const buf = std.heap.c_allocator.alloc(f64, want) catch {
        rn(p, 0);
        return;
    };
    defer std.heap.c_allocator.free(buf);
    var i: usize = 0;
    while (i < want) : (i += 1) {
        const idx: c_uint = @intCast(i + 1);
        if (R.ring_list_isnumber_gc(null, pList, idx) == 0) {
            rn(p, 0);
            return;
        }
        const pItem = R.ring_list_getitem_gc(null, pList, idx) orelse {
            rn(p, 0);
            return;
        };
        buf[i] = R.ring_item_getnumber(pItem);
    }
    rn(p, @floatFromInt(gex.stz_gguf_export_add_tensor(gs(p, 1), nRows, nCols, buf.ptr, @intCast(want))));
}
fn ring_GgufWrite(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gex.stz_gguf_export_write(gs(p, 1))));
}
fn ring_GgufInspect(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gex.stz_gguf_inspect(gs(p, 1))));
}
fn ring_GgufInspectArch(p: *anyopaque) callconv(.c) void {
    R.ring_vm_api_retstring(p, gex.stz_gguf_inspect_arch());
}

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

// THE SEAM: every embedding in the library comes through here, and the
// engine decides CPU vs GPU backbone by the MEASURED token threshold.
fn ring_NeuralEmbed(p: *anyopaque) callconv(.c) void {
    const ptr = gs(p, 1);
    const len: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    rn(p, @floatFromInt(nbb.neural_embed_routed(ptr, len)));
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

fn ring_NeuralModelHasNer(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.neural_model_has_ner()));
}
fn ring_NeuralNer(p: *anyopaque) callconv(.c) void {
    const ptr = gs(p, 1);
    const len: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    rn(p, @floatFromInt(embed.neural_ner(ptr, len)));
}
fn ring_NeuralNerText(p: *anyopaque) callconv(.c) void {
    const i: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 1));
    R.ring_vm_api_retstring(p, @ptrCast(embed.neural_ner_text(i)));
}
fn ring_NeuralNerType(p: *anyopaque) callconv(.c) void {
    const i: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 1));
    R.ring_vm_api_retstring(p, @ptrCast(embed.neural_ner_type(i)));
}

fn ring_NeuralModelHasReranker(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.neural_model_has_reranker()));
}
fn ring_NeuralRerank(p: *anyopaque) callconv(.c) void {
    const q = gs(p, 1);
    const qlen: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    const d = gs(p, 2);
    const dlen: usize = @intCast(R.ring_vm_api_getstringsize(p, 2));
    rn(p, embed.neural_rerank(q, qlen, d, dlen));
}

fn ring_NeuralVocabToken(p: *anyopaque) callconv(.c) void {
    const i: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 1));
    const t: [*:0]const u8 = @ptrCast(embed.neural_vocab_token(i));
    R.ring_vm_api_retstring(p, t);
}

// ---------------- GPU routing knobs (neural_gpu.zig) ----------------

fn ring_GpuRuntimePath(p: *anyopaque) callconv(.c) void {
    const ptr = gs(p, 1);
    const len: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    ngpu.neural_gpu_set_runtime_path(ptr, len);
    rn(p, 1);
}

fn ring_GpuSetThreshold(p: *anyopaque) callconv(.c) void {
    ngpu.neural_gpu_set_threshold(R.ring_vm_api_getnumber(p, 1));
    rn(p, 1);
}

fn ring_GpuThreshold(p: *anyopaque) callconv(.c) void {
    rn(p, ngpu.neural_gpu_threshold());
}

fn ring_GpuState(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ngpu.neural_gpu_state()));
}

fn ring_GpuCounter(p: *anyopaque) callconv(.c) void {
    rn(p, ngpu.neural_gpu_counter(@intFromFloat(R.ring_vm_api_getnumber(p, 1))));
}

fn ring_GpuCountersReset(p: *anyopaque) callconv(.c) void {
    ngpu.neural_gpu_counters_reset();
    rn(p, 1);
}

// BackboneEmbed(cText) -> the pooled vector as a Ring list ([] if the
// backbone did not run: no device, unsupported model shape, any refusal).
// Tokenizes through the SAME tokenizer the CPU path uses, so only the
// numeric core differs between the two routes.
fn ring_BackboneEmbed(p: *anyopaque) callconv(.c) void {
    const ptr = gs(p, 1);
    const len: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    const out = R.ring_vm_api_newlist(p) orelse return;
    const n_tok = embed.neural_tokenize(ptr, len);
    const n_embd: usize = @intCast(embed.neural_model_n_embd());
    if (n_tok < 2 or n_embd == 0) {
        R.ring_vm_api_retlist(p, out);
        return;
    }
    const ids = std.heap.c_allocator.alloc(i32, @intCast(n_tok)) catch {
        R.ring_vm_api_retlist(p, out);
        return;
    };
    defer std.heap.c_allocator.free(ids);
    for (0..@intCast(n_tok)) |i| ids[i] = embed.neural_token_at(@intCast(i));
    const vec = std.heap.c_allocator.alloc(f32, n_embd) catch {
        R.ring_vm_api_retlist(p, out);
        return;
    };
    defer std.heap.c_allocator.free(vec);
    if (nbb.neural_backbone_forward(ids.ptr, n_tok, vec.ptr) == 1) {
        for (vec) |v| R.ring_list_adddouble(out, @floatCast(v));
    }
    R.ring_vm_api_retlist(p, out);
}

fn ring_BackboneSetMinTokens(p: *anyopaque) callconv(.c) void {
    nbb.neural_backbone_set_min_tokens(R.ring_vm_api_getnumber(p, 1));
    rn(p, 1);
}

fn ring_BackboneMinTokens(p: *anyopaque) callconv(.c) void {
    rn(p, nbb.neural_backbone_min_tokens());
}

fn ring_BackboneRouteCount(p: *anyopaque) callconv(.c) void {
    rn(p, nbb.neural_backbone_route_count(@intFromFloat(R.ring_vm_api_getnumber(p, 1))));
}

fn ring_BackboneRouteReset(p: *anyopaque) callconv(.c) void {
    nbb.neural_backbone_route_reset();
    rn(p, 1);
}

fn ring_BackboneSupported(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(nbb.neural_backbone_supported()));
}

// --- schema -> GBNF (prompt 42 item 1). The grammar is COMPILED here;
// nothing constrains decoding with it yet, and ring_GbnfDecodingSupported
// says so rather than letting a caller assume otherwise.
fn ring_GbnfBegin(p: *anyopaque) callconv(.c) void {
    _ = p;
    gbnf.stz_gbnf_begin();
}

fn ring_GbnfField(p: *anyopaque) callconv(.c) void {
    const name = gs(p, 1);
    const nl: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    const ftype: i32 = @intFromFloat(R.ring_vm_api_getnumber(p, 2));
    const req: i32 = @intFromFloat(R.ring_vm_api_getnumber(p, 3));
    const of: i32 = @intFromFloat(R.ring_vm_api_getnumber(p, 4));
    const ch = gs(p, 5);
    const cl: usize = @intCast(R.ring_vm_api_getstringsize(p, 5));
    const ms = gs(p, 6);
    const ml: usize = @intCast(R.ring_vm_api_getstringsize(p, 6));
    rn(p, @floatFromInt(gbnf.stz_gbnf_field(name, nl, ftype, req, of, ch, cl, ms, ml)));
}

fn ring_GbnfCompile(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gbnf.stz_gbnf_compile()));
}

fn ring_GbnfText(p: *anyopaque) callconv(.c) void {
    var buf: [8192]u8 = undefined;
    const l = gbnf.stz_gbnf_text(&buf);
    if (l > 0) R.ring_vm_api_retstring2(p, &buf, @intCast(l)) else R.ring_vm_api_retstring2(p, @constCast(""), 0);
}

fn ring_GbnfLastRefusal(p: *anyopaque) callconv(.c) void {
    var buf: [512]u8 = undefined;
    const l = gbnf.stz_gbnf_last_refusal(&buf);
    if (l > 0) R.ring_vm_api_retstring2(p, &buf, @intCast(l)) else R.ring_vm_api_retstring2(p, @constCast(""), 0);
}

fn ring_GbnfUnenforced(p: *anyopaque) callconv(.c) void {
    var buf: [1024]u8 = undefined;
    const l = gbnf.stz_gbnf_unenforced(&buf);
    if (l > 0) R.ring_vm_api_retstring2(p, &buf, @intCast(l)) else R.ring_vm_api_retstring2(p, @constCast(""), 0);
}

// --- GRAMMAR-CONSTRAINED DECODING (prompt 43). The grammar compiled
// above is INSTALLED here, and from that moment the sampler in
// neural_gen.zig draws only from candidates the grammar can still accept.
// --- the machine on its own, with no model in the way. Checking a
// grammar, and asking whether a piece of text satisfies it, needs no
// vocabulary and no GGUF -- so these do not require one, and a guard can
// prove the enforcement rules on a machine with no model installed.
// They share the ONE machine the sampler uses, which is safe because a
// generation call is synchronous: nothing runs between its tokens.
fn ring_GrammarSet(p: *anyopaque) callconv(.c) void {
    const t = gs(p, 1);
    const l: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    rn(p, @floatFromInt(gmach.stz_grammar_set(t, l)));
}

fn ring_GrammarReset(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gmach.stz_grammar_reset()));
}

fn ring_GrammarAccept(p: *anyopaque) callconv(.c) void {
    const t = gs(p, 1);
    const l: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    rn(p, @floatFromInt(gmach.stz_grammar_accept(t, l)));
}

fn ring_GrammarCanAccept(p: *anyopaque) callconv(.c) void {
    const t = gs(p, 1);
    const l: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    rn(p, @floatFromInt(gmach.stz_grammar_can_accept(t, l)));
}

fn ring_GrammarCanEnd(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gmach.stz_grammar_can_end()));
}

fn ring_GrammarLive(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gmach.stz_grammar_live()));
}

fn ring_GrammarRefusal(p: *anyopaque) callconv(.c) void {
    var buf: [512]u8 = undefined;
    const l = gmach.stz_grammar_last_refusal(&buf);
    if (l > 0) R.ring_vm_api_retstring2(p, &buf, @intCast(l)) else R.ring_vm_api_retstring2(p, @constCast(""), 0);
}

fn ring_NeuralSetGrammar(p: *anyopaque) callconv(.c) void {
    const t = gs(p, 1);
    const l: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    rn(p, @floatFromInt(gen.neural_gen_set_grammar(@ptrCast(t), l)));
}

fn ring_NeuralClearGrammar(p: *anyopaque) callconv(.c) void {
    gen.neural_gen_clear_grammar();
    rn(p, 1);
}

fn ring_NeuralGrammarActive(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gen.neural_gen_grammar_active()));
}

fn ring_NeuralGrammarMasked(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gen.neural_gen_grammar_masked()));
}

fn ring_NeuralGrammarJudged(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gen.neural_gen_grammar_judged()));
}

fn ring_NeuralGrammarSteps(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gen.neural_gen_grammar_steps()));
}

fn ring_NeuralGrammarStalled(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gen.neural_gen_grammar_stalled()));
}

fn ring_NeuralGrammarComplete(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gen.neural_gen_grammar_complete()));
}

fn ring_NeuralGrammarRefusal(p: *anyopaque) callconv(.c) void {
    var buf: [512]u8 = undefined;
    const l = gen.neural_gen_grammar_refusal(&buf);
    if (l > 0) R.ring_vm_api_retstring2(p, &buf, @intCast(l)) else R.ring_vm_api_retstring2(p, @constCast(""), 0);
}

fn ring_GbnfDecodingSupported(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gbnf.stz_gbnf_decoding_supported()));
}

fn ring_GbnfDecodingStatus(p: *anyopaque) callconv(.c) void {
    var buf: [1024]u8 = undefined;
    const l = gbnf.stz_gbnf_decoding_status(&buf);
    if (l > 0) R.ring_vm_api_retstring2(p, &buf, @intCast(l)) else R.ring_vm_api_retstring2(p, @constCast(""), 0);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginegbnfbegin", .func = &ring_GbnfBegin },
    .{ .name = "stzenginegbnffield", .func = &ring_GbnfField },
    .{ .name = "stzenginegbnfcompile", .func = &ring_GbnfCompile },
    .{ .name = "stzenginegbnftext", .func = &ring_GbnfText },
    .{ .name = "stzenginegbnflastrefusal", .func = &ring_GbnfLastRefusal },
    .{ .name = "stzenginegbnfunenforced", .func = &ring_GbnfUnenforced },
    .{ .name = "stzenginegbnfdecodingsupported", .func = &ring_GbnfDecodingSupported },
    .{ .name = "stzenginegbnfdecodingstatus", .func = &ring_GbnfDecodingStatus },
    .{ .name = "stzenginegrammarset", .func = &ring_GrammarSet },
    .{ .name = "stzenginegrammarreset", .func = &ring_GrammarReset },
    .{ .name = "stzenginegrammaraccept", .func = &ring_GrammarAccept },
    .{ .name = "stzenginegrammarcanaccept", .func = &ring_GrammarCanAccept },
    .{ .name = "stzenginegrammarcanend", .func = &ring_GrammarCanEnd },
    .{ .name = "stzenginegrammarlive", .func = &ring_GrammarLive },
    .{ .name = "stzenginegrammarrefusal", .func = &ring_GrammarRefusal },
    .{ .name = "stzengineneuralsetgrammar", .func = &ring_NeuralSetGrammar },
    .{ .name = "stzengineneuralcleargrammar", .func = &ring_NeuralClearGrammar },
    .{ .name = "stzengineneuralgrammaractive", .func = &ring_NeuralGrammarActive },
    .{ .name = "stzengineneuralgrammarmasked", .func = &ring_NeuralGrammarMasked },
    .{ .name = "stzengineneuralgrammarjudged", .func = &ring_NeuralGrammarJudged },
    .{ .name = "stzengineneuralgrammarsteps", .func = &ring_NeuralGrammarSteps },
    .{ .name = "stzengineneuralgrammarstalled", .func = &ring_NeuralGrammarStalled },
    .{ .name = "stzengineneuralgrammarcomplete", .func = &ring_NeuralGrammarComplete },
    .{ .name = "stzengineneuralgrammarrefusal", .func = &ring_NeuralGrammarRefusal },
    .{ .name = "stzengineneuralbackboneembed", .func = &ring_BackboneEmbed },
    .{ .name = "stzengineneuralbackbonesupported", .func = &ring_BackboneSupported },
    .{ .name = "stzengineneuralbackbonesetmintokens", .func = &ring_BackboneSetMinTokens },
    .{ .name = "stzengineneuralbackbonemintokens", .func = &ring_BackboneMinTokens },
    .{ .name = "stzengineneuralbackboneroutecount", .func = &ring_BackboneRouteCount },
    .{ .name = "stzengineneuralbackboneroutereset", .func = &ring_BackboneRouteReset },
    .{ .name = "stzengineneuralgpuruntimepath", .func = &ring_GpuRuntimePath },
    .{ .name = "stzengineneuralgpusetthreshold", .func = &ring_GpuSetThreshold },
    .{ .name = "stzengineneuralgputhreshold", .func = &ring_GpuThreshold },
    .{ .name = "stzengineneuralgpustate", .func = &ring_GpuState },
    .{ .name = "stzengineneuralgpucounter", .func = &ring_GpuCounter },
    .{ .name = "stzengineneuralgpucountersreset", .func = &ring_GpuCountersReset },
    .{ .name = "stzengineneuralvocabtoken", .func = &ring_NeuralVocabToken },
    .{ .name = "stzengineneuralmodeltensorname", .func = &ring_NeuralModelTensorName },
    .{ .name = "stzengineneuraltokenize", .func = &ring_NeuralTokenize },
    .{ .name = "stzengineneuraltokenat", .func = &ring_NeuralTokenAt },
    .{ .name = "stzengineneuralembed", .func = &ring_NeuralEmbed },
    .{ .name = "stzengineneuralembedat", .func = &ring_NeuralEmbedAt },
    .{ .name = "stzengineneuralembedtokens", .func = &ring_NeuralEmbedTokens },
    .{ .name = "stzengineneuraltokendim", .func = &ring_NeuralTokenDim },
    .{ .name = "stzengineneuraltokenvalue", .func = &ring_NeuralTokenValue },
    .{ .name = "stzengineneuralmodelhasner", .func = &ring_NeuralModelHasNer },
    .{ .name = "stzengineneuralner", .func = &ring_NeuralNer },
    .{ .name = "stzengineneuralnertext", .func = &ring_NeuralNerText },
    .{ .name = "stzengineneuralnertype", .func = &ring_NeuralNerType },
    .{ .name = "stzengineneuralmodelhasreranker", .func = &ring_NeuralModelHasReranker },
    .{ .name = "stzengineneuralrerank", .func = &ring_NeuralRerank },
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
    .{ .name = "stzengineneuralhasgenerator", .func = &ring_NeuralHasGenerator },
    .{ .name = "stzengineneuralgenerate", .func = &ring_NeuralGenerate },
    .{ .name = "stzengineneuralgentokenize", .func = &ring_NeuralGenTokenize },
    .{ .name = "stzengineneuralgentokenat", .func = &ring_NeuralGenTokenAt },
    .{ .name = "stzengineneuralgeneratext", .func = &ring_NeuralGenerateXT },
    .{ .name = "stzengineneuralgenstart", .func = &ring_NeuralGenStart },
    .{ .name = "stzengineneuralgennext", .func = &ring_NeuralGenNext },
    .{ .name = "stzengineneuralgenchunk", .func = &ring_NeuralGenChunk },
    .{ .name = "stzengineneuralgenactive", .func = &ring_NeuralGenActive },
    .{ .name = "stzengineneuralgeneratecont", .func = &ring_NeuralGenerateCont },
    .{ .name = "stzengineneuralgencached", .func = &ring_NeuralGenCached },
    .{ .name = "stzengineneuralggufbegin", .func = &ring_GgufBegin },
    .{ .name = "stzengineneuralggufaddtensor", .func = &ring_GgufAddTensor },
    .{ .name = "stzengineneuralggufwrite", .func = &ring_GgufWrite },
    .{ .name = "stzengineneuralggufinspect", .func = &ring_GgufInspect },
    .{ .name = "stzengineneuralggufinspectarch", .func = &ring_GgufInspectArch },
};

fn ring_NeuralHasGenerator(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gen.neural_model_has_generator()));
}

// StzEngineNeuralGenerate(cPrompt, nMaxNew) -> generated text (greedy)
fn ring_NeuralGenerate(p: *anyopaque) callconv(.c) void {
    const prompt = gs(p, 1);
    const plen: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    const maxn: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 2));
    const n = gen.neural_generate(prompt, plen, maxn);
    if (n < 0) {
        R.ring_vm_api_retstring(p, "");
        return;
    }
    const t: [*:0]const u8 = @ptrCast(gen.neural_gen_text());
    R.ring_vm_api_retstring(p, t);
}

fn ring_NeuralGenTokenize(p: *anyopaque) callconv(.c) void {
    const t = gs(p, 1);
    const tlen: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    rn(p, @floatFromInt(gen.neural_gen_tokenize(t, tlen)));
}

fn ring_NeuralGenTokenAt(p: *anyopaque) callconv(.c) void {
    const i: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 1));
    rn(p, @floatFromInt(gen.neural_gen_token_at(i)));
}

// StzEngineNeuralGenerateXT(prompt, maxNew, temp, topP, topK, seed) -> text
fn ring_NeuralGenerateXT(p: *anyopaque) callconv(.c) void {
    const prompt = gs(p, 1);
    const plen: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    const maxn: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 2));
    const temp: f64 = R.ring_vm_api_getnumber(p, 3);
    const topp: f64 = R.ring_vm_api_getnumber(p, 4);
    const topk: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 5));
    const seed: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 6));
    const n = gen.neural_generate_xt(prompt, plen, maxn, temp, topp, topk, seed);
    if (n < 0) {
        R.ring_vm_api_retstring(p, "");
        return;
    }
    const t: [*:0]const u8 = @ptrCast(gen.neural_gen_text());
    R.ring_vm_api_retstring(p, t);
}

fn ring_NeuralGenStart(p: *anyopaque) callconv(.c) void {
    const prompt = gs(p, 1);
    const plen: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    const maxn: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 2));
    const temp: f64 = R.ring_vm_api_getnumber(p, 3);
    const topp: f64 = R.ring_vm_api_getnumber(p, 4);
    const topk: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 5));
    const seed: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 6));
    rn(p, @floatFromInt(gen.neural_gen_start(prompt, plen, maxn, temp, topp, topk, seed)));
}

fn ring_NeuralGenNext(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gen.neural_gen_next()));
}

fn ring_NeuralGenChunk(p: *anyopaque) callconv(.c) void {
    const t: [*:0]const u8 = @ptrCast(gen.neural_gen_chunk());
    R.ring_vm_api_retstring(p, t);
}

fn ring_NeuralGenActive(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gen.neural_gen_active()));
}

fn ring_NeuralGenerateCont(p: *anyopaque) callconv(.c) void {
    const prompt = gs(p, 1);
    const plen: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    const maxn: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 2));
    const temp: f64 = R.ring_vm_api_getnumber(p, 3);
    const topp: f64 = R.ring_vm_api_getnumber(p, 4);
    const topk: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 5));
    const seed: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 6));
    const n = gen.neural_generate_cont(prompt, plen, maxn, temp, topp, topk, seed);
    if (n < 0) {
        R.ring_vm_api_retstring(p, "");
        return;
    }
    const t: [*:0]const u8 = @ptrCast(gen.neural_gen_text());
    R.ring_vm_api_retstring(p, t);
}

fn ring_NeuralGenCached(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gen.neural_gen_cached()));
}

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
