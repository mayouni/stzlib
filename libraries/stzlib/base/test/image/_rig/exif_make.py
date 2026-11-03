"""IM9b fixtures: one asymmetric picture stored under each of the eight EXIF orientations, and its upright
form from Pillow's own ImageOps.exif_transpose -- the ORACLE, written by a library that is not ours.

  o<n>.png        the same pixels with an eXIf chunk saying orientation n (lossless: the guard can be pixel-exact)
  o<n>.jpg        the same, as a JPEG with an APP1 Exif segment (quality 100, no subsampling)
  o<n>_up.png     Pillow's upright form of o<n>.png (what the guard must reproduce exactly)
  o<n>_jpg_up.png Pillow's upright form of o<n>.jpg, decoded by libjpeg (the guard compares within a stated
                  tolerance: two decoders differ by a rounding in the inverse DCT)
  gps.jpg         a JPEG whose Exif segment carries a GPS block (the guard saves it and reads the bytes back)
  gps.png         the same, as a PNG eXIf chunk
  MANIFEST.tsv    what was written and the pixels' own checksum

Run: python exif_make.py <out dir>   (the fixtures live outside the repository; this is their recipe).
The picture is 61 x 37 -- odd on both sides, so a transpose or a half turn cannot pass by symmetry -- with a white
block in the top-left corner, a black block in the bottom-right and a gradient in each channel that depends on x, on y
and on both, so every orientation puts every pixel somewhere different.
"""
import hashlib
import os
import sys

from PIL import Image, ImageOps

W, H = 61, 37


def picture():
    im = Image.new("RGB", (W, H))
    px = im.load()
    for y in range(H):
        for x in range(W):
            px[x, y] = ((x * 4 + 3) % 256, (y * 7 + 5) % 256, (x * y + 11) % 256)
    for y in range(5):
        for x in range(5):
            px[x, y] = (255, 255, 255)
            px[W - 1 - x, H - 1 - y] = (0, 0, 0)
    return im


def exif_with(orientation, gps=False):
    ex = Image.Exif()
    ex[0x0112] = orientation
    if gps:
        g = ex.get_ifd(0x8825)
        g[1] = "N"
        g[2] = (48.0, 51.0, 24.0)
        g[3] = "E"
        g[4] = (2.0, 21.0, 7.0)
    return ex


def main(out):
    os.makedirs(out, exist_ok=True)
    base = picture()
    rows = []
    for o in range(1, 9):
        ex = exif_with(o)
        base.save(os.path.join(out, f"o{o}.png"), exif=ex)
        base.save(os.path.join(out, f"o{o}.jpg"), quality=100, subsampling=0, exif=ex)
        ImageOps.exif_transpose(Image.open(os.path.join(out, f"o{o}.png"))).convert("RGB").save(os.path.join(out, f"o{o}_up.png"))
        ImageOps.exif_transpose(Image.open(os.path.join(out, f"o{o}.jpg"))).convert("RGB").save(os.path.join(out, f"o{o}_jpg_up.png"))
        up = Image.open(os.path.join(out, f"o{o}_up.png"))
        rows.append((o, up.size, hashlib.sha256(up.tobytes()).hexdigest()[:16]))
    gx = exif_with(1, gps=True)
    base.save(os.path.join(out, "gps.jpg"), quality=95, exif=gx)
    base.save(os.path.join(out, "gps.png"), exif=gx)
    chk = Image.open(os.path.join(out, "gps.jpg")).getexif().get_ifd(0x8825)
    assert chk.get(1) == "N", "the GPS block did not survive into the fixture"
    with open(os.path.join(out, "MANIFEST.tsv"), "w", encoding="utf-8", newline="\n") as f:
        f.write("orientation\tupright size\tupright sha256 (16)\n")
        for o, size, h in rows:
            f.write(f"{o}\t{size[0]}x{size[1]}\t{h}\n")
        f.write("gps\tgps.jpg and gps.png carry GPS 48 51 24 N, 2 21 7 E\n")
    print("wrote", len(rows), "orientations and the GPS pair to", out)


if __name__ == "__main__":
    main(sys.argv[1])
