# _docling_baseline.py -- score Docling on the independent golden PDF set.
#
#     <docling-venv>\Scripts\python.exe -I _docling_baseline.py <golden dir> <results dir> [--ocr] [--artifacts <models dir>]
#
# --artifacts points Docling at models fetched beforehand (folders docling-project--docling-layout-heron and
# docling-project--docling-models), so a slow or failing network cannot stall the run inside the conversion.
#
# A MEASURING TOOL, not a dependency of the library: Docling runs in its own virtual environment outside the tree.
# The golden set (golden_v1) was written by an author who never ran an extractor; the metrics below were fixed
# BEFORE Docling's output on it was seen, so they cannot have been tuned to what Docling happens to produce.
#
# Metrics, per document, each in [0, 1] or None when the document has nothing of that kind:
#   text      share of the key body sentences found verbatim in the BODY text (whitespace collapsed, NFC)
#   order     of the sentences found, share of consecutive expected pairs that appear in that order
#   headings  share of expected heading texts found among title / section-header items
#   tables    share of expected table cells found at the same (row, column) in the best-matching table
#   lists     share of expected list items found among list items
#   furniture share of expected header/footer strings kept OUT of the body text
#   code      share of expected code blocks found in a code item (whitespace collapsed)
# plus the wall seconds of the conversion. OCR is OFF by default: these PDFs carry a text layer, and the native
# Softanza floor this baseline will be compared with reads the text layer too.

import json, sys, time, unicodedata, re, pathlib

def norm(s):
    s = unicodedata.normalize("NFC", s or "")
    return re.sub(r"\s+", " ", s).strip()

def share(hits, total):
    return None if total == 0 else hits / total

def main():
    gdir = pathlib.Path(sys.argv[1])
    rdir = pathlib.Path(sys.argv[2])
    use_ocr = "--ocr" in sys.argv
    rdir.mkdir(parents=True, exist_ok=True)

    from docling.datamodel.pipeline_options import PdfPipelineOptions
    from docling.document_converter import DocumentConverter, PdfFormatOption
    from docling.datamodel.base_models import InputFormat
    from docling_core.types.doc import DocItemLabel, TableItem
    from docling_core.types.doc.document import ContentLayer
    import importlib.metadata as md

    opts = PdfPipelineOptions()
    opts.do_ocr = use_ocr
    opts.do_table_structure = True
    if "--artifacts" in sys.argv:
        opts.artifacts_path = sys.argv[sys.argv.index("--artifacts") + 1]
    conv = DocumentConverter(format_options={InputFormat.PDF: PdfFormatOption(pipeline_options=opts)})

    rows = []
    for exp_path in sorted(gdir.glob("*.expected.json")):
        exp = json.loads(exp_path.read_text(encoding="utf-8"))
        pdf = gdir / (exp["id"] + ".pdf")
        t0 = time.perf_counter()
        doc = conv.convert(str(pdf)).document
        secs = time.perf_counter() - t0

        body, heads, lists, codes, furn, tables = [], [], [], [], [], []
        for item, _lvl in doc.iterate_items(included_content_layers={ContentLayer.BODY, ContentLayer.FURNITURE}):
            label = getattr(item, "label", None)
            layer = getattr(item, "content_layer", ContentLayer.BODY)
            if isinstance(item, TableItem):
                grid = [[norm(c.text) for c in r] for r in item.data.grid]
                tables.append(grid)
                if layer == ContentLayer.BODY:
                    body.extend(" ".join(r) for r in grid)
                continue
            text = norm(getattr(item, "text", ""))
            if not text:
                continue
            if layer == ContentLayer.FURNITURE or label in (DocItemLabel.PAGE_HEADER, DocItemLabel.PAGE_FOOTER):
                furn.append(text)
                continue
            body.append(text)
            if label in (DocItemLabel.TITLE, DocItemLabel.SECTION_HEADER):
                heads.append(text)
            if label == DocItemLabel.LIST_ITEM:
                lists.append(text)
            if label == DocItemLabel.CODE:
                codes.append(text)
        btext = " ".join(body)

        # text recall and reading order
        sents = [norm(s) for s in exp.get("key_sentences", [])]
        pos = [btext.find(s) for s in sents]
        found = [p for p in pos if p >= 0]
        pairs = [(pos[i], pos[i + 1]) for i in range(len(pos) - 1) if pos[i] >= 0 and pos[i + 1] >= 0]
        m_text = share(len(found), len(sents))
        m_order = share(sum(1 for a, b in pairs if a < b), len(pairs))

        # headings: by text (a heading may also come out as the title)
        eh = [norm(h["text"]) for h in exp.get("headings", [])]
        m_head = share(sum(1 for h in eh if h in heads), len(eh))

        # tables: each expected table against the predicted table that matches most of its cells in place
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
        m_table = share(hits, total)

        # list items: the predicted item may carry its bullet or number; accept the expected text as its tail
        el = [norm(x["text"]) for x in exp.get("list_items", [])]
        m_list = share(sum(1 for x in el if any(p == x or p.endswith(" " + x) or p.endswith(x) for p in lists)), len(el))

        ef = [norm(x) for x in exp.get("furniture", [])]
        m_furn = share(sum(1 for x in ef if x not in btext), len(ef))

        ec = [norm(x) for x in exp.get("code", [])]
        m_code = share(sum(1 for x in ec if any(x in c for c in codes)), len(ec))

        rows.append({"id": exp["id"], "difficulty": exp.get("difficulty", ""), "seconds": round(secs, 2),
                     "text": m_text, "order": m_order, "headings": m_head, "tables": m_table,
                     "lists": m_list, "furniture": m_furn, "code": m_code})
        print(exp["id"], json.dumps(rows[-1]), flush=True)

    keys = ["text", "order", "headings", "tables", "lists", "furniture", "code"]
    macro = {}
    for k in keys:
        vals = [r[k] for r in rows if r[k] is not None]
        macro[k] = None if not vals else round(sum(vals) / len(vals), 3)
    out = {"tool": "docling " + md.version("docling"), "ocr": use_ocr, "golden": gdir.name, "documents": rows, "macro": macro,
           "seconds_total": round(sum(r["seconds"] for r in rows), 1)}
    tag = "docling_baseline_" + gdir.name + ("_ocr" if use_ocr else "")
    (rdir / (tag + ".json")).write_text(json.dumps(out, indent=1, ensure_ascii=False), encoding="utf-8")

    fmt = lambda v: "--" if v is None else "%.2f" % v
    md_lines = ["# Docling baseline on " + gdir.name, "",
                "Tool: " + out["tool"] + ", OCR " + ("on" if use_ocr else "off") + ", CPU. Total " + str(out["seconds_total"]) + " s.", "",
                "| doc | difficulty | " + " | ".join(keys) + " | s |", "|---|---|" + "---|" * (len(keys) + 1)]
    for r in rows:
        md_lines.append("| " + r["id"] + " | " + r["difficulty"] + " | " + " | ".join(fmt(r[k]) for k in keys) + " | " + str(r["seconds"]) + " |")
    md_lines.append("| **macro** | | " + " | ".join(fmt(macro[k]) for k in keys) + " | |")
    (rdir / (tag + ".md")).write_text("\n".join(md_lines) + "\n", encoding="utf-8")
    print("MACRO", json.dumps(macro))

if __name__ == "__main__":
    main()
