# _make_scan_pdfs.py -- the two synthetic "scanned" PDFs of _data/, from the page-1 render of golden_v36/z09:
#   scan_flate_gray.pdf  one DeviceGray 8-bit image, FlateDecode   (what a greyscale scanner driver writes)
#   scan_dct_rgb.pdf     one DeviceRGB  8-bit image, DCTDecode     (what a phone's scan app writes)
# Both have no text layer: the reader must find 0 glyphs and one image, and the :ocr floor must read the page.
#
#   python -I -X utf8 _make_scan_pdfs.py          (run from base/test/ocr/_rig; needs Pillow)
#   python -I -X utf8 _make_scan_pdfs.py <page.png> <out.pdf>     one more twin (see below)
import io, zlib, sys
from PIL import Image

src = "../_data/z09_p1_150dpi.png"
im = Image.open(src)
W, H = im.size
pw, ph = W * 72 / 150, H * 72 / 150  # the page is the image at 150 dpi


def pdf(path, data, cs, filt, w, h):
    objs = []
    objs.append(b"<< /Type /Catalog /Pages 2 0 R >>")
    objs.append(b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>")
    objs.append(("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 %.2f %.2f] /Resources << /XObject << /Im1 4 0 R >> >> /Contents 5 0 R >>" % (pw, ph)).encode())
    objs.append(("<< /Type /XObject /Subtype /Image /Width %d /Height %d /ColorSpace /%s /BitsPerComponent 8 /Filter /%s /Length %d >>\nstream\n" % (w, h, cs, filt, len(data))).encode() + data + b"\nendstream")
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
    print(path, len(out.getvalue()), "bytes")


if len(sys.argv) == 3:
    # a TWIN: any 150-dpi page render as a greyscale Flate scan (O4: y11 and u06 page 1 beside z09's)
    #   python -I -X utf8 _make_scan_pdfs.py ../_data/y11_p1_150dpi.png ../_data/scan_y11_p1.pdf
    im = Image.open(sys.argv[1])
    W, H = im.size
    pw, ph = W * 72 / 150, H * 72 / 150
    g = im.convert("L")
    pdf(sys.argv[2], zlib.compress(g.tobytes(), 9), "DeviceGray", "FlateDecode", W, H)
    sys.exit(0)

g = im.convert("L")
pdf("../_data/scan_flate_gray.pdf", zlib.compress(g.tobytes(), 9), "DeviceGray", "FlateDecode", W, H)
rgb = im.convert("RGB")
jp = io.BytesIO()
rgb.save(jp, "JPEG", quality=80)
pdf("../_data/scan_dct_rgb.pdf", jp.getvalue(), "DeviceRGB", "DCTDecode", W, H)
