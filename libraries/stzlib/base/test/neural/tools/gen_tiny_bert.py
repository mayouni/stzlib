#!/usr/bin/env python3
# Generates the BERT-parity fixture: a TINY synthetic BERT in GGUF form
# (random weights, fixed seed) plus an INDEPENDENT numpy reference of the
# tokenization and forward pass -- the ground truth a real MiniLM can never
# give (its "expected" vectors would come from the code under test).
#
# The reference mirrors the ENGINE's exact semantics (neural_embed.zig):
#   - classic-WordPiece tokenizer: lowercase (uncased vocab), whitespace
#     split, each punctuation byte its own token, greedy longest-match with
#     "##" continuations, whole word -> [UNK] when nothing matches,
#     [CLS] ... [SEP] wrap
#   - embeddings: (token + type0) + position, then LayerNorm (biased var,
#     eps inside the sqrt)
#   - per layer: post-LN attention (softmax(QK^T / sqrt(hd)) V) and
#     tanh-GELU FFN, residuals before each LN
#   - mean-pool over tokens, L2 normalize -- all float32, engine op order
#
# Emits (both committed; ~60 KB total):
#   ../tiny_bert.gguf                -- the model (GGUF v3, f32 tensors)
#   ../bert_parity_expected.ring     -- token ids + embeddings as Ring data
#
# Regeneration is deterministic (seed 42): rerunning must reproduce both
# files byte-for-byte.

import struct
import numpy as np

rng = np.random.default_rng(42)

HID, LAYERS, HEADS, FFN, CTX = 32, 2, 2, 64, 64
HEAD_DIM = HID // HEADS
EPS = 1e-12

VOCAB = [
    "[PAD]", "[CLS]", "[SEP]", "[UNK]",
    "the", "cat", "sat", "on", "mat", "dog", "ran", "fast",
    "hello", "world", "a", "big", "red", "sun",
    "##s", "##ing", ".", ",", "run", "walk",
]
CLS, SEP, UNK = 1, 2, 3

SENTENCES = [
    "the cat sat on the mat .",
    "hello world , a big red sun",
    "the dog runs fast",
    "walking the dog",
    "the zebra ran",
]

# ---------------------------------------------------------------- tokenizer

def is_punct(ch):
    o = ord(ch)
    return (0x21 <= o <= 0x2F) or (0x3A <= o <= 0x40) or \
           (0x5B <= o <= 0x60) or (0x7B <= o <= 0x7E)

VOCAB_IDX = {t: i for i, t in enumerate(VOCAB)}

def wordpiece(word, out):
    start = 0
    while start < len(word):
        end, found = len(word), -1
        while end > start:
            sub = word[start:end]
            key = ("##" + sub) if start != 0 else sub
            if key in VOCAB_IDX:
                found = VOCAB_IDX[key]
                break
            end -= 1
        if found < 0:
            out.append(UNK)
            return
        out.append(found)
        start = end

def tokenize(text):
    out = [CLS]
    i = 0
    while i < len(text):
        ch = text[i]
        if ch in " \t\n\r":
            i += 1
            continue
        if is_punct(ch):
            wordpiece(ch, out)
            i += 1
            continue
        j = i
        word = ""
        while j < len(text) and text[j] not in " \t\n\r" and not is_punct(text[j]):
            word += text[j].lower()
            j += 1
        wordpiece(word, out)
        i = j
    out.append(SEP)
    return out

# ---------------------------------------------------------------- weights

f32 = np.float32

def W(shape, scale):
    return rng.normal(0, scale, size=shape).astype(f32)

weights = {}
weights["token_embd.weight"] = W((len(VOCAB), HID), 0.5)
weights["token_types.weight"] = W((2, HID), 0.1)
weights["position_embd.weight"] = W((CTX, HID), 0.1)
weights["token_embd_norm.weight"] = rng.uniform(0.8, 1.2, HID).astype(f32)
weights["token_embd_norm.bias"] = W((HID,), 0.05)
for L in range(LAYERS):
    p = f"blk.{L}."
    for nm in ("attn_q", "attn_k", "attn_v", "attn_output"):
        weights[p + nm + ".weight"] = W((HID, HID), 0.15)
        weights[p + nm + ".bias"] = W((HID,), 0.02)
    weights[p + "attn_output_norm.weight"] = rng.uniform(0.8, 1.2, HID).astype(f32)
    weights[p + "attn_output_norm.bias"] = W((HID,), 0.05)
    weights[p + "ffn_up.weight"] = W((FFN, HID), 0.15)
    weights[p + "ffn_up.bias"] = W((FFN,), 0.02)
    weights[p + "ffn_down.weight"] = W((HID, FFN), 0.15)
    weights[p + "ffn_down.bias"] = W((HID,), 0.02)
    weights[p + "layer_output_norm.weight"] = rng.uniform(0.8, 1.2, HID).astype(f32)
    weights[p + "layer_output_norm.bias"] = W((HID,), 0.05)

# ---------------------------------------------------------------- reference forward

def layernorm(x, g, b):
    x = x.astype(f32)
    mu = x.mean(axis=-1, keepdims=True, dtype=f32)
    d = (x - mu).astype(f32)
    var = (d * d).mean(axis=-1, keepdims=True, dtype=f32)
    return ((d / np.sqrt(var + f32(EPS))).astype(f32) * g + b).astype(f32)

def gelu(x):
    # ggml's GELU with GGML_GELU_FP16 (the vendored build defines it,
    # ggml-cpu/vec.h:46): the INPUT is quantized to f16, the tanh
    # approximation computed in f32, and the table stores the OUTPUT as
    # f16 -- mirror all three steps or the parity band pays ~1e-4 for it
    xq = x.astype(np.float16).astype(f32)
    c = f32(np.sqrt(2.0 / np.pi))
    a = f32(0.044715)
    g = (f32(0.5) * xq * (f32(1.0) + np.tanh(c * xq * (f32(1.0) + a * xq * xq)))).astype(f32)
    return g.astype(np.float16).astype(f32)

def softmax(x):
    m = x.max(axis=-1, keepdims=True)
    e = np.exp((x - m).astype(f32)).astype(f32)
    return (e / e.sum(axis=-1, keepdims=True, dtype=f32)).astype(f32)

def forward(ids):
    n = len(ids)
    x = weights["token_embd.weight"][ids] + weights["token_types.weight"][0]
    x = (x.astype(f32) + weights["position_embd.weight"][:n]).astype(f32)
    x = layernorm(x, weights["token_embd_norm.weight"], weights["token_embd_norm.bias"])
    scale = f32(1.0 / np.sqrt(HEAD_DIM))
    for L in range(LAYERS):
        p = f"blk.{L}."
        inp = x
        q = (x @ weights[p + "attn_q.weight"].T + weights[p + "attn_q.bias"]).astype(f32)
        k = (x @ weights[p + "attn_k.weight"].T + weights[p + "attn_k.bias"]).astype(f32)
        v = (x @ weights[p + "attn_v.weight"].T + weights[p + "attn_v.bias"]).astype(f32)
        ctx = np.zeros((n, HID), dtype=f32)
        for h in range(HEADS):
            s = slice(h * HEAD_DIM, (h + 1) * HEAD_DIM)
            att = softmax((q[:, s] @ k[:, s].T).astype(f32) * scale)
            ctx[:, s] = (att @ v[:, s]).astype(f32)
        attn = (ctx @ weights[p + "attn_output.weight"].T + weights[p + "attn_output.bias"]).astype(f32)
        x = layernorm((attn + inp).astype(f32), weights[p + "attn_output_norm.weight"],
                      weights[p + "attn_output_norm.bias"])
        ff = gelu((x @ weights[p + "ffn_up.weight"].T + weights[p + "ffn_up.bias"]).astype(f32))
        ff = (ff @ weights[p + "ffn_down.weight"].T + weights[p + "ffn_down.bias"]).astype(f32)
        x = layernorm((ff + x).astype(f32), weights[p + "layer_output_norm.weight"],
                      weights[p + "layer_output_norm.bias"])
    pooled = x.mean(axis=0, dtype=f32).astype(f32)
    nrm = f32(np.sqrt((pooled * pooled).sum(dtype=f32)))
    return (pooled / (nrm if nrm != 0 else f32(1))).astype(f32)

# ---------------------------------------------------------------- gguf writer

U8, I8, U16, I16, U32, I32, F32, BOOL, STRING, ARRAY = range(10)

def kv_str(k, v):
    return _key(k) + struct.pack("<I", STRING) + _s(v)

def kv_u32(k, v):
    return _key(k) + struct.pack("<II", U32, v)

def kv_f32(k, v):
    return _key(k) + struct.pack("<I", F32) + struct.pack("<f", v)

def kv_strarr(k, vals):
    out = _key(k) + struct.pack("<I", ARRAY) + struct.pack("<IQ", STRING, len(vals))
    for v in vals:
        out += _s(v)
    return out

def _s(v):
    b = v.encode("utf-8")
    return struct.pack("<Q", len(b)) + b

def _key(k):
    return _s(k)

ALIGN = 32

def write_gguf(path):
    kvs = b"".join([
        kv_str("general.architecture", "bert"),
        kv_str("general.name", "tiny-bert-parity-fixture"),
        kv_u32("general.alignment", ALIGN),
        kv_u32("bert.embedding_length", HID),
        kv_u32("bert.block_count", LAYERS),
        kv_u32("bert.attention.head_count", HEADS),
        kv_u32("bert.context_length", CTX),
        kv_u32("bert.feed_forward_length", FFN),
        kv_f32("bert.attention.layer_norm_epsilon", EPS),
        kv_strarr("tokenizer.ggml.tokens", VOCAB),
        kv_u32("tokenizer.ggml.cls_token_id", CLS),
        kv_u32("tokenizer.ggml.seperator_token_id", SEP),
        kv_u32("tokenizer.ggml.unknown_token_id", UNK),
    ])
    n_kv = 13

    names = sorted(weights.keys())
    infos = b""
    data = b""
    for nm in names:
        w = weights[nm]
        # GGUF ne[] is ne0-first = the CONTIGUOUS dim; numpy row-major shape
        # (rows, cols) therefore writes ne = [cols, rows]
        ne = list(w.shape[::-1])
        while len(data) % ALIGN:
            data += b"\x00"
        off = len(data)
        data += w.astype("<f4").tobytes()
        infos += _s(nm) + struct.pack("<I", len(ne))
        for d in ne:
            infos += struct.pack("<Q", d)
        infos += struct.pack("<IQ", 0, off)  # type 0 = GGML_TYPE_F32

    head = b"GGUF" + struct.pack("<IQQ", 3, len(names), n_kv) + kvs + infos
    pad = (-len(head)) % ALIGN
    with open(path, "wb") as fh:
        fh.write(head + b"\x00" * pad + data)
    return len(head) + pad + len(data)

# ---------------------------------------------------------------- emit

import os
here = os.path.dirname(os.path.abspath(__file__))
gguf_path = os.path.join(here, "..", "tiny_bert.gguf")
ring_path = os.path.join(here, "..", "bert_parity_expected.ring")

size = write_gguf(gguf_path)

lines = ["# GENERATED by tools/gen_tiny_bert.py (seed 42) -- do not hand-edit.",
         "# Token ids and reference embeddings for tiny_bert.gguf, computed by",
         "# an INDEPENDENT numpy forward pass (float32, engine op order).",
         "aBertParityCases = ["]
for s in SENTENCES:
    ids = tokenize(s)
    emb = forward(ids)
    ids_s = ", ".join(str(i) for i in ids)
    emb_s = ", ".join(f"{v:.9g}" for v in emb)
    lines.append('\t[ "%s",' % s)
    lines.append("\t  [ %s ]," % ids_s)
    lines.append("\t  [ %s ] ]," % emb_s)
lines[-1] = lines[-1][:-1]  # drop the trailing comma of the last case
lines.append("]")
with open(ring_path, "w", newline="\n") as fh:
    fh.write("\n".join(lines) + "\n")

print(f"tiny_bert.gguf: {size} bytes, {len(weights)} tensors")
for s in SENTENCES:
    print(f"  {tokenize(s)}  <- {s!r}")
