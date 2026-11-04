"""IM9d, slice 3: pairs of pictures whose relation was made BY CONSTRUCTION -- the golden set for near-duplicate detection.
The truth is whether two files came from the same photograph, never what a hash or a model says about them.

    python quality_pairs.py <coco images dir> <out dir> <first> <last>

Takes the COCO pictures sorted by name, <first> to <last> (the DEV slice is 0 to 40, the JUDGING slice 40 to the end: disjoint),
each brought to a long side of at most 640 (area shrink). For each source picture i it writes the picture and five copies of it:

  <i>__base   the picture
  <i>__crop   its central 90% (a crop)
  <i>__half   shrunk to half its size (a resize)
  <i>__jpg    re-encoded as a JPEG at quality 30 (a heavy re-encode)
  <i>__up     brighter, gain 1.3, clipped
  <i>__down   darker, gain 0.8

and pairs.tsv: fileA <TAB> fileB <TAB> label <TAB> kind.
  POSITIVES (label 1), five per source: base against each of its five copies.
  NEGATIVES (label 0), five per source: base_i against a copy of ANOTHER source j chosen by a fixed rule (j = i + 3 + 2k mod N, the
  copy cycling base, crop, half, jpg, up) -- so a negative is sometimes a photograph against an edited copy of a different one,
  the hard case, and never two files of one photograph.
Equal numbers of both, so a verdict that always says "same" or always "different" scores 50%.
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


def copies(im):
    h, w = im.shape[:2]
    dh, dw = int(h * 0.05), int(w * 0.05)
    return {
        "base": im,
        "crop": im[dh:h - dh, dw:w - dw],
        "half": cv2.resize(im, (max(1, w // 2), max(1, h // 2)), interpolation=cv2.INTER_AREA),
        "jpg": im,
        "up": np.clip(im.astype(np.float32) * 1.3, 0, 255).astype(np.uint8),
        "down": np.clip(im.astype(np.float32) * 0.8, 0, 255).astype(np.uint8),
    }


def main(coco, out, first, last):
    os.makedirs(out, exist_ok=True)
    names = [f for f in sorted(os.listdir(coco)) if f.lower().endswith((".jpg", ".jpeg", ".png"))][first:last]
    files = []
    for i, f in enumerate(names):
        cs = copies(load(os.path.join(coco, f)))
        row = {}
        for k, img in cs.items():
            if k == "jpg":
                fn = "%03d__jpg.jpg" % i
                cv2.imwrite(os.path.join(out, fn), img, [cv2.IMWRITE_JPEG_QUALITY, 30])
            else:
                fn = "%03d__%s.png" % (i, k)
                cv2.imwrite(os.path.join(out, fn), img)
            row[k] = fn
        files.append(row)
    n = len(files)
    pairs = []
    for i in range(n):
        for k in ("crop", "half", "jpg", "up", "down"):
            pairs.append((files[i]["base"], files[i][k], "1", "same:" + k))
    cyc = ["base", "crop", "half", "jpg", "up"]
    for i in range(n):
        for k in range(5):
            j = (i + 3 + 2 * k) % n
            if j == i:
                j = (j + 1) % n
            pairs.append((files[i]["base"], files[j][cyc[k]], "0", "different:" + cyc[k]))
    with open(os.path.join(out, "pairs.tsv"), "w", encoding="utf-8", newline="\n") as fh:
        for p in pairs:
            fh.write("\t".join(p) + "\n")
    print("wrote", n, "sources,", len(pairs), "pairs (", n * 5, "same,", n * 5, "different ) to", out)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4]))
