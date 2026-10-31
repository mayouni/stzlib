# _make_band_page.py -- a page whose footer is LIGHT TEXT ON A DARK BAND, photographed: a letterhead's navy band with
# an orange title and three lines of small light-grey type, under one paragraph of black body text, softened and
# JPEG-encoded the way a phone scan app writes it, wrapped as an image-only PDF sized in pixels. Every word on it is
# invented here; the expected lines are the ones drawn, written down below so a guard can hold the read against them.
#
#   python -I -X utf8 _make_band_page.py <out.pdf>     (Pillow; Windows' Arial)
import io, sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 1241, 1754  # A4 at 150 dpi
F = r"C:\Windows\Fonts\arial.ttf"
FB = r"C:\Windows\Fonts\arialbd.ttf"
BODY = ["Le service des archives reçoit le public du lundi au jeudi, de 8h30 à 16h00.",
        "Les demandes de copie sont traitées sous dix jours ouvrables.",
        "Chaque demande précise la référence du dossier et la période concernée.",
        "Les originaux ne quittent jamais la salle de lecture ; seules les copies",
        "certifiées peuvent être emportées par le demandeur ou son représentant.",
        "Une copie certifiée coûte deux cents francs la page, réglés au guichet.",
        "Les dossiers de plus de cinquante ans sont consultables sur rendez-vous.",
        "Les chercheurs inscrits disposent d'une place réservée dans la salle.",
        "La photographie sans flash est permise pour un usage personnel.",
        "Toute reproduction publiée mentionne le service et la cote du document.",
        "Le service est fermé les jours fériés et la dernière semaine d'août.",
        "Pour toute question, le personnel d'accueil se tient à votre disposition."]
TITLE = "OFFICE NATIONAL DES ARCHIVES NUMÉRIQUES"
LEFT = ["Registre : FR/PAR/03/2021/C17/00482 TVA : 41 286/K", "BP : 7 318 AGADEZ NIGER"]
RIGHT = ["QUARTIER NORD, AVENUE DES PALMIERS 118", "Tél : +227 20 44 17 63 - 227 96 52 18 40", "E-mail : accueil@archives.example"]

im = Image.new("RGB", (W, H), (250, 250, 248))
d = ImageDraw.Draw(im)
fb = ImageFont.truetype(F, 22)
y = 160
for line in BODY:
    d.text((100, y), line, font=fb, fill=(20, 20, 20))
    y += 34
top = H - 230
d.rectangle([0, top, W, H - 30], fill=(24, 30, 48))
ft = ImageFont.truetype(FB, 17)
fs = ImageFont.truetype(F, 15)
d.text((60, top + 50), TITLE, font=ft, fill=(232, 120, 40))
for i, line in enumerate(LEFT):
    d.text((60, top + 80 + 26 * i), line, font=fs, fill=(196, 198, 204))
for i, line in enumerate(RIGHT):
    d.text((700, top + 54 + 26 * i), line, font=fs, fill=(196, 198, 204))
im = im.filter(ImageFilter.GaussianBlur(0.9))
buf = io.BytesIO()
im.save(buf, "JPEG", quality=60)
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
print(sys.argv[1], len(o.getvalue()), "bytes")
