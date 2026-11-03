#!/usr/bin/env python3
"""doc_vlm_golden.py -- writes _golden/doc_vlm_v1.ring, the golden set of :doc-vlm (IM7, 2 of 2).

    python -I -X utf8 doc_vlm_golden.py        (run from base/test/image/_rig)

The truth is each document's expected.json (base/test/document/_data/golden_vN/), written from the text put INTO
the document's HTML by an author who never ran a reader. The selection is doc_vlm_render.py's, a rule fixed before
any model read a page. The file is generated; do not edit it by hand.
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from doc_vlm_render import DOCS, selection  # noqa: E402


def lit(s):
    # a Ring string literal: Ring has no escapes, so the delimiter is one the text does not contain
    for q in ('"', "'", "`"):
        if q not in s:
            return q + s + q
    raise SystemExit("a text holds all three quotes: " + s[:60])


def lst(items):
    return "[ " + ", ".join(lit(x) for x in items) + " ]"


def main():
    which = sys.argv[1] if len(sys.argv) > 1 else "v1"
    out = ["# doc_vlm_%s.ring -- the :doc-vlm golden set, version %s: one item per page, the page given as a PNG in the" % (which, which),
           "# folder doc_vlm_render.py fills (<key>.png) and what a correct reader recovers from it. The expectations are",
           "# generated from the documents' expected.json (base/test/document/_data), whose authors never saw a reader;",
           "# the pages are " + ("the first one-page English document of each of golden_v2 ... golden_v33 (31 pages)" if which == "v1" else "the second and, when there is one, the third one-page English document of each of golden_v2 ... golden_v33 (FRESH: no model had read one when the combination rule was written)") + ". Do not edit by hand.",
           "",
           "func StzVisionGoldenDoc%s(pcDir)" % which.upper(),
           "\t_a_ = []"]
    for d, i, diff in selection(which):
        e = json.load(open(os.path.join(DOCS, d, i + ".expected.json"), encoding="utf-8"))
        key = "v%s_%s" % (d.replace("golden_v", ""), i)
        tables = "[ " + ", ".join("[ " + ", ".join(lst(r) for r in t["rows"]) + " ]" for t in e.get("tables", [])) + " ]"
        exp = "[ :sentences = %s, :headings = %s, :tables = %s, :lists = %s, :furniture = %s, :code = %s ]" % (
            lst(e.get("key_sentences", [])), lst([h["text"] for h in e.get("headings", [])]), tables,
            lst([x["text"] for x in e.get("list_items", [])]), lst(e.get("furniture", [])), lst(e.get("code", [])))
        out.append("\t_a_ + [ pcDir + \"%s.png\", %s ]" % (key, exp))
    out += ["\treturn _a_", ""]
    p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "_golden", "doc_vlm_%s.ring" % which)
    open(p, "w", encoding="utf-8", newline="\n").write("\n".join(out))
    print("wrote", os.path.normpath(p), len(selection(which)), "pages")


if __name__ == "__main__":
    main()
