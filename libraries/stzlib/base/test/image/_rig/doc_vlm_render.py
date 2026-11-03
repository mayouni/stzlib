#!/usr/bin/env python3
"""doc_vlm_render.py -- the pages of :doc-vlm's golden set (IM7, 2 of 2), rendered, with their scanned twins.

THE TRUTH IS NOT OURS: each page is page 1 of a golden document of base/test/document/_data (golden_v2 ... v33),
whose expected structure (headings, tables, sentences, lists, furniture, code) was written from the text put INTO
the document's HTML by an author who never ran a reader; nothing here reads a PDF's text layer.

THE SELECTION RULE (fixed before any model read a page): from each of golden_v2 ... golden_v33 the FIRST document, by
id, with one page and English as its only language. golden_v1 is left out because the native PDF reader was
developed on it; golden_v34 ... v36 are French and Arabic, and Granite-Docling is an English model. 31 documents.

For each document the page is rendered at 150 dpi, greyscale (what the OCR plane is measured on), as
  <key>.png    the page a model reads            (key = <set>_<id>, e.g. v2_e01)
  <key>.pdf    the same page as an image-only PDF, a scan: no text layer, so the native reader reads it by OCR
and the folder gets golden.tsv: key, golden set, document id, difficulty.

    <docling venv>/python -I -X utf8 doc_vlm_render.py <out dir> [v1|v2]      (needs pypdfium2 and Pillow)
"""
import glob
import io
import json
import os
import sys
import zlib

import pypdfium2 as pdfium

DOCS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "document", "_data")


# the golden sets of :doc-vlm, by which of each set's one-page English documents (by id) they take: v1 the first;
# v2 the second and, when there is one, the third. v2 is FRESH: no model has read a page of it and the combination's rule
# (stzDocTags.ring, StzDocBlocksCombine) was written down before any did. golden_v1 is the native reader's development set.
SETS = {"v1": (0,), "v2": (1, 2)}


def selection(which="v1"):
    out = []
    for n in range(2, 34):
        d = "golden_v%d" % n
        ok = []
        for f in sorted(glob.glob(os.path.join(DOCS, d, "*.expected.json"))):
            e = json.load(open(f, encoding="utf-8"))
            if e.get("pages") == 1 and e.get("languages") == ["en"]:
                ok.append((d, e["id"], e.get("difficulty", "")))
        out += [ok[i] for i in SETS[which] if i < len(ok)]
    return out


def scan_pdf(path, im):
    # an image-only PDF at 150 dpi: one DeviceGray 8-bit image, FlateDecode (what a scanner driver writes)
    W, H = im.size
    pw, ph = W * 72 / 150, H * 72 / 150
    data = zlib.compress(im.convert("L").tobytes(), 9)
    objs = [b"<< /Type /Catalog /Pages 2 0 R >>", b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
            ("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 %.2f %.2f] /Resources << /XObject << /Im1 4 0 R >> >> "
             "/Contents 5 0 R >>" % (pw, ph)).encode(),
            ("<< /Type /XObject /Subtype /Image /Width %d /Height %d /ColorSpace /DeviceGray /BitsPerComponent 8 "
             "/Filter /FlateDecode /Length %d >>\nstream\n" % (W, H, len(data))).encode() + data + b"\nendstream"]
    content = ("q %.2f 0 0 %.2f 0 0 cm /Im1 Do Q" % (pw, ph)).encode()
    objs.append(b"<< /Length %d >>\nstream\n" % len(content) + content + b"\nendstream")
    out = io.BytesIO()
    out.write(b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n")
    offs = []
    for i, o in enumerate(objs, 1):
        offs.append(out.tell())
        out.write(b"%d 0 obj\n" % i + o + b"\nendobj\n")
    xref = out.tell()
    out.write(b"xref\n0 %d\n0000000000 65535 f \n" % (len(objs) + 1))
    for o in offs:
        out.write(b"%010d 00000 n \n" % o)
    out.write(b"trailer\n<< /Size %d /Root 1 0 R >>\nstartxref\n%d\n%%%%EOF\n" % (len(objs) + 1, xref))
    open(path, "wb").write(out.getvalue())


def main():
    out = sys.argv[1]
    which = sys.argv[2] if len(sys.argv) > 2 else "v1"
    os.makedirs(out, exist_ok=True)
    rows = []
    for d, i, diff in selection(which):
        key = "v%s_%s" % (d.replace("golden_v", ""), i)
        pdf = pdfium.PdfDocument(os.path.join(DOCS, d, i + ".pdf"))
        im = pdf[0].render(scale=150 / 72).to_pil().convert("L")
        im.save(os.path.join(out, key + ".png"))
        scan_pdf(os.path.join(out, key + ".pdf"), im)
        rows.append("%s\t%s\t%s\t%s" % (key, d, i, diff.replace("\t", " ").replace("\n", " ")))
        print(key, im.size, diff[:70])
    open(os.path.join(out, "golden.tsv"), "w", encoding="utf-8", newline="\n").write("\n".join(rows) + "\n")
    print(len(rows), "pages")


if __name__ == "__main__":
    main()
