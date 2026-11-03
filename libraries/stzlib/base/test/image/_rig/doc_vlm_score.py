#!/usr/bin/env python3
"""doc_vlm_score.py -- both readers' predictions on :doc-vlm's golden pages, scored by the house's one scorer.

    <docling venv>/python -I -X utf8 doc_vlm_score.py <predictions dir> <results dir> [tool ...]

The scorer is base/test/document/_doc_score.py, the function every document reader of the house is judged by
(Docling and the native PDF reader included); this script only gathers the 31 pages' expected structure into one
folder (each document's expected.json, its id replaced by the page's key: ids repeat across the golden sets) and
runs it once per tool. Tools default to floor and granite. Writes <results dir>/<tool>_doc_vlm_v1.{json,md}.
"""
import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from doc_vlm_render import DOCS, selection  # noqa: E402

SCORER = os.path.join(HERE, "..", "..", "document", "_doc_score.py")


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--set=")]
    which = ([a[6:] for a in sys.argv[1:] if a.startswith("--set=")] or ["v1"])[0]
    pdir, rdir = os.path.abspath(args[0]), os.path.abspath(args[1])
    tools = args[2:] or ["floor", "granite"]
    with tempfile.TemporaryDirectory() as g:
        gdir = os.path.join(g, "doc_vlm_" + which)
        os.makedirs(gdir)
        for d, i, diff in selection(which):
            e = json.load(open(os.path.join(DOCS, d, i + ".expected.json"), encoding="utf-8"))
            e["id"] = "v%s_%s" % (d.replace("golden_v", ""), i)
            json.dump(e, open(os.path.join(gdir, e["id"] + ".expected.json"), "w", encoding="utf-8"), ensure_ascii=False)
        for t in tools:
            subprocess.run([sys.executable, "-I", "-X", "utf8", SCORER, gdir, pdir, t, rdir], check=True)
    # one line per page and tool, for a guard in Ring to hold its own scorer against: tool, key, the seven metrics
    keys = ["text", "order", "headings", "tables", "lists", "furniture", "code"]
    lines = []
    for t in tools:
        for r in json.load(open(os.path.join(rdir, t + "_doc_vlm_" + which + ".json"), encoding="utf-8"))["documents"]:
            lines.append(chr(9).join([t, r["id"]] + ["-" if r[k] is None else repr(r[k]) for k in keys]))
    open(os.path.join(rdir, "doc_vlm_" + which + "_scores.tsv"), "w", encoding="utf-8", newline=chr(10)).write(chr(10).join(lines) + chr(10))


if __name__ == "__main__":
    main()
