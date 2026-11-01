#!/usr/bin/env python3
"""vision_parity.py -- the parity fixtures of the image plane's models (IM3 of SOFTANZA_IMAGE_INTELLIGENCE.md).

For each converted model: a fixed input made from a real photograph, prepared as that model expects, and
onnxruntime's output on it, as STZT files the engine's ocr_graph.zig reads. Written once; the engine side never
regenerates them. They are large (YuNet's input is 4.9 MB), so they live beside the models, outside the tree:

    D:\\GitHub\\_wt_dl\\docling-venv\\Scripts\\python.exe -I vision_parity.py D:\\GitHub\\_wti_models_src

Inputs (the photos are in <src>/photos, licences in their MANIFEST.tsv):
    mobilenetv3   dog.jpg, shorter side 256 (bilinear), centre crop 224, RGB, ImageNet mean/std, NCHW
    yunet         crew.jpg letterboxed into 640 x 640 (pad 0), BGR, raw 0..255
    yolox         street.jpg letterboxed into 416 x 416 (pad 114), BGR, raw 0..255
    siglip2       (IM5) dog.jpg resized to 224 x 224 by PIL (bilinear, as HF's SiglipImageProcessor), RGB,
                  (x/255 - 0.5)/0.5 -> pooler_output; plus siglip2_text.tsv: for each fixed text, the ids HF's
                  tokenizers library gives and the text tower's pooler_output on them; and siglip2_photos.tsv:
                  each photo's image embedding through the same PIL path (end-to-end: decode, resize, tower)
YuNet's expected tensor is its 12 outputs fused exactly as onnx_to_gguf.py --kind=yunet fuses them.

STZT file: "STZT", u32 rank, 4 x i64 dims (ONNX order, 1 where unused), f32 data row-major.
"""
import os
import struct
import sys

import cv2
import numpy as np
import onnxruntime as ort


def write(path, arr):
    arr = np.ascontiguousarray(arr, dtype=np.float32)
    dims = list(arr.shape) + [1] * (4 - arr.ndim)
    with open(path, "wb") as f:
        f.write(b"STZT" + struct.pack("<I", arr.ndim) + struct.pack("<4q", *dims))
        f.write(arr.tobytes())


def letterbox(img, size, pad):
    h, w = img.shape[:2]
    r = min(size / h, size / w)
    nw, nh = int(round(w * r)), int(round(h * r))
    out = np.full((size, size, 3), pad, np.uint8)
    out[:nh, :nw] = cv2.resize(img, (nw, nh), interpolation=cv2.INTER_LINEAR)
    return out


def main():
    src = sys.argv[1]
    out = os.path.join(src, "parity")
    os.makedirs(out, exist_ok=True)
    photos = os.path.join(src, "photos")

    # MobileNetV3
    bgr = cv2.imread(os.path.join(photos, "dog.jpg"))
    rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
    h, w = rgb.shape[:2]
    s = 256 / min(h, w)
    rgb = cv2.resize(rgb, (int(round(w * s)), int(round(h * s))), interpolation=cv2.INTER_LINEAR)
    h, w = rgb.shape[:2]
    y0, x0 = (h - 224) // 2, (w - 224) // 2
    crop = rgb[y0:y0 + 224, x0:x0 + 224].astype(np.float32) / 255.0
    crop = (crop - np.array([0.485, 0.456, 0.406], np.float32)) / np.array([0.229, 0.224, 0.225], np.float32)
    x = crop.transpose(2, 0, 1)[None]
    sess = ort.InferenceSession(os.path.join(src, "mobilenetv3", "model.onnx"), providers=["CPUExecutionProvider"])
    y = sess.run(None, {sess.get_inputs()[0].name: x})[0]
    write(os.path.join(out, "mobilenetv3_in.stzt"), x)
    write(os.path.join(out, "mobilenetv3_out.stzt"), y)
    print("mobilenetv3: top-1 class", int(y.argmax()))

    # YuNet
    lb = letterbox(cv2.imread(os.path.join(photos, "crew.jpg")), 640, 0).astype(np.float32)
    x = lb.transpose(2, 0, 1)[None]
    sess = ort.InferenceSession(os.path.join(src, "yunet", "face_detection_yunet_2023mar.onnx"), providers=["CPUExecutionProvider"])
    names = [o.name for o in sess.get_outputs()]
    outs = dict(zip(names, sess.run(None, {sess.get_inputs()[0].name: x})))
    fused = np.concatenate([np.concatenate([outs["%s_%d" % (hd, st)] for hd in ("cls", "obj", "bbox", "kps")], axis=2)
                            for st in (8, 16, 32)], axis=1)
    write(os.path.join(out, "yunet_in.stzt"), x)
    write(os.path.join(out, "yunet_out.stzt"), fused)
    print("yunet: fused", fused.shape, "anchors with score > 0.9:", int((np.sqrt(fused[0, :, 0] * fused[0, :, 1]) > 0.9).sum()))

    # YOLOX
    for name in ("yolox_nano", "yolox_tiny"):
        lb = letterbox(cv2.imread(os.path.join(photos, "street.jpg")), 416, 114).astype(np.float32)
        x = lb.transpose(2, 0, 1)[None]
        sess = ort.InferenceSession(os.path.join(src, "yolox", name + ".onnx"), providers=["CPUExecutionProvider"])
        y = sess.run(None, {sess.get_inputs()[0].name: x})[0]
        write(os.path.join(out, name + "_in.stzt"), x)
        write(os.path.join(out, name + "_out.stzt"), y)
        print(name + ": output", y.shape)

    # SigLIP2 (IM5)
    from PIL import Image
    from tokenizers import Tokenizer
    sd = os.path.join(src, "siglip2_base")

    def pil224(path):
        im = Image.open(path).convert("RGB").resize((224, 224), resample=Image.BILINEAR)
        a = np.asarray(im, dtype=np.float32) / 255.0
        return ((a - 0.5) / 0.5).transpose(2, 0, 1)[None].astype(np.float32)

    vs = ort.InferenceSession(os.path.join(sd, "vision_model.onnx"), providers=["CPUExecutionProvider"])
    vout = [o.name for o in vs.get_outputs()].index("pooler_output")
    x = pil224(os.path.join(photos, "dog.jpg"))
    y = vs.run(None, {vs.get_inputs()[0].name: x})[vout]
    write(os.path.join(out, "siglip2_vision_in.stzt"), x)
    write(os.path.join(out, "siglip2_vision_out.stzt"), y)
    print("siglip2 vision: pooler", y.shape)
    with open(os.path.join(out, "siglip2_photos.tsv"), "w", encoding="utf-8", newline="\n") as f:
        for name in ("dog.jpg", "cat.jpg", "crew.jpg", "street.jpg"):
            y = vs.run(None, {vs.get_inputs()[0].name: pil224(os.path.join(photos, name))})[vout][0]
            f.write(name + "\t" + " ".join("%.7g" % v for v in y) + "\n")

    tok = Tokenizer.from_file(os.path.join(sd, "tokenizer.json"))
    tok.enable_padding(length=64, pad_id=0, pad_token="<pad>")
    tok.enable_truncation(max_length=64)
    ts = ort.InferenceSession(os.path.join(sd, "text_model_fp16.onnx"), providers=["CPUExecutionProvider"])
    tout = [o.name for o in ts.get_outputs()].index("pooler_output")
    texts = ["This is a photo of a dog.", "a photo of a cat", "Times Square at night", "Pizza!  2 slices",
             "caf\u00e9 \u2615", "This is a photo of a crowd of people on a street.", "un chien qui court dans l'herbe",
             "\u0642\u0637\u0629 \u0646\u0627\u0626\u0645\u0629", "  leading and trailing  ", ""]
    with open(os.path.join(out, "siglip2_text.tsv"), "w", encoding="utf-8", newline="\n") as f:
        for t in texts:
            ids = tok.encode(t).ids
            y = ts.run(None, {ts.get_inputs()[0].name: np.array([ids], dtype=np.int64)})[tout][0]
            f.write(t + "\t" + " ".join(str(i) for i in ids) + "\t" + " ".join("%.7g" % v for v in y.astype(np.float32)) + "\n")
    print("siglip2 text: %d texts" % len(texts))


if __name__ == "__main__":
    main()
