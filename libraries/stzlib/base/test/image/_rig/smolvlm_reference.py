#!/usr/bin/env python3
"""smolvlm_reference.py -- what SmolVLM-256M says about a picture, computed by Hugging Face's own code (IM7).

THE REFERENCE IS NOT OURS: the model is transformers' SmolVLMForConditionalGeneration and the pixels are
transformers' SmolVLMImageProcessorPil (no tiling: one 512 x 512 view), loaded with the weights of the very
GGUF files the engine runs (Q8_0, dequantized by gguf_read.py). The prompt is tokenized by a `tokenizers` BPE
built from the GGUF's own vocabulary and merges -- an independent tokenizer, so the engine's is checked too.

    <docling venv>/python -I smolvlm_reference.py <models src> <photo> [<photo> ...]

For each photo writes, in <models src>/parity/smolvlm/:
  <name>_px.f32      the processor's pixels, 3 x 512 x 512 float32, channel-major
  <name>_feat.f32    the connector's output, 64 x 576 float32: what the decoder receives for the picture
  <name>_ref.txt     the prompt's ids, the top 5 next tokens with their logits, and 40 greedy tokens and text
"""
import os
import sys

import numpy as np
import torch
from PIL import Image
from tokenizers import Tokenizer, decoders, models, pre_tokenizers, AddedToken
from transformers import SmolVLMConfig, SmolVLMForConditionalGeneration
from transformers.models.smolvlm import SmolVLMImageProcessorPil

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gguf_read import GGUF  # noqa: E402

PROMPT = "Describe this image."
N_GEN = 40


def unpermute(w, n_head):
    # llama.cpp's converter permutes Q and K rows so that interleaved rope applies; undo it for HF's layout
    d0 = w.shape[0]
    return w.reshape(n_head, d0 // n_head // 2, 2, *w.shape[1:]).swapaxes(1, 2).reshape(w.shape)


def build(src):
    lm = GGUF(os.path.join(src, "smolvlm_256m", "SmolVLM-256M-Instruct-Q8_0.gguf"))
    mp = GGUF(os.path.join(src, "smolvlm_256m", "mmproj-SmolVLM-256M-Instruct-Q8_0.gguf"))
    toks = lm.meta["tokenizer.ggml.tokens"]
    vocab = {t: i for i, t in enumerate(toks)}
    nh = lm.meta["llama.attention.head_count"]
    nkv = lm.meta["llama.attention.head_count_kv"]
    cfg = SmolVLMConfig(
        vision_config=dict(hidden_size=768, intermediate_size=3072, num_hidden_layers=mp.meta["clip.vision.block_count"],
                           num_attention_heads=12, patch_size=16, image_size=512,
                           layer_norm_eps=mp.meta["clip.vision.attention.layer_norm_epsilon"], hidden_act="gelu_pytorch_tanh"),
        text_config=dict(model_type="llama", hidden_size=576, intermediate_size=1536,
                         num_hidden_layers=lm.meta["llama.block_count"], num_attention_heads=nh, num_key_value_heads=nkv,
                         rms_norm_eps=lm.meta["llama.attention.layer_norm_rms_epsilon"],
                         rope_theta=lm.meta["llama.rope.freq_base"], vocab_size=len(toks), max_position_embeddings=8192,
                         tie_word_embeddings=False, head_dim=64),
        scale_factor=mp.meta["clip.vision.projector.scale_factor"], image_token_id=vocab["<image>"],
        tie_word_embeddings=False)
    model = SmolVLMForConditionalGeneration(cfg).eval()
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
    sd["lm_head.weight"] = lm.tensor("output.weight")
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
    assert not unexpected and not [k for k in missing if "rotary" not in k], (missing, unexpected)
    # the tokenizer, from the GGUF's vocabulary and merges
    merges = [tuple(m.split(" ", 1)) for m in lm.meta["tokenizer.ggml.merges"]]
    tk = Tokenizer(models.BPE(vocab, merges))
    tk.pre_tokenizer = pre_tokenizers.Sequence([pre_tokenizers.Digits(individual_digits=True),
                                                pre_tokenizers.ByteLevel(add_prefix_space=False, use_regex=True)])
    tk.decoder = decoders.ByteLevel()
    types = lm.meta["tokenizer.ggml.token_type"]
    tk.add_special_tokens([AddedToken(t, special=True, normalized=False) for i, t in enumerate(toks) if types[i] in (3, 4)])
    return model, tk, vocab


def prompt_text():
    return ("<|im_start|>User:<fake_token_around_image><global-img>" + "<image>" * 64 +
            "<fake_token_around_image>" + PROMPT + "<end_of_utterance>\nAssistant:")


def main():
    src = sys.argv[1]
    out = os.path.join(src, "parity", "smolvlm")
    os.makedirs(out, exist_ok=True)
    model, tk, vocab = build(src)
    proc = SmolVLMImageProcessorPil(do_image_splitting=False, size={"longest_edge": 512},
                                    max_image_size={"longest_edge": 512})
    ids = tk.encode(prompt_text()).ids
    assert ids.count(vocab["<image>"]) == 64, ids
    eou = vocab["<end_of_utterance>"]
    for path in sys.argv[2:]:
        name = os.path.splitext(os.path.basename(path))[0]
        px = proc(images=[Image.open(path).convert("RGB")], return_tensors="pt")["pixel_values"]
        np.ascontiguousarray(px[0, 0].numpy(), dtype=np.float32).tofile(os.path.join(out, name + "_px.f32"))
        with torch.no_grad():
            feat = model.model.get_image_features(pixel_values=px).pooler_output[0]
            np.ascontiguousarray(feat.numpy(), dtype=np.float32).tofile(os.path.join(out, name + "_feat.f32"))
            inp = torch.tensor([ids])
            o = model(input_ids=inp, pixel_values=px)
            last = o.logits[0, -1]
            top = torch.topk(last, 5)
            gen = model.generate(input_ids=inp, pixel_values=px, max_new_tokens=N_GEN, do_sample=False,
                                 eos_token_id=eou, pad_token_id=eou)[0, len(ids):].tolist()
        text = tk.decode([g for g in gen if g != eou])
        with open(os.path.join(out, name + "_ref.txt"), "w", encoding="utf-8", newline="\n") as f:
            f.write("ids " + " ".join(map(str, ids)) + "\n")
            f.write("top " + " ".join("%d:%.4f" % (i, v) for i, v in zip(top.indices.tolist(), top.values.tolist())) + "\n")
            f.write("gen " + " ".join(map(str, gen)) + "\n")
            f.write("text " + text.replace("\n", " ") + "\n")
        print(name, "->", text)


if __name__ == "__main__":
    main()
