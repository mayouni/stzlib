#!/usr/bin/env python3
"""diode_depth.py -- the golden set of relative depth (IM6 of SOFTANZA_IMAGE_INTELLIGENCE.md).

THE TRUTH IS NOT OURS: each expected depth map is DIODE's laser scan (Vasiljevic et al. 2019, the validation
split, val.tar.gz, MD5 5c895d09201b88973c8fe4552a67dd85, from github.com/diode-dataset/diode-devkit), with the
scanner's own validity mask. The samples are picked by a FIXED RULE, written here before any floor or model ran:

  depth_v1   in DIODE val, indoors and outdoor separately, the pictures in sorted path order, every 10th one
             starting with the first: 33 indoors and 45 outdoor scenes.

A prediction is judged as a RELATIVE depth: the model and the floor give inverse depth (larger = nearer) in no
unit, so on each picture the prediction is fitted to the scan's inverse depth by least squares (a scale and a
shift, over the valid pixels), and the error is AbsRel = mean |d - d*| / d* in DEPTH after the fit -- the MiDaS
protocol. A picture agrees when its AbsRel is at most 0.20.

    <docling venv>/python -I diode_depth.py D:\\GitHub\\_wti_models_src

Copies the 78 samples into <src>/diode/depth_v1/ (the picture as PNG, the scan as float32 .npy, the mask as a
PNG of 0 and 255) and writes base/test/image/_golden/diode_depth_v1.ring. The data stays outside the repository:
its licence is not stated in the devkit, so it is used for measuring only.
"""
import os
import shutil
import sys

import cv2
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "_golden", "diode_depth_v1.ring"))


def main():
    src = sys.argv[1]
    val = os.path.join(src, "diode", "val")
    dst = os.path.join(src, "diode", "depth_v1")
    os.makedirs(dst, exist_ok=True)
    rows = []
    for kind in ("indoors", "outdoor"):
        pngs = []
        for root, _, files in os.walk(os.path.join(val, kind)):
            pngs += [os.path.relpath(os.path.join(root, f), val).replace("\\", "/") for f in files if f.endswith(".png")]
        pngs.sort()
        for rel in pngs[::10]:
            base = os.path.join(val, rel[:-4])
            name = os.path.basename(rel[:-4])
            shutil.copyfile(base + ".png", os.path.join(dst, name + ".png"))
            d = np.load(base + "_depth.npy").astype(np.float32)
            d = d[..., 0] if d.ndim == 3 else d
            np.save(os.path.join(dst, name + "_depth.npy"), d)
            mk = np.load(base + "_depth_mask.npy")
            ok = (mk > 0) & (d > 0)
            cv2.imwrite(os.path.join(dst, name + "_mask.png"), ok.astype(np.uint8) * 255)
            rows.append((name, kind, round(float(ok.mean()), 3)))
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write("# diode_depth_v1.ring -- the depth golden set, written by _rig/diode_depth.py: DIODE val's laser scans\n")
        f.write("# (every 10th picture of each kind), in <src>/diode/depth_v1. [ name, kind, share of valid pixels ]\n\n")
        f.write("func StzVisionGoldenDepthV1()\n\treturn [\n")
        for n, r in enumerate(rows):
            f.write('\t\t[ "%s", "%s", %s ]%s\n' % (r[0], r[1], r[2], "," if n < len(rows) - 1 else ""))
        f.write("\t]\n")
    print("depth_v1: %d samples (%d indoors, %d outdoor)" % (len(rows), sum(r[1] == "indoors" for r in rows),
                                                          sum(r[1] == "outdoor" for r in rows)))


if __name__ == "__main__":
    main()
