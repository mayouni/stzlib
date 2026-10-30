# _degrade_scans.py -- a 150-dpi golden page render made to look like a PHONE SCAN, wrapped as an image-only PDF
# the way a scan app writes one: the page sized in pixels (one point per pixel), the image JPEG-encoded. Each effect
# is one thing a real scan does that a rendered page does not:
#   paper    the paper is not white: grey 232 with noise (sigma 6)
#   tilt     the sheet is turned half a degree
#   shadow   the photographed page's border: a dark band down the left edge and along the bottom
#   blur     the camera's softness (Gaussian, radius 0.7 px)
#   jpeg     JPEG at quality 65
#   phone    all of the above together
# The twin is the born-digital golden page itself: its blocks are what the reader should find in the scan.
#
#   python -I -X utf8 _degrade_scans.py <page.png> <effect> <out.pdf>     (run with Pillow + numpy)
import io, sys
import numpy as np
from PIL import Image, ImageFilter

src, effect, out = sys.argv[1], sys.argv[2], sys.argv[3]
im = Image.open(src).convert("L")
effects = ["paper", "tilt", "shadow", "blur", "jpeg"] if effect == "phone" else [effect]
rng = np.random.default_rng(42)

if "tilt" in effects:
    im = im.rotate(0.5, resample=Image.BICUBIC, fillcolor=255)
if "blur" in effects:
    im = im.filter(ImageFilter.GaussianBlur(0.7))
a = np.asarray(im, dtype=np.float32)
if "paper" in effects:
    a = a * (232.0 / 255.0) + rng.normal(0, 6, a.shape)
if "shadow" in effects:
    h, w = a.shape
    left = np.clip(1.0 - np.linspace(1, 0, 60)[None, :] * 0.75, 0, 1)  # dark at the very edge, fading in 60 px
    a[:, :60] *= left
    bottom = np.clip(1.0 - np.linspace(0, 1, 40)[:, None] * 0.7, 0, 1)
    a[h - 40:, :] *= bottom
im = Image.fromarray(np.clip(a, 0, 255).astype(np.uint8))
W, H = im.size
q = 65 if "jpeg" in effects else 92
buf = io.BytesIO()
im.convert("RGB").save(buf, "JPEG", quality=q)
data = buf.getvalue()
pw, ph = float(W), float(H)  # a scan app's page: one point per pixel

objs = [b"<< /Type /Catalog /Pages 2 0 R >>", b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
        ("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 %.2f %.2f] /Resources << /XObject << /Im1 4 0 R >> >> /Contents 5 0 R >>" % (pw, ph)).encode(),
        ("<< /Type /XObject /Subtype /Image /Width %d /Height %d /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length %d >>\nstream\n" % (W, H, len(data))).encode() + data + b"\nendstream"]
content = ("q %.2f 0 0 %.2f 0 0 cm /Im1 Do Q" % (pw, ph)).encode()
objs.append(b"<< /Length %d >>\nstream\n" % len(content) + content + b"\nendstream")
o = io.BytesIO()
o.write(b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n")
offs = []
for i, ob in enumerate(objs, 1):
    offs.append(o.tell())
    o.write(b"%d 0 obj\n" % i + ob + b"\nendobj\n")
x = o.tell()
o.write(b"xref\n0 %d\n0000000000 65535 f \n" % (len(objs) + 1))
for of in offs:
    o.write(b"%010d 00000 n \n" % of)
o.write(b"trailer\n<< /Size %d /Root 1 0 R >>\nstartxref\n%d\n%%%%EOF\n" % (len(objs) + 1, x))
open(out, "wb").write(o.getvalue())
print(out, effect, len(o.getvalue()), "bytes")
