"""IM9f spike, step 3: the engine against the reference, end to end.

    python owlvit_check.py prepare <spike dir>     write input.stzt and expected.stzt (ONNX Runtime's raw output of the exported graph) in
                                                   the tensor-file format the engine's parity function reads ("STZT", rank, 4 x i64 dims, f32 data)
    python owlvit_check.py compare <spike dir>     take the engine's own output (engine_out.stzt, written by StzEngineNeuralOcrGraphParity),
                                                   do what the CALLER does with it -- normalise the class embeddings, turn the raw scale into
                                                   elu(x) + 1, dot with the reference's text embeddings -- and compare the final logits and the
                                                   detections with the reference's (logits.npy, detections.tsv)

The spike's order: owlvit_reference.py (what OWL-ViT says), owlvit_export.py (the vision side as one ONNX graph, checked against it), the engine's
converter (engine/tools/onnx_to_gguf.py <onnx> <gguf> --static --input=768), then `prepare`, the engine's parity run, and `compare`.
"""
import struct
import sys

import numpy as np


def stzt(path, arr):
    arr = np.ascontiguousarray(arr.astype(np.float32))
    dims = list(arr.shape) + [1] * (4 - arr.ndim)
    with open(path, "wb") as f:
        f.write(b"STZT" + struct.pack("<I", arr.ndim) + struct.pack("<4q", *dims))
        f.write(arr.tobytes())


def read_stzt(path):
    raw = open(path, "rb").read()
    assert raw[:4] == b"STZT"
    rank, = struct.unpack("<I", raw[4:8])
    dims = struct.unpack("<4q", raw[8:40])
    return np.frombuffer(raw[40:], dtype=np.float32).reshape(dims[:rank])


def prepare(d):
    import onnxruntime as ort
    pixel = np.load(d + "/inputs.npy").astype(np.float32)
    sess = ort.InferenceSession(d + "/owlvit_vision.onnx", providers=["CPUExecutionProvider"])
    out = sess.run(None, {"pixel": pixel})[0].astype(np.float32)
    stzt(d + "/input.stzt", pixel)
    stzt(d + "/expected.stzt", out)
    print("input", pixel.shape, "expected", out.shape)


def compare(d, queries=("a photo of a cat", "a photo of a laptop", "a photo of a keyboard")):
    o = read_stzt(d + "/engine_out.stzt")
    ce = o[:, :512]
    ce = ce / (np.linalg.norm(ce, axis=-1, keepdims=True) + 1e-6)
    shift = o[:, 512]
    sc = o[:, 513]
    sc = np.where(sc > 0, sc + 1.0, np.exp(np.minimum(sc, 0)))
    boxes = o[:, 514:]
    q = np.load(d + "/queries.npy")
    logits = (ce @ q.T + shift[:, None]) * sc[:, None]
    ref = np.load(d + "/logits.npy")
    print("logits: max abs difference from the reference %.5f (reference range %.2f to %.2f)" % (np.abs(logits - ref).max(), ref.min(), ref.max()))
    prob = 1 / (1 + np.exp(-logits))
    best = prob.max(1)
    order = np.argsort(-best)
    refbest = (1 / (1 + np.exp(-ref))).max(1)
    reforder = np.argsort(-refbest)
    print("engine detections (score >= 0.1):")
    for i in order:
        if best[i] < 0.1:
            break
        cx, cy, w, h = boxes[i]
        print("  %.4f %.4f %.4f %.4f  %.4f  %s" % (cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2, best[i], queries[int(prob[i].argmax())]))
    print("reference detections:")
    print(open(d + "/detections.tsv").read())
    print("same top patch:", int(order[0]) == int(reforder[0]), "| top-10 patches equal:", list(order[:10]) == list(reforder[:10]))


if __name__ == "__main__":
    {"prepare": prepare, "compare": compare}[sys.argv[1]](sys.argv[2])
