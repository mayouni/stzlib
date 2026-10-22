# _doc_score.py -- score any document reader's predictions on the independent golden PDF set.
#
#     python -I _doc_score.py <golden dir> <predictions dir> <tool> <results dir>
#
# A reader's predictions are one file per document, <id>.<tool>.tsv, one line per block in reading order:
#     kind <TAB> level <TAB> text
# kind is heading, paragraph, list_item, code, caption, table, page_header or page_footer. Text escapes a
# backslash, a tab and a newline as \\, \t and \n. A table's text is its rows joined by U+001E, each row's
# cells joined by U+001F. <tool>.times.tsv, when present, holds "id <TAB> seconds".
#
# Every reader -- Docling (_docling_baseline.py) and Softanza's native reader (_native_predict.ring) -- is
# scored by THIS function, so two numbers in the results differ only because the readers differ.
#
# Metrics, per document, each in [0, 1] or None when the document has nothing of that kind (fixed before any
# reader's output on the set was seen):
#   text      share of the key body sentences found verbatim in the body text (whitespace collapsed, NFC)
#   order     of the sentences found, share of consecutive expected pairs that appear in that order
#   headings  share of expected heading texts found among the heading blocks
#   tables    share of expected table cells found at the same (row, column) in the best-matching table
#   lists     share of expected list items found among the list items (a marker before the text is allowed)
#   furniture share of expected header/footer strings kept OUT of the body text
#   code      share of expected code blocks found inside a code block (whitespace collapsed)

import json, sys, re, unicodedata, pathlib

KEYS = ["text", "order", "headings", "tables", "lists", "furniture", "code"]


def norm(s):
    s = unicodedata.normalize("NFC", s or "")
    return re.sub(r"\s+", " ", s).strip()


def share(hits, total):
    return None if total == 0 else hits / total


def unescape(s):
    out, i = [], 0
    while i < len(s):
        c = s[i]
        if c == "\\" and i + 1 < len(s):
            n = s[i + 1]
            out.append({"t": "\t", "n": "\n", "\\": "\\"}.get(n, n))
            i += 2
            continue
        out.append(c)
        i += 1
    return "".join(out)


def read_predictions(path):
    blocks = []
    for line in path.read_text(encoding="utf-8").split("\n"):
        if not line:
            continue
        parts = line.split("\t")
        if len(parts) < 3:
            continue
        kind, level, text = parts[0], parts[1], "\t".join(parts[2:])
        if kind == "table":
            rows = [[unescape(c) for c in r.split("\x1f")] for r in text.split("\x1e")]
            blocks.append({"kind": kind, "level": int(level or 0), "text": "", "rows": rows})
        else:
            blocks.append({"kind": kind, "level": int(level or 0), "text": unescape(text), "rows": []})
    return blocks


def score(exp, blocks):
    body, heads, lists, codes, tables = [], [], [], [], []
    for b in blocks:
        if b["kind"] in ("page_header", "page_footer"):
            continue
        if b["kind"] == "table":
            grid = [[norm(c) for c in r] for r in b["rows"]]
            tables.append(grid)
            body.extend(" ".join(r) for r in grid)
            continue
        t = norm(b["text"])
        if not t:
            continue
        body.append(t)
        if b["kind"] == "heading":
            heads.append(t)
        elif b["kind"] == "list_item":
            lists.append(t)
        elif b["kind"] == "code":
            codes.append(t)
    btext = " ".join(body)

    sents = [norm(s) for s in exp.get("key_sentences", [])]
    pos = [btext.find(s) for s in sents]
    found = [p for p in pos if p >= 0]
    pairs = [(pos[i], pos[i + 1]) for i in range(len(pos) - 1) if pos[i] >= 0 and pos[i + 1] >= 0]
    m = {}
    m["text"] = share(len(found), len(sents))
    m["order"] = share(sum(1 for a, b in pairs if a < b), len(pairs))

    eh = [norm(h["text"]) for h in exp.get("headings", [])]
    m["headings"] = share(sum(1 for h in eh if h in heads), len(eh))

    hits = total = 0
    for et in exp.get("tables", []):
        erows = [[norm(c) for c in r] for r in et["rows"]]
        n = sum(len(r) for r in erows)
        best = 0
        for g in tables:
            k = 0
            for i, r in enumerate(erows):
                for j, c in enumerate(r):
                    if i < len(g) and j < len(g[i]) and g[i][j] == c:
                        k += 1
            best = max(best, k)
        hits += best
        total += n
    m["tables"] = share(hits, total)

    el = [norm(x["text"]) for x in exp.get("list_items", [])]
    m["lists"] = share(sum(1 for x in el if any(p == x or p.endswith(" " + x) or p.endswith(x) for p in lists)), len(el))

    ef = [norm(x) for x in exp.get("furniture", [])]
    m["furniture"] = share(sum(1 for x in ef if x not in btext), len(ef))

    ec = [norm(x) for x in exp.get("code", [])]
    m["code"] = share(sum(1 for x in ec if any(x in c for c in codes)), len(ec))
    return m


def main():
    gdir, pdir, tool, rdir = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), sys.argv[3], pathlib.Path(sys.argv[4])
    rdir.mkdir(parents=True, exist_ok=True)
    times = {}
    tf = pdir / (tool + ".times.tsv")
    if tf.exists():
        for line in tf.read_text(encoding="utf-8").splitlines():
            if "\t" in line:
                k, v = line.split("\t", 1)
                times[k] = float(v)
    rows = []
    for exp_path in sorted(gdir.glob("*.expected.json")):
        exp = json.loads(exp_path.read_text(encoding="utf-8"))
        pp = pdir / (exp["id"] + "." + tool + ".tsv")
        blocks = read_predictions(pp) if pp.exists() else []
        m = score(exp, blocks)
        m.update({"id": exp["id"], "difficulty": exp.get("difficulty", ""), "seconds": times.get(exp["id"])})
        rows.append(m)
        print(exp["id"], json.dumps(m, ensure_ascii=False), flush=True)
    macro = {}
    for k in KEYS:
        vals = [r[k] for r in rows if r[k] is not None]
        macro[k] = None if not vals else round(sum(vals) / len(vals), 3)
    secs = [r["seconds"] for r in rows if r["seconds"] is not None]
    out = {"tool": tool, "golden": gdir.name, "documents": rows, "macro": macro, "seconds_total": round(sum(secs), 3) if secs else None}
    tag = tool + "_" + gdir.name
    (rdir / (tag + ".json")).write_text(json.dumps(out, indent=1, ensure_ascii=False), encoding="utf-8")
    fmt = lambda v: "--" if v is None else "%.2f" % v
    lines = ["# " + tool + " on " + gdir.name, "",
             "Scored by `_doc_score.py`, the same function for every reader. Total " + str(out["seconds_total"]) + " s.", "",
             "| doc | difficulty | " + " | ".join(KEYS) + " | s |", "|---|---|" + "---|" * (len(KEYS) + 1)]
    for r in rows:
        s = "--" if r["seconds"] is None else ("%.3f" % r["seconds"])
        lines.append("| " + r["id"] + " | " + r["difficulty"] + " | " + " | ".join(fmt(r[k]) for k in KEYS) + " | " + s + " |")
    lines.append("| **macro** | | " + " | ".join(fmt(macro[k]) for k in KEYS) + " | |")
    (rdir / (tag + ".md")).write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("MACRO", json.dumps(macro))


if __name__ == "__main__":
    main()
