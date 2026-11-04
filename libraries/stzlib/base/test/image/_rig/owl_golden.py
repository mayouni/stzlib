"""IM9f: the golden of :find -- (picture, WORD) pairs with truth from LVIS, made by a rule fixed before any model saw them.

    python owl_golden.py <lvis_v1_val.json> <coco images dir> <out.tsv>

THE RULE (the same text is in SOFTANZA_IMAGE_INTELLIGENCE.md, row IM9f, committed before this file ever ran):

  pictures   the COCO val2017 pictures on disk that LVIS v1 val annotates, sorted by id. The first 40 are DEV (they choose each implementation's
             score threshold and nothing else); the rest are JUDGING, run once.
  words      a LVIS category's word: its first synonym without a parenthesis, else the first synonym with the parenthetical dropped; "_" -> " ".
  positive   a (picture, category) pair where the category has at least one instance whose box is at least 2% of the picture, and the picture is
             not in the category's not-exhaustive list (LVIS did not annotate every instance there). The truth boxes are those instances.
  negative   a (picture, category) pair where the category is in the picture's neg_category_ids (LVIS verified it ABSENT). Sampled to as many as
             the positives of the same split, in the order of sha1("find-v1:<picture>:<category>").
  kind       A if the word is one of YOLOX's 80 COCO class names (the floor can answer it), else B (it cannot).
  scoring    done by the checker `find-f1` (stzFaculty.ring), not here.

Each output line: split <TAB> picture file <TAB> word <TAB> kind <TAB> pos|neg <TAB> width <TAB> height <TAB> boxes "x y w h;x y w h" (LVIS's 0-based
pixels, positives only)
"""
import hashlib
import json
import os
import sys

COCO80 = ["person", "bicycle", "car", "motorcycle", "airplane", "bus", "train", "truck", "boat", "traffic light", "fire hydrant", "stop sign",
          "parking meter", "bench", "bird", "cat", "dog", "horse", "sheep", "cow", "elephant", "bear", "zebra", "giraffe", "backpack", "umbrella",
          "handbag", "tie", "suitcase", "frisbee", "skis", "snowboard", "sports ball", "kite", "baseball bat", "baseball glove", "skateboard",
          "surfboard", "tennis racket", "bottle", "wine glass", "cup", "fork", "knife", "spoon", "bowl", "banana", "apple", "sandwich", "orange",
          "broccoli", "carrot", "hot dog", "pizza", "donut", "cake", "chair", "couch", "potted plant", "bed", "dining table", "toilet", "tv",
          "laptop", "mouse", "remote", "keyboard", "cell phone", "microwave", "oven", "toaster", "sink", "refrigerator", "book", "clock", "vase",
          "scissors", "teddy bear", "hair drier", "toothbrush"]

MIN_AREA = 0.02
DEV = 40


def word_of(cat):
    syn = cat["synonyms"]
    plain = [s for s in syn if "(" not in s]
    w = plain[0] if plain else syn[0].split("_(")[0]
    return w.replace("_", " ").lower()


def main(lvis_path, img_dir, out):
    L = json.load(open(lvis_path, encoding="utf-8"))
    have = sorted(int(f[:12]) for f in os.listdir(img_dir) if f.endswith(".jpg") and f[:12].isdigit())
    imgs = {i["id"]: i for i in L["images"]}
    ids = [i for i in have if i in imgs]
    cats = {c["id"]: c for c in L["categories"]}
    by_img = {}
    for a in L["annotations"]:
        if a["image_id"] in imgs:
            by_img.setdefault(a["image_id"], {}).setdefault(a["category_id"], []).append(a)
    rows = {"dev": ([], []), "judge": ([], [])}
    for n, iid in enumerate(ids):
        split = "dev" if n < DEV else "judge"
        im = imgs[iid]
        W, H = im["width"], im["height"]
        notex = set(im["not_exhaustive_category_ids"])
        for cid, anns in sorted(by_img.get(iid, {}).items()):
            if cid in notex:
                continue
            big = [a["bbox"] for a in anns if a["bbox"][2] * a["bbox"][3] >= MIN_AREA * W * H]
            if not big:
                continue
            w = word_of(cats[cid])
            rows[split][0].append((iid, cid, w, "A" if w in COCO80 else "B", "pos", W, H, big))
        for cid in im["neg_category_ids"]:
            w = word_of(cats[cid])
            rows[split][1].append((iid, cid, w, "A" if w in COCO80 else "B", "neg", W, H, []))
    lines = []
    for split in ("dev", "judge"):
        pos, neg = rows[split]
        neg.sort(key=lambda r: hashlib.sha1(("find-v1:%012d:%d" % (r[0], r[1])).encode()).hexdigest())
        neg = neg[:len(pos)]
        for r in pos + sorted(neg, key=lambda r: (r[0], r[1])):
            lines.append((split, r))
    lines.sort(key=lambda t: (t[0] != "dev", t[1][0], t[1][1]))
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        for split, (iid, cid, w, kind, pol, W, H, boxes) in lines:
            f.write("\t".join([split, "%012d.jpg" % iid, w, kind, pol, str(W), str(H), ";".join("%.2f %.2f %.2f %.2f" % tuple(b) for b in boxes)]) + "\n")
    for split in ("dev", "judge"):
        sub = [r for s, r in lines if s == split]
        print(split, "pairs", len(sub), "| pictures", len({r[0] for r in sub}), "| words", len({r[2] for r in sub}),
              "| positive", sum(1 for r in sub if r[4] == "pos"), "| kind A", sum(1 for r in sub if r[3] == "A"), "kind B", sum(1 for r in sub if r[3] == "B"))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3])
