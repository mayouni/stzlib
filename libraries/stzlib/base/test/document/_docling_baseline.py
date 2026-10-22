# _docling_baseline.py -- run Docling on the independent golden PDF set and write its predictions.
#
#     <docling-venv>\Scripts\python.exe -I _docling_baseline.py <golden dir> <predictions dir> [--ocr] [--artifacts <models dir>]
#     python -I _doc_score.py <golden dir> <predictions dir> docling <results dir>
#
# --artifacts points Docling at models fetched beforehand (folders docling-project--docling-layout-heron and
# docling-project--docling-models), so a slow or failing network cannot stall the run inside the conversion.
#
# A MEASURING TOOL, not a dependency of the library: Docling runs in its own virtual environment outside the tree.
# This script only CONVERTS: it writes one <id>.docling.tsv per document in the shared prediction format, and
# docling.times.tsv. Scoring is _doc_score.py's, the same function that scores Softanza's native reader.
# OCR is OFF by default: these PDFs carry a text layer, and the native reader reads the text layer too.
#
# Docling's labels map to the shared kinds: title and section_header -> heading; list_item; code; caption;
# table; page_header, page_footer and anything on the furniture layer -> page_header / page_footer; every
# other text label -> paragraph.

import sys, time, pathlib


def esc(s):
    return (s or "").replace("\\", "\\\\").replace("\t", "\\t").replace("\n", "\\n")


def main():
    gdir = pathlib.Path(sys.argv[1])
    pdir = pathlib.Path(sys.argv[2])
    use_ocr = "--ocr" in sys.argv
    pdir.mkdir(parents=True, exist_ok=True)

    from docling.datamodel.pipeline_options import PdfPipelineOptions
    from docling.document_converter import DocumentConverter, PdfFormatOption
    from docling.datamodel.base_models import InputFormat
    from docling_core.types.doc import DocItemLabel, TableItem
    from docling_core.types.doc.document import ContentLayer

    opts = PdfPipelineOptions()
    opts.do_ocr = use_ocr
    opts.do_table_structure = True
    if "--artifacts" in sys.argv:
        opts.artifacts_path = sys.argv[sys.argv.index("--artifacts") + 1]
    conv = DocumentConverter(format_options={InputFormat.PDF: PdfFormatOption(pipeline_options=opts)})

    # --resume: documents already written are kept (a long set is run in pieces that each fit one run)
    resume = "--resume" in sys.argv
    tf = pdir / "docling.times.tsv"
    times = []
    if resume and tf.exists():
        times = [l for l in tf.read_text(encoding="utf-8").splitlines() if "\t" in l]
    done = {l.split("\t")[0] for l in times}
    for pdf in sorted(gdir.glob("*.pdf")):
        did = pdf.stem
        if resume and did in done and (pdir / (did + ".docling.tsv")).exists():
            continue
        t0 = time.perf_counter()
        doc = conv.convert(str(pdf)).document
        secs = time.perf_counter() - t0
        lines = []
        for item, _lvl in doc.iterate_items(included_content_layers={ContentLayer.BODY, ContentLayer.FURNITURE}):
            label = getattr(item, "label", None)
            layer = getattr(item, "content_layer", ContentLayer.BODY)
            if isinstance(item, TableItem):
                rows = "\x1e".join("\x1f".join(esc(c.text) for c in r) for r in item.data.grid)
                lines.append("table\t0\t" + rows)
                continue
            text = getattr(item, "text", "") or ""
            if label == DocItemLabel.PAGE_HEADER or (layer == ContentLayer.FURNITURE and label != DocItemLabel.PAGE_FOOTER):
                kind = "page_header"
            elif label == DocItemLabel.PAGE_FOOTER:
                kind = "page_footer"
            elif label in (DocItemLabel.TITLE, DocItemLabel.SECTION_HEADER):
                kind = "heading"
            elif label == DocItemLabel.LIST_ITEM:
                kind = "list_item"
            elif label == DocItemLabel.CODE:
                kind = "code"
            elif label == DocItemLabel.CAPTION:
                kind = "caption"
            else:
                kind = "paragraph"
            level = getattr(item, "level", 0) or 0
            lines.append(kind + "\t" + str(level) + "\t" + esc(text))
        (pdir / (did + ".docling.tsv")).write_text("\n".join(lines) + "\n", encoding="utf-8")
        times.append(did + "\t" + ("%.3f" % secs))
        print(did, "%.2f s" % secs, len(lines), "blocks", flush=True)
        tf.write_text("\n".join(times) + "\n", encoding="utf-8")
    tf.write_text("\n".join(times) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
