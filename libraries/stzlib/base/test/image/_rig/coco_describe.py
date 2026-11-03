#!/usr/bin/env python3
"""coco_describe.py -- the golden set of :describe (IM7 of SOFTANZA_IMAGE_INTELLIGENCE.md), from COCO val2017.

THE TRUTH IS NOT OURS: what a picture shows is COCO's annotation (instances_val2017.json, CC BY 4.0), written by
COCO's annotators. A description AGREES when it names the picture's MAIN object -- its largest non-crowd
annotated object -- by the category's name or one of the words below. The rule and the words were fixed here
before any floor or model described a picture of the set:

  describe_v1   the COCO val2017 pictures already in <src>/coco/images (fetched by coco_golden.py, coco_masks.py
                and coco_points.py by their own rules), in ascending id order, whose largest non-crowd object
                covers at least 10% of the picture

THE FLOOR'S CONSTANT is the category that is the main object (by the same rule) of the most val2017 pictures
OUTSIDE describe_v1, so the floor's sentence is not tuned on the pictures that judge it.

A second figure, never the score: the categories a description names that COCO did NOT annotate in the picture
(a description that invents objects).

    <docling venv>/python -I coco_describe.py D:\\GitHub\\_wti_models_src

Writes base/test/image/_golden/coco_describe_v1.ring.
"""
import collections
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "_golden", "coco_describe_v1.ring"))

# the words that name each category, besides its own name (a plural is matched by the checker)
WORDS = {
    "person": ["people", "man", "men", "woman", "women", "boy", "girl", "child", "children", "kid", "baby",
               "player", "lady", "guy", "skier", "surfer", "skateboarder", "snowboarder", "rider", "crowd",
               "individual", "someone", "pedestrian", "tennis player", "batter", "catcher", "officer", "chef"],
    "bicycle": ["bike", "cyclist"], "car": ["vehicle", "taxi", "sedan", "suv"], "motorcycle": ["motorbike", "scooter"],
    "airplane": ["plane", "aircraft", "jet", "airliner"], "bus": [], "train": ["locomotive", "railway car", "tram"],
    "truck": ["lorry", "pickup"], "boat": ["ship", "sailboat", "canoe", "kayak", "yacht", "ferry"],
    "traffic light": ["traffic signal", "stoplight"], "fire hydrant": ["hydrant"], "stop sign": [],
    "parking meter": [], "bench": [], "bird": ["seagull", "gull", "pigeon", "duck", "parrot", "goose", "swan"],
    "cat": ["kitten", "kitty"], "dog": ["puppy"], "horse": ["pony"], "sheep": ["lamb"], "cow": ["cattle", "bull", "calf"],
    "elephant": [], "bear": [], "zebra": [], "giraffe": [], "backpack": [], "umbrella": ["parasol"],
    "handbag": ["purse", "bag"], "tie": ["necktie"], "suitcase": ["luggage"], "frisbee": [], "skis": ["ski"],
    "snowboard": [], "sports ball": ["ball", "football", "soccer ball", "baseball", "tennis ball", "basketball"],
    "kite": [], "baseball bat": ["bat"], "baseball glove": ["glove", "mitt"], "skateboard": [],
    "surfboard": ["surf board"], "tennis racket": ["racket", "racquet"], "bottle": [], "wine glass": ["glass"],
    "cup": ["mug"], "fork": [], "knife": [], "spoon": [], "bowl": [], "banana": [], "apple": [],
    "sandwich": ["burger", "hamburger"], "orange": [], "broccoli": [], "carrot": [], "hot dog": ["hotdog"],
    "pizza": [], "donut": ["doughnut"], "cake": ["cupcake"], "chair": ["seat"], "couch": ["sofa"],
    "potted plant": ["plant", "houseplant", "flower pot"], "bed": [], "dining table": ["table"],
    "toilet": [], "tv": ["television", "monitor", "screen"], "laptop": ["computer", "notebook"], "mouse": [],
    "remote": ["remote control", "controller"], "keyboard": [], "cell phone": ["phone", "smartphone", "mobile phone"],
    "microwave": [], "oven": ["stove"], "toaster": [], "sink": [], "refrigerator": ["fridge"], "book": [],
    "clock": [], "vase": [], "scissors": [], "teddy bear": ["teddy", "stuffed animal", "stuffed bear"],
    "hair drier": ["hair dryer", "hairdryer"], "toothbrush": [],
}


def main():
    src = sys.argv[1]
    ann = json.load(open(os.path.join(src, "coco", "annotations", "instances_val2017.json"), encoding="utf-8"))
    cats = {c["id"]: c["name"] for c in ann["categories"]}
    assert sorted(cats.values()) == sorted(WORDS), set(cats.values()) ^ set(WORDS)
    imgs = {i["id"]: i for i in ann["images"]}
    by_img = collections.defaultdict(list)
    for a in ann["annotations"]:
        by_img[a["image_id"]].append(a)

    def main_of(iid):
        im = imgs[iid]
        objs = [a for a in by_img[iid] if not a["iscrowd"]]
        if not objs:
            return None
        big = max(objs, key=lambda a: a["area"])
        return cats[big["category_id"]] if big["area"] >= 0.10 * im["width"] * im["height"] else None

    local = sorted(int(f[:-4]) for f in os.listdir(os.path.join(src, "coco", "images")) if f.endswith(".jpg"))
    rows = []
    for iid in local:
        m = main_of(iid)
        if m:
            present = sorted({cats[a["category_id"]] for a in by_img[iid]})
            rows.append((iid, m, present))
    inside = {r[0] for r in rows}
    outside = collections.Counter(m for iid in imgs if iid not in inside for m in [main_of(iid)] if m)
    floor_cat = outside.most_common(1)[0][0]
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write("# coco_describe_v1.ring -- the :describe golden set, written by _rig/coco_describe.py from COCO val2017's\n")
        f.write("# annotations (CC BY 4.0): [ image file, main object, its words, every category annotated ]\n\n")
        f.write('func StzVisionGoldenDescribeFloorV1()\n\treturn "%s"\n\n' % floor_cat)
        f.write("func StzVisionGoldenWordsV1()\n\treturn [\n")
        names = sorted(WORDS)
        for n, c in enumerate(names):
            f.write('\t\t[ "%s", [ %s ] ]%s\n' % (c, ", ".join('"%s"' % w for w in [c] + WORDS[c]),
                                                    "," if n < len(names) - 1 else ""))
        f.write("\t]\n\nfunc StzVisionGoldenDescribeV1()\n\treturn [\n")
        for n, (iid, m, present) in enumerate(rows):
            f.write('\t\t[ "%012d.jpg", "%s", [ %s ] ]%s\n' % (iid, m, ", ".join('"%s"' % p for p in present),
                                                              "," if n < len(rows) - 1 else ""))
        f.write("\t]\n")
    print("describe_v1: %d pictures of %d local; floor '%s' (main object of %d of %d pictures outside); main objects: %s"
          % (len(rows), len(local), floor_cat, outside[floor_cat], sum(outside.values()),
             collections.Counter(r[1] for r in rows).most_common(6)))


if __name__ == "__main__":
    main()
