# _letterhead_label.py -- label the top-band blocks of a golden set: letterhead or content.
#
#     python -I _letterhead_label.py <golden dir> <blocks tsv> <out golden tsv>
#
# The labels come from the golden set's OWN furniture lists, written by its independent author: a block is
# letterhead when it lies inside one furniture line, or when furniture lines cover at least 60 per cent of
# its text; content otherwise. Neither the reader's rule nor any model has seen these labels.

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


gdir, blocks, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), pathlib.Path(sys.argv[3])
furn = {}
for p in gdir.glob("*.expected.json"):
    e = json.loads(p.read_text(encoding="utf-8"))
    furn[e["id"]] = [norm(f) for f in e.get("furniture", []) if norm(f)]
lines, n_lh = [], 0
for line in blocks.read_text(encoding="utf-8").splitlines():
    parts = line.split("\t")
    if len(parts) < 6:
        continue
    did, text = parts[0], norm(unesc(parts[1]))
    if not text:
        continue
    fs = furn.get(did, [])
    inside = any(text in f for f in fs)
    covered = sum(len(f) for f in fs if f in text)
    label = "letterhead" if inside or covered >= 0.6 * len(text) else "content"
    n_lh += label == "letterhead"
    lines.append("\t".join(parts[:6] + [label]))
out.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(len(lines), "blocks,", n_lh, "letterhead,", len(lines) - n_lh, "content")
