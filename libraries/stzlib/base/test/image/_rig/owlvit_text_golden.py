"""IM9f: the reference model's query embeddings -- the GOLDEN the engine's text tower is held to.

    python owlvit_text_golden.py <owlvit dir> <out.tsv>

One line per query: the prompt, a tab, the 512 numbers of its embedding (the model's get_text_features, L2-normalised), 6 decimals.
"""
import sys

import numpy as np
import torch
from transformers import OwlViTForObjectDetection, OwlViTProcessor

QUERIES = ["a photo of a cat", "a photo of a laptop", "a photo of a keyboard", "a red mug", "the cat's left ear", "traffic light",
           "a QR code", "a handwritten signature", "Wine Glass", "2 dogs", "café table", "!", "a stamp on paper"]


def main(model_dir, out):
    torch.set_grad_enabled(False)
    proc = OwlViTProcessor.from_pretrained(model_dir)
    m = OwlViTForObjectDetection.from_pretrained(model_dir).eval()
    rows = []
    for q in QUERIES:
        tok = proc.tokenizer([q], padding="max_length", max_length=16, truncation=True, return_tensors="pt")
        f = m.owlvit.get_text_features(input_ids=tok["input_ids"], attention_mask=tok["attention_mask"])
        f = (f.pooler_output if hasattr(f, "pooler_output") else f).numpy()[0]
        f = f / (np.linalg.norm(f) + 1e-6)
        rows.append(q + chr(9) + " ".join("%.6f" % v for v in f))
    open(out, "w", encoding="utf-8", newline="\n").write("\n".join(rows) + "\n")
    print(len(rows), "queries written to", out)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
