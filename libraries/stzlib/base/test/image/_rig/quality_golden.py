"""IM9d, slice 2: pictures whose blur and exposure were made BY CONSTRUCTION -- the golden set for IsBlurry and
IsUnderexposed / IsOverexposed. The truth is what was done to the picture, never what a measure says about it.

    python quality_golden.py <coco images dir> <out dir> <first> <last>

Takes the COCO pictures sorted by name, <first> to <last> (the DEV slice is 0 to 40, the JUDGING slice 40 to the end: disjoint),
each brought to a long side of at most 640 (area shrink), and writes for each:

  <id>__orig        the picture itself            blur: sharp*     exposure: ok
  <id>__blur3       Gaussian blur, sigma 3        blur: blurry     exposure: ok
  <id>__blur5       Gaussian blur, sigma 5        blur: blurry     exposure: ok
  <id>__motion      motion blur, a 25-pixel line  blur: blurry     exposure: ok
  <id>__under30     gain 0.30                     blur: sharp      exposure: under
  <id>__under45     gain 0.45                     blur: sharp      exposure: under
  <id>__over22      gain 2.2, clipped             blur: -          exposure: over
  <id>__over30      gain 3.0, clipped             blur: -          exposure: over

  * the original is ASSUMED sharp: a COCO photograph can itself be out of focus, and one that is counts as a false alarm.
  A darkened picture is as sharp as it was (so a blur verdict must not call it blurry); a blown-out one has lost detail to
  clipping, so no blur label is given to it. Only DECISIVE degradations are made: the borderline (gain 0.6 to 1.6, sigma 1)
  is not judged. truth.tsv: file <TAB> variant <TAB> blur label <TAB> exposure label.
"""
import os
import sys

import cv2
import numpy as np


def load(path):
    im = cv2.imread(path, cv2.IMREAD_COLOR)
    h, w = im.shape[:2]
    long_side = max(w, h)
    if long_side > 640:
        s = 640.0 / long_side
        im = cv2.resize(im, (max(1, int(round(w * s))), max(1, int(round(h * s)))), interpolation=cv2.INTER_AREA)
    return im


def gain(im, g):
    return np.clip(im.astype(np.float32) * g, 0, 255).astype(np.uint8)


def motion(im, length=25, angle=20.0):
    k = np.zeros((length, length), dtype=np.float32)
    k[length // 2, :] = 1.0
    m = cv2.getRotationMatrix2D((length / 2 - 0.5, length / 2 - 0.5), angle, 1.0)
    k = cv2.warpAffine(k, m, (length, length))
    k /= k.sum()
    return cv2.filter2D(im, -1, k, borderType=cv2.BORDER_REFLECT_101)


def main(coco, out, first, last):
    os.makedirs(out, exist_ok=True)
    names = [f for f in sorted(os.listdir(coco)) if f.lower().endswith((".jpg", ".jpeg", ".png"))][first:last]
    rows = []
    for f in names:
        base = os.path.splitext(f)[0]
        im = load(os.path.join(coco, f))
        variants = [
            ("orig", im, "sharp", "ok"),
            ("blur3", cv2.GaussianBlur(im, (0, 0), 3.0), "blurry", "ok"),
            ("blur5", cv2.GaussianBlur(im, (0, 0), 5.0), "blurry", "ok"),
            ("motion", motion(im), "blurry", "ok"),
            ("under30", gain(im, 0.30), "sharp", "under"),
            ("under45", gain(im, 0.45), "sharp", "under"),
            ("over22", gain(im, 2.2), "-", "over"),
            ("over30", gain(im, 3.0), "-", "over"),
        ]
        for name, img, blur, expo in variants:
            cv2.imwrite(os.path.join(out, base + "__" + name + ".png"), img)
            rows.append((base + "__" + name + ".png", name, blur, expo))
    with open(os.path.join(out, "truth.tsv"), "w", encoding="utf-8", newline="\n") as fh:
        for r in rows:
            fh.write("\t".join(r) + "\n")
    print("wrote", len(rows), "pictures of", len(names), "COCO sources to", out)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4]))
