#!/usr/bin/env python3
"""granite_docling_reference.py -- what Granite-Docling-258M says about a page, computed by Hugging Face's own code (IM7, 2 of 2).

THE REFERENCE IS NOT OURS: the model is transformers' Idefics3ForConditionalGeneration and the pixels are
transformers' Idefics3ImageProcessorPil (the page is resized to 2048 on its long side, then cut into 512 x 512
tiles, plus one global 512 x 512 view), loaded with the weights of the very GGUF files the engine runs (Q8_0,
dequantized by gguf_read.py). The prompt is tokenized by a `tokenizers` BPE built from the GGUF's own vocabulary
and merges -- an independent tokenizer, so the engine's is checked too. The prompt's picture part is the one
Idefics3Processor.replace_image_token builds (a row/column tag, 64 <image>, a newline after each row of tiles,
then the global view).

    <docling venv>/python -I granite_docling_reference.py <models src> <page.png> [<page.png> ...]

For each page writes, in <models src>/parity/granite/:
  <name>_px.f32      the processor's tiles, n x 3 x 512 x 512 float32, channel-major (the global view LAST)
  <name>_feat.f32    the connector's output, n x 64 x 576 float32: what the decoder receives for the tiles
  <name>_ref.txt     rows and cols, the prompt's ids, the top 5 next tokens with their logits, N_GEN greedy tokens and text
"""
import os
import sys

import numpy as np
import torch
from PIL import Image
from tokenizers import Tokenizer, decoders, models, pre_tokenizers, AddedToken
from transformers import Idefics3Config, Idefics3ForConditionalGeneration
from transformers.models.idefics3 import Idefics3ImageProcessorPil

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gguf_read import GGUF  # noqa: E402

REQUEST = "Convert this page to docling."
N_GEN = 60


def unpermute(w, n_head):
    # llama.cpp's converter permutes Q and K rows so that interleaved rope applies; undo it for HF's layout
    d0 = w.shape[0]
    return w.reshape(n_head, d0 // n_head // 2, 2, *w.shape[1:]).swapaxes(1, 2).reshape(w.shape)


def build(src):
    lm = GGUF(os.path.join(src, "granite_docling_258m", "granite-docling-258M-Q8_0.gguf"))
    mp = GGUF(os.path.join(src, "granite_docling_258m", "mmproj-granite-docling-258M-Q8_0.gguf"))
    toks = lm.meta["tokenizer.ggml.tokens"]
    vocab = {t: i for i, t in enumerate(toks)}
    nh = lm.meta["llama.attention.head_count"]
    nkv = lm.meta["llama.attention.head_count_kv"]
    cfg = Idefics3Config(
        vision_config=dict(hidden_size=768, intermediate_size=3072, num_hidden_layers=mp.meta["clip.vision.block_count"],
                           num_attention_heads=12, patch_size=16, image_size=512,
                           layer_norm_eps=mp.meta["clip.vision.attention.layer_norm_epsilon"], hidden_act="gelu_pytorch_tanh"),
        text_config=dict(model_type="llama", hidden_size=576, intermediate_size=1536,
                         num_hidden_layers=lm.meta["llama.block_count"], num_attention_heads=nh, num_key_value_heads=nkv,
                         rms_norm_eps=lm.meta["llama.attention.layer_norm_rms_epsilon"],
                         rope_theta=lm.meta["llama.rope.freq_base"], vocab_size=len(toks), max_position_embeddings=8192,
                         tie_word_embeddings=True, head_dim=64),
        scale_factor=mp.meta["clip.vision.projector.scale_factor"], image_token_id=vocab["<image>"],
        tie_word_embeddings=True)
    model = Idefics3ForConditionalGeneration(cfg).eval()
    sd = {}
    V = "model.vision_model."
    sd[V + "embeddings.patch_embedding.weight"] = mp.tensor("v.patch_embd.weight")
    sd[V + "embeddings.patch_embedding.bias"] = mp.tensor("v.patch_embd.bias")
    sd[V + "embeddings.position_embedding.weight"] = mp.tensor("v.position_embd.weight")
    for L in range(cfg.vision_config.num_hidden_layers):
        b, h = "v.blk.%d." % L, V + "encoder.layers.%d." % L
        for g, t in (("attn_q", "self_attn.q_proj"), ("attn_k", "self_attn.k_proj"), ("attn_v", "self_attn.v_proj"),
                     ("attn_out", "self_attn.out_proj"), ("ln1", "layer_norm1"), ("ln2", "layer_norm2")):
            sd[h + t + ".weight"] = mp.tensor(b + g + ".weight")
            sd[h + t + ".bias"] = mp.tensor(b + g + ".bias")
        # this mmproj names the MLP's two layers the other way round; their SHAPES say which is which
        for g in ("ffn_up", "ffn_down"):
            w = mp.tensor(b + g + ".weight")
            t = "mlp.fc1" if w.shape[0] == 3072 else "mlp.fc2"
            sd[h + t + ".weight"] = w
            sd[h + t + ".bias"] = mp.tensor(b + g + ".bias")
    sd[V + "post_layernorm.weight"] = mp.tensor("v.post_ln.weight")
    sd[V + "post_layernorm.bias"] = mp.tensor("v.post_ln.bias")
    sd["model.connector.modality_projection.proj.weight"] = mp.tensor("mm.model.fc.weight")
    T = "model.text_model."
    sd[T + "embed_tokens.weight"] = lm.tensor("token_embd.weight")
    sd[T + "norm.weight"] = lm.tensor("output_norm.weight")
    # no output.weight in this GGUF: the output matrix IS the embedding (tied)
    for L in range(cfg.text_config.num_hidden_layers):
        b, h = "blk.%d." % L, T + "layers.%d." % L
        sd[h + "self_attn.q_proj.weight"] = unpermute(lm.tensor(b + "attn_q.weight"), nh)
        sd[h + "self_attn.k_proj.weight"] = unpermute(lm.tensor(b + "attn_k.weight"), nkv)
        sd[h + "self_attn.v_proj.weight"] = lm.tensor(b + "attn_v.weight")
        sd[h + "self_attn.o_proj.weight"] = lm.tensor(b + "attn_output.weight")
        sd[h + "mlp.gate_proj.weight"] = lm.tensor(b + "ffn_gate.weight")
        sd[h + "mlp.up_proj.weight"] = lm.tensor(b + "ffn_up.weight")
        sd[h + "mlp.down_proj.weight"] = lm.tensor(b + "ffn_down.weight")
        sd[h + "input_layernorm.weight"] = lm.tensor(b + "attn_norm.weight")
        sd[h + "post_attention_layernorm.weight"] = lm.tensor(b + "ffn_norm.weight")
    missing, unexpected = model.load_state_dict({k: torch.from_numpy(np.ascontiguousarray(v)) for k, v in sd.items()},
                                                strict=False)
    model.tie_weights()
    assert not unexpected and not [k for k in missing if "rotary" not in k and "lm_head" not in k], (missing, unexpected)
    assert torch.equal(model.lm_head.weight, model.model.text_model.embed_tokens.weight)
    # the tokenizer, from the GGUF's vocabulary and merges
    merges = [tuple(m.split(" ", 1)) for m in lm.meta["tokenizer.ggml.merges"]]
    tk = Tokenizer(models.BPE(vocab, merges))
    tk.pre_tokenizer = pre_tokenizers.Sequence([pre_tokenizers.Digits(individual_digits=False),
                                                pre_tokenizers.ByteLevel(add_prefix_space=False, use_regex=True)])
    tk.decoder = decoders.ByteLevel()
    types = lm.meta["tokenizer.ggml.token_type"]
    tk.add_special_tokens([AddedToken(t, special=True, normalized=False) for i, t in enumerate(toks) if types[i] in (3, 4)])
    return model, tk, vocab


def picture_text(rows, cols):
    # Idefics3Processor.replace_image_token, with 64 <image> per view
    if rows == 0 and cols == 0:
        return "<fake_token_around_image><global-img>" + "<image>" * 64 + "<fake_token_around_image>"
    s = ""
    for r in range(rows):
        for c in range(cols):
            s += "<fake_token_around_image><row_%d_col_%d>" % (r + 1, c + 1) + "<image>" * 64
        s += "\n"
    return s + "\n<fake_token_around_image><global-img>" + "<image>" * 64 + "<fake_token_around_image>"


def prompt_text(rows, cols):
    return ("<|start_of_role|>user<|end_of_role|>" + picture_text(rows, cols) + REQUEST +
            "<|end_of_text|>\n<|start_of_role|>assistant<|end_of_role|>")


def main():
    src = sys.argv[1]
    out = os.path.join(src, "parity", "granite")
    os.makedirs(out, exist_ok=True)
    model, tk, vocab = build(src)
    proc = Idefics3ImageProcessorPil(do_image_splitting=True, size={"longest_edge": 2048},
                                     max_image_size={"longest_edge": 512})
    eot = vocab["<|end_of_text|>"]
    for path in sys.argv[2:]:
        name = os.path.splitext(os.path.basename(path))[0]
        r = proc(images=[Image.open(path).convert("RGB")], return_tensors="pt", return_row_col_info=True)
        px = r["pixel_values"]                      # (1, n tiles + 1, 3, 512, 512)
        mask = r["pixel_attention_mask"]
        rows, cols = int(r["rows"][0][0]), int(r["cols"][0][0])
        np.ascontiguousarray(px[0].numpy(), dtype=np.float32).tofile(os.path.join(out, name + "_px.f32"))
        ids = tk.encode(prompt_text(rows, cols)).ids
        assert ids.count(vocab["<image>"]) == 64 * (rows * cols + 1), (rows, cols, ids.count(vocab["<image>"]))
        with torch.no_grad():
            feat = model.model.get_image_features(pixel_values=px, pixel_attention_mask=mask)
            feat = getattr(feat, "pooler_output", feat)
            if isinstance(feat, (list, tuple)):
                feat = torch.cat([f.reshape(-1, 576) for f in feat])
            feat = feat.reshape(-1, 576)
            np.ascontiguousarray(feat.numpy(), dtype=np.float32).tofile(os.path.join(out, name + "_feat.f32"))
            inp = torch.tensor([ids])
            o = model(input_ids=inp, pixel_values=px, pixel_attention_mask=mask)
            last = o.logits[0, -1]
            top = torch.topk(last, 5)
            gen = model.generate(input_ids=inp, pixel_values=px, pixel_attention_mask=mask, max_new_tokens=N_GEN,
                                 do_sample=False, eos_token_id=eot, pad_token_id=eot)[0, len(ids):].tolist()
        text = tk.decode(gen, skip_special_tokens=False)
        with open(os.path.join(out, name + "_ref.txt"), "w", encoding="utf-8", newline="\n") as f:
            f.write("grid %d %d\n" % (rows, cols))
            f.write("ids " + " ".join(map(str, ids)) + "\n")
            f.write("top " + " ".join("%d:%.4f" % (i, v) for i, v in zip(top.indices.tolist(), top.values.tolist())) + "\n")
            f.write("gen " + " ".join(map(str, gen)) + "\n")
            f.write("text " + text.replace("\n", " ") + "\n")
        print(name, rows, cols, "->", text)


if __name__ == "__main__":
    main()
