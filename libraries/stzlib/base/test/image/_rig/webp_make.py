"""IM9b slice 3 fixtures: WebP files written by Pillow (libwebp), and what Pillow reads back from each -- the ORACLE,
a library that is not ours (it is the same upstream codec, which is the point: the vendored decoder must agree with
the reference). The decoder under test is the engine's, libwebp 1.5.0 vendored (engine/vendor/libwebp).

  w_lossless_rgb.webp    97 x 41 RGB, lossless      (exact: every byte must equal the reading)
  w_lossless_rgba.webp   the same with an alpha ramp
  w_lossy_rgb.webp       lossy, quality 80          (a lossy file decodes to one defined picture: compared byte for byte
                                                     with Pillow's reading, and the measured difference is printed)
  w_lossy_rgba.webp      lossy with an alpha ramp
  w_big_lossy.webp       300 x 200 of noise over structure, lossy quality 60 (many macroblocks, the loop filter at work)
  w_o6.webp              lossless, with an EXIF chunk saying orientation 6
  w_anim.webp            two frames: the engine must REFUSE it by name
  w_junk.webp            a RIFF/WEBP header over garbage: refused, not crashed on
  *_exp.png              what Pillow reads from each (RGB 3 channels, RGBA 4); w_o6 turned upright by exif_transpose

Run: python webp_make.py <out dir>   (the fixtures live outside the repository; this is their recipe).
"""
import os
import random
import sys

from PIL import Image, ImageOps, features

W, H = 97, 41


def structure(alpha):
    base = Image.new("RGB", (W, H))
    px = base.load()
    for y in range(H):
        for x in range(W):
            px[x, y] = ((x * 5 + 3) % 256, (y * 6 + 7) % 256, (x * y + 13) % 256)
    for y in range(6):
        for x in range(6):
            px[x, y] = (255, 255, 255)
            px[W - 1 - x, H - 1 - y] = (0, 0, 0)
    if not alpha:
        return base
    a = Image.new("L", (W, H))
    ap = a.load()
    for y in range(H):
        for x in range(W):
            ap[x, y] = (x * 2 + y * 3) % 256
    out = base.copy()
    out.putalpha(a)
    return out


def read_back(path):
    im = Image.open(path)
    im.load()
    return im.convert("RGBA" if im.mode == "RGBA" else "RGB")


def main(out):
    os.makedirs(out, exist_ok=True)
    rows = []
    for name, alpha, kw in (
        ("w_lossless_rgb", False, {"lossless": True}),
        ("w_lossless_rgba", True, {"lossless": True}),
        ("w_lossy_rgb", False, {"quality": 80, "method": 4}),
        ("w_lossy_rgba", True, {"quality": 80, "method": 4, "alpha_quality": 100}),
    ):
        structure(alpha).save(os.path.join(out, name + ".webp"), format="WEBP", **kw)
        read_back(os.path.join(out, name + ".webp")).save(os.path.join(out, name + "_exp.png"))
        rows.append(name)
    rnd = random.Random(20261103)
    big = Image.new("RGB", (300, 200))
    bp = big.load()
    for y in range(200):
        for x in range(300):
            if (x // 16 + y // 16) % 3 == 0:
                bp[x, y] = (rnd.randrange(256), rnd.randrange(256), rnd.randrange(256))
            else:
                bp[x, y] = ((x * 3) % 256, (y * 5) % 256, ((x + y) * 7) % 256)
    big.save(os.path.join(out, "w_big_lossy.webp"), format="WEBP", quality=60, method=4)
    read_back(os.path.join(out, "w_big_lossy.webp")).save(os.path.join(out, "w_big_lossy_exp.png"))
    rows.append("w_big_lossy")
    ex = Image.Exif()
    ex[0x0112] = 6
    structure(False).save(os.path.join(out, "w_o6.webp"), format="WEBP", lossless=True, exif=ex)
    ImageOps.exif_transpose(Image.open(os.path.join(out, "w_o6.webp"))).convert("RGB").save(os.path.join(out, "w_o6_exp.png"))
    f1, f2 = structure(False), structure(False).transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    f1.save(os.path.join(out, "w_anim.webp"), format="WEBP", save_all=True, append_images=[f2], duration=100, lossless=True)
    with open(os.path.join(out, "w_junk.webp"), "wb") as f:
        f.write(b"RIFF" + (40).to_bytes(4, "little") + b"WEBP" + b"VP8 " + bytes(range(7, 40)))
    with open(os.path.join(out, "MANIFEST_WEBP.tsv"), "w", encoding="utf-8", newline="\n") as f:
        f.write("Pillow %s, libwebp %s\n" % (Image.__version__, features.version("webp")))
        for r in rows:
            f.write(r + "\n")
    print("wrote", len(rows), "readable WebP fixtures; Pillow's libwebp", features.version("webp"))


if __name__ == "__main__":
    main(sys.argv[1])
