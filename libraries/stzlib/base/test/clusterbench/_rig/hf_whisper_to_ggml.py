"""Write a Whisper model fine-tuned in Hugging Face's form as whisper.cpp's ggml file, the form engine/src/whisper.zig reads.

    python -I hf_whisper_to_ggml.py <base ggml .bin> <model.safetensors> <out .bin>

The fine-tune must keep its base's architecture and vocabulary (a whisper-small fine-tune over ggml-small.bin): the
hyperparameters, the 80 mel filters and the vocabulary are copied from the base file byte for byte, and every tensor of
the base is replaced by the fine-tune's tensor of the same role, in the base's order, type (f16 or f32) and shape. A
tensor whose element count differs, or a role the fine-tune lacks, stops the conversion. The fine-tune's proj_out is its
token embedding (tied) and is not read.

Prints, for every tensor, the cosine between the base's and the fine-tune's values: a fine-tune moves its base a little,
so a cosine far from 1 means a role was mapped to the wrong tensor.
"""
import json
import struct
import sys

import numpy as np


def hf_name(ggml_name):
    """the Hugging Face tensor that plays a ggml tensor's role"""
    n = ggml_name
    fixed = {
        "encoder.positional_embedding": "model.encoder.embed_positions.weight",
        "encoder.ln_post.weight": "model.encoder.layer_norm.weight",
        "encoder.ln_post.bias": "model.encoder.layer_norm.bias",
        "decoder.positional_embedding": "model.decoder.embed_positions.weight",
        "decoder.token_embedding.weight": "model.decoder.embed_tokens.weight",
        "decoder.ln.weight": "model.decoder.layer_norm.weight",
        "decoder.ln.bias": "model.decoder.layer_norm.bias",
    }
    if n in fixed:
        return fixed[n]
    if n.startswith("encoder.conv"):
        return "model." + n
    side, _, i, rest = n.split(".", 3)          # encoder|decoder, blocks, i, the rest
    parts = {
        "attn.query": "self_attn.q_proj", "attn.key": "self_attn.k_proj", "attn.value": "self_attn.v_proj",
        "attn.out": "self_attn.out_proj", "attn_ln": "self_attn_layer_norm",
        "cross_attn.query": "encoder_attn.q_proj", "cross_attn.key": "encoder_attn.k_proj",
        "cross_attn.value": "encoder_attn.v_proj", "cross_attn.out": "encoder_attn.out_proj",
        "cross_attn_ln": "encoder_attn_layer_norm",
        "mlp.0": "fc1", "mlp.2": "fc2", "mlp_ln": "final_layer_norm",
    }
    role, kind = rest.rsplit(".", 1)             # e.g. attn.query, weight
    return "model.%s.layers.%s.%s.%s" % (side, i, parts[role], kind)


def read_safetensors(path):
    with open(path, "rb") as f:
        n = struct.unpack("<Q", f.read(8))[0]
        head = json.loads(f.read(n))
        base = 8 + n
    data = np.memmap(path, dtype=np.uint8, mode="r")
    out = {}
    for name, meta in head.items():
        if name == "__metadata__":
            continue
        a, b = meta["data_offsets"]
        dt = {"F32": np.float32, "F16": np.float16, "BF16": None}[meta["dtype"]]
        raw = data[base + a:base + b]
        if dt is None:   # bfloat16: the high half of a float32
            v = (np.frombuffer(raw.tobytes(), np.uint16).astype(np.uint32) << 16).view(np.float32)
        else:
            v = np.frombuffer(raw.tobytes(), dt).astype(np.float32)
        out[name] = v.reshape(meta["shape"])
    return out


def main():
    base_path, st_path, out_path = sys.argv[1:4]
    base = open(base_path, "rb").read()
    hf = read_safetensors(st_path)
    at = 4 + 11 * 4
    n_mel, n_fft = struct.unpack_from("<2i", base, at)
    at += 8 + 4 * n_mel * n_fft
    n_words = struct.unpack_from("<i", base, at)[0]
    at += 4
    for _ in range(n_words):
        at += 4 + struct.unpack_from("<i", base, at)[0]
    out = bytearray(base[:at])                   # hyperparameters, filters and vocabulary, as the base has them
    done = 0
    worst = 1.0
    while at < len(base):
        n_dims, n_name, ttype = struct.unpack_from("<3i", base, at)
        ne = struct.unpack_from("<%di" % n_dims, base, at + 12)
        p = at + 12 + 4 * n_dims
        name = base[p:p + n_name].decode()
        p += n_name
        count = int(np.prod(ne))
        dt = {0: np.float32, 1: np.float16}[ttype]
        size = count * np.dtype(dt).itemsize
        old = np.frombuffer(base, dt, count, p).astype(np.float32)
        src = hf.get(hf_name(name))
        if src is None:          # saved from the bare WhisperModel: the same names without "model."
            src = hf.get(hf_name(name)[len("model."):])
        if src is None:
            sys.exit("the fine-tune has no tensor for %s (%s)" % (name, hf_name(name)))
        if src.size != count:
            sys.exit("%s: %d values in the base, %d in the fine-tune" % (name, count, src.size))
        new = src.reshape(-1)
        cos = float(np.dot(old, new) / (np.linalg.norm(old) * np.linalg.norm(new) + 1e-30))
        worst = min(worst, cos)
        print("%-45s %-8s cos %.6f" % (name, "f16" if ttype else "f32", cos))
        out += base[at:p]                        # the tensor's header, unchanged
        out += new.astype(dt).tobytes()
        at = p + size
        done += 1
    open(out_path, "wb").write(out)
    print("tensors %d, lowest cosine %.6f, %d bytes written" % (done, worst, len(out)))


if __name__ == "__main__":
    main()
