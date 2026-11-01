#!/usr/bin/env python3
"""coco_dev.py -- a DEV set for :faces, kept apart from the golden set (IM4 of SOFTANZA_IMAGE_INTELLIGENCE.md).

A model's knob (YuNet's score threshold) may be chosen only on items the golden set never sees, or the golden
measures how well the knob was fitted to it. The rule, fixed before any model ran on these images: the NEXT 30
COCO val2017 images in ascending id order that satisfy faces_v1's own rule (a person whose nose and both eyes are
visible and whose eyes stand >= 12 px apart), starting after the last faces_v1 image. Truth: COCO's annotations.

    <docling venv>/python -I coco_dev.py D:\\GitHub\\_wti_models_src

Writes base/test/image/_golden/coco_dev_faces.ring and fetches the images into <src>/coco/images (MANIFEST).
"""
import hashlib
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
GOLD = os.path.normpath(os.path.join(HERE, "..", "_golden", "coco_v1.ring"))
OUT = os.path.normpath(os.path.join(HERE, "..", "_golden", "coco_dev_faces.ring"))


def main():
    src = sys.argv[1]
    kps = json.load(open(os.path.join(src, "coco", "annotations", "person_keypoints_val2017.json"), encoding="utf-8"))
    imgs = {i["id"]: i for i in kps["images"]}
    lic = {l["id"]: l["name"] for l in kps["licenses"]}
    by = {}
    for a in kps["annotations"]:
        by.setdefault(a["image_id"], []).append(a)
    faces_part = open(GOLD, encoding="utf-8").read().split("func StzVisionGoldenObjectsV1")[0]
    golden = {int(f[:-4]) for f in re.findall(r'"(\d+\.jpg)"', faces_part)}
    last = max(golden)
    dev = []
    for iid in sorted(imgs):
        if iid <= last or iid in golden:
            continue
        rows, req = [], 0
        for a in by.get(iid, []):
            k = a["keypoints"]
            nx, ny, nv = k[0:3]
            lv, rv = k[5], k[8]
            if nv == 0:
                continue
            eye = ((k[3] - k[6]) ** 2 + (k[4] - k[7]) ** 2) ** 0.5 if lv > 0 and rv > 0 else 0
            r = 1 if (nv == 2 and lv == 2 and rv == 2 and eye >= 12 and not a.get("iscrowd", 0)) else 0
            req += r
            rows.append([nx + 1, ny + 1, round(eye, 1), r])
        if req:
            dev.append((iid, rows))
        if len(dev) == 30:
            break
    idir = os.path.join(src, "coco", "images")
    man_path = os.path.join(idir, "MANIFEST.tsv")
    known = open(man_path, encoding="utf-8").read() if os.path.exists(man_path) else ""
    with open(man_path, "a", encoding="utf-8") as man:
        for iid, _ in dev:
            im = imgs[iid]
            p = os.path.join(idir, im["file_name"])
            if not os.path.exists(p):
                subprocess.run(["curl", "-s", "-f", "-L", "-o", p, im["coco_url"]], check=True)
            if im["file_name"] not in known:
                h = hashlib.sha256(open(p, "rb").read()).hexdigest()
                man.write("\t".join([im["file_name"], h, str(os.path.getsize(p)), lic.get(im["license"], "?"), im.get("flickr_url", "")]) + "\n")
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write("# coco_dev_faces.ring -- the :faces DEV set, written by _rig/coco_dev.py: COCO val2017 annotations (CC BY 4.0),\n")
        f.write("# the 30 images after faces_v1 by the same rule. For choosing knobs ONLY; never a measurement. Generated.\n\n")
        f.write("func StzVisionDevFacesV1()\n\treturn [\n")
        for n, (iid, rows) in enumerate(dev):
            f.write('\t\t[ "%s", [ %s ] ]%s\n' % (imgs[iid]["file_name"], ", ".join("[ %s, %s, %s, %d ]" % tuple(r) for r in rows), "," if n < len(dev) - 1 else ""))
        f.write("\t]\n")
    print("dev faces: %d images (ids %d..%d), written %s" % (len(dev), dev[0][0], dev[-1][0], OUT))


if __name__ == "__main__":
    main()
