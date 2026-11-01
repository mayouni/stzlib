#!/usr/bin/env python3
"""coco_golden.py -- the image plane's golden sets (IM4 of SOFTANZA_IMAGE_INTELLIGENCE.md), from COCO val2017.

THE TRUTH IS NOT OURS. Every expected answer comes from COCO's official annotations (instances_val2017.json and
person_keypoints_val2017.json, CC BY 4.0, https://cocodataset.org), written by COCO's annotators -- independent of
every floor and every model judged here (the model-flow law: golden independent of the floor). The images are
picked by FIXED RULES in ascending image-id order, written here before any model ran on them:

  faces_v1    the first 30 images with at least one person whose nose and both eyes are visible (v=2) and whose
              eyes stand at least 12 px apart; per image every person's nose is listed, marked REQUIRED when that
              rule holds and IGNORABLE otherwise (a face found there is neither a hit required nor a false alarm)
  objects_v1  the first 40 images with at least one non-crowd object of area >= 32x32 px; every object is listed,
              marked COUNTED when non-crowd and >= 32x32, else IGNORABLE (too small or a crowd)
  labels_v1   the first 40 images whose LARGEST non-crowd object is not a person, belongs to the vocabulary the
              classifier can map to, and covers at least 15% of the image; the expected answer is its category

THE FLOOR'S CONSTANT for labels_v1 is the vocabulary category present in the most val2017 images OUTSIDE labels_v1
(printed below and written into the golden file), so the floor's answer is not tuned on the items that judge it.

    <docling venv>/python -I coco_golden.py D:\\GitHub\\_wti_models_src    (needs <src>/coco/annotations/*.json)

Writes base/test/image/_golden/coco_v1.ring (the expected answers, 1-based pixels, with each image's licence and
Flickr source), and fetches the selected images into <src>/coco/images with their sha256 in MANIFEST.tsv.
"""
import hashlib
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "_golden", "coco_v1.ring"))

# COCO categories the ImageNet classifier can answer (the mapping itself is in base/image/stzVision.ring)
VOCAB = ["bicycle", "car", "motorcycle", "airplane", "bus", "train", "truck", "boat", "traffic light",
         "parking meter", "bench", "bird", "cat", "dog", "horse", "sheep", "cow", "elephant", "bear", "zebra",
         "umbrella", "banana", "orange", "broccoli", "hot dog", "pizza", "chair", "couch", "bed", "dining table",
         "toilet", "tv", "laptop", "mouse", "keyboard", "cell phone", "microwave", "refrigerator", "clock", "vase",
         "teddy bear"]


def main():
    src = sys.argv[1]
    ann = os.path.join(src, "coco", "annotations")
    inst = json.load(open(os.path.join(ann, "instances_val2017.json"), encoding="utf-8"))
    kps = json.load(open(os.path.join(ann, "person_keypoints_val2017.json"), encoding="utf-8"))
    cats = {c["id"]: c["name"] for c in inst["categories"]}
    imgs = {i["id"]: i for i in inst["images"]}
    lic = {l["id"]: l["name"] for l in inst["licenses"]}
    by_img = {}
    for a in inst["annotations"]:
        by_img.setdefault(a["image_id"], []).append(a)
    kp_by_img = {}
    for a in kps["annotations"]:
        kp_by_img.setdefault(a["image_id"], []).append(a)
    ids = sorted(imgs)

    faces = []
    for iid in ids:
        rows = []
        any_req = False
        for a in kp_by_img.get(iid, []):
            k = a["keypoints"]  # nose, left_eye, right_eye, ...: (x, y, v) triplets
            nx, ny, nv = k[0:3]
            lx, ly, lv = k[3:6]
            rx, ry, rv = k[6:9]
            if nv == 0:
                continue
            eye = ((lx - rx) ** 2 + (ly - ry) ** 2) ** 0.5 if lv > 0 and rv > 0 else 0
            req = 1 if (nv == 2 and lv == 2 and rv == 2 and eye >= 12 and not a.get("iscrowd", 0)) else 0
            any_req = any_req or req == 1
            rows.append([nx + 1, ny + 1, round(eye, 1), req])
        if any_req:
            faces.append((iid, rows))
        if len(faces) == 30:
            break

    objects = []
    for iid in ids:
        rows = []
        counted = 0
        for a in by_img.get(iid, []):
            x, y, w, h = a["bbox"]
            c = 1 if (not a.get("iscrowd", 0) and w * h >= 1024) else 0
            counted += c
            rows.append([cats[a["category_id"]], round(x + 1, 1), round(y + 1, 1), round(w, 1), round(h, 1), c])
        if counted > 0:
            objects.append((iid, rows))
        if len(objects) == 40:
            break

    labels = []
    for iid in ids:
        anns = [a for a in by_img.get(iid, []) if not a.get("iscrowd", 0)]
        if not anns:
            continue
        big = max(anns, key=lambda a: a["area"])
        name = cats[big["category_id"]]
        im = imgs[iid]
        if name in VOCAB and big["area"] >= 0.15 * im["width"] * im["height"]:
            labels.append((iid, name))
        if len(labels) == 40:
            break
    golden_label_ids = {i for i, _ in labels}

    # the floor's constant: the vocabulary category present in the most val2017 images outside labels_v1
    count = {}
    for iid, anns in by_img.items():
        if iid in golden_label_ids:
            continue
        for name in {cats[a["category_id"]] for a in anns}:
            if name in VOCAB:
                count[name] = count.get(name, 0) + 1
    prior = max(count, key=count.get)
    print("floor constant for labels_v1:", prior, "(in", count[prior], "val2017 images outside the golden)")

    # fetch the selected images
    need = sorted({i for i, _ in faces} | {i for i, _ in objects} | {i for i, _ in labels})
    idir = os.path.join(src, "coco", "images")
    os.makedirs(idir, exist_ok=True)
    man = []
    for iid in need:
        im = imgs[iid]
        p = os.path.join(idir, im["file_name"])
        if not os.path.exists(p):
            subprocess.run(["curl", "-s", "-f", "-L", "-o", p, im["coco_url"]], check=True)
        h = hashlib.sha256(open(p, "rb").read()).hexdigest()
        man.append([im["file_name"], h, os.path.getsize(p), lic.get(im["license"], "?"), im.get("flickr_url", "")])
    with open(os.path.join(idir, "MANIFEST.tsv"), "w", encoding="utf-8") as f:
        f.write("file\tsha256\tbytes\tlicence\tsource\n")
        for r in man:
            f.write("\t".join(str(x) for x in r) + "\n")

    def q(s):
        return '"' + str(s).replace('"', "'") + '"'

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write("# coco_v1.ring -- the image plane's golden sets, written by _rig/coco_golden.py from COCO val2017.\n")
        f.write("# The expected answers are COCO's annotators' (CC BY 4.0, https://cocodataset.org), not ours; 1-based\n")
        f.write("# pixels. The images are not in the tree (D:/GitHub/_wti_models_src/coco/images, sha256 in MANIFEST.tsv);\n")
        f.write("# each is listed at the end with its licence and Flickr source. Generated -- do not edit by hand.\n\n")
        f.write("func StzVisionGoldenFacesV1()\n\treturn [\n")
        for n, (iid, rows) in enumerate(faces):
            f.write("\t\t[ %s, [ %s ] ]%s\n" % (q(imgs[iid]["file_name"]), ", ".join("[ %s, %s, %s, %d ]" % tuple(r) for r in rows), "," if n < len(faces) - 1 else ""))
        f.write("\t]\n\nfunc StzVisionGoldenObjectsV1()\n\treturn [\n")
        for n, (iid, rows) in enumerate(objects):
            f.write("\t\t[ %s, [ %s ] ]%s\n" % (q(imgs[iid]["file_name"]), ", ".join("[ %s, %s, %s, %s, %s, %d ]" % (q(r[0]), r[1], r[2], r[3], r[4], r[5]) for r in rows), "," if n < len(objects) - 1 else ""))
        f.write("\t]\n\nfunc StzVisionGoldenLabelsV1()\n\treturn [\n")
        for n, (iid, name) in enumerate(labels):
            f.write("\t\t[ %s, %s ]%s\n" % (q(imgs[iid]["file_name"]), q(name), "," if n < len(labels) - 1 else ""))
        f.write("\t]\n\n# the floor's constant (the vocabulary category in the most val2017 images outside labels_v1)\n")
        f.write("func StzVisionGoldenLabelPriorV1()\n\treturn %s\n\n" % q(prior))
        f.write("# the images, their licences and sources (COCO's image records)\nfunc StzVisionGoldenImagesV1()\n\treturn [\n")
        for n, r in enumerate(man):
            f.write("\t\t[ %s, %s, %s ]%s\n" % (q(r[0]), q(r[3]), q(r[4]), "," if n < len(man) - 1 else ""))
        f.write("\t]\n")
    print("faces_v1 %d, objects_v1 %d, labels_v1 %d; %d images; written %s" % (len(faces), len(objects), len(labels), len(need), OUT))


if __name__ == "__main__":
    main()
