# _make_figure_page.py -- a letter whose COLOURED ink is both drawn and written: a letterhead logo (a red emblem beside
# dark letters), a blue round stamp signed across, and against them the coloured ink that IS text -- a blue title, a
# title in two colours, a blue heading -- and a bar chart's coloured bars under black labels. Scanned clean (JPEG, as
# a scanner writes it), wrapped as an image-only PDF sized in pixels. Every word on it is invented here.
#
#   python -I -X utf8 _make_figure_page.py <out.pdf> [<look.png>]     (Pillow; Windows' Arial)
import io, math, sys
from PIL import Image, ImageDraw, ImageFont

W, H = 1241, 1754  # A4 at 150 dpi
F = r"C:\Windows\Fonts\arial.ttf"
FB = r"C:\Windows\Fonts\arialbd.ttf"
BLUE = (28, 70, 170)
INK = (25, 25, 25)

im = Image.new("RGB", (W, H), (250, 250, 248))
d = ImageDraw.Draw(im)
# the logo: a red and orange emblem, a zigzag as tall as the letters, set tight against them
x, y = 90, 70
for k, col in enumerate([(214, 40, 48), (236, 128, 36)]):
    yo = y + 44 * k
    d.polygon([(x + 30, yo), (x, yo + 22), (x + 30, yo + 44), (x + 40, yo + 36), (x + 18, yo + 22), (x + 40, yo + 8)], fill=col)
d.text((x + 50, y + 2), "VTR", font=ImageFont.truetype(FB, 80), fill=(60, 60, 64))
# the title in blue, and a title in two colours, taller than two and a half lines
ft = ImageFont.truetype(FB, 58)
d.text((150, 250), "RAPPORT DE VISITE", font=ft, fill=BLUE)
f2 = ImageFont.truetype(FB, 76)
d.text((150, 330), "Bilan", font=f2, fill=INK)
d.text((150 + d.textlength("Bilan ", font=f2), 330), "2025", font=f2, fill=(236, 128, 36))
fb = ImageFont.truetype(F, 24)
fh = ImageFont.truetype(FB, 28)
d.text((150, 470), "Objet de la visite", font=fh, fill=BLUE)
BODY = ["La visite du chantier a eu lieu le mardi matin en présence du chef de",
        "projet et de deux techniciens. Les travaux de terrassement sont achevés",
        "et le coulage des fondations commencera la semaine prochaine.",
        "Les livraisons de ciment ont pris trois jours de retard."]
yy = 520
for line in BODY:
    d.text((150, yy), line, font=fb, fill=INK)
    yy += 38
# a bar chart: coloured bars, black labels under them
base = 960
for i, (v, lab) in enumerate([(180, "Lundi"), (120, "Mardi"), (220, "Mercredi"), (90, "Jeudi")]):
    bx = 200 + i * 190
    d.rectangle([bx, base - v, bx + 90, base], fill=[(40, 120, 200), (230, 120, 40), (60, 160, 90), (200, 60, 70)][i])
    d.text((bx, base + 12), lab, font=fb, fill=INK)
d.text((150, 1060), "Fait à Agadez, le 3 mars 2026", font=fb, fill=INK)
d.text((760, 1130), "Le Chef de Service", font=fb, fill=INK)
# the stamp: a blue double ring, its words inside, signed across
cx, cy, r = 880, 1330, 125
d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=BLUE, width=6)
d.ellipse([cx - r + 18, cy - r + 18, cx + r - 18, cy + r - 18], outline=BLUE, width=2)
fs = ImageFont.truetype(FB, 30)
for i, t in enumerate(["SERVICE", "TECHNIQUE"]):
    tw = d.textlength(t, font=fs)
    d.text((cx - tw / 2, cy - 40 + 42 * i), t, font=fs, fill=BLUE)
pts = [(cx - 190 + 8 * k, cy - 20 + 40 * math.sin(k / 3.0) - 2 * k) for k in range(48)]
d.line(pts, fill=(20, 40, 120), width=4)
buf = io.BytesIO()
im.save(buf, "JPEG", quality=88)
data = buf.getvalue()

objs = [b"<< /Type /Catalog /Pages 2 0 R >>", b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
        ("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 %d %d] /Resources << /XObject << /Im1 4 0 R >> >> /Contents 5 0 R >>" % (W, H)).encode(),
        ("<< /Type /XObject /Subtype /Image /Width %d /Height %d /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length %d >>\nstream\n" % (W, H, len(data))).encode() + data + b"\nendstream"]
content = ("q %d 0 0 %d 0 0 cm /Im1 Do Q" % (W, H)).encode()
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
open(sys.argv[1], "wb").write(o.getvalue())
if len(sys.argv) > 2:
    im.save(sys.argv[2])  # the page as drawn, to look at
print(sys.argv[1], len(o.getvalue()), "bytes")
