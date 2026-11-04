"""IM9d, slice 1: what OpenCV and numpy say about a picture -- the ORACLE for the quality measures.

    python quality_oracle.py <coco images dir> <photos dir> <out dir>

Writes lossless PNG copies (so the engine and OpenCV read the SAME pixels: JPEG decoders differ by a rounding) of 40 COCO
pictures, the four photographs and a set of extremes (noise, flat, gradients, a 1-pixel checker, tiny and 1-pixel-wide
pictures), and oracle.tsv with, for each: the variance of the Laplacian (cv2.Laplacian(gray, CV_64F, ksize=1).var()), the
same on the picture area-shrunk to a long side of 512 (cv2.INTER_AREA), the gray's mean and standard deviation, its 1st
and 99th percentile LEVEL (the level where the cumulative share first reaches the fraction), the fraction of pixels at 5
or below and at 250 or above, and the 64-bit perceptual hash by imagehash's definition (32 x 32 area reduction, 2D DCT-II
unnormalised, the 8 x 8 low block against its median, row-major, first bit most significant).
"""
import math
import os
import sys

import cv2
import numpy as np


def gray_of(bgr):
    return cv2.cvtColor(bgr, cv2.COLOR_BGR2GRAY) if bgr.ndim == 3 else bgr


def phash(gray):
    small = cv2.resize(gray, (32, 32), interpolation=cv2.INTER_AREA)
    k = np.arange(32)[:, None]
    n = np.arange(32)[None, :]
    c = 2.0 * np.cos(np.pi * k * (2 * n + 1) / 64.0)
    d = c @ small.astype(np.float64) @ c.T
    low = d[:8, :8]
    med = np.median(low)
    bits = (low > med).flatten()
    h = 0
    for b in bits:
        h = (h << 1) | int(b)
    return "%016x" % h


def lapvar(gray):
    return float(cv2.Laplacian(gray, cv2.CV_64F, ksize=1).var())


def sharp512(gray):
    h, w = gray.shape
    long_side = max(w, h)
    if long_side <= 512:
        return lapvar(gray)
    s = 512.0 / long_side
    w2 = max(1, int(math.floor(w * s + 0.5)))
    h2 = max(1, int(math.floor(h * s + 0.5)))
    return lapvar(cv2.resize(gray, (w2, h2), interpolation=cv2.INTER_AREA))


def exposure(gray):
    hist = np.bincount(gray.flatten(), minlength=256).astype(np.int64)
    n = hist.sum()
    cum = np.cumsum(hist)
    p1 = int(np.argmax(cum >= 0.01 * n))
    p99 = int(np.argmax(cum >= 0.99 * n))
    return float(gray.mean()), float(gray.std()), p1, p99, float(hist[:6].sum() / n), float(hist[250:].sum() / n)


def extremes():
    r = np.random.RandomState(7)
    out = {}
    out["x_noise"] = r.randint(0, 256, (150, 200)).astype(np.uint8)
    out["x_flat"] = np.full((100, 100), 128, dtype=np.uint8)
    out["x_black"] = np.zeros((90, 120), dtype=np.uint8)
    out["x_white"] = np.full((90, 120), 255, dtype=np.uint8)
    out["x_gradient"] = np.tile(np.linspace(0, 255, 256).astype(np.uint8), (64, 1))
    out["x_checker1"] = ((np.indices((64, 64)).sum(0) % 2) * 255).astype(np.uint8)
    out["x_tiny"] = r.randint(0, 256, (5, 7)).astype(np.uint8)
    out["x_wide1"] = r.randint(0, 256, (1, 300)).astype(np.uint8)
    out["x_tall1"] = r.randint(0, 256, (300, 1)).astype(np.uint8)
    out["x_big"] = cv2.resize(r.randint(0, 256, (60, 80)).astype(np.uint8), (1400, 1050), interpolation=cv2.INTER_CUBIC)
    return out


def main(coco, photos, out):
    os.makedirs(out, exist_ok=True)
    pics = {}
    for d, limit in ((coco, 40), (photos, 99)):
        names = [f for f in sorted(os.listdir(d)) if f.lower().endswith((".jpg", ".jpeg", ".png"))][:limit]
        for f in names:
            im = cv2.imread(os.path.join(d, f), cv2.IMREAD_COLOR)
            if im is not None:
                pics["c_" + os.path.splitext(f)[0]] = im
    pics.update(extremes())
    rows = []
    for name, im in pics.items():
        cv2.imwrite(os.path.join(out, name + ".png"), im)
        # what the engine reads from the PNG is what the oracle measures
        back = cv2.imread(os.path.join(out, name + ".png"), cv2.IMREAD_UNCHANGED)
        g = gray_of(back)
        # OpenCV's own area reductions, written so the guard can compare the engine's area resize pixel for pixel
        hh, ww = g.shape
        if max(ww, hh) > 512:
            sc = 512.0 / max(ww, hh)
            w2 = max(1, int(math.floor(ww * sc + 0.5)))
            h2 = max(1, int(math.floor(hh * sc + 0.5)))
            cv2.imwrite(os.path.join(out, name + "__a512.png"), cv2.resize(g, (w2, h2), interpolation=cv2.INTER_AREA))
        cv2.imwrite(os.path.join(out, name + "__a32.png"), cv2.resize(g, (32, 32), interpolation=cv2.INTER_AREA))
        m, sd, p1, p99, dark, light = exposure(g)
        rows.append((name + ".png", repr(lapvar(g)), repr(sharp512(g)), repr(m), repr(sd), str(p1), str(p99), repr(dark), repr(light), phash(g)))
    with open(os.path.join(out, "oracle.tsv"), "w", encoding="utf-8", newline="\n") as f:
        for r in rows:
            f.write("\t".join(r) + "\n")
    print("wrote", len(rows), "pictures and oracle.tsv to", out, "(OpenCV", cv2.__version__ + ", numpy", np.__version__ + ")")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3])
