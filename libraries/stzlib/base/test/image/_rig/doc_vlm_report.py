#!/usr/bin/env python3
"""doc_vlm_report.py -- a page a person can look at: each golden page beside what each reader recovered from it (IM7, 2 of 2).

    <docling venv>/python -I -X utf8 doc_vlm_report.py <pages dir> <predictions dir> <out.html> [--set=v1|v2]

For every page of the set: the page as it was read (greyscale, 150 dpi), the blocks the native PDF reader found in its
scan (headings, paragraphs, tables as grids), the blocks Granite-Docling wrote and, for v2, the two combined
(<key>.combined.tsv), each with the page's metric mean (the number the faculty's bar of 0.9 is held against). All are
read from the stored predictions; nothing runs.
"""
import base64
import html
import io
import json
import os
import pathlib
import statistics
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "..", "document"))
from doc_vlm_render import DOCS, selection  # noqa: E402
import _doc_score as ds  # noqa: E402

KEYS = ds.KEYS
NAMES = {"floor": "native reader", "granite": "Granite-Docling", "combined": "the two combined"}


def thumb(path, w=300):
    im = Image.open(path).convert("L")
    im = im.resize((w, int(im.height * w / im.width)), Image.LANCZOS)
    b = io.BytesIO()
    im.save(b, "JPEG", quality=55)
    return "data:image/jpeg;base64," + base64.b64encode(b.getvalue()).decode()


def blocks_html(blocks):
    out = []
    for b in blocks:
        k = b["kind"]
        if k == "table":
            rows = "".join("<tr>" + "".join("<td>%s</td>" % html.escape(c) for c in r) + "</tr>" for r in b["rows"])
            out.append("<table>%s</table>" % rows)
        elif k == "heading":
            out.append("<div class=h%d>%s</div>" % (min(max(b["level"], 1), 3), html.escape(b["text"])))
        elif k in ("page_header", "page_footer"):
            out.append("<div class=fur>%s</div>" % html.escape(b["text"]))
        elif k == "caption":
            out.append("<div class=cap>%s</div>" % html.escape(b["text"]))
        elif k == "list_item":
            out.append("<div class=li>&bull; %s</div>" % html.escape(b["text"]))
        elif k == "code":
            out.append("<pre>%s</pre>" % html.escape(b["text"]))
        else:
            out.append("<p>%s</p>" % html.escape(b["text"]))
    return "".join(out) or "<i>nothing</i>"


def mean_of(m):
    v = [m[k] for k in KEYS if m[k] is not None]
    return 1.0 if not v else sum(v) / len(v)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--set=")]
    which = ([a[6:] for a in sys.argv[1:] if a.startswith("--set=")] or ["v1"])[0]
    pages, pdir, out = args[0], args[1], args[2]
    tools = ["floor", "granite"] + (["combined"] if which == "v2" else [])
    times = {}
    for t in ("floor", "granite"):
        f = os.path.join(pdir, t + ".times.tsv")
        times[t] = {}
        if os.path.exists(f):
            for line in open(f, encoding="utf-8").read().splitlines():
                if "\t" in line:
                    k, v = line.split("\t", 1)
                    times[t][k] = float(v)
    rows, tot = [], {t: [] for t in tools}
    per_metric = {t: {k: [] for k in KEYS} for t in tools}
    for d, i, diff in selection(which):
        key = "v%s_%s" % (d.replace("golden_v", ""), i)
        exp = json.load(open(os.path.join(DOCS, d, i + ".expected.json"), encoding="utf-8"))
        cell = {}
        for t in tools:
            p = os.path.join(pdir, "%s.%s.tsv" % (key, t))
            bl = ds.read_predictions(pathlib.Path(p)) if os.path.exists(p) else []
            m = ds.score(exp, bl)
            tot[t].append(mean_of(m))
            for k in KEYS:
                if m[k] is not None:
                    per_metric[t][k].append(m[k])
            cell[t] = (bl, m, mean_of(m))
        rows.append((key, diff, thumb(os.path.join(pages, key + ".png")), cell))
    n = len(rows)
    bar = 0.9
    agree = {t: sum(1 for v in tot[t] if v >= bar) for t in tools}
    css = """
    :root{--bg:#fff;--fg:#1c1c1e;--mut:#6b6b70;--line:#d8d8dc;--ok:#1a7f37;--bad:#b3261e;--card:#f6f6f8}
    @media (prefers-color-scheme: dark){:root{--bg:#161618;--fg:#ececf0;--mut:#9a9aa2;--line:#3a3a40;--ok:#4cc26a;--bad:#f2766c;--card:#202024}}
    body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.5 system-ui,Segoe UI,sans-serif}
    main{max-width:1400px;margin:0 auto;padding:16px}
    h1{font-size:1.5rem;margin:.4em 0}.sub{color:var(--mut);margin:0 0 1em}
    table.sum{border-collapse:collapse;margin:.5em 0 1.5em}
    table.sum td,table.sum th{border:1px solid var(--line);padding:.35em .8em;text-align:right}
    table.sum th:first-child,table.sum td:first-child{text-align:left}
    .page{display:grid;grid-template-columns:300px repeat(%d,minmax(0,1fr));gap:12px;border-top:2px solid var(--line);padding:14px 0}
    @media (max-width:900px){.page{grid-template-columns:1fr}}
    .page img{width:300px;max-width:100%%;border:1px solid var(--line)}
    .col{background:var(--card);padding:8px 12px;border-radius:6px;min-width:0;overflow-x:auto}
    .col h3{margin:.1em 0 .4em;font-size:1rem}.ok{color:var(--ok)}.bad{color:var(--bad)}
    .h1{font-weight:700;font-size:1.15em}.h2{font-weight:700}.h3{font-weight:600;color:var(--mut)}
    .fur{color:var(--mut);font-size:.85em;font-style:italic}.cap{font-style:italic;color:var(--mut)}
    p{margin:.3em 0}.col table{border-collapse:collapse;margin:.4em 0;font-size:.9em}
    .col td{border:1px solid var(--line);padding:2px 6px}
    pre{margin:.3em 0;white-space:pre-wrap;font-size:.85em}
    small{color:var(--mut)}
    """ % len(tools)
    what = ("the first one-page English document of each of golden_v2 &hellip; v33 (the set the combination's rule was designed on)" if which == "v1"
            else "the second and third one-page English documents of each of golden_v2 &hellip; v33 (FRESH: no model had read them when the combination's rule was written)")
    h = ["<!doctype html><html lang=en><head><meta charset=utf-8><meta name=viewport content='width=device-width,initial-scale=1'>"
         "<title>Page as structure, %s</title><style>%s</style></head><body><main>" % (which, css),
         "<h1>A page as structure (%s): %s</h1>" % (which, " &middot; ".join(NAMES[t] for t in tools)),
         "<p class=sub>The same %d golden pages, %s, each read as a scan. Left: the page. Then, for each reader, the blocks it "
         "found, in the same kinds of blocks. The number on each is the page's mean over the metrics that apply to it (the bar is %.1f).</p>" % (n, what, bar)]
    h.append("<table class=sum><tr><th></th>%s</tr>" % "".join("<th>%s</th>" % NAMES[t] for t in tools))
    h.append("<tr><td>pages reaching the bar (%.1f)</td>%s</tr>" % (bar, "".join("<td>%d of %d</td>" % (agree[t], n) for t in tools)))
    h.append("<tr><td>mean of the pages' means</td>%s</tr>" % "".join("<td>%.3f</td>" % (sum(tot[t]) / n) for t in tools))
    for k in KEYS:
        cellsk = []
        for t in tools:
            a = per_metric[t][k]
            cellsk.append("<td>%s</td>" % ("%.3f" % (sum(a) / len(a)) if a else "&ndash;"))
        h.append("<tr><td>%s (%d pages)</td>%s</tr>" % (k, len(per_metric["floor"][k]), "".join(cellsk)))
    med = lambda d: statistics.median(d.values()) if d else float("nan")
    h.append("<tr><td>seconds a page (median)</td>%s</tr></table>" % "".join(
        "<td>%.1f</td>" % (med(times["floor"]) + med(times["granite"]) if t == "combined" else med(times[t])) for t in tools))
    for key, diff, img, cell in rows:
        h.append("<section class=page><div><img src='%s' alt='%s'><br><small>%s &mdash; %s</small></div>" % (img, key, key, html.escape(diff[:110])))
        for t in tools:
            bl, m, mean = cell[t]
            cls = "ok" if mean >= bar else "bad"
            h.append("<div class=col><h3>%s <span class=%s>%.2f</span></h3>%s</div>" % (NAMES[t], cls, mean, blocks_html(bl)))
        h.append("</section>")
    h.append("</main></body></html>")
    open(out, "w", encoding="utf-8", newline="\n").write("\n".join(h))
    print("wrote", out, "%.1f KB" % (os.path.getsize(out) / 1024))
    print("bar %.1f: %s; mean %s" % (bar, " ".join("%s %d/%d" % (t, agree[t], n) for t in tools),
                                     " ".join("%s %.3f" % (t, sum(tot[t]) / n) for t in tools)))


if __name__ == "__main__":
    main()
