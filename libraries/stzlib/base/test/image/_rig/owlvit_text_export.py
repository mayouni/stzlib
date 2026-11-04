"""IM9f, the TEXT side of OWL-ViT as one ONNX graph, and a check that the graph is the reference.

    python owlvit_text_export.py <owlvit dir> <out.onnx> ["<query>" ...]

The graph takes the 16 token ids of a query (OWL-ViT pads every query to 16: the start token, the words, the end token, then zeros) and gives
[16, 512]: the CLIP text tower's final-layer-norm hidden state of every position, already through the text projection. The query's embedding is
the row at the END token's position (the position of the largest id, 49407), L2-normalised: picking a row and normalising 512 numbers is what the
CALLER does, as the vision side's normalisation and elu are (the converter's op set has no gather-at-argmax and no ReduceL2).

After exporting, ONNX Runtime runs the graph on the reference tokenizer's ids for the queries (default: a few) and its normalised end-token rows are
compared with the reference model's text embeddings (get_text_features, normalised).
"""
import sys

import numpy as np
import onnxruntime as ort
import torch
from transformers import OwlViTForObjectDetection, OwlViTProcessor


class Text(torch.nn.Module):
    def __init__(self, m):
        super().__init__()
        self.m = m
        # the causal mask as a constant: position i sees positions 0..i. Written out here, with the embedding lookup called on the ids as they
        # are, because the model builds the mask from runtime shapes and views its ids first, which the converter cannot trace
        self.register_buffer("causal", torch.triu(torch.full((16, 16), -3.0e38), diagonal=1)[None, None])

    def forward(self, ids):
        tm = self.m.owlvit.text_model
        hs = tm.embeddings(input_ids=ids)                               # [1, 16, 512]
        hs = tm.encoder(inputs_embeds=hs, attention_mask=self.causal, is_causal=False).last_hidden_state
        hs = tm.final_layer_norm(hs)                                    # [1, 16, 512], after the final layer norm
        return self.m.owlvit.text_projection(hs)[0]                     # [16, 512]


def _unit(e):
    return e / (np.linalg.norm(e, axis=-1, keepdims=True) + 1e-6)


def main(model_dir, out, queries):
    torch.set_grad_enabled(False)
    proc = OwlViTProcessor.from_pretrained(model_dir)
    m = OwlViTForObjectDetection.from_pretrained(model_dir).eval()
    net = Text(m).eval()
    tok = proc.tokenizer(queries, padding="max_length", max_length=16, truncation=True, return_tensors="pt")
    ids = tok["input_ids"]
    ref = m.owlvit.get_text_features(input_ids=ids, attention_mask=tok["attention_mask"])
    ref = (ref.pooler_output if hasattr(ref, "pooler_output") else ref).numpy()
    ref = _unit(ref)
    torch.onnx.export(net, (ids[:1],), out, input_names=["ids"], output_names=["rows"], opset_version=17, dynamo=False)
    sess = ort.InferenceSession(out, providers=["CPUExecutionProvider"])
    worst = 0.0
    for i in range(len(queries)):
        rows = sess.run(None, {"ids": ids[i:i + 1].numpy().astype(np.int64)})[0]
        eos = int(ids[i].argmax())
        e = _unit(rows[eos][None])[0]
        worst = max(worst, float(np.abs(e - ref[i]).max()))
    print("ONNX Runtime on the exported text graph, %d queries: the end-token row, normalised, is within %.6f of the reference" % (len(queries), worst))
    print("ids of the first query:", ids[0].tolist())


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3:] or ["a photo of a cat", "a photo of a laptop", "a photo of a keyboard", "a red mug", "the cat's left ear"])
