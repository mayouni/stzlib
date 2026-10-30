# head_precision.py <golden dir> <predictions dir> <tool> -- the share of a reader's heading blocks that are
# expected headings (the shared scorer counts recall only). Same normalisation as _doc_score.py.
import json, sys, re, unicodedata, pathlib


def norm(s):
    return re.sub(r"\s+", " ", unicodedata.normalize("NFC", s or "")).strip()


def unesc(s):
    out, i = [], 0
    while i < len(s):
        if s[i] == "\\" and i + 1 < len(s):
            out.append({"t": "\t", "n": "\n", "\\": "\\"}.get(s[i + 1], s[i + 1]))
            i += 2
            continue
        out.append(s[i])
        i += 1
    return "".join(out)


g, p, tool = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), sys.argv[3]
hit = tot = 0
per = []
for e in sorted(g.glob("*.expected.json")):
    ex = json.loads(e.read_text(encoding="utf-8"))
    eh = {norm(h["text"]) for h in ex.get("headings", [])}
    f = p / (ex["id"] + "." + tool + ".tsv")
    if not f.exists():
        continue
    heads = [norm(unesc(l.split("\t")[2])) for l in f.read_text(encoding="utf-8").split("\n") if l.startswith("heading\t") and len(l.split("\t")) > 2]
    h = sum(1 for x in heads if x in eh)
    hit += h
    tot += len(heads)
    if heads:
        per.append(h / len(heads))
print(tool, "heading blocks", tot, "expected", hit, "pooled precision", round(hit / tot, 3) if tot else None,
      "macro", round(sum(per) / len(per), 3) if per else None)
