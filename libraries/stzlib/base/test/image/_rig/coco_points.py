#!/usr/bin/env python3
"""coco_points.py -- the golden set of :object-at, an object picked by a point (IM6 of SOFTANZA_IMAGE_INTELLIGENCE.md).

THE SAME 30 IMAGES AND TRUTHS AS :foreground (coco_masks_v1, written by coco_masks.py): each expected mask is the
polygon COCO's annotators drew. What is added is the PROMPT, by a FIXED RULE written before any floor or model
ran on it:

  points_v1  for each item of masks_v1, the pixel of COCO's mask farthest from the mask's border (OpenCV's exact
             L2 distance transform; the first in raster order on a tie), as [ x, y ] 1-based. A point that deep is
             on the object by COCO's own drawing, and says nothing about where a model would look.

    <docling venv>/python -I coco_points.py D:\\GitHub\\_wti_models_src

Writes base/test/image/_golden/coco_points_v1.ring.
"""
import os
import re
import sys

import cv2
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
SRC_GOLDEN = os.path.normpath(os.path.join(HERE, "..", "_golden", "coco_masks_v1.ring"))
OUT = os.path.normpath(os.path.join(HERE, "..", "_golden", "coco_points_v1.ring"))


def main():
    src = sys.argv[1]
    rows = re.findall(r'\[ "([^"]+)", "([^"]+)", "([^"]+)", ([0-9.]+) \]', open(SRC_GOLDEN, encoding="utf-8").read())
    out = []
    for img, mask, cat, frac in rows:
        m = cv2.imread(os.path.join(src, "coco", "masks", mask), cv2.IMREAD_GRAYSCALE)
        d = cv2.distanceTransform((m >= 128).astype(np.uint8), cv2.DIST_L2, cv2.DIST_MASK_PRECISE)
        k = int(np.argmax(d))  # (numpy's argmax is the first maximum in raster order)
        y, x = divmod(k, m.shape[1])
        out.append((img, mask, cat, x + 1, y + 1, round(float(d.flat[k]), 1)))
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write("# coco_points_v1.ring -- the :object-at golden set, written by _rig/coco_points.py: the 30 items of\n")
        f.write("# coco_masks_v1, each prompted by the pixel deepest inside COCO's mask. [ image, mask, category, x, y,\n")
        f.write("# its distance to the mask's border in pixels ], the point 1-based. Generated.\n\n")
        f.write("func StzVisionGoldenPointsV1()\n\treturn [\n")
        for n, r in enumerate(out):
            f.write('\t\t[ "%s", "%s", "%s", %d, %d, %s ]%s\n' % (r + ("," if n < len(out) - 1 else "",)))
        f.write("\t]\n")
    print("points_v1: %d items, depth from %.1f to %.1f px" % (len(out), min(r[5] for r in out), max(r[5] for r in out)))


if __name__ == "__main__":
    main()
