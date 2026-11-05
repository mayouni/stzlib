"""WSP-SPIKE-01: the WARM direction of OWL-ViT's shift head, found on the DEV pictures by contrast -- numpy today, the engine tomorrow.

    docling-venv python -I owl_direction.py <spike dir with owlvit_vision.onnx> <golden tsv> <coco images> <out dir>

The shift head is logit_shift: shift = w . f + b over a patch's 768 features f (the ONNX activation /Reshape_1_output_0, t397 in the GGUF, the
tensor c210 is w). On the DEV pictures only: each picture's mean feature over its 576 patches, the pictures split at the median of their mean
shift into WARM and COLD, and d = unit(mean of warm pictures' features - mean of cold pictures' features). The patch the engine applies is
w' = w - (w . d) d: the head stops reading the warm-cold axis. Written out: direction.txt (768 numbers), and what the patch does to the DEV
pictures' mean shift (before and after), so the choice is visible before any judging.
"""
import sys

import numpy as np
import onnx
import onnxruntime as ort
from PIL import Image

MEAN = np.array([0.48145466, 0.4578275, 0.40821073])[:, None, None]
STD = np.array([0.26862954, 0.26130258, 0.27577711])[:, None, None]
FEAT = "/Reshape_1_output_0"


def main(spike, golden, images, out):
    m = onnx.load(spike + "/owlvit_vision.onnx")
    inits = {t.name: t for t in m.graph.initializer}
    w = onnx.numpy_helper.to_array(inits["onnx::MatMul_1823"]).reshape(768)       # logit_shift weight (768 -> 1)
    b = float(onnx.numpy_helper.to_array(inits[[n for n in m.graph.node if n.output[0] == "/logit_shift/Add_output_0"][0].input[0]]).reshape(-1)[0]) \
        if "/logit_shift/Add_output_0" in {n.output[0] for n in m.graph.node} else 0.0
    m.graph.output.append(onnx.ValueInfoProto(name=FEAT))
    sess = ort.InferenceSession(m.SerializeToString(), providers=["CPUExecutionProvider"])
    rows = [l.rstrip("\n").split("\t") for l in open(golden, encoding="utf-8")]
    dev = sorted({r[1] for r in rows if r[0] == "dev"})
    feats = {}
    for pic in dev:
        im = Image.open(images + "/" + pic).convert("RGB").resize((768, 768), Image.BICUBIC)
        t = ((np.asarray(im).astype(np.float32).transpose(2, 0, 1) / 255 - MEAN) / STD).astype(np.float32)[None]
        o, f = sess.run(None, {"pixel": t})
        f = f.reshape(576, 768)
        feats[pic] = f.mean(0)
        assert abs((f @ w + b) - o[:, 512]).max() < 1e-3, "the shift head is not w . f + b as read"
    shifts = {p: float(feats[p] @ w + b) for p in dev}
    med = np.median(list(shifts.values()))
    warm = [p for p in dev if shifts[p] >= med]
    cold = [p for p in dev if shifts[p] < med]
    d = np.mean([feats[p] for p in warm], 0) - np.mean([feats[p] for p in cold], 0)
    d = d / np.linalg.norm(d)
    wd = float(w @ d)
    w2 = w - wd * d
    np.savetxt(out + "/direction.txt", d, fmt="%.8f")
    with open(out + "/direction_report.txt", "w") as r:
        r.write("dev pictures %d | median mean-shift %.4f | warm %d cold %d | w.d = %.4f | |w| = %.4f\n" % (len(dev), med, len(warm), len(cold), wd, np.linalg.norm(w)))
        for p in dev:
            r.write("%s\t%s\t%.4f\t%.4f\n" % (p, "warm" if p in warm else "cold", shifts[p], float(feats[p] @ w2 + b)))
    s_before = np.array([shifts[p] for p in dev]); s_after = np.array([float(feats[p] @ w2 + b) for p in dev])
    print("dev pictures %d | w.d = %.4f (|w| %.4f) | mean shift spread before: %.4f .. %.4f (sd %.4f) | after the patch: %.4f .. %.4f (sd %.4f)" % (
        len(dev), wd, np.linalg.norm(w), s_before.min(), s_before.max(), s_before.std(), s_after.min(), s_after.max(), s_after.std()))
    print("written:", out + "/direction.txt", out + "/direction_report.txt")


if __name__ == "__main__":
    main(*sys.argv[1:5])
