const std = @import("std");
const neural = @import("neural.zig");
const embed = @import("neural_embed.zig");
const gen = @import("neural_gen.zig");
const gex = @import("gguf_export.zig");
const model_digest = @import("model_digest.zig");
const ngpu = @import("neural_gpu.zig");
const nbb = @import("neural_backbone.zig");
const gops = @import("gpu_ops.zig"); // this DLL's own variant table (per-DLL device law)
const gbnf = @import("schema_gbnf.zig");
const gmach = @import("gbnf_machine.zig");
const R = @import("ring_api.zig");
const ocrg = @import("ocr_graph.zig"); // O3: PP-OCR graphs on ggml
const ocrp = @import("ocr_pipeline.zig"); // O3b: an image file in, its text lines out
const vlm = @import("vlm.zig"); // IM7: the vision half of a vision-language model
const nvit = @import("neural_vit.zig"); // IM8a: that tower, resident on the GPU
const vis = @import("vision.zig"); // IM3: the image plane's models (classify, faces, objects)
const ocrw = @import("ocr_winrt.zig"); // O5: the platform engine called in process

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
    // THE FLATTENING TAX: a tensor arrives as rows (nRows lists of nCols) or
    // flat (nRows*nCols numbers); the rows are walked here, not in Ring
    if (want > 0 and R.ring_list_islist_gc(null, pList, 1) != 0) {
        const r_count: usize = @intCast(R.ringListSize(pList));
        if (r_count != @as(usize, @intCast(nRows))) {
            rn(p, 0);
            return;
        }
        for (0..r_count) |r| {
            const row = R.ring_list_getlist_gc(null, pList, @intCast(r + 1)) orelse {
                rn(p, 0);
                return;
            };
            if (@as(usize, @intCast(R.ringListSize(row))) != @as(usize, @intCast(nCols))) {
                rn(p, 0);
                return;
            }
            for (0..@as(usize, @intCast(nCols))) |cidx| {
                const pItem = R.ring_list_getitem_gc(null, row, @intCast(cidx + 1)) orelse {
                    rn(p, 0);
                    return;
                };
                buf[r * @as(usize, @intCast(nCols)) + cidx] = R.ring_item_getnumber(pItem);
            }
        }
    } else {
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

/// StzEngineNeuralModelLoadStatus() -> why the last load was refused:
/// 0 ok, -1 unreadable, -2 digest mismatch, -3 no recorded digest.
fn ring_NeuralModelLoadStatus(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.neural_model_load_status()));
}

/// StzEngineModelDigest(cPath) -> the file's SHA-256 (64 hex), "" if unreadable.
fn ring_ModelDigest(p: *anyopaque) callconv(.c) void {
    R.ring_vm_api_retstring(p, model_digest.stz_model_digest(gs(p, 1)));
}

/// StzEngineModelExpect(cPath, cHex) -> 1, or 0 when cHex is not 64 hex chars.
fn ring_ModelExpect(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(model_digest.stz_model_expect(gs(p, 1), gs(p, 2), @intCast(R.ring_vm_api_getstringsize(p, 2)))));
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
// GK2b: the persisted matmul verdicts reach THIS DLL's variant table here --
// stz_gpu.dll's table is not ours (one device, one gpu_ops copy per DLL)
fn ring_NeuralVariantSet(p: *anyopaque) callconv(.c) void {
    const op = R.ring_vm_api_getstring(p, 1);
    const len = R.ring_vm_api_getstringsize(p, 1);
    rn(p, @floatFromInt(gops.stz_gpu_variant_set(op, @floatFromInt(len), R.ring_vm_api_getnumber(p, 2), R.ring_vm_api_getnumber(p, 3), R.ring_vm_api_getnumber(p, 4), R.ring_vm_api_getnumber(p, 5))));
}
fn ring_NeuralVariantGet(p: *anyopaque) callconv(.c) void {
    const op = R.ring_vm_api_getstring(p, 1);
    const len = R.ring_vm_api_getstringsize(p, 1);
    rn(p, gops.stz_gpu_variant_get(op, @floatFromInt(len), R.ring_vm_api_getnumber(p, 2), R.ring_vm_api_getnumber(p, 3), R.ring_vm_api_getnumber(p, 4)));
}
fn ring_NeuralVariantClear(p: *anyopaque) callconv(.c) void {
    gops.stz_gpu_variant_clear();
    rn(p, 1);
}

// GK2c: the attention foundry -- FoundryAttention(n_tok, n_embd, n_head, reps, mask)
fn ring_AttentionFoundry(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(nbb.neural_attention_foundry(R.ring_vm_api_getnumber(p, 1), R.ring_vm_api_getnumber(p, 2), R.ring_vm_api_getnumber(p, 3), R.ring_vm_api_getnumber(p, 4), R.ring_vm_api_getnumber(p, 5))));
}
fn ring_AttentionFoundryResult(p: *anyopaque) callconv(.c) void {
    rn(p, nbb.neural_attention_foundry_result(@intFromFloat(R.ring_vm_api_getnumber(p, 1))));
}
fn ring_AttentionVariantName(p: *anyopaque) callconv(.c) void {
    var buf: [32]u8 = undefined;
    const n = nbb.neural_attention_variant_name(R.ring_vm_api_getnumber(p, 1), &buf, buf.len);
    R.ring_vm_api_retstring2(p, &buf, @intCast(n));
}
fn ring_AttentionVariantUsed(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(nbb.neural_attention_variant_used()));
}

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

// GK5: the weights at f16 in VRAM, beside the f32 path
fn ring_BackboneSetWeightsF16(p: *anyopaque) callconv(.c) void {
    nbb.neural_backbone_set_weights_f16(@intFromFloat(R.ring_vm_api_getnumber(p, 1)));
}
fn ring_BackboneWeightsF16(p: *anyopaque) callconv(.c) void {
    R.ring_vm_api_retnumber(p, @floatFromInt(nbb.neural_backbone_weights_f16()));
}
fn ring_BackboneF16Available(p: *anyopaque) callconv(.c) void {
    R.ring_vm_api_retnumber(p, @floatFromInt(nbb.neural_backbone_f16_available()));
}
fn ring_BackboneWeightBytes(p: *anyopaque) callconv(.c) void {
    R.ring_vm_api_retnumber(p, nbb.neural_backbone_weight_bytes());
}

// GK4: the forward's dispatch count
fn ring_BackboneDispatches(p: *anyopaque) callconv(.c) void {
    R.ring_vm_api_retnumber(p, nbb.neural_backbone_dispatches());
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

// ---------------------------------------------------------------- OCR graphs (O3)

fn ocrArg(p: *anyopaque, n: c_int) []const u8 {
    return gs(p, n)[0..@intCast(R.ring_vm_api_getstringsize(p, n))];
}

// StzEngineNeuralOcrGraphInfo(cModel) -> [ cKind, nOps, nConstants, nParams ], [] when the file is not one
fn ring_OcrGraphInfo(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    if (ocrg.info(ocrArg(p, 1))) |i| {
        R.ring_list_addstring2(out, i.kind.ptr, @intCast(i.kind.len));
        R.ring_list_adddouble(out, @floatFromInt(i.ops));
        R.ring_list_adddouble(out, @floatFromInt(i.consts));
        R.ring_list_adddouble(out, @floatFromInt(i.params));
    } else |_| {}
    R.ring_vm_api_retlist(p, out);
}

// StzEngineNeuralOcrGraphParity(cModel, cInputBin, cExpectedBin, cOutputBin, nThreads)
//   -> [ n, nMaxAbs, nMeanAbs, nCosine, nMs, nArgmaxAgree ], [] on failure (StzEngineNeuralOcrGraphError says why)
fn ring_OcrGraphParity(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const threads: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 5));
    if (ocrg.parity(ocrArg(p, 1), ocrArg(p, 2), ocrArg(p, 3), ocrArg(p, 4), if (threads < 1) 4 else threads)) |r| {
        R.ring_list_adddouble(out, @floatFromInt(r.n));
        R.ring_list_adddouble(out, r.max_abs);
        R.ring_list_adddouble(out, r.mean_abs);
        R.ring_list_adddouble(out, r.cosine);
        R.ring_list_adddouble(out, r.ms);
        R.ring_list_adddouble(out, r.argmax_agree);
    } else |e| {
        if (ocrg.lastError().len == 0) {
            const nm = @errorName(e);
            R.ring_list_addstring2(out, nm.ptr, @intCast(nm.len));
            R.ring_vm_api_retlist(p, out);
            return;
        }
    }
    R.ring_vm_api_retlist(p, out);
}

// StzEngineNeuralOcrRead(cModelsDir, cImage, nThreads)
//   -> [ [ cText, nScore, nX0, nY0, nX1, nY1, bFlipped ], ... ] in reading order, the box in the file's pixels;
//      [] on failure (StzEngineNeuralOcrGraphError says why). The three graphs stay loaded for the process.
var ocr_stats: [6]f64 = .{ 0, 0, 0, 0, 0, 0 };

fn ring_OcrRead(p: *anyopaque) callconv(.c) void {
    ocrRead(p, "", 2, 3);
}

// StzEngineNeuralOcrReadWith(cModelsDir, cRecogniserFile, cImage, nThreads) -- the same rows, read with the named
// recogniser (ppocr_rec_arabic.gguf, ppocr_rec_cyrillic.gguf, ...) in the models folder
fn ring_OcrReadWith(p: *anyopaque) callconv(.c) void {
    ocrRead(p, ocrArg(p, 2), 3, 4);
}

fn ocrRead(p: *anyopaque, rec_file: []const u8, n_image: c_int, n_threads: c_int) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const threads: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, n_threads));
    var r = ocrp.read(ocrArg(p, 1), rec_file, ocrArg(p, n_image), if (threads < 1) 4 else threads) catch |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("{s}", .{@errorName(e)});
        R.ring_vm_api_retlist(p, out);
        return;
    };
    defer r.free();
    for (r.lines) |l| {
        const row = R.ring_list_newlist(out) orelse break;
        R.ring_list_addstring2(row, l.text.ptr, @intCast(l.text.len));
        R.ring_list_adddouble(row, l.score);
        R.ring_list_adddouble(row, l.x0);
        R.ring_list_adddouble(row, l.y0);
        R.ring_list_adddouble(row, l.x1);
        R.ring_list_adddouble(row, l.y1);
        R.ring_list_adddouble(row, if (l.flipped) 1 else 0);
    }
    ocr_stats = .{ @floatFromInt(r.boxes), r.ms_det, r.ms_cls, r.ms_rec, r.ms_total, @floatFromInt(r.votes_180) };
    R.ring_vm_api_retlist(p, out);
}

// StzEngineNeuralOcrStats() -> [ nBoxes, nMsDetect, nMsClassify, nMsRecognise, nMsTotal, nVotes180 ] of the last read
fn ring_OcrStats(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (ocr_stats) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

// StzEngineNeuralOcrMarks(cImage, nPixelsPerPoint, cBoxes) -> [ aMarks, aStrokes ] (O4): what a scanned page shows
// besides its letters -- each mark [ cKind ("rule", "dot", "fill", "panel"), nX0, nY0, nX1, nY1 ] in the image's pixels --
// and, for each box of cBoxes ("x0 y0 x1 y1;..." -- the OCR lines), the median width of its ink strokes in pixels;
// [] on failure (StzEngineNeuralOcrGraphError says why)
fn ring_OcrMarks(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const ppt: f32 = @floatCast(R.ring_vm_api_getnumber(p, 2));
    var boxes: std.ArrayList([4]f32) = .empty;
    defer boxes.deinit(std.heap.c_allocator);
    var it = std.mem.splitScalar(u8, ocrArg(p, 3), ';');
    while (it.next()) |item| {
        var f = std.mem.tokenizeScalar(u8, item, ' ');
        var b: [4]f32 = undefined;
        var k: usize = 0;
        while (f.next()) |num| : (k += 1) {
            if (k >= 4) break;
            b[k] = std.fmt.parseFloat(f32, num) catch 0;
        }
        if (k == 4) boxes.append(std.heap.c_allocator, b) catch {};
    }
    var r = ocrp.marksOf(ocrArg(p, 1), if (ppt > 0) ppt else 150.0 / 72.0, boxes.items) catch |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("{s}", .{@errorName(e)});
        R.ring_vm_api_retlist(p, out);
        return;
    };
    defer r.free();
    const ml = R.ring_list_newlist(out) orelse return;
    for (r.marks) |m| {
        const row = R.ring_list_newlist(ml) orelse break;
        const kn: []const u8 = switch (m.kind) {
            'r' => "rule",
            'd' => "dot",
            'p' => "panel",
            else => "fill",
        };
        R.ring_list_addstring2(row, kn.ptr, @intCast(kn.len));
        R.ring_list_adddouble(row, m.x0);
        R.ring_list_adddouble(row, m.y0);
        R.ring_list_adddouble(row, m.x1);
        R.ring_list_adddouble(row, m.y1);
    }
    const sl = R.ring_list_newlist(out) orelse return;
    for (r.strokes) |v| R.ring_list_adddouble(sl, v);
    R.ring_vm_api_retlist(p, out);
}

// StzEngineNeuralOcrDeskew(cImage, cOut, nMinDegrees) -> the page's skew in degrees (O4): when it is at least
// nMinDegrees the image is written turned level to cOut (BMP); 0 when the page is level (nothing written);
// a number below -90 on failure (StzEngineNeuralOcrGraphError says why)
fn ring_OcrDeskew(p: *anyopaque) callconv(.c) void {
    const min_deg: f32 = @floatCast(R.ring_vm_api_getnumber(p, 3));
    const deg = ocrp.deskew(ocrArg(p, 1), ocrArg(p, 2), min_deg) catch |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("{s}", .{@errorName(e)});
        rn(p, -999);
        return;
    };
    rn(p, deg);
}

// StzEngineNeuralOcrPrepare(cImage, cOut, nMinDegrees, bMaySharpen) -> [ nSkew, nSharpness, bSharpened, bWritten ]
// (O4): the page turned level when its skew is at least nMinDegrees, and sharpened when it is soft and bMaySharpen
// (the platform's OCR will read it); when either applies the
// result is written to cOut (BMP) and bWritten is 1; [] on failure (StzEngineNeuralOcrGraphError says why)
fn ring_OcrPrepare(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const min_deg: f32 = @floatCast(R.ring_vm_api_getnumber(p, 3));
    const r = ocrp.prepare(ocrArg(p, 1), ocrArg(p, 2), min_deg, R.ring_vm_api_getnumber(p, 4) != 0) catch |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("{s}", .{@errorName(e)});
        R.ring_vm_api_retlist(p, out);
        return;
    };
    R.ring_list_adddouble(out, r.skew);
    R.ring_list_adddouble(out, r.sharpness);
    R.ring_list_adddouble(out, if (r.sharpened) 1 else 0);
    R.ring_list_adddouble(out, if (r.written) 1 else 0);
    R.ring_vm_api_retlist(p, out);
}

// StzEngineNeuralOcrDarkBands(cImage, nPixelsPerPoint, cOutPrefix) -> [ [ nX0, nY0, nX1, nY1, cFile ], ... ] (O4):
// the dark bands of a scanned page that hold light text, in the image's pixels, each written to cFile
// (<cOutPrefix>_<n>.bmp) as dark text on light, enlarged twice, for the PP-OCR model to read; [] when there is none
// or on failure (StzEngineNeuralOcrGraphError says why)
fn ring_OcrDarkBands(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const ppt: f32 = @floatCast(R.ring_vm_api_getnumber(p, 2));
    var r = ocrp.darkBands(ocrArg(p, 1), if (ppt > 0) ppt else 150.0 / 72.0, ocrArg(p, 3)) catch |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("{s}", .{@errorName(e)});
        R.ring_vm_api_retlist(p, out);
        return;
    };
    defer r.free();
    for (r.bands, r.paths) |b, path| {
        const row = R.ring_list_newlist(out) orelse break;
        R.ring_list_adddouble(row, @floatFromInt(b.x0));
        R.ring_list_adddouble(row, @floatFromInt(b.y0));
        R.ring_list_adddouble(row, @floatFromInt(b.x1));
        R.ring_list_adddouble(row, @floatFromInt(b.y1));
        R.ring_list_addstring2(row, path.ptr, @intCast(path.len));
    }
    R.ring_vm_api_retlist(p, out);
}

// "x0 y0 x1 y1;..." -> the boxes, one per item (a short item reads as zeros)
fn ocrBoxes(arg: []const u8) std.ArrayList([4]f32) {
    var boxes: std.ArrayList([4]f32) = .empty;
    var it = std.mem.splitScalar(u8, arg, ';');
    while (it.next()) |item| {
        var f = std.mem.tokenizeScalar(u8, item, ' ');
        var b: [4]f32 = .{ 0, 0, 0, 0 };
        var n: usize = 0;
        while (f.next()) |num| : (n += 1) {
            if (n >= 4) break;
            b[n] = std.fmt.parseFloat(f32, num) catch 0;
        }
        boxes.append(std.heap.c_allocator, b) catch {};
    }
    return boxes;
}

// StzEngineNeuralOcrFigures(cImage, nPixelsPerPoint, cBoxes) -> [ [ cKind, nX0, nY0, nX1, nY1, nEx0, nEx1 ], ... ]
// (O4; nEx0..nEx1 a logo's emblem, left to right, 0 otherwise): for each
// box of cBoxes ("x0 y0 x1 y1;..." -- the OCR lines), "stamp" when it is a coloured stamp's (the box is the stamp's),
// "logo" when it is shaped like a logo -- a coloured emblem beside letters (the box takes the emblem in), "" when it is
// text; [] on failure (StzEngineNeuralOcrGraphError says why)
fn ring_OcrFigures(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const ppt: f32 = @floatCast(R.ring_vm_api_getnumber(p, 2));
    var boxes = ocrBoxes(ocrArg(p, 3));
    defer boxes.deinit(std.heap.c_allocator);
    var r = ocrp.figuresOf(ocrArg(p, 1), if (ppt > 0) ppt else 150.0 / 72.0, boxes.items) catch |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("{s}", .{@errorName(e)});
        R.ring_vm_api_retlist(p, out);
        return;
    };
    defer r.free();
    for (r.of) |f| {
        const row = R.ring_list_newlist(out) orelse break;
        const kn: []const u8 = switch (f.kind) {
            's' => "stamp",
            'l' => "logo",
            else => "",
        };
        R.ring_list_addstring2(row, kn.ptr, @intCast(kn.len));
        R.ring_list_adddouble(row, f.x0);
        R.ring_list_adddouble(row, f.y0);
        R.ring_list_adddouble(row, f.x1);
        R.ring_list_adddouble(row, f.y1);
        R.ring_list_adddouble(row, f.ex0);
        R.ring_list_adddouble(row, f.ex1);
    }
    R.ring_vm_api_retlist(p, out);
}

// StzEngineNeuralOcrWipeDrawn(cImage, cOut, nPpt, cBoxes "x0 y0 x1 y1;...") -> [ 1|0, ... ] one per box (O4): whether a
// drawn coloured shape -- a signature's stroke, a stamp's ring -- touches the line; when one does, cOut is written: a
// copy of the image without the drawn shapes' ink, for the touched lines to be read again
fn ring_OcrWipeDrawn(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const ppt: f32 = @floatCast(R.ring_vm_api_getnumber(p, 3));
    var boxes = ocrBoxes(ocrArg(p, 4));
    defer boxes.deinit(std.heap.c_allocator);
    var r = ocrp.wipeDrawn(ocrArg(p, 1), ocrArg(p, 2), if (ppt > 0) ppt else 150.0 / 72.0, boxes.items) catch |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("{s}", .{@errorName(e)});
        R.ring_vm_api_retlist(p, out);
        return;
    };
    defer r.free();
    for (r.touched) |t| R.ring_list_adddouble(out, if (t) 1 else 0);
    R.ring_vm_api_retlist(p, out);
}

// StzEngineNeuralOcrRegion(cImage, cOut, nX0, nY0, nX1, nY1, nScale) -> 1, or 0 on failure (O4): writes to cOut the
// rectangle of the image (pixels) enlarged nScale times -- a stamp read again on its own
fn ring_OcrRegion(p: *anyopaque) callconv(.c) void {
    const v = [5]f32{
        @floatCast(R.ring_vm_api_getnumber(p, 3)), @floatCast(R.ring_vm_api_getnumber(p, 4)),
        @floatCast(R.ring_vm_api_getnumber(p, 5)), @floatCast(R.ring_vm_api_getnumber(p, 6)),
        @floatCast(R.ring_vm_api_getnumber(p, 7)),
    };
    ocrp.writeRegion(ocrArg(p, 1), ocrArg(p, 2), v[0], v[1], v[2], v[3], v[4]) catch |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("{s}", .{@errorName(e)});
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    R.ring_vm_api_retnumber(p, 1);
}

// StzEngineNeuralOcrPlatformRead(cImage, cLang, nTarget) -> [ cSummary, [ [ cText, nX0, nY0, nX1, nY1, nMidTop,
// nMidBottom ], ... ] ] (O5): the :ocr floor's platform engine (Windows.Media.Ocr) called in process -- the lines in
// visual order with their boxes in the image's pixels and the median of their words' tops and bottoms, small text
// read again enlarged to nTarget pixels; the summary says "NO ENGINE for <lang>" when the machine has no pack for
// it; [] when WinRT cannot be reached (the caller falls back to the script)
fn ring_OcrPlatformRead(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const target: f32 = @floatCast(R.ring_vm_api_getnumber(p, 3));
    var r = ocrw.read(ocrArg(p, 1), ocrArg(p, 2), if (target > 0) target else 40) catch |e| {
        ocrg.setError("{s}", .{@errorName(e)});
        R.ring_vm_api_retlist(p, out);
        return;
    };
    defer r.free();
    R.ring_list_addstring2(out, r.summary.ptr, @intCast(r.summary.len));
    const ll = R.ring_list_newlist(out) orelse return;
    for (r.lines) |l| {
        const row = R.ring_list_newlist(ll) orelse break;
        R.ring_list_addstring2(row, l.text.ptr, @intCast(l.text.len));
        for (l.box) |v| R.ring_list_adddouble(row, v);
        for (l.mid) |v| R.ring_list_adddouble(row, v);
    }
    R.ring_vm_api_retlist(p, out);
}

fn ring_OcrGraphError(p: *anyopaque) callconv(.c) void {
    const e = ocrg.lastError();
    R.ring_vm_api_retstring2(p, e.ptr, @intCast(e.len));
}

// ------------------------------------------------------------------ IM3: vision
// The pixels cross as the raw bytes of a stzImage (Pixels()), with width, height and channels; the
// boxes come back in those pixels, 0-based (the Ring face adds 1). [] on failure: StzEngineNeuralOcrGraphError.

var vision_ms: f64 = 0;

// (cModel, cPixels, nW, nH, nC, nK, nThreads) -> [ [ cLabel, nScore, nIndex ], ... ] best first
fn ring_VisionClassify(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const th: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 7));
    if (vis.classify(ocrArg(p, 1), ocrArg(p, 2), @intFromFloat(R.ring_vm_api_getnumber(p, 3)), @intFromFloat(R.ring_vm_api_getnumber(p, 4)), @intFromFloat(R.ring_vm_api_getnumber(p, 5)), @intFromFloat(R.ring_vm_api_getnumber(p, 6)), if (th < 1) 4 else th)) |r| {
        defer std.heap.c_allocator.free(r.best);
        vision_ms = r.ms;
        for (r.best) |cl| {
            const row = R.ring_list_newlist(out) orelse break;
            const lab: []const u8 = if (cl.index < r.labels.len) r.labels[cl.index] else "?";
            R.ring_list_addstring2(row, lab.ptr, @intCast(lab.len));
            R.ring_list_adddouble(row, cl.score);
            R.ring_list_adddouble(row, @floatFromInt(cl.index));
        }
    } else |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("vision: {s}", .{@errorName(e)});
    }
    R.ring_vm_api_retlist(p, out);
}

// (cModel, cPixels, nW, nH, nC, nScore, nNms, nThreads) -> [ [ x, y, w, h, score, l1x, l1y, ... l5y ], ... ]
fn ring_VisionFaces(p: *anyopaque) callconv(.c) void {
    visionDetect(p, false);
}

// (cModel, cPixels, nW, nH, nC, nScore, nNms, nThreads, nTiles 0|2) -> [ [ cLabel, score, x, y, w, h, nClass ], ... ]
fn ring_VisionObjects(p: *anyopaque) callconv(.c) void {
    visionDetect(p, true);
}

fn visionDetect(p: *anyopaque, objs: bool) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const g = R.ring_vm_api_getnumber;
    const th: c_int = @intFromFloat(g(p, 8));
    const w: usize = @intFromFloat(g(p, 3));
    const h: usize = @intFromFloat(g(p, 4));
    const c: usize = @intFromFloat(g(p, 5));
    const res = if (objs)
        vis.objects(ocrArg(p, 1), ocrArg(p, 2), w, h, c, @floatCast(g(p, 6)), @floatCast(g(p, 7)), @intFromFloat(g(p, 9)), if (th < 1) 4 else th)
    else
        vis.faces(ocrArg(p, 1), ocrArg(p, 2), w, h, c, @floatCast(g(p, 6)), @floatCast(g(p, 7)), if (th < 1) 4 else th);
    if (res) |r| {
        defer std.heap.c_allocator.free(r.dets);
        vision_ms = r.ms;
        for (r.dets) |d| {
            const row = R.ring_list_newlist(out) orelse break;
            if (objs) {
                const lab: []const u8 = if (d.class < r.labels.len) r.labels[d.class] else "?";
                R.ring_list_addstring2(row, lab.ptr, @intCast(lab.len));
                R.ring_list_adddouble(row, d.score);
            }
            R.ring_list_adddouble(row, d.x);
            R.ring_list_adddouble(row, d.y);
            R.ring_list_adddouble(row, d.w);
            R.ring_list_adddouble(row, d.h);
            if (objs) {
                R.ring_list_adddouble(row, @floatFromInt(d.class));
            } else {
                R.ring_list_adddouble(row, d.score);
                for (d.lm) |v| R.ring_list_adddouble(row, v);
            }
        }
    } else |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("vision: {s}", .{@errorName(e)});
    }
    R.ring_vm_api_retlist(p, out);
}

// IM5: (cModel, cPixels, nW, nH, nC, nThreads) -> the picture's embedding, L2-normalized (SigLIP2: 768 numbers)
fn ring_VisionEmbedImage(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const g = R.ring_vm_api_getnumber;
    const th: c_int = @intFromFloat(g(p, 6));
    if (vis.embedImage(ocrArg(p, 1), ocrArg(p, 2), @intFromFloat(g(p, 3)), @intFromFloat(g(p, 4)), @intFromFloat(g(p, 5)), if (th < 1) 4 else th)) |r| {
        defer std.heap.c_allocator.free(r.v);
        vision_ms = r.ms;
        for (r.v) |x| R.ring_list_adddouble(out, x);
    } else |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("vision: {s}", .{@errorName(e)});
    }
    R.ring_vm_api_retlist(p, out);
}

// IM5: (cModel, cText, nThreads) -> the text's embedding, L2-normalized, in the same space as the pictures'
fn ring_VisionEmbedText(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const th: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 3));
    if (vis.embedText(ocrArg(p, 1), ocrArg(p, 2), if (th < 1) 4 else th)) |r| {
        defer std.heap.c_allocator.free(r.v);
        vision_ms = r.ms;
        for (r.v) |x| R.ring_list_adddouble(out, x);
    } else |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("vision: {s}", .{@errorName(e)});
    }
    R.ring_vm_api_retlist(p, out);
}

// IM6: (cModel, cPixels, nW, nH, nC, nThreads) -> the salient-object mask, W x H bytes 0..255 ("" on failure)
fn ring_VisionSaliency(p: *anyopaque) callconv(.c) void {
    const g = R.ring_vm_api_getnumber;
    const th: c_int = @intFromFloat(g(p, 6));
    if (vis.saliency(ocrArg(p, 1), ocrArg(p, 2), @intFromFloat(g(p, 3)), @intFromFloat(g(p, 4)), @intFromFloat(g(p, 5)), if (th < 1) 4 else th)) |r| {
        defer std.heap.c_allocator.free(r.px);
        vision_ms = r.ms;
        R.ring_vm_api_retstring2(p, r.px.ptr, @intCast(r.px.len));
    } else |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("vision: {s}", .{@errorName(e)});
        R.ring_vm_api_retstring2(p, "", 0);
    }
}

// IM6: (cModel, cPixels, nW, nH, nC, nThreads) -> relative inverse depth, W x H float32 little-endian bytes
// ("" on failure); stz_image turns them into a grid (StzEngineImageGridFromF32)
fn ring_VisionDepth(p: *anyopaque) callconv(.c) void {
    const g = R.ring_vm_api_getnumber;
    const th: c_int = @intFromFloat(g(p, 6));
    if (vis.depth(ocrArg(p, 1), ocrArg(p, 2), @intFromFloat(g(p, 3)), @intFromFloat(g(p, 4)), @intFromFloat(g(p, 5)), if (th < 1) 4 else th)) |r| {
        defer std.heap.c_allocator.free(r.v);
        vision_ms = r.ms;
        const bytes = std.mem.sliceAsBytes(r.v);
        R.ring_vm_api_retstring2(p, bytes.ptr, @intCast(bytes.len));
    } else |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("vision: {s}", .{@errorName(e)});
        R.ring_vm_api_retstring2(p, "", 0);
    }
}

// IM6 (MobileSAM): (cEncoder, cPixels, nW, nH, nC, nThreads) -> the id of the picture's embedding, kept in the
// engine for the prompts that follow (0 on failure)
fn ring_VisionSamEmbed(p: *anyopaque) callconv(.c) void {
    const g = R.ring_vm_api_getnumber;
    const th: c_int = @intFromFloat(g(p, 6));
    if (vis.samEmbed(ocrArg(p, 1), ocrArg(p, 2), @intFromFloat(g(p, 3)), @intFromFloat(g(p, 4)), @intFromFloat(g(p, 5)), if (th < 1) 4 else th)) |r| {
        vision_ms = r.ms;
        sam_last[2] = if (r.cached) 1 else 0;
        R.ring_vm_api_retnumber(p, @floatFromInt(r.id));
    } else |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("vision: {s}", .{@errorName(e)});
        R.ring_vm_api_retnumber(p, 0);
    }
}

var sam_last: [3]f64 = .{ 0, 0, 0 };

// IM6: (cDecoder, nId, x0, y0, x1, y1, nLabel0, nLabel1, nThreads) -> the mask, W x H bytes 0 or 255 ("" on
// failure). A point is (x0, y0) with label 1 (on the object) or 0 (off it) and label1 = -1; a box is its two
// corners with labels 2 and 3. StzEngineNeuralVisionSamLast() gives [predicted IoU, which of the four masks,
// 1 when the last embed found its picture already encoded].
fn ring_VisionSamMask(p: *anyopaque) callconv(.c) void {
    const g = R.ring_vm_api_getnumber;
    const th: c_int = @intFromFloat(g(p, 9));
    const pts = [4]f32{ @floatCast(g(p, 3)), @floatCast(g(p, 4)), @floatCast(g(p, 5)), @floatCast(g(p, 6)) };
    const labels = [2]f32{ @floatCast(g(p, 7)), @floatCast(g(p, 8)) };
    if (vis.samMask(ocrArg(p, 1), @intFromFloat(g(p, 2)), pts, labels, if (th < 1) 4 else th)) |r| {
        defer std.heap.c_allocator.free(r.px);
        vision_ms = r.ms;
        sam_last[0] = r.iou;
        sam_last[1] = @floatFromInt(r.which);
        R.ring_vm_api_retstring2(p, r.px.ptr, @intCast(r.px.len));
    } else |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("vision: {s}", .{@errorName(e)});
        R.ring_vm_api_retstring2(p, "", 0);
    }
}

fn ring_VisionSamLast(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, sam_last[0]);
    R.ring_list_adddouble(out, sam_last[1]);
    R.ring_list_adddouble(out, sam_last[2]);
    R.ring_vm_api_retlist(p, out);
}

fn ring_VisionSamFree(p: *anyopaque) callconv(.c) void {
    vis.samFree(@intFromFloat(R.ring_vm_api_getnumber(p, 1)));
    R.ring_vm_api_retnumber(p, 1);
}

// ---- IM7: a picture described in words (vlm.zig + the decoder's embedding entry) --------------------------

var vlm_ms: f64 = 0;

fn vlmRowsBytes(p: *anyopaque, proj: *const vlm.Projector, input: []const f32, th: c_int) void {
    const rows = std.heap.c_allocator.alloc(f32, proj.tokens() * proj.n_out) catch return R.ring_vm_api_retstring2(p, "", 0);
    defer std.heap.c_allocator.free(rows);
    const t0 = std.time.nanoTimestamp();
    vlm.encode(proj, input, th, rows) catch |e| {
        ocrg.setError("vlm: {s}", .{@errorName(e)});
        return R.ring_vm_api_retstring2(p, "", 0);
    };
    vlm_ms = @as(f64, @floatFromInt(std.time.nanoTimestamp() - t0)) / 1e6;
    const b = std.mem.sliceAsBytes(rows);
    R.ring_vm_api_retstring2(p, b.ptr, @intCast(b.len));
}

// (cProjector, cPixels, nW, nH, nC, nThreads) -> the picture's rows for the decoder, float32 bytes (tokens x
// width), "" on failure (StzEngineNeuralOcrGraphError says why)
fn ring_VlmEmbed(p: *anyopaque) callconv(.c) void {
    const g = R.ring_vm_api_getnumber;
    const proj = vlm.load(ocrArg(p, 1)) orelse {
        ocrg.setError("{s}", .{vlm.lastError()});
        return R.ring_vm_api_retstring2(p, "", 0);
    };
    const w: usize = @intFromFloat(g(p, 3));
    const h: usize = @intFromFloat(g(p, 4));
    const ch: usize = @intFromFloat(g(p, 5));
    const px = ocrArg(p, 2);
    if (w == 0 or h == 0 or ch == 0 or px.len != w * h * ch) {
        ocrg.setError("vlm: the pixels are not {d} x {d} x {d}", .{ w, h, ch });
        return R.ring_vm_api_retstring2(p, "", 0);
    }
    const input = std.heap.c_allocator.alloc(f32, 3 * proj.image * proj.image) catch return R.ring_vm_api_retstring2(p, "", 0);
    defer std.heap.c_allocator.free(input);
    vlm.pixelsFor(proj, px, w, h, ch, input) catch return R.ring_vm_api_retstring2(p, "", 0);
    const th: c_int = @intFromFloat(g(p, 6));
    vlmRowsBytes(p, proj, input, if (th < 1) 4 else th);
}

// (cProjector, cInputF32, nThreads) -> the rows for a tower input already prepared (3 x S x S float32 bytes,
// channel-major): parity with a reference's own preprocessing
fn ring_VlmEmbedInput(p: *anyopaque) callconv(.c) void {
    const proj = vlm.load(ocrArg(p, 1)) orelse {
        ocrg.setError("{s}", .{vlm.lastError()});
        return R.ring_vm_api_retstring2(p, "", 0);
    };
    const raw = ocrArg(p, 2);
    if (raw.len != 3 * proj.image * proj.image * 4) {
        ocrg.setError("vlm: the input is {d} bytes, not 3 x {d} x {d} floats", .{ raw.len, proj.image, proj.image });
        return R.ring_vm_api_retstring2(p, "", 0);
    }
    const input = std.heap.c_allocator.alloc(f32, 3 * proj.image * proj.image) catch return R.ring_vm_api_retstring2(p, "", 0);
    defer std.heap.c_allocator.free(input);
    @memcpy(std.mem.sliceAsBytes(input), raw);
    const th: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 3));
    vlmRowsBytes(p, proj, input, if (th < 1) 4 else th);
}

// (cBefore, cRows, cAfter, nMaxNew) -> 1 when the decoder (the loaded model) has read the text, the picture's
// rows and the text after it, and generation can go on with StzEngineNeuralGenNext; 0 otherwise
fn ring_VlmStart(p: *anyopaque) callconv(.c) void {
    const rows_b = ocrArg(p, 2);
    const n_embd = gen.embdWidth();
    if (n_embd == 0 or rows_b.len % (4 * n_embd) != 0) return R.ring_vm_api_retnumber(p, 0);
    const rows = std.heap.c_allocator.alloc(f32, rows_b.len / 4) catch return R.ring_vm_api_retnumber(p, 0);
    defer std.heap.c_allocator.free(rows);
    @memcpy(std.mem.sliceAsBytes(rows), rows_b);
    const ok = gen.startWithRows(ocrArg(p, 1), rows, rows.len / n_embd, ocrArg(p, 3), @intFromFloat(R.ring_vm_api_getnumber(p, 4)));
    R.ring_vm_api_retnumber(p, @floatFromInt(ok));
}

// (nTop) -> [ [ id, logit ], ... ] the decoder's most likely next tokens after the latest forward, best first
fn ring_VlmTop(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    defer R.ring_vm_api_retlist(p, out);
    const lg = gen.lastLogits();
    const n: usize = @min(lg.len, @as(usize, @intFromFloat(@max(0, R.ring_vm_api_getnumber(p, 1)))));
    var taken: [64]usize = undefined;
    for (0..@min(n, 64)) |k| {
        var best: usize = 0;
        var bv: f32 = -3.4e38;
        for (lg, 0..) |v, i| {
            var dup = false;
            for (taken[0..k]) |t| dup = dup or t == i;
            if (!dup and v > bv) {
                bv = v;
                best = i;
            }
        }
        taken[k] = best;
        const row = R.ring_list_newlist(out) orelse return;
        R.ring_list_adddouble(row, @floatFromInt(best));
        R.ring_list_adddouble(row, bv);
    }
}

// (nId) -> 1 when the decoder has read the token after the current sequence (teacher forcing), else 0
fn ring_VlmFeed(p: *anyopaque) callconv(.c) void {
    R.ring_vm_api_retnumber(p, if (gen.feedToken(@intFromFloat(R.ring_vm_api_getnumber(p, 1)))) 1 else 0);
}

// (cProjector, cPixels, nW, nH, nC, cBefore, cAfter, nMaxNew, nThreads) -> what the loaded decoder says about the
// picture between the two texts, greedy, until its end token or nMaxNew tokens ("" on failure, the error set).
// StzEngineNeuralVlmStats() then gives [ the picture's ms, the words' ms, the tokens made ]
var vlm_stats: [3]f64 = .{ 0, 0, 0 };

fn ring_VlmDescribe(p: *anyopaque) callconv(.c) void {
    const g = R.ring_vm_api_getnumber;
    const A = std.heap.c_allocator;
    const proj = vlm.load(ocrArg(p, 1)) orelse {
        ocrg.setError("{s}", .{vlm.lastError()});
        return R.ring_vm_api_retstring2(p, "", 0);
    };
    const w: usize = @intFromFloat(g(p, 3));
    const h: usize = @intFromFloat(g(p, 4));
    const ch: usize = @intFromFloat(g(p, 5));
    const px = ocrArg(p, 2);
    const th0: c_int = @intFromFloat(g(p, 9));
    const th: c_int = if (th0 < 1) 4 else th0;
    if (w == 0 or h == 0 or ch == 0 or px.len != w * h * ch) {
        ocrg.setError("vlm: the pixels are not {d} x {d} x {d}", .{ w, h, ch });
        return R.ring_vm_api_retstring2(p, "", 0);
    }
    if (gen.embdWidth() != proj.n_out) {
        ocrg.setError("vlm: the loaded decoder reads rows of {d}, the projector makes {d}", .{ gen.embdWidth(), proj.n_out });
        return R.ring_vm_api_retstring2(p, "", 0);
    }
    const input = A.alloc(f32, 3 * proj.image * proj.image) catch return R.ring_vm_api_retstring2(p, "", 0);
    defer A.free(input);
    const rows = A.alloc(f32, proj.tokens() * proj.n_out) catch return R.ring_vm_api_retstring2(p, "", 0);
    defer A.free(rows);
    const t0 = std.time.nanoTimestamp();
    vlm.pixelsFor(proj, px, w, h, ch, input) catch return R.ring_vm_api_retstring2(p, "", 0);
    vlm.encode(proj, input, th, rows) catch |e| {
        ocrg.setError("vlm: {s}", .{@errorName(e)});
        return R.ring_vm_api_retstring2(p, "", 0);
    };
    const t1 = std.time.nanoTimestamp();
    if (gen.startWithRows(ocrArg(p, 6), rows, proj.tokens(), ocrArg(p, 7), @intFromFloat(g(p, 8))) == 0) {
        ocrg.setError("vlm: the decoder refused the prompt (error {d})", .{gen.neural_gen_last_error()});
        return R.ring_vm_api_retstring2(p, "", 0);
    }
    var text: std.ArrayList(u8) = .{};
    defer text.deinit(A);
    var n: f64 = 0;
    while (gen.neural_gen_next() == 1) {
        n += 1;
        text.appendSlice(A, std.mem.span(gen.neural_gen_chunk())) catch break;
    }
    vlm_ms = @as(f64, @floatFromInt(t1 - t0)) / 1e6;
    vlm_stats = .{ vlm_ms, @as(f64, @floatFromInt(std.time.nanoTimestamp() - t1)) / 1e6, n };
    vision_ms = vlm_stats[0] + vlm_stats[1];
    R.ring_vm_api_retstring2(p, text.items.ptr, @intCast(text.items.len));
}

// ---- IM7 2 of 2: a PAGE (Granite-Docling) -- tiles, then the whole page, each view 64 rows ------------------

// (nW, nH, nLongest, nTile) -> [ rows, cols, canvas w, canvas h, views ] of the tiling Idefics3 makes of a page
// (rows and cols are 0 when the page is a single view)
fn ring_VlmGrid(p: *anyopaque) callconv(.c) void {
    const g = R.ring_vm_api_getnumber;
    const out = R.ring_vm_api_newlist(p) orelse return;
    defer R.ring_vm_api_retlist(p, out);
    const w: usize = @intFromFloat(g(p, 1));
    const h: usize = @intFromFloat(g(p, 2));
    const longest: usize = @intFromFloat(g(p, 3));
    const tile: usize = @intFromFloat(g(p, 4));
    if (w == 0 or h == 0 or longest == 0 or tile == 0) return;
    const gr = vlm.gridFor(w, h, longest, tile);
    for ([_]usize{ gr.rows, gr.cols, gr.w, gr.h, gr.views() }) |v| R.ring_list_adddouble(out, @floatFromInt(v));
}

// (cProjector, cPixels, nW, nH, nC, nLongest) -> the page's views for the tower, float32 bytes (views x 3 x S x S,
// channel-major, the tiles row by row and the whole page last), "" on failure: parity with a reference's pixels
fn ring_VlmPageViews(p: *anyopaque) callconv(.c) void {
    const g = R.ring_vm_api_getnumber;
    const A = std.heap.c_allocator;
    const proj = vlm.load(ocrArg(p, 1)) orelse {
        ocrg.setError("{s}", .{vlm.lastError()});
        return R.ring_vm_api_retstring2(p, "", 0);
    };
    const w: usize = @intFromFloat(g(p, 3));
    const h: usize = @intFromFloat(g(p, 4));
    const ch: usize = @intFromFloat(g(p, 5));
    const px = ocrArg(p, 2);
    const longest: usize = @intFromFloat(g(p, 6));
    if (w == 0 or h == 0 or ch == 0 or longest == 0 or px.len != w * h * ch) {
        ocrg.setError("vlm: the pixels are not {d} x {d} x {d}", .{ w, h, ch });
        return R.ring_vm_api_retstring2(p, "", 0);
    }
    const gr = vlm.gridFor(w, h, longest, proj.image);
    const buf = A.alloc(f32, gr.views() * 3 * proj.image * proj.image) catch return R.ring_vm_api_retstring2(p, "", 0);
    defer A.free(buf);
    _ = vlm.pageViews(proj, px, w, h, ch, longest, buf) catch |e| {
        ocrg.setError("vlm: {s}", .{@errorName(e)});
        return R.ring_vm_api_retstring2(p, "", 0);
    };
    const b = std.mem.sliceAsBytes(buf);
    R.ring_vm_api_retstring2(p, b.ptr, @intCast(b.len));
}

// (cProjector, cPixels, nW, nH, nC, nLongest, cTexts, nMaxNew, nThreads) -> what the loaded decoder says about the
// page, greedy, until its end token or nMaxNew tokens ("" on failure, the error set). cTexts is the prompt's texts
// joined by char(31): the text before the first view, between each two views, and after the last (one more than
// the views). StzEngineNeuralVlmStats() then gives [ the views' ms, the words' ms, the tokens made ].
// nMaxNew -1 only reads the prompt ("1"), -2 returns the views' rows instead of words: a guard's instruments
fn ring_VlmPage(p: *anyopaque) callconv(.c) void {
    const g = R.ring_vm_api_getnumber;
    const A = std.heap.c_allocator;
    const proj = vlm.load(ocrArg(p, 1)) orelse {
        ocrg.setError("{s}", .{vlm.lastError()});
        return R.ring_vm_api_retstring2(p, "", 0);
    };
    const w: usize = @intFromFloat(g(p, 3));
    const h: usize = @intFromFloat(g(p, 4));
    const ch: usize = @intFromFloat(g(p, 5));
    const px = ocrArg(p, 2);
    const longest: usize = @intFromFloat(g(p, 6));
    const th0: c_int = @intFromFloat(g(p, 9));
    const th: c_int = if (th0 < 1) 4 else th0;
    if (w == 0 or h == 0 or ch == 0 or longest == 0 or px.len != w * h * ch) {
        ocrg.setError("vlm: the pixels are not {d} x {d} x {d}", .{ w, h, ch });
        return R.ring_vm_api_retstring2(p, "", 0);
    }
    if (gen.embdWidth() != proj.n_out) {
        ocrg.setError("vlm: the loaded decoder reads rows of {d}, the projector makes {d}", .{ gen.embdWidth(), proj.n_out });
        return R.ring_vm_api_retstring2(p, "", 0);
    }
    const gr = vlm.gridFor(w, h, longest, proj.image);
    const nv = gr.views();
    const view_n = 3 * proj.image * proj.image;
    const per = proj.tokens() * proj.n_out;
    const inputs = A.alloc(f32, nv * view_n) catch return R.ring_vm_api_retstring2(p, "", 0);
    defer A.free(inputs);
    const rows = A.alloc(f32, nv * per) catch return R.ring_vm_api_retstring2(p, "", 0);
    defer A.free(rows);
    const t0 = std.time.nanoTimestamp();
    _ = vlm.pageViews(proj, px, w, h, ch, longest, inputs) catch |e| {
        ocrg.setError("vlm: {s}", .{@errorName(e)});
        return R.ring_vm_api_retstring2(p, "", 0);
    };
    for (0..nv) |v| {
        vlm.encode(proj, inputs[v * view_n ..][0..view_n], th, rows[v * per ..][0..per]) catch |e| {
            ocrg.setError("vlm: {s}", .{@errorName(e)});
            return R.ring_vm_api_retstring2(p, "", 0);
        };
    }
    const t1 = std.time.nanoTimestamp();
    // nMaxNew -2: no words, the views' rows themselves (float32 bytes, views x 64 x width): a guard's parity
    if (g(p, 8) == -2) {
        const b = std.mem.sliceAsBytes(rows);
        return R.ring_vm_api_retstring2(p, b.ptr, @intCast(b.len));
    }
    var texts: std.ArrayList([]const u8) = .{};
    defer texts.deinit(A);
    var it = std.mem.splitScalar(u8, ocrArg(p, 7), 31);
    while (it.next()) |t| texts.append(A, t) catch return R.ring_vm_api_retstring2(p, "", 0);
    if (texts.items.len != nv + 1) {
        ocrg.setError("vlm: the page has {d} views, so the prompt needs {d} texts, not {d}", .{ nv, nv + 1, texts.items.len });
        return R.ring_vm_api_retstring2(p, "", 0);
    }
    if (gen.startWithSegments(texts.items, rows, proj.tokens(), @intFromFloat(g(p, 8))) == 0) {
        ocrg.setError("vlm: the decoder refused the prompt (error {d})", .{gen.neural_gen_last_error()});
        return R.ring_vm_api_retstring2(p, "", 0);
    }
    // nMaxNew -1: the decoder has only read the prompt; "1" says so, and StzEngineNeuralVlmTop / Feed go on from
    // there (a guard's teacher forcing)
    if (g(p, 8) == -1) return R.ring_vm_api_retstring2(p, "1", 1);
    var text: std.ArrayList(u8) = .{};
    defer text.deinit(A);
    var n: f64 = 0;
    while (gen.neural_gen_next() == 1) {
        n += 1;
        text.appendSlice(A, std.mem.span(gen.neural_gen_chunk())) catch break;
    }
    vlm_ms = @as(f64, @floatFromInt(t1 - t0)) / 1e6;
    vlm_stats = .{ vlm_ms, @as(f64, @floatFromInt(std.time.nanoTimestamp() - t1)) / 1e6, n };
    vision_ms = vlm_stats[0] + vlm_stats[1];
    R.ring_vm_api_retstring2(p, text.items.ptr, @intCast(text.items.len));
}

// IM8a: (nOn) the vision tower on the GPU (1) or on the CPU graph (0); the answer is the setting now
fn ring_VisionGpu(p: *anyopaque) callconv(.c) void {
    const a = R.ring_vm_api_getnumber(p, 1);
    if (a >= 0) nvit.setEnabled(a >= 1);
    R.ring_vm_api_retnumber(p, if (nvit.enabled()) 1 else 0);
}

// IM8a profiling: (nMask) leave out kernel families (1 attention, 2 LayerNorm, 4 GELU, 8 add, 16 matmul); 0 puts everything back
fn ring_VisionGpuSkip(p: *anyopaque) callconv(.c) void {
    nvit.setSkip(@intFromFloat(@max(0, R.ring_vm_api_getnumber(p, 1))));
    R.ring_vm_api_retnumber(p, 0);
}

// () -> the GPU layer's first error of the last GPU tower call ("" when none)
fn ring_VisionGpuMessage(p: *anyopaque) callconv(.c) void {
    const m = nvit.message();
    R.ring_vm_api_retstring2(p, m.ptr, @intCast(m.len));
}

// () -> [ views the GPU tower made, the milliseconds of the last one, the stage the last call reached (10 = done) ]
fn ring_VisionGpuStats(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, nvit.viewsDone());
    R.ring_list_adddouble(out, nvit.lastMs());
    R.ring_list_adddouble(out, nvit.stage());
    R.ring_list_adddouble(out, nvit.failedStep());
    for (nvit.phases()) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

// () -> [ the picture's ms, the words' ms, tokens made ] of the last StzEngineNeuralVlmDescribe
fn ring_VlmStats(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (vlm_stats) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

// (cA, cB) -> [ cosine, largest difference, largest magnitude in cA ] of two float32 buffers of one length
// ([] otherwise): a guard's parity with a reference's output
fn ring_F32Compare(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    defer R.ring_vm_api_retlist(p, out);
    const a = ocrArg(p, 1);
    const b = ocrArg(p, 2);
    if (a.len != b.len or a.len == 0 or a.len % 4 != 0) return;
    var dot: f64 = 0;
    var na: f64 = 0;
    var nb: f64 = 0;
    var dmax: f64 = 0;
    var amax: f64 = 0;
    var i: usize = 0;
    while (i < a.len) : (i += 4) {
        const x: f64 = std.mem.bytesToValue(f32, a[i..][0..4]);
        const y: f64 = std.mem.bytesToValue(f32, b[i..][0..4]);
        dot += x * y;
        na += x * x;
        nb += y * y;
        dmax = @max(dmax, @abs(x - y));
        amax = @max(amax, @abs(x));
    }
    R.ring_list_adddouble(out, if (na > 0 and nb > 0) dot / @sqrt(na * nb) else 0);
    R.ring_list_adddouble(out, dmax);
    R.ring_list_adddouble(out, amax);
}

// () -> the milliseconds the last picture took to become rows
fn ring_VlmLastMs(p: *anyopaque) callconv(.c) void {
    R.ring_vm_api_retnumber(p, vlm_ms);
}

// IM5: (cModel, cText) -> the token ids the text model reads (padded to its fixed length)
fn ring_VisionTokens(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    if (vis.tokens(ocrArg(p, 1), ocrArg(p, 2))) |ids| {
        defer std.heap.c_allocator.free(ids);
        for (ids) |x| R.ring_list_adddouble(out, @floatFromInt(x));
    } else |e| {
        if (ocrg.lastError().len == 0) ocrg.setError("vision: {s}", .{@errorName(e)});
    }
    R.ring_vm_api_retlist(p, out);
}

// the compute time of the last vision call, ms
fn ring_VisionMs(p: *anyopaque) callconv(.c) void {
    R.ring_vm_api_retnumber(p, vision_ms);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineneuralocrgraphinfo", .func = &ring_OcrGraphInfo },
    .{ .name = "stzengineneuralocrgraphparity", .func = &ring_OcrGraphParity },
    .{ .name = "stzengineneuralocrgrapherror", .func = &ring_OcrGraphError },
    .{ .name = "stzengineneuralvisionclassify", .func = &ring_VisionClassify },
    .{ .name = "stzengineneuralvisionfaces", .func = &ring_VisionFaces },
    .{ .name = "stzengineneuralvisionobjects", .func = &ring_VisionObjects },
    .{ .name = "stzengineneuralvisionms", .func = &ring_VisionMs },
    .{ .name = "stzengineneuralvisionembedimage", .func = &ring_VisionEmbedImage },
    .{ .name = "stzengineneuralvisionembedtext", .func = &ring_VisionEmbedText },
    .{ .name = "stzengineneuralvisiontokens", .func = &ring_VisionTokens },
    .{ .name = "stzengineneuralvisionsaliency", .func = &ring_VisionSaliency },
    .{ .name = "stzengineneuralvisiondepth", .func = &ring_VisionDepth },
    .{ .name = "stzengineneuralvisionsamembed", .func = &ring_VisionSamEmbed },
    .{ .name = "stzengineneuralvisionsammask", .func = &ring_VisionSamMask },
    .{ .name = "stzengineneuralvisionsamlast", .func = &ring_VisionSamLast },
    .{ .name = "stzengineneuralvisionsamfree", .func = &ring_VisionSamFree },
    .{ .name = "stzengineneuralvlmembed", .func = &ring_VlmEmbed },
    .{ .name = "stzengineneuralvlmembedinput", .func = &ring_VlmEmbedInput },
    .{ .name = "stzengineneuralvlmstart", .func = &ring_VlmStart },
    .{ .name = "stzengineneuralvlmtop", .func = &ring_VlmTop },
    .{ .name = "stzengineneuralvlmlastms", .func = &ring_VlmLastMs },
    .{ .name = "stzengineneuralvlmfeed", .func = &ring_VlmFeed },
    .{ .name = "stzengineneuralvlmdescribe", .func = &ring_VlmDescribe },
    .{ .name = "stzengineneuralvisiongpu", .func = &ring_VisionGpu },
    .{ .name = "stzengineneuralvisiongpustats", .func = &ring_VisionGpuStats },
    .{ .name = "stzengineneuralvisiongpumessage", .func = &ring_VisionGpuMessage },
    .{ .name = "stzengineneuralvisiongpuskip", .func = &ring_VisionGpuSkip },
    .{ .name = "stzengineneuralvlmgrid", .func = &ring_VlmGrid },
    .{ .name = "stzengineneuralvlmpageviews", .func = &ring_VlmPageViews },
    .{ .name = "stzengineneuralvlmpage", .func = &ring_VlmPage },
    .{ .name = "stzengineneuralvlmstats", .func = &ring_VlmStats },
    .{ .name = "stzengineneuralf32compare", .func = &ring_F32Compare },
    .{ .name = "stzengineneuralocrread", .func = &ring_OcrRead },
    .{ .name = "stzengineneuralocrreadwith", .func = &ring_OcrReadWith },
    .{ .name = "stzengineneuralocrstats", .func = &ring_OcrStats },
    .{ .name = "stzengineneuralocrmarks", .func = &ring_OcrMarks },
    .{ .name = "stzengineneuralocrdeskew", .func = &ring_OcrDeskew },
    .{ .name = "stzengineneuralocrprepare", .func = &ring_OcrPrepare },
    .{ .name = "stzengineneuralocrdarkbands", .func = &ring_OcrDarkBands },
    .{ .name = "stzengineneuralocrfigures", .func = &ring_OcrFigures },
    .{ .name = "stzengineneuralocrwipedrawn", .func = &ring_OcrWipeDrawn },
    .{ .name = "stzengineneuralocrregion", .func = &ring_OcrRegion },
    .{ .name = "stzengineneuralocrplatformread", .func = &ring_OcrPlatformRead },
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
    .{ .name = "stzengineneuralbackbonesetweightsf16", .func = &ring_BackboneSetWeightsF16 },
    .{ .name = "stzengineneuralbackbonedispatches", .func = &ring_BackboneDispatches },
    .{ .name = "stzengineneuralbackboneweightsf16", .func = &ring_BackboneWeightsF16 },
    .{ .name = "stzengineneuralbackbonef16available", .func = &ring_BackboneF16Available },
    .{ .name = "stzengineneuralbackboneweightbytes", .func = &ring_BackboneWeightBytes },
    .{ .name = "stzengineneuralbackbonemintokens", .func = &ring_BackboneMinTokens },
    .{ .name = "stzengineneuralbackboneroutecount", .func = &ring_BackboneRouteCount },
    .{ .name = "stzengineneuralbackboneroutereset", .func = &ring_BackboneRouteReset },
    .{ .name = "stzengineneuralattentionfoundry", .func = &ring_AttentionFoundry },
    .{ .name = "stzengineneuralattentionfoundryresult", .func = &ring_AttentionFoundryResult },
    .{ .name = "stzengineneuralattentionvariantname", .func = &ring_AttentionVariantName },
    .{ .name = "stzengineneuralattentionvariantused", .func = &ring_AttentionVariantUsed },
    .{ .name = "stzengineneuralvariantset", .func = &ring_NeuralVariantSet },
    .{ .name = "stzengineneuralvariantget", .func = &ring_NeuralVariantGet },
    .{ .name = "stzengineneuralvariantclear", .func = &ring_NeuralVariantClear },
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
    .{ .name = "stzengineneuralmodelloadstatus", .func = &ring_NeuralModelLoadStatus },
    .{ .name = "stzenginemodeldigest", .func = &ring_ModelDigest },
    .{ .name = "stzenginemodelexpect", .func = &ring_ModelExpect },
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
    .{ .name = "stzengineneuralgencontextwindow", .func = &ring_NeuralGenContextWindow },
    .{ .name = "stzengineneuralgensetcontextlimit", .func = &ring_NeuralGenSetContextLimit },
    .{ .name = "stzengineneuralgenlasterror", .func = &ring_NeuralGenLastError },
    .{ .name = "stzengineneuralgentruncated", .func = &ring_NeuralGenTruncated },
    .{ .name = "stzengineneuralgenprompttokens", .func = &ring_NeuralGenPromptTokens },
    .{ .name = "stzengineneuralgenlastpool", .func = &ring_NeuralGenLastPool },
    .{ .name = "stzengineneuralsettermination", .func = &ring_NeuralSetTermination },
    .{ .name = "stzengineneuralcleartermination", .func = &ring_NeuralClearTermination },
    .{ .name = "stzengineneuralstoppedonrepeat", .func = &ring_NeuralStoppedOnRepeat },
    .{ .name = "stzengineneuralprefilllogits", .func = &ring_NeuralPrefillLogits },
    .{ .name = "stzengineneurallogitat", .func = &ring_NeuralLogitAt },
    .{ .name = "stzengineneurallogitlse", .func = &ring_NeuralLogitLse },
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

// StzEngineNeuralGenContextWindow() -> tokens the loaded generator can hold (0 if none)
fn ring_NeuralGenContextWindow(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gen.neural_gen_context_window()));
}

// StzEngineNeuralGenSetContextLimit(n) -> the window now in force (0 restores the trained context)
fn ring_NeuralGenSetContextLimit(p: *anyopaque) callconv(.c) void {
    const n: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 1));
    rn(p, @floatFromInt(gen.neural_gen_set_context_limit(n)));
}

// StzEngineNeuralGenLastError() -> 0 none, 1 no generator, 2 prompt does not fit the window, 3 forward pass failed
fn ring_NeuralGenLastError(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gen.neural_gen_last_error()));
}

// StzEngineNeuralGenTruncated() -> 1 when the last generation stopped because the window filled
fn ring_NeuralGenTruncated(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gen.neural_gen_truncated()));
}

// StzEngineNeuralGenPromptTokens() -> tokens in the last prompt handed to a start
fn ring_NeuralGenPromptTokens(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gen.neural_gen_last_prompt_tokens()));
}

// StzEngineNeuralSetTermination(nRepeatPenalty, nRepeatLastN, nStopOnRepeat, nEndBias)
fn ring_NeuralSetTermination(p: *anyopaque) callconv(.c) void {
    const rp: f64 = R.ring_vm_api_getnumber(p, 1);
    const rl: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 2));
    const sr: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 3));
    const eb: f64 = R.ring_vm_api_getnumber(p, 4);
    gen.neural_gen_set_termination(rp, rl, sr, eb);
    rn(p, 1);
}

fn ring_NeuralClearTermination(p: *anyopaque) callconv(.c) void {
    gen.neural_gen_clear_termination();
    rn(p, 1);
}

// StzEngineNeuralStoppedOnRepeat() -> 1 when the last generation was ended by stop-on-repeat
fn ring_NeuralStoppedOnRepeat(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gen.neural_gen_stopped_on_repeat()));
}

// StzEngineNeuralPrefillLogits(cPrompt) -> 1 when the prompt was prefilled and its next-token logits are kept
fn ring_NeuralPrefillLogits(p: *anyopaque) callconv(.c) void {
    const prompt = gs(p, 1);
    const plen: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    rn(p, @floatFromInt(gen.neural_gen_prefill_logits(prompt, plen)));
}

// StzEngineNeuralLogitAt(nTokenId) -> that token's logit after the last prefill
fn ring_NeuralLogitAt(p: *anyopaque) callconv(.c) void {
    const id: c_int = @intFromFloat(R.ring_vm_api_getnumber(p, 1));
    rn(p, gen.neural_gen_logit_at(id));
}

// StzEngineNeuralLogitLse() -> log-sum-exp of all logits (the softmax normaliser)
fn ring_NeuralLogitLse(p: *anyopaque) callconv(.c) void {
    rn(p, gen.neural_gen_logit_lse());
}

// StzEngineNeuralGenLastPool() -> bytes the last forward pass's graph needed
fn ring_NeuralGenLastPool(p: *anyopaque) callconv(.c) void {
    rn(p, gen.neural_gen_last_pool_bytes());
}

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
