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
    u2netp        (IM6) dog.jpg as rembg prepares it: PIL LANCZOS to 320 x 320, x / max(x), ImageNet mean/std
                  -> the fused sigmoid output; plus u2netp_<photo>.png: rembg's end-to-end mask of each photo
                  (min-max normalised, * 255 truncated to bytes, PIL LANCZOS back to the photo's size)
    depth_anything_v2_small  (IM6) dog.jpg resized to 518 x 518 by PIL BICUBIC, /255, ImageNet mean/std ->
                  predicted_depth; plus da2_<photo>.png: the depth at the photo's size (PyTorch bicubic, as HF's
                  post-processing) min-max scaled to 0..255 and rounded
    mobilesam     (IM6) dog.jpg as SAM's predictor prepares it: the longest side to 1024 by PIL BILINEAR -> the
                  encoder's embedding (onnxruntime on the resized picture, which the export pads itself); the
                  engine's input is the same picture padded to 1024 x 1024 with the pixel mean, saved as
                  sam_enc_in.stzt. Plus sam_prompts.tsv and sam_<photo>_<prompt>.png: for each photo a centre point
                  and a box (20% to 80% of each side), the full exported decoder's mask (logits > 0) and its IoU
                  ("python -I vision_parity.py <src> sam" writes only this section)
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


def sam(src, out, photos):
    from PIL import Image
    md = os.path.join(src, "mobilesam")
    es = ort.InferenceSession(os.path.join(md, "mobile_sam_image_encoder.onnx"), providers=["CPUExecutionProvider"])
    ds = ort.InferenceSession(os.path.join(md, "sam_mask_decoder_single.onnx"), providers=["CPUExecutionProvider"])
    mean = np.array([123.675, 116.28, 103.53], np.float32)

    def resized(im):
        w, h = im.size
        sc = 1024.0 / max(w, h)
        rw, rh = int(w * sc + 0.5), int(h * sc + 0.5)
        return np.asarray(im.convert("RGB").resize((rw, rh), Image.BILINEAR), dtype=np.float32), rw / w, rh / h

    a, _, _ = resized(Image.open(os.path.join(photos, "dog.jpg")))
    emb = es.run(None, {"input_image": a})[0]
    pad = np.tile(mean, (1024, 1024, 1))
    pad[:a.shape[0], :a.shape[1]] = a
    write(os.path.join(out, "sam_enc_in.stzt"), pad)
    write(os.path.join(out, "sam_enc_out.stzt"), emb)
    rows = []
    for name in ("dog.jpg", "cat.jpg", "street.jpg"):
        im = Image.open(os.path.join(photos, name))
        w, h = im.size
        a, kx, ky = resized(im)
        emb = es.run(None, {"input_image": a})[0]
        for kind, pts, lab in (("point", [w / 2, h / 2, 0, 0], [1, -1]),
                               ("box", [w * 0.2, h * 0.2, w * 0.8, h * 0.8], [2, 3])):
            c = np.array([[[pts[0] * kx, pts[1] * ky], [pts[2] * kx, pts[3] * ky]]], np.float32)
            if lab[1] == -1:
                c[0, 1] = 0
            masks, iou, _ = ds.run(None, {"image_embeddings": emb, "point_coords": c,
                                          "point_labels": np.array([lab], np.float32),
                                          "mask_input": np.zeros((1, 1, 256, 256), np.float32),
                                          "has_mask_input": np.zeros(1, np.float32),
                                          "orig_im_size": np.array([h, w], np.float32)})
            Image.fromarray(((masks[0, 0] > 0) * 255).astype(np.uint8), mode="L").save(
                os.path.join(out, "sam_%s_%s.png" % (name[:-4], kind)))
            rows.append("\t".join([name, kind, " ".join("%.4f" % v for v in pts), " ".join(str(v) for v in lab),
                                   "%.6f" % float(iou.flatten()[0])]))
    with open(os.path.join(out, "sam_prompts.tsv"), "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(rows) + "\n")
    print("mobilesam: embedding", emb.shape, "prompts", len(rows))


def main():
    src = sys.argv[1]
    out = os.path.join(src, "parity")
    os.makedirs(out, exist_ok=True)
    photos = os.path.join(src, "photos")
    if len(sys.argv) > 2 and sys.argv[2] == "sam":
        sam(src, out, photos)
        return

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

    # U2-Net-p (IM6), as rembg's u2net session computes it
    us = ort.InferenceSession(os.path.join(src, "u2netp", "u2netp.onnx"), providers=["CPUExecutionProvider"])

    def rembg_in(im):
        a = np.asarray(im.convert("RGB").resize((320, 320), Image.Resampling.LANCZOS), dtype=np.float64)
        a = a / np.max(a)
        a = (a - np.array([0.485, 0.456, 0.406])) / np.array([0.229, 0.224, 0.225])
        return a.transpose(2, 0, 1)[None].astype(np.float32)

    im = Image.open(os.path.join(photos, "dog.jpg"))
    x = rembg_in(im)
    y = us.run(None, {us.get_inputs()[0].name: x})[0]
    write(os.path.join(out, "u2netp_in.stzt"), x)
    write(os.path.join(out, "u2netp_out.stzt"), y)
    for name in ("dog.jpg", "cat.jpg", "crew.jpg", "street.jpg"):
        im = Image.open(os.path.join(photos, name))
        pred = us.run(None, {us.get_inputs()[0].name: rembg_in(im)})[0][:, 0, :, :]
        pred = (pred - pred.min()) / (pred.max() - pred.min())
        mask = Image.fromarray((np.squeeze(pred) * 255).astype("uint8"), mode="L").resize(im.size, Image.Resampling.LANCZOS)
        mask.save(os.path.join(out, "u2netp_" + name.replace(".jpg", ".png")))
    print("u2netp: fused output", y.shape)

    # Depth-Anything-V2-Small (IM6)
    ds = ort.InferenceSession(os.path.join(src, "depth_anything_v2_small", "model.onnx"), providers=["CPUExecutionProvider"])

    def da_in(im):
        a = np.asarray(im.convert("RGB").resize((518, 518), Image.Resampling.BICUBIC), dtype=np.float32) / 255.0
        a = (a - np.array([0.485, 0.456, 0.406], np.float32)) / np.array([0.229, 0.224, 0.225], np.float32)
        return a.transpose(2, 0, 1)[None].astype(np.float32)

    def cubic_resize(x, oh, ow):
        def axis(v, m, ax):
            n = v.shape[ax]
            w = np.zeros((m, n))
            for i in range(m):
                c = (i + 0.5) * n / m - 0.5
                f = int(np.floor(c))
                for k in range(f - 1, f + 3):
                    t = abs(c - k)
                    wt = (1.25 * t - 2.25) * t * t + 1 if t <= 1 else ((-0.75 * t + 3.75) * t - 6) * t + 3 if t < 2 else 0
                    w[i, min(max(k, 0), n - 1)] += wt
            return np.moveaxis(np.tensordot(w, np.moveaxis(v, ax, 0), axes=1), 0, ax)
        return axis(axis(x.astype(np.float64), ow, 1), oh, 0)

    im = Image.open(os.path.join(photos, "dog.jpg"))
    x = da_in(im)
    y = ds.run(None, {ds.get_inputs()[0].name: x})[0]
    write(os.path.join(out, "da2_in.stzt"), x)
    write(os.path.join(out, "da2_out.stzt"), y)
    for name in ("dog.jpg", "street.jpg"):
        im = Image.open(os.path.join(photos, name))
        d = ds.run(None, {ds.get_inputs()[0].name: da_in(im)})[0][0]
        d = cubic_resize(d, im.size[1], im.size[0])
        d = np.round((d - d.min()) / (d.max() - d.min()) * 255.0).astype(np.uint8)
        Image.fromarray(d, mode="L").save(os.path.join(out, "da2_" + name.replace(".jpg", ".png")))
    print("depth anything v2 small: output", y.shape)
    sam(src, out, photos)


if __name__ == "__main__":
    main()
