"""IM9f / WSP: a FRESH judging set for :find -- pictures no implementation, threshold or direction was ever tuned or judged on.

    python owl_golden_fresh.py plan  <lvis_v1_val.json> <coco images dir> <out dir>    choose the pictures, write their list and URLs (no download)
    python owl_golden_fresh.py pairs <lvis_v1_val.json> <coco images dir> <out dir>    after the download: write the pairs

THE RULE (the same text is in SOFTANZA_WEIGHT_SPACE_GOVERNANCE.md, section 8, committed before this file ever ran):

  pictures   LVIS v1 val pictures that are COCO val2017 pictures and are NOT among the 116 the find-v1 golden used (every picture on disk when
             this rule was written), ordered by sha1("find-v2:<id>"), the first 300. All are JUDGING: nothing is tuned on them.
  pairs      exactly the find-v1 rule: a positive is a category with a box of at least 2% of the picture and the picture not in its not-exhaustive
             list; a negative is a category LVIS verified absent; negatives sampled to as many as the positives, in the order of
             sha1("find-v2:<picture>:<category>"); a word is the category's first synonym without a parenthesis; kind A if it is a COCO class name.

Output of `pairs`: the find-v1 format with split "judge2" (split, picture, word, kind, pos|neg, width, height, boxes).
"""
import hashlib
import json
import os
import sys

from owl_golden import COCO80, MIN_AREA, word_of

N_PICTURES = 300
SEED = "find-v2"


def _load(lvis_path, img_dir):
    L = json.load(open(lvis_path, encoding="utf-8"))
    used = {int(f[:12]) for f in os.listdir(img_dir) if f.endswith(".jpg") and f[:12].isdigit()}
    return L, used


def plan(lvis_path, img_dir, out):
    L, used = _load(lvis_path, img_dir)
    cand = [im for im in L["images"] if "val2017" in im["coco_url"] and im["id"] not in used]
    cand.sort(key=lambda im: hashlib.sha1(("%s:%012d" % (SEED, im["id"])).encode()).hexdigest())
    pick = cand[:N_PICTURES]
    os.makedirs(out, exist_ok=True)
    with open(out + "/fresh_pictures.tsv", "w", encoding="utf-8", newline="\n") as f:
        for im in pick:
            f.write("%012d.jpg\t%s\t%d\t%d\n" % (im["id"], im["coco_url"], im["width"], im["height"]))
    print("candidates (val2017, in LVIS val, not on disk):", len(cand), "| chosen:", len(pick), "| list:", out + "/fresh_pictures.tsv")
    return pick


def pairs(lvis_path, img_dir, out, pick=None):
    L, used = _load(lvis_path, img_dir)
    if pick is None:
        ids = [int(l.split("\t")[0][:12]) for l in open(out + "/fresh_pictures.tsv", encoding="utf-8") if l.strip()]
    else:
        ids = [im["id"] for im in pick]
    imgs = {i["id"]: i for i in L["images"]}
    cats = {c["id"]: c for c in L["categories"]}
    by_img = {}
    for a in L["annotations"]:
        by_img.setdefault(a["image_id"], {}).setdefault(a["category_id"], []).append(a)
    pos, neg = [], []
    for iid in sorted(ids):
        im = imgs[iid]
        W, H = im["width"], im["height"]
        notex = set(im["not_exhaustive_category_ids"])
        for cid, anns in sorted(by_img.get(iid, {}).items()):
            if cid in notex:
                continue
            big = [a["bbox"] for a in anns if a["bbox"][2] * a["bbox"][3] >= MIN_AREA * W * H]
            if big:
                w = word_of(cats[cid])
                pos.append((iid, cid, w, "A" if w in COCO80 else "B", "pos", W, H, big))
        for cid in im["neg_category_ids"]:
            w = word_of(cats[cid])
            neg.append((iid, cid, w, "A" if w in COCO80 else "B", "neg", W, H, []))
    neg.sort(key=lambda r: hashlib.sha1(("%s:%012d:%d" % (SEED, r[0], r[1])).encode()).hexdigest())
    neg = neg[:len(pos)]
    rows = sorted(pos + neg, key=lambda r: (r[0], r[1]))
    with open(out + "/owl_find_v2.tsv", "w", encoding="utf-8", newline="\n") as f:
        for (iid, cid, w, kind, pol, W, H, boxes) in rows:
            f.write("\t".join(["judge2", "%012d.jpg" % iid, w, kind, pol, str(W), str(H), ";".join("%.2f %.2f %.2f %.2f" % tuple(b) for b in boxes)]) + "\n")
    print("pairs", len(rows), "| pictures", len({r[0] for r in rows}), "| words", len({r[2] for r in rows}), "| positive", len(pos),
          "| kind A", sum(1 for r in rows if r[3] == "A"), "kind B", sum(1 for r in rows if r[3] == "B"))


if __name__ == "__main__":
    {"plan": plan, "pairs": pairs}[sys.argv[1]](*sys.argv[2:5])
