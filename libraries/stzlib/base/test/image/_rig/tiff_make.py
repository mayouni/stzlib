"""IM9b slice 2 fixtures: baseline TIFFs written by Pillow (libtiff), and what Pillow reads back from each -- the
ORACLE, a library that is not ours. The decoder under test is the engine's own (engine/src/tiff_decode.zig).

  t_<mode>_<codec>.tif   one 97 x 41 picture (odd sizes, so a transpose cannot pass by symmetry), in the mode
                         L, RGB, RGBA, LA, P and the codec raw, packbits, lzw, deflate, lzw_pred2, deflate_pred2
                         (a variant Pillow cannot write is skipped and named in the manifest, never faked)
  big_lzw.tif            300 x 200 RGB of seeded noise over structure: many strips, and an LZW table that fills
                         and resets (the case a small picture never reaches)
  be_rgb.tif             hand-built BIG-endian uncompressed RGB (Pillow writes little-endian)
  wiz_gray.tif           hand-built WhiteIsZero gray (0 is white)
  o6.tif                 the RGB picture with the Orientation tag set to 6
  bad_*.tif              files the reader must REFUSE by name: tiled, 16-bit, CMYK
  *_exp.png              what Pillow reads from each, in the plane's own layout (gray 1 channel, RGB 3, RGBA 4;
                         gray+alpha widened to RGBA; palette expanded to RGB; o6 turned upright)

Run: python tiff_make.py <out dir>   (the fixtures live outside the repository; this is their recipe).
"""
import os
import random
import struct
import sys

from PIL import Image, ImageOps

W, H = 97, 41


def structure(mode):
    base = Image.new("RGB", (W, H))
    px = base.load()
    for y in range(H):
        for x in range(W):
            px[x, y] = ((x * 5 + 3) % 256, (y * 6 + 7) % 256, (x * y + 13) % 256)
    for y in range(6):
        for x in range(6):
            px[x, y] = (255, 255, 255)
            px[W - 1 - x, H - 1 - y] = (0, 0, 0)
    if mode == "RGB":
        return base
    if mode == "L":
        return base.convert("L")
    if mode == "RGBA":
        a = Image.new("L", (W, H))
        ap = a.load()
        for y in range(H):
            for x in range(W):
                ap[x, y] = (x * 2 + y * 3) % 256
        out = base.copy()
        out.putalpha(a)
        return out
    if mode == "LA":
        g = base.convert("L")
        a = Image.new("L", (W, H))
        ap = a.load()
        for y in range(H):
            for x in range(W):
                ap[x, y] = (x * 3 + y) % 256
        return Image.merge("LA", (g, a))
    if mode == "P":
        return base.quantize(colors=64, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    raise ValueError(mode)


CODECS = {
    "raw": ({}, None),
    "packbits": ({"compression": "packbits"}, None),
    "lzw": ({"compression": "tiff_lzw"}, None),
    "deflate": ({"compression": "tiff_adobe_deflate"}, None),
    "lzw_pred2": ({"compression": "tiff_lzw"}, 2),
    "deflate_pred2": ({"compression": "tiff_adobe_deflate"}, 2),
}


def expected(path):
    im = Image.open(path)
    im.load()
    if im.mode == "P":
        im = im.convert("RGB")
    elif im.mode == "LA":
        im = im.convert("RGBA")
    elif im.mode not in ("L", "RGB", "RGBA"):
        im = im.convert("RGB")
    return im


def write_tiff(path, w, h, spp, photometric, data, big_endian, comp=1, tile_tags=False):
    """A minimal baseline TIFF: one strip, 8 bits, contiguous. The byte order is the point."""
    e = ">" if big_endian else "<"
    bo = b"MM" if big_endian else b"II"
    entries = []

    def ent(tag, typ, count, value):
        if typ == 3 and count == 1:
            packed = struct.pack(e + "HH", value, 0)
        elif typ == 3 and count == 3:
            packed = None
        else:
            packed = struct.pack(e + "I", value)
        entries.append((tag, typ, count, value, packed))

    nent = 9 + (4 if tile_tags else 0)
    ifd_off = 8
    ifd_size = 2 + 12 * nent + 4
    extra_off = ifd_off + ifd_size
    bps_off = extra_off
    extra = b""
    if spp == 3:
        extra = struct.pack(e + "HHH", 8, 8, 8)
    data_off = extra_off + len(extra)
    rows = [
        (256, 4, 1, w), (257, 4, 1, h),
        (258, 3, spp if spp == 3 else 1, bps_off if spp == 3 else 8),
        (259, 3, 1, comp), (262, 3, 1, photometric), (273, 4, 1, data_off), (277, 3, 1, spp),
        (278, 4, 1, h), (279, 4, 1, len(data)),
    ]
    if tile_tags:
        # TileWidth, TileLength, TileOffsets, TileByteCounts: a TIFF that says it is tiled
        rows += [(322, 3, 1, 16), (323, 3, 1, 16), (324, 4, 1, data_off), (325, 4, 1, len(data))]
    out = bo + struct.pack(e + "HI", 42, ifd_off) + struct.pack(e + "H", len(rows))
    for tag, typ, count, value in rows:
        if typ == 3 and count == 1:
            v = struct.pack(e + "HH", value, 0)
        else:
            v = struct.pack(e + "I", value)
        out += struct.pack(e + "HHI", tag, typ, count) + v
    out += struct.pack(e + "I", 0) + extra + data
    open(path, "wb").write(out)


def main(out):
    os.makedirs(out, exist_ok=True)
    notes = []
    n = 0
    for mode in ("L", "RGB", "RGBA", "LA", "P"):
        pic = structure(mode)
        for name, (kw, pred) in CODECS.items():
            path = os.path.join(out, f"t_{mode}_{name}.tif")
            try:
                tags = {}
                if pred:
                    from PIL.TiffImagePlugin import ImageFileDirectory_v2
                    ifd = ImageFileDirectory_v2()
                    ifd[317] = pred
                    pic.save(path, format="TIFF", tiffinfo=ifd, **kw)
                else:
                    pic.save(path, format="TIFF", **kw)
                chk = Image.open(path)
                chk.load()
                if pred and 317 not in chk.tag_v2:
                    os.remove(path)
                    notes.append(f"skipped {mode} {name}: Pillow wrote no predictor tag")
                    continue
            except Exception as ex:
                if os.path.exists(path):
                    os.remove(path)
                notes.append(f"skipped {mode} {name}: {type(ex).__name__}: {ex}")
                continue
            expected(path).save(os.path.join(out, f"t_{mode}_{name}_exp.png"))
            n += 1
    # many strips and an LZW table that fills and resets
    rnd = random.Random(20261103)
    big = Image.new("RGB", (300, 200))
    bp = big.load()
    for y in range(200):
        for x in range(300):
            if (x // 16 + y // 16) % 3 == 0:
                bp[x, y] = (rnd.randrange(256), rnd.randrange(256), rnd.randrange(256))
            else:
                bp[x, y] = ((x * 3) % 256, (y * 5) % 256, ((x + y) * 7) % 256)
    big.save(os.path.join(out, "big_lzw.tif"), format="TIFF", compression="tiff_lzw")
    expected(os.path.join(out, "big_lzw.tif")).save(os.path.join(out, "big_lzw_exp.png"))
    n += 1
    # big endian, hand-built
    rgb = structure("RGB")
    write_tiff(os.path.join(out, "be_rgb.tif"), W, H, 3, 2, rgb.tobytes(), True)
    expected(os.path.join(out, "be_rgb.tif")).save(os.path.join(out, "be_rgb_exp.png"))
    # white is zero
    g = structure("L")
    write_tiff(os.path.join(out, "wiz_gray.tif"), W, H, 1, 0, g.tobytes(), False)
    expected(os.path.join(out, "wiz_gray.tif")).save(os.path.join(out, "wiz_gray_exp.png"))
    # orientation tag 6, upright by Pillow
    from PIL.TiffImagePlugin import ImageFileDirectory_v2
    ifd = ImageFileDirectory_v2()
    ifd[274] = 6
    rgb.save(os.path.join(out, "o6.tif"), format="TIFF", tiffinfo=ifd)
    ImageOps.exif_transpose(Image.open(os.path.join(out, "o6.tif"))).convert("RGB").save(os.path.join(out, "o6_exp.png"))
    # files that must be refused
    Image.new("I;16", (8, 8), 1000).save(os.path.join(out, "bad_16bit.tif"), format="TIFF")
    Image.new("CMYK", (8, 8), (1, 2, 3, 4)).save(os.path.join(out, "bad_cmyk.tif"), format="TIFF")
    # Pillow drops the tile tags on a strip file, so the tiled header is hand-built
    write_tiff(os.path.join(out, "bad_tiled.tif"), W, H, 3, 2, rgb.tobytes(), False, tile_tags=True)
    with open(os.path.join(out, "MANIFEST_TIFF.tsv"), "w", encoding="utf-8", newline="\n") as f:
        f.write(f"{n} readable fixtures with their Pillow readings (*_exp.png)\n")
        for line in notes:
            f.write(line + "\n")
    print("wrote", n, "readable TIFF fixtures;", len(notes), "variants skipped")
    for line in notes:
        print("  ", line)


if __name__ == "__main__":
    main(sys.argv[1])
