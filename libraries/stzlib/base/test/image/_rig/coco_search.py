#!/usr/bin/env python3
"""coco_search.py -- the truth for image search by text (IM5 of SOFTANZA_IMAGE_INTELLIGENCE.md).

Every COCO val2017 image already fetched into <src>/coco/images (the golden and dev sets of IM4, 118 files), with
the categories COCO's annotators marked in it -- every non-crowd object of area >= 32 x 32 px. A search for
"a photo of a <category>" is right at rank k when COCO marks that category in the image found there. The truth is
COCO's (CC BY 4.0), not ours; nothing here ran a model.

The QUERIES are fixed by a rule, written before any search ran: every category marked in at least 4 of the images
(so a top-3 can be all right), in COCO's own category order.

    <docling venv>/python -I coco_search.py D:\\GitHub\\_wti_models_src

Writes base/test/image/_golden/coco_search_v1.ring.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "_golden", "coco_search_v1.ring"))


def main():
    src = sys.argv[1]
    inst = json.load(open(os.path.join(src, "coco", "annotations", "instances_val2017.json"), encoding="utf-8"))
    cats = {c["id"]: c["name"] for c in inst["categories"]}
    order = [c["name"] for c in sorted(inst["categories"], key=lambda c: c["id"])]
    idir = os.path.join(src, "coco", "images")
    files = sorted(f for f in os.listdir(idir) if f.endswith(".jpg"))
    by_file = {i["file_name"]: i["id"] for i in inst["images"]}
    marked = {f: set() for f in files}
    ids = {by_file[f]: f for f in files}
    for a in inst["annotations"]:
        f = ids.get(a["image_id"])
        if f and not a.get("iscrowd", 0) and a["bbox"][2] * a["bbox"][3] >= 1024:
            marked[f].add(cats[a["category_id"]])
    count = {c: sum(1 for f in files if c in marked[f]) for c in order}
    queries = [c for c in order if count[c] >= 4]

    def q(s):
        return '"' + s.replace('"', "'") + '"'

    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write("# coco_search_v1.ring -- the truth for image search by text, written by _rig/coco_search.py from COCO\n")
        f.write("# val2017's annotations (CC BY 4.0): the categories marked in each image (non-crowd, >= 32x32 px), and\n")
        f.write("# the queries -- every category marked in at least 4 of the images. Generated -- do not edit by hand.\n\n")
        f.write("func StzVisionSearchImagesV1()\n\treturn [\n")
        for n, fn in enumerate(files):
            f.write("\t\t[ %s, [ %s ] ]%s\n" % (q(fn), ", ".join(q(c) for c in sorted(marked[fn])), "," if n < len(files) - 1 else ""))
        f.write("\t]\n\nfunc StzVisionSearchQueriesV1()\n\treturn [ %s ]\n" % ", ".join(q(c) for c in queries))
    print("%d images, %d queries: %s" % (len(files), len(queries), ", ".join("%s (%d)" % (c, count[c]) for c in queries)))


if __name__ == "__main__":
    main()
