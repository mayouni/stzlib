# ocr_score.py <golden dir> <id> <ocr txt> [<ocr txt> ...] -- an OCR text against a golden's expectation, with the
# shared scorer's normalisation: text = share of key sentences found verbatim in the OCR text (whitespace collapsed,
# NFC), headings = share of expected headings found as a whole line or inside the text, cells = share of table cells
# found anywhere in the text, words = share of the expected words (sentences + headings + cells) present. No judge.
import json, sys, re, unicodedata, pathlib

def norm(s):
    s = unicodedata.normalize("NFC", s or "")
    return re.sub(r"\s+", " ", s).strip()

g, d = sys.argv[1], sys.argv[2]
e = json.load(open(pathlib.Path(g) / (d + ".expected.json"), encoding="utf-8"))
for f in sys.argv[3:]:
    raw = open(f, encoding="utf-8").read()
    lines = [norm(l) for l in raw.splitlines() if norm(l)]
    body = norm(" ".join(lines))
    ks = [norm(s) for s in e["key_sentences"]]
    text = sum(1 for s in ks if s in body) / max(1, len(ks))
    hs = [norm(h["text"]) for h in e["headings"]]
    heads = sum(1 for h in hs if h in lines or h in body) / max(1, len(hs))
    cells = [norm(c) for t in e["tables"] for r in t["rows"] for c in r if norm(c)]
    cell = sum(1 for c in cells if c in body) / max(1, len(cells)) if cells else None
    words = set()
    for s in ks + hs + cells:
        words |= set(w for w in re.findall(r"\w+", s) if len(w) > 1)
    have = set(re.findall(r"\w+", body))
    wr = sum(1 for w in words if w in have) / max(1, len(words))
    print("%-24s %s text %.2f (%d/%d)  headings %.2f (%d/%d)  cells %s  words %.2f (%d)" % (
        pathlib.Path(f).name, d, text, round(text * len(ks)), len(ks), heads, round(heads * len(hs)), len(hs),
        ("%.2f (%d/%d)" % (cell, round(cell * len(cells)), len(cells))) if cell is not None else "--", wr, len(words)))
