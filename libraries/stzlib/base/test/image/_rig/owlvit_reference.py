"""IM9f spike, step 1: what OWL-ViT's own code says about a picture -- the REFERENCE the engine's run is held to.

    python owlvit_reference.py <owlvit dir> <picture> <out dir> "<query>" ["<query>" ...]

Loads google/owlvit-base-patch32 with Hugging Face transformers (the reference implementation), runs one picture and the text queries, and writes:

  inputs.npy      the pixel tensor the model saw [1, 3, 768, 768] (the engine must be given the same one)
  queries.npy     the L2-normalised text embeddings of the queries [Q, 512]
  image_feats.npy the vision side the engine must reproduce, per patch: the NORMALISED class embeddings [576, 512], the logit shift [576],
                  the logit scale [576] and the predicted boxes [576, 4] (cx, cy, w, h in 0..1)
  logits.npy      the detection logits [576, Q]
  detections.tsv  the boxes whose best-query sigmoid(logit) is at least 0.1, by that score: x0 y0 x1 y1 (0..1) <TAB> score <TAB> query

OWL-ViT in one paragraph: a CLIP ViT-B/32 run at 768 x 768 gives 24 x 24 = 576 patch features (the class token multiplied in, then a layer norm);
every patch is a candidate object: a box head (an MLP plus a fixed bias that depends on the patch's place) predicts its box, a class head projects it
into the text space; a query's score for a patch is a dot product with the query's text embedding, scaled and shifted by two small per-patch heads.
"""
import json
import os
import sys

import numpy as np
import torch
from PIL import Image
from transformers import OwlViTForObjectDetection, OwlViTProcessor


def main(model_dir, picture, out, queries):
    os.makedirs(out, exist_ok=True)
    proc = OwlViTProcessor.from_pretrained(model_dir)
    torch.set_grad_enabled(False)
    model = OwlViTForObjectDetection.from_pretrained(model_dir).eval()
    img = Image.open(picture).convert("RGB")
    inp = proc(text=[queries], images=img, return_tensors="pt")
    with torch.no_grad():
        pixel = inp["pixel_values"]
        # the vision side, step by step (so the engine has something to compare with at each step)
        feature_map = model.image_embedder(pixel_values=pixel)[0]                      # [1, 24, 24, 768]
        b, h, w, d = feature_map.shape
        image_feats = feature_map.reshape(b, h * w, d)                                  # [1, 576, 768]
        pred_boxes = model.box_predictor(image_feats, feature_map)                      # [1, 576, 4]  (cx, cy, w, h)
        text = model.owlvit.get_text_features(input_ids=inp["input_ids"], attention_mask=inp["attention_mask"])
        text = text.pooler_output if hasattr(text, "pooler_output") else text
        q = text / text.norm(dim=-1, keepdim=True)
        qmask = (inp["input_ids"][..., 0] > 0).reshape(1, -1)                          # one flag per query (a padded query would be 0)
        pred_logits, class_embeds = model.class_predictor(image_feats, q[None], qmask)
    ce = class_embeds[0]
    shift = model.class_head.logit_shift(image_feats)[0, :, 0]
    scale = model.class_head.elu(model.class_head.logit_scale(image_feats))[0, :, 0] + 1
    np.save(os.path.join(out, "inputs.npy"), pixel.numpy())
    np.save(os.path.join(out, "queries.npy"), q.numpy())
    np.save(os.path.join(out, "image_feats.npy"), np.concatenate([ce.numpy(), shift.numpy()[:, None], scale.numpy()[:, None], pred_boxes[0].numpy()], axis=1))
    logits = pred_logits[0].numpy()
    np.save(os.path.join(out, "logits.npy"), logits)
    prob = 1.0 / (1.0 + np.exp(-logits))
    best = prob.max(axis=1)
    order = np.argsort(-best)
    rows = []
    for i in order:
        if best[i] < 0.1:
            break
        cx, cy, bw, bh = pred_boxes[0][i].numpy()
        rows.append("%.4f %.4f %.4f %.4f\t%.4f\t%s" % (cx - bw / 2, cy - bh / 2, cx + bw / 2, cy + bh / 2, best[i], queries[int(prob[i].argmax())]))
    with open(os.path.join(out, "detections.tsv"), "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(rows) + "\n")
    print("pixel", tuple(pixel.shape), "| patches", h * w, "| feats", tuple(ce.shape), "| queries", tuple(q.shape))
    print("detections >= 0.1:", len(rows))
    for r in rows[:8]:
        print("  ", r)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4:])
