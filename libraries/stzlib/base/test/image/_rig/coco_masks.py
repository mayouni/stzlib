#!/usr/bin/env python3
"""coco_masks.py -- the golden set of :foreground, the salient object's mask (IM6 of SOFTANZA_IMAGE_INTELLIGENCE.md).

THE TRUTH IS NOT OURS: each expected mask is the polygon COCO's annotators drew around one object
(instances_val2017.json, CC BY 4.0), filled by OpenCV. The images are picked by a FIXED RULE, written here before
any floor or model ran on them:

  masks_v1   among the COCO val2017 images already fetched (<src>/coco/images, IM4's sets), in ascending id order,
             the first 30 whose largest non-crowd object covers 10% to 60% of the picture and stands ALONE -- the
             second largest object of any category is at most a third of its area. The expected answer is that
             object's mask. A prediction agrees when its pixels at 128 or more overlap the mask at IoU >= 0.5.

    <docling venv>/python -I coco_masks.py D:\\GitHub\\_wti_models_src

Writes base/test/image/_golden/coco_masks_v1.ring and the masks into <src>/coco/masks/<image id>.png.
"""
import json
import os
import sys

import cv2
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "_golden", "coco_masks_v1.ring"))


def main():
    src = sys.argv[1]
    inst = json.load(open(os.path.join(src, "coco", "annotations", "instances_val2017.json"), encoding="utf-8"))
    cats = {c["id"]: c["name"] for c in inst["categories"]}
    imgs = {i["id"]: i for i in inst["images"]}
    idir = os.path.join(src, "coco", "images")
    have = {f for f in os.listdir(idir) if f.endswith(".jpg")}
    by = {}
    for a in inst["annotations"]:
        by.setdefault(a["image_id"], []).append(a)
    mdir = os.path.join(src, "coco", "masks")
    os.makedirs(mdir, exist_ok=True)
    rows = []
    for iid in sorted(imgs):
        im = imgs[iid]
        if im["file_name"] not in have:
            continue
        anns = sorted((a for a in by.get(iid, []) if not a.get("iscrowd", 0)), key=lambda a: -a["area"])
        if not anns:
            continue
        big = anns[0]
        frac = big["area"] / (im["width"] * im["height"])
        if frac < 0.10 or frac > 0.60:
            continue
        if len(anns) > 1 and anns[1]["area"] > big["area"] / 3:
            continue
        mask = np.zeros((im["height"], im["width"]), np.uint8)
        for poly in big["segmentation"]:
            pts = np.round(np.array(poly, dtype=np.float64).reshape(-1, 2)).astype(np.int32)
            cv2.fillPoly(mask, [pts], 255)
        name = "%012d.png" % iid
        cv2.imwrite(os.path.join(mdir, name), mask)
        rows.append((im["file_name"], name, cats[big["category_id"]], round(frac, 3)))
        if len(rows) == 30:
            break
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write("# coco_masks_v1.ring -- the :foreground golden set, written by _rig/coco_masks.py: each expected mask is\n")
        f.write("# the polygon COCO's annotators drew (CC BY 4.0), filled by OpenCV, in <src>/coco/masks. Generated.\n\n")
        f.write("func StzVisionGoldenMasksV1()\n\treturn [\n")
        for n, r in enumerate(rows):
            f.write('\t\t[ "%s", "%s", "%s", %s ]%s\n' % (r[0], r[1], r[2], r[3], "," if n < len(rows) - 1 else ""))
        f.write("\t]\n")
    print("masks_v1: %d images: %s" % (len(rows), ", ".join("%s %s" % (r[2], r[3]) for r in rows)))


if __name__ == "__main__":
    main()
