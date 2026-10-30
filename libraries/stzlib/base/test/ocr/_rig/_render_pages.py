# _render_pages.py <out dir> <golden dir>/<id> ... -- the oracle renderer: every page of each golden PDF to <id>_p<n>_200dpi.png
# (pypdfium2, 200 dpi). Run it with the Docling scratch environment's python; the engine has no rasteriser (memo 1).
import sys, pathlib, pypdfium2 as pdfium
out = pathlib.Path(sys.argv[1]); out.mkdir(parents=True, exist_ok=True)
for spec in sys.argv[2:]:
    p = pathlib.Path(spec + ".pdf"); pdf = pdfium.PdfDocument(str(p))
    for i in range(len(pdf)):
        pdf[i].render(scale=200 / 72).to_pil().save(out / ("%s_p%d_200dpi.png" % (p.stem, i + 1)))
    print(p.stem, len(pdf), "pages")
